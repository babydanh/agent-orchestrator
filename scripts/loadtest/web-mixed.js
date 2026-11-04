// k6 mixed load test for staging: people browsing public pages (Next.js SSR) while others watch live.
// Live viewers reuse viewer() from live-viewers.js (Socket.IO over long-polling).
// Required env: TARGET_HOST, MATCH_ID, BASIC_AUTH ("user:pass"). Optional: TOURNAMENT_ID, PEAK (viewers), PAGE_PEAK.
// Limitation: only the HTML of each page is fetched (no JS/CSS/images), so page numbers are a lower bound.
import http from 'k6/http';
import encoding from 'k6/encoding';
import { check, sleep } from 'k6';

export { viewer } from './live-viewers.js';

const HOST = __ENV.TARGET_HOST;
const MATCH_ID = __ENV.MATCH_ID;
const TOURNAMENT_ID = __ENV.TOURNAMENT_ID || '';
const VIEW_PEAK = parseInt(__ENV.PEAK || '100', 10);
const PAGE_PEAK = parseInt(__ENV.PAGE_PEAK || '50', 10);
const HOLD = `${parseInt(__ENV.HOLD_SECONDS || '60', 10)}s`;
const RAMP = `${parseInt(__ENV.RAMP_SECONDS || '20', 10)}s`;
const AUTH = `Basic ${encoding.b64encode(__ENV.BASIC_AUTH || '')}`;

const rampTo = (peak) => [
  { duration: RAMP, target: Math.max(1, Math.round(peak / 4)) },
  { duration: RAMP, target: Math.max(1, Math.round(peak / 2)) },
  { duration: RAMP, target: Math.max(1, peak) },
  { duration: HOLD, target: Math.max(1, peak) },
  { duration: '10s', target: 0 },
];

const PAGES = ['page_home', 'page_tournaments', 'page_matches', 'page_tournament_detail', 'page_live'];
const pageThresholds = Object.fromEntries(PAGES.map((name) => [`http_req_duration{name:${name}}`, ['p(95)<3000']]));

export const options = {
  scenarios: {
    viewers: {
      executor: 'ramping-vus',
      exec: 'viewer',
      startVUs: 0,
      stages: rampTo(VIEW_PEAK),
      gracefulRampDown: '60s',
      gracefulStop: '60s',
    },
    pages: {
      executor: 'ramping-vus',
      exec: 'pages',
      startVUs: 0,
      stages: rampTo(PAGE_PEAK),
      gracefulRampDown: '30s',
      gracefulStop: '30s',
    },
  },
  thresholds: {
    // Protect staging: stop when pages mostly fail or joins fail. Latency thresholds only report.
    'http_req_failed{scenario:pages}': [{ threshold: 'rate<0.2', abortOnFail: true, delayAbortEval: '30s' }],
    live_join_ok: [{ threshold: 'rate>0.95', abortOnFail: true, delayAbortEval: '40s' }],
    'http_req_duration{scenario:pages}': ['p(95)<3000'],
    ...pageThresholds,
  },
};

const think = () => 2 + Math.random() * 4; // seconds a person stays on a page

export function pages() {
  const headers = { Authorization: AUTH };
  const open = (path, name) => {
    const res = http.get(`https://${HOST}${path}`, { headers, tags: { name }, timeout: '30s' });
    check(res, { [`${name} 200`]: (r) => r.status === 200 });
    sleep(think());
  };

  open('/', 'page_home');
  open('/tournaments', 'page_tournaments');
  open('/matches', 'page_matches');
  if (TOURNAMENT_ID) open(`/tournaments/${TOURNAMENT_ID}`, 'page_tournament_detail');
  open(`/live/${MATCH_ID}`, 'page_live');
}
