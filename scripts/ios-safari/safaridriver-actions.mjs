// Drive Mobile Safari on an iOS Simulator through Apple's safaridriver (W3C WebDriver) and tap the
// video player controls of one page. On iOS, Element Click is delivered as a single-finger touch, so
// play / unmute / fullscreen count as user gestures. Page state is read with JS only to MEASURE.
// Usage: node safaridriver-actions.mjs <url> <udid> <outDir> <actions,comma,separated>
import { spawnSync } from 'node:child_process';
import { appendFileSync, mkdirSync, writeFileSync } from 'node:fs';

const [url, udid, outDir, actionList] = process.argv.slice(2);
const DRIVER = 'http://127.0.0.1:4444';
const SUMMARY = process.env.GITHUB_STEP_SUMMARY;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
mkdirSync(outDir, { recursive: true });

// Button labels come from the Web app's vi messages (MatchReplay.*, Match.liveStream*).
const ACTIONS = {
  play: { css: ['button[aria-label="Phát"]'], expect: (b, a) => !a.paused && a.time > b.time },
  unmute: { css: ['button[aria-label="Tắt tiếng"]', 'button[aria-label="Bật tiếng sân"]'], skipIf: (s) => !s.muted, expect: (b, a) => !a.muted },
  'seek-3': { css: ['button[aria-label^="Lùi "]'], expect: (b, a) => a.time < b.time + 1 },
  'seek+3': { css: ['button[aria-label^="Tới "]'], expect: (b, a) => a.time > b.time + 2 },
  fullscreen: { css: ['button[aria-label="Toàn màn hình"]'], expect: (b, a) => a.fullscreen },
  'exit-fullscreen': { css: ['button[aria-label="Thoát toàn màn hình"]'], skipIf: (s) => !s.fullscreen, expect: (b, a) => !a.fullscreen },
};

