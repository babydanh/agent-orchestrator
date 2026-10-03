---
name: cloud-handoff
description: Use when the user requests to continue the current work on GitHub / Cloud Actions ('lên github làm tiếp', 'chuyển lên github', 'handoff to cloud', 'bàn giao lên cloud')
---

# Cloud Handoff Skill (2-Way Session & Todo Synchronization)

Bàn giao phiên làm việc đang dở dang từ máy local lên GitHub Actions Cloud Runner (`babydanh/agent-orchestrator`) để tiếp tục chạy tự động 24/7, **bảo toàn 100% Session & Danh sách TODO/Checklist**.

## Nguyên lý cốt lõi:
1. **Bảo tồn Code State**: Commit và push mọi thay đổi dở dang lên remote branch của dự án.
2. **Bảo tồn Session & TODO State**: Đẩy bản ghi session `.jsonl` mới nhất lên branch `omp-sync/sessions` để Cloud Agent nạp tiếp tục.
3. **Kích hoạt Cloud Runner**: Gọi tool MCP GitHub tạo Issue chứa cả `Branch dở dang` và `Session-ID`.
4. **Tự động Dọn Dẹp (Auto-Clean)**: Khi Pull Request được Merge, hệ thống tự động xóa branch dở dang và dọn sạch session trên cloud.

---

## Quy trình thực thi tuần tự (Tự động 100%):

### Bước 1: Xác định Repo hiện tại và Branch
Kiểm tra remote URL và trạng thái git:
```bash
git status -s
git remote get-url origin
```
Tạo tên branch handoff rõ ràng:
- Format: `omp/handoff-<timestamp>` hoặc `omp/<tên-tính-năng-đang-làm>`
- Chuyển sang branch mới:
  ```bash
  git checkout -b omp/handoff-$(date +%Y%m%d%H%M%S)
  ```

### Bước 2: Commit và Push code dở dang lên GitHub
```bash
git add .
git commit -m "chore(omp): checkpoint before cloud handoff"
git push -u origin HEAD
```

### Bước 3: Đồng bộ Session JSONL lên branch `omp-sync/sessions`
Tìm file session `.jsonl` gần nhất trong `~/.omp/agent/sessions/` tương ứng với thư mục hiện tại:
1. Xác định Session ID từ file `.jsonl` mới nhất.
2. Sao chép và push file session vào branch `omp-sync/sessions` trên `babydanh/agent-orchestrator`:
```bash
# Script hỗ trợ: powershell C:\Users\GIGABYTE\.omp\scripts\push-session.ps1 -SessionId <SESSION_ID>
```

### Bước 4: Gọi MCP GitHub tạo Issue trên Orchestrator
Sử dụng công cụ MCP GitHub `create_issue`:
- `owner`: `babydanh`
- `repo`: `agent-orchestrator`
- `title`: `[Handoff] <Tên nhiệm vụ đang dở>`
- `body`:
```markdown
## 🚀 BÀN GIAO TÁC VỤ LÊN CLOUD (AGENT HANDOFF)

### 📌 Thông tin ngữ cảnh:
- **Repo mục tiêu**: `<tên-repo-mục-tiêu>`
- **Branch dở dang**: `<tên-branch-vừa-push>`
- **Session-ID**: `<SESSION_ID>`
- **Thời điểm bàn giao**: `<timestamp>`

---

### 📋 Mục tiêu nhiệm vụ:
<Mô tả ngắn gọn mục tiêu cuối cùng>

---

### ✅ Các việc ĐÃ LÀM XONG (Done):
- [x] ...

---

### ⏳ Các việc CẦN LÀM TIẾP (Pending Checklist / TODO):
- [ ] ...

---

### 🧪 Yêu cầu kiểm chứng & bàn giao:
1. Đọc code trên branch `<tên-branch-vừa-push>`.
2. Khôi phục session `<SESSION_ID>` để tiếp nối chính xác mạch TODO.
3. Chạy test / build tương ứng đảm bảo không gãy code.
4. Mở Pull Request vào branch chính (`main`).
```

### Bước 5: Báo cáo lại cho Người dùng
Sau khi tạo Issue thành công, in ra link Issue trên GitHub và thông báo:
> "🎉 **Đã bàn giao phiên làm việc & toàn bộ TODO lên GitHub Actions thành công!**  
> 🔗 **Issue theo dõi**: `https://github.com/babydanh/agent-orchestrator/issues/<number>`  
>  
> Toàn bộ code dở dang, lịch sử chat và checklist TODO đã được chuyển lên mây. Máy ảo GitHub Actions đang khởi động để tiếp tục làm tiếp. Bạn có thể yên tâm tắt máy tính!"
