# Phát hiện nâng cấp Botkeep Node 1–5

## Kế thừa từ audit trước
- 12 tool: Node 1 gateway/catalog; route 4 tool tới Node 2, 5 tới Node 3, 2 tới Node 4, 1 tới Node 5.
- Node 1 `mock_api_client` không chuyển payload cho `PUT`; Node 1 fallback secret là `bk_sec_omp_2026`; cache giới hạn số entry chứ không giới hạn tổng byte.
- Node 2 dùng DuckDuckGo Lite scraping; bộ parse HTML/Markdown tự viết; `isPrivateIpOrHost()` không resolve DNS và redirect chưa revalidate; JSON fetch/body không giới hạn; Jina fallback gửi URL tới dịch vụ ngoài.
- Node 3 dùng thật `node:sqlite`, `quicktype-core`, ESLint + `eslint-plugin-security` + `eslint-plugin-no-secrets`, TypeScript compiler AST. Không có Semgrep. Dart review là heuristic; Drizzle interpretation là custom; `diff_validator` chưa scan nội dung diff để tìm secret.
- Node 4 gọi StackExchange và GitHub API thật; adapter/custom matching; response sau decompression không bị giới hạn; GitHub closed issue không chứng minh official fix.
- Node 5 là mock có chủ đích; Map/JSON persistence đọc/ghi toàn file đồng bộ; secret khai báo nhưng CRUD chưa xác thực.

## Xác minh upstream trong lượt này
- Model Context Protocol TypeScript SDK chính chủ hiện có v2 packages `@modelcontextprotocol/server` và `@modelcontextprotocol/node`; package Node cung cấp `NodeStreamableHTTPServerTransport` cho Node `IncomingMessage`/`ServerResponse`. Nguồn: https://github.com/modelcontextprotocol/typescript-sdk
- Mozilla Readability là parser độc lập dùng cho Firefox Reader View; tài liệu chính thức khuyến nghị Node dùng `jsdom`; Readability không tự sanitize HTML. Nguồn: https://github.com/mozilla/readability
- Turndown là HTML→Markdown converter đã xác minh qua tài liệu/package upstream; sẽ dùng thay parser regex tự viết.
- Jina Reader API gửi việc fetch URL đến `r.jina.ai`; do URL có thể chứa dữ liệu nhạy cảm, không dùng mặc định.
- Tài liệu Context7 về xác thực không thống nhất: security trong OpenAPI cho phép anonymous hoặc Bearer; API Guide nói API hosted thông thường cần key (anonymous chỉ dành cho thử nghiệm có giới hạn); tài liệu CLI mô tả lệnh CLI tra docs không cần đăng nhập và có giới hạn thấp hơn. Các mô tả này không chứng minh REST `/api/v2` hoạt động khi không có key. Node 2 gửi `Authorization: Bearer` nếu có key; nếu không, vẫn gọi REST API và giữ HTTP 401 là lỗi, không trả thành công với kết quả rỗng. Không gọi API live. Nguồn: https://context7.com/openapi.json, https://context7.com/docs/api-guide, https://context7.com/docs/clients/cli
- GitHub REST rate-limit docs: `x-ratelimit-reset` là thời điểm UTC dạng Unix epoch; vượt primary limit có 403/429 và `x-ratelimit-remaining: 0`; secondary limit có thể trả 403/429 cùng `Retry-After`. Nguồn: https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api
- Gitleaks chính thức là binary Go; upstream repo hiện ghi feature complete và chỉ nhận security patches, nên chưa mặc định kéo binary lớn vào Node 3.
- Drizzle Kit là CLI migration/schema introspection; chạy trên schema tùy ý có thể thực thi config/code, nên không thay parser AST an toàn nếu không có sandbox.

## Hạn chế thật đã biết

- Môi trường local không có Context7 key. Hành vi anonymous và quota REST chưa xác minh live; fixture local kiểm tra gửi Bearer khi có key và giữ 401 upstream thành lỗi đã loại bỏ chi tiết nhạy cảm khi không có key. Server có thể khởi động thiếu key, nhưng không đảm bảo Context7 trả kết quả docs.
- Runtime Cloud, env secrets, ingress, disk/RAM quota và persistence chưa xác minh; không thể tuyên bố deployment sẵn sàng.
- Node 1–5 ở ngoài Git repo hiện tại. Không commit/push/deploy; ZIP và cấu hình cloud không được cập nhật nếu không được yêu cầu.

