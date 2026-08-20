# HotReload Script Corpus Implementation Plan

> Plan-only record. Do not implement in the recording session. **Apply after** `test-as-data-driven-engine-harness` task 2 (`FAngelscriptTestScriptCorpus`) is green. Dual-repo: implement in `Plugins/Angelscript`, then parent gitlink.

**Goal:** Extract HotReload before/after AngelScript into the Shared test corpus, expand analyze pairs as COMPLEX `Angelscript.TestModule.HotReload.Corpus.*` leaves, and let functional CQTest load the same pairs — without putting HotReload on the engine-profile DataDriven harness.

**Architecture:** `Fixtures/HotReload/` pair files + `cases.json` + `FAngelscriptHotReloadScriptPair` + handwritten COMPLEX (snapshot, key command, per-leaf session, `[AS-HR-DRIVER]`). Analyze uses existing `CompileAnnotatedModuleFromMemory` / `AnalyzeReloadFromMemory`. Functional spawn stays CQTest + `AngelscriptFunctionalTestUtils`.

**Tech stack:** UE 5.7 COMPLEX `FAutomationTestBase` (`bInComplexTask = true`), existing HotReload EditorContext flags, `WITH_ANGELSCRIPT_UNITTESTS`.

**Spec:** `specs/as-hotreload-script-corpus/spec.md`, `specs/as-hotreload-corpus-driver/spec.md`.

## Global Constraints

- Blocked on `FAngelscriptTestScriptCorpus::TryGetByRelativePath`. Do not add a second Fixtures file reader.
- Do not add HotReload as a DataDriven engine profile (`vm` / cache / JIT).
- Do not change ClassGenerator reload policy; copy expected flags from existing tests.
- New tests start with `Angelscript` and live under `AngelscriptTest/HotReload/` or `Fixtures/HotReload/`.
- Verify only through `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`.
- Gate new Automation registration with `WITH_ANGELSCRIPT_UNITTESTS`.
- `Parameters` is `HotReload/<caseId>`. No JSON / `@file` in `OutTestCommands`.
- Do not migrate PIE, networking, BlueprintImpact, file-removal watcher, or the remaining 19 ChangeClassification methods in Wave A.
- Do not use `IMPLEMENT_COMPLEX_AUTOMATION_TEST`. Do not subclass `FAngelscriptDataDrivenAutomation`.
- Chinese-first docs at apply time (`AGENTS_ZH.md` / Test layering ZH).

---

## 1. Pair catalog parse (depends on script corpus)

- [ ] 1.1 <!-- Non-TDD --> Confirm `FAngelscriptTestScriptCorpus` exists and `Angelscript.TestModule.DataDriven.Fixtures` is green. If not, stop and finish `test-as-data-driven-engine-harness` task 2.
- [ ] 1.2 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadScriptPairTests.cpp`, prefix `Angelscript.TestModule.HotReload.Corpus.Catalog`, gated by `WITH_ANGELSCRIPT_UNITTESTS`. Failing cases: valid `no-change` JSON (same before/after relative path allowed); missing `after`; `..` in paths; `/Angelscript/Game/` virtual path rejected; `kind` neither `analyze` nor `functional` rejected; `profiles` / engine-profile ids in JSON rejected; analyze case missing `expect.requirement` rejected.
- [ ] 1.3 <!-- TDD --> Implement `AngelscriptHotReloadScriptPair.h/.cpp` with `FAngelscriptHotReloadExpect` (`Requirement`, `bWantsFullReload`, `bNeedsFullReload`), `FAngelscriptHotReloadScriptPair` (`Id`, `Kind`, `BeforeRelative`, `AfterRelative`, `Module`, `Filename`, `ClassName`, `VirtualPath`, `Expect`), and `TryLoadCatalog` / `TryLoadPair` that resolve source via `FAngelscriptTestScriptCorpus::TryGetByRelativePath`. `MakeVirtualPath(caseId)` → `/Angelscript/Memory/TestCorpus/HotReload/<caseId>.as`.
- [ ] 1.4 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label hotreload-corpus-catalog -TimeoutMs 1800000 -NoXGE` then `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus.Catalog" -Label hotreload-corpus-catalog -TimeoutMs 600000`. Require zero failures.

## 2. Authored goldens

- [ ] 2.1 <!-- Non-TDD --> Add `Fixtures/HotReload/ChangeClassification/no-change/before.as` copied from `AngelscriptHotReloadChangeClassificationTests.cpp` `NoChange` (`UReloadNoChangeTarget`). `after.as` MAY be the same file listed twice in JSON or an identical copy.
- [ ] 2.2 <!-- Non-TDD --> Add `soft-requirement` before/after from `SoftReloadRequirement` (`GetValue` returns 1 then 2). Expect SoftReload, wantsFull=false, needsFull=false. Module/filename from that test (`ReloadSoftRequirementMod`).
- [ ] 2.3 <!-- Non-TDD --> Add `function-removed` before/after from `FunctionRemovedRequiresFullReload`. Expect FullReloadRequired, wantsFull=true, needsFull=true. Keep that test's module `HotReloadChangeClassificationFunctionRemoved` and filename `HotReloadChangeClassificationFunctionRemoved.as`.
- [ ] 2.4 <!-- Non-TDD --> Add `Fixtures/HotReload/Functional/property-preserved/v1.as` and `v2.as` from `AngelscriptHotReloadTests.cpp` property-preserved (`ATestHotReloadPropertyPreserved`, Counter + GetValue).
- [ ] 2.5 <!-- Non-TDD --> Add `Fixtures/HotReload/cases.json` listing the three analyze cases and one functional case (`kind: functional`, no COMPLEX requirement for Wave A). Add `Fixtures/HotReload/README.md` (pair layout, virtual path, not engine profiles, not host `Script/`).
- [ ] 2.6 <!-- TDD --> Extend pair tests to load the real goldens from `GetRoot()` and assert `no-change` sources compile-identity fields. Re-run prefix `Angelscript.TestModule.HotReload.Corpus.Catalog`.

