# Proposal: UCLASS reload ProcessEvent

## Why

Replacement tests prove Initial ProcessEvent and UserData reload, not a live `UFUNCTION` body after Soft/Full reload, and not a transient Blueprint child. Old HotReload gold cases already specify that behavior with inline `UCLASS` source.

## What

NativeEngine `ClassGenUClassReload` embeds preprocessor-backed `UCLASS` scripts, calls `CompileModules`, and ProcessEvents:

1. SoftReload method body, same `UClass*`, live object new return; transient Blueprint child still calls the new body.
2. FullReload adds a property and stays callable; a broken reload keeps the old return.

## Out

Language folder corpus, Legacy HotReload restore, `PerformHotReload` watch, PIE, rename redirects, CacheV2.

## Capability

`angelscript/runtime/class-generation`
