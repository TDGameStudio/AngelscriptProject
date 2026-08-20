## Context

Subject is the **native** `asIScriptEngine` (`asCScriptEngine`), the same object Standalone and the UE module both compile. Official AngelScript multithreading ([manual](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_multithread.html)) covers concurrent `Execute` on separate contexts, `asPrepareMultithread` for creating engines, `asAtomicInc` for object refcounts, and a **single-thread `Build`**. It does not make `RegisterObjectType` concurrent.

Stock `GetTypeIdFromDataType` takes `ACQUIREEXCLUSIVE(engineRWLock)` around non-atomic `typeIdSeqNbr++` so executing threads can lazily publish a type id. Stock `RegisterObjectType` does **not** take that lock for name-table insert. This fork deleted working lock macros (`as_criticalsection.h` is always no-op) and kept the leftover comment, so even stock lazy-id is unprotected. Maps in this fork are UE `TMap`/`TMultiMap`; that is an implementation detail of the same native engine.

The UE host (`FAngelscriptEngine` in `AngelscriptEngine.cpp`) already occupies `RequestBuild` once per batch, `ParallelFor`s `BuildParallelParseScripts` across modules, then runs GenerateTypes / GenerateFunctions / layout / `CompileModule_Code_Stage3` (`BuildCompileCode` + `JITCompile`) serially. `GetTemplateInstanceType` (around `as_scriptengine.cpp:3385`) intern during bytecode can `AddScriptFunction`, so function ids are **not** all assigned before stage3.

Research: indexed in `attachments/README.md`. Executable file map, test sketches, and verification commands: `attachments/implementation-plan.md`.

**Chosen product shape:** Approach **A** (lock intern, keep tables), delivered as three stacked schemes. Approach **B** (two-pass intern) and **C** (concurrent containers) stay documented follow-ons, not this change's tasks.

```text
A0 floor locks  →  A1 type-registration window  →  A2 template intern + ParallelFor bytecode
                      (same type intern lock)         (same intern lock + AllocateFunction)
```

A1 is a slice of type intern. It does **not** replace A2. A2 does **not** require CallBinds ParallelFor.

## Goals / Non-Goals

**Goals:**

- Real `engineRWLock` (and GC critical sections) on both UE and Standalone hosts; Standalone must compile threads **on**.
- `RequestBuild` is linearizable (`asBUILD_IN_PROGRESS` if another thread holds the slot).
- Lazy type-id assign is stock DCL under exclusive lock; `GetTypeInfoById` observes a fully published type.
- Concurrent registration of *independent* application types into one engine during an explicit window.
- Unique names in a namespace: concurrent duplicate `RegisterObjectType("Foo")` returns `asALREADY_REGISTERED` on all but one winner.
- `GetTemplateInstanceType` intern is linearizable so host stage3 bytecode can later `ParallelFor` across modules.
- Native tests that fail today if two threads register distinct types, or two threads `RequestBuild`, into one engine.

**Non-Goals:**

- Concurrent `RegisterObjectMethod` / `RegisterObjectBehaviour` / `RegisterGlobalFunction` / `RegisterFuncdef` / `AddScriptFunction` as a public contract (A2 intern may serialize function-slot alloc *inside* template intern; that is not a public concurrent RegisterMethod API).
- Overlapping full `module->Build()` on one engine (host already batches under one `RequestBuild`).
- Claiming `asPrepareMultithread` makes `Register*` or `Build` safe.
- Replacing `asCArray` / `TMap` with lock-free containers (Approach C).
- Two-pass eager intern of all template instances before bytecode (Approach B) — follow-on if A2 intern lock is hot.
- Parallelizing UE `FAngelscriptBinds::CallBinds` (host concern; later consumer of A1).
- Making `TMap` itself thread-safe.
- Changing type-id numeric stability across process runs (ids remain insertion-order; concurrent inserts are race-order).
- Bit-identical lock internals with upstream WinXP semaphore RW lock.
- Hazelight `myas` as a design source.
- Restoring stock `Suspend`/`Abort` as a blocker for A1 (optional A0-later slice for Execute-from-timeout).

## Decisions

### 1. Three stacked schemes, not three products

| Id | Name | Unlocks | Does not unlock |
|---|---|---|---|
| **A0** | Floor locks | Stock concurrent Execute (once Suspend is restored), lazy type-id, userdata/module sites that already call the macros, linearizable `RequestBuild` | Concurrent `Register*`, parallel stage3 |
| **A1** | Type-registration window | Concurrent independent `RegisterObjectType` / Enum / Interface / Typedef | Methods, funcdefs, `Build`, stage3 |
| **A2** | Template intern + parallel bytecode | Host `ParallelFor` of `BuildCompileCode` across modules | Overlapping full Builds, CallBinds ParallelFor, lock-free containers |

