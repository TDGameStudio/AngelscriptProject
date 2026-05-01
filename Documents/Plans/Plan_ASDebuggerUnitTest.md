# AS Debugger 单元测试实施计划

## 背景与目标

### 背景

当前 `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/` 已经具备完整的 AS 调试能力，但仓库内还没有专门覆盖 debugger 的自动化测试：

- `AngelscriptDebugServer.h/.cpp` 已实现自定义 TCP 调试协议、断点、步进、变量读取、调用栈、数据断点。
- `Bind_Debugging.cpp` 已暴露 `DebugBreak()`、`ensure()`、`check()`、`GetAngelscriptCallstack()`、`FormatAngelscriptCallstack()`。
- `AngelscriptEngine.cpp` 已在 `AngelscriptLineCallback()` / `AngelscriptStackPopCallback()` 中接入 debugger。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 已有低层 `CppTests` 模式，`Plugins/Angelscript/Source/AngelscriptTest/` 已有主题化 Editor Automation 测试模式，但当前没有 `Debugger/` 测试主题目录。

这导致 debugger 相关回归目前只能依赖手工连 VSCode 扩展验证：

1. **协议回归无防护** —— message struct 的序列化变化、版本兼容变化不会被自动发现。
2. **断点/步进缺少稳定回归** —— `ProcessScriptLine()`、`PauseExecution()`、`SendCallStack()` 的行为修改后没有自动保障。
3. **变量求值缺少真实上下文校验** —— `GetDebuggerValue()` / `GetDebuggerScope()` 强依赖 `asGetActiveContext()`，纯读代码难以及时发现问题。
4. **调试绑定无自动保护** —— `DebugBreak()` / `ensure()` / `check()` 的行为一旦改坏，容易直接影响脚本调试体验。

### 目标

建立一套**分层的 AS debugger 自动化测试方案**，覆盖从协议到真实脚本暂停上下文的核心能力，并明确哪些能力适合纯单元测试，哪些必须走 Editor Automation：

1. 在 `AngelscriptRuntime/Tests/` 中补齐**纯 C++ 低层测试**，覆盖协议 message round-trip 与不依赖真实暂停上下文的稳定逻辑。
2. 在 `AngelscriptTest/Debugger/` 中建立**Editor Automation 调试场景测试**，覆盖断点、步进、调用栈、变量求值、调试绑定。
3. 将 **Win64 硬件数据断点** 单独分层，作为平台 gated 的后续阶段，不阻塞首批核心 debugger 回归。
4. 形成统一的命名、分组和运行命令，便于后续 CI / 本地回归复用。

## 范围与边界

- 本计划只针对 `Plugins/Angelscript/` 插件内 debugger 能力，不扩展 VSCode 插件或重写调试协议。
- 本计划优先验证 **C++ debug server 行为**，不是为 DAP 兼容单独开发一套新适配层。
- 首批必须覆盖：协议、断点、步进、调用栈、变量查看、`DebugBreak`/`ensure`/`check`。
- `SetDataBreakpoints` / `ClearDataBreakpoints` 因依赖 Win64 调试寄存器，单列为平台限制阶段。
- 不引入图形测试，不引入新的外部测试框架；默认沿用 UE Automation + 当前插件测试基础设施。
- 不把 debugger 测试全部硬拆成“纯单元测试”；凡是依赖 `asGetActiveContext()` / `PauseExecution()` / 实际脚本运行上下文的能力，统一走 Editor Automation 场景测试。

## 当前事实状态

### 关键实现文件

- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h`
  - 定义 `EDebugMessageType`、message struct、`FAngelscriptDebugServer` public surface。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`
  - 实现消息处理、断点重建、调用栈发送、变量求值、暂停循环、Win64 数据断点。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  - `AngelscriptLineCallback()` 在真实脚本执行中调用 `DebugServer->ProcessScriptLine(Context)`。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp`
  - 调试脚本入口：`DebugBreak()` / `ensure()` / `check()` / `GetAngelscriptCallstack()`。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.h`
  - 已暴露 `AngelscriptDisableDebugBreaks()` / `AngelscriptEnableDebugBreaks()` / `AngelscriptForgetSeenEnsures()`，可用于测试期间避免原生 `UE_DEBUG_BREAK()` 直接中断测试进程。

### 当前测试基础设施

- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
  - 已有 `Angelscript.TestModule.CppTests.*` 风格的低层自动化测试，适合无真实世界/无真实暂停上下文的 deterministic 逻辑。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h`
  - 提供 `GetResetSharedTestEngine()`、`BuildModule()`、`ExecuteIntFunction()` 等基础 helper。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h`
  - 提供 `CompileAnnotatedModuleFromMemory()` 等更适合稳定路径/生成类测试的 helper。
- `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp`
  - 已证明可以通过显式脚本路径 + `CompileAnnotatedModuleFromMemory()` 做“带文件路径语义”的 Editor Automation 测试。

### 关键约束

1. `WITH_AS_DEBUGSERVER` 定义为 `(!UE_BUILD_TEST && !UE_BUILD_SHIPPING)`，意味着 debugger 测试必须跑在 Editor / Development 语义下。
2. `BuildModule()` 默认写入带 GUID 的绝对脚本路径，不适合作为 debugger 断点/文件名精确断言的唯一 fixture。
3. `GetDebuggerValue()` / `GetDebuggerScope()` 依赖 `asGetActiveContext()` 和当前暂停帧，不能通过“脚本已经执行结束后的离线查询”替代。
4. `PauseExecution()` 是阻塞流程；调试测试必须有客户端协程/轮询逻辑负责 `Continue` / `Step*` 驱动。
5. `AngelscriptDebugServer::DebugAdapterVersion` 与 ensure 去重状态都带全局副作用；如果 fixture 不统一保存/恢复，测试顺序会污染结果。

## 测试对象与生产代码映射

为避免执行时“知道要写某个测试文件，但不知道它真正保护哪段生产代码”，先固定每类测试与生产实现的映射关系。后续若新增测试文件，也应落到下表对应的生产职责上。

