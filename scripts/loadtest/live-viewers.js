// k6 load test for the public live-viewer path of Sporto staging.
// Viewers speak Engine.IO v4 / Socket.IO to namespace /live (joinMatch), readers hit public REST.
// Required env: TARGET_HOST, MATCH_ID, BASIC_AUTH ("user:pass" of the staging gate). Never printed.
import ws from 'k6/ws';
import http from 'k6/http';
import encoding from 'k6/encoding';
import { check, sleep } from 'k6';
import { Counter, Gauge, Rate, Trend } from 'k6/metrics';

const HOST = __ENV.TARGET_HOST;
const MATCH_ID = __ENV.MATCH_ID;
const PEAK = parseInt(__ENV.PEAK || '100', 10);
const HOLD = `${parseInt(__ENV.HOLD_SECONDS || '60', 10)}s`;
const SESSION_MS = 45000; // one socket session; shorter than gracefulRampDown
const AUTH = `Basic ${encoding.b64encode(__ENV.BASIC_AUTH || '')}`;
const NS = '/live';

const joinOk = new Rate('live_join_ok');
const joinMs = new Trend('live_join_ms', true);
const viewerSeen = new Gauge('live_viewer_count_seen');
const serverConns = new Gauge('live_server_connections');
const serverLagMs = new Trend('live_server_event_loop_lag_ms');
const wsErrors = new Counter('live_ws_errors');
const scoreEvents = new Counter('live_score_events');

const rampTo = (peak) => [
  { duration: '20s', target: Math.max(1, Math.round(peak / 4)) },
  { duration: '20s', target: Math.max(1, Math.round(peak / 2)) },
  { duration: '20s', target: Math.max(1, peak) },
  { duration: HOLD, target: Math.max(1, peak) },
  { duration: '10s', target: 0 },
];

export const options = {
  scenarios: {
    viewers: {
      executor: 'ramping-vus',
      exec: 'viewer',
      startVUs: 0,
      stages: rampTo(PEAK),
      gracefulRampDown: '60s',
      gracefulStop: '60s',
    },
    readers: {
      executor: 'ramping-vus',
      exec: 'reader',
      startVUs: 0,
      stages: rampTo(Math.max(2, Math.round(PEAK / 10))),
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    // Stop the run early when the REST path degrades or joins fail, to protect staging.
    'http_req_duration{scenario:readers}': [
      { threshold: 'p(95)<1000', abortOnFail: true, delayAbortEval: '30s' },
    ],
    live_join_ok: [{ threshold: 'rate>0.95', abortOnFail: true, delayAbortEval: '40s' }],
    live_join_ms: ['p(95)<2000'],
    checks: ['rate>0.95'],
  },
};

// Messages look like: 42/live,["event", payload]
function parseEvent(msg) {
  const body = msg.slice(msg.indexOf(',') + 1);
  try {
    const arr = JSON.parse(body);
    return Array.isArray(arr) ? arr : null;
  } catch (_) {
    return null;
  }
}

function asObject(payload) {
  if (typeof payload === 'string') {
    try {
      return JSON.parse(payload);
    } catch (_) {
      return {};
    }
  }
  return payload && typeof payload === 'object' ? payload : {};
}

export function viewer() {
  const url = `wss://${HOST}/socket.io/?EIO=4&transport=websocket`;
  const params = { headers: { Authorization: AUTH, Origin: `https://${HOST}` } };
  const startedAt = Date.now();
  let joined = false;

  const res = ws.connect(url, params, (socket) => {
    socket.on('message', (msg) => {
      if (msg === '2') return socket.send('3'); // Engine.IO ping -> pong
      if (msg.startsWith('0{')) return socket.send(`40${NS},`);
      if (msg.startsWith(`40${NS},`)) return socket.send(`42${NS},["joinMatch","${MATCH_ID}"]`);
      if (msg.startsWith(`44${NS},`)) {
        wsErrors.add(1);
        return;
      }
      if (!msg.startsWith(`42${NS},`)) return;

      const evt = parseEvent(msg);
      if (!evt) return;
      const [name, payload] = evt;
      if (name === 'joined' && !joined) {
        joined = true;
        joinOk.add(true);
        joinMs.add(Date.now() - startedAt);
      } else if (name === 'exception') {
        joinOk.add(false);
        wsErrors.add(1);
      } else if (name === 'viewer:count') {
        const count = asObject(payload).viewerCount;
        if (typeof count === 'number') viewerSeen.add(count);
      } else if (name === 'system:metrics') {
        const m = asObject(payload);
        if (typeof m.connections === 'number') serverConns.add(m.connections);
        if (typeof m.eventLoopLag === 'number') serverLagMs.add(m.eventLoopLag);
      } else if (name === 'score:update' || name === 'match:status') {
        scoreEvents.add(1);
      }
    });
    socket.on('error', () => wsErrors.add(1));
    socket.setTimeout(() => {
      if (!joined) joinOk.add(false);
      socket.close();
    }, SESSION_MS + Math.floor(Math.random() * 5000));
  });

  check(res, { 'ws upgraded (101)': (r) => r && r.status === 101 });
  sleep(1);
}

export function reader() {
  const headers = { Authorization: AUTH };
  const detail = http.get(`https://${HOST}/api/v1/matches/${MATCH_ID}`, {
    headers,
    tags: { name: 'match_detail' },
  });
  const cats = http.get(`https://${HOST}/api/v1/categories`, {
    headers,
    tags: { name: 'categories' },
  });
  check(detail, { 'match detail 200': (r) => r.status === 200 });
  check(cats, { 'categories 200': (r) => r.status === 200 });
  sleep(1 + Math.random() * 2);
}
