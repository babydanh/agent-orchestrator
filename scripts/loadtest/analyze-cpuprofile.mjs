// Summarise V8 .cpuprofile files: where does the Node process spend its CPU time?
// Usage: node analyze-cpuprofile.mjs <dir with *.cpuprofile> [topN]
// Prints aggregated self time by file bucket and by function. Public CI log: only names and numbers, no source.
import { readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';

const dir = process.argv[2];
const topN = Number(process.argv[3] || 25);
if (!dir) {
  console.error('usage: analyze-cpuprofile.mjs <dir> [topN]');
  process.exit(2);
}

// pnpm paths look like .../node_modules/.pnpm/pkg@1.2.3/node_modules/pkg/dist/x.js -> bucket "pkg"
function bucketOf(url) {
  if (!url) return '(native/anonymous)';
  if (url.startsWith('node:')) return url.replace(/^node:/, 'node:').split('/')[0];
  const parts = url.replace(/\\/g, '/').split('/node_modules/');
  if (parts.length > 1) {
    const last = parts[parts.length - 1].split('/');
    return last[0].startsWith('@') ? `${last[0]}/${last[1]}` : last[0];
  }
  const match = url.replace(/\\/g, '/').match(/\/\.next\/server\/(.*)$/);
  return match ? `.next/server/${match[1].split('/').slice(0, 2).join('/')}` : path.basename(url);
}

const byBucket = new Map();
const byFunction = new Map();
let total = 0;

const files = readdirSync(dir)
  .filter((f) => f.endsWith('.cpuprofile'))
  .map((f) => path.join(dir, f))
  .sort((a, b) => statSync(b).size - statSync(a).size);

// The biggest profile is the Next server process; ignore tiny helper processes.
const [main] = files;
if (!main) {
  console.error('no .cpuprofile in', dir);
  process.exit(1);
}
console.log(`profile: ${path.basename(main)} (${(statSync(main).size / 1e6).toFixed(1)} MB), ${files.length} file(s) total`);

const profile = JSON.parse(readFileSync(main, 'utf8'));
const nodes = new Map(profile.nodes.map((n) => [n.id, n]));
const selfUs = new Map();
profile.samples.forEach((id, i) => selfUs.set(id, (selfUs.get(id) || 0) + (profile.timeDeltas[i] || 0)));

for (const [id, us] of selfUs) {
  const frame = nodes.get(id)?.callFrame;
  if (!frame) continue;
  const name = frame.functionName || '(anonymous)';
  if (name === '(idle)' || name === '(program)' || name === '(garbage collector)') {
    byFunction.set(name, (byFunction.get(name) || 0) + us);
    if (name !== '(idle)') total += us;
    continue;
  }
  total += us;
  const bucket = bucketOf(frame.url);
  byBucket.set(bucket, (byBucket.get(bucket) || 0) + us);
  const key = `${name} @ ${bucket}`;
  byFunction.set(key, (byFunction.get(key) || 0) + us);
}

const show = (title, map) => {
  console.log(`\n== ${title} (self CPU ms, % of busy time ${(total / 1000).toFixed(0)} ms)`);
  [...map.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, topN)
    .forEach(([k, us]) => console.log(`${(us / 1000).toFixed(0).padStart(8)} ms ${((us / total) * 100).toFixed(1).padStart(5)}%  ${k}`));
};
show('by file bucket', byBucket);
show('by function', byFunction);
