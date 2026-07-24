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

# Selected-reference typography and icon cleanup — 2026-07-24

## TDD evidence

The selected-reference and production assertions were changed before source implementation:

- Source boundaries failed because the product single-chevron tiddler did not exist.
- The focused browser run reported **22 passed and 5 failed**. The failures were the intended deltas: no product toggle overlay, three Open document icons, `31px` Tools rows, `10px` pre-calibration More categories, and four HTML files instead of the selected 03-only set.
- After the first implementation, **26 of 27** focused scenarios passed. The remaining failure showed an `img.tc-image-error` inside the overlay. Runtime inspection confirmed that the new tiddler existed but had been declared as `image/svg+xml`, causing TW to encode parameterized WikiText as image data. Matching the established `$:/tags/Image` plus `\parameters` pattern fixed the source error; normalizing an absent `$:/state/sidebar` to `yes` fixed the default state attribute.
- The three focused specs then passed **27/27**.
- User visual review found the production Noto Sans category labels too large at the standalone reference's `11px`. A new failing assertion captured `10px`; the category-only production rule was reduced to `10px / 400` while the selected state remained `600`. The five panel scenarios then passed **5/5**.

## Visual evidence

Real `1440×960` Open, Tools, and More/Tags panels were inspected against the retained 03 reference. Open rows and close-all now align without leading file glyphs; Tools follows the reference's compact row and type rhythm; More categories use the reviewed production-specific `10px` size while the heading and tags retain the selected hierarchy.

The open toggle shows a single left line chevron. The first closed-state screenshot caught the `160ms` rotation transition mid-frame; after settling, the glyph computed to `matrix(-1, 0, 0, -1, 0, 0)` and displayed as a right chevron. The browser assertion now waits for that exact final matrix. The native double-chevron SVG remains in the native button for behavior ownership but computes to `opacity: 0` on desktop.

## Fresh full verification

From `Wiki/`:

- The three focused Playwright specs passed **27/27**.
- TypeScript check passed.
- `lint:all` passed with **0 errors and 0 warnings**.
- Source-boundary contracts passed **12/12**.
- Product-source contracts passed **4/4**.
- The full product Playwright suite passed **63/63**. The total is intentionally four lower than the previous 67-test checkpoint because the 01 and 02 preview variants and their matrix cases were removed.
- The integrated offline Wiki build passed and emitted one Wiki from the eight already-declared internal source components; no standalone plugin packages were emitted.
- The offline artifact test passed **1/1**.
- The Wiki diff check passed.
- `comparison-artifacts/left-sidebar/` contains only `03-compact-control-rail.html`.

From the host root:

- `openspec validate improve-wiki-visual-refinements --strict` passed.
- The scoped OpenSpec diff check passed, apart from existing LF-to-CRLF normalization notices.

The watched preview responds with HTTP `200` at `http://127.0.0.1:8080/#AngelscriptWikiHome`; port `8081` was not touched. The current machine still reports Node `25.5.0`, so pnpm emits the known engine warning against the documented `>=24 <25` baseline; all checks above passed.

At this visual-review checkpoint the follow-up remained uncommitted. It did not push, publish, deploy, archive this OpenSpec, or generate standalone plugin packages.

# Command Palette glyph simplification — 2026-07-24

## TDD evidence

The source contract was added before changing the icon. Its first run reported **5 passed and 1 failed**: the existing `command.tid` exposed one long four-loop path instead of the approved two-path `>_` geometry. After replacing only the SVG body, the same focused contract passed **6/6**.

The production icon keeps the existing parameterized Image-tiddler, `24×24` view box, `data-as-icon="command"`, no-fill/current-color line treatment, rounded cap/join attributes, native icon-map title, and Command Palette PageControl behavior. Its only geometry is now:

- `M6 8l4 4-4 4` for the right-facing prompt chevron;
- `M12.5 16h5.5` for the separate baseline.

## Runtime and visual evidence

The real compact rail was inspected at `1440×960` with a `4×` device scale. The product SVG computed to `17×17px`, `fill: none`, and the expected neutral current-color stroke. The glyph remained open and balanced beside Home, More, New, Language, and Settings.

The real Tools Command Palette row was also inspected at its compact `13×13px` rendered size. The chevron and baseline remained independently legible without changing the checkbox, action label, description, or row geometry. The selected standalone 03 reference was not modified.

## Fresh verification

From `Wiki/`:

- Focused source contract: **6/6 passed** after the recorded RED run.
- Angelscript theme Playwright spec: **14/14 passed**.
- TypeScript check: passed.
- `lint:all`: passed with **0 errors and 0 warnings**.
- Source-boundary contracts: **13/13 passed**.
- Product-source contracts: **4/4 passed**.
- Full product Playwright suite: **63/63 passed**.
- Integrated offline Wiki build: passed and emitted one Wiki from the eight already-declared internal source components; it did not emit standalone plugin packages.
- Offline artifact test: **1/1 passed**.

From the host root:

- `openspec validate improve-wiki-visual-refinements --strict`: passed.
- Wiki and scoped OpenSpec diff checks: passed, apart from existing LF-to-CRLF normalization notices.
- The selected `comparison-artifacts/left-sidebar/03-compact-control-rail.html` has no diff from this production-only correction.
- The watched preview responds with HTTP `200` at `http://127.0.0.1:8080/#AngelscriptWikiHome`; port `8081` was not touched.

The current machine still reports Node `25.5.0`, so pnpm emits the known engine warning against the documented `>=24 <25` baseline. At this visual-review checkpoint the follow-up remained uncommitted and did not push, publish, deploy, archive the OpenSpec, or generate standalone plugin packages.

# Final local commit checkpoint — 2026-07-24

After user approval, the selected-reference typography, Open/toggle cleanup, and Command Palette glyph follow-up were committed in the Wiki submodule as `5b3b934` (`[Wiki] Fix: refine compact sidebar typography and icons`). The host commit records the updated Wiki gitlink together with the formal OpenSpec design, delta requirement, task checklist, and verification evidence.

