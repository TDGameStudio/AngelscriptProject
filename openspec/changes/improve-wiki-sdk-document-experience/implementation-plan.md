# Wiki SDK Document Experience Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the blog-oriented Notion cover/icon runtime surface, restore the localized core sidebar without an in-page TOC, add a bounded scrollable viewport for long AngelScript source ranges, finish the SDK title/description presentation, and establish a fast editable vendor-source boundary with screenshot-backed verification.

**Architecture:** The external-plugin manifest remains the sole runtime boundary for imported TiddlySeq packages, so the cover/icon package is removed there and at its isolated source/test/documentation references while sibling plugins remain registered. The sidebar uses only the core language-aware Open / Recent / Tools / More tabs and long documents omit a TOC card. `$angelscript-code` keeps one source-selection/highlighting/copy pipeline and adds only an optional viewport-height constraint derived from a clamped line count. SDK descriptions remain metadata-driven ViewTemplate content and receive theme-only spacing/typography refinement.

**Tech Stack:** TiddlyWiki 5 WikiText and widgets, TypeScript, CSS, Node.js 20+, pnpm 11.8.0, Playwright/Chromium, OpenSpec.

## Global Constraints

- Work in `D:/Workspace/AngelscriptProject/Wiki` on the existing `main` checkout; do not create a worktree.
- Preserve `$:/plugins/Gk0Wk/drawio`, `$:/plugins/Gk0Wk/sidebar-resizer`, `$:/plugins/Gk0Wk/focused-tiddler`, and all `$:/core/images/*` resources.
- Preserve TiddlyWiki core sidebar localization; do not hard-code English visible captions.
- Delete only `Wiki/vendor/tiddlyseq/src/notionpage-covericon/` and its package-specific references; do not delete `Wiki/vendor/tiddlyseq/`.
- `fromLine`/`toLine` select rendered and copied source, `startLine` controls displayed numbering, and `highlightLines` controls displayed emphasis; `maxVisibleLines` MUST affect only viewport height.
- Clamp numeric `maxVisibleLines` values to 3–80; malformed or omitted values keep the current unconstrained behavior.
- Keep the accepted Tomorrow Light syntax token colors and existing code font metrics.
- Preserve the four untracked user reference JPG files under `Wiki/wiki/`.
- Do not stage or commit until the user explicitly requests it.

---

### Task 1: Remove the cover/icon package at the external-plugin boundary

**Files:**
- Modify: `Wiki/scripts/external-plugin-sources.test.mjs`
- Modify: `Wiki/scripts/publish-offline.test.mjs`
- Modify: `Wiki/external-plugins.json`
- Delete: `Wiki/vendor/tiddlyseq/src/notionpage-covericon/`
- Delete: `Wiki/wiki/tiddlers/tests/playwright/NotionCoverIconExample.tid`
- Delete: `Wiki/wiki/tiddlers/tests/playwright/notion-cover-icon.spec.ts`
- Modify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Modify: `Wiki/wiki/tiddlers/as/theme-roadmap.tid`
- Modify: `Wiki/Agents.md`
- Modify: `Wiki/Agents_ZH.md`

**Interfaces:**
- Consumes: `external-plugins.json`, `validateExternalPlugins`, `prepareExternalPluginSources`, and offline library title index.
- Produces: a runtime/library without `$:/plugins/Gk0Wk/notionpage-covericon` while retaining draw.io, sidebar-resizer, and focused-tiddler.

- [x] **Step 1: Replace the positive external-plugin test with a failing absence/retention contract**

Use the existing generated-source test pattern and assert:

```js
assert.equal(manifest.plugins.some(({ name }) => name === 'notionpage-covericon'), false);
assert.doesNotThrow(() => validateExternalPlugins({ repoRoot: wikiRoot, manifest }));
const entries = prepareExternalPluginSources({ repoRoot: wikiRoot, manifest, outputPath });
assert.equal(entries.some(({ name }) => name === 'notionpage-covericon'), false);
assert.equal(existsSync(path.join(outputPath, 'notionpage-covericon')), false);
for (const retained of ['drawio', 'sidebar-resizer', 'focused-tiddler']) {
  assert.ok(entries.some(({ name }) => name === retained));
}
```

