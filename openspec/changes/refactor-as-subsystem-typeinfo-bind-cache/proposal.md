## Why

Every full `FAngelscriptEngine` currently replays every sealed `Bind_*.cpp` lambda into that engine's `asIScriptEngine`. The lambdas mix three jobs: decide the bind surface, walk UE reflection, and call `Register*`. A second Engine (tests, StaticJIT generation) pays that cost again, and the expanded per-type surface never becomes a queryable process object. The plugin already has a process-wide callback table; it still has no per-type snapshot that an Engine can apply.

## What Changes

- Introduce `FAngelscriptTypeBindInfo` as the process-level record of **one** AngelScript-visible type (value, object, enum, interface, template, or namespace). It stores declarations, members, traits, native recipes, and bind-surface conditions. It MUST NOT store `asITypeInfo*`, `asIScriptFunction*`, or other engine-owned AngelScript pointers.
- `UAngelscriptSubsystem` owns the process `TArray<FAngelscriptTypeBindInfo>` (plus a name index). It coordinates expansion after the existing bind-callback collection is sealed and before primary-engine registration.
- After generated modules load, expand bind Register functions into that array through a recording `FAngelscriptBinds` backend. `FAngelscriptBind` stays the CRT discovery object; there is no `FAngelscriptTypeBindInfoProvider`. Expand is one recording phase: a bind callback may record type, methods, adapter, and the rest of that surface. `EAngelscriptBindPhase` is not an expand schedule for migrated files; `EApplySlot` on each member is the metadata Apply uses for `RegisterObjectType` before `RegisterObjectMethod`. Eligible Explicit Register functions MAY expand on worker threads into private shards that merge into the subsystem array. Reflection / UObject walks stay on the Game Thread. Conditions (`EditorScripts`, `SimulateCooked`, editor-only, compile-out policy) are recorded on the type or member, not applied as a one-shot Editor-only snapshot.
- When an `FAngelscriptEngine` binds, it registers **allowlisted** types from the subsystem TypeBindInfo array filtered by that engine's surface. Unrecorded providers still `ExecuteRegisteredBinds`. Per-engine `FAngelscriptType` adapters are rebuilt from recorded recipes into that engine's TypeDB; they are not stored in the array. v1 keeps `as.BindFromTypeBindInfo` default 0 and does not Apply a whole engine from a partial store.
- **BREAKING** (architecture overturn): `UAngelscriptSubsystem` now retains expanded per-type bind data. This overturns the earlier direct-callback non-goal that the subsystem stores no binding content, and the Generate-change note that process-level bind snapshots are out of scope. Bind files remain; a migrated file has one Register function per type family, not seven phase lambdas. `EAngelscriptBindPhase` remains only as compatibility on unmigrated `FAngelscriptBind` until those files migrate.
- Concurrent `Register*` into one live `asIScriptEngine` is **not** this change. It is a recorded follow-on that needs AngelScript engine atomic/threaded registration. The sealed `TArray` is the catalog, not a concurrent write buffer.

## Capabilities

### New Capabilities

- `as-subsystem-typeinfo-bind-cache`: per-type `FAngelscriptTypeBindInfo`, subsystem-owned array, recording expansion (including parallel eligible providers), surface conditions, and Engine apply-from-TypeInfo registration.

### Modified Capabilities

- `as-engine-scoped-runtime-state`: process-level TypeInfo is allowed replayable metadata; engine-owned `asITypeInfo*` remains forbidden in that array.
- `as-bind-execution-timing`: observe TypeInfo expand and Engine apply as distinct passes, not only per-lambda `CallBinds` / `ExecuteRegisteredBinds`.

## Impact

- Runtime Core: TypeBindInfo types, recording/apply backends, `UAngelscriptSubsystem` store, `FAngelscriptEngine` bind path. `FAngelscriptBind` gains a `RegisterKind` constructor; the class stays.
- `Bind_*.cpp`: v1 unmigrated lambdas still `ExecuteRegisteredBinds` per engine. Migrated files become one Register function per type family on the same `FAngelscriptBind` callback type (`FAngelscriptBinds&`). Live `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod` for those types moves to Apply.
- Tests: Engine subsystem, bind isolation, BindingArchitecture, Bindings CQTest, StaticJIT NativeForms (recipes still recorded).
- Related but separate: `refactor-as-primary-engine-typed-ast-generate` function native-form catalog MAY later read TypeInfo member recipes; this change does not implement matching-profile Generate or Cache V2 HIR.
- AngelScript fork thread-safety for concurrent `Register*` is follow-on only.
