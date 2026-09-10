import { expect, test, type Page, type APIRequestContext } from '@playwright/test';
import { readFile, realpath, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { tmpdir } from 'node:os';
import { original } from '../adapter/fixture.js';

// Every filesystem mutation below must first prove it targets our temporary fixture.
async function fixtureRoot(request: APIRequestContext) {
  const workspace = await (await request.get('/api/workspace')).json();
  const root = await realpath(workspace.root);
  expect(path.dirname(root).toLowerCase()).toBe((await realpath(tmpdir())).toLowerCase());
  expect(path.basename(root)).toMatch(/^harness-web-adapter-/);
  return root;
}
async function openEditor(page: Page, file = 'README.md') {
  await page.goto(`/documents?path=${encodeURIComponent(file)}&mode=edit`);
  const body = page.getByLabel('文档正文').first();
  await expect(body).toBeVisible();
  await expect(page.locator('.editor-document-body')).not.toHaveAttribute('inert');
  return body;
}
test.beforeEach(async ({ request }) => {
  await writeFile(path.join(await fixtureRoot(request), 'README.md'), original);
});

test('dashboard search opens the actual indexed document', async ({ page }) => {
  const failures: string[] = [];
  page.on('pageerror', (error) => failures.push(error.message));
  await page.goto('/');
  await expect(page.getByRole('navigation', { name: '主导航' })).toBeVisible();
  await expect(page.locator('.recharts-surface').first()).toBeVisible();
  await page.keyboard.press('Control+k');
  await page.getByLabel('全局搜索').fill('Architecture');
  await expect(page.getByRole('option').first()).toContainText('notes/design.md');
  await page.keyboard.press('Enter');
  await expect(page).toHaveURL(/path=notes%2Fdesign.md/);
  await expect(page.locator('.markdown-body').getByRole('heading', { name: 'Architecture' })).toBeVisible();
  await expect(page.locator('.mermaid-preview svg')).toBeVisible();
  expect(failures).toEqual([]);
});

test('task selection survives board list and DAG and links to the native source line', async ({
  page,
}, info) => {
  await page.goto('/tasks?change=demo%2Ffeature-test-ready&view=board');
  await page.getByRole('button', { name: '2.1 Implement', exact: true }).click();
  await expect(page.locator('.task-detail')).toContainText('node --version');
  await expect(page.locator('.task-detail')).toContainText('Prepare');
  await page.getByRole('button', { name: '列表', exact: true }).click();
  await expect(page).toHaveURL(/task=2.1/);
  await page.getByRole('button', { name: '依赖图', exact: true }).click();
  await expect(page.locator('.react-flow__node')).toHaveCount(3);
  await expect(page.locator('.task-detail')).toContainText('Implement');
  await page.screenshot({ path: info.outputPath('task-dependencies.png'), fullPage: true });
  await page.getByRole('button', { name: /查看任务源文档/ }).click();
  await expect(page).toHaveURL(/line=13/);
  await expect(page.locator('.markdown-body li.source-highlight[data-line="13"]')).toContainText(
    '2.1 Implement',
  );
  await expect(page.locator('.markdown-body input[type="checkbox"]').first()).toBeDisabled();
});

test('real WYSIWYG saves prose while preserving original frontmatter and CRLF', async ({ page, request }) => {
  const body = await openEditor(page);
  await body.getByText('Original paragraph.', { exact: true }).click();
  await body.press('Control+End');
  await page.keyboard.insertText(' Edited in the browser.');
  await expect(page.getByRole('button', { name: '保存文档' })).toBeEnabled();
  await page.getByRole('button', { name: '查看差异' }).click();
  await expect(page.getByRole('region', { name: '文档差异' })).toContainText('Edited in the browser.');
  await page.getByRole('button', { name: '保存文档' }).click();
  await expect(page.getByText('已保存', { exact: true })).toBeVisible();
  const saved = await (await request.get('/api/document?path=README.md')).json();
  expect(saved.content).toContain('---\r\ntitle: Preserved\r\n---\r\n');
  expect(saved.content).toContain('Original paragraph. Edited in the browser.');
  expect(saved.content.replaceAll('\r\n', '')).not.toContain('\n');
  await page.getByRole('button', { name: '阅读', exact: true }).click();
  await expect(page.locator('.markdown-body')).toContainText('Edited in the browser.');
});

test('editing task prose retains native DAG identity readiness and machine fields', async ({
  page,
  request,
}) => {
  const file = 'openspec/changes/demo/feature-test-ready/tasks.md';
  const before = await (await request.get(`/api/document?path=${encodeURIComponent(file)}`)).json();
  const body = await openEditor(page, file);
  await body.getByText('Write the integration note.', { exact: true }).click();
  await body.press('Control+End');
  await page.keyboard.insertText(' Verified through the browser.');
  await expect(page.getByRole('button', { name: '保存文档' })).toBeEnabled();
  await page.keyboard.press('Control+s');
  await expect(page.getByText('已保存', { exact: true })).toBeVisible();
  const after = await (await request.get(`/api/document?path=${encodeURIComponent(file)}`)).json();
  const machine = (text: string) =>
    text.split('\n').filter((line) => line.startsWith('- [') || line.startsWith('  > Files:'));
  expect(machine(after.content)).toEqual(machine(before.content));
  expect(after.content.split('---')[1]).toBe(before.content.split('---')[1]);
  expect(after.content).toContain('  Write the integration note. Verified through the browser.');
  const plan = await (await request.get('/api/tasks?change=demo%2Ffeature-test-ready')).json();
  expect(plan.tasks.map((task: { id: string; ready: boolean }) => [task.id, task.ready])).toEqual([
    ['1.1', false],
    ['2.1', true],
    ['3.1', false],
  ]);
});

test('external revisions preserve browser drafts across navigation and prevent overwrite', async ({
  page,
  request,
}) => {
  const body = await openEditor(page);
  await body.fill('Private draft retained.');
  await expect(page.getByRole('button', { name: '保存文档' })).toBeEnabled();
  const root = await fixtureRoot(request);
  const external = original.replace('Original paragraph.', 'External revision.');
  await writeFile(path.join(root, 'README.md'), external);
  await expect(page.getByRole('alert')).toContainText('你的草稿已保留');
  await expect(body).toContainText('Private draft retained.');
  await expect(page.getByRole('button', { name: '保存文档' })).toBeDisabled();
  expect(await readFile(path.join(root, 'README.md'), 'utf8')).toBe(external);
  await page
    .getByRole('navigation', { name: '主导航' })
    .getByRole('link', { name: '工作台', exact: true })
    .click();
  const restored = await openEditor(page);
  await expect(restored).toContainText('Private draft retained.');
  await expect(page.getByRole('alert')).toContainText('你的草稿已保留');
  await page.getByRole('button', { name: '放弃草稿并载入磁盘版' }).click();
  await expect(page.getByLabel('文档正文').first()).toContainText('External revision.');
});

test('manual conflict merge adopts the disk revision only after an explicit save', async ({
  page,
  request,
}) => {
  const body = await openEditor(page);
  await body.fill('My retained paragraph.');
  const root = await fixtureRoot(request);
  const external = original.replace('Original paragraph.', 'External paragraph.');
  await writeFile(path.join(root, 'README.md'), external);
  await expect(page.getByRole('alert')).toContainText('你的草稿已保留');
  await page.getByRole('button', { name: '以磁盘版本为基准继续合并' }).click();
  await expect(page.getByRole('region', { name: '文档差异' })).toContainText('External paragraph.');
  await expect(body).toContainText('My retained paragraph.');
  expect(await readFile(path.join(root, 'README.md'), 'utf8')).toBe(external);
  await body.press('Control+End');
  await page.keyboard.insertText(' External paragraph.');
  await page.getByRole('button', { name: '保存文档' }).click();
  await expect(page.getByText('已保存', { exact: true })).toBeVisible();
  const saved = await readFile(path.join(root, 'README.md'), 'utf8');
  expect(saved).toContain('---\r\ntitle: Preserved\r\n---\r\n');
  expect(saved).toContain('My retained paragraph. External paragraph.');
});

test('document filters and keyboard resized panels survive navigation and reload', async ({ page }) => {
  await page.goto('/documents?path=README.md&q=README');
  const handle = page.getByRole('separator', { name: '调整面板宽度' });
  await expect(handle).toHaveAttribute('aria-valuenow', '24');
  await handle.focus();
  await page.keyboard.press('ArrowRight');
  await expect(handle).toHaveAttribute('aria-valuenow', '29');
  const nav = page.getByRole('navigation', { name: '主导航' });
  await nav.getByRole('link', { name: '工作台', exact: true }).click();
  await expect(page.locator('.recharts-surface').first()).toBeVisible();
  await nav.getByRole('link', { name: '文档', exact: true }).click();
  await expect(page.getByLabel('筛选文档')).toHaveValue('README');
  await expect(page).toHaveURL(/path=README.md/);
  await expect(handle).toHaveAttribute('aria-valuenow', '29');
  await page.reload();
  await expect(handle).toHaveAttribute('aria-valuenow', '29');
  await page.goto('/documents?path=notes%2Fdesign.md');
  await expect(page.getByLabel('筛选文档')).toHaveValue('');
  await expect(page.locator('.markdown-body').getByRole('heading', { name: 'Architecture' })).toBeVisible();
});

test('archives remain read-only and specification links stay inside document navigation', async ({
  page,
}) => {
  await page.goto(
    '/documents?path=openspec%2Farchive%2Fchanges%2Fdemo%2F2026-09-02-feature-test-history%2Fproposal.md&mode=edit',
  );
  await expect(page.locator('.markdown-body')).toContainText('Frozen history');
  await expect(page.locator('.readonly-note')).toContainText('历史归档');
  await expect(page.getByRole('button', { name: '编辑', exact: true })).toHaveCount(0);
  await page.goto('/specs?path=openspec%2Fspecs%2Fdemo%2Fworkbench%2Fspec.md');
  await expect(page.locator('.markdown-body')).toContainText('Local browsing');
  await page.getByRole('link', { name: 'Writing notes' }).click();
  await expect(page).toHaveURL(/path=notes%2Fdesign.md/);
});

test('themes persist and narrow navigation remains usable without page overflow', async ({ page }, info) => {
  await page.goto('/');
  await expect(page.locator('.recharts-surface').first()).toBeVisible();
  await page.screenshot({ path: info.outputPath('light-workbench.png'), fullPage: true });
  await page.getByRole('button', { name: '切换深色主题' }).click();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await page.reload();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await expect(page.locator('.recharts-surface').first()).toBeVisible();
  await page.screenshot({ path: info.outputPath('dark-workbench.png'), fullPage: true });
  await page.setViewportSize({ width: 375, height: 812 });
  await page.getByRole('button', { name: '打开导航' }).click();
  await page
    .getByRole('navigation', { name: '主导航' })
    .getByRole('link', { name: '归档', exact: true })
    .click();
  await expect(page).toHaveURL(/\/archives/);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
  await page.screenshot({ path: info.outputPath('mobile-archives.png'), fullPage: true });
});

test('record files use a vertical explorer and give desktop space to the selected document', async ({
  page,
  request,
}, info) => {
  const records = await (await request.get('/api/records?kind=change')).json();
  const record = records.find((item: { id: string }) => item.id === 'demo/feature-test-ready');
  await page.setViewportSize({ width: 1600, height: 1100 });
  await page.goto(`/changes?domain=demo&q=feature-test&selected=${encodeURIComponent(record.key)}`);
  const files = page.getByRole('navigation', { name: '记录文档' });
  await expect(files).toBeVisible();
  await expect(files.getByRole('button', { name: 'proposal.md', exact: true })).toHaveAttribute(
    'aria-current',
    'page',
  );
  await expect(page.locator('.records-index')).toHaveCount(0);
  await files.getByRole('button', { name: 'tasks.md', exact: true }).click();
  await expect(page).toHaveURL(/doc=openspec%2Fchanges%2Fdemo%2Ffeature-test-ready%2Ftasks.md/);
  await expect(files.getByRole('button', { name: 'tasks.md', exact: true })).toHaveAttribute(
    'aria-current',
    'page',
  );
  const body = page.locator('.record-document-content .markdown-body');
  await expect(body).toContainText('2.1 Implement');
  const rect = await body.boundingBox();
  expect(rect!.x).toBeLessThan(600);
  expect(rect!.y).toBeLessThan(420);
  expect(rect!.width).toBeGreaterThan(800);
  const gutters = await page.locator('.records-page').evaluate((element) => {
    const style = getComputedStyle(element);
    return [parseFloat(style.paddingLeft), parseFloat(style.paddingRight)];
  });
  expect(gutters.every((value) => value <= 28)).toBe(true);
  await page.screenshot({ path: info.outputPath('record-explorer-desktop.png'), fullPage: true });
  await page.getByLabel('筛选记录文档').fill('specs/demo/workbench');
  await files.getByRole('button', { name: 'spec.md', exact: true }).click();
  await expect(body).toContainText('Delta document');
  await page.getByLabel('筛选记录文档').fill('integration-verification-with-expanded-scope');
  await files
    .getByRole('button', { name: 'integration-verification-with-expanded-scope.md', exact: true })
    .click();
  await expect(body).toContainText('Expanded verification');
  await page.setViewportSize({ width: 375, height: 812 });
  const picker = files.getByRole('button', { name: /^选择文档/ });
  await expect(picker).toHaveAttribute('aria-expanded', 'false');
  await picker.click();
  await page.getByLabel('筛选记录文档').fill('browser-evidence');
  await files.getByRole('button', { name: 'browser-evidence.md', exact: true }).click();
  await expect(picker).toHaveAttribute('aria-expanded', 'false');
  await expect(body).toContainText('Browser evidence');
  expect((await body.boundingBox())!.y).toBeLessThan(500);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1)).toBe(true);
  await page.screenshot({ path: info.outputPath('record-explorer-mobile.png'), fullPage: true });
  await page.getByRole('button', { name: '返回记录', exact: true }).click();
  await expect(page.getByLabel('筛选记录')).toHaveValue('feature-test');
  await expect(page.getByLabel('筛选领域')).toHaveValue('demo');
  await expect(page.locator('.records-index')).toBeVisible();
});

test('narrow document panes prioritize reading and mobile file selection preserves the live editor', async ({
  page,
}) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto('/documents?path=README.md');
  const article = page.locator('.markdown-body');
  await expect(article).toContainText('Original paragraph.');
  expect((await article.boundingBox())!.width).toBeGreaterThan(600);
  await expect(page.locator('.document-outline')).toBeHidden();
  await page.setViewportSize({ width: 375, height: 812 });
  const picker = page.getByRole('button', { name: /^选择工作区文档/ });
  await expect(picker).toHaveAttribute('aria-expanded', 'false');
  // Resizing transitions the desktop sidebar out; measure the settled responsive layout.
  await expect.poll(async () => (await article.boundingBox())!.y).toBeLessThan(420);
  await page.getByRole('button', { name: '编辑', exact: true }).click();
  const body = page.getByLabel('文档正文').first();
  await expect(body).toBeVisible();
  await expect(page.locator('.editor-document-body')).not.toHaveAttribute('inert');
  await body.fill('Draft survives the mobile file picker.');
  await picker.click();
  await expect(page.getByLabel('筛选文档')).toBeVisible();
  await picker.click();
  await expect(body).toContainText('Draft survives the mobile file picker.');
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1)).toBe(true);
});
