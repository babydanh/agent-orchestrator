#!/usr/bin/env bash
# remote.sh <script trong scripts/deploy/remote/> [tham số...]
# Chạy script đó trên VPS qua $RUNNER_TEMP/ssh-vps (ssh-setup.sh tạo), nạp lib.sh trước. Script được ghi ra file tạm
# trên VPS rồi mới chạy: chạy thẳng từ stdin (bash -s) thì lệnh con đọc stdin (vd `docker compose run`, mặc định
# giữ stdin mở) sẽ nuốt phần còn lại của script. Tham số được quote bằng printf %q.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
script="$1"
shift
cat "$dir/remote/lib.sh" "$dir/remote/$script" |
  "$RUNNER_TEMP/ssh-vps" "f=\$(mktemp) && cat >\"\$f\" && bash \"\$f\" $(printf '%q ' "$@") </dev/null; rc=\$?; rm -f \"\$f\"; exit \$rc"
