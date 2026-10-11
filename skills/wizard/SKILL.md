---
name: wizard
description: Generate an interactive Bash or PowerShell wizard script that walks a human step-by-step through manual setup tasks only humans can perform (capturing API keys, setting secrets, configuring third-party dashboards, migrations).
---

# Wizard (Script dẫn đường tương tác cho người dùng)

**Wizard** là một script tự động sinh ra để hướng dẫn người dùng từng bước thực hiện những thao tác thủ công tẻ nhạt mà AI **không được phép hoặc không thể làm trực tiếp** (nhập secret key production, cấu hình dashboard bên thứ ba như Stripe/AWS/Cloudflare, đăng nhập SSO, hoặc chạy migration 1 lần).

Thay vì xả văn bản hướng dẫn dài dòng dễ làm sót bước, Wizard:
1. Tự động mở đúng URL trên trình duyệt mặc định (`open_url`).
2. Chỉ rõ chỗ cần click và giá trị cần copy.
3. Nhập giá trị an toàn (ẩn ký tự với mật khẩu/secret key).
4. Tự động ghi vào file cấu hình cục bộ (`.env`) và đẩy lên GitHub Secret (`gh secret set`).
5. Hiển thị tiến trình rõ ràng (Stage X/Y).

---

## 1. Khi nào kích hoạt Wizard?

- Khi cần setup API Keys từ dashboard bên thứ 3 (Stripe, Resend, Supabase, OpenAI, v.v.).
- Khi cần tạo Credentials / Secrets mà AI không có quyền truy cập.
- Khi cần thực hiện thao tác thủ công có tính rủi ro cao (cần xác nhận từng bước `confirm`).

---

## 2. Quy trình thực hiện

### Bước 1: Khảo sát các bước & thông số cần thu thập
Đọc lướt dự án để xác định mọi biến cần thiết:
- File `.env.example`, `.env`, `docker-compose.yml`, các workflow trong `.github/workflows/*.yml`.
- Xác định biến nào là công khai (Public) và biến nào là bí mật (Secret).

### Bước 2: Chọn định dạng Script phù hợp
- Môi trường Windows thuần: Dùng mẫu PowerShell [template.ps1](./template.ps1).
- Môi trường Linux / macOS / Git Bash / WSL: Dùng mẫu Bash [template.sh](./template.sh).

### Bước 3: Điền các Stage và tạo Script
- Sao chép mẫu template, định nghĩa danh sách các `stage`.
- Gọi các hàm tiện ích có sẵn:
  - `open_url <url>`: Tự mở trình duyệt.
  - `ask <KEY> <Prompt>`: Hỏi nhập biến thông thường.
  - `ask_secret <KEY> <Prompt>`: Hỏi nhập biến bảo mật (ẩn ký tự).
  - `write_env <KEY> <VALUE>`: Ghi an toàn vào `.env` (idempotent, không làm hỏng file cũ).
  - `set_secret <NAME> <VALUE>`: Đẩy thẳng vào GitHub Actions repo secret nếu có `gh cli`.
  - `confirm <Question>`: Hỏi xác nhận Yes/No trước thao tác nguy hiểm.

### Bước 4: Hướng dẫn người dùng chạy
- Thông báo cho người dùng lệnh chạy script:
  - Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\setup-wizard.ps1`
  - Linux/Mac: `chmod +x ./scripts/setup-wizard.sh && ./scripts/setup-wizard.sh`
