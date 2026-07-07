## 1. Record and API scaffold

- [ ] 1.1 <!-- Non-TDD --> Add `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypedBinds.h` for the typed facade, keeping `AngelscriptBinds.h` as the backend API.
- [ ] 1.2 <!-- TDD --> Add `TAngelscriptFunctionTraits` coverage for free functions, non-const member functions, const member functions, `const&` member functions, and supported captureless lambdas. Test full names: `Angelscript.CppTests.TypedBindDsl.FunctionTraits.FreeFunction`, `.MemberFunction`, `.ConstMemberFunction`, `.ConstRefMemberFunction`, `.CapturelessLambda`.
- [ ] 1.3 <!-- TDD --> Add `FAngelscriptBindClass<T>` with `.Method`, `.StaticFunction`, `.Property`, `.Constructor`, and `.ImplicitConstructor` forwarding to existing `FAngelscriptBinds`. Test full names: `Angelscript.CppTests.TypedBindDsl.BindClass.MethodRegistersExistingBackend`, `.StaticFunctionUsesNamespace`, `.PropertyRegistersMemberOffset`, `.ConstructorRegistersBehaviour`, `.ImplicitConstructorMarksImplicit`.

## 2. Options and overload support

- [ ] 2.1 <!-- TDD --> Add a bind-result wrapper with chainable `.NoDiscard()`, `.EditorOnly()`, `.Deprecated()`, `.Trivial()`, `.TrivialNativeMethod()`, and `.TrivialNativeConstructor()` options. Tests: `Angelscript.CppTests.TypedBindDsl.Options.NoDiscardMatchesBackend`, `.EditorOnlyMatchesBackend`, `.DeprecatedMatchesBackend`, `.TrivialNativeMethodMatchesBackend`, `.TrivialNativeConstructorMatchesBackend`.
- [ ] 2.2 <!-- TDD --> Add explicit overload helper support for member and free functions. Tests: `Angelscript.CppTests.TypedBindDsl.Overload.MemberFunctionRequiresExplicitSignature`, `.FreeFunctionRequiresExplicitSignature`, `.OperatorOverloadBindsSelectedSignature`.
- [ ] 2.3 <!-- Non-TDD --> Keep the options bridge compatible with either `FBoundFunction` / `FBoundProperty` or the legacy previous-bind APIs, depending on which bind refactor has landed when this change is implemented.

## 3. Representative migration

- [ ] 3.1 <!-- TDD --> Migrate `Bind_FColor.cpp` to the typed DSL for constructors, `DWColor`, ordinary methods, operator overloads, and class namespace static functions while preserving global variables.
- [ ] 3.2 <!-- TDD --> Add binding integration tests that compile and execute AS code using migrated `FColor` APIs. Test full names: `Angelscript.TestModule.Bindings.TypedBindDsl.FColorConstructors`, `.FColorProperties`, `.FColorMethods`, `.FColorNamespaceFunctions`.
- [ ] 3.3 <!-- Non-TDD --> If `Bind_FColor.cpp` exposes API gaps, document them in `design.md` and keep complex or unsuitable callsites on raw `FAngelscriptBinds` rather than forcing the DSL.

## 4. Verification

- [ ] 4.1 <!-- Non-TDD --> Build: `Tools\RunBuild.ps1`.
- [ ] 4.2 <!-- Non-TDD --> Focused core tests: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.TypedBindDsl." -Label typed-bind-dsl -TimeoutMs 600000`.
- [ ] 4.3 <!-- Non-TDD --> Focused binding tests: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.TypedBindDsl." -Label typed-bind-dsl-bindings -TimeoutMs 600000`.
- [ ] 4.4 <!-- Non-TDD --> Broader binding sanity: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-typed-dsl -TimeoutMs 600000`.
- [ ] 4.5 <!-- Non-TDD --> Validate OpenSpec: `openspec validate "refactor-as-typed-bind-dsl" --strict --json`.
