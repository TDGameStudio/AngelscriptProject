## Context

AngelScript DebugServer V2 在 UE 内监听 TCP（默认 `127.0.0.1:27099`），项目 VS Code Debug Adapter 通过自定义二进制 envelope 使用断点、异常过滤、暂停/继续/步进、栈、变量、求值和数据断点。脚本暂停发生在 `FAngelscriptDebugServer::PauseExecution` 的循环内；该循环只处理 DebugServer socket，因此依赖 UE Game Thread 的普通 MCP Toolset 无法在暂停期间执行继续或步进。

现有实现允许多个 socket，但调试状态全局共享，使用全局 `DebugAdapterVersion` 决定序列化格式，且大多数写命令无确认。TypeScript 协议实现还在 Debug Adapter 与 Language Server 中重复，旧 `writeString` 对非 ASCII 的字节长度处理不正确。VS Code 的 TypeScript enum 在 C++ 最后一个 V2 消息之后额外拥有 `StopPIE`，因此该序号必须保留，不能被 V3 新消息复用。

## Goals / Non-Goals

**Goals:**

- 以进程外本地 stdio MCP 完整覆盖当前 VS Code AngelScript 调试能力。
- 使一个 UE 目标同一时刻只有一个活动调试控制器，第二控制器得到稳定 Busy。
- 保持 V2 envelope、消息序号和旧 VS Code 客户端兼容；项目内 VS Code 与 MCP 升级到 V3。
- 抽取一个与 VS Code、MCP SDK 均解耦的 TypeScript 协议/会话包。
- 为状态、超时、断线、失效引用和错误提供确定性语义。

**Non-Goals:**

- 不编辑 `.as` 源码，不提供 `setVariable`、赋值表达式、任意语句/函数执行、snippet 或热重载。
- 不支持原生 `EngineBreak`/`UE_DEBUG_BREAK`、StopPIE、资产/Blueprint 操作、GoToDefinition 或覆盖率。
- 不支持一个 MCP 进程同时复用多个 UE 目标，也不允许强制抢占控制器。
- 不把 Debug MCP 嵌入 UE 进程或通过子进程包装 VS Code DAP。

## Decisions

### 1. 混合架构：进程内观测，进程外控制

普通状态查询由 `AngelscriptToolset` 完成；所有会让脚本进入暂停或需要在暂停期间继续通信的能力由 `Extensions/AngelscriptDebugMCP` 完成。Debug MCP 使用 stdio 与 MCP host 通信，另一路 TCP 直连 DebugServer。

替代方案一是把暂停/步进也做成 UE Toolset；Game Thread 暂停时该调用面无法推进。替代方案二是让 MCP 启动 VS Code DAP；它引入 VS Code 生命周期、二次协议翻译和难以控制的输出，不采用。

### 2. V3 只追加消息并保留序号

二进制 envelope 保持 `[int32 little-endian totalLength][uint8 messageType][body]`，最大消息大小保持 Runtime 当前限制。C++ enum 在 V2 的 `ClearDataBreakpoints` 后追加：

```text
44 ReservedStopPIE
45 DebugSessionResult
46 DebugCommandError
```

`ReservedStopPIE` 永不由 Runtime 处理，仅占住旧 TypeScript `StopPIE` 序号。`DEBUG_SERVER_VERSION` 提升到 3。Server 接受 adapter version 2 或 3；低于 2 的客户端继续确定性拒绝。项目 VS Code 与 Debug MCP 发送 3。

`DebugSessionResult` 包含 `CommandType:uint8`、`bAccepted:bool`、`bIsDebugging:bool`、`bIsPaused:bool`、`Message:FString`；`DebugCommandError` 包含 `CommandType:uint8`、`Code:FString`、`Message:FString`。V3 客户端对控制类命令收到其中之一；V2 不收到新增响应。

### 3. 协议版本属于连接，控制权属于单一 socket

DebugServer 以 `TMap<FSocket*, FClientState>` 保存每连接 `ProtocolVersion` 和角色，移除进程级 `AngelscriptDebugServer::DebugAdapterVersion`。消息体的版本化序列化使用 FArchive custom version；发给多客户端时按目标连接分别序列化。

`ControllerClient` 是唯一活动控制器：

- 首个成功 `StartDebugging` 的 V2/V3 socket 获得控制权。
- 同一 socket 重复开始是幂等成功。
- 第二个 V3 控制器收到 `Busy`，连接保持为被动连接。
- 第二个 V2 控制器因无法理解结构化 Busy 而被关闭，避免它误以为已获得控制权。
- Debug database、diagnostics、asset database 和 break-filter 查询允许被动客户端使用。
- Pause/Continue/Step、栈/变量/求值、断点/过滤器/数据断点写命令仅允许 owner。
- owner `StopDebugging` 或断线时清除断点/过滤器/数据断点、取消 break-next、恢复暂停目标并释放租约。

### 4. 命令确认与状态转换

V3 对 `StartDebugging`、`StopDebugging`、`ClearBreakpoints`、`SetBreakpoint`、`SetDataBreakpoints`、`ClearDataBreakpoints`、`BreakOptions`、`Pause`、`Continue`、`StepOver`、`StepIn`、`StepOut` 返回确定性结果。有效 `SetBreakpoint` 即便没有移行也必须返回最终行和 id；移动/无效仍沿用 `SetBreakpoint` 事件，随后发送 `DebugSessionResult`。

