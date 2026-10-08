# GLOBAL AGENT RULES & ENGINEERING STANDARDS

## 1. MANDATORY COMPLETION DELIVERY REPORT (PROMPT-ALIGNED)
Whenever concluding or completing ANY task, answering a request, or reporting back to the user, you MUST ALWAYS format your response following this exact structure:

### 📋 1. Yêu cầu ban đầu (User Goals):
- [Trích xuất chính xác từng gạch đầu dòng mục tiêu từ prompt của người dùng]

### 🚀 TRẠNG THÁI HIỆN TẠI (Execution Status):
> **[ĐÃ CODE THẬT XONG 100%]** hoặc **[MỚI LẬP KẾ HOẠCH / ĐANG KHẢO SÁT, CHƯA ĐỤNG CODE]**
*(BẮT BUỘC ghi rõ ràng 1 trong 2 trạng thái trên để người dùng biết ngay lập tức).*

### ✅ 2. Những gì đã thực hiện (Execution Checklist - Viết Thật Đơn Giản, Dễ Hiểu):
- **Tóm tắt ngắn gọn**: Đã làm đúng cái gì cho tính năng người dùng yêu cầu (nói thẳng kết quả, không viết văn vở kỹ thuật hoa mỹ).
- **Vị trí sửa cụ thể**: File và dòng cụ thể đã sửa thật (`path/to/file:line`).

### 🔗 3. Những gì liên quan & Phạm vi ảnh hưởng (Side-effects & Related Changes):
- Các file bắt buộc phải sửa ké theo (nếu có). Nếu KHÔNG có file nào khác bị ảnh hưởng, ghi rõ: *"Không ảnh hưởng file khác"*.

### 🧪 4. Kết quả kiểm tra (Verification Evidence):
- Lệnh verify đã chạy (`npm test`, `flutter analyze`, v.v.) kèm kết quả chứng minh chạy được.

### 💡 5. Lưu ý từ Advisor (nếu có):
- Nếu thấy code cũ ở chỗ khác xấu/lỗi nhưng KHÔNG được phép sửa, ghi chú ngắn tại đây để người dùng biết.

> **BẮT BUỘC TUÂN THỦ**: Không được bỏ qua form này khi kết thúc lượt trả lời. Đây là quy chuẩn cao nhất của hệ thống.
---

## 1.5. Cloud Handoff Fast-Track (Bàn Giao Siêu Tốc Trong 15 Giây)
Khi người dùng nói: *"đẩy session dở dang lên github", "lên github làm tiếp", "chuyển lên github", "handoff", "lưu session"*:
- **TUYỆT ĐỐI CẤM**: Không phân tích code, không chạy linter/test, không spawn subagent, không lập todo rườm rà.
- **THỰC HIỆN NGAY TRONG 1 BƯỚC DUY NHẤT**:
  1. Chạy ngay: `powershell C:\Users\GIGABYTE\.omp\scripts\fast-handoff.ps1`
  2. Nếu có Issue URL hoặc thông tin bàn giao -> Báo cáo link Issue và dừng lại ngay trong 15-20 giây!

---

## 1.6. Cloud Cancel & Pull Fast-Track (Hủy Cloud & Kéo Về Local Tự Động)
Khi người dùng nói: *"hủy cloud kéo về", "hủy github kéo về", "kéo dở dang về máy", "lấy về local làm tiếp"*:
- **THỰC HIỆN NGAY TRONG 1 BƯỚC DUY NHẤT**:
  1. Chạy ngay: `powershell C:\Users\GIGABYTE\.omp\scripts\cancel-cloud-and-pull.ps1`
  2. Báo cáo xác nhận đã hủy workflow trên GitHub Actions và đã kéo code + session về máy, nhắc user gõ `omp --resume` là xong ngay!
---

## 2. Git Fast-Track (Tối ưu hóa thao tác Git & Push)

## 3. Quy Tắc Chọn Công Cụ Tìm Kiếm Code (Smart Code Search & Exploration)
Để tìm kiếm chính xác, nhanh nhất và không bao giờ nuốt RAM:

