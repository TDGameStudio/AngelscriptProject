## 1. Record and protect the repository boundary

- [x] 1.1 Add the proposal, design, capability specs, and this task checklist to the host OpenSpec change.
- [x] 1.2 Confirm all source edits are scoped to `Wiki/` and all host edits are scoped to this OpenSpec change.

## 2. Isolate the retained example fixture

- [x] 2.1 Add failing runtime and artifact assertions for the default exclusion and explicit examples workflow. <!-- TDD -->
- [x] 2.2 Add the shared example filter to default Wiki scripts and offline library generation. <!-- TDD -->
- [x] 2.3 Move example tiddlers/specs under `wiki/tiddlers/examples/` and add `playwright.examples.config.ts`.
- [x] 2.4 Add `dev:examples`, `test:examples`, and `build:examples` documentation and commands.
- [x] 2.5 Update bilingual Modern.TiddlyDev tutorials and Wiki agent guides to explain the isolated fixture.

## 3. Establish AngelscriptWiki defaults

- [x] 3.1 Add the bilingual AngelscriptWiki home tiddler and set it as the default entry.
- [x] 3.2 Replace template site title/subtitle references with AngelscriptWiki identity.
- [x] 3.3 Verify theme-owned Vanilla compatibility values remain in `angelscript-theme`.
- [x] 3.4 Remove the migrated duplicate system defaults while preserving runtime and external-plugin state.
- [x] 3.5 Add Playwright assertions for site identity, home defaults, theme selection, palette selection, and legacy startup absence. <!-- TDD -->

## 4. Consolidate AS presentation tooling

- [x] 4.1 Add or retain browser-only AS highlighter, code widget, theme, and plugin documentation files.
- [x] 4.2 Extend offline publish smoke coverage to validate complete HTML and filtered plugin library contents. <!-- TDD -->
- [x] 4.3 Keep the existing AS code card selectors and copy/highlighting behavior stable.

## 5. Add bilingual AS workflow documentation

- [x] 5.1 Add the AS status snapshot with dated capability and test-baseline information.
- [x] 5.2 Add the bilingual user workflow for setup, authoring, reload, debugging, tests, and release.
- [x] 5.3 Add the bilingual maintainer workflow for bindings, build/test, diagnostics, and source-of-truth boundaries.
- [x] 5.4 Add the AS presentation/theme roadmap and dual-track navigation.

## 6. Verify and commit the Wiki subrepository

- [x] 6.1 Run TypeScript check, lint, build, library build, offline publish, product Playwright, and examples Playwright validation.
- [x] 6.2 Run `git diff --check` and inspect the Wiki-only status before staging.
- [x] 6.3 Commit example isolation as `[Wiki] Refactor: isolate template example workflow`.
- [x] 6.4 Commit defaults/theme baseline as `[Wiki] Refactor: establish AngelscriptWiki defaults`.
- [x] 6.5 Commit presentation tooling as `[Wiki] Feat: add AngelScript presentation tools`.
- [x] 6.6 Commit workflow docs as `[Wiki] Docs: add bilingual AS workflows`.
- [x] 6.7 Report the new Wiki commit SHAs and leave the host gitlink uncommitted unless separately requested.
