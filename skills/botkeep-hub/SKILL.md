---
name: botkeep-hub
description: Use when the user wants to read external web documentation cleanly as Markdown via the personal Botkeep Cloud reader, or send alerts.
---

# Botkeep Cloud Agent Hub

Tận dụng server Botkeep 24/7 để cào tài liệu sạch cho OMP mà không tốn token rác.

## Các công cụ Cloud qua Gateway `https://comagent1.bot-keep.xyz/mcp`:

### 1. Cào Web & Tài Liệu Markdown Sạch 100%:
- **MCP Tool**: `web_markdown_reader(url: "<link>")`
- Tự động kích hoạt cơ chế 2 lớp: Cào nhanh 0.5s bản địa + Jina Headless Engine cho trang SPA (React/Next.js/Tailwind). Tiết kiệm 85% token.

### 2. Tra Cứu Tài Liệu API Frameworks:
- **MCP Tool**: `devdocs_search(slug: "nestjs", q: "pipe")`
- Tìm kiếm chính xác tài liệu qua DuckDuckGo Lite, triệt tiêu tật đoán mò bịa hàm của AI.

### 3. Nuốt Trọn GitHub Repo Thành Context Sạch:
- **MCP Tool**: `gitingest_repo_digest(url: "https://github.com/user/repo")`
- Biến bất kỳ repo GitHub nào thành cây thư mục và code sạch mà không tốn 1 byte ổ đĩa PC.

### 4. Soi Độ Nặng Thư Viện NPM Trước Khi Cài:
- **MCP Tool**: `package_size_checker(pkg: "tên_package")`
- Bắt kịp thư viện nặng >100KB gzip trước khi gõ `npm install`.

### 5. Schema Lens (Drizzle tĩnh, SQL/Prisma cơ bản):
- **MCP Tool**: `drizzle_schema_lens(schemaCode: "<mã_nguồn>")`
- Drizzle TypeScript dùng TypeScript AST; Raw SQL DDL và Prisma dùng parser cơ bản. Không thực thi schema; không bảo đảm phân tích đầy đủ mọi syntax.

### 6. Quicktype Model Generator:
- **MCP Tool**: `quicktype_generator(json: "{...}", className: "Tournament", target: "dart" | "typescript")`
- Dùng `quicktype-core` để sinh mã từ mẫu JSON; chất lượng kiểu phụ thuộc dữ liệu mẫu, không bảo đảm 100%.

### 7. SQLite trên tệp DB bền vững (có giới hạn):
- **MCP Tool**: `sqlite_query(sql: "SELECT * FROM tournaments")`
- Dùng `node:sqlite`, quota mặc định 64 MiB và kết quả tối đa 500 hàng/1 MiB. DDL/DML thay đổi DB dùng chung và lưu trên file. Node 24.14 local phát `ExperimentalWarning`; quota/runtime Cloud cần kiểm chứng riêng.

### 8. Rà mã nguồn:
- **MCP Tool**: `code_security_review(code: "<mã>", language: "typescript" | "javascript" | "dart")`
- JS/TS dùng ESLint AST + security rules; Dart chỉ heuristic, không phải Semgrep hoặc Dart Analyzer. Ngôn ngữ mặc định là TypeScript.

### 9. Chặn Conflict & Lộ Bí Mật Git:
- **MCP Tool**: `diff_validator(diff: "<git diff>")`
- Chỉ kiểm tra conflict markers và đường dẫn tệp nhạy cảm; không dò secret trong nội dung diff và không thay thế Git.

### 10. StackOverflow Accepted Bug Solver:
- **MCP Tool**: `stackoverflow_solver(q: "<thông_báo_lỗi>", tag: "flutter" | "next.js")`
- Bốc thẳng câu trả lời có TÍCH XANH và code fix đặc trị trên Stack Overflow trong 0.3s.

### 11. GitHub Closed Issue Solver:
- **MCP Tool**: `github_issue_solver(q: "<lỗi_framework>", repo: "vercel/next.js")`
- Quét các Issue đã Closed để lấy cách fix chính thức từ chính tác giả thư viện.

### 12. Mock API Client (Flutter & Web):
- **MCP Tool**: `mock_api_client(collection: "tournaments", method: "GET" | "POST", data: {...})`
- Quản lý dữ liệu test thể thao qua API; dung lượng lưu trữ của instance Cloud chưa được xác minh.
