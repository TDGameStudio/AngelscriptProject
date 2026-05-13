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
| `AngelscriptGameplayTagsLookup` | `Bind_FGameplayTag.cpp:24` `TSet<FName>` | 从不清理 | 只增不减，阻止 FName 相关页面回收 |
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

extern TSet<FName> AngelscriptGameplayTagsLookup;
AngelscriptGameplayTagsLookup.Empty();
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
