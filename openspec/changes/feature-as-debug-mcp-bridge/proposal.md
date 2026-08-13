## Why

现有 AngelScript DebugServer V2 已支持断点、暂停、继续、三类步进、栈、变量和求值，但 UE Game Thread 在脚本暂停期间只泵 DebugServer TCP 消息，进程内 UE MCP Toolset 无法可靠发出继续或步进。需要一个运行在 UE 进程外的本地 stdio MCP 控制器，并补齐可并存客户端所需的会话所有权和确定性响应。

## What Changes

- 扩展 DebugServer 为兼容 V2 的 V3：每连接协议版本、单活动控制器租约、稳定 Busy/状态错误、确定性断点响应以及断连清理。
- 新增项目共享的 TypeScript 调试协议/会话包，统一二进制编解码、Unicode FString、TCP 生命周期、超时和调试状态机。
- 迁移项目 VS Code Debug Adapter 与 Language Server 使用共享协议层，并保留现有用户调试语义。
- 新增本地 stdio `AngelscriptDebugMCP`，覆盖现有 AngelScript 调试能力：源码/条件/数据断点、异常过滤、暂停/继续/步进、等待停止、栈/作用域/变量和求值。
- 不提供源码编辑、赋值、任意函数执行、片段执行、热重载、原生断点、StopPIE 或强制接管会话。

## Capabilities

### New Capabilities

- `as-debug-mcp-bridge`: 单 UE 目标的本地 stdio MCP 调试工具、状态模型、超时和稳定错误契约。
- `debugger-session-control-v3`: DebugServer V3 的每连接协商、单控制器租约、所有权释放、命令确认和引用失效契约。

### Modified Capabilities

- `debugger-protocol-v2`: 保留 V2 线协议和消息序号兼容，同时定义 V3 客户端与旧客户端并存边界。

## Impact

- 修改 `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging` 与对应 Debugger 自动化测试。
- 新增 `Extensions/AngelscriptDebugProtocol` 和 `Extensions/AngelscriptDebugMCP`，并修改 `Extensions/AngelscriptVSCode`。
- 新增本地 Debug MCP 冒烟验证脚本和中文优先使用文档。
- 默认连接 `127.0.0.1:27099`；一个 MCP 进程只控制一个 UE 目标，一个 UE 目标同一时刻只有一个活动调试控制器。
