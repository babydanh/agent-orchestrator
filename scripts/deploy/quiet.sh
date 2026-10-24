#!/usr/bin/env bash
# quiet.sh <tên bước> <lệnh...>
# Repo này public: log Actions ai cũng đọc. Output thô của build/test/migrate (đoạn code, SQL, stack trace của repo
# private) đi vào file tạm rồi bị xoá; log chỉ có OK, hoặc khi lỗi là tối đa 20 dòng có chữ error/fail (cắt 200 ký tự).
# QUIET_SUMMARY=<regex>: khi xanh, in thêm tối đa 5 dòng khớp (vd dòng tổng kết của jest).
set -uo pipefail
name="$1"
shift
log="$(mktemp)"
trap 'rm -f "$log"' EXIT
"$@" >"$log" 2>&1
code=$?
if ((code == 0)); then
  echo "OK    $name"
  if [[ -n "${QUIET_SUMMARY:-}" ]]; then
    grep -E "$QUIET_SUMMARY" "$log" | tail -n 5 | cut -c1-200 || true
  fi
  exit 0
fi
echo "::error::$name lỗi (exit $code)"
grep -iE 'error|fail' "$log" | grep -vE '^[[:space:]]+at ' | tail -n 20 | cut -c1-200 || true
exit "$code"
