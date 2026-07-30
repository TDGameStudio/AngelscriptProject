# AngelscriptWiki Visual Refinements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the reviewed sidebar visual distractions and compact SDK description-to-tag spacing without changing document metadata order.

**Architecture:** The correction stays inside the existing CSS ownership boundaries: the imported sidebar-resizer owns its rail pseudo-element, and the local Angelscript theme owns the More-sidebar and SDK-document overrides. Playwright checks the resulting browser behavior and geometry rather than exposing new runtime APIs.

**Tech Stack:** TiddlyWiki 5.4, CSS packaged in `.tid` and `.css` plugin sources, Playwright, TypeScript test source, pnpm 11.8.0 through `npm exec`.

## Global Constraints

- Work in the current `Wiki/` submodule checkout; do not create or switch worktrees.
- Preserve unrelated untracked image/reference assets and do not edit `.generated/`.
- Do not change the right-sidebar, focused-story, Notion-light baseline, resize geometry, drag calculation, or public WikiText interfaces.
- Keep `as-sdk-document: yes` metadata in its existing title → description → tag → body order; only reduce description-to-tag whitespace and preserve the tag-to-body reading break.
- Modify only `vendor/tiddlyseq/src/sidebar-resizer/style.css`, `src/angelscript-theme/desktop-refinement.tid`, and `wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts` unless verification proves another file is required.
- Use `npm exec --yes pnpm@11.8.0 -- ...` because global `pnpm` is unavailable.
- Do not create a commit: the Wiki worktree already contains user-owned untracked reference images and the user has not requested a commit.

---

### Task 1: Add browser regression coverage for the reviewed states

**Files:**

- Modify: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`
- Test: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

**Interfaces:**

- Consumes: `#gk0wk-sidebar-resize-area`, `.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button`, `.as-sdk-description`, `.tc-tags-wrapper`, and `.tc-tiddler-body` rendered by the development Wiki.
- Produces: Focused regression tests named around `resize rail`, `More sidebar`, and `SDK description` for Task 2 to satisfy.

- [ ] **Step 1: Confirm the focused baseline**

Run: `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

Expected: The existing seven tests pass before test expectations are changed.

- [ ] **Step 2: Make the resize assertion describe the requested idle state**

In the existing `keeps the sidebar resize rail full-height and restrained while Tools scrolls` case, replace the idle opacity range assertion with:

```ts
expect(initial.railOpacity).toBe(0);
```

Keep its hover, active-drag, full-height, and minimum-hit-target assertions unchanged.

- [ ] **Step 3: Add a failing More-sidebar rail test**

Add a focused browser case that opens `/#AS/Workflow/GettingStarted`, activates main sidebar tab index `3`, and measures every secondary category button:

```ts
const categoryButtons = page.locator(
  '.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button',
);
await expect(categoryButtons.first()).toBeVisible();
await expect.poll(() =>
  categoryButtons.evaluateAll(buttons =>
    buttons.map(button => getComputedStyle(button).borderRightWidth),
  ),
).toEqual(expect.arrayContaining(['0px']));
```

Also assert every measured value is `0px`, the selected category is visible, and a focused category receives the existing visible `2px` focus outline.

- [ ] **Step 4: Add a failing SDK spacing/order test**

Open `/#AngelscriptWikiHome`, select its SDK frame, and return the bounding boxes and sibling indexes of `.as-sdk-description`, `.tc-tags-wrapper`, and `.tc-tiddler-body`:

```ts
const descriptionToTag = tagRect.top - descriptionRect.bottom;
const tagToBody = bodyRect.top - tagRect.bottom;

expect(indexes.description).toBeLessThan(indexes.tags);
expect(indexes.tags).toBeLessThan(indexes.body);
expect(descriptionToTag).toBeLessThanOrEqual(12);
expect(tagToBody).toBeGreaterThan(descriptionToTag);
```

The body test element must be `.tc-tiddler-body`, not a text node, so the result is stable across localized body text.

