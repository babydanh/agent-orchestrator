# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging> <sha> <refresh_db: true|false>.
# Chuyển từ deploy-staging.yml của repo Backend (phần sau bootstrap và kiểm khoá): pull, postgres/redis,
# làm mới DB khi cần, migrate, bật backend (frontend chỉ khi chưa chạy), smoke cổng nội bộ.
STAGING_DIR="$1"
SHA="$2"
REFRESH_DB="$3"
init_log "backend-staging-${SHA:0:8}"
staging_compose() {
  docker compose -p sporto-staging -f "$STAGING_DIR/docker-compose.yml" --env-file "$STAGING_DIR/.env.staging" "$@"
}

# Frontend do deploy Web staging quản lý (pull + tạo lại); không pull ở đây để hai lượt không đua nhau tạo lại nó.
logged "pull migrate + backend staging" staging_compose --profile tools pull migrate backend
logged "postgres + redis staging" staging_compose up -d --wait postgres redis

# Mặc định chỉ chép DB prod khi DB staging còn trống; refresh_db=true (input hoặc commit có [refresh-db]) thì chép đè.
if [[ "$REFRESH_DB" == "true" ]]; then
  logged "chép lại DB staging từ prod (ghi đè)" bash "$STAGING_DIR/deploy/refresh-db.sh"
else
  logged "chép DB prod nếu DB staging trống" bash "$STAGING_DIR/deploy/refresh-db.sh" --if-empty
fi

logged "migrate staging (dry-run)" staging_compose --profile tools run --rm migrate node run-prod-migration.js --dry-run
logged "migrate staging" staging_compose --profile tools run --rm migrate node run-prod-migration.js
logged "bật backend staging" staging_compose up -d --no-deps backend

# Chỉ dựng frontend khi container chưa chạy (lần đầu hoặc bị xoá) và image đã có trên VPS.
if ! docker ps --format '{{.Names}}' | grep -qx sporto-staging-web &&
  docker image inspect ghcr.io/babydanh/hethongfrontendweb_qlgiaidau:staging >/dev/null 2>&1; then
  logged "bật frontend staging (đang không chạy)" staging_compose up -d --no-deps frontend
fi

APP_API_KEY="$(sed -n 's/^APP_API_KEY=//p' "$STAGING_DIR/.env.staging" | tail -n 1 | tr -d "\"'\r")"
for attempt in 1 2 3 4 5 6; do
  if api_get http://172.17.0.1:3100/api/v1/categories >/dev/null 2>>"$DEPLOY_LOG"; then
    echo "OK    smoke backend staging (lần $attempt)"
    exit 0
  fi
  sleep 5
done
docker logs --tail 200 sporto-staging-api >>"$DEPLOY_LOG" 2>&1 || true
echo "LỖI  smoke backend staging không trả 200; log container nằm trong $DEPLOY_LOG"
exit 1
