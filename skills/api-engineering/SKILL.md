---
name: api-engineering
description: Use when designing, building, auditing, refactoring, or securing REST APIs, NestJS DTOs, and database migrations.
license: MIT
metadata:
  author: ECC Standards & Addy Best Practices
  version: "2.0.0"
---

# API Engineering: Design, Compatibility, Security & Migrations

Production standards for building rock-solid backend services (NestJS / Node.js / TypeScript).

---

## 1. RESTful Design & Contract Consistency

- **Resource-Oriented URLs**: Nouns, plural, hierarchical:
  - `GET /api/v1/tournaments`
  - `POST /api/v1/tournaments/:id/matches`
  - `PATCH /api/v1/matches/:id/score`
- **Idempotency**: `PUT` and `DELETE` must be idempotent. Use `Idempotency-Key` headers for critical payments/tournament registrations.
- **Strong DTO Validation**: Always validate request payloads using `class-validator` and `class-transformer` in NestJS:
  - Whitelist payloads (`whitelist: true, forbidNonWhitelisted: true`) to reject unknown properties (prevents mass-assignment vulnerabilities).

---

## 2. Backward Compatibility Protocol (Zero Client-Breakage)

When evolving existing APIs (especially consumed by Flutter mobile apps or third parties):
1. **Never rename or remove existing JSON fields** in active responses without a deprecation window.
2. **Additive-Only Evolution**:
   - New fields MUST be optional on input, or provide fallback default values.
   - If payload structure fundamentally changes, introduce versioning: `/api/v2/...` or version header.
3. **Graceful Nullability**: Mobile apps crash on unexpected `null`. Ensure fields documented as non-nullable never return `null`.

---

## 3. Security Hardening & Pit of Success

1. **Input Sanitization & Injection Guards**:
   - Parameterize all SQL / ORM queries. Never concatenate raw SQL strings.
   - Sanitize HTML/Markdown inputs (`sanitize-html` or `DOMPurify`) to prevent XSS.
2. **Rate Limiting & DoS Protection**:
   - Apply rate limit guards (`@nestjs/throttler` or Redis token bucket) on public endpoints and login/registration routes.
3. **Safe Error Responses**:
   - Never leak internal stack traces, DB connection strings, or SQL syntax errors to clients.
   - Return structured error contracts: `{ statusCode, error, message, timestamp }`.

---

## 4. Zero-Downtime Database Migration Safeguards (Expand / Contract)

When modifying database schemas (PostgreSQL / TypeORM / Drizzle / Prisma) on live production:
- ❌ **CẤM TUYỆT ĐỐI**:
  - `DROP COLUMN` hoặc `DROP TABLE` trong cùng 1 bước deploy.
  - `ALTER TABLE ... ADD COLUMN ... NOT NULL` mà không có `DEFAULT`.
  - `CREATE INDEX` trên bảng lớn mà không có `CONCURRENTLY`.
- ✅ **Quy trình 3 bước (Expand / Contract)**:
  1. **Bước 1 (Expand)**: Thêm cột mới nullable hoặc có default. Giữ nguyên cột cũ.
  2. **Bước 2 (Dual Write)**: Backend ghi đồng thời vào cả 2 cột. Chạy batch data migration đồng bộ.
  3. **Bước 3 (Contract)**: Chuyển toàn bộ read sang cột mới. Xóa cột cũ ở phiên bản tiếp theo.
