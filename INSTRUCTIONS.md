# GLOBAL AGENT RULES & ENGINEERING STANDARDS

## 1. Mandatory AST-Grep for Code Search & Inspection
Whenever inspecting, searching, or refactoring source code in supported languages (TypeScript, JavaScript, Python, Dart, Rust, Go, Java, C/C++):
- The agent **MUST ALWAYS prioritize `ast-grep` via bash/terminal commands (`ast-grep run -p '...'`)** over naive plain-text regex (`grep`) or semantic search (`find`).
- **Why**: Drastically reduces token noise, whitespace drift, and captures multi-line syntax, decorators, widget trees, and function signatures with 100% precision.
- **Examples**:
  ```bash
  ast-grep run -p 'class $NAME extends $BASE { $$$ }' --lang dart
  ast-grep run -p 'void $FN($$$ARGS) { $$$ }' --lang dart
  ast-grep run -p 'Widget build(BuildContext context) { $$$ }' --lang dart
  ```
- **When to use plain grep / find**: ONLY for non-code files (`.env`, `.yaml`, `.json`, `.md`, logs) or literal error message strings.

---

## 2. Smart Feedback Loop: Advisor vs. Worker (No Infinite Loops)
- **Selective Auto-Fix (P0/P1 Blockers Only)**:
  - If the Advisor flags a **CRITICAL BUG, LOGIC FLAW, RUNTIME CRASH, or MISSING REQUIREMENT**: The Lead agent **MUST** automatically dispatch a quick follow-up to the worker to fix it before concluding.
  - If the Advisor only provides **STYLE / NITPICKS / OPTIONAL SUGGESTIONS**: Do **NOT** loop or re-dispatch (avoids wasting tokens and infinite debates). Instead, include the suggestion in the final user report.
- **Mandatory User Report (Prompt-Aligned Delivery)**:
  - Whenever concluding or completing a task, the Lead agent **MUST ALWAYS report back by mapping directly to the user's initial prompt/request**:
    1. **📋 Yêu cầu ban đầu (User Goals)**: Trích xuất ngắn gọn các mục tiêu chính từ prompt của user.
    2. **✅ Những gì đã thực hiện (Execution Checklist)**: Điểm danh từng ý trong prompt đã giải quyết xong ở file/hàm cụ thể nào.
    3. **🔗 Những gì liên quan & Phạm vi ảnh hưởng (Side-effects & Related Changes)**:
       - Các file hoặc component phụ bắt buộc phải sửa ké theo để không bị gãy code (ví dụ: đổi route, cập nhật model import, chỉnh sửa state/DI).
       - Cảnh báo nếu thay đổi này có ảnh hưởng ngầm tới các màn hình khác trong project.
    4. **🧪 Kết quả kiểm tra (Verification)**: Kết quả chạy `ast-grep`, linter hoặc test thực tế.
    5. **💡 Gợi ý thêm từ Advisor (nếu có)**: Lưu ý ngắn gọn của Advisor (nếu có).

---

## 3. Superpowers Engineering Discipline & Clean Code
- **Non-Destructive Editing**: NEVER delete existing comments, docstrings, or unrelated logic. Keep edits surgical and minimal.
- **Evidence-First**: Always verify file paths, exported signatures, and imports before calling them. Never hallucinate functions or imports.
- **Clean Architecture & Early Returns**: Guard clauses early, max 2 levels of nested `if/else`, single-responsibility functions (< 40 lines).
- **Task Planning & Verification**: Before complex changes, establish discovery -> implementation -> verification steps. Verify with linter/tests (`flutter analyze`, `npm test`, etc.) before finishing.

---

## 4. Flutter & Dart Idioms
- **Aggressive `const`**: Prefix immutable widgets with `const`.
- **Pure `build()`**: Never perform computation, instantiate controllers, or make HTTP/DB calls inside `build()`.
- **Controller Lifecycle**: Always properly dispose controllers and stream subscriptions in `dispose()`.
- **Null Safety**: Clean use of `?.` and `??`. Never use bang (`!`) unless non-nullness is mathematically guaranteed.
