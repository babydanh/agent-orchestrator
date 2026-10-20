"""Test persist_codex_token.py: chỉ ghi secret khi run này thật sự làm mới token (không ghi đè bản mới hơn)."""
import base64
import json
import os
import sqlite3
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import persist_codex_token as p  # noqa: E402


def tok(refresh: str, expires: int) -> str:
    return json.dumps({"access": "a-" + refresh, "refresh": refresh, "expires": expires, "email": "x@y"})


def b64(s: str) -> str:
    return base64.b64encode(s.encode()).decode()


class ShouldPersistTest(unittest.TestCase):
    def test_token_khong_doi_thi_khong_ghi(self):
        t = tok("r1", 100)
        self.assertFalse(p.should_persist(b64(t), t)[0])

    def test_run_lam_moi_token_thi_ghi(self):
        self.assertTrue(p.should_persist(b64(tok("r1", 100)), tok("r2", 200))[0])

    def test_token_cu_hon_ban_da_tiem_thi_khong_ghi_de(self):
        self.assertFalse(p.should_persist(b64(tok("r2", 200)), tok("r1", 100))[0])

    def test_khong_co_tai_khoan_thi_khong_ghi(self):
        self.assertFalse(p.should_persist(b64(tok("r1", 100)), None)[0])


class ActiveCodexTest(unittest.TestCase):
    def test_bo_tai_khoan_da_xoa_lay_ban_moi_nhat(self):
        with tempfile.TemporaryDirectory() as d:
            db = os.path.join(d, "agent.db")
            con = sqlite3.connect(db)
            con.execute("CREATE TABLE auth_credentials (id INTEGER PRIMARY KEY, provider TEXT, credential_type TEXT, "
                        "data TEXT, disabled_cause TEXT, updated_at INTEGER)")
            rows = [("openai-codex", tok("cu", 1), None, 1), ("openai-codex", tok("xoa", 9), "deleted by user", 9),
                    ("openai-codex", tok("moi", 5), None, 5), ("openrouter", "{}", None, 10)]
            con.executemany("INSERT INTO auth_credentials (provider, credential_type, data, disabled_cause, updated_at) "
                            "VALUES (?, 'oauth', ?, ?, ?)", rows)
            con.commit()
            con.close()
            self.assertEqual(json.loads(p.active_codex(db))["refresh"], "moi")


if __name__ == "__main__":
    unittest.main()
