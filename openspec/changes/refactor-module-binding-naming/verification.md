# Verification

## Naming and artifact checks

- Public protocol header is `Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/AngelscriptModuleBindingProtocol.h`.
- Runtime receiver is `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ModuleBinding.cpp`.
- UHT profile and layout files are `module-binding-generation-modules.json` and `module-binding-layout-version.txt`.
- Default ModuleLocal-off generation reports `5835` total entries, `3358` direct, `2477` stubs, `0` module-binding entries, and `29` normal shards.
- Layout token remains `0xA5C0DE02`; public and generated ABI assertions remain `48`, `32`, and `32` bytes.
- Source scans find no legacy ModuleBinding-path symbols or artifact names in Runtime, UHTTool, focused tests, maintained UHT docs, or shared specs. The unrelated AngelScript builder dependency test retains its compiler dependency terminology.

## Passing checks

- `Tools\RunBuild.ps1 -Label module-binding-rename-final -NoXGE -TimeoutMs 1800000`: passed; Runtime, Test, UHT generation, and editor target linked.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label module-binding-rename-final-uht -TimeoutMs 600000`: `15/15` passed after rebuilding updated binaries.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionTable" -Label module-binding-generated-table -TimeoutMs 600000`: `11/11` passed.

## Existing baseline

The broader `RuntimeCpp` suite retains the previously recorded `90/101` result with 11 shared Engine/TypeDatabase lifecycle failures. No full-suite rerun is recorded yet for this naming-only migration; focused UHT and build validation cover the changed protocol and generated-artifact path.
