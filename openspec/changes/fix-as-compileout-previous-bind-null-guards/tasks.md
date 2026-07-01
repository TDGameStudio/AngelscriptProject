## 1. Source Update

- [x] 1.1 Replace `CompileOutPreviousBind()` direct `GetFunctionById(GetPreviouslyBoundFunctionRef())` lookup with guarded `GetPreviousBind()` usage.
- [x] 1.2 Replace `CompileOutPreviousBindAsMethodChain()` direct lookup with guarded `GetPreviousBind()` usage.
- [x] 1.3 Confirm adjacent compile-out and previous-bind mutators still no-op consistently for null script functions.

## 2. Regression Coverage

- [x] 2.1 Add a private static no-op CDECL helper to `AngelscriptBindsRegistrationTests.cpp` for failed object-method registration.
- [x] 2.2 Add a `CompileOutPreviousBindHelpersIgnoreFailedRegistration` test under `Angelscript.TestModule.Engine.Binds`.
- [x] 2.3 In the test, use `FAngelscriptBinds::ExistingClass()` with an unregistered unique type name, bind a method, assert the returned id and `GetPreviousFunctionId()` are negative, and assert `GetPreviousBind()` is null.
- [x] 2.4 Suppress or expect only the intentional AngelScript config error emitted by the failed registration.
- [x] 2.5 Call both previous-bind compile-out helpers and assert the failed previous-bind id and null lookup remain unchanged.

## 3. Verification

- [x] 3.1 Run `Tools\RunBuild.ps1 -Label compileout-previous-bind-build -TimeoutMs 1800000 -NoXGE`.
- [x] 3.2 Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.Binds" -Label compileout-previous-bind-binds -TimeoutMs 600000`.
- [x] 3.3 Run `openspec validate fix-as-compileout-previous-bind-null-guards --strict --json`.