错误 code 固定为 `Busy`、`NotController`、`InvalidState`、`InvalidArgument`、`Unsupported`、`Disconnected` 和 `ProtocolError`。Pause 只允许运行态；三类 Step 只允许暂停态；Continue 在暂停态或存在 pause/break-next 请求时有效；栈/作用域/变量/求值只允许暂停态。

`HasStopped` 增加一次 `stop_generation`（客户端本地递增，不改线协议）；收到 `HasContinued` 或发送成功的继续/步进时，上一代 frame/scope/variable/data-breakpoint 候选引用全部失效。

### 5. 共享 TypeScript 协议包

新增私有 workspace 包 `Extensions/AngelscriptDebugProtocol`，Node `>=20`、strict TypeScript，职责分为：

- `codec.ts`：envelope parser/writer、Unreal FString（UTF-16LE，包括终止符与负字符数）、int/bool/array 编解码。
- `messages.ts`：精确消息 enum、V2/V3 payload 类型与编码器。
- `transport.ts`：单 TCP 目标、部分包/粘包、连接/断线、写入背压。
- `session.ts`：一次一个有序请求、命令确认、事件状态机、超时、opaque reference 与 generation。
- `errors.ts`：稳定错误 code 和可序列化错误类型。

包不依赖 `vscode`、DAP 或 MCP SDK。VS Code extension 使用 session API；Language Server 至少复用 codec/messages，删除重复 envelope/parser。正确的 FString 实现以 Unicode 单元测试锁定。

### 6. stdio Debug MCP 工具面

`Extensions/AngelscriptDebugMCP` 使用稳定版 MCP TypeScript SDK v1 与 zod，Node `>=20`，stdout 只写 JSON-RPC，日志只写 stderr。CLI 默认 `--host 127.0.0.1 --port 27099`，环境变量可覆盖；一个进程只有一个 session。

公开工具固定为：

- 会话：`get_debug_status`、`start_debugging`、`stop_debugging`
- 源码断点：`set_breakpoints`、`list_breakpoints`
- 异常：`list_exception_filters`、`set_exception_filters`
- 数据断点：`set_data_breakpoints`、`list_data_breakpoints`、`clear_data_breakpoints`
- 执行：`pause_execution`、`continue_execution`、`step_over`、`step_into`、`step_out`、`wait_for_stop`
- 检查：`get_call_stack`、`get_scopes`、`get_variables`、`evaluate`

路径通常是本机绝对 `.as` 路径；虚拟/映射路径必须同时给 `module_name`。数据断点最多 4 个，只能由暂停态变量返回的 opaque candidate 建立；MCP 响应不得返回原生地址。`evaluate` 保持当前 VS Code debugger 的成员/下标/路径求值语义，不接受赋值或任意语句；属性/全局 getter 可能执行脚本，这一风险写入工具描述和文档。

### 7. 等待、超时与取消

普通请求默认超时 5 秒；pause/step/wait 默认 30 秒、可配置但最大 300 秒。`pause_execution` 和三类 step 等待下一次 stopped event 并返回停止位置；`continue_execution` 在收到命令确认并进入 running 后返回；`wait_for_stop` 只等待事件，不发控制命令。

pause/step 超时后客户端必须发送 Continue，清除未完成的 pause/break-next，避免稍后意外停住。`wait_for_stop` 超时不改变目标状态。TCP 断线会拒绝全部待处理 promise，错误为 `Disconnected`。

## Risks / Trade-offs

- [旧 V2 客户端无法理解 Busy] → 第二个 V2 Start 直接断开；首个 V2 会话保持原行为。
- [无 request id 的旧线协议只能 FIFO] → session 层强制一次一个相关请求；V3 确认带 command type，发现错序立即 `ProtocolError`。
- [暂停期间 owner 异常退出会卡住 UE] → socket 移除路径必须恢复执行并清理控制状态，增加自动化测试与进程级 smoke。
- [getter 求值可能有副作用] → 保留既有调试语义但显式告警；不增加 assignment、call 或 arbitrary statement API。
- [TypeScript 包迁移可能破坏 VSIX] → 共享包先用 golden codec tests 固定线兼容，再迁移 extension/language-server，并同时构建/打包 VSIX。
- [数据断点依赖地址但 MCP 禁止暴露地址] → 地址只保存在 session 内 opaque reference 表；resume 时按 generation 立即失效。

## Migration Plan

1. 先为现有 envelope、V2 payload 和 enum 序号建立 C++/TypeScript golden tests。
2. 在 Runtime 加入 per-client version、V3 消息与 lease；保持 V2 adapter 测试通过。
3. 建立共享 TypeScript 包并迁移项目 VS Code/LSP，extension 版本提升到 `1.10.0`。
4. 基于共享 session 实现 Debug MCP 和模拟服务器测试。
5. 用真实 UE Editor 执行连接、断点、暂停、三类步进、变量/求值、数据断点、Busy 与断连恢复 smoke。
6. 回滚 Debug MCP 只需停止进程；Server V3 仍接受 V2，必要时可让项目 VS Code 临时发送 2。

## Open Questions

无。传输、目标模型、租约、工具集合、超时、求值边界和兼容策略均已收口。
