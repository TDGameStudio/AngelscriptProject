## Context

`AngelscriptTest/HotReload/` is a mature functional suite (EditorContext, Heavy): ChangeClassification (`AnalyzeReloadFromMemory`, 22 `TEST_METHOD`s), property/function/delegate/struct/enum reloads, Blueprint children, PIE, networking, file removal, version chains. Helpers already exist: `CompileAnnotatedModuleFromMemory`, `AnalyzeReloadFromMemory`, `AngelscriptFunctionalTestUtils::CompileScriptModule` / spawn.

The gap is authoring, not analyzer coverage. Almost every case inlines `ScriptV1` / `ScriptV2` via `ASTEST_AS`. `test-as-data-driven-engine-harness` now records a Shared script corpus keyed by `/Angelscript/Memory/TestCorpus/<relative>.as`, and it **forbids** HotReload observations on that COMPLEX engine-profile driver. HotReload still needs the same corpus, plus **same-path new content**, plus ClassGenerator / World assertions that `executeInt` cannot express.

This record is plan-only. Implementation happens later, after `FAngelscriptTestScriptCorpus` exists. Production pipeline ownership and `FReloadState` work live in sibling `refactor-as-hotreload-pipeline`.

## Goals / Non-Goals

**Goals:**

- Move reusable HotReload AngelScript into `Fixtures/HotReload/` as before/after (or v1/v2/v3) files.
- Fetch those files through `FAngelscriptTestScriptCorpus` by a stable TestCorpus virtual path.
- Compile and analyze reloads with **one module + one filename/virtual identity**; only the source text changes.
- Expand the **analyze** matrix (ChangeClassification shape) as COMPLEX leaves under `Angelscript.TestModule.HotReload.Corpus.*`.
- Let existing HotReload CQTest load the same pairs for spawn/reinstance/Blueprint-child work without becoming engine-profile leaves.
- Ship goldens: unchanged module, one soft body-only (or current `SoftReloadRequirement`), one full-reload classification, plus functional property preservation from `AngelscriptHotReloadTests.cpp`.

**Non-Goals:**

- Add `hot-reload` as a profile on `FAngelscriptDataDrivenAutomation` (`vm` / `cache-roundtrip` / JIT).
- Change ClassGenerator / Editor DirectoryWatcher / ClassReloadHelper production behavior.
- Replace or rewrite all ~30 HotReload `.cpp` files in Wave A.
- Migrate PIE, multiplayer PIE, networking, BlueprintImpact, Level Blueprint, file-removal watcher, or literal-asset cases in Wave A.
- Cartesian HotReload pairs against Cache V2 or StaticJIT.
- Merge host `Script/` or `UAngelscriptTestSuite` into this corpus.
- Reimplement CQTest macros. Functional HotReload stays CQTest + `FActorTestSpawner` / `FAngelscriptTestWorld`.
- Name any type `FAngelscriptTestFixture` (engine RAII helper already exists).

## Decisions

### 1. Separate change and separate COMPLEX, same corpus

HotReload is not “another engine profile”. The axis is **edit category → `EReloadRequirement`**, then optionally **instance/Blueprint survival**. That needs ClassGenerator annotated compile, not VM `executeInt`.

```text
FAngelscriptTestScriptCorpus          Shared (harness change)
        │
        ├─ DataDriven engine harness     theme/caseId@profileId   (vm/cache/jit)
        └─ HotReload corpus driver       HotReload/<caseId>       (analyze | functional helper)
```

Copy from DataDriven: handwritten `FAutomationTestBase` (`bInComplexTask = true`), catalog snapshot, command as key, per-leaf session, `GetTestSourceFileName` → primary `.as`, compact driver Info. Do **not** subclass the DataDriven Automation object. Prefix stays under `Angelscript.TestModule.HotReload` so the existing Heavy suite picks it up.

### 2. Pair files, one virtual identity

Physical:

```text
Fixtures/HotReload/ChangeClassification/no-change/before.as
Fixtures/HotReload/ChangeClassification/no-change/after.as
Fixtures/HotReload/Functional/property-preserved/v1.as
Fixtures/HotReload/Functional/property-preserved/v2.as
Fixtures/HotReload/cases.json
```

Canonical compile identity (memory):

```text
/Angelscript/Memory/TestCorpus/HotReload/<caseId>.as
```

`before.as` / `after.as` are **payloads**. `TryGetByVirtualPath` is not enough alone (two texts, one key). The HotReload helper loads both files by relative path, then compiles with `CompileAnnotatedModuleFromMemory` using catalog `module` + `filename` (today’s ClassGenerator contract, e.g. `ReloadNoChangeMod` / `ReloadNoChangeMod.as`). Optionally pass the TestCorpus virtual path as `Filename` only if existing annotated compile already accepts `/Angelscript/Memory/...`; Wave A default is: **keep catalog `filename` as the ClassGenerator section name**, store `virtualPath` on the pair for logs and future `CompileMemorySource`. Do not invent `/Angelscript/Test/`.

Same-content analyze (`no-change`) uses identical before and after files (or the same relative path listed twice).

### 3. Catalog schema (analyze vs functional)

`cases.json` lists explicit cases. No hidden cartesian.

```json
{
  "id": "no-change",
  "kind": "analyze",
  "before": "HotReload/ChangeClassification/no-change/before.as",
  "after": "HotReload/ChangeClassification/no-change/after.as",
  "module": "ReloadNoChangeMod",
  "filename": "ReloadNoChangeMod.as",
  "class": "UReloadNoChangeTarget",
  "expect": {
    "requirement": "SoftReload",
    "wantsFull": false,
    "needsFull": false
  }
}
```

`kind: analyze` → COMPLEX leaf: compile v1 annotated, `AnalyzeReloadFromMemory` v2, `TestEqual` requirement flags. Reuse `AnalyzeReloadFromMemory` / `CompileAnnotatedModuleFromMemory`; do not reimplement ClassGenerator.

`kind: functional` → **not** required to be a COMPLEX leaf in Wave A. CQTest calls `FAngelscriptHotReloadScriptPair::TryLoad` then existing `CompileScriptModule` + spawn + reload + execute. A later wave MAY expand functional kinds through the same COMPLEX if isolation holds.

Forbidden in this catalog: `profiles: ["vm"]`, `engine: shared` as a JIT matrix, `observations: [{ "kind": "executeInt" }]`. Those belong to the engine harness.

### 4. Per-leaf session on the HotReload COMPLEX

Same leak rule as DataDriven: the registered instance holds the pair snapshot only. `RunTest` constructs a short-lived session: acquire shared test engine (`ASTEST_CREATE_ENGINE` / `GetSharedEngine` matching current HotReload tests), `DiscardModule` after, no leftover `UASClass` pointers on the Automation object.

`Parameters` is `HotReload/<caseId>` only. Driver card:

```text
[AS-HR-DRIVER] key=HotReload/no-change kind=analyze module=ReloadNoChangeMod filename=ReloadNoChangeMod.as expect=SoftReload
```

On failure repeat the card in `AddError`. Dump before/after with `[AS-SOURCE-BEGIN]` markers (`before` / `after` labels) when compile or analyze fails.

### 5. Functional tests keep CQTest

Blueprint child, PIE, networking, component reinstancing stay `TEST_CLASS` under the existing HotReload prefix. They MAY load pairs from the corpus. Wave A proves this with property preservation (`Counter` survives, `GetValue` body changes) using files extracted from `AngelscriptHotReloadTests.cpp`, still driven by CQTest + `AngelscriptFunctionalTestUtils`.

Do not require those tests to register an analyze leaf.

### 6. Wave A goldens, not a full migrate

Extract from `AngelscriptHotReloadChangeClassificationTests.cpp` (keep the CQTest methods until dual-run):

