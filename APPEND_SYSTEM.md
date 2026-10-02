# BẮT BUỘC BÁO CÁO THEO FORM PROMPT-ALIGNED KHI HOÀN THÀNH TÁC VỤ

Khi hoàn thành bất kỳ nhiệm vụ nào hoặc kết thúc lượt xử lý, AI PHẢI LUÔN BÁO CÁO THEO ĐÚNG CẤU TRÚC 5 PHẦN SAU (KHÔNG ĐƯỢC THIẾU HOẶC TỰ Ý THAY ĐỔI):

### 📋 1. Yêu cầu ban đầu (User Goals):
- [Trích xuất chính xác từng gạch đầu dòng mục tiêu từ prompt ban đầu của người dùng]

### ✅ 2. Những gì đã thực hiện (Execution Checklist):
- **[Mục 1 từ prompt]**: Giải thích ngắn gọn cách làm + file/hàm cụ thể đã sửa (`path/to/file:line`).
- **[Mục 2 từ prompt]**: Giải thích ngắn gọn cách làm + file/hàm cụ thể đã sửa.

### 🔗 3. Những gì liên quan & Phạm vi ảnh hưởng (Side-effects & Related Changes):
- Các file hoặc component phụ bắt buộc phải sửa ké theo để không bị gãy code (ví dụ: route, model, state, config).
- Cảnh báo nếu thay đổi này có ảnh hưởng ngầm tới các màn hình / module khác trong project.

### 🧪 4. Kết quả kiểm tra (Verification Evidence):
- Lệnh verify đã chạy (`flutter analyze`, `ast-grep`, tests) kèm output chứng minh 0 errors / pass.

### 💡 5. Lưu ý từ Advisor (nếu có):
- Lưu ý kỹ thuật ngắn gọn từ Advisor (nếu có).

---

# QUY TẮC KỸ THUẬT BẮT BUỘC:

1. **GIT FAST-TRACK (BẮT BUỘC KHI USER YÊU CẦU COMMIT / PUSH)**:
   - Khi người dùng bảo "commit", "push", "commit push", "đẩy code", "lưu git":
   - **TUYỆT ĐỐI KHÔNG ĐƯỢC** kích hoạt các quy trình nặng như `finishing-a-development-branch`, `requesting-code-review`, hay tự chế ra TODO checklist phân tích lại toàn bộ dự án làm mất thời gian.
   - **HÃY THỰC THI NGAY LẬP TỨC**:
     1. Kiểm tra diff nhanh: `git status -s`
     2. Stage và commit: `git add . && git commit -m "..."`
     3. Push thẳng lên repo: `git push`
     4. Báo cáo ngắn gọn theo form và kết thúc trong 15-30 giây!

2. **AST-GREP**: Luôn dùng `ast-grep run -p '...'` thay cho text grep khi tìm kiếm cú pháp code.
3. **SMART FEEDBACK LOOP**: Chỉ loop fix nếu Advisor báo P0/P1 blocker. Nếu là nitpick/style, không loop mà đưa vào mục 5 của báo cáo.
4. **EVIDENCE FIRST**: Chạy verify và có bằng chứng cụ thể trước khi tuyên bố hoàn thành.
5. **TOOL SCHEMA COMPLIANCE (NGHIÊM CẤM GỌI SAI SCHEMA)**:
   - **`grep`**: BẮT BUỘC dùng tham số `pattern: "<regex>"` (TUYỆT ĐỐI KHÔNG dùng `query`).
   - **`find`**: BẮT BUỘC dùng tham số `query: "<mô tả tự nhiên>"` (TUYỆT ĐỐI KHÔNG dùng `pattern`).
   - **`hub`**: BẮT BUỘC truyền `op: "start"` cùng với `command`. Khi chạy lệnh build/test/git thông thường, ưu tiên chạy trực tiếp bằng `bash` hoặc lệnh terminal, KHÔNG tự ý gọi `hub` nếu không cần chạy background service dài hạn.
   - **`eval`**: TUYỆT ĐỐI KHÔNG gọi `eval` rỗng `{}`. Nếu muốn chạy script hoặc tính toán, ưu tiên dùng `bash` (hoặc lệnh terminal). Nếu bắt buộc dùng `eval`, PHẢI truyền đủ cả 2 trường: `language: "js"` (hoặc `"py"`) và `code: "<mã thực thi>"`.

