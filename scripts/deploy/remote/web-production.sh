# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app prod> <sha>.
# Chuyển từ deploy.yml của repo Web: kéo :latest, thay container frontend.
APP_DIR="$1"
SHA="$2"
IMAGE=ghcr.io/babydanh/hethongfrontendweb_qlgiaidau:latest
init_log "web-production-${SHA:0:8}"
cd "$APP_DIR"

pull_retry "$IMAGE"

remove_old_frontend() {
  docker compose stop frontend || true
  docker compose rm -f frontend || true
  docker rm -f qlgiaidau-frontend || true
  docker ps -a --filter "name=frontend" --format "{{.ID}}" | xargs -r docker rm -f || true
}
logged "gỡ container frontend cũ" remove_old_frontend
logged "bật frontend" docker compose up -d --no-deps frontend
logged "docker image prune" docker image prune -f || echo "CẢNH BÁO: prune lỗi sau khi deploy; bỏ qua."
