# Old reload tests enter through CompileModules

## Reusable Insight

The isolated HotReload corpus almost never calls `PerformHotReload` or the watcher thread. Annotated `UCLASS(` source goes through preprocess then `CompileModules(SoftReloadOnly|FullReload)`. Proof is ProcessEvent on a live UObject, not UserData alone.

## Evidence

`CompileModuleWithResult` in `Legacy/Shared/AngelscriptTestEngineHelper.cpp`. Gold cases `SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass` and `SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody`.

## Boundaries

Does not authorize restoring Legacy files or `WITH_ANGELSCRIPT_UNITTESTS`. File watch, PIE, and rename redirects remain separate.

## Application

Replacement NativeEngine reload tests should preprocess inline `UCLASS` source and call `CompileModules`, then ProcessEvent.

## Sources

[legacy-reload-slice](../drafts/findings/legacy-reload-slice.md). Disposition: candidate.
