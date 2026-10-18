# Agent Orchestrator (OMP chạy trên GitHub Actions)

Bộ điều phối để **đẩy việc đang làm dở từ máy local lên cloud và làm tiếp**, cho cả cụm dự án giải đấu
(Backend, Web, App, ...). Bản thân repo này không chứa code dự án, chỉ chứa workflow.

## Mục tiêu

Trước khi đi ngủ, bạn nói "đẩy lên cloud làm tiếp". Session dở dang được lưu và đẩy lên GitHub, cloud được cấu hình
để chạy tiếp **đúng session đó** rồi báo kết quả vào Issue. Không hẹn giờ: bạn nói là chạy ngay.

## Luồng hiện được cấu hình (chưa có bằng chứng chạy trọn vẹn)

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

- Session **trên máy bạn**: test nhẹ (vài file) chạy trên máy; test nặng (E2E full-stack, cả bộ Flutter, pytest AICheckVAR)
  đẩy lên `test-runner.yml` theo skill `cloud-test-runner` (`~/.omp/scripts/cloud-test-runner.py`).
- Session **trên cloud** (`agent-task.yml`): test chạy trên cloud.
- `test-runner.yml` chỉ chạy khi được dispatch (bạn bấm tay hoặc session local theo skill), không hẹn giờ.
  - `fullstack-e2e`: Postgres + Redis + Backend + Web rồi chạy toàn bộ Playwright, Allure thành artifact. Mất ~55–58 phút / timeout 60.
  - `web`: Playwright KHÔNG có backend (API SSR rơi về production) — không dùng để xác minh. `all` không chạy job này.
  - `backend` (Jest), `app` (`flutter analyze` + `flutter test`, không thiết bị thật), `aicheckvar` (pytest).
  - `auto25d`: hỏng — repo `Auto25D-Remotion` "not found" trên run 12/10.
- Đọc lỗi: `python ~/.omp/scripts/cloud-test-runner.py summary <run_id|last>`.

## Quét bảo mật Backend / Web / App (`security-scan.yml`)

- Chạy tay: `gh workflow run security-scan.yml -f target=all -f ref=main` (`target`: `all`, `backend`, `web`, `app`). Tự chạy mỗi thứ Hai 02:20 UTC. Chưa nối deploy gate.
- Quét tĩnh, không cài dependency và không chạy code của repo được quét:
  - Gitleaks 8.30.1 (CLI, không dùng gitleaks-action): toàn bộ lịch sử mọi nhánh.
  - OSV-Scanner 2.7.0: mọi lockfile đã track (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `pubspec.lock`).
  - Semgrep 1.181.0 CE với quy tắc cục bộ `scripts/security/rules/semgrep-ts-js.yml` (SQL nội suy, exec động, eval, `dangerouslySetInnerHTML` động). Trước mỗi lượt quét, `scripts/security/semgrep_selftest.py` chạy fixture lỗi (phải bị bắt đủ) và fixture an toàn (phải sạch).
- Phạm vi: Backend và Web có đủ ba scanner. App (Flutter/Dart) chỉ có Gitleaks và OSV: Semgrep coi Dart là thử nghiệm nên không có SAST cho App.
- Ghim và kiểm: binary và wheel được ghim phiên bản cùng SHA256 từ nguồn chính thức. Dependency transitive của Semgrep lấy từ PyPI, chưa ghim hash.
- Quyền và token: workflow chỉ có `contents: read`. Clone repo mục tiêu dùng `GH_PAT` qua biến môi trường `GIT_CONFIG_*`, token không vào `.git/config` hay URL. Tối đa 2 job song song.
- Kết quả:
  - Log và step summary công khai chỉ có số lượng, trạng thái, SHA. Không có đường dẫn file, snippet, giá trị secret hay stderr.
  - Chi tiết (rule/advisory, gói@phiên bản, file, dòng, commit) chỉ vào issue private: Web ghi trong repo Web; Backend/App ghi trong `babydanh/omp-global-config` vì hai repo mục tiêu đang public. Tiêu đề chứa tên repo để không trộn báo cáo.
  - Job đỏ với "có phát hiện" khi có finding. Job đỏ với "lỗi hạ tầng" khi scanner lỗi, thiếu lockfile, không quét được file, hoặc không đọc/ghi được issue. Hai loại được tách riêng trong summary.
- `GH_PAT` cần Contents read trên 3 repo mục tiêu và Issues read/write trên Web và `omp-global-config`. Không ghi được báo cáo private thì job báo lỗi hạ tầng, không bỏ qua.
- Gitleaks quét cả lịch sử, nên secret đã xoá khỏi nhánh hiện tại vẫn bị báo nếu còn trong commit cũ.

## Secrets cần có (Settings -> Secrets and variables -> Actions)

- `GH_PAT`: kéo/đẩy code vào các repo dự án (cần Contents, Actions, Issues).
- `OPENROUTER_API_KEY`: model dự phòng cho OMP.
- `OMP_CODEX_AUTH`: token Codex OAuth cho OMP.

## Lưu ý đã biết

- Cloud chỉ thấy code **đã push lên GitHub**. Việc sửa dở chưa commit trên máy thì chưa lên cloud được.
- Repo này đang **public** (đã kiểm tra bằng GitHub API): không để dữ liệu nhạy cảm trong nhánh `omp-sync/sessions`.
- **Chưa có bằng chứng** các lần handoff trước đã resume và hoàn thành đúng. Các bước trên có trong `fast-handoff.ps1`
  và `agent-task.yml` (đã đọc code), nhưng chưa ai chạy trọn một vòng và đo kết quả. Không coi đây là tính năng đã kiểm chứng.
