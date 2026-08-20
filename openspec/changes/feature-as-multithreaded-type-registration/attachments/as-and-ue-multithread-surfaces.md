# Native AngelScript multithread surfaces, and UE ways to run them

Scope: native `asIScriptEngine` / `asCScriptEngine` plus Unreal dispatch primitives. Not Hazelight `myas`. Not a v1 scope expansion — maps what already exists vs what would be a later native change.

Sources: official [Multithreading](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_multithread.html), [Concurrent scripts](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_concurrent.html), [GC objects](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_gc_object.html), [Fine tuning](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_finetuning.html); this fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/`; Standalone `Compat/Source/AngelscriptStandaloneThreadCompat.cpp`; UE 5.x Core `Async/` and `HAL/`.

## A. Native AngelScript — what stock already designed for threads

Stock “supports multithreading” is a **narrow** contract. Check `asGetLibraryOptions()` for `AS_NO_THREADS`.

### A1. Already defined (stock)

| Surface | Contract | Notes |
|---|---|---|
| `context->Execute()` on **separate** contexts | Concurrent | Same module OK if app protects globals. Same context from two threads: undefined. |
| `asCreateScriptEngine` from several threads | After `asPrepareMultithread()` | Shares one `asIThreadManager`. One engine: optional. |
| `asThreadCleanup()` | Required on thread exit | Otherwise TLS leaks until engine destroy. |
| DLL / multi-module hosts | `asGetThreadManager` + `asPrepareMultithread(ptr)` | One manager across modules. |
| Object refcounts | `asAtomicInc` / `asAtomicDec` / `asCAtomic` | For objects **shared** across executing threads. |
| App-registered objects used by many Executes | App must lock | Library offers `asAcquireExclusiveLock` / `asAcquireSharedLock` on the **thread manager**, not around `Register*`. |
| `asILockableSharedBool` | Weak-ref / shared flag | `asCreateLockableSharedBool`; Set/Lock use a critical section. |
| `SetUserData` / `GetUserData` | RW lock | Exclusive write, shared read (`engineRWLock`). |
| Lazy `GetTypeIdFromDataType` | Exclusive `engineRWLock` | First-touch type id during **execute**, not Register. |
| `GetDataTypeFromTypeId` | Shared `engineRWLock` | Map lookup. |
| `RequestBuild` / `isBuilding` | Exclusive, non-blocking | Second concurrent `Build` returns `asBUILD_IN_PROGRESS`. Docs: only one thread may build. Upstream TODO: parallel compilations. |
| `scriptModules` list | Commented as synchronized with `engineRWLock` | Discard vs compile is still a known hole (`as_module.cpp` TODO). |
| GC add/collect | `gcCritical` + `gcCollecting` | Auto-GC may run on **any executing thread**. Manual GC from a background thread is allowed **if** GC behaviours are thread-safe. |
| `NotifyGarbageCollectorOfNewObject` | Takes `gcCritical` | Called from factories during Execute. |
| Context pool | `SetContextCallbacks` / `RequestContext` / `ReturnContext` | Engine does not lock the pool. App callback must be thread-safe if Execute is concurrent. Nested registered calls also `RequestContext`. |
| `context->Suspend()` / `Abort()` | Other thread may set flags | Official concurrent-scripts timeout thread does this. |
| Multiple **engines** | Isolated | Rarely needed; config groups cover most isolation. |
| Fibers | Not OS threads | Must not switch fiber mid-`Execute`; suspend first. |
| Cooperative “concurrent scripts” | One OS thread | Round-robin `Execute` + timeout/`Suspend`. Not multithreading. |
| `CContextMgr` add-on | Explicitly **not** multithread | Coroutines / cooperative only. |
| Most add-ons (`scriptarray`, `scriptdictionary`, `scriptstdstring`, …) | Not thread-safe | Docs: review or replace. |

`AS_NO_THREADS` in `as_config.h` / project flags: compile without the above locks for a single-thread host (fine-tuning doc).

### A2. Stock does **not** make concurrent

| Surface | Why |
|---|---|
| `RegisterObjectType` / Enum / Interface / Typedef / GlobalProperty / ObjectMethod / ObjectBehaviour / GlobalFunction | Name tables + `asCArray` unsynchronized. |
| `SetDefaultNamespace` | Engine-wide pointer. |
| `module->Build`, `CompileFunction`, `CompileGlobalVar`, `LoadByteCode` | Mutates engine; `RequestBuild` serializes (fail, not wait). |
| `BindImportedFunction` / imported-id allocator | TODO: breaks if discard races compile. |
| Same `asIScriptContext` used on two threads | Stack + TLS `activeContext`. |
| Message callback object | Not a concurrent log API. |
| JIT compiler object | First-compile races unless the JIT itself locks. |

### A3. This fork vs stock

| Stock | This fork (UE module) | Standalone CMake |
|---|---|---|
| Real `asCThreadReadWriteLock` unless `AS_NO_THREADS` | `as_criticalsection.h` **always** empty macros | Same empty header; CMake also **defines `AS_NO_THREADS`** on `AngelscriptMaintainedFork` |
| `as_thread.cpp`: prepare / cleanup / app RW lock / TLS | `thread_local asCThreadLocalData` only; **no** `asPrepareMultithread` definition | `Compat/Source/AngelscriptStandaloneThreadCompat.cpp` **does** implement prepare/cleanup/app `std::shared_mutex`. Does **not** compile `as_thread.cpp`. App lock is still not `engineRWLock`. |
| `GetTypeIdFromDataType` exclusive lock | Comment kept, lock gone; `TMap::Add` | Same engine cpp |
| `RequestBuild` under lock | Plain `isBuilding = true` — two threads can both enter Build | Same |
| `SetUserData` under lock | Macros no-op | Same |
| GC critical sections | Macros no-op; GC lists race if Execute is concurrent | Same, and `AS_NO_THREADS` |
| `Suspend`/`Abort` from another thread | **`return asERROR`** stubs | Same cpp |
| `asCLockableSharedBool::Lock` | `ENTERCRITICALSECTION` no-op | Same |
| `asCAtomic` | `FPlatformAtomics` — this path **works**; covered by `AngelscriptNativeAtomicTests.cpp` (`FRunnable`) | Same `as_atomic.cpp` |
| JIT bind | Fork extra: `std::mutex jitBindingMutex` on `asCScriptFunction` | Same |
| `BuildParallelParseScripts` | **Serial** loop over sections (name only) | Same |

MSVC `as_config.h` still `#define AS_WINDOWS_THREADS`. The UE module is **not** compiled `AS_NO_THREADS`, but the lock **types** were deleted, so `asGetLibraryOptions()` will **not** contain `AS_NO_THREADS` even though locks are inert.

