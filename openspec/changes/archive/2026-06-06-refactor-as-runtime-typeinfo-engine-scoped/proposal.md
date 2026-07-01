# refactor-as-runtime-typeinfo-engine-scoped

## Why

`refactor-as-runtime-global-state` had become a mixed-scope change: `tasks.md` showed 0/15, but the code state showed that TypeInfo, legacy fallback, and ContextPool work had already landed. Keeping both "already landed" and "not yet landed" state in one change makes OpenSpec stop being a useful record, so the completed portion needed to be extracted and archived as a baseline.

The extracted scope is the set of runtime facts already visible in code:

- In `Binds/Helper_GetTypeInfo.h`, `TGetStaticTypeInfo<T>` has changed from a single process-wide `asITypeInfo*` to an engine-keyed `TMap<asIScriptEngine*, asITypeInfo*>`, with `SetForEngine` / `GetForEngine` / `IsForEngine` / `ClearForEngine`.
- `Core/AngelscriptEngine.cpp` calls `FAngelscriptStaticTypeInfoRegistry::ClearForEngine` on the engine teardown path, clearing TypeInfo entries for the outgoing engine before the AS engine is released.
- The `Bind_FString.cpp` / `Bind_FText.cpp` format paths all use the new API, with no remaining direct `TGetStaticTypeInfo<T>::TypeInfo` access.
- The three legacy fallback registries (`AngelscriptType.cpp::LegacyDatabase`, `AngelscriptBinds.cpp::LegacyBindState`, `AngelscriptBindDatabase.cpp::LegacyBindDatabase`) were audited and only store UE metadata, not AS runtime objects exposed across engines.
- `GAngelscriptContextPool` calls `ReleaseContextsForScriptEngine` during engine teardown to release contexts for a disappearing engine.

The remaining enum lookup deglobalization, ToString fallback fence, and multi-engine format regression tests do not belong to this change; they are handled by later `refactor-as-runtime-globals-enum-and-tostring` work. The eight `FAngelscriptClassGenerator` static delegates are handled by the separate `refactor-as-classgen-engine-owned-hooks` work.

## What Changes

This change does not modify code; every target fact was already completed in historical commits. Its only purpose is to:

- Record the implemented facts as ADDED requirements in capability `as-engine-scoped-runtime-state`.
- Make the baseline spec show the established portion of the deglobalization work, so later enum / ToString changes can build on it with MODIFIED deltas.

## Capabilities

### New Capabilities

- **as-engine-scoped-runtime-state**: defines storage rules for runtime state that references AS engine-owned objects, covering the already-landed facts for engine-keyed TypeInfo, teardown cleanup, legacy fallback metadata constraints, and context-pool engine-keyed teardown.

### Modified Capabilities

- None.

## Impact

- OpenSpec files only.
- The related implementation under `Plugins/Angelscript/Source/AngelscriptRuntime/` was already completed; this change has no code impact.
- Later `refactor-as-runtime-globals-enum-and-tostring` work applies MODIFIED deltas on top of the baseline spec established here.
