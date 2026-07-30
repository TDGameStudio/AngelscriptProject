# Verification Notes

Date: 2026-07-24

## Passing checks

- `pnpm run check` — TypeScript check passed.
- `pnpm run lint:all` — local and bounded vendor lint passed.
- `pnpm run test:source-boundaries` — 22/22 passed after the intended red-to-green boundary assertions for the retired sidebar resizer, legacy documentation bundle, and CSS selector.
- `pnpm run test:product-sources` — 4/4 passed; the selected source inventory contains only product sources.
- `pnpm run test` — TiddlyWiki product test passed (1/1).
- `pnpm run test:artifact` — offline build and artifact assertion passed; the build prepared exactly eight selected product plugins.

## Browser regression repair and complete verification

The initial full browser run identified a stale `tests/playwright/product/document-experience.spec.ts` assertion in `keeps Tools rows single-line and readable within the compact sidebar`. It expected each rendered `as-sidebar-tool-row` to contain a direct `button` plus a direct `i` description element, while the existing product template renders the product-owned `.as-tool-action` container and a nested `.tc-btn-text` label instead.

With explicit approval, the assertion was updated to validate the current `.as-tool-action → button → .tc-btn-text` truncation chain: overflow remains hidden, labels retain ellipsis and `nowrap`, and rows remain compact. The focused document-experience spec passed 17/17. A fresh complete `pnpm run verify` then passed, including Playwright 71/71.

## Environment warnings

The local shell reports Node `v25.5.0`, while `package.json` requires `>=24 <25`. Commands used the repository-declared `pnpm@11.8.0` through `npm exec`; all passing checks above completed despite the Node-version and npm pnpm-config warnings.
