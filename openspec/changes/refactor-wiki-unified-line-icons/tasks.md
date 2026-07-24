## 1. Corrected catalog and semantics

- [x] 1.1 Replace the string-only catalog with per-icon v2 records for semantic ID, category, asset, source profile, upstream Feather name, and license.
- [x] 1.2 Classify all selected core and product-plugin image titles; give every non-excluded target an explicit semantic icon and specific exclusion reasons.
- [x] 1.3 Remove the `generic-tool` fallback and declare the limited true semantic aliases with their primary target and rationale.
- [x] 1.4 Keep state/action variants visually distinct, including lock/unlock, preview open/closed, timestamps, folding, story views, and heading levels.

## 2. Curated assets and deterministic output

- [x] 2.1 Retain the fit-for-purpose local sidebar line geometry and add only reviewed Feather 4.28 single-icon assets with MIT provenance.
- [x] 2.2 Add the deliberate reviewed-import helper; keep normal generation and runtime independent from `Reference/tw-icons`.
- [x] 2.3 Regenerate canonical Image tiddlers, all system overrides, sidebar map, TypeScript registry, and the non-default review gallery.
- [x] 2.4 Scale the former 20-by-20 sidebar toggle path into the common 24-by-24 canvas without changing its intended visual proportions.

## 3. Visual-quality correction and regression coverage

- [x] 3.1 Add a shared no-fill cascade rule and narrow legacy fill selectors so interaction-state CSS cannot paint generated line icons.
- [x] 3.2 Add source contracts for provenance, no fallback, geometry uniqueness, explicit aliases, exact toggle geometry, and generator freshness.
- [x] 3.3 Add Playwright coverage for the gallery’s source metadata and computed fill, plus sidebar hover and hide/show state transitions.
- [x] 3.4 Override the tiddler-toolbar More-action control with the semantic menu glyph while retaining `down-arrow` for genuine dropdown controls.
- [x] 3.5 Give AS code-copy idle, success, and failure states dedicated catalog icons rather than reusing core toolbar state glyphs.
- [x] 3.6 Make both More-action popups use a fixed 16px line-icon column and vertically centred text; cover the nested dirty-indicator wrapper and the Markdown plugin image override.
- [x] 3.7 Run source, type, scoped-lint, artifact, and affected product-browser verification; capture desktop and narrow-width visual evidence. The full workspace lint baseline remains blocked by unrelated existing errors and format warnings in `assert-toolchain.mjs`, `watch-external-plugin-sources.test.mjs`, and other untouched files.

## 4. Documentation and handoff

- [x] 4.1 Update Chinese-first contributor guidance for the v2 catalog, reviewed Feather import, licensing, gallery, and no-fallback policy.
- [x] 4.2 Validate the OpenSpec record and report remaining unrelated dirty-worktree paths without staging or modifying them.
