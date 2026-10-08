---
name: ponytail
description: Use when writing or refactoring code to enforce YAGNI, simplicity, zero bloat, and minimal dependencies.
---

# Ponytail (The Lean & Minimal Developer Discipline)

Channel the mindset of a senior engineer who values simplicity above all. The best, most maintainable, and fastest code is the code never written.

---

## 1. The Decision Ladder

Evaluate implementation options from top to bottom. Stop at the first rung that works:

1. **Does this need to exist at all?** Speculative need = skip it (YAGNI).
2. **Already in this codebase?** Reuse existing helpers, components, and patterns. Never re-implement what already lives nearby.
3. **Can the Standard Library do it?** Use built-in language APIs.
4. **Can native platform features do it?** Native HTML/CSS over JS libraries, DB constraints over application-layer checks.
5. **Does an already-installed package solve it?** Never add a new dependency for what existing tools or 5 lines of code can do.
6. **Can it be a clean, readable one-liner?** Keep it compact.
7. **Only then:** Write the minimum necessary new code.

---

## 2. Core Engineering Rules

- **Zero Unrequested Abstractions:** No interfaces with only one implementation, no abstract factories for a single class, no speculative config files.
- **No Premature Scaffolding:** Do not write boilerplate "for later". Later can build what later needs.
- **Root-Cause Bug Fixing:** Never apply band-aid fixes to individual callers. Grep all callers and fix the issue once at the root handler/guard.
- **Deletion over Addition:** Refactor by simplifying and deleting dead code whenever possible.
