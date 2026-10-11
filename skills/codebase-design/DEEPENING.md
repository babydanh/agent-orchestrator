# Deepening (Kỹ thuật làm sâu Module)

Cách gộp và tái cấu trúc một cụm module nông (shallow modules) thành một module sâu (deep module) an toàn dựa trên loại phụ thuộc.

---

## 4 Phân loại Phụ thuộc (Dependency Categories)

### 1. In-process (Tính toán thuần túy trong bộ nhớ)
- Không I/O, không gọi mạng.
- **Chiến lược**: Gộp thẳng các module nhỏ lại và test trực tiếp qua Interface mới. Không cần mock hay adapter trung gian.

### 2. Local-substitutable (Có thể thay thế cục bộ)
- Có phụ thuộc DB hoặc File system nhưng có giải pháp chạy in-memory tương đương (SQLite in-memory, PGLite, Mock FS).
- **Chiến lược**: Giữ seam nội bộ (internal seam). Module kiểm thử bằng bản in-memory trong test suite mà không làm lộ chi tiết ra Interface công khai.

### 3. Remote but owned (Dịch vụ nội bộ tự quản)
- Microservice, gRPC nội bộ hoặc hàng đợi nội bộ.
- **Chiến lược Ports & Adapters**: Định nghĩa 1 Port (interface) tại Seam. Lõi logic thuộc về module sâu; tầng mạng được tiêm vào dưới dạng Adapter. Test dùng in-memory adapter; production dùng HTTP/gRPC adapter.

### 4. True external (Dịch vụ bên thứ ba hoàn toàn)
- Stripe, Twilio, OpenAI API...
- **Chiến lược**: Module nhận external dependency qua injected port; test cung cấp Mock Adapter.

---

## Kỷ luật Seam (Đường nối)

- **1 Adapter = Seam giả định. 2 Adapter mới là Seam thật**: Đừng sinh ra interface trừ khi có ít nhất 2 triển khai (thường là Production + Test). Nếu chỉ có 1 triển khai, đó chỉ là lớp gián tiếp vô tích sự.
- **Seam nội bộ vs Seam bên ngoài**: Module sâu có thể có các seam nội bộ phục vụ việc tổ chức code riêng của nó. Tuyệt đối không phơi bày các seam nội bộ ra Interface chỉ để phục vụ viết unit test.

---

## Chiến lược kiểm thử: Thay thế, không xếp tầng (Replace, don't layer)

- Khi đã tạo được Deep Module, các bài test unit vụn vặt cũ của các shallow module sẽ trở thành rác thừa: **Hãy xóa chúng đi**.
- Viết test mới bám sát Interface của Deep Module. Test phải kiểm tra **kết quả quan sát được từ bên ngoài**, không kiểm tra trạng thái nội bộ.
- Nhờ đó, khi refactor cấu trúc code bên trong, các bài test vẫn pass xanh hoàn toàn vì hành vi bên ngoài không đổi.
