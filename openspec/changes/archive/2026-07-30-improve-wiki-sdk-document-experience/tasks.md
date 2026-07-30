## 1. Behavior Contracts

- [x] 1.1 Add Playwright assertions for desktop hit targets, hover, pressed, selected, focus, links, and title-action timing
- [x] 1.2 Add absence assertions for the removed cover/icon package and retention assertions for core icons and draw.io <!-- TDD -->
- [x] 1.3 Add widget and Playwright assertions for `maxVisibleLines`, complete-range copying, wheel scrolling, globally consistent scrollbar geometry, and icon-only localized copy feedback <!-- TDD -->
- [x] 1.4 Add Playwright assertions for the localized core sidebar, friendly identity, stable title/description hierarchy, readable width, TOC absence, command-palette idle/help modes, and home links
- [x] 1.5 Add failing Playwright assertions for bounded 31vw desktop sidebar geometry and compact content-sized core tabs <!-- TDD -->
- [x] 1.6 Add failing Playwright assertions for canonical toolbar visibility, natural button geometry, and the untagged control's default/hover colors <!-- TDD -->
- [x] 1.7 Add a failing Playwright reproduction for the resize rail shrinking after Tools scrolling and for the coarse 10px hover fill <!-- TDD -->
- [x] 1.8 Add failing Playwright assertions for the user-selected four-control toolbar and the restored non-default AS documentation outline <!-- TDD -->

## 2. Theme and External Plugin Boundary

- [x] 2.1 Fix desktop breakpoint expansion and implement shared light interaction tokens
- [x] 2.2 Refine links, tabs, title toolbar timing, readable prose width, and wide technical surfaces
- [x] 2.3 Remove only the `notionpage-covericon` manifest entry and imported package while preserving sibling TiddlySeq plugins <!-- Non-TDD -->
- [x] 2.4 Remove cover/icon bridge, offline, browser, theme, and author-documentation references <!-- TDD -->
- [x] 2.5 Normalize the optional SDK description typography and spacing without changing the accepted palette <!-- TDD -->
- [x] 2.6 Restore `clamp(320px, 31vw, 600px)` sidebar width and reference-density tab/list spacing without changing colors or plugin inventory <!-- TDD -->
- [x] 2.7 Restore natural `.tc-page-controls` geometry and harmonize only the More-sidebar untagged action <!-- TDD -->
- [x] 2.8 Pin the desktop sidebar resize hit area to the viewport and render a separate one/two-pixel interaction rail in editable vendor source <!-- TDD -->

## 3. SDK Document Experience

- [x] 3.1 Restore the core Open / Recent / Tools / More sidebar and remove the custom documentation default tab
- [x] 3.2 Add friendly title/breadcrumb presentation and metadata to canonical SDK pages
- [x] 3.3 Remove the in-page contents card, TOC startup module, and dedicated TOC styles
- [x] 3.4 Change command-palette idle routing and localized navigation presentation
- [x] 3.5 Fix known stale home-page links and implement icon-only code-copy results backed by active-language accessible labels
- [x] 3.6 Implement clamped `maxVisibleLines` viewport behavior without changing source slicing, line numbering, highlighting, or copying <!-- TDD -->
- [x] 3.7 Expand and document the Focused source range example as a long internally scrollable code card <!-- TDD -->
- [x] 3.8 Replace ineffective short PageControlButtons config titles with canonical visibility tiddlers and the approved SDK control set <!-- TDD -->
- [x] 3.9 Persist the user-selected Home / More / control-panel / language toolbar and restore the trailing AS outline without restoring an in-page TOC <!-- TDD -->

## 4. Editable Vendor Source and Lint Boundary

- [x] 4.1 Add source-boundary tests proving imported repositories live outside local `src` and complete lint composes local and vendor scopes <!-- TDD -->
- [x] 4.2 Move the four tracked imported repositories to `vendor/` and update manifest, watcher/build paths, Git attributes, ignore rules, and documentation
- [x] 4.3 Keep enabled vendor TypeScript in `check` and preserve manifest-driven hot reload and offline builds
- [x] 4.4 Replace the unbounded type-aware bundle scan with a bounded vendor correctness audit that excludes prebuilt/minified artifacts

## 5. Verification

- [x] 5.1 Run focused tests in red/green order and run Wiki typecheck, local lint, vendor lint, composed lint, build, source-boundary, external-plugin, offline-publish, and full Playwright coverage
- [x] 5.2 Capture and inspect desktop screenshots for the restored core sidebar, static pages, title/description hierarchy, normal/hover/pressed/selected/focus states, command palette, and the code viewport before and after scrolling
- [x] 5.3 Inspect generated artifacts and final diffs without staging unrelated files
- [x] 5.4 Capture 2048px reference-comparison and 1280px safety screenshots, then rerun focused and full regression coverage
- [x] 5.5 Capture toolbar and More/Tags default/hover screenshots and rerun complete verification
- [x] 5.6 Capture the resize rail after Tools scrolling in rest, hover, and drag states; rerun focused and complete verification
- [x] 5.7 Capture and inspect the persisted four-control toolbar and AS outline, then rerun focused and complete Wiki verification
