# GLOSSARY.md Format

## Cấu trúc chuẩn

```md
# {Tên ngữ cảnh / Tên dự án}

{Mô tả 1-2 câu về ngữ cảnh này là gì và tại sao nó tồn tại.}

## Thuật ngữ cốt lõi (Language)

**Order**:
Yêu cầu mua hàng của khách hàng gửi tới hệ thống.
_Avoid_: Purchase, transaction, cart

**Invoice**:
Chứng từ yêu cầu thanh toán gửi cho khách hàng sau khi đơn hàng được xác nhận.
_Avoid_: Bill, receipt, payment_request

**Customer**:
Cá nhân hoặc tổ chức đặt mua hàng và thanh toán.
_Avoid_: Client, buyer, account, user
```

## Các quy tắc cốt lõi

1. **Rõ ràng và quyết đoán (Be opinionated):** Khi có nhiều từ đồng nghĩa cho cùng 1 khái niệm, chọn từ chuẩn nhất và đưa các từ còn lại vào danh sách `_Avoid_`.
2. **Định nghĩa ngắn gọn:** Tối đa 1-2 câu. Định nghĩa nó **LÀ CÁI GÌ**, không phải nó làm cái gì hay code cài đặt ra sao.
3. **Chỉ chứa thuật ngữ nghiệp vụ đặc thù:** Không đưa thuật ngữ lập trình chung chung (như timeout, error handler, cache, JWT) vào đây trừ khi dự án gắn một ngữ nghĩa nghiệp vụ riêng biệt cho nó.
4. **Không chứa chi tiết kỹ thuật:** Tuyệt đối không biến `GLOSSARY.md` thành nơi ghi spec, tên bảng hay mã code.

## Đơn ngữ cảnh vs Đa ngữ cảnh

- **Đơn ngữ cảnh (Phổ biến nhất):** Duy nhất 1 file `GLOSSARY.md` ở thư mục gốc của repository.
- **Đa ngữ cảnh:** 1 file `GLOSSARY-MAP.md` ở root trỏ tới các `GLOSSARY.md` con:

```md
# Sơ đồ ngữ cảnh (Glossary Map)

## Ngữ cảnh
- [Ordering](./src/ordering/GLOSSARY.md): Tiếp nhận và theo dõi đơn hàng
- [Billing](./src/billing/GLOSSARY.md): Quản lý hóa đơn và đối soát thanh toán

## Quan hệ liên ngữ cảnh
- **Ordering → Billing**: Ordering phát sự kiện `OrderPlaced`; Billing nhận để xuất hóa đơn.
```
