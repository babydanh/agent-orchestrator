import { appendFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { setTimeout as sleep } from 'node:timers/promises';

const [url, actionsCsv, udid, screenshotPrefix, waitSeconds, deviceName] = process.argv.slice(2);
const allowedActions = new Set(['play', 'unmute', 'seek-3', 'seek+3', 'fullscreen', 'exit-fullscreen']);
const actions = (actionsCsv ?? '').split(',').map((action) => action.trim()).filter(Boolean);
const summaryFile = process.env.GITHUB_STEP_SUMMARY;
const appiumUrl = process.env.APPIUM_URL ?? 'http://127.0.0.1:4723/wd/hub';

if (!url || !actions.length || !udid || !screenshotPrefix || !waitSeconds || !deviceName) {
  console.error('Usage: run-actions.mjs URL ACTIONS UDID SCREENSHOT_PREFIX WAIT_SECONDS DEVICE_NAME');
  process.exit(2);
}
for (const action of actions) {
  if (!allowedActions.has(action)) throw new Error(`Unsupported action: ${action}`);
}

let sessionId;
let failed = false;
const lines = [];

function stateLabel(state) {
  if (!state) return 'không đọc được video';
  const currentTime = Number.isFinite(state.currentTime) ? `${state.currentTime.toFixed(2)}s` : 'không có';
  return `currentTime=${currentTime}, paused=${state.paused}, muted=${state.muted}, fullscreenElement=${state.fullscreenElement}, webkitDisplayingFullscreen=${state.webkitDisplayingFullscreen}`;
}

function summary(line) {
  lines.push(line);
  console.log(line);
}

async function request(method, path, body, timeoutMs = 120_000) {
  let response;
  try {
    response = await fetch(`${appiumUrl}${path}`, {
      method,
      headers: body ? { 'content-type': 'application/json' } : undefined,
      body: body ? JSON.stringify(body) : undefined,
      signal: AbortSignal.timeout(timeoutMs),
    });
  } catch (error) {
    throw new Error(`${method} ${path} failed: ${error.message}`);
  }
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const error = payload.value?.message ?? payload.message ?? `${response.status} ${response.statusText}`;
    const requestError = new Error(error);
    requestError.httpStatus = response.status;
    throw requestError;
  }
  return payload.value;
}

async function readState() {
  return request('POST', `/session/${sessionId}/execute/sync`, {
    script: `const videos = [...document.querySelectorAll('video')];
      const video = videos.find((item) => !item.paused && Number.isFinite(item.currentTime)) || videos[0] || null;
      const fullscreenElement = document.fullscreenElement || document.webkitFullscreenElement || null;
      const webkitDisplayingFullscreen = videos.some((item) => Boolean(item.webkitDisplayingFullscreen));
      return video ? {
        currentTime: Number.isFinite(video.currentTime) ? video.currentTime : null,
        paused: Boolean(video.paused),
        muted: Boolean(video.muted),
        fullscreenElement: Boolean(fullscreenElement),
        webkitDisplayingFullscreen,
        fullscreen: Boolean(fullscreenElement || webkitDisplayingFullscreen)
      } : null;`,
    args: [],
  });
}

async function findElement(selectors) {
  for (const selector of selectors) {
    try {
      const result = await request('POST', `/session/${sessionId}/element`, {
        using: 'css selector',
        value: selector,
      });
      const elementId = result['element-6066-11e4-a52e-4f735466cecf'] ?? result.ELEMENT;
      if (!elementId) continue;
      const displayed = await request('GET', `/session/${sessionId}/element/${elementId}/displayed`);
      if (displayed === true) return { elementId, selector };
    } catch (error) {
      if (error.httpStatus !== 404) throw error;
    }
  }
  return null;
}

async function tapElement(elementId) {
  const rect = await request('GET', `/session/${sessionId}/element/${elementId}/rect`);
  await request('POST', `/session/${sessionId}/actions`, {
    actions: [{
      type: 'pointer',
      id: 'ios-finger',
      parameters: { pointerType: 'touch' },
      actions: [
        { type: 'pointerMove', duration: 0, x: Math.round(rect.x + rect.width / 2), y: Math.round(rect.y + rect.height / 2) },
        { type: 'pointerDown', button: 0 },
        { type: 'pause', duration: 100 },
        { type: 'pointerUp', button: 0 },
      ],
    }],
  });
}

