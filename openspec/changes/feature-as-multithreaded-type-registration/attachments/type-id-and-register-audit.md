# Audit: type id allocation and Register* shared state

Source of truth: this repo's maintained fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/` and public header `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`. Hazelight `myas` was not used as a design input.

## 1. Type id allocator

`as_scriptengine.h`:

```text
mutable int                       typeIdSeqNbr;
mutable TMap<int, asCTypeInfo*>   mapTypeIdToTypeInfo;
```

Constructor (`as_scriptengine.cpp`): primitives consume `asTYPEID_VOID`..`asTYPEID_FLOAT64`; then `typeIdSeqNbr = asTYPEID_FLOAT64 + 1`.

Lazy assign (`GetTypeIdFromDataType`, ~4993):

```text
typeId = ot->typeId;
if (typeId == -1)
{
    // comment: "Make sure another thread didn't determine the typeId while we were waiting for the lock"
    if (ot->typeId == -1)
    {
        typeId = typeIdSeqNbr++;
        // OR asTYPEID_SCRIPTOBJECT / TEMPLATE / APPOBJECT
        ot->typeId = typeId;
        mapTypeIdToTypeInfo.Add(typeId, ot);
    }
}
```

Facts:

- `typeIdSeqNbr++` is not atomic. Two threads can read the same value.
- The inner `if (ot->typeId == -1)` is double-checked locking **without a lock**. The comment is leftover.
- `asCTypeInfo::typeId` is `mutable int` (`as_typeinfo.h`), also non-atomic.
- `TMap::Add` is not safe for concurrent writers (or writer vs reader during rehash).
- `GetTypeIdFromDataType` is `const` and mutates those fields (hence `mutable`).
- Public flags: `asTYPEID_MASK_SEQNBR = 0x03FFFFFF` (~67M sequence numbers). Overflow is not a near-term concern for bind-time types.

`RegisterObjectType` / `RegisterEnum` / `RegisterInterface` do **not** assign `typeId` themselves. They insert the `asCObjectType`/`asCEnumType` then `return GetTypeIdByDecl(name)`, which parses the name again and calls `GetTypeIdFromDataType`.

## 2. Function id allocator (out of v1, same class of bug)

```text
GetNextScriptFunctionId:
  if freeScriptFunctionIds not empty → peek last
  else → scriptFunctions.GetLength()

AddScriptFunction:
  maybe PopLast free id
  PushLast or fill hole
```

Non-atomic, reuse stack, array realloc. Method registration cannot join the type window until this is designed separately.

## 3. RegisterObjectType writes (no lock)

After flag/name checks:

- `allRegisteredTypes.Add(type)` → `asCSymbolMap` → `TMultiMap<uint64, OBJ>`
- `allRegisteredTypesByName.Add(type)` → `asCMapByName` → `TMultiMap<uint32, OBJ>`
- `registeredObjTypes.PushLast(type)` → `asCArray` (heap realloc when capacity exceeded)
- templates also `registeredTemplateTypes.PushLast` and may `templateSubTypes.PushLast`

Reads on the same tables: `GetRegisteredType`, `CheckNameConflict`, `ParseDataType`. Concurrent register of two new names races insert; concurrent register of the **same** name can both miss `GetRegisteredType` and both insert.

`isPrepared = false` at entry is a plain store.

`defaultNamespace` is an engine pointer used as the type's namespace. `SetDefaultNamespace` is a process-wide switch.

## 4. engineRWLock is currently fiction

`as_criticalsection.h` (entire implementation):

```text
#define DECLAREREADWRITELOCK(x)
#define ACQUIREEXCLUSIVE(x)
#define RELEASEEXCLUSIVE(x)
#define ACQUIRESHARED(x)
#define RELEASESHARED(x)
```

`asCScriptEngine` still *declares* `DECLAREREADWRITELOCK(mutable engineRWLock)` and several paths still wrap userdata / module enumeration / cleanup callbacks with `ACQUIREEXCLUSIVE`. Those are no-ops.

`as_config.h` on MSVC still `#define AS_WINDOWS_THREADS`. The fork did not wire Windows SRWLOCK or UE `FRWLock` into this header.

`asCAtomic` **does** use `FPlatformAtomics::InterlockedIncrement` (`as_atomic.cpp`). That path is used for engine/function/type **refcounts**, not type ids.

## 5. What *is* thread-aware today

- `thread_local asCThreadLocalData` in `as_thread.cpp` (active context, temp string). Used by execution and `GetTypeDeclaration`, not by `RegisterObjectType`.
- Public `asPrepareMultithread` / `asThreadCleanup` still declared in `Core/angelscript.h`.
- Standalone thread manager uses `std::mutex` / `std::shared_mutex` in `AngelscriptStandaloneThreadCompat.cpp` for the *application* lock around thread-manager lifetime, not type tables.

## 6. Conclusion for the hypothesis

"Type registration is single-thread because type id is not atomic" is **directionally right and incomplete**.

| Mechanism | Atomic today? | Blocks concurrent RegisterObjectType? |
|---|---|---|
| `typeIdSeqNbr++` | No | Yes (duplicate/lost ids) |
| `ot->typeId` publish | No | Yes (torn reads) |
| `mapTypeIdToTypeInfo` (`TMap`) | No | Yes (rehash / lost entries) |
| `asCSymbolMap` / `asCMapByName` (`TMultiMap`) | No | Yes (uniqueness + crash) |
| `asCArray::PushLast` | No | Yes (realloc UAF) |
| `defaultNamespace` | No | Yes (wrong namespace) |
| `isPrepared` | No | Secondary |
| `engineRWLock` macros | N/A (no-ops) | Cannot save you |
| `GetNextScriptFunctionId` | No | Blocks concurrent *methods*, not type decls |

Fixing only the counter would still leave map/array/namespace races.
