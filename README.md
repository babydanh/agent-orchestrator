# Agent Orchestrator (OMP chạy trên GitHub Actions)

Bộ điều phối để **đẩy việc đang làm dở từ máy local lên cloud và làm tiếp**, cho cả cụm dự án giải đấu
(Backend, Web, App, ...). Bản thân repo này không chứa code dự án, chỉ chứa workflow.

## Mục tiêu

Trước khi đi ngủ, bạn nói "đẩy lên cloud làm tiếp". Session dở dang được lưu và đẩy lên GitHub, cloud chạy
tiếp **đúng session đó** (resume đầy đủ), xong thì báo kết quả vào Issue. Không hẹn giờ: bạn nói là chạy ngay.

## Quy trình bàn giao (đã chạy được)

1. **Local**: nói "đẩy session lên github làm tiếp". Script `fast-handoff.ps1` sẽ:
   - commit + push nhánh đang làm dở;
   - đẩy file session `.jsonl` lên nhánh `omp-sync/sessions`;
   - tạo một **Issue** `[Handoff] ...` chứa `Session-ID`, `Repo mục tiêu`, `Branch dở dang`, checklist.
2. **Cloud** (`agent-task.yml`) chạy khi có Issue của chủ repo (hoặc dispatch tay):
   - kéo các repo dự án về, checkout đúng nhánh dở dang;
   - tải session từ `omp-sync/sessions` và chạy `omp --continue` để làm tiếp;
   - chạy test **ngay trên runner** (Postgres + Redis đã dựng sẵn), kể cả Playwright E2E khi việc liên quan Web;
   - push code **thẳng lên nhánh** (`omp/issue-N` hoặc nhánh dở dang), không tạo Pull Request;
   - báo kết quả (pass/fail + link run + nhánh đã push) vào Issue **chỉ khi chạy do Issue kích hoạt**; dispatch tay thì không có comment; lưu lại session.
3. **Kéo về local** khi muốn làm tiếp ở máy: `cancel-cloud-and-pull.ps1`, rồi `omp --resume`.

## Chưa làm (không có trong workflow hiện tại)

- **Tự merge vào `main`**: chưa có. Workflow chỉ push lên nhánh. Merge vào `main` của Web/Backend sẽ kích hoạt
  `deploy.yml` (deploy production), nên nếu làm thì chỉ nên merge khi toàn bộ kiểm tra xanh.
- **Hẹn giờ chạy**: không dùng. Chạy ngay khi có Issue hoặc dispatch tay.
- `cleanup-merged.yml` chỉ chạy khi một Pull Request được merge. Vì quy trình không dùng PR nên file này không kích hoạt.

## Test chạy ở đâu

- Session **trên máy bạn**: test chạy trên máy bạn.
- Session **trên cloud** (`agent-task.yml`): test chạy trên cloud.
- `test-runner.yml` là workflow riêng, chỉ chạy khi **bạn dispatch tay** (không tự chạy, không hẹn giờ). Nó dựng
  Postgres + Redis + Backend + Web rồi chạy toàn bộ Playwright, xuất báo cáo Allure thành artifact.

## Secrets cần có (Settings -> Secrets and variables -> Actions)

- `GH_PAT`: kéo/đẩy code vào các repo dự án (cần Contents, Actions, Issues).
- `OPENROUTER_API_KEY`: model dự phòng cho OMP.
- `OMP_CODEX_AUTH`: token Codex OAuth cho OMP.

## Lưu ý đã biết

- Cloud chỉ thấy code **đã push lên GitHub**. Việc sửa dở chưa commit trên máy thì chưa lên cloud được.
- Repo này đang **public**: không để dữ liệu nhạy cảm trong nhánh `omp-sync/sessions`.
- Chưa có bằng chứng các lần handoff trước đã resume và hoàn thành đúng. Cơ chế có trong workflow, nhưng chưa đo
  tỉ lệ thành công.