Neither commit is pushed. The OpenSpec remains active and unarchived, port `8081` remains untouched, and no standalone plugin packages were generated or published.

# Preview-only compact tag popup — 2026-07-24

## Baseline and TDD evidence

Runtime inspection of the formal Wiki confirmed that the native tag reveal keeps the useful `$:/core/ui/TagTemplate` order — tag target, divider, tagged-tiddler list — but computes to a `380px` minimum width, `14px` text, square border, and no shadow. The selected 03 reference had only a static `ASWiki/Home` span and no tag-popup interaction.

The selected-preview Playwright scenario was written before modifying 03. Its first run reported **8 passed and 1 failed**; the sole new failure was the expected missing semantic `ASWiki/Home` button and associated popup. After the preview implementation, the focused suite passed **9/9**.

The first full lint checkpoint then caught an unsafe `evaluateAll` return around DOM `className` in the new test. Replacing that page-side value extraction with Playwright-native `toHaveClass` assertions retained the exact target/divider/list order contract and removed the unsafe/deprecated typing path. The rerun passed with **0 errors and 0 warnings**.

## Preview design and interaction evidence

Only `03-compact-control-rail.html` was changed:

- The tag pill is now a semantic button with `aria-controls`, `aria-haspopup="menu"`, and live `aria-expanded`.
- Its anchored popup preserves the tag-target/divider/tagged-list order and uses a `260px` white surface, `6px` radius, `#d9dde2` border, selected two-layer menu shadow, `11px` text, and `29px` rows.
- `AngelscriptWikiHome` uses the Open panel's pale-blue current surface, `2px` blue accent edge, and `500` weight. Hover/focus rows use the quieter blue surface and no document/file glyph.
- Click toggles the popup; outside click closes it; `Escape` closes and restores focus; page-level and tiddler-level action menus close the tag popup before opening.
- Representative popup links remain ordinary anchors. Formal TiddlyWiki tag templates, filters, popup state, drag/drop, theme source, and navigation were not modified.

At `1440×960`, the inspected popup measured `260×139px` at `x=349`; its computed font size was `11px`, radius `6px`, and shadow matched the selected menu token. At `390×844`, after closing the overlay drawer, it measured from `x=24` to `x=284` inside the `390px` viewport.

## Fresh verification

From `Wiki/`:

- TypeScript check: passed.
- `lint:all`: passed with **0 errors and 0 warnings** after the recorded test-only correction.
- Source-boundary contracts: **13/13 passed**.
- Product-source contracts: **4/4 passed**.
- Focused selected-preview Playwright suite: **9/9 passed**.
- Full product Playwright suite: **64/64 passed**.
- Exact diff check: passed with the repository's existing LF-to-CRLF notices.
- The only Wiki source diffs are the selected 03 HTML and its preview Playwright spec.

From the host root:

- `openspec validate improve-wiki-visual-refinements --strict`: passed.
- Scoped OpenSpec diff check: passed.
- The formal watched Wiki still responds with HTTP `200` at `http://127.0.0.1:8080/`.

The standalone file remains at `Wiki/comparison-artifacts/left-sidebar/03-compact-control-rail.html` for user review. This preview-only checkpoint did not modify production TW, touch port `8081`, commit, push, run a Wiki/plugin build, package plugins, publish, deploy, or archive the OpenSpec.

# Superseded More/Tags disclosure interpretation — 2026-07-24

User review rejected this checkpoint because it interpreted “use the same popup style as the body tag” as “replace More/Tags with an inline disclosure directory.” The RED/GREEN and visual evidence below remains a factual record of the rejected experiment, but the directory is not the accepted 03 design and is replaced by the corrected shared-popup task 19.

## TDD evidence

The selected-preview scenario was added before changing the More/Tags renderer. Its RED run reported **9 passed and 1 failed**; the sole new failure was the expected absence of `[data-more-tag-directory]` while the existing dark static tag pills remained. After implementing the disclosure directory, the same focused suite passed **10/10**.

The scenario covers seven semantic tag buttons, derived count badges, controlled hidden lists, `29px` and `11px` computed styles, pale-blue/`2px` expanded and current states, no SVG/file glyphs, single-open switching, second-activation collapse, keyboard Enter, the separated untagged group, and no horizontal overflow after moving the sidebar separator to its `240px` minimum.

## Preview design and visual evidence

Only the standalone 03 renderer was extended:

- The seven dark pills are now full-width tag disclosure rows with a quiet count and compact CSS chevron.
- Counts come from each tag group's representative tiddler array rather than a duplicated numeric field.
- Expanding a tag reveals its tiddlers inline. Opening another tag closes the previous list; activating the same tag again collapses it.
- `ASWiki/Home` exposes three representative tiddlers, with `AngelscriptWikiHome` using the established pale-blue current surface and `2px` accent edge.
- “未设标签” remains the seventh group and is separated by a restrained horizontal divider.
- The other ten More categories continue through the existing generic chip/empty-state renderer.

Desktop `1440×960` and minimum-sidebar-width screenshots were inspected. At the default `264px` sidebar width the selected label, count, chevron, and three expanded rows remain visually distinct. At the `240px` minimum, long labels use ellipsis and the More panel retains `scrollWidth <= clientWidth`; no horizontal scrollbar or overlap appears.

## Fresh verification

From `Wiki/`:

- TypeScript check: passed.
- `lint:all`: passed with **0 errors and 0 warnings** after correcting one test-only dprint line-wrap warning.
- Source-boundary contracts: **13/13 passed**.
- Product-source contracts: **4/4 passed**.
- Focused selected-preview Playwright suite: **10/10 passed** after the recorded RED run.
- Full product Playwright suite: **65/65 passed**.
- Scoped Wiki diff check: passed with only the repository's existing LF-to-CRLF notices.
- Wiki source changes remain limited to the selected 03 HTML and its preview Playwright test; formal TiddlyWiki source is unchanged.

From the host root:

- The design decision, delta scenario, implementation checklist, and this evidence were appended to the existing visual-refinement OpenSpec.
- `openspec validate improve-wiki-visual-refinements --strict`: passed.
- Scoped OpenSpec diff check passed with only existing LF-to-CRLF notices.

The current machine still reports Node `25.5.0`, so pnpm emits the known engine warning against the documented `>=24 <25` baseline. This preview-only checkpoint did not touch port `8081`, commit, push, run a Wiki/plugin build, package plugins, publish, deploy, archive the OpenSpec, or modify production TW.

# Corrected More/Tags body-style popup — 2026-07-24

## Requirement correction and TDD evidence

User review clarified that More/Tags should keep its compact tag controls and open the same floating surface as the body tag. The accepted behavior is not the preceding inline disclosure directory.

The rejected directory scenario was replaced before changing the HTML. Its RED run reported **9 passed and 1 failed**; the sole new failure was the expected absence of the seven `[data-more-tag-popup-toggle]` controls while the mistaken directory remained. After removing the directory and adding the shared popup, the desktop contract completed successfully. The first narrow rerun exposed a test-step error: the test closed the default-open mobile drawer before trying to select More. Removing that incorrect toggle action left implementation unchanged, and the focused suite passed **10/10**. A further explicit narrow `toBeVisible()` assertion also passed.

## Shared popup and visual evidence

The corrected 03 implementation keeps the compact More/Tags tag buttons and adds one popup outside the clipping sidebar DOM:

- The body and More popup use the same `.tag-popup`, `.tag-popup-target`, `.tag-popup-divider`, `.tag-popup-list`, and `.tag-popup-item` classes.
- Playwright compares their computed width, radius, background, border, shadow, text color, font size, line height, and padding as one exact object; the values are equal.
- Only positioning differs: the body popup remains absolutely anchored below the body tag, while the More popup is fixed at page level, placed beyond the desktop sidebar edge, and clamped inside the viewport.
- Selecting a new sidebar tag retargets the same popup and clears the old button; selecting the current tag closes it.
- Outside click, `Escape`, the body tag, page/tiddler action menus, More-category changes, sidebar-tab changes, sidebar resizing, and viewport resizing close the More popup. `Escape` restores trigger focus.
- Popup content retains the tag target, divider, representative tiddler list, `29px` rows, pale-blue/`2px` current item, and no file/document SVG.

At `1440×960`, the inspected `ASWiki/Home` popup begins immediately beyond the `264px` sidebar, uses the same `260px` white surface as the body popup, and displays three representative rows without clipping. At `390×844`, a real viewport screenshot and runtime geometry check confirmed `display: block`, `visibility: visible`, `z-index: 100`, and bounds `x=114…374`, fully contained inside the viewport. The earlier missing full-page screenshot was a fixed-layer screenshot-stitching artifact; the actual viewport screenshot and `elementFromPoint` both confirmed the popup is the visible top layer.

## Fresh verification

From `Wiki/`:

- Focused selected-preview Playwright suite: **10/10 passed** after the recorded RED run and narrow-test correction.
- TypeScript check: passed.
- `lint:all`: passed with **0 errors and 0 warnings** after correcting one test-only dprint line-wrap warning.
- Source-boundary contracts: **13/13 passed**.
- Product-source contracts: **4/4 passed**.
- Full product Playwright suite: **65/65 passed**.
- Scoped Wiki and OpenSpec diff checks: passed with only the repository's existing LF-to-CRLF notices.
- `openspec validate improve-wiki-visual-refinements --strict`: passed.

The corrected work remains limited to `03-compact-control-rail.html`, its preview test, and this existing visual-refinement OpenSpec. It does not modify production TiddlyWiki source, touch port `8081`, commit, push, build/package plugins, publish, deploy, or archive.

# Production sidebar tag-popup overflow correction — 2026-07-24

## Width/root-cause audit

The runtime audit confirmed that the left-sidebar resizer does not double-apply or miscalculate width. After a real pointer drag to `320px`, `$:/themes/tiddlywiki/vanilla/metrics/sidebarwidth` persisted as `320px`, the temporary `--angelscript-sidebar-width` value was removed, the rail remained `40px`, `.tc-sidebar-scrollable` measured `280px`, and the separator center plus story-river start both measured exactly `320px`.

The failure was a width-contract mismatch between the intentionally compact variable sidebar and TiddlyWiki's nested native overflow surfaces:

- The 03 production contract treats the persisted metric as the total rail-plus-content width. The More/Tags inner client width measured `115`, `139`, `195`, `235`, `275`, `315`, and `395px` at total widths `240`, `264`, `320`, `360`, `400`, `440`, and `520px`.
- Vanilla applies `overflow: auto` to both `.tc-sidebar-scrollable` and `.tc-tab-content.tc-vertical`.
- A real `260px` TagTemplate popup needs `269px` of inner scroll extent at its native anchor offset. At the default `264px` total width it expanded the inner content from `139px` to `269px`; the taller `ASWiki/Workflow` popup also expanded inner scroll height from `274px` to `382px`.
- The native `380px` Untagged Reveal uses the sidebar as its offset parent and instead expanded the outer sidebar from `224px` to `457px`.
- Independently, the theme's `width: 100%` tag-manager heading retained the native button's `2px` inline margins, producing a closed-state `139/143px` client/scroll mismatch.

The issue therefore becomes weaker or disappears when the sidebar is widened beyond roughly `394px`, but the resizer is not the defect. Raising its minimum from `240px` to approximately `394px` would destroy the selected compact layout. The correction instead resets the heading margin and portals only the currently open sidebar TagTemplate/Untagged Reveal.

Knot's `tw5` source knowledge and the locked local TiddlyWiki `5.4.1` source agree on the relevant core behavior: Reveal uses absolute positioning relative to its offset parent and does not automatically portal beyond overflow ancestors; native popup state remains managed by `$tw.popup`.

## TDD and widget-lifecycle correction

