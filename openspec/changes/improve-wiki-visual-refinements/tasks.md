## 1. Baseline and regression coverage

- [x] 1.1 <!-- TDD --> Run the existing focused Angelscript theme Playwright suite from `Wiki/` with `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts` and record any pre-existing failure before changing source.
- [x] 1.2 <!-- TDD --> Update `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`: change the existing resize assertion to `expect(initial.railOpacity).toBe(0)`; add a More-sidebar case that opens main tab index `3` and asserts every `.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button` has `borderRightWidth === '0px'`; add an `/#AngelscriptWikiHome` case that asserts the element sequence is title, `.as-sdk-description`, `.tc-tags-wrapper`, `.tc-tiddler-body`, that `descriptionToTag <= 12`, and that `tagToBody > descriptionToTag`.
- [x] 1.3 <!-- TDD --> Run the focused theme spec with `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts` and confirm the three new/updated assertions fail for the intended baseline behavior rather than due to a fixture or selector error. The npm wrapper does not forward `--grep` to Playwright correctly, so the full nine-test spec is the reliable focused command.

## 2. Scoped theme corrections

- [x] 2.1 <!-- Non-TDD --> Modify `Wiki/vendor/tiddlyseq/src/sidebar-resizer/style.css` so the fixed full-height resize hit target retains its geometry but the `::before` rail has `opacity: 0` at rest, `opacity: 0.42` on hover, and the existing stronger `2px` / `0.68` active-drag state.
- [x] 2.2 <!-- Non-TDD --> Modify `Wiki/src/angelscript-theme/desktop-refinement.tid` with `.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button { border-right: none; }`, retaining all existing selected, hover, and focus rules.
- [x] 2.3 <!-- Non-TDD --> Modify the same local theme refinement with an `as-sdk-title`-scoped spacing override: set `.as-sdk-description` to `margin: 0.35rem 0 0.5rem` and the following `.tc-tags-wrapper` to `margin-top: 0`, preserving title/description/tag/body order and the inherited lower tag margin before body content.
- [x] 2.4 <!-- TDD --> Re-run the focused theme spec after each source change with `npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts` and adjust only the affected scoped values until all assertions pass. The npm wrapper does not forward `--grep` to Playwright correctly, so this nine-test spec is the reliable focused command.

## 3. Visual and project verification

- [x] 3.1 <!-- Non-TDD --> Inspect local desktop Wiki rendering for the idle/hover/drag resize states, the More sidebar, and `AngelscriptWikiHome`; compare the SDK header rhythm against `Wiki/临时参考4.jpg` without changing the reference assets.
- [x] 3.2 <!-- Non-TDD --> Run `npm exec --yes pnpm@11.8.0 -- run check`, `npm exec --yes pnpm@11.8.0 -- run lint`, and `npm exec --yes pnpm@11.8.0 -- run test:playwright` from `Wiki/`.
- [x] 3.3 <!-- Non-TDD --> Run `npm exec --yes pnpm@11.8.0 -- run build` from `Wiki/`, run `openspec validate improve-wiki-visual-refinements --strict` from the host root, inspect exact Wiki and host diffs, and mark the completed checklist items.

## 4. More-sidebar divider geometry correction

- [x] 4.1 <!-- TDD --> Diagnose the current More-sidebar presentation in the running Wiki and confirm that `.tc-tab-content.tc-vertical.tc-sidebar-tabs-more` begins before the category column ends, so its inherited `1px` `border-left` overlays the “全部 / 最近 / 标签” controls.
- [x] 4.2 <!-- TDD --> Extend the focused More-sidebar Playwright case to assert that category buttons have no right border, the vertical More content panel has one `1px` left divider, and its left edge is at least `4px` to the right of the category-column bounds. Confirm the intermediate no-divider stylesheet fails this assertion.
- [x] 4.3 <!-- TDD --> Give only that More content panel a `0.5rem` left margin while retaining its `1px` left divider; rerun the focused theme suite to 9/9 passing and re-check browser geometry (a 5px gap from the rightmost category button at 1440px) plus the updated screenshot.

## 5. Left-sidebar experiment contract

