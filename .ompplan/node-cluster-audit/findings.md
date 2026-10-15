# Kiểm kê Botkeep Node 1–5 — mã nguồn và gói cục bộ

**Phạm vi:** đọc mã/manifest trong `D:/DevTools/botkeep-cluster-final/node{1..5}-*/` và kiểm tra danh sách tệp trong các ZIP hiện có. Chỉ đánh giá tĩnh và chạy kiểm tra cú pháp/test cục bộ đã ghi ở `progress.md`; không gọi API ngoài, không truy cập Botkeep Cloud, không sửa mã dịch vụ, không deploy.

## Kết luận nhanh

- **Không node nào là một tool upstream nguyên bản 100%.** Node 1 là gateway MCP tự viết; Node 2 và 4 là adapter tự viết gọi dịch vụ/API ngoài; Node 3 bọc một số engine chính chủ nhưng phần xử lý/schema vẫn có logic tự viết; Node 5 là mock có chủ đích.
- Engine upstream thực sự trong Node 3: `node:sqlite`, `quicktype-core`, ESLint cùng `eslint-plugin-security`/`eslint-plugin-no-secrets`, và TypeScript compiler AST. Không thấy Semgrep trong dependency hoặc implementation; tên thư mục `node3-sqlite-semgrep` gây hiểu nhầm.
- Dịch vụ nguồn thật: Node 2 gọi DuckDuckGo Lite/Jina Reader/Bundlephobia/Gitingest; Node 4 gọi StackExchange API và GitHub Issues API. Đây là API upstream được gọi qua lớp glue tự triển khai, không phải engine solver chính thức.
- Node 5 trả dữ liệu giả và bảng điểm SSE ngẫu nhiên; phù hợp vai trò mock, không phải nguồn dữ liệu thể thao thực.
- Tên mô tả/claim cần sửa trước khi gọi là “chuẩn”: `github_issue_solver` không xác minh issue là lời giải của tác giả thư viện; `diff_validator` không quét secret trong nội dung; Dart ở Node 3 là heuristic; Node 2 dùng scraping/regex và chuyển URL người dùng sang dịch vụ ngoài.

## Ma trận năm node

| Node | Tool và nguồn thật | Phần tự viết / đánh giá | Sửa ưu tiên |
|---|---|---|---|
| **1 — `node1-gateway-filter`** | Gateway/catalog/router MCP tối giản; không có engine phân tích upstream. Catalog có 12 tool và chuyển tiếp tới Node 2–5. | Toàn bộ gateway/cache/forwarding là code riêng. `mock_api_client` có lỗi hợp đồng: request `PUT` không chuyển payload. Backend HTTP lỗi có thể được trả như HTTP 200 mà không đánh dấu MCP `isError`. Cache giới hạn số entry và TTL nhưng không có giới hạn byte cứng. | Bỏ secret mặc định dùng chung; fail-closed nếu chưa cấu hình. Sửa chuyển tiếp body `PUT` và ánh xạ lỗi upstream thành MCP error. Giới hạn cache theo byte nếu giữ cache kết quả lớn. |
| **2 — `node2-devdocs-reader`** | Gọi DuckDuckGo Lite (HTML search), Jina Reader, Bundlephobia và Gitingest. Không dùng API tài liệu chính thức/SDK tập trung; một số dịch vụ bên ngoài là nguồn dữ liệu thật. | HTTP adapter và lọc HTML/Markdown viết tay; tìm kết quả bằng regex trên HTML. `isPrivateIpOrHost()` không kiểm tra DNS-resolve tới IP private và redirect được theo trước khi tái thẩm định URL, nên SSRF có thể vượt bộ lọc. Một số body/JSON response không có giới hạn; không có rate limit/attribution nhất quán. `/read` có thể gửi URL người dùng sang Jina; `/gitingest` gửi repo URL sang Gitingest. | Ưu tiên chặn SSRF thực sự: kiểm tra IP sau DNS, chặn mọi dải private/link-local, giới hạn và xác thực lại từng redirect hoặc dùng allowlist. Thêm giới hạn byte cho request/decompressed response; minh bạch dịch vụ ngoài. Bỏ secret mặc định. Thay regex HTML bằng parser có cấu trúc nếu cần độ tin cậy. |
| **3 — `node3-sqlite-semgrep`** | SQLite thật qua `node:sqlite`; sinh Dart/TypeScript bằng `quicktype-core`; ESLint thật với plugin security/no-secrets; TypeScript compiler AST thật. | Wrapper API/logic custom. Dart security review vẫn là heuristic; Drizzle AST custom và SQL/Prisma parser cơ bản; diff validator chỉ phát hiện conflict marker/tên tệp nhạy cảm, **không** quét secret trong nội dung diff. SQL endpoint cho phép DDL/DML trên DB file dùng chung, nên lệnh có thể thay đổi dữ liệu lâu dài. Không có Semgrep. Node `>=24 <25`; Node 24 phát cảnh báo Experimental cho `node:sqlite`. | Bỏ secret mặc định. Đổi tên thư mục/nhãn Semgrep hoặc tích hợp Semgrep thật; không quảng cáo Dart như static analyzer đầy đủ. Thu hẹp/mô tả chính xác khả năng Drizzle/SQL/Prisma và diff. Cân nhắc cô lập DB theo người dùng hoặc giới hạn quyền SQL nếu không muốn caller sửa dữ liệu dùng chung. |
| **4 — `node4-solver-engine`** | StackExchange Data API, lọc câu hỏi có accepted answer; GitHub Search API cho issue đã đóng. | HTTP/decompression, tìm kiếm và trình bày tự viết. Issue đóng không đồng nghĩa lời giải đã được tác giả thư viện xác nhận. Status/quota/rate-limit upstream xử lý chưa đủ; `totalFound` là số kết quả đã lấy (tối đa 3/4), không phải tổng số upstream. POST body và response sau giải nén được buffer không giới hạn; JSON parse lỗi có thể bị xem như kết quả rỗng. | Bỏ secret mặc định; giới hạn request và decompressed response. Xử lý status/quota/rate-limit và phân biệt upstream failure với kết quả rỗng. Sửa mô tả `github_issue_solver` và ý nghĩa `totalFound`. |
| **5 — `node5-mock-backend`** | Không có engine/API upstream; seeded fixtures, Map + JSON file và SSE điểm số sinh ngẫu nhiên. Đây là mock có chủ đích. | `CLUSTER_SECRET` được khai báo nhưng không dùng; REST CRUD không xác thực, request body không giới hạn, pagination không validate/cap, PUT cho phép đổi ID, ID sinh từ timestamp có nguy cơ đụng nhau, lỗi đọc/ghi persistence bị nuốt. File persistence thành công trong môi trường local không chứng minh Cloud giữ dữ liệu qua restart. | Nếu có thể truy cập qua mạng: thêm auth cho mutation trước khi expose. Giới hạn body/pagination, giữ ID bất biến khi PUT, phát hiện lỗi ghi file và làm rõ persistence chỉ là mock/local. Không thay mock bằng nguồn dữ liệu thật trừ khi yêu cầu sản phẩm thay đổi. |
## Ma trận từng tool: engine upstream hay code tự viết?

