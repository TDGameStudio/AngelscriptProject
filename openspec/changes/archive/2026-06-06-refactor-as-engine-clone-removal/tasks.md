# Tasks: refactor-as-engine-clone-removal

> Verification commands follow project standards (`Documents/Guides/Build.md`,
> `Documents/Guides/Test.md`): builds run via `Tools\RunBuild.ps1`, tests via
> `Tools\RunTests.ps1`. Both scripts are invoked through PowerShell with
> `-NoProfile -ExecutionPolicy Bypass` and an explicit `-TimeoutMs` ≤ `3600000`.
> A whole-project build is the smallest unit of `RunBuild.ps1` work — there is
> no `-Target` / `-Action` flag.

## 1. Create FAngelscriptTestEngine

- [x] 1.1 <!-- Non-TDD --> Create `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.h` with struct definition inheriting `FAngelscriptEngine`. Declare `ResetModules()`, `FullReset()`, `Create()`, `GetSharedEngine()`, `DestroySharedEngine()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.1-test-engine-header -TimeoutMs 600000 -NoXGE`

- [x] 1.2 <!-- Non-TDD --> Create `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.cpp` implementing `ResetModules()` (discard all modules, GC), `FullReset()` (discard modules + clear generated types), `GetSharedEngine()` (lazy singleton), `DestroySharedEngine()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.2-test-engine-impl -TimeoutMs 900000 -NoXGE`

- [x] 1.3 <!-- Non-TDD --> Change required `FAngelscriptEngine` members from `private` to `protected` to enable subclass access (Modules map, Engine pointer, SharedState pointer). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.3-protected-access -TimeoutMs 600000 -NoXGE`

## 2. Migrate Test Infrastructure

- [x] 2.1 <!-- Non-TDD --> Update `AngelscriptTestMacros.h` to route `ASTEST_CREATE_ENGINE`, `ASTEST_GET_ENGINE`, `ASTEST_RESET_ENGINE` through `FAngelscriptTestEngine` APIs. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.1-macro-routing -TimeoutMs 600000 -NoXGE`

- [x] 2.2 <!-- Non-TDD --> Update `AngelscriptTestUtilities.h`: replace `GetOrCreateSharedCloneEngine()` and `AcquireCleanSharedCloneEngine()` implementations to delegate to `FAngelscriptTestEngine::GetSharedEngine()`. The single `CreateCloneFrom` call at line 178 is replaced here. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.2-utilities -TimeoutMs 600000 -NoXGE`

- [x] 2.3 <!-- Non-TDD --> Replace the 14 remaining `CreateCloneFrom` call sites in test sources with `FAngelscriptTestEngine::Create()` or `GetSharedEngine()` as appropriate: 4 in `Core/AngelscriptEngineIsolationTests.cpp` (lines 120, 155, 287, 914), 9 in `Core/AngelscriptMultiEngineLifecycleTests.cpp` (lines 104, 105, 137, 169, 204, 226, 381, 488, 489), 1 in `Core/AngelscriptEnginePerformanceTests.cpp` (line 160). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine" -Label clone-removal-2.3-migration-smoke -TimeoutMs 900000`

- [x] 2.4 <!-- Non-TDD --> Update `AngelscriptTestEnginePool.h` to use `FAngelscriptTestEngine` instead of Clone-based pooling. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.MultiEngine" -Label clone-removal-2.4-pool -TimeoutMs 900000`

