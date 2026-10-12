#!/usr/bin/env python3
"""Kiem tra va cham truoc khi commit/push khi nhieu session lam chung mot repo.

CHI DOC, khong sua repo. Dung:
    python safe-push-check.py <thu-muc-repo> [file1 file2 ...]

Neu truyen danh sach file: day la cac file SESSION NAY sua. Script bao file nao
cung dang bi session khac sua do (cung cay lam viec hoac worktree khac) va file nao
da bi nguoi khac doi tren origin.

Exit code: 0 = an toan, 1 = co canh bao can xem, 2 = KHONG nen push.
"""
import subprocess
import sys

DEPLOY_BRANCHES = ("main", "master")


def git(repo, *args, raw=False):
    r = subprocess.run(
        ["git", "-C", repo, *args],
        capture_output=True, encoding="utf-8", errors="replace", timeout=60,
    )
    out = r.stdout or ""
    return r.returncode, (out if raw else out.strip()), (r.stderr or "").strip()


def status_paths(repo):
    """Moi file dang thay doi trong cay lam viec: sua, da stage, FILE MOI CHUA ADD, doi ten.

    Dung `-z` (tach bang NUL) nen ten co dau cach / ky tu dac biet KHONG bi quote hay escape.
    Moi record: 'XY path'. Voi rename/copy (X hoac Y la R/C) record ke tiep la duong dan CU.
    """
    r = subprocess.run(
        ["git", "-C", repo, "status", "--porcelain=v1", "-z", "--untracked-files=all"],
        capture_output=True, timeout=60,
    )
    recs = r.stdout.decode("utf-8", errors="replace").split("\0")
    paths = set()
    i = 0
    while i < len(recs):
        rec = recs[i]
        i += 1
        if len(rec) < 4:
            continue
        xy, path = rec[:2], rec[3:]
        paths.add(path)
        if "R" in xy or "C" in xy:
            i += 1  # bo qua record duong dan cu cua rename/copy
    return paths


def lines(text):
    return [l for l in text.splitlines() if l.strip()]


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    repo = sys.argv[1]
    mine = {f.replace("\\", "/") for f in sys.argv[2:]}
    level = 0
    notes = []

    rc, branch, err = git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    if rc != 0:
        print(f"KHONG doc duoc repo: {err}")
        return 2
    git(repo, "fetch", "-q", "origin")

    # 1. Ahead / behind so voi upstream
    rc, lr, _ = git(repo, "rev-list", "--left-right", "--count", "HEAD...@{u}")
    ahead = behind = 0
    if rc == 0 and lr:
        ahead, behind = (int(x) for x in lr.split())
    print(f"Nhanh: {branch} | ahead {ahead} / behind {behind} so voi origin")
    if behind:
        level = max(level, 1)
        notes.append(f"Origin da co {behind} commit moi. Phai fetch + rebase truoc khi push.")

    # 2. File dang sua do trong cay lam viec nay
    wip = status_paths(repo)
    others_wip = wip - mine if mine else wip
    print(f"File sua do trong thu muc nay: {len(wip)}")
    if mine and others_wip:
        level = max(level, 1)
        notes.append(
            f"{len(others_wip)} file sua do KHONG thuoc session nay (cua session khac). "
            "Chi `git add` dung ten file cua minh, KHONG `git add .`."
        )
        for f in sorted(others_wip)[:8]:
            print(f"   [session khac?] {f}")

    # 3. File minh sua co bi nguoi khac doi tren origin khong (nguy co conflict)
    if mine and behind:
        _, changed, _ = git(repo, "diff", "--name-only", "HEAD...@{u}")
        clash = mine & {c.strip() for c in lines(changed)}
        if clash:
            level = max(level, 2)
            notes.append("CONFLICT NHIEU KHA NANG: file ban sua cung bi doi tren origin: " + ", ".join(sorted(clash)))

    # 4. Worktree khac cung sua cung file
    _, wts, _ = git(repo, "worktree", "list", "--porcelain")
    cur = None
    for blk in wts.split("\n\n"):
        d = {}
        for l in blk.splitlines():
            k, _, v = l.partition(" ")
            d[k] = v
        p = d.get("worktree", "").replace("\\", "/")
        if not p:
            continue
        if cur is None:
            cur = p  # muc dau tien la cay chinh
            continue
        if mine:
            there = status_paths(p)
            both = mine & there
            if both:
                level = max(level, 2)
                notes.append(f"Worktree {p} cung dang sua: " + ", ".join(sorted(both)))

    # 5. Nhanh deploy
    if branch in DEPLOY_BRANCHES:
        import os
        wf = os.path.join(repo, ".github", "workflows")
        if os.path.isdir(wf):
            hits = []
            for f in os.listdir(wf):
                try:
                    t = open(os.path.join(wf, f), encoding="utf-8", errors="replace").read()
                except OSError:
                    continue
                if "push:" in t and branch in t and ("deploy" in f.lower() or "docker" in t.lower()):
                    hits.append(f)
            if hits:
                level = max(level, 1)
                notes.append(
                    f"Push `{branch}` KICH HOAT workflow ({', '.join(hits)}) = co the DEPLOY PRODUCTION. "
                    "Xac nhan voi nguoi dung truoc khi push."
                )

    print("-" * 60)
    if not notes:
        print("AN TOAN: khong thay va cham.")
    for n in notes:
        print("*", n)
    print({0: "KET QUA: AN TOAN", 1: "KET QUA: CO CANH BAO, doc truoc khi push", 2: "KET QUA: KHONG NEN PUSH"}[level])
    return level


if __name__ == "__main__":
    sys.exit(main())