- [x] **Step 2: Change the offline-library assertion to require absence**

```js
assert.equal(
  libraryTitles.has('$:/plugins/Gk0Wk/notionpage-covericon'),
  false,
  'offline library must exclude the retired Notion cover and icon plugin',
);
```

- [x] **Step 3: Run the focused tests and verify the new contracts fail before removal**

Run from `Wiki/`:

```powershell
pnpm run test:external-plugins
pnpm run test:publish:offline
```

Expected: both fail because the manifest/library still include the package.

- [x] **Step 4: Remove only the package and package-specific references**

Delete the exact imported package directory and dedicated browser fixture/spec, remove its JSON manifest object, remove `.gk0wk-notionpageb-changecover` theme overrides, and remove cover/icon author guidance. Update both agent guides to list only retained runtime document plugins and explicitly state that SDK pages do not load a cover/icon ViewTemplate.

- [x] **Step 5: Re-run focused removal tests**

Run:

```powershell
pnpm run test:external-plugins
pnpm run test:publish:offline
```

Expected: PASS; generated entries omit notionpage-covericon and retain the three named sibling plugins.

---

### Task 2: Add the bounded AngelScript code viewport with TDD

**Files:**
- Modify: `Wiki/wiki/tiddlers/tests/playwright/angelscript-code.spec.ts`
- Modify: `Wiki/wiki/tiddlers/tests/playwright/AngelscriptCodeExamples.tid`
- Modify: `Wiki/src/angelscript-tools/index.ts`
- Modify: `Wiki/src/angelscript-tools/index.css`
- Modify: `Wiki/src/angelscript-tools/readme.tid`

**Interfaces:**
- Consumes: widget attributes `code`, `fromLine`, `toLine`, `startLine`, `highlightLines`, `lineNumbers`, and `copy`.
- Produces: optional `maxVisibleLines`, `.angelscript-code-scroll[data-max-visible-lines]`, and unchanged full selected-source copy text.

- [x] **Step 1: Expand the canonical focused-range fixture**

Use a selected source range longer than the viewport:

```tid
<$angelscript-code
  code={{{ [[AngelscriptCodeExample]get[text]] }}}
  lineNumbers="yes"
  highlightLines="42,45-47,60"
  fromLine="4"
  toLine="35"
  startLine="40"
  maxVisibleLines="10"
/>
```

Add adjacent author text explaining that `fromLine`/`toLine` select and copy the full range, while `maxVisibleLines` only creates a mouse-wheel-scrollable viewport.

- [x] **Step 2: Add failing browser assertions for overflow, scrolling, clamping, and complete copying**

The focused example test SHALL assert:

```ts
const scroll = example.locator('.angelscript-code-scroll');
await expect(scroll).toHaveAttribute('data-max-visible-lines', '10');
expect(await scroll.evaluate(element => element.scrollHeight > element.clientHeight)).toBe(true);
await expect(scroll).toHaveCSS('overflow-y', 'auto');
await scroll.hover();
await page.mouse.wheel(0, 500);
await expect.poll(() => scroll.evaluate(element => element.scrollTop)).toBeGreaterThan(0);
```

The copy test SHALL compare clipboard text with normalized lines 4–35 of `AngelscriptCodeExample`, including an ending line initially outside the viewport. Add malformed/low/high attribute fixtures and assert omission is unconstrained while `1` becomes `3` and `200` becomes `80`.

- [x] **Step 3: Run the focused Playwright spec and verify failure**

Run:

```powershell
pnpm exec playwright test wiki/tiddlers/tests/playwright/angelscript-code.spec.ts
```

Expected: FAIL because the widget does not parse or apply `maxVisibleLines`.

- [x] **Step 4: Implement bounded parsing and viewport metadata**

Add a focused parser:

