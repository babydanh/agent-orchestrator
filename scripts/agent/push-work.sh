#!/usr/bin/env bash
# Bước 7 của agent-task.yml: gom MỌI việc agent đã làm trong từng repo rồi đẩy lên nhánh của issue, không để mất code.
#
#   push-work.sh <nhánh> <thư mục repo>...        (chạy trong thư mục workspace chứa các repo đã clone)
#
# Mỗi repo:
#   1. Thay đổi chưa commit ở thư mục clone và ở MỌI git worktree agent tạo: commit tại chỗ (issue #19 mất việc vì
#      agent làm trong worktree mà bước cũ chỉ xem thư mục clone). Worktree ở nhánh khác: gộp vào nhánh cần đẩy.
#   2. Nhánh trên origin đã có commit mới trong lúc agent chạy (người dùng/session khác đẩy thêm): fetch rồi merge
#      vào (issue #17 mất 18 file vì push bị từ chối "fetch first" và job dừng). Merge xung đột: KHÔNG ép, đẩy việc
#      của agent sang nhánh riêng <nhánh>-agent-run<RUN_ID>.
#   3. Báo số file nhánh khác origin/main: 0 file nghĩa là agent không để lại code (báo "xong" mà nhánh rỗng).
#
# Đẩy qua remote `origin` (bước 4 đặt credential helper đọc $GH_PAT, URL remote không chứa token).
# Ghi PUSHED_REPOS (nhiều dòng) vào $GITHUB_ENV nếu có. Exit 1 nếu có repo không đẩy được; repo khác vẫn được xử lý.
set -uo pipefail

BRANCH="${1:?thiếu tên nhánh}"
shift
ISSUE="${ISSUE_NUMBER:-?}"
RUN="${RUN_ID:-${GITHUB_RUN_ID:-local}}"
BASE="${BASE_REF:-origin/main}"
ALL_REPORT=()
FAILED=0

say() { printf '%s\n' "$*"; }
warn() { printf '::warning::%s\n' "$*"; }
worktrees() { git worktree list --porcelain | awk '/^worktree /{print substr($0,10)}'; }
holder_of() { git worktree list --porcelain | awk -v b="branch refs/heads/$1" '/^worktree /{w=substr($0,10)} $0==b{print w}'; }

commit_dirty() {  # $1 = thư mục: commit mọi thay đổi chưa commit
  [ -z "$(git -C "$1" status --porcelain)" ] && return 0
  git -C "$1" add -A
  git -C "$1" commit -q -m "chore(agent): tự commit phần agent chưa commit cho issue #$ISSUE" && say ">>> đã tự commit việc dở trong $1"
}

