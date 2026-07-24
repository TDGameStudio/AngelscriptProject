## 1. Record and protect the approved scope

- [ ] 1.1 Preserve the current Wiki package-script and untracked line-icon test changes while adding this OpenSpec's review, proposal, design, and capability deltas. <!-- Non-TDD -->
- [ ] 1.2 Add a source-boundary regression that forbids tracked product tests from depending on `comparison-artifacts`, then remove only the approved tracked left-sidebar fixture and its dedicated standalone test suite. <!-- TDD -->
- [ ] 1.3 Record the zh-Hans/en-GB support boundary, lingo compatibility ownership, inherited-theme identity defect, and follow-up authoring rules in the Wiki review/design artifacts. <!-- Non-TDD -->

## 2. Establish the strict developer-toolchain contract

- [ ] 2.1 Add failing Node tests for supported Node 24/pnpm 11.8.0, unsupported Node majors, missing package-manager identity, and pnpm 11.x version mismatch. <!-- TDD -->
- [ ] 2.2 Implement `Wiki/scripts/assert-toolchain.mjs` with an exported validation function and a direct CLI diagnostic path. <!-- TDD -->
- [ ] 2.3 Route standard package workflows through the toolchain check and replace nested npm calls plus the Playwright server command with pnpm commands, without removing the existing line-icon source-boundary test entry. <!-- TDD -->
- [ ] 2.4 Update `Wiki/AGENTS.md` and `Wiki/README.md` with exact Node 24/pnpm 11.8.0, Corepack, Scoop, and `npm exec` remediation guidance. <!-- Non-TDD -->

## 3. Make publishing and source bridging deterministic

- [ ] 3.1 Convert `publish-offline.test.mjs` into a failing async module-level publisher test that prepares sources and calls an exported `publishOffline()` rather than spawning pnpm. <!-- TDD -->
- [ ] 3.2 Export the publisher, anchor repository paths to its script directory, and retain direct-script publishing behavior. <!-- TDD -->
- [ ] 3.3 Add failing temporary-directory tests for queued product-source bridge coalescing, full-copy reconciliation after deletion/rename, entry isolation, flush, and dispose. <!-- TDD -->
- [ ] 3.4 Implement the per-entry debounced full-copy queue and route `dev-external-plugin-sources.mjs` through it with diagnostics. <!-- TDD -->

## 4. Make browser verification fresh by default

- [ ] 4.1 Add/update configuration-level coverage for a default Playwright server that builds and serves a unique isolated offline artifact, and for explicit external-server opt-in through `PLAYWRIGHT_BASE_URL`. <!-- TDD -->
- [ ] 4.2 Update package scripts and `playwright.config.ts` so default browser tests prepare a unique isolated generated-source root, build and serve its offline artifact rather than a development preview, and do not silently reuse an existing local server. <!-- TDD -->

## 5. Preserve multilingual compatibility <!-- TDD -->

- [ ] 5.1 Add failing source-level coverage for the default/supported locales, en-GB fallback, lingo legacy-plus-language-code paths, aligned theme translation keys, and absence of inherited TidGi identity in project-owned translations. <!-- TDD -->
- [ ] 5.2 Correct the local theme's zh-Hans/en-GB translation values to AngelScriptWiki identity while preserving their shared key set, and retain the TiddlyWiki lingo compatibility patch. <!-- TDD -->
- [ ] 5.3 Document Chinese-first bilingual authoring, permitted UI-text lookup paths, and TiddlyWiki-upgrade compatibility review steps in `Wiki/AGENTS.md` and `Wiki/README.md`. <!-- Non-TDD -->
- [ ] 5.4 Add failing actual-product visual tests for zh-Hans/en-GB at desktop and narrow viewports, covering visible navigation, bounded shell geometry, and no horizontal overflow. <!-- TDD -->
- [ ] 5.5 Add a test-only contrast helper and failing focus/contrast assertions for reviewed body, control, and tag states; extend the real product tests until they pass. <!-- TDD -->
- [ ] 5.6 Record the screenshot-golden admission policy (fixed renderer, deterministic scenes, masks, tolerance, review) without adding screenshot snapshots in this change. <!-- Non-TDD -->

## 6. Verify and integrate

- [ ] 6.1 On Node 24/pnpm 11.8.0, run `pnpm run check`, `pnpm run lint:all`, `pnpm run test:source-boundaries`, `pnpm run test:product-sources`, `pnpm run test`, `pnpm run test:artifact`, `pnpm run test:playwright`, and `pnpm run verify`; record results. <!-- Non-TDD -->
- [ ] 6.2 Review both repositories for unrelated changes, commit the Wiki submodule first, then commit only this OpenSpec and the parent Wiki gitlink. <!-- Non-TDD -->

## 7. Implement the approved layered test-execution architecture

- [x] 7.1 Record the evidence: current Node/Playwright scale, single sequential `verify` command, one CI job, no project-owned commit hook, duplicate publication cost, and shared generated-source race. <!-- Non-TDD -->
- [x] 7.2 Define gate ownership: `guard`, a 30-second `fast` layer, explicitly declared functional domains, manual/required-before-release `integration`, and `release`; document that this is not an optional-test policy. <!-- Non-TDD -->
- [x] 7.3 Define the regression-test admission rule: lowest viable layer first, existing surface suite before a new spec, and visual checks owned by theme/sidebar/document/i18n surfaces. <!-- Non-TDD -->
- [ ] 7.4 Measure current command durations on the pinned Node 24/pnpm 11.8.0 baseline against the fixed 30-second `fast` target; if the target is exceeded, move nonessential work down to a later verification layer. <!-- Non-TDD -->
- [x] 7.5 Add explicit fast, feature-domain, smoke, full-integration, and release command entry points while retaining `verify` as the explicit all-level command. <!-- TDD -->
- [x] 7.6 Add a versioned functional-domain suite registry; move formal product tests into `shell`, `sidebar`, `document`, `code`, `tools`, and `i18n` without creating duplicate scenarios. <!-- TDD -->
- [x] 7.7 Split CI into a required fast pull-request job and manually dispatchable product-integration and release/artifact jobs; document release validation as required before delivery. <!-- TDD -->
- [x] 7.8 Make every test-owned preview and release build use an isolated generated-source root; keep the offline artifact server on a fixed dedicated test port only in the explicit integration layer, and cover coexistence with a running interactive preview. <!-- TDD -->
- [x] 7.9 Update maintainer documentation with normal local-development commands, mandatory affected-suite selection, and the complete CI/release escalation path. <!-- Non-TDD -->