- [x] 5.1 <!-- Non-TDD --> Capture and inspect the current 1440×1000 production Wiki layout, trace the left-sidebar, topbar toggle, resize hit target, story river, palette, and inherited right-sidebar breakpoint rules, and record the production-theme stop boundary.
- [x] 5.2 <!-- TDD --> Add `Wiki/tests/playwright/product/sidebar-experiment-previews.spec.ts` covering three standalone files, identical representative content, no remote dependencies, desktop alignment, pointer and keyboard resizing, open/close recovery, narrow drawer behavior, reduced motion, and the three distinct non-sudden resize affordances.
- [x] 5.3 <!-- TDD --> Run `npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/sidebar-experiment-previews.spec.ts` before implementation and confirm all nine cases fail specifically because the three preview files do not exist.

## 6. Conservative standalone previews

- [x] 6.1 <!-- Non-TDD --> Add `01-quiet-seam.html` with the current white sidebar and tiddler surface, a permanent neutral seam that only strengthens on hover/drag, and a title-row collapse control.
- [x] 6.2 <!-- Non-TDD --> Add `02-soft-surface.html` with a restrained neutral sidebar surface, unchanged tiddler canvas, a persistent short resize grip, and a quiet grouped utility row.
- [x] 6.3 <!-- Non-TDD --> Add `03-compact-control-rail.html` with a `264px` initial width, a persistent `40px` control rail, an unchanged tiddler canvas, and a stable reopen surface after collapse.
- [x] 6.4 <!-- TDD --> Implement the shared inline interaction contract in each independent file: pointer capture, `240px` to `min(520px, 40vw)` bounds, keyboard adjustment, ARIA state, visible focus, reduced-motion handling, and a narrow left drawer; rerun the focused suite to 9/9 passing.
- [x] 6.5 <!-- Non-TDD --> Inspect 1440×1000 idle, hover, and closed screenshots for all three variants plus a 390×844 drawer screenshot, retaining the implementation only after confirming the current palette, typography, tiddler card, and content structure remain visually stable.

## 7. Preferred compact-rail interaction contract

- [x] 7.1 <!-- TDD --> Extend the preview Playwright suite for five main tabs, pointer and keyboard selection, one visible associated panel, stable main-tiddler content, five styled open tiddlers with working close/count behavior, grouped Recent entries, Tools and More content, collapsible AS groups, and complete control-rail zones and tooltips; confirm the new cases fail against the first 03 preview.
- [x] 7.2 <!-- Non-TDD --> Replace the compact preview's static sidebar body with semantic tab panels that curate the current production Wiki's real Open, Tools, More, and AS information architecture, add five representative open items with current/close/count states, and add representative grouped Recent data.
- [x] 7.3 <!-- Non-TDD --> Refine the `40px` control rail into top toggle, primary actions, separators, and bottom utilities with accessible right-side tooltips plus distinct selected, hover, pressed, focus, and collapsed states.
- [x] 7.4 <!-- TDD --> Implement tab roving focus, panel selection, More-category selection, and AS group collapse/selection in the standalone inline script; rerun the focused suite to green.
- [x] 7.5 <!-- Non-TDD --> Reopen the refined 03 preview and inspect every main panel, rail hover/focus, open/closed desktop state, and mobile drawer without changing production theme source.
- [x] 7.6 <!-- TDD --> Replace the redesigned Tools cards/switches and wrapping More chips with browser-covered, visually refined versions of the original Tools checkbox/button/description rows and More vertical category/divider/content geometry.
- [x] 7.7 <!-- TDD --> Add the original four-action tiddler view toolbar plus distinct page-level and tiddler-level More menu examples; cover menu content, open/close state, Escape focus restoration, and viewport containment.
- [x] 7.8 <!-- Non-TDD --> Refine the Open panel's close-all control into a quiet integrated batch-action row with live item detail, restrained destructive hover/focus treatment, and a correct empty state.

## 8. Record, verification, and review checkpoint

- [x] 8.1 <!-- Non-TDD --> Update this OpenSpec's proposal, design, delta specs, and task record to describe the accepted left-sidebar context, three preview alternatives, selected compact-rail refinement, production-theme stop boundary, and no-plugin-package constraint.
- [x] 8.2 <!-- TDD --> Run the focused preview suite, type check, lint, source-boundary tests, full product Playwright suite, integrated offline Wiki build, strict OpenSpec validation, and exact diff checks; record fresh results in `verification.md`.
- [x] 8.3 <!-- Non-TDD --> Commit the three preview files and test in the Wiki submodule, then commit only the formal OpenSpec files and updated Wiki gitlink in the host repository; do not push, archive the OpenSpec, publish packages, or modify production Wiki theme source.

