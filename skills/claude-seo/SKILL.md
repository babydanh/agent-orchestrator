---
name: claude-seo
description: Use when auditing frontend SEO, optimizing 100-point meta tags, structured schema JSON-LD, or clean headless SEO.
---

# 🎯 CLAUDE-SEO: TIÊU CHUẨN VÀNG TỐI ƯU SEO 100/100 (FRONTEND & HEADLESS)

Kỹ năng tối ưu hóa công cụ tìm kiếm chuẩn Google & AI Search (GEO/AEO). Đảm bảo đạt điểm tối đa trên Google Lighthouse / PageSpeed mà **KHÔNG làm bẩn mã nguồn giao diện (UI Cleanliness)**.

---

## 🚫 NGUYÊN TẮC BẤT DI BẤT DỊCH: GIẤU THẺ SEO ẨN DƯỚI (HEADLESS SEO)
1. **Tuyệt đối KHÔNG viết thẻ SEO rải rác bên trong UI Component**:
   - Không nhét thẻ `<title>`, `<meta>`, hay script lạ vào giữa các file component giao diện (`Button.tsx`, `Hero.tsx`, v.v.).
   - Mọi metadata phải được cô lập ở tầng cấu hình tĩnh (`seo.config.ts`, `metadata.ts`) hoặc thẻ `<head>` của Server Layout.
2. **Schema JSON-LD tàng hình 100%**:
   - Dữ liệu có cấu trúc (Rich Snippets) bắt buộc nằm trong thẻ `<script type="application/ld+json">`.
   - Phải vô hình hoàn toàn với người dùng, không bao giờ render ra text thừa trên màn hình làm vỡ bố cục CSS.

---

## 📊 BAREM CHẤM ĐIỂM 100/100 GOOGLE LIGHTHOUSE & TECHNICAL SEO

### 1. Cấu trúc On-Page & Headings (Trọng số 30%)
- **H1 Unique**: Đúng 1 thẻ `<h1>` duy nhất cho toàn bộ trang (chứa từ khóa chính ở 3 từ đầu tiên).
- **Hệ thống phân cấp chặt chẽ**: `h1` ➔ `h2` ➔ `h3`. Cấm nhảy cóc từ `h1` sang `h3`.
- **Title Tag**: Từ **50 - 60 ký tự**, định dạng: `Từ khóa chính - Từ khóa phụ | Tên thương hiệu`.
- **Meta Description**: Từ **145 - 160 ký tự**, mô tả súc tích, kích thích click (CTR), có Call-To-Action (CTA).
- **Canonical Link**: Luôn có `<link rel="canonical" href="https://domain.com/path" />` để tránh bị phạt Duplicate Content.

### 2. Hình ảnh & Core Web Vitals (Trọng số 35%)
- **Tất cả ảnh có Alt ẩn**: Mọi thẻ `<img />` hoặc `<Image />` bắt buộc có thuộc tính `alt="Mô tả chi tiết ngữ cảnh"` (không để alt rỗng hoặc alt chung chung như `image.png`).
- **Chống giật khung hình (CLS = 0)**: Mọi ảnh phải khai báo rõ `width` và `height`, hoặc dùng wrapper có tỉ lệ cố định `aspect-ratio`.
- **Định dạng ảnh thế hệ mới**: Ưu tiên `.webp` hoặc `.avif`. Dung lượng ảnh dưới 100KB.

### 3. Dữ liệu có cấu trúc (Schema JSON-LD) (Trọng số 20%)
Tự động nhúng ít nhất 2 loại schema theo ngữ cảnh:
- **Trang chủ / Công ty**: `Organization` (Name, Logo, Social links, Contact).
- **Bài viết / Blog**: `Article` / `BlogPosting` (Headline, DatePublished, Author, Image).
- **Trang sản phẩm / Dịch vụ**: `Product` hoặc `Service` kèm AggregateRating.
- **Trang câu hỏi**: `FAQPage` (Tăng cơ hội xuất hiện trực tiếp trên kết quả tìm kiếm).
- **Điều hướng**: `BreadcrumbList` (Cho bot Google hiểu cấu trúc cây thư mục).

### 4. Open Graph & Social Sharing (Trọng số 15%)
Đầy đủ các thẻ xem trước khi chia sẻ mạng xã hội (Facebook, Zalo, Twitter):
- `og:title`, `og:description`, `og:type`, `og:url`
- `og:image`: Kích thước chuẩn **1200x630 px**
- `twitter:card`: `summary_large_image`

---

## 🛠️ CODE TEMPLATE MẪU (CHUẨN NEXT.JS / REACT / HTML)

### Mẫu 1: Cô lập Metadata riêng biệt (`src/config/seo.ts`)
```typescript
export interface SeoParams {
  title: string;
  description: string;
  path: string;
  ogImage?: string;
}

export function buildPageMetadata({ title, description, path, ogImage }: SeoParams) {
  const baseUrl = "https://yourdomain.com";
  const url = `${baseUrl}${path}`;
  const image = ogImage || `${baseUrl}/og-default.webp`;

  return {
    title: `${title} | YourBrand`,
    description,
    alternates: { canonical: url },
    openGraph: {
      title,
      description,
      url,
      siteName: "YourBrand",
      images: [{ url: image, width: 1200, height: 630 }],
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [image],
    },
    robots: {
      index: true,
      follow: true,
    },
  };
}
```

### Mẫu 2: Component Schema JSON-LD Tàng hình (`components/seo/JsonLd.tsx`)
```tsx
import React from 'react';

export function JsonLd({ data }: { data: Record<string, any> }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

---

## 🔍 QUY TRÌNH CHECKLIST KHI REVIEW HOẶC XUẤT CODE FRONTEND
Mỗi khi lập trình hoặc review giao diện web, AI phải đối soát 5 cổng kiểm tra:
1. [ ] Đã có đúng 1 thẻ `<h1>` duy nhất chưa?
2. [ ] Tất cả các ảnh đã có `alt` và kích thước `width/height` chưa?
3. [ ] Metadata đã được tách ra file cấu hình riêng, không làm bẩn JSX chưa?
4. [ ] Thẻ Canonical URL đã trỏ chính xác chưa?
5. [ ] Schema JSON-LD đã được chèn vào tầng ngầm chưa?