The updated source contracts were run before implementation and reported **6 passed / 2 failed**: the expected failures were the missing portal variants in the theme stylesheet and the missing startup adapter. The three new browser scenarios all failed as intended:

- the width-range scenario first observed `115px` client width versus `119px` scroll width at the `240px` minimum;
- the Untagged scenario could not find a portalled real-tag popup;
- the narrow scenario could not find a contained portal.

The first implementation made the narrow geometry pass, but the other two tests caught a TiddlyWiki widget-tree lifecycle problem: Reveal widgets reuse their own DOM node during refresh, so leaving that node under `body` while the core refreshes can empty the original TagTemplate wrapper and break native close/switch behavior. The implementation was corrected rather than weakening the tests:

- `th-page-refreshing` first restores the exact same Reveal node, original inline style, parent, and sibling position;
- core TiddlyWiki then refreshes its normal widget tree and popup state;
- `th-page-refreshed` re-adopts the node only when the corresponding native trigger still reports `aria-expanded="true"`;
- no content is cloned and the adapter never writes, deletes, or triggers popup-state tiddlers.

The source contract then passed **8/8**, the three new focused browser scenarios passed **3/3**, and the complete expanded-sidebar file passed **10/10**.

## Visual and geometry evidence

Four real runtime screenshots were captured under the ignored `Wiki/test-results/` inspection directory:

- `tag-popup-final-body-1440.png`
- `tag-popup-final-sidebar-tag-1440.png`
- `tag-popup-final-untagged-1440.png`
- `tag-popup-final-sidebar-tag-390.png`

All four were inspected directly. The body tag remains a native absolute child at `x=349`, width `260px`. At the default `264px` total desktop sidebar, both sidebar variants start at `x=272`, exactly `8px` beyond the sidebar's `x=264` edge, and align vertically with their trigger rows. The real-tag popup measures `260×175.5px`; Untagged measures `260×215px` and uses flat normal-weight rows with no target divider. The 390px drawer popup measures from `x=68` to `x=328` and from `y=244` to `y=329.5`, fully within the required `16px` viewport inset.

After the correction, default desktop geometry remains stable before and during both popups:

- inner More content: `client 139×274`, `scroll 139×274`;
- outer sidebar: `client 224×960`, `scroll 224×960`.

Playwright repeats the no-growth check at total widths `240`, `264`, `320`, `400`, and `520px`, verifies external dismissal, switches a real tag directly to Untagged with only one portal, and confirms body, macro, and TagManager popups remain native absolute children.

## Fresh verification

From `Wiki/`:

- TypeScript check: passed.
- Scoped local lint across `src`, `scripts`, tracked Playwright tests, and configuration: passed with **0 errors and 0 warnings**. The unrelated untracked homepage-concept spec remains excluded and untouched.
- Vendor lint: passed.
- Source-boundary contracts: **15/15 passed**.
- Product-source contracts: **4/4 passed**.
- TiddlyWiki node test: **1/1 passed**.
- Expanded-sidebar Playwright suite: **10/10 passed**.
- Complete tracked product Playwright suite: **70/70 passed**.
- Integrated Wiki build: passed and emitted only `Wiki/dist/index.html` (`4,015,367` bytes).
- Offline artifact test: initially could not launch its internally hard-coded global `pnpm` command; rerunning through temporary project-version `pnpm 11.8.0` passed **1/1** and rebuilt the same single HTML.
- HTTP watched preview: `200` at `http://127.0.0.1:8080/#AngelscriptWikiHome`.

The build log's “8 product plugin sources / Minimized plugins” entries are the eight already-declared internal source roots embedded into the one Wiki HTML; no standalone plugin archives or packages were emitted, published, or deployed. Node remains `25.5.0`, so pnpm reports the known engine warning against the documented `>=24 <25` baseline.

From the host root:

- `openspec validate improve-wiki-visual-refinements --strict`: passed.
- Scoped Wiki/OpenSpec `git diff --check`: passed with only the repository's existing LF-to-CRLF normalization notices.

## Commit checkpoint

The Wiki implementation, the selected `03` visual reference, and their regression coverage were committed in the Wiki submodule as `0f8f599` (`[Wiki] Fix: prevent sidebar tag popup overflow`). The host commit records that submodule revision together with this OpenSpec update. Neither repository was pushed or deployed; no standalone plugins were packaged, port `8081` was not touched, and `improve-wiki-visual-refinements` remains active for later style iterations.

## Directory-first sidebar startup — 2026-07-24

### TDD evidence

The first focused run covered the defaults, theme, document-experience, and expanded-sidebar specs. It produced **39 passed and 3 expected failures**:

- the site-subtitle segment visibility config was absent;
- `$:/config/DefaultSidebarTab` still selected core Open;
- no main sidebar tab had the localized `目录` caption.

The directory test was then tightened from a missing-locator timeout to an explicit `toHaveCount(1)` assertion and rerun RED. After the native config and WikiText changes, the first GREEN run reached **41/42**; the only remaining failure exposed an older drag/drop test that implicitly expected Open to be the default. Making that test select its own `开启` panel removed the accidental dependency. The complete focused rerun then passed **42/42**.

### Runtime inspection

The watched product at `http://127.0.0.1:8080/#AS/Workflow/GettingStarted` returned HTTP `200`. Fresh screenshots were captured under the ignored `Wiki/test-results/` directory:

- `sidebar-directory-desktop-1440.png`;
- `sidebar-directory-drawer-390.png`.

Direct inspection confirmed that the desktop header contains `AngelscriptWiki` followed immediately by the single-row `目录 / 开启 / 最近 / 工具 / 更多` tab strip, with no English subtitle or empty subtitle band. `目录` is selected on load, and the localized directory heading, two collapsible groups, current-document highlight, and SDK-document description remain visible. The opened `390×844` drawer keeps the same five tabs on one row, contains both directory groups, and shows no subtitle gap or horizontal overflow.

### Fresh verification

From `Wiki/`:

- TypeScript check: passed.
- Local lint: passed with **0 errors and 0 warnings** after applying the reported dprint-only line wrapping; vendor lint passed.
- Source-boundary contracts: **15/15 passed**.
- Product-source contracts: **4/4 passed**.
- TiddlyWiki node suite: **1/1 passed**.
- Focused product browser suite: **42/42 passed**.
- Complete product Playwright suite: **70/70 passed** in about one minute with one worker.
- Integrated Wiki build: passed and emitted only `Wiki/dist/index.html` (`4,015,513` bytes).
- Offline artifact test through the project-version `pnpm 11.8.0`: **1/1 passed** and rebuilt the same single HTML.

The build continues to report eight internal product plugin source roots that are minimized into the one Wiki HTML; it did not emit or publish eight standalone plugin packages. The known local Node `25.5.0` warning against the documented `>=24 <25` baseline remains unchanged.

The product keeps `npm run dev` intentionally read-only. Browser-side authoring still requires the existing explicit `npm run dev:wiki` command; no development-server scripts changed.

The Wiki implementation and its regression coverage were committed in the Wiki submodule as `9c4fd27` (`[Wiki] Feat: make directory the default sidebar entry`). The host commit records that submodule revision together with the updated OpenSpec design, requirement, task, and verification artifacts. Neither repository was pushed or deployed. The change does not modify `03-compact-control-rail.html`, the unrelated homepage concepts, `angelscript-icon.svg`, `临时图片.jpg`, port `8081`, publishing, OpenSpec archive state, or standalone plugin packaging.

## Native SVG browser favicon — 2026-07-24

### TDD evidence

Three independent contracts were added before the favicon source changed:

- The source contract reported **8 passed / 1 expected failure**. The new case failed with `Missing approved SVG favicon source`; every pre-existing source contract passed.
- The integrated offline build completed, then the artifact contract failed at the intended boundary because `$:/favicon.ico` still had `image/x-icon` instead of `image/svg+xml`.
- The focused real-browser defaults scenario failed at the same intended boundary because the live `$:/favicon.ico` tiddler still reported `image/x-icon`.

The first artifact attempt did not reach the product assertion because the active Scoop installation had moved to Node `25.5.0` and exposed no global `pnpm` shim. The repository still declares Node 24 in both `.nvmrc` and `package.json`. Investigation found cached, exact project-compatible executables for Node `24.18.0` and pnpm `11.8.0`; all subsequent build/test entry points used those executables process-locally without changing the global installation, repository scripts, lockfile, or dependencies.

### Implementation

The approved `Wiki/angelscript-icon.svg` payload was moved byte-for-byte to `Wiki/wiki/tiddlers/system/$__favicon.svg`. Adjacent metadata maps it to the canonical title `$:/favicon.ico` with `type: image/svg+xml`. The former `256×256` ICO payload and `image/x-icon` metadata were removed.

No RawMarkup favicon link, custom startup module, or generated ICO was added. TiddlyWiki `5.4.1` remains the behavior owner: its existing favicon startup module reads `$:/favicon.ico` and updates `link#faviconLink` with a data URI. No file under `Wiki/src/angelscript-tools/icons/` changed.

### Fresh verification

From `Wiki/`, using Node `24.18.0` and pnpm `11.8.0`:

- TypeScript check: passed.
- Local and vendor lint: passed with **0 errors**.
- Source-boundary contracts: **16/16 passed**, including the new SVG source/metadata contract.
- Product-source contracts: **4/4 passed**.
- Integrated offline artifact test: **1/1 passed** after rebuilding the Wiki.
- Focused real-browser defaults scenario: **1/1 passed**.
- The live `$:/favicon.ico` tiddler reported `image/svg+xml`.
- `link#faviconLink` matched the runtime prefix `data:image/svg+xml`; a fresh browser context measured the generated data URI at `10,961` characters.
- The decoded runtime icon was rendered and inspected at `256×256` in `Wiki/test-results/favicon-runtime-preview.png`; the white square, black wings, halo, circular outline, and central mark were present without blank output or clipping.
- `dist/` contained only `index.html` (`3,999,612` bytes); no external favicon, plugin library, JSON plugin bundle, standalone plugin package, publication, or deployment was produced.

The complete 70-case Playwright suite was not repeated for this isolated favicon resource replacement. Coverage was deliberately limited to the source mapping, integrated single-HTML serialization, real TiddlyWiki favicon lifecycle, type/lint boundaries, and product-source boundaries. Port `8081`, the selected 03 reference, unrelated homepage concepts, `临时图片2.jpg`, publishing, OpenSpec archive state, and internal Wiki icons remain untouched.

## Semi-transparent enlarged favicon canvas — 2026-07-24

### TDD evidence

The source, artifact, and focused browser contracts were tightened before the SVG changed. The source run reported **8 passed / 1 expected failure** at the old `viewBox="86 59 1076 1076"`. The focused real-browser scenario also failed at that exact old view-box declaration before it could reach the opacity assertion. Both failures therefore demonstrated the missing approved crop/background behavior rather than a fixture or favicon-loader error.

The implementation changed only two SVG declarations:

- `viewBox="118 89 1016 1016"`;
- `<rect x="118" y="89" width="1016" height="1016" fill="#ffffff" fill-opacity="0.72"/>`.

The complete path data, title, description, dimensions, aspect-ratio behavior, filesystem-tiddler metadata, and native TiddlyWiki favicon lifecycle remain unchanged.

### GREEN and regression evidence

Using Node `24.18.0` and pnpm `11.8.0`:

- Direct source contract: **9/9 passed**.
- Source-boundary contracts: **16/16 passed**.
- Product-source contracts: **4/4 passed**.
- Focused real-browser defaults/favicon scenario: **1/1 passed**.
- The browser canvas corner sample was exactly `[255, 255, 255, 184]`, matching `72%` white opacity after 8-bit rounding.
- Integrated offline artifact test: **1/1 passed**.
- TypeScript check: passed.
- Local and vendor lint: passed with no lint errors.
- Rebuilt `dist/index.html`: `3,999,636` bytes and still the only `dist/` file.

