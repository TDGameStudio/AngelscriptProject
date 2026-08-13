# 实现蓝图

本文是 `feature-as-mcp-observability-toolset` 的 plan-only 实现说明。它固定 v1 的文件边界、C++ seam、反射类型、Toolset 调用约定和验证步骤；实现阶段可以调整局部命名或 helper 组织，但不得改变 `design.md` 与 capability specs 中的外部语义。

## 1. 必须保持的边界

- `AngelscriptRuntime` 不依赖 `ToolsetRegistry`、`ModelContextProtocolEditor` 或任何 Editor 模块。
- `AngelscriptToolset` 只依赖 Runtime 的公开 observation DTO/facade；不得读取 `FAngelscriptEngine`、`FAngelscriptDebugServer` 的字段。
- 六个工具全部为同步、Game Thread、只读查询；不得触发 Engine 创建、编译、reload、pause、continue、step 或断点修改。
- 不返回 `FCodeSection::Code`、脚本正文、VM/socket/native pointer、数据断点地址或调试客户端局部 breakpoint id。
- 调试器的暂停/继续/步进/调用栈/变量/求值能力继续属于独立的进程外 Debug MCP；本 Toolset 只给出“是否具备/是否连接/是否暂停/有哪些活动源码断点”的摘要。

## 2. 精确文件图

### 2.1 `Plugins/Angelscript` 子模块

