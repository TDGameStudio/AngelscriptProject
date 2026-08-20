# Approaches compared

Stock AngelScript already "supports multithreading" for **Execute**, not for **Register***. See `attachments/native-as-multithread-contract.md`. Approaches below are native `asCScriptEngine` only.

**Letter collision:** this file’s A/B/C/D were the original research options. Delivery names in `design.md` / `tasks.md` / `implementation-plan.md` are **A0 / A1 / A2**:

| Delivery | This file | ROI attachment |
|---|---|---|
| A0 floor | Approach B (restore locks) + Standalone threads-on | ROI “floor” |
| A1 window | Approach C (registration window) | type intern slice |
| A2 intern + bytecode | (not in this file) | ROI Approach A compile intern |
| Follow-on B / C | Approach D+ | two-pass intern / concurrent containers |

Do not implement this file’s Approach A (atomic-only) as the product.

## Approach A — Atomic `typeIdSeqNbr` only

Change `typeIdSeqNbr++` to `asAtomicInc` / `FPlatformAtomics::InterlockedIncrement`.

- Pros: tiny diff; matches "id is not atomic".
- Cons: stock itself used a **mutex**, not an atomic, and only around lazy `GetTypeIdFromDataType`. Name tables and `RegisterObjectType` still race. False sense of safety.

Reject as the product change. Optional extra inside a locked section.

## Approach B — Restore stock locks only (lazy type id + Build exclusion)

Put `asCThreadReadWriteLock` back, wrap `GetTypeIdFromDataType` as upstream does, keep `RegisterObjectType` unlocked.

- Pros: recovers stock execute-time type-id publish; matches official "multithread" docs.
- Cons: does **not** make native `RegisterObjectType` concurrent. The user's ask is configuration, not only Execute.

Necessary baseline, not sufficient for concurrent registration.

## Approach C — Registration window + locked Register* insert (the actual extension)

1. Restore real `engineRWLock` (Approach B).
2. `BeginConcurrentTypeRegistration` / `EndConcurrentTypeRegistration`.
3. `RegisterObjectType` / `RegisterEnum` / `RegisterInterface`: parse locally; exclusive lock for uniqueness + table insert + id publish.
4. `typeIdSeqNbr++` stays inside that lock (stock); atomic increment optional.
5. Methods, funcdefs, `Build` remain single-thread (stock already serializes Build).

- Pros: native `asIScriptEngine::RegisterObjectType` from worker threads is defined; Standalone-testable; does not invent lock-free `asCArray`.
- Cons: `SetDefaultNamespace` still exclusive; template specialization stays exclusive; function ids still serial.

This plus Approach B is v1.

## Approach D — FNamePool-style sharded name maps

Replace `asCSymbolMap` inner `TMultiMap` with N shards each with `FRWLock`.

- Pros: better scaling if type insert lock is the measured hotspot.
- Cons: uniqueness across shards is easy (hash of name+ns), but `registeredObjTypes` order and `GetObjectTypeByIndex` still need a concurrent list or a merge step; more Standalone surface; premature without Approach C numbers.

Defer to v2 if Approach C lock is hot.

## Approach E — Parallel prepare, serial commit (no concurrent Register*)

Worker threads build `asCObjectType` blobs; game thread inserts them.

- Pros: avoids concurrent maps entirely; similar to TypeInfo expansion.
- Cons: does not make `asIScriptEngine::RegisterObjectType` itself thread-safe; plugin and tests that call the public API from workers still illegal; user asked for engine registration to be multithreaded.

Keep as the TypeInfo *expansion* story (`refactor-as-subsystem-typeinfo-bind-cache`). Do not substitute it for this change.

## Historical note

Stock docs already say one thread may `Build`. UE `CallBinds` ParallelFor is a host topic and is not this change. This change only extends native type-declaration `Register*` on `asCScriptEngine`.

## Recommendation

Ship **Approach B as the floor** (stock lazy-id lock restored) plus **Approach C** (registration window + locked `RegisterObjectType` insert). That is the native-engine extension beyond stock. Approach A is optional inside the lock. Measure before Approach D. Approach E is a host pattern, not native `asIScriptEngine` multithreaded registration.
