## 1. Phase 1 - Direct Calls And Metadata

- [x] 1.1 <!-- TDD --> Extend `AngelscriptASFunctionOptimizedCallTests.cpp` with direct optimized-call edge cases for byte return, float/double special values, reference writeback, exception fallback, and discard/stale behavior; verify with the ASFunction test prefix.
- [x] 1.2 <!-- TDD --> Extend ASFunction metadata coverage for generated function predicates, native negative cases, generated property/world-context classification, and source metadata stale behavior; verify with the ASFunction test prefix.
- [x] 1.3 <!-- TDD --> Run Phase 1 verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ASFunction" -Label uasfunction-phase1 -TimeoutMs 600000`.

## 2. Phase 2 - Wrapper ABI And Virtual Dispatch

- [x] 2.1 <!-- TDD --> Add a reflected wrapper ABI fixture covering byte, bool, dword, qword, float, double, object-return, primitive-return, and reference shapes through `ProcessEvent`.
- [x] 2.2 <!-- TDD --> Use the same fixture to cover direct `UASFunction::RuntimeCallEvent` Parms consumption and return/writeback behavior.
- [x] 2.3 <!-- TDD --> Add virtual dispatch coverage proving a parent generated `UASFunction` invoked on a child object executes the child override.
- [x] 2.4 <!-- Non-TDD --> Add only minimal test-local or shared test helper code needed to keep reflected parameter setup readable; do not add production runtime API unless required by a failing test.
- [x] 2.5 <!-- TDD --> Run Phase 2 verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ASFunction" -Label uasfunction-phase2 -TimeoutMs 600000`.

## 3. Final Verification

- [x] 3.1 <!-- Non-TDD --> Run build verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label uasfunction-dispatch-coverage -TimeoutMs 180000`.
- [x] 3.2 <!-- Non-TDD --> Run OpenSpec validation: `openspec validate "test-uasfunction-runtime-dispatch-coverage" --strict --json`.