Implication: restoring stock execute-time safety is more than type-id. The same empty macros also disable GC, userdata, Build slot, and lockable shared bool. Standalone cannot get real engine locks until CMake drops `AS_NO_THREADS` (or lock macros ignore that flag — worse, two meanings of “no threads”).

### A4. Native places worth supporting later (not v1 type-registration)

Ordered by how close they are to stock, not by plugin bind work.

1. **Restore stock locks (floor).** `engineRWLock` + `gcCritical`/`gcCollecting` + `asCLockableSharedBool` + `RequestBuild` exclusive. Makes concurrent **Execute** and lazy type-id defined again. Does not make `Register*` concurrent.
2. **Restore public C thread API on the UE module** to match Standalone (`asPrepareMultithread`, `asThreadCleanup`, app lock). Today those symbols are declared in `Core/angelscript.h` and only defined in Standalone ThreadCompat.
3. **Context `Suspend`/`Abort`.** Stock execute-timeout and cooperative hosts need this. This fork currently returns `asERROR`.
4. **Type-declaration `Register*` window** — current change v1.
5. **Thread-safe `RequestContext` pool** — host callback + engine still serializes nothing; required as soon as Execute is concurrent.
6. **GC behaviours** of registered containers (array/map) if auto-GC stays on during concurrent Execute.
7. **Concurrent Build** — upstream TODO; shared types, function ids, `scriptModules`. Far larger than type registration.
8. **Concurrent methods / `AddScriptFunction`** — function-id allocator + `scriptFunctions` array; out of v1 by design.
9. **Intra-Build parallel parse** — native `asCBuilder::BuildParallelParseScripts` is a serial `for` over sections. The **UE host** (`FAngelscriptEngine` compile pipeline) already `RequestBuild()`s once, then `ParallelFor`s that parse function **across modules** (batches of 100). GenerateTypes / functions / layout / bytecode stay serial on the game thread. That is host-stage parallelism inside one engine build slot, not a concurrent `asIScriptModule::Build()` API. Two threads calling `module->Build()` still hit `asBUILD_IN_PROGRESS` (and this fork’s unlocked `isBuilding` is racy). Different problem from concurrent `RegisterObjectType`.

## B. Unreal Engine — ways to run multithreaded work

UE is a **named-thread + worker pool** runtime. UObject/GC stay on the **game thread**. Native AS engine tables are not UObjects; Execute that touches `UObject` still is.

### B1. Where work runs

| Thread | Owns | Safe for native AS? |
|---|---|---|
| Game thread | UObject, actor tick, most binds that call engine APIs | Registration today; any script that uses UObject |
| Render / RHI | Scene, GPU commands | Do not put AS engine here |
| Audio / load | Streaming | Possible for pure native compile/register if no UObject |
| TaskGraph / `GThreadPool` workers | CPU jobs | Pure native `Register*` / `Execute` **if** the engine contract allows it |
| Dedicated `FRunnableThread` | Long-lived loops | Tests already use this for `asCAtomic`; overkill for one-shot register |