- [x] 2.5 <!-- Non-TDD --> Replace remaining `EAngelscriptEngineCreationMode` token usages in test sources whose target behaviour is Full or pure isolation (non-`CreateCloneFrom` sites): `Functional/Types/AngelscriptTypeTests.cpp` lines 372/389/423/438 (Full × 4 via `CreateScriptScanFreeEngineForTesting`), `AngelScriptSDK/AngelscriptContextPoolTests.cpp` lines 87/91 (Full × 2), `Core/AngelscriptEnginePerformanceTests.cpp` lines 173/190 (Clone × 2 — promote to Full per user decision since Clone semantics are gone). Drop the enum argument; the helper signature change in 2.7 should make these mechanical. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.5-enum-tokens -TimeoutMs 900000 -NoXGE`

- [x] 2.6 <!-- Non-TDD --> Replace 9 `CreateUncompiledWithMode` call sites with `FAngelscriptEngine::CreateUncompiled(Config, Dependencies)` (the existing Full-only uncompiled factory at `AngelscriptEngine.h:128` / `AngelscriptEngine.cpp:763`). Sites: `Core/AngelscriptEngineDependencyInjectionTests.cpp` lines 58/104/154/205 (default-mode → Full), `Core/AngelscriptMultiEngineLifecycleTests.cpp` lines 279/314/406/415/446 (mixed Full/Clone → all Full). Test bodies that asserted on `GetCreationMode()` after these calls have their assertions removed in 4.5. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.6-uncompiled-with-mode -TimeoutMs 900000 -NoXGE`

- [x] 2.7 <!-- Non-TDD --> Refactor `AngelscriptTest/Shared/AngelscriptTestUtilities.h::CreateScriptScanFreeEngineForTesting` (line 166-) to drop the `EAngelscriptEngineCreationMode Mode` parameter and dispatch internally to `FAngelscriptEngine::CreateUncompiled` (or `FAngelscriptTestEngine::Create` once introduced). Update all call sites to drop the trailing enum argument. This task may be ordered before 2.5 since 2.5 depends on the new signature. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.7-helper-signature -TimeoutMs 900000 -NoXGE`

## 3. Remove Clone from Runtime

- [x] 3.1 <!-- Non-TDD --> Delete `EAngelscriptEngineCreationMode` enum from `AngelscriptEngine.h`. Remove `CreateCloneFrom()` declarations (both overloads at lines 129-130). Remove `CreateUncompiledWithMode()` (only callers are test code that already migrated in Phase 2). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.1-api-delete -TimeoutMs 900000 -NoXGE`

- [x] 3.2 <!-- Non-TDD --> Remove Clone-related members from `FAngelscriptEngine`: `CreationMode`, `SourceEngine`, `InstanceId`, `bOwnsEngine`. Remove `MakeModuleName()` Clone branch. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.2-members -TimeoutMs 900000 -NoXGE`

- [x] 3.3 <!-- Non-TDD --> Delete `CreateCloneFrom()` and `AdoptSharedStateFrom()` implementations from `AngelscriptEngine.cpp`. The single internal forwarder at `AngelscriptEngine.cpp:811` (`CreateUncompiledWithMode` → `CreateCloneFrom`) is removed alongside its caller in 3.1. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.3-impl-delete -TimeoutMs 900000 -NoXGE`

- [x] 3.4 <!-- Non-TDD --> Simplify `Shutdown()`: remove `bPendingOwnerRelease` checks, `ActiveCloneCount` waiting logic, deferred-release branches. Direct call to `ReleaseOwnedSharedStateResources()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.4-shutdown -TimeoutMs 900000 -NoXGE`

- [x] 3.5 <!-- Non-TDD --> Drop the `GetCreationModeString` helper and the `CreationMode` column from `Dump/AngelscriptStateDump.cpp` (lines 67-78 plus the call sites that emit it, around line 344 and the EngineOverview header/row at lines 315-317; also drop the redundant `OwnsEngine` and `SourceEngineId` columns now that those concepts are gone). Update any matching CSV header / `Dump/` test fixtures so the columns disappear cleanly. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label clone-removal-3.5-dump-cleanup -TimeoutMs 600000`

- [x] 3.6 <!-- Non-TDD --> Delete the inline accessors that referenced removed fields: `GetCreationMode` (`AngelscriptEngine.h:203`), `GetSourceEngine` (`h:205-208`), `GetInstanceId` (`h:209`). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.6-accessors -TimeoutMs 900000 -NoXGE`