| 测试层 | 主要测试文件 | 主要保护的生产文件 | 重点函数 / 结构 | 备注 |
|---|---|---|---|---|
| 协议序列化 | `AngelscriptDebugProtocolTests.cpp` | `Debugging/AngelscriptDebugServer.h` | `EDebugMessageType`、各 message struct 的 `operator<<` | 重点防字段顺序、版本分支回归 |
| 传输与 framing | `AngelscriptDebugTransportTests.cpp` | `Debugging/AngelscriptDebugServer.cpp` | `ProcessMessages()`、`SendMessageToClient()`、message envelope 处理 | 重点防半包、多包、错误长度 |
| session / smoke | `AngelscriptDebuggerSmokeTests.cpp` | `Core/AngelscriptEngine.cpp`、`Debugging/AngelscriptDebugServer.cpp` | `Tick()`、`DebugServer->Tick()`、握手消息处理 | 重点防端口、pump、握手链路断裂 |
| 断点命中 | `AngelscriptDebuggerBreakpointTests.cpp` | `Debugging/AngelscriptDebugServer.cpp` | `ProcessScriptLine()`、`ReapplyBreakpoints()`、`CanonizeFilename()` | 重点防文件名/模块名/分支命中错误 |
| 步进行为 | `AngelscriptDebuggerSteppingTests.cpp` | `Debugging/AngelscriptDebugServer.cpp` | `StepIn` / `StepOver` / `StepOut` 处理、暂停状态机 | 重点防 step 被错误退化为 continue |
| 调用栈 | `AngelscriptDebuggerCallstackTests.cpp` | `Debugging/AngelscriptDebugServer.cpp` | `SendCallStack()`、frame 组装逻辑 | 重点防 frame 顺序和 source/line 漂移 |
| 变量与求值 | `AngelscriptDebuggerVariableTests.cpp` | `Debugging/AngelscriptDebugServer.cpp`、`Core/AngelscriptDebugValue.h` | `GetDebuggerScope()`、`GetDebuggerValue()`、`FASDebugValue` | 重点防 scope/path 解析与值格式化回归 |
| 调试绑定 | `AngelscriptDebuggerBindingTests.cpp` | `Binds/Bind_Debugging.cpp`、`Binds/Bind_Debugging.h` | `DebugBreak()`、`ensure()`、`check()`、callstack formatting | 重点防 pause-path / no-crash 模式语义漂移 |
| 数据断点 | `AngelscriptDebuggerDataBreakpointTests.cpp` | `Debugging/AngelscriptDebugServer.cpp` | `SetDataBreakpoints()`、`ClearDataBreakpoints()`、`ProcessScriptStackPop()` | 仅 Win64，重点防寄存器状态残留 |

执行时若发现某个测试文件开始保护多个完全不同的生产职责，应优先拆文件，而不是在一个 `*.cpp` 里堆所有断言。

## 测试分层方案

### Layer A：Runtime 低层 `CppTests`

放置位置：`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`

适用对象：

- message struct 的序列化 / 反序列化 round-trip
- 协议版本字段兼容
- 不依赖真实 paused context 的 helper/pure logic

命名建议：

- `Angelscript.TestModule.CppTests.Debugger.Protocol.*`
- `Angelscript.TestModule.CppTests.Debugger.Transport.*`

### Layer B：Editor Automation Debugger 场景测试

放置位置：`Plugins/Angelscript/Source/AngelscriptTest/Debugger/`

适用对象：

- 断点命中
- StepIn / StepOver / StepOut
- 调用栈读取
- `%local%` / `%this%` / `%module%` / global 变量求值
- `DebugBreak()` / `ensure()` / `check()` 调试行为

命名建议：

- `Angelscript.TestModule.Debugger.Breakpoint.*`
- `Angelscript.TestModule.Debugger.Stepping.*`
- `Angelscript.TestModule.Debugger.Callstack.*`
- `Angelscript.TestModule.Debugger.Variables.*`
- `Angelscript.TestModule.Debugger.Bindings.*`

### Layer C：Win64 平台 gated 数据断点测试

放置位置：`Plugins/Angelscript/Source/AngelscriptTest/Debugger/`

适用对象：

- `SetDataBreakpoints`
- `ClearDataBreakpoints`
- `ProcessScriptStackPop()` 对越界/离栈 data breakpoint 的清理行为

命名建议：

- `Angelscript.TestModule.Debugger.DataBreakpoint.*`

## 计划文件/目录落点

### 新增文件

- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDebugProtocolTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDebugTransportTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.h`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.h`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.h`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerSmokeTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerBreakpointTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerSteppingTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerCallstackTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerVariableTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerBindingTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerDataBreakpointTests.cpp`

### 可能修改文件

- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
  - 补充 debugger 测试客户端需要的 `Networking` / `Sockets` 依赖与 `Debugger` include path。
- `Config/DefaultEngine.ini`
  - 如需统一跑组，增加 `AngelscriptDebugger` / `AngelscriptDebuggerCore` 过滤组。
- `Documents/Guides/Test.md`
  - 补充 debugger 测试命名、运行命令、Win64 限制和推荐批次。

## 实施细化约定

为避免后续执行时再次把任务做成“只有阶段名，没有落地细节”，本计划中所有 debugger 测试任务默认遵循以下统一约定。若某一步没有单独写明，按本节执行。

### 通用任务拆解模板

每个测试实现步骤都要至少回答四件事：

1. **文件职责**：这一步新增/修改的文件分别承载什么角色，避免 helper、fixture、test case 混在一起。
2. **实现要求**：这一步必须落地哪些 helper、调用路径、状态恢复、断言字段。
3. **验证方式**：至少说明跑哪些测试路径、观察哪些返回值/停止原因/日志字段。
4. **完成判据**：什么结果算该步完成，什么情况算只是“部分实现”。

### 通用测试结构

对于 `AngelscriptTest/Debugger/` 下的 Editor Automation 调试场景测试，统一使用以下四段式结构组织单个用例：

1. **Setup**
   - 创建或重置 `AngelscriptDebuggerTestSession`
   - 建立 `AngelscriptDebuggerTestClient`
   - 编译当前 case 专属脚本 fixture，并记录脚本文件名、模块名、关键行号
   - 根据场景发送 `StartDebugging`、`SetBreakpoint`、`RequestBreakFilters` 等前置消息
2. **Action**
   - 启动脚本执行，或在已暂停上下文中发送 `Continue` / `StepIn` / `StepOver` / `StepOut` / `RequestVariables` / `RequestEvaluate`
   - 若需要等待 server 处理，统一通过 session pump helper 驱动，而不是散落的手工 sleep
3. **Assert**
   - 断言消息类型、停止原因、脚本文件、行号、调用栈深度、变量名/值/类型、日志文本等
   - 对变量/求值类测试，默认同时校验正例和至少一个失败路径
4. **Cleanup**
   - 发送 `Continue` / `StopDebugging` / `Disconnect`（按场景需要）
   - 恢复全局状态：debug breaks、`DebugAdapterVersion`、ensure 去重状态
   - 销毁 session/client，确保不会把暂停状态或 socket 残留给下一个测试

### 通用 helper 责任边界

为避免职责污染，helper 按以下边界实现：

- `AngelscriptDebuggerTestSession`
  - 只负责 engine 生命周期、端口、global scope、pump、超时和跨测试状态恢复
  - 不负责编解码具体 debugger 消息体
- `AngelscriptDebuggerTestClient`
  - 只负责 TCP 连接、消息 envelope 编解码、等待消息、基础 convenience API
  - 不负责脚本 fixture 编译或脚本执行
- `AngelscriptDebuggerScriptFixture`
  - 只负责稳定脚本路径、模块命名、行号映射、脚本内容组织
  - 不负责 socket 通讯或 debugger 状态机
- 各 `*Tests.cpp`
  - 只负责组合前述 helper 完成场景，不在测试文件里再次发明通用 encode/decode、pump 或脚本路径生成逻辑

### 建议 helper API 草案

为了让执行者不需要二次设计接口，本计划建议 helper 直接收敛到以下最小 API 面。实现时可以微调命名，但职责不要偏离。

