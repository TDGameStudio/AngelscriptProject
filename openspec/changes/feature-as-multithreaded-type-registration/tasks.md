# Concurrent Type Registration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore native `asCScriptEngine` locks (A0), define concurrent independent type `Register*` inside a window (A1), then intern templates so host stage3 bytecode can ParallelFor (A2).

**Architecture:** One `engineRWLock` intern lock. Keep existing tables. Window begin/end. Cvar-gated bytecode ParallelFor default off.

**Tech Stack:** Maintained AngelScript fork, `FRWLock` / `FCriticalSection` + Standalone `UECompat`, native SDK tests, Standalone CTest.

**Spec:** `design.md`, `specs/as-engine-thread-lock-floor/spec.md`, `specs/as-multithreaded-type-registration/spec.md`, `specs/as-compile-intern-parallel-bytecode/spec.md`. File map, code sketches, and commands: `attachments/implementation-plan.md`.

## Global Constraints

- Dual-repo: C++ in `Plugins/Angelscript` first, then parent gitlink + this OpenSpec.
- Do not ParallelFor `CallBinds` or make `RegisterObjectMethod` concurrent.
- Do not replace `asCArray` / `TMap` with lock-free containers.
- Do not use Hazelight `myas` as an implementation template.
- Do not commit unless the user asks.
- Standalone must keep compiling: `FRWLock` / `FCriticalSection` live in `Plugins/Angelscript/Standalone/Compat/UECompat.h`.
- New tests: `Angelscript` prefix. Pure SDK → `AngelscriptTest/AngelScriptSDK/` plus Standalone CTest.
- Verify only with `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`.
- Native engine first: tests call `asIScriptEngine`, not `FAngelscriptBinds`.

---

## 1. A0 failing tests and Standalone threads-on

- [ ] 1.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptConcurrentTypeRegistrationTests.cpp` with prefix `Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration`. Implement `RequestBuildFromTwoThreads` exactly as in `attachments/implementation-plan.md` (CreateBareSdkEngine, two FRunnable, one `0` and one `asBUILD_IN_PROGRESS`, then `BuildCompleted` and a later successful `RequestBuild`). Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration" -Label as-mt-1.1 -TimeoutMs 600000`. Expected: FAIL (both succeed) or compile-fail until the file is picked up.

- [ ] 1.2 <!-- TDD --> Add `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneConcurrentTypeRegistrationTests.cpp` and CMake `add_executable` / `add_test(NAME AngelscriptStandalone.ConcurrentTypeRegistration ...)` next to Compat as in the implementation plan. Same RequestBuild assertions via `std::thread`. Run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-1.2`. Expected: FAIL or compile-fail.

- [ ] 1.3 <!-- TDD --> Implement `FCriticalSection` and `FRWLock` in `Plugins/Angelscript/Standalone/Compat/UECompat.h` using `std::mutex` / `std::shared_mutex` with UE method names (`Lock`/`Unlock`/`TryLock`, `ReadLock`/`WriteLock` and matching Unlocks). Add a tiny Compat assert that a `FRWLock` write-lock then unlock does not deadlock. Re-run Standalone suite. Expected: shim compiles; RequestBuild CTest still FAIL.

- [ ] 1.4 <!-- Non-TDD --> Remove `AS_NO_THREADS` from `AngelscriptMaintainedFork` `target_compile_definitions` in `Plugins/Angelscript/Standalone/CMakeLists.txt` and from the private-definition list in `Plugins/Angelscript/Standalone/Tests/CMake/AssertTargetInterfaces.cmake` (keep the INTERFACE leak assert). Confirm MSVC `as_config.h` still defines `AS_WINDOWS_THREADS` so it does not re-add `AS_NO_THREADS`. Run Standalone suite. Expected: compile; RequestBuild still FAIL until 2.x.

## 2. A0 restore engineRWLock and RequestBuild

- [ ] 2.1 <!-- TDD --> Replace always-empty macros in `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_criticalsection.h` with `#ifndef AS_NO_THREADS` types `asCThreadCriticalSection` / `asCThreadReadWriteLock` wrapping `FCriticalSection` / `FRWLock`. Keep macro names (`ACQUIREEXCLUSIVE`, `ACQUIRESHARED`, …). Do not paste stock Win32/pthread lock bodies.

