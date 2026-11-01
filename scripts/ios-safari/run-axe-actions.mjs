import { appendFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { setTimeout as sleep } from 'node:timers/promises';

const [actionsCsv, udid, screenshotPrefix, waitSeconds] = process.argv.slice(2);
const actions = (actionsCsv ?? '').split(',').map((action) => action.trim()).filter(Boolean);
const summaryFile = process.env.GITHUB_STEP_SUMMARY;
const validActions = new Set(['play', 'unmute', 'seek-3', 'seek+3', 'fullscreen', 'exit-fullscreen']);
const actionLabels = {
  play: ['Play', 'Phát'],
  unmute: ['Mute court audio', 'Tắt tiếng', 'Unmute', 'Bật tiếng', 'Volume high', 'Volume low', 'Âm lượng to', 'Âm lượng nhỏ', 'Mute'],
  'seek-3': ['Back 3 seconds', 'Lùi 3 giây'],
  'seek+3': ['Forward 3 seconds', 'Tới 3 giây'],
  fullscreen: ['Fullscreen', 'Toàn màn hình', 'Enter fullscreen', 'Enter full screen'],
  'exit-fullscreen': ['Exit fullscreen', 'Thoát toàn màn hình', 'Exit full screen', 'Done'],
};
const actionPoints = {
  play: [{ x: 220, y: 171 }],
  unmute: [{ x: 78, y: 284 }],
  'seek-3': [{ x: 132, y: 171 }],
  'seek+3': [{ x: 308, y: 171 }],
  fullscreen: [{ x: 408, y: 284 }],
  // Native iOS fullscreen exposes Done near the top-left; CSS fullscreen keeps the in-player control.
  'exit-fullscreen': [{ x: 40, y: 80 }, { x: 408, y: 925 }, { x: 408, y: 284 }],
};
const timePoint = { x: 151, y: 284 };

if (!actions.length || !udid || !screenshotPrefix || !waitSeconds) {
  console.error('Usage: run-axe-actions.mjs ACTIONS UDID SCREENSHOT_PREFIX WAIT_SECONDS');
  process.exit(2);
}
for (const action of actions) {
  if (!validActions.has(action)) throw new Error(`Unsupported action: ${action}`);
}

let failed = false;
const report = [];
const maxBuffer = 16 * 1024 * 1024;
const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();

function runAxe(args) {
  return execFileSync('axe', args, { encoding: 'utf8', maxBuffer, timeout: 90_000, stdio: ['ignore', 'pipe', 'pipe'] });
}

function saveJson(file, value) {
  writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

function describePoint(point, file) {
  const raw = runAxe(['describe-ui', '--point', `${point.x},${point.y}`, '--udid', udid]);
  const snapshot = JSON.parse(raw);
  saveJson(file, snapshot);
  return snapshot;
}

function describeScreen(file) {
  const snapshot = JSON.parse(runAxe(['describe-ui', '--udid', udid]));
  saveJson(file, snapshot);
  return snapshot;
}

function frameFor(node) {
  if (node.frame && Number.isFinite(node.frame.x) && Number.isFinite(node.frame.y)
      && Number.isFinite(node.frame.width) && Number.isFinite(node.frame.height)) return node.frame;
  const source = node.AXFrame ?? node.frame;
  if (typeof source !== 'string') return null;
  const match = source.match(/\{\{\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\},\s*\{\s*([\d.]+)\s*,\s*([\d.]+)\s*\}\}/);
  return match ? { x: Number(match[1]), y: Number(match[2]), width: Number(match[3]), height: Number(match[4]) } : null;
}

function inspect(snapshot) {
  const nodes = [];
  const strings = [];
  const seen = new Set();
  function visit(value) {
    if (Array.isArray(value)) {
      for (const child of value) visit(child);
      return;
    }
    if (!value || typeof value !== 'object') {
      if (typeof value === 'string') strings.push(value);
      return;
    }
    const labelValue = value.AXLabel ?? value.label ?? value.accessibilityLabel ?? value.title ?? value.name;
    const label = typeof labelValue === 'string' ? labelValue.trim() : '';
    const role = [value.role, value.type, value.AXRole, value.AXRoleDescription, value.role_description, value.elementType]
      .filter((part) => typeof part === 'string').join(' ');
    const frame = frameFor(value);
    if (label) {
      const key = `${label}\0${JSON.stringify(frame)}`;
      if (!seen.has(key)) {
        seen.add(key);
        nodes.push({ label, role, frame, id: value.AXUniqueId ?? value.identifier ?? null });
      }
      strings.push(label);
    } else if (frame) {
      const key = `\0${JSON.stringify(frame)}\0${role}`;
      if (!seen.has(key)) {
        seen.add(key);
        nodes.push({ label: '', role, frame, id: value.AXUniqueId ?? value.identifier ?? null });
      }
    }
    for (const [key, child] of Object.entries(value)) {
      if (typeof child === 'string') {
        if (/label|value|title|help|name|identifier|description/i.test(key)) strings.push(child);
      } else {
        visit(child);
      }
    }
  }
  visit(snapshot);

  const labels = nodes.map((node) => node.label).filter(Boolean);
  const uniqueStrings = [...new Set(strings.map((value) => value.trim()).filter(Boolean))];
  const timeSources = uniqueStrings.filter((value) => /\b\d{1,2}:\d{2}(?::\d{2})?\b/.test(value));
  const currentSource = timeSources.find((value) => /current|elapsed|position|playback|progress|played|time/i.test(value))
    ?? timeSources.find((value) => /\d{1,2}:\d{2}(?::\d{2})?.*(?:\/|of)\s*\d{1,2}:\d{2}/i.test(value))
    ?? timeSources[0] ?? null;
  const timeMatch = currentSource?.match(/\b(\d{1,2}:\d{2}(?::\d{2})?)\b/);
  const currentTime = timeMatch ? parseTime(timeMatch[1]) : null;
  const normalizedLabels = labels.map(normalize);
  const paused = normalizedLabels.some((label) => label === 'pause' || label === 'tam dung' || label.startsWith('pause '))
    ? false
    : normalizedLabels.some((label) => label === 'play' || label === 'phat' || label.startsWith('play ')) ? true : null;
  const volumeLabels = labels.filter((label) => /volume|audio|sound|mute|tieng|am luong/i.test(normalize(label)));
  const volumeTerms = volumeLabels.map(normalize);
  const muted = volumeTerms.some((label) => label.includes('unmute') || label.includes('bat tieng') || label.includes('volume off') || label.includes('mute court audio') || label.includes('tat tieng'))
    ? true
    : volumeTerms.some((label) => label.includes('volume high') || label.includes('volume low') || label.includes('am luong')) ? false : null;
  const fullscreen = normalizedLabels.some((label) => /exit fullscreen|exit full screen|thoat toan man hinh|^done$/.test(label))
    ? true
    : normalizedLabels.some((label) => /^(fullscreen|full screen|toan man hinh|enter fullscreen|enter full screen)$/.test(label))
      || labels.includes('Safari') ? false : null;
  return { nodes, labels, times: timeSources, currentSource, currentTime, paused, muted, volumeLabels, fullscreen };
}

function parseTime(value) {
  const parts = value.split(':').map(Number);
  return parts.length === 3 ? parts[0] * 3600 + parts[1] * 60 + parts[2] : parts[0] * 60 + parts[1];
}

function pointContains(frame, point) {
  return frame && point.x >= frame.x && point.x <= frame.x + frame.width
    && point.y >= frame.y && point.y <= frame.y + frame.height;
}

function nearestHit(state, point) {
  return state.nodes
    .filter((node) => pointContains(node.frame, point) && node.frame.width <= 140 && node.frame.height <= 140)
    .sort((left, right) => left.frame.width * left.frame.height - right.frame.width * right.frame.height)[0] ?? null;
}

function selectTarget(action, state) {
  const expected = actionLabels[action].map(normalize);
  const labelled = state.nodes.find((node) => node.label && expected.includes(normalize(node.label)));
  if (labelled) return { node: labelled, labelled: true };
  for (const point of actionPoints[action]) {
    const hit = nearestHit(state, point);
    if (hit) return { node: hit, point, labelled: false };
  }
  return null;
}

function desiredAlreadySatisfied(action, state) {
  if (action === 'play') return state.paused === false;
  if (action === 'unmute') return state.muted === false;
  if (action === 'fullscreen') return state.fullscreen === true;
  if (action === 'exit-fullscreen') return state.fullscreen === false;
  return false;
}

function tapTarget(target, point) {
  if (target?.labelled) {
    try {
      runAxe(['tap', '--label', target.node.label, '--udid', udid, '--wait-timeout', '3', '--tap-style', 'physical']);
      return 'AXe nhãn · chạm vật lý';
    } catch (error) {
      const errorText = `${error.message}\n${error.stderr?.toString() ?? ''}`;
      if (!/not found|no match|multiple|ambiguous|no element|selector/i.test(errorText)) throw error;
    }
  }
  runAxe(['tap', '-x', String(point.x), '-y', String(point.y), '--udid', udid, '--tap-style', 'physical']);
  return `AXe tọa độ (${point.x},${point.y}) · chạm vật lý`;
}

function escapeCell(value) {
  return String(value).replace(/[\r\n]+/g, ' ').replaceAll('|', '\\|');
}

function stateText(target, time) {
  return `currentTime=${time.currentTime === null ? 'không đọc được' : `${time.currentTime}s`}, paused=${target.paused ?? 'không rõ'}, muted=${target.muted ?? 'không rõ'}, fullscreen=${target.fullscreen ?? 'không rõ'}`;
}

function appendSummary() {
  if (!summaryFile || !report.length) return;
  appendFileSync(summaryFile, `\n### Thao tác AXe trên Safari\n\n| # | Thao tác | Nút tìm được | Cách bấm | Trạng thái trước → sau | Kết quả | Bằng chứng |\n|---:|---|---|---|---|---|---|\n${report.join('\n')}\n\nTrạng thái lấy từ hit-test AXe theo điểm accessibility và nhãn hiển thị; ảnh/video được lưu trong artifact.\n`);
}

async function readPoint(point, file) {
  return inspect(describePoint(point, file));
}

async function main() {
  mkdirSync('shots', { recursive: true });
  await sleep(Number(waitSeconds) * 1000);
  runAxe(['screenshot', '--output', `${screenshotPrefix}.png`, '--udid', udid]);

  for (const [index, action] of actions.entries()) {
    const number = String(index + 1).padStart(2, '0');
    const prefix = `shots/${number}-${action}`;
    const points = actionPoints[action];
    let beforeTarget = null;
    let selected = null;
    let targetPoint = points[0];
    const targetErrors = [];
    let targetError = '';
    for (const point of points) {
      try {
        beforeTarget = await readPoint(point, `${prefix}-before-${point.x}-${point.y}.json`);
        selected = selectTarget(action, beforeTarget);
        targetPoint = point;
        if (selected?.labelled) break;
        if (!selected && points.length > 1) continue;
        if (selected) break;
      } catch (error) {
        targetErrors.push(error.message);
      }
    }
    if (!selected && targetErrors.length) targetError = targetErrors.join('; ');
    let beforeTime = null;
    try {
      beforeTime = await readPoint(timePoint, `${prefix}-time-before.json`);
    } catch (error) {
      targetError ||= `không đọc được thời gian trước thao tác: ${error.message}`;
    }
    if (!selected) targetError ||= `không tìm thấy điều khiển tại tọa độ AXe (${targetPoint.x},${targetPoint.y})`;

    let tapMode = 'không bấm';
    let actionError = targetError;
    if (selected && beforeTarget && !desiredAlreadySatisfied(action, beforeTarget)) {
      try {
        tapMode = tapTarget(selected, targetPoint);
      } catch (error) {
        actionError ||= `bấm AXe thất bại: ${error.message}`;
      }
    } else if (selected) {
      tapMode = 'đã ở trạng thái đích';
    } else {
      // Still perform the requested physical touch so all later actions retain evidence.
      try {
        runAxe(['tap', '-x', String(targetPoint.x), '-y', String(targetPoint.y), '--udid', udid, '--tap-style', 'physical']);
        tapMode = `AXe tọa độ (${targetPoint.x},${targetPoint.y}) · chạm vật lý (dự phòng)`;
      } catch (error) {
        actionError ||= `bấm dự phòng thất bại: ${error.message}`;
      }
    }

    let immediateTarget = null;
    let immediateTime = null;
    try {
      immediateTarget = await readPoint(targetPoint, `${prefix}-immediate.json`);
    } catch (error) {
      actionError ||= `không đọc được trạng thái điều khiển sau bấm: ${error.message}`;
    }
    try {
      immediateTime = await readPoint(timePoint, `${prefix}-time-immediate.json`);
    } catch (error) {
      actionError ||= `không đọc được thời gian ngay sau bấm: ${error.message}`;
    }
    await sleep(2500);
    let afterTime = null;
    let afterTarget = immediateTarget;
    try {
      runAxe(['screenshot', '--output', `${prefix}.png`, '--udid', udid]);
    } catch (error) {
      actionError ||= `chụp ảnh thất bại: ${error.message}`;
    }
    try {
      afterTime = await readPoint(timePoint, `${prefix}.json`);
    } catch (error) {
      actionError ||= `không đọc được trạng thái sau chờ: ${error.message}`;
    }
    if ((action === 'fullscreen' || action === 'exit-fullscreen') && immediateTarget?.fullscreen === null) {
      try {
        const screen = inspect(describeScreen(`${prefix}-screen.json`));
        if (screen.fullscreen !== null) afterTarget = screen;
      } catch (error) {
        actionError ||= `không đọc được cây AX toàn màn hình: ${error.message}`;
      }
    }

    const successState = Boolean(beforeTarget && beforeTime && immediateTarget && immediateTime && afterTime);
    let expected = false;
    if (successState) {
      if (action === 'play') expected = afterTarget.paused === false && afterTime.currentTime > 0;
      else if (action === 'unmute') expected = afterTarget.muted === false;
      else if (action === 'seek-3') expected = beforeTime.currentTime !== null && immediateTime.currentTime !== null && immediateTime.currentTime < beforeTime.currentTime;
      else if (action === 'seek+3') expected = beforeTime.currentTime !== null && immediateTime.currentTime !== null && immediateTime.currentTime > beforeTime.currentTime;
      else if (action === 'fullscreen') expected = afterTarget.fullscreen === true;
      else if (action === 'exit-fullscreen') expected = afterTarget.fullscreen === false;
    }
    const success = Boolean(selected) && !actionError && expected;
    if (!success) failed = true;
    const foundLabel = selected?.node.label || `tọa độ (${targetPoint.x},${targetPoint.y})${selected?.node.role ? ` · ${selected.node.role}` : ''}`;
    const beforeState = beforeTarget && beforeTime ? stateText(beforeTarget, beforeTime) : 'không đọc được';
    const afterState = afterTarget && afterTime ? stateText(afterTarget, afterTime) : 'không đọc được';
    const clocks = `đọc đồng hồ ${immediateTime?.currentSource ?? 'không rõ'}: ${beforeTime?.currentTime ?? 'n/a'}s → ${immediateTime?.currentTime ?? 'n/a'}s → ${afterTime?.currentTime ?? 'n/a'}s`;
    const status = success ? 'PASS' : `FAIL${actionError ? `: ${actionError}` : ': trạng thái không đổi đúng kỳ vọng'}`;
    report.push(`| ${number} | \`${action}\` | ${escapeCell(foundLabel)} | ${escapeCell(tapMode)} | ${escapeCell(`${beforeState} → ${afterState}; ${clocks}`)} | ${escapeCell(status)} | \`${prefix}.png\`, \`${prefix}.json\` |`);
    console.log(`${number} ${action}: ${status}; found=${Boolean(selected)}; label=${foundLabel}; tap=${tapMode}; before=${beforeState}; after=${afterState}; image=${prefix}.png`);
    if (actionError) console.error(actionError);
  }
  appendSummary();
  if (failed) process.exitCode = 1;
}

main().catch((error) => {
  console.error(`Lỗi helper AXe: ${error.stack ?? error}`);
  appendSummary();
  process.exitCode = 1;
});
