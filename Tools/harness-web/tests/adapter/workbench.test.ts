import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { mkdtemp, mkdir, writeFile, readFile, copyFile, rm, symlink } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { createApp } from '../../src/server/app.js';
import { Workspace } from '../../src/server/workspace.js';

import { createFixture, original } from './fixture.js';
let root: string;
let app: Awaited<ReturnType<typeof createApp>>;
let sessionToken: string;
const headers = () => ({ 'x-harness-session': sessionToken, origin: 'http://localhost:80' });
async function file(relative: string, content: string) {
  const target = path.join(root, relative);
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, content);
}

beforeAll(async () => {
  root = await createFixture();
  app = await createApp({ workspaceRoot: root, watch: false });
  const workspace = await app.inject('/api/workspace');
  sessionToken = workspace.json().sessionToken;
});
afterAll(async () => {
  await app?.close();
  if (root) await rm(root, { recursive: true, force: true });
});

describe('native records and factual projections', () => {
  it('reports selected workspace and packaged native CLI availability', async () => {
    const result = await app.inject('/api/workspace');
    expect(result.statusCode).toBe(200);
    expect(result.json()).toMatchObject({ root, cliAvailable: true });
    expect(result.json().sessionToken).toMatch(/^[a-f0-9]{64}$/);
  });
  it('does not confuse existing artifacts with completed tasks', async () => {
    const result = await app.inject('/api/records?kind=change');
    expect(result.statusCode).toBe(200);
    expect(
      result.json().find((r: { id: string }) => r.id === 'demo/feature-test-ready'),
      (await app.inject('/api/workspace')).body,
    ).toMatchObject({ artifactComplete: true, progress: { total: 3, complete: 1, remaining: 2 } });
  });
  it('returns native dependency readiness and handles omitted task arrays', async () => {
    const ready = (await app.inject('/api/tasks?change=demo%2Ffeature-test-ready')).json();
    expect(ready.tasks.map((t: { id: string; ready: boolean }) => [t.id, t.ready])).toEqual([
      ['1.1', false],
      ['2.1', true],
      ['3.1', false],
    ]);
    const planning = (await app.inject('/api/tasks?change=demo%2Ffeature-test-planning')).json();
    expect(planning).toMatchObject({
      state: 'waiting',
      tasks: [],
      taskIssues: [],
      progress: { total: 0, complete: 0, remaining: 0 },
    });
  });
  it('exposes invalid graphs as diagnostics rather than valid ready work', async () => {
    const result = (await app.inject('/api/tasks?change=demo%2Ffeature-test-invalid')).json();
    expect(result.state).toBe('waiting');
    expect(result.taskIssues.length).toBeGreaterThan(0);
    const metrics = (await app.inject('/api/metrics')).json();
    expect(metrics.tasks).toEqual({ ready: 1, waiting: 1, done: 1, invalid: 1 });
    expect(metrics.timeline).toEqual([
      { date: '2026-09-01', created: 4, archived: 0 },
      { date: '2026-09-02', created: 0, archived: 1 },
    ]);
  });
  it('keeps archive identity distinct and exposes frozen documents', async () => {
    const records = (await app.inject('/api/records?kind=archive')).json();
    expect(records).toHaveLength(1);
    expect(records[0]).toMatchObject({
      id: 'demo/feature-test-history',
      closure: 'completed',
      kind: 'archive',
    });
    const detail = (await app.inject(`/api/record?key=${encodeURIComponent(records[0].key)}`)).json();
    expect(detail.documents.every((d: { readonly: boolean }) => d.readonly)).toBe(true);
  });
});