| 文件 | 操作 | 责任 |
|---|---|---|
| `Source/AngelscriptRuntime/Observability/AngelscriptObservabilityTypes.h` | 新增 | Runtime 导出的全部 `UENUM`/`USTRUCT` observation DTO |
| `Source/AngelscriptRuntime/Observability/AngelscriptObservability.h` | 新增 | `FAngelscriptObservability` 的六个 Game Thread-only C++ 入口 |
| `Source/AngelscriptRuntime/Observability/AngelscriptObservability.cpp` | 新增 | Engine 解析、DTO 转换、计数、hash 格式化、排序去重 |
| `Source/AngelscriptRuntime/Core/AngelscriptEngine.h` | 修改 | 两个 owner-owned 窄快照入口；把 `CompilationLock` 改为 `mutable` 以支持 const 诊断快照 |
| `Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | 修改 | 在锁内复制当前 diagnostics；把 DebugServer 快照委托给 server owner |
| `Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` | 修改 | 非反射 raw debug snapshot、源码断点 metadata sidecar、const capture 入口 |
| `Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` | 修改 | accepted/clear/reapply 断点 metadata 维护和状态复制 |
| `Source/AngelscriptTest/Observability/AngelscriptObservabilityTests.cpp` | 新增 | 无 Engine、DTO、模块、hash、诊断、排序与无副作用测试 |
| `Source/AngelscriptTest/Observability/AngelscriptObservabilityDebugTests.cpp` | 新增 | DebugServer 状态与 source metadata sidecar 回归 |

实现前先检查 `AngelscriptEngine.h/.cpp` 的当前未提交改动并人工合并；这两个文件在本计划形成时已有用户的 StaticJIT/Cache 相关修改，禁止覆盖或 reset。

### 2.2 父仓库

| 文件 | 操作 | 责任 |
|---|---|---|
| `Plugins/AngelscriptToolset/AngelscriptToolset.uplugin` | 新增 | 可选、NoRedist、Editor-only 插件 descriptor |
| `Source/AngelscriptToolset/AngelscriptToolset.Build.cs` | 新增 | Runtime + ToolsetRegistry 模块依赖 |
| `Source/AngelscriptToolset/Public/AngelscriptToolsetModule.h` | 新增 | 空模块声明 |
| `Source/AngelscriptToolset/Private/AngelscriptToolsetModule.cpp` | 新增 | 空模块实现；注册生命周期不放在 module startup |
| `Source/AngelscriptToolset/Public/AngelscriptToolsetTypes.h` | 新增 | 三个分页结果 `USTRUCT` |
| `Source/AngelscriptToolset/Public/AngelscriptToolset.h` | 新增 | `UAngelscriptToolset` 和六个 `AICallable` UFunction |
| `Source/AngelscriptToolset/Private/AngelscriptToolset.cpp` | 新增 | facade 适配、分页和固定错误 |
| `Source/AngelscriptToolset/Public/AngelscriptToolsetSubsystem.h` | 新增 | `UEditorSubsystem` 注册所有者 |
| `Source/AngelscriptToolset/Private/AngelscriptToolsetSubsystem.cpp` | 新增 | cvar callback、实际 Registry 状态协调、shutdown 反注册 |
| `Source/AngelscriptToolsetTests/AngelscriptToolsetTests.Build.cs` | 新增 | Toolset CQTest 模块依赖 |
| `Source/AngelscriptToolsetTests/Private/AngelscriptToolsetTestsModule.cpp` | 新增 | 测试模块入口，受 `WITH_ANGELSCRIPT_UNITTESTS` gate |
| `Source/AngelscriptToolsetTests/Private/AngelscriptToolsetTests.cpp` | 新增 | schema、Registry execution、分页和错误测试 |
| `Source/AngelscriptToolsetTests/Private/AngelscriptToolsetSubsystemTests.cpp` | 新增 | cvar/注册生命周期测试 |
| `AngelscriptProject.uproject` | 修改 | 仅宿主验证时显式启用 `AngelscriptToolset` |
| `Documents/Guides/AngelscriptMCP.md` | 新增 | 中文优先使用/边界说明 |
| `Plugins/Angelscript/README.md` | 修改 | 指向父仓库可选 Toolset 的简短入口 |

`Plugins/AngelscriptToolset` 是父仓库普通目录，不执行 `git submodule add`。实现提交顺序为：先提交 `Plugins/Angelscript` 子模块，再提交父仓库 gitlink、Toolset 插件、宿主配置、文档与 OpenSpec。

## 3. Runtime 反射 DTO

`AngelscriptObservabilityTypes.h` 使用 `CoreMinimal.h`，并将 `AngelscriptObservabilityTypes.generated.h` 保持为最后一个 include。所有结构均为 `USTRUCT(BlueprintType)`，字段均为：

```cpp
UPROPERTY(BlueprintReadOnly, Category = "AngelScript|Observability")
```

所有 `USTRUCT` 与 facade 用 `ANGELSCRIPTRUNTIME_API` 导出；`UENUM` 完整定义在公开头中，不需要 out-of-line 导出符号。固定类型/字段如下：

```cpp
UENUM(BlueprintType)
enum class EAngelscriptDiagnosticSeverity : uint8
{
    Info,
    Warning,
    Error,
};

USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptScriptRootObservation
{
    GENERATED_BODY()
    FString AbsolutePath;
    FString SourceKind;
    FString MountName;
};

USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptCodeSectionObservation
{
    GENERATED_BODY()
    FString VirtualPath;
    FString RelativeFilename;
    FString AbsoluteFilename;
    FString CodeHashHex;
};
```

其余结构保持以下字段顺序，便于 schema review 与 JSON fixture 稳定：

- `FAngelscriptRuntimeStatus`
  - `ProductVersion`, `UnrealEngineVersion`
  - `bEngineAvailable`, `bScriptEngineAvailable`
  - `bInitialCompileFinished`, `bInitialCompileSucceeded`, `bDiagnosticsDirty`
  - `ScriptRootCount`, `ActiveModuleCount`, `DiagnosticFileCount`, `DiagnosticCount`
  - `ErrorCount`, `WarningCount`, `InfoCount`
  - `TArray<FAngelscriptScriptRootObservation> ScriptRoots`
- `FAngelscriptModuleObservation`
  - `ModuleName`
  - `TArray<FAngelscriptCodeSectionObservation> Sections`
  - `CodeHashHex`, `CombinedDependencyHashHex`
  - `ClassCount`, `EnumCount`, `DelegateCount`
  - `TArray<FString> ImportedModules`
  - `bCompileError`, `bLoadedPrecompiledCode`, `bLoadedIncrementalCache`, `bModuleSwapInError`
- `FAngelscriptDiagnosticObservation`
  - `Filename`, `Line`, `Column`, `Severity`, `Message`, `bIsCompiling`
- `FAngelscriptDebugStatus`
  - `bDebugServerCompiled`, `bServerCreated`, `bListening`
  - `ClientCount`, `DebuggingClientCount`
  - `bIsDebugging`, `bIsPaused`, `bPauseRequested`, `bBreakNextScriptLine`
  - `SourceBreakpointCount`, `DataBreakpointCount`, `DebugServerVersion`
- `FAngelscriptBreakpointObservation`
  - `RequestedSource`, `CanonicalSource`, `ModuleName`
  - `RequestedLine`, `ResolvedLine`, `Condition`

所有整数计数/行列默认 `0`，bool 默认 `false`，字符串/数组默认空。不要使用 UObject constructor 初始化这些值。`Severity` 默认 `Info`。

## 4. Runtime facade 与 owner seam

### 4.1 facade 公开签名

`AngelscriptObservability.h` 只 include DTO header；实现文件才 include Engine、DebugServer、plugin manager 和 engine version：

```cpp
struct ANGELSCRIPTRUNTIME_API FAngelscriptObservability
{
    static FAngelscriptRuntimeStatus CaptureRuntimeStatus();
    static TArray<FAngelscriptModuleObservation> CaptureModules();
    static bool TryCaptureModule(
        const FString& ModuleName,
        FAngelscriptModuleObservation& OutModule);
    static TArray<FAngelscriptDiagnosticObservation> CaptureDiagnostics();
    static FAngelscriptDebugStatus CaptureDebugStatus();
    static TArray<FAngelscriptBreakpointObservation> CaptureBreakpoints();
};
```

每个入口第一条有效语句统一为：

```cpp
checkf(IsInGameThread(),
    TEXT("AngelScript observability capture must run on the Game Thread."));
```

然后只调用 `FAngelscriptEngine::TryGetCurrentEngine()`。禁止调用 `Get()`、`GetOrCreate()` 或通过 subsystem 创建 fallback Engine。

### 4.2 Engine 诊断快照

在 `FAngelscriptEngine` 增加：

```cpp
void CaptureDiagnosticsForObservation(
    TArray<FDiagnostics>& OutDiagnostics,
    bool& bOutDiagnosticsDirty) const;
```

实现约束：

```cpp
OutDiagnostics.Reset();
FScopeLock Lock(&CompilationLock);
bOutDiagnosticsDirty = bDiagnosticsDirty;
Diagnostics.GenerateValueArray(OutDiagnostics);
```

为支持 const 方法，将现有锁声明改为 `mutable FCriticalSection CompilationLock;`。锁内只复制当前 `Diagnostics` 与 dirty flag；不得访问 `LastEmittedDiagnostics`，不得调用 `EmitDiagnostics`，也不得在锁内做 DTO 转换、排序或 plugin/version 查询。

### 4.3 DebugServer raw snapshot

在 `AngelscriptDebugServer.h` 定义非 USTRUCT、无指针的内部传输类型：

```cpp
struct FAngelscriptDebugServerStateSnapshot
{
    bool bListening = false;
    int32 ClientCount = 0;
    int32 DebuggingClientCount = 0;
    bool bIsDebugging = false;
    bool bIsPaused = false;
    bool bPauseRequested = false;
    bool bBreakNextScriptLine = false;
    int32 SourceBreakpointCount = 0;
    int32 DataBreakpointCount = 0;
    int32 DebugServerVersion = 0;
};