```ts
function parseMaxVisibleLines(value: string) {
  if (!/^[+-]?\d+$/.test(value.trim())) return undefined;
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed)) return undefined;
  return Math.min(80, Math.max(3, parsed));
}
```

During render, parse the attribute; when defined, set `data-max-visible-lines` and an inline `max-height` equal to two block paddings plus `maxVisibleLines * 1.452rem`. Do not slice `range.source` or modify line/highlight calculations.

- [x] **Step 5: Implement the thin stable scrollbar**

Apply the same low-contrast scrollbar treatment to every AngelScript scroll surface, while vertical overflow remains enabled only for bounded viewports:

```css
.angelscript-code-scroll[data-max-visible-lines] {
  overflow-y: auto;
}

.angelscript-code-scroll {
  scrollbar-color: #d6dbe1 transparent;
  scrollbar-width: thin;
}

.angelscript-code-scroll::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}
```

Add transparent tracks, rounded `#d6dbe1` thumbs, and only a slightly darker `#c4cbd3` hover thumb without changing width or adding another border. Add a browser assertion on an ordinary unconstrained AS card so the style cannot regress back to the bounded-only selector.

- [x] **Step 6: Replace visible copy words with localized icon feedback**

Render inline SVG copy, success, and failure states without text inside the button. Resolve `title`, `aria-label`, and hidden `aria-live` text from the active core `$:/language/Buttons/CopyToClipboard/Hint` and copied-to-clipboard notification tiddlers. Assert that both enhanced AngelScript cards and ordinary core code blocks have empty visible button text, a state icon, localized accessible metadata, and unchanged clipboard content.

- [x] **Step 7: Document the author contract and re-run the focused spec**

Document `maxVisibleLines="10"`, the 3–80 clamp, source-range/copy semantics, omission behavior, global low-contrast scrollbars, and icon-only active-language copy feedback in `readme.tid`. Re-run the focused Playwright command and expect PASS.

---

### Task 3: Harmonize the optional SDK description line

**Files:**
- Modify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Test: `Wiki/wiki/tiddlers/tests/playwright/document-experience.spec.ts`

**Interfaces:**
- Consumes: `as-sdk-document: yes`, `caption`, and optional `description` metadata through `$:/themes/angelscript/view-template-description`.
- Produces: stable title/description spacing and subordinate, readable one-sentence metadata aligned to the 54rem document measure.

- [x] **Step 1: Add description hierarchy assertions**

Assert that a canonical SDK page has one `.as-sdk-description`, uses regular font weight, remains within the 54rem measure, and has non-negative stable block spacing. Add a wrapping probe or viewport geometry assertion so the description cannot overlap the title toolbar.

- [x] **Step 2: Run the focused document-experience spec and verify the spacing contract fails**

Run:

```powershell
pnpm exec playwright test wiki/tiddlers/tests/playwright/document-experience.spec.ts
```

Expected: FAIL on the current `margin-top: -0.65rem` styling.

- [x] **Step 3: Replace negative spacing with stable metadata typography**

Keep the existing metadata filter/template and update only the theme rule:

```css
.as-sdk-description {
  width: 100%;
  max-width: 54rem;
  margin: 0.35rem 0 1.4rem;
  color: #667383;
  font-size: 0.925rem;
  font-weight: 400;
  line-height: 1.6;
}
```

Use these exact values for the acceptance pass so the screenshot and computed-style assertions test one deterministic contract.

- [x] **Step 4: Re-run the focused document test**

Run the same Playwright command and expect PASS.

---

### Task 4: Separate editable vendor repositories and make complete lint bounded

