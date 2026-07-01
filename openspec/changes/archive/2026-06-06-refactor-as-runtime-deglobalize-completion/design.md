# Design: refactor-as-runtime-global-state

## Context

The immediate failing point is `FString::Format`, but the real target is runtime deglobalization. The project had already removed `GAngelscriptEngine`, and engine discovery had moved to ContextStack / subsystem ownership, but bind and type-system code still had legacy/static storage capable of retaining engine-owned AngelScript objects.

Deglobalization classification rules:

- May remain global: pure registration descriptors, UE reflection objects, names, configuration, replayable bind callbacks.
- Must be deglobalized: objects created and destroyed by a specific `asIScriptEngine`, such as `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, `asCContext*`.
- Must be audited: legacy fallback storage, because these usually support old "no current engine" paths and can hide cross-engine state.

`TGetStaticTypeInfo<T>::TypeInfo` was the first reproduced issue: binding `FString` / `FText` wrote the current engine's `asITypeInfo*` into a process-wide static, and later format argument conversion compared the current engine's type object against that stale historical pointer.

## Narrow Failure Chain

1. Engine A binds `FString`, storing Engine A's `asITypeInfo*` in `TGetStaticTypeInfo<FString>::TypeInfo`.
2. Engine B becomes current and executes `FString::Format("{0}", "Hello")`.
3. The format string itself is read directly as `FString`; the checked argument is the second parameter (`{0}`).
4. Engine B resolves the argument type id to Engine B's `FString` type object.
5. Pointer comparison against Engine A's cached `TypeInfo` fails even though both types are named `FString`.
6. The formatter throws the invalid-argument branch.

Historical note: commit `679704f` had an explicit `FString TypeInfo is per script engine` fallback that also accepted `TypeInfo->GetName() == "FString"`. Commit `4140354` removed that fallback and exposed the stale global cache again. That fallback proves the observed failure mode, but the durable fix is engine-scoped caching rather than name-only acceptance.

## Goals / Non-Goals

**Goals:**

1. Use deglobalization as the main thread and establish runtime state layering rules plus processing order.
2. Move confirmed process-wide state that stores engine-owned AS objects to engine-owned / engine-keyed / lifecycle-cleared structures.
3. Handle `TGetStaticTypeInfo<T>` first because it has a stable reproduced failure chain through `FString::Format`.
4. Cover both `FString::Format` and `FText::Format`, because they share the same static TypeInfo pattern.
5. Classify similar state into "handle immediately / audit then handle / safe to keep" so global registries are not blindly deleted.

**Non-Goals:**

- Do not rewrite the full bind system.
- Do not remove global registries that store only metadata.
- Do not use name comparison as the final architecture; name fallback is only a short-term stopgap.
- Do not replace the standard build/test entry points.

## Technical Approach

### A1. State ownership classification first

Classify each runtime state location by what it stores before deciding migration shape:

| Class | Contents | Handling |
|---|---|---|
| Engine-owned AS objects | `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, `asCContext*` | Must move into `FAngelscriptEngine`, be partitioned by engine key, or be cleared during engine teardown |
| Engine-derived mutable state | State depending on current engine bind order, type database, or script enum lookup | Prefer moving into `FAngelscriptEngine`; if fallback remains, prove it cannot read/write across engines |
| Replayable metadata | bind descriptors, function pointers, UE reflection objects, names, configuration | Can remain global, but must not cache AS runtime objects |
| Scoped acceleration cache | TLS / RAII short-lived acceleration cache | Can remain if it expires at scope end and does not expose objects across engines |

### A2. First migration: `TGetStaticTypeInfo<T>`

Change `TGetStaticTypeInfo<T>` from "one global AS pointer per C++ type" to "one AS pointer per engine."

Target behavior:

- Bind phase records both `asITypeInfo*` and the engine that created it.
- Read phase only returns the `asITypeInfo*` for the current engine.
- Engine shutdown clears that engine's entries before AS engine release.
- `FString::Format` / `FText::Format` keep fast pointer comparison, but compare against the current engine's type object.

Acceptable shape:

- Keep `TGetStaticTypeInfo<T>` as the entry point to avoid spreading bind call-site changes.
- Add operations such as `SetForCurrentEngine(TypeInfo)` / `GetForCurrentEngine()` / `ClearForEngine(...)`.
- Key can be `FAngelscriptEngine*` or `asIScriptEngine*`, but there must be a clear cleanup point to avoid address-reuse false positives.

