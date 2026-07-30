# More Sidebar Typography Preview Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline, interactive HTML preview that compares the current More-sidebar typography with the approved “quiet index panel” treatment across all eleven real categories.

**Architecture:** Keep the experiment isolated under `Wiki/comparison-artifacts/more-sidebar-layout/`. A single HTML file owns representative data, semantic markup, inline CSS, and inline JavaScript; a colocated Node test opens the file in Chromium and verifies the interaction and overflow contract without registering the experiment in the normal package test layers.

**Tech Stack:** HTML5, CSS custom properties, vanilla JavaScript, Node test runner, `@playwright/test` Chromium.

## Global Constraints

- Preserve the current More palette exactly: `#edf3f7`, `#dbe4ec`, `#45566a`, `#667589`, `#236c99`, and `#e6f1f7`.
- Preserve the 84px category column and 1px divider in both comparison modes.
- Include exactly eleven categories: 全部、最近、标签、缺失、草稿、孤立、类型、系统、默认、探索、插件.
- Default to 插件 and 优化版.
- Keep all CSS, JavaScript, icons, and data inline; load no remote dependency.
- Do not modify production Wiki source, `new_review2.html`, package scripts, or the normal test registry.
- Keep the preview and its local contract uncommitted until user visual review.

---

### Task 1: Define the preview-local browser contract

**Files:**
- Create: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs`
- Test: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs`

**Interfaces:**
- Consumes: `more-sidebar-typography-preview.html` through a `file:///` URL.
- Produces: A preview-local contract for semantic tabs, mode switching, keyboard navigation, offline assets, and overflow.

- [ ] **Step 1: Create the failing test**

```js
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { pathToFileURL } from 'node:url';

import { chromium } from '@playwright/test';

const previewPath = resolve(
  import.meta.dirname,
  'more-sidebar-typography-preview.html',
);

test('contains an offline eleven-category comparison surface', () => {
  assert.equal(existsSync(previewPath), true, 'Preview HTML is missing');
  const source = readFileSync(previewPath, 'utf8');
  assert.doesNotMatch(source, /https?:\/\//);
  assert.match(source, /data-mode="optimized"/);
  assert.match(source, /role="tablist"/);
});

test('switches all categories and modes without overflow', async () => {
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1100, height: 820 } });
    await page.goto(pathToFileURL(previewPath).href);

    const tabs = page.locator('[data-more-tabs] > [role="tab"]');
    await assert.doesNotReject(async () => {
      assert.equal(await tabs.count(), 11);
    });
    await page.locator('[role="tab"][aria-selected="true"]').waitFor();
    assert.equal(
      (await page.locator('[role="tab"][aria-selected="true"]').textContent())?.trim(),
      '插件',
    );

    for (const tab of await tabs.all()) {
      await tab.click();
      assert.equal(await page.locator('[role="tabpanel"]:visible').count(), 1);
    }

    await page.getByRole('tab', { name: '插件', exact: true }).focus();
    await page.keyboard.press('Home');
    assert.equal(
      (await page.locator('[role="tab"][aria-selected="true"]').textContent())?.trim(),
      '全部',
    );
    await page.keyboard.press('End');
    assert.equal(
      (await page.locator('[role="tab"][aria-selected="true"]').textContent())?.trim(),
      '插件',
    );

    await page.getByRole('button', { name: '当前版', exact: true }).click();
    await page.locator('[data-preview-shell][data-mode="current"]').waitFor();
    await page.getByRole('button', { name: '优化版', exact: true }).click();
    await page.locator('[data-preview-shell][data-mode="optimized"]').waitFor();

    for (const width of [1100, 360]) {
      await page.setViewportSize({ width, height: 820 });
      const overflow = await page.locator('[data-preview-shell]').evaluate(element => ({
        document: document.documentElement.scrollWidth - document.documentElement.clientWidth,
        shell: element.scrollWidth - element.clientWidth,
      }));
      assert.ok(overflow.document <= 1);
      assert.ok(overflow.shell <= 1);
    }
  } finally {
    await browser.close();
  }
});
```

- [ ] **Step 2: Run the contract to verify RED**

Run:

```powershell
node --test comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs
```

Expected: FAIL with `Preview HTML is missing`.

### Task 2: Build the semantic single-file preview

**Files:**
- Create: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.html`
- Test: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs`

**Interfaces:**
- Consumes: No runtime dependency; representative data is embedded in `previewData`.
- Produces:
  - `selectTab(tabId: string, focus?: boolean): void`
  - `setMode(mode: 'current' | 'optimized'): void`
  - semantic tab and tabpanel elements generated from `previewData`.

