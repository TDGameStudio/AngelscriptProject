# 调试 / 日志 / 错误处理 覆盖矩阵

> **本矩阵是调试/日志/错误处理测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 3 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持。
>
> - 测试文件：`Debug`(17) / `Logging`(13) / `ErrorHandling`(6) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Debug|Logging|ErrorHandling>`
> - 图例见 `../coverage-matrix.md`。

## 1. 调试（DebugTests 17）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Ensure/Check 绑定 / Callstack 与 Throw 绑定 | ✅ | `EnsureAndCheckBindings` `CallstackAndThrowBindings` |
| 日志严重级辅助 / 格式化调试日志表面 | ✅ | `LogSeverityHelpersEmitExpectedVerbosity` `FormattedDebugLoggingSurfaceIncludesValuesAndContext` |
| DrawDebugString（来自对象 / 参数化） | ✅ | `DrawDebugStringFromObject` `DrawDebugStringParameters` |
| DebugBreak 可在自动化中禁用 | ✅ | `DebugBreakBindingCanBeDisabledForAutomation` |
| 对象检查辅助暴露名称与 Outer | ✅ | `ObjectInspectionHelpersExposeNamesAndOuter` |
| CPU Profiler scoped event 面向脚本 / Profiler 模式（计数器/暂存内存） | ✅ | `CpuProfilerScopedEventIsScriptFacing` `ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory` |
| Stat/Show 命令名经注册控制台命令分发 | ✅ | `StatAndShowCommandNamesDispatchThroughRegisteredConsoleCommand` |
| 调试错误处理模式 / 调试工作流用可调用脚本辅助 | ✅ | `DebugErrorHandlingPatterns` `DebuggingWorkflowPatternsUseCallableScriptHelpers` |
| 原生日志 Verbosity 枚举编译期边界 | 🚫 | `NativeLogVerbosityEnumsRemainCompileTimeBoundary` |
| 不支持的 DrawDebug 形状参数编译失败 | 🚫 | `UnsupportedDrawDebugShapeParametersFailToCompile` |
| 控制台 Profiler 与 Debugger 控制编译失败 / Debugger 客户端专属特性编译失败 | 🚫 | `ConsoleProfilerAndDebuggerControlsFailToCompile` `DebuggerClientOnlyFeaturesFailToCompile` |

## 2. 日志（LoggingTests 13）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Print 函数 / UE_LOG 宏 | ✅ | `PrintFunctions` `UELogMacros` |
| 日志类别 / 格式化 | ✅ | `LogCategories` `LogFormatting` |
| 条件日志 / 条件日志函数门控 | ✅ | `ConditionalLogging` `ConditionalLogFunctionsGateOutput` |
| 函数进出日志 / 性能友好日志 / 上下文丰富日志 | ✅ | `FunctionEntryExitLogging` `PerformanceConsciousLogging` `ContextRichLogging` |
| Verbosity 函数发出预期类别 / 支持的日志级别映射到自动化安全 Verbosity | ✅ | `LogVerbosityFunctionsEmitExpectedCategories` `SupportedLogLevelsMapToAutomationSafeVerbosity` |
| 网络调试日志模式 | ✅ | `NetworkDebugLoggingPatterns` |
| 不支持的原生日志宏与 Verbosity 枚举编译失败 | 🚫 | `UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile` |

## 3. 错误处理（ErrorHandlingTests 6）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 返回模式与 out 结果 | ✅ | `ReturnPatternsAndOutResults` |
| null 边界提前返回与重试 | ✅ | `NullBoundsEarlyReturnAndRetry` |
| ThrowIf 报告脚本异常 | ✅ | `ThrowIfReportsScriptException` |
| 受保护的负向边界保留回退 | ✅ | `GuardedNegativeBoundariesPreserveFallbacks` |
| 负向运行期与编译边界 / 负向编译边界 | 🚫 | `NegativeRuntimeAndCompileBoundaries` `NegativeCompileBoundaries` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| Debug | 17 |
| Logging | 13 |
| ErrorHandling | 6 |
| **合计** | **36** |

**待实现（⬜）**：当前无硬缺口；不支持的原生日志/Profiler/Debugger API 均以 🚫 负向断言固化。
