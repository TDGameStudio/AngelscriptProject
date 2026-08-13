# 调研记录

调研日期：2026-08-12。UE 基线来自本机 `C:\Program Files\Epic Games\UE_5.8`；AngelScript 基线来自当前 `Plugins/Angelscript` 子模块。此文件记录为什么采用当前实现边界，不作为产品 API 文档。

## UE 5.8 ToolsetRegistry 证据

### 定义与注册

- `Engine/Plugins/Experimental/ToolsetRegistry/Source/ToolsetRegistry/Public/ToolsetRegistry/ToolsetDefinition.h`
  - `UToolsetDefinition` 是 UObject Toolset 基类。
  - 注释明确要求工具为 static UFunction 并带 `meta=(AICallable)`；非工具 UFunction 要带 `AIIgnore`。
  - `GetToolsetVersion()` 当前在 CDO 上调用，默认返回 `1.0`。
- `.../Private/ToolsetRegistry/ToolsetDefinition.cpp`
  - `IsFunctionAICallable` 先检查 `FUNC_Static`，再检查 `AICallable`；违反任一条件会得到定义错误。
- `.../Public/ToolsetRegistry/UToolsetRegistry.h`
  - 公共入口具备 `IsAvailable`、`RegisterToolsetClass`、`UnregisterToolsetClass`、`IsToolsetClassRegistered`、`ExecuteTool`、`GetToolsetJsonSchema`。
- `.../Private/ToolsetRegistry/FunctionLibraryToolset.cpp`
  - C++ Toolset 名是 `<ScriptPackageQualifier>.<UClassName>`；因此 `UAngelscriptToolset` 的实际名称是 `AngelscriptToolset.AngelscriptToolset`。
  - 执行时 `ensureAlways(IsInGameThread())`，并用 `FToolCallExceptionHandler` 捕获脚本错误。
- `.../Private/ToolsetRegistry/ObjectFunctionToolCall.cpp`
  - 普通同步返回值固定包装为 `{"returnValue": ...}`。
- `.../Private/ToolsetRegistry/ToolsetJson.cpp`
  - 返回属性经 `FJsonObjectConverter::UPropertyToJsonValue` 转换；默认会把字段首字母 standardize 为小写。

### Engine 自带参考插件

`Engine/Plugins/Experimental/Toolsets/AutomationTestToolset` 的 descriptor、Build.cs、Toolset 和 subsystem 表明：

- descriptor 使用 `NoRedist=true`、`EditorOnly=true`、`EnabledByDefault=false`；主模块为 Editor/PostEngineInit，测试模块为 Editor/Default。
- 只声明 `ToolsetRegistry` plugin dependency；不直接依赖 `ModelContextProtocolEditor`。
- `UAutomationTestToolsetSubsystem` 在 initialize 时依据 cvar 注册，在 deinitialize 时反注册。
- 当前参考实现用本地 `bToolsetRegistered`；本 change 为应对外部注册/反注册和测试导致的状态漂移，进一步以 `IsToolsetClassRegistered` 为真实状态源。

`Engine/Plugins/Experimental/ModelContextProtocol/Source/ModelContextProtocolEditor/Private/ModelContextProtocolToolsetRegistryAdapter.*` 负责把 Registry 工具适配到 MCP，因此业务 Toolset 不应链接 MCP Editor 模块。

## AngelScript Runtime 证据

### Engine 与测试隔离

- `Core/AngelscriptEngine.cpp` 中 `TryGetCurrentEngine()` 依次考虑当前 Engine context、测试抑制和 engine subsystem；它不会主动创建 Engine。
- `Core/AngelscriptEngine.h` 已有 `FScopedAngelscriptEngineResolutionSuppressionForTesting`，并在多组现有测试使用。无 Engine 观测测试直接复用它，不新增 global hook。
- `GetActiveModules()` 返回 `TArray<TSharedRef<FAngelscriptModuleDesc>>`；底层为 map，调用者必须自行排序。
- `GetEffectiveScriptRootDescriptors()` 提供 `FAngelscriptSourceRoot` 副本；`Core/AngelscriptSource.h` 的稳定字段为 `AbsolutePath`、`EAngelscriptSourceKind`、`MountName`。