async function revealReplayControls() {
  const replayVideo = await findElement(['video[data-replay-video]']);
  if (!replayVideo) return;
  await tapElement(replayVideo.elementId);
  await sleep(250);
}

function selectorsFor(action, state) {
  switch (action) {
    case 'play':
      return state?.paused !== false
        ? ['button[aria-label="Play"]', 'button[aria-label="Phát"]']
        : ['button[aria-label="Pause"]', 'button[aria-label="Tạm dừng"]'];
    case 'unmute':
      return ['button[aria-label="Mute court audio"]', 'button[aria-label="Volume high"]', 'button[aria-label="Volume low"]', 'button[aria-label="Tắt tiếng"]', 'button[aria-label="Âm lượng to"]', 'button[aria-label="Âm lượng nhỏ"]'];
    case 'seek-3':
      return ['button[aria-label="Back 3 seconds"]', 'button[aria-label="Lùi 3 giây"]'];
    case 'seek+3':
      return ['button[aria-label="Forward 3 seconds"]', 'button[aria-label="Tới 3 giây"]'];
    case 'fullscreen':
      return state?.fullscreen
        ? ['button[aria-label="Exit fullscreen"]', 'button[aria-label="Thoát toàn màn hình"]']
        : ['button[aria-label="Fullscreen"]', 'button[aria-label="Toàn màn hình"]'];
    case 'exit-fullscreen':
      return state?.fullscreen
        ? ['button[aria-label="Exit fullscreen"]', 'button[aria-label="Thoát toàn màn hình"]']
        : ['button[aria-label="Fullscreen"]', 'button[aria-label="Toàn màn hình"]'];
  }
}

function shouldTap(action, state) {
  if (action === 'play') return state?.paused !== false;
  if (action === 'unmute') return state?.muted !== false;
  if (action === 'fullscreen') return state?.fullscreen !== true;
  if (action === 'exit-fullscreen') return state?.fullscreen === true;
  return true;
}

function isExpected(action, beforeTap, after, afterTap) {
  if (!after) return false;
  switch (action) {
    case 'play': return after.paused === false && Number.isFinite(after.currentTime) && after.currentTime > 0;
    case 'unmute': return after.muted === false;
    case 'seek-3': return Number.isFinite(beforeTap?.currentTime) && Number.isFinite(afterTap?.currentTime) && afterTap.currentTime < beforeTap.currentTime;
    case 'seek+3': return Number.isFinite(beforeTap?.currentTime) && Number.isFinite(afterTap?.currentTime) && afterTap.currentTime > beforeTap.currentTime;
    case 'fullscreen': return after.fullscreen === true;
    case 'exit-fullscreen': return after.fullscreen === false;
  }
}

function screenshot(file) {
  for (let attempt = 1; attempt <= 2; attempt += 1) {
    try {
      execFileSync('perl', ['-e', 'alarm shift; exec @ARGV', '90', 'xcrun', 'simctl', 'io', udid, 'screenshot', file], { stdio: 'pipe' });
      return;
    } catch (error) {
      console.error(`Chụp ${file} lỗi lần ${attempt}: ${error.message}`);
      if (attempt === 2) throw error;
    }
  }
}

