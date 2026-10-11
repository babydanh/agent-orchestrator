---
name: visual-qa-reporting
description: Use when running Flutter, Web, or desktop tests and needing visual evidence, screenshot proofs, failure video recordings, or generating interactive HTML and Excel test reports.
---

# Visual QA & Proof Reporting (Flutter & Web)

## Overview
Generate deterministic, visual test evidence (screenshots, videos, HTML dashboards, and Excel test cases) for Flutter and Web applications using tools already installed on the workstation.

---

## 1. When to Use

| Testing Need | Tool / Mechanism | Output Artifact |
| :--- | :--- | :--- |
| **Flutter Widget / Logic Test** | `flutter test --reporter json` | `build/reports/test_report.json` |
| **Mobile Screenshot Proof** | `adb exec-out screencap -p` | `build/reports/screenshots/<tc_id>.png` |
| **Mobile Failure Video** | `adb shell screenrecord` (hardware encoded) | `build/reports/videos/<tc_id>_fail.mp4` |
| **Web E2E & Filmstrip Trace** | Playwright Trace Viewer + Screenshots | `playwright-report/index.html` |
| **Desktop Automation Proof** | MCP `cua-driver` `start_recording` / `stop_recording` | `trajectories/<turn>/recording.mp4` |
| **Consolidated Visual Report** | Bun HTML generator / Allure spec | Standalone `report.html` (single-file) |
| **QA Excel Test Plan** | Bun ExcelJS generator | `test_cases_<feature>.xlsx` (ISTQB format) |

---

## 2. Core Execution Patterns

### Pattern A: Flutter Real-Device Visual Test (via ADB & Phone)
*Applies to mobile apps (e.g. Redmi 25053RT47C / aa785b1a via scrcpy / USB).*

1. **Capture Screenshot Proof on Failure / Success:**
```bash
adb -s aa785b1a exec-out screencap -p > build/reports/screenshots/TC_REG_01_pass.png
```

2. **Capture Hardware Video Only When Testing Critical Flow:**
```bash
adb -s aa785b1a shell screenrecord --size 720x1280 --time-limit 30 /sdcard/run.mp4 &
# Run test flow...
# If PASS:
adb -s aa785b1a shell rm /sdcard/run.mp4
# If FAIL:
adb -s aa785b1a pull /sdcard/run.mp4 build/reports/videos/TC_REG_01_fail.mp4
adb -s aa785b1a shell rm /sdcard/run.mp4
```

---

### Pattern B: Playwright Web Visual & Trace Report
*Applies to Next.js / Web frontends.*

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['allure-playwright', { outputFolder: 'allure-results', detail: true }],
  ],
  use: {
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  },
});
```

---

## 3. Allure Report Automated Ingestion & Parsing (AI Self-Correction Loop)

Khi chạy Playwright với `allure-playwright`, kết quả chi tiết từng ca test được ghi ra `allure-results/*.json`.
OMP đọc trực tiếp các file JSON này trong 0.1 giây để tự động chẩn đoán và sửa lỗi:

### Audit Script cho OMP (Đọc sạch lỗi không cần mở browser):
```bash
python -c "
import json, glob
failures = []
for f in glob.glob('allure-results/*-result.json'):
    with open(f, encoding='utf-8') as fp:
        data = json.load(fp)
        if data.get('status') in ['failed', 'broken']:
            failures.append({
                'name': data.get('name'),
                'status': data.get('status'),
                'message': data.get('statusDetails', {}).get('message', ''),
                'trace': data.get('statusDetails', {}).get('trace', '')[:300]
            })
print(f'Tong so ca FAIL: {len(failures)}')
for item in failures:
    print(f'- [FAIL] {item[\"name\"]}: {item[\"message\"]}')
"
```

### Quy trình tự động sửa lỗi (Self-Healing Loop):
1. Đọc `allure-results/*-result.json` để xác định chính xác selector, HTTP status code hoặc assertion bị fail.
2. Mở file nguồn được chỉ định trong stack trace.
3. Dùng tool `edit` để sửa đúng dòng code bị hỏng.
4. Chạy lại `pnpm test:e2e` để xác nhận test đã xanh 100%.

---

## 4. ISTQB Excel Test Case Standard Specification

| Header (Col) | Field Name | Width | Format / Rules |
| :--- | :--- | :--- | :--- |
| **A** | `Test Case ID` | 14 | `TC_<MODULE>_<INDEX>` (e.g. `TC_REG_01`) |
| **B** | `Phân hệ / Module` | 18 | Tên màn hình / luồng chính |
| **C** | `Mục tiêu kiểm thử` | 32 | Mô tả ngắn gọn điều kiện cần kiểm tra |
| **D** | `Tiền điều kiện` | 26 | Dữ liệu hệ thống ban đầu |
| **E** | `Các bước thực hiện` | 36 | 1. Bước A -> 2. Bước B -> 3. Bước C |
| **F** | `Dữ liệu mẫu (Data)` | 22 | Tên, số điện thoại, giá trị biên |
| **G** | `Kết quả mong đợi` | 30 | Hệ thống phản hồi chuẩn |
| **H** | `Trạng thái` | 12 | 🟩 `PASS` (Xanh lá) hoặc 🟥 `FAIL` (Đỏ) |
| **I** | `Mức độ rủi ro` | 14 | `P0 - Critical`, `P1 - High`, `P2 - Normal` |
| **J** | `Đường dẫn Proof` | 24 | Link trỏ tới file ảnh/video chứng minh |

---

## 5. Anti-Bloat, Cleanup & File Overwrite Rules
1. **Bảo toàn Test Code Vĩnh Viễn (`test/`)**: Toàn bộ file code kiểm thử (`*_test.dart`, `*.spec.ts`) là tài sản cốt lõi của dự án, tuyệt đối không bao giờ bị xóa hay đè mất.
2. **Kế thừa Lịch Sử (History Trend JSON)**: Lưu số liệu tóm tắt (Pass/Fail rate theo thời gian) dưới dạng JSON để vẽ biểu đồ tiến độ chất lượng.
3. **Mặc định GHI ĐÈ Media Tạm Thời**: Thư mục ảnh/video tạm chỉ ghi đè theo kết quả lần chạy mới nhất để chống phình ổ cứng.
4. **Chỉ giữ video khi THẤT BẠI (Retain on failure only)**: Ca test nào PASS thì hủy video ngay lập tức (0 byte dung lượng).
