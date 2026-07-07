## 1. Namespace Behavior Tests

- [ ] 1.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp` so Blueprint library namespace tests assert full registered AS type namespaces for representative libraries, including `USubsystemLibrary` and a library with class-level `ScriptName`; verify red/green with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindConfig" -Label library-full-namespace-bindconfig -TimeoutMs 600000`.
- [ ] 1.2 <!-- TDD --> Replace or remove namespace-shortening isolation assertions in `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineIsolationTests.cpp`; expected coverage is that multiple engine contexts use the same full-name rule and no per-engine trim list behavior remains; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.MultiEngine" -Label library-full-namespace-multiengine -TimeoutMs 600000`.

## 2. Runtime Namespace Rule

- [ ] 2.1 <!-- TDD --> Simplify `FAngelscriptFunctionSignature::GetScriptNamespaceForClass()` in `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h` so reflected library namespaces come from `InType->GetAngelscriptTypeName()` and ignore class-level namespace `ScriptName`, prefix lists, and suffix lists; verify with the `Angelscript.TestModule.Engine.BindConfig` command from task 1.1.
- [ ] 2.2 <!-- Non-TDD --> Remove obsolete settings from `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`, including `bUseScriptNameForBlueprintLibraryNamespaces`, `BlueprintLibraryNamespacePrefixesToStrip`, and `BlueprintLibraryNamespaceSuffixesToStrip`; verify by searching `rg -n "bUseScriptNameForBlueprintLibraryNamespaces|BlueprintLibraryNamespacePrefixesToStrip|BlueprintLibraryNamespaceSuffixesToStrip" Plugins/Angelscript/Source`.
- [ ] 2.3 <!-- Non-TDD --> Remove obsolete engine state/helpers from `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` and `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`, including trim-list sorting and test setters; verify with the same `rg` search from task 2.2 and a build.

## 3. Subsystem Helper Migration

- [ ] 3.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptSubsystemBindingsTests.cpp` so scripts call `USubsystemLibrary::Get*Subsystem(...)` and local-player helper functions instead of `Subsystem::...`; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Subsystem" -Label library-full-namespace-subsystem -TimeoutMs 600000`.
- [ ] 3.2 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptFunctionLibrarySignatureTests.cpp` so subsystem helper namespace discovery expects `USubsystemLibrary` and no longer expects `Subsystem`; verify with the `Angelscript.TestModule.Engine.BindConfig` command from task 1.1.
- [ ] 3.3 <!-- TDD --> Change `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp` to bind helper globals under `USubsystemLibrary` while preserving native subsystem class `ClassName::Get()` accessors; verify with the subsystem binding and BindConfig commands.
- [ ] 3.4 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` so generated subsystem `static Get()` wrappers call `USubsystemLibrary::...` or `UEditorSubsystemLibrary::...`; verify with the existing preprocessor/subsystem tests selected by searching for generated subsystem accessor coverage.

## 4. Documentation And Examples

- [ ] 4.1 <!-- Non-TDD --> Search scripts, docs, and tests for stale short namespace references; expected result is no active `Subsystem::`, `EditorSubsystem::`, or removed namespace-setting reference outside archived/historical notes; verify with `rg -n "Subsystem::|EditorSubsystem::|bUseScriptNameForBlueprintLibraryNamespaces|BlueprintLibraryNamespacePrefixesToStrip|BlueprintLibraryNamespaceSuffixesToStrip" Plugins/Angelscript/Source Script Documents/Guides openspec`.
- [ ] 4.2 <!-- Non-TDD --> Update affected examples or current guides that describe stripped library names; if only archived/historical documents mention old behavior, leave them untouched and note the boundary in implementation summary; verify with the search command from task 4.1.

## 5. Final Verification

- [ ] 5.1 <!-- Non-TDD --> Run a standard build after runtime/test/doc changes; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label library-full-namespace-build -TimeoutMs 180000`.
- [ ] 5.2 <!-- Non-TDD --> Run focused binding and subsystem tests after implementation; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindConfig" -Label library-full-namespace-bindconfig-final -TimeoutMs 600000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Subsystem" -Label library-full-namespace-subsystem-final -TimeoutMs 600000`.
- [ ] 5.3 <!-- Non-TDD --> Validate the OpenSpec change before apply completion or archive; verify with `openspec validate "refactor-as-library-full-namespaces" --strict --json`.