1. **Khi nào BẮT BUỘC dùng `ripwire` (Kiến trúc & Đồ thị quan hệ)**:
   - **Chỉ dùng khi**: Cần hiểu luồng dữ liệu lớn, tính toán phạm vi ảnh hưởng (*blast radius*), xem ai đang gọi hàm này (*impact*, *uses*), hoặc khám phá kiến trúc dự án mới (*explore*).
   - Cực kỳ mạnh vì nó cắt giảm 75% token rác so với đọc chay cả file.

2. **Khi nào BẮT BUỘC dùng `ast-grep` (Tìm kiếm cấu trúc cú pháp cụ thể)**:
   - Khi tìm class, function, widget tree, decorator trong TypeScript, Dart, Python, Go, Rust:
     `ast-grep run -p 'function $FN($$$ARGS) { $$$ }'`

3. **Khi nào dùng `grep` / `read` thuần (Chuỗi chữ, i18n, text cụ thể)**:
   - Khi tìm **chuỗi thông báo lỗi, text dịch đa ngôn ngữ (i18n vi.json, en.json), key config, file `.env`, file test**: Dùng `grep` trực tiếp là nhanh nhất và đúng trọng tâm nhất (như trong ảnh thực tế bạn đang làm).

## 4. Smart Feedback Loop: Advisor vs. Worker (No Infinite Loops)
- **Selective Auto-Fix (P0/P1 Blockers Only)**:
  - If the Advisor flags a **CRITICAL BUG, LOGIC FLAW, RUNTIME CRASH, or MISSING REQUIREMENT**: The Lead agent **MUST** automatically dispatch a quick follow-up to the worker to fix it before concluding.
  - If the Advisor only provides **STYLE / NITPICKS / OPTIONAL SUGGESTIONS**: Do **NOT** loop or re-dispatch (avoids wasting tokens and infinite debates). Instead, include the suggestion in section 5 of the final user report.

---

## 5. Superpowers Engineering Discipline & Clean Code
- **Non-Destructive Editing**: NEVER delete existing comments, docstrings, or unrelated logic. Keep edits surgical and minimal.
- **Evidence-First**: Always verify file paths, exported signatures, and imports before calling them. Never hallucinate functions or imports.
- **Clean Architecture & Early Returns**: Guard clauses early, max 2 levels of nested `if/else`, single-responsibility functions (< 40 lines).
- **Task Planning & Verification**: Before complex changes, establish discovery -> implementation -> verification steps. Verify with linter/tests (`flutter analyze`, `npm test`, etc.) before finishing.

---

## 6. Flutter & Dart Idioms
- **Aggressive `const`**: Prefix immutable widgets with `const`.
- **Pure `build()`**: Never perform computation, instantiate controllers, or make HTTP/DB calls inside `build()`.
- **Controller Lifecycle**: Always properly dispose controllers and stream subscriptions in `dispose()`.
- **Null Safety**: Clean use of `?.` and `??`. Never use bang (`!`) unless non-nullness is mathematically guaranteed.

---

## 7. Tool Schema Compliance (Strict Validation Guard)
To prevent tool schema validation errors (`- pattern must be regex pattern`, `- query must be plain language`, `- op must be hub operation`, `- eval missing code/language`):
- **Tool `grep`**: ALWAYS provide `pattern: "<regex>"`. NEVER use `query` or pass empty object.
- **Tool `find`**: ALWAYS provide `query: "<natural language concept>"`. NEVER use `pattern`.
- **Tool `hub`**: ALWAYS provide `op: "start"` when starting a process, along with `command`. For regular build/test/run commands, execute them directly via terminal (`bash`/terminal tool) instead of invoking `hub`.
- **Tool `eval`**: NEVER invoke `eval` with an empty object `{}`. Prefer `bash` for commands/scripts. If using `eval`, you MUST provide both `language: "js"` (or `"py"`) and `code: "<executable code>"`.

