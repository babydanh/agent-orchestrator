---
name: api-backward-compatibility
description: Ensures backend API changes in NestJS do not break Flutter mobile app or Next.js web clients still running on older versions.
---

# API Backward Compatibility & Multi-Client Safety

Sử dụng khi sửa đổi, thêm bớt trường trong DTO, Controller của `HethongBackendApi_QuanlyGiaiDau`.

## 1. Nguyên Tắc An Toàn Cho Mobile App Flutter
- Người dùng App Mobile không cập nhật app ngay lập tức (vẫn dùng version v1.0.0 trong khi backend đã lên v2.0.0).
- **Không bao giờ đổi tên trường cũ**: Nếu muốn đổi `teamName` thành `name`, phải giữ lại `teamName` kèm decorator `@Deprecated` và map giá trị song song.
- **Không bao giờ chuyển một trường Optional thành Required**: Sẽ làm crash JSON Deserializer của Flutter (`type 'Null' is not a subtype of type 'String'`).

## 2. API Versioning & Semantic Evolution
- Thêm endpoint version mới (`/api/v2/...`) thay vì sửa đè lên endpoint cũ nếu có thay đổi cấu trúc mảng hoặc phân trang.
- Đảm bảo header `Accept-Language` và timestamp ISO-8601 UTC đồng nhất giữa Flutter và Web.
