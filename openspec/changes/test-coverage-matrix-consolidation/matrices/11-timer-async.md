# 定时器 / 异步覆盖矩阵

> 域：FTimerHandle、SetTimer、延迟执行、周期回调、Latent 边界。
> 测试文件：`AngelscriptCoverageTimerTests.cpp`（Automation 前缀 `Angelscript.TestModule.Coverage.Timer`）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例见 `../coverage-matrix.md`。

| 状态 | 方法数 |
|------|-------|
| ✅ | 31 |

## 测试方法清单

| # | TEST_METHOD | 覆盖点 |
|---|-------------|--------|
| 1 | TimerHandlePauseUnpauseAndClear | 句柄暂停/恢复/清除 |
| 2 | SingleShotAndMultipleHandlesCompile | 单次/多句柄编译 |
| 3 | TimerBasicUsage | 基础用法 |
| 4 | TimerManagement | 定时器管理 |
| 5 | TimerWithParameters | 带参回调 |
| 6 | TimerDelegateLambdaSetTimerBoundary | Lambda 委托设置边界 |
| 7 | TimerDelayExecution | 延迟执行 |
| 8 | MultipleTimers | 多定时器并存 |
| 9 | TimerRemainingAndElapsed | 剩余/已用时间查询 |
| 10 | TimerFirstDelay | 首次延迟 |
| 11 | TimerImmediateExecution | 立即执行 |
| 12 | SystemDelay | 系统级延迟 |
| 13 | TimerClearAndInvalidate | 清除并失效 |
| 14 | TimerClearThenReuseHandleVariable | 清除后复用句柄变量 |
| 15 | TimerActorDestroyStopsCallbacks | Actor 销毁停止回调 |
| 16 | TimerLambdaCapture | Lambda 捕获 |
| 17 | TimerUseCaseSkillCooldown | 用例：技能冷却 |
| 18 | TimerUseCasePeriodicCheck | 用例：周期检查 |
| 19 | TimerUseCaseBuffDuration | 用例：Buff 持续 |
| 20 | TimerHandleInvalidationAndSupportedQueries | 句柄失效与受支持查询 |
| 21 | TimerCompileStableActorAndComponentCallSites | Actor/组件调用点编译稳定性 |
| 22 | TimerRepeatedFunctionNameReplacesExistingTimer | 同名函数替换既有定时器 |
| 23 | TimerDelegateLambdaSingleShotBoundary | Lambda 单次边界 |
| 24 | TimerDynamicFunctionNameReflectionLifecycle | 动态函数名反射生命周期 |
| 25 | TimerInvalidHandleQueriesStayDeterministic | 无效句柄查询确定性 |
| 26 | TimerUiCountdownAndAiStatePatterns | UI 倒计时/AI 状态模式 |
| 27 | TimerComponentCallbacksRunOnOwnerWorld | 组件回调在 Owner World 运行 |
| 28 | TimerDelayedSpawnUseCaseRunsFromWorldTimer | 延迟生成用例 |
| 29 | TimerDestroyedComponentStopsCallbacks | 组件销毁停止回调 |
| 30 | LatentMovementFunctionsRemainCompileBoundaries | Latent 移动函数编译边界 |
| 31 | SystemDelayCompilesWithoutDeterministicLatentAdvance | 无确定性 Latent 推进的延迟编译 |
