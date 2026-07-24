## Context

`Wiki/` is a TiddlyWiki 5.4.1 product submodule, not a collection of separately published plugins. Its healthy production architecture is already explicit: `product-sources.json` selects eight local/vendor product sources; the theme owns presentation, tools owns browser behavior, configuration owns defaults, and vendor provenance is verified before generated plugin sources are consumed.

The reviewed workflow has three reliability gaps. First, the declared Node 24/pnpm 11.8.0 contract is not enforced before commands run, while scripts recursively call npm and the artifact test shells out to a bare pnpm. Second, the development bridge mirrors individual filesystem events, so rapid source changes can leave an intermediate generated tree visible to a reused preview. Third, Playwright reuses an already-running local server by default, which can make a passing product test describe an older source snapshot.

The current language path is bilingual rather than generic i18n: `$:/language` defaults to `zh-Hans`, `tiddlywiki.info` explicitly loads the zh-Hans language plugin while TiddlyWiki core provides en-GB, reader content selects Chinese/English blocks from that field, theme configuration resolves `<<lingo>>` keys, and a local `$:/core/macros/lingo` patch retains both TiddlyWiki 5.4.1's legacy lookup and language-code fallback. The imported theme translations still identify themselves as TidGi/"太记预置主题", which is user-visible and incompatible with the product identity.

The current host is intentionally dirty outside this scope. The Wiki submodule also contains a separate, in-progress unified-line-icons change: its package-script addition and untracked `scripts/line-icons.test.mjs` must be preserved.

The Wiki now contains 48 Node tests and 69 Playwright product tests. `package.json` exposes focused individual commands, but ordinary development guidance centers `pnpm run verify`; that command serializes static checks, source contracts, runtime tests, offline publication, artifact validation, and the entire browser suite. The sole CI workflow runs that same aggregate command in one 35-minute job. There are no user-maintained Husky hooks beyond the generated Husky support files, no supported `fast` command, no named product-surface suites, and no stated rule for when a new feature needs a browser test rather than a lower-level regression.

An exploratory local run also reproduced a Windows ownership conflict: a running preview retained the shared `.generated/plugin-sources` tree while a second preparation attempted to replace it, and `rmSync()` failed with `ENOTEMPTY`. Test-owned previews and interactive previews therefore require separate generated-source roots in the later implementation; owning a different TCP port alone is insufficient.

## Goals / Non-Goals

**Goals:**

- Establish one supported, deterministic Wiki toolchain: Node 24 and pnpm 11.8.0.
- Remove bare package-manager dependence from artifact testing while retaining direct CLI publishing.
- Make generated plugin sources converge to a complete per-plugin source snapshot after a change batch.
- Ensure ordinary Playwright runs do not silently inspect a stale development server.
- Remove only the approved tracked left-sidebar comparison fixture and the test suite that exclusively exercises it.
- Preserve zh-Hans and en-GB as the supported reader locales, document their fallback and authoring rules, and remove inherited theme-brand strings from both translation catalogs.
- Add stable actual-product visual verification for both supported languages and desktop/narrow viewports without turning the full suite into cross-platform screenshot-noise.
- Record a future layered execution model in which `fast` is the automatic pull-request CI gate, complete product integration runs only by explicit manual request or as pre-release validation, and release validation remains required before delivery.
- Preserve the review evidence and implementation decisions in an independently executable OpenSpec.

**Non-Goals:**

- Merging theme, tools, configuration, or vendor plugins.
- Changing product-source entries, vendor hashes, Draw.io's user-triggered external iframe policy, Wiki content, or reader-facing styles.
- Deleting ignored comparison artifacts such as `new_review.html`, `new_review2.html`, home-concept files, or review screenshots.
- Completing the pending theme decomposition, SDK metadata, browser-matrix, historical-spec reconciliation, or icon-system tasks tracked by other Wiki OpenSpecs.
- Making Node 25 or pnpm 11.15.x part of the supported verification baseline.
- Adding a third locale, machine translation, a runtime translation service, or rewriting all existing bilingual article content.
- Adding broad screenshot golden files before CI browser, fonts, masking rules, and reviewed stable scenes are specified.
- Changing the current package scripts, Playwright test annotations, CI workflow, generated-source layout, or required GitHub checks in this record-only task. Those changes are deferred to the implementation tasks below.

## Decisions

### 1. Enforce the declared Node/pnpm pair at standard entry points

Add a small Node-only `scripts/assert-toolchain.mjs` module. Its exported validation function accepts injected version/user-agent input for unit tests; its CLI path reads the current process. The supported pair is Node major `24` and pnpm exactly `11.8.0`. It reports the detected values and recommends either Node 24 plus Corepack or `npm exec --yes pnpm@11.8.0 -- <command>`.

