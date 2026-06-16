# Spec: Crash Snapshot Extension

## ADDED Requirements

### Requirement: Extension lifecycle management

崩溃快照系统 SHALL 通过 `IAngelscriptExtension` 接口管理其生命周期，而不是在模块启动时全局初始化。

#### Scenario: Extension registration during module startup
- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` 执行
- **THEN** 崩溃快照扩展 SHALL 通过 `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension()` 注册

#### Scenario: Extension NOT directly initialized during module startup
- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` 执行
- **THEN** 系统 SHALL NOT 直接调用 `FAngelscriptCrashSnapshot::Startup()`

#### Scenario: Extension NOT directly shutdown during module unload
- **WHEN** `FAngelscriptRuntimeModule::ShutdownModule()` 执行
- **THEN** 系统 SHALL NOT 直接调用 `FAngelscriptCrashSnapshot::Shutdown()`

### Requirement: Engine instance awareness

崩溃快照系统 SHALL 响应每个 `FAngelscriptEngine` 实例的创建和销毁事件。

#### Scenario: First engine instance attached
- **WHEN** 第一个 `FAngelscriptEngine` 实例通过 `OnEngineAttached` 附加到扩展
- **THEN** 扩展 SHALL 调用 `FAngelscriptCrashSnapshot::Startup()` 注册全局崩溃处理器

#### Scenario: Middle engine instance attached
- **WHEN** 第二个或后续的 `FAngelscriptEngine` 实例通过 `OnEngineAttached` 附加
- **THEN** 扩展 SHALL 递增引用计数但 SHALL NOT 再次注册崩溃处理器

#### Scenario: Middle engine instance detached
- **WHEN** 非最后一个 `FAngelscriptEngine` 实例通过 `OnEngineDetached` 分离
- **THEN** 扩展 SHALL 递减引用计数但 SHALL NOT 取消注册崩溃处理器

#### Scenario: Last engine instance detached
- **WHEN** 最后一个 `FAngelscriptEngine` 实例通过 `OnEngineDetached` 分离
- **THEN** 扩展 SHALL 调用 `FAngelscriptCrashSnapshot::Shutdown()` 取消注册全局崩溃处理器

### Requirement: Reference counting thread safety

引擎实例引用计数 SHALL 是线程安全的，支持多线程环境下的引擎创建和销毁。

#### Scenario: Concurrent engine instance creation
- **WHEN** 多个线程同时创建 `FAngelscriptEngine` 实例并触发 `OnEngineAttached`
- **THEN** 引用计数的递增操作 SHALL 是原子的，不产生竞态条件

#### Scenario: Concurrent engine instance destruction
- **WHEN** 多个线程同时销毁 `FAngelscriptEngine` 实例并触发 `OnEngineDetached`
- **THEN** 引用计数的递减操作 SHALL 是原子的，不产生竞态条件

#### Scenario: Concurrent creation and destruction
- **WHEN** 一个线程正在附加引擎实例，另一个线程正在分离引擎实例
- **THEN** 引用计数操作 SHALL 保持一致性，崩溃处理器注册状态 SHALL 正确

### Requirement: Crash handler behavior preservation

崩溃处理器的行为和输出格式 SHALL 与扩展化之前保持完全一致。

#### Scenario: Crash snapshot content unchanged
- **WHEN** 系统崩溃触发 `OnHandleSystemError` 回调
- **THEN** 生成的崩溃快照 JSON SHALL 包含与之前相同的字段和数据结构

#### Scenario: Crash snapshot file path unchanged
- **WHEN** 系统崩溃时未配置自定义输出路径
- **THEN** 崩溃快照 SHALL 写入 `<ProjectSaved>/Angelscript/CrashSnapshots/<timestamp>/AngelscriptCrashSnapshot.json`

#### Scenario: Crash handler atomic execution
- **WHEN** 系统崩溃触发崩溃处理器
- **THEN** 崩溃处理器 SHALL 使用 `GHandlingCrash` 原子变量确保只执行一次

#### Scenario: Current engine resolution
- **WHEN** 崩溃处理器执行时需要获取引擎实例
- **THEN** 系统 SHALL 通过 `FAngelscriptEngine::TryGetCurrentEngine()` 获取当前引擎上下文

### Requirement: Testing interface compatibility

测试接口 SHALL 保持向后兼容，不受扩展化重构的影响。