- [ ] 2.2 <!-- TDD --> Implement `asPrepareMultithread`, `asUnprepareMultithread`, `asGetThreadManager`, `asThreadCleanup`, and `asAcquireExclusiveLock` / shared pair in UE `as_thread.cpp` (header `Core/angelscript.h` already declares them). Keep existing `thread_local asCThreadLocalData`. Application lock is **not** `engineRWLock`. Standalone `AngelscriptStandaloneThreadCompat.cpp` already implements the C APIs; leave it, now compiled with threads on.

- [ ] 2.3 <!-- TDD --> Lock `asCScriptEngine::RequestBuild` (`as_scriptengine.cpp:3321`) like 2.38 `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_scriptengine.cpp:3609`. Also take exclusive lock in `BuildCompleted` when clearing `isBuilding`. Re-run 1.1 prefix. Expected: `RequestBuildFromTwoThreads` PASS.

- [ ] 2.4 <!-- TDD --> Restore exclusive DCL in `GetTypeIdFromDataType` (`as_scriptengine.cpp:5027-5041`) from 2.38 ~5094, using this fork’s `mapTypeIdToTypeInfo.Add`. Extract `AssignTypeIdLocked` if it keeps the increment+map insert in one place. Add `LazyTypeIdFromTwoThreads` if you can construct a type with `typeId == -1` and call `GetTypeIdFromDataType` from two FRunnables. Run ConcurrentTypeRegistration prefix. Expected: unique id, one sequence consumed.

- [ ] 2.5 <!-- Non-TDD --> `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-mt-2.5 -TimeoutMs 1800000` and `Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-2.5-standalone`. Then `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-mt-2.5-sdk -TimeoutMs 900000`. Expected: compile; SDK PASS; Standalone PASS including new CTest RequestBuild case.

## 3. A1 window API and locked type intern

- [ ] 3.1 <!-- TDD --> Add `BeginConcurrentTypeRegistration` / `EndConcurrentTypeRegistration` at the end of `asIScriptEngine` in `Core/angelscript.h` and `as_scriptengine.h` / `.cpp` as in `attachments/implementation-plan.md`. Default `concurrentTypeRegistrationOpen = false`. Tests: `BeginRejectedWhileBuilding`, nested Begin → `asINVALID_CONFIGURATION`, End without Begin → `asINVALID_CONFIGURATION`. Run ConcurrentTypeRegistration prefix. Expected: FAIL until implemented, then PASS.

- [ ] 3.2 <!-- TDD --> While the window is open, `RequestBuild` returns `asINVALID_CONFIGURATION`; `CreateContext`, `RegisterObjectMethod`, `RegisterObjectBehaviour`, `RegisterObjectProperty`, `RegisterGlobalFunction`, `RegisterFuncdef`, and `RegisterEnumValue` return `asINVALID_CONFIGURATION`. Test `MethodRegisterRejectedDuringWindow`. Run ConcurrentTypeRegistration prefix. Expected: FAIL until guards exist, then PASS.

- [ ] 3.3 <!-- TDD --> Snapshot `asSNameSpace* ns = defaultNamespace` at `RegisterObjectType` entry. Under exclusive `engineRWLock`: uniqueness (`GetRegisteredType` / `CheckNameConflict`), insert `allRegisteredTypes` / `allRegisteredTypesByName` / `registeredObjTypes`, `AssignTypeIdLocked`, unlock. Template and specialization branches stay exclusive for the whole intern. Do not use unlocked `GetTypeIdByDecl` as the only publish path. `SetDefaultNamespace` takes exclusive for the pointer swap.

- [ ] 3.4 <!-- TDD --> Tests `RegistersTwoTypesFromWorkerThreads` and `DuplicateNameFromTwoThreads` (POD value types size 4, names `ConcurrentTypeA`/`ConcurrentTypeB`/`ConcurrentDup`) as in the implementation plan. Open the window around the workers. Run ConcurrentTypeRegistration prefix. Expected: FAIL on races until 3.3, then PASS.

- [ ] 3.5 <!-- TDD --> Same two scenarios on Standalone CTest (`std::thread`, `Begin`/`End`). Re-run `Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-3.5`. Expected: PASS.

- [ ] 3.6 <!-- TDD --> Concurrent `RegisterEnum` unique names and concurrent `RegisterInterface` unique names inside the window (same native file). Same exclusive intern helper, different kind arrays (`registeredEnums` vs object types). Run ConcurrentTypeRegistration prefix. Expected: FAIL until those APIs use the locked insert, then PASS.