The check runs through package lifecycle hooks for the standard workflow (`dev`, build, test, artifact test, Playwright, and verify). Package scripts invoke pnpm consistently; the existing line-icon addition to `test:source-boundaries` remains unchanged. A warning-only policy was rejected because the current Node 25/pnpm-missing failure appears late and is not reproducible against CI.

### 2. Test the publisher as a module, not through a nested package command

`publish-offline.mjs` exports `publishOffline()` and computes its repository paths from the script location. A direct invocation remains supported through an ESM main-module guard. `publish-offline.test.mjs` becomes an ordinary async `node:test`: it prepares product sources, removes the generated dist directory, calls `publishOffline()`, and validates the resulting artifact.

This keeps the build command integration intact while making the test deterministic and runnable without assuming a bare executable in `PATH`. Calling `process.env.npm_execpath` was rejected because it retains package-manager recursion and has environment-dependent semantics.

### 3. Reconcile a plugin snapshot after each source-change batch

Keep `prepareProductSources()` as the authoritative initial full preparation. Refactor the watcher around a per-plugin queue: a source event identifies its owning manifest entry, enqueues that entry, and a short debounce invokes the existing full-copy primitive for that plugin. A fresh complete source directory replaces the generated plugin directory, so deletes and directory renames cannot leave stale children.

The queue exposes enqueue, flush, and dispose behavior through a small internal factory. Its tests use real temporary directories and controlled timers; no watcher library is added. Event-level incremental copying was rejected because it creates intermediate states, makes rename handling platform-sensitive, and has no focused regression coverage.

### 4. Fresh product test servers are the default

`playwright.config.ts` starts a dedicated static server only when `PLAYWRIGHT_BASE_URL` is absent. That server builds a unique offline artifact from a unique `.generated/` source root and listens at a fixed dedicated test address. When the variable is present, Playwright launches no server and tests the explicit external URL. This turns reuse from an implicit local convenience into an explicit developer choice and makes default source/test results deterministic without contending with the interactive preview.

### 5. Remove the standalone visual fixture without deleting local experiments

Delete only the Git-tracked `comparison-artifacts/left-sidebar/03-compact-control-rail.html` and `tests/playwright/product/sidebar-experiment-previews.spec.ts`, which exclusively test that independent mockup. Add a source-boundary assertion preventing product test code from depending on `comparison-artifacts`. The ignored directory remains because it holds user-owned experimental material outside the product source of truth.

### 6. Treat language selection and lingo fallback as a product compatibility boundary

Declare `zh-Hans` and `en-GB` as the only supported product locales. `zh-Hans` remains the default; unavailable or unrecognized content falls back to `en-GB`. Product-facing WikiText must use a core language tiddler, `<<lingo>>` under an explicit lingo base, or the established `$:/language` conditional pattern; TypeScript must resolve existing TiddlyWiki language tiddlers instead of embedding a new visible English label.

Retain the local lingo patch until the locked TiddlyWiki baseline supplies both the legacy and language-code paths needed by the theme and bilingual content. Add a source-level multilingual contract test: it checks configured locales/default, both required lingo paths, matching theme translation key sets, absence of inherited TidGi identity in project-owned translations, and the bilingual navigation selection mechanism. The local theme catalog is renamed to AngelscriptWiki/AngelScript wording in both languages; vendor translations are not modified.

### 7. Extend visual verification through stable runtime invariants first

The existing product suite already tests real DOM geometry, computed CSS, overflow, focus, and interaction state for the shell, sidebar, More, tags, code, and controls. Extend it with a compact locale/viewport matrix over actual Wiki pages: zh-Hans and en-GB at desktop and narrow widths must preserve visible navigation, bounded sidebar/story geometry, and no horizontal document overflow. Add a small contrast helper used only by test code to verify reviewed opaque foreground/background pairs meet WCAG AA text contrast and that keyboard focus remains visible.

Do not add `toHaveScreenshot` golden files in this change. Screenshot baselines require a fixed CI browser/font renderer, deterministic fixture state, explicit masks for time/history/volatile lists, a reviewed tolerance policy, and a small stable-scene inventory. Record these prerequisites in the review rather than introducing an unreliable pixel gate.

### 8. Execute tests by risk gate, not as an undifferentiated optional set

