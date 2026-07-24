## Verification results

The formal migration was verified on 2026-07-24 after the source change.

| Command / review | Result |
| --- | --- |
| Focused More Playwright red phase | Four new expectations failed on the unmodified source: 264px More boundary, 240px slider minimum, `chevron-down`, and 42px category column. |
| Focused More Playwright green phase | 4/4 passed after the shared-width, slider, component-style and icon changes. |
| Related sidebar Playwright suites | 27/27 passed in `angelscript-theme.spec.ts` and `sidebar-expanded-panels.spec.ts`. |
| Full product Playwright suite | 73/73 passed via `npm run test:playwright`. |
| TypeScript | `npm run check` passed. |
| Lint | `npm run lint` passed with no warnings. |
| Source boundaries | `npm run test:source-boundaries` passed: 22/22. |
| Plugin source test | `npm run test` passed: 1 Jasmine spec, 0 failures. |
| Offline Wiki build | `npm run build:wiki` compiled the Angelscript theme and TDGameStudio tools plugins. |
| Built-Wiki interaction | More default and plugin interaction produced no browser console or page errors. |
| Manual visual review | Reviewed only two states: desktop More default long list and 390px More Tags drawer. The desktop uses the effective 460px boundary and the mobile drawer remains unchanged. |

## Deferred experiment work

The following accepted `new_review.html` experiment rules are intentionally not in this migration: the quieter document card, document typography/vertical rhythm, and low-contrast persistent tiddler titlebar toolbar. They require a separate document-wide review because they affect every tiddler, not only More and its supporting layout surfaces. The shared body/More tag component is now formally migrated; it is the only body-surface rule included in this change.

## Tag and Explore finishing pass — 2026-07-25

| Command / review | Result |
| --- | --- |
| Tag TDD red phase | The new product assertion failed on the unmodified formal Wiki because no label exposed `data-as-tag-color-variant`; this confirmed that the preview-only behavior was not already present in source. |
| Tag TDD green phase | The targeted `uses one square tag component...` Playwright scenario passed after introducing the scoped component and synchronizer. It sets a real `ASWiki/Workflow!!color` field and verifies the body/More 4px geometry, neutral fallback, subdued colour surface, and 2px accent. |
| Explore TDD green phase | The More component scenario passed with a native Explore file row rendered as a compact flex row, a 24px link target, and no horizontal tree overflow. |
| Related product suites | `npx playwright test tests/playwright/product/angelscript-theme.spec.ts tests/playwright/product/sidebar-expanded-panels.spec.ts` passed: **27/27**. This includes adaptive-width/slider, body and More tag popups, narrow drawer, plugins, and directory-group regressions. |
| TypeScript / lint | `npm run check` and `npm run lint` passed. |
| Source contracts | `npm run test:source-boundaries` passed: **23/23**, including a new contract that rejects hard-coded `ASWiki/*` demonstration colours and tag-tiddler mutation. |
| Product source bridge | `npm run test:product-sources` passed: **4/4**. |
| Offline Wiki build | `npm run build:wiki` passed and compiled `$:/themes/angelscript` plus `$:/plugins/TDGameStudio/angelscript-tools`, including the new startup tiddler. |
| Direct desktop review | Reviewed 1440px More Tags with one real configured colour and several unconfigured tags, then More Explore after its native tree had rendered. The colour is restrained rather than a saturated fill; neutral tags remain coherent; Explore icons, names and counts align in one compact directory rhythm. Temporary capture artifacts were removed after review. |

## Native TagManager parity pass — 2026-07-25

| Command / review | Result |
| --- | --- |
| TagManager TDD red phase | The `$:/TagManager` test initially failed because its native table labels were outside the synchronizer selector and therefore had no colour-variant marker. |
| TagManager green phase | The same test passed after extending only the shared tag component and synchronizer selectors to `.tc-tag-manager-table`; it verifies a real `ASWiki/Workflow!!color`, 24px target, 4px radius, 2px accent and the unchanged native popup. |
| Static verification | `npm run check`, `npm run lint` (zero warnings), and `npm run test:source-boundaries` passed; the source contract requires TagManager coverage and forbids hard-coded demonstration colours or tag-tiddler mutation. |
| Offline artifact | `npm run build:wiki` passed, the rebuilt `Wiki/dist/index.html` was opened for review, and its theme/tools plugins include the TagManager selector extension. |
| Final full product suite | `npm run test:playwright` passed: **73/73**. |
