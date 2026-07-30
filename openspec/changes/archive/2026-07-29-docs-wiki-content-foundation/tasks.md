## 1. Execution Baseline

- [x] 1.1 <!-- Non-TDD --> Capture parent, Wiki, and plugin branch/HEAD/status baselines and record every pre-existing dirty path before implementation.
- [x] 1.2 <!-- Non-TDD --> Re-read and reconcile the active changes that overlap `Wiki/package.json`, source-boundary tests, navigation, multilingual behavior, icons, theme, and Playwright files.
- [x] 1.3 <!-- Non-TDD --> Confirm Node 24, pnpm 11.8.0, and `pnpm run toolchain:check` in the current Wiki checkout without changing dependencies.

## 2. Document Content Contract

- [x] 2.1 <!-- TDD --> Add failing fixture tests for `.tid` parsing, required metadata, enum validation, deterministic diagnostics, and positive/nonnegative revision rules.
- [x] 2.2 <!-- TDD --> Implement `.tid` source parsing and deterministic document-record collection in `Wiki/scripts/document-content-contract.mjs`.
- [x] 2.3 <!-- TDD --> Add failing fixture tests for Chinese/English pairing, Chinese-first review, current-locale/Chinese fallback inputs, translation revisions, and stale status.
- [x] 2.4 <!-- TDD --> Implement pair uniqueness, Chinese-first, revision, and stale-translation source validation.
- [x] 2.5 <!-- TDD --> Add failing fixture tests for topic ownership, depth, `internals`, integration kind/dependencies, nonempty placeholders, legacy-tag denial, and compatibility-title allowlisting.
- [x] 2.6 <!-- TDD --> Implement topic, internals, integration, placeholder, retired-tag, page-role, and compatibility validation.
- [x] 2.7 <!-- TDD --> Add failing fixture tests for Showcase IDs, tier field/tag agreement, purpose, catalog coverage, and hidden-fixture boundaries.
- [x] 2.8 <!-- TDD --> Implement Showcase and source-key validation and add `test:document-content` to the current package scripts without losing existing changes.
- [x] 2.9 <!-- TDD --> Add failing fixtures for Hazelight catalog ID/schema/enums/revisions/evidence/consequence/benchmark rules and restricted-source excerpt/link leakage.
- [x] 2.10 <!-- TDD --> Implement deterministic Hazelight catalog validation and stale-row detection while keeping restricted source metadata-only.

## 3. Topic and Tag Architecture

- [x] 3.1 <!-- TDD --> Add a failing repository-level contract asserting the `ASWiki/Docs` root, exact fifteen topic keys, unique order, and neutral initial colors.
- [x] 3.2 <!-- TDD --> Create the Docs root plus fifteen ordered first-level topic tag tiddlers and make the taxonomy contract pass.
- [x] 3.3 <!-- TDD --> Add a failing repository-level contract for fifteen Chinese L0 landing pages and their required topic-specific placeholder sections.
- [x] 3.4 <!-- TDD --> Create the fifteen Chinese topic landing pages with logical keys, metadata, source inputs, dependencies, and explicit unreviewed state.
- [x] 3.5 <!-- TDD --> Create the metadata-driven `AS/Docs` directory and verify ordering is independent from filename and localized caption.
- [x] 3.6 <!-- TDD --> Add failing tests that deny `ASWiki/Home`, `ASWiki/Navigation`, `ASWiki/Status`, `ASWiki/Theme`, `ASWiki/Workflow`, and `ASWiki/Maintainer`.
- [x] 3.7 <!-- TDD --> Remove the six legacy tags, add exact page-role/topic mappings, retain current canonical titles/bodies, and make retirement tests pass.
- [x] 3.8 <!-- TDD --> Update current tag-color/popup/sidebar test fixtures to use a real first-level topic while preserving explicit negative tests for retired tags.

## 4. Chinese-First Document Resolution

