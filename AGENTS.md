# GLOBAL AGENT RULES & ENGINEERING STANDARDS

## 1. CLINE ADAPTIVE COMMUNICATION & DIRECT-DELIVERY PROTOCOL (CHUẨN TRỌNG TÂM - ZERO RUSSIAN)
AI BẮT BUỘC tuân thủ phong cách giao tiếp linh hoạt, đi thẳng vào bản chất và tuyệt đối KHÔNG dùng form mẫu quan liêu rườm rà:
- 🛑 **CẤM TIẾNG NGA 100%**: Tuyệt đối không sinh tiếng Nga trong `todo`, `i` intent của tool (`Проверка`, `Запуск`, `Подготовка`, `Доставка`), hay trong hội thoại. Mọi nội dung hiển thị phải là 100% Tiếng Việt (hoặc tiếng Anh kỹ thuật).

### 1. KHI HỎI ĐÁP, GIẢI THÍCH, KHẢO SÁT, TƯ VẤN (Conversation / Q&A / Research):
- **CẤM FORM MẪU BÁO CÁO HÀNH CHÍNH**: Tuyệt đối KHÔNG in các đề mục cứng nhắc ("Yêu cầu ban đầu", "Trạng thái hiện tại", "Checklist", "Phạm vi ảnh hưởng", "Kết quả verify").
- **ÁP DỤNG NGUYÊN LÝ 3 TẦNG (CLINE 3-LAYER EXPLANATION)**:
  1. 🎯 **Kết luận trực tiếp (Bottom Line Up Front)**: Trả lời thẳng vào câu hỏi trong 1-2 câu đầu tiên. Có hay không, được hay không, bản chất là gì.
  2. 💡 **Bản chất cốt lõi (Giải thích dễ hiểu)**: Cung cấp đầy đủ nguyên nhân sâu xa từ gốc rễ, nhưng dùng ngôn ngữ đời thường, hình tượng hóa thực tế (analogies) thay vì xả thuật ngữ tiếng Anh khó hiểu (jargon).
  3. 🚀 **Tác động & Lời khuyên hành động**: Tác động thực tế là gì (ảnh hưởng hiệu năng, rủi ro) và người dùng cần làm gì tiếp theo (tối đa 1-2 phương án rõ ràng).

### 2. CHỈ KHI CODE THẬT / SỬA BUG / LÀM TÍNH NĂNG (Code Changes & Bugfixes):
- Sau khi viết code hoặc sửa xong các file, bàn giao kết quả CÔ ĐỌNG trong 3 gạch đầu dòng:
  - ✅ **Đã hoàn thành**: Tóm tắt 1 câu việc đã làm xong thật (kèm trạng thái: **[ĐÃ CODE THẬT XONG 100%]**).
  - 📍 **Vị trí sửa cụ thể**: File và dòng cụ thể đã sửa (`path/to/file:line`).
  - 🧪 **Kiểm tra thực tế**: Lệnh test/linter đã chạy và kết quả xác minh pass.

### 3. QUY TẮC ĐÍNH KÈM GÓC NHÌN ADVISOR (ADVISOR INSIGHT PROTOCOL):
- Hệ thống có model Advisor chạy ngầm liên tục phản biện và soi rọi các góc khuất kỹ thuật:
  - **Khi không có gì đặc biệt hoặc chỉ là nhắc nhở hiển nhiên**: **Im lặng 100%**, tuyệt đối không viết câu sáo rỗng kiểu "không có lưu ý gì".
  - **Khi Advisor phát hiện Insight đáng giá** (bẫy ngầm tương lai, nghẽn hiệu năng, giải pháp gọn hơn, hoặc rủi ro vỡ cấu trúc): Tự động đính kèm duy nhất 1 khối ở cuối:
    > 💡 **Góc nhìn Advisor**: [1-2 câu cô đọng chỉ thẳng bẫy ngầm hoặc mẹo tối ưu thực chiến từ góc nhìn Senior].
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
---

