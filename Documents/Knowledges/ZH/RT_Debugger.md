# RT_Debugger — 调试协议集成（DebugServer V2）

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 站在"DebugServer V2 怎么把外部 IDE 客户端的暂停 / 单步 / 断点 / 变量观察请求，翻译成 `asCContext` 这一层的执行控制"的视角，看 `Debugging/AngelscriptDebugServer.{h,cpp}`、`Core/AngelscriptEngine.cpp::AngelscriptLineCallback` / `UpdateLineCallbackState` 与 AS 内核 `asCContext::ExecuteNext / SetLineCallback` 三者的协作。本文不重写 AS 字节码 VM 主循环（那是 `AS_VirtualMachine.md` 的事）、不重写 ClassGenerator / HotReload / StaticJIT 的内部实现（那分别是 `Type_ClassGeneration.md` / `RT_HotReload.md` / `RT_StaticJIT.md`）、不写 VS Code 扩展或 DAP 适配器的客户端实现（那属于 `Documents/Plans/Plan_DebugAdapter.md` 与未来的 OpenSpec 提案）。**本文聚焦的是"在 UE 进程内运行的调试服务端"——它如何挂入 AS 引擎、用什么协议跟客户端通信、断点 / 单步 / 调用栈 / 变量观察的内部状态机怎么走，以及它与 HotReload / StaticJIT / 多 Engine 实例如何协调。**
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` (~763 行) · `Debugging/AngelscriptDebugServer.cpp` (~3312 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp::CreateConfiguredContext / CreateContext / AngelscriptLineCallback / AngelscriptStackPopCallback / UpdateLineCallbackState / TryBreakpointAngelscriptDebugging` (~325–360 / ~1930–1945 / ~5840–5980 / ~6130–6160 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h::FDebuggerValue / FDebuggerScope / GetDebuggerValue / GetDebuggerScope / GetDebuggerMember` (~611–752 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp::SetLineCallback / ExecuteNext (asBC_SUSPEND) / 退出循环时的 m_lineCallback` (~5066 / ~2476–2490 / ~1042–1057 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebugger*Tests.cpp` (11 个 .cpp，~5756 行总测试覆盖；`SmokeTests` / `SessionInfraTests` / `BreakpointTests` / `SteppingTests` / `PauseTests` / `EvaluationTests` / `DataBreakpointTests` 等)
> **关联文档**:
> `Documents/Knowledges/ZH/AS_VirtualMachine.md` — `asCContext::Execute` / `ExecuteNext` 解释器主循环（line callback 在 `asBC_SUSPEND` 处插入）
> · `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — `FAngelscriptEngine::Tick` 中 `DebugServer->Tick()` 的位置
> · `Documents/Knowledges/ZH/RT_HotReload.md` — `PerformHotReload` 末尾 `DebugServer->ReapplyBreakpoints()` 协同
> · `Documents/Knowledges/ZH/RT_StaticJIT.md` — `asEP_BUILD_WITHOUT_LINE_CUES` 在 JIT 路径下消除 `asBC_SUSPEND` 的影响
> · `Documents/Knowledges/ZH/RT_CodeCoverage.md` — Coverage 子系统同样借用 line callback 钩子
> **外部参考**:
> [Debug Adapter Protocol 规范](https://microsoft.github.io/debug-adapter-protocol/specification) — 客户端侧 DAP 适配器映射的目标协议（注意：本插件 wire 格式并非 DAP，是自定义二进制；DAP 是适配器层的目标）

---

## 概览

本文聚焦一个核心问题：**当一个外部 IDE 客户端通过 TCP socket 连接 UE 进程内的 `FAngelscriptDebugServer`，发出"在 `Foo.as:42` 行设个断点 / 命中后给我变量值 / 现在 step over"，这套请求怎么穿过 envelope 协议、最终落到 `asCContext` 的字节码执行循环上？反过来，AS 脚本每跑一行如何反馈给客户端？多个 IDE 同时连接 / 多个 Engine 实例 / 与 HotReload 与 StaticJIT 怎么共存？**

DebugServer V2 是一套"**服务端在 UE 进程内、协议自描述、客户端在外部 IDE**"的远程调试架构。它由四层组成，自上而下嵌入 AS 引擎：

```text
┌──────────────────────────────────────────────────────────────────────────┐
│ 第 0 层（外部）：IDE 客户端 / DAP 适配器                                 │
│   VS Code 扩展 ── DAP request ──> TS DAP 适配器 ── 二进制 envelope ──>   │
│   （客户端实现尚未随插件分发；详见 Plan_DebugAdapter.md）                │
└─────────────────────────────────────┬────────────────────────────────────┘
                                      │ TCP 连接（默认端口由 -asdebugport= 指定）
┌─────────────────────────────────────▼────────────────────────────────────┐
│ 第 1 层：传输与 envelope                                                 │
│   FTcpListener::OnConnectionAccepted → FAngelscriptDebugServer           │
│   ProcessMessages：循环读 [int32 长度][uint8 类型][Body] envelope        │
│   SerializeDebugMessageEnvelope / TryDeserializeDebugMessageEnvelope     │
│   QueuedSends 写回（每客户端一个 FIFO）                                  │
└─────────────────────────────────────┬────────────────────────────────────┘
                                      │ EDebugMessageType 派发
┌─────────────────────────────────────▼────────────────────────────────────┐
│ 第 2 层：会话与状态机                                                    │
│   HandleMessage(type, body, client)                                      │
│     · StartDebugging / StopDebugging       ─ 调试会话边界                 │
│     · Pause / Continue / StepIn/Over/Out   ─ 执行控制                     │
│     · SetBreakpoint / ClearBreakpoints     ─ 断点表维护                   │
│     · RequestVariables / RequestEvaluate   ─ 状态查询                     │
│   核心位标志：bIsDebugging / bIsPaused / bBreakNextScriptLine /          │
│              bPauseRequested / ConditionBreakFrame+ConditionBreakFunction│
└─────────────────────────────────────┬────────────────────────────────────┘
                                      │ 改写 asCContext 静态门控
┌─────────────────────────────────────▼────────────────────────────────────┐
│ 第 3 层：AS 内核钩子                                                     │
│   FAngelscriptEngine::CreateContext                                      │
│     Context->SetLineCallback(AngelscriptLineCallback)                    │
│     Context->SetStackPopCallback(AngelscriptStackPopCallback)            │
│   asCContext::ExecuteNext (asBC_SUSPEND opcode):                         │
│     if (CanEverRunLineCallback &&                                        │
│         (ShouldAlwaysRunLineCallback ||                                  │
│          m_currentFunction->module->hasBreakPoints))                     │
│       m_lineCallback(this) → AngelscriptLineCallback                     │
│         → DebugServer->ProcessScriptLine(ctx)                            │
│            → 命中断点 / 单步条件成立 → PauseExecution → 阻塞循环         │
└──────────────────────────────────────────────────────────────────────────┘
```

DebugServer V2 与 V1 的关键差异在于：**`DEBUG_SERVER_VERSION = 2` 是 wire 协议版本号**，握手时通过 `DebugServerVersion` 消息回送给客户端；客户端通过 `DebugAdapterVersion` 在 `StartDebugging` 时反向声明能力等级（v0/v1 限制 ModuleName 字段、v2 暴露变量地址用于 hardware data breakpoint）。版本字段保留在每条相关消息的 `operator<<` 序列化分支中，向下兼容旧客户端。

后续章节按"**协议层 → 启动入口 → AS 引擎钩子 → 断点匹配 → 单步语义 → 调用栈与变量 → 多客户端 / 多 Engine → 与 HotReload / StaticJIT 协同 → VS Code 客户端形态**"的顺序展开。

---

## 一、传输与 Envelope 协议（第 1 层）

### 1.1 三段式 wire 格式

DebugServer 不是 DAP 标准的 JSON-RPC，而是一套**自定义的二进制 envelope**。每条消息固定为：

```text
┌──────────────────┬──────────────┬──────────────────────────────────┐
│  MessageLength   │ MessageType  │  Body (FArchive 序列化)           │
│  (int32, 4 字节) │ (uint8, 1B)  │  (变长，UE FArchive 小端序)        │
└──────────────────┴──────────────┴──────────────────────────────────┘
            ▲ MessageLength = sizeof(MessageType=1) + Body.Num()
```

`SerializeDebugMessageEnvelope` 写入这三段；`TryDeserializeDebugMessageEnvelope` 在客户端 socket 缓冲区上做"半包 / 整包"判定，未收满 length 头或未收满 body 时返回 `bOutHasEnvelope=false` 让上层等待下一次 `ProcessMessages`。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: TryDeserializeDebugMessageEnvelope
// ============================================================================
if (InOutBuffer.Num() < static_cast<int32>(sizeof(int32)))
    return true;                              // 还没收满 4 字节长度头
// ... 读 MessageLength
if (MessageLength <= 0 || MessageLength > MaxDebuggerEnvelopeSizeBytes)
    return false;                             // ★ 16 MB 上限保护
const int32 TotalEnvelopeSize = sizeof(int32) + MessageLength;
if (InOutBuffer.Num() < TotalEnvelopeSize)
    return true;                              // body 半包，等下次
// 读取 MessageType + Body，从 InOutBuffer 中 RemoveAt 已消费的字节
```

`MaxDebuggerEnvelopeSizeBytes = 16 * 1024 * 1024` 是有意的——`RequestDebugDatabase` 在大型项目上能产出数 MB 的 JSON 描述（所有类型 / 函数 / 属性 / 文档），需要单条 envelope 容纳完整的类型表。

### 1.2 EDebugMessageType 一览

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.h
// 节选自: enum class EDebugMessageType : uint8
// ============================================================================
enum class EDebugMessageType : uint8 {
    Diagnostics, RequestDebugDatabase, DebugDatabase,
    StartDebugging, StopDebugging, Pause, Continue,
    RequestCallStack, CallStack,
    ClearBreakpoints, SetBreakpoint,
    HasStopped, HasContinued,
    StepOver, StepIn, StepOut, EngineBreak,
    RequestVariables, Variables,
    RequestEvaluate, Evaluate, GoToDefinition,
    BreakOptions, RequestBreakFilters, BreakFilters,
    Disconnect, DebugDatabaseFinished, AssetDatabaseInit,
    AssetDatabase, AssetDatabaseFinished, FindAssets,
    DebugDatabaseSettings, PingAlive, DebugServerVersion,
    CreateBlueprint, ReplaceAssetDefinition,
    SetDataBreakpoints, ClearDataBreakpoints,
};
```

按职能可分四组：

- **会话控制**：`StartDebugging` / `StopDebugging` / `Disconnect` / `PingAlive` / `DebugServerVersion`
- **执行控制**：`Pause` / `Continue` / `StepIn` / `StepOver` / `StepOut` / `HasStopped` / `HasContinued` / `EngineBreak`
- **断点 / 数据断点**：`SetBreakpoint` / `ClearBreakpoints` / `SetDataBreakpoints` / `ClearDataBreakpoints` / `BreakOptions` / `RequestBreakFilters` / `BreakFilters`
- **状态 / 元数据查询**：`RequestCallStack` / `CallStack` / `RequestVariables` / `Variables` / `RequestEvaluate` / `Evaluate` / `Diagnostics` / `RequestDebugDatabase` / `DebugDatabase` / `DebugDatabaseSettings` / `DebugDatabaseFinished` / `AssetDatabase*` / `FindAssets` / `CreateBlueprint` / `GoToDefinition` / `ReplaceAssetDefinition`

每条消息都有对应的 `FXxxMessage` 结构 + `friend FArchive& operator<<`，由 UE 的 `FMemoryWriter` / `FMemoryReader` 统一序列化（FString = `[int32 长度][UTF-16LE 字符][NUL]`，TArray = `[int32 元素数][元素流]`）。版本兼容采用 `if (Ar.IsSaving() || !Ar.AtEnd())` 模式逐字段守门——加新字段不破坏旧客户端解析。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.h
// 节选自: FAngelscriptBreakpoint::operator<<
// ============================================================================
Ar << BP.Filename;
Ar << BP.LineNumber;
if (Ar.IsSaving() || !Ar.AtEnd())             // ★ Id 字段是 v1 加的
    Ar << BP.Id;
else
    BP.Id = -1;
if (Ar.IsSaving() || !Ar.AtEnd())             // ★ ModuleName 是 v2 加的
    Ar << BP.ModuleName;
if (Ar.IsSaving() || !Ar.AtEnd())             // ★ Condition 也是 v2 加的
    Ar << BP.Condition;
```

`FAngelscriptVariable` 类似——`ValueAddress` / `ValueSize` 仅在 `AngelscriptDebugServer::DebugAdapterVersion >= 2` 时序列化，老客户端看不到这两个字段，也就无法发起 hardware data breakpoint。

### 1.3 收发主循环：`ProcessMessages` 与 `Tick`

`FAngelscriptDebugServer::Tick` 在每帧 `FAngelscriptEngine::Tick` 末尾被调用一次，进而走入 `ProcessMessages`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ProcessMessages（核心收发循环）
// ============================================================================
// 1) 接收新连接：从 PendingClients (Mpsc 队列) 出队挂到 Clients[]
while (PendingClients.Dequeue(Client))
    Clients.Add(Client);

// 2) 清理：连接断开 / 队头消息 10s 仍未发完 → RemoveClientState
if (Client->GetConnectionState() != SCS_Connected || ... timeout)
    RemoveClientState(Client, true);

// 3) 对每个客户端：循环读 envelope 并分发到 HandleMessage
while (Client->HasPendingData(DataSize)) {
    // 先读 4 字节包长，再读 PacketSize 字节 body
    HandleMessage(MessageType, Datagram, Client);
}
TrySendingMessages(Client);                    // 把 QueuedSends 中的字节送出

// 4) 心跳：每 5 秒给 ClientsThatAreDebugging 发 PingAlive
if (bIsDebugging && now >= NextPingDebuggerAliveTime) ...

// 5) 异步 callstack：bIsPaused 期间客户端 Request 后此处补发
if (bIsPaused && CallstackRequests.Num() > 0)
    for (Socket : CallstackRequests) SendCallStack(Socket);
```

这里的几个关键设计：

- **`QueuedSends`**：每个客户端有自己的 `TArray<FQueuedMessage>` FIFO；`SendMessageToAll` / `SendMessageToClient` 都先入队再 `TrySendingMessages`；`Send` 部分写出剩余字节会留在队头，下次 `ProcessMessages` 续发。
- **`PingAlive` 5 秒一次**：双向心跳，客户端不响应也无所谓——但服务端能借 `GetConnectionState()` + 队头 10 秒超时自动剪掉死连接。
- **暂停期间的 callstack 异步路径**：客户端在 `HandleMessage` 中收到 `RequestCallStack` 不会立即应答，而是把 socket 加入 `CallstackRequests`；只有当 `bIsPaused == true`（脚本停在 line callback 的 `PauseExecution` while 循环里）时才走 `SendCallStack`——因为只有暂停时才有"当前活跃 context"对应的栈。

---

## 二、启动入口与配置

### 2.1 命令行 / Config

DebugServer 由 `FAngelscriptEngineConfig::DebugServerPort` 驱动，从命令行读入：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngineConfig::FromCurrentProcess
// ============================================================================
FParse::Value(FCommandLine::Get(), TEXT("-asdebugport="), Config.DebugServerPort);
```

- 命令行 `-asdebugport=27099` → `DebugServerPort = 27099`
- 不指定 → 默认 `0`，**不创建** DebugServer（生产部署默认状态）
- `FAngelscriptStateDump::AddConfigValue("DebugServerPort", ...)` 会把当前端口录入状态导出，便于排查"为什么没启动"

值得注意的是：**没有专门的 CVar (`as.Debug...`) 来运行时切换**；`DebugServerPort` 是 process-life 的——这是有意为之，因为 DebugServer 的生命周期与 `FAngelscriptEngine` 绑定，跨重启切换风险高。

### 2.2 创建时机与门控

服务器对象在 `FAngelscriptEngine::Initialize` 中按下列条件创建：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::Initialize（节选）
// 性质: DebugServer 创建条件
// ============================================================================
#if WITH_AS_DEBUGSERVER
if ((!bUsePrecompiledData || bScriptDevelopmentMode) && FApp::HasProjectName())
    DebugServer = new FAngelscriptDebugServer(this, RuntimeConfig.DebugServerPort);
#endif
```

- **`WITH_AS_DEBUGSERVER`** 编译期开关——shipping 默认关闭
- **`!bUsePrecompiledData || bScriptDevelopmentMode`**：cooked + StaticJIT 路径下默认不开（除非显式 `-as-development-mode`），因为 cooked 通常没有源码，调试无意义
- **`FApp::HasProjectName()`**：避免在工具模式（无 Project）下绑端口

构造函数本身只做：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer 构造函数
// ============================================================================
Listener = new FTcpListener(FIPv4Endpoint(FIPv4Address::Any, Port));
Listener->OnConnectionAccepted().BindRaw(this, &FAngelscriptDebugServer::HandleConnectionAccepted);
#if PLATFORM_WINDOWS && WITH_AS_DEBUGSERVER
DataBreakpoint_Windows::GActiveDebugServer.Store(this);
DataBreakpoint_Windows::DegbugRegisterExceptionHandlerHandle =
    ::AddVectoredExceptionHandler(0, DataBreakpoint_Windows::DebugRegisterExceptionHandler);
#endif
```

- `FIPv4Address::Any`——默认监听所有接口；远程调试无认证（所以 `Plan_DebugAdapter` 明确说"远程调试不在范围内"）
- Vectored Exception Handler 注册一次，用于 Windows 硬件 data breakpoint（详见 §六）
- **没有线程**——所有 socket I/O 由 `Tick` 在 game thread 上推进，避免 AS 引擎线程同步问题

### 2.3 测试入口

测试模块走的是 `InitializeForTesting()` 路径，独立分配端口（避免与开发者的 27099 冲突）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::InitializeForTesting（节选）
// ============================================================================
#if WITH_AS_DEBUGSERVER
DebugServer = new FAngelscriptDebugServer(this, RuntimeConfig.DebugServerPort);
#endif
```

`AngelscriptDebuggerTestSession` 通过 `MakeUniqueDebugServerPort()` 申请高端口；`Plan_DisabledTestReenablement` 记录了一次回归——曾经此处漏判导致 28 个 Debugger 测试因 `DebugServer == nullptr` 失败。

---

## 三、AS 引擎钩子：line callback 三段门

DebugServer 与 AS 内核耦合的唯一通道是 **line callback**——`asCContext` 在每个语句边界（`asBC_SUSPEND` 字节码）有机会回调用户函数。

### 3.1 钩子安装：每个 context 配一对回调

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: CreateConfiguredContext / CreateContext（节选）
// ============================================================================
auto* Context = static_cast<asCContext*>(ScriptEngine->CreateContext());
Context->SetExceptionCallback(asFUNCTION(LogAngelscriptException), 0, asCALL_CDECL);
#if WITH_AS_DEBUGVALUES || WITH_AS_DEBUGSERVER
Context->SetLineCallback(AngelscriptLineCallback);                // ★
Context->SetStackPopCallback(AngelscriptStackPopCallback);        // ★
#endif
```

每个新建的 `asCContext`（包含 `GameThreadTLD->primaryContext` 与 thread-local 池中的所有 context）都装上这两个回调。`AngelscriptLineCallback` 是真正调用 `DebugServer->ProcessScriptLine` 的入口；`AngelscriptStackPopCallback` 用来在栈帧弹出时检查"data breakpoint 监视的栈变量是不是出栈了"。

### 3.2 三段静态门控

注意：**直接每个语句都回 callback 太慢**——AS 引擎内部用了三个静态布尔变量做层级门控：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.cpp::ExecuteNext
// 节选自: asBC_SUSPEND 指令处理
// ============================================================================
case asBC_SUSPEND:
    if (CanEverRunLineCallback) {                                 // ★ 第 1 道
        if (ShouldAlwaysRunLineCallback ||                        // ★ 第 2 道
            (m_currentFunction->module && m_currentFunction->module->hasBreakPoints)) {  // ★ 第 3 道
            if (m_lineCallback) {
                /* save program/stack pointers */
                m_lineCallback(this);
            }
        }
    }
    break;
```

- **`CanEverRunLineCallback`**（静态全局）：若没有任何调试器 / Coverage / DebugValues 启用，整个分支被跳过——`asBC_SUSPEND` 退化为 1-2 条指令的开销。
- **`ShouldAlwaysRunLineCallback`**（静态全局）：`bBreakNextScriptLine` 期间或 `Coverage` 开启时为 true——绕过模块级 hasBreakPoints 检查，捕获每一行。
- **`m_currentFunction->module->hasBreakPoints`**（per-module）：只有当某模块被 `SetBreakpoint` 标过，才在该模块的字节码里去做断点匹配。

`UpdateLineCallbackState` 是这两个静态变量的唯一写入处：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::UpdateLineCallbackState
// ============================================================================
bool bEverRunLineCallback   = false;
bool bAlwaysRunLineCallback = false;
#if WITH_AS_DEBUGSERVER
if (DebugServer != nullptr) {
    if (DebugServer->bIsDebugging)               bEverRunLineCallback   = true;  // 客户端在调试
    if (DebugServer->DataBreakpoints.Num() != 0) bEverRunLineCallback   = true;  // 有数据断点
    if (DebugServer->bBreakNextScriptLine)       bAlwaysRunLineCallback = true;  // 单步 / 暂停
}
#endif
#if WITH_AS_COVERAGE                                                              // ★ Coverage 也借 hook
if (CodeCoverage != nullptr) { bEverRunLineCallback = true; bAlwaysRunLineCallback = true; }
#endif
asCContext::CanEverRunLineCallback     = bEverRunLineCallback;
asCContext::ShouldAlwaysRunLineCallback = bAlwaysRunLineCallback;
```

每次状态改变（StartDebugging、StepIn、SetBreakpoint、StopDebugging、ClearBreakpoints……）都必须显式调用一次 `UpdateLineCallbackState`——这是性能与正确性的接缝。

### 3.3 line callback 主体：`AngelscriptLineCallback`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: AngelscriptLineCallback（节选）
// ============================================================================
void AngelscriptLineCallback(asCContext* Context) {
    if (!IsInGameThread()) return;                          // ★ 只在 game thread 工作
    if (GAngelscriptLineReentry) return;                    // 防止 callback 中调脚本递归
    GAngelscriptLineReentry = true;
    // ... DebugValues stack 维护（与 DebugServer 解耦的另一条独立路径）
#if WITH_AS_DEBUGSERVER
    if (auto* DebugServer = AngelscriptManager.DebugServer)
        DebugServer->ProcessScriptLine(Context);            // ★ 关键调用
#endif
#if WITH_AS_COVERAGE
    /* CodeCoverage->HitLine(...) */
#endif
    GAngelscriptLineReentry = false;
}
```

非 game thread 直接放过——避免 worker thread 上跑脚本时多线程访问 `Clients[]`。这意味着**异步任务里跑的 AS 脚本是无法被该调试器拦下来的**（一个有意识的折衷）。

---

## 四、断点：file:line 到字节码的匹配

### 4.1 数据结构

DebugServer 维护两组并行的索引，各承担一种查找方向：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.h
// 节选自: FAngelscriptDebugServer 数据成员（断点相关）
// ============================================================================
struct FFileBreakpoints {
    TSharedPtr<FAngelscriptModuleDesc> Module;          // ★ 哪个模块
    TSet<int32>                       Lines;            // 断点行号集合
    TMap<int32, FString>              Conditions;       // line → 条件表达式
};
int32                                            BreakpointCount = 0;
TMap<FString, TSharedPtr<FFileBreakpoints>>      Breakpoints;        // ModuleName / Filename → ...
TMap<const char*, TSharedPtr<FFileBreakpoints>>  SectionBreakpoints; // section* → 共享同一 FFileBreakpoints
```

- `Breakpoints` 用 `FString`（ModuleName，否则 fallback 到 Filename）作为 key——客户端可能按模块名也可能按文件名设断点。
- `SectionBreakpoints` 用 `const char*` 指针作为 key（指向 AS 引擎内部 section 名的字符串地址）——line callback 中 `Context->GetLineNumber(0, nullptr, &Section)` 直接拿到一个 `const char*`，按指针比对避免每行做 string copy。
- 两个 map 共享同一个 `TSharedPtr<FFileBreakpoints>`，断点的增删只在 `Breakpoints` 一处修改，`SectionBreakpoints` 是 lazy-bind 的指针缓存。

### 4.2 SetBreakpoint：行号对齐 + 模块标记

客户端送来 `Filename + LineNumber + ModuleName + Condition + Id`；服务端做四件事：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: HandleMessage(SetBreakpoint)（节选）
// ============================================================================
BP.Filename = CanonizeFilename(BP.Filename);              // \\ → /
auto ModuleDesc = Manager.GetModuleByFilenameOrModuleName(BP.Filename, BP.ModuleName);
const FString& Key = ModuleDesc.IsValid() ? ModuleDesc->ModuleName : BP.Filename;
TSharedPtr<FFileBreakpoints>& Active = Breakpoints.FindOrAdd(Key);
// ...
asCModule* FoundModule = (asCModule*)ModuleDesc->ScriptModule;
FoundModule->hasBreakPoints = true;                       // ★ 打开模块级 hasBreakPoints
int32 BestLine = -1;
for (asCScriptFunction* Func : FoundModule->scriptFunctions) {
    int32 LineInFunc = Func->FindNextLineWithCode(WantedLine);
    if (LineInFunc >= WantedLine && (BestLine == -1 || LineInFunc < BestLine))
        BestLine = LineInFunc;
}
if (BestLine != -1) CodeLine = BestLine;                  // ★ 对齐到下一条可执行行
// ...
if (CodeLine != -1 && !bDuplicate) {
    Active->Lines.Add(CodeLine);
    Active->Conditions.Add(CodeLine, BP.Condition);       // 可选条件
    BreakpointCount += 1;
    if (CodeLine != WantedLine && BP.Id != -1) {
        // 行号被对齐了，回送一个 SetBreakpoint 通知客户端真实落点
        FAngelscriptBreakpoint ChangedBP = ...;
        SendMessageToClient(Client, EDebugMessageType::SetBreakpoint, ChangedBP);
    }
}
```

关键点：

- **行号对齐**：用户在空行 / 注释行设的断点会自动 snap 到下一条可执行字节码所在的行。`asCScriptFunction::FindNextLineWithCode` 是 AS 内核扫字节码 LineCue 表的辅助函数。
- **重设的反向通告**：当 `BP.Id != -1` 且 `CodeLine != WantedLine`，服务器回送一条 `SetBreakpoint` 消息（同一 message type 双向）携带新行号——客户端据此把 IDE 中的小红点滑到真实落点。
- **`hasBreakPoints` 翻 true**：这一步翻开模块级门，让 `asBC_SUSPEND` 在该模块字节码里开始触发 line callback。
- **Condition 表达式**：可选，触发后由 `EvaluateConditionalBreakpoint` 在 `ProcessScriptLine` 中现场求值（详见 §4.4）。

### 4.3 ProcessScriptLine：命中判断主流程

每行字节码触发后，`ProcessScriptLine` 是仲裁中心：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ProcessScriptLine（节选，命中分支）
// ============================================================================
if (!bIsDebugging) return;
if (bIsPaused) return;
if (IsEngineExitRequested()) return;
ProcessMessages();                                        // ★ 先收一轮客户端消息

if (bBreakNextScriptLine) {
    bool bShouldBreak = true;
    // StepOver/StepOut 用 ConditionBreakFrame + ConditionBreakFunction 进一步过滤
    if (ConditionBreakFrame != -1 && ConditionBreakFunction != nullptr) {
        int32 CallstackSize = Context->GetCallstackSize();
        int32 CheckFrame = CallstackSize - ConditionBreakFrame - 1;
        if (CheckFrame > 0 && Context->GetFunction(CheckFrame) == ConditionBreakFunction)
            bShouldBreak = false;                         // ★ 还在原函数 / 子调用，跳过
    }
    if (bShouldBreak) { bIsPaused = true; bBreakNextScriptLine.Store(false); /*...*/ }
}
else if (BreakpointCount > 0
        && Context->m_currentFunction->module->hasBreakPoints) {
    const char* Section; int32 Line = Context->GetLineNumber(0, nullptr, &Section);
    /* SectionBreakpoints[Section] lazy-bind */
    if (ActiveBreakpoints->Lines.Contains(Line) && !bWasIgnored) {
        // 条件断点求值
        bool bConditionAllowsBreak = true;
        if (auto* Cond = ActiveBreakpoints->Conditions.Find(Line))
            bConditionAllowsBreak = EvaluateConditionalBreakpoint(*this, Context, *Cond, ...);
        if (bConditionAllowsBreak && ShouldBreakOnActiveSide()) {
            bIsPaused = true;                             // ★ 命中
            IgnoreBreakLine = Line; IgnoreBreakSection = Section;
        }
    }
}

if (bIsPaused) {
    FStoppedMessage StopMsg;
    StopMsg.Reason = bWasPause ? "pause" : (bWasStep ? "step" : "breakpoint");
    PauseExecution(&StopMsg);                             // ★ 阻塞循环 + 通告 HasStopped
}
```

几个隐式约定：

- **优先级**：`bBreakNextScriptLine`（单步 / Pause 主动请求）优先于"普通断点匹配"——单步过程中即使经过断点行也不重复触发"breakpoint" reason。
- **IgnoreBreakLine / IgnoreBreakSection**：用户 Continue 后，**同一行不会立即第二次命中**——`IgnoreBreak*` 记录当前行，下一次 line callback 不在同一行触发；移行后清除。
- **`ShouldBreakOnActiveSide`**：通过 `BreakOptions` 配合 `GetDebugCheckBreakOptions` hook 判断"PIE 多人模式下，break 是否只在 server / client / authority 发生"，避免双客户端调试相互打架。

### 4.4 条件断点 EvaluateConditionalBreakpoint

支持 `==` / `!=` / `>` / `>=` / `<` / `<=` 六个运算符，操作数可以是字面量（int / bool / 字符串）或调试器 Path 表达式（自动加 `0:` 前缀走 frame=0 的局部变量）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: EvaluateConditionalBreakpoint（节选）
// ============================================================================
ParseConditionalBreakpointOperator(Cond, LeftOp, Op, RightOp);
TryResolveConditionalBreakpointValue(*this, Context, LeftOp,  LeftValue);   // 字面量 or DebuggerValue
TryResolveConditionalBreakpointValue(*this, Context, RightOp, RightValue);
// 数值运算 / 字符串相等比较
```

求值失败（找不到符号 / 不支持的算符）会 `UE_LOG(Warning)` 并默认 `bConditionAllowsBreak=true`——**宁可多停，不可少停**。

### 4.5 ClearBreakpoints / ClearAllBreakpoints

按文件清除：清空 `Active->Lines` 与 `Conditions`、把对应 module 的 `hasBreakPoints=false`。`StartDebugging` 第一个客户端到达时也会调用 `ClearAllBreakpoints`——避免上一会话残留。

---

## 五、单步执行：StepIn / StepOver / StepOut 的字节码语义

三种单步在 wire 上是三条独立消息，但内部状态机只用两个变量编码：`bBreakNextScriptLine` + `(ConditionBreakFrame, ConditionBreakFunction)`。

### 5.1 三种单步的状态写入

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: HandleMessage(StepIn / StepOver / StepOut)
// ============================================================================
// ── StepIn：下一行就停（无论进函数还是同帧）
case StepIn:
    bBreakNextScriptLine = true;
    ConditionBreakFrame = -1; ConditionBreakFunction = nullptr;
    UpdateLineCallbackState();

// ── StepOver：下一行停，但若进入了子函数（调用栈变深）则跳过
case StepOver:
    bBreakNextScriptLine = true;
    int32 CallstackSize = Context->GetCallstackSize();
    ConditionBreakFrame    = CallstackSize - 1;             // ★ 当前帧深度
    ConditionBreakFunction = Context->GetFunction(0);       // 当前函数指针
    UpdateLineCallbackState();

// ── StepOut：跳出当前函数到调用者的下一行
case StepOut:
    if (Context->GetCallstackSize() >= 2) {
        bBreakNextScriptLine = true;
        ConditionBreakFrame    = CallstackSize - 2;         // 父帧深度
        ConditionBreakFunction = Context->GetFunction(1);   // 父函数指针
    } else {
        bBreakNextScriptLine = false;                       // 顶层函数 → 直接跑完
    }
    UpdateLineCallbackState();
```

### 5.2 ProcessScriptLine 的"跳过"判定

回看 §4.3 的 `bBreakNextScriptLine` 分支——核心判断是：

```text
CallstackSize = Context->GetCallstackSize();
CheckFrame    = CallstackSize - ConditionBreakFrame - 1;
if (CheckFrame > 0 && Context->GetFunction(CheckFrame) == ConditionBreakFunction)
    bShouldBreak = false;     // 还在原函数的"子调用"中（栈更深），不停
```

- **StepIn**：`ConditionBreakFrame = -1` → 上面的 `if` 不成立 → 永远 `bShouldBreak = true` → 每行都停。
- **StepOver**：`ConditionBreakFrame = CallstackSize - 1`（= 当时的"自己")。如果之后进了子函数，`CallstackSize` 变大 → `CheckFrame > 0` → 比较 `GetFunction(CheckFrame)` 是不是当时的函数——如果是，说明仍在原函数发起的子调用，跳过；如果不是（典型：单步退出原函数后调用方），停下。
- **StepOut**：`ConditionBreakFrame = CallstackSize - 2`（= 父帧）。逻辑同上——只要还在原父函数及其子调用中就跳过；当回到父函数的祖父帧才停。
- **顶层 StepOut**：`bBreakNextScriptLine = false` 直接收手——避免在脚本入口外侧再触发不存在的"父帧"。

### 5.3 与 IgnoreBreakLine 协同

stepping 完成后，`ProcessScriptLine` 在 `bIsPaused = true` 设置 `IgnoreBreakLine` / `IgnoreBreakSection`——下一次 Continue 后即使原行号有断点也不会立即重停，避免"按下 F10 死循环"。

### 5.4 测试覆盖

`AngelscriptDebuggerSteppingTests.cpp`（~1260 行）覆盖的场景：

- `StepIn` / `StepOver` / `StepOut` 基本路径
- 跨文件跨模块单步（`CrossFileSteppingFixture`）
- StepOut 顶层帧不重停（`StartActionThenExpectCompletionMonitor`）
- StepOver 在循环、分支、嵌套调用中的边界
- 单步过程中触发其他断点的优先级

详见 §九 "VS Code 客户端配置" 末尾的 "测试矩阵速查"。

---

## 六、调用栈、变量与表达式求值

### 6.1 SendCallStack：脚本帧 + Blueprint 帧交错

`Context->GetCallstackSize()` / `Context->GetFunction(i)` 给出 AS 的调用链，但插件还要把 Blueprint 帧（如果开了 `DO_BLUEPRINT_GUARD`）插进去——形成"AS 调脚本调 BP 调 AS"那种夹心栈：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::SendCallStack（节选）
// ============================================================================
for (int32 i = StackSize-1; i >= 0; --i) {
    auto* ScriptFunction = (asCScriptFunction*)Context->GetFunction(i);
    FAngelscriptCallFrame Frame;
#if DO_BLUEPRINT_GUARD
    int BPFrame = Context->GetBlueprintCallstackFrame(i);
    for (; BPStackIndex < BPFrame; ++BPStackIndex) {
        UFunction* Function = BPStack->GetCurrentScriptStack()[BPStackIndex]->Node;
        if (IsAngelscriptGenerated(Function)) continue;        // 跳过 AS 生成的 thunk
        Frame.Name   = FString::Printf(TEXT("(BP) %s"), ...);
        Frame.Source = FString::Printf(TEXT("::%s"), ...);
        Stack.Frames.Insert(Frame, 0);
    }
#endif
    if (ScriptFunction->traits.GetTrait(asTRAIT_GENERATED_FUNCTION)) continue;
    if (ScriptFunction->GetFuncType() == asFUNC_SYSTEM) {
        Frame.Name = FString::Printf(TEXT("(C++) %s"), ...);    // C++ 注册的 system 函数
    } else {
        Frame.Name       = ANSI_TO_TCHAR(ScriptFunction->GetName());
        Frame.LineNumber = Context->GetLineNumber(i, nullptr, &SectionName);
        Frame.Source     = ANSI_TO_TCHAR(SectionName);
        if (DebugAdapterVersion >= 1)
            Frame.ModuleName = ANSI_TO_TCHAR(ScriptFunction->GetModuleName());
    }
    Stack.Frames.Insert(Frame, 0);
}
```

发送时机：`HandleMessage(RequestCallStack)` 把 socket 加入 `CallstackRequests`，等到 `bIsPaused` 状态稳定后由 `ProcessMessages` 末尾批量回送——保证回的栈是"暂停时刻"的快照。

`asTRAIT_GENERATED_FUNCTION` 是 ClassGenerator 给 getter / setter / thunk 函数打的标记，调试栈里跳过这些"机器生成"的桥接函数让用户视角更干净。

### 6.2 变量观察：Path → Address → FDebuggerValue

**Path 语法**：`{Frame}:{Variable}.{Member}.{Member}`，例如 `0:Owner.Name`。可选前缀：

- `%local%` → 当前帧所有局部变量（scope 形式）
- `%this%` → 当前帧 this 对象（scope 形式）
- `%module%` → 当前 module 的全局变量（scope 形式）

`GetDebuggerValue` / `GetDebuggerScope` 实现拆分如下：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::GetDebuggerValue（节选，主路径）
// ============================================================================
TGuardValue<bool> ScopeEvaluateWatch(bIsEvaluatingDebuggerWatch, true);  // ★ 标记"正在求值"
// 1) 解析 Frame:Path 拆分
LexFromString(Frame, *Path.Left(ColonIndex)); NamePath = Path.RightChop(ColonIndex+1);
Frame = ResolveDebuggerFrame(Frame);          // 把 IDE frame 编号映射到 AS / BP 真实帧
ParseExpression(Expr, NamePath);              // ".Owner.Components[0].Name" → tokens

// 2) 第一个 token 在 frame 范围中查找：local → this → module → global
auto* Context = (asCContext*)asGetActiveContext();
// ── Local
int32 VarCount = Context->GetVarCount(Frame);
for (...) if (VarName matches Expr[0]) {
    auto Usage = FAngelscriptTypeUsage::FromTypeId(Context->GetVarTypeId(i, Frame));
    if (Usage.GetDebuggerValue(Context->GetAddressOfVar(i, Frame), CurrentValue))
        bValidValue = true;
}
// ── this
if (!bValidValue) { /* Context->GetThisPointer(Frame) → Usage.GetDebuggerMember */ }
// ── module global
if (!bValidValue) { /* Module->GetAddressOfGlobalVar / GetDebuggerMember */ }

// 3) 后续 token：依赖 FDebuggerValue 上一步的 Address 走 GetDebuggerMember
for (int32 i = 1; i < Expr.Num(); ++i) {
    if (CurrentValue.Usage.GetDebuggerMember(CurrentValue.Address, Expr[i].Name, Next))
        CurrentValue = MoveTemp(Next);
}
```

`FAngelscriptType::GetDebuggerValue` / `GetDebuggerScope` / `GetDebuggerMember` 是 `Bind_*.cpp` 各类型自定义的虚函数族（`Bind_BlueprintType.cpp` / `Bind_TArray.cpp` / `Bind_TMap.cpp` / `Bind_TSet.cpp` / `Bind_TOptional.cpp` / `Bind_FName.cpp` / `Bind_Delegates.cpp` 等都覆写）。这层抽象让"变量怎么展开成 children" 的策略写在类型族那侧，而不是堆在 DebugServer 里。

### 6.3 FDebuggerValue 的内存视图

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptType.h
// 节选自: struct FDebuggerValue
// ============================================================================
struct FDebuggerValue {
    FString Name, Type, Value;
    FAngelscriptTypeUsage Usage;
    void* Address = nullptr;
    bool bHasMembers = false;
    TArray<uint8>          LiteralValue;     // ★ 临时构造值的内联存储
    FAngelscriptTypeUsage  LiteralType;
    bool   bTemporaryValue = false;
    void*  NonTemporaryAddress = nullptr;    // ★ 临时值的"真正存储"
    void*  AddressToMonitor = nullptr;       // ★ data breakpoint 监视地址
    int    AddressToMonitorValueSize = 0;
    void* GetAddressToMonitor() const;       // 优先取 AddressToMonitor，其次 NonTemporaryAddress
    int   GetAddressToMonitorValueSize() const;
};
```

- **`bTemporaryValue` + `NonTemporaryAddress`**：表达式求值产生的临时（如 `arr[0]` 返回的临时副本）保留对原始存储的指针——data breakpoint 才能落到"原值"的物理地址，而不是临时栈位。
- **`LiteralValue`**：值类型展开 children 时需要先在调试器侧物化一份副本（Align 16 字节），用 `AllocateLiteral` / `ClearLiteral` 配对管理生命周期。

### 6.4 RequestEvaluate / RequestVariables 应答

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: HandleMessage(RequestVariables / RequestEvaluate)（节选）
// ============================================================================
case RequestVariables: {
    *Datagram << Path;
    FAngelscriptVariables Vars; FDebuggerScope Scope;
    if (GetDebuggerScope(Path, Scope))
        for (auto& V : Scope.Values) {
            FAngelscriptVariable W;
            W.Name = V.Name; W.Value = V.Value; W.Type = V.Type;
            W.ValueAddress = (uint64)V.GetAddressToMonitor();   // ★ v2 才有
            W.ValueSize    = V.GetAddressToMonitorValueSize();
            W.bHasMembers  = V.bHasMembers;
            Vars.Variables.Add(W);
        }
    SendMessageToClient(Client, EDebugMessageType::Variables, Vars);
}
```

这里有个"为什么变量地址要回给客户端"的微妙之处：客户端可以基于 `ValueAddress + ValueSize` 主动发起 `SetDataBreakpoints`，把"Watch 一个具体内存位置变化"做成 IDE 的右键菜单——服务端拿到地址后通过 Windows 硬件 DR0–DR3 寄存器装上写断点。

### 6.5 数据断点：硬件 DRx 寄存器（Windows）

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: DataBreakpoint_Windows::DebugRegisterExceptionHandler（节选）
// ============================================================================
LONG WINAPI DebugRegisterExceptionHandler(EXCEPTION_POINTERS* ExceptionInfo) {
    if (ExceptionInfo->ExceptionRecord->ExceptionCode == EXCEPTION_SINGLE_STEP
        && (ExceptionInfo->ContextRecord->Dr6 & 0xF) > 0) {
        // 哪一号 DR 触发了？查 Dr6 低 4 位
        for (uint8 i = 0; i < DATA_BREAKPOINT_HARDWARE_LIMIT; i++) {
            if ((Dr6 & (0x1 << i)) == 0) continue;
            auto& Breakpoint = DebugServer->ActiveDataBreakpoints[i];
            // HitCount > 0：递减；到 0 时标记 Remove_ReachedHitCount + bTriggered
            // 否则直接 bTriggered=true
            Breakpoint.SetContext(asGetActiveContext());
        }
        DebugServer->bBreakNextScriptLine.Store(true);          // ★ 推迟到下一个脚本行处理
        OwnerEngine->UpdateLineCallbackState();
        return EXCEPTION_CONTINUE_EXECUTION;
    }
    return EXCEPTION_CONTINUE_SEARCH;
}
```

要点：

- **硬件限制 4 个**：`DATA_BREAKPOINT_HARDWARE_LIMIT = 4`（Intel x86 / x86_64 只有 DR0–DR3）。多设的 data breakpoint 进入 `DataBreakpoints[]` 但不上寄存器，等空位释放再 promote 到 active。
- **延迟到 line callback**：异常 handler 不安全做堆分配，`bBreakNextScriptLine = true` 推迟到下一个 `asBC_SUSPEND` 触发的 `ProcessScriptLine` 中产生 `FStoppedMessage` 与广播。
- **C++ 断点支持**：`bCppBreakpoint = true` 的 entry 命中时 `UE_DEBUG_BREAK()`——便于在 C++ debugger 中同步停。
- **softlock 救生圈**：`ClearAllAngelscriptDataBreakpointsFromHandler()` 是个 `ANGELSCRIPTRUNTIME_API` 的全局函数，可以从 Visual Studio Immediate Window 调用，强制清空所有 active data breakpoint——避免一个高频写的内存位置把调试器卡死在 spam break。
- **Stack pop 联动**：`AngelscriptStackPopCallback` 检测出栈帧地址与 `Breakpoint.Address` 重叠时把 `Status = Remove_OutOfScope` —— 监视的栈变量随作用域消失，自动清断点而不是变成"对一段空闲内存的写"乱报。

非 Windows 平台没有这条 hardware path，data breakpoint 客户端发过来会被静默接收但不实际生效。

---

## 七、多客户端、多 Engine 与 Pause 状态机

### 7.1 多客户端同时 attach

`Clients[]` 与 `ClientsThatAreDebugging` 是两个独立列表：

- 任何 socket 连上来都进入 `Clients[]`——可以纯收发 `Diagnostics` / `RequestDebugDatabase`（语言服务用法），不必发 `StartDebugging`。
- 发了 `StartDebugging` 才进 `ClientsThatAreDebugging`——这才参与暂停 / 单步 / 断点流程。

广播策略：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.h
// 节选自: SendMessageToAll（模板函数）
// ============================================================================
for (auto* Client : Clients) {                    // ★ 注意：是 Clients，不是 ClientsThatAreDebugging
    QueuedSends.FindOrAdd(Client).Emplace_GetRef().Buffer = Buffer;
    TrySendingMessages(Client);
}
```

`HasStopped` / `HasContinued` / `Diagnostics` / `ReplaceAssetDefinition` 等一律广播到所有连接客户端——**多 IDE 同时连同一个 UE 进程，都看见暂停**。这意味着：

- 第一个发 `StartDebugging` 的客户端会触发 `ClearAllBreakpoints` 与 `BreakOptions` reset；后续 `StartDebugging` 不重置（避免互相踩）。
- 所有调试客户端共享一份"全局断点表"——某客户端设的断点其他客户端也会看到 stop，但只有自己设的断点会带 `Id` 回送。
- `StopDebugging` 只把当前客户端从 `ClientsThatAreDebugging` 移除；但若它是最后一个 → `bIsDebugging = false` + `ClearAllBreakpoints`。

`RemoveClientState` 是中央清理函数：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::RemoveClientState（节选）
// ============================================================================
ClientsThatAreDebugging.RemoveSwap(Client);
ClientsThatWantDebugDatabase.RemoveSwap(Client);
CallstackRequests.RemoveSwap(Client);
QueuedSends.Remove(Client);
if (bResetDebugStateIfLastDebuggingClient && ClientsThatAreDebugging.Num() == 0) {
    bIsDebugging = false; bPauseRequested = false; bIsPaused = false;
    bBreakNextScriptLine = false;
    ClearAllBreakpoints();
    OwnerEngine->UpdateLineCallbackState();           // ★ 关闭 line callback 门
}
```

### 7.2 PauseExecution：阻塞循环 + 心跳泵送

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::PauseExecution
// ============================================================================
bIsPaused = true;
SendMessageToAll(EDebugMessageType::HasStopped, *StopMessage);
asCContext* Context = (asCContext*)asGetActiveContext();
Context->m_loopDetectionTimer = -1.0;             // ★ 暂停期间不计入 timeout
const double PauseDeadline = MaxPauseTimeoutSeconds > 0.0f
    ? FPlatformTime::Seconds() + MaxPauseTimeoutSeconds : 0.0;
while (bIsPaused) {
    if (PauseDeadline > 0.0 && now >= PauseDeadline) {
        UE_LOG(Warning, "PauseExecution auto-resuming after %.1f s safety timeout");
        bIsPaused = false; break;
    }
    ProcessMessages();                            // ★ 阻塞期间继续泵送
    FPlatformProcess::Sleep(0);                   // 让出 CPU
}
SendMessageToAll(EDebugMessageType::HasContinued, ContinueMsg);
```

要点：

- **同步阻塞 game thread**——这是"调试器一停整个 UE 进程也停"的根因；编辑器 UI 会卡住，预期内。
- **`m_loopDetectionTimer = -1.0`**：AS 引擎本来有"一个 context 跑超过 N 秒就强行 abort"的循环检测，调试期间必须关掉，否则停太久会被自杀。
- **`MaxPauseTimeoutSeconds`**：测试基础设施用——headless 自动化环境下若客户端断连或测试逻辑出错，避免 game thread 永久卡死。生产代码不设 timeout（默认 0）。
- **`ProcessMessages`** 在循环里继续跑——这就是为什么 `Continue` / `RequestCallStack` / `RequestVariables` / `Step*` 都能在暂停期间送达并立即处理。

### 7.3 多 Engine 实例：每个 Engine 一个 DebugServer

`FAngelscriptDebugServer` 持有 `OwnerEngine` 指针，所有 hook 调用都带上 owner：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ShouldBreakOnActiveSide
// ============================================================================
UObject* WorldContext = OwnerEngine != nullptr ? OwnerEngine->GetCurrentWorldContextObject() : nullptr;
auto& Delegate = OwnerEngine != nullptr
    ? OwnerEngine->GetHooks().GetDebugCheckBreakOptions()
    : FAngelscriptEngine::Get().GetHooks().GetDebugCheckBreakOptions();
return Delegate.IsBound() ? Delegate.Execute(BreakOptions, WorldContext) : true;
```

这层 owner-aware 设计支持：

- **PIE 多客户端**：每个 PIE 实例可能有自己的 `FAngelscriptEngine`（取决于 GameInstance 子系统），互不干扰各自的 DebugServer
- **Test 多 Engine**：`AngelscriptDebuggerTestSession` 创建独立 engine + 独立端口，跑并行测试不冲突
- **`AngelscriptEngineHooksTests::DebugServerCallSitesUseCurrentEngineHooks`**：明确测试"`ShouldBreakOnActiveSide` 应该用 OwnerEngine 的 hooks 而不是全局单例"——历史 bug 修复

### 7.4 `bIsEvaluatingDebuggerWatch` 重入护栏

变量求值过程中可能调用脚本中的 getter / property accessor——这些调用会再次触发 line callback。`bIsEvaluatingDebuggerWatch` 是 `TGuardValue` 在 `GetDebuggerValue` 入口设置的标志，外界（如 `EngineUpdateLineCallbackState`）可以查询它来跳过本次回调，避免"watch 一个属性导致再停一次"的递归。

---

## 八、与 HotReload / StaticJIT / Coverage 的协同

### 8.1 HotReload：ReapplyBreakpoints

热重载会重新构造 `asCModule`，原模块对象被替换。`PerformHotReload` 末尾：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::PerformHotReload（节选）
// ============================================================================
#if WITH_AS_DEBUGSERVER
if (DebugServer != nullptr)
    DebugServer->ReapplyBreakpoints();        // ★ 重新绑模块 + 翻 hasBreakPoints
#endif
```

`ReapplyBreakpoints` 遍历 `Breakpoints[ModuleName]` 表，重新查找当前 `FAngelscriptModuleDesc`，并把 `asCModule::hasBreakPoints` 翻 true：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ReapplyBreakpoints
// ============================================================================
for (auto& Elem : Breakpoints) {
    auto FileBreakpoints = Elem.Value;
    if (FileBreakpoints->Lines.Num() == 0) {
        FileBreakpoints->Module = nullptr;
    } else {
        auto ModuleDesc = Manager.GetModuleByModuleName(Elem.Key);
        FileBreakpoints->Module = ModuleDesc;
        if (ModuleDesc.IsValid()) {
            asCModule* ScriptModule = (asCModule*)ModuleDesc->ScriptModule;
            ScriptModule->hasBreakPoints = true;     // ★
        }
    }
}
```

`SectionBreakpoints` 不在这里清——它是"section 字符串指针 → 共享 FFileBreakpoints"的缓存，section 指针在新模块加载后会变化，但 lazy lookup 在下次 `ProcessScriptLine` 中会重新填充。

**HotReload 期间 PauseExecution 的活性**：HotReload 仅在 game thread 的 `Tick` 中触发，但若调试器恰好 `PauseExecution` 把 game thread 阻塞在循环里——HotReload 永远不会启动。这是有意的：调试期间锁住编译流水线，防止"用户改文件 → 触发热重载 → 旧 asCModule 被替换 → callstack 上的 `Context->GetFunction(i)` 指向已释放内存"的悬挂。详见 `RT_HotReload.md` §三 "Tick 调度"。

### 8.2 StaticJIT：互斥而非协同

StaticJIT 路径下：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::Initialize（StaticJIT 启用分支节选）
// ============================================================================
Engine->SetEngineProperty(asEP_BUILD_WITHOUT_LINE_CUES, 1);  // ★ 不生成 asBC_SUSPEND
Engine->SetJITCompiler(StaticJIT);
```

这条 `asEP_BUILD_WITHOUT_LINE_CUES = 1` 让编译器**不在字节码中插入 `asBC_SUSPEND` 行号标记**——line callback 永远不会被触发。配合 cooked 默认条件 `!bUsePrecompiledData || bScriptDevelopmentMode`，结论是：

- **JIT 路径下没有断点**：JIT 函数指针被 `jitFunction` 直接调走，跳过 `ExecuteNext` 主循环，自然没有 `asBC_SUSPEND`
- **DebugServer 不创建**：除非用 `-as-development-mode` 强制开启 + 退化到解释器
- **Coverage 同样关闭**：`WITH_AS_COVERAGE` 与 StaticJIT 互斥

工程上的处理方式是"**开发态用解释器调试，发布态用 StaticJIT 提速**"，这也是为什么 `Plan_AS238JITv2Port` 的待补齐方向之一是"运行期 JIT 与调试共存"。

### 8.3 Coverage 协同

`WITH_AS_COVERAGE` 时 `CodeCoverage` 子系统也会请求 `ShouldAlwaysRunLineCallback = true`——line callback 同时承担"记录命中行号"与"调试器 stop 判定"两个职责。两者在 `AngelscriptLineCallback` 内顺序调用、互不干扰。

### 8.4 异常协同：ProcessException

当 AS 抛出未捕获异常，`asCContext::SetExceptionCallback` 走 `LogAngelscriptException`，后者再调 `DebugServer->ProcessException(Context)`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ProcessException
// ============================================================================
if (bIsPaused) return;                       // 已经停了，不重复
ProcessMessages();
if (!bIsDebugging) return;
FStoppedMessage StopMsg;
StopMsg.Reason = TEXT("exception");
StopMsg.Text   = ANSI_TO_TCHAR(Context->GetExceptionString());
PauseExecution(&StopMsg);                    // ★ 把异常呈现为 stop
```

这让 IDE 上的"Caught Exceptions"面板可以拦下未处理的脚本异常。

---

## 九、VS Code 客户端形态与 launch.json

### 9.1 当前现状

**插件本身不附带 VS Code 扩展或 DAP 适配器**——这是 `Plan_DebugAdapter.md` 标注的待补齐工作。但 wire 协议已稳定，外部社区或 fork（如 Hazelight）有现成实现可参考。

### 9.2 launch.json 形态（设计目标）

来自 `Plan_DebugAdapter.md` §4 的 schema 草案：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "angelscript",
            "request": "attach",
            "name": "Attach to UE Editor",
            "host": "127.0.0.1",
            "port": 27099,
            "scriptRoot": "${workspaceFolder}/Script"
        }
    ]
}
```

- **`type: angelscript`**：DAP 适配器在 `package.json::contributes.debuggers` 中注册的 type 名
- **`request: attach`**：永远是 attach（不 launch UE，因为 UE 的启动由 UAT 控制）
- **`host` / `port`**：与 UE 进程的 `-asdebugport=` 必须一致；默认 27099 是约定值
- **`scriptRoot`**：路径映射用——AS 调试服务器返回的 `Section` 字段是相对仓库根的路径（已被 `CanonizeFilename` 标准化为 `/`），客户端需要拼回本地绝对路径

### 9.3 启动 UE 进程的命令行示例

```bat
UnrealEditor.exe AngelscriptProject.uproject -asdebugport=27099 -as-development-mode
```

- `-asdebugport=27099`：启用 DebugServer，监听 27099
- `-as-development-mode`（可选）：cooked 构建里强制走解释器路径，便于在打包后的 build 上调试
- 多端口部署：Editor + dedicated server 同时调试 → 两端各自 `-asdebugport=27099` / `-asdebugport=27100`

### 9.4 协议握手序列（建议适配器实现顺序）

```text
Client → Server : StartDebugging { DebugAdapterVersion = 2 }
Server → Client : DebugServerVersion { DebugServerVersion = 2 }
Client → Server : RequestBreakFilters
Server → Client : BreakFilters { ["break:any","break:ensure",...] }
Client → Server : RequestDebugDatabase
Server → Client : DebugDatabaseSettings { ... }
Server → Client : DebugDatabase * N（分块的 JSON）
Server → Client : DebugDatabaseFinished
Client → Server : SetBreakpoint × 用户在 IDE 设的所有断点
... 进入正常会话
```

一旦 `bIsDebugging = true`，UE 端的 line callback 门启用、scripts 执行进入"逐行检查"模式。

### 9.5 测试矩阵速查

| 测试文件 | 行数 | 主要覆盖 |
|----------|------|---------|
| `AngelscriptDebuggerSmokeTests.cpp` | ~216 | Handshake、BreakFilters 往返 |
| `AngelscriptDebuggerSessionInfraTests.cpp` | ~283 | DebugAdapterVersion sentinel、连接超时、PingAlive |
| `AngelscriptDebuggerSessionTests.cpp` | ~339 | StartDebugging / StopDebugging 多客户端切换 |
| `AngelscriptDebuggerBreakpointTests.cpp` | ~959 | HitLine、ClearThenResume、行对齐、Conditional、BreakOptions 门 |
| `AngelscriptDebuggerSteppingTests.cpp` | ~1260 | StepIn/Over/Out、跨文件、顶层 StepOut、并发 stepping |
| `AngelscriptDebuggerPauseTests.cpp` | ~434 | Pause→停在下一行、Pause 期间 Continue/Step、超时 |
| `AngelscriptDebuggerEvaluationTests.cpp` | ~529 | RequestVariables、RequestEvaluate、`%local%`/`%this%`/`%module%` |
| `AngelscriptDebuggerDatabaseTests.cpp` | ~162 | DebugDatabase 的 JSON 形状 |
| `AngelscriptDebuggerDataBreakpointTests.cpp` | ~428 | Windows DRx、HitCount、OutOfScope、softlock 释放 |
| `AngelscriptDebuggerBindingTests.cpp` | ~664 | `FAngelscriptType::GetDebuggerValue` 各 bind 类型实现验证 |
| `AngelscriptDebuggerBlueprintFrameTests.cpp` | ~482 | DO_BLUEPRINT_GUARD 帧交错、BP `this` 求值 |

合计 ~5756 行测试，对应"一边修代码一边能本地跑回归"的安全网。

---

## 附录 A：EDebugMessageType 速查

| 消息 | 方向 | 触发后果（服务端） | 触发后果（客户端可见） |
|------|------|-------------------|----------------------|
| `StartDebugging` | C→S | `bIsDebugging=true` + 首次时 `ClearAllBreakpoints` + `UpdateLineCallbackState` | 收到 `DebugServerVersion` |
| `StopDebugging` | C→S | 客户端从 `ClientsThatAreDebugging` 移除；最后一个时 `bIsDebugging=false` | （无回送） |
| `Pause` | C→S | `bBreakNextScriptLine=true` + `bPauseRequested=true` | 下一行触发 `HasStopped(reason=pause)` |
| `Continue` | C→S | `bIsPaused=false` 解开 `PauseExecution` 循环 | `HasContinued` 广播 |
| `StepIn` | C→S | `bBreakNextScriptLine=true` + 清条件 | 下一行 `HasStopped(reason=step)` |
| `StepOver` | C→S | + `ConditionBreakFrame=cur` + `ConditionBreakFunction=cur` | 跳过子调用后 `HasStopped(step)` |
| `StepOut` | C→S | + 父帧条件；顶层 `bBreakNextScriptLine=false` | 父帧下一行 `HasStopped(step)` |
| `EngineBreak` | C→S | 暂停期间触发 `UE_DEBUG_BREAK()` 落到 C++ debugger | （C++ 调试器接管） |
| `SetBreakpoint` | C↔S | 行对齐 + `hasBreakPoints=true`；行变化时回送 `SetBreakpoint(LineNumber=新)` | IDE 中 BP 标记滑动 |
| `ClearBreakpoints` | C→S | 按文件清空 `Lines`+`Conditions` + `hasBreakPoints=false` | （无回送） |
| `SetDataBreakpoints` | C→S | 写入 `DataBreakpoints[]` + `RebuildActiveDataBreakpoints` + 写 DRx | （触发后异步） |
| `ClearDataBreakpoints` | C→S/S→C | 清空所有数据断点 | 触发删除时服务端反向通告 |
| `RequestCallStack` | C→S | 加入 `CallstackRequests`；暂停时批量回送 | `CallStack` 一个 envelope |
| `CallStack` | S→C | — | 渲染 stack frames |
| `RequestVariables` | C→S | `GetDebuggerScope(Path)` | `Variables` |
| `Variables` | S→C | — | 渲染 variable tree |
| `RequestEvaluate` | C→S | `GetDebuggerValue(Path, Frame)` | `Evaluate` |
| `Evaluate` | S→C | — | 渲染 expression result |
| `Diagnostics` | S→C | 编译错误 / 警告主动推 | 渲染到 Problems 面板 |
| `RequestDebugDatabase` | C→S | 标记 `ClientsThatWantDebugDatabase` + 序列化全量类型表 | `DebugDatabase` × N + `DebugDatabaseFinished` |
| `DebugDatabaseSettings` | S→C | 同步 `bAutomaticImports` 等编译选项 | 调整客户端编辑器/语法服务行为 |
| `BreakOptions` | C→S | 写入 `BreakOptions` Filter set | 影响 `ShouldBreakOnActiveSide` |
| `RequestBreakFilters` / `BreakFilters` | C→S/S→C | 通过 `GetDebugBreakFilters` hook 收集 filter 名 | IDE 渲染 break filter 列表 |
| `PingAlive` | S→C | 5 秒一次健康检查 | 客户端可忽略 |
| `Disconnect` | C→S | `Client->Close()` + `RemoveClientState(true)` | socket 断开 |
| `GoToDefinition` | C→S | `FSourceCodeNavigation::Navigate*`（仅 Editor + WITH_EDITOR） | 编辑器跳到对应符号 |
| `FindAssets` / `CreateBlueprint` / `ReplaceAssetDefinition` | C→S | 桥接 `FAngelscriptEditorDebugBridge` 委托 | 编辑器创建 BP / 替换 asset 定义 |

---

## 附录 B：常见问题与避坑

1. **"端口设了但客户端连不上"**：检查 `WITH_AS_DEBUGSERVER` 是否定义、检查 `bUsePrecompiledData` 是否在 cooked 路径阻断 DebugServer 创建（解决：加 `-as-development-mode`）。
2. **"打开了调试就卡顿"**：`bIsDebugging=true` 把 `CanEverRunLineCallback` 翻 true——所有模块的 `asBC_SUSPEND` 都会进入插件 hook（即使没断点也走一遍 `ProcessScriptLine`）。生产环境别长期 attach。
3. **"断点设了但不触发"**：模块没编译进当前 engine（检查 `GetModuleByFilenameOrModuleName` 返回是否有效）；或行号被 `FindNextLineWithCode` 对齐到了 `-1`（空行 / 注释 / 模板生成函数）；或 `ShouldBreakOnActiveSide` 被 hook 否决（多人模式过滤）。
4. **"StepOver 进了子函数"**：客户端发送 `StepOver` 时 `Context` 已经在 line callback 中——服务端取的是 callback 时刻的 `CallstackSize` 与 `GetFunction(0)`；如果客户端逻辑在 `HasStopped` 后未等到一帧就发 `StepOver`，可能取到错误的 `ConditionBreakFunction`。一般 DAP 适配器实现会 await `stopped` event 完整处理后再发 step。
5. **"data breakpoint 监视的栈变量乱报"**：`AngelscriptStackPopCallback` 应该自动把它标 `Remove_OutOfScope`——若没有，检查目标地址范围是否真的落入 `OldStackFrameStart..End`（栈是从高地址向低地址增长）。
6. **"调试一个高频脚本死循环"**：Visual Studio Immediate 调用 `ClearAllAngelscriptDataBreakpointsFromHandler()` 紧急释放 spam break；或调高 `MaxPauseTimeoutSeconds`（仅测试场景）。
7. **"HotReload 之后断点失效"**：`ReapplyBreakpoints` 仅根据 ModuleName 重绑——若文件名 / 模块名变了，需要重新 SetBreakpoint。`SectionBreakpoints` 在 lazy lookup 时自动重建，无需手工清理。
8. **"DebugDatabase 太大客户端 OOM"**：单条 envelope 上限 16 MB；类型超大时可在客户端流式累积 `DebugDatabase` 直到 `DebugDatabaseFinished`，不要一次性 allocate。
9. **"两个 PIE 客户端调试相互打断"**：用 `BreakOptions` 的 `break:server` / `break:client` 过滤，配合 `GetDebugCheckBreakOptions` hook 在游戏侧实现"我是不是该理这个 break"。
10. **"测试中 PauseExecution 永久卡住"**：测试 session 必须 `MockServer` 或显式设 `MaxPauseTimeoutSeconds`；headless 失败的"hung test"通常源于客户端断连而服务端不自动 resume。`AngelscriptDebuggerSessionConfig::DefaultTimeoutSeconds` 同样是测试基础设施的关键参数。

---

## 小结

- **DebugServer V2 = 自定义二进制 envelope 协议 + asCContext line callback 钩子 + Path-based 变量观察**：wire 上不是 DAP，但语义上完全对齐 DAP 的"attach / pause / continue / step / breakpoint / stackTrace / variables / evaluate"。DAP 适配器是 IDE 侧待补齐的工作（详见 `Plan_DebugAdapter.md`），UE 进程内服务端已稳定。
- **三段静态门控（`CanEverRunLineCallback` / `ShouldAlwaysRunLineCallback` / `module->hasBreakPoints`）是性能与正确性的接缝**：未启用调试时 `asBC_SUSPEND` 退化到一两条指令开销；启用调试时按"全局 → 模块"逐级放开门，每一层的状态翻转都必须通过 `UpdateLineCallbackState` 显式同步。
- **单步语义 = `bBreakNextScriptLine` + `(ConditionBreakFrame, ConditionBreakFunction)` 两位状态**：StepIn 没有条件，StepOver / StepOut 用栈深度 + 函数指针双重比对来跳过子调用——这种用"指针相等性"判定"还在原帧调用链中"的写法是 AS 内核接口的固定用法。
- **多客户端是"一对多广播 + 各自请求"的混合模式**：所有 `HasStopped` / `HasContinued` 给所有 socket，但 `Variables` / `CallStack` 走 `SendMessageToClient` 定点回应；`bIsDebugging` 只在最后一个 debug client 退出时关闭。多 Engine 实例每个独立 owner、独立端口、独立断点表。
- **与 HotReload / StaticJIT 是"协同 + 互斥"的混合**：HotReload 末尾 `ReapplyBreakpoints` 把断点重新绑到新模块；StaticJIT 通过 `asEP_BUILD_WITHOUT_LINE_CUES` 完全消除 line callback 触发点——两条路径在 cooked + Development 模式之间二选一，不能共存。
- **Windows 硬件 data breakpoint 是 fork 特色**：4 个 DRx 寄存器 + Vectored Exception Handler 实现"对内存写一发停一次"，命中后延迟到 line callback 中再跑通常的 Pause / 广播流程；非 Windows 平台静默退化。
