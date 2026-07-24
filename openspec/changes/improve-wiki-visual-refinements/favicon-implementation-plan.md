# Native SVG Wiki Favicon Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Wiki's binary ICO browser favicon with the approved `angelscript-icon.svg` while retaining TiddlyWiki 5.4.1's native `$:/favicon.ico` runtime lifecycle.

**Architecture:** Store the reviewed SVG as a filesystem tiddler whose metadata maps it to the canonical `$:/favicon.ico` title with type `image/svg+xml`. TiddlyWiki's existing favicon startup module will serialize it into a data URI and update `link#faviconLink`; no RawMarkup link, custom startup code, external favicon artifact, or internal control-icon change is introduced.

**Tech Stack:** TiddlyWiki 5.4.1 filesystem tiddlers, Node.js 24 test runner, Playwright 1.61, pnpm 11.8.0, OpenSpec.

**Status:** Implemented and verified. Task 5 supersedes the rejected semi-transparent canvas recorded in Task 4.

## Global Constraints

- Work in the current `D:/Workspace/AngelscriptProject/Wiki` main checkout; do not create a worktree.
- Keep the canonical tiddler title exactly `$:/favicon.ico` and set its type exactly to `image/svg+xml`.
- Preserve the supplied path data and AngelScript title; use the approved final view box `236 207 780 780` with no background `<rect>`, and do not redraw or optimize the artwork.
- Affect only browser favicon surfaces; do not modify compact-rail, sidebar, Command Palette, toolbar, or document icon tiddlers.
- The integrated build must remain a single `dist/index.html`; do not emit a favicon file, standalone plugin packages, or plugin-library artifacts.
- Do not push, publish, deploy, archive the OpenSpec, or package plugins.
- Do not stage or modify unrelated untracked comparison artifacts or `临时图片2.jpg`.

---

## File Map

- `Wiki/scripts/core-contract.test.mjs`: source-level contract for the physical SVG, canonical metadata mapping, and removal of the old ICO source.
- `Wiki/scripts/publish-offline.test.mjs`: integrated artifact contract for `$:/favicon.ico`, its SVG MIME type/body, and the single-file `dist/` boundary.
- `Wiki/tests/playwright/product/angelscript-defaults.spec.ts`: runtime contract for TiddlyWiki's loaded favicon tiddler and `link#faviconLink` data URI.
- `Wiki/wiki/tiddlers/system/$__favicon.svg`: approved SVG payload moved from `Wiki/angelscript-icon.svg`.
- `Wiki/wiki/tiddlers/system/$__favicon.svg.meta`: metadata mapping the SVG payload to `$:/favicon.ico` with `image/svg+xml`.
- `Wiki/wiki/tiddlers/system/$__favicon.ico`: former binary favicon payload, removed.
- `Wiki/wiki/tiddlers/system/$__favicon.ico.meta`: former ICO metadata, removed.
- `openspec/changes/improve-wiki-visual-refinements/tasks.md`: completion state for tasks 23.1–23.3.
- `openspec/changes/improve-wiki-visual-refinements/verification.md`: fresh RED/GREEN/build/browser evidence.

### Task 1: Lock the SVG favicon contract in RED

**Files:**

- Modify: `Wiki/scripts/core-contract.test.mjs`
- Modify: `Wiki/scripts/publish-offline.test.mjs`
- Modify: `Wiki/tests/playwright/product/angelscript-defaults.spec.ts`

**Interfaces:**

- Consumes: existing TiddlyWiki filesystem-tiddler loading, offline tiddler store serialization, and `link#faviconLink`.
- Produces: executable source, artifact, and runtime requirements that fail against the existing ICO-backed source.

- [x] **Step 1: Add the source-level failing contract**

Add these paths beside the existing source-path constants in `Wiki/scripts/core-contract.test.mjs`:

```js
const faviconSvg = path.join(wikiRoot, 'wiki', 'tiddlers', 'system', '$__favicon.svg');
const faviconSvgMeta = `${faviconSvg}.meta`;
const legacyFaviconIco = path.join(
  wikiRoot,
  'wiki',
  'tiddlers',
  'system',
  '$__favicon.ico',
);
```