## 4. Simplify FAngelscriptOwnedSharedState

- [x] 4.1 <!-- Non-TDD --> Remove `ActiveParticipants`, `ActiveCloneCount`, `bPendingOwnerRelease`, `bReleased` from `FAngelscriptOwnedSharedState`. Remove the `GetActiveParticipantsForTesting()` / `GetActiveCloneCountForTesting()` accessors and any tests that referenced them. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.1-shared-state-fields -TimeoutMs 900000 -NoXGE`

- [x] 4.2 <!-- Non-TDD --> Change `TSharedPtr<FAngelscriptOwnedSharedState>` to `TUniquePtr<FAngelscriptOwnedSharedState>` in `FAngelscriptEngine`. Update all usages. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.2-uniqueptr -TimeoutMs 900000 -NoXGE`

- [x] 4.3 <!-- Non-TDD --> Simplify `ReleaseOwnedSharedStateResources()`: remove double-release guard (`bReleased` check), remove participant tracking. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.3-release -TimeoutMs 900000 -NoXGE`

- [x] 4.4 <!-- Non-TDD --> Delete the `FAngelscriptMultiEngineTestAccess` helper class (`Core/AngelscriptMultiEngineLifecycleTests.cpp` lines 51-58) and the `ParticipantCountsTrackFullAndClones` test (lines 477-501). The mechanism they validate — `ActiveParticipants` / `ActiveCloneCount` reference counting — is removed in 4.1, so these have no remaining target. In place of the deleted test, add a new `ASTest.Engine.TestEngine.SharedStateReleaseIsImmediate` test in the new `AngelscriptTestEngine.cpp` that asserts the single-owner contract: when an engine is destroyed, its `FAngelscriptOwnedSharedState` releases without deferred coordination. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.MultiEngine" -Label clone-removal-4.4-shared-state-tests -TimeoutMs 900000`

- [x] 4.5 <!-- Non-TDD --> Rewrite `RunCloneHonorsInjectedDependencies` (`Core/AngelscriptMultiEngineLifecycleTests.cpp` around line 314) to a new test `RunMultipleFullEnginesHaveIndependentDependencies`: create two independent `FAngelscriptEngine::CreateUncompiled` engines with different injected `DirectoryExists` / `MakeDirectory` callbacks and assert that each engine sees its own dependencies. Also clean up `Core/AngelscriptCoreExecutionTests.cpp` lines 252-253 (the `GetCreationMode()` round-trip assertions) and lines 295/330/352 (Clone branch) — keep the Full path assertions, drop the Clone branch + `GetCreationMode()` checks. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests" -Label clone-removal-4.5-multi-engine-rewrite -TimeoutMs 1200000`

- [x] 4.6 <!-- Non-TDD --> Trim `Core/AngelscriptEngineLifecycleModeTests.cpp` to its still-meaningful content: delete the Clone vs. Full dispatch cases (lines 72-78, 89-95) and any `GetCreationMode()`-based assertions; keep any pure Full-engine lifecycle assertions that survive. If after trimming the file has no remaining tests, delete the file and remove its entry from `AngelscriptTest.Build.cs`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests" -Label clone-removal-4.6-lifecycle-mode-tests -TimeoutMs 900000`

## 5. Full Validation

- [x] 5.1 <!-- Non-TDD --> Whole-project build (no `-NoXGE`, full link). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-5.1-full-build -TimeoutMs 1800000`

- [x] 5.2 <!-- Non-TDD --> Run the smoke + RuntimeCpp + Bindings suites (catches engine lifecycle, multi-engine, dependency injection, and binding regressions). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke,RuntimeCpp,Bindings -Label clone-removal-5.2-regression -TimeoutMs 2400000`

