## Why

`UAngelscriptActorLibrary::GetAttachedActorsOfClass` currently dereferences a null actor and returns every attached actor when the requested class is null. Both paths make a script-visible helper unsafe and differ from the expected empty-result contract used by other guarded actor helpers. Hazelight fixed this narrow regression in commit `6948712ac8cd`.

## What Changes

- Return an empty array when `GetAttachedActorsOfClass` receives a null actor.
- Return an empty array when `GetAttachedActorsOfClass` receives a null actor class.
- Add regression coverage for normal class filtering, null class, and null actor inputs.
- Keep all other Hazelight candidates, including `FBox3f`, `FAssetData`, Blueprint parent discovery, and curve API extensions, outside this change.

## Capabilities

### New Capabilities

- `actor-attached-actor-query`: Define the safe result contract for querying attached actors by class.

### Modified Capabilities

None.

## Impact

- Runtime helper: `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptActorLibrary.h`.
- UE functional regression tests: `Plugins/Angelscript/Source/AngelscriptTest/Functional/Actor/AngelscriptActorMixinTests.cpp`.
- No module dependencies, public type signatures, or unrelated bindings change.