- [ ] 3.7 <!-- TDD --> Concurrent `RegisterTypedef` unique names inside the window, pushing `registeredTypeDefs`. Run ConcurrentTypeRegistration prefix. Expected: FAIL until locked, then PASS.

- [ ] 3.8 <!-- Non-TDD --> Comment on `RegisterFuncdef` that it is outside the window (touches function ids). No concurrent RegisterFuncdef test. Confirm `CallBinds` is unchanged.

## 4. A2 template intern and AllocateFunction

- [ ] 4.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptCompileInternTests.cpp` prefix `Angelscript.TestModule.AngelScriptSDK.Engine.CompileIntern`. Tests: two threads intern distinct template subtypes; two threads intern the same subtype (same pointer). Register a template type as in the implementation plan (or Standalone StdLib array if dummy template fails). Run: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.CompileIntern" -Label as-mt-4.1 -TimeoutMs 600000`. Expected: FAIL until `GetTemplateInstanceType` is locked.

- [ ] 4.2 <!-- TDD --> Double-checked locking on `GetTemplateInstanceType` (`as_scriptengine.cpp:3385`): shared lookup, exclusive create, re-check, insert `templateInstanceBuckets`. Re-run CompileIntern prefix. Expected: distinct-subtype and same-subtype tests PASS.

- [ ] 4.3 <!-- TDD --> Add `asCScriptEngine::AllocateFunction`. Grep `GetNextScriptFunctionId` and `AddScriptFunction` under `ThirdParty/angelscript/source/` and convert peek+add pairs. Keep `freeScriptFunctionIds` reuse inside the exclusive lock. Template intern must call `AllocateFunction` for cloned methods. Test that two intern paths do not receive the same function id. Run CompileIntern prefix. Expected: PASS.

- [ ] 4.4 <!-- TDD --> Fix diagnostic races used by parallel compile: host `bHadCompileErrors` in `AngelscriptEngine.cpp` Parse ParallelFor (~5537) must be atomic; `WriteMessage` / `preMessage` must not tear. Add or extend a test that two builders can `WriteMessage` without crashing. This is a prerequisite for 5.x even if the cvar stays 0.

## 5. A2 host ParallelFor stage3 (default off)

- [ ] 5.1 <!-- Non-TDD --> Split `FAngelscriptEngine::CompileModule_Code_Stage3` (`AngelscriptEngine.cpp:7358`) into bytecode (`BuildCompileCode`) and serial JIT+builder dispose. Add `TAutoConsoleVariable<int32>` `as.Compile.ParallelBytecode` default `0`. When 0, call the original serial sequence.

- [ ] 5.2 <!-- TDD --> When the cvar is 1, `ParallelFor` bytecode across `CompiledModules` with `EParallelForFlags::Unbalanced`, then serial JIT. Skip `bCompileError` / `bLoadedPrecompiledCode` as today. Do not ParallelFor `CompileFunctions` inside one builder. Do not ParallelFor stage4 `ResetGlobalVars`. Native or editor test: with cvar 0, a two-module compile still succeeds (behavior preserve). Optional: with cvar 1 in a native-only compile if the test harness can set the cvar.

- [ ] 5.3 <!-- Non-TDD --> Do **not** default the cvar to 1. Record in the change directory (not `tasks.md`) if a ForceClean log is captured: compare `"script compilation stage3"` vs parse timers. Approach B/C stay unscheduled.

## 6. Final verification

- [ ] 6.1 <!-- Non-TDD --> `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration" -Label as-mt-6.1 -TimeoutMs 600000`. Expected: PASS.

- [ ] 6.2 <!-- Non-TDD --> `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine.CompileIntern" -Label as-mt-6.2 -TimeoutMs 600000`. Expected: PASS after A2; skip until 4.x if stopping after A1.

- [ ] 6.3 <!-- Non-TDD --> `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label as-mt-6.3-sdk -TimeoutMs 900000`. Expected: PASS.

- [ ] 6.4 <!-- Non-TDD --> `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -Label as-mt-6.4`. Expected: previous Standalone tests plus ConcurrentTypeRegistration CTest, all PASS.

- [ ] 6.5 <!-- Non-TDD --> Confirm `CallBinds` is not ParallelFor’d and `as.Compile.ParallelBytecode` defaults to 0. No TypeInfo apply change.
