## Context

UE 5.8 将可供 MCP 使用的引擎工具统一到 `ToolsetRegistry`：插件声明继承 `UToolsetDefinition` 的类，以静态 `UFUNCTION(meta=(AICallable))` 描述工具，再通过 `UToolsetRegistry` 注册。`ModelContextProtocolEditor` 会自动适配注册项，功能插件不需要直接链接 MCP 模块。

本机 UE 5.8 自带的 `AutomationTestToolset` 证明了推荐形态：`EditorOnly`、`EnabledByDefault=false`、主模块 `PostEngineInit`、`UEditorSubsystem` 管理 cvar 与注册生命周期、单独测试模块。`ToolsetRegistry` 的 `FJsonObjectConverter` 路径原生支持 USTRUCT、嵌套 USTRUCT 和 TArray 返回值；同步工具的最终 JSON 固定包在 `{"returnValue": ...}` 中。工具执行发生在 Game Thread，`UKismetSystemLibrary::RaiseScriptError` 会被 ToolsetRegistry 捕获为 tool error。

AngelScript 当前已有 `TryGetCurrentEngine()`、`GetActiveModules()`、`FAngelscriptModuleDesc`、诊断表和 DebugServer 状态，但缺少适合外部工具的窄快照契约。`FAngelscriptStateDump` 面向完整 CSV 审计，不适合作为在线 MCP API。诊断可能由编译回调线程写入并使用 `CompilationLock`；DebugServer 的 socket、断点容器和数据断点地址也不能直接泄露到 Toolset。

## Goals / Non-Goals

**Goals:**

- 提供单一公开 C++ facade，将 Engine/DebugServer 所有者快照转换成 UE 可反射值类型。
- 在 UE 5.8 Editor 中注册六个紧凑、同步、只读、可分页的 AngelScript 工具。
- 保持 section 路径关联、64 位 hash 精度、诊断严重度和源码断点 requested/resolved 语义。
- 保证单次调用内稳定排序，并用固定错误前缀区分参数非法和模块不存在。
- 只暴露调试状态摘要；完整暂停、继续、步进和变量检查由进程外 Debug MCP 提供。

**Non-Goals:**

- 不读取或返回 `.as` 源码正文，不修改源码、模块、资产、蓝图或运行时设置。
- 不触发编译、热重载、片段执行、测试、覆盖率导出或 StateDump。
- 不公开 `asIScriptEngine*`、`FSocket*`、协议客户端断点 id、值地址、数据断点地址或其他原生指针。
- 不在该 Toolset 内实现暂停、继续、步进、求值或变量读取。
- 不提供跨多次分页调用的事务快照或 continuation token。

## Decisions

### 1. 同步敏感数据由所有者捕获，facade 负责 DTO 转换

实现采用三层边界：

1. `FAngelscriptEngine` 继续通过既有公开 API提供模块描述符，并新增窄的 const 诊断快照方法；该方法在所有者内部持有 `CompilationLock`。
2. `FAngelscriptDebugServer` 新增不含 socket/地址的原始状态快照，并为活动源码断点保存观测 sidecar 元数据。
3. `FAngelscriptObservability` 在 Game Thread 调用上述入口，转换为反射 DTO、排序并聚合计数。

比较过的替代方案：

- Toolset 直接读 Engine/DebugServer：文件少，但把内部容器布局和编译宏泄漏到第二个插件，拒绝。
- facade 直接遍历所有公开字段：比 Toolset 直接读稍好，但仍绕过诊断锁和 DebugServer 所有权，拒绝。
- 所有者窄快照 + facade：增加少量 seam，但同步、编译宏、元数据和测试责任最清楚，采用。

Runtime 核心不依赖 ToolsetRegistry；只有可选 `AngelscriptToolset` 插件依赖 UE 5.8 ToolsetRegistry。

### 2. 反射 DTO 使用成组结构和精确字符串 hash

所有公开 DTO 都是 `USTRUCT(BlueprintType)`，字段为 `UPROPERTY(BlueprintReadOnly, Category="AngelScript|Observability")`，由 `ANGELSCRIPTRUNTIME_API` 导出。类型放在独立 `AngelscriptObservabilityTypes.h`，避免 Toolset 包含庞大的 Engine 头。

公开模型固定为：

