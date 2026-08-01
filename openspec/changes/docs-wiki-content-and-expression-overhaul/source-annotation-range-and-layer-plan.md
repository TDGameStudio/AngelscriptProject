# Source Annotation Range and Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make whole-line annotations underline only actual source characters and paint connectors below source ink until the current relationship is explicitly pinned.

**Architecture:** Keep the existing Highlight-owned `<pre>/<code>` and sibling overlay architecture. Split whole-line visual measurement into trimmed per-line DOM ranges while preserving exact `match` measurement, and reuse the existing single SVG connector layer with a disclosure-controlled stacking state so only its active path is visible when elevated.

**Tech Stack:** TiddlyWiki 5 widgets, TypeScript, CSS/SVG, DOM Range, Playwright, Node 24, pnpm 11.8.0.

## Global Constraints

- Do not add an external runtime dependency.
- Do not insert annotation nodes into `<pre>/<code>` or change copied source.
- Exact `match` offsets and geometry remain unchanged.
- Indentation, trailing whitespace, and empty lines receive no visible underline or fill.
- Hover/focus does not elevate connectors; click/Enter/Space disclosure does.
- Narrow and print modes continue to hide connectors and range overlays.
- Do not commit or push from the current dirty workspace unless the user explicitly asks.

---

### Task 1: Lock the two regressions with Playwright

**Files:**
- Modify: `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeExample.tid`
- Modify: `Wiki/tests/playwright/product/code/annotated-code.spec.ts`

**Interfaces:**
- Consumes: existing `<$code-note line toLine>` fixture and `.angelscript-code-connectors` SVG.
- Produces: regression assertions for trimmed whole-line marks and disclosure-controlled connector stacking.

- [x] **Step 1: Add indentation to the existing two-line whole-range fixture**

Keep displayed lines 11–12 and the existing `完整两行` note, but prefix both source lines with different indentation so mark geometry can be compared with the first non-whitespace character.

- [x] **Step 2: Add failing range geometry assertions**

For both marks owned by `完整两行`, construct DOM Ranges over each line's trimmed text and assert the overlay mark `x`, `y`, and `width` differ by less than `0.75px`. Assert the explicit empty-line fixture keeps a resolved anchor but has `border-bottom-style: none` and a transparent background.

- [x] **Step 3: Add failing connector stacking assertions**

On the two-note lifecycle fixture, assert:

```ts
await expect(connectors).toHaveCSS('z-index', '0');
await firstSummary.hover();
await expect(connectors).toHaveCSS('z-index', '0');
await firstSummary.click();
await expect(connectors).toHaveCSS('z-index', '4');
await expect(firstConnector).toHaveCSS('opacity', '1');
await expect(secondConnector).toHaveCSS('opacity', '0');
await firstSummary.click();
await expect(connectors).toHaveCSS('z-index', '0');
```

- [x] **Step 4: Run the focused code test and confirm RED**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature code
```

Expected: the new trimmed-range and default/elevated connector assertions fail against the current implementation.

### Task 2: Implement content-aware marks and disclosure layering

**Files:**
- Modify: `Wiki/src/angelscript-tools/index.ts`
- Modify: `Wiki/src/angelscript-tools/index.css`
- Test: `Wiki/tests/playwright/product/code/annotated-code.spec.ts`

**Interfaces:**
- Consumes: `ResolvedNote.hasMatch`, `startOffset`, `endOffset`, existing `setDetailState()`, `.is-active`, and one owned SVG connector layer.
- Produces: per-line visible source segments and `.angelscript-code-connectors.is-elevated`.

- [x] **Step 1: Render no-match annotations as trimmed per-line DOM ranges**

In `renderRangeMark()`, preserve the existing single native Range for `note.hasMatch`. Otherwise split `code.textContent.slice(note.startOffset, note.endOffset)` on newlines, compute each line's leading/trailing whitespace, and create one native Range only for each non-empty trimmed segment. Reuse the existing text-boundary mapping and overlay creation for every segment.

- [x] **Step 2: Make the explicit empty-line anchor invisible**

Keep the existing non-zero empty-line geometry so its source port and connector remain resolvable, but add `.angelscript-code-range-mark--empty-line` rules that remove `border-bottom` and `background`.

- [x] **Step 3: Put the connector SVG below source by default**

Change `.angelscript-code-connectors` from `z-index: 4` to `z-index: 0`. Add `.is-elevated { z-index: 4; }`; while elevated, set non-active connector paths to `opacity: 0` and retain the active path at `opacity: 1`.

- [x] **Step 4: Tie elevation to disclosure rather than preview**

In `setDetailState()`, add `is-elevated` only while `openNoteId` owns an open detail. Hover/focus continues to call `setActive()` without elevating. Closing, switching, outside click, `Escape`, refresh, and destroy remove the elevation class through the existing detail-state lifecycle.

- [x] **Step 5: Run the code domain and confirm GREEN**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature code
```

Expected: all code-domain tests pass.

### Task 3: Verify production pages and record completion

**Files:**
- Modify: `openspec/changes/docs-wiki-content-and-expression-overhaul/tasks.md`
- Modify: `openspec/changes/docs-wiki-content-and-expression-overhaul/verification-source-explanations-2026-07-31.md`

**Interfaces:**
- Consumes: the corrected widget and P02/P04 production evidence pages.
- Produces: rebuilt offline Wiki, comparison screenshots, and a recorded verification result.

- [x] **Step 1: Run static and build verification**

Run:

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run check
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run build:wiki
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:artifact
```

Expected: all commands pass.

- [x] **Step 2: Capture and inspect P02/P04 screenshots**

Capture both production tiddlers from `Wiki/dist/index.html`. Confirm each full-line mark begins at the first source character, empty indentation is unmarked, inactive connectors sit visually behind source ink, and a clicked connector is readable above it without elevating sibling paths.

- [x] **Step 3: Update the OpenSpec record**

Mark task 2.17 complete and append the exact code-domain, check, build, artifact, and visual results to `verification-source-explanations-2026-07-31.md`. Preserve the existing unrelated repository baseline blockers.
