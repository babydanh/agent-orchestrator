---
name: cloud-handoff
description: Use when the user requests to continue the current work on GitHub / Cloud Actions ('lên github làm tiếp', 'chuyển lên github', 'handoff to cloud', 'bàn giao lên cloud')
---

# Cloud Handoff Skill

Bàn giao phiên làm việc đang dở dang từ máy local lên GitHub Actions Cloud Runner (`babydanh/agent-orchestrator`) để tiếp tục chạy tự động 24/7.

## Nguyên lý cốt lõi:
1. **Lưu giữ toàn bộ trạng thái code (Code State)**: Commit và push mọi thay đổi dở dang lên remote branch.
2. **Bảo tồn ngữ cảnh kế hoạch (Context Preservation)**: Tổng hợp chính xác những việc đã hoàn thành (`[x]`) và những việc còn lại (`[ ]`).
3. **Kích hoạt Cloud Runner**: Gọi tool MCP GitHub để mở Issue trên `babydanh/agent-orchestrator`.

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
Nếu có thay đổi chưa commit:
```bash
git add .
git commit -m "chore(omp): checkpoint before cloud handoff"
git push -u origin HEAD
```
*Lưu ý: Nếu gặp lỗi chưa có remote upstream, dùng cờ `-u origin <branch>` để đẩy lên.*

### Bước 3: Tổng hợp Bản tin Bàn giao (Handover Brief)
Trích xuất từ kế hoạch hiện tại (từ `08-tasks.md`, `PlanArtifacts.md`, hoặc TODO trong chat):
1. **Mục tiêu**: Việc gì đang làm?
2. **Repo liên quan**: Backend (`HethongBackendApi_QuanlyGiaiDau`) hay App (`HethongFrontEndApp_QLgiaidau`) hay Web (`HethongFrontEndWeb_QLgiaidau`)?
3. **Branch dở dang**: Tên branch vừa push ở Bước 2.
4. **Việc đã xong (Done)**:
   - [x] Task 1...
   - [x] Task 2...
5. **Việc cần làm tiếp (Pending)**:
   - [ ] Task 3: Chi tiết cần code ở file nào...
   - [ ] Task 4: Chạy test...

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
- **Thời điểm bàn giao**: `<timestamp>`

---

### 📋 Mục tiêu nhiệm vụ:
<Mô tả ngắn gọn mục tiêu cuối cùng>

---

### ✅ Các việc ĐÃ LÀM XONG (Done):
- [x] ...

---

### ⏳ Các việc CẦN LÀM TIẾP (Pending Checklist):
- [ ] ...

---

### 🧪 Yêu cầu kiểm chứng & bàn giao:
1. Đọc code trên branch `<tên-branch-vừa-push>`.
2. Tiếp tục hoàn thiện các mục trong danh sách **Pending Checklist** ở trên.
3. Chạy toàn bộ test suites đảm bảo không gãy code.
4. Mở Pull Request vào branch chính (`main`).
```

### Bước 5: Báo cáo lại cho Người dùng
Sau khi tạo Issue thành công, in ra link Issue trên GitHub và thông báo:
> "🎉 **Đã bàn giao phiên làm việc lên GitHub Actions thành công!**  
> 🔗 **Issue theo dõi**: `https://github.com/babydanh/agent-orchestrator/issues/<number>`  
>  
> Toàn bộ code dở dang và kế hoạch todo đã được chuyển lên mây. Máy ảo GitHub Actions đang khởi động để tiếp tục làm tiếp. Bạn có thể yên tâm tắt máy tính!"