struct FAngelscriptSourceBreakpointSnapshot
{
    FString RequestedSource;
    FString CanonicalSource;
    FString ModuleName;
    int32 RequestedLine = 0;
    int32 ResolvedLine = 0;
    FString Condition;
};
```

`FAngelscriptDebugServer` 增加：

```cpp
void CaptureObservation(
    FAngelscriptDebugServerStateSnapshot& OutState,
    TArray<FAngelscriptSourceBreakpointSnapshot>& OutBreakpoints) const;
```

`FAngelscriptEngine` 再增加一个始终可编译的 gateway：

```cpp
bool CaptureDebugServerObservation(
    FAngelscriptDebugServerStateSnapshot& OutState,
    TArray<FAngelscriptSourceBreakpointSnapshot>& OutBreakpoints) const;
```

两个 raw 类型在 Engine header 中前置声明，完整定义仍归 DebugServer header。gateway 先清空 outputs；`WITH_AS_DEBUGSERVER=0` 或 `DebugServer == nullptr` 时返回 `false`，否则委托 `DebugServer->CaptureObservation(...)` 并返回 `true`。这样 facade 不读取 `DebugServer` 指针，Toolset 也看不到该指针。

DebugServer capture 在 Game Thread 上读取：

- `IsListening()`；
- `Clients.Num()` 与 `ClientsThatAreDebugging.Num()`；
- `bIsDebugging`, `bIsPaused`, `bPauseRequested`, `bBreakNextScriptLine.Load()`；
- `BreakpointCount`；
- `DataBreakpoints.Num()`，语义为“配置的权威数据断点数量”，不是最多四个硬件 active slot 数；
- `DEBUG_SERVER_VERSION`，当前 UE 5.8 baseline 为 V2。

它只遍历 breakpoint sidecar，并返回副本；不调用 `ProcessMessages`、`PauseExecution`、`ReapplyBreakpoints` 或 `UpdateDataBreakpoints`。

## 5. 源码断点 metadata sidecar

现有 `FFileBreakpoints` 的 `Lines`/`Conditions` 继续是执行权威；新增：

```cpp
TMap<int32, FAngelscriptSourceBreakpointSnapshot>
    ObservationMetadataByResolvedLine;
```

### 5.1 写入点

在 `EDebugMessageType::SetBreakpoint` 分支保留：

- `OriginalFilename`：canonicalize 前的客户端 requested source；
- `BP.Filename`：`CanonizeFilename` 后的 canonical source；
- `WantedLine`：requested line；
- `CodeLine`：最终 resolved line。

只有 `CodeLine != -1 && !bDuplicateBreakpoint`、且 `Lines.Add(CodeLine)` 已被接受后，才写：

```cpp
FAngelscriptSourceBreakpointSnapshot& Metadata =
    Active->ObservationMetadataByResolvedLine.Add(CodeLine);
Metadata.RequestedSource = OriginalFilename;
Metadata.CanonicalSource = BP.Filename;
Metadata.ModuleName = ModuleDesc.IsValid()
    ? ModuleDesc->ModuleName
    : BP.ModuleName;
