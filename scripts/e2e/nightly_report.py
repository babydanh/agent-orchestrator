"""Ghi một comment kết quả E2E vào Issue cố định '[Nightly] Kết quả E2E hằng đêm'.

  python nightly_report.py <thư mục allure-report>
Env: GH_TOKEN, JOB_STATUS, RUN_URL, REPO.
"""
import collections
import glob
import json
import os
import sys
import urllib.request

TITLE = '[Nightly] Kết quả E2E hằng đêm'


def summarize(report_dir):
    # Gộp theo historyId để retry không bị đếm nhiều lần; lấy lần chạy cuối của mỗi test.
    by = {}
    for f in glob.glob(os.path.join(report_dir, 'data/test-cases/*.json')):
        with open(f, encoding='utf-8') as fh:
            d = json.load(fh)
        key = d.get('historyId') or d.get('fullName') or d.get('name')
        start = (d.get('time') or {}).get('start') or 0
        if key not in by or start > by[key][0]:
            by[key] = (start, d)
    if not by:
        return 'KHÔNG có kết quả test nào (suite không chạy tới Playwright hoặc report rỗng).'
    st = collections.Counter(v[1].get('status') for v in by.values())
    return (f"{len(by)} test: pass {st.get('passed', 0)}, fail {st.get('failed', 0)}, "
            f"broken {st.get('broken', 0)}, skipped {st.get('skipped', 0)}")


def main():
    body = f"**E2E đêm** | job: `{os.environ['JOB_STATUS']}`\n\n{summarize(sys.argv[1])}\n\nRun: {os.environ['RUN_URL']}"
    repo = os.environ['REPO']
    headers = {'Authorization': 'Bearer ' + os.environ['GH_TOKEN'], 'Accept': 'application/vnd.github+json',
               'Content-Type': 'application/json', 'User-Agent': 'nightly'}

    def call(path, data=None):
        req = urllib.request.Request(f'https://api.github.com/repos/{repo}{path}', headers=headers,
                                     data=json.dumps(data).encode() if data else None, method='POST' if data else 'GET')
        return json.loads(urllib.request.urlopen(req).read().decode())

    issues = call('/issues?state=open&per_page=100')
    num = next((i['number'] for i in issues if i['title'] == TITLE and 'pull_request' not in i), None)
    if num is None:
        num = call('/issues', {'title': TITLE, 'body': 'Issue cố định: mỗi đêm workflow tự thêm một comment kết quả.'})['number']
    call(f'/issues/{num}/comments', {'body': body})
    print('Đã ghi kết quả vào issue #', num)


if __name__ == '__main__':
    main()