## 1.7. Visual QA Fast-Track (Lệnh Tự Nhiên: "test cho tôi flow này...")
Khi người dùng nói tự nhiên như: `"test cho tôi flow này..."`, `"test flow này"`, `"test màn này"`, `"test"`, `"kiểm tra flow..."`:
- **KHÔNG giải thích dài dòng, KHÔNG in hàng trăm dòng log test làm loãng chat.**
- **THỰC HIỆN TỰ ĐỘNG BẰNG SUBAGENT NGẦM**:
  1. Chạy ngầm bằng subagent miễn phí (hoặc lệnh nền `flutter test` / `bun test`).
  2. **Bảo tồn Dữ Liệu & Chống Rác (Strict Test Data Retention)**:
     - **Test code cũ (`test/`)**: GIỮ NGUYÊN 100%, tích lũy làm tài sản dự án trong Git, tuyệt đối không tự ý xóa.
     - **Lịch sử test (Trend JSON)**: Kế thừa và nối tiếp để vẽ biểu đồ so sánh chất lượng giữa các lần chạy.
     - **Ảnh / Video Proof tạm**: Ghi đè theo lượt chạy mới nhất vào `build/reports/` (không commit vào Git, tự hủy video khi PASS) để chống đầy ổ cứng.
  3. Chỉ trả về kết quả cô đọng đúng **3 dòng**:
     - 📊 **Kết quả**: X/Y ca test PASS (thời gian: Z giây).
     - 🖼️ **Ảnh proof / Báo cáo**: Đường dẫn mở file HTML/PNG (nếu có).
     - 🔴 **Lỗi (nếu có)**: Tên test case bị hỏng kèm vị trí file/dòng.
---

## 1.8. Lavish Visual Plan Protocol (CHỦ ĐỘNG TRỰC QUAN HÓA & KỶ LUẬT 1 TAB)
- **KHI NÀO AI BẮT BUỘC DÙNG LAVISH**:
  - 🎯 **BẮT BUỘC 100% KHI LẬP KẾ HOẠCH (PLAN REVIEW / PLAN MODE)**:
    + Bất cứ khi nào Agent bước vào pha **Lập kế hoạch (Plan Review / Plan Mode / Bước 1..N / Assumptions & contingencies)** như trong hình: **CẤM CHỈ IN CHỮ TRONG TERMINAL**.
    + BẮT BUỘC xuất toàn bộ các bước (Context, Approach, Bước 1..8, Critical Files, Verification, Assumptions) vào `.lavish/plan.html` kèm sơ đồ luồng Mermaid và mở trình duyệt để người dùng xem và duyệt trực quan!
  - 🎯 **CHỦ ĐỘNG MỞ KHI**:
    1. **Có kế hoạch, kiến trúc hoặc phân tích hệ thống**: Cần sơ đồ Mermaid/SVG, bảng đối chiếu phương án hoặc kế hoạch nhiều bước.
    2. **Có sự so sánh, đánh đổi (Trade-offs)**: Đối chiếu phương án A vs B giúp người dùng dễ chọn.
    3. **Nội dung dài hoặc dạng trực quan**: Xem qua trang web HTML sẽ trực quan và dễ nắm bắt hơn nhiều so với đọc chữ dài trong terminal.
    4. **Khi người dùng có nhắc đến**: *"lavish"*, *"plan"*, *"kế hoạch"*, *"sơ đồ"*, *"trực quan"*, *"so sánh"*, *"báo cáo"*.
  - 💬 **Chỉ trả lời ngắn bằng chữ khi**: Câu hỏi một dòng ngắn, kiểm tra trạng thái tức thì, hoặc chào hỏi thông thường.
- **XỬ LÝ TAB TRÌNH DUYỆT (KỂ CẢ KHI BẠN LỠ TAY TẮT TAB)**:
  - **Lần đầu tiên**: Mở đúng **1 tab duy nhất** trên trình duyệt cho bạn xem.
  - **Nếu tab đang mở bình thường**: AI chỉ ghi đè file `.lavish/plan.html` trên đĩa, tab cũ sẽ **tự động cập nhật nội dung mới (Live Reload)** mà không mở thêm tab mới.
  - **Nếu bạn đã lỡ tay tắt tab đó đi**: AI kiểm tra nếu server/tab đã đóng thì mới chạy lại với cờ `--reopen` để mở lại đúng 1 tab mới cho bạn tiếp tục xem, tuyệt đối không đẻ tràn lan nhiều tab.
