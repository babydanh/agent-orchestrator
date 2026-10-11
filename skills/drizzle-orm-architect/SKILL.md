---
name: drizzle-orm-architect
description: Use when designing, reading, querying, or migrating PostgreSQL database schemas using Drizzle ORM in NestJS or Next.js projects.
---

# Drizzle ORM & PostgreSQL Architecture Skill

Kỹ năng kiến trúc Database PostgreSQL chuẩn chỉ bằng Drizzle ORM, chống ảo giác tên cột và chống lỗi N+1 Query.

## 1. Schema Lens (Phân Tích Cấu Trúc Bảng Chuẩn Xác):
Trước khi viết câu lệnh query phức tạp hoặc migration:
- **Gọi MCP Tool `drizzle_schema_lens`**:
  Truyền mã nguồn của file schema (`schema.ts`) vào tool `drizzle_schema_lens`.
  Tool sẽ trả về bản đồ tóm tắt (Cheat Sheet) siêu ngắn gọn:
  * Tên bảng & Tên cột thật trong database.
  * Các giá trị Enum hợp lệ.
  * Khóa ngoại (Foreign Keys) và Quan hệ (`relations`).

## 2. Quy Tắc Vàng Khi Query Drizzle:
- **Chống N+1 Query**: Tuyệt đối KHÔNG gọi query bên trong vòng lặp `for` hay `map`.
  Dùng cú pháp Relational Queries:
  ```typescript
  const data = await db.query.tournaments.findMany({
    with: {
      matches: true,
      teams: true,
    },
  });
  ```
- **Khớp Kiểu Dữ Liệu**:
  * Khóa chính UUID: `id: uuid('id').defaultRandom().primaryKey()`
  * Khóa ngoại: Bắt buộc có `.references(() => otherTable.id, { onDelete: 'cascade' })`
  * Cột thời gian: `createdAt: timestamp('created_at').defaultNow().notNull()`
- **Transactions & Concurrency**:
  Khi cập nhật số dư, tỉ số trận đấu hoặc slot thi đấu, bắt buộc bọc trong `db.transaction()` để chống race condition.