### Module 与诊断

- `Core/AngelscriptEngine.h` 的 `FAngelscriptModuleDesc::FCodeSection` 同时保存 virtual/relative/absolute path、处理后 `Code` 和 `int64 CodeHash`。Toolset 需要保持路径关联，但必须排除 `Code`。
- module 还提供 `CodeHash`、`CombinedDependencyHash`、Classes/Enums/Delegates/ImportedModules 和四个 compile/cache flag。
- JSON/JavaScript number 不能精确表示全部 64 位 hash，因此契约采用 `0x` + 16 位小写十六进制字符串。
- `FDiagnostics` 是 filename + diagnostic array + emitted/compiling flags；单项 `FDiagnostic` 有 Row/Column/bIsError/bIsInfo。
- 当前 `Diagnostics`、`bDiagnosticsDirty` 与 `CompilationLock` 在 Engine 内；编译 callback 写路径会使用该锁。安全外部入口应由 Engine 在锁内复制，而不是让 facade/Toolset直接遍历 map。
- `LastEmittedDiagnostics` 是发送 bookkeeping，不是当前诊断真相；观测不得读取或修改它。

### 产品/引擎版本

- `Core/UnrealAngelscriptVersion.h` 定义 `UNREAL_ANGELSCRIPT_VERSION_STRING`，当前为 `1.0.0`。
- `Dump/AngelscriptOfflineExportService.cpp` 已采用“优先 Angelscript plugin descriptor VersionName、回退编译期宏”和 `FEngineVersion::Current().ToString()`；观测 facade 应复用该语义。

## DebugServer V2 证据

- `Debugging/AngelscriptDebugServer.h` 定义 `DEBUG_SERVER_VERSION 2`。
- server 持有 `Clients`、`ClientsThatAreDebugging`、pause/debug flags、`BreakpointCount`、`Breakpoints`、`SectionBreakpoints` 和 `DataBreakpoints`；这些容器含 `FSocket*` 或地址语义，不能直接反射。
- `FFileBreakpoints` 目前只有 `Module`、resolved `Lines` 和 per-line `Conditions`。
- `SetBreakpoint` message 中的 `BP.Id` 只在 changed/removal reply 使用，没有存入 `FFileBreakpoints`；UE Toolset 无法承诺稳定 breakpoint id。
- module 成功解析后，`Breakpoints` 以 module name 为 key，多个 source section 又指向同一 resolved line set；无法从现有 map 可靠反推 requested source。
- `ClearBreakpoints` 会清空指定 active entry 的 Lines/Conditions；`ClearAllBreakpoints` 清空整个 map；`ReapplyBreakpoints` 只恢复 module/VM has-breakpoint 关联。

因此 v1 需要 owner-maintained、execution-neutral metadata sidecar，且只在断点被最终接受后记录 requested/canonical source 与 requested/resolved line。执行仍使用原 Lines/Conditions。

DebugServer V2 没有 exclusive controller/lease 概念。v1 只报告 `ClientCount` 和 `DebuggingClientCount`，不伪造 `bHasController`。

## 方案比较与结论

1. Toolset 直接读取 Engine/DebugServer：依赖内部字段、宏和容器布局，拒绝。
2. Runtime facade 直接读取所有公开容器：隔离了 Editor 插件，但绕过 owner 同步与断点身份来源，拒绝。
3. Engine/DebugServer 窄 raw snapshot + Runtime reflected facade + Editor Toolset：同步、所有权、反射和 UE 5.8 适配责任清晰，采用。

完整暂停、继续、步进、调用栈、变量和求值并非技术上不能做，而是需要调试 session ownership、超时、重入和协议控制平面；应由独立 `feature-as-debug-mcp-bridge` 处理，不能混入本只读 Toolset。