Ship A0 even if A1/A2 slip: this fork is currently weaker than stock 2.38 on locks. A1 and A2 share the same exclusive intern section; do not invent a second type-table lock.

**Rejected:** only atomizing `typeIdSeqNbr` as the product. Stock never made `RegisterObjectType` safe that way, and name-table `PushLast`/`TMultiMap::Add` still race. See `attachments/id-allocators-and-atomics.md`.

### 2. A0 — restore macros with `FRWLock`, not stock Win32 SRWLOCK

**Choice:** Bring back `#ifndef AS_NO_THREADS` macros in `as_criticalsection.h` as in stock 2.38 (`DECLAREREADWRITELOCK` → a real RW lock object). Implementation of `asCThreadReadWriteLock` / `asCThreadCriticalSection` wraps **UE `FRWLock` / `FCriticalSection`** in `AngelscriptRuntime`, and the same types shimmed in `Plugins/Angelscript/Standalone/Compat/UECompat.h` (`std::shared_mutex` / `std::mutex`). Keep macro names so existing userdata/module/GC sites become real.

**Standalone:** `Plugins/Angelscript/Standalone/CMakeLists.txt` currently sets `AS_NO_THREADS` on `AngelscriptMaintainedFork`, and `Tests/CMake/AssertTargetInterfaces.cmake` lists it as a private definition. Remove it. `as_config.h` will still force `AS_NO_THREADS` if neither `AS_WINDOWS_THREADS` nor `AS_POSIX_THREADS` is set; MSVC already defines `AS_WINDOWS_THREADS`. Do **not** compile stock Win32 lock bodies — wrap `FRWLock` so Standalone does not need `Windows.h` SRWLOCK.

**`RequestBuild` / `BuildCompleted`:** copy 2.38:

```text
ACQUIREEXCLUSIVE(engineRWLock);
if (isBuilding) { RELEASEEXCLUSIVE; return asBUILD_IN_PROGRESS; }
isBuilding = true;
RELEASEEXCLUSIVE;
```

`BuildCompleted` clears `isBuilding` under exclusive lock as well (2.38 clears it unlocked; this fork should lock both sides so the flag is not a torn write).

**Lazy type-id:** copy 2.38 DCL around `as_scriptengine.cpp:5027-5041` (`ACQUIREEXCLUSIVE`, re-read `ot->typeId`, `typeIdSeqNbr++`, `mapTypeIdToTypeInfo.Add`, `RELEASEEXCLUSIVE`). Shared lock on `GetDataTypeFromTypeId` / `GetTypeInfoById` map lookup (already has `ACQUIRESHARED` at several sites — those become real).

**Public thread C API:** `Core/angelscript.h` already declares `asPrepareMultithread` / `asThreadCleanup` / `asAcquireExclusiveLock`. Standalone `AngelscriptStandaloneThreadCompat.cpp` implements them but gates the **application** `shared_mutex` on `AS_NO_THREADS`. UE `as_thread.cpp` only has `thread_local asCThreadLocalData` and does **not** implement the C APIs. Restore the C APIs on the UE translation unit (or a small UE-side cpp next to it) so the public header links. Application `asAcquireExclusiveLock` is **not** `engineRWLock`; do not conflate them.

**Atomic increment of `typeIdSeqNbr`:** optional inside the exclusive section. Stock used a plain `++` because the lock serializes it. Prefer plain `++` in A0 to match stock; A1 may keep that.

### 3. A1 — registration window, begin/end pair

**Choice:** `BeginConcurrentTypeRegistration()` / `EndConcurrentTypeRegistration()` on `asIScriptEngine` (add at the **end** of the public interface, before the protected destructor, so existing virtual order is unchanged). Default closed. No new `asEEngineProp` — a property can be left on into `Build()`.

Return codes:

| Call | Success | Already open / not open | `isBuilding` |
|---|---|---|---|
| Begin | `asSUCCESS` | `asINVALID_CONFIGURATION` | `asBUILD_IN_PROGRESS` |
| End | `asSUCCESS` | `asINVALID_CONFIGURATION` | n/a |

While the window is open:

- **Defined concurrent:** `RegisterObjectType`, `RegisterEnum`, `RegisterInterface`, `RegisterTypedef`.
- **Forbidden (return `asINVALID_CONFIGURATION`):** `RequestBuild` / module `Build`, `CreateContext`, `PrepareEngine`, `RegisterObjectMethod`, `RegisterObjectBehaviour`, `RegisterObjectProperty`, `RegisterGlobalFunction`, `RegisterFuncdef`, `RegisterEnumValue` (value insert is a second table; keep serial after types). Nested `Begin`.
- **Exclusive with in-flight registers:** `SetDefaultNamespace`.

