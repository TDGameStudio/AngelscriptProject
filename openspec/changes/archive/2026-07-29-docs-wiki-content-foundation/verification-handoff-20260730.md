# Verification and Handoff — 2026-07-30

## Outcome

The documentation-content foundation is implemented. It provides:

- fifteen neutral documentation topics and 42 Chinese formal document placeholders;
- locale-aware logical links with reviewed-Chinese fallback and stale translation handling;
- exact language, Unreal-language, hot-reload, UHT, Hazelight, integration, internals, and Showcase structures;
- a 42-entry Base/Pattern/Lab Showcase catalog;
- an isolated, fixed-revision public source corpus plus three generated bounded excerpts;
- Chinese-first and equivalent English author guidance;
- source, migration, compatibility, artifact, and browser contracts.

All change-owned failures observed during verification were corrected. The repository-wide commands still expose three pre-existing baseline problems described below; those unrelated files were intentionally not reformatted, weakened, moved, or otherwise absorbed into this content change.

## Successful verification

All commands used Node 24.18.0 and pnpm 11.8.0 through the supported temporary toolchain wrapper.

| Gate | Result |
|---|---|
| `pnpm run check` | PASS |
| `pnpm run test:document-content` | 36/36 PASS |
| `pnpm run test:source-corpus` | 8/8 PASS |
| `pnpm run test:multilingual` | 3/3 PASS |
| `pnpm run test:product-sources` | 4/4 PASS |
| `pnpm run test:source-bridge` | 3/3 PASS |
| `pnpm run test:product-test-infrastructure` | 19/19 PASS |
| change-owned local lint, excluding the two recorded baseline files | PASS |
| `pnpm run lint:vendors` | PASS |
| `pnpm run test:feature document` | 18/18 PASS |
| `pnpm run test:feature sidebar` after updating the compatibility-collapse expectation | 33/33 PASS |
| `pnpm run test:runtime` | 1 spec, 0 failures |
| `pnpm run test:artifact-server` | 2/2 PASS |
| `pnpm run build:wiki` | PASS |
| `pnpm run test:artifact` | 1/1 PASS |
| `git diff --check` | PASS |

The document browser gate inspects Home-driven locale resolution, Docs, Internals, exact emphasized sequences, UHT, revisioned Hazelight data and restricted-source boundaries, six integration landings, all Showcase tiers, compatibility links, and all three rendered source excerpts with commit-pinned external links.

The artifact gate additionally asserts the required Home/Docs/Internals/UHT/Hazelight/integration/Showcase titles, exact 42-entry catalog, exact three generated excerpts, fixed commit URLs and hashes, and absence of raw-corpus titles from the boot store.

## Preserved baseline failures

Fresh repository-wide runs produced the following evidence:

1. `pnpm run test:source-boundaries`: 35/36 PASS. The sole failure is the pre-existing tracked `tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts`, which still contains a `comparison-artifacts` path. The content-foundation source-boundary failures (old navigation contract and document-domain sidebar coupling) were corrected.
2. `pnpm run lint:all`: change-owned and vendor files pass when checked independently. The full local lint still reports:
   - a pre-existing dprint warning for generated `src/angelscript-tools/line-icon-registry.ts`;
   - nine pre-existing unnecessary type-assertion errors plus formatting warnings in `tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts`.
3. `pnpm run test:ui:full`: the first complete run was 79/81. Its change-owned failure was the old assumption that a compatibility link was visible before expanding the now-collapsed compatibility group; after correction, the complete sidebar domain is 33/33. The remaining pre-existing failure is the Home control foreground/background contrast ratio `4.230388196991729`, below the required `4.5`, in `tests/playwright/product/i18n/locale-visual.spec.ts`.
4. `pnpm run verify`: executed and failed at the same two pre-existing lint files before reaching later release stages. Those later stages were therefore run independently and are listed above.

These are not waived product defects. They remain visible for their owning changes; this OpenSpec does not weaken their assertions or disguise them as passes.

## Content and packaging measurements

### Content shape

- Formal documents: 42, all `zh-Hans`.
- Lifecycle: 42 explicit `placeholder` pages.
- Depths: L0 22, L1 3, L2 4, L3 2, L4 7, L5 4.
- Internals pages: 11.
- First-level topic tags: 15.
- Compatibility titles: exactly 7.
- Showcase catalog: 42 entries.
- Document-content contract errors: 0.

### Source corpus and validation

- Public repository: `https://github.com/TDGameStudio/UnrealAngelscriptPlugin`.
- Revision: `4e2e23ca16ae9f1786258fb96b09b268259b1aad`.
- Git tree: `a77cbed376c025f78226fc242fd824878b1c24c9`.
- Snapshot digest: `sha256:972d6490ff4640473eff63fdeb0bbf1b928fb5943a20173131ac80fbe5b08fec`.
- Raw corpus: 1,158 files, 17,692,585 bytes.
- First explicit network sync wall time observed by the command runner: 9.3 seconds.
- Offline reference-validation time, five runs: 144.94, 148.10, 152.29, 152.91, and 156.65 ms; median 152.29 ms.
- Generated excerpt bodies: 5,871 bytes.
- Manifest plus public/restricted registries: 4,242 bytes.

### Offline artifact

The pre-existing `dist/index.html` was measured immediately before `build:wiki`, then the new artifact was measured with the same parser.

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Decoded single-file artifact | 4,252,872 bytes | 4,396,954 bytes | +144,082 bytes |
| Boot tiddlers | 155 | 231 | +76 |
| Generated source excerpt tiddlers | 0 | 3 | +3 |

The 17.7 MiB raw corpus contributes zero raw-corpus paths/titles to the offline boot store.

## Workspace preservation

The implementation baseline recorded parent `639e668…`, Wiki `509ef98…`, and plugin `bc6c4f3…`. While this work was in progress, external/user activity advanced:

- parent HEAD to `a0cfe640933e1612bd1bc7dd8449e29def7998c5`;
- Wiki HEAD to `a752ac07a18aaf66e0623c6f68110b62d737fd51`;
- plugin HEAD to `dc99986febf1f0911a3ebfdc6d987cc3c0594907`.

This OpenSpec did not create those commits. The plugin's four pre-existing modified paths remain modified:

```text
Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h
Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp
Source/AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp
Source/AngelscriptTest/Shared/AngelscriptTestMacros.h
```

The formerly untracked native-version test is now part of the externally advanced plugin commit. The two pre-existing untracked Wiki images remain present and unmodified by this work. No OpenSpec/Wiki commit or push was requested or performed.
