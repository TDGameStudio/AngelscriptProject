# Design: Crash Snapshot as Engine Extension

## Context

当前崩溃快照系统在 `FAngelscriptRuntimeModule::StartupModule()` 中通过静态函数 `FAngelscriptCrashSnapshot::Startup()` 全局初始化，注册 `FCoreDelegates::OnHandleSystemError` 回调。在模块卸载时通过 `Shutdown()` 取消注册。

**当前架构的问题：**

1. **生命周期耦合错误**：崩溃快照与模块生命周期绑定，而非引擎实例生命周期。一个进程中可能存在多个 `FAngelscriptEngine` 实例（测试环境、编辑器内多个引擎上下文），但只有一个全局崩溃处理器。

2. **引擎实例无感知**：崩溃时通过 `FAngelscriptEngine::TryGetCurrentEngine()` 获取当前引擎，但这依赖于引擎上下文栈的正确性。在崩溃场景下，栈可能已损坏或指向错误的实例。

3. **无法按需禁用**：作为全局初始化的系统，无法针对特定引擎实例启用或禁用崩溃快照。

4. **违反扩展机制设计**：项目已经建立了 `IAngelscriptExtension` / `FAngelscriptEngineExtensionRegistry` 机制用于引擎生命周期管理，但崩溃快照系统未使用。

**现有扩展机制：**

- `IAngelscriptExtension` 接口：`OnEngineAttached(FAngelscriptEngine&)` 和 `OnEngineDetached(FAngelscriptEngine&)`
- `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(Extension)` - 注册扩展
- 扩展在引擎创建时自动附加，销毁时自动分离
- 参考实现：`FClassReloadHelper::FClassReloadHelperExtension`（ClassReloadHelper.h）

## Goals / Non-Goals

**Goals:**

- 将崩溃快照系统改为通过 `IAngelscriptExtension` 接口管理生命周期
- 使崩溃处理器在第一个引擎实例附加时注册，最后一个实例分离时取消注册
- 保持现有的崩溃快照 JSON 格式和输出逻辑不变
- 保持测试接口（`WriteSnapshotForTesting`, `ConfigureForTesting`）的兼容性
- 支持多引擎实例环境（每个引擎实例独立追踪，但共享一个全局崩溃处理器）

**Non-Goals:**

- 不改变崩溃快照的输出格式或内容结构
- 不修改崩溃快照的写入逻辑或性能特性
- 不支持每个引擎实例独立的崩溃处理器（UE 的 `OnHandleSystemError` 是全局的）
- 不在此次重构中添加新的诊断数据收集能力

## Decisions

### 决策 1: 引擎引用持有策略

**选择：扩展内部持有弱引用，崩溃时通过引擎上下文栈解析**

**理由：**
- `IAngelscriptExtension::OnEngineAttached` 接收的是引擎的裸引用 `FAngelscriptEngine&`
- 崩溃快照可能在任意线程、任意时刻触发，引擎对象可能已经开始析构
- 使用弱引用（`TWeakPtr` 或直接存储指针 + 标志）可以避免延长引擎生命周期
- 崩溃处理器本身仍然使用 `FAngelscriptEngine::TryGetCurrentEngine()` 获取当前引擎，因为崩溃可能发生在任意引擎上下文中

**替代方案：**
- ❌ 强引用 `TSharedPtr<FAngelscriptEngine>` - 但 `FAngelscriptEngine` 不是通过 `TSharedPtr` 管理的，无法获取
- ❌ 存储引擎指针列表 - 需要线程安全管理，且崩溃时无法确定哪个引擎是活跃的

**实现：**
- 扩展内部维护一个静态引用计数器（类似 `ClassReloadHelper` 的模式）
- 第一个引擎附加时注册全局崩溃处理器
- 最后一个引擎分离时取消注册
- 崩溃处理器仍使用 `FAngelscriptEngine::TryGetCurrentEngine()` 获取引擎实例

### 决策 2: 全局状态迁移策略

**选择：保留现有全局状态，仅迁移初始化时机**

**理由：**
- 现有的全局状态（`GSystemErrorHandle`, `GOverrideOutputDir`, `GMarker`, `GHandlingCrash`）在 `AngelscriptCrashSnapshot_Private` 命名空间中
- 这些状态本质上是进程级别的，不需要按引擎实例分离
- 崩溃处理必须是进程级别的单例（UE 的 `FCoreDelegates::OnHandleSystemError` 是全局的）
- 迁移到扩展类内部会增加复杂度，但不带来实际收益

**替代方案：**
- ❌ 将全局状态移到扩展类静态成员 - 增加复杂度，无实质改善
- ❌ 每个引擎实例独立的崩溃配置 - 无法实现，`OnHandleSystemError` 是全局的

**实现：**
- 保持 `AngelscriptCrashSnapshot_Private` 命名空间中的全局状态不变
- `Startup()/Shutdown()` 改为私有，由扩展类调用
- 测试接口（`ConfigureForTesting`）保持公开，直接操作全局状态

### 决策 3: 扩展注册位置

**选择：在 `FAngelscriptRuntimeModule::StartupModule()` 中注册扩展**

**理由：**
- 扩展需要在任何引擎实例创建之前注册
- 模块启动是最早的初始化点
- 参考 `FClassReloadHelper::Init()` 的实现（在 `AngelscriptEditor` 模块启动时注册）

**替代方案：**
- ❌ 在第一个引擎初始化时注册 - 太晚，可能错过引擎创建事件
- ❌ 延迟注册 + `ReplayCurrentEngine()` - 增加复杂度，且与现有模式不一致

