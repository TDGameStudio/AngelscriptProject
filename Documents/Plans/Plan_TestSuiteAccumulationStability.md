# 测试套件累积稳定性修复计划

## 背景与目标

全量单进程测试在运行到 `Angelscript.TestModule.Debugger.Stepping.StepOver` 时出现超时，但单独运行 StepOver 与 Debugger 分桶均可稳定通过。排查显示这更像全量顺序运行后的状态、socket、异步 IO 或脚本类资源累积问题，而不是 StepOver 自身的稳定断言失败。

本计划目标是先收口已观察到的三个高确定性问题：陈旧 learning interface 测试仍使用已废弃脚本 `UINTERFACE()`、DebugServer 接受的客户端 socket 缺少销毁路径、Preprocessor 异步加载只轮询一次就进入解析。更大的引擎池、数据库缓存、UClass 垃圾回收和 Runtime/TestEngine 解耦问题保留为后续架构计划，不混入本次最小稳定性修复。

## 影响范围

本次涉及以下操作：
- **测试脚本对齐**：把陈旧脚本接口声明替换为当前支持的 native interface dispatch 路径。
- **资源生命周期收口**：在 DebugServer 中统一 close + destroy 客户端 socket，并在析构时清空调试会话状态。
- **端口窗口扩展**：扩大测试 DebugServer 端口轮转窗口，降低单进程多轮测试中的端口复用压力。
- **异步加载等待修复**：确保所有异步文件读取完成后才进入 preprocessor 解析阶段。
- **计划登记**：新增本计划并在机会索引中登记。

受影响文件：
- `Documents/Plans/Plan_TestSuiteAccumulationStability.md` — 新增计划。
- `Documents/Plans/Plan_OpportunityIndex.md` — 登记测试稳定性 Plan。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningInterfaceDispatchTraceTests.cpp` — 对齐当前 interface 能力边界。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` — 声明 socket 清理 helper。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` — 实现客户端销毁和析构清理。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.cpp` — 扩大测试端口轮转窗口。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` — 修复异步加载等待。

## 分阶段执行计划

- [ ] **P1** 修复陈旧 interface learning 测试
  - 当前测试仍在脚本中声明 `UINTERFACE()`，但编译管线已经明确不再支持脚本自定义 interface，因此全量 TestModule 中该测试会稳定失败。
  - 改为使用 `UAngelscriptNativeParentInterface` 这类 test-module native interface，复用当前生产路径 `CallInterfaceMethod` 的 dispatch 语义，learning trace 只讲清楚“脚本 actor 实现 native interface 并通过 bridge 分发”。
  - 验收以 `Angelscript.TestModule.Learning.Runtime.InterfaceDispatch` 单测通过为准。
- [ ] **P1** 📦 Git 提交：`[AngelscriptTest] Fix: align learning interface dispatch trace`

- [ ] **P2** 收口 DebugServer 客户端 socket 生命周期
  - `FTcpListener` 在 accept delegate 返回 `true` 后不会替调用方销毁 socket；当前 DebugServer 只在断连时调用 `Close()`，没有统一 `DestroySocket()`。
  - 新增 `CloseAndDestroyClient()` / `ResetClientStateForShutdown()` 一类最小 helper，在运行时断连和析构时同时移除 client 队列、debugging 列表、debug database 请求、queued sends 和 callstack 请求。
  - 验收以 Debugger suite 稳定通过，并观察不再长期累积已断连 client socket 为准。
- [ ] **P2** 📦 Git 提交：`[AngelscriptRuntime] Fix: destroy debugger client sockets`

- [ ] **P3** 降低测试 DebugServer 端口复用压力
  - 当前端口窗口按进程只轮转 10 个 offset，全量单进程里多轮 debugger engine 会快速复用端口。
  - 将 per-process bucket 扩大为 100 个 offset，并保持端口范围在 `30000..39999` 内。
  - 验收以 Debugger suite 和 StepOver 单测可正常启动 debug server 为准。
- [ ] **P3** 📦 Git 提交：`[AngelscriptTest] Fix: widen debugger test port window`

- [ ] **P4** 修复 Preprocessor 异步加载等待
  - 当前 `PerformAsynchronousLoads()` 启动异步 size/read 后只遍历一次文件；在 IO 较慢或全量测试负载下可能在 `RawCode` 未填充时进入 `ParseIntoChunks()`。
  - 改为先启动所有请求，再等待所有 `bLoadAsynchronous` 文件完成，最后统一释放 async request 和 handle；打开或请求失败时按空文件处理并退出异步状态。
  - 验收以 `Angelscript.TestModule.Preprocessor` 通过，尤其 `AsyncLoad.AsyncMatchesSynchronousPreprocess` 不再在全量顺序中触发空读崩溃为准。
- [ ] **P4** 📦 Git 提交：`[AngelscriptRuntime] Fix: wait for async preprocessor loads`

- [ ] **P5** 跑针对性验证并记录剩余风险
  - 必跑：learning interface 单测、preprocessor 分桶、Debugger suite。
  - 时间允许再跑 `Angelscript.TestModule` 单进程聚合；若仍失败，应记录首个失败点和是否仍为 StepOver 超时。
  - 不在本次内承诺全量 `Angelscript` suite 通过，除非 fresh full-suite 实际完成且无失败。
- [ ] **P5** 📦 Git 提交：`[Docs] Test: record accumulation stability verification`

## 验收标准

- `Angelscript.TestModule.Learning.Runtime.InterfaceDispatch` 不再使用脚本 `UINTERFACE()` 并通过。
- DebugServer 销毁时不会遗留 accepted client socket，也不会保留 stale queued sends / callstack requests / debug database request clients。
- 测试 DebugServer 端口分配在单进程多轮会话中有更大的轮转空间，避免 10 个端口快速复用。
- Preprocessor 异步加载会等待所有文件读取完成后再解析。
- 针对性测试输出明确记录：哪些通过、哪些因超时或既有问题未通过。

## 风险与注意事项

### 风险

1. **全量 suite 仍可能超时**：本次修复针对已确认的高概率累积点，但全量顺序中还可能存在其他状态泄漏，例如 generated `UClass` detached class、共享 engine database 或 Blueprint bind 缓存累积。
   - **缓解**：先用分桶和 `Angelscript.TestModule` 聚合验证缩小剩余范围，再决定是否拆独立 `TestEngine` 或缓存测试 database。
2. **socket 销毁时机过早**：如果对仍在 `QueuedSends` 中的活跃 client 调用 destroy，会导致后续访问悬空指针。
   - **缓解**：所有 client 移除路径必须先从 `ClientsThatWantDebugDatabase`、`ClientsThatAreDebugging`、`CallstackRequests`、`QueuedSends` 中移除，再从 `Clients` 移除并销毁。
3. **异步回调捕获 File 引用**：等待逻辑依赖 `Files` 数组在 `PerformAsynchronousLoads()` 期间不重分配。
   - **缓解**：只在 AddFile 完成后进入 Preprocess，等待期间不增删 `Files`。

### 已知行为变化

1. **Learning trace 语义变化**：`Learning.Runtime.InterfaceDispatch` 从“脚本生成 interface”改为“脚本实现 native interface”，与当前编译管线真实能力保持一致。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningInterfaceDispatchTraceTests.cpp`
2. **DebugServer 析构更激进清理状态**：析构时会关闭并销毁 pending/active client socket，并重置 paused/debugging flags。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`
