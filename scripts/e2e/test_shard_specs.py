import os
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shard_specs import split  # noqa: E402

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "shard_specs.py")


class SplitTest(unittest.TestCase):
    def test_moi_spec_nam_dung_mot_shard(self):
        specs = [f"test/e2e/s{i:02}.spec.ts" for i in range(23)]
        durations = {s: (i * 7) % 40 + 1 for i, s in enumerate(specs[:15])}
        for total in (1, 2, 4, 6):
            buckets, _ = split(specs, durations, total)
            flat = [s for b in buckets for s in b]
            self.assertEqual(sorted(flat), specs, f"total={total}")

    def test_file_nang_khong_don_chung_mot_shard(self):
        # Playwright --shard chia theo thứ tự chữ cái: ba file nặng cuối danh sách sẽ rơi cùng shard cuối.
        specs = [f"test/e2e/a{i}.spec.ts" for i in range(9)] + ["test/e2e/z1.spec.ts", "test/e2e/z2.spec.ts", "test/e2e/z3.spec.ts"]
        durations = {s: 10 for s in specs[:9]} | {"test/e2e/z1.spec.ts": 150, "test/e2e/z2.spec.ts": 140, "test/e2e/z3.spec.ts": 130}
        buckets, loads = split(specs, durations, 3)
        self.assertEqual(sorted(len([s for s in b if "/z" in s]) for b in buckets), [1, 1, 1])
        self.assertLessEqual(max(loads) - min(loads), 20)

    def test_spec_moi_tinh_bang_trung_vi(self):
        specs = ["test/e2e/a.spec.ts", "test/e2e/b.spec.ts", "test/e2e/c.spec.ts", "test/e2e/new.spec.ts"]
        _, loads = split(specs, {"test/e2e/a.spec.ts": 10, "test/e2e/b.spec.ts": 20, "test/e2e/c.spec.ts": 300}, 1)
        self.assertEqual(loads, [10 + 20 + 300 + 20])


class CliTest(unittest.TestCase):
    def run_cli(self, root, shard, durations):
        return subprocess.run([sys.executable, SCRIPT, "--root", root, "--shard", shard, "--durations", durations],
                              capture_output=True, text=True, encoding="utf-8", cwd=os.path.dirname(root))

    def test_hop_cac_shard_bang_toan_bo_ke_ca_thu_muc_con(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = os.path.join(tmp, "e2e")
            os.makedirs(os.path.join(root, "p0"))
            names = ["a.spec.ts", "b.spec.ts", "p0/c.spec.ts", "d.spec.ts", "helper.ts"]
            for n in names:
                open(os.path.join(root, n), "w").close()
            durations = os.path.join(tmp, "d.json")
            with open(durations, "w", encoding="utf-8") as f:
                f.write('{"specs": {"e2e/p0/c.spec.ts": 50}}')
            got = []
            for i in (1, 2, 3):
                r = self.run_cli(root, f"{i}/3", durations)
                self.assertEqual(r.returncode, 0, r.stderr)
                got += [l for l in r.stdout.splitlines() if l]
            self.assertEqual(sorted(got), ["e2e/a.spec.ts", "e2e/b.spec.ts", "e2e/d.spec.ts", "e2e/p0/c.spec.ts"])

    def test_shard_sai_dang_bi_tu_choi(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = os.path.join(tmp, "e2e")
            os.makedirs(root)
            open(os.path.join(root, "a.spec.ts"), "w").close()
            for bad in ("0/4", "5/4", "x"):
                self.assertNotEqual(self.run_cli(root, bad, os.path.join(tmp, "none.json")).returncode, 0, bad)


if __name__ == "__main__":
    unittest.main()
