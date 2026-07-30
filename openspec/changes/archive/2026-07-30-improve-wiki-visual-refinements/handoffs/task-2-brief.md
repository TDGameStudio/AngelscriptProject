# Task 2: Scoped CSS corrections

Read this file first. It is the complete requirement for this task.

## Scope

This is Task 2 of the `improve-wiki-visual-refinements` change in the shared AngelscriptWiki workspace. Task 1 added regression tests in `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`; the current nine-test focused spec fails exactly three expected assertions: idle resize opacity is `0.14` rather than `0`, most More-sidebar category buttons have a `1px` right border rather than `0px`, and `AngelscriptWikiHome` has a `26.39px` description-to-tag gap rather than at most `12px`.

Modify **only** these production source paths:

- `Wiki/vendor/tiddlyseq/src/sidebar-resizer/style.css`
- `Wiki/src/angelscript-theme/desktop-refinement.tid`

Do not change tests, OpenSpec artifacts, generated files, reference images, drag logic, selector order unrelated to the request, or any user-owned untracked files. Do not commit, stage, reset, or revert.

## Exact CSS changes

1. In `style.css`, leave the existing fixed 12px, full-height resize hit target and all pointer/drag behavior untouched. In `div#gk0wk-sidebar-resize-area::before`, change only idle visual state from:

```css
opacity: 0.14;
```

to:

```css
opacity: 0;
```

Keep the existing hover `opacity: 0.42` and active `width: 2px; opacity: 0.68` declarations.

2. In `desktop-refinement.tid`, add a narrow local override outside the desktop media query:

```css
.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button {
  border-right: none;
}
```

Do not reset other borders, backgrounds, hover states, selected states, or focus outlines.

3. In the same local theme refinement, add only these SDK-scoped spacing rules:

```css
.tc-tiddler-frame:has(.as-sdk-title) .as-sdk-description {
  margin: 0.35rem 0 0.5rem;
}

.tc-tiddler-frame:has(.as-sdk-title) .as-sdk-description + .tc-tags-wrapper {
  margin-top: 0;
}
```

Do not alter `.tc-tags-wrapper` globally, its inherited bottom margin, or ViewTemplate order. SDK metadata must remain title → description → tag → body.

## Required green verification

Run this reliable focused test command from `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
```

Global `pnpm` is unavailable. Do not use `--grep`: npm's wrapper does not forward it to Playwright correctly. Expected: all nine tests pass. If `descriptionToTag` still exceeds `12px`, adjust only the Task 2 scoped description/tag margins and rerun. Do not change the test threshold or body gap expectation.

## Report

Use `apply_patch` to write a concise changed-paths summary, exact green-command result, and any concern to `openspec/changes/improve-wiki-visual-refinements/handoffs/task-2-report.md`. Return only `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED` plus one short sentence.