- `FAngelscriptDebuggerTestSession`
  - `bool Initialize(const FAngelscriptDebuggerSessionConfig& Config)`
  - `void Shutdown()`
  - `bool PumpUntil(TFunctionRef<bool()> Predicate, float TimeoutSeconds)`
  - `FAngelscriptEngine& GetEngine()`
  - `FAngelscriptDebugServer& GetDebugServer()`
  - `int32 GetPort() const`
- `FAngelscriptDebuggerTestClient`
  - `bool Connect(const FString& Host, int32 Port)`
  - `void Disconnect()`
  - `bool SendStartDebugging(int32 AdapterVersion)`
  - `bool SendContinue()`
  - `bool SendStepIn()` / `SendStepOver()` / `SendStepOut()`
  - `bool SendSetBreakpoint(const FAngelscriptBreakpoint& Breakpoint)`
  - `bool SendRequestCallStack()` / `SendRequestVariables(const FString& Scope)` / `SendRequestEvaluate(const FString& Path)`
  - `TOptional<FStoppedMessage> WaitForStopped(float TimeoutSeconds)`
  - `TOptional<FAngelscriptCallStack> WaitForCallStack(float TimeoutSeconds)`
  - `TOptional<FAngelscriptVariables> WaitForVariables(float TimeoutSeconds)`
- `FAngelscriptDebuggerScriptFixture`
  - `static FDebuggerScriptFixture CreateBreakpointFixture()`
  - `static FDebuggerScriptFixture CreateSteppingFixture()`
  - `static FDebuggerScriptFixture CreateCallstackFixture()`
  - `bool Compile(FAngelscriptEngine& Engine) const`
  - `int32 GetLine(FName Marker) const`
  - `FString GetEvalPath(FName Marker) const`

这些 API 的价值在于：后续每个测试文件都能直接写成“发消息 → 等消息 → 断言结果”的业务流，不会把精力浪费在重复写 socket 和脚本样板上。

### 通用命名与断言约定

- 测试名统一使用 `Angelscript.TestModule.CppTests.Debugger.*` 或 `Angelscript.TestModule.Debugger.*`
- 断点类测试至少断言：`StoppedReason`、`Source`、`LineNumber`
- 步进类测试至少断言：新旧行号差异、调用栈深度变化、停止原因从 `step` 派生
- 变量类测试至少断言：`Name`、`Value`、`Type`、`bHasMembers`
- 协议类测试至少断言 round-trip 后所有已定义字段一致；不能只校验一个字段
- 日志类测试不能只看“没崩”；必须额外校验日志/错误文本确实出现

### 通用消息序列约定

为避免后续每个场景都重新摸索消息顺序，默认按以下顺序组织请求与等待：

- **握手类**：`Connect -> StartDebugging -> Wait(DebugServerVersion/基础响应)`
- **断点类**：`SetBreakpoint -> 启动脚本执行 -> Wait(HasStopped) -> Assert(CallStack/Line/Reason) -> Continue`
- **步进类**：`命中初始断点 -> StepIn/StepOver/StepOut -> Wait(HasStopped) -> Assert(新行号与栈深度)`
- **变量类**：`命中断点 -> RequestCallStack -> RequestVariables 或 RequestEvaluate -> Assert(变量值/类型/成员)`
- **绑定类**：
  - pause-path：`StartDebugging -> 触发 DebugBreak/ensure -> Wait(HasStopped)`
  - no-crash/log：`禁用 debug break -> 执行 ensure/check -> Assert(日志文本)`

若某个测试需要偏离以上顺序，必须在步骤说明里写清原因，不能默认执行者自行猜。

### 通用等待与异步编排约定

- 优先使用“等待具体消息/条件成立”的 helper，而不是裸 `Sleep`。
- 如果一个场景既要驱动脚本执行，又要等待 debugger 返回，优先使用“脚本执行 + pump/wait”并行编排，而不是先执行完脚本再去等消息。
- 若引入 typed expectation helper，命名保持一致，例如：`WaitForStopped()`、`WaitForContinued()`、`WaitForCallStack()`、`WaitForVariables()`。
- 任何 expectation helper 都必须在失败时输出“期望的 message type / 超时毫秒 / 已收到的最后一条消息类型”等诊断信息，方便定位挂起原因。

### 超时与清理约定

- 所有等待 debugger 消息的 helper 都必须接受显式超时参数，默认值统一由 session fixture 暴露
- 禁止在测试里散落硬编码 `Sleep(0.1f)` / 多处复制轮询逻辑；统一走 pump-until helper
- 任何测试只要曾让脚本进入 paused 状态，就必须在退出前显式恢复执行或断开调试会话
- 任何修改全局开关的测试都必须在同一作用域内恢复，不能依赖“下一个测试会重置”

### 验证命令模板

执行阶段应优先按最小回归面分批验证：

- 低层协议：`Automation RunTests Angelscript.TestModule.CppTests.Debugger`
- 冒烟与断点：`Automation RunTests Angelscript.TestModule.Debugger.Smoke+Angelscript.TestModule.Debugger.Breakpoint`
- 步进/调用栈/变量：`Automation RunTests Angelscript.TestModule.Debugger.Stepping+Angelscript.TestModule.Debugger.Callstack+Angelscript.TestModule.Debugger.Variables`
- 绑定与 Win64 数据断点：按平台条件单独运行，避免一次性把不稳定面混入基础回归

## 分阶段执行计划

### Phase 1：建立 debugger 测试基线与公共 fixture

> 目标：先把“可稳定驱动 debugger 的测试会话、端口、脚本路径与全局状态管理”做出来，避免后续每个测试文件都各自造轮子。

