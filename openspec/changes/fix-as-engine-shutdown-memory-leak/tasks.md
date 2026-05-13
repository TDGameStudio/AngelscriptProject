## Tasks

### 1. Shutdown Path: UASClass RemoveFromRoot <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: Append `ASClass->RemoveFromRoot()` + `ASClass->ClearFlags(RF_Standalone)` to the UASClass cleanup loop in `Shutdown()`
- **Verification**: Build succeeded
- [x] Done

### 2. Shutdown Path: UASStruct/UDelegateFunction/UUserDefinedEnum RemoveFromRoot <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: After the UASClass loop, add `ForEachObjectWithPackage` traversal of AngelscriptPackage to call `RemoveFromRoot()` + `ClearFlags(RF_Standalone)` on all related types
- **Verification**: Build succeeded
- [x] Done

### 3. GBlueprintEventsByScriptName Shutdown Cleanup <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: `extern` reference and `Empty()` in `ReleaseOwnedSharedStateResources()`
- **Verification**: Build succeeded
- [x] Done

### 4. AngelscriptGameplayTagsLookup — Preserved (Not Cleared) <!-- Non-TDD -->

- **Decision change**: Originally planned to clear. Implementation triggered `GameplayTagNamespaceGlobals` test regression. Analysis confirmed this TSet is the dedup index for the global `AngelscriptGameplayTags` TChunkedArray — clearing it causes linear array growth; clearing both the lookup and the array breaks `AngelscriptRebindGameplayTagsToCurrentEngine()`. Removed `Empty()` call and added comments explaining the rationale.
- [x] Done (not cleared)

### 5. CachedEditorClasses Reset <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`
- **Change**: Promoted `IsEditorOnlyClass` function-local `static TMap` to file-scope `GCachedEditorClasses`, added `ResetCachedEditorClasses()` exposed cleanup entry, called from `ReleaseOwnedSharedStateResources()` under `#if WITH_EDITOR`
- **Verification**: Build succeeded
- [x] Done

### 6. Package Unroot <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: At the end of Shutdown, call `RemoveFromRoot()` + `ClearFlags(RF_Standalone)` on `AngelscriptPackage` and `AssetsPackage`
- **Verification**: Build succeeded
- [x] Done

### 7. Build Verification <!-- Non-TDD -->

- **Verification**: `Build.bat AngelscriptProjectEditor Win64 Development` — Succeeded
- [x] Done

### 8. Test Regression Verification <!-- Non-TDD -->

- **Verification**: Full test suite run; identified and fixed GameplayTag regression
- [x] Done

### 9. GScriptNativeForms Leak Fix (Phase 2) <!-- Non-TDD -->

- **Files**:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.h` — Added `static void ReleaseAllNativeForms();` declaration
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp` — Implementation: iterate GScriptNativeForms, delete values, Empty
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — Called in `ReleaseOwnedSharedStateResources()` under `#if AS_CAN_GENERATE_JIT` guard
- **Verification**: Build succeeded
- [x] Done

### 10. AngelscriptDocs 4 TMap Cleanup (Phase 2) <!-- Non-TDD -->

- **Files**:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDocs.h` — Added `static void ResetAllDocumentation();` declaration
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDocs.cpp` — Implementation: `Empty()` all 4 TMaps
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — Called in `ReleaseOwnedSharedStateResources()`
- **Verification**: Build succeeded
- [x] Done
