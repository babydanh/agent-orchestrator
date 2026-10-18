"""Chia spec Playwright vào N shard cân theo thời gian chạy đã đo (giây), in danh sách file của một shard.

  python shard_specs.py --root test/e2e --shard 2/4 [--durations spec-durations.json]

`--shard` của Playwright chia theo SỐ TEST và giữ thứ tự chữ cái, nên các file nặng (vòng đời giải, nhập danh sách)
dồn chung một shard. Ở đây xếp file nặng trước, mỗi file vào shard đang nhẹ nhất (LPT). Mỗi spec nằm đúng một
shard; spec mới chưa có số đo tính bằng trung vị. Trong một shard giữ thứ tự chữ cái như khi chạy một máy.
"""
import argparse
import json
import os
import statistics
import sys

DEFAULT_DURATIONS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec-durations.json")


def list_specs(root):
    """Mọi *.spec.ts dưới root (kể cả thư mục con), đường dẫn dạng `test/e2e/...` dùng dấu `/`."""
    out = []
    for dirpath, _, names in os.walk(root):
        for name in names:
            if name.endswith(".spec.ts"):
                out.append(os.path.relpath(os.path.join(dirpath, name)).replace("\\", "/"))
    return sorted(out)


def split(specs, durations, total):
    known = [durations[s] for s in specs if s in durations]
    fallback = statistics.median(known) if known else 1.0
    weight = {s: durations.get(s, fallback) for s in specs}
    buckets = [[] for _ in range(total)]
    loads = [0.0] * total
    for spec in sorted(specs, key=lambda s: (-weight[s], s)):
        i = min(range(total), key=lambda k: (loads[k], k))
        buckets[i].append(spec)
        loads[i] += weight[spec]
    return [sorted(b) for b in buckets], loads


def parse_shard(text):
    try:
        current, total = (int(x) for x in text.split("/"))
    except ValueError:
        raise argparse.ArgumentTypeError(f"--shard phải dạng i/N, nhận '{text}'")
    if not 1 <= current <= total:
        raise argparse.ArgumentTypeError(f"--shard {text}: cần 1 <= i <= N")
    return current, total


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--shard", required=True, type=parse_shard)
    ap.add_argument("--durations", default=DEFAULT_DURATIONS)
    a = ap.parse_args()
    specs = list_specs(a.root)
    if not specs:
        print(f"không có spec nào dưới {a.root}", file=sys.stderr)
        return 2
    with open(a.durations, encoding="utf-8") as f:
        durations = json.load(f)["specs"]
    current, total = a.shard
    buckets, loads = split(specs, durations, total)
    print(f"shard {current}/{total}: {len(buckets[current - 1])}/{len(specs)} spec, ước tính "
          f"{loads[current - 1] / 60:.1f} phút (các shard: {', '.join(f'{x / 60:.1f}' for x in loads)})", file=sys.stderr)
    print("\n".join(buckets[current - 1]))
    return 0


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    sys.exit(main())