Metadata.RequestedLine = WantedLine;
Metadata.ResolvedLine = CodeLine;
Metadata.Condition = BP.Condition;
```

无效或落在已有 resolved line 的重复请求继续走原协议拒绝路径，不覆盖首个已接受断点的 metadata。协议 `BP.Id` 只用于当前 client 的 changed/removal reply，绝不写入 sidecar。

### 5.2 清理与 reload 点

- `EDebugMessageType::ClearBreakpoints` 清空对应 `Lines`、`Conditions` 时同时 `ObservationMetadataByResolvedLine.Reset()`。
- `ClearAllBreakpoints()` 最终 `Breakpoints.Empty()` 已能销毁 sidecar；测试仍需断言 capture 为空且 `BreakpointCount == 0`。
- `ReapplyBreakpoints()` 只更新 module pointer/VM `hasBreakPoints`，保留 sidecar，因 requested/resolved identity 并未被协议重新定义。
- 若未来 reload 会重新解析 resolved line，必须作为独立 change 明确迁移规则；v1 不在 observation capture 时猜测或重定位。

## 6. DTO 转换规则

### 6.1 版本与 hash

`ProductVersion` 复用 Offline Export 的策略：优先 `IPluginManager::Get().FindPlugin(TEXT("Angelscript"))->GetDescriptor().VersionName`，找不到 descriptor 时回退 `UTF8_TO_TCHAR(UNREAL_ANGELSCRIPT_VERSION_STRING)`。`UnrealEngineVersion` 使用 `FEngineVersion::Current().ToString()`。

hash helper 固定为：

```cpp
static FString FormatHashHex(int64 Hash)
{
    return FString::Printf(
        TEXT("0x%016llx"),
        static_cast<unsigned long long>(static_cast<uint64>(Hash)));
}
```

必须测试 `0`、`1`、`MAX_int64` 和按位 `0xffffffffffffffff`，分别得到 16 位小写 payload。不要返回 `int64` JSON number。

### 6.2 source kind 与 severity

`EAngelscriptSourceKind` 通过 exhaustive `switch` 映射为 `Unknown/Game/Plugin/Memory`；default 分支仍回退 `Unknown`，不得输出枚举整数。

诊断映射保持当前 Engine 语义：

```cpp
if (Diagnostic.bIsError)      Severity = Error;
else if (Diagnostic.bIsInfo)  Severity = Info;
else                          Severity = Warning;
```

`Line = Row`、`Column = Column`，不做 0/1-based 修正；`bIsCompiling` 来自所属 `FDiagnostics` 文件组。

### 6.3 稳定排序和去重

比较函数逐字段调用 `FString::Compare(..., ESearchCase::CaseSensitive)`；不要依赖 locale、路径大小写折叠、`TMap`/`TSet` 顺序。severity 排序 rank 固定 `Error=0, Warning=1, Info=2`。

roots、sections、imports 先排序再按全部公开 identity 字段精确去重。modules、diagnostics 和 breakpoints 不做可能掩盖真实重复项的去重，只排序。module lookup 使用 trim 后的精确、case-sensitive `ModuleName`；Toolset trim 只用于判断空值，非空查询本身保持调用者原字符串，不偷偷修正名称。

### 6.4 单次调用一致性

- `CaptureRuntimeStatus` 在一次调用中各取一次 roots/modules/diagnostics snapshot，再从这些本地副本算计数。`bEngineAvailable=true`；`bScriptEngineAvailable` 来自 `GetScriptEngine()!=nullptr`；initial compile 字段分别映射现有 `bIsInitialCompileFinished`/`bDidInitialCompileSucceed`；`DiagnosticFileCount` 包含当前 diagnostics map 的文件组数量，`DiagnosticCount`/severity counts 为各组单项求和。
- `ListModules`、`GetDiagnostics`、`ListBreakpoints` 各自只调用一次对应 facade capture，再分页。
- `TryCaptureModule` 可以直接查当前 active modules，不调用 `CaptureModules` 两次。
- 不保留跨工具调用 cache；每页的 `Total` 只描述该次 capture。

## 7. Toolset 插件骨架

### 7.1 descriptor

`AngelscriptToolset.uplugin` 固定关键字段：

```json
{
  "FileVersion": 3,
  "Version": 1,
  "VersionName": "1.0.0",
  "FriendlyName": "AngelScript Toolset",
  "Description": "Read-only AngelScript runtime observability tools for UE ToolsetRegistry and MCP.",
  "Category": "Scripting",
  "NoRedist": true,
  "EditorOnly": true,
  "CanContainContent": false,
  "IsExperimentalVersion": true,
  "Installed": false,
  "EnabledByDefault": false,
  "Modules": [
    {
      "Name": "AngelscriptToolset",
      "Type": "Editor",
      "LoadingPhase": "PostEngineInit",
      "TargetAllowList": ["Editor"]
    },
    {
      "Name": "AngelscriptToolsetTests",
      "Type": "Editor",
      "LoadingPhase": "Default",
      "TargetAllowList": ["Editor"]
    }
  ],
  "Plugins": [
    { "Name": "Angelscript", "Enabled": true },
    { "Name": "ToolsetRegistry", "Enabled": true }
  ]
}
```

不设置 `EngineVersion`：项目/CI 契约锁定 UE 5.8，但 descriptor 不应拒绝自编译的 5.8 patch/source build。`NoRedist` 与 UE 5.8 experimental `ToolsetRegistry`/`AutomationTestToolset` 一致。

### 7.2 Build.cs

主模块 public dependencies：

```csharp
"AngelscriptRuntime", "ToolsetRegistry"
```

private dependencies：

```csharp
"Core", "CoreUObject", "Engine", "EditorSubsystem", "UnrealEd"
```

只有实际实现需要解析 JSON fixture 时，测试模块才添加 `Json`/`JsonUtilities`；主模块不手写 JSON，不添加它们。任何模块都不添加 `ModelContextProtocolEditor`。

测试模块 dependencies 固定从最小集合开始：public 无依赖，private 使用 `Core`、`CoreUObject`、`Engine`、`UnrealEd`、`CQTest`、`AngelscriptRuntime`、`AngelscriptToolset`、`ToolsetRegistry`，以及解析 schema/result 所需的 `Json`。只有测试实际调用 `FJsonObjectConverter` 时才加入 `JsonUtilities`。

### 7.3 分页类型与 Toolset 类

`AngelscriptToolsetTypes.h` 定义三个结构：

- `FAngelscriptModuleObservationPage`：`TArray<FAngelscriptModuleObservation> Items`, `int32 Total`, `Offset`, `Limit`。
- `FAngelscriptDiagnosticObservationPage`：相同 page metadata，item 为 diagnostic。
- `FAngelscriptBreakpointObservationPage`：相同 page metadata，item 为 breakpoint。

`UAngelscriptToolset` 公开形态：

```cpp
UCLASS(BlueprintType)
class ANGELSCRIPTTOOLSET_API UAngelscriptToolset : public UToolsetDefinition
{
    GENERATED_BODY()

public:
    virtual FString GetToolsetVersion() const override { return TEXT("1.0.0"); }

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptRuntimeStatus GetRuntimeStatus();

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptModuleObservationPage ListModules(
        int32 Offset = 0, int32 Limit = 50);

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptModuleObservation GetModule(const FString& ModuleName);

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptDiagnosticObservationPage GetDiagnostics(
        int32 Offset = 0, int32 Limit = 100);

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptDebugStatus GetDebugStatus();