### A3. Second migration candidates

These are not all rewritten immediately. Each is confirmed by asking whether it stores an AS runtime object and whether that object can be read across engines:

- `GScriptEnumTypeLookupByName`: global `FName -> asITypeInfo*`; must move into engine storage or engine partitioning.
- `LegacyToStringList`: `FToStringType` contains `asITypeInfo*`; legacy fallback should store metadata only, or prove it is never read across engines after bind.
- `LegacyDatabase` / `LegacyBindState` / `LegacyBindDatabase`: mostly descriptor data, but must confirm whether type finder / previous-bound-index logic depends on current engine.
- `GAngelscriptContextPool`: TLS context pool already matches by `DesiredScriptEngine` when taking/returning contexts; must confirm engine teardown covers all pooled contexts.

### A4. Regression chain

Regression tests must prove not only single-engine success, but that state left by a previous engine does not pollute the next engine.

Acceptance chain:

1. Engine A completes bind and writes the state involved in the old issue.
2. Engine A tears down, or execution switches to Engine B.
3. Engine B executes `FString::Format("{0}", "Hello")` and returns `Hello`.
4. Engine B executes the equivalent `FText` formatting path or shared TypeInfo cache verification.
5. If enum / ToString fallback is migrated, add the matching cross-engine sequence or teardown case.

## Similar Global State Inventory

### P0: Deglobalize immediately

- `Binds/Helper_GetTypeInfo.h`: `TGetStaticTypeInfo<T>::TypeInfo` is a process-wide `asITypeInfo*`; this is the current root cause.
- `Binds/Bind_FString.cpp` / `Binds/Bind_FText.cpp`: format path depends on the static TypeInfo above and forms the first acceptance chain.

### P1: High risk, audit and preferably close in this change

- `Binds/Bind_UEnum.cpp`: `GScriptEnumTypeLookupByName` is process-wide `FName -> asITypeInfo*`.
- `Binds/Bind_FString.cpp`: `LegacyToStringList` is a legacy fallback whose element type `FToStringType` can carry `asITypeInfo*`.

### P2: Medium risk, confirm whether engine-owned objects are actually stored

- `Core/AngelscriptType.cpp`: `LegacyDatabase` is fallback `FAngelscriptTypeDatabase`.
- `Core/AngelscriptBinds.cpp`: `LegacyBindState` is a fallback bind-state registry.
- `Core/AngelscriptBindDatabase.cpp`: `LegacyBindDatabase` is fallback bind metadata.
- `Core/AngelscriptEngine.cpp`: `thread_local FAngelscriptContextPool GAngelscriptContextPool` stores `asCContext*`, but already has containment logic that matches/releases by script engine.

### P3: Safe to keep, but must not become AS pointer caches

- Static `FName`, config switches, console variables.
- Bind extension registry that stores replayable registration logic.
- Caches that store only UE reflection objects, names, function pointers, and declaration text.
- RAII/TLS temporary caches such as `FScopedBindCaches`, as long as they expire at scope end.

## Decision

Proceed along the "runtime AS object deglobalization" thread. `FString::Format` is not a standalone hotfix; it is the first reproducible acceptance chain.

Recommended execution order:

1. Record state layering and inventory, clarifying which global state must be handled.
2. Move `TGetStaticTypeInfo<T>` to engine-scoped storage.
3. Use `FString` / `FText` format to prove current-engine type identity is stable.
4. Continue with `GScriptEnumTypeLookupByName` and `LegacyToStringList`.
5. Audit legacy database / bind state / context pool, keep pure metadata, and remove any AS runtime object cross-engine leakage.

## Risks / Trade-offs

- **Expanded migration surface**: the main thread expands from a formatting regression to deglobalization and touches more state. Mitigation is P0/P1/P2 staging rather than rewriting every legacy fallback at once.
- **Cleanup order**: engine-owned AS pointers must be removed before AS engine release, or later address reuse may create new false positives.
- **Fallback compatibility**: name comparison can temporarily stop the failure, but it cannot be the final structure because it would keep hiding cross-engine state leaks.
- **Legacy fallback uncertainty**: some fallback paths may only serve static initialization. First prove whether they store AS runtime objects, then decide whether to migrate or keep them.