Outside the window: serial `Register*` as today. Insert still takes the exclusive intern lock (one code path). Non-shipping: if an in-flight type-register counter is >0 and the window is closed, `ensure` — overlapping use without opt-in is a host bug.

**`RegisterObjectType` critical section (non-template):**

1. Validate flags/name with no shared writes (local `asCBuilder`).
2. Snapshot `asSNameSpace* ns = defaultNamespace` at entry **before** waiting on the lock.
3. Exclusive: `GetRegisteredType` / `CheckNameConflict` using `ns`; on miss `asNEW`, insert `allRegisteredTypes` / `allRegisteredTypesByName` / `registeredObjTypes`, **eager** `typeId` assign + `mapTypeIdToTypeInfo.Add` in the same exclusive section; unlock.
4. Return that type id (do not call unlocked `GetTypeIdByDecl` as the only publish path).

Template `asOBJ_TEMPLATE` and template-specialization branches stay exclusive for the whole intern (they read `templateSubTypes` / existing instances). `ParseTemplateDecl` / `ParseDataType` that only tokenize may run before the lock; if they look up registered types, take shared lock for lookup or hold exclusive for the whole register.

**Namespace:** public `RegisterObjectType` uses the snapshot. Tests that need another namespace pass it via `SetDefaultNamespace` on the **same** thread before that thread's register, or (internal) `RegisterObjectTypeInNamespace` helper. Concurrent `SetDefaultNamespace` from another thread takes exclusive and waits; it cannot tear the snapshot already captured on the stack.

**Function ids stay serial in A1.** `RegisterFuncdef` is out of the window.

### 4. A1 type-id: lock first, eager at insert, atomic optional

Publication: assign sequence and `mapTypeIdToTypeInfo` insert under the same exclusive lock. After A1, newly registered application types should not remain `typeId == -1`. Lazy DCL remains for types created on other paths (script types today still lazy-assign on first `GetTypeIdFromDataType`). A2 may eager-assign script types at GenerateTypes intern; that is the same helper.

**Rejected as the whole product:** `FPlatformAtomics::InterlockedIncrement` on `typeIdSeqNbr` without locking the map.

Type-id numeric values may differ under concurrency vs a serial schedule. Document that. Deterministic ids need a pre-assigned table (out of scope).

### 5. A2 — intern `GetTemplateInstanceType`, then ParallelFor bytecode

**Why this is the compile ROI:** host already parallelizes Parse. Stage3 (`FAngelscriptScopeTimer` `"script compilation stage3"`, `CompileModule_Code_Stage3` → `asCBuilder::BuildCompileCode` → `CompileFunctions`) is the usual CPU hog and is a serial `for` over modules. Bytecode calls `GetTemplateInstanceType`, which on miss inserts `templateInstanceBuckets` and may clone methods via `AddScriptFunction`.

**Cheap version (this change):**

1. `GetTemplateInstanceType`: shared lock for bucket lookup; exclusive for create + bucket insert + any `AllocateFunction`; double-checked lookup after acquiring exclusive.
2. Replace the two-phase `GetNextScriptFunctionId` (peek free-list or `scriptFunctions.GetLength()`) + later `AddScriptFunction` with one `AllocateFunction(asCScriptFunction*)` that reserves the slot under the intern lock. Keep hole reuse **inside** that lock. Call it from `GetTemplateInstanceType` and from remaining serial GenerateFunctions.
3. Host: split `CompileModule_Code_Stage3` so `BuildCompileCode` can `ParallelFor` across modules (`EParallelForFlags::Unbalanced`); keep `JITCompile` serial unless the existing per-function JIT mutex is proven enough. Gate with cvar `as.Compile.ParallelBytecode` default **0**.
4. Diagnostics: `bHadCompileErrors` must be atomic or merged at the barrier (Parse already races this). `engine->preMessage` is a singleton — bytecode workers must not tear it; prefer per-builder messages (already `numErrors` on `asCBuilder`) and a locked `WriteMessage`.

**Cleaner follow-on (Approach B, not this change):** walk AST / type uses, intern all template instances serially, then bytecode is read-only on type/function tables.

**Do not** ParallelFor `CompileFunctions` **inside** one builder until `functions[]` mutation and `preMessage` are per-thread. Across **modules** is the first ParallelFor (each module has its own `asCBuilder`).

Measure first on a Cache-miss / ForceClean compile: if `"script compilation stage3"` is not the dominant timer, do not enable the cvar by default.

