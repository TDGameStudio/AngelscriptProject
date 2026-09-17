import assert from 'node:assert/strict';
import test from 'node:test';
import { waitForArchify } from './probe-skills.mjs';

test('skill probe waits for a provider that registers during DSH boot', async () => {
  let calls = 0;
  const archify = { name: 'archify', provider: 'archify-plugin' };
  const skills = {
    async list() {
      calls += 1;
      return calls < 3 ? [] : [archify];
    },
  };
  const result = await waitForArchify(skills, '/workspace', {
    timeoutMs: 1_000,
    sleep: async () => {},
  });
  assert.equal(calls, 3);
  assert.equal(result.archify, archify);
  assert.deepEqual(result.list, [archify]);
});
