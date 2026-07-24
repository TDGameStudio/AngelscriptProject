## 1. Record the reviewed experiment

- [x] 1.1 Record the `new_review.html` experiment, the accepted More direction, the excluded body-theme work, and the rollback boundary in proposal and design artifacts.
- [x] 1.2 Specify the adaptive More width, slider semantics, native-content preservation, and Page Actions icon contract.

## 2. Add failing product coverage <!-- TDD -->

- [x] 2.1 Add an `angelscript-theme.spec.ts` scenario proving that a 264px base sidebar expands only while More is active, aligns the resize handle and story boundary, exposes the contextual slider minimum, and restores the unchanged base width after leaving More.
- [x] 2.2 Add a slider-interaction scenario proving that More keyboard and pointer adjustment start from the actual effective width, persist only an explicit adjustment, and continue to obey the desktop maximum.
- [x] 2.3 Update `sidebar-expanded-panels.spec.ts` expectations for the approved More component: 84px category column, one divider, readable content area, all 11 native categories, normal long-link wrapping, native tag colours, grid plugin cards, and no horizontal overflow.
- [x] 2.4 Update compact-rail coverage to require the product-owned `more` icon and non-ambiguous home state while More is selected.
- [x] 2.5 Run the focused Playwright tests and confirm the new assertions fail against the current source for the expected pre-migration reasons.

## 3. Implement the shared layout model <!-- TDD -->

- [x] 3.1 Introduce the theme-level effective sidebar-width variable and route desktop sidebar, story river, resize-area, and static-template geometry through it.
- [x] 3.2 Refactor `left-sidebar-resizer.ts` so More activates a matching contextual minimum for pointer, keyboard, ARIA, and persistence, without a second stored width or changes to narrow drawer behavior.
- [x] 3.3 Replace the scattered More presentation rules with one component-scoped desktop treatment in `compact-control-rail.tid`; remove superseded More overrides from `desktop-refinement.tid`.
- [x] 3.4 Add the reusable overflow icon tiddler and map native Page Actions to it; scope the More-active home neutralization to the compact rail.
- [x] 3.5 Run the focused Playwright tests until all new and updated assertions pass.

## 4. Validate and close the migration

- [x] 4.1 Run `npm run check`, `npm run lint`, `npm run test:source-boundaries`, the affected Playwright suites, and `npm run build:wiki` from `Wiki/`.
- [x] 4.2 Inspect the desktop More default/system and plugin states plus a 390px mobile drawer state; check browser console output and page overflow without generating broad screenshot sets.
- [x] 4.3 Update this task list with actual verification results and summarize the remaining deferred body-theme experiment work.
