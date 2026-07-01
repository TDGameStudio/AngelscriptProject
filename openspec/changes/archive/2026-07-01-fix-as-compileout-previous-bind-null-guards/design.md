# Compile-Out Previous Bind Null Guard Design

## Context

`FAngelscriptBinds::CompileOutInTest`, `CompileOutIfNoLog`, `CompileOutAsEnsure`, `CompileOutAsCheck`, and `CompileReplaceWithFirstArgInTest` already handle a null `asCScriptFunction*`. Most previous-bind metadata mutators also use `GetPreviousBind()` and therefore no-op when the previous function id cannot be resolved.

The remaining direct dereferences are:

- `FAngelscriptBinds::CompileOutPreviousBind()`
- `FAngelscriptBinds::CompileOutPreviousBindAsMethodChain()`

The risk is narrow but real. `OnBind()` stores the last registration result even when registration failed, so `GetPreviousFunctionId()` can be a negative AngelScript error code. `GetFunctionById()` then returns null, and these two helpers currently dereference the null pointer while trying to set `compileOutType`.

## Goals / Non-Goals

**Goals:**

- Make both previous-bind compile-out helpers no-op when no previous script function exists.
- Preserve the current `compileOutType` changes for valid previous binds.
- Cover the failed-registration path through a focused Core bind test if it is stable in the local harness.

**Non-Goals:**

- Do not change bind registration error handling or hide the original AngelScript config error.
- Do not change `OnBind()` semantics for failed registration results.
- Do not add new public APIs or expose writable test hooks for previous bind state.

## Decisions

### Use `GetPreviousBind()` in both helpers

Replace the direct `Manager.Engine->GetFunctionById(GetPreviouslyBoundFunctionRef())` calls with the same pattern used by adjacent previous-bind mutators:

```cpp
if (auto* Function = (asCScriptFunction*)GetPreviousBind())
{
	Function->compileOutType = asECompileOutType::CompileOutEntirely;
}
```

and the equivalent `CompileOutAsMethodChain` assignment.

Rationale: `GetPreviousBind()` already handles the `-1` sentinel and centralizes the lookup. This keeps the compile-out helpers consistent with `DeprecatePreviousBind()`, `SetPreviousBindIsEditorOnly()`, `SetPreviousBindNoDiscard()`, and the other previous-bind metadata helpers.

Alternative considered: duplicate a local `Function == nullptr` guard after `GetFunctionById()`. That would fix the crash, but it leaves the two helpers inconsistent with the rest of the previous-bind API and repeats lookup details that already exist.

### Keep `OnBind()` unchanged

`OnBind()` currently writes `GetPreviouslyBoundFunctionRef() = FunctionId` regardless of whether `GetFunctionById(FunctionId)` succeeds. This change should not alter that behavior.

Rationale: storing the last registration result is broader bind-state behavior, and changing it could affect callers that inspect `GetPreviousFunctionId()` after a failed bind. The defect is only that two follow-up mutators assume the id resolves to a function.

Alternative considered: make `OnBind()` only update previous-bind state for valid functions. That is a wider behavior change and would weaken regression coverage for failed registrations.

### Exercise the real failed-registration path

Add the regression to `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindsRegistrationTests.cpp`, under the existing `Angelscript.TestModule.Engine.Binds` prefix.

The stable setup is:

1. Create an isolated test engine and enter `FAngelscriptEngineScope`.
2. Construct `FAngelscriptBinds MissingBinds = FAngelscriptBinds::ExistingClass(...)` with a unique type name that is not registered as an object type.
3. Call `MissingBinds.Method("void Missing()", &NoOpPreviousBindGuard)`.
4. Assert the returned id, `GetPreviousFunctionId()`, and `GetPreviousBind()` reflect a failed registration.
5. Call `CompileOutPreviousBind()` and `CompileOutPreviousBindAsMethodChain()`.
6. Assert the previous id is still the failed id and `GetPreviousBind()` is still null.

The expected AngelScript config error can be handled by temporarily suppressing the `Angelscript` log category with `UE_SET_LOG_VERBOSITY(Angelscript, Fatal)` plus `ON_SCOPE_EXIT`, matching existing tests that intentionally trigger script or bind errors. If the exact emitted diagnostic is stable after implementation, `AddExpectedError` is also acceptable, but the test should not depend on a fragile full diagnostic string.

## Risks / Trade-offs

- Failed bind test emits expected config noise -> suppress the local `Angelscript` log category around the one failing bind registration.
- CDECL method wrapper signature can be easy to get wrong -> use a private static no-op helper that accepts the object pointer first, and the existing `Method(FBindString, Value(CDECL *)(Args...), ...)` overload.
- A no-crash assertion is implicit -> also assert the previous id and null lookup before and after calling both helpers, so the test proves the failed-bind state survived the calls.

## Migration Plan

1. Patch the two helpers in `AngelscriptBinds.cpp`.
2. Add the focused Core bind regression test.
3. Run the narrow `Angelscript.TestModule.Engine.Binds` prefix, then build validation.

Exact validation commands:

- `Tools\RunBuild.ps1 -Label compileout-previous-bind-build -TimeoutMs 1800000 -NoXGE`
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.Binds" -Label compileout-previous-bind-binds -TimeoutMs 600000`
- `openspec validate fix-as-compileout-previous-bind-null-guards --strict --json`

## Open Questions

- None at this point. The current code exposes a stable failed-registration path without adding test-only hooks.
