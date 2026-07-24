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

# Compact control rail production migration — 2026-07-24

## TDD and focused regression

The production contract was added first to:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/angelscript-theme.spec.ts tests/playwright/product/document-experience.spec.ts
```

Before the production implementation, the focused run reported **18 passed and 8 failed**. The failures were the intended missing-contract failures: no compact control rail, the old `280px` sidebar geometry, no focusable/keyboard-operable ARIA separator, and selectors finding no native rail controls. After synchronizing the source bridge and implementing the rail, the same two-spec surface passed. Follow-up visual findings for the Open list, close-all control, Tools rows, and the rail More popup were also captured as failing Playwright assertions before their scoped CSS corrections.

The follow-up full suite includes **14 Angelscript theme cases**, **17 document-experience cases**, and the unchanged **12 standalone preview cases**.

## Product implementation evidence

- The desktop rail is a theme-guarded `$:/tags/PageTemplate` extension ordered before the core sidebar.
- Its six actions transclude the existing Home, More, New Tiddler, Command Palette, Language, and Control Panel button tiddlers. Palette is not an independent rail control and remains available through Control Panel. No preview SVG path or Unicode icon placeholder was copied into production.
- The default `264px` total width is split into a persistent `40px` rail and `224px` sidebar content region. Closing the sidebar retains the `40px` rail; the narrow drawer remains rail-free.
- The resize target remains `12px` wide with a quiet persistent `1px` seam. It exposes `role="separator"`, vertical orientation, current/min/max ARIA values, `8px` arrow adjustments, and Home/End bounds.
- The Open list uses a single-line ellipsized title, a `24px` per-item close target revealed on hover/focus, and an integrated `36px` close-all row.
- Tools keeps the native checkbox/button/description structure while constraining labels and descriptions to single-line ellipsis. More/Tags and AS keep the native information architecture.
- The page-level More popup opens to the right of the rail and the tiddler-level More popup retains native actions with aligned icon/label coloring.
- `Agents_ZH.md` was updated before `Agents.md`; both now require Knot `tw5` knowledge lookup first, local TiddlyWiki `5.4.1` source/runtime verification second, and official documentation as fallback.

## Fresh verification

From `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:source-boundaries
npm exec --yes pnpm@11.8.0 -- run test:product-sources
npm exec --yes pnpm@11.8.0 -- run test:playwright
npm exec --yes pnpm@11.8.0 -- run build:wiki
npm exec --yes pnpm@11.8.0 -- run test:artifact
```

Fresh results:

- TypeScript check: passed.
- ESLint: passed with **0 errors and 0 warnings**.
- Source-boundary tests: **9 passed**.
- Product-source tests: **4 passed**.
- Full product Playwright suite: **60 passed (41.6s)**.
- Integrated offline Wiki build: passed. It prepared the eight source components already declared by the product and emitted one integrated Wiki; it did not generate standalone plugin packages.
- Offline artifact test: **1 passed**.

From the host root:

```powershell
openspec validate improve-wiki-visual-refinements --strict
git -C Wiki diff --check
git diff --check -- openspec/changes/improve-wiki-visual-refinements
```

Fresh results: the active OpenSpec change is valid and both intended diffs have no whitespace errors. Git only reports the repository's existing LF-to-CRLF normalization notices.

## Visual inspection and environment

Real product rendering was inspected for desktop Open, Tools, More/Tags, AS, page-level More, tiddler toolbar/More, closed, and resize-hover states, plus the `390×844` drawer. The result remains within the accepted Notion-light document style while matching the selected compact rail's spacing, surfaces, states, and information architecture.

The read-only watched preview is running at `http://127.0.0.1:8080/`. Port `8081` was not changed. The current machine still uses Node `25.5.0`, so pnpm emits the expected engine warning against the documented `>=24 <25` baseline; all fresh checks above passed, and the project baseline remains Node 24.

# Compact rail fidelity follow-up — 2026-07-24

## TDD evidence

The follow-up assertions were added before the implementation. The first two-spec run reported **26 passed and 5 failed**. The failures were the intended deltas:

- the rail still exposed seven controls including Palette instead of the selected six-control set;
- the utility controls were ordered Control Panel before Language;
- the main sidebar selected tab still used an inherited background and `2px` button border instead of the preview's transparent surface and `::after` underline;
- the Language popup extended to `1021.375px` in a `960px` viewport;
- native Control Panel selection still used the inherited theme state rather than the compact-rail state.

