# Source Note Placement Lab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task in the current checkout. Do not use a worktree and do not dispatch subagents for this task.

**Goal:** Add four removable TiddlyWiki Lab pages that compare Auto Dock, Top Notes, Reserved Rail, and After Code against the same P04 C++ source without changing existing production-page defaults.

**Architecture:** Extend the existing `CodeSurfaceWidget` with one opt-in `experimentalLayout` attribute whose valid values are `auto`, `top`, `reserved`, and `after`. The default render path and DOM remain unchanged. Experimental modes reuse the existing source selection, Highlight output, DOM Range resolution, Popover/Anchor fallback, accessibility state, and teardown; only the note host, placement selection, connector terminal overlay, numbering presentation, and Lab-only CSS change.

**Tech Stack:** TiddlyWiki 5 widget modules, TypeScript, CSS, DOM Range, inline SVG, Playwright, Node contract tests, pnpm through the repository's Node 24/npm wrapper.

## Global Constraints

- Work in `D:\Workspace\AngelscriptProject` and its existing `Wiki` submodule checkout; do not create or switch worktrees.
- Preserve all unrelated dirty files in the parent repository and Wiki submodule.
- Do not add third-party runtime dependencies.
- Do not change P02–P10, L01–L02, the 42-entry Showcase catalog, or the formal reader-document count.
- Do not change default DOM, numbering, layout selection, or behavior when `experimentalLayout` is absent, blank, or invalid.
- All four experiments consume `AS/Showcase/Source/P04-ScriptGameInstanceSubsystem`; do not duplicate its source body.
- Experimental notes have no visual or accessible ordinal, retain keyboard/pointer disclosure, and keep source text, line geometry, and copy output stable.
- At `390px`, all experimental modes use After Code without document-level horizontal overflow.
- Do not commit or push unless the user explicitly asks.

---

## File Map

- Modify `Wiki/src/angelscript-tools/index.ts`: parse the opt-in attribute, select placements, host the Reserved Rail, measure source-ink collision, render terminal connector overlays, and suppress ordinals only in Lab mode.
- Modify `Wiki/src/angelscript-tools/index.css`: define Lab-only idle/active styling and the `right`, `top`, `reserved`, and `after` layouts without changing default selectors.
- Create `Wiki/tests/playwright/product/code/annotation-layout-lab.spec.ts`: browser behavior and geometry contract for all four variants.
- Modify `Wiki/tests/playwright/product/document/document-content-foundation.spec.ts`: verify the temporary Lab entry and four-page navigation without changing the existing 11 catalog rows.
- Create `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementIndex.tid`: temporary comparison hub.
- Create `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE01AutoDock.tid`: automatic right/top selection experiment.
- Create `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE02TopNotes.tid`: fixed top-note strip experiment.
- Create `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE03ReservedRail.tid`: separate source scroller and note rail experiment.
- Create `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE04AfterCode.tid`: full-width source and after-code notes experiment.
- Modify `Wiki/wiki/tiddlers/showcase/LabIndex.tid`: append one temporary navigation section after the unchanged 11-row catalog.
- Modify `openspec/changes/docs-wiki-content-and-expression-overhaul/tasks.md`: add and later complete task 2.18.
- Create `openspec/changes/docs-wiki-content-and-expression-overhaul/verification-source-note-placement-lab-2026-07-31.md`: record exact commands and results.

### Task 1: Lock the Lab contracts with failing tests

**Files:**
- Create: `Wiki/tests/playwright/product/code/annotation-layout-lab.spec.ts`
- Modify: `Wiki/tests/playwright/product/document/document-content-foundation.spec.ts`

**Interfaces:**
- Consumes: existing `.angelscript-code`, `.angelscript-code-note`, `.angelscript-code-range-mark`, `.angelscript-code-connector`, and P04 source tiddler.
- Produces: exact DOM/test contract for `data-experimental-layout`, `data-annotation-placement`, `.angelscript-code--layout-lab`, `.angelscript-code-note-terminal-connectors`, and the five new tiddler titles.

- [ ] **Step 1: Add a Playwright suite for experimental placement**

Create a suite with the four page titles and shared labels:

```ts
const pages = {
  auto: 'AS/Showcase/Lab/AnnotationPlacement/E01-AutoDock',
  top: 'AS/Showcase/Lab/AnnotationPlacement/E02-TopNotes',
  reserved: 'AS/Showcase/Lab/AnnotationPlacement/E03-ReservedRail',
  after: 'AS/Showcase/Lab/AnnotationPlacement/E04-AfterCode',
} as const;

const labels = [
  '守卫创建资格',
  '验证当前 VM',
  '先 Unreal，后脚本',
  '先桥接清理，再父类拆除',
];
```

The suite must assert:

```ts
await expect(surface).toHaveAttribute('data-experimental-layout', variant);
await expect(surface).toHaveAttribute('data-annotation-placement', expected);
await expect(surface.locator('.angelscript-code-note-summary')).toHaveText(labels);
await expect(surface.locator('[data-note-index]')).toHaveCount(0);
await expect(surface.locator('.angelscript-code-note-summary').first())
  .toHaveAttribute('aria-label', `注解：${labels[0]}`);
```

Add geometry checks that source line rectangles do not move across open/close, Auto chooses `top` for P04, Top notes end above the first code line, Reserved Rail does not intersect the source scroller, After notes start below `<pre>`, and `390px` resolves every variant to `after`.

- [ ] **Step 2: Add the temporary Lab navigation test**

Extend `document-content-foundation.spec.ts` after the existing Lab catalog assertions:

```ts
await expect(lab.locator('.as-annotation-placement-lab-entry')).toHaveCount(1);
await expect(lab.locator('.as-showcase-catalog-entry')).toHaveCount(11);
await lab.getByRole('link', { name: '打开源码注解位置实验' }).click();
await expect(page.locator(
  '.tc-tiddler-frame[data-tiddler-title="AS/Showcase/Lab/AnnotationPlacement"]',
)).toBeVisible();
```

Then assert the hub contains four links with the exact page titles.

- [ ] **Step 3: Run the code and document suites to observe RED**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature code
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature document
```

Expected: the new code suite fails because the four tiddlers do not exist; the document assertion fails because `.as-annotation-placement-lab-entry` does not exist. Existing tests should continue passing before those new assertions.

### Task 2: Add the opt-in widget contract and placement engine

**Files:**
- Modify: `Wiki/src/angelscript-tools/index.ts`
- Test: `Wiki/tests/playwright/product/code/annotation-layout-lab.spec.ts`

**Interfaces:**
- Consumes: `CodeSurfaceWidget.render()`, `updateAnnotationLayout()`, `renderRangeMarks()`, and `onDestroy()`.
- Produces:
  - `type ExperimentalLayout = 'auto' | 'top' | 'reserved' | 'after'`
  - `parseExperimentalLayout(value: string): ExperimentalLayout | undefined`
  - `data-experimental-layout` only for valid values
  - `data-annotation-placement="right|top|reserved|after"` only for valid Lab modes
  - a Reserved Rail frame only when the requested mode is `reserved`.

- [ ] **Step 1: Parse only exact experimental values**

Add:

```ts
type ExperimentalLayout = 'auto' | 'top' | 'reserved' | 'after';
type AnnotationPlacement = 'right' | 'top' | 'reserved' | 'after';

function parseExperimentalLayout(value: string): ExperimentalLayout | undefined {
  const normalized = value.trim();
  return normalized === 'auto' ||
    normalized === 'top' ||
    normalized === 'reserved' ||
    normalized === 'after'
    ? normalized
    : undefined;
}
```

Store the result in `CodeSurfaceWidget.experimentalLayout`. For a valid value, add `.angelscript-code--layout-lab`, set `data-experimental-layout`, and leave the old class/dataset path untouched for missing or invalid values.

- [ ] **Step 2: Create the Reserved Rail host only for that experiment**

For `reserved`, wrap only the experimental `scroll` in:

```html
<div class="angelscript-code-reserved-frame">
  <div class="angelscript-code-scroll">...</div>
  <aside class="angelscript-code-reserved-rail" aria-label="源码注解">...</aside>
</div>
```

Move `.angelscript-code-note-layer` into the `aside`; keep range marks and the main connector SVG beside `<pre>` in `.angelscript-code-column`. Do not add the frame on the default path or other experiments.

- [ ] **Step 3: Suppress ordinals only for valid Lab modes**

In `renderNote()` branch on `this.experimentalLayout`:

```ts
if (this.experimentalLayout) {
  summary.setAttribute('aria-label', `注解：${definition.label || '未命名注解'}`);
} else {
  summary.dataset.noteIndex = noteIndex;
  summary.setAttribute('aria-label', `注解 ${noteIndex}：${definition.label || '未命名注解'}`);
}
```

Use `点击注解查看完整说明。` as the Lab hint; retain the current numbered hint verbatim on the default path.

- [ ] **Step 4: Select the actual placement**

Keep the current `rail`/`after-code` calculation as the first, untouched branch when `experimentalLayout` is undefined. For Lab mode:

```ts
if (this.example.clientWidth < MIN_ANNOTATION_RAIL_WIDTH) return 'after';
if (requested === 'after') return 'after';
if (requested === 'top') return 'top';
if (requested === 'reserved') return 'reserved';
return this.hasRightRailClearance(16) ? 'right' : 'top';
```

`hasRightRailClearance(16)` must measure all non-empty `Range.getClientRects()` from the existing `<pre><code>` text, convert the maximum ink-right edge into code-column coordinates, calculate the candidate rail-left from the current visible source width, and require `maxInkRight <= railLeft - 16`.

Toggle Lab placement classes atomically, set `data-annotation-placement`, and set the inherited `--as-code-top-note-height` after measuring the wrapped Top note layer. Do not rebuild or edit the source DOM.

- [ ] **Step 5: Run the targeted suite**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/code/annotation-layout-lab.spec.ts
```