Add this test before the sidebar contracts:

```js
test('browser favicon uses the approved SVG through the native system tiddler', () => {
  assert.ok(existsSync(faviconSvg), 'Missing approved SVG favicon source');
  assert.ok(existsSync(faviconSvgMeta), 'Missing SVG favicon metadata');
  assert.equal(existsSync(legacyFaviconIco), false, 'Legacy ICO favicon source must be removed');

  const svg = readFileSync(faviconSvg, 'utf8').replace(/\r\n/g, '\n');
  const metadata = readFileSync(faviconSvgMeta, 'utf8').replace(/\r\n/g, '\n');
  assert.match(svg, /<title id="title">AngelScript 天使翅膀图标<\/title>/);
  assert.match(svg, /viewBox="86 59 1076 1076"/);
  assert.match(svg, /<rect x="86" y="59" width="1076" height="1076" fill="#ffffff"\/>/);
  assert.match(metadata, /^title: \$:\/favicon\.ico$/m);
  assert.match(metadata, /^type: image\/svg\+xml$/m);
});
```

- [x] **Step 2: Add the integrated artifact failing contract**

In `Wiki/scripts/publish-offline.test.mjs`, retain the parsed tiddlers as both an array and a title map:

```js
const offlineTiddlers = JSON.parse(offlineStoreMatch[1]);
const offlineTitles = new Set(offlineTiddlers.map(({ title }) => title));
const offlineByTitle = new Map(offlineTiddlers.map(tiddler => [tiddler.title, tiddler]));
```

Add this assertion block after the general `dist/index.html` checks:

```js
const favicon = offlineByTitle.get('$:/favicon.ico');
assert.ok(favicon, 'offline Wiki must include the native favicon system tiddler');
assert.equal(favicon.type, 'image/svg+xml');
assert.match(favicon.text, /<title id="title">AngelScript 天使翅膀图标<\/title>/);
assert.match(favicon.text, /viewBox="86 59 1076 1076"/);
assert.deepEqual(
  readdirSync(distPath),
  ['index.html'],
  'offline publish must remain a single HTML without an external favicon',
);
```

- [x] **Step 3: Add the runtime failing contract**

Extend the `state` object in `Wiki/tests/playwright/product/angelscript-defaults.spec.ts`:

```ts
faviconType: $tw.wiki.getTiddler('$:/favicon.ico')?.fields.type ?? '',
```

After the existing state assertions, add:

```ts
expect(state.faviconType).toBe('image/svg+xml');
await expect(page.locator('#faviconLink')).toHaveAttribute('href', /^data:image\/svg\+xml/);
```

- [x] **Step 4: Run the source contract and verify RED**

Run from `Wiki/`:

```powershell
node --test scripts/core-contract.test.mjs
```

Expected: exactly the new favicon contract fails with `Missing approved SVG favicon source`; unrelated source contracts pass.

- [x] **Step 5: Run the artifact contract and verify RED**

Run from `Wiki/`:

```powershell
npm run test:artifact
```

Expected: the build completes, then the new favicon assertion fails because `$:/favicon.ico` still has type `image/x-icon`.

- [x] **Step 6: Run the focused browser contract and verify RED**

Run from `Wiki/`:

```powershell
npx playwright test tests/playwright/product/angelscript-defaults.spec.ts --grep "loads the AngelscriptWiki defaults" --reporter=list
```

Expected: the selected test fails because `faviconType` is `image/x-icon`, not `image/svg+xml`.

### Task 2: Replace the physical ICO with the approved SVG

**Files:**

- Move: `Wiki/angelscript-icon.svg` → `Wiki/wiki/tiddlers/system/$__favicon.svg`
- Create: `Wiki/wiki/tiddlers/system/$__favicon.svg.meta`
- Delete: `Wiki/wiki/tiddlers/system/$__favicon.ico`
- Delete: `Wiki/wiki/tiddlers/system/$__favicon.ico.meta`

**Interfaces:**

