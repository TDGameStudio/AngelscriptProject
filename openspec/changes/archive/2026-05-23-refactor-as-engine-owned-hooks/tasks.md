# Tasks: refactor-as-engine-owned-hooks

> Verification commands follow project standards (`Documents/Guides/Build.md`, `Documents/Guides/Test.md`): builds run via `Tools\RunBuild.ps1`, tests via `Tools\RunTests.ps1`. Commands use PowerShell with `-NoProfile -ExecutionPolicy Bypass` and explicit timeouts.

## 1. Engine Hook Surface

- [x] 1.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineHooksTests.cpp` covering engine-owned hook isolation: register a pre-compile or class-analyze hook on one engine, operate through a second independent engine, and assert the hook does not fire for the wrong engine. Verify the new test initially fails or does not compile until the engine hook surface exists. Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks-1.1-red -TimeoutMs 900000`

- [x] 1.2 <!-- TDD --> Create `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h/.cpp`, move the runtime hook delegate type declarations out of `AngelscriptRuntimeModule.h`, add `FAngelscriptEngineHooks`, and add `FAngelscriptEngine::GetHooks()` so each engine owns its hook set. Keep implementation minimal enough to satisfy the new isolation test. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks-1.2-green -TimeoutMs 900000`

- [x] 1.3 <!-- Non-TDD --> Run a build after the hook container lands to catch include and export issues before broad call-site migration. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-owned-hooks-1.3-build -TimeoutMs 900000 -NoXGE`

## 2. Runtime Compile and Preprocessor Migration

- [x] 2.1 <!-- TDD --> Update existing compiler/preprocessor hook tests or add focused cases so pre-compile, post-compile, pre-generate-classes, post-compile-class-collection, and class-analyze behavior is exercised through `FAngelscriptEngine::GetHooks()` rather than `FAngelscriptRuntimeModule`. Verify expected failing compile/test state before implementation if old module getters are removed from the test path. Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label engine-owned-hooks-2.1-red -TimeoutMs 900000`

- [x] 2.2 <!-- TDD --> Migrate `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` and `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` from `FAngelscriptRuntimeModule::GetPreCompile/GetPostCompile/GetOnInitialCompileFinished/GetClassAnalyze/GetPreGenerateClasses/GetPostCompileClassCollection` to the current engine hook surface. Preserve hook timing and mutable class-analyze semantics. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label engine-owned-hooks-2.2-compiler -TimeoutMs 900000`

- [x] 2.3 <!-- Non-TDD --> Run preprocessor coverage to confirm class-analysis and structured compilation event behavior remain compatible. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label engine-owned-hooks-2.3-preprocessor -TimeoutMs 900000`

## 3. Runtime Bind and Debug Migration

- [x] 3.1 <!-- TDD --> Add or update runtime C++ tests for engine-owned `GetComponentCreated`, `GetOnLiteralAssetCreated`, `GetPostLiteralAssetSetup`, `GetDynamicSpawnLevel`, and debug suffix/break filter hooks where existing coverage is insufficient. Verify the tests target `FAngelscriptEngine::GetHooks()` and fail before the runtime bind call sites are migrated. Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks-3.1-red -TimeoutMs 900000`

- [x] 3.2 <!-- TDD --> Migrate runtime bind/debug call sites from `FAngelscriptRuntimeModule` to engine hooks: `Bind_AActor.cpp`, `Bind_UActorComponent.cpp`, `Bind_UObject.cpp`, `Bind_FString.cpp`, `Bind_BlueprintType.cpp`, `Bind_Console.h`, `AngelscriptDebugServer.cpp`, and affected debugger tests. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks-3.2-hooks -TimeoutMs 900000`

- [x] 3.3 <!-- Non-TDD --> Run debugger-focused regression for migrated debug break/filter/object suffix behavior. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger" -Label engine-owned-hooks-3.3-debugger -TimeoutMs 900000`

## 4. Editor/Debug Bridge Migration

- [x] 4.1 <!-- TDD --> Add or update editor tests so debug asset listing, editor blueprint creation, and default asset path override are registered through the new editor/debug bridge rather than `FAngelscriptRuntimeModule`. Verify the tests fail or do not compile before the bridge API exists. Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor" -Label engine-owned-hooks-4.1-red -TimeoutMs 900000`

- [x] 4.2 <!-- TDD --> Create the narrow bridge type for `GetDebugListAssets`, `GetEditorCreateBlueprint`, and `GetEditorGetCreateBlueprintDefaultAssetPath`, update `AngelscriptDebugServer.cpp`, `AngelscriptEditorModule.cpp`, and editor/debug tests to use it, and remove those hooks from `FAngelscriptRuntimeModule`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor" -Label engine-owned-hooks-4.2-editor -TimeoutMs 900000`

## 5. Runtime Module Cleanup and Validation

- [x] 5.1 <!-- Non-TDD --> Remove migrated delegate declarations and all migrated static hook getters from `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h/.cpp`. Keep only UE module lifecycle, initialization compatibility, and test-only initialization helpers. Verify no migrated call sites remain: `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Select-String -Path 'Plugins/Angelscript/Source/**/*.cpp','Plugins/Angelscript/Source/**/*.h' -Pattern 'FAngelscriptRuntimeModule::Get(PreCompile|PostCompile|OnInitialCompileFinished|ClassAnalyze|PreGenerateClasses|PostCompileClassCollection|DynamicSpawnLevel|DebugCheckBreakOptions|DebugBreakFilters|DebugObjectSuffix|ComponentCreated|OnLiteralAssetCreated|PostLiteralAssetSetup|DebugListAssets|EditorCreateBlueprint|EditorGetCreateBlueprintDefaultAssetPath)' -SimpleMatch:$false | ForEach-Object { $_.Path + ':' + $_.LineNumber + ':' + $_.Line.Trim() }"`

- [x] 5.2 <!-- Non-TDD --> Run a whole-project build to catch all include/API migration issues. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-owned-hooks-5.2-full-build -TimeoutMs 1800000`

- [x] 5.3 <!-- Non-TDD --> Run the focused regression set for engine hooks, compiler, preprocessor, debugger, and editor bridge. Verify sequentially: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks-5.3-engine -TimeoutMs 900000`; `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label engine-owned-hooks-5.3-compiler -TimeoutMs 900000`; `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label engine-owned-hooks-5.3-preprocessor -TimeoutMs 900000`; `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger" -Label engine-owned-hooks-5.3-debugger -TimeoutMs 900000`; `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor" -Label engine-owned-hooks-5.3-editor -TimeoutMs 900000`

- [x] 5.4 <!-- Non-TDD --> Run `openspec validate refactor-as-engine-owned-hooks --strict --json` from the worktree root and confirm the change is apply-ready or archive-ready depending on implementation state.
