# Design: Code Coverage as Engine Extension

## Context

当前代码覆盖率系统在 `FAngelscriptEngine` 初始化过程中通过条件编译和裸指针创建：

```cpp
// AngelscriptEngine.cpp:1816-1821
#if WITH_AS_COVERAGE
    if (FAngelscriptCodeCoverage::CoverageEnabled())
    {
        CodeCoverage = new FAngelscriptCodeCoverage;
    }
#endif

// AngelscriptEngine.cpp:2007-2015
#if WITH_EDITOR && WITH_AS_COVERAGE
    FCoreDelegates::OnPostEngineInit.AddLambda([&]()
    {
        if (CodeCoverage != nullptr)
        {
            CodeCoverage->AddTestFrameworkHooks();
        }
    });
#endif
```

**当前架构的问题：**

1. **生命周期不清晰**：`CodeCoverage` 是裸指针成员，没有明确的析构逻辑。搜索代码未发现 `delete CodeCoverage` 调用，可能存在内存泄漏。

2. **初始化分离**：对象创建在 `Initialize_AnyThread()`，测试框架钩子注册在 `PostInitialize_GameThread()` 通过延迟回调完成，逻辑分散。

3. **Lambda 闭包捕获**：`OnPostEngineInit` Lambda 捕获 `this`，如果引擎在回调触发前销毁，会导致悬挂引用。

4. **引擎实例耦合不当**：代码覆盖率数据通过引擎成员指针访问，但在多引擎环境下没有隔离。

5. **扩展机制未使用**：项目已有 `IAngelscriptExtension` 机制，但代码覆盖率未使用，导致架构不一致。

**现有扩展机制：**

参考 `FClassReloadHelperExtension` 和即将实现的 `FAngelscriptCrashSnapshotExtension`，扩展系统提供：
- 清晰的生命周期钩子（`OnEngineAttached` / `OnEngineDetached`）
- 按引擎实例管理（每个扩展实例对应一个引擎实例）
- 统一的注册点（模块启动时）

## Goals / Non-Goals

**Goals:**

- 将代码覆盖率系统改为通过 `IAngelscriptExtension` 接口管理生命周期
- 移除引擎中的 `CodeCoverage` 裸指针成员
- 移除 `OnPostEngineInit` Lambda 闭包，在引擎附加时直接初始化
- 支持多引擎实例环境下的独立覆盖率追踪
- 确保 `FAngelscriptCodeCoverage` 对象正确析构，无内存泄漏
- 保持现有的覆盖率 API 和报告生成逻辑不变

**Non-Goals:**

- 不改变代码覆盖率的数据收集逻辑或报告格式
- 不修改 `MapExecutableLines`, `HitLine`, `StartRecording` 等公共 API
- 不在此次重构中优化覆盖率追踪的性能
- 不改变 `WITH_AS_COVERAGE` 编译条件的行为

## Decisions

### 决策 1: 扩展持有覆盖率对象的策略

**选择：扩展内部通过 `TUniquePtr` 持有 `FAngelscriptCodeCoverage` 实例**

**理由：**
- `FAngelscriptCodeCoverage` 不是通过 `TSharedPtr` 管理的，使用 `TUniquePtr` 确保独占所有权
- 每个引擎实例应该有独立的覆盖率数据，不应共享
- `TUniquePtr` 自动析构，解决当前可能存在的内存泄漏问题
- 扩展的生命周期与引擎实例一致，适合使用独占指针

**替代方案：**
- ❌ 全局单例 - 无法支持多引擎实例的独立追踪
- ❌ 裸指针 - 需要手动管理生命周期，容易出错
- ❌ `TSharedPtr` - 过度设计，覆盖率对象不需要共享

**实现：**
```cpp
class FAngelscriptCodeCoverageExtension : public IAngelscriptExtension
{
private:
    TUniquePtr<FAngelscriptCodeCoverage> Coverage;
    FAngelscriptEngine* AttachedEngine = nullptr;
    
public:
    virtual void OnEngineAttached(FAngelscriptEngine& Engine) override
    {
        if (FAngelscriptCodeCoverage::CoverageEnabled())
        {
            Coverage = MakeUnique<FAngelscriptCodeCoverage>();
            AttachedEngine = &Engine;
            
            #if WITH_EDITOR
            Coverage->AddTestFrameworkHooks();
            #endif
        }
    }
    
    virtual void OnEngineDetached(FAngelscriptEngine& Engine) override
    {
        Coverage.Reset(); // 自动析构
        AttachedEngine = nullptr;
    }
};
```