describe('owned documents and safe mutations', () => {
  it('prunes Git-ignored trees while retaining tracked documents inside ignored directories', async () => {
    const fixtureRoot = await mkdtemp(path.join(tmpdir(), 'harness-web-watch-scope-'));
    let workspace: Workspace | undefined;
    try {
      execFileSync('git', ['init', '--quiet', fixtureRoot]);
      execFileSync('git', ['-C', fixtureRoot, 'config', 'core.autocrlf', 'false']);
      await mkdir(path.join(fixtureRoot, 'scratch/deep/cache'), { recursive: true });
      await mkdir(path.join(fixtureRoot, 'retained/generated'), { recursive: true });
      await writeFile(path.join(fixtureRoot, '.gitignore'), 'scratch/\nretained/\n');
      await writeFile(path.join(fixtureRoot, 'scratch/deep/cache/noise.md'), '# Ignored noise\n');
      await writeFile(path.join(fixtureRoot, 'retained/generated/noise.md'), '# Ignored child\n');
      await writeFile(path.join(fixtureRoot, 'retained/guide.md'), '# Tracked guide\n');
      execFileSync('git', ['-C', fixtureRoot, 'add', '-f', 'retained/guide.md', '.gitignore']);
      workspace = new Workspace(fixtureRoot);
      await workspace.initialize(true);
      const changes: string[] = [];
      workspace.on('invalidate', (event: { path: string }) => changes.push(event.path));
      await writeFile(path.join(fixtureRoot, 'scratch/deep/cache/noise.md'), '# New ignored noise\n');
      await new Promise((resolve) => setTimeout(resolve, 1100));
      expect(changes).toEqual([]);
      await writeFile(path.join(fixtureRoot, 'retained/guide.md'), '# Updated tracked guide\n');
      await expect.poll(() => changes, { timeout: 5000 }).toContain('retained/guide.md');
      expect(
        changes.some((entry) => entry.startsWith('scratch/') || entry.startsWith('retained/generated/')),
      ).toBe(false);
    } finally {
      await workspace?.close();
      await rm(fixtureRoot, { recursive: true, force: true });
    }
  });
  it('excludes ignored, reference and vendor files from browsing and searching', async () => {
    const documents = (await app.inject('/api/documents')).json();
    expect(documents.some((d: { path: string }) => d.path === 'README.md')).toBe(true);
    expect(documents.some((d: { path: string }) => /Reference|vendor|ignored/.test(d.path))).toBe(false);
    expect((await app.inject('/api/search?q=secret')).json()).toEqual([]);
    for (const bad of [
      '../README.md',
      'Reference/upstream.md',
      'ignored/private.md',
      'openspec/project.yaml',
    ]) {
      expect(
        (await app.inject(`/api/document?path=${encodeURIComponent(bad)}`)).statusCode,
      ).toBeGreaterThanOrEqual(400);
    }
  });
  it('preserves bytes on no-op saves and rejects stale writes with current content', async () => {
    const before = (await app.inject('/api/document?path=README.md')).json();
    const unchanged = await app.inject({
      method: 'PUT',
      url: '/api/document',
      headers: headers(),
      payload: { path: 'README.md', content: before.content, baseRevision: before.revision },
    });
    expect(unchanged.statusCode).toBe(200);
    expect(await readFile(path.join(root, 'README.md'), 'utf8')).toBe(original);
    const changed = original.replace('Original paragraph.', 'Edited paragraph.');
    const result = await app.inject({
      method: 'PUT',
      url: '/api/document',
      headers: headers(),
      payload: { path: 'README.md', content: changed, baseRevision: before.revision },
    });
    expect(result.statusCode).toBe(200);
    const conflict = await app.inject({
      method: 'PUT',
      url: '/api/document',
      headers: headers(),
      payload: { path: 'README.md', content: 'overwrite', baseRevision: before.revision },
    });
    expect(conflict.statusCode).toBe(409);
    expect(conflict.json()).toMatchObject({ code: 'REVISION_CONFLICT', current: { content: changed } });
  });
  it('rejects protected source edits and immutable workflow documents', async () => {
    const before = (await app.inject('/api/document?path=README.md')).json();
    const result = await app.inject({
      method: 'PUT',
      url: '/api/document',
      headers: headers(),
      payload: {
        path: 'README.md',
        content: before.content.replace('title: Preserved', 'title: Lost'),
        baseRevision: before.revision,
      },
    });
    expect(result.statusCode).toBe(422);
    expect(result.json().code).toBe('PROTECTED_CONTENT');
    const relative = 'openspec/changes/demo/feature-test-ready/attachments/replans/replan-example.md';
    const frozen = (await app.inject(`/api/document?path=${encodeURIComponent(relative)}`)).json();
    expect(frozen.readonly).toBe(true);
    expect(
      (
        await app.inject({
          method: 'PUT',
          url: '/api/document',
          headers: headers(),
          payload: { path: relative, content: 'overwrite', baseRevision: frozen.revision },
        })
      ).statusCode,
    ).toBe(403);
  });
  it('rejects cross-origin access, hostile Host headers and missing session mutations', async () => {
    expect((await app.inject({ url: '/api/workspace', headers: { host: 'evil.example' } })).statusCode).toBe(
      403,
    );
    expect(
      (await app.inject({ url: '/api/workspace', headers: { origin: 'https://evil.example' } })).statusCode,
    ).toBe(403);
    expect(
      (
        await app.inject({
          method: 'PUT',
          url: '/api/document',
          payload: { path: 'README.md', content: 'x', baseRevision: 'x' },
        })
      ).statusCode,
    ).toBe(403);
    expect(
      (
        await app.inject({
          method: 'PUT',
          url: '/api/document',
          headers: { ...headers(), origin: 'http://localhost:9999' },
          payload: { path: 'README.md', content: 'x', baseRevision: 'x' },
        })
      ).statusCode,
    ).toBe(403);
  });
  it('rejects a tracked symlink escaping the workspace', async () => {
    const outside = await mkdtemp(path.join(tmpdir(), 'harness-web-outside-'));
    try {
      await writeFile(path.join(outside, 'outside.md'), 'outside secret');
      await symlink(outside, path.join(root, 'linked'), 'junction');
      const response = await app.inject('/api/document?path=linked%2Foutside.md');
      expect(response.statusCode).toBeGreaterThanOrEqual(400);
    } finally {
      await rm(path.join(root, 'linked'), { force: true, recursive: true });
      await rm(outside, { force: true, recursive: true });
    }
  });
  it('serializes competing saves so exactly one succeeds', async () => {
    const current = (await app.inject('/api/document?path=README.md')).json();
    const results = await Promise.all(
      ['One', 'Two'].map((value) =>
        app.inject({
          method: 'PUT',
          url: '/api/document',
          headers: headers(),
          payload: {
            path: 'README.md',
            content: current.content.replace('Edited paragraph.', `${value} paragraph.`),
            baseRevision: current.revision,
          },
        }),
      ),
    );
    expect(results.map((result) => result.statusCode).sort()).toEqual([200, 409]);
  });
  it('keeps document reading available when the packaged CLI is absent', async () => {
    const offline = await createApp({
      workspaceRoot: root,
      watch: false,
      cliPath: path.join(root, 'missing.exe'),
    });
    try {
      expect((await offline.inject('/api/workspace')).json().cliAvailable).toBe(false);
      expect((await offline.inject('/api/document?path=README.md')).statusCode).toBe(200);
      expect((await offline.inject('/api/tasks?change=demo%2Ffeature-test-ready')).statusCode).toBe(503);
    } finally {
      await offline.close();
    }
  });
  it.skipIf(process.platform !== 'win32')(
    'rejects a native-watch override before acquiring Windows handles',
    async () => {
      vi.stubEnv('CHOKIDAR_USEPOLLING', '0');
      try {
        await expect(createApp({ workspaceRoot: root, watch: true })).rejects.toMatchObject({
          code: 'WATCH_CONFIGURATION',
        });
        expect(process.env.CHOKIDAR_USEPOLLING).toBe('0');
      } finally {
        vi.unstubAllEnvs();
      }
    },
  );
  it('allows native OpenSpec archive moves while running and invalidates documents after the move', async () => {
    const fixtureRoot = await createFixture();
    let live: Awaited<ReturnType<typeof createApp>> | undefined;
    const abort = new AbortController();
    const source = 'openspec/changes/demo/feature-test-ready';
    const target = 'openspec/archive/changes/demo/2026-09-05-feature-test-ready';
    try {
      const tasksFile = path.join(fixtureRoot, source, 'tasks.md');
      await writeFile(tasksFile, (await readFile(tasksFile, 'utf8')).replaceAll('- [ ]', '- [x]'));
      const closure = path.join(fixtureRoot, 'closure.yaml');
      await writeFile(closure, 'kind: completed\n');
      live = await createApp({ workspaceRoot: fixtureRoot, watch: true });
      await live.listen({ host: '127.0.0.1', port: 0 });
      const address = live.server.address();
      if (!address || typeof address === 'string') throw new Error('Expected local address');
      const response = await fetch(`http://127.0.0.1:${address.port}/api/events`, { signal: abort.signal });
      const reader = response.body!.getReader();
      await reader.read();
      expect(
        (await live.inject('/api/documents'))
          .json()
          .some((item: { path: string }) => item.path === `${source}/proposal.md`),
      ).toBe(true);
      const output = execFileSync(
        path.join(fixtureRoot, '.agents/skills/openspec/bin/openspec.exe'),
        [
          'change',
          'archive',
          'demo/feature-test-ready',
          '--date',
          '2026-09-05',
          '--closure-file',
          closure,
          '--json',
        ],
        { cwd: fixtureRoot, encoding: 'utf8', windowsHide: true, timeout: 15000 },
      );
      expect(JSON.parse(output)).toMatchObject({ archive_id: 'demo/2026-09-05-feature-test-ready' });
      const invalidation = await Promise.race([
        reader.read(),
        new Promise<never>((_, reject) =>
          setTimeout(
            () => reject(new Error('Archive did not invalidate the document catalog')),
            5000,
          ).unref(),
        ),
      ]);
      expect(new TextDecoder().decode(invalidation.value)).toContain('event: invalidate');
      await expect
        .poll(
          async () =>
            (await live!.inject('/api/documents'))
              .json()
              .some((item: { path: string }) => item.path === `${target}/proposal.md`),
          { timeout: 5000 },
        )
        .toBe(true);
      expect(
        (await live.inject('/api/documents'))
          .json()
          .some((item: { path: string }) => item.path.startsWith(`${source}/`)),
      ).toBe(false);
      // Updating this isolated historical fixture proves continued polling; production archives stay read-only through the API.
      expect((await live.inject('/api/search?q=postmoveunique')).json()).toEqual([]);
      await writeFile(
        path.join(fixtureRoot, target, 'proposal.md'),
        '# Archived proposal\n\npostmoveunique\n',
      );
      await expect
        .poll(async () => (await live!.inject('/api/search?q=postmoveunique')).json(), { timeout: 5000 })
        .toEqual([
          { path: `${target}/proposal.md`, title: 'Archived proposal', excerpt: 'postmoveunique', line: 3 },
        ]);
    } finally {
      abort.abort();
      await live?.close();
      await rm(fixtureRoot, { recursive: true, force: true });
    }
  });
  it('invalidates searches and emits SSE after an external Chinese document edit', async () => {
    const live = await createApp({ workspaceRoot: root, watch: true });
    const abort = new AbortController();
    try {
      await live.listen({ host: '127.0.0.1', port: 0 });
      const address = live.server.address();
      if (!address || typeof address === 'string') throw new Error('Expected local address');
      const response = await fetch(`http://127.0.0.1:${address.port}/api/events`, { signal: abort.signal });
      expect(response.status).toBe(200);
      const reader = response.body!.getReader();
      await reader.read();
      expect((await live.inject('/api/search?q=%E4%BF%AE%E6%94%B9')).json()).toEqual([]);
      await file('Chinese.md', '# 观察笔记\n\n外部修改会刷新搜索索引。\n');
      const event = await Promise.race([
        reader.read(),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error('No file invalidation received')), 5000).unref(),
        ),
      ]);
      expect(new TextDecoder().decode(event.value)).toContain('event: invalidate');
      const result = (await live.inject('/api/search?q=%E4%BF%AE%E6%94%B9')).json();
      expect(result).toEqual([
        { path: 'Chinese.md', title: '观察笔记', excerpt: '外部修改会刷新搜索索引。', line: 3 },
      ]);
    } finally {
      abort.abort();
      await live.close();
    }
  });
  it('includes initialized studio submodules but excludes external submodule documents', async () => {
    for (const name of ['Owned', 'Community']) {
      const module = path.join(root, 'Modules', name);
      await mkdir(module, { recursive: true });
      execFileSync('git', ['init', '--quiet', module]);
      execFileSync('git', ['-C', module, 'config', 'core.autocrlf', 'false']);
      await writeFile(path.join(module, 'README.md'), `# ${name} module\n`);
      execFileSync('git', ['-C', module, 'add', 'README.md']);
      execFileSync('git', [
        '-C',
        module,
        '-c',
        'user.name=Fixture',
        '-c',
        'user.email=fixture@example.invalid',
        'commit',
        '--quiet',
        '-m',
        'Fixture',
      ]);
      const commit = execFileSync('git', ['-C', module, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
      execFileSync('git', [
        '-C',
        root,
        'update-index',
        '--add',
        '--cacheinfo',
        `160000,${commit},Modules/${name}`,
      ]);
    }
    await file(
      '.gitmodules',
      '[submodule "owned"]\n\tpath = Modules/Owned\n\turl = https://github.com/TDGameStudio/Owned.git\n[submodule "community"]\n\tpath = Modules/Community\n\turl = https://github.com/Somebody/Community.git\n',
    );
    const modules = await createApp({ workspaceRoot: root, watch: false });
    try {
      const documents = (await modules.inject('/api/documents')).json();
      expect(
        documents.some((document: { path: string }) => document.path === 'Modules/Owned/README.md'),
      ).toBe(true);
      expect(
        documents.some((document: { path: string }) => document.path === 'Modules/Community/README.md'),
      ).toBe(false);
      expect((await modules.inject('/api/document?path=Modules%2FCommunity%2FREADME.md')).statusCode).toBe(
        404,
      );
    } finally {
      await modules.close();
    }
  });
});