push_repo() {  # chạy trong thư mục repo; in các dòng báo cáo ra fd 3
  local repo="$1" target_wt wt wt_head side n
  tmp_wt=""  # toàn cục trong subshell: trap EXIT dọn worktree tạm
  target_wt=$(holder_of "$BRANCH")

  ensure_target() {  # worktree giữ $BRANCH (tạo nhánh từ $1 nếu chưa có, tạo worktree tạm nếu không ai giữ)
    [ -n "$target_wt" ] && return 0
    git rev-parse -q --verify "refs/heads/$BRANCH" >/dev/null || git branch "$BRANCH" "$1"
    tmp_wt="$(mktemp -d)/wt"
    git worktree add -q "$tmp_wt" "$BRANCH" && target_wt="$tmp_wt"
  }

  # 1a. Việc dở ở thư mục clone mà nhánh chưa ở đâu cả: chuyển việc đó sang nhánh tại chỗ. Nhánh đã có (commit của
  # agent) thì KHÔNG reset nó (checkout -B sẽ xoá các commit đó): đưa việc dở sang nhánh tạm, bước 1c gộp vào.
  if [ -n "$(git status --porcelain)" ] && [ -z "$target_wt" ]; then
    if git rev-parse -q --verify "refs/heads/$BRANCH" >/dev/null; then
      git checkout -q -b "$BRANCH-wip-$RUN"
    else
      git checkout -q -b "$BRANCH"
      target_wt=$(holder_of "$BRANCH")
    fi
  fi
  # 1b. Commit mọi việc dở: thư mục clone + mọi worktree. Commit hỏng (hook, quyền...) là việc chưa được lưu:
  # báo lỗi, không coi repo là đã gom xong.
  while IFS= read -r wt; do
    if ! commit_dirty "$wt" || [ -n "$(git -C "$wt" status --porcelain)" ]; then
      warn "$repo: KHÔNG commit được việc dở trong $wt, việc này chưa được đẩy"
      echo "- $repo: việc dở trong \`$wt\` KHÔNG commit được, chưa được lưu (xem log)" >&3
      FAILED=1
    fi
  done < <(worktrees)
  # 1c. Việc ở worktree khác nhánh: gộp vào nhánh cần đẩy.
  while IFS= read -r wt; do
    [ "$wt" = "$target_wt" ] || [ "$wt" = "$tmp_wt" ] && continue
    wt_head=$(git -C "$wt" rev-parse HEAD)
    git merge-base --is-ancestor "$wt_head" "$BASE" 2>/dev/null && continue  # chỉ là main: không có việc
    ensure_target "$wt_head" || { warn "$repo: không tạo được worktree cho $BRANCH"; FAILED=1; continue; }
    git -C "$target_wt" merge-base --is-ancestor "$wt_head" HEAD && continue
    if git -C "$target_wt" merge -q --no-edit "$wt_head"; then
      say ">>> $repo: đã gộp việc trong worktree $wt vào $BRANCH"
    else
      git -C "$target_wt" merge --abort || true
      side="$BRANCH-worktree-$(basename "$wt")"
      if git push -q origin "$wt_head:refs/heads/$side"; then
        warn "$repo: worktree $wt xung đột với $BRANCH, đã đẩy riêng lên $side"
        echo "- $repo: nhánh \`$side\` (worktree xung đột với $BRANCH, gộp tay)" >&3
      else
        FAILED=1
      fi
    fi
  done < <(worktrees)

  if ! git rev-parse -q --verify "refs/heads/$BRANCH" >/dev/null; then
    say ">>> $repo: không có nhánh $BRANCH, bỏ qua"
    return 0
  fi

  # 2. origin/$BRANCH có commit mới trong lúc agent chạy: gộp vào trước khi đẩy (không force).
  if git fetch -q origin "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH" 2>/dev/null \
     && ! git merge-base --is-ancestor "origin/$BRANCH" "refs/heads/$BRANCH"; then
    ensure_target "origin/$BRANCH"
    if git -C "$target_wt" merge -q --no-edit "origin/$BRANCH"; then
      say ">>> $repo: origin/$BRANCH có commit mới trong lúc agent chạy, đã gộp vào trước khi đẩy"
    else
      git -C "$target_wt" merge --abort || true
      side="$BRANCH-agent-run$RUN"
      if git push -q origin "refs/heads/$BRANCH:refs/heads/$side"; then
        warn "$repo: việc của agent xung đột với commit mới trên origin/$BRANCH, đã đẩy riêng lên $side"
        echo "- $repo: nhánh \`$side\` (xung đột với commit mới trên $BRANCH, gộp tay)" >&3
      else
        FAILED=1
      fi
      return 0
    fi
  fi

  if ! git push -q -u origin "refs/heads/$BRANCH:refs/heads/$BRANCH"; then
    side="$BRANCH-agent-run$RUN"
    if git push -q origin "refs/heads/$BRANCH:refs/heads/$side"; then
      warn "$repo: push $BRANCH bị từ chối, đã đẩy riêng lên $side"
      echo "- $repo: nhánh \`$side\` (push $BRANCH bị từ chối)" >&3
    else
      FAILED=1
    fi
    return 0
  fi

  # 3. Nhánh có code thật không.
  git fetch -q origin "+refs/heads/${BASE#origin/}:refs/remotes/$BASE" 2>/dev/null || true
  n=$(git diff --name-only "$BASE...refs/heads/$BRANCH" 2>/dev/null | wc -l | tr -d ' ')
  echo "- $repo: nhánh \`$BRANCH\`, $n file khác ${BASE#origin/}" >&3
  [ "$n" = "0" ] && warn "$repo: nhánh $BRANCH KHÔNG khác ${BASE#origin/} (agent không để lại code)."
  say ">>> $repo: đã đẩy $BRANCH ($n file khác ${BASE#origin/})"
  return 0
}

for dir in "$@"; do
  [ -e "$dir/.git" ] || continue
  report=$(mktemp)
  if ! ( cd "$dir" && FAILED=0 && tmp_wt="" \
         && trap '[ -n "$tmp_wt" ] && git worktree remove --force "$tmp_wt" >/dev/null 2>&1' EXIT \
         && push_repo "$dir" 3>>"$report" && exit "$FAILED" ); then
    FAILED=1
    warn "$dir: có phần không đẩy được, xem log ở trên"
  fi
  while IFS= read -r line; do [ -n "$line" ] && ALL_REPORT+=("$line"); done < "$report"
  rm -f "$report"
done

[ ${#ALL_REPORT[@]} -eq 0 ] && ALL_REPORT=("(không repo nào có nhánh $BRANCH)")
printf '%s\n' "${ALL_REPORT[@]}"
if [ -n "${GITHUB_ENV:-}" ]; then
  { echo "PUSHED_REPOS<<PUSHED_EOF"; printf '%s\n' "${ALL_REPORT[@]}"; echo "PUSHED_EOF"; } >> "$GITHUB_ENV"
fi
exit "$FAILED"
