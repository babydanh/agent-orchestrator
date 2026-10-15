# Tiến độ dựng lại ZIP Node 3

## Đã xong
- [x] Khảo sát contracts Node 3, gateway, ZIP và giới hạn runtime chưa xác minh.
- [x] Chọn Node 24; không giả định có Python, không gửi mã lên dịch vụ ngoài.
- [x] Viết test hành vi trước; quan sát test đỏ trên engine cũ.
- [x] Thay Node 3 bằng `node:sqlite`, `quicktype-core`, ESLint security rules, và AST parser TypeScript cho Drizzle.
- [x] `npm test`: 11/11 pass trên Node v24.14.0.

## Đã xong tại local
- [x] Đổi MCP `semgrep_code_review` thành `code_security_review`; cập nhật schema gateway, skills và README theo engine/giới hạn thật.
- [x] Kiểm tra `tools/list`: 12 công cụ; schema ngôn ngữ và mô tả SQLite/Quicktype/Drizzle khớp source.
- [x] Tạo ZIP Node 3 (25.022 byte) và ZIP gateway (5.770 byte); danh sách file xác nhận, không có `node_modules`. MCP `initialize` khớp phiên bản `2.0.0` trong package.
- [x] Load smoke 5 route đồng thời; Windows peak working set cục bộ 241.6 MiB, không đại diện Cloud.

## Chưa xác minh trên Cloud / review
- Botkeep runtime Node, quota RAM/đĩa, filesystem bền vững và peak RSS thực tế chưa được probe; ZIP chưa deploy.
- `node:sqlite` trên Node 24.14 local phát `ExperimentalWarning`.
- SQLite quota mặc định local là 64 MiB; không suy ra quota Cloud.
- Drizzle TypeScript dùng AST tĩnh; SQL DDL/Prisma parser cơ bản; Dart mode heuristic, không phải Dart Analyzer.
- OCR review/scan không chạy vì provider `openai` trong cấu hình thiếu API key; không có báo cáo OCR.