- `EAngelscriptDiagnosticSeverity { Info, Warning, Error }`。
- `FAngelscriptScriptRootObservation`：`AbsolutePath`、`SourceKind`、`MountName`。`SourceKind` 为稳定字符串 `Unknown`、`Game`、`Plugin` 或 `Memory`。
- `FAngelscriptCodeSectionObservation`：`VirtualPath`、`RelativeFilename`、`AbsoluteFilename`、`CodeHashHex`。
- `FAngelscriptRuntimeStatus`：`ProductVersion`、`UnrealEngineVersion`、`bEngineAvailable`、`bScriptEngineAvailable`、`bInitialCompileFinished`、`bInitialCompileSucceeded`、`bDiagnosticsDirty`、`ScriptRootCount`、`ActiveModuleCount`、`DiagnosticFileCount`、`DiagnosticCount`、`ErrorCount`、`WarningCount`、`InfoCount`、`ScriptRoots`。
- `FAngelscriptModuleObservation`：`ModuleName`、`Sections`、`CodeHashHex`、`CombinedDependencyHashHex`、`ClassCount`、`EnumCount`、`DelegateCount`、`ImportedModules`、`bCompileError`、`bLoadedPrecompiledCode`、`bLoadedIncrementalCache`、`bModuleSwapInError`。
- `FAngelscriptDiagnosticObservation`：`Filename`、`Line`、`Column`、`Severity`、`Message`、`bIsCompiling`。行列沿用 Engine 值，未知位置保持 `0`，不做 0/1-based 转换。
- `FAngelscriptDebugStatus`：`bDebugServerCompiled`、`bServerCreated`、`bListening`、`ClientCount`、`DebuggingClientCount`、`bIsDebugging`、`bIsPaused`、`bPauseRequested`、`bBreakNextScriptLine`、`SourceBreakpointCount`、`DataBreakpointCount`、`DebugServerVersion`。
- `FAngelscriptBreakpointObservation`：`RequestedSource`、`CanonicalSource`、`ModuleName`、`RequestedLine`、`ResolvedLine`、`Condition`。

不使用三组平行的 virtual/relative/absolute path 数组；一个 code section 的路径和 hash 必须保持在同一个结构里。不把 `int64` hash 直接交给 JSON number，因为 JavaScript 对大于 `2^53-1` 的整数不能精确表示；所有 hash 使用 `0x` 加 16 位小写十六进制字符串，按 `uint64` 位模式格式化。

`bInitialCompileSucceeded` 只有在 `bInitialCompileFinished=true` 时有业务意义；未完成时保持当前 Engine 默认值但消费者不得据此判断成功。

### 3. Runtime facade 的线程与无 Engine 语义

facade 公开签名固定为：

```cpp
static FAngelscriptRuntimeStatus CaptureRuntimeStatus();
static TArray<FAngelscriptModuleObservation> CaptureModules();
static bool TryCaptureModule(const FString& ModuleName, FAngelscriptModuleObservation& OutModule);
static TArray<FAngelscriptDiagnosticObservation> CaptureDiagnostics();
static FAngelscriptDebugStatus CaptureDebugStatus();
static TArray<FAngelscriptBreakpointObservation> CaptureBreakpoints();
```

这些是 Game Thread-only 的 C++ API。每个入口以 `checkf(IsInGameThread(), ...)` 表达编程前置条件；ToolsetRegistry 已保证正常工具调用在 Game Thread，离线程调用属于 C++ 调用者错误，不转成 MCP 业务错误。

字段来源固定为：`bScriptEngineAvailable = Engine->GetScriptEngine() != nullptr`，initial compile 字段来自 `bIsInitialCompileFinished`/`bDidInitialCompileSucceed`，roots 来自 `GetEffectiveScriptRootDescriptors()`，active modules 来自 `GetActiveModules()`。`TryCaptureModule` 为保持外部契约的精确、case-sensitive 名称匹配，应遍历一次 active module snapshot；不得借用可能执行 module-name 规范化的查找入口。

无活动 Engine 时：

- `CaptureRuntimeStatus()` 返回 `bEngineAvailable=false`，产品/UE版本仍填写，计数为 0。
- `CaptureDebugStatus()` 返回编译期能力：`bDebugServerCompiled` 和 `DebugServerVersion` 可用，但 `bServerCreated=false`，其余运行状态为 0/false。
- 三个集合入口返回空数组。
- `TryCaptureModule()` 清空 `OutModule` 并返回 `false`。
- 任何入口都不得调用 `GetOrCreate()`、`FAngelscriptEngine::Get()`、`EmitDiagnostics()` 或其他有副作用的 fallback。

