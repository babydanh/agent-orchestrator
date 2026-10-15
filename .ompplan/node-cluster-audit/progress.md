# Tiến độ audit và bản đồ tool Node 1–5

- [x] Kiểm kê 12 tool từ catalog Node 1 và xác định node đích: Node 2 có 4, Node 3 có 5, Node 4 có 2, Node 5 có 1; Node 1 là gateway/catalog.
- [x] Đối chiếu package.json của Nodes 1–5: Node 1/2/4/5 không khai báo dependencies; Node 3 khai báo `quicktype-core`, ESLint security plugins và TypeScript parser.
- [x] Phân loại từng tool thành engine thật, API thật + adapter custom, logic heuristic/custom, hoặc mock có chủ đích.
- [x] Ghi khuyến nghị chọn real/custom cho từng tool vào `findings.md`.
- [x] Cập nhật `.lavish/plan.html` thành sơ đồ route + ma trận 12 tool.
- [x] Mở báo cáo trong Lavish và kiểm tra ảnh ở desktop/mobile; trang hiển thị, document width không tràn viewport mobile.
- [x] Không sửa source service, không thêm dependency, không gọi API ngoài và không deploy.

## Kết luận

Không phải mọi tool cần upstream repo riêng. Dùng engine upstream cho parsing/code generation/static analysis/SQL; giữ adapter custom mỏng cho API; giữ Gateway và mock custom nếu đúng mục tiêu. Cloud chưa xác minh.
