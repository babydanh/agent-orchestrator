// k6 load test for the public live-viewer path of Sporto staging.
// Viewers speak Engine.IO v4 / Socket.IO (long-polling) to namespace /live (joinMatch), readers hit public REST.
// Required env: TARGET_HOST, MATCH_ID, BASIC_AUTH ("user:pass" of the staging gate). Never printed.
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
const RECORD_SEP = String.fromCharCode(0x1e); // Engine.IO v4 packet separator in polling bodies

const joinOk = new Rate('live_join_ok');
const joinMs = new Trend('live_join_ms', true);
const viewerSeen = new Gauge('live_viewer_count_seen');
const serverConns = new Gauge('live_server_connections');
const serverLagMs = new Trend('live_server_event_loop_lag_ms');
const wsErrors = new Counter('live_ws_errors');
const scoreEvents = new Counter('live_score_events');

// REST_ABORT=off keeps the REST p95 threshold as a pass/fail result but stops it from aborting the run,
// so the test can reach the real breaking point. Join failures still abort (protects staging).
const REST_ABORT = (__ENV.REST_ABORT || 'on') !== 'off';

const RAMP = `${parseInt(__ENV.RAMP_SECONDS || '20', 10)}s`;
const rampTo = (peak) => [
  { duration: RAMP, target: Math.max(1, Math.round(peak / 4)) },
  { duration: RAMP, target: Math.max(1, Math.round(peak / 2)) },
  { duration: RAMP, target: Math.max(1, peak) },
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
      stages: rampTo(Math.min(20, Math.max(2, Math.round(PEAK / 10)))), // REST readers stay light per shard
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    // Stop the run early when the REST path degrades or joins fail, to protect staging.
    'http_req_duration{scenario:readers}': [
      REST_ABORT
        ? { threshold: 'p(95)<1000', abortOnFail: true, delayAbortEval: '30s' }
        : 'p(95)<1000',
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

// Staging blocks WebSocket upgrade (Basic Auth gate), so its web client uses long-polling only
// (see Web src/lib/socket.ts). Viewers therefore speak Engine.IO v4 over HTTP long-polling,
// exactly like a real staging browser.
function handleEvent(packet, state, startedAt) {
  const evt = parseEvent(packet);
  if (!evt) return;
  const [name, payload] = evt;
  if (name === 'joined' && !state.joined) {
    state.joined = true;
    joinOk.add(true);
    joinMs.add(Date.now() - startedAt);
  } else if (name === 'exception') {
    state.failed = true;
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
}

export function viewer() {
  const base = `https://${HOST}/socket.io/?EIO=4&transport=polling`;
  const reqParams = (name) => ({
    headers: {
      Authorization: AUTH,
      Origin: `https://${HOST}`,
      'Content-Type': 'text/plain;charset=UTF-8',
    },
    tags: { name, type: 'poll' },
    timeout: '40s',
  });
  const startedAt = Date.now();
  const state = { joined: false, failed: false };

  const hs = http.get(base, reqParams('eio_handshake'));
  const handshakeOk = check(hs, { 'handshake 200': (r) => r.status === 200 && r.body.startsWith('0') });
  if (!handshakeOk) {
    joinOk.add(false);
    wsErrors.add(1);
    sleep(1);
    return;
  }

  const url = `${base}&sid=${JSON.parse(hs.body.slice(1)).sid}`;
  const send = (packet) => http.post(url, packet, reqParams('eio_send'));
  send(`40${NS},`);

  let sentJoin = false;
  const endAt = Date.now() + SESSION_MS + Math.floor(Math.random() * 5000);
  while (Date.now() < endAt && !state.failed) {
    const res = http.get(url, reqParams('eio_poll')); // long-poll: blocks until a packet or ping
    if (res.status !== 200) {
      wsErrors.add(1);
      break;
    }
    for (const packet of res.body.split(RECORD_SEP)) {
      if (packet === '2') send('3'); // Engine.IO ping -> pong
      else if (packet.startsWith(`40${NS},`) && !sentJoin) {
        sentJoin = true;
        send(`42${NS},["joinMatch","${MATCH_ID}"]`);
      } else if (packet.startsWith(`44${NS},`)) wsErrors.add(1);
      else if (packet.startsWith(`42${NS},`)) handleEvent(packet, state, startedAt);
    }
  }

  if (!state.joined) joinOk.add(false);
  send('1'); // polite Engine.IO close
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