Expected: page-not-found assertions remain red until Task 4, while any inline test fixture or parser unit assertions for invalid/default values pass.

### Task 3: Add Lab-only layout and connector rendering

**Files:**
- Modify: `Wiki/src/angelscript-tools/index.ts`
- Modify: `Wiki/src/angelscript-tools/index.css`
- Test: `Wiki/tests/playwright/product/code/annotation-layout-lab.spec.ts`

**Interfaces:**
- Consumes: the valid experimental mode and actual placement from Task 2.
- Produces: `.angelscript-code--lab-right`, `--lab-top`, `--lab-reserved`, `--lab-after`, and `.angelscript-code-note-terminal-connectors`.

- [ ] **Step 1: Implement layout-specific note positioning**

Branch `layoutNotes()` by `data-annotation-placement`:

- `top`: clear every inline `top`, let a wrapping flex note layer place labels, and return its height.
- `after`: clear every inline `top`; source comes first and the static note layer follows.
- `right`/`reserved`: retain source-range-aligned vertical stacking; for Reserved Rail compute note top in the rail's coordinate system using `mark.getBoundingClientRect()` and `rail.getBoundingClientRect()`.

Only right/default rail layouts may set the code-column minimum height to the greater of source and note stack heights.

- [ ] **Step 2: Draw direction-appropriate connectors**

Keep the existing horizontal cubic for right/default/reserved. For Top use a vertical cubic:

```ts
const bendY = startY + (endY - startY) * 0.5;
const path = `M ${startX} ${startY} C ${startX} ${bendY}, ${endX} ${bendY}, ${endX} ${endY}`;
```

After Code has no connector layer in idle/hover; range activation remains the relationship cue.

- [ ] **Step 3: Add the terminal overlay**

For Lab Right, clone the connector path into a second SVG over the code column and clip it to the note-rail region beginning at `--as-code-note-rail-left`. For Reserved Rail, create a terminal SVG inside the reserved rail and draw from its left boundary to the note port. Add `aria-hidden="true"` and `pointer-events: none`.

When `openNoteId` is set, add `.is-hidden` to the terminal layer while elevating the main connector; restore it on close. The visible terminal endpoint must be within `1px` of the note-port center.

- [ ] **Step 4: Add Wiki-aligned experimental styling**

All Lab selectors must be rooted at `.angelscript-code--layout-lab` so default pages are unchanged. Use the existing gray-blue tokens:

```css
.angelscript-code--layout-lab .angelscript-code-note-summary {
  padding-left: 0.75rem;
  border-color: transparent;
  background: transparent;
  color: #74808d;
}

.angelscript-code--layout-lab .angelscript-code-note-summary::before {
  content: none;
}

.angelscript-code--layout-lab .angelscript-code-note.is-active
  .angelscript-code-note-summary,
.angelscript-code--layout-lab .angelscript-code-note-summary:focus-visible {
  border-color: #9ab7d8;
  background: rgb(255 255 255 / 88%);
  color: #38475a;
}
```

Top uses a wrapping strip above source with `--as-code-top-note-height`; Reserved uses `grid-template-columns: minmax(0, 1fr) 14rem`; After reuses the established static note ordering. At the existing narrow breakpoint, force every Lab mode to a single source-then-note column. Preserve print and reduced-motion rules.

- [ ] **Step 5: Run lint/type checks for the changed module**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec eslint src/angelscript-tools/index.ts tests/playwright/product/code/annotation-layout-lab.spec.ts
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run check
```

Expected: zero ESLint errors/warnings for targeted files; `check` exits 0.

### Task 4: Add the five removable Wiki Lab tiddlers

**Files:**
- Create: `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementIndex.tid`
- Create: `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE01AutoDock.tid`
- Create: `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE02TopNotes.tid`
- Create: `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE03ReservedRail.tid`
- Create: `Wiki/wiki/tiddlers/showcase/lab/AnnotationPlacementE04AfterCode.tid`
- Modify: `Wiki/wiki/tiddlers/showcase/LabIndex.tid`

**Interfaces:**
- Consumes: `experimentalLayout`, P04 source tiddler, and direct-child `<$code-note>`.
- Produces: five exact titles under `AS/Showcase/Lab/AnnotationPlacement` and `.as-annotation-placement-lab-entry` on the Lab index.

- [ ] **Step 1: Add the temporary hub**

Use `type: text/vnd.tiddlywiki`, `tags: [[ASWiki/Showcase/LayoutExperiment]]`, an explicit removable-experiment warning, a compact comparison table, and four TW5 internal links. Do not add `as-doc-kind`, `as-showcase-id`, `as-showcase-tier`, or `ASWiki/Docs/showcase-lab`.

- [ ] **Step 2: Add four pages with identical source and notes**

Each page renders:

```tid
<$annotated-code
  language="cpp"
  title="C++ · UScriptGameInstanceSubsystem"
  code={{{ [[AS/Showcase/Source/P04-ScriptGameInstanceSubsystem]get[text]] }}}
  startLine="17"
  lineNumbers="yes"
  experimentalLayout="VARIANT"