The artifact test's first invocation again stopped before product assertions because its internal child command expects a globally visible bare `pnpm`. Re-running it with the already-identified process-local Node 24/pnpm 11.8 shim reached the actual artifact assertions and passed. No global installation, package script, dependency, lockfile, or generated plugin-package workflow changed.

### Light/dark small-size inspection

The live `link#faviconLink` SVG data URI was rendered at `16px`, `32px`, and `64px` on both `#f4f5f7` and `#1f2329` samples. The comparison is stored in the ignored `Wiki/test-results/favicon-sizes-light-dark.png` file and was inspected directly.

The `64px` black-artwork bounds measured `[1, 13, 62, 53]`, and every size reported `0` dark edge pixels, so the enlarged wing tips remain inside the canvas. All three sizes retained corner alpha `184`; the translucent contrast layer therefore remains visible against dark browser chrome while allowing the surrounding tone to show through. The `16px` sample necessarily loses fine wing detail because the approved source is complex; further clarity would require a separately approved simplified small-size glyph rather than a more aggressive crop.

The running read-only preview remains available at `http://127.0.0.1:8080/?favicon=semi-transparent-enlarged#AngelscriptWikiHome`. The complete 70-case Playwright suite was not repeated for this isolated two-declaration SVG refinement. No internal icon tiddler, port `8081`, publication, deployment, OpenSpec archive, or standalone plugin package was changed.

## Screenshot-corrected transparent favicon crop — 2026-07-24

### User screenshot correction and RED evidence

Direct inspection of `Wiki/临时图片3.jpg` showed that the `72%` white rectangle still rendered as a conspicuous light-gray square in the real browser tab. It also showed that the approximately six-percent crop did not make the center mark sufficiently legible at favicon size. The semi-transparent canvas recorded in section 24 is therefore a rejected intermediate result, not the current design target.

Three contracts were changed before the final SVG edit:

- the source contract requires `viewBox="236 207 780 780"` and rejects every `<rect>` element;
- the offline artifact contract applies the same requirements to the serialized `$:/favicon.ico` tiddler;
- the focused real-browser contract requires the new view box, no rectangle, and corner RGBA `[0, 0, 0, 0]`.

The direct source run reported **8 passed / 1 expected failure** at the former `viewBox="118 89 1016 1016"`. The focused real-browser scenario reported **0 passed / 1 expected failure** at the same old declaration. These failures confirmed that the tests distinguished the approved screenshot correction from the rejected intermediate SVG.

### Final implementation

Only two SVG-level changes were made:

- the root view box is now `236 207 780 780`;
- the full-canvas white rectangle was removed completely.

The complete original path data, XML metadata, intrinsic dimensions, `$:/favicon.ico` title, `image/svg+xml` type, and native TiddlyWiki favicon startup lifecycle remain unchanged. The tighter favicon-specific view box intentionally clips a small amount of the outer wing tips so the central mark occupies more of the `16–20px` browser-tab canvas. No internal Wiki image/icon tiddler changed.

### GREEN, build, and visual evidence

Using Node `24.18.0` and pnpm `11.8.0`:

- Direct source contract: **9/9 passed**.
- Focused real-browser defaults/favicon scenario: **1/1 passed**.
- Source-boundary contracts: **16/16 passed**.
- Product-source contracts: **4/4 passed**.
- TypeScript check: passed.
- Local and vendor lint: passed with no lint errors.
- Integrated offline artifact test: **1/1 passed** and rebuilt the one-file Wiki.
- The live `$:/favicon.ico` tiddler reported `image/svg+xml`.
- The live `link#faviconLink` used an SVG data URI.
- Canvas corner RGBA was exactly `[0, 0, 0, 0]` at `16px`, `20px`, `32px`, and `64px`.

The first artifact invocation stopped during generated-source cleanup with Windows `EPERM` because the read-only port `8080` development process held `.generated/plugin-sources`. That process alone was stopped, the artifact test was rerun successfully, and port `8080` was restored. Port `8081` remained owned by its original process and was not restarted or modified.

The final live-data-URI inspection is stored in ignored test output:

- `Wiki/test-results/favicon-final-tab-transparent-crop.png`;
- `Wiki/test-results/favicon-final-metrics.json`.

The screenshot simulates the real light browser-tab geometry and also renders the live favicon at `16px`, `20px`, `32px`, and `64px` on light and dark surfaces. Inspection against `临时图片3.jpg` confirms that the square canvas is gone and the central mark is larger. The source is still a black line-art logo, so dark browser chrome has inherently lower contrast; adding a pale backing shape would recreate the rejected square, while a true light/dark adaptive favicon would require a separately approved artwork variant.

The running read-only preview is available at `http://127.0.0.1:8080/?favicon=transparent-medium-crop#AngelscriptWikiHome`. The complete 70-case Playwright suite was intentionally not repeated for this isolated favicon-only correction. Both repositories remain uncommitted for user review; nothing was pushed, published, deployed, archived, or packaged as a standalone plugin.

## Compact Tools row density and column alignment — 2026-07-24

### Root cause and RED evidence

The production Tools rows retained the core `tc-sidebar-tools-item` class and native PageControl button transclusions, but two unrelated inherited rules altered their real geometry:

- Vanilla applied `3px` block margins to every `.tc-sidebar-tools-item` and to the version paragraph under `.tc-sidebar-lists`;
- the Angelscript base theme applied `2px` margins to every native `button`.

The row stylesheet therefore declared `min-height: 29px` while the browser produced `31px` row boxes with an approximately `34px` pitch. The version paragraph's intended local margin also computed as `3px` on all sides. Independent `auto` action tracks then placed production description starts at multiple horizontal offsets according to each PageControl caption width.

The existing two product specs passed **24/24** before the new assertions. After adding computed-style and real-bounding-box coverage first, the run reported **23 passed / 1 expected failure**: the Tools version paragraph expected `margin-top: 1px` but received the inherited `3px`. The new main-tab idle/hover/focus checks passed during that same RED run, confirming that the reported grey Recent hover block is not reproducible from the current source and should be guarded rather than countered with another CSS override.

