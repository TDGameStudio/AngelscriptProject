# Angelscript 全量去全局化后续计划

> **⚠️ 本计划已被 `Plan_DeGlobalizationV2.md` 替代**（2026-04-28）。`Plan_DeGlobalizationV2.md` 合并了本计划与 `Plan_TestEngineIsolation.md` Phase 2-4 的执行内容，并基于最新的 Hazelight 对比分析重新组织了 Phase 结构。本文件保留为历史参考，待正式归档到 `Archives/`。

## 背景与目标

### 背景

`Plan_TechnicalDebt.md` 在 `Phase 5` 中已经完成两类低风险 containment：

- 测试侧 helper 统一使用 `FScopedGlobalEngineOverride` / `FScopedTestWorldContextScope`，不再通过混杂命名隐式切换全局状态。
- `Debugging/AngelscriptDebugServer.cpp` 的低风险 runtime 路径已收口为 owner engine 注入与单点 active debug server 入口，不再在该文件里散用 `FAngelscriptEngine::Get()`。

但这并不等于全仓库已经完成去全局化。`ClassGenerator`、`Core/AngelscriptEngine.cpp`、以及部分 world-context 绑定路径仍然依赖静态 `GlobalEngine` / `CurrentWorldContext` 作为核心生命周期机制。继续在 `Plan_TechnicalDebt.md` 中推进这些工作，会把当前技术债计划膨胀成跨模块架构重构。

### 目标

1. 明确当前 containment 已完成的边界。
2. 为完整去全局化准备独立的后续计划，而不是继续在技术债计划里渐进扩张。
3. 固定启动后续计划的前置条件和非目标范围，避免下一轮再从零判断边界。

## 当前事实状态

- 已 containment：
  - `Plugins/Angelscript/Source/AngelscriptTest/Shared/*` 的测试 helper 入口
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` 的低风险 runtime 全局访问点
- 仍未 containment 的核心路径：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp` 等显式 world-context 绑定入口

## 分阶段执行计划

### Phase 1：固定 architecture boundary

> 目标：把“全量去全局化”的真正改造边界固定下来，而不是继续在主技术债计划里做零散 patch。

- [ ] **P1.1** 列出必须保留全局入口的核心生命周期路径
  - 区分“构建系统 / class generator 必须在无显式上下文下工作”的路径与“可以通过参数或 scope 显式化”的路径。
  - 对每类路径标记现有 owner / consumer / 生命周期顺序，避免误把核心 bootstrapping 路径当成普通工具函数重构。
  - 同步说明哪些路径已经由 `Plan_TechnicalDebt` 做过 containment，避免重复施工。
- [ ] **P1.1** 📦 Git 提交：`[Docs/GlobalState] Feat: freeze architecture boundary for full de-globalization work`

### Phase 2：设计显式上下文入口

> 目标：在不破坏启动、热重载和测试体系的前提下，设计 engine / world-context 的显式传递接口。

- [ ] **P2.1** 为 compile/class-generation 路径设计显式 engine owner 传递方案
  - 重点覆盖 `ClassGenerator`、module compilation、hot-reload 分析入口。
  - 不允许直接把静态 getter 替换成层层参数传播而不记录生命周期影响；每条链路都要说明谁拥有 engine、谁只借用。
  - 若局部链路无法显式化，必须说明原因并留下最小静态边界，而不是假装可以完全消灭全局。
- [ ] **P2.1** 📦 Git 提交：`[Runtime/GlobalState] Refactor: design explicit engine-owner flow for compile and class-generation paths`

- [ ] **P2.2** 为 world-context 绑定路径设计显式上下文策略
  - 聚焦 `Bind_SystemTimers`、`Bind_UUserWidget`、以及其他 `SetPreviousBindRequiresWorldContext(true)` 相关入口。
  - 明确哪些 API 应继续保留“隐式当前 world context”语义，哪些应转成显式参数或 wrapper。
  - 不与 interface/bind parity 计划混写。
- [ ] **P2.2** 📦 Git 提交：`[Runtime/GlobalState] Refactor: design explicit world-context strategy for runtime binds`

### Phase 3：分批实施与验证

> 目标：按可验证的小批次实施，不把完整去全局化变成一次性大爆炸。

- [ ] **P3.1** 选择一条 compile/class-generation 链路做首批实现
  - 必须先补 focused regression，再动实现。
  - 首批只允许改一条完整调用链，不得同时展开多个子系统。
- [ ] **P3.1** 📦 Git 提交：`[Runtime/GlobalState] Refactor: implement first explicit engine-owner pipeline slice`

- [ ] **P3.2** 选择一条 world-context 绑定链路做首批实现
  - 必须证明 isolate test engine、production engine、world context scope 不会串线。
  - 若实现中需要新增 helper，先落到 `Shared` 层并补文档。
- [ ] **P3.2** 📦 Git 提交：`[Runtime/GlobalState] Refactor: implement first explicit world-context pipeline slice`

- [ ] **P3.3** 执行最终构建与 focused/full regression
  - 至少覆盖 compile/class-generation、shared helper、world-context bind、hot-reload 关键路径。
  - 把未完成的静态边界和后续任务继续写回本计划，而不是回流主技术债计划。
- [ ] **P3.3** 📦 Git 提交：`[Test/GlobalState] Test: verify first de-globalization slices and remaining static boundaries`

## 验收标准

- `Plan_TechnicalDebt.md` 不再承担“完整去全局化”的后续扩张。
- 已 containment 与待去全局化的路径边界清晰，后续工作有独立计划可承接。
- 任何未来的去全局化改动都能明确归到本计划，而不是重新混回技术债主线。

## 风险与注意事项

- 该计划是架构重构计划，不再适合继续套用 `Plan_TechnicalDebt.md` 的 low-risk 节奏。
- 不要试图一次性消灭全部静态入口；必须接受某些启动期边界仍然需要最小静态机制。
- 每次只允许推进一条完整调用链，并以 focused regression 证明安全。 
