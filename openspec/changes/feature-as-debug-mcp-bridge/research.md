# 调研记录

## 既有 AngelScript 调试能力

DebugServer V2 和 VS Code Adapter 已实现源码/条件断点、四个硬件数据断点、异常过滤、Pause/Continue、StepIn/StepOver/StepOut、call stack、scopes/variables 与 evaluate。`PauseExecution` 在活动脚本线程内循环，只调用 `ProcessMessages()` 并 sleep，因此控制端必须位于 UE 进程外。

当前风险包括：全局 adapter version、多调试 socket 共享状态、无 owner lease、无 request id、普通有效断点不回包，以及 TypeScript 独有的 `StopPIE` enum 序号。

## 外部调试 MCP 参考

- Microsoft DebugMCP: https://github.com/microsoft/DebugMCP
- mcp-debugger: https://github.com/debugmcpdev/mcp-debugger
- MCP TypeScript SDK stdio server: https://ts.sdk.modelcontextprotocol.io/server

共同模式是控制器位于被调试进程外，通过 stdio 对 MCP host 提供工具，再通过专用调试协议控制目标。这与 AngelScript 暂停循环的约束一致。

## TypeScript 复用边界

`Extensions/AngelscriptVSCode/extension/src/unreal-debugclient.ts` 主要依赖 Node `net`/`events`，适合抽取；`debug.ts` 依赖 VS Code/DAP，保留为适配层。Language Server 另有重复的 enum 和 envelope parser，至少应共享 codec/messages。
