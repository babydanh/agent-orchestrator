#!/usr/bin/env bash
# Job e2e của agent-task.yml: chạy E2E của việc bằng test-runner.yml, rồi chạy lại đúng các spec có test đỏ trên nhánh
# nền (hoặc main) để tách test do việc này làm đỏ khỏi test vốn đã đỏ từ trước. Agent chỉ được gọi sửa test đỏ mới.
#
# Env vào:  GH_TOKEN, REPO, REQ (mã yêu cầu duy nhất), SPECS,
#           WEB_REF / BACKEND_REF (nhánh của việc, không có thì nhánh nền, rỗng = main),
#           BASE_WEB_REF / BASE_BACKEND_REF (nhánh nền, rỗng = main).
# Ra stdout (nối vào $GITHUB_OUTPUT): run_id, conclusion, failed (số test đỏ mới), preexisting (số test đỏ có sẵn),
#           base_run_id, fingerprint (dấu danh sách test đỏ mới). Ghi failed.txt, preexisting.txt ở thư mục hiện tại.
# conclusion=no_task_branch: không repo nào có nhánh của việc, E2E không kiểm được gì nên không chạy.
set -uo pipefail
export LC_ALL=C

FIND_WAIT=${E2E_FIND_SECONDS:-10}
POLL_WAIT=${E2E_POLL_SECONDS:-60}
: > failed.txt
: > preexisting.txt

emit() {
  echo "run_id=${RUN_ID:-}"
  echo "conclusion=$CONCLUSION"
  echo "failed=$(wc -l < failed.txt | tr -d ' ')"
  echo "preexisting=$(wc -l < preexisting.txt | tr -d ' ')"
  echo "base_run_id=${BASE_RUN_ID:-}"
  echo "fingerprint=$(sha256sum failed.txt | cut -c1-16)"
}

# run_e2e <request_id> <web_ref> <backend_ref> <specs> <file>: chạy test-runner, chờ xong, ghi test đỏ vào <file>,
# in "<run_id> <conclusion>". Không tìm thấy lượt chạy thì trả 1.
run_e2e() {
  local req=$1 web=$2 backend=$3 specs=$4 out=$5 id="" status="" conclusion
  gh workflow run test-runner.yml --repo "$REPO" -f target_project=fullstack-e2e \
    -f web_ref="$web" -f backend_ref="$backend" -f specs="$specs" -f request_id="$req" -f no_report=true >&2 || return 1
  for _ in $(seq 1 30); do
    sleep "$FIND_WAIT"
    id=$(gh run list --repo "$REPO" --workflow test-runner.yml --limit 30 --json databaseId,displayTitle \
      --jq ".[] | select(.displayTitle | endswith(\"#$req\")) | .databaseId" | head -n 1)
    [ -n "$id" ] && break
  done
  [ -n "$id" ] || return 1
  echo "Run E2E web=${web:-main} backend=${backend:-main}: https://github.com/$REPO/actions/runs/$id" >&2
  # Hỏi trạng thái mỗi phút thay vì `gh run watch`: watch rớt mạng là thoát sớm khi run còn chạy.
  for _ in $(seq 1 140); do
    status=$(gh run view "$id" --repo "$REPO" --json status --jq .status 2>/dev/null || echo unknown)
    [ "$status" = completed ] && break
    sleep "$POLL_WAIT"
  done
  conclusion=$(gh run view "$id" --repo "$REPO" --json conclusion --jq .conclusion 2>/dev/null || echo unknown)
  [ "$status" = completed ] || conclusion=timed_out_waiting
  # Test đỏ = dòng ✘ của Playwright (gồm cả lượt chạy lại). Bỏ dòng:cột để so được giữa hai nhánh khi spec bị sửa.
  gh run view "$id" --repo "$REPO" --log 2>/dev/null \
    | grep -a -oE '✘ +[0-9]+ \[[a-z]+\] › [^(]+' \
    | sed -E 's/^✘ +[0-9]+ //; s/(\.spec\.ts):[0-9]+:[0-9]+/\1/; s/ +$//' | sort -u > "$out" || true
  echo "$id $conclusion"
}

if [ "${WEB_REF:-}" = "${BASE_WEB_REF:-}" ] && [ "${BACKEND_REF:-}" = "${BASE_BACKEND_REF:-}" ]; then
  CONCLUSION=no_task_branch
  emit
  exit 0
fi

if ! read -r RUN_ID CONCLUSION < <(run_e2e "$REQ" "${WEB_REF:-}" "${BACKEND_REF:-}" "${SPECS:-}" task-failed.txt); then
  echo "::error::Không thấy run test-runner của yêu cầu $REQ" >&2
  exit 1
fi
cp task-failed.txt failed.txt

if [ "$CONCLUSION" != success ] && [ -s task-failed.txt ]; then
  base_specs=$(grep -oE 'test/e2e/[A-Za-z0-9_./-]+\.spec\.ts' task-failed.txt | sort -u | tr '\n' ' ')
  if read -r BASE_RUN_ID _ < <(run_e2e "$REQ-base" "${BASE_WEB_REF:-}" "${BASE_BACKEND_REF:-}" "${base_specs% }" base-failed.txt); then
    comm -12 task-failed.txt base-failed.txt > preexisting.txt
    comm -23 task-failed.txt base-failed.txt > failed.txt
  else
    BASE_RUN_ID=""
    echo "::warning::Không chạy lại được trên nhánh nền, coi mọi test đỏ là của việc này" >&2
  fi
fi
emit
