## Context

`FAngelscriptEngine` is declared as a `USTRUCT` in `AngelscriptRuntime/Core/AngelscriptEngine.h`, but that only makes the struct type visible to Unreal's generated code. It does not make the engine's real runtime state broadly observable through UE reflection because only a few object references are `UPROPERTY` fields today.

Most of the remaining fields are not valid or safe `UPROPERTY` candidates:

- AngelScript VM internals such as `asCScriptEngine*`, `asCContext*`, `asIScriptModule*`, and `asIScriptFunction*`.
- Runtime ownership fields such as `TUniquePtr<FAngelscriptTypeDatabase>`, `TUniquePtr<FAngelscriptBindState>`, `FBlueprintEventSignatureRegistry`, `FStaticJIT`, and precompiled data.
- Threading and synchronization fields such as `FCriticalSection`, volatile hot-reload flags, and context pools.
- Injected dependencies and hooks such as `TFunction<>` callbacks and delegate containers.
- Cache maps keyed by non-reflected pointer types or storing private descriptor objects.

Changing those members into reflected fields would make UHT reject the type in many places and would also give GC/serialization systems misleading ownership signals. The correct shape is a separate reflection-visible state view that reports the state of those members without owning them.

## Goals / Non-Goals

**Goals:**

1. Provide a UE-reflectable observation surface for `FAngelscriptEngine` state.
2. Represent as many high-value engine member categories as practical with safe reflected values: direct values, object references/paths, presence flags, counts, name lists, or limited summaries.
3. Keep `FAngelscriptEngine` as the single runtime owner of AngelScript VM resources and plugin services.
4. Make state-view reflection testable through `UScriptStruct` and `FProperty` enumeration.
5. Keep the first implementation small enough to be used by editor/debug tooling later without requiring editor-module dependencies.

**Non-Goals:**

- Converting every `FAngelscriptEngine` member into a real `UPROPERTY`.
- Serializing or duplicating the underlying AngelScript VM.
- Making `FAngelscriptEngine` a `UObject`.
- Exposing private descriptor/cache objects as mutable public API.
- Replacing the existing CSV state dump system.
- Adding a Blueprint function library or editor query UI in this change.

## Decisions

### D1: Add a reflectable state value view instead of reflecting engine internals directly

Create a top-level `USTRUCT(BlueprintType)` named `FAngelscriptEngineReflectionSnapshot` in `AngelscriptEngine.h` (or a nearby runtime header included by it if the implementation wants to keep the header smaller). The type is the concrete value carrier for the `feature-as-engine-reflectable-state` capability. `FAngelscriptEngine` gains:

```cpp
FAngelscriptEngineReflectionSnapshot CaptureReflectionSnapshot() const;
```

The captured value contains only UHT-supported fields and owns no VM resources. The live engine remains the authoritative source of truth.

Alternatives considered:

- **Direct `UPROPERTY` conversion for all members**: rejected because many member types cannot be reflected and raw runtime resources must not be owned by GC/serialization.
- **Make the engine a `UObject`**: rejected because it would change construction, destruction, shutdown, and global-engine ownership semantics.
- **Use only `AngelscriptStateDump` CSV output**: rejected because CSV is an external diagnostics export, not an in-process UE reflection surface.

### D2: Model non-reflectable members as observation summaries

The reflectable state view uses safe projections for each field category:

| Engine member category | State-view representation |
| --- | --- |
| `bool`, `int32`, `double`, `FString`, `FName`, `TArray<FString>` | Direct reflected value |
| `UObject` / `UPackage` / settings pointers | Reflected object pointer when safe, plus path/name strings where useful |
| Raw AS VM pointers | `bHas*` flags and optional pointer-address strings for diagnostics |
| `TMap` / `TSet` / `TArray` caches | Counts and optional name/path previews |
| Diagnostics maps | file count, message count, error/warning/info counts, dirty flags |
| Active modules | module count and module names |
| Hot reload queues | queued-change counts and last-change time |
| Owned subsystems (`TypeDatabase`, `BindState`, JIT, DebugServer, coverage) | presence flags and stable public counts where existing public accessors exist |
| Thread locks / callbacks / injected dependencies | presence/configuration flags, not reflected internals |

The first pass does not need a perfect field-for-field UI. It should cover most high-value internal member groups and leave low-value or unsafe details behind conservative summaries.

### D3: Keep state capture const and side-effect free

`CaptureReflectionSnapshot()` must read current engine state and allocate only value-view storage. It must not initialize the engine, compile modules, emit diagnostics, mutate hot reload queues, or acquire long-lived ownership.

If a value would require intrusive access or side effects, expose a conservative placeholder such as `bHasX`, `XCount`, or a summary entry. Low-value fields can be omitted when the surrounding category is already represented.

### D4: Defer Blueprint function-library access

The first implementation includes only the reflected state-view type and the C++ `FAngelscriptEngine::CaptureReflectionSnapshot()` method. A `UBlueprintFunctionLibrary` or editor query wrapper is deferred until a concrete tool or Blueprint consumer exists.

Rationale: The user's core requirement is UE reflection visibility. A reflected value struct plus C++ capture API satisfies that and avoids committing to Blueprint API shape before a UI consumer exists.

### D5: Tests validate reflection metadata and live values

Add tests under `Plugins/Angelscript/Source/AngelscriptTest/Core/`, using the existing runtime integration layer and prefix:

```text
Angelscript.TestModule.Engine.ReflectableState.*
```

The tests should verify:

- `FAngelscriptEngineReflectionSnapshot::StaticStruct()` exists.
- Expected `FProperty` names are discoverable.
- Capturing a value view from a initialized test engine reports expected stable values such as script-engine presence, package/settings presence, initial compile flags, module count, diagnostics count, and script root path count.
- Adding a diagnostic through existing engine APIs is reflected in diagnostic summary fields.

## Risks / Trade-offs

- **Risk: Reflectable state view drifts from engine fields as `FAngelscriptEngine` evolves.** Mitigation: include a test that verifies representative high-value field groups, and add a task to document the mapping categories near the value struct.
- **Risk: Reflectable state view becomes too large or noisy.** Mitigation: first implementation groups internals into summaries and previews instead of mirroring every map entry.
- **Risk: Pointer-address strings encourage consumers to depend on unstable identities.** Mitigation: pointer strings are diagnostic-only and should be omitted unless needed; prefer presence flags and counts.
- **Risk: Capturing while hot reload or compile is mutating state can observe a transient value.** Mitigation: document the view as best-effort diagnostic state; do not add locks beyond existing safe read patterns unless tests reveal a real data race.
- **Risk: Blueprint exposure is requested later.** Mitigation: design keeps the reflected value in `AngelscriptRuntime`, so a function library or editor panel can be added without changing the value-view contract.

## Migration Plan

1. Add the reflectable state struct(s) and the const capture API without changing existing engine ownership.
2. Add failing reflection metadata and value tests under the engine test scope.
3. Implement value population using existing public or same-class access to engine fields.
4. Build and run the focused engine reflectable state tests.
5. Run a broader engine-prefix regression to catch lifecycle or header/UHT issues.

Rollback is straightforward: remove the additive reflectable state structs, capture API, and tests. No existing runtime behavior or serialized data is migrated.

## Open Questions

- Whether pointer-address diagnostic strings are useful enough to include, or whether presence flags and counts are sufficient.
- How many preview entries to expose for maps/sets such as active modules, diagnostics, and hot reload queues. The recommended default is a small fixed cap such as 16 entries.