### 决策 2: 引擎访问覆盖率对象的策略

**选择：通过扩展注册表查找扩展，然后访问覆盖率对象**

**理由：**
- 移除引擎成员指针，解耦引擎和覆盖率系统
- 覆盖率系统成为可选扩展，不影响引擎核心结构
- 保持 API 兼容性，现有调用点通过辅助函数访问

**替代方案：**
- ❌ 保留引擎成员指针 - 违反扩展化目标
- ❌ 全局访问器 - 无法支持多引擎实例

**实现：**
```cpp
// AngelscriptCodeCoverage.h
class FAngelscriptCodeCoverageExtension : public IAngelscriptExtension
{
public:
    FAngelscriptCodeCoverage* GetCoverage() const { return Coverage.Get(); }
    
    // 静态辅助函数：为给定引擎查找覆盖率对象
    static FAngelscriptCodeCoverage* GetForEngine(FAngelscriptEngine& Engine);
};

// 引擎中的调用改为：
FAngelscriptCodeCoverage* Coverage = FAngelscriptCodeCoverageExtension::GetForEngine(*this);
if (Coverage != nullptr)
{
    Coverage->MapExecutableLines(Module);
}
```

### 决策 3: 测试框架钩子注册时机

**选择：在 `OnEngineAttached` 中立即调用 `AddTestFrameworkHooks()`**

**理由：**
- 移除对 `FCoreDelegates::OnPostEngineInit` 的依赖
- 引擎附加时自动化测试模块已经加载（如果在编辑器环境）
- 避免 Lambda 闭包捕获引起的生命周期问题
- 简化初始化流程，逻辑集中

**替代方案：**
- ❌ 保留 `OnPostEngineInit` - 不必要的延迟，增加复杂度
- ❌ 延迟到第一次使用 - 增加状态管理复杂度

**风险缓解：**
- `AddTestFrameworkHooks()` 内部应该检查自动化测试模块是否可用
- 如果模块未加载，静默失败或记录警告，不阻止引擎初始化

### 决策 4: 覆盖率对象的访问边界

**选择：保持覆盖率对象的访问为引擎实例局部的，不提供全局访问**

**理由：**
- 每个引擎实例有独立的覆盖率数据
- 避免多引擎环境下的数据混淆
- 符合扩展系统的设计原则

**实现细节：**
- 引擎内部通过 `FAngelscriptCodeCoverageExtension::GetForEngine(*this)` 访问
- 外部代码需要通过引擎实例访问（不提供静态全局访问器）
- 测试代码可以直接创建扩展实例进行单元测试

### 决策 5: 扩展注册位置

**选择：在 `FAngelscriptRuntimeModule::StartupModule()` 中注册扩展**

**理由：**
- 与崩溃快照扩展保持一致
- 扩展需要在任何引擎实例创建之前注册
- 模块启动是最早的初始化点

**实现：**
```cpp
void FAngelscriptRuntimeModule::StartupModule()
{
    // 注册代码覆盖率扩展
    #if WITH_AS_COVERAGE
    FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(
        MakeShared<FAngelscriptCodeCoverageExtension>());
    #endif
}
```

## Risks / Trade-offs

### 风险 1: 测试框架钩子注册失败

**风险：** 如果在 `OnEngineAttached` 时自动化测试模块尚未加载，`AddTestFrameworkHooks()` 可能失败。

**缓解：**
- 在 `AddTestFrameworkHooks()` 内部检查 `IAutomationControllerModule` 是否可用
- 如果不可用，记录警告日志但不阻止引擎初始化
- 编辑器环境下，引擎子系统初始化时自动化模块通常已经加载

### 风险 2: 引擎访问覆盖率对象的性能

**风险：** 通过扩展注册表查找覆盖率对象可能引入性能开销。

**缓解：**
- 覆盖率追踪本身是开发时功能，性能不是主要关注点
- 可以在引擎内部缓存扩展指针（如果需要）
- `GetForEngine()` 实现应该高效（直接从注册表查找，O(1) 或 O(N)，N 为扩展数量通常很小）

### 风险 3: 多引擎实例下的覆盖率数据管理

**风险：** 在多引擎实例环境下，如何合并或区分不同引擎的覆盖率数据？

**接受理由：**
- 当前实现本身不支持多引擎覆盖率数据合并
- 每个引擎实例独立生成覆盖率报告，符合预期
- 如果需要合并，可以在后续改进中实现（超出此次重构范围）