**实现：**
```cpp
void FAngelscriptRuntimeModule::StartupModule()
{
    // 注册崩溃快照扩展
    FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(
        MakeShared<FAngelscriptCrashSnapshotExtension>());
}
```

### 决策 4: 引用计数与多引擎支持

**选择：使用静态引用计数跟踪活跃引擎数量**

**理由：**
- 全局崩溃处理器应该在有任何引擎实例时激活，所有引擎实例销毁后才停用
- 简单的引用计数可以确保这一点
- 参考 `FAngelscriptEngine::AcquireProcessPackages()` 中的 `GAngelscriptPackageRefCount` 模式

**实现：**
```cpp
class FAngelscriptCrashSnapshotExtension : public IAngelscriptExtension
{
private:
    static int32 ActiveEngineCount;
    
public:
    virtual void OnEngineAttached(FAngelscriptEngine& Engine) override
    {
        if (++ActiveEngineCount == 1)
        {
            FAngelscriptCrashSnapshot::Startup();
        }
    }
    
    virtual void OnEngineDetached(FAngelscriptEngine& Engine) override
    {
        if (--ActiveEngineCount == 0)
        {
            FAngelscriptCrashSnapshot::Shutdown();
        }
    }
};
```

## Risks / Trade-offs

### 风险 1: 崩溃处理器取消注册时机

**风险：** 如果在引擎销毁过程中发生崩溃，此时崩溃处理器可能已经被取消注册。

**缓解：**
- 引擎销毁是从 `OnEngineDetached` 触发的，此时引擎仍然有效
- 只有在最后一个引擎分离后才取消注册，此时应该没有活跃的脚本执行
- 保持与当前实现一致的时机（模块卸载时取消注册）

### 风险 2: 多线程崩溃场景

**风险：** 在多线程环境中，一个线程触发崩溃时，另一个线程可能正在附加或分离引擎。

**缓解：**
- `GHandlingCrash` 原子变量确保崩溃处理器只执行一次
- 引用计数操作应该是原子的（使用 `FPlatformAtomics` 或 `std::atomic`）
- 崩溃处理器本身是无锁的，不依赖扩展对象状态

### Trade-off 1: 全局崩溃处理器的局限

**权衡：** 仍然只有一个全局崩溃处理器，无法区分哪个引擎实例导致了崩溃。

**接受理由：**
- UE 的 `OnHandleSystemError` 本身就是全局的
- 崩溃快照通过 `FAngelscriptEngine::TryGetCurrentEngine()` 获取当前引擎，这已经是最好的解决方案
- 如果需要多引擎隔离，需要更深层次的架构变更（超出此次重构范围）

### Trade-off 2: 测试接口保持静态

**权衡：** 测试接口（`ConfigureForTesting`, `WriteSnapshotForTesting`）仍然是静态的，无法指定特定引擎实例。

**接受理由：**
- 保持向后兼容
- 测试场景通常只有一个引擎实例
- 如果需要多引擎测试，可以通过 `FAngelscriptEngine::TryGetCurrentEngine()` 切换上下文

## Migration Plan

### 实施步骤

1. **创建扩展类**
   - 在 `AngelscriptCrashSnapshot.h` 中添加 `FAngelscriptCrashSnapshotExtension` 类
   - 实现 `OnEngineAttached` 和 `OnEngineDetached`
   - 添加静态引用计数器

2. **重构初始化逻辑**
   - 将 `Startup()/Shutdown()` 改为私有或保持公开但标记为内部使用
   - 扩展类中调用这些方法

3. **注册扩展**
   - 在 `FAngelscriptRuntimeModule::StartupModule()` 中注册扩展
   - 移除直接的 `Startup()` 调用

4. **清理模块代码**
   - 从 `FAngelscriptRuntimeModule::ShutdownModule()` 中移除 `Shutdown()` 调用
   - 确保扩展在模块卸载前自动分离

5. **验证测试**
   - 运行现有崩溃快照测试
   - 验证多引擎实例场景（如果有相关测试）

### 回滚策略

如果出现问题，可以简单回退：
1. 恢复 `FAngelscriptRuntimeModule::StartupModule/ShutdownModule` 中的直接调用
2. 取消扩展注册
3. 删除扩展类

所有更改都是加法性的，不影响现有功能的核心逻辑。

### 验证清单

- [ ] 编辑器启动时崩溃快照正常注册
- [ ] PIE 模式下崩溃能正确生成快照
- [ ] 崩溃快照 JSON 格式不变
- [ ] 测试接口（`WriteSnapshotForTesting`）仍然工作
- [ ] 多次创建/销毁引擎实例不会导致泄漏或重复注册
- [ ] 模块卸载时崩溃处理器被正确取消注册

## Open Questions

1. **是否需要支持按引擎实例配置崩溃快照？**
   - 当前设计是全局配置（`ConfigureForTesting` 是静态的）
   - 如果需要，可以扩展为引擎实例级别的配置存储
   - 建议：暂时保持全局配置，需要时再扩展

2. **是否需要在崩溃快照中记录引擎实例 ID？**
   - 可以在 JSON 输出中添加引擎实例指针或 ID
   - 有助于多引擎环境的调试
   - 建议：作为后续改进，不在此次重构中实现

3. **是否需要对扩展注册失败进行错误处理？**
   - 当前假设扩展注册总是成功
   - 建议：添加日志记录，但不阻止模块启动