### Scoped implementation

Only `Wiki/src/angelscript-theme/compact-control-rail.tid` changed in the runtime:

- common and Other tool lists use a `2px` grid gap;
- Tools-panel-qualified row and action-button rules reset only their inherited margins;
- the version paragraph uses a panel-qualified `1px 2px 9px` margin;
- row tracks are `14px clamp(92px, 52%, 104px) minmax(0, 1fr)`;
- native action buttons retain intrinsic width capped by the shared action track.

The `tc-sidebar-tools-item` class, native visibility checkboxes, PageControl transclusions, descriptions, icon mapping, common ordering, Other discovery/collapse behavior, typography, colors, borders, and hover/focus presentation remain unchanged. No global button rule, main-tab stylesheet, mobile drawer, or selected 03 reference was modified.

### GREEN, build, and visual evidence

- Focused product browser files: **24/24 passed** after the development source snapshot was refreshed.
- Final focused-file rerun after formatting: **24/24 passed**. The attempted npm-forwarded `--grep` was ignored by the wrapper, so this final command conservatively reran both complete files instead of only two cases.
- TypeScript check: passed.
- Local and vendor lint: passed with no lint errors or formatting warnings.
- Source-boundary contracts: **16/16 passed**.
- Product-source contracts: **4/4 passed**.
- Integrated single-HTML build: passed and produced `Wiki/dist/index.html`.
- Offline artifact validation: **1/1 passed**.
- Strict OpenSpec validation: passed.
- Diff whitespace checks: passed; Git reported only existing line-ending notices.

The shell currently resolves Node `25.5.0`, so pnpm emitted the repository's expected engine warning (`>=24 <25`) during these commands. The checks themselves completed successfully; the existing process-local Node `24.18.0` binary remains available, and no engine declaration, dependency, package script, or lockfile changed in this refinement.

Six persistent review screenshots were generated under `Wiki/comparison-artifacts/review/sidebar-tools-refinement-20260724/`:

- `01-tools-default-full.png`;
- `02-tools-default-sidebar.png`;
- `03-tools-other-expanded-sidebar.png`;
- `04-tools-min-240-sidebar.png`;
- `05-tools-max-520-sidebar.png`;
- `06-recent-hover-sidebar.png`.

Direct inspection confirmed aligned description starts and no horizontal overflow at `240px`, `264px`, and `520px`; the expanded Other group uses the same geometry; and Recent hover remains transparent without a rectangular block. Port `8080` was restored after the build-source refresh. Port `8081` remained on its original PID and was never restarted or modified. The screenshots are review artifacts, not Wiki runtime inputs. Nothing was committed, pushed, published, deployed, archived, or packaged as a standalone plugin.

## Other-tools semantic icons and compact icon-label gap — 2026-07-24

### Root cause and RED evidence

The compact Tools layout already reserved the selected 03 reference's `5px` icon-to-label gap through the icon position and action-button padding, but TiddlyWiki's native `.tc-btn-text { margin-left: 7px; }` increased the measured production gap to `12px`. The centralized sidebar icon map also covered only the common controls, so all fourteen bundled controls discovered under “其他工具” used the same `generic-tool` fallback.

The source contract was extended first with the complete bundled mapping and product image-tiddler requirements. It reported **8 passed / 1 expected failure**, with `$:/core/ui/Buttons/palette` unresolved instead of mapping to `palette`. A live Chromium probe independently measured the old `12px` gap and found `generic-tool` on the palette row.

The first formal browser rerun exposed two legitimate core DOM variants in the gap assertion rather than a product rendering failure: `save-wiki` nests `.tc-btn-text` inside `.tc-dirty-indicator`, while `import` renders its primary label as a bare button text node alongside its file input button. The final assertion therefore measures the first visible text glyph in each native action instead of assuming one PageControl wrapper. The runtime selector remains tightly scoped to `.as-sidebar-panel-tools` and resets `.tc-btn-text` descendants only.

### Scoped implementation

- Added thirteen line-icon image tiddlers: `palette`, `lock`, `network`, `image`, `journal`, `link`, `print`, `refresh`, `save`, `storyview`, `theme`, `clock`, and `unfold`.
- Added explicit icon-map entries for the fourteen bundled Other controls; `$:/core/ui/Buttons/tag-manager` reuses the existing `tag` icon.
- Preserved `generic-tool` as the fallback for unknown or future PageControls, verified with the injected test control.
- Reset only Tools action-button `.tc-btn-text` left margins, leaving native toolbars elsewhere unchanged.
- Preserved native PageControl transclusions, checkboxes, captions, descriptions, ordering, state, the Other disclosure, responsive column tracks, and all TiddlyWiki behavior.

### GREEN, build, and visual evidence

Using the process-local Node `24.18.0` binary:

- Direct source contract: **9/9 passed**.
- Focused real-browser Tools scenario: **1/1 passed**.
- The browser verified all fourteen bundled semantic mappings, generic fallback for one injected future control, and a `5px` icon-right to first-visible-text gap for every common and Other row.
- The same scenario retained zero horizontal overflow at `240px`, `264px`, and `520px` total sidebar widths.
- TypeScript check: passed.
- Local and vendor lint: passed with no lint errors.
- Source-boundary contracts: **16/16 passed**.
- Product-source contracts: **4/4 passed**.
- Integrated single-HTML build and offline artifact validation: **1/1 passed**; `Wiki/dist/` contains only `index.html`, with no plugin library or standalone plugin JSON packages.

The artifact check's first invocation stopped before building because its internal Windows command expects a `pnpm` executable on `PATH`; this shell exposes pnpm only as a fixed `.cjs` entry. A process-local temporary command shim routed that invocation to the existing Node 24/pnpm installation, the unchanged artifact test then passed, and the temporary shim was deleted immediately. No project script, dependency, lockfile, global environment, or runtime source was changed for that infrastructure issue.

