## Why

Stock AngelScript's native engine allows multiple threads to *execute* (separate contexts, `asPrepareMultithread`, atomic refcounts). It does **not** allow multiple threads to *configure* or *compile* one engine: `RegisterObjectType` is unsynchronized, and `Build` is explicitly single-thread. Type ids are a lazy `typeIdSeqNbr++` behind `engineRWLock` so executing threads can first-touch a type id — still not concurrent registration.

This fork is weaker than stock on that floor: `as_criticalsection.h` is always no-op, UE `as_thread.cpp` no longer implements `asPrepareMultithread`, `RequestBuild` is an unlocked `isBuilding = true`, and `GetTypeIdFromDataType` kept the “waiting for the lock” comment with no lock. Maps are UE `TMap`/`TMultiMap`; that is an implementation detail of the same native engine.

Upstream **2.38.0** (`Reference/angelscript-v2.38.0`) and official **2.39.0 WIP** do **not** add concurrent `Register*` or parallel `Build`. There is nothing to cherry-pick for those two capabilities. What *can* be restored from 2.38 is the lock macros, locked `RequestBuild`, and locked lazy type-id.

The UE host already `ParallelFor`s Parse across modules inside one `RequestBuild`. Stage3 bytecode stays a serial `for` because `GetTemplateInstanceType` intern (and sometimes `AddScriptFunction`) is unlocked. Highest compile ROI is intern-then-parallel, not lock-free `asCArray`.

This change records **three stacked schemes** on native `asCScriptEngine`. Implement in order. Do not start with CallBinds ParallelFor or concurrent containers.

## What Changes

- Treat this as a **native engine** contract on `asIScriptEngine` / `asCScriptEngine` (Standalone CMake host and `AngelscriptRuntime` share the same fork). UE bind layer is only a future caller.
- **Scheme A0 (floor):** restore working `engineRWLock` / critical-section macros on UE and Standalone; lock `RequestBuild`; restore stock exclusive DCL around lazy `GetTypeIdFromDataType`; drop Standalone `AS_NO_THREADS` so those macros are not compiled out; restore public thread C APIs on the UE `as_thread.cpp` path if the header still exports them.
- **Scheme A1 (type-registration window):** while `BeginConcurrentTypeRegistration` / `EndConcurrentTypeRegistration` is open, concurrent `RegisterObjectType` / `RegisterEnum` / `RegisterInterface` / `RegisterTypedef` of independent names is defined (uniqueness + table insert + type-id publish under exclusive lock). Namespace is captured per call. Methods, funcdefs, and `Build` stay single-thread.
- **Scheme A2 (compile intern + parallel bytecode):** lock whole `GetTemplateInstanceType` (lookup shared / create exclusive); merge `GetNextScriptFunctionId` + `AddScriptFunction` into one `AllocateFunction` used inside that intern; then host `ParallelFor` of `BuildCompileCode` across modules behind a default-off cvar. Per-thread / per-builder diagnostics at the same time.
- **Not this change:** Approach B (two-pass eager intern then read-only codegen), Approach C (sharded / lock-free containers), `ParallelFor(CallBinds)`, overlapping full `Build()`, lock-free `asCArray`.
- Tests are native SDK + Standalone CTest against `asIScriptEngine`, no `UObject`.

## Capabilities

### New Capabilities

- `as-engine-thread-lock-floor`: real RW/critical-section macros, locked `RequestBuild`, stock lazy type-id DCL, Standalone threads-on, public thread C API on both hosts.
- `as-multithreaded-type-registration`: native engine registration-window, unique type ids, linearizable duplicate names, namespace snapshot.
- `as-compile-intern-parallel-bytecode`: intern lock on `GetTemplateInstanceType` + `AllocateFunction`, optional host ParallelFor of stage3 bytecode, default off until measured.

### Modified Capabilities

- (none)

## Impact

- Native fork: `as_criticalsection.h`, `as_thread.cpp` (UE), `as_scriptengine.cpp` / `.h` (`RequestBuild`, `GetTypeIdFromDataType`, `RegisterObjectType` / Enum / Interface / Typedef, `GetTemplateInstanceType`, `GetNextScriptFunctionId` / `AddScriptFunction`), `as_builder.cpp` (`CompileFunctions` / diagnostics), possibly `as_context.cpp` Suspend/Abort as a later floor slice.
- Public header `Core/angelscript.h`: begin/end window. `asPrepareMultithread` remains the stock "create engines from many threads" API; it is not a substitute for concurrent `Register*` or parallel `Build`.
- Standalone: drop `AS_NO_THREADS` on `AngelscriptMaintainedFork`; add `FRWLock` / `FCriticalSection` to `UECompat.h`; CMake + `AssertTargetInterfaces.cmake`; new CTests.
- Host compile: `AngelscriptEngine.cpp` stage3 loop only in A2, cvar-gated.
- Plugin `CallBinds` / TypeInfo apply are out of this change; they may call the window later.
- Dual-repo: C++ in `Plugins/Angelscript` first, then parent gitlink + this OpenSpec.
