---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch (Auto One-Shot Clean Cutover)

## Core Directive: ZERO PAUSE & DIRECT ONE-SHOT INTEGRATION
Tuyệt đối KHÔNG dừng lại hỏi lựa chọn (no paused integration), KHÔNG tạo detached HEAD, KHÔNG tạo Pull Request rườm rà.
Khi code và test đã xong, AI **BẮT BUỘC TỰ ĐỘNG THỰC THI GỘP TRỰC TIẾP VÀO NHÁNH CHÍNH (MAIN)** trong 1 lượt duy nhất!

---

## The 3-Step Clean Cutover Flow

### Bước 1: Verify Tests & Clean Status
Chạy verify kiểm tra linter/test tương ứng (`pnpm test:e2e`, `pnpm test`, hoặc `flutter test`).
Nếu test PASS 100%, tiếp tục Bước 2 ngay lập tức, không dừng lại báo cáo giữa chừng.

### Bước 2: Tự Động Merge Thẳng Vào Nhánh Chính (Main / Active Branch)
1. Xác định nhánh chính: `main`.
2. Nếu đang ở worktree tạm:
   ```bash
   MAIN_ROOT=$(git rev-parse --show-toplevel)
   cd "$MAIN_ROOT"
   git checkout main
   git pull origin main --rebase
   git merge <feature-branch> --ff-only || git merge <feature-branch> -m "chore: auto-merge feature into main"
   ```
3. Nếu đang ở nhánh `main`:
   ```bash
   git add .
   git commit -m "feat: complete feature with full verified tests"
   git push origin main
   ```

### Bước 3: Dọn Sạch Rác Đĩa Ngay Lập Tức
1. Xóa nhánh tạm vừa merge: `git branch -D <feature-branch> 2>/dev/null || true`
2. Xóa sạch mọi worktree tạm:
   ```bash
   git worktree prune
   ```
3. Bàn giao kết quả cô đọng đúng 3 dòng:
   - ✅ **Đã hoàn thành**: [Tên tính năng] đã merge và push thẳng lên `origin/main` 100%!
   - 📍 **Vị trí sửa cụ thể**: File và commit SHA.
   - 🧪 **Kiểm tra thực tế**: Lệnh test pass.
