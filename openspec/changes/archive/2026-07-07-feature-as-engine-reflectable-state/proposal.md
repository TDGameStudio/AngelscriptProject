## Why

`FAngelscriptEngine` is already a `USTRUCT`, but most of its operational state is invisible to UE reflection because the real members are raw AngelScript pointers, locks, smart pointers, injected callbacks, and internal caches that cannot safely become `UPROPERTY` fields. We need a reflection-visible observation surface that lets UE tooling inspect engine state without making the runtime owner itself serializable or GC-managed.

## What Changes

- Add a new reflectable engine-state capability for `FAngelscriptEngine`.
- Introduce one or more `USTRUCT(BlueprintType)` value structs whose fields are safe UE-reflectable views of engine state.
- Add a const capture API on `FAngelscriptEngine` that populates the value view from the live engine.
- Expose high-value internal-resource categories through observation fields such as presence flags, counts, names, object paths, and limited summaries rather than raw `UPROPERTY` ownership.
- Add tests proving the reflectable state struct is visible through `UScriptStruct` / `FProperty` enumeration and that key fields reflect the current engine state.
- Do not convert raw AngelScript VM resources, thread primitives, injected callbacks, or ownership-only pointers into real `UPROPERTY` members.

## Capabilities

### New Capabilities

- `as-engine-reflectable-state`: Defines the reflection-visible state observation surface for observing `FAngelscriptEngine` through UE's property system.

### Modified Capabilities

- None.

## Impact

- **AngelscriptRuntime**: `Core/AngelscriptEngine.h/.cpp` gains reflectable state view types and a capture API; implementation reads existing engine fields without changing ownership or initialization semantics.
- **Deferred runtime API**: A Blueprint/editor query wrapper is not part of the first implementation; it can be added later when a concrete consumer exists.
- **AngelscriptTest**: Runtime integration tests are added or updated under the existing engine test scope to validate reflection metadata and state-view values.
- **No breaking runtime ownership change**: The live engine still owns AS VM resources directly; reflected fields are value summaries, object references already safe for reflection, or string/count diagnostics.
- **No new module dependency**: The change stays within `AngelscriptRuntime` and existing test dependencies.
