# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app prod> <apply: true|false>.
# Nạp danh bạ sân vào DB PRODUCTION trong container `migrate` (mượn network + DB_* của compose prod; runner không có
# đường tới DB prod). Apply: pg_dump backup TRƯỚC, kiểm bằng pg_restore --list, rồi mới ghi. Prod chưa có ranh giới
# phường nên seed chạy với --allow-no-regions (province_code/ward_code NULL; tìm sân không dùng chúng).
# Output thô (tên sân, địa chỉ, SQL) chỉ vào log trên VPS; log Actions chỉ có dòng số đếm trong whitelist bên dưới.
APP_DIR="$1"
APPLY="$2"
DATA=/tmp/sporto-venue-seed/venue-directory.json
init_log "backend-prod-seed-venues"
trap 'rm -f "$DATA"' EXIT
cd "$APP_DIR"

[[ -s "$DATA" ]] || { echo "LỖI  thiếu file dữ liệu sân trên VPS"; exit 1; }

# Image prod phải là bản đã có cờ --allow-no-regions (deploy a1b2f605 trở lên).
logged "kiểm image có seed-venue-directory.js mới" docker compose run --rm -T migrate node -e \
  "if(!require('fs').readFileSync('seed-venue-directory.js','utf8').includes('--allow-no-regions'))process.exit(3)"

flag=""
if [[ "$APPLY" == "true" ]]; then
  flag="--apply"
  backup="/var/backups/sporto-prod-before-venues-$(date +%Y%m%d%H%M%S).dump"
  mkdir -p /var/backups
  umask 077
  logged "pg_dump backup DB prod" bash -c "docker compose exec -T postgres sh -c 'pg_dump -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" -Fc' > '$backup'"
  size="$(stat -c %s "$backup")"
  ((size > 1048576)) || { echo "LỖI  file backup quá nhỏ ($size byte); dừng, chưa ghi gì"; exit 1; }
  entries="$(docker compose exec -T postgres pg_restore --list <"$backup" | grep -c . || true)"
  ((entries > 20)) || { echo "LỖI  pg_restore --list chỉ thấy $entries mục; dừng, chưa ghi gì"; exit 1; }
  echo "OK    backup: $backup ($size byte, $entries mục)"
fi

out="$(mktemp)"
set +e
docker compose run --rm -T -v "$DATA:/tmp/venue-directory.json:ro" migrate \
  node seed-venue-directory.js --file /tmp/venue-directory.json --allow-no-regions $flag >"$out" 2>&1
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
echo "OK    seed sân prod ($([[ -n "$flag" ]] && echo apply || echo dry-run))"