async function main() {
  console.log('Starting Appium Safari session (up to 10 minutes for XCUITest/WDA startup)');
  const session = await request('POST', '/session', {
    capabilities: {
      alwaysMatch: {
        platformName: 'iOS',
        browserName: 'Safari',
        'appium:automationName': 'XCUITest',
        'appium:udid': udid,
        'appium:deviceName': deviceName,
        'appium:noReset': true,
        'appium:newCommandTimeout': 300,
        'appium:wdaLaunchTimeout': 600_000,
        'appium:showXcodeLog': true,
        'appium:waitForIdleTimeout': 0,
      },
    },
  }, 600_000);
  sessionId = session.sessionId;
  if (!sessionId) throw new Error('Appium did not return a WebDriver session ID');

  let navigationError = null;
  try {
    await request('POST', `/session/${sessionId}/url`, { url });
  } catch (error) {
    navigationError = error.message;
    failed = true;
  }
  await sleep(Number(waitSeconds) * 1000);
  let initialState = null;
  let initialStateError = null;
  try {
    initialState = await readState();
  } catch (error) {
    initialStateError = error.message;
    failed = true;
  }
  const initialShot = `${screenshotPrefix}.png`;
  let initialShotError = null;
  try {
    screenshot(initialShot);
  } catch (error) {
    initialShotError = error.message;
    failed = true;
  }
  summary(`Trang đích: ${url} · trạng thái ban đầu: ${stateLabel(initialState)}${navigationError ? ` · lỗi mở trang: ${navigationError}` : ''}${initialStateError ? ` · lỗi đo trạng thái: ${initialStateError}` : ''}${initialShotError ? ` · lỗi chụp: ${initialShotError}` : ''} · ảnh: ${initialShot}`);

  for (const [index, action] of actions.entries()) {
    let before = null;
    let found = null;
    let tapped = false;
    let tapError = null;
    let afterTap = null;
    try {
      before = await readState();
    } catch (error) {
      tapError = `Đọc trạng thái trước thao tác lỗi: ${error.message}`;
    }
    try {
      await revealReplayControls();
    } catch (error) {
      tapError ??= error.message;
    }
    try {
      before = await readState();
    } catch (error) {
      tapError ??= `Đọc trạng thái trước thao tác lỗi: ${error.message}`;
    }
    try {
      found = await findElement(selectorsFor(action, before));
    } catch (error) {
      tapError ??= error.message;
    }
    if (found && shouldTap(action, before)) {
      try {
        before = await readState().catch(() => before);
        await tapElement(found.elementId);
        tapped = true;
        await sleep(250);
        afterTap = await readState();
      } catch (error) {
        tapError ??= error.message;
      }
    } else {
      afterTap = before;
    }

    await sleep(tapped ? 2250 : 2500);
    let after = null;
    let shotError = null;
    const screenshotPath = `shots/${String(index + 1).padStart(2, '0')}-${action}.png`;
    try {
      after = await readState();
    } catch (error) {
      tapError ??= `Đọc trạng thái sau thao tác lỗi: ${error.message}`;
    }
    try {
      screenshot(screenshotPath);
    } catch (error) {
      shotError = error.message;
    }
    const expected = isExpected(action, before, after, afterTap);
    const passed = Boolean(found && expected && !tapError && !shotError);
    if (!passed) failed = true;
    const result = passed ? 'PASS' : 'FAIL';
    const selector = found?.selector ?? 'không tìm thấy';
    const errors = [tapError, shotError].filter(Boolean).join('; ');
    summary(`- ${result} \`${action}\`: nút=${found ? 'có' : 'không'} (${selector}); chạm=${tapped ? 'có' : 'không'}; trước: ${stateLabel(before)}; sau chạm: ${stateLabel(afterTap)}; sau 2.5s: ${stateLabel(after)}; kỳ vọng=${expected ? 'đạt' : 'không đạt'}${errors ? `; lỗi=${errors}` : ''}; ảnh: ${screenshotPath}`);
  }

  await request('DELETE', `/session/${sessionId}`);
  sessionId = undefined;
  return failed ? 1 : 0;
}

try {
  const exitCode = await main();
  if (summaryFile) appendFileSync(summaryFile, `${lines.join('\n')}\n`);
  process.exitCode = exitCode;
} catch (error) {
  failed = true;
  summary(`- FAIL thao tác WebDriver: ${error.message}`);
  if (summaryFile) appendFileSync(summaryFile, `${lines.join('\n')}\n`);
  console.error(error.stack ?? error.message);
  process.exitCode = 1;
} finally {
  if (sessionId) {
    try {
      await request('DELETE', `/session/${sessionId}`);
    } catch (error) {
      console.error(`Không đóng được WebDriver session: ${error.message}`);
    }
  }
}
