# UE types already inside the fork, and what "atomic id" means in UE

## 1. UE types in this AngelScript engine

The maintained fork is compiled as part of `AngelscriptRuntime`, not as a pristine C library. Observed UE (or UE-shaped) types in engine headers:

| Location | Type | Role |
|---|---|---|
| `as_scriptengine.h` | `TMap<int, asCTypeInfo*>` | `mapTypeIdToTypeInfo` |
| `as_scriptengine.h` | `TMap<void*, asCGlobalProperty*>` | `varAddressMap` |
| `as_scriptengine.h` | `TArray<asCObjectType*>` | `unvalidatedTemplateInstances` |
| `as_scriptengine.h` | `TMap<uint64, TArray<asCObjectType*, TInlineAllocator<2>>>` | `templateInstanceBuckets` |
| `as_map.h` | `TMultiMap<uint32, OBJ>` | `asCMapByName` |
| `as_map.h` | `TMultiMap<uint64, OBJ>` | `asCSymbolMap` |
| `as_map.h` | `#include "CoreTypes.h"` | UE core types |
| `as_atomic.cpp` | `FPlatformAtomics` | refcount inc/dec |
| `as_memory.h` | `AngelscriptSDK::SDKAlloc` | replaces raw new |
| `as_string.h` | `asCString` | still custom; not `FString` |

Standalone compiles the same headers against `Plugins/Angelscript/Standalone/Compat/UECompat.h`, which provides `TMap`, `TArray`, `FPlatformAtomics` (`std::atomic_ref`), and `FMemory`. It does **not** currently provide `FRWLock` / `FCriticalSection`.

Implication: making type tables concurrent cannot assume "we are in UE only". Any `FRWLock` used by the fork needs a Standalone shim, same as `TMap`.

## 2. UE containers are not a concurrent map

`TMap` / `TMultiMap` / `TArray` are single-threaded structures. Concurrent `Add` during rehash is undefined. UE code that needs concurrent intern/insert does **not** atomize a counter and keep writing `TMap`.

## 3. Analogue: FNamePool (local Engine 5.8)

Path: `Engine/Source/Runtime/Core/Private/UObject/UnrealNames.cpp`.

FName insertion is the closest UE pattern to "many threads register unique typed names":

- Hash → **shard** (`FNamePoolShard`, 256 or 1024 shards).
- Per shard: `mutable FRWLock Lock` plus slot table.
- Entry counts are `std::atomic<uint32>`.
- Lookups take `FRWScopeLock(..., SLT_ReadOnly)`; create takes write lock (`FWriteScopeLock`).
- `FNameEntryAllocator` also uses `FRWLock` around block allocation.

This is **lock + shard + atomic stats**, not "atomic id only". The id (`FNameEntryId`) is a handle into a concurrent-safe allocator, published under the shard lock.

## 4. Analogue: FUObjectArray::AllocateUObjectIndex

`UObjectBase::AddObject` can run off-game-thread (sets `EInternalObjectFlags::Async`). Index allocation is a dedicated concurrent structure with locks, not an unsynchronized `TArray::Add`. Native class bootstrap (`DeferredRegister`) is still carefully ordered on the game thread for compiled-in objects.

AS application type registration is closer to FName intern (config-time unique names) than to UObject construction during gameplay.

## 5. Analogue already in this fork: asCAtomic

`asCAtomic::atomicInc` → `FPlatformAtomics::InterlockedIncrement`. That is the correct primitive for `typeIdSeqNbr`. It is already paid for and Standalone-tested (`AngelscriptStandaloneCompatTests.cpp` asserts InterlockedIncrement). Reuse it; do not invent a second atomic helper.

## 6. What to copy from UE, what not to copy

Copy:

- Interlocked increment for the sequence number.
- `FRWLock` around table mutation + lookup (shared for find, exclusive for insert).
- Standalone shim so the fork stays one codebase.

Do not copy in v1:

- 1024-way FName shards. Bind-time type count is small; one engine lock plus work outside the lock is the first design.
- Making `TMap` itself thread-safe.
- Process-global intern: types stay per `asIScriptEngine`.
