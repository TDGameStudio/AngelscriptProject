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

## 5. Unify tag colour variants and Explore rows <!-- TDD -->

- [x] 5.1 Replace the legacy native-fill product assertion with failing coverage for the 4px neutral tag baseline and an actual tag tiddler `color` field producing a quiet body/More variant.
- [x] 5.2 Add a failing More Explore assertion for compact file rows, same-line icon/name layout, and no horizontal tree overflow.
- [x] 5.3 Implement a scoped tag component and a product-owned startup synchronizer that only derives variants from valid `color` fields; remove superseded untagged-label overrides without changing popup ownership.
- [x] 5.4 Implement scoped native Explore directory-row styling without modifying reveal state, tree data or More categories.
- [x] 5.5 Run focused and full affected product tests, static validation, build, and direct desktop/mobile inspection; record results and the remaining deferred body-theme scope.

## 6. Extend the tag component to native TagManager <!-- TDD -->

- [x] 6.1 Add a failing `$:/TagManager` assertion proving that a real tag `color` field receives the same geometry and restrained colour variant without changing its native popup.
- [x] 6.2 Extend only the scoped component and synchronizer selectors to the TagManager table; retain native table, editing and popup behavior.
- [x] 6.3 Rebuild the offline Wiki, reopen the inspected artifact, and rerun static and full product validation.
