# Kế hoạch: dựng lại ZIP Node 3

## Mục tiêu
Thay engine giả của Node 3 bằng engine thật chạy được cục bộ trên Node 24; không giả định quota Cloud 2 GiB và không gửi source code tới dịch vụ ngoài.

## Phạm vi
- `sqlite_query`: dùng `node:sqlite`, lưu file SQLite có quota, giữ response `{ columns, values }` và di trú `db_storage.json` nếu có.
- `quicktype_generator`: dùng package chính chủ `quicktype-core`; dependency được cài từ `package.json`/`package-lock.json` khi Botkeep build, không đưa `node_modules` vào ZIP.
- `code_security_review`: Node profile chưa chứng minh có Python. Không đưa Semgrep CE vào gói Node. Dùng ESLint + plugin security cho JavaScript/TypeScript; đổi tên MCP tool cho đúng. Dart chỉ là heuristic, không phải Dart Analyzer.
- `drizzle_schema_lens`: dùng TypeScript compiler AST cho Drizzle tĩnh; giữ giới hạn rõ với SQL/Prisma, không thực thi code schema người dùng.
- Request body, kết quả SQL và dung lượng DB phải có giới hạn.

## Không làm
- Không gọi Semgrep Cloud API hoặc gửi code của người dùng ra ngoài khi chưa có đồng ý.
- Không giả định Botkeep instance có Python, không thay đổi Node runtime Cloud từ đây.
- Không đưa `node_modules` vào ZIP.

## Các pha
1. Kiểm tra gateway/callers, source ZIP và contracts.
2. Viết test đỏ cho SQL JOIN/persistence/result shape/row cap, Quicktype Dart/TS, ESLint findings/secrets, AST Drizzle và body limit.
3. Thay code, đồng bộ tên tool/gateway/skills, giữ migration và persistence có hạn mức.
4. Cài dependencies trong build cục bộ, đo ZIP và Windows peak working set qua smoke test, dựng ZIP mới.
5. Review diff/ZIP. Ghi rõ Cloud runtime chưa được probe/deploy nếu không có quyền trực tiếp.

## Tiêu chí chấp nhận
- SQLite engine thật xử lý JOIN và prepared statement; SQL lỗi trả lỗi thay vì success giả.
- Quicktype core thật sinh code Dart/TypeScript từ dữ liệu mẫu.
- JS/TS scanner chạy ESLint thật; API/tool name không còn tự nhận là Semgrep. Dart heuristic nếu còn phải phân biệt engine.
- Drizzle AST xử lý namespace import và callback table schema mà regex cũ không đọc được.
- ZIP có `package.json`, `package-lock.json`, source cần thiết; không có `node_modules`; có thể chạy trên Node 24.
- Đã đo Windows peak working set cục bộ dưới workload xác định và archive size; không tuyên bố Cloud đã xác minh.
