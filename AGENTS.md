# GLOBAL AGENT RULES & ENGINEERING STANDARDS

## 1. MANDATORY COMPLETION DELIVERY REPORT (PROMPT-ALIGNED)
Whenever concluding or completing ANY task, answering a request, or reporting back to the user, you MUST ALWAYS format your response following this exact structure:

### 📋 1. Yêu cầu ban đầu (User Goals):
- [Trích xuất chính xác từng gạch đầu dòng mục tiêu từ prompt của người dùng]

### ✅ 2. Những gì đã thực hiện (Execution Checklist):
- **[Mục 1 từ prompt]**: Giải thích ngắn gọn cách làm + file/hàm cụ thể đã sửa (`path/to/file:line`).
- **[Mục 2 từ prompt]**: Giải thích ngắn gọn cách làm + file/hàm cụ thể đã sửa.

### 🔗 3. Những gì liên quan & Phạm vi ảnh hưởng (Side-effects & Related Changes):
- Các file hoặc component phụ bắt buộc phải sửa ké theo để không bị gãy code (ví dụ: route, model, state, config).
- Cảnh báo nếu thay đổi này có ảnh hưởng ngầm tới các phần khác trong project.

### 🧪 4. Kết quả kiểm tra (Verification Evidence):
- Lệnh verify đã chạy (`flutter analyze`, `ast-grep`, tests) kèm output chứng minh 0 errors / pass.

### 💡 5. Lưu ý từ Advisor (nếu có):
- Lưu ý kỹ thuật ngắn gọn từ Advisor (nếu có).

> **BẮT BUỘC TUÂN THỦ**: Không được bỏ qua form này khi kết thúc lượt trả lời. Đây là quy chuẩn cao nhất của hệ thống.

---

## 2. Git Fast-Track (Tối ưu hóa thao tác Git & Push)
Khi người dùng yêu cầu "commit", "push", "commit push", "đẩy code", "lưu git":
- **TUYỆT ĐỐI KHÔNG ĐƯỢC** kích hoạt quy trình cồng kềnh như `finishing-a-development-branch`, không tạo plan todo phức tạp, không spawn reviewer subagent làm tốn thời gian.
- **Thực hiện ngay lập tức**:
  1. `git status -s` để xem file thay đổi.
  2. `git add . && git commit -m "..."`
  3. `git push`
  4. Trả lời báo cáo nhanh gọn trong 15-30 giây.

---

## 3. Mandatory AST-Grep for Code Search & Inspection
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

## 9. Local Web Server Anti-Bloat Protocol
- **NO Arbitrary Dev Servers & NO `--webpack`**:
  - The host system has limited memory. NEVER run `next dev --webpack` or start ad-hoc dev servers on custom ports (e.g. 3104) without user request.
  - If a Next.js test requires a running frontend, use the existing running instance on `http://localhost:3101` (`pnpm start:3101`).
  - If a dev server must be started, use ONLY `pnpm dev:3101` (Turbopack) and terminate it immediately after verification finishes.