The workflow SHALL distinguish five named levels. `guard` validates the pinned toolchain before every standard command. `fast` runs type checking, local lint, and deterministic Node/source contracts within a 30-second target and is the normal mandatory local loop; it does not publish an artifact or reserve the fixed browser-test port. `affected` runs explicitly requested `shell`, `sidebar`, `document`, `code`, `tools`, or `i18n` browser suites. `integration` runs the entire runtime and Chromium product suite plus the isolated artifact-server contract only when explicitly requested. `release` runs offline publication, artifact structure validation, and the full vendor audit before delivery.

These levels do not make regressions optional. They state the earliest required gate: a maintainer runs `fast` plus the relevant `affected` suite during ordinary feature work; pull-request CI runs the fast gate only; complete integration is run on explicit request or before release; release work remains mandatory before delivery but is not added to every edit loop. The aggregate `verify` command remains the explicit all-level release command and must not be described as the default command for every local edit.

Affected selection SHALL be declared through a repository-owned suite registry, not guessed from `git diff` paths. Each browser regression belongs to exactly one functional domain and selected launch-critical scenarios carry an `@smoke` title marker. A new test must be placed in an existing domain suite whenever it protects the same contract. A separate spec is justified only when it introduces a distinct fixture lifecycle or independently owned product boundary; historical task names are not a valid test-suite boundary.

CI SHALL expose a required fast pull-request job and manually dispatchable integration/release jobs. Browser test ownership must create a unique generated-source root and offline artifact directory for each test server; it must never prepare, delete, or watch the same root owned by an interactive preview.

## Risks / Trade-offs

- [A developer has Scoop's newer pnpm rather than 11.8.0] → Fail immediately with a command that runs the exact package-manager version without changing repository state.
- [The main toolchain check blocks an ad hoc command] → Limit automatic checks to standard product workflow commands; direct script invocation remains available for focused internal tests.
- [A full plugin copy costs more than incremental copying] → Product plugins are small enough for development use, and correctness after rename/delete is worth the bounded copy cost.
- [A local dev server already owns port 8080] → Default Playwright uses a distinct fixed test port and artifact root; the maintainer may pass `PLAYWRIGHT_BASE_URL` to test that server intentionally.
- [Removing the fixture loses visual history] → The user explicitly approved removal; live product specs retain runtime behavior coverage and ignored comparison artifacts remain available locally.
- [Existing icon work modifies package scripts concurrently] → Preserve its source-boundary test entry while applying narrowly scoped script changes, and validate the combined suite.
- [A new feature adds literal text in one locale] → Document the accepted localization entry points and add/extend the multilingual contract before adding product-visible text.
- [A TiddlyWiki upgrade changes lingo behavior] → Keep the two-path lingo test and require a review of the local compatibility patch before changing the locked baseline.
- [Visual tests become environment-sensitive] → Assert stable computed styles and geometry over actual deterministic product scenes; defer pixel goldens until the renderer/mask policy is approved.
- [Test levels become a loophole for skipped regression coverage] → Keep `fast` plus the declared affected suite mandatory for local feature work, retain a manual full-integration command, and require release validation before delivery.
- [Path-derived test selection becomes stale after refactors] → Use explicit product-surface annotations or a versioned suite registry rather than inferring ownership from changed filenames.
- [A fresh test server races an interactive preview] → Allocate a unique generated-source root per server, not only a distinct port.

## Migration Plan

1. Record the OpenSpec artifacts and the audit evidence before source changes.
2. Add and observe failing unit/contract tests for the new toolchain, publishing, bridge, and comparison-boundary behaviors.
3. Implement each production change minimally, preserving current package and icon-test edits.
4. Add the multilingual contract, correct inherited theme strings, and document the authoring/compatibility policy before adding later product-visible text.
5. Add the locale/viewport visual matrix and reviewed contrast/focus invariants without committing screenshot baselines.
6. Add the named fast/affected/full/release commands, an explicit product-domain registry, and an isolated offline-artifact server while preserving the aggregate verification escape hatch.
7. Migrate existing product specs into their functional domains, add source-boundary contracts, and expose a fast pull-request CI job with manually dispatchable integration/release jobs.
8. Run focused checks after each group, then execute the full Wiki verification from a Node 24/pnpm 11.8.0 environment.
9. Commit the Wiki submodule first; then commit only this OpenSpec and the resulting parent `Wiki` gitlink.

Rollback is source-level: reverting the Wiki commit restores prior scripts and the reference fixture. No source manifest, vendor snapshot, remote repository, deployment, or external service state is changed.

## Open Questions

- The fast command has a 30-second budget. The pinned Node 24/pnpm 11.8.0 baseline measurement determines which non-essential check moves down a level if that budget is exceeded.
