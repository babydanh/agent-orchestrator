---
name: api-security-audit
description: Audits REST and GraphQL endpoints for OWASP Top 10 vulnerabilities, IDOR, broken object-level authorization, and secret leaks.
---

# API Security & IDOR Pentest Playbook

Sử dụng khi viết Controller, Guard, hoặc chuẩn bị deploy API.

## 1. IDOR & Ownership Verification (Bắt buộc 100%)
- Mọi endpoint có param `/:id` (ví dụ: `/tournaments/:id/matches`, `/teams/:id/roster`) PHẢI kiểm tra quyền sở hữu:
  `WHERE id = :id AND organizerId = req.user.id`.
- Tuyệt đối không chỉ kiểm tra Role mà quên kiểm tra Resource Ownership (User A có role Organizer không được phép sửa giải của Organizer B).

## 2. Token & Payload Sanitization
- Bắt buộc dùng `ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })` trong NestJS để chặn Mass Assignment.
- Tuyệt đối không trả về `passwordHash`, `refreshToken`, `internalNote` trong API Response DTO. Dùng `class-transformer` (`@Exclude()`) hoặc select cụ thể.