### 6. Tests live in native SDK and Standalone CTest first

Plugin `CallBinds` ParallelFor is a later consumer. Engine tests must not need `UObject`.

- Native: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Engine/` using `AngelscriptNativeCoreTestSupport.h` (`CreateNativeEngine` / `CreateBareSdkEngine`) and `FRunnable` like `AngelscriptNativeAtomicTests.cpp`. Prefix `Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration` and `...Engine.CompileIntern`.
- Standalone CTest: new executable next to `AngelscriptStandaloneCompatTests`, `std::thread`, same assertions, so the `FRWLock` shim is forced.

UBT already globbs `AngelscriptTest` `.cpp` files; adding a file under `AngelScriptSDK/Engine/` does not require `AngelscriptTest.Build.cs` edits.

### 7. Host CallBinds stays serial

After A1, a later host may:

```text
BeginConcurrentTypeRegistration();
// ParallelFor type-declaration applies only
EndConcurrentTypeRegistration();
// serial methods / behaviours / properties
```

This change does **not** land that ParallelFor.

## Risks / Trade-offs

- [Coarse lock makes ParallelFor of RegisterObjectType scale poorly] → Keep parse/allocate outside the lock; only uniqueness + table insert inside. Measure before sharding (Approach C).
- [Standalone `AS_NO_THREADS` would compile restored macros to no-ops] → Remove the define; CTest covers threads-on; update `AssertTargetInterfaces.cmake`.
- [Enabling lock macros changes timing of existing userdata/module paths] → Those macros are currently no-ops; enabling them is a behavior change toward actual thread safety. Run native SDK + Standalone 19/19 (plus new tests).
- [Template specialization path in `RegisterObjectType` reads existing template instances] → Stay exclusive for that branch in A1.
- [Consumers call `RegisterObjectMethod` from workers anyway] → Window returns `asINVALID_CONFIGURATION`; methods not in the concurrent allowlist.
- [A2 ParallelFor races `WriteMessage` / `preMessage` / `bHadCompileErrors`] → Treat diagnostics as a hard A2 prerequisite, not a follow-on.
- [Function-id hole reuse vs bump] → Keep reuse inside `AllocateFunction`'s lock in A2; dropping reuse is a later optional.
- [2.38 / 2.39 WIP already parallelize Register or Build] → They do not. See `attachments/upstream-2.38-and-wip-2.39-multithread.md`.
- [UE `ParallelFor` of Register* is a host choice] → Do not call TaskGraph from inside `asCScriptEngine`; native tests use `FRunnable` / `std::thread`.
- [Cache V2 ExactStartup skips the compile pipeline] → A2 only pays off on cold start / ForceClean / big dirty sets. Measure that path.
- [Restored `asPrepareMultithread` on UE vs existing TLS-only `as_thread.cpp`] → Implement C APIs without replacing `thread_local`; do not bring back a process-wide thread manager unless tests need `asGetThreadManager`.

## Migration Plan

1. Land A0 tests (`RequestBuild` from two threads; existing SDK still PASS) and Standalone threads-on.
2. Restore macros + locked `RequestBuild` + lazy type-id DCL.
3. Land A1 failing concurrent register tests; then window + locked insert + eager type id.
4. Land A2 intern tests (`GetTemplateInstanceType` from two threads); then `AllocateFunction`; then cvar-gated host ParallelFor.
5. Default: window closed, parallel bytecode cvar off. Existing `CallBinds` unchanged.

Rollback: window default closed; cvar off; if lock macros regress, keep implementation behind `AS_ENGINE_TYPE_REGISTRATION_LOCK` / `#ifndef AS_NO_THREADS` for one release.

Dual-repo: commit submodule `Plugins/Angelscript` first, then parent gitlink + this OpenSpec.

## Open Questions

- Whether to restore stock `asCContext::Suspend` / `Abort` (currently `return asERROR`) in the same A0 PR or a follow-up. Recommendation: **follow-up**. A1/A2 do not need it.
- Whether `RegisterTypedef` shares the exact object-type insert helper or a second small helper (typedef is `asCTypedefType`, not `asCObjectType`). Recommendation: shared `InternRegisteredType(asCTypeInfo*)` for name uniqueness + maps + eager id; typed arrays (`registeredObjTypes` vs `registeredEnums` vs `registeredTypeDefs`) stay per-kind.
- Default of `as.Compile.ParallelBytecode` after A2 is green. Recommendation: remain **0** until a measured ForceClean log shows stage3 >> parse with the intern lock not dominating Insights.
- Approach B trigger: intern lock > ~15% of stage3 wall time on a representative project. Not scheduled in `tasks.md`.
