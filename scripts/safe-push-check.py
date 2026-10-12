#!/usr/bin/env python3
"""Kiem tra va cham truoc khi commit/push khi nhieu session lam chung mot repo.

CHI DOC, khong sua repo. Dung:
    python safe-push-check.py <thu-muc-repo> [file1 file2 ...]

Neu truyen danh sach file: day la cac file SESSION NAY sua. Script bao file nao
cung dang bi session khac sua do (cung cay lam viec hoac worktree khac) va file nao
da bi nguoi khac doi tren origin.

Exit code: 0 = an toan, 1 = co canh bao can xem, 2 = KHONG nen push.
"""
import os
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


class GateError(Exception):
    """Git that bai: cong an toan phai DONG (exit 2), tuyet doi khong coi la 'sach'."""

def status_paths(repo):
    """Moi file dang thay doi trong cay lam viec: sua, da stage, FILE MOI CHUA ADD, doi ten.

    Dung `-z` (tach bang NUL) nen ten co dau cach / ky tu dac biet KHONG bi quote hay escape.
    Moi record: 'XY path'. Voi rename/copy (X hoac Y la R/C) record ke tiep la duong dan CU.
    """
    r = subprocess.run(
        ["git", "-C", repo, "status", "--porcelain=v1", "-z", "--untracked-files=all"],
        capture_output=True, timeout=60,
    )
    if r.returncode != 0:
        raise GateError((r.stderr or b"").decode("utf-8", errors="replace").strip() or f"git status exit {r.returncode}")
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
    rc, _, err = git(repo, "fetch", "-q", "origin")
    if rc != 0:
        level = 2
        notes.append(f"`git fetch origin` that bai: {err or 'git loi'}. Khong biet origin co gi moi, coi nhu KHONG an toan.")

    # 1. Chon MOC so sanh: upstream cua nhanh; nhanh moi chua push thi dung nhanh mac dinh cua origin.
    ref = ""
    for cand in ("@{u}", "refs/remotes/origin/HEAD", "refs/remotes/origin/main", "refs/remotes/origin/master"):
        rc, sha, _ = git(repo, "rev-parse", "--verify", "-q", cand)
        if rc == 0 and sha:
            ref = cand
            break
    ref_sha = ""
    ahead = behind = 0
    if not ref:
        level = 2
        notes.append("KHONG co moc so sanh nao (khong co upstream, origin/HEAD, origin/main, origin/master). Coi nhu KHONG an toan.")
    else:
        rc, ref_sha, _ = git(repo, "rev-parse", ref)
        rc, lr, err = git(repo, "rev-list", "--left-right", "--count", f"HEAD...{ref}")
        if rc != 0 or len(lr.split()) != 2:
            level = 2
            notes.append(f"KHONG so sanh duoc voi `{ref}`: {err or lr!r}. Coi nhu KHONG an toan.")
        else:
            ahead, behind = (int(x) for x in lr.split())
        if ref != "@{u}":
            level = max(level, 1)
            notes.append(f"Nhanh `{branch}` chua co upstream: so voi `{ref}` thay the. Push dau tien se tao upstream.")
    print(f"Nhanh: {branch} | ahead {ahead} / behind {behind} so voi origin")
    if behind:
        level = max(level, 1)
        notes.append(f"Origin da co {behind} commit moi. Phai fetch + rebase truoc khi push.")

    # 2. File dang sua do trong cay lam viec nay
    try:
        wip = status_paths(repo)
    except GateError as e:
        print(f"KHONG doc duoc trang thai cay lam viec: {e}")
        print("KET QUA: KHONG NEN PUSH (cong dong khi khong chac chan)")
        return 2
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
        rc, changed, err = git(repo, "diff", "--name-only", f"HEAD...{ref}")
        if rc != 0:
            level = 2
            notes.append(f"KHONG so sanh duoc file voi origin: {err or 'git loi'}. Coi nhu KHONG an toan.")
            changed = ""
        clash = mine & {c.strip() for c in lines(changed)}
        if clash:
            level = max(level, 2)
            notes.append("CONFLICT NHIEU KHA NANG: file ban sua cung bi doi tren origin: " + ", ".join(sorted(clash)))

    # 4. Worktree KHAC cung sua cung file: ca file dang sua do LAN commit da tao nhung chua len origin.
    rc, wts, err = git(repo, "worktree", "list", "--porcelain")
    if rc != 0:
        level = 2
        notes.append(f"KHONG liet ke duoc worktree: {err or 'git loi'}. Coi nhu KHONG an toan.")
        wts = ""
    rc, here, err = git(repo, "rev-parse", "--show-toplevel")
    me = os.path.normcase(os.path.realpath(here if rc == 0 and here else repo))
    base = ref_sha  # moc so sanh dung chung (xem tren)
    for blk in wts.split("\n\n"):
        d = {}
        for l in blk.splitlines():
            k, _, v = l.partition(" ")
            d[k] = v
        p = d.get("worktree", "")
        if not p or os.path.normcase(os.path.realpath(p)) == me:
            continue  # bo qua CHINH cay dang chay (khong phai 'entry dau tien')
        label = d.get("branch", "").replace("refs/heads/", "") or "(detached)"
        if not mine:
            continue
        theirs = set()
        try:
            theirs |= status_paths(p)  # file dang sua do (staged, unstaged, untracked, rename)
        except GateError as e:
            level = 2
            notes.append(f"KHONG doc duoc trang thai worktree {p}: {e}. Coi nhu KHONG an toan.")
            continue
        head = d.get("HEAD", "")
        if base and head:
            # commit cua worktree do chua co tren upstream cua minh: file ho da commit
            rc, mb, _ = git(repo, "merge-base", base, head)
            if rc != 0 or not mb:
                level = 2
                notes.append(f"KHONG tim duoc merge-base voi nhanh `{label}` ({p}). Coi nhu KHONG an toan.")
                continue
            rc, committed, err = git(repo, "diff", "--name-only", f"{mb}..{head}")
            if rc != 0:
                level = 2
                notes.append(f"KHONG so sanh duoc commit cua nhanh `{label}`: {err or 'git loi'}. Coi nhu KHONG an toan.")
                continue
            theirs |= {c.strip() for c in lines(committed)}
        elif head:
            level = max(level, 1)
            notes.append(f"Khong co upstream de so commit cua nhanh `{label}`; chi so duoc file dang sua do.")
        both = mine & theirs
        if both:
            level = max(level, 2)
            notes.append(f"Nhanh/worktree `{label}` ({p}) cung dang sua hoac da commit: " + ", ".join(sorted(both)))

    # 5. Nhanh deploy
    if branch in DEPLOY_BRANCHES:
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
