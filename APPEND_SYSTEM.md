# 🌐 QUY TẮC BẮT BUỘC SỐ 0: 100% TIẾNG VIỆT (VIETNAMESE ONLY)
- AI BẮT BUỘC PHẢI HỎI, TRẢ LỜI, BÁO CÁO VÀ GIAO TIẾP VỚI NGƯỜI DÙNG BẰNG 100% TIẾNG VIỆT TỰ NHIÊN.
- TUYỆT ĐỐI KHÔNG hỏi người dùng, không tạo câu hỏi lựa chọn (interactive questions / prompts / options / decisions) bằng tiếng Anh. Mọi câu hỏi xác nhận hay làm rõ ý định đều PHẢI viết bằng tiếng Việt.
- Chỉ giữ tiếng Anh cho tên code, tên hàm, đường dẫn file, CLI command và thuật ngữ kỹ thuật chuyên ngành không dịch được.

---

# 🚨 QUY TẮC ƯU TIÊN SỐ 1: CLOUD HANDOFF (BÀN GIAO LÊN GITHUB ACTIONS)
Khi người dùng nói bất kỳ câu nào như: "đẩy session workflow đang làm dở lên github", "đẩy session", "lưu session", "lên github làm tiếp", "chuyển lên github", "handoff", "lên mây làm tiếp":
1. Lưu code: `git add . && git commit -m "checkpoint before cloud handoff" && git push -u origin HEAD`
2. Tạo Issue: Gọi MCP GitHub `create_issue` trên repo `babydanh/agent-orchestrator` với title `[Handoff] <Tên nhiệm vụ>` kèm danh sách TODO `[x]` / `[ ]`, tên branch dở dang và checklist bàn giao.
3. Báo cáo link Issue và dừng lại ngay!

---

# ⚡ TỰ ĐỘNG KÍCH HOẠT TOÀN BỘ SKILLS THEO NGỮ CẢNH (FULL AUTO-SKILL ENGINE)
Khi nhận bất kỳ tác vụ nào, AI PHẢI TỰ ĐỘNG nhận diện ngữ cảnh và áp dụng ngay bộ skill tương ứng từ kho `~/.omp/agent/skills/` mà không cần người dùng nhắc tên:

### 1. Ý tưởng, Lập kế hoạch & Tổ chức thực thi
- **Trước khi bắt tay làm tính năng mới**: Tự động kích hoạt `brainstorming` (khảo sát yêu cầu, làm rõ ý đồ thiết kế).
- **Lập kế hoạch tổng thể**: Tự động dùng `writing-plans` để chia nhỏ milestone.
- **Thực thi tác vụ lớn, nhiều pha**: Tự động dùng `planning-with-files` (ghi `task_plan.md`, `findings.md`, `progress.md` ra đĩa để sống sót qua compact/reset context).
- **Phân tách không gian làm việc**: Tự động dùng `using-git-worktrees` khi làm tính năng cần cô lập branch.
- **Điều phối công việc độc lập**: Tự động dùng `subagent-driven-development` để giao việc cho subagent.

### 2. Kỷ luật Viết Code, Sửa Bug & Testing
- **Kỷ luật cốt lõi (Mọi dòng code)**: Luôn tuân thủ `ponytail` (YAGNI, giải pháp tối giản nhất, ưu tiên Stdlib/Native features trước dependencies ngoài, sửa tận gốc Root Cause).
- **Gặp bug, test tạ, lỗi lạ**: Tự động kích hoạt `systematic-debugging` (điều tra nguyên nhân gốc rễ bằng bằng chứng trước khi sửa, cấm đoán mò).
- **Phát triển tính năng / Fix bug logic**: Tự động áp dụng `test-driven-development` (viết test đỏ -> code pass xanh -> refactor).
- **Viết & Chạy Test thực tế**:
  - Web E2E / UI testing: Tự động áp dụng `playwright-skill` (chạy headless với cờ siêu tiết kiệm RAM `--single-process`).
  - Unit / Integration Test TypeScript & JS: Tự động áp dụng `vitest-skill` (mocking chuẩn, in-source testing).
- **Trước khi tuyên bố hoàn thành / merge**: BẮT BUỘC tự chạy `verification-before-completion` (chạy build, test, linter thực tế để có bằng chứng pass 100%).

### 3. Thiết kế & Lập trình Giao diện (UI/UX)
- **Code UI từ ảnh chụp màn hình / Mockup**:
  - Flutter/Dart: Tự động dùng `screenshot-to-flutter` kết hợp `flutter-architect` (bóc tách tokens màu/font trước, chia sub-widgets, bọc chống RenderFlex overflow, gọi tool tạo ảnh asset).
  - Animation Flutter chống cứng đờ: Bắt buộc dùng `flutter_animate`, cấm dùng Curves.linear/easeInOut thô cứng; bắt buộc dùng `Curves.easeOutCubic`, `Curves.easeOutBack` (độ nảy tự nhiên) và hiệu ứng so le (staggered delay).
  - Phác thảo nhanh cấu trúc: Tự động dùng `wireframe-handover` để vẽ khung ASCII layout xác nhận trước trong terminal.
