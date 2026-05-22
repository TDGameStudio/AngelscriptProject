# Known Failures Inherited at Merge Time

Recorded as part of the batch merge that landed
`refactor-as-remove-autoaccessor` (submodule `cdcc0f3`) +
`test-as-native-sdk-coverage` (submodule `a6799ea`) onto main on
2026-05-22.

## Summary

The autoaccessor removal in submodule commit `cdcc0f3` deleted the AngelScript
parser/builder/binder support for the `auto` property accessor sugar. Six
existing tests still depended on that mechanism and were not updated as part
of the original branch (`refactor-as-engine-extension-hooks-root` author
straywriter). They fail on this branch's own pre-rebase tip and continue to
fail after rebase onto main's hooks-merged baseline.

These failures are NOT introduced by the merge itself — they are inherited
from the autoaccessor branch. The merge preserves them rather than papering
over them. Follow-up is required to either update the tests for the new
uniform-accessor surface or remove the obsolete coverage.

## Failing tests (6 total)

### Parser / ScriptNode (2) — test removed parser feature

Both come from `e6fee36 [AngelscriptTest] Test: expand native SDK coverage`
and exercise the parser's autoaccessor support that `cdcc0f3` removed.

- `Angelscript.TestModule.AngelScriptSDK.Parser.Declarations.FAngelscriptNativeParserDeclarationsTests.PropertyAccessorGetSet`
  - Assertion: `ParserDeclVirtualProperty should parse successfully` → expected 0, got -1
  - File: `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeParserDeclarationsTests.cpp:52`
  - Root cause: parser no longer recognises `get` / `set` keyword inside
    property declarations after autoaccessor removal.

- `Angelscript.TestModule.AngelScriptSDK.ScriptNode.Shape.FAngelscriptNativeScriptNodeShapeTests.VirtualPropertyNodeShape`
  - Assertion: `ScriptNodeShapeVirtualProperty should parse successfully` → -1
  - File: `Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeScriptNodeShapeTests.cpp:52`
  - Same root cause as above.

**Fix direction**: either delete these two tests (they test a removed
language feature) or rewrite them against the surviving uniform-accessor
parser path.

### Bindings using autoaccessor-generated getters (2)

These tests compile script modules that use UE properties expecting an
auto-generated `Get_X()` getter. Without autoaccessor, those getters are
not synthesised, so the script fails to compile.

- `Angelscript.TestModule.Bindings.BodyInstance.FAngelscriptBodyInstanceBindingsTest.FBodyInstanceDefaults`
  - Compile error: `'bSimulatePhysics' is not a member of 'FBodyInstance'`
  - Test compiles a `.as` snippet that reaches `FBodyInstance::bSimulatePhysics`
    via the autoaccessor-generated path.

- `Angelscript.TestModule.Bindings.HitResult.FAngelscriptHitResultBindingsTest.FHitResultDefault`
  - Same pattern on `FHitResult`.

**Fix direction**: rewrite the test scripts to use the explicit
uniform-accessor calls or the manually exposed bind surface.

### ClassGenerator + Compiler integration tests (2)

Both rely on autoaccessor-generated getters to satisfy expectations.

- `Angelscript.TestModule.ClassGenerator.LiteralAsset.FAngelscriptLiteralAssetPostInitTests.PostInitResolvesGeneratedGetterInsteadOfNameCollision`
  - Assertion: `should execute the generated getter exactly once during post-init` → expected 1, got 0
  - File: `Source/AngelscriptTest/ClassGenerator/AngelscriptLiteralAssetPostInitTests.cpp:376`
  - Root cause: no generated getter exists to be invoked.

- `Angelscript.TestModule.Compiler.EndToEnd.FCompilerPipelinePropertyDefaultMatrixTests.DefaultSubobjectPathApplied`
  - Compile error in `Saved/Automation/Tests/Compiler/DefaultSubobjectPath.as`
  - Root cause: script under test uses autoaccessor syntax.

**Fix direction**: rewrite the affected test scripts and assertions to
use uniform accessors.

## Verification commands

To confirm these are still the only autoaccessor-related regressions and
none have spread:

```powershell
# Targeted prefixes covering all 6:
powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label autoaccessor-known-fail-sdk -TimeoutMs 600000
powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Bindings.BodyInstance" -Label autoaccessor-known-fail-bodyinstance -TimeoutMs 300000
powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Bindings.HitResult" -Label autoaccessor-known-fail-hitresult -TimeoutMs 300000
powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.ClassGenerator.LiteralAsset" -Label autoaccessor-known-fail-classgen -TimeoutMs 300000
powershell -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Compiler.EndToEnd" -Label autoaccessor-known-fail-compiler -TimeoutMs 600000
```

## Pre-existing flakes that survive merge unchanged

The following 14 failures predate this batch merge (verified on baseline
submodule `24d1572`). They are environmental / namespace / hot-reload
issues unrelated to autoaccessor:

- `Angelscript.TestModule.Delegate.Multicast.*.BroadcastInvokesScriptHandler`
- `Angelscript.TestModule.FunctionLibraries.Gameplay.*.AsyncSaveLoadDelegates`
- `Angelscript.TestModule.FunctionLibraries.Gameplay.*.ImmediateFailureCallbacks`
- `Angelscript.TestModule.FunctionLibraries.Math.*.PlanarProjectionAndColorFormatting`
- `Angelscript.TestModule.FunctionLibraries.Math.*.ShortestPathAndTransformSemantics`
- `Angelscript.TestModule.FunctionLibraries.MathOrientation.*.FactoriesAndTransformMutators`
- `Angelscript.TestModule.FunctionLibraries.Script.*.GlobalInitContextHotReloadName`
- `Angelscript.TestModule.FunctionLibraries.Script.*.GlobalInitContext`
- `Angelscript.TestModule.FunctionLibraries.Widget.*.RenderTransformNullGuard`
- `Angelscript.TestModule.GameInstanceSubsystem.Lifecycle`
- `Angelscript.TestModule.Learning.Runtime.ScriptClassToBlueprint`
- `Angelscript.TestModule.Learning.Runtime.TimerAndLatent`
- `Angelscript.TestModule.Learning.Runtime.UEBridge`
- `Angelscript.TestModule.Memory.BindFreeEvidence.*.BindFreeEvidence_LeakReport`
  (MALLOC_LEAKDETECTION=0 env)

## Backup / rollback path

If these regressions become blocking, rollback is available via:

```powershell
# Outer repo to pre-batch state
git reset --hard backup/pre-batch-merge/main

# Submodule to pre-batch state
git -C Plugins/Angelscript reset --hard backup/pre-batch-merge/sub-main
```

The hooks merge (commit `7e6e8b5`, submodule `8b15773`) survives that
rollback because the backup tags pre-date this batch.
