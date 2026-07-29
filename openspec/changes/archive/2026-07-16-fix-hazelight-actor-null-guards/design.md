## Context

`UAngelscriptActorLibrary` is registered as an `AActor` script mixin. `GetAttachedActorsOfClass` first queries the actor's attached actors and then filters the result by `ActorClass`. The current implementation assumes both inputs are valid: a null actor is dereferenced, while a null class skips filtering and returns all attached actors.

The fix is intentionally limited to this helper and its existing functional test file. The plugin remains a submodule; OpenSpec records live in the parent repository and production/test source changes live in `Plugins/Angelscript`.

## Goals / Non-Goals

**Goals:**

- Make null actor and null class calls return an empty array without dereferencing invalid inputs.
- Preserve the current filtering behavior for valid actors and valid classes.
- Exercise all three paths through the existing AngelScript `AActor` mixin surface.

**Non-Goals:**

- Do not change `GetAttachedActors` or other actor helpers.
- Do not add a new API, exception type, logging behavior, or output-array contract.
- Do not adopt the unrelated Hazelight `FBox3f`, `FAssetData`, Blueprint, or curve changes.

## Decisions

- Guard `Actor` before calling `GetAttachedActors`, because this is the only safe point before dereferencing the receiver.
- Guard `ActorClass.Get()` before querying or filtering, because a null requested class has no meaningful match and must produce an empty result.
- Return the already-created empty `TArray<AActor*>` for both invalid-input cases. This matches the helper's return shape and avoids introducing script-visible exceptions.
- Keep the existing reverse-removal filter unchanged for valid inputs, minimizing behavior change and preserving `EAllowShrinking::No`.
- Add one scenario-focused CQTest method to the existing Actor mixin test class. Its inline fixture exercises valid filtering and null-class behavior through the AngelScript mixin; the null-actor case calls the static library entry from C++ so the test reaches the native guard instead of AngelScript's null receiver short-circuit.

## Risks / Trade-offs

- [Risk] Existing callers may have relied on a null class returning all attached actors. → [Mitigation] Treat that behavior as the identified bug; document and test the new empty-result contract.
- [Risk] Calling the null actor path on the old implementation can terminate the test process through an access violation. → [Mitigation] The regression is isolated in the Actor test process and the null-class path provides a controlled pre-fix failure; run the native null-actor assertion after the guard is implemented.

## Migration Plan

No data or configuration migration is required. The source and regression test changes are compiled together; rollback is limited to reverting the two plugin-submodule file changes and the parent OpenSpec record.

## Open Questions

None.