>
```

Use the exact four P04 note definitions from the formal page so only layout differs. Each page includes source path, revision, display range, layout behavior, fallback behavior, known trade-off, a link back to the hub, and a link to `AS/Showcase/Pattern/P04-AngelScriptCppBridge`.

- [ ] **Step 3: Add one manual Lab-index entry after the catalog**

Append:

```tid
!! 临时源码注解位置实验

<div class="as-annotation-placement-lab-entry" role="note">
这组页面不占用 Showcase ID，可以在选型后整组移除。

[[打开源码注解位置实验|AS/Showcase/Lab/AnnotationPlacement]]
</div>
```

Do not alter the JSON catalog or its 11 Lab rows.

- [ ] **Step 4: Run the new browser suite to GREEN**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/code/annotation-layout-lab.spec.ts
```

Expected: all Lab placement tests pass.

### Task 5: Verify defaults, content contracts, visuals, and build

**Files:**
- Modify: `openspec/changes/docs-wiki-content-and-expression-overhaul/tasks.md`
- Create: `openspec/changes/docs-wiki-content-and-expression-overhaul/verification-source-note-placement-lab-2026-07-31.md`

**Interfaces:**
- Consumes: completed widget and tiddlers.
- Produces: recorded test/build evidence and checked task 2.18.

- [ ] **Step 1: Run code and document feature suites**

Run from `Wiki`:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature code
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature document
```

Expected: both suites pass; existing default-annotation assertions continue passing.

- [ ] **Step 2: Run static checks and the content contract**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run check
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec node --test scripts/document-content-contract.test.mjs
```

Expected: both commands exit 0; the contract still reports the exact 42-entry catalog and unchanged formal-document baseline.

- [ ] **Step 3: Build the standalone Wiki**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run build:wiki
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:artifact
```

Expected: `Wiki/dist/index.html` is rebuilt and artifact tests pass.

- [ ] **Step 4: Capture desktop, active, and narrow screenshots**

Use Playwright against the built/served Wiki to capture every experiment at desktop width, one active-note state, and the shared `390px` fallback. Visually check:

- the long `TryGetCurrentEngine()` line is readable and not under a note surface;
- no `01`–`04` appears on Lab notes;
- default notes are quiet and active notes are legible;
- Right/Reserved terminal segments reach their ports;
- Top gutter aligns with the first source line;
- no document-level overflow exists at `390px`.

- [ ] **Step 5: Record the evidence and complete OpenSpec task 2.18**

Add to `tasks.md`:

```markdown
- [x] 2.18 <!-- TDD --> 新增四个可移除的 P04 源码注解位置 Lab（Auto Dock / Top Notes / Reserved Rail / After Code），只通过 `experimentalLayout` 显式启用；保持正式页默认、42 项 Showcase catalog 和正式文档数量不变，并完成长行避让、无序号、connector terminal、窄屏回退与清理回归验证。
```

Record each command, exit code, pass count, screenshots, and any known experimental limitation in the verification file.

- [ ] **Step 6: Open all four experiment pages for user review**

Open `D:\Workspace\AngelscriptProject\Wiki\dist\index.html` with each tiddler hash in the local browser. Report the absolute file path and exact tiddler titles; do not claim a production layout has been selected.

## Plan Self-Review

- Spec coverage: all four layouts, shared P04 source, no numbering, terminal connector, long-line collision, narrow/print/reduced-motion, navigation isolation, default regression, removal boundary, and verification have explicit tasks.
- Placeholder scan: no `TBD`, `TODO`, “implement later”, or unspecified error-handling step remains.
- Type consistency: the only public experiment attribute is `experimentalLayout`; allowed values and `data-annotation-placement` values match the design and every test/task reference.
- Scope check: all work belongs to one Wiki source-annotation experiment; no production-page migration, external dependency, catalog expansion, commit, or push is included.
