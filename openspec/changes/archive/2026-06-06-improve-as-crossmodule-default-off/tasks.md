# Tasks - improve-as-crossmodule-default-off

> `tasks.md` is the implementation plan. Update checkboxes only after the matching verification passes.

## 1. UHTTool default-off coverage

- [x] 1.1 <!-- TDD --> Update UHTTool resolver tests in `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleLinkProbeTests.cpp` to require CrossModule generation to be disabled by default, assert explicit opt-in preserves source profile selection, and assert summary diagnostics expose the enabled state. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDefaultOff" -Label crossmodule-default-off-red -TimeoutMs 900000`.

## 2. Build-time generation gate

- [x] 2.1 <!-- TDD --> Add a default-disabled CrossModule generation gate to `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-generation-modules.json` and `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`, including summary diagnostics. Verification: rerun the test from 1.1.
- [x] 2.2 <!-- TDD --> Thread the gate through the generator so disabled CrossModule generation skips the Engine link probe, cross-module-only modules, and runtime-linked `unexported-symbol` wrapper generation while keeping normal runtime shards. Verification: rerun the test from 1.1.

## 3. Final verification

- [x] 3.1 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label crossmodule-default-off-uhttool -TimeoutMs 900000`.
- [x] 3.2 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label crossmodule-default-off-build -TimeoutMs 900000 -SerializeByEngine -NoXGE`.
- [x] 3.3 <!-- Non-TDD --> Run `openspec validate "improve-as-crossmodule-default-off" --strict --json`.
