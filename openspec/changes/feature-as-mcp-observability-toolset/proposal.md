## Why

UE 5.8 的 MCP/ToolsetRegistry 已能把 `AICallable` UFunction 暴露给智能工具，但 AngelScript 运行时尚无稳定、紧凑且只读的观测入口。当前只能依赖控制台、日志或大体量 CSV StateDump，无法安全地回答“运行时是否就绪、加载了哪些模块、有哪些诊断、调试器当前是什么状态”等日常问题。

## What Changes

- 在 `AngelscriptRuntime` 增加线程边界明确、无副作用、稳定排序的公开观测 facade，并由 Engine/DebugServer 所有者提供同步安全的窄原始快照。
- 新增父仓库直接持有的可选 Editor 插件 `Plugins/AngelscriptToolset`，通过 UE 5.8 `ToolsetRegistry` 注册六个只读 `AICallable` 工具。
- 为列表查询提供分页和稳定错误；不返回源代码、原生地址或内部大体量 StateDump。
- 明确排除 AngelScript 源码写入、片段执行、热重载、资产/蓝图修改、覆盖率和原生断点能力。

## Capabilities

### New Capabilities

- `as-runtime-observability`: AngelScript 运行时、模块、诊断和调试状态的稳定只读 C++ 快照契约。
- `as-mcp-observability-toolset`: 通过 UE 5.8 ToolsetRegistry/MCP 暴露六个 AngelScript 可观测工具的契约。

### Modified Capabilities

- `as-engine-reflectable-state`: 将既有可反射状态要求收口为可由外部 Toolset 安全消费的公开观测 facade 与稳定快照类型。

## Impact

- 修改 `Plugins/Angelscript/Source/AngelscriptRuntime` 的公开头、实现与 DebugServer 只读状态访问；源码断点只增加不参与执行的观测 metadata sidecar。
- 修改 `Plugins/Angelscript/Source/AngelscriptTest`，增加运行时观测回归测试。
- 新增 `Plugins/AngelscriptToolset`（父仓库普通目录，不是 Git submodule），仅 Editor 加载，依赖 `AngelscriptRuntime` 与 UE `ToolsetRegistry`，不直接依赖 `ModelContextProtocolEditor`。
- 更新中英文插件/工具文档与验证脚本说明；不改变现有 AngelScript 编译或执行语义。