- [x] 5.3 <!-- Non-TDD --> Run the bind/free regression family added in commit `91ac208` to confirm no memory leaks or cross-cycle accumulation. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Memory" -Label clone-removal-5.3-bind-free -TimeoutMs 900000`

- [x] 5.4 <!-- Non-TDD --> Confirm `AngelscriptRuntime` no longer references any Clone-mode symbol after the migration. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Select-String -Path 'Plugins/Angelscript/Source/AngelscriptRuntime/**/*.cpp','Plugins/Angelscript/Source/AngelscriptRuntime/**/*.h' -Pattern 'EAngelscriptEngineCreationMode|CreateCloneFrom|ActiveCloneCount|ActiveParticipants|bPendingOwnerRelease' -SimpleMatch:$false | ForEach-Object { $_.Path + ':' + $_.LineNumber } | Sort-Object -Unique"` (expected: empty output).

- [x] 5.5 <!-- Non-TDD --> Run `openspec validate refactor-as-engine-clone-removal --strict --json` from the project root and confirm the change passes. The change is then ready for `openspec archive`.

## 6. Inline FAngelscriptOwnedSharedState into FAngelscriptEngine

> Tail of the clone-removal cleanup (see design D7). With Clone gone the struct
> exists only as pure indirection; flattening removes 5 duplicate fields, 30+
> `SharedState->X` accesses, and 3 helper functions
> (`EnsureSharedStateCreated`, `InitializeOwnedSharedState`,
> `ReleaseOwnedSharedStateResources`). Single Section, single build verification
> at the end — no public API changes, internal refactor only.

- [x] 6.1 <!-- Non-TDD --> Move the 7 owned data members of `FAngelscriptOwnedSharedState` onto `FAngelscriptEngine` as private fields (preserving forward-declared `TUniquePtr<...>` pattern; the `~FAngelscriptEngine()` definition already lives in `.cpp` so the unique-ptr destructor is well-formed): `TUniquePtr<FAngelscriptTypeDatabase> TypeDatabase`, `TUniquePtr<FAngelscriptBindState> BindState`, `TUniquePtr<TArray<FToStringType>> ToStringList`, `TUniquePtr<FAngelscriptBindDatabase> BindDatabase`, `TUniquePtr<FBlueprintEventSignatureRegistry> BlueprintEventSignatureRegistry`, `TArray<FName> StaticNames`, `TMap<FName, int32> StaticNamesByIndex`. Update the 5 `Get*()` accessors (`GetTypeDatabase`, `GetBindState`, `GetToStringList`, `GetBindDatabase`, `GetBlueprintEventSignatureRegistry`) to return `Field.Get()` directly (no `SharedState.IsValid()` guard — pre-init `TUniquePtr<>::Get()` returns nullptr, identical observable behavior). Update the static-name globals routing in `GetOrAddStaticName` / `ReserveStaticNames` / `ResetStaticNames` / `AddStaticNameFromPrecompiled` / `GetStaticNames` (cpp:1213, 1241, 1257, 1273, 1290) to use `CurrentEngine->StaticNames` / `CurrentEngine->StaticNamesByIndex` directly.

- [x] 6.2 <!-- Non-TDD --> Delete the 5 duplicate mirror fields from `FAngelscriptOwnedSharedState`: `ScriptEngine` (mirrors `FAngelscriptEngine::Engine`), `PrimaryContext` (mirrors `GameThreadTLD->primaryContext`), `PrecompiledData` / `StaticJIT` / `DebugServer` (each mirrors a same-named field already on `FAngelscriptEngine`). Delete the 4 dual-ownership safety guards in `Shutdown()` (cpp:1426/1433/1439/1445 — the `(LocalSharedState == nullptr || LocalSharedState->X == nullptr)` clauses) since both sides of the OR are now always equivalent; replace each with the simple `if (X != nullptr) { delete X; X = nullptr; }` form.

