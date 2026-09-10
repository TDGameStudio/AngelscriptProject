import { mkdir, writeFile, readFile, realpath, rm } from 'node:fs/promises';
import path from 'node:path';
import { tmpdir } from 'node:os';
import { createFixture } from '../adapter/fixture.js';
import { createApp } from '../../src/server/app.js';

// Browser tests use the actual server and packaged CLI against one isolated Git workspace.
const workspaceRoot = await createFixture();
async function file(relative: string, content: string) {
  const target = path.join(workspaceRoot, relative);
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, content);
}
await file(
  'notes/design.md',
  '# Design notebook\n\nA document for visual writing.\n\n## Architecture\n\n- Local workspace\n- Portable records\n\n| Layer | Role |\n| --- | --- |\n| Web | Explore |\n| Documents | Author |\n\n```mermaid\nflowchart LR\n  Documents --> Workbench\n  OpenSpec --> Workbench\n```\n',
);
const taskPath = 'openspec/changes/demo/feature-test-ready/tasks.md';
const taskSource = await readFile(path.join(workspaceRoot, taskPath), 'utf8');
await file(
  taskPath,
  taskSource.replace(
    '- [ ] 2.1 Implement — verify: `node --version`\n  > Files: `README.md`\n',
    '- [ ] 2.1 Implement — verify: `node --version`\n  > Files: `README.md`\n\n  Write the integration note.\n',
  ),
);
await file(
  'openspec/specs/demo/workbench/spec.yaml',
  'api_version: openspec.dev/v1\nkind: spec\nmetadata:\n  uid: spec_739aaeb2-bc99-4631-9984-fb7c5c1e409c\n  id: demo/workbench\n  title: Workspace browsing\n',
);
await file(
  'openspec/specs/demo/workbench/spec.md',
  '# Workspace browsing\n\n## Requirements\n\n### Requirement: Local browsing\n\nThe workbench SHALL display project documents.\n\n#### Scenario: Open a document\n- **WHEN** a document is selected\n- **THEN** its contents are visible\n\n[Writing notes](../../../../notes/design.md)\n',
);
await file(
  'openspec/changes/demo/feature-test-ready/specs/demo/workbench/spec.md',
  '# Delta document\n\nNested specification content remains reachable from the Change.\n',
);
await file(
  'openspec/changes/demo/feature-test-ready/attachments/data/browser-evidence.md',
  '# Browser evidence\n\nThe file explorer keeps this evidence beside its Change.\n',
);
await file(
  'openspec/changes/demo/feature-test-ready/attachments/data/integration-verification-with-expanded-scope.md',
  '# Expanded verification\n\nLong document names remain distinguishable and selectable.\n',
);
const app = await createApp({ workspaceRoot, watch: true, frontend: 'production' });
await app.listen({ host: '127.0.0.1', port: 4320 });
let closing = false;
async function close() {
  if (closing) return;
  closing = true;
  await app.close();
  const actual = await realpath(workspaceRoot);
  const parent = await realpath(tmpdir());
  if (
    path.dirname(actual).toLowerCase() === parent.toLowerCase() &&
    path.basename(actual).startsWith('harness-web-adapter-')
  ) {
    await rm(actual, { recursive: true, force: true });
  }
  process.exit(0);
}
process.on('SIGINT', () => void close());
process.on('SIGTERM', () => void close());
