"""Test push-work.sh (bước 7 agent-task.yml) trên repo git thật + remote bare cục bộ.

Chạy: python scripts/agent/test_push_work.py   (cần bash: Git Bash trên Windows)
"""
import os
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "push-work.sh")
BRANCH = "omp/issue-17"
# Windows: `bash` trên PATH có thể là WSL (không thấy ổ V:), dùng Git Bash đi kèm git.
_GIT_BASH = os.path.join(os.path.dirname(os.path.dirname(shutil.which("git") or "")), "bin", "bash.exe")
BASH = _GIT_BASH if os.name == "nt" and os.path.exists(_GIT_BASH) else (shutil.which("bash") or "bash")


def git(cwd, *args):
    r = subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode:
        raise RuntimeError(f"git {args}: {r.stderr}")
    return r.stdout.strip()


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


class PushWorkTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp().replace("\\", "/")
        self.origin = f"{self.tmp}/web.git"
        self.ws = f"{self.tmp}/workspace"
        self.repo = f"{self.ws}/web"
        self.other = f"{self.tmp}/other"
        git(self.tmp, "init", "-q", "--bare", "-b", "main", self.origin)
        for d in (self.repo, self.other):
            git(self.tmp, "clone", "-q", "-c", "core.autocrlf=false", self.origin, d)
            git(d, "config", "user.email", "t@t")
            git(d, "config", "user.name", "t")
        write(f"{self.other}/a.txt", "1\n2\n3\n")
        git(self.other, "add", "-A")
        git(self.other, "commit", "-qm", "base")
        git(self.other, "push", "-q", "origin", "HEAD:main")
        git(self.repo, "pull", "-q", "origin", "main")

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def run_script(self):
        env = {**os.environ, "ISSUE_NUMBER": "17", "RUN_ID": "99", "GITHUB_ENV": f"{self.tmp}/github_env",
               "RECOVER_DIR": f"{self.tmp}/recover"}
        return subprocess.run([BASH, SCRIPT, BRANCH, "web", "app"], cwd=self.ws, env=env,
                              capture_output=True, text=True, encoding="utf-8", errors="replace")

    def remote_file(self, ref, path):
        git(self.other, "fetch", "-q", "origin")
        return git(self.other, "show", f"origin/{ref}:{path}")

    def github_env(self):
        with open(f"{self.tmp}/github_env", encoding="utf-8") as f:
            return f.read()

    def remote_branches(self):
        out = git(self.other, "ls-remote", "--heads", "origin")
        return sorted(line.split("refs/heads/")[1] for line in out.splitlines())

    def test_nhanh_tren_origin_di_tiep_trong_luc_agent_chay_thi_gop_roi_day(self):
        # Issue #17: lúc agent chạy, người dùng đẩy thêm commit lên CÙNG nhánh; push cũ bị từ chối và mất 18 file.
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        git(self.repo, "push", "-q", "origin", BRANCH)
        git(self.other, "fetch", "-q", "origin")
        git(self.other, "checkout", "-q", "-b", BRANCH, f"origin/{BRANCH}")
        write(f"{self.other}/spec.md", "sua dac ta\n")
        git(self.other, "add", "-A")
        git(self.other, "commit", "-qm", "docs: spec")
        git(self.other, "push", "-q", "origin", BRANCH)
        write(f"{self.repo}/code.ts", "agent\n")  # agent làm, chưa commit
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_file(BRANCH, "code.ts"), "agent")
        self.assertEqual(self.remote_file(BRANCH, "spec.md"), "sua dac ta")
        self.assertIn(f"- web: nhánh `{BRANCH}`, 2 file khác main", self.github_env())

    def test_xung_dot_voi_commit_moi_tren_origin_thi_day_sang_nhanh_rieng(self):
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        git(self.repo, "push", "-q", "origin", BRANCH)
        git(self.other, "fetch", "-q", "origin")
        git(self.other, "checkout", "-q", "-b", BRANCH, f"origin/{BRANCH}")
        write(f"{self.other}/a.txt", "1\nNGUOI DUNG\n3\n")
        git(self.other, "commit", "-qam", "user edit")
        git(self.other, "push", "-q", "origin", BRANCH)
        write(f"{self.repo}/a.txt", "1\nAGENT\n3\n")
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_file(BRANCH, "a.txt"), "1\nNGUOI DUNG\n3")  # không ép đè
        self.assertEqual(self.remote_file(f"{BRANCH}-agent-run99", "a.txt"), "1\nAGENT\n3")  # việc agent còn nguyên
        self.assertIn("gộp tay", r.stdout)

    def test_viec_trong_worktree_chua_commit_khong_bi_mat(self):
        # Issue #19: agent làm trong git worktree, bước cũ chỉ xem thư mục clone và đẩy nhánh rỗng.
        wt = f"{self.ws}/web.worktrees/viec"
        git(self.repo, "worktree", "add", "-q", "-b", "viec-rieng", wt)
        write(f"{wt}/feature.dart", "x\n")
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_file(BRANCH, "feature.dart"), "x")
        self.assertNotIn(BRANCH, git(self.repo, "worktree", "list"))  # worktree tạm đã dọn

    def test_khong_co_viec_thi_khong_day_va_bao_ro(self):
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_branches(), ["main"])
        self.assertIn("không repo nào có nhánh", self.github_env())

    def test_nhanh_rong_bao_canh_bao_khong_khac_main(self):
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("KHÔNG khác main", r.stdout)

    def test_nhanh_da_co_commit_cua_agent_khong_bi_reset_khi_thu_muc_clone_con_viec_do(self):
        # Agent commit lên nhánh rồi quay về main và sửa tiếp: checkout -B cũ sẽ xoá commit trên nhánh.
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        write(f"{self.repo}/commit1.ts", "1\n")
        git(self.repo, "add", "-A")
        git(self.repo, "commit", "-qm", "agent commit")
        git(self.repo, "checkout", "-q", "main")
        write(f"{self.repo}/dirty.ts", "2\n")
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_file(BRANCH, "commit1.ts"), "1")
        self.assertEqual(self.remote_file(BRANCH, "dirty.ts"), "2")

    def test_hook_commit_chan_thi_van_commit_bo_qua_hook_va_day(self):
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        write(f"{self.repo}/.git/hooks/pre-commit", "#!/bin/sh\nexit 1\n")
        os.chmod(f"{self.repo}/.git/hooks/pre-commit", 0o755)
        write(f"{self.repo}/code.ts", "agent\n")
        r = self.run_script()
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(self.remote_file(BRANCH, "code.ts"), "agent")
        self.assertIn("--no-verify", r.stdout)

    def test_khong_commit_duoc_thi_sao_luu_file_do_va_bao_loi(self):
        # index.lock bị kẹt: add/commit đều hỏng. File dở phải có bản sao để workflow tải lên artifact.
        git(self.repo, "checkout", "-q", "-b", BRANCH)
        write(f"{self.repo}/src/code.ts", "agent\n")
        write(f"{self.repo}/a.txt", "1\nsua\n3\n")
        write(f"{self.repo}/.git/index.lock", "")
        r = self.run_script()
        os.remove(f"{self.repo}/.git/index.lock")
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("agent-recover", self.github_env())
        saved = f"{self.tmp}/recover/web/web"
        with open(f"{saved}/src/code.ts", encoding="utf-8") as f:
            self.assertEqual(f.read(), "agent\n")
        with open(f"{saved}/a.txt", encoding="utf-8") as f:
            self.assertEqual(f.read(), "1\nsua\n3\n")


if __name__ == "__main__":
    unittest.main()