**Quy ước:** “Engine upstream” = thư viện/engine thật được dependency hoặc API sử dụng; “adapter custom” = MCP/HTTP gọi và định dạng kết quả do dự án viết. API thật không có nghĩa là tool hoàn toàn upstream.

| Tool | Node | Nguồn/engine đang dùng | Phân loại và khuyến nghị |
|---|---:|---|---|
| `devdocs_search` | 2 | DuckDuckGo Lite HTML, trích kết quả bằng regex | Scraper tự viết, không phải API tài liệu chính thức. Nếu cần tra cứu tài liệu chính xác, dùng nguồn/search API chính thức theo từng hệ; giữ adapter mỏng. |
| `web_markdown_reader` | 2 | HTTP fetch + regex HTML→Markdown; fallback Jina Reader | Hybrid: parser tự viết + dịch vụ Jina thật. Dùng parser HTML/reader có cấu trúc; giữ Jina tùy chọn và xử lý SSRF/redirect trước khi fetch. |
| `package_size_checker` | 2 | Bundlephobia API | Dữ liệu upstream thật, HTTP wrapper tự viết. Giữ adapter; xử lý timeout, lỗi API và giới hạn response. |
| `gitingest_repo_digest` | 2 | Gọi Gitingest API | Dịch vụ upstream thật, wrapper tự viết. Giữ nếu chấp nhận gửi URL repo tới dịch vụ ngoài; mô tả rõ dữ liệu được gửi đi. |
| `sqlite_query` | 3 | Node tích hợp `node:sqlite` | SQLite engine thật, endpoint/guard là custom. Giữ engine; kiểm soát quyền SQL và tách dữ liệu nếu dùng nhiều người. |
| `code_security_review` | 3 | ESLint 10, `eslint-plugin-security`, `eslint-plugin-no-secrets`, TypeScript parser | Engine thật cho JS/TS; nhánh Dart là heuristic. Giữ ESLint; nếu quảng bá hỗ trợ Dart thì dùng Dart Analyzer thật hoặc nói rõ giới hạn. Không gọi đây là Semgrep. |
| `diff_validator` | 3 | Kiểm tra conflict marker và đường dẫn nhạy cảm tự viết | Validator custom hẹp, chưa scan secret trong nội dung. Giữ nếu chỉ cần kiểm tra cơ bản; nếu cần secret scanning thì tích hợp Gitleaks thật và đổi mô tả. |
| `quicktype_generator` | 3 | `quicktype-core` 26.0.0 | Engine upstream thật, wrapper JSON→Dart/TypeScript tự viết. Giữ Quicktype; kiểm tra schema mẫu và lỗi đầu vào ở wrapper. |
| `drizzle_schema_lens` | 3 | TypeScript compiler AST; phần nhận diện Drizzle tự viết; SQL/Prisma parser cơ bản | Dùng parser upstream thật nhưng chưa phải Drizzle Kit đầy đủ. Nếu cần semantics đầy đủ, có thể dùng `drizzle-kit` trong sandbox vì nạp schema/config có thể thực thi mã; nếu không, giữ parser tĩnh và ghi rõ construct chưa hỗ trợ. |
| `stackoverflow_solver` | 4 | StackExchange Data API, lọc câu hỏi có accepted answer | API upstream thật; tìm kiếm, chọn và định dạng kết quả custom. Giữ adapter; gọi chính xác là tìm accepted answers, không cam kết đó là fix áp dụng được. |
| `github_issue_solver` | 4 | GitHub Issues Search API, lọc issue đóng | API upstream thật; wrapper custom. Issue đóng không chứng minh fix chính thức; đổi tên/mô tả thành tìm issue đã đóng, hoặc bổ sung xác minh trước khi gọi là solver. |
| `mock_api_client` | 5 | Node 5 mock CRUD, Map/JSON và SSE giả lập | Tự viết có chủ đích. Giữ mock cho test; chỉ thay bằng API dữ liệu thể thao thật nếu sản phẩm yêu cầu dữ liệu live. |