- [x] 6.3 <!-- Non-TDD --> Inline `EnsureSharedStateCreated()` (cpp:1153) into its single caller `Initialize` (cpp:985): replace with direct `MakeUnique` calls on the 7 fields. Inline `InitializeOwnedSharedState()` (cpp:1002) into its single caller `Initialize` (cpp:992): with the 5 mirror fields gone the function becomes a no-op and is deleted outright. Delete both function declarations from `AngelscriptEngine.h` (lines 352, 545).

- [x] 6.4 <!-- Non-TDD --> Delete the free-function helper `ReleaseOwnedSharedStateResources` (cpp:440-) and fold its body into `Shutdown()`: directly destroy/release the engine's own pointer fields (`DebugServer`, `StaticJIT`, `PrecompiledData`, plus the GameThreadTLD primary context release, plus the type/bind/registry `Reset()` calls). Drop the `LocalSharedState` local in `Shutdown()` and the final `SharedState.Reset()` (cpp:1570).

- [x] 6.5 <!-- Non-TDD --> Delete the `FAngelscriptOwnedSharedState` struct definition (cpp:259-) and its forward declaration (h:51). Delete the `SharedState` field on `FAngelscriptEngine` (h:425). Verify a clean grep returns no remaining references to the struct name in `Plugins/Angelscript/Source/AngelscriptRuntime/`.

- [x] 6.6 <!-- Non-TDD --> Comment cleanup in `Bind_BlueprintEvent.cpp:537-553` and `BlueprintEventSignatureRegistry.h:15`: replace the `EnsureSharedStateCreated()` and `SharedState->BlueprintEventSignatureRegistry.Reset()` references in the explanatory comments with the new direct-field equivalents (`Initialize() now allocates BlueprintEventSignatureRegistry inline`, `Engine->BlueprintEventSignatureRegistry.Reset()`).

- [x] 6.7 <!-- Non-TDD --> Build the whole project and run the engine + multi-engine + test-engine prefixes to confirm no behavioral regression. Verify (one command, sequential):
  ```
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-6.7-flatten-build -TimeoutMs 900000 -NoXGE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label clone-removal-6.7-flatten-engine-tests -TimeoutMs 1200000
  ```

## 7. Collapse Create / CreateUncompiled into single Create factory

> Tail of the clone-removal cleanup (see design D8). Phase 2's migration of
> `CreateUncompiledWithMode → CreateUncompiled` left two near-identical static
> factories on `FAngelscriptEngine`. Phase 7 routes the "skip initial compile"
> behavior through a new `FAngelscriptEngineConfig::bSkipInitialCompile` flag,
> migrates the ~47 direct callers, and deletes `CreateUncompiled`. No further
> public-API surface changes after this section.

- [x] 7.1 <!-- Non-TDD --> Add `bool bSkipInitialCompile = false;` to `FAngelscriptEngineConfig` in `AngelscriptRuntime/Core/AngelscriptEngine.h`. The default reflects the production path (full Initialize). Place the field next to the other initialization toggles (`bSkipThreadedInitialize`, `bForceThreadedInitialize`). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-7.1-config-flag -TimeoutMs 900000 -NoXGE`

- [x] 7.2 <!-- Non-TDD --> Rewrite `FAngelscriptEngine::Create(Config, Dependencies)` in `AngelscriptEngine.cpp` to dispatch on `Config.bSkipInitialCompile`: when `true`, call `Engine->InitializeWithoutInitialCompile()`; when `false`, call `Engine->Initialize()`. Keep the existing `MakeUnique<FAngelscriptEngine>(Config, Deps)` construction and the `UE_LOG(... CreateUncompiled -> %p ...)` line, retitled to `Create -> %p`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-7.2-create-dispatch -TimeoutMs 900000 -NoXGE`