- [x] 4.1 <!-- TDD --> Add failing macro/runtime tests for current-locale resolution, Chinese fallback, missing documents, invalid logical keys, and stale English.
- [x] 4.2 <!-- TDD --> Implement the logical document-target macro and global `as-doc-link` WikiText procedure.
- [x] 4.3 <!-- TDD --> Implement ViewTemplate notices for Chinese fallback and stale English revisions and make runtime tests pass.
- [x] 4.4 <!-- TDD --> Replace hard-coded primary AS navigation with Docs, Internals, and Showcase directory links while retaining a bounded compatibility group.
- [x] 4.5 <!-- TDD --> Add browser coverage for Chinese default, English selection, Chinese fallback notice, stale revision notice, missing-document state, and unchanged legacy deep links.

## 5. Emphasized Chapters and Internals

- [x] 5.1 <!-- TDD --> Add failing contract expectations for exact L0–L5 logical keys in `unreal-language` and `hot-reload`.
- [x] 5.2 <!-- TDD --> Create the five additional Unreal language-feature skeletons with the complete feature-family catalog and L4/L5 internals evidence shape.
- [x] 5.3 <!-- TDD --> Create the five additional hot-reload skeletons with change classification, recovery, full pipeline, and L4/L5 internals evidence shape.
- [x] 5.4 <!-- TDD --> Create the cross-topic `AS/Docs/Internals` directory filtered by `as-doc-kind: internals` without an internals tag hierarchy.
- [x] 5.5 <!-- TDD --> Add browser coverage that lower depths precede internals and that internals results retain owning topic and depth.
- [x] 5.6 <!-- TDD --> Add failing contract expectations for the exact four UHT logical keys/depths and seven Hazelight logical keys/depths plus the nested Hazelight topic tag.
- [x] 5.7 <!-- TDD --> Create the UHT overview, workflow, internals, and maintenance pages with distinct `NativeRuntimeLinked`, `NativeModuleFunctionAddress`, reflective/RPC fallback, layout-version, artifact, diagnostics, and test contracts.
- [x] 5.8 <!-- TDD --> Extend the document contract for the machine-readable Hazelight catalog: unique IDs plus relationship, confidence, compared revisions/date, Unreal-version applicability, both evidence lists, consequences, disposition, benchmark, detail key, and restricted-source metadata.
- [x] 5.9 <!-- TDD --> Create the Hazelight overview/matrix/binding/class/struct/architecture/audit pages or informative placeholders from the pinned audit research, including the non-exhaustive thirteen-file report and current editor-only `future-candidate`.
- [x] 5.10 <!-- TDD --> Add source/browser coverage that private Hazelight source is never rendered/mirrored, historical estimates are not reviewed benchmarks, and a baseline revision change marks affected comparison rows stale.

## 6. Special Topics

- [x] 6.1 <!-- TDD --> Add failing contract expectations for GameplayTags, GAS, Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree landings.
- [x] 6.2 <!-- TDD --> Create GameplayTags and GAS placeholder landings as optional-plugin topics and record the GAS-to-GameplayTags dependency.
- [x] 6.3 <!-- TDD --> Create Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree placeholder landings as engine-domain topics.
- [x] 6.4 <!-- TDD --> Add browser coverage for integration-kind labels, dependency presentation, and separation from the core learning sequence.

## 7. Showcase Foundation

- [x] 7.1 <!-- TDD --> Add failing contract tests for the Showcase root, Base/Pattern/Lab tier tags, unique tier membership, purpose fields, and exact 42-entry B01–B15/P01–P16/L01–L11 coverage.
- [x] 7.2 <!-- TDD --> Create Showcase root/tier tag tiddlers and root/Base/Pattern/Lab indexes without final colors.
- [x] 7.3 <!-- TDD --> Create the B01–B15, P01–P16, and L01–L11 catalog with mapped/gap/experiment state and planned verification.
- [x] 7.4 <!-- TDD --> Classify the existing Markdown, Markdown More, and WikiText pages and adapt the current syntax index as a compatibility entry.
- [x] 7.5 <!-- TDD --> Move the ordinary-title AngelScript reader page out of the hidden test directory, retain hidden `$:/tests/...` code fixtures, and remove the source-boundary exception.
- [x] 7.6 <!-- TDD --> Add focused browser coverage for tier discoverability, Base stability, Pattern containment/accessibility, Lab warnings, and the moved AngelScript page.
- [x] 7.7 <!-- TDD --> Record B13 procedure/function/legacy-macro cases with parameter/default/quoting/scope/nesting/filter/transclusion acceptance and distinguish recommended current syntax from compatibility syntax.
- [x] 7.8 <!-- TDD --> Record B14 trusted WikiText HTML cases with semantic markup, nested widgets/procedure output, escaped dangerous examples, and an explicit no-live-script/no-inline-handler boundary.
- [x] 7.9 <!-- TDD --> Record B15 local/external embed cases with title/loading/minimal-sandbox/referrer/fallback/offline/denied-frame/responsive acceptance and no third-party dependency in normal verification.
- [x] 7.10 <!-- TDD --> Record P15/P16 reusable author contracts and keep L11 embed security/packaging as Lab until CSP, privacy, offline-artifact, accessibility, and threat review graduate it.

