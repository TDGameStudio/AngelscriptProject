# AngelScript 引擎内存分析与改进

> 2026-05-13 | OpenSpec: `fix-as-engine-shutdown-memory-leak`

## 一、问题背景

全量测试套件运行时（200+ 引擎 Init/Shutdown 周期），进程内存峰值达 **~12.9GB**，每个引擎生命周期平均增长 **~51.6MB**，且内存不归还给 OS。

正常基线参考：

| 阶段 | 内存 |
|------|------|
| UE Editor 启动（无 AS） | ~1.5–2.0 GB |
| + AS 引擎 init + bind（121 Bind_*.cpp） | ~2.5–3.5 GB |
| 单次 bind 过程增量 | ~800–1200 MB |

## 二、根因分层

内存增长由 4 个层次叠加造成，其中只有第 1 层可通过代码修复。

### 第 1 层：真实资源泄漏（已修复）

| 泄漏源 | 问题 | 修复 |
|--------|------|------|
| UASClass / UASStruct / UDelegateFunction / UUserDefinedEnum | 创建时标记 `RF_MarkAsRootSet`，shutdown 后从不 `RemoveFromRoot()`，GC 永远无法回收 | Shutdown 时添加 `RemoveFromRoot()` + `ClearFlags(RF_Standalone)` |
| AngelscriptPackage / AssetsPackage | 同上，包对象一直被 root 持有 | Shutdown 时 unroot |
| GScriptNativeForms | 每次 bind `new FScriptFunctionNativeForm*` 但从不 `delete`，引擎销毁后旧 key 成为悬垂指针，随引擎周期数线性增长 | `FScriptFunctionNativeForm::ReleaseAllNativeForms()` 逐个 delete + Empty |
| AngelscriptDocs 4 个 TMap | `UnrealDocumentation` / `UnrealTypeDocumentation` / `GlobalVariableDocumentation` / `UnrealPropertyDocumentation` 跨引擎周期永久累积 | `FAngelscriptDocs::ResetAllDocumentation()` 清空 |
| GBlueprintEventsByScriptName | 全局 TMap 只增不清，持有旧引擎 UClass*/UFunction* 悬垂指针 | Shutdown 时 `Empty()` |
| GCachedEditorClasses | 函数级 static TMap，持有旧引擎 UClass* 悬垂指针 | 提升为文件级 + 暴露 `ResetCachedEditorClasses()` |

### 第 2 层：UE 分配器不归还内存（架构性，不可修复）

UE5 Editor 默认使用 **mimalloc**（`FMallocMimalloc`）：

- `FMemory::Trim(true)` 只触发 `mi_collect(true)`，效果有限
- 已释放的虚拟地址空间仍保留在进程 working set
- 这是所有现代分配器的共同特征——为性能 retain 页面供后续复用

### 第 3 层：FNamePool 单调增长（UE 架构性，不可修复）

- `FNamePool` 是 **append-only** 设计
- 每个引擎周期注册大量 FName（类型名、属性名、函数名）
- 这些 FName 永远不会被释放
- 每个引擎周期约增加数 MB 的 FName 数据

### 第 4 层：GameplayTag 绑定是进程级持久存储（架构性，不应清理）

- `AngelscriptGameplayTags`（TChunkedArray）提供稳定内存地址，AS 引擎的全局变量直接指向其中的元素
- `AngelscriptGameplayTagsLookup`（TSet）是该数组的去重索引，两者必须同步
- `AngelscriptRebindGameplayTagsToCurrentEngine()` 遍历已有数组将 tag 重新绑定到 clone/test 引擎，依赖数组作为 tag 真值源
- 单独清理 Lookup 会导致 TChunkedArray 线性增长（每个引擎周期追加一份完整副本）；同时清理两者会破坏 Rebind 机制

## 三、修复详情

### 3.1 涉及文件