- [x] 7.3 <!-- Non-TDD --> Update `FAngelscriptTestEngine::Create(Config, Dependencies)` in `AngelscriptTest/Shared/AngelscriptTestEngine.cpp`: copy the incoming `FAngelscriptEngineConfig`, set `LocalConfig.bSkipInitialCompile = true;`, then delegate to `FAngelscriptEngine::Create(LocalConfig, Dependencies)`. The wrapper preserves the test-module ergonomics (test code keeps calling `FAngelscriptTestEngine::Create(...)` without ever touching the flag). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.TestEngine" -Label clone-removal-7.3-test-engine-wrapper -TimeoutMs 600000`

- [x] 7.4 <!-- Non-TDD --> Migrate the 33 `FAngelscriptEngine::CreateUncompiled` call sites in `AngelscriptTest/Core/*` and `AngelscriptTest/Functional/*` to `FAngelscriptTestEngine::Create`: 22 in `AngelscriptEngineIsolationTests.cpp`, 5 in `AngelscriptMultiEngineLifecycleTests.cpp`, 5 in `AngelscriptEngineDependencyInjectionTests.cpp`, plus the 1 existing direct `FAngelscriptEngine::Create` caller (`AngelscriptEngineDependencyInjectionTests.cpp`) which gets re-routed through the wrapper. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label clone-removal-7.4-test-core-migration -TimeoutMs 1200000`

- [x] 7.5 <!-- Non-TDD --> Migrate the 2 wrapper sites in `AngelscriptTest/Shared/AngelscriptTestUtilities.h` (and any sibling `AngelscriptTestEngineHelper.h` callers) to `FAngelscriptTestEngine::Create`. These are the test wrappers themselves — they should not call the runtime factory directly. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label clone-removal-7.5-test-shared-migration -TimeoutMs 900000`

- [x] 7.6 <!-- Non-TDD --> Migrate the 12 `FAngelscriptEngine::CreateUncompiled` call sites in `AngelscriptEditor/Tests/*` to set `Config.bSkipInitialCompile = true;` inline (right after the `FAngelscriptEngineConfig::FromCurrentProcess()` call) and switch to `FAngelscriptEngine::Create(Config, Deps)`. Sites: `AngelscriptDirectoryWatcherTests.cpp:94`, `AngelscriptClassReloadHelperTests.cpp:57`, `AngelscriptClassReloadHelperStructTests.cpp:31`, `AngelscriptClassReloadHelperPostReloadTests.cpp:34`, `AngelscriptEditorModulePopupTests.cpp:73`, `AngelscriptClassReloadHelperDelegateTests.cpp:40`, `AngelscriptClassReloadHelperClassReloadTests.cpp:38`, `AngelscriptBlueprintImpactScanTests.cpp:34`, `AngelscriptEditorModuleDirectoryWatcherTests.cpp:75`, `AngelscriptBlueprintImpactScanNoImpactTests.cpp:34`, `AngelscriptEditorMenuExtensionsTests.cpp:57`, `AngelscriptEditorModuleAssetCreationTests.cpp:105`. Editor tests cannot depend on `AngelscriptTest` (Build.cs barrier), so the wrapper isn't an option here. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.AngelscriptEditor" -Label clone-removal-7.6-editor-migration -TimeoutMs 1200000`

- [x] 7.7 <!-- Non-TDD --> Delete `FAngelscriptEngine::CreateUncompiled` from `AngelscriptEngine.h` (declaration at the static-factory block, currently sibling to `Create`) and `AngelscriptEngine.cpp` (definition that immediately follows `Create`). Search the entire `Plugins/Angelscript/Source/` tree for residual `CreateUncompiled` references and confirm zero hits. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-7.7-delete-uncompiled -TimeoutMs 900000 -NoXGE`

- [x] 7.8 <!-- Non-TDD --> End-of-section regression. Verify (one command, sequential):
  ```
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-7.8-final-build -TimeoutMs 1800000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label clone-removal-7.8-final-engine -TimeoutMs 1200000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional" -Label clone-removal-7.8-final-functional -TimeoutMs 1200000
  ```
