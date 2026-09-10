import { mkdtemp, mkdir, writeFile, copyFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

export const original =
  '---\r\ntitle: Preserved\r\n---\r\n# Engineering notes\r\n\r\nOriginal paragraph.\r\n';

export async function createFixture() {
  const root = await mkdtemp(path.join(tmpdir(), 'harness-web-adapter-'));
  async function file(relative: string, content: string) {
    const target = path.join(root, relative);
    await mkdir(path.dirname(target), { recursive: true });
    await writeFile(target, content);
  }
  execFileSync('git', ['init', '--quiet', root]);
  execFileSync('git', ['-C', root, 'config', 'core.autocrlf', 'false']);
  await file('.gitignore', 'ignored/\n');
  await file('README.md', original);
  await file('Reference/upstream.md', '# Never indexed\nexternal-secret');
  await file('src/vendor/package/README.md', '# Never indexed\nvendor-secret');
  await file('ignored/private.md', '# Never indexed\nignored-secret');
  await file(
    'openspec/project.yaml',
    'api_version: openspec.dev/v1\nkind: project\nmetadata:\n  uid: project_a14b24a4-65c2-4ef8-b157-bfe194796300\n  id: fixture\n  title: Fixture\ndefault_workflow: fixture\n',
  );
  await mkdir(path.join(root, 'openspec/specs'), { recursive: true });
  await file(
    'openspec/workflows/fixture/workflow.yaml',
    'name: fixture\nversion: 1\ndescription: Fixture\nartifacts:\n- id: proposal\n  generates: proposal.md\n  description: Proposal\n  template: proposal.md\n  required: true\n  requires: []\n- id: tasks\n  generates: tasks.md\n  description: Tasks\n  template: tasks.md\n  required: true\n  requires: []\napply:\n  requires: [tasks]\n  tracks: tasks.md\narchive:\n  requires: [proposal, tasks]\nvalidation:\n  profile: record-v1\n',
  );
  await file('openspec/workflows/fixture/templates/proposal.md', '# Proposal\n');
  await file('openspec/workflows/fixture/templates/tasks.md', '# Tasks\n');
  await file(
    'openspec/domains/demo/domain.yaml',
    'api_version: openspec.dev/v1\nkind: domain\nmetadata:\n  uid: domain_1413c08a-aead-4445-b267-dc46c4488601\n  id: demo\n  title: Demo domain\n',
  );
  for (const [id, uid] of [
    ['feature-test-ready', '4b691cb8-c1d3-4c5a-99d9-c78a09c17faa'],
    ['feature-test-planning', '4b691cb8-c1d3-4c5a-99d9-c78a09c17fab'],
    ['feature-test-invalid', '4b691cb8-c1d3-4c5a-99d9-c78a09c17fac'],
  ]) {
    await file(
      `openspec/changes/demo/${id}/change.yaml`,
      `api_version: openspec.dev/v1\nkind: change\nmetadata:\n  uid: change_${uid}\n  id: demo/${id}\n  title: ${id}\nworkflow: fixture\ncreated_at: 2026-09-01T00:00:00Z\n`,
    );
    await file(`openspec/changes/demo/${id}/proposal.md`, '# Proposal\n\nWork remains.\n');
  }
  await file(
    'openspec/changes/demo/feature-test-ready/tasks.md',
    '---\ntask_graph:\n  version: 1\n  depends_on:\n    "1.1": []\n    "2.1": ["1.1"]\n    "3.1": ["2.1"]\n---\n\n- [x] 1.1 Prepare — verify: `node --version`\n  > Files: `README.md`\n\n- [ ] 2.1 Implement — verify: `node --version`\n  > Files: `README.md`\n\n- [ ] 3.1 Integrate — verify: `node --version`\n  > Files: `README.md`\n',
  );
  await file(
    'openspec/changes/demo/feature-test-invalid/tasks.md',
    '---\ntask_graph:\n  version: 1\n  depends_on:\n    "1.1": ["1.1"]\n---\n\n- [ ] 1.1 Cycle — verify: `node --version`\n  > Files: `README.md`\n',
  );
  await file(
    'openspec/archive/changes/demo/2026-09-02-feature-test-history/change.yaml',
    'api_version: openspec.dev/v1\nkind: change\nmetadata:\n  uid: change_0b45eb32-94fb-4bd8-8e7f-6a510b5becfe\n  id: demo/feature-test-history\n  title: Archived history\nworkflow: fixture\ncreated_at: 2026-09-01T00:00:00Z\narchived_at: 2026-09-02T00:00:00Z\narchive_schema: closure-v1\nclosure:\n  kind: completed\n',
  );
  await file(
    'openspec/archive/changes/demo/2026-09-02-feature-test-history/proposal.md',
    '# Frozen history\n',
  );
  await file(
    'openspec/changes/demo/feature-test-ready/attachments/replans/replan-example.md',
    '# Applied replan\n',
  );
  execFileSync('git', ['-C', root, 'add', '.']);
  const binary = path.resolve(
    path.dirname(fileURLToPath(import.meta.url)),
    '../../../../.agents/skills/openspec/bin/openspec.exe',
  );
  const target = path.join(root, '.agents/skills/openspec/bin/openspec.exe');
  await mkdir(path.dirname(target), { recursive: true });
  await copyFile(binary, target);
  return root;
}