- [ ] **Step 5: Run the focused tests and verify red**

Run: `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

Expected: The new expectations fail because the current idle rail opacity is `0.14`, More category buttons have a `1px` right border, and the current SDK description-to-tag gap is `26.39px`; existing selectors and fixtures load successfully. The npm wrapper does not forward `--grep` correctly, so the nine-test theme spec is the reliable focused command.

### Task 2: Apply the smallest scoped CSS corrections

**Files:**

- Modify: `Wiki/vendor/tiddlyseq/src/sidebar-resizer/style.css`
- Modify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Test: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

**Interfaces:**

- Consumes: Task 1's focused test names and layout measurements.
- Produces: Existing desktop sidebar behavior with only the requested visual refinements.

- [ ] **Step 1: Hide only the idle resize decoration**

In `vendor/tiddlyseq/src/sidebar-resizer/style.css`, update the existing `div#gk0wk-sidebar-resize-area::before` state to:

```css
opacity: 0;
```

Retain its `width: 1px`, `transition`, and all hit-area properties. Retain the existing hover state at `opacity: 0.42` and the active state at `width: 2px; opacity: 0.68`.

- [ ] **Step 2: Remove only the More-sidebar category right border**

Add this local override to `src/angelscript-theme/desktop-refinement.tid` outside the desktop media query so it follows the existing More-sidebar presentation rules:

```css
.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button {
  border-right: none;
}
```

Do not reset any other border, background, outline, selected state, hover state, or generic tab selector.

- [ ] **Step 3: Compact only SDK description-to-tag spacing**

Add these local, SDK-scoped rules to the same stylesheet:

```css
.tc-tiddler-frame:has(.as-sdk-title) .as-sdk-description {
  margin: 0.35rem 0 0.5rem;
}

.tc-tiddler-frame:has(.as-sdk-title) .as-sdk-description + .tc-tags-wrapper {
  margin-top: 0;
}
```

Do not alter `.tc-tags-wrapper` globally or its bottom margin.

- [ ] **Step 4: Run focused tests and verify green**

Run: `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

Expected: All requested interaction, border, spacing, and order assertions pass. If the measured description-to-tag gap exceeds `12px`, adjust only the two scoped Task 2 margins and rerun until it passes without reducing the tag-to-body reading break.

### Task 3: Inspect and validate the integrated Wiki change

**Files:**

- Verify: `Wiki/vendor/tiddlyseq/src/sidebar-resizer/style.css`
- Verify: `Wiki/src/angelscript-theme/desktop-refinement.tid`
- Verify: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`
- Update: `openspec/changes/improve-wiki-visual-refinements/tasks.md`

**Interfaces:**

- Consumes: Task 2's passing focused tests.
- Produces: Evidence-backed visual, type, lint, browser, build, and OpenSpec verification.

- [ ] **Step 1: Inspect the desktop presentation**

Use the local development Wiki at `http://127.0.0.1:8080/` or a Playwright screenshot at desktop width to check the idle/hover/drag resize rail, the More sidebar without a vertical category rail, and `AngelscriptWikiHome` against `Wiki/临时参考4.jpg`. Do not modify reference image assets.

- [ ] **Step 2: Run project verification from `Wiki/`**

Run:

```powershell
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:playwright
npm exec --yes pnpm@11.8.0 -- run build
```

Expected: Each command exits with code `0`; investigate any failure before claiming completion.

- [ ] **Step 3: Validate the record and inspect exact diffs**

Run from the host root:

```powershell
openspec validate improve-wiki-visual-refinements --strict
git -C Wiki diff --check
git -C Wiki diff -- vendor/tiddlyseq/src/sidebar-resizer/style.css src/angelscript-theme/desktop-refinement.tid wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
git diff --check -- openspec/changes/improve-wiki-visual-refinements
```

Expected: The OpenSpec change validates and no whitespace error or unintended source path appears. Mark only the completed OpenSpec checklist items as `[x]`.