**Files:**
- Add: `Wiki/eslint.vendor.config.mjs`
- Add: `Wiki/scripts/source-boundaries.test.mjs`
- Modify: `Wiki/package.json`
- Modify: `Wiki/eslint.config.mjs`
- Modify: `Wiki/tsconfig.json`
- Modify: `Wiki/.gitignore`
- Modify: `Wiki/.gitattributes`
- Modify: `Wiki/external-plugins.json`
- Move: `Wiki/src/tiddlyseq/` to `Wiki/vendor/tiddlyseq/`
- Move: `Wiki/src/tw-command-palette/` to `Wiki/vendor/tw-command-palette/`
- Move: `Wiki/src/tiddlywiki-codemirror-6/` to `Wiki/vendor/tiddlywiki-codemirror-6/`
- Move: `Wiki/src/tiddlywiki-plugins/` to `Wiki/vendor/tiddlywiki-plugins/`
- Modify: `Wiki/Agents.md`
- Modify: `Wiki/Agents_ZH.md`
- Modify: `Wiki/README.md`

**Interfaces:**
- Consumes: manifest repository paths, watcher/preparation bridge, active vendor TypeScript, and tracked imported reference repositories.
- Produces: editable tracked `vendor/` roots, full local lint, bounded vendor audit, and `lint:all = lint + lint:vendors`.

- [x] **Step 1: Add a failing source-boundary contract**

Assert that runtime repository paths start with `vendor/`, no imported repository is duplicated under `src/`, the two inactive reference repositories also live under `vendor/`, and the package exposes separate `lint`, `lint:vendors`, and composed `lint:all` commands.

- [x] **Step 2: Move only the four validated imported repositories**

Resolve and verify source and destination paths under the Wiki workspace before using a native PowerShell move. Keep migration backups ignored, unignore only the four tracked repository names, update whitespace attributes and every manifest/document path, and do not touch user images.

- [x] **Step 3: Keep enabled vendor plugins typechecked and hot-reloadable**

Add active vendor TypeScript paths to `tsconfig.json`; leave `sourcePath` relative to each imported repository; validate preparation and the existing watcher add/change/delete test after the move.

- [x] **Step 4: Replace unbounded type-aware vendor scanning**

`lint` checks local `src`, scripts, configuration, and Playwright tests. `lint:vendors` uses a non-project TypeScript parser plus serious correctness rules, disables incompatible upstream inline rule directives, and ignores `files/lib/**`, `*.min.js`, `dist`, and `node_modules`. `lint:all` runs both commands. Require zero errors/warnings and record elapsed time.

- [x] **Step 5: Verify and document the boundary**

Run `test:source-boundaries`, `test:external-plugins`, `check`, `lint:all`, and `build`; document that registered vendor edits remain supported and hot-reloadable while `.submodule-backup-*` and `.retired-*` are not development roots.

---

### Task 5: Full verification and visual acceptance

**Files:**
- Modify: `openspec/changes/improve-wiki-sdk-document-experience/tasks.md`
- Generate (ignored): `Wiki/test-results/sdk-review/*.png`

**Interfaces:**
- Consumes: completed tasks 1–4 and the existing documentation/sidebar/command-palette/theme work.
- Produces: independently passing static checks, generated artifacts, browser interactions, and inspected desktop screenshots.

- [x] **Step 1: Fix remaining targeted lint findings and run lint independently**

Remove the unnecessary optional chain from `.as` file-extension access and the unused `container` binding in `document-experience.spec.ts`. Run the targeted ESLint command as its own process and require exit code 0 before broader verification.

- [x] **Step 2: Run the complete Wiki verification matrix as separate commands**

Run from `Wiki/`:

```powershell
pnpm run check
pnpm run lint
pnpm run lint:all
pnpm run build
pnpm test
pnpm run test:external-plugins
pnpm run test:source-boundaries
pnpm run test:publish:offline
pnpm run test:playwright
```

Expected: every command exits 0 independently. If imported vendor lint exposes upstream-only issues unrelated to this change, report them separately rather than masking a local lint failure.

- [x] **Step 3: Start the watched Wiki and capture deterministic desktop screenshots**

At 1536×960 capture and inspect:

- SDK page with the restored localized core sidebar, breadcrumb, title, one-line description, tags, and initial body.
- AngelScript examples page at the Focused source range before scrolling.
- The same viewport after mouse-wheel scrolling to a non-zero `scrollTop`.
- Scrollbar default and hovered states.
- Representative core sidebar and toolbar hover/focus plus command-palette states already required by the parent design.