- [ ] **P1.1** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.h/.cpp`
  - 封装一套可复用的 debugger test session：创建 `CreateTestingFullEngine()` / 等价 full engine、通过 `FAngelscriptEngineConfig.DebugServerPort` 指定测试专用端口、使用 `FScopedTestEngineGlobalScope` 挂接为当前全局 engine。
  - 提供 `PumpDebugServer()` / `PumpUntil()` 一类 helper，显式驱动 `FAngelscriptDebugServer::Tick()` 或等价 engine tick，避免 client 侧等待但 server 不处理消息。
  - 默认使用**测试自有 full engine**，而不是依赖当前编辑器 production engine；只有明确需要 editor 全局上下文的个别用例才回退到 `GetProductionEngine()`。
  - 统一管理跨测试全局状态恢复：`AngelscriptDebugServer::DebugAdapterVersion`、`AngelscriptEnableDebugBreaks()` / `AngelscriptDisableDebugBreaks()`、`AngelscriptForgetSeenEnsures()`。
  - **文件职责**：
    - `.h` 只暴露 session 生命周期、pump、超时和状态恢复接口；不在头文件里展开 TCP 编解码细节。
    - `.cpp` 负责 engine 创建、debug server 驱动、默认超时实现、析构清理。
  - **实现要求**：
    - 至少提供 `Initialize()`、`Shutdown()`、`PumpOneTick()`、`PumpUntil(Predicate, Timeout)`、`GetPort()`、`GetEngine()`、`GetDebugServer()` 这类接口。
    - `Initialize()` 内必须显式设置 `Config.DebugServerPort`，避免与默认 `27099` 端口或本机其他调试会话冲突。
    - 若 engine 需要在 game thread 上执行初始化，统一在此处收口，不把线程切换逻辑散到各测试文件。
  - **验证方式**：
    - 本步完成后至少保证 `AngelscriptTest` 模块可编译；后续 `P2.3` 冒烟测试必须直接复用本 helper，不允许绕开 session 手工启 engine。
  - **完成判据**：
    - 执行者能只通过 `AngelscriptDebuggerTestSession` 完成“起 engine + 拿到 debug server + 驱动消息循环 + 清理全局状态”四件事，无需再在测试文件中复制 engine lifecycle 逻辑。
- [ ] **P1.1** 📦 Git 提交：`[Debugger/Test] Feat: add debugger test session fixture`

- [ ] **P1.2** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.h/.cpp`
  - 提供 loopback TCP 调试客户端 helper：`Connect()`、`Disconnect()`、`SendMessage()`、`ReceiveMessage()`、`WaitForMessage()`。
  - 端口由 `AngelscriptDebuggerTestSession` 统一分配和暴露，client 不自行决定最终端口。
  - 所有收发 helper 必须基于后续 Phase 2 固化的 framing contract，而不是在测试里再复制一套“猜测版协议”。
  - **文件职责**：
    - `.h` 暴露 message envelope、typed send/receive、等待工具、常用断言辅助。
    - `.cpp` 只实现 socket 连接、buffer 累积、framing 解析、消息等待；不介入脚本编译与断点逻辑。
  - **实现要求**：
    - 至少提供 `SendRawEnvelope()`、`template SendTypedMessage<T>()`、`ReceiveEnvelope()`、`WaitForMessageType()`、`DrainPendingMessages()`。
    - 在 typed receive 侧允许直接把 body 反序列化为 `FDebugServerVersionMessage`、`FAngelscriptCallStack`、`FAngelscriptVariables` 等现有 message struct，避免测试文件重复写解析代码。
    - 对超时、断链、半包和 unexpected message type 返回明确错误文本，不能只返回 `false`。
  - **验证方式**：
    - 先由 `P2.2` 固化 framing contract，再用 `P2.3` 冒烟测试实际走一次 `StartDebugging -> DebugServerVersion` 的最小消息闭环。
  - **完成判据**：
    - 后续各 `Debugger/*.cpp` 测试文件只需要关心“发什么消息、断言什么结果”，不需要再手动管理 socket buffer 和 body 反序列化。
- [ ] **P1.2** 📦 Git 提交：`[Debugger/Test] Feat: add debugger TCP test client helpers`

