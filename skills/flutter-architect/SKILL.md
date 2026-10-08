---
name: flutter-architect
description: Use when architecting, building, debugging layout overflows, or testing Flutter and Dart mobile apps.
license: MIT
metadata:
  author: Flutter Best Practices & ECC Standards
  version: "2.0.0"
---

# Flutter Architect: Clean Layers, Responsive Layouts, Debugging & Testing

Unified production guidelines for cross-platform Flutter and Dart application engineering.

---

## 1. Clean 3-Layer Architecture & State Management

Maintain strict separation of concerns:
```
[ Presentation (UI) ] ──> [ Logic (Bloc / Riverpod / Cubit) ] ──> [ Data (Repositories & DataSources) ]
```
- **Presentation**: Pure widgets. **NEVER** instantiate controllers, make HTTP/DB calls, or compute business logic inside `build()`.
- **Pure `build()` & Aggressive `const`**: Prefix immutable widgets with `const` to allow Flutter to skip unnecessary element rebuilds.
- **Controller Lifecycle**: Always properly dispose controllers (`TextEditingController`, `AnimationController`, `ScrollController`) and cancel stream subscriptions in `dispose()`.

---

## 2. Responsive UI & Layout Overflow Elimination

### Fixing Common Layout Errors:
1. **RenderFlex Overflowed (Yellow/Black striped tape)**:
   - Inside `Row` or `Column`: Wrap variable-width/height children with `Expanded` or `Flexible`.
   - Wrap text widgets with `overflow: TextOverflow.ellipsis` and `maxLines: ...`.
   - For scrollable forms, wrap Column with `SingleChildScrollView`.
2. **Vertical Viewport Was Given Unbounded Height**:
   - Occurs when putting a `ListView` inside a `Column` or `SingleChildScrollView`.
   - **Fix**: Set `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()`, or wrap the `ListView` in an `Expanded`.
3. **Adaptive Form Factors (Mobile vs Tablet vs Desktop)**:
   - Use `LayoutBuilder` or `MediaQuery.sizeOf(context).width` with breakpoint helpers:
     - Mobile: `< 600px`
     - Tablet: `600px - 1024px`
     - Desktop: `> 1024px`

---

## 3. High-Performance JSON & Data Mapping

- Keep data models immutable (`final` properties, `copyWith`, `==` and `hashCode`).
- Prefer `dart:convert` `jsonDecode` with typed factory constructors (`fromJson` / `toJson`) or code generation (`freezed` / `json_serializable`).
- Guard against unexpected nulls from API with defensive defaults:
  ```dart
  name: json['name'] as String? ?? 'N/A',
  score: (json['score'] as num?)?.toInt() ?? 0,
  ```

---

## 4. Fluid Animations & Natural Spring Physics (Chống Animation cứng đơ)

Tuyệt đối **KHÔNG dùng `Curves.linear` hay animation đều đều giả trân**. Để UI mượt mà, đàn hồi tự nhiên như iOS/Material 3:

1. **Chuẩn Thư Viện Hàng Đầu (`flutter_animate`)**:
   - Ưu tiên dùng `flutter_animate` với cú pháp chainable sạch, không rác boilerplate `AnimationController`:
     ```dart
     widget
       .animate()
       .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
       .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack); // easeOutBack tạo độ nảy nhẹ tự nhiên
     ```
2. **Quy chuẩn Curves vật lý (Bắt buộc tuân thủ)**:
   - **Xuất hiện / Fade In**: Bắt buộc dùng `Curves.easeOutCubic` hoặc `Curves.easeOutQuad` (vào nhanh, phanh êm).
   - **Click / Tap / Scale nảy**: Bắt buộc dùng `Curves.easeOutBack` (có độ nảy đàn hồi overshoot nhẹ).
   - **Chuyển trang / BottomSheet**: Dùng `Curves.fastOutSlowIn` (chuẩn Material 3 Motion).
3. **Hiệu ứng so le (Staggered Animation)**:
   - Khi render danh sách `ListView` hoặc các Cards: Bắt buộc dùng hiệu ứng so le với độ trễ `delay: (index * 50).ms` để các item xuất hiện tuần tự mượt mà, không bị giật cục đồng loạt.

---

## 5. Testing & Verification

1. **Widget Testing (`WidgetTester`)**:
   - Verify UI rendering and user interactions without running an emulator:
     ```dart
     testWidgets('Submits score on button tap', (tester) async {
       await tester.pumpWidget(const MyApp());
       await tester.enterText(find.byKey(const Key('score_input')), '21');
       await tester.tap(find.byType(ElevatedButton));
       await tester.pumpAndSettle();
       expect(find.text('Submitted'), findsOneWidget);
     });
     ```
2. **Static Analysis & Error Correction**:
   - Always run `dart analyze` to catch type warnings, deprecations, and potential NPEs.
   - Run `dart fix --apply` to automatically resolve mechanical lint recommendations.
