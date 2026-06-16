# Spec: Code Coverage Extension

## ADDED Requirements

### Requirement: Extension lifecycle management

代码覆盖率系统 SHALL 通过 `IAngelscriptExtension` 接口管理其生命周期，而不是在引擎初始化时直接创建。

#### Scenario: Extension registration during module startup
- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` 执行且 `WITH_AS_COVERAGE` 已定义
- **THEN** 代码覆盖率扩展 SHALL 通过 `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension()` 注册

#### Scenario: Extension NOT directly initialized during engine creation
- **WHEN** `FAngelscriptEngine::Initialize_AnyThread()` 执行
- **THEN** 系统 SHALL NOT 直接创建 `FAngelscriptCodeCoverage` 对象或设置 `CodeCoverage` 成员指针

#### Scenario: Extension NOT use delayed callback for initialization
- **WHEN** `FAngelscriptEngine::PostInitialize_GameThread()` 执行
- **THEN** 系统 SHALL NOT 注册 `FCoreDelegates::OnPostEngineInit` Lambda 闭包

### Requirement: Engine instance awareness

代码覆盖率系统 SHALL 响应每个 `FAngelscriptEngine` 实例的创建和销毁事件，支持独立的覆盖率追踪。

#### Scenario: Engine instance attached with coverage enabled
- **WHEN** `FAngelscriptEngine` 实例通过 `OnEngineAttached` 附加到扩展且 `FAngelscriptCodeCoverage::CoverageEnabled()` 返回 true
- **THEN** 扩展 SHALL 创建一个新的 `FAngelscriptCodeCoverage` 对象并通过 `TUniquePtr` 持有

#### Scenario: Engine instance attached with coverage disabled
- **WHEN** `FAngelscriptEngine` 实例通过 `OnEngineAttached` 附加但 `CoverageEnabled()` 返回 false
- **THEN** 扩展 SHALL NOT 创建 `FAngelscriptCodeCoverage` 对象

#### Scenario: Engine instance detached
- **WHEN** `FAngelscriptEngine` 实例通过 `OnEngineDetached` 从扩展分离
- **THEN** 扩展 SHALL 通过 `TUniquePtr::Reset()` 释放关联的 `FAngelscriptCodeCoverage` 对象

#### Scenario: Multiple engine instances with independent coverage
- **WHEN** 创建两个 `FAngelscriptEngine` 实例，每个都启用了代码覆盖率
- **THEN** 每个引擎实例 SHALL 拥有独立的 `FAngelscriptCodeCoverage` 对象，覆盖率数据互不干扰

### Requirement: Test framework hooks integration

代码覆盖率扩展 SHALL 在引擎附加时立即集成测试框架钩子，无需延迟回调。

#### Scenario: Test framework hooks registration in editor
- **WHEN** 引擎实例附加到扩展且 `WITH_EDITOR` 已定义
- **THEN** 扩展 SHALL 调用 `Coverage->AddTestFrameworkHooks()` 注册测试框架钩子

#### Scenario: Test framework hooks NOT registered outside editor
- **WHEN** 引擎实例附加到扩展但 `WITH_EDITOR` 未定义
- **THEN** 扩展 SHALL NOT 调用 `AddTestFrameworkHooks()`

#### Scenario: Graceful handling of missing automation module
- **WHEN** `AddTestFrameworkHooks()` 执行但 `IAutomationControllerModule` 未加载
- **THEN** 系统 SHALL 记录警告日志但 SHALL NOT 崩溃或阻止引擎初始化

### Requirement: Coverage object access through extension

引擎和外部代码 SHALL 通过扩展系统访问代码覆盖率对象，而不是直接通过引擎成员指针。

#### Scenario: Access coverage for specific engine
- **WHEN** 代码调用 `FAngelscriptCodeCoverageExtension::GetForEngine(Engine)`
- **THEN** 系统 SHALL 通过扩展注册表查找关联的扩展实例并返回其 `Coverage` 指针

#### Scenario: Access coverage when not enabled
- **WHEN** 调用 `GetForEngine(Engine)` 但该引擎实例未启用代码覆盖率
- **THEN** 系统 SHALL 返回 `nullptr`

#### Scenario: Access coverage when extension not registered
- **WHEN** 调用 `GetForEngine(Engine)` 但扩展未注册（`WITH_AS_COVERAGE` 未定义）
- **THEN** 系统 SHALL 返回 `nullptr`

#### Scenario: No engine member pointer for coverage
- **WHEN** 检查 `FAngelscriptEngine` 类定义
- **THEN** 系统 SHALL NOT 包含 `FAngelscriptCodeCoverage* CodeCoverage` 成员变量

### Requirement: Coverage functionality preservation

代码覆盖率的所有功能和 API SHALL 保持与扩展化之前完全一致。

#### Scenario: MapExecutableLines still works
- **WHEN** 模块编译后调用覆盖率的 `MapExecutableLines(Module)`
- **THEN** 系统 SHALL 正确映射模块中的可执行行到内部覆盖率表

#### Scenario: HitLine still works
- **WHEN** 脚本执行触发行回调并调用 `HitLine(Module, Line)`
- **THEN** 系统 SHALL 正确记录该行的执行次数

#### Scenario: StartRecording still works
- **WHEN** 测试框架或用户代码调用 `StartRecording()`
- **THEN** 系统 SHALL 开始记录行命中，后续 `HitLine` 调用生效

#### Scenario: StopRecordingAndWriteReport still works
- **WHEN** 测试结束后调用 `StopRecordingAndWriteReport(OutputDir)`
- **THEN** 系统 SHALL 停止记录并将覆盖率报告 HTML 文件写入指定目录

#### Scenario: Coverage report format unchanged
- **WHEN** 生成覆盖率报告
- **THEN** 输出的 HTML 文件结构和内容格式 SHALL 与扩展化之前一致

### Requirement: Memory management correctness

代码覆盖率对象 SHALL 正确管理生命周期，无内存泄漏或悬挂引用。

#### Scenario: Coverage object properly destroyed on engine detach
- **WHEN** 引擎实例从扩展分离
- **THEN** 关联的 `FAngelscriptCodeCoverage` 对象 SHALL 通过 `TUniquePtr` 自动析构

#### Scenario: No memory leak in repeated engine creation
- **WHEN** 多次创建和销毁引擎实例（例如测试场景）
- **THEN** 系统 SHALL NOT 泄漏 `FAngelscriptCodeCoverage` 对象或其内部数据结构

#### Scenario: Test framework delegate handles properly removed
- **WHEN** 覆盖率对象析构时
- **THEN** 在 `AddTestFrameworkHooks()` 中注册的自动化测试委托 SHALL 被正确移除

#### Scenario: No dangling Lambda captures
- **WHEN** 检查代码中不再使用 `OnPostEngineInit` Lambda
- **THEN** 系统 SHALL NOT 包含可能导致悬挂引用的 Lambda 闭包

### Requirement: Engine internal call site updates

引擎内部所有访问代码覆盖率的调用点 SHALL 更新为通过扩展系统访问。

#### Scenario: CompileModules uses GetForEngine
- **WHEN** `FAngelscriptEngine::CompileModules` 需要调用 `MapExecutableLines`
- **THEN** 系统 SHALL 通过 `FAngelscriptCodeCoverageExtension::GetForEngine(*this)` 获取覆盖率对象

#### Scenario: Line callback uses GetForEngine
- **WHEN** 脚本行回调函数需要调用 `HitLine`
- **THEN** 系统 SHALL 通过 `GetForEngine` 获取覆盖率对象

#### Scenario: GetOnScreenMessages uses GetForEngine
- **WHEN** `GetOnScreenMessages` 需要显示覆盖率状态
- **THEN** 系统 SHALL 通过 `GetForEngine` 获取覆盖率对象

#### Scenario: State dump uses GetForEngine
- **WHEN** `FAngelscriptStateDump` 需要导出覆盖率信息
- **THEN** 系统 SHALL 通过 `GetForEngine(Engine)` 获取覆盖率对象

### Requirement: Conditional compilation preservation

代码覆盖率系统 SHALL 保持现有的条件编译行为。

#### Scenario: Extension only compiled with WITH_AS_COVERAGE
- **WHEN** 编译时未定义 `WITH_AS_COVERAGE`
- **THEN** `FAngelscriptCodeCoverageExtension` 类和相关代码 SHALL NOT 被编译

#### Scenario: Extension registered only with WITH_AS_COVERAGE
- **WHEN** 模块启动且 `WITH_AS_COVERAGE` 未定义
- **THEN** 系统 SHALL NOT 注册代码覆盖率扩展

#### Scenario: Test framework hooks only in editor
- **WHEN** 引擎附加到扩展但 `WITH_EDITOR` 未定义
- **THEN** 系统 SHALL NOT 尝试调用 `AddTestFrameworkHooks()`

### Requirement: Multi-engine instance support

代码覆盖率系统 SHALL 正确支持进程中存在多个 `FAngelscriptEngine` 实例的场景。

#### Scenario: Sequential engine creation with coverage
- **WHEN** 创建引擎 A 启用覆盖率，销毁 A，创建引擎 B 启用覆盖率，销毁 B
- **THEN** 每个引擎实例 SHALL 拥有独立的覆盖率对象，生命周期互不影响

#### Scenario: Overlapping engine lifetimes with coverage
- **WHEN** 创建引擎 A 和 B 都启用覆盖率，两者同时存在
- **THEN** 两个引擎实例 SHALL 各自拥有独立的覆盖率数据，互不干扰

#### Scenario: Coverage data isolation
- **WHEN** 引擎 A 执行脚本并记录覆盖率，引擎 B 也执行脚本
- **THEN** 引擎 A 的覆盖率数据 SHALL NOT 包含引擎 B 的执行记录

#### Scenario: Independent coverage reports
- **WHEN** 两个引擎实例分别生成覆盖率报告
- **THEN** 每个报告 SHALL 仅包含对应引擎实例的覆盖率数据

### Requirement: CoverageEnabled check preservation

`FAngelscriptCodeCoverage::CoverageEnabled()` 静态检查 SHALL 保持现有行为。

#### Scenario: Coverage enabled based on command line or config
- **WHEN** 通过命令行参数或配置启用代码覆盖率
- **THEN** `CoverageEnabled()` SHALL 返回 true，扩展创建覆盖率对象

#### Scenario: Coverage disabled by default
- **WHEN** 未设置覆盖率启用标志
- **THEN** `CoverageEnabled()` SHALL 返回 false，扩展不创建覆盖率对象

#### Scenario: Coverage respect WITH_AS_COVERAGE definition
- **WHEN** 编译时未定义 `WITH_AS_COVERAGE`
- **THEN** 系统 SHALL NOT 提供 `CoverageEnabled()` 功能或返回 false

### Requirement: Performance and overhead

代码覆盖率扩展 SHALL 不引入显著的性能开销或增加初始化时间。

#### Scenario: Extension registration minimal overhead
- **WHEN** 模块启动并注册代码覆盖率扩展
- **THEN** 注册操作 SHALL 在毫秒级完成，不影响模块启动性能

#### Scenario: GetForEngine lookup efficient
- **WHEN** 引擎内部调用 `GetForEngine` 访问覆盖率对象
- **THEN** 查找操作 SHALL 是 O(1) 或 O(N)（N 为扩展数量，通常 < 10），不成为性能瓶颈

#### Scenario: Coverage tracking overhead unchanged
- **WHEN** 覆盖率启用时脚本执行触发行回调
- **THEN** 通过扩展访问覆盖率对象的额外开销 SHALL 可忽略不计（相对于覆盖率追踪本身）

### Requirement: Logging and diagnostics

扩展系统 SHALL 提供足够的日志记录以便诊断代码覆盖率系统的生命周期和问题。

#### Scenario: Engine attachment with coverage logging
- **WHEN** 引擎实例附加到扩展且覆盖率启用
- **THEN** 系统 SHALL 记录 "Code coverage enabled for engine instance" 或类似日志

#### Scenario: Engine detachment logging
- **WHEN** 引擎实例从扩展分离
- **THEN** 系统 SHALL 记录引擎分离和覆盖率对象清理事件

#### Scenario: Test framework hooks registration logging
- **WHEN** 测试框架钩子成功注册
- **THEN** 系统 SHALL 记录 "Code coverage test framework hooks registered" 或类似日志

#### Scenario: Test framework hooks failure logging
- **WHEN** 测试框架钩子注册失败（例如模块未加载）
- **THEN** 系统 SHALL 记录警告日志说明失败原因

#### Scenario: Coverage report generation logging
- **WHEN** 覆盖率报告生成完成
- **THEN** 系统 SHALL 记录输出目录和报告文件数量
