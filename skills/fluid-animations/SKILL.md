---
name: fluid-animations
description: Use when creating, styling, or refining UI animations, page transitions, micro-interactions, lists, or gestures in Web (React, Next.js, Framer Motion, Tailwind) or Flutter (flutter_animate) to ensure 60fps butter-smooth, physics-based responsiveness.
---

# Fluid Animations & Physics-Based Micro-Interactions

## Overview
Animations must feel snappy, physical, and alive — never sluggish, floaty, or robotic. This skill enforces 60fps performance budgets, spring physics, and staggered timing across both Web (Framer Motion / CSS) and Flutter (`flutter_animate`).

---

## 1. The 3 Golden Rules of Butter-Smooth Feel

| Factor | Bad (Laggy / Sluggish) | Good (Butter-Smooth 60fps) |
| :--- | :--- | :--- |
| **Duration Budget** | `> 400ms` (Feels like slow motion) | **`150ms – 250ms`** (Snappy, decisive, instant) |
| **Curves & Easing** | `linear`, `easeInOut` (Stiff & robotic) | **Spring physics** or **`easeOutCubic` / `easeOutBack`** |
| **List Loading** | All items pop up simultaneously (Janky) | **Staggered delay**: `index * (30-50ms)` (Waterfall flow) |

---

## 2. Web Stack: Framer Motion & Tailwind Patterns

### A. Snappy Tap & Hover Micro-Interactions (Physical Feedback)
Never leave buttons, cards, or chips flat on click/tap:
```tsx
// ✅ Correct: Physical spring reaction on click & hover
<motion.button
  whileHover={{ scale: 1.02, y: -1 }}
  whileTap={{ scale: 0.96 }}
  transition={{ type: "spring", stiffness: 450, damping: 25 }}
  className="px-4 py-2 bg-blue-600 text-white rounded-lg"
>
  Xác nhận
</motion.button>
```

### B. List Staggered Reveal (Smooth Waterfall)
```tsx
// ✅ Correct: Staggered entry with fast duration
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.04, delayChildren: 0.05 }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 12 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { type: "spring", stiffness: 400, damping: 28 }
  }
};
```

### C. Seamless Layout Transitions (`layoutId`)
When switching tabs or active filters, never flicker:
```tsx
// ✅ Correct: Fluid sliding pill indicator
{isActive && (
  <motion.div
    layoutId="activePill"
    className="absolute inset-0 bg-blue-600 rounded-md -z-10"
    transition={{ type: "spring", stiffness: 380, damping: 30 }}
  />
)}
```

---

## 3. Flutter Stack: `flutter_animate` Standards

### A. Snappy Card & Modal Reveal
```dart
// ✅ Correct: Snappy fade + subtle upward rise with easeOutCubic
widget
  .animate()
  .fadeIn(duration: 200.ms, curve: Curves.easeOutCubic)
  .slideY(begin: 0.12, end: 0, duration: 240.ms, curve: Curves.easeOutCubic);
```

### B. Elastic Success / Alert Badges (Overshoot)
```dart
// ✅ Correct: Elastic spring pop for icons, scores, badges
badgeWidget
  .animate()
  .scale(
    begin: const Offset(0.7, 0.7),
    end: const Offset(1.0, 1.0),
    duration: 320.ms,
    curve: Curves.easeOutBack, // Subtle overshoot creates satisfying pop
  );
```

### C. Staggered ListView / GridView
```dart
// ✅ Correct: Staggered waterfall flow for match lists
Widget buildItem(int index) {
  return matchCard
    .animate()
    .fadeIn(duration: 220.ms, delay: (index * 35).ms)
    .slideY(begin: 0.08, end: 0, duration: 250.ms, curve: Curves.easeOutCubic);
}
```

---

## 4. Performance & 60FPS Budgets (Anti-Jank Rules)

1. **GPU-Accelerated Properties Only**:
   - Web: Animate ONLY `transform` (`x`, `y`, `scale`, `rotate`) and `opacity`. NEVER animate `height`, `width`, `top`, `left`, `margin`, or `padding` directly (causes layout recalculation / reflow).
   - Flutter: Use `RepaintBoundary` for animated widgets and keep controllers outside `build()`.
2. **Cap Max Duration**:
   - Micro-interaction: `100ms – 160ms`.
   - Popups / Drawers / Dialogs: `200ms – 260ms`.
   - Never let an animation exceed `350ms` unless it is an explicit cinematic splash screen.
3. **Reduced Motion Accessibility**:
   - Always honor system reduced motion preferences (`useReducedMotion()` in Web, `MediaQuery.disableAnimationsOf(context)` in Flutter).
