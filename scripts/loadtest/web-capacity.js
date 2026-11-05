// k6 capacity test for the Web's prerendered public pages, scored like the $12 Server Challenge
// (https://github.com/arjaythedev/twelve-dollar-server-challenge, bench/load.js):
// one virtual user (VU) = one person who opens a page, reads for a few seconds and opens another,
// roughly one request every ~10 s. A step passes when p95 < 500 ms, p99 < 1 s and under 1% of requests fail.
// Env: BASE_URL (default http://127.0.0.1:3000), VUS, RAMP_UP (default 30s), HOLD (default 90s),
//      PATHS (comma separated, default "/,/tournaments,/matches").
// Limitation: only the HTML of each page is fetched (no JS/CSS/images), so the numbers are an upper bound.
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://127.0.0.1:3000';
const VUS = Number(__ENV.VUS || 500);
const PATHS = (__ENV.PATHS || '/,/tournaments,/matches').split(',').map((p) => p.trim()).filter(Boolean);

export const options = {
  discardResponseBodies: true, // keeps k6 cheap; latency still covers the full download
  scenarios: {
    users: {
      executor: 'ramping-vus',
      stages: [
        { duration: __ENV.RAMP_UP || '30s', target: VUS },
        { duration: __ENV.HOLD || '90s', target: VUS },
        { duration: '10s', target: 0 },
      ],
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
  summaryTrendStats: ['avg', 'med', 'p(95)', 'p(99)', 'max'],
};

const between = (lo, hi) => lo + Math.random() * (hi - lo);
const pick = () => PATHS[Math.floor(Math.random() * PATHS.length)];

function open(path) {
  const res = http.get(`${BASE_URL}${path}`, { tags: { name: path } });
  check(res, { 'status 200': (r) => r.status === 200 });
}

export default function () {
  if (__ITER === 0) sleep(between(0, 5)); // spread VUs that start in the same tick

  open(PATHS[0]);
  sleep(between(3, 7));

  open(pick());
  sleep(between(3, 8));

  if (Math.random() < 0.5) open(pick());
  sleep(between(5, 15));
}
