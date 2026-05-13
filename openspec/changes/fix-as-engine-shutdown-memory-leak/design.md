## Current State

AngelscriptEngine 支持多实例生命周期（Init → Compile → Run → Shutdown），测试模块依赖此机制实现引擎隔离。当前 Shutdown 路径存在以下缺陷：

### UObject Root 引用泄漏

ClassGenerator 在 `FAngelscriptClassGenerator::CreateNewClass` 等方法中创建 UObject 时使用 `RF_MarkAsRootSet`：

```
AngelscriptClassGenerator.cpp:2711  UASClass         RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:2761  UASStruct        RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:2813  UDelegateFunction RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:3814  UUserDefinedEnum  RF_MarkAsRootSet
```

Shutdown 路径 (`FAngelscriptEngine::Shutdown()` line 1590-1608) 仅清空脚本指针（`ScriptTypePtr`、`OwnerScriptEngine` 等），但**从未调用 `RemoveFromRoot()`**。`CleanupRemovedClass()` (line 4981-5033) 有 `RemoveFromRoot()` 逻辑，但仅在热重载替换类时调用，不在 shutdown 路径上。

Package (`AngelscriptPackage`) 在 shutdown 末尾 `RemoveFromRoot()`，但内部 UObject 仍独立 rooted。

### 全局静态容器未清理

| 容器 | 定义 | Shutdown 行为 | 风险 |
|------|------|---------------|------|
| `GBlueprintEventsByScriptName` | `Bind_BlueprintEvent.cpp:68` `TMap<UClass*, TMap<FString, UFunction*>>` | 仅 PrecompiledData 场景清理 | 持有旧引擎 UClass*/UFunction* 悬垂指针 |
| `AngelscriptGameplayTagsLookup` | `Bind_FGameplayTag.cpp:24` `TSet<FName>` | 保留不清理 | 是全局 TChunkedArray 的去重索引；清理会导致数组线性增长或破坏 Rebind 机制 |
| `CachedEditorClasses` | `Bind_BlueprintType.cpp:941` `static TMap<UClass*, bool>` | 从不清理 | 持有旧引擎 UClass* 悬垂指针 |

### FName Pool 累积

`FNamePool` 是 append-only（UE 架构设计）。每次引擎周期通过 `Rename(*OldClassName_REPLACED_N*)` 创建唯一 FName，导致永久累积。此问题无法在插件层面修复，但减少重命名次数可以缓解。

## Goals

- Shutdown 后所有 owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum 从 GC root 移除，允许后续 GC 回收
- 全局静态容器在引擎 shutdown 时清理，消除悬垂指针风险
- 不影响正常的单引擎生命周期和热重载行为

## Non-Goals

- 修复 FName Pool append-only 设计（UE 引擎层面）
- 修改 UE 分配器行为或切换分配器
- 在 shutdown 后主动触发 `CollectGarbage()`（交给调用方决定）

## Technical Approach

### 1. Shutdown 路径增加 RemoveFromRoot

在 `FAngelscriptEngine::Shutdown()` 现有 UASClass 清理循环中追加：

```cpp
ASClass->RemoveFromRoot();
ASClass->ClearFlags(RF_Standalone);
```

对 UASStruct、UDelegateFunction、UUserDefinedEnum 新增类似的遍历清理循环（使用 `TObjectRange` 或利用 Package 的 Inner 对象遍历）。

### 2. 全局容器清理

在 `ReleaseOwnedSharedStateResources()` 末尾（AS 引擎已释放后）增加：

```cpp
extern TMap<UClass*, TMap<FString, UFunction*>> GBlueprintEventsByScriptName;
GBlueprintEventsByScriptName.Empty();

// AngelscriptGameplayTagsLookup 保留不清理
// 它是 AngelscriptGameplayTags TChunkedArray 的去重索引，
// 清理 lookup 而不清理数组会导致线性增长；
// 同时清理两者会破坏 AngelscriptRebindGameplayTagsToCurrentEngine() 的 rebind 机制
```

