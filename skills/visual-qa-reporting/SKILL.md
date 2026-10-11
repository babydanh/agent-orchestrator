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
# Capture immediate screenshot directly from phone hardware without lag:
adb -s aa785b1a exec-out screencap -p > build/reports/screenshots/TC_REG_01_pass.png
```

2. **Capture Hardware Video Only When Testing Critical Flow:**
```bash
# 1. Start video recording in background on phone chip:
adb -s aa785b1a shell screenrecord --size 720x1280 --time-limit 30 /sdcard/run.mp4 &

# 2. Run the test flow...

# 3. Pull video to PC if failed, or delete if passed:
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
    ['json', { outputFile: 'playwright-report/results.json' }],
  ],
  use: {
    // 0 MB wasted on passes, only captures proof on failures:
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure', // Interactive filmstrip + DOM inspector
  },
});
```

Run command:
```bash
bun x playwright test --reporter=html
```

---

### Pattern C: Generate Standalone HTML Visual Dashboard
*Consolidates JSON results + Screenshots into a single shareable HTML file.*

Run via `bun -e`:
```javascript
import fs from 'fs';

const report = {
  timestamp: new Date().toISOString(),
  suite: "Tournament App E2E",
  passed: 18,
  failed: 1,
  cases: [
    { id: "TC_REG_01", title: "Register with valid credentials", status: "PASS", duration: "0.42s", proof: "TC_REG_01_pass.png" },
    { id: "TC_REG_02", title: "Capacity limit blocks extra entries", status: "FAIL", duration: "0.58s", proof: "TC_REG_02_fail.png", error: "Expected disabled button but was clickable" }
  ]
};

const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>QA Visual Report - \${report.suite}</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #0f172a; color: #f8fafc; padding: 24px; }
    .card { background: #1e293b; border-radius: 12px; padding: 20px; margin-bottom: 16px; border: 1px solid #334155; }
    .pass { color: #4ade80; font-weight: bold; }
    .fail { color: #f87171; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #334155; }
    th { background: #0f172a; color: #94a3b8; }
    img.proof { max-width: 140px; border-radius: 6px; cursor: pointer; transition: transform .2s; }
    img.proof:hover { transform: scale(3.5); z-index: 100; position: relative; }
  </style>
</head>
<body>
  <h1>📊 \${report.suite} - QA Visual Dashboard</h1>
  <div class="card">
    <p>Tổng ca test: <strong>\${report.passed + report.failed}</strong> | <span class="pass">✔ \${report.passed} PASS</span> | <span class="fail">✖ \${report.failed} FAIL</span></p>
  </div>
  <table>
    <thead><tr><th>ID</th><th>Tính năng</th><th>Trạng thái</th><th>Thời gian</th><th>Ảnh Proof</th></tr></thead>
    <tbody>
      \${report.cases.map(c => \`<tr>
        <td>\${c.id}</td>
        <td>\${c.title}\${c.error ? \`<div class="fail" style="font-size:12px">\${c.error}</div>\` : ''}</td>
        <td class="\${c.status.toLowerCase()}">\${c.status}</td>
        <td>\${c.duration}</td>
        <td>\${c.proof ? \`<img class="proof" src="screenshots/\${c.proof}" alt="proof"/>\` : '-'}</td>
      </tr>\`).join('')}
    </tbody>
  </table>
</body>
</html>`;

fs.writeFileSync('build/reports/visual_report.html', html);
console.log('✅ Generated standalone visual report at build/reports/visual_report.html');
```

---

## 3. ISTQB Excel Test Case Standard Specification

When requested to export Excel test cases, adhere to this structure:

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

## 4. Anti-Bloat, Cleanup & File Overwrite Rules
1. **Bảo toàn Test Code Vĩnh Viễn (`test/`)**: Toàn bộ file code kiểm thử (`*_test.dart`, `*.spec.ts`) là tài sản cốt lõi của dự án, **tuyệt đối không bao giờ bị xóa hay đè mất**. Chúng được commit vào Git để chạy kiểm thử hồi quy (regression) lâu dài.
2. **Kế thừa Lịch Sử (History Trend JSON)**: Lưu số liệu tóm tắt (Pass/Fail rate theo thời gian) dưới dạng file JSON siêu nhẹ để vẽ biểu đồ tiến độ chất lượng giữa các lần chạy.
3. **Mặc định GHI ĐÈ Media Tạm Thời**: File `visual_report.html` và thư mục ảnh tạm `build/reports/screenshots/` sẽ ghi đè theo kết quả lần chạy mới nhất để chống phình ổ cứng.
4. **Chỉ giữ video khi THẤT BẠI (Retain on failure only)**: Ca test nào PASS thì hủy video ngay lập tức (0 byte dung lượng).
5. **Bảo vệ Git Repo**: Mọi thư mục báo cáo đều nằm trong `build/reports/` hoặc `playwright-report/` (đã có trong `.gitignore`), tuyệt đối không commit video hay ảnh vào Git.
