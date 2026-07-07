# Tasks: feature-as-engine-reflectable-state

> Verification commands follow project standards (`Documents/Guides/Build.md`,
> `Documents/Guides/Test.md`): builds run via `Tools\RunBuild.ps1`, tests via
> `Tools\RunTests.ps1`. Both scripts are invoked through PowerShell with
> `-NoProfile -ExecutionPolicy Bypass` and an explicit `-TimeoutMs`.

## 1. Reflectable State Metadata Slice

- [ ] 1.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineReflectableStateTests.cpp` with CQTest coverage under `Angelscript.TestModule.Engine.ReflectableState`. Start with `StructIsReflected`, which only asserts `FAngelscriptEngineReflectionSnapshot::StaticStruct()` exists and required `FProperty` names are discoverable (`bIsInitialized`, `bHasScriptEngine`, `bIsInitialCompileFinished`, `bDidInitialCompileSucceed`, `ScriptRootPaths`, `ActiveModuleCount`, `DiagnosticsFileCount`, `DiagnosticsMessageCount`, `DiagnosticsErrorCount`, `HotReloadQueuedChangeCount`). Expected RED: C++ compilation fails because the reflectable state value type does not exist yet. Verify RED with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-1.1-red -TimeoutMs 900000 -NoXGE`.

- [ ] 1.2 <!-- Non-TDD --> Add the top-level `USTRUCT(BlueprintType) FAngelscriptEngineReflectionSnapshot` in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (or a small included runtime header if the implementation needs to reduce header size). Include only UHT-supported `UPROPERTY(VisibleAnywhere, BlueprintReadOnly)` fields. Prioritize the minimum high-value set from the spec: lifecycle flags, package/settings/world references or paths, script roots, active modules, diagnostics, hot reload queues, selected service presence flags, build-configuration-gated services, and runtime config summary values. Verify UHT/build and the metadata test with:
  ```
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-1.2-build -TimeoutMs 900000 -NoXGE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState.StructIsReflected" -Label engine-reflectable-state-1.2-test -TimeoutMs 600000
  ```

## 2. Reflectable State Value Rows And Mapping Notes

- [ ] 2.1 <!-- Non-TDD --> Add any small nested `USTRUCT(BlueprintType)` value rows needed by the reflectable state view, such as diagnostic file summaries or bounded collection preview rows. Keep them value-only; do not store raw AS VM pointers, locks, `TUniquePtr`, `TSharedPtr`, or injected callbacks in reflected fields. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-2.1-row-types -TimeoutMs 900000 -NoXGE`.

- [ ] 2.2 <!-- Non-TDD --> Add a short mapping comment near the reflectable state type documenting how non-reflectable engine member categories are represented (presence flags, counts, names, paths, and limited previews). This comment should explain that the first implementation is representative rather than exhaustive, and that the live engine remains the resource owner. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-2.2-doc-comment -TimeoutMs 900000 -NoXGE`.

## 3. Capture API Implementation

- [ ] 3.1 <!-- TDD --> Extend `AngelscriptEngineReflectableStateTests.cpp` with `CapturesInitializedEngineState`, which calls `CaptureReflectionSnapshot()` and asserts initialized state, script-engine presence, package/settings/world observation fields, script root paths, active module count, and initial compile flags. Expected RED: C++ compilation fails because the capture API does not exist yet. Verify RED with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-3.1-red -TimeoutMs 900000 -NoXGE`.

- [ ] 3.2 <!-- TDD --> Add `FAngelscriptEngineReflectionSnapshot CaptureReflectionSnapshot() const;` to `FAngelscriptEngine` and implement the minimal lifecycle/package/settings/root-path/module fields in `AngelscriptEngine.cpp`. The implementation must be const and side-effect-free. Verify GREEN for the core-value test with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState.CapturesInitializedEngineState" -Label engine-reflectable-state-3.2-green -TimeoutMs 600000`.