- [ ] **P1.3** 更新 `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
  - 新增 `Debugger` include path。
  - 明确补充 `Networking` / `Sockets` 依赖，确保 TCP debug client helper 可以直接编译。
  - **实现要求**：
    - 只补本次 debugger tests 必需依赖，不顺手扩大 `PublicDependencyModuleNames`。
    - 若 `Debugger/` 新目录只供私有测试使用，优先放入 `PrivateIncludePaths`，不要把测试目录无意义地暴露为 public include。
  - **验证方式**：
    - 单独编译 `AngelscriptTest` 模块，确认新增 helper include、`FSocket`、`ISocketSubsystem`、`Networking` 相关符号都能解析。
  - **完成判据**：
    - 后续 `AngelscriptDebuggerTestClient` 与 `Debugger/*.cpp` 文件不需要再通过相对 include 或复制 runtime include path 才能编译。
- [ ] **P1.3** 📦 Git 提交：`[Debugger/Test] Chore: add debugger test module dependencies`

- [ ] **P1.4** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.h/.cpp`
  - 封装“稳定脚本文件路径 + 固定行号”的编译方式。
  - 优先复用 `CompileAnnotatedModuleFromMemory()` 或等价 helper，确保 debugger 断点按固定脚本文件命中。
  - 明确禁止在 debugger 场景测试里直接依赖 `BuildModule()` 的 GUID 绝对路径作为断言对象。
  - **文件职责**：
    - `.h` 定义 fixture 描述结构，例如模块名、脚本相对路径、关键断点行号、关键变量路径。
    - `.cpp` 负责根据测试名生成脚本源码、写入稳定文件名、编译模块并返回行号索引。
  - **实现要求**：
    - fixture 至少覆盖三类脚本：断点/步进脚本、调用栈/变量脚本、绑定行为脚本。
    - 行号不要靠“手数源码第几行”隐式维护；应在 fixture 中集中声明关键语句行号，避免后续改脚本后测试全体悄悄漂移。
    - 如果使用 `CompileAnnotatedModuleFromMemory()`，应明确脚本文件名与模块名的映射规则，避免同名模块互相覆盖。
  - **验证方式**：
    - 至少保证 fixture 生成的脚本路径在断点命中消息和 callstack/source 字段中保持稳定。
  - **完成判据**：
    - 后续断点/步进/变量测试可以直接引用 fixture 提供的 `LineNumbers`、`VariablePaths`、`ModuleName`，不再在测试文件里手写行号常量。
- [ ] **P1.4** 📦 Git 提交：`[Debugger/Test] Feat: add deterministic debugger script fixtures`

- [ ] **P1.5** 如确有必要，更新 `Config/DefaultEngine.ini`，添加 `AngelscriptDebugger` 测试组过滤规则
  - `Contains="Angelscript.TestModule.CppTests.Debugger."`
  - `Contains="Angelscript.TestModule.Debugger."`
  - 仅在确认现有配置确实需要统一入口时执行；否则保留到 Phase 6。
  - **实现要求**：
    - 先确认仓库当前是否已有 debugger 相关 group，避免新旧规则重叠或命中范围过宽。
    - group 只聚合同主题 debugger tests，不要顺手把 `Angelscript.TestModule.CppTests.AngelscriptCodeCoverage.*` 或其他依赖 line callback 的测试一并纳入。
  - **验证方式**：
    - 配置后用 `Automation RunTest Group:AngelscriptDebugger` 验证过滤结果；若匹配面不稳定则宁可先不提交该步。
  - **完成判据**：
    - 文档和配置中对 debugger test group 的命名一致，且不会误包含非 debugger 用例。
- [ ] **P1.5** 📦 Git 提交：`[Debugger/Test] Chore: add debugger automation test groups`

### Phase 2：补齐 Runtime 低层协议与传输测试

> 目标：优先锁住最 deterministic 的 debugger 协议层，先把 framing contract 定死，再上 TCP smoke 和真断点场景。

- [ ] **P2.1** 创建 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDebugProtocolTests.cpp`
  - 对以下 message struct 做保存/读取 round-trip：
    - `FStartDebuggingMessage`
    - `FDebugServerVersionMessage`
    - `FAngelscriptBreakpoint`
    - `FAngelscriptClearBreakpoints`
    - `FAngelscriptVariable` / `FAngelscriptVariables`
    - `FAngelscriptDataBreakpoint` / `FAngelscriptDataBreakpoints`
    - `FAngelscriptBreakFilters`
    - `FAngelscriptDebugDatabaseSettings`
  - 覆盖 `DebugAdapterVersion >= 2` 时 `ValueAddress` / `ValueSize` 的序列化分支。
  - 每个测试必须显式保存并恢复 `AngelscriptDebugServer::DebugAdapterVersion`，避免不同协议版本用例相互污染。
  - 测试名建议统一使用 `Angelscript.TestModule.CppTests.Debugger.Protocol.*`。
  - **实现要求**：
    - 用例按消息族拆分，而不是一个 test 覆盖所有 struct：`Protocol.StartDebugging.RoundTrip`、`Protocol.Breakpoint.RoundTrip`、`Protocol.Variables.Version2RoundTrip` 之类分别存在。
    - round-trip 断言必须覆盖所有已定义字段；例如 `FAngelscriptVariable` 不仅要比对 `Name/Value/Type`，还要在 V2 下校验 `ValueAddress/ValueSize`。
    - 对可选字段（如旧版协议下不存在的字段）要明确写出“旧版加载后的默认值预期”，不能只断言反序列化成功。
  - **验证方式**：
    - 运行 `Angelscript.TestModule.CppTests.Debugger.Protocol.*`，确保每个消息族至少一个正例，关键兼容分支至少一个版本切换用例。
  - **完成判据**：
    - 任何 message struct 字段顺序变动、字段丢失、版本分支错误，都能由该文件中的单测直接打红。
- [ ] **P2.1** 📦 Git 提交：`[Debugger/Test] Feat: add debugger protocol round-trip tests`

- [ ] **P2.2** 创建 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDebugTransportTests.cpp`
  - 先明确并固定 debugger framing contract：长度字段到底表示 body 长度，还是 `messageType + body` 总长度；该语义必须与当前实现保持一致后再继续 smoke 测试。
  - 如果当前产品代码缺少可复用的 framing seam，优先先抽出极小的 encode/decode helper 供生产代码与测试共用，而不是在测试中手写第二份协议实现。
  - 至少覆盖：单消息、多消息顺序读取、截断包失败路径、错误长度失败路径，以及“空消息体”的**真实可接受 envelope**，不得先假设真正零长度 inbound packet 一定合法。
  - 该文件优先测生产编解码逻辑，不依赖真实远端 IDE。
  - **实现要求**：
    - 如果当前实现没有可直接复用的 framing helper，本步应优先抽出一个极小的 encode/decode 公共函数，再让生产代码与测试共同使用它。
    - transport tests 必须覆盖“连续两条消息写入同一个 buffer 后被顺序读出”的场景，防止只验证单消息 happy path。
    - 错误路径要明确断言行为：返回失败、记录错误、丢弃连接或保留缓冲区中的哪一种；不能只写“应该失败”。
  - **验证方式**：
    - 运行 `Angelscript.TestModule.CppTests.Debugger.Transport.*`，并确认其中至少存在 `SingleEnvelope`、`MultipleEnvelopes`、`TruncatedEnvelope`、`InvalidLength` 四类命名清晰的 case。
  - **完成判据**：
    - 后续 `TestClient` 对长度字段和 body 读取语义不再靠猜；transport contract 已被写成测试事实。
- [ ] **P2.2** 📦 Git 提交：`[Debugger/Test] Feat: add debugger transport framing tests`

- [ ] **P2.3** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerSmokeTests.cpp`
  - 在完成 `P2.2` framing contract 固化后，建立最小冒烟路径：启动 debugger test session → 创建 debug client → 完成 `StartDebugging` 握手 → 验证 `DebugServerVersion` 与基础返回消息可收发。
  - 测试名建议：`Angelscript.TestModule.Debugger.Smoke.Handshake`。
  - **实现要求**：
    - 冒烟测试至少覆盖 `Connect -> StartDebugging -> 收到版本/基础响应 -> StopDebugging/Disconnect` 的闭环，不只测 TCP 连接成功。
    - 若 server 需要 engine tick 才能处理消息，必须显式通过 session pump 驱动；禁止依赖“编辑器自己会 tick 到”。
    - 除版本消息外，建议再追加一个极轻量请求（如 `RequestBreakFilters` 或等价无脚本依赖请求）确认双向消息都可用。
  - **验证方式**：
    - 冒烟测试结束后 `bIsDebugging`、client 连接和 queued message 状态都应恢复到空闲，不留下长连接。
  - **完成判据**：
    - 该测试能作为后续所有 debugger 场景测试的前置健康检查：只要它红，优先排查 transport/session，而不是断点逻辑。
- [ ] **P2.3** 📦 Git 提交：`[Debugger/Test] Feat: add debugger handshake smoke test`

- [ ] **P2.4** 运行 `Angelscript.TestModule.CppTests.Debugger.*` 与 `Angelscript.TestModule.Debugger.Smoke.*`，确认协议层与握手冒烟都通过
  - **验证方式**：
    - 先单跑 `Protocol.*`、再单跑 `Transport.*`、最后跑 `Smoke.*`，避免一口气运行后无法定位是协议层还是 session 层出问题。
    - 若 `Smoke` 失败，优先检查 port、tick 驱动和 framing，而不是直接修改断点/变量测试计划。
  - **完成判据**：
    - Phase 2 结束时，后续所有场景测试都可以默认“传输层和最小握手是可信的”。
- [ ] **P2.4** 📦 Git 提交：`[Debugger/Test] Test: verify low-level debugger protocol and smoke suite`

### Phase 3：建立断点与步进核心场景测试

> 目标：基于真实脚本执行与暂停上下文，验证 debugger 最核心的“停得住、继续得动、步进正确”。

- [ ] **P3.1** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerBreakpointTests.cpp`
  - 使用固定脚本 fixture 构造明确行号的测试脚本。
  - 覆盖：
    - `SetBreakpoint` 后命中指定脚本行
    - `ClearBreakpoints` 后同一路径不再停住
    - 同一脚本多断点只命中当前执行路径上的断点
  - 测试名建议：`Angelscript.TestModule.Debugger.Breakpoint.HitLine`、`...ClearThenResume`、`...IgnoreInactiveBranch`。
  - **实现要求**：
    - fixture 至少准备两段脚本：单路径脚本（验证精确命中）和带 `if/else` 或多函数调用的脚本（验证未执行分支不误停）。
    - 触发脚本执行时优先复用现有 `ExecuteGeneratedIntEventOnGameThread()` / 等价 game-thread helper，不要在测试里直接裸调 UObject 事件并自行同步。
    - 对 `SetBreakpoint` 的断言至少包含：收到 `HasStopped`/同义停止消息、停止文件为 fixture 文件、停止行号等于预设断点行、停止原因为 breakpoint。
  - **验证方式**：
    - 每个用例结束前都要显式发送 `Continue` 或 `StopDebugging`，并确认脚本能够收尾执行，不把 paused 状态遗留给后续 case。
  - **完成判据**：
    - 该文件能区分“断点根本没命中”“命中了错误行”“命中了不该执行的分支”三类错误，而不是只有一个模糊失败。
- [ ] **P3.1** 📦 Git 提交：`[Debugger/Test] Feat: add debugger breakpoint hit tests`

- [ ] **P3.2** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerSteppingTests.cpp`
  - 构造 caller/callee 双层脚本，覆盖：
    - `StepIn` 进入被调用函数
    - `StepOver` 在当前 frame 内移动到下一行
    - `StepOut` 返回调用者 frame
  - 每个用例都必须同时断言：停止原因、行号变化、栈深度变化。
  - **实现要求**：
    - fixture 中至少包含一处函数调用点和一处调用后的下一行，以区分 `StepIn` 与 `StepOver` 的落点。
    - `StepOut` 用例必须在 callee 内部发起，不允许在 caller 层直接发 `StepOut` 造成无效通过。
    - 若获取栈深度需要先请求 callstack，本步允许复用 `RequestCallStack` 作为辅助断言，但主要目标仍是验证 step 行为。
  - **验证方式**：
    - 对每个 step 用例同时记录 stepping 前后的 `LineNumber` 与 `FrameCount`，避免只断言其中一个维度。
  - **完成判据**：
    - 三种 step 行为各自有单独用例，且任何一种 step 被错误实现为 continue 或 break-next-line 都会被识别出来。
- [ ] **P3.2** 📦 Git 提交：`[Debugger/Test] Feat: add debugger stepping tests`

- [ ] **P3.3** 在 `AngelscriptDebuggerSmokeTests.cpp` 或独立 helper 中补充统一超时/continue 清理逻辑
  - 任何失败分支都必须发送 `Continue` / `StopDebugging` 或显式清理 client，防止测试用例卡死后续批次。
  - **实现要求**：
    - 将“等待停止”“等待继续”“失败时兜底断开”“暂停后自动恢复”统一抽到 helper；不得让每个 `RunTest()` 自己复制一版。
    - 至少支持 `ON_SCOPE_EXIT` 风格的恢复钩子，保证断言提前返回时也会执行清理。
  - **验证方式**：
    - 人为制造一个失败分支（例如等待不存在的断点），确认测试会超时失败但不会让后续用例永远卡住。
  - **完成判据**：
    - debugger 场景测试的失败形态从“挂住整个批次”收敛为“单用例超时报错并可继续执行后续用例”。
- [ ] **P3.3** 📦 Git 提交：`[Debugger/Test] Chore: harden debugger test cleanup and timeouts`

- [ ] **P3.4** 运行 `Angelscript.TestModule.Debugger.Breakpoint.*` 与 `Angelscript.TestModule.Debugger.Stepping.*`
  - **验证方式**：
    - 先单独跑 `Breakpoint.*`，再单独跑 `Stepping.*`，最后一起跑，确认没有共享状态污染。
  - **完成判据**：
    - 同一轮回归中，断点和步进用例既能单跑，也能组合跑，不因前序用例留下 breakpoints/debugging 状态而互相影响。
- [ ] **P3.4** 📦 Git 提交：`[Debugger/Test] Test: verify breakpoint and stepping suites`

### Phase 4：补齐调用栈与变量求值测试

> 目标：验证 debugger 在 paused context 中真正输出了可供 IDE 使用的栈帧与变量数据。

- [ ] **P4.1** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerCallstackTests.cpp`
  - 覆盖 `RequestCallStack` / `CallStack`：
    - 帧顺序正确（最顶层是当前函数）
    - `Name` / `Source` / `LineNumber` 非空且指向 fixture 脚本
    - 多层调用链条下 frame 数量与脚本层次一致
  - **实现要求**：
    - fixture 至少包含三层函数调用（例如 `Entry -> Middle -> Leaf`），确保 callstack 不是只有单帧的假阳性。
    - 对每一帧至少断言函数名、文件名和行号；若 `ModuleName` 有值，也一并校验其与 fixture 模块名一致。
    - 第一批不强行覆盖 Blueprint frame；若后续需要纳入 Blueprint 栈帧，必须作为新增任务单独扩 scope。
  - **验证方式**：
    - 先命中断点，再发送 `RequestCallStack`；不能跳过“已暂停”前提直接请求栈，避免测成空上下文。
  - **完成判据**：
    - 调用栈 tests 能区分“帧顺序错了”“行号错了”“source 路径漂移了”三类回归。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.Callstack.SingleFrame`
    - `Angelscript.TestModule.Debugger.Callstack.NestedFrames`
    - `Angelscript.TestModule.Debugger.Callstack.SourceAndLineMatchFixture`
- [ ] **P4.1** 📦 Git 提交：`[Debugger/Test] Feat: add debugger callstack tests`

- [ ] **P4.2** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerVariableTests.cpp`
  - 覆盖 `RequestVariables` / `RequestEvaluate`：
    - `%local%` scope
    - `%this%` scope
    - `%module%` scope
    - global / namespace global 路径
    - 直接表达式路径如 `0:LocalValue`、`0:this.Member`、`0:%module%.GlobalCounter`
  - 至少验证 `Name`、`Value`、`Type`、`bHasMembers`；若 `DebugAdapterVersion >= 2`，再验证 `ValueAddress` / `ValueSize`。
  - **实现要求**：
    - fixture 中至少准备：
      - 一个局部整型/字符串变量
      - 一个带成员字段的 `this` 对象
      - 一个模块级全局变量
      - 一个命名空间或全局属性 accessor 场景
    - `RequestVariables` 与 `RequestEvaluate` 要分别覆盖，避免只测其中一个 API。
    - 对 `bHasMembers=true` 的值，应至少再向下一层取一次成员，证明成员展开路径有效。
  - **验证方式**：
    - 路径断言优先使用 fixture 提供的稳定变量路径，不在测试里手写散落字符串。
    - 对字符串值、对象成员值等易变文本允许精确匹配或带界限的包含匹配，但需在计划中明确用哪种方式。
  - **完成判据**：
    - 变量 tests 可以证明 debugger 不只是“能返回一坨变量”，而是能按 scope/path 取到预期值与类型。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.Variables.LocalScope`
    - `Angelscript.TestModule.Debugger.Variables.ThisScope`
    - `Angelscript.TestModule.Debugger.Variables.ModuleScope`
    - `Angelscript.TestModule.Debugger.Variables.EvaluateDirectPath`
    - `Angelscript.TestModule.Debugger.Variables.ExpandMembers`
- [ ] **P4.2** 📦 Git 提交：`[Debugger/Test] Feat: add debugger variables and evaluate tests`

- [ ] **P4.3** 为变量测试补充负例
  - 不存在变量名
  - 非法 frame index
  - 成员链错误
  - 空作用域请求不应崩溃
  - **实现要求**：
    - 对每个负例明确预期：返回 false、返回空数组、返回错误日志，还是返回默认 message；不要只写“应该失败”。
    - 负例必须覆盖 `RequestEvaluate` 与 `RequestVariables` 两条路径里至少各一类错误，而不是都压在一个 API 上。
  - **验证方式**：
    - 校验失败后 session/client 仍可继续发送下一条合法请求，避免错误路径把整个 debugger 会话打坏。
  - **完成判据**：
    - 变量错误路径从“可能崩溃/卡住/静默错误”收敛为可预测的失败行为。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.Variables.InvalidFrame`
    - `Angelscript.TestModule.Debugger.Variables.InvalidMemberPath`
    - `Angelscript.TestModule.Debugger.Variables.UnknownScope`
- [ ] **P4.3** 📦 Git 提交：`[Debugger/Test] Test: add negative debugger variable lookup coverage`

- [ ] **P4.4** 运行 `Angelscript.TestModule.Debugger.Callstack.*` 与 `Angelscript.TestModule.Debugger.Variables.*`
  - **验证方式**：
    - 先单跑 `Callstack.*`、再单跑 `Variables.*`、最后组合跑，确认没有 frame/path 全局状态泄露。
  - **完成判据**：
    - 组合回归下，变量和调用栈测试仍保持稳定，不因之前 case 的暂停帧/模块名残留而串味。
- [ ] **P4.4** 📦 Git 提交：`[Debugger/Test] Test: verify callstack and variable suites`

### Phase 5：补齐调试绑定行为测试

> 目标：覆盖脚本层最常用的调试入口，保证 `DebugBreak/ensure/check/callstack` 这些对脚本作者可见的 API 不回归。

- [ ] **P5.1** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerBindingTests.cpp`
  - 提供统一 RAII / fixture，显式区分两类测试模式：
    - **Pause-path 模式**：保持 debug breaks enabled，用于验证已连接 debugger client 时 `DebugBreak()` 真正触发暂停。
    - **No-crash / log 模式**：临时调用 `AngelscriptDisableDebugBreaks()`，用于验证 `ensure()` / `check()` 日志与不崩溃行为。
  - 在每个测试前后恢复全局状态：`AngelscriptEnableDebugBreaks()`、`AngelscriptForgetSeenEnsures()`。
  - **实现要求**：
    - 用显式的小型 guard 类或 `ON_SCOPE_EXIT` 统一封装 debug break 模式切换，不让每个用例手写 enable/disable 成对调用。
    - 如果 `DO_CHECK` / `WITH_AS_DEBUGSERVER` 影响行为，须在测试文件顶部或用例名中明确写出条件，不得让执行者靠编译配置猜。
  - **验证方式**：
    - 至少有一个用例验证 pause-path 真能停住，有一个用例验证 no-crash/log 路径真不会硬中断测试进程。
  - **完成判据**：
    - 绑定测试从一开始就把“会不会真的断进 C++ 调试器”这个风险隔离掉，而不是靠人工小心执行。
  - **建议 guard 结构**：
    - `FScopedAngelscriptDebugBreakMode`
    - `FScopedAngelscriptEnsureReset`
    - 若已有现成 RAII 风格 helper，可复用现有命名风格而不强行引入新类名。
- [ ] **P5.1** 📦 Git 提交：`[Debugger/Test] Feat: add debugger binding test guards`

- [ ] **P5.2** 在 `AngelscriptDebuggerBindingTests.cpp` 中覆盖：
  - `GetAngelscriptCallstack()` 返回非空栈信息
  - `FormatAngelscriptCallstack()` 返回包含脚本函数名/文件名的字符串
  - `DebugBreak()` 在 **pause-path 模式** 且已连接 debugger client 时能够触发暂停事件
  - `ensure(false, "...")` / `check(false, "...")` 在 **no-crash / log 模式** 下产生日志且不造成测试进程异常中断
  - **实现要求**：
    - `GetAngelscriptCallstack()` / `FormatAngelscriptCallstack()` 不仅看非空，还应至少匹配到 fixture 中的函数名或文件名片段。
    - `DebugBreak()` 用例需要先建立活跃 debugger session，再触发脚本中的 `DebugBreak()`；不能只直接调用 C++ helper 伪造暂停。
    - `ensure` / `check` 用例应分别覆盖带 message 和不带 message 两种形式中的至少一种，避免只测单重载。
  - **验证方式**：
    - 对日志类用例尽量使用已有 `AddExpectedError`/日志捕获能力，而不是依赖人工读日志。
  - **完成判据**：
    - 该文件能证明“脚本作者真的会用到的调试 API”在连接 debugger 和未连接 debugger 两种状态下都行为可控。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.Bindings.GetCallstack`
    - `Angelscript.TestModule.Debugger.Bindings.FormatCallstack`
    - `Angelscript.TestModule.Debugger.Bindings.DebugBreakPausePath`
    - `Angelscript.TestModule.Debugger.Bindings.EnsureLogsWithoutBreaking`
    - `Angelscript.TestModule.Debugger.Bindings.CheckLogsWithoutBreaking`
- [ ] **P5.2** 📦 Git 提交：`[Debugger/Test] Feat: add debug break and ensure binding tests`

- [ ] **P5.3** 补充 `AngelscriptForgetSeenEnsures()` 相关回归
  - 验证同一 ensure 位点不会重复打断，调用 forget 后再次触发可重新命中。
  - **实现要求**：
    - 至少有三个动作顺序：首次触发 ensure -> 同位点再次触发不重复打断 -> 调用 forget -> 第三次再次命中。
    - 若涉及 `GEndPlayMapCount` 或其他去重状态，应确保测试内显式重置，不依赖前序 map 生命周期。
  - **验证方式**：
    - 除了看暂停次数，还要验证重置前后日志/停止事件数量符合预期。
  - **完成判据**：
    - ensure 去重逻辑被准确锁住，不会因为重构日志/断点流程而悄悄改变语义。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.Bindings.EnsureDeduplicates`
    - `Angelscript.TestModule.Debugger.Bindings.EnsureDedupReset`
- [ ] **P5.3** 📦 Git 提交：`[Debugger/Test] Test: cover ensure de-duplication reset behavior`

- [ ] **P5.4** 运行 `Angelscript.TestModule.Debugger.Bindings.*`
  - **验证方式**：
    - 先单跑 pause-path 相关用例，再单跑 no-crash/log 相关用例，最后合并跑，确认两种模式不会互相污染全局开关。
  - **完成判据**：
    - 绑定类用例在同一批次下仍保持稳定，且失败时不会把整个 automation 进程打断。
- [ ] **P5.4** 📦 Git 提交：`[Debugger/Test] Test: verify debugger binding suite`

### Phase 6：补齐 Win64 数据断点与文档落地

> 目标：把平台限定能力和运行文档补齐，但不让 Win64 数据断点阻塞前五个 Phase 的核心交付。

- [ ] **P6.1** 创建 `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerDataBreakpointTests.cpp`
  - 仅在 `PLATFORM_WINDOWS && WITH_AS_DEBUGSERVER` 下启用。
  - 利用变量查询返回的 `ValueAddress` / `ValueSize` 建立 data breakpoint。
  - 覆盖：
    - 变量写入后在下一脚本行停住
    - `ClearDataBreakpoints` 后不再命中
    - 离开栈帧或 hit count 到 0 时状态按预期清理
  - **实现要求**：
    - 在文件顶部明确平台 gate 和 skip 策略：非 Win64 或不支持硬件断点时，要么编译期排除，要么运行时明确 `AddInfo/Skip`，不能让用例误红。
    - `ValueAddress` / `ValueSize` 的来源必须来自 debugger 返回值，而不是测试自己去猜内存布局。
    - 至少覆盖单个 data breakpoint、清除后不再触发、hit count 递减三种路径；若超出硬件上限的行为要测，单独列为附加 case。
  - **验证方式**：
    - 每个用例结束后确认 `DataBreakpoints` 已清空或恢复，避免硬件寄存器状态污染本机后续调试。
  - **完成判据**：
    - 该文件能在支持环境中稳定验证 data breakpoint 的核心语义，在不支持环境中稳定跳过。
  - **建议最小用例清单**：
    - `Angelscript.TestModule.Debugger.DataBreakpoint.TriggerOnWrite`
    - `Angelscript.TestModule.Debugger.DataBreakpoint.ClearStopsTriggering`
    - `Angelscript.TestModule.Debugger.DataBreakpoint.CleanupOnScopeExit`
- [ ] **P6.1** 📦 Git 提交：`[Debugger/Test] Feat: add Win64 data breakpoint tests`

- [ ] **P6.2** 更新 `Documents/Guides/Test.md`
  - 补充 debugger 测试的推荐分批命令：
    - `Automation RunTests Angelscript.TestModule.CppTests.Debugger`
    - `Automation RunTests Angelscript.TestModule.Debugger`
    - 如配置了组：`Automation RunTest Group:AngelscriptDebugger`
  - 写明必须先读取 `AgentConfig.ini`，通过 `Paths.EngineRoot` 和 `ProjectFile` 组装命令，不能写死本地路径。
  - 写明 Win64 数据断点测试仅在支持硬件调试寄存器的环境启用。
  - **实现要求**：
    - 文档里区分“低层协议/transport”与“场景调试”两类入口，避免执行者一上来就跑完整 debugger 矩阵。
    - 明确说明推荐执行顺序、推荐超时、常见失败定位方式（端口冲突、session 未 pump、断点文件路径漂移）。
  - **验证方式**：
    - 文档更新后，按文档命令实际跑至少一组最小用例，确认命令和测试前缀一致。
  - **完成判据**：
    - 新人只看 `Test.md` 就能知道 debugger tests 分哪几类、先跑哪一批、哪里是 Win64-only。
- [ ] **P6.2** 📦 Git 提交：`[Docs] Feat: document debugger automation test entry points`

- [ ] **P6.3** 运行一轮分批验证
  - `Angelscript.TestModule.CppTests.Debugger.*`
  - `Angelscript.TestModule.Debugger.Breakpoint.*`
  - `Angelscript.TestModule.Debugger.Stepping.*`
  - `Angelscript.TestModule.Debugger.Callstack.*`
  - `Angelscript.TestModule.Debugger.Variables.*`
  - `Angelscript.TestModule.Debugger.Bindings.*`
  - Win64 环境再追加 `Angelscript.TestModule.Debugger.DataBreakpoint.*`
  - **实现要求**：
    - 每一批验证都记录失败定位优先级：协议/transport -> smoke -> breakpoint/stepping -> callstack/variables -> bindings -> data breakpoint。
    - 若组合跑失败，必须回退到上一层最小批次复现，而不是直接在全量矩阵里盲改。
  - **完成判据**：
    - 最终矩阵不是“跑过一次算完”，而是能清楚说明每一层通过后对后续层提供了什么可信前提。
- [ ] **P6.3** 📦 Git 提交：`[Debugger/Test] Test: verify full debugger automation matrix`

## 推荐实施顺序

如果需要先交第一批可用价值，建议按以下里程碑推进：

1. **M1** = Phase 1 + Phase 2
   - 先锁住协议与测试脚手架，保证后续调试测试能稳定驱动。
2. **M2** = Phase 3 + Phase 4
   - 交付最核心的断点 / 步进 / 栈 / 变量验证能力。
3. **M3** = Phase 5
   - 补脚本作者直接可见的调试绑定行为。
4. **M4** = Phase 6
   - 再处理 Win64 data breakpoint 和文档/分组完善。

## 验收标准

1. `AngelscriptRuntime/Tests/` 中存在 `Angelscript.TestModule.CppTests.Debugger.*` 测试集，并覆盖核心 message round-trip 与 framing。
2. `AngelscriptTest/Debugger/` 目录建立完成，且至少包含 `Smoke / Breakpoint / Stepping / Callstack / Variables / Bindings` 六类测试文件。
3. 断点测试可稳定命中固定脚本文件与固定行号，不依赖 GUID 绝对路径。
4. 步进测试同时断言停止原因、行号和调用栈深度变化。
5. 变量测试覆盖 `%local%`、`%this%`、`%module%` 与 global 查询路径。
6. `DebugBreak()` / `ensure()` / `check()` 有自动化测试保护，且测试期间不会意外触发原生 `UE_DEBUG_BREAK()` 中断整个进程。
7. Win64 数据断点测试被明确标记为平台 gated；非 Win64 环境不会误跑失败。
8. `Documents/Guides/Test.md` 明确给出 debugger 测试的运行入口与限制说明。

## 风险与注意事项

### 风险 1：脚本文件路径不稳定导致断点断言脆弱

现有 `BuildModule()` 会写入带 GUID 的绝对脚本路径，适合普通编译/执行测试，不适合 debugger 精确断言文件名与行号。

**缓解**：必须引入 `AngelscriptDebuggerScriptFixture`，统一为 debugger 测试生成固定路径和固定脚本内容。

### 风险 2：`PauseExecution()` 阻塞导致测试批次卡死

debugger 测试不同于普通 `RunTest()`，失败路径若没有发送 `Continue` / `StopDebugging`，很容易把整个 automation 进程挂住。

**缓解**：所有调试场景测试统一复用超时 + 清理 helper，失败分支也必须兜底断开 client 并恢复执行。

### 风险 3：transport framing 语义不先钉死，会让后续 smoke/client 测试建立在错误假设上

当前 send/receive 代码对长度字段的含义必须先用测试固定下来，否则后续 test client 很容易根据“看起来合理”的协议猜测实现，导致测试在保护一份并不存在的协议。

**缓解**：先完成 `P2.2`，必要时抽出生产可复用的 framing helper；在 contract 固化前不进入 handshake smoke。

### 风险 4：变量求值与调用栈测试容易被“离线伪验证”误导

`GetDebuggerValue()` / `GetDebuggerScope()` 依赖当前 active context。脚本执行结束后再测，只能测到假阳性或空上下文。

**缓解**：变量/栈相关测试必须发生在 debugger 已暂停、且 frame 已知的时刻，不允许替换成“脚本执行完成后读取其它缓存”的伪用例。

### 风险 5：Win64 数据断点受硬件环境和外部调试器干扰

`DataBreakpoint_Windows` 依赖 debug register 和异常处理，在 CI、远程桌面或外部调试器附加时都可能不稳定。

**缓解**：将数据断点单列为平台 gated 阶段；首批核心交付不依赖它通过。

### 风险 6：`DebugBreak()` / `check()` 直接打断进程

如果测试没有先禁用原生 debug break，脚本层 `DebugBreak()` 或失败 `check()` 可能直接触发 `UE_DEBUG_BREAK()`。

**缓解**：绑定测试拆成两种模式执行：

- **pause-path 模式** 保持 debug breaks enabled，但必须建立活动 debugger session，并通过 guard/session cleanup 保证测试不会把进程卡死。
- **no-crash / log 模式** 先调用 `AngelscriptDisableDebugBreaks()`，只验证日志与不崩溃语义。

两种模式都必须在测试结束后恢复全局状态，不能混用一套模糊流程。 