Final review images are stored under `Wiki/comparison-artifacts/review/sidebar-tools-refinement-20260724/`:

- `07-tools-5px-gap-sidebar.png` — default common Tools group;
- `09-other-tools-final-5px-icons-sidebar.png` — expanded Other group with the final semantic icons and corrected spacing.

Both screenshots were inspected directly. The save caption retains TiddlyWiki's native dirty-state color; this refinement changes only its icon and spacing. Port `8080` remains available for read-only review, port `8081` was not modified, and the comparison screenshots remain review artifacts rather than Wiki runtime inputs. Nothing was committed, pushed, published, deployed, archived, or packaged as a standalone plugin.

## Description-free Tools rows and hidden Palette default — 2026-07-24

### Root cause and approved behavior

The explanation after each Tools action was product-owned rather than required by TiddlyWiki. `$:/core/ui/SideBar/Tools` explicitly transcluded every PageControl's `description` field into `.as-tool-description`, and the theme reserved a third responsive grid track for that secondary text. The Palette checkbox was also intentionally on: `page-control-palette.tid` set the standard PageControl visibility tiddler to `show`.

The approved behavior removes that description node and its stylesheet rather than merely hiding it, changes each row to a checkbox track plus one flexible action track, and sets Palette's product default to `hide`. No startup module enforces that value. Palette remains in the dynamic Other group, and its native checkbox can still create a `show` user override.

### RED and implementation evidence

- Direct source contract after adding the new expectations: **8 passed / 1 expected failure**, at the existing `as-tool-description` node.
- Two focused real-browser scenarios after adding the runtime expectations: **0 passed / 2 expected failures**. The configuration scenario received Palette `show` instead of `hide`; the Tools scenario found sixteen rendered `.as-tool-description` elements instead of zero.
- Removed the description transclusion from `Wiki/src/angelscript-tools/navigation/sidebar-tools.tid`.
- Removed the description CSS and changed row tracks to `14px minmax(0, 1fr)` in `Wiki/src/angelscript-theme/compact-control-rail.tid`.
- Changed only the Palette visibility default from `show` to `hide` in `Wiki/src/angelscript-wiki-config/config/page-control-palette.tid`.

Native PageControl action transclusions, accessible names/hints, visibility checkboxes, semantic icons, `5px` icon-label spacing, `29px` row density, `2px` row gap, ordering, Other discovery, unknown-tool fallback, hover/focus behavior, and user configuration persistence remain intact.

### GREEN, build, and visual evidence

Using the process-local Node `24.18.0` binary:

- Direct source contract: **9/9 passed**.
- Focused browser scenarios: **2/2 passed** in one shared Playwright startup.
- The browser confirmed zero description elements; Palette present and initially unchecked; manually checking Palette writes `show`; and two-column rows remain free of horizontal overflow at `240px`, `264px`, and `520px`.
- TypeScript check: passed.
- Local and vendor lint: passed without errors or formatting warnings after the two new test expressions were normalized.
- Source-boundary contracts: **16/16 passed**.
- Product-source contracts: **4/4 passed**.
- Integrated single-HTML build and offline artifact validation: **1/1 passed**. The build consumed eight product plugin sources but produced only `Wiki/dist/index.html`, with no standalone plugin packages.

The live inspection returned `descriptionCount: 0`, `initialPaletteChecked: false`, and computed row columns `14px 168px` at the default captured width. Two ignored review screenshots were generated and inspected:

- `Wiki/comparison-artifacts/review/sidebar-tools-refinement-20260724/10-tools-without-descriptions-sidebar.png`;
- `Wiki/comparison-artifacts/review/sidebar-tools-refinement-20260724/11-other-tools-no-descriptions-palette-off-sidebar.png`.

The common and Other groups now read as compact action lists without a competing italic column, and Palette remains visibly discoverable but unchecked. The screenshots are not runtime inputs and are excluded from the requested Git commit. Port `8081`, unrelated files, publishing, deployment, OpenSpec archival, and standalone plugin packaging remain untouched. After visual acceptance, the user explicitly requested the reviewed source and OpenSpec changes be committed through the Wiki-submodule-first workflow; no push was requested.

## Quiet main-sidebar tab hover and 400/500 typography — 2026-07-24

### Root cause and approved behavior

The compact main-tab rule had the same effective cascade strength as the generic sidebar button-hover rule in `desktop-refinement.tid`. Depending on stylesheet ordering, hovering `最近` could therefore inherit a pale control fill and darker text that do not belong to the approved `03-compact-control-rail` index-like row.

The product now scopes only the horizontal main row through `.tc-sidebar-header .tc-sidebar-tabs-main`. Its unselected tabs keep the transparent `03` presentation and their baseline color at idle, hover, and keyboard focus, with an explicit `400` font weight. The selected `目录` tab retains its transparent accent presentation, two-pixel underline, and `500` weight. The existing `:focus-visible` outline remains intact. More's vertical categories, Tools rows, control-rail buttons, and tiddler toolbars are outside this selector and unchanged.

### RED, GREEN, and scoped validation

- RED: the new direct source contract failed exactly as intended because the existing main-tab baseline had no explicit `400` and used the weaker unscoped selector.
- GREEN: direct source contract **10/10 passed** after the scoped CSS and selected-hover guard were added.
- GREEN: the one focused Chromium scenario **1/1 passed**. It verified transparent idle/hover/focus backgrounds, unchanged unselected color, normal/selected `400`/`500` weights, visible `2px` focus outline, selected accent state, underline, and stable geometry.
- `git diff --check` passed for the Wiki production/test files.

Per the user's request to avoid excessive verification before recording the accepted refinement, the broader typecheck, lint, build/artifact, full Playwright, screenshot-capture, and strict OpenSpec validation suites were intentionally not rerun in this small follow-up. Port `8081`, unrelated tracked and untracked files, publishing, deployment, OpenSpec archival, and standalone plugin packaging remain untouched.