- Consumes: the reviewed SVG payload and TiddlyWiki's filesystem-tiddler metadata convention.
- Produces: one `$:/favicon.ico` tiddler with `type: image/svg+xml` and no legacy ICO source.

- [x] **Step 1: Move the approved SVG without changing its body**

Move `Wiki/angelscript-icon.svg` to `Wiki/wiki/tiddlers/system/$__favicon.svg` as a byte-preserving repository move.

- [x] **Step 2: Add the canonical metadata**

Create `Wiki/wiki/tiddlers/system/$__favicon.svg.meta` with exactly:

```text
title: $:/favicon.ico
type: image/svg+xml
```

- [x] **Step 3: Remove the superseded ICO pair**

Delete:

```text
Wiki/wiki/tiddlers/system/$__favicon.ico
Wiki/wiki/tiddlers/system/$__favicon.ico.meta
```

Do not touch any file under `Wiki/src/angelscript-tools/icons/`.

- [x] **Step 4: Run the source contract and verify GREEN**

Run from `Wiki/`:

```powershell
node --test scripts/core-contract.test.mjs
```

Expected: all source contracts pass, including `browser favicon uses the approved SVG through the native system tiddler`.

### Task 3: Verify the integrated artifact and live browser

**Files:**

- Modify: `openspec/changes/improve-wiki-visual-refinements/tasks.md`
- Modify: `openspec/changes/improve-wiki-visual-refinements/verification.md`
- Generated and untracked: `Wiki/dist/index.html`

**Interfaces:**

- Consumes: the SVG-backed `$:/favicon.ico` tiddler from Task 2.
- Produces: fresh verification evidence and a running local Wiki for user review.

- [x] **Step 1: Run focused GREEN checks**

Run from `Wiki/`:

```powershell
npm run test:artifact
npx playwright test tests/playwright/product/angelscript-defaults.spec.ts --grep "loads the AngelscriptWiki defaults" --reporter=list
```

Expected: the artifact test passes with only `dist/index.html`, and the focused Playwright case passes with an SVG data URI.

- [x] **Step 2: Run scoped regression checks**

Run from `Wiki/`:

```powershell
npm run check
npm run lint:all
npm run test:source-boundaries
npm run test:product-sources
```

Expected: every command exits `0` with no test failures or lint errors. Do not rerun the unrelated full 70-case Playwright suite for this favicon-only change.

- [x] **Step 3: Validate OpenSpec and diffs**

Run from the repository root:

```powershell
openspec validate improve-wiki-visual-refinements --strict
git -C Wiki diff --check
git diff --check -- openspec/changes/improve-wiki-visual-refinements
```

Expected: strict validation passes and both diff checks report no whitespace errors.

- [x] **Step 4: Inspect the live browser state**

Start the normal read-only Wiki development server on `127.0.0.1:8080`, open a fresh browser context at `/`, and verify:

```js
document.querySelector('#faviconLink')?.getAttribute('href').startsWith('data:image/svg+xml')
```

Expected: `true`; the browser tab shows the supplied black-and-white AngelScript wing icon. Port `8081` remains untouched.

- [x] **Step 5: Record evidence and complete OpenSpec tasks**

Append the exact RED/GREEN command results and browser `faviconLink` evidence to `verification.md`. Mark tasks `23.1`, `23.2`, and `23.3` complete only after every corresponding result is present.

- [x] **Step 6: Stop before integration**

Report the Wiki and host diffs, the local preview URL, and all remaining unrelated untracked files. Do not commit the Wiki implementation or host gitlink unless the user explicitly requests a Git submission after visual review.

### Task 4: Refine background transparency and small-size scale

**Files:**

- Modify: `Wiki/scripts/core-contract.test.mjs`
- Modify: `Wiki/scripts/publish-offline.test.mjs`
- Modify: `Wiki/tests/playwright/product/angelscript-defaults.spec.ts`
- Modify: `Wiki/wiki/tiddlers/system/$__favicon.svg`
- Modify: `openspec/changes/improve-wiki-visual-refinements/verification.md`

**Interfaces:**

- Consumes: the SVG-backed `$:/favicon.ico` lifecycle from Tasks 1–3.
- Produces: the approved semi-transparent contrast surface and safe six-percent canvas enlargement without path changes.

