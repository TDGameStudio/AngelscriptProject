# Proposal: Refactor Crash Snapshot as Extension

## Why

当前崩溃快照系统（`FAngelscriptCrashSnapshot`）在 `FAngelscriptRuntimeModule::StartupModule()` 中全局初始化，生命周期与模块绑定而非引擎实例。这导致该系统无法感知特定引擎实例的生命周期，无法利用引擎扩展机制进行按需启用/禁用，也难以在多引擎实例环境中正确工作。将其重构为引擎扩展可以解耦生命周期管理，使其成为可选的、按引擎实例管理的诊断功能。

## What Changes

- 将 `FAngelscriptCrashSnapshot` 从全局静态初始化改为通过 `IAngelscriptExtension` 接口实现
- 创建 `FAngelscriptCrashSnapshotExtension` 类，实现 `OnEngineAttached` 和 `OnEngineDetached` 生命周期钩子
- 移除 `FAngelscriptRuntimeModule` 中的 `Startup()/Shutdown()` 调用
- 将 `FCoreDelegates::OnHandleSystemError` 的注册移到扩展的 `OnEngineAttached` 中
- 支持多引擎实例环境下的独立崩溃快照生成
- 保持现有的崩溃快照 JSON 输出格式和测试接口兼容性

## Capabilities

### New Capabilities

- `crash-snapshot-extension`: 崩溃快照系统作为引擎扩展的完整实现，包括生命周期管理、引擎实例感知、延迟初始化等能力

### Modified Capabilities

<!-- 无现有规范变更，这是纯内部重构 -->

## Impact

**代码影响：**
- `AngelscriptRuntime/Dump/AngelscriptCrashSnapshot.h` - 修改公共接口，添加扩展类
- `AngelscriptRuntime/Dump/AngelscriptCrashSnapshot.cpp` - 重构初始化逻辑
- `AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` - 移除直接调用，注册扩展
- `AngelscriptRuntime/Core/AngelscriptEngineExtensionRegistry.h` - 可能需要确认多引擎实例支持

**行为影响：**
- 崩溃快照将在第一个 `FAngelscriptEngine` 实例创建时注册全局崩溃处理器
- 在最后一个引擎实例销毁时取消注册
- 现有测试代码（`WriteSnapshotForTesting`, `ConfigureForTesting`）保持兼容
- 编辑器和运行时的崩溃快照功能不受影响

**依赖影响：**
- 引擎扩展注册表成为崩溃快照系统的必要依赖
- 引擎实例的生命周期决定崩溃快照功能的激活状态