- [ ] **Step 1: Add the document shell and exact data schema**

The inline script must define these eleven records in this order:

```js
const previewData = [
  { id: 'all', label: '全部', kind: 'list', count: 24, items: [] },
  { id: 'recent', label: '最近', kind: 'timeline', count: 8, groups: [] },
  { id: 'tags', label: '标签', kind: 'tags', count: 7, tags: [] },
  { id: 'missing', label: '缺失', kind: 'list', count: 3, items: [] },
  { id: 'drafts', label: '草稿', kind: 'empty', count: 0, message: '没有草稿' },
  { id: 'orphans', label: '孤立', kind: 'list', count: 4, items: [] },
  { id: 'types', label: '类型', kind: 'groups', count: 4, groups: [] },
  { id: 'system', label: '系统', kind: 'groups', count: 4, groups: [] },
  { id: 'shadows', label: '默认', kind: 'system-list', count: 18, items: [] },
  { id: 'explorer', label: '探索', kind: 'tree', count: 12, nodes: [] },
  { id: 'plugins', label: '插件', kind: 'plugins', count: 8, plugins: [] },
];
```

Populate every array with representative real AngelscriptWiki names from the design review:

- ordinary titles such as `AngelscriptWikiHome`, `语法展示范式`, and `AS/Workflow/GettingStarted`;
- system paths such as `$:/core/ui/SideBar/More` and `$:/plugins/TDGameStudio/angelscript-tools`;
- tags including `ASWiki/Home`, `ASWiki/Workflow`, and one configured colour variant;
- plugin names and descriptions including `commandpalette`, `autocomplete`, `Core`, `draw.io`, `MarkdownMore`, and `TDGameStudio.AngelscriptTools`.

The body must contain:

```html
<main class="review-page">
  <header class="review-header">
    <div>
      <p class="review-kicker">ANGELSCRIPT WIKI · MORE SIDEBAR</p>
      <h1>更多侧栏排版实验</h1>
      <p>保持现有配色，只比较字体层级、列表节奏、分组和换行。</p>
    </div>
    <div class="mode-switch" role="group" aria-label="预览模式">
      <button type="button" data-mode-button="current">当前版</button>
      <button type="button" data-mode-button="optimized" aria-pressed="true">优化版</button>
    </div>
  </header>
  <section class="comparison-stage">
    <aside class="wiki-context" aria-hidden="true">…</aside>
    <section class="more-preview" data-preview-shell data-mode="optimized">
      <div class="more-tabs" role="tablist" aria-label="更多分类" data-more-tabs></div>
      <div class="more-divider"></div>
      <div class="more-content" data-more-content></div>
    </section>
    <aside class="type-legend">…</aside>
  </section>
</main>
```

- [ ] **Step 2: Implement renderers with one shared hierarchy**

Define:

```js
const renderers = {
  list: renderList,
  timeline: renderTimeline,
  tags: renderTags,
  empty: renderEmpty,
  groups: renderGroups,
  'system-list': renderSystemList,
  tree: renderTree,
  plugins: renderPlugins,
};
```

Every renderer returns a panel whose first child in optimized mode is:

```html
<header class="panel-heading">
  <span class="panel-title"></span>
  <span class="panel-count"></span>
</header>
```

Apply these content rules:

- list rows use `.entry-title` and optional `.entry-meta`;
- timeline uses `.group-label`, `.timeline-title`, and `.timeline-time`;
- tags use 4px-radius `.tag-chip` buttons and a separate `.untagged-group`;
- groups use `.group-label` followed by ordinary entries;
- system paths add `.technical`;
- tree rows use `.tree-toggle`, `.tree-icon`, `.tree-label`, `.tree-count`, and `--depth`;
- plugin cards use separate `.plugin-name` and `.plugin-description` elements.

- [ ] **Step 3: Implement both typography modes from the approved tokens**

Shared geometry:

```css
.more-preview {
  --surface: #edf3f7;
  --line: #dbe4ec;
  --ink: #45566a;
  --muted: #667589;
  --accent: #236c99;
  --accent-soft: #e6f1f7;
  display: grid;
  grid-template-columns: 84px 1px minmax(0, 1fr);
  width: min(388px, 100%);
  min-width: 0;
}
```

Current mode must reproduce the reviewed hierarchy:

```css
[data-mode="current"] [role="tab"] { min-height: 30px; font-size: 13px; font-weight: 600; }
[data-mode="current"] .panel-heading { display: none; }
[data-mode="current"] .entry-title,
[data-mode="current"] .timeline-title { font-size: 14px; font-weight: 500; line-height: 1.4; }
[data-mode="current"] .plugin-name,
[data-mode="current"] .plugin-description { display: inline; font-size: 13px; }
[data-mode="current"] .plugin-name { font-weight: 600; }
[data-mode="current"] .plugin-name::after { content: ": "; }
```

