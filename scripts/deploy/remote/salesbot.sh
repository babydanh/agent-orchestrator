# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app> <sha> <chủ GHCR> <origin dashboard|''> <url embed|''> <profiles>
# Bộ Docker của salesbot-admin (deploy/docker): gói file đã chép lên $APP_DIR/.deploy-pkg.tgz; giải nén đè compose,
# init.sh, db-init, mẫu matrix (không đụng secrets/, matrix/, models/), init.sh tạo secret còn thiếu, đặt SALESBOT_TAG,
# pull, bật lại stack, kiểm sức khoẻ. Lỗi thì quay về tag trước. Migration chỉ thêm (expand), nên code cũ chạy được
# trên schema mới; migration không lùi.
APP_DIR="$1"
SHA="$2"
OWNER="$3"
ORIGIN="$4"
EMBED_URL="$5"
PROFILES="$6"
# Không cần root: log nằm trong thư mục app (quyền 700), không phải /var/log.
DEPLOY_LOG_DIR="$APP_DIR/deploy-logs"
init_log "salesbot-${SHA:0:8}"
cd "$APP_DIR"

if [[ ! -f secrets/api.env && -z "$ORIGIN" ]]; then
  echo "LỖI  lần đầu cần input origin (vd https://dash.example.com)"
  exit 1
fi
logged "giải nén gói deploy" tar -xzf .deploy-pkg.tgz -C "$APP_DIR"
rm -f .deploy-pkg.tgz

# KEY=value trong .env của compose (không phải secret): thay tại chỗ hoặc thêm.
set_env() {
  touch .env
  grep -v "^$1=" .env >.env.tmp || true
  printf '%s=%s\n' "$1" "$2" >>.env.tmp
  mv .env.tmp .env
}
init_args=()
[[ -z "$ORIGIN" ]] || init_args+=(--origin "$ORIGIN")
[[ -z "$EMBED_URL" ]] || init_args+=(--embed-url "$EMBED_URL")
if [[ "$PROFILES" != keep ]]; then
  [[ "$PROFILES" != *embed* || -n "$EMBED_URL" ]] || init_args+=(--with-embed)
  [[ "$PROFILES" != *messenger* ]] || init_args+=(--with-matrix)
  set_env COMPOSE_PROFILES "$([[ "$PROFILES" == none ]] || echo "$PROFILES")"
fi
# bash < 4.4 under set -u treats an empty "${arr[@]}" as unbound; expand only when non-empty.
logged "init.sh (secret còn thiếu, không đổi secret đã có)" sh init.sh ${init_args[@]+"${init_args[@]}"}

PREV="$(sed -n 's/^SALESBOT_TAG=//p' .env | tail -n 1)"
set_env GHCR_OWNER "$OWNER"
set_env SALESBOT_TAG "$SHA"

pull_all() {
  local attempt
  for attempt in 1 2 3; do
    timeout 15m docker compose pull --quiet && return 0
    echo "pull lần $attempt/3 lỗi" >&2
  done
  return 1
}
logged "docker compose pull" pull_all

# api /health trả {"ok":true} khi DB + Redis sống; web /login qua cổng loopback của host; 9router (20128) và gateway
# (18789) phải nhận kết nối: "running" không đủ, container đang restart liên tục vẫn có lúc là running. Chưa đăng
# nhập Zalo vẫn là trạng thái hợp lệ của bản mới.
healthy() {
  local port
  port="$(sed -n 's/^WEB_PORT=//p' .env | tail -n 1)"
  docker compose exec -T api node -e "
    const net = require('net');
    const open = (p) => new Promise((ok, no) => net.connect(p, '127.0.0.1').on('connect', function () { this.end(); ok(); }).on('error', no));
    fetch('http://127.0.0.1:3400/health').then((r) => r.json())
      .then((b) => (b.ok ? Promise.all([open(20128), open(18789)]) : Promise.reject()))
      .then(() => process.exit(0), () => process.exit(1));" || return 1
  curl -fsS -o /dev/null --max-time 10 "http://127.0.0.1:${port:-3300}/login" || return 1
  docker compose ps --status running --services | grep -qx watchdog
}
# Lần đầu gateway còn tải plugin zalouser/matrix từ npm, nên chờ tới 5 phút.
wait_healthy() {
  local _
  for _ in $(seq 1 60); do
    healthy >/dev/null 2>&1 && return 0
    sleep 5
  done
  return 1
}

if logged "docker compose up -d" docker compose up -d && logged "chờ api/web/bot khoẻ (tối đa 300 giây)" wait_healthy; then
  logged "docker image prune" docker image prune -f || echo "CẢNH BÁO: prune lỗi; bỏ qua."
  echo "OK    salesbot chạy bản ${SHA:0:8}"
  exit 0
fi
logged "trạng thái container" docker compose ps -a || true
if [[ -z "$PREV" || "$PREV" == "$SHA" ]]; then
  echo "LỖI  bản mới không khoẻ, không có tag trước để quay về"
  exit 1
fi
set_env SALESBOT_TAG "$PREV"
logged "quay về ${PREV:0:8}" docker compose up -d && logged "chờ bản cũ khoẻ" wait_healthy || true
echo "LỖI  bản ${SHA:0:8} không khoẻ, đã quay về ${PREV:0:8}; chi tiết trong log trên VPS"
exit 1
