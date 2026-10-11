---
name: codebase-design
description: Shared discipline and vocabulary for designing deep modules (John Ousterhout philosophy). Use when designing or refactoring module interfaces, turning shallow modules into deep ones, making code highly testable, or applying the Design-It-Twice pattern.
---

# Codebase Design (Deep Modules Philosophy)

Thiết kế **Deep Modules**: Ẩn giấu lượng lớn hành vi phức tạp đằng sau một Interface (Giao diện) cực kỳ nhỏ gọn, đặt tại đường nối (Seam) sạch sẽ, và dễ dàng kiểm thử trực tiếp qua Interface đó.

Triết lý này dựa trên nguyên lý của John Ousterhout (*A Philosophy of Software Design*) và Michael Feathers (*Working Effectively with Legacy Code*).

---

## 1. Từ điển thiết kế cốt lõi

- **Module**: Bất kỳ đơn vị code nào có Interface và Implementation (có thể là một function, class, package, hoặc service slice).
- **Interface**: Mọi thứ mà bên gọi (caller) cần biết để sử dụng module: chữ ký kiểu, bất biến (invariants), thứ tự gọi, chế độ lỗi, cấu hình bắt buộc.
- **Implementation**: Phần code nằm bên trong module thực thi logic.
- **Depth (Độ sâu)**: Tỷ lệ đòn bẩy. Lượng hành vi mà bên ngoài nhận được chia cho độ phức tạp của Interface phải học.
  - **Deep Module**: Interface nhỏ gọn + Implementation sâu (LÝ TƯỞNG).
  - **Shallow Module**: Interface cồng kềnh + Implementation nông choẹt (BÀI TRỪ: hàm chỉ pass-through, wrapper vô nghĩa).
- **Seam (Đường nối)**: Vị trí ta có thể thay đổi hành vi của hệ thống mà không cần sửa code tại chính vị trí đó.
- **Adapter**: Thành phần cụ thể cắm vào Seam để đáp ứng Interface.
- **Leverage (Đòn bẩy)**: Giá trị mà bên gọi nhận được từ độ sâu của module.
- **Locality (Tính cục bộ)**: Thay đổi, sửa lỗi, và kiểm thử tập trung tại một nơi thay vì lan tràn ra khắp các caller.

---

## 2. Deep vs Shallow Module

```
┌─────────────────────────────────┐
│     Interface Nhỏ Gọn           │  ← Rất ít hàm, tham số đơn giản
├─────────────────────────────────┤
│                                 │
│     Implementation Sâu Rộng     │  ← Logic phức tạp được đóng gói kín
│                                 │
└─────────────────────────────────┘
         DEEP MODULE (TỐT)

┌─────────────────────────────────┐
│     Interface Cồng Kềnh         │  ← Quá nhiều hàm, tham số phức tạp
├─────────────────────────────────┤
│  Implementation Nông            │  ← Chỉ chuyển tiếp (pass-through)
└─────────────────────────────────┘
        SHALLOW MODULE (TRÁNH)
```

Khi thiết kế hoặc review code, luôn tự hỏi:
- *Mình có thể giảm bớt số lượng hàm/phương thức không?*
- *Mình có thể đơn giản hóa tham số truyền vào không?*
- *Mình có thể giấu bớt chi tiết phức tạp vào bên trong module không?*

---

## 3. Các nguyên tắc cốt lõi

1. **Phép thử Xóa Bỏ (The Deletion Test)**:
   - Thử tưởng tượng xóa module này đi: Nếu sự phức tạp biến mất hoàn toàn, nó chỉ là một tầng trung chuyển rác (pass-through). Nếu sự phức tạp phân tán ngược lại khắp N nơi gọi, chứng tỏ nó đang làm việc xứng đáng.
2. **Interface chính là Bề Mặt Kiểm Thử (The Interface is the test surface)**:
   - Caller và Unit Test cùng giao tiếp qua 1 Interface. Nếu phải test xuyên qua ruột bên trong (private state/method), thiết kế module đó đang có vấn đề.
3. **1 Adapter là Seam giả định, 2 Adapter mới là Seam thật**:
   - Không tạo abstraction/interface trừ khi thực sự có ít nhất 2 triển khai khác nhau (ví dụ: Production Adapter vs In-Memory Test Adapter). Không tạo interface thừa chỉ có 1 implementation duy nhất!
4. **Thiết kế dễ kiểm thử**:
   - Nhận dependency từ ngoài vào, không tự khởi tạo bên trong (`new Service()` trong ruột).
   - Trả về kết quả thay vì gây tác dụng phụ ẩn (side-effect).

---

## 4. Kỹ thuật nâng cao

- **Làm sâu module theo phụ thuộc**: Xem [DEEPENING.md](./DEEPENING.md).
- **Thử nghiệm đa phương án Interface song song**: Xem [DESIGN-IT-TWICE.md](./DESIGN-IT-TWICE.md).
