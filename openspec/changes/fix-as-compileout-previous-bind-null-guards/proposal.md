## Why

Remote PR #1 exposed one small defensive gap that is still present locally: `CompileOutPreviousBind()` and `CompileOutPreviousBindAsMethodChain()` directly dereference the previous bind lookup. Other compile-out helpers already tolerate failed bind registration by returning when `GetFunctionById()` is null; these two helpers should match that behavior.

## What Changes

- Add null guards to previous-bind compile-out helpers.
- Keep the helpers as no-op when the previous bind registration failed or no longer resolves to a script function.
- Preserve current behavior when the previous bind is valid.
- Add focused regression coverage or document the narrowest feasible validation if the failed-bind path is not directly injectable.

## Capabilities

### New Capabilities

- `as-compileout-bind-safety`: Defensive behavior for compile-out bind helpers when bind registration fails.

### Modified Capabilities

- None.

## Impact

- Affected code: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`.
- Likely tests: `Plugins/Angelscript/Source/AngelscriptTest/Core/` or an existing bind-config test if it can exercise a failed previous bind.
- No public API, data format, or script behavior change is intended for valid bindings.
