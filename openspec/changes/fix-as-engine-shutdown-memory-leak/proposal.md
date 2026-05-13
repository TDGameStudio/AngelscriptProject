## Why

AngelscriptEngine 在多次 Init/Shutdown 周期中存在真实的资源泄漏，导致进程内存持续增长（201 次周期增长 ~10.3 GB）。根因是 ClassGenerator 创建的 UObject（UASClass、UASStruct、UDelegateFunction、UUserDefinedEnum）使用 `RF_MarkAsRootSet` 标记为 GC root，但 Shutdown 路径从未调用 `RemoveFromRoot()`，导致这些 UObject 永久残留。同时多个全局/文件级静态容器（`GBlueprintEventsByScriptName`、`AngelscriptGameplayTagsLookup`、`CachedEditorClasses`）在引擎 shutdown 时从不清理，持有悬垂指针并阻止页面回收。

虽然生产环境不会反复创建/销毁引擎，但测试套件依赖引擎隔离（每测试一个 full engine cycle），此泄漏导致全量测试进程内存超 12 GB 并触发 900s 超时。悬垂指针也是潜在崩溃隐患。

## What Changes

- 在 `FAngelscriptEngine::Shutdown()` 中对 owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum 调用 `RemoveFromRoot()` + `ClearFlags(RF_Standalone)`，使 GC 可以在后续回收
- 在 Shutdown 路径清理 `GBlueprintEventsByScriptName`（当前仅 PrecompiledData 场景清理）
- `AngelscriptGameplayTagsLookup` 保留不清理（它是全局 TChunkedArray 的去重索引，清理会导致数组线性增长或破坏 Rebind 机制）
- 重置 `CachedEditorClasses` 函数级静态缓存（或在 bind 入口处清理）

## Capabilities

### New Capabilities
- `engine-shutdown-resource-cleanup`: 确保 AngelscriptEngine shutdown 时正确释放所有 owned UObject root 引用和全局静态容器，使多次引擎生命周期不累积残留资源

### Modified Capabilities

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — Shutdown() 增加 RemoveFromRoot 逻辑
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp` — 暴露 GBlueprintEventsByScriptName 清理入口
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGameplayTag.cpp` — 暴露 AngelscriptGameplayTagsLookup 清理入口
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` — CachedEditorClasses 重置
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` — 可能需要额外的 UASStruct/UDelegateFunction/UUserDefinedEnum 遍历清理
- 测试模块受益：全量测试内存占用显著降低
