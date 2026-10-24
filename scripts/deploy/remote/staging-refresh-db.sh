# Chạy trên VPS (sau lib.sh). Tham số: <thư mục staging>.
# Xoá DB staging và chép lại từ bản sao prod (refresh-db.sh của repo Backend, nhánh staging).
STAGING_DIR="$1"
init_log "staging-refresh-db"
logged "chép lại DB staging từ prod (ghi đè)" bash "$STAGING_DIR/deploy/refresh-db.sh"
