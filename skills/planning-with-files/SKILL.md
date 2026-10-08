---
name: planning-with-files
description: Use when executing multi-step complex engineering tasks requiring disk-persistent plans (task_plan.md, findings.md).
---

# Planning with Files (Persistent Multi-Step Execution)

Use this skill whenever handling non-trivial, multi-phase refactors, feature implementations, or complex debugging sessions. Instead of keeping execution state and architectural notes purely in conversation context (which rots, compacts, or gets lost on reset), persist state directly on disk.

---

## 1. Core Triad Structure

Create these files in the project working directory or `.ompplan/` (if working in root repo):

### `task_plan.md` (The Blueprint & Roadmap)
- High-level goal and technical scope.
- Architecture decisions, constraints, and non-goals.
- Phased execution breakdown (Phase 1, Phase 2, ...).
- Success criteria and verification checklist.

### `findings.md` (Codebase Intelligence & Discoveries)
- Relevant files, paths, and line references.
- Key interfaces, data models, and API schemas discovered.
- Gotchas, edge cases, dependencies, and environment idiosyncrasies.
- Research outputs so you don't repeat expensive grep/find queries.

### `progress.md` (Live State & Checklist)
- Active phase and current objective.
- Granular checklist items: `[x]` Done, `[/]` In progress, `[ ]` Pending.
- Recent changes made (with modified file references).
- Current blocker or next immediate action.

---

## 2. Two-Phase Execution Workflow

### Phase 1: Discovery & Planning
1. **Analyze Requirements:** Parse user instructions and verify existing code before writing plans.
2. **Initialize Files:** Create `task_plan.md`, `findings.md`, and `progress.md`.
3. **Log Discoveries:** As you view files and trace code paths, record key facts in `findings.md`.
4. **Draft Milestones:** Outline small, verifiable steps in `progress.md` and check them off incrementally.

### Phase 2: Execution & Continuous Checkpoints
1. **One Step at a Time:** Focus on the active item in `progress.md`.
2. **Update Immediately:** Mark items `[x]` as soon as implemented and verified.
3. **Record Findings:** If a file behaves differently than expected, update `findings.md`.
4. **Verify Before Next Step:** Run tests or syntax checks to ensure zero regressions before advancing.

---

## 3. Surviving Context Compaction & Resets

When the session context reaches compaction or a new session starts:
1. Immediately read `task_plan.md` and `progress.md`.
2. Locate the first unchecked or in-progress item `[/]`.
3. Check `findings.md` for already-discovered paths and decisions to avoid re-reading the entire repo.
4. Continue execution without losing state or asking the user to repeat themselves.

---

## 4. Completion & Cleanup

Once all items in `progress.md` are checked and verified:
- Run final test suites / builds.
- Present a concise summary to the user referencing the completed milestones.
- Keep or archive the files based on project conventions (e.g., delete scratch plans or commit if part of project docs).
