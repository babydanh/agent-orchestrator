---
name: deep-research
description: Deep research with hyperresearch. Use when the user asks for deep research, comprehensive literature review, academic synthesis, or multi-source verified analysis across papers, trials, and web documents.
---

# Deep Research (hyperresearch)

Sử dụng framework **hyperresearch** để thực hiện nghiên cứu chuyên sâu, đối chiếu đa nguồn và trích xuất tài liệu vào Knowledge Vault.

## 1. Khi nào kích hoạt?
- Khi người dùng yêu cầu: *"Nghiên cứu sâu về..."*, *"Khảo sát toàn diện thuật toán/công nghệ..."*, *"Tìm kiếm các bài báo khoa học/chứng cứ về..."*.
- Tuyệt đối không dùng cho các câu hỏi tra cứu code ngắn hay fix bug thông thường (ưu tiên Ripwire/grep/read).

## 2. Công cụ MCP có sẵn:
Khi cần tìm kiếm hoặc đọc tài liệu trong kho tri thức đã lưu:
- `hyperresearch_search_notes`: Tìm kiếm toàn văn các ghi chú và bài báo trong vault.
- `hyperresearch_read_note`: Đọc chi tiết một bài nghiên cứu theo ID.
- `hyperresearch_read_many`: Đọc hàng loạt bài nghiên cứu.
- `hyperresearch_list_notes`: Liệt kê các ghi chú theo tags/thời gian.
- `hyperresearch_backlinks` & `hubs`: Phân tích đồ thị liên kết giữa các tài liệu.

## 3. Chạy Pipeline cào và tổng hợp mới:
Khi cần cào nguồn mới từ Internet:
```bash
python -m hyperresearch select --task "<đề tài>" --budget 2000
```
Mọi tài liệu cào được sẽ tự động lưu vào thư mục `research/notes/` của dự án dưới dạng Markdown + YAML frontmatter.
