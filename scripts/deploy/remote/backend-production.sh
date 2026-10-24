# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app prod> <sha>.
# Chuyển từ deploy.yml của repo Backend: kéo :latest, migrate (dry-run rồi thật), thay container backend, smoke API.
APP_DIR="$1"
SHA="$2"
IMAGE=ghcr.io/babydanh/hethongbackendapi_quanlygiaidau:latest
init_log "backend-production-${SHA:0:8}"
cd "$APP_DIR"
sed -i "s#giaidau\.vnvar\.com#sporto.asia#g" .env

APP_API_KEY="$(sed -n 's/^APP_API_KEY=//p' .env | head -n 1)"
if [[ -z "$APP_API_KEY" ]]; then
  echo "LỖI  .env trên VPS thiếu APP_API_KEY"
  exit 1
fi
# Backend đang tắt (lần deploy trước lỗi) thì vẫn deploy để khôi phục.
api_get "https://sporto.asia/api/v1/categories" >/dev/null 2>&1 || echo "Backend đang không trả lời; deploy bản mới để khôi phục."

pull_retry "$IMAGE"
logged "migrate (dry-run)" docker compose run --rm migrate node run-prod-migration.js --dry-run
logged "migrate" docker compose run --rm migrate

remove_old_backend() {
  docker compose stop backend || true
  docker compose rm -f backend || true
  docker rm -f qlgiaidau-backend || true
  docker ps -a --filter "name=backend" --format "{{.ID}}" | xargs -r docker rm -f || true
}
logged "gỡ container backend cũ" remove_old_backend
logged "bật backend" docker compose up -d --no-deps backend

for attempt in 1 2 3 4 5 6; do
  if api_get "https://sporto.asia/api/v1/categories" >/dev/null 2>>"$DEPLOY_LOG"; then
    echo "OK    smoke /categories (lần $attempt)"
    break
  fi
  if ((attempt == 6)); then
    docker compose logs --tail=200 backend >>"$DEPLOY_LOG" 2>&1 || true
    echo "LỖI  smoke /categories sau khi bật backend; log container nằm trong $DEPLOY_LOG"
    exit 1
  fi
  sleep 5
done

if ! wards="$(api_get "https://sporto.asia/api/v1/regions/wards?provinceCode=30" 2>>"$DEPLOY_LOG")"; then
  docker compose logs --tail=200 backend >>"$DEPLOY_LOG" 2>&1 || true
  echo "LỖI  smoke /regions/wards bị từ chối; log container nằm trong $DEPLOY_LOG"
  exit 1
fi
if ! printf '%s' "$wards" | grep -q '"data"'; then
  echo "LỖI  smoke /regions/wards trả sai dạng"
  exit 1
fi
echo "OK    smoke /regions/wards"

logged "docker image prune" docker image prune -f || echo "CẢNH BÁO: prune lỗi sau khi smoke đã xanh; bỏ qua."
