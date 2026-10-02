---
name: drizzle-migration-safeguard
description: Zero-downtime database migration rules for Drizzle ORM and PostgreSQL. Prevents dangerous table locks, irreversible data loss, and breaking schema changes.
---

# Drizzle ORM Zero-Downtime Migration Safeguards

Kích hoạt khi viết hoặc chạy migration database (`drizzle-kit generate`, `drizzle-kit migrate`, `push`).

## 1. Các lệnh CẤM TUYỆT ĐỐI trên Production
- CẤM `DROP COLUMN` hoặc `DROP TABLE` trực tiếp trong 1 bước.
- CẤM `ALTER TABLE ... ADD COLUMN ... NOT NULL` mà không có `DEFAULT` (sẽ khóa toàn bộ bảng và timeout API).
- CẤM `CREATE INDEX` trên bảng lớn mà không có `CONCURRENTLY`.

## 2. Quy trình 3 bước cho Breaking Changes (Expand / Contract Pattern)
1. **Bước 1 (Expand)**: Thêm cột mới nullable hoặc có default. Giữ nguyên cột cũ.
2. **Bước 2 (Dual Write)**: Code Backend ghi đồng thời vào cả 2 cột (cũ và mới). Chạy batch data migration.
3. **Bước 3 (Contract)**: Chuyển toàn bộ read sang cột mới. Xóa cột cũ ở phiên bản tiếp theo.