## 8. Source Reference Corpus

- [x] 8.1 <!-- TDD --> Add failing offline tests for exact repository commit, tree hash, allowed paths, license classifications, registry keys, anchors/ranges, excerpt hashes, raw-source boot exclusion, metadata-only restricted Hazelight keys, and private-Hazelight corpus rejection.
- [x] 8.2 <!-- TDD --> Implement the source-corpus manifest/registry validator and deterministic bounded excerpt generator.
- [x] 8.3 <!-- TDD --> Add local temporary-Git fixture tests for exact-revision checkout, wrong identity, moved/ambiguous/missing references, unknown licenses, and transactional replacement.
- [x] 8.4 <!-- TDD --> Implement the explicit networked source-corpus synchronizer so it never copies the current plugin worktree and never commits or pushes.
- [x] 8.5 <!-- Non-TDD --> With explicit network authorization, import one reviewed published `UnrealAngelscriptPlugin` commit and review revision, tree, file, license, size, and reference diffs.
- [x] 8.6 <!-- TDD --> Generate and validate the first selected source excerpts and commit-pinned links for internals documents.
- [x] 8.7 <!-- TDD --> Add offline `test:source-corpus` to normal verification while proving `dev`, `test`, `verify`, and `build:wiki` cannot invoke synchronization.

## 9. Author Guidance and Migration Evidence

- [x] 9.1 <!-- Non-TDD --> Update `Wiki/AGENTS_ZH.md` with paths, fields, tags, Chinese-first revision workflow, internals evidence, placeholder rules, source references, Hazelight comparison/restricted-source rules, Showcase tiers, TiddlyWiki procedure/function/HTML/embed boundaries, and verification.
- [x] 9.2 <!-- Non-TDD --> Review the Chinese author guidance against implemented source and tests before producing the equivalent `Wiki/AGENTS.md` update.
- [x] 9.3 <!-- Non-TDD --> Map every migrated existing Wiki page and every promoted knowledge/Hazelight/example source to its new logical key and disposition.
- [x] 9.4 <!-- TDD --> Add a source-level check that all registered source keys resolve and all compatibility titles remain inside the exact allowlist.

## 10. Verification and Handoff

- [x] 10.1 <!-- TDD --> Run document-content, source-corpus, multilingual, source-boundary, product-source, and focused Playwright gates; resolve all change-owned failures and record preserved pre-existing baseline failures.
- [x] 10.2 <!-- TDD --> Run `pnpm run check`, change-owned and vendor lint, `pnpm run build:wiki`, and the repository-wide `pnpm run verify`; record the pre-existing files that prevent the repository-wide lint/verify command from becoming green without expanding this change.
- [x] 10.3 <!-- Non-TDD --> Inspect the offline artifact across Home, Docs, Internals, emphasized chapters, UHT, Hazelight baselines/report limitations/details, special topics, Chinese fallback, placeholders, the 42-entry Showcase catalog, and source excerpts.
- [x] 10.4 <!-- Non-TDD --> Measure and record raw corpus bytes, generated excerpt/index bytes, offline artifact delta, boot tiddler delta, and update/reference-validation time.
- [x] 10.5 <!-- Non-TDD --> Compare parent/Wiki/plugin statuses against the captured baseline, record externally advanced HEADs, and confirm unrelated dirty changes and the plugin worktree are preserved.
- [x] 10.6 <!-- Non-TDD --> If explicitly requested, commit the Wiki repository first, then stage only the parent Wiki gitlink and this OpenSpec record; otherwise leave both uncommitted.