`CachedEditorClasses` 是函数级 static，需要在 bind 入口或 shutdown 时通过暴露清理函数来重置。

### 3. GScriptEnumTypeLookupByName 已有 Reset

`Bind_UEnum.cpp:376` 在 bind 入口已经 `Reset()`，无需额外处理。

### 4. GScriptNativeForms 泄漏清理（Phase 2 补充）

`StaticJITBinds.cpp:27` 的 `static TMap<asIScriptFunction*, FScriptFunctionNativeForm*> GScriptNativeForms` 存在两个问题：
- key 是 `asIScriptFunction*`，每个引擎实例创建不同的 function 对象，引擎销毁后成为悬垂指针
- value 是 `new FScriptNativeXxx(...)` 分配的对象，从不 `delete`，随引擎周期线性增长

该泄漏仅在预编译模式（`IsGeneratingPrecompiledData()` 为 true）下发生，因为所有 `BindNativeXxx` 方法都有该守卫。

修复方案：在 `FScriptFunctionNativeForm` 上添加 `static void ReleaseAllNativeForms()` 方法，遍历 map delete value + Empty。基类已有 `virtual ~FScriptFunctionNativeForm() {}`，通过基类指针 delete 安全。

### 5. AngelscriptDocs 4 个 TMap 清理（Phase 2 补充）

`AngelscriptDocs.cpp:28-31` 的 4 个静态 TMap（`UnrealDocumentation`、`UnrealTypeDocumentation`、`GlobalVariableDocumentation`、`UnrealPropertyDocumentation`）从不清理。key 为 int 类型 ID/function ID，跨引擎周期可能不完全相同，存在数据残留风险。

修复方案：在 `FAngelscriptDocs` 上添加 `static void ResetAllDocumentation()` 方法，4 个 TMap 全部 Empty。

### 6. 去全局化评估

完整审计了 AngelscriptRuntime 中所有全局静态容器（20+个），分类为：合理的全局（进程级常量/管理器）、已修复清理、新发现泄漏、低优先级可选。完全去全局化（迁入 SharedState）技术可行但 ROI 不高，当前 shutdown 清理已足够解决内存泄漏问题。

## Tradeoffs

| 决策 | 选项 A | 选项 B | 选择 |
|------|--------|--------|------|
| UObject 清理时机 | Shutdown 时 RemoveFromRoot，延迟 GC 回收 | Shutdown 时 ConditionalBeginDestroy 立即销毁 | A — 更安全，避免 destroy 顺序依赖 |
| 全局容器清理位置 | 在 ReleaseOwnedSharedStateResources | 在每个 Bind 文件中添加 cleanup 函数 | A — 集中管理，减少遗漏 |
| CachedEditorClasses | 暴露 static 清理函数 | 改为引擎实例级缓存 | A — 最小改动 |

## Risks

- **热重载兼容性**：`CleanupRemovedClass` 和新的 shutdown 清理可能存在执行顺序冲突。需确保 shutdown 路径只处理 `OwnerScriptEngine == Engine` 的对象。
- **多引擎共享实例**：SharedState 的 `ActiveParticipants` 机制已存在，shutdown 清理需要在所有参与者都退出后才执行全局容器清理。
- **测试行为变化**：清理后 GC 可能回收之前残留的对象，导致某些依赖残留状态的测试行为变化。

## 调查过程：内存插桩策略与决策记录

### 插桩目的

全量测试运行时进程内存峰值达 ~12.9GB，每引擎周期增长 ~51.6MB。为区分"真实泄漏"与"分配器保留/UE 架构性增长"，在以下位置添加了临时内存插桩：

### 插桩 1：Init 阶段逐步追踪（`AngelscriptEngine.cpp` Initialize_GameThread）

