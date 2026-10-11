---
name: botkeep-hub
description: Use when the user wants to read external web documentation cleanly as Markdown via the personal Botkeep Cloud reader, or send alerts.
---

# Botkeep Cloud Agent Hub

Tận dụng server Botkeep 24/7 để cào tài liệu sạch cho OMP mà không tốn token rác.

## Danh Sách 9 Siêu Công Cụ Cloud (Qua Gateway `https://comagent1.bot-keep.xyz/mcp`):

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

### 5. Universal Database Schema Lens (Hiểu Mọi Database):
- **MCP Tool**: `drizzle_schema_lens(schemaCode: "<mã_nguồn>")`
- Tự động bóc tách Drizzle ORM, Raw SQL DDL (`CREATE TABLE`), hoặc Prisma schema thành bảng tóm tắt quan hệ (~300 tokens) chống ảo giác tên cột 100%.

### 6. Recursive Quicktype Model Generator:
- **MCP Tool**: `quicktype_generator(json: "{...}", className: "Tournament", target: "dart" | "typescript")`
- Tự động sinh ra các Class Model lồng nhau (Nested Classes) kèm `fromJson` và `toJson` chuẩn xác 100%.

### 7. SQL Database Sandbox (RAM & Disk Persistent):
- **MCP Tool**: `sqlite_query(sql: "SELECT * FROM tournaments")`
- Chạy thử nghiệm SQL trên RAM & lưu trữ đĩa 2GB trên Cloud mà không cần bật PostgreSQL nặng nề ở PC.

### 8. AST Security & Code Review:
- **MCP Tool**: `semgrep_code_review(code: "<đoạn_mã>")`
- Bắt lỗi Flutter `setState` thiếu mounted check, Next.js hardcode localhost, lộ secret.

### 9. Chặn Conflict & Lộ Bí Mật Git:
- **MCP Tool**: `diff_validator(diff: "<git diff>")`
- Quét conflict markers (`<<<<<<<`) và file nhạy cảm (`.env`, `private key`) trước khi commit.

### 10. StackOverflow Accepted Bug Solver:
- **MCP Tool**: `stackoverflow_solver(q: "<thông_báo_lỗi>", tag: "flutter" | "next.js")`
- Bốc thẳng câu trả lời có TÍCH XANH và code fix đặc trị trên Stack Overflow trong 0.3s.

### 11. GitHub Closed Issue Solver:
- **MCP Tool**: `github_issue_solver(q: "<lỗi_framework>", repo: "vercel/next.js")`
- Quét các Issue đã Closed để lấy cách fix chính thức từ chính tác giả thư viện.

### 12. Mock API Client 24/7 (Flutter & Web):
- **MCP Tool**: `mock_api_client(collection: "tournaments", method: "GET" | "POST", data: {...})`
- Truy vấn, thêm, sửa, xóa dữ liệu test thể thao trên Cloud lưu trữ đĩa 2GB mà không cần bật Backend ở PC.
