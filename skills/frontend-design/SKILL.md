---
name: frontend-design
description: Use when creating distinctive frontend interfaces, bespoke UI aesthetics, typography, animations, and avoiding generic UI slop.
---

# Frontend Design (Anti-Slop Art Direction)

Use this skill whenever designing, styling, or creating frontend pages and UI components. It prevents the predictable, lifeless "AI slop" (grey cards, generic purple/blue gradients, cookie-cutter layouts) by requiring intentional design direction before coding.

---

## 1. Eliminate "AI UI Slop" Anti-Patterns

### ❌ What AI Typically Generates (Avoid):
- Centered white/dark-grey cards with `rounded-xl` and `shadow-md` everywhere.
- Generic Indigo/Violet `#6366F1` gradient buttons on dark backgrounds.
- Symmetrical, boring 3-column feature grids with identical lucide icons in circles.
- Lack of whitespace contrast and flat, uninspired visual hierarchy.

### ✅ What Real Designers Build (Enforce):
- **Distinct Aesthetic Personality:** Match the domain (e.g., Brutalist/Editorial for news/creative tools, Crisp Swiss Minimalism for productivity, Warm Organic for lifestyle).
- **Asymmetry & Focal Points:** Break predictable grids with varied card sizes, editorial hero sections, or striking typography scale.
- **Intentional Color Palette:** 1 dominant personality color + high-contrast neutrals + 1 deliberate accent color. Avoid rainbow gradients.

---

## 2. Core Design Pillars

### A. Typography Hierarchy
- Pair an expressive display typeface (or bold sans weights) with an ultra-clean body typeface.
- Maintain strict modular type scale (e.g., Hero: `text-5xl font-black tracking-tight`, Body: `text-sm text-muted-foreground leading-relaxed`).
- Always control letter-spacing (`tracking-tight` for large headings, `tracking-normal` for body).

### B. Depth, Borders & Spatial Rhythm
- Prefer crisp 1px borders (`border-border/60` or `border-zinc-200/80`) over heavy fuzzy drop-shadows.
- Use layered surface elevation: Page background (`bg-background`) $\rightarrow$ Card container (`bg-card`) $\rightarrow$ Active item / hover state.
- Generous, intentional padding: Don't cramp content. Give hero elements breathing room (`py-16 md:py-24`).

### C. Polish & Micro-Interactions
- Subtle state transitions: `transition-all duration-200 ease-out`.
- Distinct hover & active feedback: Subtle transform (`hover:-translate-y-0.5`), surface brighten, or refined border glow.
- Tactile button states: Active press effect (`active:scale-[0.98]`).

---

## 3. Workflow When Building Any UI
1. **Define the Mood:** State the visual theme (e.g., "Linear-style dark minimalism with amber accents").
2. **Lock the Palette:** Define 1-2 semantic accent tokens and high-contrast text shades.
3. **Draft the Layout:** Create high-impact layout with strong contrast and purposeful hierarchy.
4. **Implement & Refine:** Combine with technical specs (`ui-ux-pro-max`) to guarantee accessibility and responsive fidelity.
