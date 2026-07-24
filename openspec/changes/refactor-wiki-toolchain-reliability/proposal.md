## Why

The Wiki product has a sound runtime/plugin boundary, but its developer workflow is less deterministic than the product itself: the repository pins Node 24 and pnpm 11.8.0 while scripts mix npm and pnpm, the offline test shells out to a bare pnpm executable, and the incremental generated-source bridge can expose a reused preview to stale files. The selected static left-sidebar reference is also still tracked and tested even though the equivalent behavior is covered by the live product suite.

The test suite is also growing without an execution architecture: 48 Node tests and 69 Playwright product tests currently converge only through one sequential `verify` command and one CI job. There is no sanctioned fast loop or product-surface grouping, so normal feature work is pushed either toward unnecessarily broad local verification or toward skipping validation altogether. This change implements a layered execution model: a sub-30-second fast gate, explicit product-domain regressions, manually requested complete integration, and release validation.

This change records the review and makes the supported development, offline-build, and browser-test path deterministic without altering the reader-facing Wiki design or its selected plugin set.

## What Changes

- Add a strict Wiki developer-toolchain contract for Node 24 and pnpm 11.8.0, with actionable diagnostics and pnpm-consistent command composition.
- Refactor the offline artifact test to invoke the publish module directly rather than spawning a hard-coded package-manager command.
- Replace per-path generated-source watcher mirroring with debounced, per-plugin full reconciliation and direct regression coverage for source changes.
- Make default product Playwright runs build and serve a unique isolated offline artifact rather than a development preview; an external server is used only through explicit `PLAYWRIGHT_BASE_URL` opt-in.
- Remove the tracked `comparison-artifacts/left-sidebar/03-compact-control-rail.html` fixture and its standalone visual-reference suite while keeping untracked local comparison artifacts intact.
- Establish and document the supported bilingual contract: Chinese (`zh-Hans`) default, English (`en-GB`) fallback, lingo compatibility ownership, and product-language requirements for later Wiki work.
- Remove inherited TidGi/"太记预置主题" identity from the local Angelscript theme's visible translation catalog and cover both supported locales with regression checks.
- Add runtime visual-verification coverage for the supported language/viewport matrix and critical focus, contrast, overflow, and interaction-state style contracts; record screenshot-golden prerequisites without introducing an unstable baseline yet.
- Implement a layered test-execution architecture: fast local contracts, declared feature-domain suites, manually requested complete integration, and release-only artifact concerns. Define rules that prevent one-off feature tests from accumulating as unowned suites.
- Record the architecture audit, validated boundaries, intentionally deferred work, and relationship to existing Wiki OpenSpecs in this change's review record.

## Capabilities

### New Capabilities

- `wiki-development-toolchain`: Defines the supported Node/pnpm baseline and deterministic standard development, artifact-test, and Playwright entry points for the integrated Wiki.
- `wiki-multilingual-compatibility`: Defines the supported Wiki locales, fallback behavior, lingo compatibility boundary, and requirements for new product-facing text.
- `wiki-visual-verification`: Defines the stable, runtime visual-style regression matrix for actual product surfaces.
- `wiki-test-execution-architecture`: Defines implemented test levels, product-domain selection rules, CI gates, and regression-test admission policy for the integrated Wiki.

### Modified Capabilities

- `wiki-document-experience-integration`: Tightens the generated product-source bridge so changes converge to complete, current per-plugin generated copies rather than partial event-by-event mutations.

## Impact

- Wiki submodule: package scripts, development scripts, artifact publishing test, Playwright configuration, product-source bridge tests, future test-command/CI design, repository documentation, and one tracked comparison fixture/test suite.
- Parent repository: this OpenSpec record and, after the Wiki commit, only the `Wiki` gitlink.
- No reader-facing TiddlyWiki API, plugin manifest entry, vendor tree hash, external service policy, content model, or accepted visual layout changes.
