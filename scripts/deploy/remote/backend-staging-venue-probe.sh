# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging>.
# Gọi thử GET /social-locations/search trên backend staging (cổng nội bộ, kèm x-app-key đọc từ .env.staging).
# CHỈ ĐỌC. Log Actions công khai: chỉ in mã HTTP, số kết quả, số có isVerified/mã vùng, độ trễ (ms). Không in tên/địa chỉ sân.
STAGING_DIR="$1"
init_log "backend-staging-venue-probe"
APP_API_KEY="$(sed -n 's/^APP_API_KEY=//p' "$STAGING_DIR/.env.staging" | tail -n 1 | tr -d "\"'\r")"
export APP_API_KEY
command -v python3 >/dev/null || { echo "LỖI  VPS không có python3"; exit 1; }
script="$(mktemp)"
trap 'rm -f "$script"' EXIT
cat >"$script" <<'PY'
import json, os, time, urllib.parse, urllib.request, urllib.error
BASE = "http://172.17.0.1:3100/api/v1"
KEY = os.environ["APP_API_KEY"]

def get(path, params=None):
    url = BASE + path + ("?" + urllib.parse.urlencode(params) if params else "")
    req = urllib.request.Request(url, headers={"x-app-key": KEY})
    t = time.perf_counter()
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            body, code = r.read(), r.status
    except urllib.error.HTTPError as e:
        body, code = b"", e.code
    return code, (time.perf_counter() - t) * 1000, body

code, _, body = get("/categories")
cats = json.loads(body) if code == 200 else []
cats = cats.get("data", cats) if isinstance(cats, dict) else cats
cat = next((c["id"] for c in cats if "pickle" in str(c.get("name", "")).lower()), None)
print(f"categories: http={code} pickleball_id={'có' if cat else 'KHÔNG TÌM THẤY'}")

cases = [("pickleball", None), ("sân", None), ("sân", cat), ("tennis", None)]
for q, cid in cases:
    params = {"q": q, "limit": 10}
    if cid: params["categoryId"] = cid
    lat, code, rows = [], 0, []
    for _ in range(3):  # tổng 12 lần, dưới trần 20 lần/phút
        code, ms, body = get("/social-locations/search", params)
        lat.append(ms)
        if code == 200: rows = json.loads(body)
    verified = sum(1 for r in rows if "isVerified" in r)
    region = sum(1 for r in rows if r.get("provinceCode") and r.get("wardCode"))
    tag = "q=%s%s" % (q, "+categoryId" if cid else "")
    print(f"{tag}: http={code} ketqua={len(rows)} co_isVerified={verified} co_maVung={region} do_tre_ms_max={max(lat):.0f}")
PY
python3 "$script" 2>>"$DEPLOY_LOG" || { echo "LỖI  probe lỗi; chi tiết trong $DEPLOY_LOG trên VPS"; exit 1; }
echo "OK    probe search staging"