- [x] **Step 4: Inspect source boundaries and generated output**

Require all of the following:

```powershell
rg -n "notionpage-covericon|gk0wk-notionpage|page-cover" external-plugins.json scripts src/angelscript-theme wiki/tiddlers Agents.md Agents_ZH.md
git diff --check
git status --short
```

Expected: no runtime/document/test references remain; only historical non-runtime records outside the Wiki may mention the retired capability. The four user JPGs remain untracked and untouched.

- [x] **Step 5: Update OpenSpec task state without committing**

Mark only genuinely completed tasks in `tasks.md`, run `openspec validate improve-wiki-sdk-document-experience --strict`, and leave all source changes unstaged until the user requests a commit.

---

### Task 6: Restore the reference sidebar geometry without reverting color

**Files:**
- Modify: `Wiki/wiki/tiddlers/tests/playwright/document-experience.spec.ts`
- Modify: `Wiki/src/angelscript-wiki-config/config/sidebar-width.tid`
- Modify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Modify: `openspec/changes/improve-wiki-sdk-document-experience/tasks.md`
- Generate (ignored): `Wiki/comparison-artifacts/sidebar-reference-2048.png`
- Generate (ignored): `Wiki/comparison-artifacts/sidebar-safety-1280.png`

**Interfaces:**
- Consumes: TiddlyWiki's `$:/themes/tiddlywiki/vanilla/metrics/sidebarwidth`, the core localized `.tc-sidebar-tabs-main` controls, and the retained light interaction tokens.
- Produces: a desktop sidebar whose width resolves from `clamp(320px, 31vw, 600px)` and whose core tab labels use compact content-sized geometry without changing color, localization, plugin inventory, or mobile behavior.

- [x] **Step 1: Write failing desktop geometry and density assertions**

Extend the existing core-sidebar Playwright test to set a 1280px desktop viewport and assert a resolved sidebar width near `396.8px`, then set a 2048px viewport and assert the maximum `600px`. For each visible main sidebar tab, assert `min-width: 0px`; continue asserting the localized core tab titles and the absence of the custom Docs tab and TOC module.

- [x] **Step 2: Run the focused test and verify the migrated fixed-width behavior fails**

Run from `Wiki/`:

```powershell
pnpm exec playwright test wiki/tiddlers/tests/playwright/document-experience.spec.ts --grep "original core sidebar layout"
```

Expected: FAIL because both desktop viewports resolve to the migrated fixed `320px` metric and sidebar tabs still inherit the generic `32px` minimum width.

- [x] **Step 3: Restore the bounded reference proportion and sidebar-only compact controls**

Set the sidebar metric tiddler text to:

```text
clamp(320px, 31vw, 600px)
```

In `desktop-refinement.tid`, keep the existing interaction colors, focus ring, and stable control transitions. Remove `.tc-sidebar-lists .tc-tab-buttons button` from the generic 32px minimum-size group and add a desktop-only sidebar rule that keeps `min-width: 0`, preserves core padding, and does not reduce the tab's normal line-height or keyboard focus treatment. Do not alter mobile selectors or reintroduce removed plugins/tabs.

- [x] **Step 4: Run focused and full regression coverage**

Run:

```powershell
pnpm exec playwright test wiki/tiddlers/tests/playwright/document-experience.spec.ts
pnpm run check
pnpm run lint:all
pnpm run build
pnpm run test:playwright
```

Expected: all commands exit 0; desktop geometry assertions pass, core captions remain language-driven, colors remain the accepted Tomorrow-derived values, and mobile navigation tests remain green.

- [x] **Step 5: Capture and inspect reference-sized screenshots**

At 2048×830, seed multiple ordinary documentation titles into the story list so the Open tab exposes real list density, then capture `sidebar-reference-2048.png`. At 1280×800 capture `sidebar-safety-1280.png`. Inspect both against `Wiki/临时图片参考2.jpg`, accepting different SDK content and plugin inventory while requiring the restored right-column proportion, compact tab/list rhythm, and unchanged light color system.