## 2. Git Fast-Track & Kỷ Luật Đa Session Thông Minh (Concurrent Multi-Session Auto-Rebase)
- **CƠ CHẾ TỰ ĐỘNG KHI CHẠY NHIỀU SESSION CÙNG LÚC (Zero-Pause Multi-Session Flow)**:
  - Khi bạn chạy nhiều session song song (Session A vừa đẩy code lên `main`, Session B chuẩn bị merge):
  - **CẤM HOẢNG LOẠN DỪNG CHỜ (Zero Integration Paused)**: AI **TUYỆT ĐỐI KHÔNG** để detached HEAD hay dừng lại hỏi menu lựa chọn.
  - **TỰ ĐỘNG REBASE THÔNG MINH**:
    1. AI tự động chạy `git fetch origin main`.
    2. Tự động `git rebase origin/main` (nối tiếp code của mình lên trên những gì Session A vừa làm).
    3. Nếu có conflict đơn giản: tự động resolve hoặc `git merge origin/main --no-edit`.
    4. Gộp thẳng vào `main` và `git push origin main` ngay lập tức!
- **CẤM TỰ TIỆN TẠO WORKTREE / NHÁNH RÁC**:
  - Trừ khi người dùng nói rõ: *"tạo branch mới / tạo worktree"*, AI **TUYỆT ĐỐI KHÔNG** tự ý chạy `git worktree add`, `git checkout -b <nhanh_moi>` hoặc tự cách ly vào thư mục `.worktrees/` hay `D:/tmp/`.
  - Mọi thao tác sửa lỗi, code tính năng, refactor **BẮT BUỘC thực hiện trực tiếp trên nhánh hiện tại (hoặc `main`)**.
- **Quy trình kết thúc công việc (One-Shot Clean Cutover)**:
  - Làm xong: `git add . && git commit -m "..." && git push origin <current_branch>`.
  - Dọn sạch ngay mọi nhánh tạm và worktree trong 1 giây (`git worktree prune`).
## 3. Quy Tắc Chọn Công Cụ Tìm Kiếm Code (Smart Code Search & Exploration)
Để tìm kiếm chính xác, nhanh nhất và không bao giờ nuốt RAM:

1. **Khi nào BẮT BUỘC dùng `ripwire` & Quy tắc tối ưu chống nghẽn CPU**:
   - **Chỉ dùng khi**: Cần hiểu luồng dữ liệu lớn, tính toán phạm vi ảnh hưởng (*blast radius* - `impact`), xem ai đang gọi hàm này (*uses*), hoặc định vị kiến trúc (*explore*).
   - **QUY TẮC BẢO VỆ CPU 0%**:
     + **TUYỆT ĐỐI CẤM** quét thư mục cha (`Duancanhan`, `D:/`). Bắt buộc truyền đường dẫn dự án con cụ thể (`Duancanhan/AICheckVAR` hoặc `Duancanhan/Project_QuanLyGiaiDau`).
     + Luôn đặt giới hạn token vừa phải (`budget_tokens: 1500` đến `3000`) để máy chủ trả lời trong < 1 giây, tuyệt đối không để CPU bị vắt kiệt.
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

## 6. Flutter & Dart Idioms & Live Device Testing (scrcpy)
- **Aggressive `const`**: Prefix immutable widgets with `const`.
- **Pure `build()`**: Never perform computation, instantiate controllers, or make HTTP/DB calls inside `build()`.
- **Controller Lifecycle**: Always properly dispose controllers and stream subscriptions in `dispose()`.
- **Null Safety**: Clean use of `?.` and `??`. Never use bang (`!`) unless non-nullness is mathematically guaranteed.
- **Live Device Mirroring & Headless Testing (scrcpy & adb)**:
  - **Khi test tự động / CI / Headless**: Chạy trực tiếp trên thiết bị hoặc Dart VM, **hoàn toàn KHÔNG cần mở cửa sổ `scrcpy`** để tiết kiệm tài nguyên. Nếu cần ảnh bằng chứng (Visual QA), chụp ngầm qua ADB: `adb exec-out screencap -p > proof.png`.
  - **Khi cần xem/điều khiển trực tiếp qua scrcpy**: Khởi chạy với cờ **`--turn-screen-off`** để tắt hẳn màn hình điện thoại (tiết kiệm pin, chống nóng máy, chỉ hiển thị cửa sổ điều khiển 420px trên Windows):
    `scrcpy --no-audio --stay-awake --turn-screen-off --window-title "Flutter Live Device" --window-width 420`
  - **Nếu chưa có thiết bị kết nối (`adb devices` rỗng)**: AI **bắt buộc chủ động nhắc người dùng ngay**: *"Bạn hãy cắm cáp điện thoại hoặc bật Wi-Fi debug để mình kết nối nhé!"*. Tuyệt đối không âm thầm bỏ qua hoặc tự ý đòi cài máy ảo/giả lập ngốn RAM.
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

