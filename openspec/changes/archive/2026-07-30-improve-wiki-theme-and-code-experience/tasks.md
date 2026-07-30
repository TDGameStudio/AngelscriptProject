## 1. Behavior contracts

- [x] 1.1 <!-- TDD --> Replace the `as-code` Playwright fixture and assertions with failing UE AngelScript core-codeblock, Tomorrow token, source escaping, shared copy, and `angelscript-code` line-control coverage.
- [x] 1.2 <!-- TDD --> Extend theme/document tests with failing desktop focus, readable control, fixed-light, unified code-surface, and narrow-screen regression assertions.

## 2. Unified highlighting and code presentation

- [x] 2.1 <!-- TDD --> Register a source-owned UE AngelScript Highlight.js grammar and MIME mapping, remove the hand tokenizer, and make the representative syntax tests pass.
- [x] 2.2 <!-- TDD --> Replace `$as-code` with `$angelscript-code`, source-range parsing, displayed line numbers, highlighted rows, and safe invalid-range behavior.
- [x] 2.3 <!-- TDD --> Chain the core code-block post-render with an idempotent accessible copy action for fenced and enhanced code.
- [x] 2.4 <!-- TDD --> Apply the RefWiki classic Tomorrow token mapping and one shared structural code surface to all languages.

## 3. Conservative theme refinement

- [x] 3.1 <!-- TDD --> Restore visible `:focus-visible`, readable muted controls and links, full-width sidebar search, and consistent 32px desktop controls without changing layout.
- [x] 3.2 <!-- TDD --> Verify 1440x1000 and 1280x800 desktop behavior plus 390x844 regression-only mobile overflow and navigation behavior.

## 4. Documentation and verification

- [x] 4.1 <!-- Non-TDD --> Update plugin, Wiki, and bilingual agent documentation for Tomorrow, the UE grammar source, TW5 attribute inputs, line coordinates, copy behavior, and `$as-code` removal.
- [x] 4.2 <!-- Non-TDD --> Run type checking, lint, external-source tests, plugin tests, build, offline publish tests, complete Playwright coverage, and stale-interface scans; record verification results.
- [x] 4.3 <!-- Non-TDD --> Keep imported plugins under `src/`, retain the generated source bridge, and split fast local `lint` from explicit full-tree `lint:all`.

## 5. Visual-review corrections

- [x] 5.1 <!-- TDD --> Restore the six original LinOnetwo muted/control palette values rejected during desktop visual review, while retaining the visible focus and Tomorrow code refinements.
