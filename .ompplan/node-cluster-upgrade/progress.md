# Tiến độ nâng cấp Botkeep Node 1–5

## Khóa phạm vi và hợp đồng
- [x] Đọc lại audit 12 tool, các rủi ro đã xác định và báo cáo Lavish trước đó.
- [x] Xác nhận người dùng cho phép nâng cấp source service; không bao gồm deploy Cloud.
- [x] Đọc tài liệu chính thức MCP SDK, Jina Reader, Context7, Mozilla Readability, Gitleaks và Drizzle Kit.
- [x] Xác nhận manifests, runtime, routes/contracts và test harness của 5 node.
- [x] Chốt Context7 cho docs thật, không whitelist library; validation theo giới hạn/contract API.
- [x] Đối chiếu Context7 OpenAPI v2: docs endpoints cho phép anonymous hoặc Bearer; guide prose mâu thuẫn, chưa probe live quota.

## Regression tests
- [x] Viết regression tests trước khi đổi hành vi cho Node 1–5.
- [x] Chạy test đỏ ban đầu: Node 1, 3, 4, 5 fail ở hành vi thiếu; Node 2 ban đầu thiếu module.
- [x] Chạy lại suites sau rà soát: Node 1 8/8, Node 2 20/20, Node 3 15/15, Node 4 19/19, Node 5 19/19; syntax checks liên quan exit 0.

## Pha triển khai
- [x] Node 1: MCP SDK chính thức, PUT forwarding, secret fail-closed, giới hạn cache và MCP body.
- [x] Node 2: Context7, Readability/Turndown cục bộ, validate library ID, SSRF/redirect/body/deadline protection.
- [x] Node 3: Secretlint cục bộ trên added diff lines; fail-closed và mô tả engine đúng coverage.
- [x] Node 4: giới hạn body/response/deadline; giữ status quota và Retry-After; auth fail-closed.
- [x] Node 5: SQLite migration/persistence, CRUD auth, body/pagination/database caps và SSE cleanup.

## Pha xác minh
- [x] Chạy toàn bộ suite từng node sau khi tích hợp.
- [x] `node --check` trên service/test files đã sửa của Node 1–5.
- [x] Smoke gateway → mock backend: credentials/401 và PUT update đều pass.
- [ ] Chưa đo tổng dependency size/peak RSS/ZIP vì không có workload đại diện; số đo Node 1 `node_modules` 18,629 KiB chỉ là cục bộ, không dùng để kết luận Cloud 2 GiB.
- [x] Cập nhật `.lavish/plan.html` theo kết quả local và giới hạn còn lại.

## Ruling
- Không deploy, commit hoặc push; source services nằm ngoài repo Git hiện tại.
- Không gọi API Context7 live vì thiếu `CONTEXT7_API_KEY`; không gửi source code tới dịch vụ phân tích ngoài.
- Runtime/quota/persistence Cloud và tải concurrency đại diện chưa xác minh.
## Vòng xác minh sau phản biện
- [x] Đọc lại source/test hiện tại: Node 4 epoch mapping, q-body regression, Node 4 auth constants và Node 5 `server.requestTimeout` đã có.
- [x] Xác nhận Node 2 đã có test Bearer forwarding và route fixture giữ HTTP 401; findings trước đó cần diễn đạt mâu thuẫn auth rõ hơn.
- [x] Node 1 test JSON-RPC thật qua `/mcp`; body vượt cap 4 MiB trả 413 (suite 8/8).
- [x] Bổ sung assertion `ERR_UPSTREAM_QUOTA_EXCEEDED` cho 403 quota, test Node 1 body 413 với cap 4 MiB; Node 4 suite 19/19 và Node 1 suite 8/8 pass.
- [x] Chạy lại suites Node 1–5; smoke JSON-RPC initialize/tools/list/tools/call, gateway PUT tới Node 5, 401 và body cap đã được xác minh qua test thật.
- [x] Cập nhật `.lavish/plan.html`, findings và progress theo kết quả; ghi rõ Node 3 `>=24`, rollout `CLUSTER_SECRET`, Node 5 mock, mâu thuẫn Context7 auth và giới hạn phép đo Cloud.

