# 🎯 Agent Orchestrator (OMP Multi-Repo AI Worker)

Hệ thống điều phối tự động hóa đa kho lưu trữ (Multi-Repo) chạy bằng **OMP (`@oh-my-pi/pi-coding-agent`)** trên **GitHub Actions**.

## 🚀 Cách sử dụng:
1. Tạo một **Issue** mới trong repository này.
2. Mô tả nhiệm vụ bạn muốn thực hiện (Ví dụ: Thêm API mới ở Backend và cập nhật giao diện bên App).
3. GitHub Actions sẽ tự động:
   - Kéo cả 2 repo `HethongBackendApi_QuanlyGiaiDau` và `HethongFrontEndApp_QLgiaidau` về.
   - Bật OMP lên phân tích, viết code và chạy test độc lập cho từng repo (`pnpm test` cho Backend, `flutter test` cho App).
   - Tự động tạo nhánh và mở **Pull Request (PR)** trên từng repo tương ứng.
   - Báo cáo kết quả và đường link các PR trực tiếp vào Issue.

## 🔐 Cần cấu hình Secrets:
Trong **Settings -> Secrets and variables -> Actions**, hãy thêm 2 Secrets:
- `GH_PAT`: GitHub Personal Access Token (để kéo/đẩy code vào các repo).
- `OPENROUTER_API_KEY`: API Key OpenRouter của bạn để OMP gọi mô hình AI.