## 9. Selected production contract and RED coverage

- [x] 9.1 <!-- Non-TDD --> Record `03-compact-control-rail` as the direct production default, native TW/plugin icon tiddlers as the icon source, `264px` as the default total desktop width, `40px` as the persistent rail/collapsed width, the unchanged mobile drawer/bottom-controls fallback, and the no-package/no-publish boundary in the formal proposal, design, and delta specs.
- [x] 9.2 <!-- TDD --> Extend `Wiki/tests/playwright/product/angelscript-theme.spec.ts` and `Wiki/tests/playwright/product/document-experience.spec.ts` with production assertions for the seven native rail controls/icons, `40px`/`264px` geometry, persistent collapsed rail, native panel/menu structure, quiet idle resize seam, keyboard separator bounds/ARIA, reduced motion, and the narrow-layout fallback.
- [x] 9.3 <!-- TDD --> Run `npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/angelscript-theme.spec.ts tests/playwright/product/document-experience.spec.ts` from `Wiki/` and confirm the new assertions fail because the production control rail and keyboard separator behavior are not implemented.

## 10. Native PageTemplate rail and stable defaults

- [x] 10.1 <!-- Non-TDD --> Add `Wiki/src/angelscript-tools/navigation/compact-control-rail.tid` as a theme-guarded `$:/tags/PageTemplate` extension before the core sidebar; transclude native Home, More, New Tiddler, Command Palette, Palette, Control Panel, and Language buttons in top/primary/utility zones without copying preview menus, SVG paths, or Unicode glyphs.
- [x] 10.2 <!-- Non-TDD --> Update `Wiki/src/angelscript-wiki-config/config/` so the default total sidebar width is `264px`, the duplicate desktop sidebar PageControls segment is hidden, the seven rail actions are visible by default, and `$:/tags/PageControls` retains a deterministic compatible order.
- [x] 10.3 <!-- Non-TDD --> Add `Wiki/src/angelscript-theme/compact-control-rail.tid` for the selected `40px` neutral rail, native `17px` icons, zones, separators, tooltips, interaction states, native sidebar panels, page/tiddler menus, and reduced-motion rules while preserving the Notion-light document and system typography.

## 11. Layout and accessible resizer

- [x] 11.1 <!-- TDD --> Modify `Wiki/src/angelscript-theme/left-sidebar-layout.tid` so desktop sidebar content begins after the rail, the story uses the total width, the collapsed story retains `40px`, the top-left toggle is persistently visible, the resizer uses a quiet idle seam, and the existing mobile drawer remains rail-free.
- [x] 11.2 <!-- TDD --> Modify `Wiki/src/angelscript-tools/navigation/left-sidebar-resize-area.tid` and `left-sidebar-resizer.ts` to expose a focusable vertical separator, update ARIA values, support `8px` arrow adjustments plus Home/End bounds, and preserve the existing pointer persistence/cleanup behavior.
- [x] 11.3 <!-- TDD --> Re-run the focused two-spec Playwright command until the selected production contract passes, then run the existing standalone preview spec to ensure the visual reference remains unchanged.

## 12. Workflow guidance and integrated verification

- [x] 12.1 <!-- Non-TDD --> Update `Wiki/Agents_ZH.md` first and `Wiki/Agents.md` in sync so TW5 research prefers Knot's `tw5` knowledge base, verifies exact behavior against the locked local TiddlyWiki `5.4.1` source, and falls back to official TiddlyWiki documentation.
- [x] 12.2 <!-- Non-TDD --> Inspect real `1440×1000` Open, Tools, More/Tags, AS, page-More, tiddler-toolbar/More, closed, and resize states plus the `390×844` drawer; compare against `03-compact-control-rail.html` while preserving native data and icon sources.
- [x] 12.3 <!-- TDD --> Run `check`, `lint`, `test:source-boundaries`, `test:product-sources`, full `test:playwright`, `build:wiki`, `test:artifact`, strict OpenSpec validation, and exact Wiki/host diff checks; record fresh evidence in `verification.md`.

## 13. Dual-repository commit checkpoint

