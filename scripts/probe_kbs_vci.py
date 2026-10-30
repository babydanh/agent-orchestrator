"""Throwaway spike: can a GitHub runner IP reach the KBS / VCI price boards?

Prints only status codes, sizes, counts and public prices (no secrets are involved).
Writes the live symbol list to symbols.txt so the workflow can upload it.
"""
import gzip
import itertools
import json
import string
import sys
import time
import urllib.request

KBS = "https://kbbuddywts.kbsec.com.vn/iis-server/investment/stock/iss"
VCI = "https://trading.vietcap.com.vn/api/price/symbols/getList"
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124 Safari/537.36"
REQUIRED = ["TT", "TV", "FB", "FS", "FO", "FR", "PTQ", "PTV", "B1", "B2", "B3",
            "S1", "S2", "S3", "RE", "CL", "FL", "SB", "EX", "t"]
SAMPLE = ["FPT", "VCB", "HPG"]
CHUNK = 1500


def post(url, payload, extra=None):
    req = urllib.request.Request(
        url, data=json.dumps(payload).encode(), method="POST",
        headers={"Content-Type": "application/json", "User-Agent": UA, **(extra or {})})
    t0 = time.time()
    with urllib.request.urlopen(req, timeout=30) as r:
        raw = r.read()
        if r.headers.get("Content-Encoding") == "gzip" or raw[:2] == b"\x1f\x8b":
            raw = gzip.decompress(raw)
        return r.status, len(raw), round(time.time() - t0, 2), json.loads(raw)


def probe_kbs():
    codes = ["".join(c) for c in itertools.product(string.ascii_uppercase, repeat=3)]
    live = {}
    for i in range(0, len(codes), CHUNK):
        status, size, secs, rows = post(KBS, {"code": ",".join(codes[i:i + CHUNK])})
        hit = [r for r in rows if "TT" in r]
        live.update({r["SB"]: r for r in hit})
        print(f"KBS chunk {i // CHUNK}: status={status} bytes={size} secs={secs} rows={len(rows)} live={len(hit)}")
        time.sleep(1)
    print(f"KBS live symbols total: {len(live)}")
    missing = {f for r in live.values() for f in REQUIRED if f not in r}
    print(f"KBS required fields missing in some rows: {sorted(missing) or 'none'}")
    for s in SAMPLE:
        r = live.get(s, {})
        print(f"KBS {s}: " + " ".join(f"{k}={r.get(k)}" for k in ["EX", "CP", "RE", "TT", "TV", "FB", "FS", "IT"]))
    open("symbols.txt", "w").write("\n".join(sorted(f"{s},{r.get('EX')}" for s, r in live.items())))
    return live


def probe_vci():
    status, size, secs, data = post(
        VCI, {"symbols": SAMPLE},
        {"Origin": "https://trading.vietcap.com.vn", "Referer": "https://trading.vietcap.com.vn/"})
    print(f"VCI: status={status} bytes={size} secs={secs} type={type(data).__name__} len={len(data)}")
    first = data[0] if isinstance(data, list) and data else {}
    print("VCI first row keys:", sorted(first)[:40] if isinstance(first, dict) else first)


def main():
    ok = True
    for name, fn in (("KBS", probe_kbs), ("VCI", probe_vci)):
        try:
            fn()
        except Exception as e:  # report the failure kind, keep going to the other source
            ok = False
            print(f"{name} FAILED: {type(e).__name__}: {e}")
    sys.exit(0 if ok else 1)


main()
