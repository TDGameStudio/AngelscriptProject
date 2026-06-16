# Proposal: Refactor Code Coverage as Extension

## Why

当前代码覆盖率系统（`FAngelscriptCodeCoverage`）在 `FAngelscriptEngine::Initialize_AnyThread()` 中通过 `new FAngelscriptCodeCoverage` 直接创建，并在 `PostInitialize_GameThread()` 中通过 `FCoreDelegates::OnPostEngineInit` Lambda 注册测试框架钩子。这种设计导致：

1. **生命周期管理混乱**：对象通过裸指针持有，析构逻辑不清晰
2. **初始化时机依赖全局回调**：使用 `OnPostEngineInit` Lambda 闭包，难以追踪和测试
3. **无法利用扩展机制**：代码覆盖率是典型的可选诊断功能，应该通过扩展系统管理
4. **与崩溃快照系统不一致**：类似的诊断功能应该使用统一的扩展模式

将其重构为引擎扩展可以：
- 使用 `IAngelscriptExtension` 统一管理生命周期
- 在引擎附加时直接初始化，无需延迟到 `OnPostEngineInit`
- 与其他扩展（如崩溃快照）保持一致的架构模式
- 简化测试和调试

## What Changes

- 将 `FAngelscriptCodeCoverage` 从引擎内部裸指针改为通过 `IAngelscriptExtension` 接口管理
- 创建 `FAngelscriptCodeCoverageExtension` 类，实现 `OnEngineAttached` 和 `OnEngineDetached` 生命周期钩子
- 移除 `FAngelscriptEngine::Initialize_AnyThread()` 中的 `CodeCoverage = new FAngelscriptCodeCoverage`
- 移除 `PostInitialize_GameThread()` 中的 `OnPostEngineInit` Lambda 闭包
- 在扩展的 `OnEngineAttached` 中创建 `FAngelscriptCodeCoverage` 实例并调用 `AddTestFrameworkHooks()`
- 在扩展的 `OnEngineDetached` 中清理代码覆盖率对象
- 支持按引擎实例独立的代码覆盖率追踪（每个引擎实例有独立的覆盖率数据）
- 保持现有的覆盖率 API 和报告生成逻辑不变

## Capabilities

### New Capabilities

- `code-coverage-extension`: 代码覆盖率系统作为引擎扩展的完整实现，包括生命周期管理、按引擎实例独立追踪、测试框架钩子集成等能力

### Modified Capabilities

<!-- 无现有规范变更，这是纯内部重构 -->

## Impact

**代码影响：**
- `AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.h` - 修改接口，添加扩展类
- `AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp` - 重构初始化逻辑
- `AngelscriptRuntime/Core/AngelscriptEngine.h` - 移除 `CodeCoverage` 裸指针成员
- `AngelscriptRuntime/Core/AngelscriptEngine.cpp` - 移除直接创建和 Lambda 注册代码
- `AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` - 注册扩展

**行为影响：**
- 代码覆盖率将在 `FAngelscriptEngine` 实例创建时初始化（如果 `CoverageEnabled()`）
- 测试框架钩子在引擎附加时立即注册，不再依赖 `OnPostEngineInit`
- 每个引擎实例拥有独立的 `FAngelscriptCodeCoverage` 对象
- 覆盖率报告生成逻辑保持不变
- 现有的 `MapExecutableLines`, `HitLine`, `StartRecording`, `StopRecordingAndWriteReport` API 保持兼容

**依赖影响：**
- 引擎扩展注册表成为代码覆盖率系统的必要依赖
- 移除对 `FCoreDelegates::OnPostEngineInit` 的依赖
- 引擎实例的生命周期决定代码覆盖率功能的激活状态

**优势：**
- ✅ 支持多引擎实例环境下的独立覆盖率追踪
- ✅ 生命周期管理更清晰（通过扩展接口而非裸指针）
- ✅ 初始化时机更可控（引擎附加时而非全局回调）
- ✅ 与其他扩展（崩溃快照、热重载）架构一致
