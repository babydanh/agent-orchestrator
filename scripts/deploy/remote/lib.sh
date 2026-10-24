# Nạp trước mỗi script chạy trên VPS (scripts/deploy/remote.sh ghép lib.sh + script, chép lên VPS rồi chạy):
#   bash scripts/deploy/remote.sh <script>.sh <tham số...>
# Log Actions của repo này là công khai. Output thô (SQL migrate, dữ liệu DB, log container, cấu hình) chỉ ghi vào
# file trên VPS (/var/log/sporto-deploy, quyền 700); log Actions chỉ có tên bước, OK/LỖI và exit code.
set -euo pipefail

DEPLOY_LOG_DIR=/var/log/sporto-deploy
DEPLOY_LOG=/dev/null

# init_log <tên>: mở file log của lượt deploy này.
init_log() {
  mkdir -p "$DEPLOY_LOG_DIR"
  chmod 700 "$DEPLOY_LOG_DIR"
  DEPLOY_LOG="$DEPLOY_LOG_DIR/$1-$(date +%Y%m%d-%H%M%S).log"
  : >"$DEPLOY_LOG"
  echo "Log đầy đủ trên VPS: $DEPLOY_LOG"
}

# logged <tên bước> <lệnh...>: chạy lệnh, output vào log VPS. Lỗi thì in tên bước + exit code, trả mã lỗi của lệnh.
logged() {
  local name="$1"
  shift
  echo "== $name" >>"$DEPLOY_LOG"
  "$@" >>"$DEPLOY_LOG" 2>&1 && {
    echo "OK    $name"
    return 0
  }
  local code=$?
  echo "LỖI  $name (exit $code); chi tiết trong $DEPLOY_LOG trên VPS"
  return "$code"
}

# pull_retry <image>: docker pull nối tiếp được từ layer đã tải, nên thử lại 3 lần rẻ hơn một lần chờ dài.
pull_retry() {
  local image="$1" attempt
  for attempt in 1 2 3; do
    if timeout 10m docker pull "$image" >>"$DEPLOY_LOG" 2>&1; then
      echo "OK    pull $image"
      return 0
    fi
    echo "Pull $image lần $attempt/3 lỗi."
  done
  echo "LỖI  pull $image sau 3 lần; chi tiết trong $DEPLOY_LOG trên VPS"
  return 1
}

# api_get <url>: GET kèm x-app-key (đọc từ biến APP_API_KEY). Header đi qua --config để khoá không nằm trong argv (ps).
api_get() {
  curl --fail --silent --show-error --max-time 15 \
    --config <(printf 'header = "x-app-key: %s"\n' "$APP_API_KEY") "$@"
}
