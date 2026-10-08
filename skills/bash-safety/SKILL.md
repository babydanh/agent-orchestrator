---
name: bash-safety
description: Use when running destructive shell commands, deleting directories, killing processes, or avoiding shell state loss.
---

# Shell & Command Safety Guidelines

Safety rules to ensure agent terminal commands never accidentally corrupt workspaces, wipe critical directories, or terminate essential system services.

---

## 1. Destructive Command Safeguards

- **No Blind Deletions:**
  - Never execute `rmdir /s /q` or `Remove-Item -Recurse -Force` with wildcards (`*`) or relative paths near roots.
  - Always verify target paths explicitly before deleting.
  - Prefer moving to a backup directory or trashing rather than permanent recursive deletion when cleaning state.

## 2. Process Control Safety

- **Accurate Process Targeting:**
  - When killing processes (`taskkill` or `Stop-Process`), always specify exact names or verify PIDs.
  - Never run blanket kill commands that could terminate the IDE, editor, or system background daemons.

## 3. Configuration & State Integrity

- **Non-Destructive Overwrites:**
  - Before overwriting global config files (`~/.bashrc`, `~/.omp/config.yml`, etc.), ensure backups exist.
  - Always verify command syntax before batch operations.
