#!/usr/bin/env python3
"""Turn `flutter test --reporter json` + the media of app_ui_runner.py into an allure-results folder.

One <uuid>-result.json per test: name (the Vietnamese title), labels (tc, epic, feature, tag, suite), steps (lines printed as
`[[STEP]] text`), attachments (video/mp4 per recorded segment, the last-screen png, the printed log) and status.

Usage: flutter_to_allure.py --json flutter.json --media DIR [--results allure-results] [--epoch-ms N]
`DIR` holds media.json, videos/ and screenshots/ (the --out of app_ui_runner.py).
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import uuid

TC = re.compile(r"TC-[A-Z0-9]+-([A-Z0-9]+)-(\d+[a-z]?)")
STEP = "[[STEP]] "


def load_events(path):
    out = []
    for line in open(path, encoding="utf-8", errors="replace"):
        try:
            out.append(json.loads(line))
        except ValueError:
            pass
    return out


def convert(events, media, media_dir, results, epoch_ms):
    os.makedirs(results, exist_ok=True)
    tests = {}
    for e in events:
        t = e.get("type")
        if t == "testStart":
            test = e["test"]
            tests[test["id"]] = {"name": test["name"], "start": e["time"], "steps": [], "logs": [], "errors": [],
                                 "skip": bool(test.get("metadata", {}).get("skip")), "hidden": test["name"].startswith("loading ")}
        elif t == "print" and e.get("testID") in tests:
            tt, msg = tests[e["testID"]], e.get("message", "")
            if msg.startswith(STEP):
                tt["steps"].append((msg[len(STEP):], e["time"]))
            elif not msg.startswith("[[SHOT]]"):
                tt["logs"].append(msg)
        elif t == "error" and e.get("testID") in tests:
            tests[e["testID"]]["errors"].append((e.get("error", ""), e.get("stackTrace", "")))
        elif t == "testDone" and e.get("testID") in tests:
            tt = tests[e["testID"]]
            tt["end"], tt["result"], tt["skipped"] = e["time"], e.get("result"), bool(e.get("skipped"))
            tt["hidden"] = tt["hidden"] or bool(e.get("hidden"))
    written = 0
    for tid, tt in tests.items():
        if tt["hidden"] or "end" not in tt:
            continue
        m = TC.search(tt["name"])
        code = m.group(0) if m else None
        group = m.group(1) if m else "OTHER"
        title = tt["name"][m.end():].strip() if m else tt["name"]
        status = "skipped" if (tt["skipped"] or tt["skip"]) else ("passed" if tt["result"] == "success" else "failed")
        base = epoch_ms
        steps = []
        marks = tt["steps"]
        for i, (text, ts) in enumerate(marks):
            stop = marks[i + 1][1] if i + 1 < len(marks) else tt["end"]
            steps.append({"name": text, "status": "passed", "stage": "finished", "start": base + ts, "stop": base + stop})
        if status == "failed" and steps:
            steps[-1]["status"] = "failed"
        attachments = []
        info = media.get("tests", {}).get(str(tid), {})
        for n, v in enumerate(info.get("videos", []), 1):
            src = os.path.join(media_dir, "videos", v)
            if os.path.exists(src):
                dst = f"{uuid.uuid4()}-attachment.mp4"
                shutil.copy(src, os.path.join(results, dst))
                attachments.append({"name": f"Video toàn luồng (phần {n})", "source": dst, "type": "video/mp4"})
        shot = info.get("screenshot")
        if shot and os.path.exists(os.path.join(media_dir, "screenshots", shot)):
            dst = f"{uuid.uuid4()}-attachment.png"
            shutil.copy(os.path.join(media_dir, "screenshots", shot), os.path.join(results, dst))
            attachments.append({"name": "Màn hình cuối", "source": dst, "type": "image/png"})
        log = "\n".join(tt["logs"])
        if log:
            dst = f"{uuid.uuid4()}-attachment.txt"
            open(os.path.join(results, dst), "w", encoding="utf-8").write(log)
            attachments.append({"name": "Log của test", "source": dst, "type": "text/plain"})
        result = {
            "uuid": str(uuid.uuid4()),
            "historyId": hashlib.md5((code or tt["name"]).encode()).hexdigest(),
            "fullName": tt["name"],
            "name": f"{code} {title}" if code else title,
            "status": status,
            "stage": "finished",
            "start": base + tt["start"],
            "stop": base + tt["end"],
            "steps": steps,
            "attachments": attachments,
            "labels": [
                {"name": "epic", "value": "VNCare Mobile UI E2E (emulator Android API 34)"},
                {"name": "feature", "value": group},
                {"name": "suite", "value": group},
                {"name": "framework", "value": "flutter integration_test"},
                {"name": "language", "value": "dart"},
            ] + ([{"name": "tc", "value": code}, {"name": "tag", "value": code}] if code else []),
        }
        if status == "failed":
            err = tt["errors"][0] if tt["errors"] else ("test failed", "")
            result["statusDetails"] = {"message": err[0][:2000], "trace": err[1][:6000]}
        with open(os.path.join(results, f"{result['uuid']}-result.json"), "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False)
        written += 1
    with open(os.path.join(results, "environment.properties"), "w", encoding="utf-8") as f:
        f.write("Platform=Android emulator API 34 (x86_64, google_apis)\nApi=apps/api e2e-main + PostgreSQL 17\nRunner=GitHub Actions ubuntu-latest\n")
    return written


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", required=True)
    ap.add_argument("--media", required=True)
    ap.add_argument("--results", default="allure-results")
    ap.add_argument("--epoch-ms", type=int, default=None)
    a = ap.parse_args()
    media = {}
    mp = os.path.join(a.media, "media.json")
    if os.path.exists(mp):
        media = json.load(open(mp, encoding="utf-8"))
    epoch = a.epoch_ms if a.epoch_ms is not None else media.get("t0_epoch_ms", 0)
    n = convert(load_events(a.json), media, a.media, a.results, epoch)
    print(f"wrote {n} allure results to {a.results}")
    return 0 if n else 1


if __name__ == "__main__":
    raise SystemExit(main())