#### Scenario: WriteSnapshotForTesting remains functional
- **WHEN** 测试代码调用 `FAngelscriptCrashSnapshot::WriteSnapshotForTesting(OutputDir, Marker)`
- **THEN** 系统 SHALL 生成崩溃快照到指定目录，格式与实际崩溃时一致

#### Scenario: ConfigureForTesting remains functional
- **WHEN** 测试代码调用 `FAngelscriptCrashSnapshot::ConfigureForTesting(OutputDir, Marker)`
- **THEN** 全局崩溃快照配置 SHALL 被更新，后续崩溃使用该配置

#### Scenario: Console command remains functional
- **WHEN** 测试通过控制台执行 `as.Test.ConfigureCrashSnapshot <dir> <marker>`
- **THEN** 系统 SHALL 调用 `ConfigureForTesting` 并输出确认日志

### Requirement: Multiple engine instance support

崩溃快照系统 SHALL 支持进程中存在多个 `FAngelscriptEngine` 实例的场景。

#### Scenario: Sequential engine creation and destruction
- **WHEN** 创建引擎实例 A，销毁 A，创建引擎实例 B，销毁 B
- **THEN** 崩溃处理器 SHALL 在 A 创建时注册，A 销毁时取消注册，B 创建时重新注册，B 销毁时再次取消注册

#### Scenario: Overlapping engine lifetimes
- **WHEN** 创建引擎实例 A，创建引擎实例 B，销毁 A，销毁 B
- **THEN** 崩溃处理器 SHALL 在 A 创建时注册，在 B 销毁时取消注册

#### Scenario: Crash with multiple active engines
- **WHEN** 系统中有多个活跃的 `FAngelscriptEngine` 实例时发生崩溃
- **THEN** 崩溃快照 SHALL 基于 `FAngelscriptEngine::TryGetCurrentEngine()` 返回的当前引擎生成

### Requirement: No memory leaks

扩展系统 SHALL 不引入内存泄漏或资源泄漏。

#### Scenario: Extension object lifecycle
- **WHEN** 扩展通过 `RegisterExtension` 注册并最终模块卸载
- **THEN** 扩展对象 SHALL 通过 `TSharedRef` 正确管理生命周期，不产生内存泄漏

#### Scenario: Repeated engine creation and destruction
- **WHEN** 多次创建和销毁 `FAngelscriptEngine` 实例（例如测试场景）
- **THEN** 系统 SHALL NOT 泄漏崩溃处理器句柄或其他资源

#### Scenario: Crash handler delegate handle management
- **WHEN** 崩溃处理器在 `Startup()` 中注册 `FCoreDelegates::OnHandleSystemError` 回调
- **THEN** 回调句柄 SHALL 在 `Shutdown()` 中正确移除，不产生悬挂引用

### Requirement: Graceful degradation

崩溃快照系统 SHALL 在异常情况下优雅降级，不阻止引擎初始化。

#### Scenario: Extension registration failure
- **WHEN** 扩展注册因任何原因失败（理论上不应发生）
- **THEN** 系统 SHALL 记录错误日志但 SHALL NOT 阻止模块启动

#### Scenario: Crash handler registration failure
- **WHEN** `FCoreDelegates::OnHandleSystemError.Add` 失败
- **THEN** 系统 SHALL 记录错误日志但 SHALL NOT 崩溃或阻止引擎初始化

#### Scenario: Crash snapshot write failure
- **WHEN** 崩溃时无法创建输出目录或写入 JSON 文件
- **THEN** 系统 SHALL 记录错误信息但 SHALL NOT 引发二次崩溃

### Requirement: Logging and diagnostics

扩展系统 SHALL 提供足够的日志记录以便诊断崩溃快照系统的生命周期。

#### Scenario: Engine attachment logging
- **WHEN** `FAngelscriptEngine` 实例附加到扩展
- **THEN** 系统 SHALL 记录引擎附加事件和当前引用计数

#### Scenario: Engine detachment logging
- **WHEN** `FAngelscriptEngine` 实例从扩展分离
- **THEN** 系统 SHALL 记录引擎分离事件和当前引用计数

#### Scenario: Crash handler registration logging
- **WHEN** 第一个引擎附加导致崩溃处理器注册
- **THEN** 系统 SHALL 记录 "Angelscript crash snapshot handler registered" 或类似日志

#### Scenario: Crash handler unregistration logging
- **WHEN** 最后一个引擎分离导致崩溃处理器取消注册
- **THEN** 系统 SHALL 记录 "Angelscript crash snapshot handler unregistered" 或类似日志
