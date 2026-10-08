---
name: pixel-perfect-responsive
description: Use when building responsive Web or Flutter UI to ensure adaptive, fluid layout across all screen sizes (mobile 4-7 inch, tablet 8-11 inch, laptop 13-16 inch, desktop ultrawide 24-34 inch). Prevents overflow, cramped text, broken grids, and layout shift.
---

# Pixel-Perfect Responsive UI (Web & Flutter)

Hệ thống quy chuẩn ép AI viết code responsive co giãn mượt mà cho **mọi inch màn hình**: từ điện thoại mini (iPhone SE 4.7"), máy lớn (Pro Max 6.7"), Tablet/iPad (8-11"), Laptop (13-16") đến Màn hình PC/Ultrawide (24-34").

---

## 1. Luật Thép Bất Di Bất Dịch (Zero Overflow & Fluid First)

1. **CẤM Kích Thước Cứng (No Hardcoded Fixed Width/Height)**:
   - Web: CẤM dùng `width: 800px`, `height: 500px` cho layout container. Bắt buộc dùng `max-width`, `min-width`, `%`, `flex`, `grid`, hoặc `clamp()`.
   - Flutter: CẤM gán cứng `width: 380` khi không nằm trong `LayoutBuilder` hoặc `FittedBox`.
2. **Nguyên Tắc Mobile-First**:
   - Viết style cho màn hình nhỏ nhất (320px - 375px) làm chuẩn gốc.
   - Dùng media-query / breakpoints để mở rộng dần lên Tablet và Desktop.
3. **CẤM Tràn Màn Hình (No RenderFlex Overflow & No Horizontal Scroll)**:
   - Mọi danh sách hay form phải co giãn được hoặc bọc trong vùng cuộn an toàn (`SingleChildScrollView`, `overflow-y-auto`, `overflow-x-hidden`).

---

## 2. Chuẩn Web / Next.js / Tailwind CSS (Từng Inch Màn Hình)

### Bảng Breakpoints Chuẩn:
- **Mobile nhỏ (4.7" - 5.5")**: `< 380px` (`xs`)
- **Mobile chuẩn (5.8" - 6.7")**: `380px - 639px` (mặc định base)
- **Tablet / iPad mini (7.9" - 10.5")**: `640px` (`sm:`) & `768px` (`md:`)
- **Laptop (13" - 15.6")**: `1024px` (`lg:`) & `1280px` (`xl:`)
- **Desktop / Màn to (24" - 32"+)**: `1536px` (`2xl:`)

### Kỹ Thuật Bắt Buộc Dùng:

#### A. Fluid Typography & Spacing (Hàm `clamp()`):
Không để font chữ bị bé tí trên màn 4K hoặc quá to tràn viền trên màn 4.7":
```css
/* Font chữ tự động tính toán theo % màn hình nhưng có chặn sàn và trần */
font-size: clamp(0.875rem, 0.75rem + 0.6vw, 1.25rem); /* Body text */
font-size: clamp(1.5rem, 1rem + 2vw, 3rem);            /* Tiêu đề H1 */
padding: clamp(1rem, 3vw, 2.5rem);
```

#### B. CSS Grid Tự Động Tính Cột (`auto-fit` / `auto-fill`):
Không cần viết hàng chục dòng media query, lưới tự nhảy cột theo độ rộng màn hình:
```css
grid-template-columns: repeat(auto-fit, minmax(min(100%, 280px), 1fr));
```

#### C. Container Queries (`@container`):
Thay vì phụ thuộc vào toàn màn hình (viewport), cho component tự responsive theo khung cha chứa nó:
```html
<div class="@container">
  <div class="flex flex-col @md:flex-row @lg:grid @lg:grid-cols-3">
    <!-- Tự đổi layout khi container co giãn -->
  </div>
</div>
```

---

## 3. Chuẩn Flutter / Dart (Mobile, Foldable, Tablet, Desktop)

### A. Quy tắc ScreenUtil / Proportional Scale:
Khi có `flutter_screenutil`, bắt buộc tận dụng:
```dart
// Width, Height, Radius scale theo tỉ lệ màn hình
Container(
  width: 160.w,
  height: 48.h,
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
)
// Font chữ scale chuẩn DPI
Text('Tiêu đề', style: TextStyle(fontSize: 18.sp));
```

### B. Widget Bắt Buộc Cho Responsive Không Bị Vỡ:
1. **Chống RenderFlex Overflow**:
   - Dùng `Flexible` hoặc `Expanded` trong `Row` / `Column`.
   - Bọc text dài bằng `TextOverflow.ellipsis` và `maxLines`.
2. **LayoutBuilder & OrientationBuilder**:
   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       if (constraints.maxWidth < 600) {
         return _buildMobileLayout(); // 1 cột
       } else if (constraints.maxWidth < 1024) {
         return _buildTabletLayout(); // 2 cột
       }
       return _buildDesktopLayout(); // 3 cột kèm sidebar
     },
   )
   ```
3. **Adaptive Widgets**:
   - Dùng `SafeArea` tránh tai thỏ (Notch) và Dynamic Island.
   - Dùng `Wrap` thay vì `Row` khi danh sách tags / buttons có nguy cơ tràn chiều ngang.

---

## 4. Công Cụ Kiểm Chứng Thực Tế (Verification Tools)

### A. Dành cho Web / Next.js:
1. **CSS `clamp()` Playground**: Tự động kiểm tra tính toán font-size/padding trên dev server.
2. **Responsively App MCP Server (`@responsively/mcp`)**:
   - Repo chính thức: `responsively-org/responsively-app` (hỗ trợ native Model Context Protocol).
   - Khi dev web, agent có thể kết nối qua `npx -y @responsively/mcp` để tự động gọi tool:
     - `navigate(url)`: Nạp URL dev server vào tất cả các thiết bị cùng lúc.
     - `screenshot()`: Tự chụp ảnh giao diện trên 30+ màn hình (từ iPhone 4.7" đến Desktop 34") để phát hiện vỡ layout trước khi kết thúc task.

### B. Dành cho Flutter:
1. **`device_preview` package**:
   - Bọc app trong `DevicePreview(builder: (context) => MyApp())` lúc debug.
   - Cho phép đổi tức thì giữa iPhone SE 4.7", iPhone 16 Pro Max 6.7", iPad 11" và màn hình gập (Foldable) trên cùng 1 lần chạy.

---

## 5. Checklist Tự Kiểm Tra (Self-Verification):
Trước khi bàn giao code UI, AI phải tự soi lại:
- [ ] Màn hình 360px (Android nhỏ / iPhone SE 4.7") có bị đè chữ hay tràn viền ngang không?
- [ ] Màn hình 768px - 1024px (iPad/Tablet 8-11") layout có bị giãn toang hoác xấu xí không?
- [ ] Màn hình Desktop 1920px container có được khóa `max-w-7xl mx-auto` để không bị bè ngang hết cỡ không?
