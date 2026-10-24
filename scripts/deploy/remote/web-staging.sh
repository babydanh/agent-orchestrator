# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging> <sha> <sha256 của NEXT_PUBLIC_APP_API_KEY đã build vào image>.
# Chuyển từ deploy-staging.yml của repo Web: kéo :staging, tạo lại frontend của compose staging, giữ nguyên prod.
STAGING_DIR="$1"
SHA="$2"
KEY_SHA="$3"
COMPOSE_FILE="$STAGING_DIR/docker-compose.yml"
ENV_FILE="$STAGING_DIR/.env.staging"
IMAGE=ghcr.io/babydanh/hethongfrontendweb_qlgiaidau:staging
# Container prod dùng chung VPS; deploy staging không được đụng nó.
PROD_CONTAINER=qlgiaidau-frontend
init_log "web-staging-${SHA:0:8}"

# Backend staging tạo compose và .env staging; chưa có thì phải deploy Backend staging trước.
for f in "$COMPOSE_FILE" "$ENV_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "LỖI  chưa có $(basename "$f") của staging; deploy Backend staging trước."
    exit 1
  fi
done
check_app_key "$ENV_FILE" "$KEY_SHA"
staging_compose() {
  docker compose -p sporto-staging -f "$COMPOSE_FILE" --env-file "$ENV_FILE" "$@"
}

prod_before="$(docker inspect --format '{{.Id}}' "$PROD_CONTAINER" 2>/dev/null || echo none)"
pull_retry "$IMAGE"
logged "bật frontend staging" staging_compose up -d --no-deps frontend

prod_after="$(docker inspect --format '{{.Id}}' "$PROD_CONTAINER" 2>/dev/null || echo none)"
if [[ "$prod_before" != "$prod_after" ]]; then
  echo "LỖI  container prod $PROD_CONTAINER đổi ID trong lúc deploy staging"
  exit 1
fi
echo "OK    container prod $PROD_CONTAINER giữ nguyên ID"

# Smoke cổng nội bộ của frontend staging, chờ tối đa khoảng 60 giây.
code=000
for _ in $(seq 1 30); do
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://172.17.0.1:3101/ || true)"
  [[ "$code" == "200" ]] && break
  sleep 2
done
if [[ "$code" != "200" ]]; then
  {
    staging_compose ps frontend
    staging_compose logs --tail=120 frontend
  } >>"$DEPLOY_LOG" 2>&1 || true
  echo "LỖI  smoke frontend staging trả HTTP $code; log container nằm trong $DEPLOY_LOG"
  exit 1
fi
echo "OK    smoke frontend staging: HTTP 200"

logged "docker image prune" docker image prune -f || echo "CẢNH BÁO: prune lỗi sau khi deploy staging; bỏ qua."