```cpp
auto LogPhaseMemory = [this](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[InitPhase:%s] engine=%p PhysMB=%llu VirtMB=%llu"),
        Phase, this,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

在 `PreInitialize`、`EnsureSharedStateCreated`、`BindScriptTypes`、`InitializeOwnedSharedState`、`DebugServer` 各阶段后调用。

**发现**：单次 bind 阶段（121 个 Bind_*.cpp）贡献 ~800-1200MB，是主要的内存消耗者，但这些是合理的业务数据。

### 插桩 2：Shutdown 阶段逐步追踪（`AngelscriptEngine.cpp` Shutdown）

```cpp
auto LogShutdownPhaseMemory = [this](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[ShutdownPhase:%s] engine=%p PhysMB=%llu VirtMB=%llu"),
        Phase, this,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

在 Shutdown 开始、Release 前后调用。

**发现**：AS 引擎 `ShutDownAndRelease()` 后 PhysMB 基本不降，说明分配器未归还页面。

### 插桩 3：Release 阶段逐步追踪（`AngelscriptEngine.cpp` ReleaseOwnedSharedStateResources）

```cpp
auto LogReleaseMem = [](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[ReleasePhase:%s] PhysMB=%llu VirtMB=%llu"),
        Phase,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

在 AS 引擎释放、TypeDB/BindState/BindDB/StaticNames 各 Reset、全局容器清理、JIT/Docs 清理各步后调用。同时输出 AS 引擎对象统计和 Docs TMap 计数。

**发现**：
- `TypeDatabase.Reset()` 和 `BindDatabase.Reset()` 可释放少量内存
- 全局容器清理本身内存影响微小，但消除了悬垂指针风险
- 分配器整体不归还——`FMemory::Trim(true)` 对 mimalloc 效果有限

### 插桩 4：Bind 逐项追踪（`AngelscriptBinds.cpp` CallBinds）

```cpp
const FPlatformMemoryStats BindsStartMem = FPlatformMemory::GetStats();
// ... per-bind tracking ...
const uint64 PrePhys = FPlatformMemory::GetStats().UsedPhysical / (1024 * 1024);
Bind.Function();
const uint64 PostPhys = FPlatformMemory::GetStats().UsedPhysical / (1024 * 1024);
if (PostPhys > PrePhys)
{
    UE_LOG(Angelscript, Display, TEXT("[BindMem] #%03d '%s' +%lluMB (total %lluMB)"),
        BindIndex, *Bind.BindName.ToString(), PostPhys - PrePhys, PostPhys);
}
```

**发现**：识别出内存消耗最大的几个 bind（蓝图类型注册、Actor 绑定等），但这些都是合理的业务逻辑。

### 插桩 5：内存生命周期测试（`AngelscriptEngineMemoryLifecycleTests.cpp`）

新增 ~555 行的测试文件，在 `Source/AngelscriptTest/GC/` 下，包含：
- `FMemorySnapshot` 结构体：采集进程内存、UObject 计数、按类型分类的 UObject 统计
- 各阶段前后对比输出
- 创建→销毁→GC 全周期内存追踪

**发现**：提供了量化证据证明 UObject 泄漏和全局容器累积的存在。

### 移除决策

所有插桩在完成诊断后被移除，原因：
1. **性能开销**：每个 bind（121 次）都调用 `FPlatformMemory::GetStats()` 增加不必要的系统调用
2. **日志噪音**：正常运行不需要这些输出，会干扰有意义的日志
3. **诊断目的已达成**：真实泄漏已定位并修复，剩余增长确认为 UE 架构性行为

保留的有意义代码（~131 行）聚焦于修复本身，不包含任何诊断日志。

### 修复后回归验证

修复提交后执行了全量编译验证（Build succeeded）和测试回归。发现一个回归：

- **GameplayTagNamespaceGlobals 测试失败**：最初 `AngelscriptGameplayTagsLookup.Empty()` 导致后续引擎周期重复注册 GameplayTag 触发 `asNAME_TAKEN`。根因是 UE 的 GameplayTag 注册是进程级一次性操作，清除 guard 后无法安全重注册。修复方案是保留 `AngelscriptGameplayTagsLookup` 不清理，并添加注释说明其作为进程级 guard 的必要性。
