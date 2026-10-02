---
name: prompt-architect
description: Automatic prompt structuring, intent analysis, and deterministic TODO checklist decomposition. Use for every coding, refactoring, or UI task to plan steps cleanly before editing files.
---

# Prompt Architect & Structured Task Decomposition

Whenever the user provides a task, feature request, bug fix, or refactoring prompt:

## Phase 0: Intent & Requirement Synthesis
1. Identify the core user intent (feature, bugfix, UI polish, logic optimization).
2. Clarify implicit constraints (framework conventions, responsive layout, null-safety, state management).
3. Identify relevant target files before touching anything.

## Phase 1: Mandatory Deterministic TODO Breakdown
Always construct and display a structured markdown task list before executing any code changes:

```markdown
### 📋 Execution Plan (TODO)
- [ ] **I. Discovery & Inspection**
  - [ ] Audit target files and dependencies
  - [ ] Identify root cause / exact widget tree or data flow
- [ ] **II. Implementation**
  - [ ] Apply code changes in core components
  - [ ] Ensure consistent styling and contract compliance
- [ ] **III. Verification & Quality Gate**
  - [ ] Run static analysis (e.g., `flutter analyze` or lint checks)
  - [ ] Verify runtime behavior or test cases
```

## Phase 2: Execution Protocol
- Update checklist items to `- [x]` immediately as each phase is completed.
- Never edit multiple complex files simultaneously without inspecting them first.
- If unexpected errors arise, add a sub-item to the TODO list before proceeding.

## Phase 3: Mandatory Completion Delivery Report (Prompt-Aligned)
Before concluding any response, the Lead agent MUST output the final report in this exact structure:
### 📋 1. Yêu cầu ban đầu (User Goals):
- [Trích xuất chính xác từng gạch đầu dòng mục tiêu từ prompt của người dùng]

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