| Case id | Source method | Expect |
|---|---|---|
| `no-change` | `NoChange` | SoftReload, not wants/needs full |
| `soft-requirement` | `SoftReloadRequirement` | current asserted requirement |
| `function-removed` | `FunctionRemovedRequiresFullReload` | FullReloadRequired |

Plus functional `property-preserved` from `AngelscriptHotReloadTests.cpp`.

Do not extract the other 19 classification methods until those three leaves dual-run green.

### 7. Disk watcher and Editor DirectoryWatcher are a later slice

`AngelscriptHotReloadFileRemovalTests` and editor watcher timing need an isolated `GetProjectDir` + real files, similar to DataDriven disk mounts. Wave A is memory annotated compile + analyze, plus one in-memory functional reload. Do not claim DirectoryWatcher coverage.

## File map

Create:

- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadScriptPair.h`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadScriptPair.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadScriptPairTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadCorpusAutomation.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadCorpusAutomationTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/README.md`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/cases.json`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/ChangeClassification/no-change/before.as` (after identical)
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/ChangeClassification/soft-requirement/before.as` + `after.as`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/ChangeClassification/function-removed/before.as` + `after.as`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/Functional/property-preserved/v1.as` + `v2.as`

Modify:

- `AngelscriptHotReloadTests.cpp` — property-preserved method loads corpus pair (dual-run with files as source of truth).
- `Documents/UnitTest/UnitTest.md`, `Documents/Guides/Test.md`, `Documents/Guides/TestConventions.md`
- `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/README.md` (pointer to HotReload pairs)
- Chinese-first layering notes at apply time

Do not add a new TestSuiteDefinitions prefix; `Angelscript.TestModule.HotReload` already covers Corpus leaves.

## Data flow

```text
Fixtures/HotReload/**/before.as + after.as
        │
        ▼
FAngelscriptTestScriptCorpus::TryGetByRelativePath
        │
        ▼
FAngelscriptHotReloadScriptPair (module, filename, expect)
        │
        ├─ kind=analyze → COMPLEX GetTests / RunTest
        │     CompileAnnotated v1 → AnalyzeReloadFromMemory v2
        │     AddInfo [AS-HR-DRIVER]
        │
        └─ kind=functional → CQTest
              CompileScriptModule v1 → spawn → reload v2 → assert instance
```

## Risks / Trade-offs

- [Apply order] Corpus API missing → This change SHALL NOT invent a second file reader. Block on harness task 2 (`FAngelscriptTestScriptCorpus`).
- [Filename vs virtual path] ClassGenerator tests today use short `Reload*.as` names → Wave A keeps catalog `filename`; virtual path is the corpus key and log field. Revisit if annotated compile should take TestCorpus paths.
- [Shared engine leak] COMPLEX one instance → per-leaf session + `DiscardModule`, same as current `ON_SCOPE_EXIT`.
- [Expectation drift] Extracted files diverge from remaining CQTest strings → dual-run the three classification methods until retirement.
- [Over-migrate] Moving PIE/net into COMPLEX too early → Wave A goldens only.

## Migration Plan

1. Land pair loader + three analyze goldens + COMPLEX leaves (depends on corpus API).
2. Point `property-preserved` CQTest at functional files.
3. Dual-run existing ChangeClassification methods for those three; do not delete them in the same step.
4. Later: remaining classification rows, then disk-watcher slice, then optional functional COMPLEX.
5. Rollback: do not register the HotReload COMPLEX; CQTest files remain authoritative.

## Open Questions

Resolved in this record:

- Not an engine-harness profile. Separate COMPLEX + CQTest functional helper.
- Wave A does not migrate all classification methods.
- `Parameters` is `HotReload/<caseId>`, not JSON.

Still open until apply:

- Whether annotated compile `Filename` should become the TestCorpus virtual path (inspect `CompileAnnotatedModuleFromMemory` / preprocessor section names).
- Exact `SoftReloadRequirement` expected enum values copied from the current test body (copy, do not invent policy).