## Hợp đồng và kết quả xác minh
- Runtime cục bộ `v24.14.0`, npm `11.9.0`. Engines: Node 1 `>=20`; Node 2 `^20.19.0 || ^22.13.0 || >=24`; Node 3 `>=24 <25`; Node 4 chưa khai báo engine; Node 5 `>=22.13.0`.
- Bộ test sau vòng xác minh: Node 1 `8/8`, Node 2 `20/20`, Node 3 `15/15`, Node 4 `19/19`, Node 5 `19/19`; các lệnh `node --check` trên server/helper/test files đã sửa đều exit 0.
- Node 1 MCP SDK handshake với protocol `2025-11-25`, catalog 12 tool và JSON-RPC initialize/tools/call pass; test body vượt cap 4 MiB nhận 413. Cache giới hạn 1000 entry / 8 MiB tổng / 1 MiB mỗi entry.
- Node 2 map Context7 v2 theo OpenAPI; kiểm tra library ID trực tiếp/kết quả tìm kiếm, SSRF resolve + pin IP và revalidate redirect. Bearer được gửi khi có key; nếu thiếu key, upstream 401 được giữ thành lỗi chứ không giả thành công; live auth/quota chưa kiểm tra.
- Node 3 Secretlint `@secretlint/node` + preset recommendation chạy cục bộ trên dòng diff được thêm; AWS Access Key ID được kiểm bổ sung bằng pattern hẹp. Engine lỗi fail-closed; README nêu rõ Dart heuristic và không tuyên bố Semgrep.
- Node 4 fixtures cục bộ xác nhận giới hạn body/query/response/decompression/deadline; GitHub reset epoch đổi thành delta-seconds; 403 quota trả `ERR_UPSTREAM_QUOTA_EXCEEDED`/429; body quá cỡ bị chặn cả khi query `q` đã có. Không gọi upstream live.
- Node 5 SQLite giữ thứ tự legacy, duplicate IDs và first-match semantics; auth CRUD, body/timeout/pagination/quota guards; hard cap `max_page_count` chỉ ràng buộc connection SQLite của service.
- Gateway → Node 5 smoke: request auth bị từ chối khi thiếu/sai secret; `mock_api_client` PUT truyền payload và cập nhật row đúng.
- Dependency đo được duy nhất: Node 1 `node_modules` `18,629 KiB`. Tổng install size, peak RSS và concurrency đại diện chưa đo; số unpacked size npm registry chỉ là metadata gói riêng lẻ.
- Ripwire không có git HEAD hoặc `.ripwire_quality_baseline` tại các thư mục service; quality delta không thể so sánh hồi tố. Edit-check không thấy caller arity mismatch, nhưng status là `no-baseline`.
## Xác minh phản biện trên source hiện tại
- Node 1 `test/node1.test.cjs` gửi JSON-RPC thật (`initialize`, `tools/list`, `tools/call`) tới `/mcp` trên gateway được khởi chạy riêng, kiểm tra PUT tới Node 5 và HTTP 401. Test mới xác nhận body vượt cap 4 MiB nhận 413; toàn suite pass 8/8.
- Node 2 `context7.js:176-179` gửi `Authorization: Bearer` khi cấu hình API key. `test/node2.test.cjs:144-164` kiểm tra header; fixture route tại `:358-426` xác nhận upstream 401 vẫn là HTTP 401 với thông báo đã ẩn chi tiết.
- Node 4 `upstream-json.js:91-114` đổi epoch GitHub sang số giây còn lại và phân loại quota thành `ERR_UPSTREAM_QUOTA_EXCEEDED`/429; regression kiểm tra cả status, mã lỗi và `Retry-After`. `test/node4-auth.test.cjs:214-225` phủ body quá cỡ khi có `?q=test`; `SERVER_PATH` và `UPSTREAM_PATH` đều được khai báo tại `:8-9`. Test dùng loopback allowlist tường minh; production `DEFAULT_ALLOWED_HOSTS` vẫn chỉ gồm API chính thức.
- Node 5 `server.js:204-225` giới hạn thời gian nhận body; `:513-517` đặt `server.requestTimeout` cho pha headers. Suite 19/19 pass; không cần thêm timeout body trùng lặp.
- Node 3 khai báo Node `>=24 <25` và dùng `node:sqlite`; runtime Cloud chưa xác minh. Bỏ secret mặc định buộc phải cấu hình cùng `CLUSTER_SECRET` cho gateway và mọi node được bảo vệ trước khi deploy. Node 5 vẫn là mock; SQLite local không chứng minh persistence Cloud.
- Không có workload đại diện. RSS idle hoặc ZIP mã nguồn không chứng minh tương thích quota Cloud 2 GiB; không suy rộng số đo local sang Cloud.


- Không deploy, commit, push, gọi Context7 live hoặc gửi source code tới dịch vụ phân tích ngoài.
