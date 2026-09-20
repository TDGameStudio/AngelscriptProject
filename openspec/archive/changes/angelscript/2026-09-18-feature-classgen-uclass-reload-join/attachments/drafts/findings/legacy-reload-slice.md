# What to borrow from old HotReload tests

Translated from draft `findings/legacy-reload-slice.md`. Approval R15.

Old tree: `Plugins/Angelscript/Source/AngelscriptTest/Legacy/HotReload/` (~32 files), gated by `WITH_ANGELSCRIPT_UNITTESTS`, isolated by `.ubtignore`. Do not port the suite. Borrow the gold cases.

## How old tests reload

Most cases do not call `PerformHotReload`, Tick, or the file watcher.

When the source contains `UCLASS(`, `CompileModuleWithResult` runs `PreprocessAndCompile` then `CompileModules`. Memory source plus preprocessor-filled Class/Method rows, then ClassGen.

Gold: `HotReloadPropertyTests.SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass`

```
Compile UCLASS : UObject + UFUNCTION GetVersion
→ NewObject + ProcessEvent → 1
→ SoftReloadOnly changes the body
→ same UClass*
→ live instance ProcessEvent → 2
```

Fail gold: `FunctionTests.FailureKeepsOldCodeAndDiagnostics` — after a broken reload the live instance still returns 5.

Classification cases only `AnalyzeReloadFromMemory`.

## Blueprint create gold

`HotReloadBlueprintChildTests` uses `FKismetEditorUtilities::CreateBlueprint` + `CompileBlueprint` under `/Temp/...`.

Minimum borrow: `SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody`

- Script `UCLASS` parent
- Transient Blueprint child, `IsChildOf` parent, child is not `UASClass`
- SoftReload parent body
- Parent `UClass*` unchanged; existing Blueprint instance ProcessEvents the new return

Out: Level Blueprint, rename redirect, PIE, networking, components, delegates, performance.

## Versus current ClassGenReload

`ClassGenReload` only checks UserData. No `UCLASS()` source, no preprocessor Methods, no Soft ProcessEvent, no Blueprint child.

`ClassGenCall` proves Initial ProcessEvent, not a reloaded body.
