---
name: postgres-concurrency-locks
description: Deep expertise in PostgreSQL row-level locks (FOR UPDATE, FOR NO KEY UPDATE, FOR SHARE, FOR KEY SHARE, SKIP LOCKED) and Redis distributed locks (Redlock) for high-concurrency race conditions.
---

# PostgreSQL Concurrency & Distributed Locking Playbook

Sử dụng skill này khi xử lý các bài toán tranh chấp tài nguyên cao (high-concurrency race conditions): 88 đội đăng ký cùng 1 giây, thanh toán tranh vé, trừ tiền ví, cập nhật tỉ số trực tiếp.

## 1. PostgreSQL Lock Matrix & Rules
- **`FOR UPDATE`**: Khóa độc quyền toàn bộ dòng. Chỉ dùng khi có mutation thay đổi số dư ví, trừ slot trực tiếp. Chặn mọi transaction khác đọc có lock.
- **`FOR KEY SHARE`**: Khóa bảo vệ foreign key, CHO PHÉP các transaction khác cùng đọc `FOR KEY SHARE`. Dùng khi nhiều đội cùng join vào 1 giải đấu (Tournament row) mà không làm nghẽn nhau!
- **`SKIP LOCKED`**: Dùng cho Queue xử lý công việc (Job worker): lấy ngay các dòng chưa bị khóa, bỏ qua dòng đang xử lý.
- **Quy tắc thứ tự khóa (Lock Ordering)**: Luôn khóa các bảng theo thứ tự ID tăng dần (`ORDER BY id ASC`) để tránh 100% Deadlock (`deadlock detected`).

## 2. Redis Distributed Lock (Redlock Pattern)
- Áp dụng khi thao tác trải dài qua nhiều service hoặc hệ thống bên thứ 3 (ZaloPay, VNPay).
- Set key với TTL: `SET resource_lock <uuid> NX PX 5000`.
- Release lock bằng Lua script để kiểm tra đúng owner UUID trước khi xóa.
