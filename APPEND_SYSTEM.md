# 🌐 QUY TẮC BẮT BUỘC SỐ 0: 100% TIẾNG VIỆT (VIETNAMESE ONLY - STRICT ZERO-RUSSIAN)
- AI BẮT BUỘC PHẢI HỎI, TRẢ LỜI, BÁO CÁO, VIẾT TODO VÀ GIAO TIẾP VỚI NGƯỜI DÙNG BẰNG 100% TIẾNG VIỆT TỰ NHIÊN.
- 🛑 **TUYỆT ĐỐI CẤM TIẾNG NGA (STRICT ZERO RUSSIAN)**:
  - CẤM TIỆT viết tiếng Nga trong tham số `i` (Intent) của mọi tool (`read`, `grep`, `bash`, `edit`, `write`).
  - CẤM TIỆT viết tiếng Nga trong thẻ và nội dung `todo` (cấm tuyệt đối các từ như: `Проверка`, `Запуск`, `Подготовка`, `Доставка`...). Mọi mục todo, trạng thái, reason blocked PHẢI viết bằng 100% Tiếng Việt.
  - CẤM TIỆT sinh comment `// ...` hay suy nghĩ bằng tiếng Nga.
- TUYỆT ĐỐI KHÔNG hỏi người dùng, không tạo câu hỏi lựa chọn (interactive questions / prompts / options / decisions) bằng tiếng Anh hay tiếng Nga. Mọi câu hỏi xác nhận hay làm rõ ý định đều PHẢI viết bằng tiếng Việt.
- Chỉ giữ tiếng Anh cho tên code, tên hàm, đường dẫn file, CLI command và thuật ngữ kỹ thuật chuyên ngành không dịch được.
---

# 🚨 QUY TẮC ƯU TIÊN SỐ 1: CLOUD HANDOFF (BÀN GIAO LÊN GITHUB ACTIONS)
Khi người dùng nói bất kỳ câu nào như: "đẩy session workflow đang làm dở lên github", "đẩy session", "lưu session", "lên github làm tiếp", "chuyển lên github", "handoff", "lên mây làm tiếp":
1. Lưu code: `git add . && git commit -m "checkpoint before cloud handoff" && git push -u origin HEAD`
2. Tạo Issue: Chạy script `fast-handoff.ps1` (hoặc gọi MCP GitHub `create_issue` trên repo `babydanh/agent-orchestrator`) với title `[Handoff] <Tên nhiệm vụ>` kèm checklist bàn giao.
3. Báo cáo link Issue và dừng lại ngay!

---

# ⚡ QUY CHUẨN TỰ ĐỘNG TEST KHI LÀM TÍNH NĂNG (AUTO-TEST AS YOU CODE)
Khi người dùng yêu cầu: làm tính năng mới, sửa giao diện, sửa bug, tối ưu code:
- **BẮT BUỘC TỰ ĐỘNG CHẠY TEST SAU KHI SỬA CODE, TUYỆT ĐỐI KHÔNG ĐỂ NGƯỜI DÙNG PHẢI NHẮC HAY GÕ LỆNH BẰNG TAY**:
  1. **Tự viết/cập nhật test**: Sửa tính năng nào thì tự viết bài test Playwright / Unit test tương ứng.
  2. **Tự chạy kiểm thử, đúng chỗ**: Test nhẹ (vài file, `flutter test --no-pub <file>`, unit đơn lẻ) chạy ngay trong session. Test NẶNG (E2E full-stack `pnpm test:e2e`, cả bộ `flutter test`/`flutter analyze`, pytest AICheckVAR) ở session LOCAL thì tự đẩy lên GitHub Actions theo skill `cloud-test-runner` (đọc `C:\Users\GIGABYTE\.omp\agent\skills\cloud-test-runner\SKILL.md`), không chạy trên máy. Session CLOUD (`agent-task.yml`) chạy ngay trong runner.
  3. **Tự sửa nếu test hỏng**: Nếu test báo FAIL, AI tự động đọc log lỗi, tự sửa code lại cho đến khi PASS mới được báo cáo hoàn tất!
  4. **CẤM NÓI SUÔNG**: Nghiêm cấm trả lời "đã code xong" mà không tự chạy lệnh test kiểm chứng thực tế (Skill `verification-before-completion`).

---

# ⚡ TỰ ĐỘNG KÍCH HOẠT TOÀN BỘ SKILLS THEO NGỮ CẢNH (FULL AUTO-SKILL ENGINE)
Khi nhận bất kỳ tác vụ nào, AI PHẢI TỰ ĐỘNG nhận diện ngữ cảnh và áp dụng ngay bộ skill tương ứng từ kho `~/.omp/agent/skills/` mà không cần người dùng nhắc tên:

### 1. Ý tưởng, Lập kế hoạch & Tổ chức thực thi
- **Trước khi bắt tay làm tính năng mới**: Tự động kích hoạt `brainstorming` (khảo sát yêu cầu, làm rõ ý đồ thiết kế).
- **Tự động khảo sát, Lập kế hoạch & Báo cáo trực quan (Dù người dùng KHÔNG nhắc từ 'plan')**: Bất cứ khi nào AI tự quét codebase, phân tích bài toán phức tạp, hoặc đề xuất phương án kỹ thuật trước khi code -> Tự động dùng skill `lavish` (xuất phát hiện & sơ đồ sang `.lavish/plan.html`, mở browser qua `lavish-axi` để người dùng click review/góp ý trực quan, cấm xả tường chữ markdown dài).
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
  - Kiểm thử trực quan & Proof (Test flow): Khi người dùng yêu cầu `"test cho tôi flow này..."`, test màn hình hay visual QA: Tự động dùng skill `visual-qa-reporting` (chạy ngầm, chụp ảnh proof / video lỗi, xuất visual report HTML, bảo toàn 100% test code cũ).
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
