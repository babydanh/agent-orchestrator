#!/usr/bin/env python3
"""Run `flutter test` (integration_test on an Android emulator) and record ONE video per test.

The runner follows the JSON reporter of `flutter test` live: when a test starts it starts `adb shell screenrecord`
(screenrecord stops at 180 s, so a test is recorded in segments of at most --segment seconds), when the test ends it stops
the recording, pulls the segments and takes a screenshot of the last screen. It writes:

  <out>/flutter.json     raw reporter lines (input of flutter_to_allure.py)
  <out>/media.json       {"t0_epoch_ms": .., "tests": {"<testID>": {"videos": [..], "screenshot": ".."}}}
  <out>/videos/<testID>-<n>.mp4, <out>/screenshots/<testID>.png

Usage: app_ui_runner.py --out DIR [--device emulator-5554] [--segment 170] -- flutter test --no-pub -d emulator-5554 FILE ...
The runner adds `--reporter json` itself. Exit code is the one of flutter test.
"""
import argparse
import json
import os
import subprocess
import sys
import threading
import time


def adb(device, *args, **kw):
    return subprocess.run(["adb", "-s", device, *args], capture_output=True, **kw)


class Recorder:
    """Records one test as consecutive screenrecord segments."""

    def __init__(self, device, test_id, out_dir, segment, size):
        self.device, self.test_id, self.out_dir = device, test_id, out_dir
        self.segment, self.size = segment, size
        self.stop_flag = threading.Event()
        self.files = []
        self.thread = threading.Thread(target=self._loop, daemon=True)
        self.thread.start()

    def _loop(self):
        n = 0
        while not self.stop_flag.is_set():
            n += 1
            remote = f"/sdcard/e2e_{self.test_id}_{n}.mp4"
            cmd = ["adb", "-s", self.device, "shell", "screenrecord", "--time-limit", str(self.segment),
                   "--bit-rate", "2500000", "--size", self.size, remote]
            proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            while proc.poll() is None and not self.stop_flag.is_set():
                time.sleep(0.2)
            if proc.poll() is None:
                # SIGINT makes screenrecord finish the mp4 properly.
                adb(self.device, "shell", "pkill", "-2", "screenrecord")
                try:
                    proc.wait(timeout=20)
                except subprocess.TimeoutExpired:
                    proc.kill()
            time.sleep(1.0)
            local = os.path.join(self.out_dir, "videos", f"{self.test_id}-{n}.mp4")
            adb(self.device, "pull", remote, local)
            adb(self.device, "shell", "rm", "-f", remote)
            if os.path.exists(local) and os.path.getsize(local) > 1000:
                self.files.append(os.path.basename(local))

    def stop(self):
        self.stop_flag.set()
        self.thread.join(timeout=90)
        return self.files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--device", default="emulator-5554")
    ap.add_argument("--segment", type=int, default=170)
    ap.add_argument("--size", default="360x800")
    ap.add_argument("cmd", nargs=argparse.REMAINDER)
    a = ap.parse_args()
    cmd = a.cmd[1:] if a.cmd and a.cmd[0] == "--" else a.cmd
    if not cmd:
        ap.error("missing flutter test command after --")
    os.makedirs(os.path.join(a.out, "videos"), exist_ok=True)
    os.makedirs(os.path.join(a.out, "screenshots"), exist_ok=True)
    media = {"t0_epoch_ms": int(time.time() * 1000), "tests": {}}
    names, rec, synced = {}, None, False
    shot_taken = set()
    raw = open(os.path.join(a.out, "flutter.json"), "w", encoding="utf-8")
    proc = subprocess.Popen(cmd + ["--reporter", "json"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, encoding="utf-8", errors="replace", bufsize=1)
    for line in proc.stdout:
        line = line.rstrip("\n")
        try:
            e = json.loads(line)
        except ValueError:
            print(line, flush=True)  # build output, Gradle, flutter tool messages
            continue
        raw.write(line + "\n")
        raw.flush()
        if not synced and isinstance(e.get("time"), int):
            # the reporter counts milliseconds from the start of its run: anchor them to the wall clock once
            media["t0_epoch_ms"] = int(time.time() * 1000) - e["time"]
            synced = True
        t = e.get("type")
        if t == "testStart":
            test = e["test"]
            names[test["id"]] = test["name"]
            if test["name"].startswith("loading ") or test.get("metadata", {}).get("skip"):
                continue
            print(f"::group::START {test['name']}", flush=True)
            rec = Recorder(a.device, test["id"], a.out, a.segment, a.size)
            media["tests"][str(test["id"])] = {"videos": [], "screenshot": None}
        elif t == "print":
            msg = e.get("message", "")
            print(f"    {msg}", flush=True)
            # The test prints [[SHOT]] while its last screen is still up (after the body, before teardown of the app).
            if msg.startswith("[[SHOT]]") and rec is not None and str(rec.test_id) == str(e.get("testID")):
                shot = os.path.join(a.out, "screenshots", f"{e['testID']}.png")
                with open(shot, "wb") as f:
                    f.write(adb(a.device, "exec-out", "screencap", "-p").stdout)
                shot_taken.add(str(e["testID"]))
        elif t == "error":
            print(f"    ERROR: {e.get('error', '')[:600]}", flush=True)
        elif t == "testDone" and not e.get("hidden"):
            tid = str(e["testID"])
            if rec is not None and str(rec.test_id) == tid:
                shot = os.path.join(a.out, "screenshots", f"{tid}.png")
                if tid not in shot_taken:
                    with open(shot, "wb") as f:
                        f.write(adb(a.device, "exec-out", "screencap", "-p").stdout)
                videos = rec.stop()
                rec = None
                media["tests"][tid] = {"videos": videos, "screenshot": os.path.basename(shot)}
            print(f"::endgroup::\n{e.get('result')}{' (skipped)' if e.get('skipped') else ''}: {names.get(e['testID'])}", flush=True)
    rc = proc.wait()
    if rec is not None:
        rec.stop()
    raw.close()
    with open(os.path.join(a.out, "media.json"), "w", encoding="utf-8") as f:
        json.dump(media, f)
    print(f"flutter test exit code {rc}", flush=True)
    return rc


if __name__ == "__main__":
    sys.exit(main())