### Trade-off 1: 扩展查找开销 vs 引擎成员直接访问

**权衡：** 移除引擎成员指针后，访问覆盖率对象需要通过扩展查找，增加了间接层。

**接受理由：**
- 解耦带来的架构优势大于性能损失
- 覆盖率追踪调用频率不高（主要在行回调中，已有性能开销）
- 可以通过缓存优化（如果成为瓶颈）

### Trade-off 2: 按引擎实例独立 vs 全局单例

**权衡：** 每个引擎实例独立的覆盖率对象会增加内存占用。

**接受理由：**
- 支持多引擎实例是正确的架构选择
- 实际使用中，覆盖率通常只在单引擎环境下启用
- 内存占用相对于覆盖率数据本身可以忽略不计

## Migration Plan

### 实施步骤

1. **创建扩展类**
   - 在 `AngelscriptCodeCoverage.h` 中添加 `FAngelscriptCodeCoverageExtension` 类
   - 实现 `OnEngineAttached` 和 `OnEngineDetached`
   - 使用 `TUniquePtr<FAngelscriptCodeCoverage>` 持有覆盖率对象

2. **添加访问辅助函数**
   - 实现 `FAngelscriptCodeCoverageExtension::GetForEngine(FAngelscriptEngine&)` 静态函数
   - 通过扩展注册表查找扩展实例并返回覆盖率对象指针

3. **移除引擎成员指针**
   - 从 `FAngelscriptEngine` 中删除 `CodeCoverage` 成员
   - 删除 `Initialize_AnyThread()` 中的 `CodeCoverage = new FAngelscriptCodeCoverage`
   - 删除 `PostInitialize_GameThread()` 中的 `OnPostEngineInit` Lambda

4. **更新引擎内部调用点**
   - 查找所有访问 `CodeCoverage` 的代码
   - 改为通过 `FAngelscriptCodeCoverageExtension::GetForEngine(*this)` 访问
   - 主要调用点：`MapExecutableLines`, `HitLine`, 状态导出

5. **注册扩展**
   - 在 `FAngelscriptRuntimeModule::StartupModule()` 中注册扩展
   - 使用 `#if WITH_AS_COVERAGE` 条件编译

6. **构建和验证**
   - 运行 `Tools\RunBuild.ps1` 确保编译通过
   - 验证编辑器启动无错误日志
   - 确认覆盖率功能在测试中正常工作

7. **测试覆盖率功能**
   - 运行自动化测试并生成覆盖率报告
   - 验证报告格式和内容未改变
   - 测试多引擎实例场景（如果有相关测试）

8. **清理和文档更新**
   - 检查是否有遗留的引用
   - 更新相关文档和注释

### 回滚策略

如果出现问题，可以简单回退：
1. 恢复 `FAngelscriptEngine::CodeCoverage` 成员指针
2. 恢复 `Initialize_AnyThread()` 和 `PostInitialize_GameThread()` 中的初始化代码
3. 取消扩展注册
4. 删除扩展类

所有更改都是加法性的，不影响现有功能的核心逻辑。

### 验证清单

- [ ] 编辑器启动时代码覆盖率系统正常初始化（如果 `CoverageEnabled()`）
- [ ] 测试框架钩子正确注册，覆盖率在测试运行时追踪
- [ ] 覆盖率报告生成功能正常，输出格式不变
- [ ] 多次创建/销毁引擎实例不会导致内存泄漏
- [ ] `MapExecutableLines` 和 `HitLine` 调用正常工作
- [ ] 状态导出包含覆盖率信息（如果启用）
- [ ] 不再有 `delete CodeCoverage` 遗漏导致的内存泄漏

## Open Questions

1. **是否需要支持跨引擎实例的覆盖率数据合并？**
   - 当前设计是每个引擎实例独立的覆盖率数据
   - 如果需要合并，可以在报告生成阶段实现
   - 建议：暂时保持独立，需要时再扩展

2. **是否需要提供全局访问器用于外部工具？**
   - 当前设计要求通过引擎实例访问覆盖率对象
   - 外部工具（如覆盖率分析器）可能需要直接访问
   - 建议：先实现引擎实例局部访问，如果外部工具需要再添加全局访问器

3. **是否需要在扩展中缓存引擎指针？**
   - 当前设计存储了 `AttachedEngine` 指针
   - 可用于未来的引擎实例关联需求
   - 建议：保留，但目前未使用
