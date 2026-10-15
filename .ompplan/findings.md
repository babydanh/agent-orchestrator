# Phát hiện Node 3

## Files và triển khai
- Source: `D:/DevTools/botkeep-cluster-final/node3-sqlite-semgrep/` gồm `server.js`, manifest/lock, README và test.
- Archive cũ `D:/DevTools/botkeep-node3-sqlite.zip` được giữ nguyên. ZIP mới: `D:/DevTools/botkeep-node3-sqlite-v2.zip` (4 file, không `node_modules`).
- Gateway catalog: `D:/DevTools/botkeep-cluster-final/node1-gateway-filter/server.js`; MCP review đổi tên thành `code_security_review`, package version 2.0.0.
- Botkeep docs `botkeep.cloud/docs/nodejs` yêu cầu `package.json` + `package-lock.json`, không upload `node_modules`; `botkeep.cloud/docs/hosting` dùng profile runtime riêng cho app và tài nguyên chia sẻ.
- Botkeep public docs `botkeep.cloud` chưa xác minh được là đúng instance domain `bot-keep.xyz`; không coi là runtime probe Cloud.

## Contracts hiện tại
- `/sqlite` response `{ success: true, results: [{ columns: string[], values: any[][] }] }`; health `/` public; các route còn lại yêu cầu Bearer token.
- `/review` response `{ engine, passed, totalIssues, issues }`, input `code` và optional `language` (`javascript`, `typescript`, `dart`).
- `/validate-diff` response `{ safeToApply, totalWarnings, warnings }`.
- `/quicktype` response `{ target, className, code }`, input `{ json, className?, target? }`.
- `/drizzle-lens` và `/schema-lens` response `{ dialect, totalTables, totalEnums, totalRelations, schemaCheatSheet }`.

## Baseline trước rebuild
- SQL cũ dùng `Map` + JSON và regex; fallback có thể trả success giả.
- Quicktype cũ là generator tự viết, không phải `quicktype-core`.
- Code review cũ dựa trên regex, không phải Semgrep.
- Drizzle lens cũ regex trên source và không thực thi schema.

## Xác minh local

- `node:sqlite` chạy local trên Node 24.14; Node phát `ExperimentalWarning`. Load smoke 5 route đồng thời: baseline RSS 58 MiB; 2 lần đọc health ghi nhận cao nhất 240 MiB; Windows `PeakWorkingSet64` là 241.6 MiB. Workload cục bộ, không phải Cloud.
- Health check cũ từng báo 32 MiB trước rebuild; đó là điểm đo tức thời, không phải peak.
- Botkeep docs hướng dẫn Node/Python profile riêng; Python trên Node3 chưa xác minh.

## NPM versions/compatibility
- Registry metadata: `quicktype-core@26.0.0` requires Node >=20; unpacked 4.17 MB.
- `eslint@10.12.0` requires Node `^20.19.0 || ^22.13.0 || >=24`.
- `eslint-plugin-security@4.2.0`, `eslint-plugin-no-secrets@2.3.3` support Node >=18/18.18.
- `@typescript-eslint/parser@8.71.1` supports ESLint 10 but requires TypeScript <6.1; use `typescript@6.0.3` (not 7.x).
- Các phiên bản trên đã cài; `npm ls --depth=0` xác nhận đủ package và `npm test` pass 11/11 trên Node v24.14.0.

## Ràng buộc
- No Semgrep Cloud API/code upload without explicit consent.
- SQLite options support `returnArrays` and SQL limits in Node docs; preserve column/value arrays.
- Cloud data is inaccessible locally; support safe legacy `db_storage.json` migration without deleting source JSON.
