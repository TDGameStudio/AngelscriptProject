## Why

HotReload tests already cover a real decision surface (`AnalyzeReloadFromMemory`, ClassGenerator soft/full reload, Blueprint children, PIE), but each case still owns inline `ASTEST_AS` v1/v2 strings. That is the same authoring trap as the engine-matrix tests: the AngelScript is trapped in C++, so it cannot be fetched by virtual path, reused by World/functional helpers, or expanded as independently selectable leaves. The data-driven engine harness explicitly must **not** grow HotReload observations; this change is the separate HotReload corpus and driver. Direction id: `reload-generation` (`docs-as-test-direction-map`).

## What Changes

- Store HotReload **before/after** (and short sequences) as authored files under `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/`, queried through Shared `FAngelscriptTestScriptCorpus` by a **stable TestCorpus virtual path**. Before and after are two files; compile/reload uses **one** virtual path / module identity with swapped content.
- Add a HotReload-owned pair/catalog API (`FAngelscriptHotReloadScriptPair`) so CQTest functional tests can load a scenario without inlining source and without becoming DataDriven engine-profile leaves.
- Add a **second** handwritten COMPLEX `FAutomationTestBase` under `AngelscriptTest/HotReload/` that expands **analyze** catalog rows into `Angelscript.TestModule.HotReload.Corpus.*` leaves. Copy the DataDriven expansion mechanism (snapshot `GetTests`, command as key, per-leaf session, `[AS-HR-DRIVER]` card). Do not reuse `FAngelscriptDataDrivenAutomation`, do not list `vm` / `cache-roundtrip` / JIT profiles, do not call `FBridge`.
- Keep existing `Angelscript.TestModule.HotReload.*` CQTest until dual-run. Wave A extracts a few ChangeClassification goldens plus one functional property-preservation case. Do not migrate PIE, networking, BlueprintImpact, file-removal watcher, or all 22 classification methods in the first wave.
- Depends on `test-as-data-driven-engine-harness` Decision 16 (`FAngelscriptTestScriptCorpus`). Apply this change after that corpus lookup API exists. Plan-only in this recording session.

## Capabilities

### New Capabilities

- `as-hotreload-script-corpus`: Before/after fixture layout, TestCorpus virtual-path identity for reload, catalog fields (module, filename, expected `EReloadRequirement`), and the rule that HotReload C++ tests do not own reusable pair source.
- `as-hotreload-corpus-driver`: COMPLEX analyze-matrix expansion, per-leaf session, driver card, functional pair helper for CQTest spawn/reinstance, gating, and the boundary against the engine-profile DataDriven harness.

### Modified Capabilities

- None. Existing `hotreload-test-coverage` / `as-hotreload-property-coverage` requirements stay. This change adds an authoring and expansion layer; it does not change ClassGenerator reload policy.

## Impact

- Future sources under `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/` and `Plugins/Angelscript/Source/AngelscriptTest/HotReload/` (corpus helper + COMPLEX bridge). Pair lookup uses Shared `AngelscriptTestScriptCorpus`.
- Dual-repo: OpenSpec in the parent, implementation in `Plugins/Angelscript`, then parent gitlink.
- Automation prefix `Angelscript.TestModule.HotReload.Corpus.*` (covered by existing Heavy `HotReload` suite prefix `Angelscript.TestModule.HotReload`).
- Docs: `Documents/UnitTest/UnitTest.md`, `Documents/Guides/Test.md`, `Documents/Guides/TestConventions.md`, `Fixtures/README.md` / HotReload README, Chinese-first `AGENTS_ZH.md` / Test layering notes at apply time.
- Sibling: `test-as-data-driven-engine-harness` remains the engine-profile matrix (VM/cache/JIT). `refactor-as-hotreload-pipeline` is the production pipeline map (ownership, `FReloadState`, helper includes). This change owns HotReload **test pairs** only. Host `Script/` teaching corpus stays a third tree.