---

### Task 7: Restore the RefWiki toolbar layout and harmonize untagged metadata

**Files:**
- Modify: `Wiki/wiki/tiddlers/tests/playwright/document-experience.spec.ts`
- Modify: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`
- Modify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Modify: `Wiki/src/angelscript-theme/palette.tid`
- Modify: `Wiki/src/angelscript-wiki-config/config/page-control-advanced-search.tid`
- Modify: `Wiki/src/angelscript-wiki-config/config/page-control-command-palette.tid`
- Modify: `Wiki/src/angelscript-wiki-config/config/page-control-layout.tid`
- Modify: `Wiki/src/angelscript-wiki-config/config/page-control-refresh.tid`
- Modify: `Wiki/src/angelscript-wiki-config/config/page-control-save-wiki.tid`
- Create: `Wiki/src/angelscript-wiki-config/config/page-control-home.tid`
- Create: `Wiki/src/angelscript-wiki-config/config/page-control-more-page-actions.tid`
- Create: `Wiki/src/angelscript-wiki-config/config/page-control-control-panel.tid`
- Create: `Wiki/src/angelscript-wiki-config/config/page-control-new-journal.tid`
- Create: `Wiki/src/angelscript-wiki-config/config/page-controls-order.tid`

**Interfaces:**
- Consumes: TiddlyWiki `$:/tags/PageControls`, `$:/core/ui/PageTemplate/pagecontrols`, canonical PageControlButtons visibility tiddlers, and the existing light interaction variables.
- Produces: the approved six-control SDK toolbar with RefWiki natural geometry plus a readable untagged action in the core More/Tags surface.

- [x] **Step 1: Add failing runtime toolbar and color assertions**

Assert that the visible encoded button titles, in order, are Home, More actions, new tiddler, new Markdown, control panel, and draw.io; save, Command Palette, and new journal are absent. Assert toolbar `min-width`/`min-height` compute to `auto`, width stays below 25px, and height stays below 29px. Open the fourth core sidebar tab and assert the exact “未设标签” button resolves to `rgb(238, 242, 247)` background and `rgb(93, 107, 123)` foreground, with the existing blue interaction background on hover.

- [x] **Step 2: Run the focused specs and verify RED**

Run `document-experience.spec.ts` and `angelscript-theme.spec.ts`. Expected: FAIL because current toolbar buttons are 32×32px, save/Command Palette remain visible through incorrectly titled configs, Home/More remain hidden, and untagged resolves to dark `rgb(92,112,128)` behind `rgb(119,119,119)`.

- [x] **Step 3: Correct the canonical visibility tiddlers**

Use titles of the exact form `$:/config/PageControlButtons/Visibility/$:/core/ui/Buttons/<name>`. Show Home, More actions, and control panel; hide save-wiki, CommandPalette, new-journal, refresh, layout, and advanced-search. New tiddler, Markdown, and draw.io remain visible through their existing default/manifest registration. Add a `$:/tags/PageControls` list-field override that orders the approved visible controls exactly as the reference toolbar while leaving unlisted hidden controls registered for the More actions menu.

- [x] **Step 4: Restore compact geometry and semantic untagged color**

Inside the desktop media query, override only `.tc-page-controls button` to `min-width: auto; min-height: auto` after the isolated-control 32px rule. Set `untagged-background` to `#eef2f7`; give `.tc-more-sidebar .tc-untagged-label.tc-tag-label` `#5d6b7b` text and `#d8dee6` border, with the existing interaction tokens on hover/active.

- [x] **Step 5: Verify and capture**

Run focused specs, `check`, `lint:all`, `build`, and full Playwright. Capture the toolbar plus More/Tags default and hovered untagged states at 2048×830, inspect them against the RefWiki runtime screenshot, validate OpenSpec strictly, and leave changes unstaged.
