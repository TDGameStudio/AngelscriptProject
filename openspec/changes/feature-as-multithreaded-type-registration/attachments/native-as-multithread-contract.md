# Native AngelScript engine multithreading (stock contract)

Primary sources:

- Official manual: [Multithreading](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_multithread.html)
- Upstream mirror: `sdk/angelscript/source/as_scriptengine.cpp`, `as_criticalsection.h`, `as_thread.cpp` (`codecat/angelscript-mirror`)
- This fork: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/` and `Core/angelscript.h`

This is the **native `asIScriptEngine` / `asCScriptEngine`** contract. UE binds, `CallBinds`, and TypeInfo apply are only hosts that would *call* these APIs.

## 1. What stock AngelScript means by "multithread"

The library supports multithreading **if** `asGetLibraryOptions()` does not contain `AS_NO_THREADS`. The documented guarantees are:

| Operation | Stock contract |
|---|---|
| Multiple threads each `context->Execute()` | Yes. Separate contexts. Same module allowed if the app protects shared globals. |
| Creating engines from several threads | Yes, after `asPrepareMultithread()` on the main thread (shared `asCThreadManager`). |
| Thread exit | Must `asThreadCleanup()` or that thread's TLS leaks until engine destroy. |
| `module->Build()` / compile | **One thread at a time.** Docs: the engine only allows one thread to build, because build mutates engine state. |
| `RegisterObjectType` / other `Register*` | **Not a concurrent API.** Not listed as safe. Name tables and `asCArray` inserts are unsynchronized. |
| Application-registered objects/properties used from many executing scripts | App must lock. Library provides `asAcquireExclusiveLock` / `asAcquireSharedLock` on the **thread manager**, not around `Register*`. |
| Object refcounts shared across threads | `asAtomicInc` / `asAtomicDec`. |
| GC | Can run on any executing thread; GC behaviours must be thread-safe. |

Stock multithreading is **execution + engine construction + refcount**, not **parallel type configuration**.

## 2. Type id: mutex in stock, not an atomic counter

Stock `GetTypeIdFromDataType` (upstream `as_scriptengine.cpp`):

```text
typeId = ot->typeId;
if (typeId == -1)
{
    ACQUIREEXCLUSIVE(engineRWLock);
    // Make sure another thread didn't determine the typeId while we were waiting for the lock
    if (ot->typeId == -1)
    {
        typeId = typeIdSeqNbr++;
        // flags...
        ot->typeId = typeId;
        mapTypeIdToTypeInfo.Insert(typeId, ot);
    }
    RELEASEEXCLUSIVE(engineRWLock);
}
```

Facts:

- `typeIdSeqNbr++` is **still a non-atomic int**. Stock does **not** use `asAtomicInc` here.
- Safety is the **engine RW lock** plus double-checked locking.
- The comment exists because this path is `const` and can run from **many executing threads** the first time something asks for a type id (lazy assign). Types can be registered with `typeId == -1`; the first `GetTypeId*` publishes the id.
- `GetDataTypeFromTypeId` takes `ACQUIRESHARED(engineRWLock)` around the map lookup.

This is **not** "concurrent `RegisterObjectType`". It is "concurrent *readers* of type identity after types already exist".

Stock `RegisterObjectType` itself: `isPrepared = false`, validate, insert `allRegisteredTypes` / arrays, `return GetTypeIdByDecl(name)`. **No `ACQUIREEXCLUSIVE` around the name-table insert.** Two threads calling `RegisterObjectType` on stock AS is still a data race on those arrays/maps. The lock only appears later inside `GetTypeIdFromDataType` if both reach lazy id assign — too late to make registration itself defined.

## 3. Stock locks (`as_criticalsection.h`)

When `AS_NO_THREADS` is **not** set:

- `DECLAREREADWRITELOCK` → `asCThreadReadWriteLock`
- Windows: `CRITICAL_SECTION` + semaphore (Vista- SRWLOCK left as TODO)
- POSIX: `pthread_rwlock_t`

When `AS_NO_THREADS` **is** set, the macros are empty (same text this fork always uses).

Stock `as_thread.cpp` implements the public C API: `asPrepareMultithread`, `asUnprepareMultithread`, `asGetThreadManager`, `asAcquireExclusiveLock` (locks `threadManager->appRWLock`), `asThreadCleanup`, plus TLS via `TlsAlloc` / `pthread_key`.

`asAcquireExclusiveLock` is an **application lock** for protecting *registered objects at runtime*, not the engine configuration tables.

## 4. What this fork changed (native layer)

| Stock | This fork |
|---|---|
| Real `asCThreadReadWriteLock` unless `AS_NO_THREADS` | `as_criticalsection.h` is **always** empty macros |
| `GetTypeIdFromDataType` takes exclusive lock around `typeIdSeqNbr++` | Same comment, **no lock**; `TMap::Add` instead of `asCMap::Insert` |
| `as_thread.cpp` full manager + public C API | Reduced to `thread_local asCThreadLocalData`; `asPrepareMultithread` still **declared** in `Core/angelscript.h` |
| `asCMap` for type-id map | UE `TMap` / `TMultiMap` (`asCSymbolMap`, `asCMapByName`) |
| `asCAtomic` platform atomics | `FPlatformAtomics` (refcount only, still not type id) |

MSVC `as_config.h` still `#define AS_WINDOWS_THREADS`, so stock would have compiled real locks. The fork deleted the lock types instead of wiring them to UE/`std::shared_mutex`.

Net: this fork is **weaker** than stock for the one concurrent type-id path stock actually had (lazy id during execute). It is **equal** to stock for `Register*`: both are single-thread configuration.

## 5. Implication for the proposal

If the product goal is "native AS engine supports multithreaded **type registration**":

- That is a **new** `asCScriptEngine` capability. Stock AngelScript 2.33/2.38 does not offer it.
- Restoring stock `engineRWLock` around lazy `GetTypeIdFromDataType` only recovers **execute-time** id publish, which is necessary but not the user's `RegisterObjectType` goal.
- Making `typeIdSeqNbr` atomic without a lock is **not** how stock solved even the lazy-id case; stock used the RW lock.
- Concurrent `RegisterObjectType` still needs uniqueness on name tables (`asCArray` / `asCMap` or this fork's `TMultiMap`) under exclusive lock (or equivalent). Atomic id alone is insufficient on stock **and** on this fork.

UE plugin bind parallelization is a **caller** of this native API, not the engine change itself.
