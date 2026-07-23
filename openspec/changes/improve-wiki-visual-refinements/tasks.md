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
