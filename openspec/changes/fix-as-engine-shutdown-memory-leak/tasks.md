## Tasks

### 1. Shutdown 路径 UASClass RemoveFromRoot <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: 在 `Shutdown()` 的 UASClass 清理循环（line ~1590-1608）中追加 `ASClass->RemoveFromRoot()` + `ASClass->ClearFlags(RF_Standalone)`
- **Verification**: `Tools\RunBuild.ps1 -Target AngelscriptProject -Config Development -Platform Win64`
- [ ] 完成

### 2. Shutdown 路径 UASStruct/UDelegateFunction/UUserDefinedEnum RemoveFromRoot <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: 在 Shutdown UASClass 循环后，增加对 AngelscriptPackage 内 UASStruct、UDelegateFunction、UUserDefinedEnum 的遍历，调用 `RemoveFromRoot()` + `ClearFlags(RF_Standalone)`
- **Verification**: `Tools\RunBuild.ps1 -Target AngelscriptProject -Config Development -Platform Win64`
- [ ] 完成

### 3. GBlueprintEventsByScriptName Shutdown 清理 <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: 在 `ReleaseOwnedSharedStateResources()` 末尾 `extern` 引用并 `Empty()` 该全局容器
- **Verification**: 编译通过
- [ ] 完成

### 4. AngelscriptGameplayTagsLookup Shutdown 清理 <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- **Change**: 在 `ReleaseOwnedSharedStateResources()` 末尾 `extern` 引用并 `Empty()` 该全局容器
- **Verification**: 编译通过
- [ ] 完成

### 5. CachedEditorClasses 重置 <!-- Non-TDD -->

- **File**: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`
- **Change**: 在 `IsEditorOnlyClass` 函数的 static TMap 改为可通过外部调用清理（添加清理函数），或在 bind 入口 `#if WITH_EDITOR` 块中 `Reset()`
- **Verification**: 编译通过
- [ ] 完成

### 6. 编译验证 <!-- Non-TDD -->

- **Verification**: `Tools\RunBuild.ps1 -Target AngelscriptProject -Config Development -Platform Win64`
- [ ] 完成

### 7. 运行 GC 主题测试验证 <!-- Non-TDD -->

- **Verification**: `Tools\RunTests.ps1 -Group GC -TimeoutMs 300000`
- [ ] 完成

### 8. GScriptNativeForms 泄漏修复（Phase 2） <!-- Non-TDD -->

- **Files**:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.h` — 添加 `static void ReleaseAllNativeForms();` 声明
  - `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp` — 实现：遍历 GScriptNativeForms delete value + Empty
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — 在 `ReleaseOwnedSharedStateResources()` 中 `#if AS_CAN_GENERATE_JIT` 守卫内调用
- **Verification**: 编译通过
- [x] 完成

### 9. AngelscriptDocs 4 个 TMap 清理（Phase 2） <!-- Non-TDD -->

- **Files**:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDocs.h` — 添加 `static void ResetAllDocumentation();` 声明
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDocs.cpp` — 实现：4 个 TMap 全部 Empty
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — 在 `ReleaseOwnedSharedStateResources()` 中调用
- **Verification**: 编译通过
- [x] 完成
