## Why

AngelscriptEngine leaks resources across multiple Init/Shutdown cycles, causing unbounded process memory growth (~10.3 GB over 201 cycles). The root cause is that ClassGenerator-created UObjects (UASClass, UASStruct, UDelegateFunction, UUserDefinedEnum) are marked with `RF_MarkAsRootSet` but the Shutdown path never calls `RemoveFromRoot()`, so these UObjects permanently survive GC. Additionally, several global/file-scope static containers (`GBlueprintEventsByScriptName`, `CachedEditorClasses`) are never cleared on shutdown, retaining dangling pointers to destroyed engine objects.

While production does not repeatedly create/destroy engines, the test suite relies on engine isolation (one full engine cycle per test). This leak causes full-suite process memory to exceed 12 GB and trigger 900s timeouts. Dangling pointers also pose a latent crash risk.

## What Changes

- In `FAngelscriptEngine::Shutdown()`, call `RemoveFromRoot()` + `ClearFlags(RF_Standalone)` on all owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum, allowing subsequent GC to reclaim them.
- Clear `GBlueprintEventsByScriptName` on shutdown (currently only cleared in the PrecompiledData path).
- `AngelscriptGameplayTagsLookup` is intentionally preserved — it is the dedup index for the global `AngelscriptGameplayTags` TChunkedArray; clearing it causes linear array growth or breaks the Rebind mechanism.
- Reset `CachedEditorClasses` function-local static cache via an exposed cleanup function.
- Add `FScriptFunctionNativeForm::ReleaseAllNativeForms()` to delete heap-allocated NativeForm objects and empty the global map.
- Add `FAngelscriptDocs::ResetAllDocumentation()` to clear four static documentation TMaps.

## Capabilities

### New Capabilities
- `engine-shutdown-resource-cleanup`: Ensures AngelscriptEngine shutdown correctly releases all owned UObject root references and global static containers, preventing residual resource accumulation across multiple engine lifecycles.

### Modified Capabilities

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — Shutdown() adds RemoveFromRoot logic + global container cleanup calls
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` — CachedEditorClasses refactored to file-scope with reset function
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.h/.cpp` — ReleaseAllNativeForms added
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDocs.h/.cpp` — ResetAllDocumentation added
- Test module benefits: significantly reduced full-suite memory usage
