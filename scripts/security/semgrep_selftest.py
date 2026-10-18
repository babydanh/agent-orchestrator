#!/usr/bin/env python3
"""Self-test quy tắc Semgrep cục bộ bằng fixture giả.

- Fixture vulnerable: mỗi quy tắc phải báo đúng số vị trí kỳ vọng và không có quy tắc lạ nào báo.
- Fixture safe (negative): không được báo vị trí nào.
- Semgrep phải quét đủ mọi file fixture và không có lỗi phân tích.

Không in nội dung fixture hay stderr của Semgrep: chỉ in số đếm và tên quy tắc.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from collections import Counter
from pathlib import Path

# Số vị trí (quy tắc, file, dòng) kỳ vọng trong fixture vulnerable. Thêm/bớt fixture thì cập nhật bảng này.
EXPECTED_VULNERABLE = {
    "js-sql-template-injection": 2,
    "js-dynamic-exec": 3,
    "js-eval": 2,
    "jsx-dangerously-set-inner-html": 2,
}


def run_semgrep(semgrep: str, rules: Path, target: Path, out: Path, log: Path) -> int:
    cmd = [
        semgrep,
        "scan",
        "--config",
        str(rules),
        "--json",
        "--output",
        str(out),
        "--metrics=off",
        "--disable-version-check",
        "--quiet",
        str(target),
    ]
    with log.open("w", encoding="utf-8") as fh:
        try:
            return subprocess.run(cmd, stdout=fh, stderr=fh, timeout=600, check=False).returncode
        except subprocess.TimeoutExpired:
            return -1


def unique_hits(data: dict) -> list[tuple[str, str, object]]:
    seen: set[tuple[str, str, object]] = set()
    hits: list[tuple[str, str, object]] = []
    for r in data.get("results", []):
        key = (
            str(r.get("check_id", "")).rsplit(".", 1)[-1],
            str(r.get("path", "")),
            (r.get("start") or {}).get("line"),
        )
        if key not in seen:
            seen.add(key)
            hits.append(key)
    return hits


def main() -> int:
    ap = argparse.ArgumentParser(description="Self-test quy tắc Semgrep bằng fixture.")
    ap.add_argument("--semgrep", required=True, help="đường dẫn binary semgrep đã ghim")
    ap.add_argument("--rules", required=True, type=Path)
    ap.add_argument("--fixtures", required=True, type=Path)
    a = ap.parse_args()

    failures: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        tmpd = Path(tmp)
        for kind in ("vulnerable", "safe"):
            target = a.fixtures / kind
            n_files = sum(1 for f in target.rglob("*") if f.is_file())
            out, log = tmpd / f"{kind}.json", tmpd / f"{kind}.log"
            rc = run_semgrep(a.semgrep, a.rules, target, out, log)
            if rc != 0:
                failures.append(f"{kind}: semgrep exit={rc}")
                continue
            data = json.loads(out.read_text(encoding="utf-8"))
            if data.get("errors"):
                failures.append(f"{kind}: semgrep báo lỗi phân tích={len(data['errors'])}")
            scanned = len((data.get("paths") or {}).get("scanned") or [])
            if scanned != n_files:
                failures.append(f"{kind}: quét {scanned}/{n_files} file")
            counts = Counter(rule for rule, _, _ in unique_hits(data))
            if kind == "vulnerable":
                for rule, expected in EXPECTED_VULNERABLE.items():
                    if counts.get(rule, 0) != expected:
                        failures.append(f"vulnerable: {rule} báo {counts.get(rule, 0)}, kỳ vọng {expected}")
                extra = sorted(set(counts) - set(EXPECTED_VULNERABLE))
                if extra:
                    failures.append(f"vulnerable: quy tắc ngoài kỳ vọng báo: {', '.join(extra)}")
                print(f"vulnerable: {sum(counts.values())} vị trí báo trên {n_files} file; theo quy tắc: {dict(counts)}")
            else:
                n = sum(counts.values())
                print(f"safe: {n} vị trí báo (kỳ vọng 0) trên {n_files} file")
                if n:
                    failures.append(f"safe: {n} vị trí báo nhầm (false positive)")

    if failures:
        for f in failures:
            print(f"::error::Self-test Semgrep thất bại: {f}")
        return 1
    print("Self-test Semgrep: đạt (fixture lỗi giả bị bắt đủ, fixture an toàn sạch).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
