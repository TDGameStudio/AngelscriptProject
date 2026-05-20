# Tasks: refactor-as-engine-clone-removal

> Verification commands follow project standards (`Documents/Guides/Build.md`,
> `Documents/Guides/Test.md`): builds run via `Tools\RunBuild.ps1`, tests via
> `Tools\RunTests.ps1`. Both scripts are invoked through PowerShell with
> `-NoProfile -ExecutionPolicy Bypass` and an explicit `-TimeoutMs` ≤ `3600000`.
> A whole-project build is the smallest unit of `RunBuild.ps1` work — there is
> no `-Target` / `-Action` flag.

## 1. Create FAngelscriptTestEngine

- [ ] 1.1 <!-- Non-TDD --> Create `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.h` with struct definition inheriting `FAngelscriptEngine`. Declare `ResetModules()`, `FullReset()`, `Create()`, `GetSharedEngine()`, `DestroySharedEngine()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.1-test-engine-header -TimeoutMs 600000 -NoXGE`

- [ ] 1.2 <!-- Non-TDD --> Create `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.cpp` implementing `ResetModules()` (discard all modules, GC), `FullReset()` (discard modules + clear generated types), `GetSharedEngine()` (lazy singleton), `DestroySharedEngine()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.2-test-engine-impl -TimeoutMs 900000 -NoXGE`

- [ ] 1.3 <!-- Non-TDD --> Change required `FAngelscriptEngine` members from `private` to `protected` to enable subclass access (Modules map, Engine pointer, SharedState pointer). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-1.3-protected-access -TimeoutMs 600000 -NoXGE`

## 2. Migrate Test Infrastructure

- [ ] 2.1 <!-- Non-TDD --> Update `AngelscriptTestMacros.h` to route `ASTEST_CREATE_ENGINE`, `ASTEST_GET_ENGINE`, `ASTEST_RESET_ENGINE` through `FAngelscriptTestEngine` APIs. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.1-macro-routing -TimeoutMs 600000 -NoXGE`

- [ ] 2.2 <!-- Non-TDD --> Update `AngelscriptTestUtilities.h`: replace `GetOrCreateSharedCloneEngine()` and `AcquireCleanSharedCloneEngine()` implementations to delegate to `FAngelscriptTestEngine::GetSharedEngine()`. The single `CreateCloneFrom` call at line 178 is replaced here. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-2.2-utilities -TimeoutMs 600000 -NoXGE`

- [ ] 2.3 <!-- Non-TDD --> Replace the 14 remaining `CreateCloneFrom` call sites in test sources with `FAngelscriptTestEngine::Create()` or `GetSharedEngine()` as appropriate: 4 in `Core/AngelscriptEngineIsolationTests.cpp` (lines 120, 155, 287, 914), 9 in `Core/AngelscriptMultiEngineLifecycleTests.cpp` (lines 104, 105, 137, 169, 204, 226, 381, 488, 489), 1 in `Core/AngelscriptEnginePerformanceTests.cpp` (line 160). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine" -Label clone-removal-2.3-migration-smoke -TimeoutMs 900000`

- [ ] 2.4 <!-- Non-TDD --> Update `AngelscriptTestEnginePool.h` to use `FAngelscriptTestEngine` instead of Clone-based pooling. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.MultiEngine" -Label clone-removal-2.4-pool -TimeoutMs 900000`

## 3. Remove Clone from Runtime

- [ ] 3.1 <!-- Non-TDD --> Delete `EAngelscriptEngineCreationMode` enum from `AngelscriptEngine.h`. Remove `CreateCloneFrom()` declarations (both overloads at lines 129-130). Remove `CreateUncompiledWithMode()` (only callers are test code that already migrated in Phase 2). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.1-api-delete -TimeoutMs 900000 -NoXGE`

- [ ] 3.2 <!-- Non-TDD --> Remove Clone-related members from `FAngelscriptEngine`: `CreationMode`, `SourceEngine`, `InstanceId`, `bOwnsEngine`. Remove `MakeModuleName()` Clone branch. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.2-members -TimeoutMs 900000 -NoXGE`

- [ ] 3.3 <!-- Non-TDD --> Delete `CreateCloneFrom()` and `AdoptSharedStateFrom()` implementations from `AngelscriptEngine.cpp`. The single internal forwarder at `AngelscriptEngine.cpp:811` (`CreateUncompiledWithMode` → `CreateCloneFrom`) is removed alongside its caller in 3.1. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.3-impl-delete -TimeoutMs 900000 -NoXGE`

- [ ] 3.4 <!-- Non-TDD --> Simplify `Shutdown()`: remove `bPendingOwnerRelease` checks, `ActiveCloneCount` waiting logic, deferred-release branches. Direct call to `ReleaseOwnedSharedStateResources()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-3.4-shutdown -TimeoutMs 900000 -NoXGE`

- [ ] 3.5 <!-- Non-TDD --> Drop the `GetCreationModeString` helper and the `CreationMode` column from `Dump/AngelscriptStateDump.cpp` (lines 67-78 plus the call sites that emit it). Update any matching CSV header / `Dump/` test fixtures so the column disappears cleanly. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label clone-removal-3.5-dump-cleanup -TimeoutMs 600000`

## 4. Simplify FAngelscriptOwnedSharedState

- [ ] 4.1 <!-- Non-TDD --> Remove `ActiveParticipants`, `ActiveCloneCount`, `bPendingOwnerRelease`, `bReleased` from `FAngelscriptOwnedSharedState`. Remove the `GetActiveParticipantsForTesting()` / `GetActiveCloneCountForTesting()` accessors and any tests that referenced them. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.1-shared-state-fields -TimeoutMs 900000 -NoXGE`

- [ ] 4.2 <!-- Non-TDD --> Change `TSharedPtr<FAngelscriptOwnedSharedState>` to `TUniquePtr<FAngelscriptOwnedSharedState>` in `FAngelscriptEngine`. Update all usages. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.2-uniqueptr -TimeoutMs 900000 -NoXGE`

- [ ] 4.3 <!-- Non-TDD --> Simplify `ReleaseOwnedSharedStateResources()`: remove double-release guard (`bReleased` check), remove participant tracking. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-4.3-release -TimeoutMs 900000 -NoXGE`

## 5. Full Validation

- [ ] 5.1 <!-- Non-TDD --> Whole-project build (no `-NoXGE`, full link). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-5.1-full-build -TimeoutMs 1800000`

- [ ] 5.2 <!-- Non-TDD --> Run the smoke + RuntimeCpp + Bindings suites (catches engine lifecycle, multi-engine, dependency injection, and binding regressions). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke,RuntimeCpp,Bindings -Label clone-removal-5.2-regression -TimeoutMs 2400000`

- [ ] 5.3 <!-- Non-TDD --> Run the bind/free regression family added in commit `91ac208` to confirm no memory leaks or cross-cycle accumulation. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Memory" -Label clone-removal-5.3-bind-free -TimeoutMs 900000`

- [ ] 5.4 <!-- Non-TDD --> Confirm `AngelscriptRuntime` no longer references any Clone-mode symbol after the migration. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Select-String -Path 'Plugins/Angelscript/Source/AngelscriptRuntime/**/*.cpp','Plugins/Angelscript/Source/AngelscriptRuntime/**/*.h' -Pattern 'EAngelscriptEngineCreationMode|CreateCloneFrom|ActiveCloneCount|ActiveParticipants|bPendingOwnerRelease' -SimpleMatch:$false | ForEach-Object { $_.Path + ':' + $_.LineNumber } | Sort-Object -Unique"` (expected: empty output).