- [x] 13.1 <!-- Non-TDD --> Commit only the intended production rail/theme/config/tests/guidance files in the Wiki submodule with `[Wiki] Feat: migrate compact control rail to product sidebar`.
- [x] 13.2 <!-- Non-TDD --> Commit only the formal OpenSpec files and updated Wiki gitlink in the host repository with `[Wiki] Docs: record compact control rail production migration`; do not stage the untracked backup preview, push, publish, deploy, archive, or generate standalone plugin packages.

## 14. Compact rail fidelity follow-up

- [x] 14.1 <!-- TDD --> Add failing product assertions for the six-control rail, Language-above-Control-Panel utility order, absent Palette rail control, dynamic Home state, native More selected state, native Control Panel navigation, contained Language popup, and the five-tab preview geometry.
- [x] 14.2 <!-- TDD --> Refine the production rail and sidebar-tab CSS so Home follows the focused tiddler, selected rail buttons match the preview, the five tabs use a non-layout-shifting pseudo-element underline, Language opens upward within the viewport, and Control Panel remains native.
- [x] 14.3 <!-- Non-TDD --> Remove Palette only from the compact rail, keep palette selection available through the native Control Panel, and order the remaining bottom utilities as Language above Control Panel.
- [x] 14.4 <!-- Non-TDD --> Inspect real `1440×960` Home, page-More, Language, and Control Panel states against `03-compact-control-rail.html` while leaving port `8081` untouched.
- [x] 14.5 <!-- TDD --> Run focused Playwright, type checking, local lint, source/product-boundary tests, full product Playwright, integrated Wiki build, artifact validation, strict OpenSpec validation, and exact Wiki/host diff checks; do not commit, push, publish, package plugins, deploy, or archive.

## 15. TW-native expanded-panel fidelity

- [x] 15.1 <!-- TDD --> Add source contracts and failing Playwright scenarios for a product-scoped line-icon map, live Open/Recent data, sixteen ordered common Tools controls plus dynamic “其他工具”, the native eleven-category More structure, and two state-driven AS groups; confirm the first run fails on the missing production structures rather than fixture errors.
- [x] 15.2 <!-- TDD --> Add the scoped icon tiddlers and JSON action map, keep the six native PageControl buttons as the behavior layer, and cover their actual popup/navigation behavior plus computed `fill: none` line-icon rendering.
- [x] 15.3 <!-- TDD --> Shadow only the Open, Recent, Tools, and More/Tags presentation tiddlers and refine the existing AS navigation WikiText; preserve StoryList drag/close messages, real HistoryList order, PageControl visibility/config and extension discovery, TagTemplate/UntaggedTemplate, and native state/history semantics.
- [x] 15.4 <!-- TDD --> Apply the 03 row, count, current, grouping, divider, close-all, Other-tools, and collapsible-navigation styling; compare real `1440×960` Open, Recent, Tools, More/Tags, and AS panels against the standalone reference and correct global SVG/link-style collisions.
- [x] 15.5 <!-- TDD --> Run focused and full source/browser checks, the integrated offline Wiki build and artifact test, strict OpenSpec validation, HTTP preview check, and exact Wiki/host diff checks; keep the change unarchived, leave port `8081` untouched, and do not generate or publish standalone plugin packages.

## 16. Selected-reference typography and icon cleanup

- [x] 16.1 <!-- TDD --> Update `Wiki/tests/playwright/product/sidebar-experiment-previews.spec.ts`, `sidebar-expanded-panels.spec.ts`, and `angelscript-theme.spec.ts` first so they require only `03-compact-control-rail.html`, exact 03 Tools/More computed typography, no Open-row or close-all document glyphs, and one product single-chevron overlay on the native desktop sidebar toggle; run the focused specs and confirm the new expectations fail for the current three-preview, inherited-font, and double-chevron implementation.
- [x] 16.2 <!-- TDD --> Delete tracked `Wiki/comparison-artifacts/left-sidebar/01-quiet-seam.html`, tracked `02-soft-surface.html`, and the untracked `03-compact-control-rail - 备份.html`; refactor the preview suite's variant matrix and descriptions to the single selected 03 reference while retaining its desktop resize, narrow drawer, panel, toolbar/menu, reduced-motion, and offline contracts.
- [x] 16.3 <!-- TDD --> Modify `Wiki/src/angelscript-theme/compact-control-rail.tid` with panel-scoped 03 typography: Tools `11px / 400` actions, `10px / 400` compact descriptions, `29px` rows; More `10px / 400` production categories after active-font review, `600` selected/category heading weight, and `10px / 400` tags.
- [x] 16.4 <!-- TDD --> Add `Wiki/src/angelscript-tools/icons/sidebar/sidebar-toggle.tid`, layer it from `compact-control-rail.tid` above the native desktop show/hide button, hide only the native desktop double-chevron SVG, reverse the product glyph for the closed state, and remove the leading document/close-all icon transclusions plus their grid columns from `sidebar-open.tid` and the compact theme.
- [x] 16.5 <!-- TDD --> Re-run the three focused specs, inspect real and 03 `1440×960` Tools, More/Tags, Open, open-toggle, and closed-toggle screenshots, then run `check`, `lint:all`, source/product boundary tests, full Playwright, integrated Wiki build/artifact validation, strict OpenSpec validation, HTTP preview, and exact diff checks; do not touch port `8081`, publish, deploy, archive, or package standalone plugins.

