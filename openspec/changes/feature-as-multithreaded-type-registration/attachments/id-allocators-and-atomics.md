# ID allocators vs atomic increment

Question: can the engine’s id sites just use `asAtomicInc` / `FPlatformAtomics`?

Short answer: the **integer** can. Almost none of these allocators are “just an integer.” The serial part is **publishing the id into an array/map** (and, for functions, **reusing holes**). Unique numbers without a published slot are unused ids.

`asCAtomic` / `asAtomicInc` already exist (`as_atomic.cpp` → `FPlatformAtomics`). Using them on a counter is cheap and optional **inside** a lock. They do not replace the lock around `TMap::Add` / `asCArray::PushLast`.

## Sites

| Allocator | How it works today | Atomic bump enough for unique numbers? | Still racy without a lock |
|---|---|---|---|
| `typeIdSeqNbr++` then `ot->typeId` + `mapTypeIdToTypeInfo.Add` | Lazy, per type object; OR’s `asTYPEID_*` flags; seq in `asTYPEID_MASK_SEQNBR` (26 bits) | Yes for the sequence | Same type first-touched by two threads (need CAS/`ot->typeId` DCL); `TMap::Add`; later `GetTypeInfoById` must see a complete type |
| `GetNextScriptFunctionId` + `AddScriptFunction` | **Peek** free list **or** `scriptFunctions.GetLength()`; later `PopLast` + `PushLast` or fill hole | Only if you **stop reusing** ids and treat length as a monotonic counter | Two threads can peek the same length/same free slot; `PushLast` realloc; `scriptFunctions[id] = func` |
| `GetNextImportedFunctionId` | Same peek/free-list as functions (`FUNC_IMPORTED \| idx`) | Same | Same; source TODO: compile vs discard |
| `GetScriptSectionNameIndex` | Lookup intern map; else `scriptSectionNames.PushLast` | Index is `GetLength()`, not a separate counter | Intern uniqueness + `TMultiMap`/`asCArray` |
| `AddNameSpace` | Intern by name | N/A (name is the key) | Map insert |
| GC `numAdded++` + `gcNewObjects.PushLast` | Stock already under `gcCritical` | Yes for `seqNbr` | `PushLast` on the GC list; stock used the lock, not an atomic |

Function/import ids are a **two-phase** protocol: `GetNext*` does not reserve. Two threads both see `GetLength()==10`, both build a function with id 10, both `PushLast`. Atomic increment of a **separate** `functionIdSeqNbr` would uniquify the number only if `AddScriptFunction` no longer uses `GetLength()` as the id and no longer hands out `freeScriptFunctionIds.back()`.

## Type id is the misleading one

```text
if (ot->typeId == -1) {
    typeId = typeIdSeqNbr++;          // unique number — atomic can do this
    typeId |= asTYPEID_APPOBJECT;      // flags in high bits
    ot->typeId = typeId;              // publish on the type — needs DCL/CAS
    mapTypeIdToTypeInfo.Add(typeId, ot);  // TMap — not atomic
}
```

Stock put a **mutex** around this whole block, and left `typeIdSeqNbr++` as a plain int, because the lock already serializes the increment. Two executing threads first-asking for the **same** type must not consume two sequence numbers and must not both `Add`.

Atomic increment alone:

- Different types: unique seq, still crash/lost entries on `TMap::Add` / `registeredObjTypes.PushLast`.
- Same type, lazy path: two seq numbers burned; `ot->typeId` last-writer wins; map may hold a stale or duplicate key.

## What “just atomize the counters” would still leave serial

GenerateTypes / `RegisterObjectType`: name uniqueness, `allScriptDeclaredTypes`, `sharedScriptTypes`.
GenerateFunctions: `scriptFunctions` slot publish (even with monotonic atomic ids you must grow the array under a lock or a lock-free vector).
Bytecode: `GetTemplateInstanceType` intern (keyed by type args, not an id bump).

## Practical split

- **Do** `asAtomicInc` on `typeIdSeqNbr` (and GC `numAdded` if the list insert is separately locked). Harmless, matches existing `asCAtomic`.
- **Do not** treat that as concurrent `Register*` or concurrent `Build`.
- Function ids: either keep a lock around peek+insert+free-list, or drop reuse (monotonic atomic id + locked/growable `scriptFunctions`). Dropping reuse changes bytecode/hot-reload density; that is a separate product choice, not a one-line atomic.

v1 type registration: lock around uniqueness + table insert; atomic type-id is optional inside that lock. Function-id allocator stays serial.