## 9. High-Performance 32GB RAM & Multi-Worker Dev/Test Protocol
- **Runtime Preference (Bun > Node)**:
  - Luôn ưu tiên dùng `bun` thay vì `node`/`npm`/`yarn` khi chạy script, API mock, testing runner hoặc dev server (ví dụ: `bun run dev`, `bun test`, `bun run build`).
  - Runtime của `bun` khởi động siêu tốc và tốn rất ít RAM tĩnh (~30MB–60MB).
- **Turbopack Bắt Buộc (Next.js)**:
  - CẤM chạy Webpack (`next dev --webpack` hoặc Next.js mặc định không cờ khi dự án hỗ trợ Turbo).
  - Luôn chạy với cờ `--turbo` (ví dụ: `pnpm dev --turbo` hoặc `bun run dev -- --turbo`).
  - Nâng trần bộ nhớ cho Node.js / TypeScript Compiler phục vụ các dự án lớn:
    `NODE_OPTIONS="--max-old-space-size=4096"` (PowerShell: `$env:NODE_OPTIONS="--max-old-space-size=4096"`). Đảm bảo `tsc --noEmit` và `next build` chạy mượt mà, không bao giờ bị lỗi `JavaScript heap out of memory`.
- **Quy trình Test Web & Khai Thác Đa Nhân**:
  1. **Tái sử dụng server có sẵn**: Kiểm tra cổng trước (ví dụ cổng `3101` hoặc `3000`). Nếu đã có server chạy sẵn, tuyệt đối KHÔNG khởi tạo thêm instance mới.
  2. **Headless & Direct HTTP Verification**: Khi test API hoặc render trang, ưu tiên dùng `curl`, `fetch`, hoặc test script dạng console thay vì bật trình duyệt Chrome/Puppeteer ngốn hàng GB RAM.
  3. **Tắt Server Ngay Khi Xong Test**:
     - Dev server phục vụ test KHÔNG được để chạy ngầm vĩnh viễn.
     - Sau khi verify xong endpoint / UI, phải tắt ngay tiến trình (PowerShell: `Stop-Process -Id <PID> -Force` hoặc `taskkill /F /PID <PID>`).
  4. **Khai thác đa nhân song song (Multi-Worker Concurrency)**: Với 32GB RAM và CPU 6 nhân 12 luồng, cho phép chạy `--maxWorkers=4` hoặc `--concurrency=4` khi test (Vitest, Jest, Playwright, Flutter test) để tăng tốc độ kiểm thử gấp 3–4 lần mà không lo tràn RAM.
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

---

## 14. 60FPS Fluid Animation & Micro-Interaction Protocol (Skill: `fluid-animations`)
- **Quy chuẩn bắt buộc cho mọi dòng code Animation (Web & Flutter)**:
  - **CẤM Duration rùa bò (`> 350ms`) & Curves đơ cứng (`linear`, `easeInOut`)**:
    - Micro-interaction phản hồi bấm nút: Bắt buộc từ **`100ms – 160ms`** (ngay lập tức).
    - Dialog, Popup, BottomSheet: Bắt buộc từ **`200ms – 260ms`**.
  - **Phản hồi vật lý Spring (Physics-Based Feel)**:
    - Web (`framer-motion`): Nút bấm, Card phải có `whileTap={{ scale: 0.96 }}` và `whileHover` với lò xo `stiffness: 450, damping: 25`.
    - Flutter (`flutter_animate`): Dùng `Curves.easeOutBack` (độ nảy nhẹ tự nhiên) hoặc `Curves.easeOutCubic` (vào nhanh, phanh êm).
  - **Hiệu ứng thác nước so le (Staggered Flow)**:
    - Danh sách List / Grid tuyệt đối không được xuất hiện đồng loạt thô cứng; bắt buộc có độ trễ so le **`30ms – 50ms`** giữa các phần tử để mắt thấy lướt như dòng nước.

---

