## 1. Diagnostics Surface

- [ ] 1.1 <!-- TDD --> Add focused StaticJIT diagnostics API coverage under `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/` for precompiled cache load/compile, function-id resolution, generated registration, and execution counters; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label staticjit-diagnostics-red -TimeoutMs 600000`.
- [ ] 1.2 <!-- TDD --> Implement the non-Shipping StaticJIT diagnostics surface under `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/`, guarded by `AS_WITH_STATIC_JIT_DIAGNOSTICS`, and keep required `FAngelscriptEngine` private-state access narrow; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label staticjit-diagnostics-api -TimeoutMs 600000`.
- [ ] 1.3 <!-- TDD --> Add `as.StaticJIT.DumpDiagnostics` console command behavior for process-level and function-level diagnostics, including missing-engine and missing-function handling; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label staticjit-diagnostics-command -TimeoutMs 600000`.

## 2. Runtime API Cleanup

- [ ] 2.1 <!-- Non-TDD --> Remove `FAngelscriptEngine::LoadPrecompiledDataForTesting`, `FAngelscriptEngine::CompileLoadedPrecompiledDataForTesting`, and `FAngelscriptEngine::GetStaticJITFunctionIdForTesting`, migrating all StaticJIT AOT test call sites to diagnostics APIs; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label staticjit-engine-diagnostics -TimeoutMs 600000`.
- [ ] 2.2 <!-- Non-TDD --> Rename StaticJIT AOT generation helpers and generated entry marker calls from `ForTesting` / `TestHooks` naming to diagnostics naming, then regenerate checked-in AOT artifacts if output changes; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-diagnostics-generated -TimeoutMs 180000`.
- [ ] 2.3 <!-- Non-TDD --> Search `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/` and `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/` for stale StaticJIT-specific `ForTesting` / `TestHooks` references introduced by the AOT path; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label staticjit-diagnostics-final -TimeoutMs 600000`.

## 3. Validation

- [ ] 3.1 <!-- Non-TDD --> Run final build and OpenSpec validation with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-diagnostics-build -TimeoutMs 180000` and `openspec validate "improve-static-jit-diagnostics" --strict --json`.
