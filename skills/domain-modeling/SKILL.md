---
name: domain-modeling
description: Build, maintain, and sharpen a project's domain model and ubiquitous language. Use when discussing codebase terminology, writing or editing GLOSSARY.md, or recording architectural decisions in ADRs.
---

# Domain Modeling & Ubiquitous Language

Chủ động xây dựng và mài sắc mô hình nghiệp vụ (Domain Model) và ngôn ngữ chung (Ubiquitous Language) của dự án. 
Kỹ năng này áp dụng kỷ luật: thách thức các thuật ngữ mơ hồ, sáng tạo các kịch bản biên, và ghi nhận ngay vào `GLOSSARY.md` và `docs/adr/` khi các quyết định được chốt.

## 1. Cấu trúc thư mục

### Đơn ngữ cảnh (Hầu hết dự án):
```
/
├── GLOSSARY.md
├── docs/
│   └── adr/
│       ├── 0001-slug.md
│       └── 0002-slug.md
└── src/
```

### Đa ngữ cảnh (Hệ thống lớn / Microservices / Monorepo):
Nếu có `GLOSSARY-MAP.md` ở root, dự án có nhiều ngữ cảnh:
```
/
├── GLOSSARY-MAP.md
├── docs/adr/                         ← Quyết định toàn hệ thống
└── src/
    ├── ordering/
    │   ├── GLOSSARY.md
    │   └── docs/adr/                 ← Quyết định riêng của context
    └── billing/
        ├── GLOSSARY.md
        └── docs/adr/
```

Khởi tạo file theo kiểu lười (Lazy): Chỉ tạo khi có thuật ngữ/quyết định thực tế đầu tiên. Không tạo file rỗng.

---

## 2. Quy tắc trong phiên làm việc

### 1. Đối chiếu và thách thức với từ điển (Challenge against the glossary)
Khi người dùng hoặc code dùng từ ngữ mâu thuẫn với `GLOSSARY.md`, phải đặt câu hỏi ngay:
*"Trong GLOSSARY bạn định nghĩa 'Cancellation' là hủy đơn, nhưng ở đây bạn đang muốn nói đến hoàn tiền (Refund). Bạn muốn dùng nghĩa nào?"*

### 2. Mài sắc ngôn ngữ mơ hồ (Sharpen fuzzy language)
Khi phát hiện từ ngữ chung chung hoặc bị quá tải (overloaded):
*"Bạn đang nói 'Account', ý bạn là Customer (khách mua) hay User (tài khoản hệ thống)? Hai khái niệm này khác nhau."*

### 3. Thử thách với kịch bản cụ thể (Stress-test with scenarios)
Khi bàn về quan hệ thực thể, hãy đặt ra các tình huống biên:
*"Nếu một User bị khóa tài khoản nhưng vẫn còn Order đang giao dở thì hệ thống xử lý thế nào?"*

### 4. Đối chiếu chéo với Code (Cross-reference with code)
Kiểm tra xem code thực tế có làm đúng như mô tả không:
*"Bạn nói Order không thể sửa sau khi Submit, nhưng hàm `updateOrder` trong service vẫn cho phép đổi items. Đâu là hành vi chuẩn?"*

### 5. Cập nhật `GLOSSARY.md` tức thì (Update inline)
Khi một thuật ngữ được chốt định nghĩa và các từ cần tránh (`_Avoid_`), ghi ngay vào `GLOSSARY.md`. Tuyệt đối không để dồn lại cuối phiên.
Xem định dạng chuẩn tại [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md).

### 6. Đề xuất ghi ADR có chọn lọc (Offer ADRs sparingly)
Chỉ đề xuất tạo ADR khi thỏa mãn cả 3 điều kiện:
1. **Khó đảo ngược**: Chi phí đổi ý sau này rất đắt.
2. **Bất ngờ nếu không có ngữ cảnh**: Lập trình viên tương lai đọc code sẽ thắc mắc *"tại sao lại làm quái đản thế này?"*.
3. **Kết quả của sự đánh đổi thực sự**: Có các giải pháp thay thế khả thi nhưng ta chọn phương án này vì lý do cụ thể.
Xem định dạng chuẩn tại [ADR-FORMAT.md](./ADR-FORMAT.md).