诊断所有者快照只复制当前 `Diagnostics`，不复制 `LastEmittedDiagnostics`，不删除空项，不修改 `bDiagnosticsDirty`/`bHasEmittedAny`。锁只覆盖复制；严重度转换、计数和排序在释放锁后完成。

### 4. 稳定排序定义

所有比较使用 `FString::Compare(..., ESearchCase::CaseSensitive)` 的序数顺序，不依赖 `TMap`/`TSet` 迭代顺序：

- roots：`SourceKind / MountName / AbsolutePath`；完全相同项去重。
- modules：`ModuleName`。
- sections：`VirtualPath / RelativeFilename / AbsoluteFilename / CodeHashHex`；完全相同项去重。
- imports：字符串序数排序并精确去重。
- diagnostics：`Filename / Line / Column / Severity(Error, Warning, Info) / Message`。
- source breakpoints：`CanonicalSource / ModuleName / ResolvedLine / RequestedLine / Condition`。

排序只保证同一状态下结果稳定，不把路径改写成小写，也不跨调用缓存结果。

### 5. 源码断点用 sidecar 保留观测身份

现有 `FFileBreakpoints` 只保存 resolved line set 和 condition map；协议 `Id` 只用于给当前客户端回包，不会持久保存，因此 v1 不得在 `ListBreakpoints` 中承诺 `Id`。模块有多个 section 时，也不能从 resolved line 反推出唯一源码路径。

为避免伪造结果，在 `FFileBreakpoints` 中增加 `MetadataByResolvedLine` sidecar。仅在断点最终被接受时记录 requested/canonical source、module、requested/resolved line 和 condition；重复或无效断点不记录。`ClearBreakpoints`、`ClearAllBreakpoints` 同步清空；`ReapplyBreakpoints` 保留 sidecar。执行路径仍继续使用既有 `Lines` 和 `Conditions`，sidecar 不改变断点命中语义。

`ListBreakpoints` 仅列出该 sidecar 中当前活动源码断点。数据断点只在 `GetDebugStatus.DataBreakpointCount` 中给出数量，地址、名称、hit count 和 scope 不通过 UE Toolset 暴露。

### 6. Toolset 使用强类型返回值

Toolset 类固定为 `UAngelscriptToolset : UToolsetDefinition`，覆盖 `GetToolsetVersion()` 返回 `1.0.0`。六个静态函数为：

```cpp
static FAngelscriptRuntimeStatus GetRuntimeStatus();
static FAngelscriptModuleObservationPage ListModules(int32 Offset = 0, int32 Limit = 50);
static FAngelscriptModuleObservation GetModule(const FString& ModuleName);
static FAngelscriptDiagnosticObservationPage GetDiagnostics(int32 Offset = 0, int32 Limit = 100);
static FAngelscriptDebugStatus GetDebugStatus();
static FAngelscriptBreakpointObservationPage ListBreakpoints(int32 Offset = 0, int32 Limit = 100);
```

每个列表 page 都只含 `Items`、`Total`、`Offset`、`Limit`。ToolsetRegistry 会把返回值包装为 `returnValue` 并把字段转成 lowerCamel JSON。每次列表调用先完成一次全量、稳定排序的 facade capture，再切片；`Offset >= Total` 是合法空页，仍回传真实 `Total/Offset/Limit`。不同页是不同时间点的独立快照；运行时变化可能让后续页的 `Total` 改变。

固定验证规则和错误文本为：

- `Offset < 0` → `[InvalidArgument] offset must be greater than or equal to 0.`
- `Limit < 1 || Limit > 200` → `[InvalidArgument] limit must be between 1 and 200 inclusive.`
- trim 后 `ModuleName` 为空 → `[InvalidArgument] moduleName must not be empty.`
- active module 不存在 → `[NotFound] active AngelScript module '<name>' was not found.`

错误路径调用 `UKismetSystemLibrary::RaiseScriptError` 后立即返回默认值；通过 ToolsetRegistry 执行时默认返回值会被异常结果取代。测试必须通过 `UToolsetRegistry::ExecuteTool` 验证错误，而不是只直接调用静态 C++ 函数。

### 7. 插件与注册生命周期

新增父仓库普通目录 `Plugins/AngelscriptToolset`，不是 submodule。descriptor 采用：