### Node 1 — lớp gateway, không phải tool thứ 13

Gateway/catalog/router MCP là code tự viết. Nó đăng ký 12 tool ở trên và chuyển tiếp tới Nodes 2–5. Dùng MCP SDK chính thức chỉ khi muốn chuẩn hóa giao thức; việc route tới từng backend vẫn là logic riêng. Comment ở `node1-gateway-filter/server.js:47` ghi “6 công cụ”, nhưng catalog có 12 entry (`:48–214`) nên comment đã cũ.

### Nên upstream hóa phần nào?

- **Nên dùng engine thật:** SQLite, sinh model Quicktype, lint JS/TS; thêm Dart Analyzer nếu vẫn tuyên bố hỗ trợ Dart.
- **Nên giữ adapter custom mỏng:** gọi Bundlephobia/Gitingest/StackExchange/GitHub; đây là tích hợp API chứ không cần thay bằng repo solver lớn.
- **Nên thay parser tự chế nếu cần độ chính xác:** HTML→Markdown; Drizzle chỉ khi cần hỗ trợ schema đầy đủ và có sandbox.
- **Chỉ thêm secret scanner upstream nếu sản phẩm cần scan nội dung:** nếu không thì giữ `diff_validator` hẹp và mô tả đúng.
- **Giữ custom/mock có chủ đích:** gateway routing và Node 5 mock. Không cần “upstream hóa” chúng chỉ để tăng số dependency.

**Tóm lại:** upstream hóa đúng điểm giúp tăng độ chính xác; không làm mọi tool tự nhiên tốt hơn. Auth, SSRF, giới hạn body/response và kiểm soát dữ liệu vẫn cần sửa ở wrapper.

## Xếp thứ tự cần xử lý

### P1 — trước khi mở dịch vụ ra mạng công khai
1. Nodes 1–4 dùng fallback secret dễ đoán `bk_sec_omp_2026`; phải bỏ fallback và dừng khởi động khi thiếu secret cấu hình. Node 5 không dùng secret và không xác thực CRUD.
2. Node 2: sửa SSRF/redirect/DNS validation trước khi cho nhận URL tùy ý.
3. Node 4 và Node 5 (cùng Node 2 ở các endpoint liên quan): đặt giới hạn request, response sau giải nén và tài nguyên xử lý.
4. Xác minh Cloud ingress/firewall/auth thực tế; trạng thái mạng triển khai hiện chưa biết.

### P2 — tính đúng của hợp đồng/description
1. Node 1 `mock_api_client` PUT làm mất body; lỗi này khiến cập nhật record qua gateway không đúng.
2. Node 4 sửa claim “giải pháp chính thức của tác giả” vì chỉ tìm issue đóng; sửa `totalFound` để không giả làm tổng upstream.
3. Node 3 đổi nhãn Semgrep; làm rõ Dart heuristic, parser giới hạn và diff validator không quét nội dung secret.
4. Node 2 bỏ claim chất lượng “100% sạch/85% tiết kiệm token” nếu chưa có benchmark tái lập.

## Gói phát hành và bằng chứng

- Năm ZIP hiện có liệt kê mã `server.js`/`package.json`; không thấy `node_modules`. Node 1 và Node 3 ZIP mới có `package-lock.json`; Node 2/4/5 không có lockfile. Mã nguồn Node 3 có dependency thật và script test; Node 1/2/4/5 chủ yếu dùng Node built-in.
- Kết quả cú pháp: `node --check server.js` đạt cho cả 5 node.
- Node 3: `npm test` đạt **11/11**. Không thấy bộ test tương đương cho Node 1, 2, 4, 5; cú pháp pass không chứng minh hành vi an toàn.
- Không có lời gọi API ngoài trong lượt audit này. Không xác nhận bản ZIP trùng byte với từng thư mục source; không xác nhận node nào đang chạy trên Cloud.
- Cloud runtime/version, biến secret, giới hạn RAM/disk, ingress và tính bền dữ liệu chưa được kiểm tra. Theo trạng thái trước đó, ZIP mới của Node 1/3 chưa deploy; trạng thái Node 2/4/5 không xác định.
