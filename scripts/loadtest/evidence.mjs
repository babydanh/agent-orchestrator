// Evidence capture for the k6 live load test (headless Chromium).
//   node evidence.mjs watch  <host> <matchId> <outDir> <seconds>   video + screenshots of /live/<matchId>
//   node evidence.mjs report <htmlFile> <outPng>                    screenshot of the k6 web-dashboard report
// BASIC_AUTH ("user:pass") comes from the environment and is never written anywhere.
import { chromium } from 'playwright';
import { mkdirSync, writeFileSync } from 'node:fs';

const [mode, ...args] = process.argv.slice(2);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const SHOT_EVERY_MS = 20000;

async function watch([host, matchId, outDir, secondsRaw]) {
  const seconds = parseInt(secondsRaw, 10);
  const sep = (process.env.BASIC_AUTH || '').indexOf(':');
  const auth = process.env.BASIC_AUTH || '';
  const credentials = {
    username: auth.slice(0, sep),
    password: auth.slice(sep + 1),
    send: 'always',
  };
  mkdirSync(outDir, { recursive: true });

  const browser = await chromium.launch();
  const context = await browser.newContext({
    httpCredentials: credentials,
    viewport: { width: 1280, height: 720 },
    recordVideo: { dir: outDir, size: { width: 1280, height: 720 } },
  });
  const page = await context.newPage();
  const log = [];
  const stamp = () => new Date().toISOString();
  // Log only URL paths (no query) and messages, never headers.
  page.on('console', (m) => m.type() === 'error' && log.push(`${stamp()} console.error ${m.text()}`));
  page.on('pageerror', (e) => log.push(`${stamp()} pageerror ${e.message}`));
  page.on('requestfailed', (r) => log.push(`${stamp()} requestfailed ${new URL(r.url()).pathname}`));
  page.on('response', (r) => r.status() >= 400 && log.push(`${stamp()} http ${r.status()} ${new URL(r.url()).pathname}`));
  page.on('websocket', (w) => {
    log.push(`${stamp()} websocket open ${new URL(w.url()).pathname}`);
    w.on('close', () => log.push(`${stamp()} websocket close`));
  });

  try {
    await page.goto(`https://${host}/live/${matchId}`, { waitUntil: 'domcontentloaded', timeout: 45000 });
  } catch (err) {
    log.push(`${stamp()} goto failed: ${err.message}`);
  }

  const deadline = Date.now() + seconds * 1000;
  let n = 0;
  while (Date.now() < deadline) {
    await page.screenshot({ path: `${outDir}/live-${String(n++).padStart(2, '0')}.png` }).catch((e) => log.push(`${stamp()} screenshot failed: ${e.message}`));
    await sleep(SHOT_EVERY_MS);
  }
  await page.screenshot({ path: `${outDir}/live-final.png` }).catch(() => {});
  writeFileSync(`${outDir}/browser-log.txt`, `${log.join('\n')}\n`);
  await context.close(); // flushes the video
  await browser.close();
}

async function report([htmlFile, outPng]) {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  page.on('console', (m) => m.type() === 'error' && console.error(`report console.error: ${m.text()}`));
  page.on('pageerror', (e) => console.error(`report pageerror: ${e.message}`));
  await page.goto(`file://${process.cwd()}/${htmlFile}`, { waitUntil: 'load' });
  // The report is a module page that decodes gzip data first; wait for real content, then let charts draw.
  await page.waitForSelector('#root > *', { timeout: 30000 }).catch((e) => console.error(`report not rendered: ${e.message}`));
  await sleep(5000);
  await page.screenshot({ path: outPng, fullPage: true });
  await browser.close();
}

if (mode === 'watch') await watch(args);
else if (mode === 'report') await report(args);
else {
  console.error('usage: evidence.mjs watch|report ...');
  process.exit(2);
}
