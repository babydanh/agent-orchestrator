# Chạy trên VPS (sau lib.sh). Tham số: <thư mục app prod> <tournament_id> <DIRECT|PAYOS>.
# Đổi tournaments.fee_collection_mode của ĐÚNG MỘT giải, trong container `migrate` (mượn network + DB_* của
# compose prod; runner không có đường tới DB prod). Log Actions là công khai nên script chỉ in chế độ trước/sau.
APP_DIR="$1"
TOURNAMENT_ID="$2"
MODE="$3"
init_log "backend-tournament-fee-mode-${TOURNAMENT_ID:0:8}"
cd "$APP_DIR"

JS=$(cat <<'NODE'
const postgres = require('postgres');
const [id, mode] = process.argv.slice(1);
const sql = process.env.DATABASE_URL
  ? postgres(process.env.DATABASE_URL, { ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false, prepare: false, max: 1 })
  : postgres({
      host: process.env.DB_HOST || 'postgres',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      username: process.env.DB_USERNAME || process.env.DB_USER || process.env.POSTGRES_USER || 'postgres',
      password: process.env.DB_PASSWORD || process.env.POSTGRES_PASSWORD || 'postgres',
      database: process.env.DB_DATABASE || process.env.DB_NAME || process.env.POSTGRES_DB || 'tournament_db',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
      prepare: false,
      max: 1,
    });
(async () => {
  const before = await sql`SELECT fee_collection_mode AS m FROM tournaments WHERE id = ${id}`;
  if (before.length !== 1) {
    console.log('NOT_FOUND: khong co giai nay');
    process.exitCode = 2;
    return;
  }
  const after = await sql`UPDATE tournaments SET fee_collection_mode = ${mode} WHERE id = ${id} RETURNING fee_collection_mode AS m`;
  console.log(`before=${before[0].m} after=${after[0].m} rows=${after.length}`);
})()
  .catch((err) => {
    console.log(`LOI: ${err.code || err.message}`);
    process.exitCode = 1;
  })
  .finally(() => sql.end({ timeout: 5 }));
NODE
)

# -T: no TTY; output (only before/after mode) is safe for the public log.
docker compose run --rm -T migrate node -e "$JS" "$TOURNAMENT_ID" "$MODE"
