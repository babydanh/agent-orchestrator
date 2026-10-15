# Kế hoạch nâng cấp Botkeep Node 1–5

## Mục tiêu
Nâng cấp năm node theo hướng dùng engine/API upstream thật ở nơi có sẵn, giữ adapter nhỏ và trung thực về phần mock/custom; xử lý lỗi hợp đồng và giới hạn tài nguyên đã được audit.

## Quyết định kiến trúc
- Node 1: dùng MCP SDK chính thức thay cho JSON-RPC/MCP tự xử lý nếu API SDK giữ được đường dẫn `/mcp`, danh sách tool và shape phản hồi hiện có.
- Node 2: dùng Context7 API cho tìm tài liệu (không tự cào DuckDuckGo); dùng Mozilla Readability + Turndown để trích xuất HTML cục bộ, không chuyển nội dung trang sang Jina. Chỉ kiểm tra input theo giới hạn API, không whitelist framework/thư viện; hỗ trợ tra cứu rộng mọi library Context7. Giới hạn fetch/redirect/body và chặn SSRF trước từng lần kết nối.
- Node 3: giữ SQLite, Quicktype, ESLint security plugins và TypeScript compiler AST đang chạy thật. Tích hợp engine upstream cho secret scan nếu có package/API phù hợp; bỏ mọi mô tả gây hiểu nhầm về Semgrep, Dart analyzer hoặc độ bao phủ.
- Node 4: tiếp tục dùng StackExchange/GitHub API chính thức; chỉ giữ logic chuyển đổi dữ liệu mỏng, giới hạn response/decompression và trả trạng thái lỗi/nguồn dữ liệu chính xác.
- Node 5: vẫn là mock có chủ đích; thay JSON whole-file persistence bằng SQLite tích hợp của Node, xác thực CRUD bằng secret dùng chung và giới hạn body/pagination.
- Tài liệu auth Context7 không thống nhất: API Guide yêu cầu key cho API hosted thông thường; OpenAPI và tài liệu CLI mô tả khả năng truy cập không key trong một số hình thức/giới hạn. Mã gửi Bearer khi cấu hình; nếu không có key vẫn thử gọi REST API và phải trả lỗi upstream 401, không giả thành công. Không khẳng định hành vi live chưa kiểm tra.

## Phạm vi
Nguồn dịch vụ ở `D:/DevTools/botkeep-cluster-final/node{1..5}-*/`, nằm ngoài Git repo hiện tại. Báo cáo/tiến độ nằm trong `.ompplan/node-cluster-upgrade/`; bản đồ hiện có nằm trong `.lavish/plan.html`.

## Ràng buộc
- Giữ nguyên tên tool, route, input/output contract trừ khi test chứng minh bắt buộc phải thay đổi.
- Không thêm dependency chỉ để thay vài dòng bằng wrapper; dùng package upstream khi nó thực sự là engine lõi.
- Không giả định Cloud runtime, secret, quota disk/RAM hay persistence đã được cấu hình.
- Không dùng mock response làm bằng chứng engine/API upstream hoạt động.
- Mỗi thay đổi hành vi có test hồi quy; chạy test và smoke flow sau khi thay đổi xong.
- Không tạo branch/worktree; source service ở ngoài repo Git hiện tại.

## Pha
1. [x] Xác nhận manifests, runtime, tool contracts, server handlers, test harness và các giới hạn đo được.
2. [x] Chốt API upstream/dependency theo tài liệu chính thức; ghi rõ cấu hình ngoài còn thiếu.
3. [x] Viết regression tests trước; triển khai Node 1–5, giữ tool names/routes và contracts có thể giữ.
4. [x] Chạy full test suite và syntax checks cho cả năm node; smoke gateway → mock backend xác minh auth và PUT forwarding.
5. [x] Cập nhật `.lavish/plan.html`, findings/progress và giới hạn Cloud.

## Tiêu chí hoàn tất
- [x] Phân loại rõ upstream engine/API, adapter, custom logic và mock; không phóng đại claim.
- [x] Sửa các lỗi audit được yêu cầu: `PUT` payload, secret fallback/auth, SSRF validation, body/response/time bounds và persistence.
- [x] Node 5 persist SQLite, giữ CRUD/SSE/mock behavior cùng legacy ordering/duplicate semantics.
- [x] Tests/smoke chạy thật; suites sau vòng xác minh: Node 1 8/8, Node 2 20/20, Node 3 15/15, Node 4 19/19, Node 5 19/19.
- [ ] Tổng dependency size/peak RSS không đo được theo workload đại diện; chỉ ghi nhận Node 1 `node_modules` 18,629 KiB. Không suy luận khả năng đáp ứng quota Cloud 2 GiB từ số đo local.
- [x] Không tuyên bố Cloud-ready: runtime/quota/secrets/persistence Cloud và Context7 live quota chưa xác minh.
## Vòng xác minh bổ sung — phạm vi hẹp
- Chỉ xác minh các điểm phản biện cụ thể; không thêm tích hợp upstream, dependency hoặc kiến trúc mới.
- Node 1: gửi JSON-RPC thật tới `/mcp` cho `initialize`/`tools/call`; kiểm tra giới hạn body 4 MiB bằng test 413.
- Node 2: ghi rõ mâu thuẫn tài liệu xác thực; giữ Bearer khi có key và xác nhận upstream 401 không biến thành kết quả rỗng thành công.
- Node 4: xác nhận `x-ratelimit-reset` đổi từ Unix epoch sang số giây còn lại; test 403 quota gồm mã lỗi và HTTP 429; xác nhận body quá cỡ vẫn bị chặn khi có `?q=`.
- Node 5: xác nhận `server.requestTimeout` bảo vệ headers và timer riêng bảo vệ body; không sửa nếu suite/source hiện tại đủ.
- Không suy luận khả năng chạy trên Cloud từ máy local; workload đại diện chưa có. Ghi rõ Node 3 cần Node `>=24`, secret phải được cấp đồng bộ trước deploy, Node 5 vẫn là mock.