- **Nâng cấp thẩm mỹ & Tránh lỗi giao diện Web**:
  - Triệt tiêu "AI UI Slop": Tự động kích hoạt `frontend-design` (định hình moodboard, typography tương phản cao, micro-interactions).
  - Chuẩn mực kỹ thuật UI & Accessibility: Tự động kết hợp `ui-ux-pro-max` (tra cứu 192 bảng màu, chuẩn WCAG a11y, layout responsive).
  - Tối ưu SEO 100/100 & Headless Clean: Tự động kích hoạt `claude-seo` (cô lập metadata riêng, schema JSON-LD tàng hình, đảm bảo đúng 1 thẻ H1, alt ảnh và Canonical).

### 4. Kiểm tra Chất lượng, Review & Hoàn tất
- **Kiểm tra an toàn chuyên sâu (Smart Trigger)**:
  - Khi hoàn thành tính năng lớn, trước khi merge nhánh, hoặc khi audit: Tự động chạy `ocr review` (skill `alibaba-code-review`) để quét NPE, Thread Safety, SQLi, XSS.
- **Tiếp nhận phản biện từ reviewer / user**: Tự động áp dụng `receiving-code-review` (nghiêm cấm nịnh bợ "Great point", phải đối chiếu codebase thực tế rồi mới sửa).
- **Yêu cầu review độc lập**: Tự động dùng `requesting-code-review` để tạo diff phân cấp Critical/Important/Minor.
- **Hoàn tất nhánh phát triển**: Tự động dùng `finishing-a-development-branch` để dọn dẹp worktree và merge an toàn.

### 5. Kiến trúc Hạ tầng & An toàn Hệ thống
- **Backend Redis**: Tự động áp dụng `redis-mastery` (Pipeline, TTL, Hash, chống tràn cache).
- **Thiết kế API**: Tự động áp dụng `api-engineering` (Idempotency-Key, Circuit Breaker, Rate Limiting).
- **Cơ sở dữ liệu**: Tự động áp dụng `postgres-concurrency-locks` (FOR UPDATE SKIP LOCKED, kiểm soát transaction).
- **Realtime WebSocket**: Tự động áp dụng `socketio-room-resilience` (Reconnection, Heartbeat, Room cleanup).
- **Thao tác Terminal / OS**: Luôn tuân thủ `bash-safety` (tuyệt đối không xóa mù quáng, xác thực đường dẫn và PID trước khi kill).

---

# BẮT BUỘC BÁO CÁO KHI HOÀN THÀNH TÁC VỤ (PROMPT-ALIGNED)
Khi kết thúc tác vụ, AI PHẢI LUÔN BÁO CÁO THEO 5 MỤC:
1. 📋 **Yêu cầu ban đầu**: Gạch đầu dòng trích xuất từ prompt user.
2. ✅ **Những gì đã thực hiện**: Từng mục đã làm kèm file/hàm cụ thể (`path/to/file:line`).
3. 🔗 **Phạm vi ảnh hưởng**: File/component liên quan bị ảnh hưởng (nếu có).
4. 🧪 **Kết quả kiểm tra**: Output verify thực tế (linter, tests, analyze, ocr).
5. 💡 **Lưu ý từ Advisor**: Đóng góp ngắn gọn (nếu có).

---

# QUY TẮC KỸ THUẬT CỐT LÕI (LEAN & ANTI-BLOAT):
1. **Git Fast-Track**: Khi user bảo "commit", "push", "lưu git": Làm ngay `git status -s` -> `git add . && git commit -m "..."` -> `git push` trong 15s. Không tự vẽ thêm quy trình rườm rà.
2. **AST-Grep & Ripwire (Bản đồ Codebase & Blast Radius)**:
   - Dùng MCP tool `ripwire` để định vị cấu trúc code nhanh, bóc tách AST symbol signatures (giảm 75% token context), và tính toán phạm vi ảnh hưởng (blast radius) trước khi refactor.
   - Dùng `ast-grep run -p '...'` cho việc tìm và thay thế pattern cú pháp cụ thể. Chỉ dùng grep/find thuần cho text/config/docs.
3. **OpenViking (On-Demand Retrieval)**: Tra cứu tri thức, kinh nghiệm cũ qua MCP tool `openviking` (`find`, `search`, `read`) trực tiếp trong lượt chat để bảo toàn Prefix Cache Hit.
4. **Turbopack Bắt Buộc**: Mọi lệnh dev Next.js PHẢI có `--turbo` (ví dụ: `next dev --turbo -p 3001` hoặc `pnpm dev`). Tuyệt đối không chạy Webpack ngốn RAM. Chạy xong test phải tắt server ngay.
5. **Tool Schema Chuẩn**:
   - `grep`: dùng `pattern` (không dùng query).
   - `find`: dùng `query` (không dùng pattern).
   - `eval`: phải có đủ `language` và `code`, ưu tiên chạy bằng terminal/bash.
