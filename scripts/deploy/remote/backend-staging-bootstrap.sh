# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging> <sha> <file secret tạm>.
# File secret (quyền 600) do bước trước ghi qua stdin; nạp vào môi trường rồi xoá ngay khi script kết thúc.
STAGING_DIR="$1"
SHA="$2"
SECRETS_FILE="$3"
trap 'rm -f "$SECRETS_FILE"' EXIT
init_log "backend-staging-bootstrap-${SHA:0:8}"
set -a
# shellcheck disable=SC1090
. "$SECRETS_FILE"
set +a
logged "bootstrap cấu hình staging (compose, vhost, htpasswd)" bash "$STAGING_DIR/deploy/bootstrap.sh"
