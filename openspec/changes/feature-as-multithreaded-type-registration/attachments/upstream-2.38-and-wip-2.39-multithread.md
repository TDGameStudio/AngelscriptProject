# Upstream 2.38.0 and official WIP 2.39 vs this fork

Sources:

- Local pin: `Reference/angelscript-v2.38.0` (`anjo76/angelscript` tag `v2.38.0`, 2025-08-08)
- Official latest: GitHub `anjo76/angelscript` **master** = **2.39.0 WIP** (changelog dated 2026-08-17 on [wip.php](https://angelcode.com/angelscript/wip.php))
- Docs: [Multithreading](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_multithread.html) (unchanged contract)
- Changelog: [changes2.html](https://www.angelcode.com/angelscript/sdk/docs/articles/changes2.html)

## Verdict

Neither **2.38.0** nor **2.39.0 WIP** implements concurrent `RegisterObjectType` or parallel `Build`. The official multithread story is still Execute-centric. Parallel compile remains a source TODO. Concurrent type registration would be **beyond upstream**, not a backport.

## 2.38.0 (`Reference/angelscript-v2.38.0`)

| Topic | 2.38.0 | This fork |
|---|---|---|
| `as_criticalsection.h` | Real `asCThreadCriticalSection` / `asCThreadReadWriteLock` unless `AS_NO_THREADS`. Windows: `CRITICAL_SECTION` + semaphore (comment still mentions SRWLOCK as nicer). POSIX: `pthread_rwlock_t`. | Always empty macros |
| `as_thread.cpp` | Full `asPrepareMultithread` / `asThreadCleanup` / `asAcquire*Lock` / TLS (`TlsAlloc`) | UE: `thread_local` only. Standalone CMake: ThreadCompat + **`AS_NO_THREADS`** |
| `RegisterObjectType` | No `ACQUIREEXCLUSIVE` around name-table insert. `isPrepared = false`, validate, `asNEW`, PushLast, return `GetTypeIdByDecl` | Same class of race; maps are `TMap` |
| `GetTypeIdFromDataType` | Exclusive `engineRWLock`, DCL, plain `typeIdSeqNbr++`, insert map | Comment kept, **no lock** |
| `RequestBuild` | Exclusive lock; second thread `asBUILD_IN_PROGRESS` | No lock; `isBuilding` racy |
| `asCModule::Build` | “Only one thread may build” + **TODO: It should be possible to have multiple threads perform compilations** | Same TODO. Host splits stages; only Parse is ParallelFor |
| `asCBuilder::Build` | Single `Build()` (parse+compile together) | Staged `BuildParallelParseScripts` / GenerateTypes / … for the host |
| `GetNextScriptFunctionId` | Peek free-list or `scriptFunctions.GetLength()`; `AddScriptFunction` later | Same two-phase protocol |
| `GetTemplateInstanceType` | Linear scan of `templateInstanceTypes` **without** engine RW lock | Bucket `TMap`; still no lock |
| GC | `gcCritical` / `gcCollecting` real | Macros no-op |
| `Suspend` / `Abort` | Set flags; other thread may suspend a running context | Return `asERROR` |

2.38.0 language/API extras (foreach, variadic, template **functions**, qword type flags) are unrelated to intern concurrency.

Changelog items that **are** multithread, all older than 2.38:

- Constraint: only one thread may compile (this is a **guard**, not parallelism)
- Multiple threads querying typeIds (lazy id + `engineRWLock`)
- `GetModule` / `DiscardModule` thread-safe
- `SetLineCallback` from a second thread
- `GarbageCollect` full cycle on a parallel thread (behaviours must be TS)
- `asPrepareMultithread` / `asAtomicInc` / app RW lock
- Some add-on refcounts / string factory / parseFloat thread-safe

None of those are “parallel compile” or “concurrent Register*”.

## Official latest (2.39.0 WIP, master as of 2026-08)

Fetched `as_module.cpp` from GitHub master: **same** “Only one thread may build” + **same TODO** on `Build` / `CompileFunction` / related.

Fetched `as_thread.cpp` from master: still thread-manager + app lock. New vs older Windows TLS:

- `AS_WINDOWS_USEFLS` → `FlsAlloc` / `FlsSetValue` / fiber callback instead of `TlsAlloc`
- WIP note: “Added support for Fiber Local Storage on Windows (Thanks Roel Binnendijk)”

That fixes **fiber vs TLS** (official docs already warned fibers can corrupt the context stack). It does **not** intern types concurrently or compile on many threads.

Other 2.39 WIP items (enum underlying type, factory const handle, `GetLineEntry`, JIT `CleanFunction` always called, number separators) are language/API, not compile parallelism.

WIP planned list is a Google Doc; changelog does not list concurrent `Register*` or multi-thread `Build` as incoming.

## What we can copy from 2.38/WIP vs what we invent

**Copy / restore (stock floor):**

- Real critical section + RW lock macros
- `RequestBuild` exclusive
- Lazy type-id DCL under exclusive lock
- Public `asPrepareMultithread` / `asThreadCleanup` / app lock (Standalone already has a subset)
- Optional: 2.39 FLS if this fork still needs fiber-safe TLS (UE already uses `thread_local`; fibers are a separate host issue)

**Do not expect to backport:**

- Concurrent `RegisterObjectType`
- Parallel `asCBuilder` / `module->Build()`
- Locked `GetTemplateInstanceType` intern
- Merged `AllocateFunction`
- Host `ParallelFor` Parse (that is this project’s UE pipeline, not upstream)

Those remain this fork’s product work (`internal-structure-multithread-roi.md`).
