# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging> <apply: true|false>.
# Nạp danh bạ sân vào DB staging trong container `migrate` (mượn network + DB_* của compose staging).
# Output thô (tên sân, địa chỉ, SQL) chỉ vào log trên VPS; log Actions chỉ có dòng số đếm trong whitelist bên dưới.
STAGING_DIR="$1"
APPLY="$2"
DATA="$STAGING_DIR/tmp/venue-directory.json"
init_log "backend-staging-seed-venues"
trap 'rm -f "$DATA"' EXIT
staging_compose() {
  docker compose -p sporto-staging -f "$STAGING_DIR/docker-compose.yml" --env-file "$STAGING_DIR/.env.staging" "$@"
}

[[ -s "$DATA" ]] || { echo "LỖI  thiếu file dữ liệu sân trên VPS"; exit 1; }

# Migration sân chạy cùng deploy; chạy lại ở đây để chắc (idempotent, cùng lệnh với deploy).
logged "migrate staging" staging_compose --profile tools run --rm -T migrate node run-prod-migration.js

flag=""
[[ "$APPLY" == "true" ]] && flag="--apply"
out="$(mktemp)"
set +e
staging_compose --profile tools run --rm -T -v "$DATA:/tmp/venue-directory.json:ro" migrate \
  node seed-venue-directory.js --file /tmp/venue-directory.json $flag >"$out" 2>&1
rc=$?
set -e
{ echo "== seed-venue-directory $flag"; cat "$out"; } >>"$DEPLOY_LOG"

# Whitelist: tiêu đề báo cáo, số sân theo môn, số không có phường, lý do bỏ qua (số đếm), inserted=N, dòng lỗi ❌.
grep -E '^(DRY-RUN|Sẽ ghi|ĐÃ GHI).*: [0-9]+ sân$|^  [^ ].{0,12} +[0-9]+$|Không có phường phủ điểm|^  Bỏ qua:|^inserted=[0-9]+$|^❌' "$out" | cut -c1-200 || true
rm -f "$out"
if ((rc != 0)); then
  echo "LỖI  seed sân (exit $rc); chi tiết trong $DEPLOY_LOG trên VPS"
  exit "$rc"
fi
echo "OK    seed sân ($([[ -n "$flag" ]] && echo apply || echo dry-run))"
