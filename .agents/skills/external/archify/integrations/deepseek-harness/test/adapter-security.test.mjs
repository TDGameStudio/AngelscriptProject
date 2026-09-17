import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const libRoot = path.resolve(here, '..', 'lib');

test('host-loaded adapter code does not open a second execution, network, credential, or telemetry surface', () => {
  const files = fs.readdirSync(libRoot).filter((name) => name.endsWith('.js'));
  assert.ok(files.length > 0, 'adapter lib is missing');
  const source = files.map((name) => fs.readFileSync(path.join(libRoot, name), 'utf8')).join('\n');
  assert.doesNotMatch(source, /child_process/);
  assert.doesNotMatch(source, /node:child_process/);
  assert.doesNotMatch(source, /fetch\s*\(/);
  assert.doesNotMatch(source, /node:http|node:https|node:net|node:dgram/);
  assert.doesNotMatch(source, /telemetry|opentelemetry|otlp/i);
  assert.doesNotMatch(source, /credentials|DEEPSEEK_API_KEY|process\.env\.\w*TOKEN/);
  assert.doesNotMatch(source, /setInterval|setTimeout|Worker|cluster/);
  assert.doesNotMatch(source, /archify_render|archify_deliver|tools\.register/);
});

test('package resolution failures fail loud instead of returning a guessed Skill root', async () => {
  const { resolveArchifySkillRoot } = await import('../lib/index.js');
  assert.throws(() => resolveArchifySkillRoot('file:///tmp/archify-dsh-missing-profile/'));
  assert.throws(() => resolveArchifySkillRoot(''));
});