async function wd(method, path, body, timeoutMs = 60_000) {
  const res = await fetch(DRIVER + path, {
    method, headers: { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(timeoutMs),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`${method} ${path} -> ${res.status} ${json?.value?.error ?? ''}: ${String(json?.value?.message ?? '').slice(0, 300)}`);
  return json.value;
}

async function newSession() {
  const caps = { platformName: 'iOS', browserName: 'Safari', 'safari:useSimulator': true, 'safari:deviceUDID': udid };
  for (let attempt = 1; attempt <= 2; attempt++) {
    try {
      const v = await wd('POST', '/session', { capabilities: { alwaysMatch: caps } }, 240_000);
      return v.sessionId;
    } catch (e) {
      console.log(`tạo phiên lần ${attempt} lỗi: ${e.message}`);
      if (attempt === 2) throw e;
      await sleep(15_000);
    }
  }
}

const STATE_JS = `
  const v = document.querySelector('video');
  const labels = [...document.querySelectorAll('button[aria-label]')]
    .filter((b) => { const r = b.getBoundingClientRect(); return r.width > 0 && r.height > 0; })
    .map((b) => b.getAttribute('aria-label'));
  return {
    hasVideo: !!v, time: v ? v.currentTime : -1, paused: v ? v.paused : null, muted: v ? v.muted : null,
    fullscreen: !!document.fullscreenElement || !!(v && v.webkitDisplayingFullscreen),
    fullscreenEnabled: !!document.fullscreenEnabled,
    elementRequestFullscreen: typeof document.documentElement.requestFullscreen,
    videoWebkitEnterFullscreen: v ? typeof v.webkitEnterFullscreen : 'no-video',
    labels: [...new Set(labels)].slice(0, 30),
  };`;

// Mark the first visible match so WebDriver can click exactly that element; return its rect (CSS px).
const MARK_JS = `
  document.querySelectorAll('[data-ios-test-target]').forEach((e) => e.removeAttribute('data-ios-test-target'));
  for (const sel of arguments[0]) {
    const el = [...document.querySelectorAll(sel)].find((b) => { const r = b.getBoundingClientRect(); return r.width > 0 && r.height > 0; });
    if (el) {
      el.setAttribute('data-ios-test-target', '1');
      const r = el.getBoundingClientRect();
      return { sel, rect: [r.left, r.top, r.width, r.height].map(Math.round), vw: innerWidth, vh: innerHeight, dpr: devicePixelRatio };
    }
  }
  return null;`;

// Measurement only: log where synthetic touches land and what the video does (never drives the page).
const LISTEN_JS = `
  if (window.__iosLog) return 'da gan';
  window.__iosLog = [];
  const push = (o) => window.__iosLog.push(o);
  const label = (t) => { const b = t && t.closest && t.closest('button,[role=button]'); return b ? b.getAttribute('aria-label') : (t && t.tagName); };
  for (const type of ['touchstart', 'pointerdown', 'click']) document.addEventListener(type, (e) => {
    const p = (e.touches && e.touches[0]) || (e.changedTouches && e.changedTouches[0]) || e;
    push({ type, x: Math.round(p.clientX), y: Math.round(p.clientY), target: label(e.target) });
  }, true);
  for (const type of ['play', 'playing', 'pause', 'error', 'waiting', 'webkitbeginfullscreen', 'webkitendfullscreen'])
    document.addEventListener(type, (e) => { if (e.target && e.target.tagName === 'VIDEO') push({ type }); }, true);
  document.addEventListener('fullscreenchange', () => push({ type: 'fullscreenchange', on: !!document.fullscreenElement }));
  document.addEventListener('fullscreenerror', () => push({ type: 'fullscreenerror' }));
  addEventListener('unhandledrejection', (e) => push({ type: 'rejection', reason: String(e.reason).slice(0, 160) }));
  return 'gan xong';`;
const DRAIN_JS = `const l = window.__iosLog || []; window.__iosLog = []; return l;`;

function shot(name) {
  const file = `${outDir}/${name}.png`;
  const r = spawnSync('xcrun', ['simctl', 'io', udid, 'screenshot', file], { timeout: 90_000, encoding: 'utf8' });
  return r.status === 0 ? file : `CHỤP LỖI (${r.status ?? 'quá giờ'})`;
}

async function markTarget(sid, css) {
  const mark = await wd('POST', `/session/${sid}/execute/sync`, { script: MARK_JS, args: [css] });
  if (!mark) return null;
  const el = await wd('POST', `/session/${sid}/element`, { using: 'css selector', value: '[data-ios-test-target="1"]' });
  return { ...mark, id: Object.values(el)[0] };
}

// way 1: Element Click (a single-finger touch on iOS); way 2: Perform Actions with a touch pointer on the element.
async function tap(sid, css, way) {
  const m = await markTarget(sid, css);
  if (!m) return { ok: false, how: 'không thấy nút' };
  const where = `${m.sel} rect=${m.rect.join(',')} vw=${m.vw}x${m.vh} dpr=${m.dpr}`;
  try {
    if (way === 1) await wd('POST', `/session/${sid}/element/${m.id}/click`, {});
    else await wd('POST', `/session/${sid}/actions`, { actions: [{ type: 'pointer', id: 'finger1', parameters: { pointerType: 'touch' }, actions: [
      { type: 'pointerMove', duration: 0, origin: { 'element-6066-11e4-a52e-4f735466cecf': m.id }, x: 0, y: 0 },
      { type: 'pointerDown', button: 0 }, { type: 'pause', duration: 100 }, { type: 'pointerUp', button: 0 }] }] });
    return { ok: true, how: `cách ${way}: ${where}` };
  } catch (e) {
    return { ok: false, how: `cách ${way}: ${where} lỗi: ${e.message}` };
  }
}

async function main() {
  const rows = [];
  let failed = false;
  const sid = await newSession();
  console.log(`phiên safaridriver: ${sid}`);
  const state = () => wd('POST', `/session/${sid}/execute/sync`, { script: STATE_JS, args: [] });
  try {
    await wd('POST', `/session/${sid}/url`, { url }, 120_000);
    for (let i = 0; i < 30 && !(await state()).hasVideo; i++) await sleep(2_000);
    await sleep(3_000);
    console.log(`bộ ghi: ${await wd('POST', `/session/${sid}/execute/sync`, { script: LISTEN_JS, args: [] })}`);
    let s = await state();
    writeFileSync(`${outDir}/00-truoc.json`, JSON.stringify(s, null, 1));
    console.log(`trước thao tác: ${JSON.stringify(s)}`);
    shot('00-truoc');
    const list = actionList.split(',').filter(Boolean);
    for (const [i, name] of list.entries()) {
      const spec = ACTIONS[name];
      const nn = String(i + 1).padStart(2, '0');
      if (spec.skipIf?.(s)) { rows.push([name, 'bỏ qua (đã ở trạng thái cần)', '', 'OK']); continue; }
      const before = s;
      let t, events = [];
      for (const way of [1, 2]) {
        t = await tap(sid, spec.css, way);
        await sleep(3_000);
        s = await state();
        events = await wd('POST', `/session/${sid}/execute/sync`, { script: DRAIN_JS, args: [] });
        console.log(`   ${t.how} | sự kiện: ${JSON.stringify(events).slice(0, 600)}`);
        if (t.ok && spec.expect(before, s)) break;
      }
      writeFileSync(`${outDir}/${nn}-${name}.json`, JSON.stringify({ tap: t, events, before, after: s }, null, 1));
      const file = shot(`${nn}-${name}`);
      const pass = t.ok && spec.expect(before, s);
      if (!pass) failed = true;
      const delta = `time ${before.time.toFixed(1)}→${s.time.toFixed(1)}, paused ${before.paused}→${s.paused}, muted ${before.muted}→${s.muted}, fullscreen ${before.fullscreen}→${s.fullscreen}`;
      rows.push([name, t.how.split(' rect=')[0], delta, pass ? 'OK' : 'FAIL']);
      console.log(`${nn} ${name}: ${pass ? 'OK' : 'FAIL'} | ${delta} | ${file}`);
    }
  } finally {
    await wd('DELETE', `/session/${sid}`).catch(() => {});
  }
  if (SUMMARY) {
    appendFileSync(SUMMARY, `\n| Thao tác | Cách bấm | Trạng thái video trước→sau | Kết quả |\n|---|---|---|---|\n${rows.map((r) => `| ${r.join(' | ')} |`).join('\n')}\n`);
  }
  process.exit(failed ? 1 : 0);
}

main().catch((e) => { console.error(`LỖI: ${e.message}`); process.exit(2); });