| 文件 | 改动类型 |
|------|----------|
| `AngelscriptEngine.cpp` | UObject RemoveFromRoot、Package unroot、全局容器清理调用 |
| `StaticJITBinds.h` | 添加 `static void ReleaseAllNativeForms()` 声明 |
| `StaticJITBinds.cpp` | 实现 `ReleaseAllNativeForms()`：遍历 map delete value + Empty |
| `AngelscriptDocs.h` | 添加 `static void ResetAllDocumentation()` 声明 |
| `AngelscriptDocs.cpp` | 实现 `ResetAllDocumentation()`：4 个 TMap 全部 Empty |
| `Bind_BlueprintType.cpp` | `CachedEditorClasses` 提升为文件级 + `ResetCachedEditorClasses()` |
| `AngelscriptTestMacros.h` | `ASTEST_CREATE_ENGINE_FULL()` 改用 `AcquireTransientFullTestEngine()` |
| `AngelscriptTestUtilities.h` | 新增 `AcquireTransientFullTestEngine()`：销毁旧引擎 + GC + 创建新引擎 |
| `AngelscriptEngineIsolationTests.cpp` | 补充 `FAngelscriptEngineScope` 修复 context 测试 |

### 3.2 Shutdown 路径清理顺序

```
FAngelscriptEngine::Shutdown()
│
├── 1. UASClass 循环：清空脚本指针 + RemoveFromRoot + ClearFlags
├── 2. ForEachObjectWithPackage：UASStruct/UDelegateFunction/UUserDefinedEnum 同上
├── 3. ReleaseOwnedSharedStateResources()
│   ├── AS 引擎 ShutDownAndRelease()
│   ├── TypeDatabase / BindState / BindDatabase / StaticNames Reset
│   ├── GBlueprintEventsByScriptName.Empty()
│   ├── ResetCachedEditorClasses() [WITH_EDITOR]
│   ├── FScriptFunctionNativeForm::ReleaseAllNativeForms() [AS_CAN_GENERATE_JIT]
│   └── FAngelscriptDocs::ResetAllDocumentation()
│
├── 4. AngelscriptPackage / AssetsPackage → RemoveFromRoot + ClearFlags
└── 5. 清空引擎指针
```

### 3.3 回归修复

- **GameplayTagNamespaceGlobals 测试失败**：最初实施了 `AngelscriptGameplayTagsLookup.Empty()`，导致后续引擎周期重复注册触发 `asNAME_TAKEN`。确认 UE GameplayTag 注册是进程级不可逆操作后，移除 `Empty()` 调用并添加注释说明其作为进程级 guard 的必要性。

## 四、内存分配架构分析

### 4.1 当前分配路径

AS 相关的所有内存分配最终都走 UE 的 `FMemory`（即 mimalloc）。

**SDK 层**（`as_memory.h`）：

```cpp
#define asNEW(x)        new(FMemory::Malloc(sizeof(x), alignof(x))) x
#define asDELETE(ptr,x) {void *tmp = ptr; (ptr)->~x(); FMemory::Free(tmp);}
#define asNEWARRAY(x,cnt)  (x*)FMemory::Malloc(sizeof(x)*cnt, alignof(x))
#define asDELETEARRAY(ptr) FMemory::Free(ptr)
```

**SDK 全局入口**（`as_memory.cpp`）：

```cpp
void *asAllocMem(size_t size) { return FMemory::Malloc(size, alignof(asBYTE)); }
void asFreeMem(void *mem)     { FMemory::Free(mem); }
```

统计：SDK 源码中 **103 处 `asNEW`** + **7 处 `asNEWARRAY`**，**101 处 `asDELETE`** + **9 处 `asDELETEARRAY`**。

**已有池化**：

| 池 | 管理者 | 对象类型 |
|----|--------|----------|
| `scriptNodePool` | `asCMemoryMgr`（引擎实例级） | `asCScriptNode` |
| `byteInstructionPool` | `asCMemoryMgr`（引擎实例级） | `asCByteInstruction` |
| `GAngelscriptContextPool` | 全局池 | `asCContext*` |

### 4.2 统一分配器可行性评估

| 方案 | 原理 | 改动量 | 风险 | ROI |
|------|------|--------|------|-----|
| **Arena/Region 分配器** | 创建引擎级 Arena，shutdown 时整体释放 | 改 200+ 处 SDK 代码；UObject 无法纳入 Arena；SharedState 跨引擎共享 | 高 | 极低 |
| **自定义 FMalloc 子分配器** | fork UE 分配器层，AS 走独立分配路径 | 需 fork mimalloc，与 UE 内部冲突 | 高 | 极低 |
| **扩展池化** | 增加更多对象类型的池化 | 中等 | 低 | 低——高频对象已池化 |
| **LLM 标签统计** | 在 `as_memory.h` 宏中嵌入 UE LLM 标签 | ~20 行 | 零 | **高** |

### 4.3 Arena 分配器不可行的具体原因