    UFUNCTION(meta = (AICallable), Category = "AngelScript|Toolset")
    static FAngelscriptBreakpointObservationPage ListBreakpoints(
        int32 Offset = 0, int32 Limit = 100);
};
```

每个 UFUNCTION 前写清晰 doc comment；UE 5.8 会把 description 放入 tool schema。不要再增加任何普通 UFUNCTION；`UToolsetDefinition::IsFunctionAICallable` 会把未标 `AICallable`/`AIIgnore` 的静态函数视为无效定义。

UE 5.8 生成的 Toolset 注册名不是简写：`UAngelscriptToolset` 的实际 toolset name 为 `AngelscriptToolset.AngelscriptToolset`（script package qualifier + UClass name），测试不得硬编码成仅 `AngelscriptToolset`。

## 8. 分页与错误实现

共享 private helper 先验证参数，再切片：

```cpp
static bool ValidatePageArguments(int32 Offset, int32 Limit)
{
    if (Offset < 0)
    {
        UKismetSystemLibrary::RaiseScriptError(
            TEXT("[InvalidArgument] offset must be greater than or equal to 0."));
        return false;
    }
    if (Limit < 1 || Limit > 200)
    {
        UKismetSystemLibrary::RaiseScriptError(
            TEXT("[InvalidArgument] limit must be between 1 and 200 inclusive."));
        return false;
    }
    return true;
}
```

成功分页算法：

1. `Page.Total = AllItems.Num()`；保存 requested `Offset/Limit`。
2. `Start = FMath::Min(Offset, Total)`。
3. `Count = FMath::Min(Limit, Total - Start)`。
4. `Items.Append(AllItems.GetData() + Start, Count)`；`Count == 0` 时不要做无效 pointer arithmetic。

错误后立即返回默认 page/struct；ToolsetRegistry 会捕获 `RaiseScriptError` 并把执行结果置为 error，默认返回值不得被客户端当作成功使用。

`GetModule`：

1. 用临时副本做 `TrimStartAndEndInline()`，仅判断是否为空。
2. 空时 raise `[InvalidArgument] moduleName must not be empty.`。
3. 用原始非空 `ModuleName` 调用 `TryCaptureModule`，保持 exact lookup。
4. false 时 raise `FString::Printf(TEXT("[NotFound] active AngelScript module '%s' was not found."), *ModuleName)`。

测试通过 `UToolsetRegistry::ExecuteTool(TEXT("AngelscriptToolset.AngelscriptToolset"), ToolName, JsonInput)` 验证真实输入反序列化、`returnValue` wrapper 和 error capture。同步工具的 `UToolCallAsyncResultString` 应在当前 Game Thread 完成；测试仍先断言 non-null 与 `bIsComplete`，成功读 `Value`，失败读 `Error`。

典型成功输出（字段由 `FJsonObjectConverter` standardize 为首字母小写）：

```json
{
  "returnValue": {
    "items": [],
    "total": 0,
    "offset": 0,
    "limit": 50
  }
}
```

## 9. Subsystem 生命周期

使用 `as.Toolset.Enable`，backing bool 默认 `true`。静态 callback：若 `GEditor == nullptr` 直接返回；否则取 `UAngelscriptToolsetSubsystem` 并调用 `SetToolsetEnabled(Variable->GetBool())`。

```text
Initialize
  -> Super::Initialize
  -> SetToolsetEnabled(cvar current value)