- `VersionName=1.0.0`、`EditorOnly=true`、`CanContainContent=false`、`EnabledByDefault=false`。
- `NoRedist=true`，与 UE 5.8 experimental `ToolsetRegistry` 的分发边界一致。
- 主模块 `AngelscriptToolset` 为 `Editor`、`PostEngineInit`、`TargetAllowList=[Editor]`。
- 测试模块 `AngelscriptToolsetTests` 为 `Editor`、`Default`、`TargetAllowList=[Editor]`。
- plugin dependency 仅显式启用 `Angelscript` 和 `ToolsetRegistry`。
- 不设置严格 `EngineVersion` descriptor，避免拒绝自编译 UE 5.8 patch build；规格和 CI 明确只支持 UE 5.8。

主模块 public dependencies 为 `AngelscriptRuntime` 和 `ToolsetRegistry`，因为公开 UFUNCTION 签名和基类使用它们；其他 `Core`、`CoreUObject`、`Engine`、`EditorSubsystem`、`UnrealEd` 为 private。不得依赖 `ModelContextProtocolEditor`。

`UAngelscriptToolsetSubsystem : UEditorSubsystem` 镜像 UE `AutomationTestToolset` 模式。`as.Toolset.Enable` 默认 `1`，cvar callback 查找当前 subsystem 并调用 `SetToolsetEnabled`。方法以 `UToolsetRegistry::IsToolsetClassRegistered` 作为真实状态来源，避免本地 bool 与 Registry 漂移：需要启用且未注册时注册，随后验证注册成功；需要禁用且已注册时反注册。`Deinitialize` 必须先禁用再调用 `Super::Deinitialize()`。

UE 5.8 以 script package qualifier 加 UClass name 生成注册名，因此 `UAngelscriptToolset` 的实际 Toolset name 为 `AngelscriptToolset.AngelscriptToolset`。schema/ExecuteTool 测试使用该完整名称，不假定短名。

### 8. 测试分层

- Runtime DTO、排序、hash、无 Engine、模块和诊断：`AngelscriptTest/Observability`，前缀 `Angelscript.TestModule.Observability.Runtime`。
- DebugServer 状态、sidecar、无地址和副作用：同目录，前缀 `Angelscript.TestModule.Observability.Debug`，复用现有 Debugger session/client fixture，不手写第二套 TCP harness。
- Toolset schema、JSON 输出、分页、RaiseScriptError 与 subsystem/cvar：`AngelscriptToolsetTests`，前缀 `Angelscript.Editor.Toolset.*`，错误通过公共 `UToolsetRegistry::ExecuteTool` 端到端验证。
- 所有 plugin 内 CQTest 注册继续受 `WITH_ANGELSCRIPT_UNITTESTS` gate；该宏从 `AngelscriptRuntime` public compile environment 传播，测试模块不得重复解析 ini 或重定义。

## Risks / Trade-offs

- [诊断可能由编译线程写入] → `FAngelscriptEngine` 在 owner method 内持 `CompilationLock` 复制，锁外转换和排序。
- [绝对路径包含本机信息] → 仅面向受信本地 MCP；不读取文件正文，文档明确隐私边界。
- [分页期间状态变化] → 每个调用独立捕获并返回当次 `Total`，不声称跨页事务一致性。
- [DebugServer V2 没有 controller 概念] → v1 暴露 `DebuggingClientCount`，不伪造 `bHasController`；后续 V3 change 可增加 owner 状态而不改变当前字段语义。
- [源码断点现状缺少持久 source/id] → 只增加不参与执行的 metadata sidecar；不暴露客户端局部 id。
- [大项目列表响应过大] → 列表默认 50/100，单次强制最大 200；模块详情仍是单项工具。
- [ToolsetRegistry 未初始化] → 插件在 `PostEngineInit` 注册并验证实际 Registry 状态；注册失败保留未注册状态并记录日志，不伪装成功。
- [与 broad reflectable-state 记录重叠] → 本变更只实现 MCP 所需最小 DTO/facade，不复制 StateDump 的全量内部字段。

## Migration Plan

1. 先落 Runtime DTO、诊断 owner seam、facade 和 Runtime tests，不启用新插件。
2. 增加 DebugServer metadata sidecar/只读快照与测试，不修改命中逻辑。
3. 加入可选 Toolset 插件、typed schema、Registry 执行测试和 subsystem/cvar。
4. 在宿主 `.uproject` 显式启用插件做 UE 5.8 验证；插件 descriptor 自身仍默认关闭。
5. 更新中文优先文档。回滚时可只禁用 Toolset 插件；Runtime 观测 API和 sidecar 没有主动执行路径。

## Open Questions

无。类型字段、hash 表示、断点身份、排序、分页、错误文本、注册生命周期、文件边界和测试分层均已收口。