---

## 8. Continuous Self-Evolution & Memory Distillation (Hermes-Style)
OMP operates with a perpetual shared memory layer via OpenViking (`openviking` MCP server). To continuously improve and never repeat mistakes:

1. **Before Taking Action (Recall & Context Injection)**:
   - When facing a complex bug, architecture decision, or user preference ambiguity, query memory first:
     `call: openviking__find(query: "<topic / error message / tech stack>")`
   - Apply past lessons and avoid repeating verified failures.

2. **Self-Distillation on Task Completion (Extract & Filter)**:
   - **DO NOT** memorize raw chatter, casual greetings, or temporary logs.
   - **ONLY DISTILL**:
     - *Verified Successes (Good)*: Solution patterns for non-trivial bugs, obscure API behaviors, project architectural conventions, user-explicit workflow rules.
     - *Anti-Patterns (Bad)*: Approaches that failed during testing, invalid dependencies, commands that caused runtime errors.
   - **Format for Remembering**:
     `call: openviking__remember(text: "[TAG: SOLUTION/RULE] Context: ... | Issue: ... | Verified Solution: ...")`

3. **Active Memory Correction & Pruning (Fix & Forget)**:
   - If a previously stored rule or workaround is proven wrong, outdated, or superseded by a cleaner solution:
     1. Search for the obsolete memory: `openviking__find(query: "...")`
     2. Remove or overwrite the outdated memory using `openviking__forget(uri: "...")` or `openviking__edit`.
     3. Save the newly verified solution.
   - **Never allow conflicting or obsolete advice to linger in the memory bank.**

---

## 9. Low-RAM Web Server & Dev/Test Protocol
- **Runtime Preference (Bun > Node)**:
  - Luôn ưu tiên dùng `bun` thay vì `node`/`npm`/`yarn` khi chạy script, API mock, testing runner hoặc dev server (ví dụ: `bun run dev`, `bun test`, `bun run build`).
  - Runtime của `bun` ngốn cực ít RAM (~30MB–60MB) so với Node (~200MB–600MB+).
- **Turbopack Bắt Buộc (Next.js)**:
  - CẤM chạy Webpack (`next dev --webpack` hoặc Next.js mặc định không cờ khi dự án hỗ trợ Turbo).
  - Luôn chạy với cờ `--turbo` (ví dụ: `pnpm dev --turbo` hoặc `bun run dev -- --turbo`).
  - Nếu phải dùng Node cho Next.js, luôn giới hạn heap size:
    `NODE_OPTIONS="--max-old-space-size=512"` (PowerShell: `$env:NODE_OPTIONS="--max-old-space-size=512"`).
- **Quy trình Test Web Tiết Kiệm RAM**:
  1. **Tái sử dụng server có sẵn**: Kiểm tra cổng trước (ví dụ cổng `3101` hoặc `3000`). Nếu đã có server chạy sẵn, tuyệt đối KHÔNG khởi tạo thêm instance mới.
  2. **Headless & Direct HTTP Verification**: Khi test API hoặc render trang, ưu tiên dùng `curl`, `fetch`, hoặc test script dạng console thay vì bật trình duyệt Chrome/Puppeteer ngốn hàng GB RAM.
  3. **Tắt Server Ngay Khi Xong Test**:
     - Dev server phục vụ test KHÔNG được để chạy ngầm vĩnh viễn.
     - Sau khi verify xong endpoint / UI, phải tắt ngay tiến trình (PowerShell: `Stop-Process -Id <PID> -Force` hoặc `taskkill /F /PID <PID>`).
  4. **Giới hạn số worker**: Khi build hoặc test với Jest/Vitest/Playwright, luôn truyền `--maxWorkers=1` hoặc `--concurrency=1` để tránh fork nhiều process Node song song làm tràn RAM.

---

