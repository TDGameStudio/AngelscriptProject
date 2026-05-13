## 1. Preprocessor Context

- [x] 1.1 <!-- TDD --> Add failing preprocessor context tests in `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/` proving explicit flags/default options affect preprocessing and default construction remains equivalent. Expected RED: the explicit context type/constructor does not exist or the test cannot observe explicit context values yet.
- [x] 1.2 <!-- TDD --> Implement `FAngelscriptPreprocessorContext` or equivalent in `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/` with explicit values plus a current-engine/settings factory, and route `FAngelscriptPreprocessor` construction through it.
- [x] 1.3 <!-- TDD --> Update preprocessor test helpers in `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorTestHelpers.h` to support explicit context construction without forcing unrelated tests to use global engine-derived defaults.
- [x] 1.4 <!-- Non-TDD --> Verify Preprocessor Context with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-context -TimeoutMs 600000`.

## 2. Preprocessor Summary

- [x] 2.1 <!-- TDD --> Add failing tests for summary counts and hook-time availability using scripts with imports, classes, functions, properties, enums, delegates, and generated code. File scope: `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/` and optionally `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/`. Expected RED: summary API does not exist or reports missing category counts.
- [x] 2.2 <!-- TDD --> Add read-only preprocessor summary structs/APIs in `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h/.cpp`, computing stable file/module/chunk/import/declaration/generated-code summaries without exposing mutable internals.
- [x] 2.3 <!-- TDD --> Migrate new or touched hook tests away from direct `Files`/`ChunkedCode` inspection where summary coverage is sufficient; keep legacy helper access only where tests intentionally validate parser internals.
- [x] 2.4 <!-- Non-TDD --> Verify Preprocessor Summary with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-summary -TimeoutMs 600000`.

## 3. Compilation Events Foundation

- [x] 3.1 <!-- TDD --> Add failing compilation events contract tests proving no-listener behavior is silent and registered listeners receive value-style events. File scope: `Plugins/Angelscript/Source/AngelscriptTest/Compiler/` or `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/` if reusing guide fixtures. Expected RED: compilation events API does not exist or no events are recorded.
- [x] 3.2 <!-- TDD --> Implement `AngelscriptCompilationEvents` event enum, event struct, listener registration/subscription API, no-listener fast path, and read-only payload conventions under `Plugins/Angelscript/Source/AngelscriptRuntime/Core/` or `Core/Compilation/`.
- [x] 3.3 <!-- TDD --> Add compilation events tests proving existing `FAngelscriptRuntimeModule` compile delegates still fire with their prior semantics while compilation events provide additional structured data.
- [x] 3.4 <!-- Non-TDD --> Verify Compilation Events Foundation with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label compilation-events-foundation -TimeoutMs 600000`.

## 4. Hook Event Emission

- [x] 4.1 <!-- TDD --> Adapt `FAngelscriptPreprocessor::OnProcessChunks` and `OnPostProcessCode` moments to emit `Preprocess.ProcessChunks` and `Preprocess.PostProcessCode` compilation events based on the summary API. File scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/`.
- [x] 4.2 <!-- TDD --> Add minimal compile begin/end event emission in `FAngelscriptEngine::CompileModules()` with paired result/failure events across normal, compile-error, partial, and full-reload-required outcomes where practical.
- [x] 4.3 <!-- TDD --> Add module-level compilation events around existing Stage1-4 functions and stable half-steps: module assembly/import input, parse, type generation, layout, function generation, code compilation, conditional JIT status/handoff metadata, globals initialization, and class-generation handoff. File scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` and related event helpers.
- [x] 4.4 <!-- TDD --> Ensure parallel parse does not broadcast nondeterministic worker-thread events; collect summaries and emit deterministic compilation events from the main compile flow.
- [x] 4.5 <!-- Non-TDD --> Verify Hook Event Emission with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-compilation-events -TimeoutMs 600000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label compile-events-stages -TimeoutMs 600000`.

## 5. Thin Compilation Context

- [x] 5.1 <!-- TDD --> Add tests or assertions around compile-run scoping that prove any `FAngelscriptCompilationContext` state is per-run and does not leak into subsequent compile runs. File scope: `Plugins/Angelscript/Source/AngelscriptTest/Compiler/`. Expected RED: context API does not exist or compile-run scoping cannot be observed yet.
- [x] 5.2 <!-- TDD --> Introduce a thin per-run compilation context in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/` or `Core/Compilation/`, initially holding only compile type, input/compiled module summaries, result flags, compilation event sink access, and state genuinely shared across existing compile steps.
- [x] 5.3 <!-- TDD --> Refactor only minimal `CompileModules()` local-state usage needed for event summaries into the context; do not migrate the full pipeline to `ICompilationPhase` classes in this change.
- [x] 5.4 <!-- Non-TDD --> Verify Thin Compilation Context with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label compilation-context -TimeoutMs 600000`.

## 6. Documentation and Final Verification

- [x] 6.1 <!-- Non-TDD --> Update documentation that describes preprocessing/compiler hook boundaries, likely `Documents/Guides/Test.md`, `Documents/Guides/TestCatalog.md`, and any LearningGuide or plan index references touched by new tests. Verification: inspect changed docs and run `rg -n "CompilationEvents|PreprocessorContext|Preprocess\.ProcessChunks|Compile\.Begin" Documents Plugins/Angelscript/Source/AngelscriptTest`.
- [x] 6.2 <!-- Non-TDD --> Run focused preprocessor and compiler event suites after implementation. Verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label final-preprocessor-hooks -TimeoutMs 600000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label final-compiler-events -TimeoutMs 600000`.
- [x] 6.3 <!-- Non-TDD --> Run standard build to catch module/include/API regressions. Verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label refactor-as-compilation-event-hook -TimeoutMs 180000 -NoXGE`.
- [x] 6.4 <!-- Non-TDD --> Run a smoke suite after focused tests pass. Verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix hooks-smoke -TimeoutMs 600000`.