1. **`asDELETE` 需要单独析构+释放**：SDK 到处在逐个对象 delete，Arena 模式下不支持单独 free
2. **UObject 绑定 UE GC**：`NewObject<>` 走 UE 对象系统，不可能放进自定义 Arena
3. **SharedState 跨引擎共享**：多引擎实例共享 SharedState 的设计导致 Arena 不能按引擎实例简单划分
4. **FName 不可控**：UE 的 FNamePool 是全局单例，任何分配器方案都管不到

### 4.4 推荐方案：LLM 标签统计

在不改变任何分配行为的前提下，通过 UE 的 Low Level Memory 标签系统获得 AS 内存占用的可观测性：

```cpp
// as_memory.h — 修改 asNEW 宏
#define asNEW(x) new(ASTaggedMalloc(sizeof(x), alignof(x))) x

// as_memory.cpp — 实现
void* ASTaggedMalloc(size_t Size, size_t Align)
{
    LLM_SCOPE_BYNAME(TEXT("AngelScript/SDK"));
    return FMemory::Malloc(Size, Align);
}
```

插件层面也可以类似标记：

```cpp
// AngelscriptEngine.cpp 关键路径
LLM_SCOPE_BYNAME(TEXT("AngelScript/Binds"));
// ... bind 执行 ...
```

收益：
- 在 UE 的 `stat LLM` 或 Unreal Insights 中可以看到 AS 分配的精确总量和分类
- 零行为变更、零性能影响（LLM 在 Shipping build 中编译为空）
- 改动量 ~20 行

## 五、全局静态容器审计总表

| 容器 | 位置 | 作用域 | Shutdown 行为 | 状态 |
|------|------|--------|---------------|------|
| `GBlueprintEventsByScriptName` | `Bind_BlueprintEvent.cpp:68` | 进程级 | 已修复：Empty | ✅ |
| `AngelscriptGameplayTagsLookup` | `Bind_FGameplayTag.cpp:24` | 进程级 guard | 不清理（设计如此） | ✅ 保留 |
| `GCachedEditorClasses` | `Bind_BlueprintType.cpp:941` | 进程级 | 已修复：ResetCachedEditorClasses | ✅ |
| `GScriptNativeForms` | `StaticJITBinds.cpp:27` | 进程级 | 已修复：ReleaseAllNativeForms | ✅ |
| `UnrealDocumentation` 等 4 个 | `AngelscriptDocs.cpp:28-31` | 进程级 | 已修复：ResetAllDocumentation | ✅ |
| `GScriptEnumTypeLookupByName` | `Bind_UEnum.cpp:376` | 进程级 | 已有 Reset | ✅ 无需处理 |
| `GAngelscriptContextPool` | `AngelscriptEngine.cpp` | 进程级 | `ReleaseContextsForScriptEngine` 清理 | ✅ 无需处理 |

## 六、调查方法论

### 6.1 插桩策略

在 4 个关键路径添加了临时内存插桩（`FPlatformMemory::GetStats()`）：

1. **Init 阶段**：PreInit → SharedState → BindScriptTypes → InitComplete → DebugServer 各步后
2. **Shutdown 阶段**：开始 → Release 前后
3. **Release 阶段**：AS 引擎释放 → TypeDB/BindState/BindDB/StaticNames Reset → 全局容器清理 → JIT/Docs 清理 各步后
4. **Bind 逐项**：121 个 Bind 前后各采集 PhysMB，输出增量

另外新增了 `AngelscriptEngineMemoryLifecycleTests.cpp`（~555 行）进行量化验证。

### 6.2 插桩移除

诊断完成后全部移除，原因：
- 每个 Bind 调用 `FPlatformMemory::GetStats()` 增加不必要的系统调用
- 正常运行不需要这些日志输出
- 真实泄漏已定位修复，剩余增长确认为 UE 架构性行为

最终提交仅保留 **~131 行有意义的修复代码**。

## 七、结论

| 维度 | 现状 |
|------|------|
| 真实泄漏 | 全部修复 |
| 分配器统一 | 已经统一到 FMemory（mimalloc） |
| 池化 | 高频对象已池化（ScriptNode/ByteInstruction/Context） |
| 可观测性 | 无统一标签，推荐 LLM 标签方案（~20 行改动） |
| 剩余内存增长 | UE 架构性行为（mimalloc 保留 + FNamePool 累积），不可在插件层修复 |
