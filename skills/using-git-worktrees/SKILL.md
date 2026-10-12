---
name: using-git-worktrees
description: DISABLED - Enforce single-branch workflow directly on active branch or main
---

# Single-Branch Direct Workflow (No Isolated Worktrees)

## Core Directive: ZERO ISOLATED WORKTREES
Người dùng yêu cầu kỷ luật MỘT NHÁNH DUY NHẤT. Tuyệt đối KHÔNG tạo worktree mới, KHÔNG tạo thư mục cách ly tại `.worktrees/` hay `D:/tmp/`.

---

## The Rule
1. Mọi thao tác sửa code, refactor, thêm tính năng PHẢI thực hiện trực tiếp trên thư mục làm việc hiện tại (`main` hoặc nhánh đang checkout).
2. Khi hoàn thành: commit và push thẳng vào nhánh hiện tại.
3. Không cách ly, không detached HEAD, không gây phân mảnh hay kẹt merge.