- [ ] 3.3 <!-- TDD --> Extend the same test file with `CaptureIsReadOnly`. Capture active-module and diagnostics counters before and after `CaptureReflectionSnapshot()` and assert the capture does not mutate module state, diagnostics maps, dirty flags, hot reload queues, or current engine context. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState.CaptureIsReadOnly" -Label engine-reflectable-state-3.3-readonly -TimeoutMs 600000`.

## 4. Diagnostics And Representative Coverage

- [ ] 4.1 <!-- TDD --> Extend the same test file with a diagnostics-summary case: inject a compile diagnostic through existing `FAngelscriptEngine::ScriptCompileError` test patterns, capture the value view, and assert diagnostic file/message/error counts and `bDiagnosticsDirty`. Expected RED: diagnostic summary fields exist from task 1.2 but are not populated yet. Verify RED/GREEN with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState" -Label engine-reflectable-state-4.1-diagnostics -TimeoutMs 600000`.

- [ ] 4.2 <!-- TDD --> Populate diagnostics summary fields from `Diagnostics` and `LastEmittedDiagnostics`, including file count, message count, error/warning/info counts, dirty state, and stable filename previews. Verify GREEN for the diagnostics test with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState" -Label engine-reflectable-state-4.2-diagnostics-green -TimeoutMs 600000`.

- [ ] 4.3 <!-- TDD --> Populate representative runtime ownership/service fields: script-engine presence, selected database/service presence flags, config settings, world context, and package references. Include precompiled data, StaticJIT, debug server, and code coverage only where they are low-risk to summarize under the current build guards. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState" -Label engine-reflectable-state-4.3-services-green -TimeoutMs 600000`.

- [ ] 4.4 <!-- TDD --> Populate high-value collection/config/hot-reload summaries: `AllRootPaths`, active module names, queued reload/deletion counts, selected reload queues, selected cache counts, and runtime config booleans such as simulated cooked, test errors, editor script usage, automatic import method, generated precompiled data, and development mode. Omit low-value private queues when a safer category summary already exists. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState" -Label engine-reflectable-state-4.4-collections-green -TimeoutMs 600000`.

## 5. Validation And Cleanup

- [ ] 5.1 <!-- Non-TDD --> Confirm the first implementation does not add a `UBlueprintFunctionLibrary` or new Blueprint/editor query wrapper. This change's query surface is only the reflected value type plus `FAngelscriptEngine::CaptureReflectionSnapshot() const`; add a later OpenSpec change when a concrete consumer exists. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "rg -n \"UBlueprintFunctionLibrary|GetCurrentAngelscriptEngineReflectionSnapshot|CaptureCurrentReflectionSnapshot\" Plugins/Angelscript/Source/AngelscriptRuntime"` (expected: empty output unless the implementation deliberately documents a future-facing comment without code).

- [ ] 5.2 <!-- Non-TDD --> Search `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` and any new snapshot headers to confirm no non-reflectable engine resource type was added as a `UPROPERTY` (`asC*`, `asI*`, `TUniquePtr`, `TSharedPtr`, `TFunction`, `FCriticalSection`, raw debug/JIT service pointer ownership). Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "rg -n -U 'UPROPERTY\\([^\\)]*\\)[\\s\\S]{0,200}\\b(asC|asI|TUniquePtr|TSharedPtr|TFunction|FCriticalSection|FStaticJIT|FAngelscriptPrecompiledData)' Plugins/Angelscript/Source/AngelscriptRuntime/Core"` (expected: empty output).

- [ ] 5.3 <!-- Non-TDD --> Run a focused build and reflectable state test pass. Verify with:
  ```
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-reflectable-state-build -TimeoutMs 900000 -NoXGE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.ReflectableState" -Label engine-reflectable-state-final -TimeoutMs 600000
  ```

- [ ] 5.4 <!-- Non-TDD --> Run a broader engine-prefix regression to catch lifecycle/header/UHT issues outside the new test file. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label engine-reflectable-state-engine-regression -TimeoutMs 900000`.

- [ ] 5.5 <!-- Non-TDD --> Run OpenSpec strict validation for this change and fix any structural issues before apply is considered complete. Verify with `openspec validate feature-as-engine-reflectable-state --strict --json`.