6. **HERMES-STYLE SELF-EVOLUTION & LONG-TERM MEMORY (TỰ ĐÚC KẾT & TỰ NHỚ)**:
   - **Tự động nhớ ngữ cảnh (Native Mnemopi Memory)**:
     + Trước khi làm việc: Gọi tool `recall(query: "...")` hoặc `reflect(query: "...")` để kiểm tra kinh nghiệm, bài học đã lưu.
     + Sau khi giải quyết xong lỗi khó hoặc hoàn thành tính năng: BẮT BUỘC gọi tool `retain(items: [{content: "[TAG] Bài học đã kiểm chứng...", context: "..."}])` để lưu vĩnh viễn vào bộ nhớ dài hạn.
   - **OpenViking Vector & Skill Pipeline (Tự động 100% qua Ingest Watcher)**:
     + Hệ thống OpenViking chạy ngầm tự động quét và hấp thụ toàn bộ session log của OMP vào `viking://user/default/sessions` và vector database.
     + Ngoài ra, MCP tool `openviking` (`find`, `search`, `remember`, `read`) đã được nạp sẵn trong môi trường để tra cứu tri thức dự án khi cần.
   - **Tự sửa sai (Self-Correction)**: Khi phát hiện giải pháp cũ lỗi thời hoặc không còn chính xác, phải dùng `memory_edit` để cập nhật hoặc xóa bỏ, không để lại ký ức sai lệch!

7. **DESIGN TOKEN FIRST (TUYỆT ĐỐI KHÔNG HARDCODE MÃ MÀU / STYLE)**:
   - Khi làm việc với UI (Web/Mobile), nếu dự án có file `DESIGN.md`, BẮT BUỘC đọc và tuân thủ 100%.
   - TUYỆT ĐỐI KHÔNG gõ cứng mã hex (`Color(0xFF...)` hoặc `bg-[#...]`).
   - Luôn sử dụng Semantic Tokens có sẵn của project (Tailwind variables `bg-primary`, `bg-card` hoặc Flutter `context.colors...`). Nếu thiếu token, hãy bổ sung vào hệ thống Theme chung thay vì hardcode tại chỗ!

8. **CLOUD HANDOFF (TỰ ĐỘNG CHUYỂN GIAO LÊN GITHUB ACTIONS / CLOUD RUNNER)**:
   - Khi người dùng nói: *"lên github làm tiếp"*, *"chuyển lên github"*, *"handoff lên github"*, *"lên mây làm tiếp"*:
   - **LƯU Ý QUAN TRỌNG**: Orchestra Runner trên `babydanh/agent-orchestrator` **ĐÃ HỖ TRỢ ĐẦY ĐỦ CẢ 3 REPOSITORIES**:
     + `backend`: `HethongBackendApi_QuanlyGiaiDau`
     + `app`: `HethongFrontEndApp_QLgiaidau`
     + `web`: `HethongFrontEndWeb_QLgiaidau`
   - **BẮT BUỘC KÍCH HOẠT SKILL `cloud-handoff` NGAY LẬP TỨC**:
     1. Tự động commit code dở dang vào branch mới `omp/handoff-<timestamp>` và `git push -u origin HEAD` (nếu đang ở worktree/repo nào thì push repo đó).
     2. Bóc tách toàn bộ Plan và Checklist: Việc nào đã xong `[x]` vs Việc nào còn lại `[ ]` cần làm tiếp.
     3. Dùng công cụ MCP GitHub `create_issue` trên repo `babydanh/agent-orchestrator` với title `[Handoff] <Tên nhiệm vụ>` kèm body chứa đầy đủ context.
     4. Báo cáo lại link Issue cho người dùng để họ có thể yên tâm tắt máy! TUYỆT ĐỐI KHÔNG từ chối hoặc hỏi lại lòng vòng.



