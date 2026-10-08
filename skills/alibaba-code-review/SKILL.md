---
name: alibaba-code-review
description: Use when finishing features, before git commit, or auditing NPE, SQLi, and security bugs via Alibaba ocr CLI.
---

# Alibaba Open Code Review (OCR) Workflow

Automated code review leveraging Alibaba's open-source `ocr` engine (`alibaba/open-code-review`), which uses deterministic static pipelines + targeted LLM analysis for 9x token efficiency and high precision.

---

## 1. When to Use
- After completing a non-trivial feature or bugfix.
- Before running `git commit`.
- When explicitly requested to audit code security, potential race conditions, or null pointers.

---

## 2. Execution Workflow

### Step 1: Run the `ocr` CLI
Execute via bash/terminal in the project root:
```bash
ocr review
```
Or to run a targeted vulnerability scan:
```bash
ocr scan
```

### Step 2: Analyze & Patch Defects
If `ocr` reports defects:
- Focus on critical categories:
  - **NPE (Null Pointer Exceptions)** & unhandled nullability.
  - **Concurrency & Thread Safety** (race conditions, shared state).
  - **Security Vulnerabilities** (SQL injection, XSS, insecure deserialization).
  - **Resource Leaks** (unclosed DB connections, streams).
- Inspect the exact file and line numbers flagged.
- Apply root-cause fixes directly to the source code.

### Step 3: Re-verify & Confirm
- Re-run `ocr review` to ensure 0 critical warnings.
- Once clean, proceed to git commit or report a clean status to the user.
