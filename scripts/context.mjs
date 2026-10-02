import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const task = process.argv.slice(2).join(' ').trim();
if (!task) {
  console.error('Usage: pnpm context "the change or question to investigate"');
  process.exit(1);
}
const root = fileURLToPath(new URL('../', import.meta.url));
const child = spawn('ripwire', [root, `--for=${task}`, '--token-budget=4000', '--legend=compact'], {
  cwd: root,
  stdio: ['ignore', 'pipe', 'pipe'],
  timeout: 120_000,
});
let bytes = 0;
let lines = 0;
let truncated = false;
child.stdout.on('data', (chunk) => {
  for (const line of chunk.toString().split(/(?<=\n)/)) {
    if (bytes + Buffer.byteLength(line) > 50_000 || lines >= 2000) {
      truncated = true;
      continue;
    }
    bytes += Buffer.byteLength(line);
    lines += (line.match(/\n/g) ?? []).length;
    process.stdout.write(line);
  }
});
child.stderr.pipe(process.stderr);
child.on('error', (error) => {
  console.error(`Could not run ripwire: ${error.message}. Ensure ripwire is installed and on PATH.`);
  process.exitCode = 1;
});
child.on('close', (code, signal) => {
  if (truncated) console.log('\n[Output truncated at 2000 lines / 50KB; narrow the task.]');
  if (signal) console.error(`ripwire stopped: ${signal}`);
  process.exitCode = code ?? 1;
});
