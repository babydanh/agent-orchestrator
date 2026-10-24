# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app prod> <sha>.
# Nạp provinces/wards v2 SAU migrate, trong container `migrate` (mượn network + DB_* của compose prod;
# runner không có đường tới DB prod).
# KHÔNG chạy seed-ward-boundaries.js: nguồn ranh giới (3321 phường) chỉ phủ 80% danh mục v2 (3452 phường),
# gắn nhầm polygon còn tệ hơn không có. Lý do đầy đủ: comment cùng bước trong deploy.yml của repo Backend.
APP_DIR="$1"
SHA="$2"
init_log "backend-seed-regions-${SHA:0:8}"
cd "$APP_DIR"
logged "nạp provinces/wards v2" docker compose run --rm migrate node seed-regions-v2.js
