---
name: wait-what
description: Stop, reset, and re-explain. Use when the user says 'khoan đã', 'chưa hiểu', 'nói lại xem', 'wait what', or when a previous explanation failed to land.
---

# Wait What (Cơ chế Reset & Tái diễn giải)

Kích hoạt ngay khi người dùng phản hồi:
- *"khoan đã"*, *"từ từ đã"*, *"chưa hiểu"*, *"nói lại xem"*, *"wait what"*, *"nói gì rối thế"*.

Khi nhận tín hiệu này, AI **TUYỆT ĐỐI KHÔNG**:
1. Không lặp lại nguyên văn đoạn giải thích cũ.
2. Không tranh luận bảo vệ quan điểm kỹ thuật.
3. Không xả thêm thuật ngữ khó hiểu (jargon).

---

## Quy trình 3 bước tái diễn giải

### 1. Nhận diện phần bị hổng ngữ cảnh (Missing Context)
Người dùng thường bị rối vì thiếu một giả định ngầm mà AI quên nói trước.
Xác định ngay: *Khái niệm nào đang khiến người dùng khựng lại?*

### 2. Hạ tông kỹ thuật & Dùng ngôn ngữ đời thường (Plain Language)
- Sử dụng cách diễn đạt giản dị, hình tượng hóa thực tế (analogies).
- Bám sát từ điển thuật ngữ `GLOSSARY.md` của dự án (nếu có) để không dùng từ chéo ngoe.
- Cắt bỏ mọi chi tiết râu ria về framework, thư viện hay cấu trúc ngầm không liên quan đến vấn đề chính.

### 3. Cấu trúc câu trả lời cô đọng (3 phần)
- **Bản chất vấn đề (Trong 1 câu)**: Vấn đề thực sự đang xảy ra là gì.
- **Tại sao nó quan trọng**: Ảnh hưởng gì đến người dùng hoặc dự án.
- **Lựa chọn tiếp theo (Tối đa 2 phương án)**: Người dùng chỉ cần chọn A hoặc B.
