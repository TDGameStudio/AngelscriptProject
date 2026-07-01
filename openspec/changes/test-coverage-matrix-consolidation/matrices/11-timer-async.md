# 定时器 / 异步覆盖矩阵

> **本矩阵是定时器测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 `AngelscriptCoverageTimerTests.cpp` 的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork/headless 不适用。
>
> - 测试文件：`AngelscriptCoverageTimerTests.cpp`（31 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.Timer`
> - 图例见 `../coverage-matrix.md`。

## 1. 基础用法与管理

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础用法 / 定时器管理 | ✅ | `TimerBasicUsage` `TimerManagement` |
| 单次与多句柄编译 | ✅ | `SingleShotAndMultipleHandlesCompile` |

## 2. 句柄操作

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 暂停/恢复/清除 | ✅ | `TimerHandlePauseUnpauseAndClear` |
| 清除并失效 / 清除后复用句柄变量 | ✅ | `TimerClearAndInvalidate` `TimerClearThenReuseHandleVariable` |
| 句柄失效与受支持查询 / 无效句柄查询确定性 | ✅ | `TimerHandleInvalidationAndSupportedQueries` `TimerInvalidHandleQueriesStayDeterministic` |

## 3. 延迟与周期

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 延迟执行 / 首次延迟 / 立即执行 / 系统延迟 | ✅ | `TimerDelayExecution` `TimerFirstDelay` `TimerImmediateExecution` `SystemDelay` |
| 多定时器并存 | ✅ | `MultipleTimers` |
| 剩余/已用时间查询 | ✅ | `TimerRemainingAndElapsed` |

## 4. 参数与回调

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 带参回调 / Lambda 捕获 | ✅ | `TimerWithParameters` `TimerLambdaCapture` |
| 同名函数替换既有定时器 | ✅ | `TimerRepeatedFunctionNameReplacesExistingTimer` |
| 动态函数名反射生命周期 | ✅ | `TimerDynamicFunctionNameReflectionLifecycle` |

## 5. 组件 / Actor 回调

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Actor 销毁停止回调 | ✅ | `TimerActorDestroyStopsCallbacks` |
| 组件回调在 Owner World 运行 / 组件销毁停止回调 | ✅ | `TimerComponentCallbacksRunOnOwnerWorld` `TimerDestroyedComponentStopsCallbacks` |
| 延迟生成用例 / Actor 与组件调用点编译稳定性 | ✅ | `TimerDelayedSpawnUseCaseRunsFromWorldTimer` `TimerCompileStableActorAndComponentCallSites` |

## 6. 典型用例

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 技能冷却 / 周期检查 / Buff 持续 | ✅ | `TimerUseCaseSkillCooldown` `TimerUseCasePeriodicCheck` `TimerUseCaseBuffDuration` |
| UI 倒计时与 AI 状态模式 | ✅ | `TimerUiCountdownAndAiStatePatterns` |

## 7. Lambda / Latent 边界

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Lambda 委托 SetTimer / 单次边界 | 🚫 | `TimerDelegateLambdaSetTimerBoundary` `TimerDelegateLambdaSingleShotBoundary` |
| Latent 移动函数编译边界 | 🚫 | `LatentMovementFunctionsRemainCompileBoundaries` |
| 无确定性 Latent 推进的延迟编译 | 🚫 | `SystemDelayCompilesWithoutDeterministicLatentAdvance` |

---

**对应测试方法**：31 方法。
**待实现（⬜）**：当前无硬缺口；headless 下以确定性句柄状态断言为主，Latent/Lambda 路径作编译边界。