## 3. COMPLEX analyze driver

- [ ] 3.1 <!-- TDD --> Add `AngelscriptHotReloadCorpusAutomationTests.cpp`, prefix `Angelscript.TestModule.HotReload.Corpus.Automation`. Failing cases: `GetTests` emits beautified `Angelscript.TestModule.HotReload.Corpus.no-change`; command `HotReload/no-change`; command is not JSON; `GetTestSourceFileName` returns the no-change before `.as`; gating macro present; two sequential `RunTest` calls do not leave engine/module pointers on the COMPLEX object.
- [ ] 3.2 <!-- TDD --> Implement handwritten `AngelscriptHotReloadCorpusAutomation.cpp` as COMPLEX `FAutomationTestBase`. Snapshot analyze cases only. `RunTest` constructs a session: shared test engine (same as current HotReload tests), `CompileAnnotatedModuleFromMemory` v1, `AnalyzeReloadFromMemory` v2, `TestEqual` expect flags, `DiscardModule`, `AddInfo` `[AS-HR-DRIVER]`. Failures dump before/after with `[AS-SOURCE-BEGIN]`. Do not call DataDriven `RunCase`. Do not use `IMPLEMENT_COMPLEX_AUTOMATION_TEST`.
- [ ] 3.3 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus.no-change" -Label hotreload-corpus-no-change -TimeoutMs 600000`. Require pass.
- [ ] 3.4 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus.soft-requirement" -Label hotreload-corpus-soft -TimeoutMs 600000` and `-TestPrefix "Angelscript.TestModule.HotReload.Corpus.function-removed" -Label hotreload-corpus-fn-removed -TimeoutMs 600000`. Require pass. Copy flags from the existing methods; do not invent policy.

## 4. Functional CQTest consumes corpus

- [ ] 4.1 <!-- TDD --> Change the property-preserved path in `AngelscriptHotReloadTests.cpp` to `FAngelscriptHotReloadScriptPair::TryLoad("property-preserved")` (or relative paths) instead of inline `ScriptV1`/`ScriptV2`. Keep spawn / BeginPlay / property asserts. Failing test first if the method is rewritten behind a helper: helper returns empty until files load.
- [ ] 4.2 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label hotreload-property-preserved-corpus -TimeoutMs 600000` is too wide; prefer the existing method name prefix if stable, otherwise run `Angelscript.TestModule.HotReload` with timeout 1200000 and require the property-preserved method pass. Record the exact prefix used in `verification.md`.
- [ ] 4.3 <!-- TDD --> Dual-run ChangeClassification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ChangeClassification.NoChange" -Label hotreload-class-no-change -TimeoutMs 600000` plus `SoftReloadRequirement` and `FunctionRemovedRequiresFullReload`. All three SHALL still pass. Do not delete those `TEST_METHOD`s.

## 5. Docs and suite closure

- [ ] 5.1 <!-- Non-TDD --> Update `Documents/UnitTest/UnitTest.md` (ZH first if the Chinese guide is the layering source): HotReload pairs vs DataDriven engine profiles vs `UAngelscriptTestSuite`; prefix `Angelscript.TestModule.HotReload.Corpus`; `[AS-HR-DRIVER]`; apply order after script corpus.
- [ ] 5.2 <!-- Non-TDD --> Update `Documents/Guides/Test.md`, `Documents/Guides/TestConventions.md`, `Fixtures/README.md`, `Shared/README.md`. Point HotReload authors at `Fixtures/HotReload/`. State DirectoryWatcher/PIE are not Wave A.
- [ ] 5.3 <!-- Non-TDD --> Do **not** add a new suite name; confirm `TestSuiteDefinitions.ps1` `HotReload` prefix already covers `Angelscript.TestModule.HotReload.Corpus`.
- [ ] 5.4 <!-- TDD --> `Tools\RunBuild.ps1 -Label hotreload-corpus-closure -TimeoutMs 1800000 -NoXGE` then `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Corpus" -Label hotreload-corpus-all -TimeoutMs 600000`. Record counts in this change `verification.md`.
- [ ] 5.5 <!-- TDD --> `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ChangeClassification" -Label hotreload-classification-dual -TimeoutMs 600000`. Require zero failures.
- [ ] 5.6 <!-- Non-TDD --> Commit submodule first, then parent gitlink + OpenSpec. Do not commit unless the user asks.

## 6. Later (not Wave A)

- [ ] 6.1 <!-- Non-TDD --> Remaining 19 ChangeClassification methods → pair files + catalog rows after 5.4 is green. Dual-run then retire `TEST_METHOD`s one by one.
- [ ] 6.2 <!-- Non-TDD --> Isolated disk mount + DirectoryWatcher file-removal slice (`AngelscriptHotReloadFileRemovalTests`). Same corpus identity, physical overwrite under temp `Script/`.
- [ ] 6.3 <!-- Non-TDD --> Optional COMPLEX expansion of `kind: functional` if session isolation is proven. PIE/net/BlueprintImpact stay CQTest unless a later change says otherwise.