## 15. Real Engineering Protocols (Domain Modeling, Deep Modules & Wizard)
- **Quy chuẩn Domain Modeling (`domain-modeling`)**:
  - Khi thiết kế tính năng hoặc schema, kiểm tra và duy trì `GLOSSARY.md` với danh sách `_Avoid_` để thống nhất 100% thuật ngữ nghiệp vụ giữa Database, API và UI.
  - Chỉ tạo ADR trong `docs/adr/` khi thỏa đủ 3 điều kiện: Khó đảo ngược, Gây bất ngờ nếu không giải thích, và Có sự đánh đổi thực sự.
- **Quy chuẩn Deep Module & Design-It-Twice (`codebase-design`)**:
  - Luôn thiết kế **Deep Module**: Interface tối giản, ít hàm, ít tham số nhưng giấu logic sâu bên trong. Bài trừ các Shallow Module / Wrapper pass-through mỏng dính làm rác code.
  - Khi thiết kế hệ thống lớn: Áp dụng Design-It-Twice (chạy subagent song song thiết kế 3 phương án Interface đối nghịch) để chọn ra thiết kế tối ưu nhất.
- **Quy chuẩn Wizard Script (`wizard`)**:
  - Khi gặp thao tác thủ công người dùng phải làm (nhập secret key, OAuth, dashboard third-party, migration): Không xả tài liệu dài dòng, hãy tự sinh script `template.ps1` (cho Windows) hoặc `template.sh` để dẫn đường từng bước tương tác.
- **Quy chuẩn Reset & Tái diễn giải (`wait-what`)**:
  - Khi người dùng phản hồi *"khoan đã"*, *"chưa hiểu"*, *"nói lại xem"*: Lập tức dừng cãi/giải thích kỹ thuật rườm rà; hạ tông kỹ thuật, lược bỏ jargon, giải thích lại bằng ngôn ngữ đời thường và chốt 2 lựa chọn A/B.


---

---

## 16. Regression-Guard & Pre-Test Awareness Protocol (Quy Chuẩn Đọc Test Cũ Trước Khi Code)
Khi người dùng yêu cầu sửa lỗi, làm tính năng mới hoặc nâng cấp giao diện, AI **BẮT BUỘC** tuân thủ chu trình 4 bước để không bao giờ phá vỡ hệ thống cũ:

1. **BƯỚC 1: Đọc & Khảo Sát Test Cũ (Pre-Test Inspection - BẮT BUỘC TRƯỚC KHI ĐỤNG CODE)**:
   - Trước khi sửa bất kỳ file logic hay component nào: Phải quét thư mục test liên quan (`test/e2e/*.spec.ts`, `tests/`, `*_test.dart`, hoặc `docs/testcases.xlsx`).
   - Đọc kỹ các ca test hiện có đang assert cái gì (tên selector UI, HTTP status, schema dữ liệu, luồng điều hướng).
   - Nắm rõ: *Tính năng này đã có bài test nào bảo vệ chưa? Nếu sửa file này thì bài test nào sẽ bị ảnh hưởng?*

2. **BƯỚC 2: Kiểm Định Phạm Vi Ảnh Hưởng (Blast Radius & Regression Check)**:
   - Dùng `ripwire` (`impact`, `uses`) hoặc `ast-grep` để xem hàm/component này đang được ai gọi.
   - Tuyệt đối KHÔNG sửa code kiểu phá vỡ hợp đồng cũ (Breaking changes) trừ khi người dùng yêu cầu thay đổi nghiệp vụ.

3. **BƯỚC 3: Test-Driven & Viết Test Mới Cho Tính Năng Mới (New Coverage)**:
   - Nếu là tính năng mới: Viết thêm kịch bản test (hoặc test case mới) bao phủ luồng mới, gắn thẻ ID rõ ràng (ví dụ: `TC-FEAT-01`).
   - Cập nhật mục lục danh mục test: Giữ nguyên các test cũ, chỉ nối tiếp thêm (append) tính năng mới vào hệ thống.

4. **BƯỚC 4: Chạy Verify Thực Tế (Allure & Playwright Verification - Local vs Cloud Delegation)**:
   - **Tùy chọn A (Chạy nhẹ tại Local)**: Nếu chỉ là Unit Test, API test, hoặc kiểm tra logic biên nhỏ: Chạy ngầm trong terminal (`pnpm test`, `flutter test`).
   - **Tùy chọn B (TỰ ĐỘNG ĐẨY LÊN GITHUB ACTIONS TEST E2E - Khuyên Dùng Cho UI Nặng)**:
     - Khi test giao diện Web E2E (đòi hỏi bật Docker Postgres, Redis, NestJS, Next.js, Chromium): **AI TỰ ĐỘNG KÍCH HOẠT CLOUD HANDOFF (`fast-handoff.ps1`)** để đẩy lên GitHub Actions máy ảo 16GB RAM tự chạy ngầm 100%.
     - Máy tính ở nhà KHÔNG bị bật Docker hay dev server làm lag máy, nghẽn RAM khi người dùng đang làm việc hay chơi game.
     - Sau khi Cloud chạy xong Playwright & Allure Report: Tự động ghi nhận PASS/FAIL và đính kèm link xem báo cáo trực quan.

