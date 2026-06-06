## Current State

`AngelscriptFunctionTableCodeGenerator.LoadSupportedModules()` reads `AngelscriptRuntime.Build.cs` and uses that set for all generated modules. This is correct for normal same-module shards because those files compile inside `AngelscriptRuntime` and include target module headers. It is too restrictive for cross-module shards because those files compile inside the target module and publish POD wrapper tables through `IModularFeatures`.

The latest diagnostics show `315` `disabled-safe-cross-module` candidates. These are already non-RPC, public, signature-resolved, and inside the current safe automatic cross-module subset; they are skipped only because their modules are not in the generated module set.

## Goals

- Decouple cross-module wrapper generation from AngelscriptRuntime link dependencies.
- Preserve the current runtime-linked module behavior for normal Direct/Stub shards.
- Add a small pilot allowlist for cross-module-only modules.
- Keep unsupported signatures and RPC/Net exclusions unchanged.
- Make the new coverage visible in summary and CSV diagnostics.

## Non-Goals

- Do not add new module dependencies to `AngelscriptRuntime.Build.cs`.
- Do not generate normal AngelscriptRuntime same-module shards for cross-module-only modules.
- Do not expand the safe signature protocol in this change.
- Do not direct-bind RPC/Net functions.

## Technical Approach

Introduce an `AngelscriptCrossModuleGenerationModules` data source owned by `AngelscriptUHTTool`, likely a simple text file with comments and one module name per line. `LoadSupportedModules()` becomes `LoadModuleGenerationPolicy()` and returns separate sets:

- `RuntimeLinkedModules`: modules discovered from `AngelscriptRuntime.Build.cs`; these continue to generate normal Direct/Stub shards plus cross-module wrappers for unexported safe functions.
- `CrossModuleOnlyModules`: modules from the new allowlist that are present in the current UHT session; these generate only target-module `AS_FunctionTable_<Module>_CrossModule_*.cpp` shards.
- `AllCrossModuleModules`: the union used for stale cleanup and disabled-module diagnostics.

For cross-module-only modules, collection should only emit `CrossModule` entries created through `TryCreateCrossModuleEntry()` when the direct resolver fails with `unexported-symbol`. It must not emit normal `ERASE_NO_FUNCTION()` stub rows into AngelscriptRuntime output. Runtime injection can still create `ClassFuncMaps` entries through `FAngelscriptBinds::AddFunctionEntry()` during the Late+60 `IModularFeatures` pass.

The pilot allowlist should start with modules that are high in `disabled-safe-cross-module` and relatively valuable for runtime scripting. The initial set is:

- `GameplayCameras`
- `IKRig`
- `Niagara`
- `GameplayAbilities`
- `MovieSceneTracks`

Editor-heavy modules such as `ControlRigEditor`, `PythonScriptPlugin`, `NiagaraEditor`, `EditorScriptingUtilities`, and `Blutility` stay deferred until editor-only module availability is handled explicitly.

## Risks

- A module may appear in UHT diagnostics but not be compiled or loaded in the current target. Mitigation: generated summary records the candidate count, while runtime remains safe because missing feature registration falls back naturally.
- Target-module wrapper shards may fail to compile due to include or deprecation differences in newly allowlisted modules. Mitigation: start with a small pilot, run full project build, and shrink the pilot only if evidence shows a module-specific compile blocker.
- Summary totals can become ambiguous if cross-module-only rows are mixed with normal Direct/Stub rows. Mitigation: keep `EntryKind=CrossModule` and `ThunkStyle=FrameWrapper`, and add tests that verify allowlisted modules do not produce normal same-module Direct/Stub shards.

## Verification

- Add RED tests that fail while the generator still derives generation solely from `AngelscriptRuntime.Build.cs`.
- Run the targeted UHTTool resolver test prefix.
- Run a full project build with `Tools\RunBuild.ps1 -SerializeByEngine -NoXGE`.
- Validate the OpenSpec change with `openspec validate`.
