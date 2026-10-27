"""Test e2e-run.sh (job e2e của agent-task.yml) với `gh` giả: tách test đỏ do việc gây ra khỏi test đỏ có sẵn.

Chạy: python scripts/agent/test_e2e_run.py   (cần bash: Git Bash trên Windows)
"""
import os
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "e2e-run.sh")
_GIT_BASH = os.path.join(os.path.dirname(os.path.dirname(shutil.which("git") or "")), "bin", "bash.exe")
BASH = _GIT_BASH if os.name == "nt" and os.path.exists(_GIT_BASH) else (shutil.which("bash") or "bash")

# gh giả: `workflow run` ghi lại lệnh; `run list` trả id đã khai cho mã yêu cầu nằm trong --jq;
# `run view` trả completed / kết luận / log đã khai cho id đó.
FAKE_GH = r"""#!/usr/bin/env bash
d="$FAKE_GH_DIR"
case "$1 $2" in
  "workflow run") printf '%s\n' "$*" >> "$d/dispatched.txt" ;;
  "run list")
    prev=""; q=""; for a in "$@"; do [ "$prev" = "--jq" ] && q=$a; prev=$a; done
    req=$(printf '%s' "$q" | sed -E 's/.*#([^"\\]+).*/\1/')
    [ -f "$d/id-$req" ] && cat "$d/id-$req" ;;
  "run view")
    case " $* " in
      *" --log "*) cat "$d/log-$3" 2>/dev/null ;;
      *status*) echo completed ;;
      *) cat "$d/conclusion-$3" ;;
    esac ;;
esac
"""


def playwright_log(*failed):
    """Log `gh run view --log` thật của test-runner: mỗi test đỏ in ✘ một lần cho mỗi lượt chạy lại, cuối log có
    bảng tổng kết `1) [chromium] › ...` và `N failed` (không được đếm thêm lần nữa)."""
    prefix = "🚀 Full-Stack E2E shard 1/1 (Postgres + Backend NestJS + Web Next.js)\tUNKNOWN STEP\t2026-10-26T19:23:58.5647624Z"
    lines = [f"{prefix} Running 12 tests using 1 worker"]
    n = 0
    for t in failed:
        for _retry in range(2):
            n += 1
            lines.append(f"{prefix}   ✘  {n:>2} [chromium] › {t} (46.3s)")
    for i, t in enumerate(failed, 1):
        lines.append(f"{prefix}   {i}) [chromium] › {t} ─────────────")
    lines.append(f"{prefix}   {len(failed)} failed")
    return "\n".join(lines) + "\n"


class E2eRunTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp().replace("\\", "/")
        self.bin = f"{self.tmp}/bin"
        self.gh = f"{self.tmp}/gh"
        self.work = f"{self.tmp}/work"
        for d in (self.bin, self.gh, self.work):
            os.makedirs(d)
        with open(f"{self.bin}/gh", "w", encoding="utf-8", newline="\n") as f:
            f.write(FAKE_GH)
        os.chmod(f"{self.bin}/gh", 0o755)

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def fake_run(self, req, run_id, conclusion, *failed):
        for name, text in ((f"id-{req}", run_id), (f"conclusion-{run_id}", conclusion),
                           (f"log-{run_id}", playwright_log(*failed))):
            with open(f"{self.gh}/{name}", "w", encoding="utf-8", newline="\n") as f:
                f.write(text if name.startswith("log") else text + "\n")

    def run_script(self, web_ref="omp/issue-54", base_web_ref="nhap-excel-mot-cua", specs="test/e2e/a.spec.ts"):
        env = {**os.environ, "PATH": self.bin + os.pathsep + os.environ["PATH"], "FAKE_GH_DIR": self.gh,
               "GH_TOKEN": "x", "REPO": "o/r", "REQ": "agent-1", "SPECS": specs,
               "WEB_REF": web_ref, "BACKEND_REF": "", "BASE_WEB_REF": base_web_ref, "BASE_BACKEND_REF": "",
               "E2E_FIND_SECONDS": "0", "E2E_POLL_SECONDS": "0"}
        r = subprocess.run([BASH, SCRIPT], cwd=self.work, env=env, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
        self.assertEqual(r.returncode, 0, r.stderr)
        return dict(line.split("=", 1) for line in r.stdout.splitlines() if "=" in line)

    def read(self, name):
        path = f"{self.work}/{name}" if name.endswith(".txt") and not name.startswith("dispatched") else f"{self.gh}/{name}"
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as f:
            return f.read().splitlines()

    def test_only_tests_not_red_on_base_count_against_the_task(self):
        self.fake_run("agent-1", "100", "failure",
                      "test/e2e/a.spec.ts:605:3 › Nhập Excel › giữ ghi chú",
                      "test/e2e/b.spec.ts:20:1 › Tìm giải")
        # Trên nhánh nền, cùng test đó nằm ở dòng khác (spec bị sửa trên nhánh việc): vẫn là cùng một test.
        self.fake_run("agent-1-base", "200", "failure", "test/e2e/b.spec.ts:18:1 › Tìm giải")
        out = self.run_script()
        self.assertEqual((out["failed"], out["preexisting"], out["base_run_id"]), ("1", "1", "200"))
        self.assertEqual(self.read("failed.txt"), ["[chromium] › test/e2e/a.spec.ts › Nhập Excel › giữ ghi chú"])
        self.assertEqual(self.read("preexisting.txt"), ["[chromium] › test/e2e/b.spec.ts › Tìm giải"])
        base_dispatch = self.read("dispatched.txt")[1]
        self.assertIn("web_ref=nhap-excel-mot-cua", base_dispatch)
        self.assertIn("specs=test/e2e/a.spec.ts test/e2e/b.spec.ts", base_dispatch)

    def test_all_red_tests_also_red_on_base_leaves_nothing_for_the_agent(self):
        self.fake_run("agent-1", "100", "failure", "test/e2e/b.spec.ts:20:1 › Tìm giải")
        self.fake_run("agent-1-base", "200", "failure", "test/e2e/b.spec.ts:20:1 › Tìm giải")
        out = self.run_script()
        self.assertEqual((out["conclusion"], out["failed"], out["preexisting"]), ("failure", "0", "1"))

    def test_base_run_missing_counts_every_red_test_against_the_task(self):
        self.fake_run("agent-1", "100", "failure", "test/e2e/b.spec.ts:20:1 › Tìm giải")
        out = self.run_script()
        self.assertEqual((out["failed"], out["preexisting"], out["base_run_id"]), ("1", "0", ""))

    def test_green_run_does_not_rerun_on_base(self):
        self.fake_run("agent-1", "100", "success")
        out = self.run_script()
        self.assertEqual((out["conclusion"], out["failed"]), ("success", "0"))
        self.assertEqual(len(self.read("dispatched.txt")), 1)

    def test_no_task_branch_skips_e2e_instead_of_testing_the_base(self):
        out = self.run_script(web_ref="nhap-excel-mot-cua")
        self.assertEqual(out["conclusion"], "no_task_branch")
        self.assertEqual(self.read("dispatched.txt"), [])


if __name__ == "__main__":
    unittest.main()
