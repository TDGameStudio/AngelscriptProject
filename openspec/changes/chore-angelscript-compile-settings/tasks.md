## 1. Config And Build Rules

- [x] 1.1 <!-- Non-TDD --> Add `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompileOptions.h/.cpp` with `UAngelscriptCompileOptions`.
- [x] 1.2 <!-- Non-TDD --> Register `UAngelscriptCompileOptions` as `Project / Plugins / AngelscriptCompileOptions` in `AngelscriptEditorModule.cpp`, and unregister it during shutdown.
- [x] 1.3 <!-- Non-TDD --> Create `Config/DefaultAngelscriptCompileOptions.ini` with `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]` and `bCompileAngelscriptUnitTests=false`.
- [x] 1.4 <!-- Non-TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` to add `Config/DefaultAngelscriptCompileOptions.ini` to `ExternalDependencies` when `Target.ProjectFile` is available.
- [x] 1.5 <!-- Non-TDD --> Add a small config reader in `AngelscriptTest.Build.cs` that reads `bCompileAngelscriptUnitTests` from `DefaultAngelscriptCompileOptions.ini` with a deliberate default.
- [x] 1.6 <!-- Non-TDD --> Add `PrivateDefinitions.Add("WITH_ANGELSCRIPT_UNITTESTS=0/1")` from the parsed setting.
- [x] 1.7 <!-- Non-TDD --> Keep `UAngelscriptCompileOptions` separate from existing `UAngelscriptSettings` and any future generic Angelscript editor settings class.

## 2. Test Registration Gate

- [x] 2.1 <!-- Non-TDD --> Inspect `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestMacros.h`, `AngelScriptSDK/AngelscriptTestAdapter.h`, and `AngelscriptTestModule.cpp` for central registration paths.
- [x] 2.2 <!-- TDD --> Add or update a narrow compile-time validation test that proves the `WITH_ANGELSCRIPT_UNITTESTS` definition is visible to `AngelscriptTest` code.
- [x] 2.3 <!-- Non-TDD --> Gate centralized Angelscript unit test registration paths with `#if WITH_ANGELSCRIPT_UNITTESTS`.
- [x] 2.4 <!-- Non-TDD --> Search for direct `IMPLEMENT_SIMPLE_AUTOMATION_TEST`, `DEFINE_SPEC`, or CQTest registration patterns that bypass the central gate and add the smallest local gates needed.

## 3. Documentation

- [x] 3.1 <!-- Non-TDD --> Document `DefaultAngelscriptCompileOptions.ini` and `bCompileAngelscriptUnitTests` in `Documents/Guides/Build.md`.
- [x] 3.2 <!-- Non-TDD --> Document that `Tools\RunTests.ps1` requires a build with `bCompileAngelscriptUnitTests=true` for Angelscript C++ automation tests.
- [x] 3.3 <!-- Non-TDD --> Update plugin-facing README material if consumer builds should default to tests disabled.

## 4. Verification

- [x] 4.1 <!-- Non-TDD --> Run `Tools\RunBuild.ps1` with `bCompileAngelscriptUnitTests=false`; expected result: editor build succeeds and Angelscript unit test registration is omitted.
- [x] 4.2 <!-- Non-TDD --> Change `Config/DefaultAngelscriptCompileOptions.ini` to `bCompileAngelscriptUnitTests=true` and rerun `Tools\RunBuild.ps1`; expected result: UBT invalidates the makefile because `DefaultAngelscriptCompileOptions.ini` was modified.
- [x] 4.3 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -TimeoutMs 600000` with `bCompileAngelscriptUnitTests=true`; expected result: AngelScriptSDK tests are discoverable and pass.
- [x] 4.4 <!-- Non-TDD --> Restore the intended checked-in `bCompileAngelscriptUnitTests` value and record verification notes in the OpenSpec change.