## 10. UI Wireframe & Mockup Handover Protocol (Skill: `wireframe-handover`)
- **Nguyên tắc Wireframe-First**: Khi người dùng gửi ảnh giao diện cũ, screenshot, hoặc link web kèm yêu cầu làm lại UI / thêm tính năng:
  - **TUYỆT ĐỐI KHÔNG** đè code dự án hoặc viết logic thật ngay lập tức.
  - Kích hoạt ngay skill `wireframe-handover` (`C:\Users\GIGABYTE\.omp\agent\skills\wireframe-handover\SKILL.md`).
- **Vẽ khung trực tiếp ngay trong Prompt (Siêu nhẹ, 0 byte file, xem ngay tại terminal)**:
  1. Vẽ khung **ASCII Box / Unicode Grid** (`┌─┐`, `│ │`, `└─┘`) hoặc Mermaid thể hiện rõ vị trí Navbar, Sidebar, Card, Table, Form, Buttons.
  2. Đánh dấu rõ các khối `[Mới: ...]` hoặc vị trí đã điều chỉnh theo yêu cầu của user.
  3. Dừng lại hỏi chốt ý kiến:
     *"Khung layout phác họa trực tiếp ở trên bạn xem đã đúng ý chưa? Cần đổi vị trí khối nào hay thêm bớt gì trước khi mình bắt đầu code thật không?"*
  4. Chỉ khi người dùng phản hồi duyệt ("ok", "tiến hành đi") mới bắt đầu viết code vào dự án.

---

## 12. Pixel-Perfect Responsive UI Protocol (Skill: `pixel-perfect-responsive`)
- **Quy chuẩn bắt buộc cho mọi dòng code UI (Web & Flutter)**:
  - **CẤM kích thước cứng (No Fixed Width/Height)**: Cấm gán width cứng (`width: 600px`, `width: 380`) khiến màn hình nhỏ bị tràn (horizontal scroll / RenderFlex overflow).
  - **Mobile-First & Fluid Spacing**:
    - Web: Bắt buộc dùng CSS `clamp(min, val, max)` cho typography/padding và CSS Grid `auto-fit`/`minmax` để tự thích ứng từ màn 4.7" đến 34" Ultrawide.
    - Flutter: Bắt buộc dùng `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`) hoặc `LayoutBuilder` / `Flexible` / `Wrap` để không bao giờ bị RenderFlex vàng/đen.

---

---

## 13. Adversarial Planning & Edge-Case Protocol (Tư Duy Kế Hoạch Chống Lỗ Hổng)
- **Bắt buộc áp dụng trong khâu PLAN trước khi đụng vào code**:
  1. **Tự phản biện lỗi biên (Adversarial Self-Audit)**:
     - Luôn lường trước ít nhất 3 kịch bản xấu nhất: Mạng rớt / timeout giữa chừng, dữ liệu null / mảng rỗng, thao tác bấm đúp liên tục (race condition / idempotency).
  2. **Cite-Check (Kiểm chứng tham số & schema thật)**:
     - Tuyệt đối cấm bịa hàm / bịa tên trường API. Bắt buộc đọc file schema hoặc type definition trước khi đưa vào kế hoạch.
  3. **Surgical Scope**:
     - Kế hoạch phải chỉ rõ file nào cần sửa và sửa đúng đoạn nào (phẫu thuật từng dòng), cấm viết lại toàn bộ file.


## 11. End-to-End Implementation Discipline (Làm Tới Nơi Tới Chốn)
- **Được phép chủ động sửa toàn bộ các file liên quan**:
  - Khi làm tính năng người dùng yêu cầu, AI **ĐƯỢC PHÉP VÀ NÊN chủ động sửa trọn gói** các thành phần liên quan (route, model, database schema, state, UI, API service) để tính năng chạy được từ A-Z.
  - Chỉ cần nhớ nguyên tắc cốt lõi: **Mọi file sửa đều phải phục vụ trực tiếp cho tính năng chính**, không đi sửa lung tung ngoài lề.
  - Báo cáo rõ ràng: Đã sửa những file nào, tính năng đã code thật xong chưa.
