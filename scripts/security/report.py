#!/usr/bin/env python3
"""Tổng hợp kết quả quét bảo mật (Gitleaks, OSV-Scanner, Semgrep) và công bố an toàn.

- Log công khai và step summary chỉ có: tên scanner, trạng thái, số lượng, ghi chú mã thoát, SHA.
- Chi tiết (rule/advisory, gói@phiên bản, file, dòng, commit) chỉ vào issue có tiêu đề cố định,
  trong repo private: Web ghi tại Web; repo public ghi tại omp-global-config private.
- Lỗi hạ tầng tách khỏi phát hiện. Lỗi hạ tầng (kể cả không ghi được issue) làm job đỏ.
Mã thoát: 0 sạch, 1 có phát hiện, 2 lỗi hạ tầng.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import subprocess
import sys
from pathlib import Path

ISSUE_TITLE = "[Security Scan] Báo cáo tự động: Gitleaks / OSV-Scanner / Semgrep"
MAX_ROWS = 300
MAX_BODY_CHARS = 60000

CLEAN = "sạch"
FINDINGS = "có phát hiện"
INFRA = "lỗi hạ tầng"
NOT_APPLICABLE = "không áp dụng"


def result(name, status, note="", rows=()):
    return {"name": name, "status": status, "note": note, "rows": list(rows)}


def exit_code(rd: Path, name: str):
    try:
        return int((rd / f"{name}.exit").read_text(encoding="utf-8").strip())
    except (OSError, ValueError):
        return None


def load(path: Path, default):
    """Trả về default nếu file không tồn tại, None nếu JSON hỏng."""
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except ValueError:
        return None


def rel(raw, wd: Path) -> str:
    if not raw:
        return ""
    p = Path(str(raw))
    try:
        return p.relative_to(wd).as_posix()
    except ValueError:
        return p.as_posix()


def scan_gitleaks(rd: Path, wd: Path):
    name = "Gitleaks (lịch sử mọi nhánh)"
    code = exit_code(rd, "gitleaks")
    if code != 0:
        return result(name, INFRA, f"exit={code}")
    items = load(rd / "gitleaks.json", None)
    if not isinstance(items, list):
        return result(name, INFRA, "báo cáo không đọc được")
    rows = [
        {
            "rule": str(i.get("RuleID", "?")),
            "file": rel(i.get("File", ""), wd),
            "line": str(i.get("StartLine", "")),
            "commit": str(i.get("Commit", ""))[:12],
        }
        for i in items
    ]
    return result(name, FINDINGS if rows else CLEAN, rows=rows)


def scan_osv(rd: Path, wd: Path):
    name = "OSV-Scanner (lockfile)"
    code = exit_code(rd, "osv")
    lock_file = rd / "osv.lockfiles"
    locks = lock_file.read_text(encoding="utf-8").strip() if lock_file.exists() else "0"
    if code == 128:
        return result(name, INFRA, "exit=128: không có lockfile được hỗ trợ")
    if code not in (0, 1):
        return result(name, INFRA, f"exit={code}")
    data = load(rd / "osv.json", None)
    if not isinstance(data, dict):
        return result(name, INFRA, "báo cáo không đọc được")
    rows, seen = [], set()
    for res in data.get("results", []):
        src = rel((res.get("source") or {}).get("path", ""), wd)
        for pkg in res.get("packages", []):
            p = pkg.get("package") or {}
            pv = f"{p.get('name', '?')}@{p.get('version', '?')}"
            for vuln in pkg.get("vulnerabilities", []):
                adv = str(vuln.get("id", "?"))
                cve = next((a for a in vuln.get("aliases", []) if str(a).startswith("CVE-")), "")
                key = (adv, pv, src)
                if key in seen:
                    continue
                seen.add(key)
                rows.append({"rule": f"{adv} {cve}".strip(), "pkg": pv, "file": src})
    if code == 1 and not rows:
        return result(name, INFRA, "exit=1 nhưng báo cáo không có lỗ hổng")
    return result(name, FINDINGS if rows else CLEAN, f"lockfile={locks}", rows)


def scan_semgrep(rd: Path, wd: Path):
    name = "Semgrep (TS/JS/JSX)"
    code = exit_code(rd, "semgrep")
    if code != 0:
        return result(name, INFRA, f"exit={code}")
    data = load(rd / "semgrep.json", None)
    if not isinstance(data, dict):
        return result(name, INFRA, "báo cáo không đọc được")
    rows, seen = [], set()
    for r in data.get("results", []):
        rule = str(r.get("check_id", "?")).rsplit(".", 1)[-1]
        file = rel(r.get("path", ""), wd)
        line = str((r.get("start") or {}).get("line", ""))
        if (rule, file, line) not in seen:
            seen.add((rule, file, line))
            rows.append({"rule": rule, "file": file, "line": line})
    errors = data.get("errors") or []
    scanned = (data.get("paths") or {}).get("scanned") or []
    if errors:
        diagnostics = []
        for error in errors:
            span = next(iter(error.get("spans") or []), {})
            location = error.get("location") or {}
            error_type = error.get("type") if isinstance(error.get("type"), str) else "scanner-error"
            diagnostics.append({
                "rule": f"SCAN_INCOMPLETE:{error_type}",
                "file": rel(error.get("path") or location.get("path") or span.get("file"), wd),
                "line": str((error.get("start") or location.get("start") or span.get("start") or {}).get("line", "")),
            })
        return {**result(name, INFRA, f"lỗi phân tích={len(errors)}", rows), "diagnostics": diagnostics}
    if not scanned:
        return result(name, INFRA, "không quét được file nào", rows)
    return result(name, FINDINGS if rows else CLEAN, rows=rows)


def semgrep_not_applicable():
    return result(
        "Semgrep (TS/JS/JSX)",
        NOT_APPLICABLE,
        "Dart chưa được Semgrep hỗ trợ ổn định, không có SAST cho dự án này",
    )


def gh(args, token: str):
    try:
        r = subprocess.run(
            ["gh", *args],
            capture_output=True,
            text=True,
            timeout=180,
            env={**os.environ, "GH_TOKEN": token},
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return 1, ""
    # stderr của gh không in ra: có thể chứa chi tiết nội bộ.
    return r.returncode, r.stdout


def esc(value) -> str:
    return str(value).replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def build_body(a, scans) -> str:
    now = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    out = [
        "Báo cáo quét bảo mật tự động. Chi tiết chỉ hiển thị trong repo private này.",
        "",
        f"Dự án `{a.target}` · ref `{a.ref}` · commit `{a.sha[:12]}` · cập nhật {now}",
        "",
        "| Scanner | Trạng thái | Số phát hiện | Ghi chú |",
        "|---|---|---|---|",
    ]
    out += [f"| {s['name']} | {s['status']} | {len(s['rows'])} | {esc(s['note'])} |" for s in scans]
    rows = [(s["name"], r) for s in scans for r in [*s["rows"], *s.get("diagnostics", [])]]
    if rows:
        out += ["", "| Scanner | Quy tắc / advisory | Gói@phiên bản | File | Dòng | Commit |", "|---|---|---|---|---|---|"]
        for name, r in rows[:MAX_ROWS]:
            cells = [name, r.get("rule", ""), r.get("pkg", ""), r.get("file", ""), r.get("line", ""), r.get("commit", "")]
            out.append("| " + " | ".join(esc(c) for c in cells) + " |")
        if len(rows) > MAX_ROWS:
            out += ["", f"Còn {len(rows) - MAX_ROWS} dòng không hiển thị do giới hạn độ dài."]
    out += [
        "",
        "Nội dung không chứa đoạn mã, giá trị bí mật hay stderr của scanner.",
        "Gitleaks: xoay vòng khoá/token đã lộ trước, rồi làm sạch lịch sử nếu cần. "
        "OSV-Scanner: nâng phiên bản gói theo advisory. Semgrep: sửa theo file và dòng.",
    ]
    return "\n".join(out)[:MAX_BODY_CHARS]


def sync_issue(a, scans, token: str):
    """Chi tiết không bao giờ công bố vào repo public, kể cả khi mã nguồn mục tiêu public."""
    target_repo = f"{a.owner}/{a.repo}"
    rc, out = gh(["api", f"repos/{target_repo}", "--jq", ".private"], token)
    if rc != 0:
        return f"issue: lỗi hạ tầng (không đọc được repo, gh exit={rc})", True
    repo = target_repo
    if out.strip() != "true":
        repo = f"{a.owner}/omp-global-config"
        rc, out = gh(["api", f"repos/{repo}", "--jq", ".private"], token)
        if rc != 0 or out.strip() != "true":
            return "issue: lỗi hạ tầng (không có kho báo cáo private)", True
    title = f"{ISSUE_TITLE} · {a.repo}"
    rc, out = gh(["issue", "list", "--repo", repo, "--state", "open", "--limit", "100", "--json", "number,title"], token)
    try:
        issues = json.loads(out) if rc == 0 else None
    except ValueError:
        issues = None
    if issues is None:
        return "issue: lỗi hạ tầng (không liệt kê được issue)", True
    existing = next((i for i in issues if i.get("title") == title), None)

    clean = all(s["status"] in (CLEAN, NOT_APPLICABLE) for s in scans)
    if existing is None and clean:
        return "issue: không có gì cần ghi (sạch)", False

    body_file = a.reports / "issue-body.md"
    body_file.write_text(build_body(a, scans), encoding="utf-8")
    if existing is None:
        rc, out = gh(["issue", "create", "--repo", repo, "--title", title, "--body-file", str(body_file)], token)
        if rc != 0:
            return f"issue: lỗi hạ tầng (tạo issue, gh exit={rc})", True
        return f"issue: đã tạo #{out.strip().rsplit('/', 1)[-1]}", False

    num = str(existing["number"])
    rc, _ = gh(["issue", "edit", num, "--repo", repo, "--body-file", str(body_file)], token)
    if rc != 0:
        return f"issue: lỗi hạ tầng (cập nhật #{num}, gh exit={rc})", True
    if not clean:
        return f"issue: đã cập nhật #{num}", False
    rc, _ = gh(["issue", "close", num, "--repo", repo, "--reason", "completed"], token)
    if rc != 0:
        return f"issue: lỗi hạ tầng (đóng #{num}, gh exit={rc})", True
    return f"issue: đã đóng #{num} (sạch)", False


def main() -> int:
    ap = argparse.ArgumentParser(description="Tổng hợp và công bố kết quả quét bảo mật.")
    for flag in ("target", "repo", "owner", "sha", "ref"):
        ap.add_argument(f"--{flag}", required=True)
    ap.add_argument("--workdir", required=True, type=Path)
    ap.add_argument("--reports", required=True, type=Path)
    ap.add_argument("--semgrep", required=True, choices=["true", "false"])
    a = ap.parse_args()

    scans = [
        scan_gitleaks(a.reports, a.workdir),
        scan_osv(a.reports, a.workdir),
        scan_semgrep(a.reports, a.workdir) if a.semgrep == "true" else semgrep_not_applicable(),
    ]
    issue_line, issue_infra = sync_issue(a, scans, os.environ.get("GH_TOKEN", ""))

    lines = [f"## Security scan · {a.target} · ref `{a.ref}` · commit `{a.sha[:12]}`", ""]
    for s in scans:
        if s["status"] == NOT_APPLICABLE:
            lines.append(f"- {s['name']}: {s['status']} ({s['note']})")
        else:
            tail = f" ({s['note']})" if s["note"] else ""
            lines.append(f"- {s['name']}: {s['status']}, số phát hiện={len(s['rows'])}{tail}")
    lines += [f"- {issue_line}", ""]

    infra = issue_infra or any(s["status"] == INFRA for s in scans)
    findings = any(s["status"] == FINDINGS for s in scans)
    if infra:
        verdict, code = "ĐỎ: lỗi hạ tầng (không phải phát hiện; kết quả có thể chưa đầy đủ)", 2
    elif findings:
        verdict, code = "ĐỎ: có phát hiện bảo mật", 1
    else:
        verdict, code = "XANH: sạch", 0
    lines.append(f"**Kết quả:** {verdict}")

    text = "\n".join(lines)
    print(text)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as fh:
            fh.write(text + "\n")
    return code


if __name__ == "__main__":
    sys.exit(main())
