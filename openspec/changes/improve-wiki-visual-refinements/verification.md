# Verification — 2026-07-23

## Focused visual regression

From `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
```

Initial result: **9 passed (8.1s)**. A visual follow-up established that the More content panel's inherited left border is intentional but incorrectly overlaid the category column. The focused test now asserts one `1px` panel divider and a minimum `4px` geometry gap from the category-column bounds; after applying the `0.5rem` panel offset, it passed at **9/9 (9.2s)**. The focused coverage includes the hidden idle resize rail, hover/drag presentation and resize geometry, the separated More-sidebar divider plus focus behavior, and SDK description/tag/body ordering and spacing.

## Project checks

From `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:playwright
npm exec --yes pnpm@11.8.0 -- run build
```

Results:

- Type check: passed.
- Lint: passed with no errors or warnings after formatting the added assertion.
- Full Playwright suite: **32 passed (26.4s)**.
- Build: passed; the Wiki build prepared its eight already-enabled local sources and compiled browser-consumable bundles for **local validation only**. Nothing was published, distributed, or released.

At the host root:

```powershell
openspec validate improve-wiki-visual-refinements --strict
git -C Wiki diff --check
```

Results: the OpenSpec change is valid and the Wiki diff has no whitespace errors. Git only reports the repository's existing LF-to-CRLF normalization notices for the three modified text files.

## Environment note

The default Playwright web-server command initially encountered `ENOTEMPTY` while a user-owned external-plugin watcher was concurrently updating `.generated/plugin-sources`. The detailed evidence and safe workaround are retained in `handoffs/task-2-report.md`. No user process or reference image was stopped, deleted, or edited.

The current `Wiki/` workspace is treated as a Wiki development project. Future use of `publish`, external deployment, package distribution, or release procedures requires an explicit user request; a local `build` by itself is not publication work.

# Left-sidebar standalone experiments — 2026-07-24

## Focused preview regression

From `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/sidebar-experiment-previews.spec.ts
```

Fresh result: **12 passed (10.5s)**. The suite covers all three self-contained preview files, shared content, desktop and mobile open/close behavior, pointer and keyboard resize bounds, the three stable resize affordances, and reduced motion. The selected compact-rail case additionally covers:

- five keyboard-operable main panels and stable main-tiddler content;
- five open items, per-item close behavior, live count, integrated close-all presentation, and the empty state;
- grouped Recent content;
- the original Tools checkbox/button/description row structure;
- the original More vertical category/divider/content geometry;
- collapsible AS navigation;
- the persistent rail, its zones, labels, states, and tooltips;
- the page-level More action menu;
- the original four-action tiddler view toolbar and its distinct tiddler-level More menu;
- Escape dismissal with focus restoration.

The close-all empty-state assertion and the Tools/More/menu assertions were each observed failing against the preceding implementation before their corresponding fixes.

## Project verification

From `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:source-boundaries
npm exec --yes pnpm@11.8.0 -- run test:playwright
npm exec --yes pnpm@11.8.0 -- run build:wiki
```

Fresh results:

- TypeScript check: passed.
- ESLint: passed.
- Source-boundary tests: **9 passed**.
- Full product Playwright suite: **55 passed (39.7s)**.
- Integrated offline Wiki build: passed and produced `Wiki/dist/index.html` (3,943,613 bytes).

The first build attempt encountered the already documented `ENOTEMPTY` conflict because the assistant-owned read-only preview service on port `8080` still held `.generated/plugin-sources`. Port `8081` was confirmed as a separate existing service and was left untouched. Only the assistant-owned `8080` process and its esbuild child were stopped, `build:wiki` then completed and prepared the eight already-enabled product sources, and the same read-only preview service was restarted successfully on `http://127.0.0.1:8080`. This build was local Wiki integration validation only: no package publication, plugin release, upload, deployment, or push occurred.

At the host root:

```powershell
openspec validate improve-wiki-visual-refinements --strict
git -C Wiki diff --check
git diff --check -- openspec/changes/improve-wiki-visual-refinements
```

Fresh results: the OpenSpec change is valid and both Wiki and formal OpenSpec diffs have no whitespace errors.

## Visual inspection and boundaries

Desktop screenshots were inspected for the selected compact candidate's default Open panel, original-layout Tools panel, original-layout More/Tags panel, page-level More action popup, tiddler view toolbar, and tiddler-level More popup. The close-all control was inspected again after fixing a CSS rule that had incorrectly made its hidden empty state visible alongside the populated list.

The formal production theme, TiddlyWiki templates, runtime plugin source, and resize implementation were not changed by this experiment pass. The additional local file `03-compact-control-rail - 备份.html` was not created or modified by this pass and remains outside the intended three-file commit.

## Environment note

The project declares Node `>=24 <25`; this machine currently uses Node `25.5.0` with pnpm `11.8.0`. The package manager emitted the expected engine warning, but the fresh check, lint, tests, and integrated build all completed successfully. Node 24 remains the documented supported baseline.
