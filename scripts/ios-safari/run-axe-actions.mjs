import { appendFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { setTimeout as sleep } from 'node:timers/promises';

const [actionsCsv, udid, screenshotPrefix, waitSeconds] = process.argv.slice(2);
const actions = (actionsCsv ?? '').split(',').map((action) => action.trim()).filter(Boolean);
const summaryFile = process.env.GITHUB_STEP_SUMMARY;
const validActions = new Set(['play', 'unmute', 'seek-3', 'seek+3', 'fullscreen', 'exit-fullscreen']);
const labelsByAction = {
  play: ['Play', 'Phát'],
  unmute: ['Mute court audio', 'Tắt tiếng', 'Unmute', 'Bật tiếng', 'Volume high', 'Volume low', 'Âm lượng to', 'Âm lượng nhỏ', 'Mute'],
  'seek-3': ['Back 3 seconds', 'Lùi 3 giây'],
  'seek+3': ['Forward 3 seconds', 'Tới 3 giây'],
  fullscreen: ['Fullscreen', 'Toàn màn hình', 'Enter fullscreen', 'Enter full screen'],
  'exit-fullscreen': ['Exit fullscreen', 'Thoát toàn màn hình', 'Exit full screen'],
};

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

function describeUi(file) {
  const raw = runAxe(['describe-ui', '--udid', udid]);
  const snapshot = JSON.parse(raw);
  saveJson(file, snapshot);
  return snapshot;
}

function readFrame(node) {
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
    const role = [value.role, value.type, value.AXRole, value.AXRoleDescription, value.elementType]
      .filter((part) => typeof part === 'string').join(' ');
    const frame = readFrame(value);
    if (label) {
      const key = `${label}\0${JSON.stringify(frame)}`;
      if (!seen.has(key)) {
        seen.add(key);
        nodes.push({ label, role, frame, id: value.AXUniqueId ?? value.identifier ?? null });
      }
      strings.push(label);
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
  const uniqueStrings = [...new Set(strings.map((value) => value.trim()).filter(Boolean))];
  const labelList = nodes.map((node) => node.label);
  const timeSources = uniqueStrings.filter((value) => /\b\d{1,2}:\d{2}(?::\d{2})?\b/.test(value));
  const currentSource = timeSources.find((value) => /current|elapsed|position|playback|progress|played|time/i.test(value))
    ?? timeSources.find((value) => /\d{1,2}:\d{2}(?::\d{2})?.*(?:\/|of)\s*\d{1,2}:\d{2}/i.test(value))
    ?? timeSources[0] ?? null;
  const timeMatch = currentSource?.match(/\b(\d{1,2}:\d{2}(?::\d{2})?)\b/);
  const currentTime = timeMatch ? parseTime(timeMatch[1]) : null;
  const normalizedLabels = labelList.map(normalize);
  const paused = normalizedLabels.some((label) => label === 'pause' || label === 'tam dung' || label.startsWith('pause '))
    ? false
    : normalizedLabels.some((label) => label === 'play' || label === 'phat' || label.startsWith('play ')) ? true : null;
  const volumeLabels = labelList.filter((label) => /volume|audio|sound|mute|tieng|am luong/i.test(normalize(label)));
  const volumeTerms = volumeLabels.map(normalize);
  const muted = volumeTerms.some((label) => label.includes('unmute') || label.includes('bat tieng') || label.includes('tat tieng') || label.includes('mute court audio'))
    ? true
    : volumeTerms.some((label) => label.includes('volume high') || label.includes('volume low') || label.includes('am luong') || label === 'mute') ? false : null;
  const fullscreen = normalizedLabels.some((label) => /exit fullscreen|exit full screen|thoat toan man hinh/.test(label))
    ? true
    : normalizedLabels.some((label) => /^(fullscreen|full screen|toan man hinh|enter fullscreen|enter full screen)$/.test(label)) ? false : null;
  return { nodes, labels: labelList, times: timeSources, currentSource, currentTime, paused, muted, volumeLabels, fullscreen };
}

function parseTime(value) {
  const parts = value.split(':').map(Number);
  return parts.length === 3 ? parts[0] * 3600 + parts[1] * 60 + parts[2] : parts[0] * 60 + parts[1];
}

function targetFor(action, state) {
  const expected = [...labelsByAction[action]];
  if (action === 'play' && state.paused === false) expected.push('Pause', 'Tạm dừng');
  if (action === 'fullscreen' && state.fullscreen === true) expected.push(...labelsByAction['exit-fullscreen']);
  if (action === 'exit-fullscreen' && state.fullscreen === false) expected.push(...labelsByAction.fullscreen);
  const normalized = expected.map(normalize);
  const candidates = state.nodes.filter((node) => normalized.includes(normalize(node.label)));
  const byButtonRole = candidates.find((node) => /button/i.test(node.role));
  return byButtonRole ?? candidates[0] ?? null;
}

function desiredAlreadySatisfied(action, state) {
  if (action === 'play') return state.paused === false;
  if (action === 'unmute') return state.muted === false;
  if (action === 'fullscreen') return state.fullscreen === true;
  if (action === 'exit-fullscreen') return state.fullscreen === false;
  return false;
}

function tapTarget(node) {
  try {
    runAxe(['tap', '--label', node.label, '--udid', udid, '--wait-timeout', '3', '--tap-style', 'physical']);
    return 'AXe label · chạm vật lý';
  } catch (error) {
    const errorText = `${error.message}\n${error.stderr?.toString() ?? ''}`;
    if (!/not found|no match|multiple|ambiguous|no element|selector/i.test(errorText) || !node.frame) throw error;
    const x = Math.round(node.frame.x + node.frame.width / 2);
    const y = Math.round(node.frame.y + node.frame.height / 2);
    runAxe(['tap', '-x', String(x), '-y', String(y), '--udid', udid, '--tap-style', 'physical']);
    return `AXe tọa độ (${x},${y}) · chạm vật lý (dự phòng)`;
  }
}

function timeText(state) {
  return state.currentSource ? `${state.currentSource} (${state.currentTime}s)` : 'không thấy thời gian trong cây AX';
}

function stateText(state) {
  return `currentTime=${state.currentTime === null ? 'không đọc được' : `${state.currentTime}s`}, paused=${state.paused ?? 'không rõ'}, muted=${state.muted ?? 'không rõ'}, fullscreen=${state.fullscreen ?? 'không rõ'}`;
}
function escapeCell(value) {
  return String(value).replace(/[\r\n]+/g, ' ').replaceAll('|', '\\|');
}

function isExpected(action, before, immediate, after) {
  if (action === 'play') return after.currentTime !== null && after.currentTime > 0 && after.paused === false;
  if (action === 'unmute') return (immediate.muted ?? after.muted) === false;
  if (action === 'seek-3') return before.currentTime !== null && immediate.currentTime !== null && immediate.currentTime < before.currentTime;
  if (action === 'seek+3') return before.currentTime !== null && immediate.currentTime !== null && immediate.currentTime > before.currentTime;
  if (action === 'fullscreen') return (immediate.fullscreen ?? after.fullscreen) === true;
  if (action === 'exit-fullscreen') return (immediate.fullscreen ?? after.fullscreen) === false;
  return false;
}

function appendSummary() {
  if (!summaryFile || !report.length) return;
  appendFileSync(summaryFile, `\n### Thao tác AXe trên Safari\n\n| # | Thao tác | Nút tìm được | Cách bấm | Trạng thái trước → sau | Kết quả | Bằng chứng |\n|---:|---|---|---|---|---|---|\n${report.join('\n')}\n\nẢnh và cây accessibility được lưu cùng artifact. Thời gian/trạng thái suy ra từ nội dung AX hiển thị; AXe không thực thi JavaScript trang.\n`);
}

async function main() {
  mkdirSync('shots', { recursive: true });
  let initial = null;
  try {
    await sleep(Number(waitSeconds) * 1000);
    initial = describeUi(`${screenshotPrefix}-initial.json`);
    runAxe(['screenshot', '--output', `${screenshotPrefix}.png`, '--udid', udid]);
  } catch (error) {
    failed = true;
    console.error(`Không đọc/chụp được giao diện AXe ban đầu: ${error.message}`);
  }
  let previousSnapshot = initial;

  for (const [index, action] of actions.entries()) {
    const number = String(index + 1).padStart(2, '0');
    const prefix = `shots/${number}-${action}`;
    let beforeSnapshot = previousSnapshot;
    let before = beforeSnapshot ? inspect(beforeSnapshot) : null;
    let target = null;
    let tapMode = 'không bấm';
    let actionError = '';
    if (!before) {
      try {
        beforeSnapshot = describeUi(`${prefix}-before.json`);
        before = inspect(beforeSnapshot);
      } catch (error) {
        actionError = `không đọc được cây AX trước thao tác: ${error.message}`;
      }
    }
    if (before) {
      target = targetFor(action, before);
      if (!target) {
        actionError = `không tìm thấy nút theo AX label: ${labelsByAction[action].join(' / ')}`;
      } else if (desiredAlreadySatisfied(action, before)) {
        tapMode = 'đã ở trạng thái đích, không đổi trạng thái';
      } else {
        try {
          tapMode = tapTarget(target);
        } catch (error) {
          actionError = `bấm AXe thất bại: ${error.message}`;
        }
      }
    }

    let immediateSnapshot = null;
    let immediate = null;
    try {
      immediateSnapshot = describeUi(`${prefix}-immediate.json`);
      immediate = inspect(immediateSnapshot);
    } catch (error) {
      actionError ||= `không đọc được cây AX ngay sau bấm: ${error.message}`;
    }
    await sleep(2500);
    let afterSnapshot = null;
    let after = null;
    try {
      afterSnapshot = describeUi(`${prefix}.json`);
      after = inspect(afterSnapshot);
      previousSnapshot = afterSnapshot;
    } catch (error) {
      actionError ||= `không đọc được cây AX sau chờ: ${error.message}`;
    }
    let screenshotError = '';
    try {
      runAxe(['screenshot', '--output', `${prefix}.png`, '--udid', udid]);
    } catch (error) {
      screenshotError = error.message;
      actionError ||= `chụp ảnh thất bại: ${error.message}`;
    }

    const expected = before && immediate && after ? isExpected(action, before, immediate, after) : false;
    const success = Boolean(target) && !actionError && expected && !screenshotError;
    if (!success) failed = true;
    const label = target ? `${target.label} (${target.role || 'AX element'})` : 'không tìm thấy';
    const beforeText = before ? stateText(before) : 'không đọc được';
    const afterText = after ? stateText(after) : 'không đọc được';
    const delta = `${beforeText} → ${afterText}; đồng hồ: ${before ? timeText(before) : 'n/a'} → ${immediate ? timeText(immediate) : 'n/a'}`;
    const status = success ? 'PASS' : `FAIL${actionError ? `: ${actionError}` : expected ? '' : ': trạng thái không đổi đúng kỳ vọng'}`;
    report.push(`| ${number} | \`${action}\` | ${escapeCell(label)} | ${escapeCell(tapMode)} | ${escapeCell(delta)} | ${escapeCell(status)} | \`${prefix}.png\`, \`${prefix}.json\` |`);
    console.log(`${number} ${action}: ${status}; found=${Boolean(target)}; label=${target?.label ?? 'none'}; tap=${tapMode}; before=${beforeText}; after=${afterText}; image=${prefix}.png; tree=${prefix}.json`);
    if (actionError) console.error(actionError);
    if (screenshotError) console.error(`Lỗi ảnh: ${screenshotError}`);
  }
  appendSummary();
  if (failed) process.exitCode = 1;
}

main().catch((error) => {
  console.error(`Lỗi helper AXe: ${error.stack ?? error}`);
  appendSummary();
  process.exitCode = 1;
});
