// FIXTURE KIỂM THỬ QUY TẮC SEMGREP: lỗi giả có chủ đích. Không import, không chạy, không dùng trong build.
declare const pool: { query: (sql: string, params?: unknown[]) => Promise<unknown> };
declare const db: { $queryRawUnsafe: (sql: string) => Promise<unknown> };
declare const id: string;
declare const userName: string;

const byTemplate = pool.query(`SELECT * FROM users WHERE id = ${id}`);
const byConcat = db.$queryRawUnsafe("SELECT * FROM users WHERE name = '" + userName + "'");