---

## 17. Cua-Driver Zero-Focus-Steal & Background-Only Protocol (Chạy Nền 100% Không Cướp Chuột/Phím)
Khi sử dụng `cua-driver` để thao tác, điều khiển hoặc tự động hóa ứng dụng desktop (Windows/Linux/macOS), AI **BẮT BUỘC TUÂN THỦ NGUYÊN TẮC HOẠT ĐỘNG CHÌM DƯỚI NỀN 100%**:

1. **TUYỆT ĐỐI KHÔNG CƯỚP TIÊU ĐIỂM (Zero-Focus-Steal)**:
   - **CẤM** tự ý gọi `bring_to_front` hoặc kích hoạt cửa sổ nhảy lên đè màn hình của người dùng.
   - Khi khởi chạy app: Luôn dùng `launch_app` ở chế độ chạy nền (`SW_SHOWNOACTIVATE`) để ứng dụng âm thầm mở dưới taskbar mà không giật tiêu điểm từ cửa sổ người dùng đang gõ.

2. **ƯU TIÊN CÔNG NGHỆ CHẠY NGẦM UIA (`element_token`) THAY VÌ DI CHUỘT THẬT**:
   - **Click ngầm**: Bắt buộc click qua `element_token` (UI Automation / Windows Message) — cơ chế này click trực tiếp vào nút bấm ngay cả khi cửa sổ đang bị thu nhỏ (minimized), bị che khuất hoặc nằm dưới nền. Con trỏ chuột thật của người dùng vẫn tự do di chuyển không bị giật.
   - **Gõ phím ngầm (`type_text`, `press_key`)**: Gửi lệnh qua `PostMessage(WM_CHAR / WM_KEYDOWN)` thẳng tới PID của ứng dụng mục tiêu. Người dùng vẫn đang gõ code hoặc chat bình thường mà không bị chèn chữ lung tung.

3. **CHỤP ẢNH & KIỂM TRA CHỨNG MINH TỰ ĐỘNG (Headless Inspection)**:
   - Quét trạng thái qua `get_window_state(pid, window_id)` và `verify_state`: Chụp ảnh cửa sổ ngầm qua bộ đệm đồ họa mà không cần kéo cửa sổ ra trước mặt người dùng.

4. **CHỈ ĐƯỢC PHÉP ĐƯA LÊN MÀN HÌNH CHÍNH KHI NGƯỜI DÙNG YÊU CẦU**:
   - Trừ phi người dùng nói rõ: *"mở cửa sổ lên cho tôi xem"*, *"đưa ra ngoài màn hình"*, AI tuyệt đối giữ mọi hành vi dưới nền 100%. Người dùng có thể vừa chơi game, xem phim, gõ code trong khi Cua-Driver âm thầm thao tác app bên dưới.

---

## 18. Anti-Patterns & Zero-Repeat-Mistakes Protocol (Bắt Buộc Tránh Vết Xe Đổ)
- Trước khi thực hiện các tác vụ hệ thống, thao tác file, tìm kiếm ripwire hay cấu hình Node/Cloud:
  AI **BẮT BUỘC** đối chiếu các bẫy kỹ thuật trong file: `C:\Users\GIGABYTE\.omp\agent\ANTI_PATTERNS.md`.
- Tuyệt đối không lặp lại các lỗi đã được lập chỉ mục (lỗi mkdirSync root D:\, lỗi Ripwire nổ CPU, lỗi đẻ tab Lavish, lỗi node:sqlite < 22.5).
- Áp dụng triệt để nguyên lý **Agentless Surgical Edit**: Định vị phẫu thuật qua AST -> Chỉ mở vùng dòng liên quan -> Sửa đúng 2-5 dòng bằng `edit` có Hash Tag, cấm viết lại toàn bộ file.