# Verification Record

## Verified on 2026-07-18

- `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`
  - `NativeRuntimeLinked` build succeeded.
  - UHT analyzed `5835` functions: `3358` `NativeRuntimeLinked`, `2477` `ReflectiveFallback`, `0` target-module bindings, `29` shards.
- `Tools\RunBuild.ps1` with temporary `FunctionBindingMethod=None`
  - Build succeeded.
  - UHT reported zero analyzed functions and zero generated shards.
  - `AS_FunctionTable_*` stale outputs in the Editor UHT directory were reduced to zero.
- Temporary `NativeModuleFunctionAddress` configuration on the installed UE 5.8 engine
  - UBT rejected the build before generation with the source-engine requirement diagnostic.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.FunctionBinding"`
  - `3/3 PASS`.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionBinding"`
  - `3/3 PASS`.
- `openspec validate refactor-function-binding-strategy --strict`
  - Valid.

## Remaining environment or follow-up coverage

- `6.5`: A complete target-module generation/registration run requires a source-built Unreal Engine. The current machine only exposes `C:\Program Files\Epic Games\UE_5.8\Engine`, classified as installed.
- `6.6`: The Editor callback is registered and the UBT rejection path is verified; a direct interactive Project Settings save-rejection test remains to be run in an Editor session with a controllable settings UI.
- `7.3`: The generator is responsibility-oriented at method and analysis-record level, but the large C# generator has not yet been split into separate top-level emitter/configuration types. This is recorded as a structural follow-up rather than hidden behind a completed checkbox.
