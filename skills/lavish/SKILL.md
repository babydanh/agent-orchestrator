---
name: lavish
description: Turn complex plans, multi-option architecture decisions, and large visual reviews into rich HTML artifacts using lavish-axi CLI. Strictly enforces 1-tab limit with live-reload.
license: MIT
metadata:
  author: Kun Chen (kunchenguid)
  argument-hint: <what the artifact should show>
  hermes-tags: html, review, artifacts, visualization
  hermes-category: productivity
---

# Lavish Editor Protocol (Chuẩn Hóa Kỷ Luật 1 Tab & Live-Reload)

Mở giao diện HTML trên trình duyệt để con người xem sơ đồ luồng, bảng đối chiếu phương án kiến trúc, hoặc bản kế hoạch phức tạp.

---

## 1. Tiêu chí Kích hoạt Bắt buộc (When to Use)

- 🎯 **TỰ ĐỘNG DÙNG KHI**:
  1. Tác vụ lớn nhiều bước (chạm từ **3 files trở lên** hoặc làm tính năng mới từ đầu).
  2. Bài toán có sự đánh đổi (Trade-offs giữa 2-3 phương án A/B/C).
  3. Cần vẽ sơ đồ luồng dữ liệu (Data flow Mermaid / SVG) hoặc bảng ma trận tính năng.
  4. Người dùng yêu cầu: *"cho tôi plan lavish"*, *"vẽ sơ đồ"*, *"kế hoạch trực quan"*.

- 🛑 **TUYỆT ĐỐI CẤM DÙNG KHI**:
  1. Hỏi đáp, giải thích khái niệm, khảo sát ngắn.
  2. Sửa bug nhỏ cục bộ (1-2 file), chạy lệnh test, đọc log.

---

## 2. Kỷ luật Duy nhất 1 Tab Trình duyệt (Anti-Tab-Spam)

1. **Lần đầu tiên**: Mở file `.lavish/plan.html`:
   ```bash
   npx -y lavish-axi .lavish/plan.html
   ```
2. **Các lần cập nhật sau**:
   - **CHỈ GHI ĐÈ FILE TRÊN ĐĨA**: Ghi đè nội dung mới vào `.lavish/plan.html`.
   - Tab trình duyệt đang mở sẽ **TỰ ĐỘNG CẬP NHẬT (Live Reload)** mà không cần chạy lại lệnh mở tab mới.
3. **Khi người dùng đã lỡ tay đóng tab**:
   - Chỉ khi tab đã bị tắt hẳn, AI mới gọi lại với cờ `--reopen`:
   ```bash
   npx -y lavish-axi --reopen .lavish/plan.html
   ```

---

## 3. Tiêu chuẩn Nội dung Artifact (.lavish/plan.html)

- **Theme**: Dark mode hiện đại, typography rõ ràng.
- **Components**:
  - Tóm tắt quyết định chính (Summary Cards).
  - Sơ đồ Mermaid luồng xử lý hoặc SVG architecture.
  - Bảng đối chiếu các phương án kiến trúc (Option Comparison Matrix).
  - Checklist công việc có thể tick review.
