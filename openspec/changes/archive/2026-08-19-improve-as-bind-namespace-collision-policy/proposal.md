## Why

`improve-as-library-namespace-canonicalization` makes multiple function libraries contribute to one public namespace (`FMath::` by default). Same-name bindings then split into exact duplicates (keep the existing declaration) and incompatible collisions (fail bind). A review of that work found that incompatible collisions already fail closed, but the diagnostic is overwritten on every later collision instead of keeping the first failure, and there is no bind-time count of how many exact-duplicates versus incompatible collisions actually occur. That follow-up must not be lost after the FMath change lands.

## What Changes

- Add bind-time observation for library-namespace collisions: per-event log plus per-engine counts for exact-duplicate suppressions and incompatible same-key collisions.
- Capture those counts from a real initialized engine (default mappings) and from the existing NotInAngelscript collision fixtures, then decide the remaining policy from evidence rather than from the review note alone.
- Align incompatible-collision diagnostic publication with `RecordRegistrationFailure`: first failure wins; later collisions still fail closed and still skip the incoming function.
- Keep exact-duplicate suppression as the canonicalization rule (do not turn exact duplicates into bind failures).
- Do not add `Math::` / `MathLibrary::` aliases while doing this follow-up.

## Capabilities

### New Capabilities

- `as-bind-namespace-collision-policy`: Bind-time observation, first-failure diagnostics, and exact-duplicate versus incompatible collision handling when multiple libraries share one canonical namespace.

### Modified Capabilities

None. Shared `openspec/specs/` does not yet contain `as-library-namespace-canonicalization` (that change is still in-flight). This follow-up adds a distinct diagnostic/policy capability rather than rewriting the unpublished FMath spec in place.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp` (`IsEquivalentScriptSignatureAlreadyBound`).
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` / `AngelscriptBinds.cpp` (`FAngelscriptBindState`, first-failure diagnostic).
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (`BindScriptTypes` summary log).
- Namespace tests in `Plugins/Angelscript/Source/AngelscriptTest/FunctionLibraries/AngelscriptLibraryNamespaceCanonicalizationTests.cpp`.
- Depends on, and must not contradict, `improve-as-library-namespace-canonicalization`.
- No Unreal header edits and no new runtime dependency.
