"""Bước 9 của agent-task.yml: ghi token Codex OAuth mới về secret OMP_CODEX_AUTH, CHỈ khi run này thật sự làm mới nó.

Bản cũ ghi đè secret ở MỌI run (kể cả run bị huỷ, run không đụng tới token) bằng bản trong agent.db. Nhiều run chạy
song song cùng đọc một secret: run nào xong sau ghi đè bản của run trước, kể cả khi bản của nó cũ hơn. Refresh token
OAuth bị xoay vòng nên bản cũ không dùng được nữa -> run sau báo "Khóa Codex không dùng được" (run 39352451699,
20/10). Ở đây chỉ ghi khi: token trong agent.db KHÁC token đã tiêm lúc đầu run VÀ hạn dùng (expires) mới hơn.

Biến môi trường: GH_PAT, REPO (owner/name), OMP_CODEX_AUTH (base64 JSON đã tiêm ở bước 5), AGENT_DB (tuỳ chọn).
"""
from __future__ import annotations

import base64
import json
import os
import sqlite3
import sys


def active_codex(db_path: str) -> str | None:
    """JSON của tài khoản openai-codex đang dùng (giống sync-codex-token.ps1: bỏ tài khoản đã xoá)."""
    if not os.path.exists(db_path):
        return None
    con = sqlite3.connect(db_path)
    try:
        row = con.execute(
            "SELECT data FROM auth_credentials WHERE provider = 'openai-codex' AND disabled_cause IS NULL "
            "ORDER BY updated_at DESC, id DESC LIMIT 1"
        ).fetchone()
    finally:
        con.close()
    return row[0] if row and row[0] else None


def _expires(data: str) -> int:
    try:
        return int(json.loads(data).get("expires") or 0)
    except (ValueError, TypeError, AttributeError):
        return 0


def should_persist(injected_b64: str | None, current: str | None) -> tuple[bool, str]:
    """(có ghi không, lý do). injected_b64 = secret lúc đầu run; current = JSON trong agent.db lúc cuối run."""
    if not current:
        return False, "agent.db không có tài khoản openai-codex đang dùng"
    try:
        injected = base64.b64decode(injected_b64 or "").decode("utf-8")
    except ValueError:
        injected = ""
    if injected and json.dumps(json.loads(injected), sort_keys=True) == json.dumps(json.loads(current), sort_keys=True):
        return False, "token không đổi trong run này"
    if _expires(current) <= _expires(injected):
        return False, "token trong agent.db không mới hơn token đã tiêm (không ghi đè bản mới hơn của run khác)"
    return True, "run này đã làm mới token"


def put_secret(token: str, repo: str, value_b64: str) -> int:
    import requests
    from nacl import encoding, public

    headers = {"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json",
               "X-GitHub-Api-Version": "2022-11-28"}
    pk = requests.get(f"https://api.github.com/repos/{repo}/actions/secrets/public-key", headers=headers, timeout=30)
    if pk.status_code != 200:
        print(f"Lỗi lấy public key: {pk.status_code}")
        return pk.status_code
    key = pk.json()
    box = public.SealedBox(public.PublicKey(key["key"].encode(), encoding.Base64Encoder))
    encrypted = base64.b64encode(box.encrypt(value_b64.encode())).decode()
    res = requests.put(f"https://api.github.com/repos/{repo}/actions/secrets/OMP_CODEX_AUTH", headers=headers,
                       json={"encrypted_value": encrypted, "key_id": key["key_id"]}, timeout=30)
    return res.status_code


def main() -> int:
    token, repo = os.environ.get("GH_PAT"), os.environ.get("REPO")
    if not token or not repo:
        print("Thiếu GH_PAT hoặc REPO, bỏ qua.")
        return 0
    current = active_codex(os.environ.get("AGENT_DB") or os.path.expanduser("~/.omp/agent/agent.db"))
    ok, why = should_persist(os.environ.get("OMP_CODEX_AUTH"), current)
    print(f"Token Codex: {why}.")
    if not ok:
        return 0
    status = put_secret(token, repo, base64.b64encode(current.encode()).decode())
    print("Đã cập nhật secret OMP_CODEX_AUTH." if status in (201, 204) else f"Lỗi cập nhật secret: {status}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
