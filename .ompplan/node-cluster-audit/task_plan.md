# Kế hoạch: audit tool của Botkeep Node 1–5

## Mục tiêu
Kiểm kê mã nguồn cục bộ của cả 5 node; phân loại engine upstream thật, adapter tự viết, tool tự viết/giới hạn, và mức cần sửa theo bằng chứng.

## Ràng buộc
- Read-only: không sửa source/package/ZIP, không deploy, không gọi dịch vụ phân tích bên ngoài, không xóa/kill tiến trình hoặc session.
- Phân biệt kiểm chứng local và Cloud; không dùng nhãn “100% chuẩn” nếu chỉ có wrapper hoặc chưa chạy Cloud.
- Không coi test pass là chứng minh sản phẩm tương đương upstream.

## Pha
1. Tìm và audit riêng source Node 1–5: `D:/DevTools/botkeep-cluster-final/node{1..5}-*/`.
2. Đối chiếu package, upstream engine, các đường xử lý, phạm vi và hạn chế.
3. Thực hiện xác minh read-only/local thích hợp, ghi rõ những node chưa thể kiểm tra.
4. Tổng hợp bảng: chuẩn upstream / wrapper / tự triển khai / cần sửa; ghi thứ tự ưu tiên và Cloud caveat.

## Tiêu chí báo cáo
- Mỗi node/tool có đường dẫn và bằng chứng code/dependency.
- Nêu rõ cái gì chạy bằng engine gốc và phần nào là glue/custom.
- Không tuyên bố triển khai hay xác minh Cloud nếu chưa có bằng chứng.
