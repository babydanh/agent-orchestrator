# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging>.
# Gọi thử GET /social-locations/search trên backend staging (cổng nội bộ, kèm x-app-key đọc từ .env.staging).
# CHỈ ĐỌC. Log Actions công khai: chỉ in mã HTTP, số kết quả, số có isVerified/mã vùng, độ trễ (ms). Không in tên/địa chỉ sân.
STAGING_DIR="$1"
init_log "backend-staging-venue-probe"
APP_API_KEY="$(sed -n 's/^APP_API_KEY=//p' "$STAGING_DIR/.env.staging" | tail -n 1 | tr -d "\"'\r")"
BASE="http://172.17.0.1:3100/api/v1"
body="$(mktemp)"
trap 'rm -f "$body"' EXIT

# Id môn Pickleball từ /categories (khớp object có chữ pickleball, lấy "id").
api_get -o "$body" -w '%{http_code}' "$BASE/categories" >"$body.code" 2>>"$DEPLOY_LOG" || true
cat_http="$(cat "$body.code")"; rm -f "$body.code"
cat_id="$(tr '{' '
' <"$body" | grep -i pickleball | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -n 1 || true)"
echo "categories: http=$cat_http pickleball_id=$([[ -n "$cat_id" ]] && echo có || echo KHÔNG_TÌM_THẤY)"

# probe <nhãn> <q> [categoryId]: 3 lần gọi, in số kết quả của lần cuối và độ trễ lớn nhất (tổng 12 lần, dưới trần 20 lần/phút).
probe() {
  local tag="$1" q="$2" cid="${3:-}" args=(-G --data-urlencode "q=$q" --data-urlencode "limit=10") i meta code max=0 ms
  [[ -n "$cid" ]] && args+=(--data-urlencode "categoryId=$cid")
  for i in 1 2 3; do
    meta="$(api_get "${args[@]}" -o "$body" -w '%{http_code} %{time_total}' "$BASE/social-locations/search" 2>>"$DEPLOY_LOG" || true)"
    code="${meta% *}"
    ms="$(awk -v t="${meta#* }" 'BEGIN{printf "%d", t*1000}')"
    if ((ms > max)); then max=$ms; fi
  done
  # grep không khớp trả 1; với set -e + pipefail sẽ giết script, nên mọi lệnh đếm có || true.
  local n v r
  n="$( (grep -o '"venueId"' "$body" || true) | wc -l)"
  v="$( (grep -o '"isVerified"' "$body" || true) | wc -l)"
  r="$( (grep -oE '"wardCode":"[^"]+"' "$body" || true) | wc -l)"
  echo "$tag: http=$code ketqua=$n co_isVerified=$v co_maPhuong=$r do_tre_ms_max=$max"
}
probe "q=pickleball" "pickleball"
probe "q=sân" "sân"
[[ -n "$cat_id" ]] && probe "q=sân+categoryId(pickleball)" "sân" "$cat_id"
probe "q=tennis" "tennis"
echo "OK    probe search staging"
