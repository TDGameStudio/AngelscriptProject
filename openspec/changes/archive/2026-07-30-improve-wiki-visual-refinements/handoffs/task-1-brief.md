# Task 1: Browser regression coverage

Read this file first. It is the complete requirement for this task.

## Scope

This is Task 1 of the `improve-wiki-visual-refinements` change in the AngelscriptWiki submodule. Implement **only** browser regression coverage in `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`; do not change CSS, TiddlyWiki source, OpenSpec requirements, generated files, or reference images.

The Wiki baseline test suite was run before this task and its seven existing tests passed. Global `pnpm` is unavailable; run all project commands as `npm exec --yes pnpm@11.8.0 -- ...` from `Wiki/`. Do not commit, stage, reset, or revert anything: the Wiki worktree has user-owned untracked reference images.

## Required red assertions

1. In the existing test named `keeps the sidebar resize rail full-height and restrained while Tools scrolls`, change the idle rail expectation from an opacity range to exactly:

```ts
expect(initial.railOpacity).toBe(0);
```

Keep its hit target, fixed geometry, hover, active drag, and resize assertions.

2. Add one test whose name includes `More sidebar`. It opens `/#AS/Workflow/GettingStarted`, clicks main sidebar tab index `3`, locates `.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button`, and asserts all secondary category buttons have `borderRightWidth === '0px'`. It must also prove the selected button remains visible and a focused category button retains the existing 2px visible focus outline.

3. Add one test whose name includes `SDK description`. It opens `/#AngelscriptWikiHome`, identifies the SDK tiddler frame, and measures `.as-sdk-description`, `.tc-tags-wrapper`, and `.tc-tiddler-body`. It must assert sibling order description < tags < body, `descriptionToTag <= 12`, and `tagToBody > descriptionToTag`. Do not use a body text node; measure the body element.

## Required red verification

Run:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts --grep "resize rail|More sidebar|SDK description"
```

The command must fail because the present CSS has idle opacity `0.14`, a `1px` More-sidebar right border, and an overly large SDK description-to-tag gap. The report must distinguish expected assertion failures from fixture/selector problems.

## Report

Use `apply_patch` to write a concise result, changed paths, the red-command result, and any concern to `openspec/changes/improve-wiki-visual-refinements/handoffs/task-1-report.md`. Do not implement the CSS fix. In your final response, return only `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED` plus one short sentence.