## 17. Command Palette glyph simplification

- [x] 17.1 <!-- TDD --> Extend `Wiki/scripts/core-contract.test.mjs` to read `Wiki/src/angelscript-tools/icons/sidebar/command.tid` and require the existing parameterized Image-tiddler, `24×24` view box, `data-as-icon="command"`, no fill, current-color stroke, exactly two paths, a right-facing chevron path, and a separate baseline path; run `node --test scripts/core-contract.test.mjs` from `Wiki/` and confirm the new contract fails against the dense one-path loop glyph.
- [x] 17.2 <!-- TDD --> Replace only the SVG body in `Wiki/src/angelscript-tools/icons/sidebar/command.tid` with the approved unframed `>_` paths while retaining its title, `$:/tags/Image`, `\parameters`, size binding, class, data attribute, accessibility attributes, and native Command Palette mapping/behavior.
- [x] 17.3 <!-- TDD --> Run the source contract and focused `Wiki/tests/playwright/product/angelscript-theme.spec.ts` rail scenario, inspect the real `1440×960` rail and Tools row at `17px`, then run `check`, `lint:all`, source/product boundary tests, full Playwright, integrated Wiki build/artifact validation, strict OpenSpec validation, HTTP preview, and exact diff checks; leave the 03 reference, port `8081`, Git history, publishing, deployment, archive state, and standalone plugin packaging unchanged.

## 18. Preview-only compact tag popup

- [x] 18.1 <!-- TDD --> Extend `Wiki/tests/playwright/product/sidebar-experiment-previews.spec.ts` with a selected-03 scenario that requires a semantic `ASWiki/Home` tag toggle and associated hidden popup; after activation require `aria-expanded="true"`, a `260px`/`6px`/white/menu-shadow surface, native-shape tag-link/divider/tagged-list order, `11px` type, `29px` tagged rows, a current row with a `2px` accent edge and pale-blue background, no document SVG, outside-click close, `Escape` close with focus restoration, mutual exclusion with page/tiddler action menus, and containment at `390px`; run the focused spec and confirm failure because 03 currently renders a static tag span with no popup.
- [x] 18.2 <!-- TDD --> Modify only `Wiki/comparison-artifacts/left-sidebar/03-compact-control-rail.html`: replace the static tag span with a button/anchored popup using `data-tag-toggle` and `data-tag-popup`, add the approved tag-target/divider/representative tagged-tiddler markup and compact styles, then extend the inline script with idempotent open/close/toggle helpers integrated into document click, `Escape`, and existing action-menu mutual exclusion without changing formal TiddlyWiki source.
- [x] 18.3 <!-- TDD --> Re-run the focused selected-preview spec, inspect desktop `1440×960` closed/open/hover/focus and `390×844` contained-popup screenshots, run `check`, `lint:all`, source/product boundary tests, full Playwright, strict OpenSpec validation, HTTP/file preview, and exact diff checks; open the standalone 03 file for user review, leave production TW and port `8081` untouched, and do not commit, push, build/package plugins, publish, deploy, or archive.

## 19. Preview-only More/Tags body-style popup

