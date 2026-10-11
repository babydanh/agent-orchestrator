# Design It Twice (Thiết kế hai lần / Thử nghiệm đa phương án)

Dựa trên nguyên lý của Ousterhout: **Ý tưởng đầu tiên của bạn hiếm khi là ý tưởng tốt nhất**.

Khi cần thiết kế interface cho một module hoặc subsystem quan trọng, thay vì chọn ngay cách đầu tiên hiện ra trong đầu, hãy dùng mô hình subagents song song để khám phá các góc nhìn khác biệt.

---

## Quy trình 3 bước

### Bước 1: Khung bài toán (Problem Space)
Trước khi giao việc cho subagent, xác định rõ ràng:
- Các ràng buộc mà interface mới bắt buộc phải đáp ứng.
- Phụ thuộc mà module cần sử dụng (In-process, Database, Remote API).
- Một đoạn mã phác họa nhanh ngữ cảnh (code sketch) để cụ thể hóa bài toán.

### Bước 2: Chạy 3+ Subagents song song với góc nhìn đối nghịch
Spawn các subagent độc lập, mỗi agent được gán một tiêu chí thiết kế riêng biệt:

- **Agent 1 (Tối giản tối đa - Minimalist)**:
  - *Mục tiêu*: Interface chỉ 1-2 hàm duy nhất. Tối đa hóa đòn bẩy trên từng entry point.
- **Agent 2 (Linh hoạt mở rộng - Extensibility)**:
  - *Mục tiêu*: Hỗ trợ nhiều use-case, cấu hình plugin, dễ mở rộng mà không sửa core.
- **Agent 3 (Tối ưu trường hợp phổ biến nhất - Ergonomic / DX)**:
  - *Mục tiêu*: Trường hợp 90% dev hay dùng phải cực kỳ ngắn gọn, default value thông minh, không cần boilerplate.
- **Agent 4 (Ports & Adapters - nếu có phụ thuộc bên ngoài)**:
  - *Mục tiêu*: Tách biệt hoàn toàn phần lõi nghiệp vụ và phần giao tiếp hạ tầng.

Mỗi phương án phải trình bày:
1. Interface đề xuất (Types, methods, params, error handling).
2. Code ví dụ lúc caller gọi thực tế.
3. Phần ruột phức tạp nào đã được giấu kín sau Seam.
4. Đánh đổi (Trade-offs): Ưu điểm vượt trội ở đâu và điểm yếu là gì.

### Bước 3: So sánh và chốt phương án
So sánh các phương án dựa trên:
- **Độ sâu (Depth)**: Tỷ lệ đòn bẩy Interface / Implementation.
- **Tính cục bộ (Locality)**: Khi có thay đổi, logic tập trung tại một chỗ hay văng ra khắp nơi.
- **Khuyến nghị rõ ràng**: Đưa ra nhận định dứt khoát về phương án mạnh nhất, hoặc kết hợp lai (Hybrid) các điểm sáng của 2 phương án tốt nhất.
