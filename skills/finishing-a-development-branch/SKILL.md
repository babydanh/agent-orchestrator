---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to integrate multi-session concurrent work cleanly into main
---

# Finishing a Development Branch (Concurrent Multi-Session Auto-Rebase & Merge)

## BẢN CHẤT VẤN ĐỀ MULTI-SESSION:
Khi bạn mở 2 hay nhiều session cùng lúc (Session A làm tính năng 1, Session B làm tính năng 2):
- Session A vừa commit lên `main`.
- Session B chuẩn bị merge thì thấy `main` đã thay đổi (+155 dòng của Session A).
- **CON AI CŨ**: Bị hoảng loạn, phanh dừng lại (Integration paused) và để detached HEAD bắt người dùng chọn.
- **QUY CHUẨN MỚI THÔNG MINH (Auto-Rebase & Zero-Pause)**: AI **TỰ ĐỘNG CHỦ ĐỘNG PULL MỚI NHẤT VỀ, REBASE NỐI TIẾP, VÀ MERGE THẲNG VÀO MAIN**!

---

## The 4-Step Auto-Rebase & Fast Merge Flow

### Bước 1: Verify Tests
Chạy kiểm tra linter/test tương ứng. Nếu PASS, đi tiếp ngay Bước 2 (không dừng lại hỏi).

### Bước 2: Tự Động Kéo Mới Nhất Về Và Rebase Nối Tiếp (Smart Pull & Rebase)
Trước khi merge vào `main`:
```bash
MAIN_ROOT=$(git rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 1. Kéo toàn bộ thay đổi mới nhất mà các Session khác vừa đẩy lên main
git fetch origin main

# 2. Tự động rebase nhánh của mình lên đầu main mới nhất (Stacking changes)
git rebase origin/main || {
  echo ">>> Tự động giải quyết conflict hoặc dùng git merge an toàn..."
  git rebase --abort 2>/dev/null || true
  git merge origin/main --no-edit
}
```

### Bước 3: Gộp Thẳng Vào Main & Push Ngay Lập Tức
```bash
git checkout main
git pull origin main --rebase
git merge <feature-branch> --no-edit
git push origin main
```
- **TUYỆT ĐỐI KHÔNG TẠO DETACHED HEAD**.
- **TUYỆT ĐỐI KHÔNG DỪNG LẠI CHỜ LỰA CHỌN (ZERO PAUSE)**.

### Bước 4: Dọn Sạch Nhánh Tạm & Worktree Trong 1 Giây
```bash
git branch -D <feature-branch> 2>/dev/null || true
git worktree prune 2>/dev/null || true
```
Bàn giao kết quả đúng 3 dòng:
- ✅ **Đã hoàn thành**: Đã tự động rebase và merge thẳng vào `origin/main` 100%!
- 📍 **Commit**: Commit SHA mới nhất trên `main`.
- 🧪 **Kiểm tra**: Tất cả test pass.