Optimized mode must implement the approved hierarchy exactly:

```css
[data-mode="optimized"] [role="tab"] { min-height: 28px; font-size: 12px; font-weight: 400; line-height: 18px; }
[data-mode="optimized"] [role="tab"][aria-selected="true"] { font-weight: 600; }
[data-mode="optimized"] .panel-heading { min-height: 32px; font-size: 12px; font-weight: 600; }
[data-mode="optimized"] .panel-count { font-size: 11px; font-weight: 500; font-variant-numeric: tabular-nums; }
[data-mode="optimized"] .entry-title,
[data-mode="optimized"] .timeline-title { font-size: 13px; font-weight: 400; line-height: 18.5px; }
[data-mode="optimized"] .entry-current,
[data-mode="optimized"] .plugin-name,
[data-mode="optimized"] .tree-directory { font-weight: 500; }
[data-mode="optimized"] .group-label { font-size: 11.5px; font-weight: 500; line-height: 17px; letter-spacing: 0; }
[data-mode="optimized"] .plugin-description,
[data-mode="optimized"] .timeline-time { font-size: 12px; font-weight: 400; line-height: 17.5px; }
[data-mode="optimized"] .technical { font: 400 11.5px/17px "Fira Code", "Cascadia Mono", Consolas, monospace; }
```

- [ ] **Step 4: Implement tab, mode, and tree interactions**

```js
let selectedTabId = 'plugins';
let selectedMode = 'optimized';

function selectTab(tabId, focus = false) {
  selectedTabId = tabId;
  for (const tab of document.querySelectorAll('[role="tab"]')) {
    const selected = tab.dataset.tabId === tabId;
    tab.setAttribute('aria-selected', String(selected));
    tab.tabIndex = selected ? 0 : -1;
    if (selected && focus) tab.focus();
  }
  for (const panel of document.querySelectorAll('[role="tabpanel"]')) {
    panel.hidden = panel.dataset.panelId !== tabId;
  }
}

function setMode(mode) {
  selectedMode = mode;
  document.querySelector('[data-preview-shell]').dataset.mode = mode;
  for (const button of document.querySelectorAll('[data-mode-button]')) {
    button.setAttribute('aria-pressed', String(button.dataset.modeButton === mode));
  }
}
```

The tablist key handler selects the previous/next tab for ArrowUp/ArrowDown, and the first/last tab for Home/End. Tree toggles update `aria-expanded` and the visibility of descendant rows. Mode switching must not reset `selectedTabId`.

- [ ] **Step 5: Add responsive and accessibility finishing rules**

At widths below 700px:

- hide `.wiki-context` and `.type-legend`;
- keep `.more-preview` at `min(388px, 100%)`;
- reduce outer page padding to 12px;
- retain the 84px category column and prevent horizontal overflow.

Add visible `:focus-visible` outlines and:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
```

- [ ] **Step 6: Run the preview-local contract to verify GREEN**

Run:

```powershell
node --test comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs
```

Expected: 2 tests pass.

### Task 3: Inspect the visual result and hand off for review

**Files:**
- Verify: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.html`
- Verify: `Wiki/comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs`

**Interfaces:**
- Consumes: completed preview and local contract.
- Produces: screenshot evidence and a directly openable HTML path for user review.

- [ ] **Step 1: Capture optimized plugin and explorer states**

Use Chromium at `1100×820` to open the file URL, capture optimized 插件, then select 探索 and capture it. Store screenshots only under ignored `Wiki/.generated/review/`.

- [ ] **Step 2: Inspect the screenshots**

Confirm:

- inactive categories are quieter than selected;
- content heading and count establish context without becoming a second navigation bar;
- plugin name and description occupy separate typographic levels;
- explorer directory/file/count baselines align;
- no line clips, overlaps, or horizontal overflow;
- current/optimized comparison changes typography without changing palette.

- [ ] **Step 3: Run final scoped verification**

Run:

```powershell
node --test comparison-artifacts/more-sidebar-layout/more-sidebar-typography-preview.test.mjs
git diff --check -- comparison-artifacts/more-sidebar-layout
```

Expected: 2 tests pass and no whitespace errors.

- [ ] **Step 4: Keep implementation uncommitted for user review**

Report the HTML path, the two local test results, the visual findings, and the fact that production source and unrelated Wiki files remain untouched. Do not commit until the user explicitly requests it.
