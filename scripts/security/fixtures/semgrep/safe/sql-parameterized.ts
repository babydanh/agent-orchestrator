// FIXTURE AN TOÀN (negative case) cho quy tắc SQL: không được báo bất kỳ vị trí nào.
declare const pool: { query: (sql: string, params?: unknown[]) => Promise<unknown> };
declare const sql: (strings: TemplateStringsArray, ...values: unknown[]) => unknown;
declare const id: string;
declare const text: string;
declare const values: unknown[];

const SELECT_ACTIVE = "SELECT * FROM users WHERE active = true";

pool.query("SELECT * FROM users WHERE id = $1", [id]);
pool.query(`SELECT * FROM users WHERE active = true`);
pool.query(text, values);
pool.query(SELECT_ACTIVE);
const fragment = sql`SELECT * FROM users WHERE id = ${id}`;