SetToolsetEnabled(desired)
  -> if Registry unavailable: log warning and return
  -> actual = IsToolsetClassRegistered(UAngelscriptToolset)
  -> desired && !actual: RegisterToolsetClass
  -> !desired && actual: UnregisterToolsetClass
  -> reread actual; if actual != desired, log error

Deinitialize
  -> SetToolsetEnabled(false)
  -> Super::Deinitialize
```

不保存唯一真相的 `bToolsetRegistered`。Registry 是真实状态来源，这也覆盖其他测试/插件提前注册或反注册导致的漂移。主 module 的 `StartupModule`/`ShutdownModule` 保持空，避免与 subsystem 双重拥有注册。

## 10. TDD 测试矩阵

### 10.1 Runtime

| 场景 | Fixture/输入 | 关键断言 |
|---|---|---|
| 无 Engine | `FScopedAngelscriptEngineResolutionSuppressionForTesting` | unavailable/空数组，scope 前后 current engine 不变 |
| 反射完整性 | 各 DTO `StaticStruct()` | struct 有效；批准字段存在且类型正确；无 pointer/object field |
| hash 精度 | 0、1、`MAX_int64`、全 1 bit pattern | `0x` + 16 lowercase hex |
| 多 section | 两个含不同 virtual/relative/absolute path 的 section | 同一 section record 内路径不串位；无 `Code` 字段 |
| roots/imports | 乱序与精确重复 | case-sensitive 排序、精确去重 |
| modules | 至少两个乱序 module | `ModuleName` 稳定；counts/flags 正确 |
| diagnostics | Info/Warning/Error 与同位置不同消息 | severity、filename/row/column/compiling、Error/Warning/Info 排序 |
| 诊断无副作用 | dirty/emitted bookkeeping 预置 | capture 前后完全相同，不触发 emit |
| off-thread contract | 能安全捕获 check 的现有 test harness | 明确触发 checked precondition；不在普通 worker 上制造未捕获 crash |

### 10.2 DebugServer

| 场景 | 关键断言 |
|---|---|
| `WITH_AS_DEBUGSERVER=0` | compiled=false、serverCreated=false、breakpoints 空 |
| server 未创建 | compiled=true、serverCreated=false、version 仍为 V2 |
| accepted breakpoint | requested/canonical/module/requested/resolved/condition 全部保留 |
| duplicate resolved line | 第二个请求不覆盖第一个 sidecar，count 不增加 |
| invalid line | sidecar 不产生记录 |
| clear one file/module | Lines、Conditions、sidecar 同时空 |
| clear all | source/data counts 为 0，列表空 |
| reapply | sidecar identity 保留，执行 Lines 不变 |
| data breakpoint | 只返回 count；反射 DTO/schema/JSON 不含 Address、Scope、Value |
| 多 client | ClientCount/DebuggingClientCount 正确；不出现 controller 字段 |

优先复用 `AngelscriptTest/Debugger` 现有 session/client fixture 和消息序列化 helper，不新建第二套 TCP server harness。

### 10.3 Toolset

| 场景 | 验证层 |
|---|---|
| 类/版本 | `UAngelscriptToolset` 继承关系；schema version `1.0.0` |
| 六工具白名单 | 解析 `GetToolsetJsonSchema`，工具名集合精确相等 |
| typed schema | page items 为嵌套 struct array；输出含 `returnValue` |
| 默认分页 | module 50，diagnostics/breakpoints 100 |
| 边界分页 | offset 0/total/beyond total；limit 1/200 |
| 非法分页 | offset -1；limit 0/201；完整固定 error 文本 |
| module lookup | whitespace-only invalid；unknown NotFound；exact active module success |
| unavailable | 两个 status 成功、三个 list 空、GetModule NotFound |
| 注册 | cvar 1 注册、重复 1 幂等、0 反注册、deinitialize 清理 |
| Registry 漂移 | 测试外部预注册/反注册后 `SetToolsetEnabled` 能按实际状态协调 |

Toolset 测试模块内的 CQTest 注册与测试代码受 `#if WITH_ANGELSCRIPT_UNITTESTS` 保护；该 define 来自 `AngelscriptRuntime` public compile environment，不在 Toolset 重新读 ini 或重复定义。

## 11. 实施顺序与每阶段完成条件

1. **Runtime types/no-engine RED→GREEN**：DTO 可反射，无 Engine 不创建。
2. **module/diagnostic RED→GREEN**：owner diagnostic seam、精确 hash、稳定排序和计数完成。
3. **DebugServer RED→GREEN**：raw snapshot 与 sidecar 完成，既有 debugger tests 同时通过。
4. **Toolset schema RED→GREEN**：descriptor/Build.cs/class/page 类型生成合法 schema。
5. **Tool execution RED→GREEN**：Registry 端到端分页、wrapper、固定错误完成。
6. **Subsystem RED→GREEN**：cvar 和 Registry 实际状态协调完成。
7. **文档与最终验证**：宿主显式启用、构建、两个窄前缀、strict OpenSpec、dirty tree 审计。

任一阶段若发现 Runtime 已有同步/所有权规则与本蓝图冲突，先更新本 change 的 `design.md`、spec delta 与后续 tasks，再继续实现；不要用 friend/direct field read 绕开问题。