- [x] 19.1 <!-- TDD --> Replace the rejected inline-directory scenario in `Wiki/tests/playwright/product/sidebar-experiment-previews.spec.ts` with a selected-03 contract requiring seven semantic sidebar tag buttons, one shared hidden popup outside the sidebar, exact computed-style parity with the body `.tag-popup`, target/divider/list order, representative/current rows, retarget/toggle/focus/mutual-exclusion behavior, desktop outside-sidebar placement, and `390px` containment; run `npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/sidebar-experiment-previews.spec.ts` from `Wiki/` and confirm failure because the current mistaken implementation is an inline disclosure directory.
- [x] 19.2 <!-- TDD --> Modify only `Wiki/comparison-artifacts/left-sidebar/03-compact-control-rail.html`: remove the inline disclosure CSS/renderer, restore compact tag controls, add one page-level More-tag popup that reuses the body popup classes, populate it from structured representative tag data, and add only the fixed-position/clamping and shared open/close/focus integration needed to avoid sidebar clipping while retaining the other ten More categories.
- [x] 19.3 <!-- TDD --> Re-run the focused preview suite to green, inspect desktop and `390px` popup states, then run TypeScript, `lint:all`, source/product boundary tests, full Playwright, strict OpenSpec validation, and exact diff checks; reopen the standalone 03 file for user review, leave production TW and port `8081` untouched, and do not commit, push, build/package plugins, publish, deploy, or archive.

## 20. Production CSS-only real-tag popup

- [x] 20.1 <!-- TDD --> Extend the Wiki source contract and production Playwright coverage first: require one theme-owned stylesheet scoped through `span.tc-tag-list-item[data-tag-title]`, no TagTemplate shadow/startup positioner/global dropdown reset, the approved `260px`/`6px`/white/border/shadow/`11px` surface and `29px` target/tagged rows, body and More/Tags computed-style parity, native outside-click close and absolute positioning, and unchanged Untagged/ordinary dropdown presentation; run the focused commands and confirm failure because the production stylesheet does not exist.
- [x] 20.2 <!-- TDD --> Add `Wiki/src/angelscript-theme/tag-popup.tid` with only the scoped surface, target/divider/tagged-row, hover, and focus rules; retain `$:/core/ui/TagTemplate`, `$:/tags/TagDropdown`, `.tc-tagged-draggable-list`, popup state, Reveal geometry, navigation, and drag/drop unchanged, and do not add a synthetic current-row state.
- [x] 20.3 <!-- TDD --> Re-run the source and focused production suites to green, inspect real body and More/Tags popups at `1440×960` plus the native drawer at `390×844`, then run `check`, `lint:all`, source/product boundary tests, full Playwright, integrated Wiki build/artifact validation, strict OpenSpec validation, HTTP preview, and exact Wiki/host diff checks; record evidence in `verification.md`, keep the OpenSpec unarchived, and do not commit, push, publish, deploy, or package standalone plugins.

## 21. Production sidebar tag-popup overflow correction

- [x] 21.1 <!-- TDD --> Update the source contract and production Playwright scenarios before implementation: lock the verified total-width arithmetic, require zero closed-state overflow after resetting the `100%` tag-manager heading's native inline margin, and require one browser startup adapter that moves only an already-open real-tag or Untagged Reveal triggered below `.tc-sidebar-scrollable`, never clones content or writes popup state, keeps body/macro/TagManager reveals native, prevents inner/outer overflow across representative `240–520px` widths, preserves native `aria-expanded`/outside-click/switch/cleanup behavior, and clamps desktop plus `390×844` geometry; run the focused source/browser commands and record the expected RED failures.
- [x] 21.2 <!-- TDD --> Reset only the More tag-manager heading button margin, add a typed sidebar-only popup portal startup module and metadata, extend the theme stylesheet with explicit body/portal real-tag and sidebar Untagged variants, move the connected Reveal node to `document.body` after core handles the trigger, position it `8px` beyond the desktop sidebar or below/above the narrow trigger within a `16px` inset, and retain all TiddlyWiki state, filtering, navigation, drag/drop, link, and disposal ownership.
- [x] 21.3 <!-- TDD --> Re-run the focused source/browser suites to green; capture and inspect body-tag, desktop More-tag, desktop Untagged, and narrow More-tag screenshots plus measured geometry/overflow evidence; then run scoped lint/type/source/product/browser/build/artifact/OpenSpec validation, update `verification.md`, keep this change unarchived, and do not commit, push, publish, deploy, or package plugins.