Golden rule: **no UPROPERTY / UFUNCTION / GetWorld / spawn from workers.** Dispatch results with `AsyncTask(ENamedThreads::GameThread, ...)` and `TWeakObjectPtr`.

### B2. Dispatch APIs (pick the simplest that fits)

| API | Best for this project | Avoid when |
|---|---|---|
| `ParallelFor` / `ParallelForTemplate` (`Async/ParallelFor.h`) | Independent type rows once the native window exists. Caller participates and **blocks**. Use `MinBatchSize`; `Unbalanced` if register cost varies. | Holding a lock inside every iteration (serializes). Sharing a `TMap` without the engine lock. UObject in the body. |
| `UE::Tasks::Launch` + `Prerequisites` | One-shot native compile/execute jobs, chaining “register window → Build on one task”. Preferred UE5+ API. | Need game-thread UObject apply in the same lambda. |
| `UE::Tasks::FPipe` | Serialize all `Build()` / method `Register*` onto one logical queue without a mutex in the caller. | Trying to parallelize the piped work anyway. |
| `Async(EAsyncExecution::ThreadPool, …)` → `TFuture` | Host wants a future; `Thread` = new OS thread (rare). | Fire-and-forget that captures `UObject*`. |
| `AsyncTask(ENamedThreads::GameThread, …)` | Apply UObject results after worker native work. | Doing the heavy native work on GT. |
| `TGraphTask` / TaskGraph | Many dependencies; Unreal Insights task traces. | Simple N-way register (use ParallelFor). |
| `FAsyncTask` / `FAutoDeleteAsyncTask` | Reusable pooled units. | New code: prefer `UE::Tasks`. |
| `FRunnable` + `FRunnableThread` | Native SDK tests (`AngelscriptNativeAtomicTests.cpp`); dedicated AS worker if we ever own a thread. | Data-parallel registration (use ParallelFor). Docs: avoid unless you need a named long-lived thread. |

### B3. Synchronization (what the native engine should use)

| Primitive | Role vs AS |
|---|---|
| `FRWLock` + `FReadScopeLock` / `FWriteScopeLock` | Stock `engineRWLock` shape. **Not recursive.** Standalone needs a shim (`std::shared_mutex` already used for the **app** lock). |
| `FCriticalSection` + `FScopeLock` | Recursive mutex; stock GC `CRITICAL_SECTION` analogue. |
| `FPlatformAtomics` / `std::atomic` | Already wired as `asAtomicInc`. Sequence numbers **inside** a lock, not instead of a lock. |
| `TQueue<T, EQueueMode::Mpsc>` | Host job queue: workers enqueue, GT or one AS pipe dequeues. Does not make engine tables concurrent. |
| `FEvent` / `FEventRef` | Wait for Build slot / window close. |
| `TSharedPtr<T, ESPMode::ThreadSafe>` | Cross-thread shared **non-UObject** state. Default `ESPMode` is **not** thread-safe. |
| `std::mutex` | Already on `jitBindingMutex`. Fine for a single function’s JIT bind; do not mix with `FRWLock` on the same data. |

UE containers (`TMap`, `TArray`, `TMultiMap`) are **not** concurrent. Concurrent intern in UE looks like **FNamePool**: shard + per-shard `FRWLock` + atomics for counts. That is the analogue for unique names, not the v1 implementation (one engine lock is enough for bind-time type count).

Do **not** copy parallel rendering, AnimGraph worker graphs, or async package loading into the native engine. Those are UE subsystem pipelines.

### B4. How UE dispatch should meet native AS (later consumers)

```text
Worker / ParallelFor          Native asIScriptEngine              Game thread
─────────────────────         ──────────────────────              ──────────
BeginConcurrentTypeReg  →     window + exclusive insert
RegisterObjectType × N  →     uniqueness + typeId publish
EndConcurrentTypeReg    →
                              FPipe or GT: Register methods
                              FPipe or GT: module->Build()
Execute on workers      →     one context per thread              if UObject: dispatch GT
RequestContext          →     thread-safe pool
asThreadCleanup         →     end of worker
```

`ParallelFor(CallBinds)` remains illegal until the native allowlist is real **and** method registration stays off the workers. Historical `Documents/Plans/Plan_BindParallelization.md` still holds for **methods + bind lambdas**.

## C. Recommendation for this change

Keep v1 = restore real locks (stock execute/GC/userdata/Build-slot) + type-declaration window.

When restoring locks, treat Standalone `AS_NO_THREADS` as a **product flag to flip** (or compile a threads-on CTest target). Otherwise restored macros compile out on Standalone while the UE module thinks threads are on.

Do not put ParallelFor / TaskGraph inside `asCScriptEngine` v1. Those are **hosts**. Native tests can use `FRunnable` (already in Atomic tests) or `std::thread` in Standalone CTest.

Next native follow-ons after v1, if wanted: UE-module `asPrepareMultithread` parity with Standalone; `Suspend`/`Abort`; thread-safe context pool; GC behaviour audit. Concurrent `Build` stays a separate change.
