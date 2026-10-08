---
name: screenshot-to-flutter
description: Use when converting UI screenshots, mockups, or wireframes into clean Flutter/Dart widgets and layouts.
---

# Screenshot to Flutter (Pixel-Accurate Widget Synthesis)

Inspired by `pixels2flutter`, this skill converts UI screenshots, mockups, or wireframes into production-ready, modular Dart/Flutter code while eliminating typical AI layout errors (`RenderFlex overflow`, unconstrained viewports, generic styling).

---

## 1. The 3-Phase Execution Pipeline

Never jump straight into writing a massive monolithic Widget file. Always execute in 3 deterministic phases:

```
[UI Screenshot / Mockup]
          │
          ▼
Phase 1: Token & Asset Extraction (Colors, Typography, Icons, Images)
          │
          ▼
Phase 2: Widget Tree Architecture (Modular breakdown, Overflow guards)
          │
          ▼
Phase 3: Code Implementation & DartPad Validation
```

---

## 2. Phase 1: Token & Asset Extraction

Before writing code, extract and verify design constants from the screenshot:
1. **Color Palette:**
   - Primary, Secondary, Background (`Scaffold`), Surface (`Card`), and Text colors in `0xFFxxxxxx` format.
2. **Typography Scale:**
   - Heading (`fontSize`, `fontWeight`), Subtitle, Body, and Caption.
3. **Spacing & Radii:**
   - Consistent padding/gap (e.g., 8, 16, 24) and border radii (`BorderRadius.circular(12)`).
4. **Asset & Image Generation:**
   - If the screenshot contains custom illustrations, banners, or avatars:
   - Call the environment's image generation tool (e.g., `generate_image`) with descriptive prompts to produce exact placeholder assets.
   - Reference generated assets via `Image.asset()` or `Image.file()`, or provide high-fidelity `NetworkImage` / `Container(decoration: ...)` fallbacks.

---

## 3. Phase 2: Widget Architecture (Anti-Overflow Rules)

To prevent Flutter's notorious yellow-black zebra stripes (`RenderFlex overflowed`):

1. **Root Scrolling:** Always wrap scrollable body sections in `SingleChildScrollView(child: Column(...))` or `CustomScrollView(slivers: [...])`.
2. **Flex Protection:** Never put an unconstrained `ListView` directly inside a `Column`. Always wrap in `Expanded` or set `shrinkWrap: true, physics: const NeverScrollableScrollPhysics()`.
3. **Modular Sub-Widgets:** Break the screen down into private helper builder methods or dedicated stateless widgets:
   - `_buildHeader(BuildContext context)`
   - `_buildMetricCards(BuildContext context)`
   - `_buildActionList(BuildContext context)`
   - `_buildBottomBar(BuildContext context)`
4. **Material 3 Semantics:**
   - Use `FilledButton`, `OutlinedButton`, `Card(elevation: 0, shape: ...)`, `InputDecoration`.
   - Avoid nesting 10 levels of generic `Container` widgets.

---

## 4. Phase 3: Dart Implementation Template

Structure the resulting code cleanly so it can be pasted into the project or run directly on DartPad:

```dart
import 'package:flutter/material.dart';

class GeneratedScreen extends StatelessWidget {
  const GeneratedScreen({super.key});

  // 1. Design Tokens extracted from screenshot
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildMainContent(),
              const SizedBox(height: 20),
              _buildActionFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHeaderSection() { /* Extracted components */ }
  Widget _buildMainContent() { /* Extracted components */ }
  Widget _buildActionFooter() { /* Extracted components */ }
}
```

---

## 5. Verification Checklist
- [ ] No hardcoded screen widths/heights (`MediaQuery` or responsive flex used).
- [ ] Overflow guarded with `SingleChildScrollView` or `Expanded`.
- [ ] Visual hierarchy, padding, and corner radii strictly match the screenshot.
- [ ] Reusable models or state parameters separated from UI layout.