After implementation, the six focused Home/tab/control-order/More/Language/Control-Panel scenarios passed:

```powershell
.\node_modules\.bin\playwright.cmd test tests/playwright/product/angelscript-theme.spec.ts tests/playwright/product/document-experience.spec.ts --grep "uses native TW controls|matches the compact preview tab row|uses the compact RefWiki page-control geometry|opens the rail More menu|keeps the toolbar language control|opens Settings as the native ControlPanel"
```

Result: **6 passed**.

## Runtime and visual evidence

- Open, Recent, Tools, More, and AS use the preview's `34px` tab height, `13px` gap, neutral/selected text treatment, and absolute `2px` underline without a layout-changing selected border.
- Home uses the preview selection only when `$:/HistoryList!!current-tiddler` is `AngelscriptWikiHome`; navigating to Control Panel removes the Home state and selects only Control Panel.
- More preserves the native popup and gains the same selected rail presentation while open.
- The bottom rail contains Language above Control Panel. Language opens upward to the right and remains inside the `1440×960` viewport. Control Panel continues to open `$:/ControlPanel` as a native focused tiddler and does not create another settings popup.
- Palette was removed only as an independent compact-rail action; the setting remains available through Control Panel.
- Real `1440×960` Home, More, Language, and Control Panel states were compared with `03-compact-control-rail.html`.

## Fresh verification

From `Wiki/`:

- TypeScript check: passed.
- Local ESLint: passed with **0 errors and 0 warnings**.
- Source-boundary tests: **9 passed**.
- Product-source tests: **4 passed**.
- Full product Playwright suite: **62 passed (49.8s)**.
- Integrated offline Wiki build: passed and emitted one Wiki from the eight already-declared internal source components; it did not emit standalone plugin packages.
- Offline artifact test: **1 passed**.
- Wiki diff check: passed with only the repository's existing LF-to-CRLF notices.

The first standalone product-source preparation attempt raced the already-running development watcher on `.generated/plugin-sources` and received Windows `ENOTEMPTY`. The stale watcher tree was stopped after browser verification, the same preparation completed successfully as part of `build:wiki`, and the watched preview was then restarted. The final preview responds with HTTP `200` at `http://127.0.0.1:8080/`; port `8081` remains independently owned by its original process.

# TW-native expanded-panel fidelity — 2026-07-24

## TDD and debugging evidence

The icon-map and panel contracts were written before their implementations:

- `test:source-boundaries` first failed because the scoped icon map and panel shadow tiddlers did not exist.
- The five new browser scenarios first failed because production had no 03-style Open, Recent, Tools, More/Tags, or AS structures.
- The first implementation exposed three TiddlyWiki-specific errors rather than being papered over with static data: hyphenated custom filter-function names were parsed as ordinary filter syntax, a Recent outer list repeated its groups once per history item, and `is[tiddler]` excluded core/plugin PageControl shadows. Dotted filter-function names, a one-result outer guard, and `all[shadows+tiddlers]` corrected the runtime contracts.
- Computed-style assertions then caught global `tc-tiddlylink` borders/weights, SVG fill inheritance, and the inherited `8px` More-content margin. Panel-qualified selectors and a scoped `data-as-icon` line-SVG rule corrected those collisions.

Focused results before the full verification checkpoint:

- Five new expanded-panel scenarios: **5 passed**.
- Combined Angelscript theme, document experience, and expanded-panel suite: **36 passed (25.8s)**.

## Fresh full verification

From `Wiki/`:

- TypeScript check: passed.
- Local and bounded vendor ESLint: passed with **0 errors and 0 warnings**.
- Source-boundary contracts: **12 passed**.
- Product-source contracts: **4 passed**.
- Full product Playwright suite: **67 passed (54.9s)**.
- Integrated offline Wiki build: passed. The preparation message enumerates the eight already-declared internal source components consumed by the build; the command emitted the single integrated Wiki and did not create standalone plugin packages.
- Offline artifact test: **1 passed**.

From the host root:

- `openspec validate improve-wiki-visual-refinements --strict`: passed.
- Wiki and scoped OpenSpec diff checks: passed, apart from the repository's existing LF-to-CRLF normalization notices.

The watched preview remained available at `http://127.0.0.1:8080/` and was opened for the user after the implementation. Port `8081` was not touched. The machine still reports Node `25.5.0`, so pnpm emits the known engine warning against the project baseline `>=24 <25`; all checks above passed.
