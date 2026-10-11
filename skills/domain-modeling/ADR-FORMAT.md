# Architectural Decision Record (ADR) Format

ADR lưu trữ tại thư mục `docs/adr/` và đánh số tuần tự: `0001-slug.md`, `0002-slug.md`, v.v.
Thư mục `docs/adr/` chỉ được tạo khi có quyết định kiến trúc thực tế đầu tiên.

## Mẫu tối giản chuẩn (Minimal Template)

```md
# {Tên quyết định ngắn gọn}

{1-3 câu: Ngữ cảnh bài toán là gì, chúng ta đã quyết định điều gì, và tại sao chọn phương án này.}
```

Giá trị cốt lõi của ADR nằm ở việc **ghi nhận lại quyết định đã được đưa ra và lý do vì sao**, không phải ở việc vẽ vời hình thức dài dòng.

## Các phần mở rộng (Chỉ thêm khi thực sự cần)

- **Trạng thái (Status)**: `proposed | accepted | deprecated | superseded by ADR-NNNN`
- **Các phương án đã cân nhắc (Considered Options)**: Chỉ ghi khi các phương án bị loại bỏ mang tính cảnh báo đáng giá (để người sau không lặp lại).
- **Hệ quả (Consequences)**: Những ràng buộc phát sinh cần lưu ý.

## Khi nào BẮT BUỘC ghi ADR?

Thỏa mãn đủ 3 điều kiện:
1. **Khó đảo ngược**: Đổi ý tốn hàng tuần hoặc hàng tháng công sức refactor.
2. **Bất ngờ nếu không giải thích**: Người đọc code sẽ tự hỏi *"sao chỗ này không dùng cách thông thường?"*
3. **Có sự đánh đổi rõ ràng**: Có 2-3 phương án khả thi và ta chọn phương án này vì lý do cụ thể.

Ví dụ đủ chuẩn:
- Chọn Database engine hoặc Message broker (Postgres thay vì Mongo, RabbitMQ thay vì Kafka).
- Monorepo vs Multi-repo.
- Kiến trúc xử lý bất đồng bộ hoặc giao tiếp giữa các module.
- Quyết định dùng raw SQL thay vì ORM vì hiệu năng truy vấn lớn.
