# Tasks - improve-as-cross-module-generation-profiles

> `tasks.md` is the implementation plan. Update checkboxes only after the matching verification passes.

## 1. Profile configuration tests

- [x] 1.1 <!-- TDD --> Update UHTTool resolver tests in `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleLinkProbeTests.cpp` to require `cross-module-generation-modules.json`, assert `common/source/installed` profile shape, assert current source engine profile diagnostics in `AS_FunctionTable_Summary.json`, and assert profile modules are still absent from `AngelscriptRuntime.Build.cs`. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleGenerationProfiles" -Label crossmodule-profile-red -TimeoutMs 900000`.

## 2. JSON profile implementation

- [x] 2.1 <!-- TDD --> Replace `cross-module-generation-modules.txt` loading in `AngelscriptFunctionTableCodeGenerator.cs` with JSON profile loading from `cross-module-generation-modules.json`, including `common`, `source`, and `installed` profile arrays. Verification: rerun the test from 1.1.
- [x] 2.2 <!-- TDD --> Add source/installed engine profile detection based on the resolved engine root and select `common + source` for source engines or `common + installed` for installed engines, falling back to installed with a warning when unknown. Verification: rerun the test from 1.1.
- [x] 2.3 <!-- TDD --> Extend `AS_FunctionTable_Summary.json` with selected profile, configured modules, effective modules, and config path diagnostics. Verification: rerun the test from 1.1.

## 3. Source profile expansion

- [x] 3.1 <!-- Non-TDD --> Replace `cross-module-generation-modules.txt` with `cross-module-generation-modules.json` and populate the source profile with the current `disabled-safe-cross-module` module pool while keeping installed empty. Verification: `Tools\RunBuild.ps1 -Label crossmodule-profile-build -TimeoutMs 900000 -SerializeByEngine -NoXGE`.
- [x] 3.2 <!-- Non-TDD --> If build verification proves module-specific compile failures, remove only failing source-profile modules and document the reason in `design.md`; otherwise leave the full source pool enabled. Verification: rerun the build from 3.1.

## 4. Final verification

- [x] 4.1 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label crossmodule-profile-uhttool -TimeoutMs 900000`.
- [x] 4.2 <!-- Non-TDD --> Run `openspec validate "improve-as-cross-module-generation-profiles" --strict --json`.