- [x] **Step 1: Tighten the contracts before editing the SVG**

Replace the old view-box assertions with:

```js
assert.match(svg, /viewBox="118 89 1016 1016"/);
assert.match(
  svg,
  /<rect x="118" y="89" width="1016" height="1016" fill="#ffffff" fill-opacity="0.72"\/>/,
);
```

Apply the same body assertions to the serialized `$:/favicon.ico` artifact, and extend the focused Playwright test to require the two declarations from the live tiddler text.

- [x] **Step 2: Run RED**

Run the source contract and focused browser defaults scenario with Node 24. Expected: both fail because the current SVG still uses `86 59 1076 1076` and an opaque background.

- [x] **Step 3: Modify only the canvas declarations**

Use exactly:

```svg
viewBox="118 89 1016 1016"
```

and:

```svg
<rect x="118" y="89" width="1016" height="1016" fill="#ffffff" fill-opacity="0.72"/>
```

Do not modify the `<path>` element or favicon metadata.

- [x] **Step 4: Run GREEN and scoped regression checks**

Run the source contract, focused Playwright scenario, artifact test, type check, lint, source boundaries, product-source boundaries, strict OpenSpec validation, and diff checks with the project-compatible Node 24/pnpm 11.8.0 entry points.

- [x] **Step 5: Inspect actual small-size rendering**

Read the live `link#faviconLink` data URI in a fresh Chromium context. Render it at `16px`, `32px`, and `64px` on `#f4f5f7` and `#1f2329` samples in one ignored screenshot. Confirm the full background corner is white with alpha approximately `184`, the black path reaches neither horizontal edge, and no sample is blank or clipped.

- [x] **Step 6: Record and stop before commit**

Append exact RED/GREEN results and the screenshot path to `verification.md`, mark OpenSpec tasks 24.1–24.3 complete, and leave both repositories uncommitted until the user approves the new favicon visually.

### Task 5: Correct the favicon against the real browser-tab screenshot

**Files:**

- Modify: `Wiki/scripts/core-contract.test.mjs`
- Modify: `Wiki/scripts/publish-offline.test.mjs`
- Modify: `Wiki/tests/playwright/product/angelscript-defaults.spec.ts`
- Modify: `Wiki/wiki/tiddlers/system/$__favicon.svg`
- Modify: `openspec/changes/improve-wiki-visual-refinements/verification.md`

**Interfaces:**

- Consumes: the SVG-backed native favicon lifecycle and the reviewed `临时图片3.jpg` browser-tab evidence.
- Produces: a fully transparent, moderately cropped favicon without the rejected grey-white square.

- [x] **Step 1: Replace the rejected assertions and run RED**

Require:

```js
assert.match(svg, /viewBox="236 207 780 780"/);
assert.doesNotMatch(svg, /<rect\b/);
```

The focused browser test must read `[0, 0, 0, 0]` at the `64×64` corner. Run the source contract and focused browser scenario; both must fail against the current `1016×1016` view box and `72%` background.

- [x] **Step 2: Apply the approved B composition**

Set:

```svg
viewBox="236 207 780 780"
```

Delete the full-canvas `<rect>` element. Do not edit the path or metadata.

- [x] **Step 3: Run GREEN and scoped regression checks**

Run the source contract, focused browser scenario, artifact test, type check, lint, source boundaries, product-source boundaries, strict OpenSpec validation, and diff checks with Node 24/pnpm 11.8.0.

- [x] **Step 4: Reproduce the browser-tab review surface**

Render the live data URI inside a `20px` mock browser tab matching `临时图片3.jpg`, plus `16px`, `32px`, and `64px` samples. Confirm that no grey-white square remains and that the central roundel, halo, and inner wings are visible. Record that the crop deliberately removes a small part of the outer wing tips.

- [x] **Step 5: Record and stop before commit**

Append the screenshot-correction RED/GREEN evidence and final comparison path to `verification.md`, mark OpenSpec tasks 25.1–25.3 complete, and leave both repositories uncommitted until the user reviews the real preview.
