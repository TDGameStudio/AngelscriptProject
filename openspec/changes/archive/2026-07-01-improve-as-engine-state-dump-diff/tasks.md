## 1. Baseline Audit And Test Targets

- [x] 1.1 <!-- Non-TDD --> Record current dump table list and gap map in `openspec/changes/improve-as-engine-state-dump-diff/design.md`.
- [x] 1.2 <!-- TDD --> Add failing CQTest coverage in `Plugins/Angelscript/Source/AngelscriptTest/Dump/AngelscriptStateDumpDiffTests.cpp` for snapshot API presence and deterministic row keys.
- [x] 1.3 <!-- TDD --> Add failing CQTest coverage in `Plugins/Angelscript/Source/AngelscriptTest/Dump/AngelscriptStateDumpDiffTests.cpp` for compile before/after diff rows.
- [x] 1.4 <!-- TDD --> Add failing dump end-to-end assertions in `Plugins/Angelscript/Source/AngelscriptTest/Dump/AngelscriptDumpTests.cpp` for the new snapshot/diff CSV files and `DumpSummary.csv` rows.

## 2. Snapshot Data Model

- [x] 2.1 <!-- TDD --> Create `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateSnapshot.h` with `FAngelscriptStateSnapshot`, `FAngelscriptStateSnapshotRow`, capture options, and stable row-key helpers.
- [x] 2.2 <!-- TDD --> Create `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateSnapshot.cpp` with public FAS engine rows and public `asIScriptEngine` rows only, enough to satisfy the first API-shape tests.
- [x] 2.3 <!-- TDD --> Add deterministic sorting and duplicate-key detection for snapshot rows.
- [x] 2.4 <!-- TDD --> Add CSV serialization helpers for one normalized `EngineStateSnapshot.csv` table.

## 3. Diff Data Model

- [x] 3.1 <!-- TDD --> Create `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDiff.h` with `FAngelscriptStateDiff`, `FAngelscriptStateDiffRow`, and diff options.
- [x] 3.2 <!-- TDD --> Create `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDiff.cpp` with added/removed/changed comparison by `Category + Identity + Field`.
- [x] 3.3 <!-- TDD --> Add `StateDiff.csv` and `StateDiffSummary.csv` serialization.
- [x] 3.4 <!-- TDD --> Verify a synthetic before/after snapshot test reports changed scalar rows and added/removed collection rows.

## 4. FAS Engine Private Coverage

- [x] 4.1 <!-- TDD --> Add a narrow dump-local friend/access helper in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` for snapshot capture.
- [x] 4.2 <!-- TDD --> Capture private `FAngelscriptEngine` containers: `ActiveModules`, `ModulesByScriptModule`, hot-reload state maps/queues, context pool count, interface signatures, static-name caches, script enum lookup, bound Blueprint event argument specializations, diagnostics, and last-emitted diagnostics.
- [x] 4.3 <!-- TDD --> Capture service ownership and mode rows: `TypeDatabase`, `BindState`, `ToStringList`, `BindDatabase`, `BlueprintEventSignatureRegistry`, `LifetimeToken`, `PrecompiledData`, `StaticJIT`, `CodeCoverage`, `DebugServer`, package references, and lifecycle/config flags.
- [x] 4.4 <!-- TDD --> Extend `RuntimeConfig.csv` to include currently missing config flags such as `bSkipInitialCompile` and `bSkipStaticJITCodeGen`.

## 5. AngelScript Internal Coverage

- [x] 5.1 <!-- TDD --> Include dump-local internal adapters for `asCScriptEngine` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateSnapshot.cpp`.
- [x] 5.2 <!-- TDD --> Capture `asCScriptEngine` internal collection counts and rows for registered declarations, script declarations, modules, script sections, type-id map, build/defer flags, message callback state, and GC stats.
- [x] 5.3 <!-- TDD --> Add `asCModule` internal rows for module identity, functions, globals, imports, dependencies, type lists, external declarations, global init state, break/discard flags, and reload state.
- [x] 5.4 <!-- TDD --> Add AS type/function detail rows using `as_typeinfo.h`, `as_objecttype.h`, and `as_scriptfunction.h` where fields are stable enough for diagnostics.
- [x] 5.5 <!-- TDD --> Split optional category-specific CSV outputs: `EngineMemberState.csv`, `EngineCollections.csv`, `AsEngineInternalState.csv`, `AsModuleInternalState.csv`, `AsTypeInternalState.csv`, and `AsFunctionInternalState.csv`.

## 6. Dump API And Command Wiring

- [x] 6.1 <!-- TDD --> Extend `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h` with `CaptureSnapshot`, `DiffSnapshots`, `DumpSnapshot`, and `DumpDiff`.
- [x] 6.2 <!-- TDD --> Wire `DumpAll()` to capture and write snapshot tables without changing existing table semantics.
- [x] 6.3 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptDumpCommand.cpp` help text to mention upgraded snapshot tables.
- [x] 6.4 <!-- TDD --> Keep `as.DumpEngineState [OutputDir]` backward compatible; defer extra command flags unless tests or manual workflow require them.

## 7. Compiler Event Diagnostic Logging

- [x] 7.1 <!-- TDD --> Add a shared test helper under `Plugins/Angelscript/Source/AngelscriptTest/Dump/` or `Plugins/Angelscript/Source/AngelscriptTest/Shared/` for before/after snapshot capture, diff dump, and artifact path logging.
- [x] 7.2 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerEventsTests.cpp` to use the shared helper when validating compile result impact.
- [x] 7.3 <!-- TDD --> Assert that compiler-event diagnostics include FAS active-module impact and AS engine/module internal impact rows.
- [x] 7.4 <!-- TDD --> Ensure the test cleans up compiled modules through existing `FScopedAngelscriptModule` or explicit discard paths.

## 8. Documentation And Verification

- [x] 8.1 <!-- Non-TDD --> Update `Documents/Guides/TestCatalog.md` with the new dump/diff tests.
- [x] 8.2 <!-- Non-TDD --> Update dump documentation references in `AGENTS.md` or related guides if command output expectations change.
- [x] 8.3 <!-- Non-TDD --> Run `openspec validate improve-as-engine-state-dump-diff --strict --json`.
- [x] 8.4 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label engine-state-dump-diff -TimeoutMs 600000`.
- [x] 8.5 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler.Events" -Label compiler-events-state-diff -TimeoutMs 600000`.
- [x] 8.6 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label engine-state-dump-diff -TimeoutMs 900000 -NoXGE` because the implementation will add runtime headers and include private AS internals.
