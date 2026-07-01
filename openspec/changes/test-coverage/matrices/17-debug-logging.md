# Debug / Logging / Error Handling Coverage Matrix

> **This matrix is the design specification header for debug/logging/error handling tests**: each row is a concrete verifiable scenario guiding three test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported.
>
> - Test files: `Debug`(17) / `Logging`(13) / `ErrorHandling`(6) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<Debug|Logging|ErrorHandling>`
> - See `../coverage-matrix.md` for the legend.

## 1. Debug, DebugTests 17

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Ensure/Check bindings / Callstack and Throw bindings | ✅ | `EnsureAndCheckBindings` `CallstackAndThrowBindings` |
| Log severity helpers / formatted debug logging surface | ✅ | `LogSeverityHelpersEmitExpectedVerbosity` `FormattedDebugLoggingSurfaceIncludesValuesAndContext` |
| DrawDebugString, from object / parameterized | ✅ | `DrawDebugStringFromObject` `DrawDebugStringParameters` |
| DebugBreak can be disabled for automation | ✅ | `DebugBreakBindingCanBeDisabledForAutomation` |
| Object inspection helpers expose names and Outer | ✅ | `ObjectInspectionHelpersExposeNamesAndOuter` |
| CPU Profiler scoped event script-facing / profiler patterns, counters and scratch memory | ✅ | `CpuProfilerScopedEventIsScriptFacing` `ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory` |
| Stat/Show command names dispatch through registered console command | ✅ | `StatAndShowCommandNamesDispatchThroughRegisteredConsoleCommand` |
| Debug error handling patterns / debugging workflow uses callable script helpers | ✅ | `DebugErrorHandlingPatterns` `DebuggingWorkflowPatternsUseCallableScriptHelpers` |
| Native log Verbosity enum compile-time boundary | 🚫 | `NativeLogVerbosityEnumsRemainCompileTimeBoundary` |
| Unsupported DrawDebug shape parameters fail to compile | 🚫 | `UnsupportedDrawDebugShapeParametersFailToCompile` |
| Console Profiler and Debugger controls fail to compile / Debugger client-only features fail to compile | 🚫 | `ConsoleProfilerAndDebuggerControlsFailToCompile` `DebuggerClientOnlyFeaturesFailToCompile` |

## 2. Logging, LoggingTests 13

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Print functions / UE_LOG macros | ✅ | `PrintFunctions` `UELogMacros` |
| Log categories / formatting | ✅ | `LogCategories` `LogFormatting` |
| Conditional logging / conditional log functions gate output | ✅ | `ConditionalLogging` `ConditionalLogFunctionsGateOutput` |
| Function entry/exit logging / performance-conscious logging / context-rich logging | ✅ | `FunctionEntryExitLogging` `PerformanceConsciousLogging` `ContextRichLogging` |
| Verbosity functions emit expected categories / supported log levels map to automation-safe verbosity | ✅ | `LogVerbosityFunctionsEmitExpectedCategories` `SupportedLogLevelsMapToAutomationSafeVerbosity` |
| Network debug logging patterns | ✅ | `NetworkDebugLoggingPatterns` |
| Unsupported native log macros and Verbosity enums fail to compile | 🚫 | `UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile` |

## 3. Error Handling, ErrorHandlingTests 6

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Return patterns and out results | ✅ | `ReturnPatternsAndOutResults` |
| Null bounds early return and retry | ✅ | `NullBoundsEarlyReturnAndRetry` |
| ThrowIf reports script exception | ✅ | `ThrowIfReportsScriptException` |
| Guarded negative boundaries preserve fallbacks | ✅ | `GuardedNegativeBoundariesPreserveFallbacks` |
| Negative runtime and compile boundaries / negative compile boundaries | 🚫 | `NegativeRuntimeAndCompileBoundaries` `NegativeCompileBoundaries` |

---

## Summary

| File | Methods |
|------|------|
| Debug | 17 |
| Logging | 13 |
| ErrorHandling | 6 |
| **Total** | **36** |

**Pending (⬜)**: no hard gaps currently; unsupported native logging / Profiler / Debugger APIs are all locked by 🚫 negative assertions.
