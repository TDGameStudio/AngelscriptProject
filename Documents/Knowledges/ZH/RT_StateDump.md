# RT_StateDump — State Dump 可观测性实现细节

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: State Dump 子系统的实现机制（不重复 `Arch_EditorTestDumpCollaboration.md` 的 27 表清单与协作边界，专注于"入口设计、CSV 写入、扩展注册、命令行集成"四件事）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h` (~54 行)
> · `AngelscriptRuntime/Dump/AngelscriptStateDump.cpp` (~1195 行，24 个 DumpXXX + DumpSummary)
> · `AngelscriptRuntime/Dump/AngelscriptCSVWriter.h` (~99 行，UTF-8 受限 CSV 输出器)
> · `AngelscriptRuntime/Core/AngelscriptPerformanceStats.h`（`AS_PERF_SCOPE_DUMP_ALL` 宏）
> · `AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp` (~131 行，挂入 `OnDumpExtensions`)
> · `AngelscriptEditor/Core/AngelscriptEditorModule.cpp`（StartupModule / ShutdownModule 调用 Register/Unregister）
> · `AngelscriptRuntime/Dump/AngelscriptDumpCommand.cpp` (~64 行，`as.DumpEngineState` 控制台命令)
> · `AngelscriptTest/Dump/AngelscriptDumpTests.cpp` (~282 行，端到端 + Summary 校验)
> · `AngelscriptEditor/Tests/AngelscriptEditorStateDumpTests.cpp` (~201 行，扩展点注册/反注册回归)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — 三方协作边界（27 表清单与契约视角）
> · `Documents/Knowledges/ZH/RT_HotReload.md` — Tick 中的热重载链路（`HotReloadState.csv` 数据来源）
> · `Documents/Knowledges/ZH/RT_Debugger.md` — DebugServer V2 协议（`DebugServerState.csv` / `DebugBreakpoints.csv` 字段含义）
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `FAngelscriptClassGenerator` 与 `FClassReloadHelper::ReloadState`（`EditorReloadState.csv` 上游）
> · `AGENTS.md` §"Build & Validation Principles" — Dump 的"纯外部观察者"约束

---

## 概览

本文聚焦一个核心问题：**`FAngelscriptStateDump::DumpAll()` 是如何把整个 `FAngelscriptEngine` 的运行时状态以 27 张 CSV 表的形式同步落盘的？它如何在不破坏"纯外部观察者"原则的前提下接受 Editor 模块的扩展、并被 Test 模块通过控制台命令复用？**

`Arch_EditorTestDumpCollaboration.md` 已经从"协作边界"角度完整列出了 27 张表的命名与所属 Phase（详见该文 §3.2），并定义了"Editor 不动 Runtime 私有字段"的契约。本文不重复那份清单，转而从实现侧给出：

```text
                       ┌────────────────────────────────────────────────────────┐
                       │  FAngelscriptStateDump::DumpAll(Engine, OutputDir="")  │
                       │  · ResolveOutputDir → ProjectSaved/Angelscript/Dump/<时间戳> │
                       │  · EnsureOutputDir   (mkdir -p)                        │
                       │  · AS_PERF_SCOPE_DUMP_ALL()                            │
                       └─────────────────────────────────┬──────────────────────┘
                                                         │
                ┌────────────────────────────────────────┼──────────────────────────────────────┐
                ▼ Phase A 引擎全景                       ▼ Phase B 编译产物                     ▼ Phase C/D 各子系统
   DumpEngineOverview       DumpModules / Classes /        DumpRegisteredTypes / BindRegistrations /
   DumpRuntimeConfig        Properties / Functions /       BindDatabase_* / ToStringTypes /
   DumpEngineSettings       Enums / Delegates              Diagnostics / ScriptEngineState /
                                                          HotReloadState / JITDatabase /
                                                          PrecompiledData / StaticJITState /
                                                          DebugServerState / DebugBreakpoints /
                                                          DocumentationStats / CodeCoverage
                                                         ▼
                       ┌────────────────────────────────────────────────────────┐
                       │  OnDumpExtensions.Broadcast(ResolvedOutputDir)         │
                       │     · Editor 端 DumpEditorState                        │
                       │       └─ EditorReloadState.csv                         │
                       │       └─ EditorMenuExtensions.csv                      │
                       └─────────────────────────────────┬──────────────────────┘
                                                         ▼
                       ┌────────────────────────────────────────────────────────┐
                       │  AddExtensionTableResult("EditorReloadState.csv") ×N   │
                       │   (回填 RowCount 到 TableResults)                      │
                       └─────────────────────────────────┬──────────────────────┘
                                                         ▼
                       ┌────────────────────────────────────────────────────────┐
                       │  DumpSummary(TableResults) → DumpSummary.csv           │
                       │  UE_LOG: "Wrote N/M Success statuses, K rows, in '...'│
                       └────────────────────────────────────────────────────────┘
```

后续章节按照"入口契约 / CSVWriter / 调度顺序 / 扩展回填 / 控制台命令 / 测试协作 / 边界与性能"的顺序展开。

---

## 一、`FAngelscriptStateDump` 的入口契约：单文件、零状态、纯静态

`AngelscriptStateDump.h` 暴露的全部公开符号只有 4 个：一个静态函数 `DumpAll`、一个嵌套结构体 `FTableResult`、一个委托类型 `FDumpExtensionsDelegate`、一个静态成员 `OnDumpExtensions`。整个 dump 子系统**没有任何成员状态**，也没有 "FAngelscriptStateDump 的实例"——Hazelight 风格的 dump 在 UE5 fork 中被裁剪成了一个**静态命名空间**。

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h
// 角色: 27 张 CSV 表的统一入口；扩展点是 OnDumpExtensions 多播
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptStateDump
{
    struct FTableResult
    {
        FString TableName;
        int32 RowCount = 0;
        FString Status = TEXT("Success");      // ★ 默认 Success；NotAvailable / Skipped / PartialExport / Error 都允许
        FString ErrorMessage;
    };

    using FDumpExtensionsDelegate = TMulticastDelegate<void(const FString&)>;

    /** 唯一公开入口；OutputDir = "" 时自动 ProjectSaved/Angelscript/Dump/<timestamp> */
    static FString DumpAll(FAngelscriptEngine& Engine, const FString& OutputDir = TEXT(""));

    /** 唯一扩展点：广播参数为 ResolvedOutputDir（Editor 注册者向同一目录写自己的 CSV）*/
    static FDumpExtensionsDelegate OnDumpExtensions;

private:
    // 25 个 private 静态 DumpXXX 方法，外部无法绕过 DumpAll 直接调用
    static FString ResolveOutputDir(const FString& OutputDir);
    static bool    EnsureOutputDir(const FString& OutputDir);
    static FString MakeTimestampDirectoryName();
    static FTableResult DumpEngineOverview(FAngelscriptEngine& Engine, const FString& OutputDir);
    // ...（24 个 DumpXXX + DumpSummary，全部 private）
};
```

**为什么是静态而不是单例？**
- 静态函数对调用方没有"先获取再用"的额外步骤，匹配"只在故障诊断 / 控制台命令时偶发使用"的语义。
- 没有任何成员字段意味着**多 Engine 实例并发 dump 互不干扰**——每次调用都把 `FAngelscriptEngine& Engine` 与 `OutputDir` 显式传进去（详见 §八）。
- `OnDumpExtensions` 是 `static FDumpExtensionsDelegate`，全局唯一。这是有意的：dump 的扩展者（Editor）也只在"全局只有一份编辑器进程"的语境下注册；不需要按 Engine 实例分发。

**调用方契约**：

| 方面 | 规则 |
|------|------|
| 调用线程 | Game Thread（DumpAll 内部不加锁，假定调用方在主线程；从 `as.DumpEngineState` 控制台命令派发即满足） |
| Engine 状态 | 必须 `IsInitialized()`；未初始化时由 Test 模块的命令包装层在调用前 reject（见 §六） |
| OutputDir 语义 | 空字符串 = 启用默认时间戳目录；非空 = 测试 / CI 给定的固定目录（用于差异比对） |
| 返回值 | 实际写入的目录路径；空字符串表示"目录都没建出来"（一般是磁盘只读 / 路径非法） |
| 异常 | 不抛；任何 IO 失败都通过 `FTableResult::Status = "Error"` 上报到 `DumpSummary.csv` |

`FTableResult::Status` 的 5 个合法取值是**dump 系统的语义契约**，每张表的"半成功"语义都在这一个字符串字段里收敛：

| Status | 含义 | 何时出现 |
|--------|------|---------|
| `Success` | 表写出，行数 > 0 或表本身就该为空 | 大多数表的常态 |
| `NotAvailable` | 该数据当前 fork 没有公开枚举 API | 仅 `ToStringTypes.csv`（见 §五） |
| `PartialExport` | 仅导出公开队列、私有跟踪数据被略过 | 仅 `HotReloadState.csv` |
| `Skipped` | 编译开关或 runtime 开关关闭 | `CodeCoverage.csv`（无 `WITH_AS_COVERAGE`）/ `DebugServerState.csv`（无 `WITH_AS_DEBUGSERVER`） |
| `Error` | 写盘失败或目标对象不存在 | 任何 `SaveToFile` 失败、或扩展表未生成 |

测试侧把这五种状态作为 expectation 进行字符串比对（见 §七），所以**任何新增 status 字符串都会破坏回归**——必须慎重。

---

## 二、`FCSVWriter`：唯一允许的写入工具

dump 全栈只用一个写入器——`FCSVWriter`（99 行）。它强制 UTF-8、强制 `,` 分隔、强制 `\r\n` 换行、对包含 `, " \n \r` 的字段自动加引号转义。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptCSVWriter.h
// 角色: 受限的 CSV 输出器；"Header + Rows" 即整体 API
// ============================================================================
struct FCSVWriter
{
    void  AddHeader(TArray<FString> InHeader)   { Header = MoveTemp(InHeader); }
    void  AddRow(TArray<FString> InRow)         { Rows.Add(MoveTemp(InRow)); }
    int32 GetRowCount() const                   { return Rows.Num(); }

    bool SaveToFile(const FString& Filename, FString* OutError = nullptr) const;

private:
    static FString EscapeField(const FString& Field)        // ★ 仅在含特殊字符时加引号
    {
        const bool bNeedsQuotes = Field.Contains(TEXT(","))
            || Field.Contains(TEXT("\""))
            || Field.Contains(TEXT("\n"))
            || Field.Contains(TEXT("\r"));
        if (!bNeedsQuotes) return Field;
        FString Escaped = Field.Replace(TEXT("\""), TEXT("\"\""));
        return FString::Printf(TEXT("\"%s\""), *Escaped);
    }

    TArray<FString> Header;
    TArray<TArray<FString>> Rows;
};
```

为什么写得这么"克制"？三条理由共同指向同一个结论——**dump 输出是机器可比对的契约，不是给人读的报告**：

1. **强制 UTF-8 + `\r\n`**：`SaveToFile` 用 `FFileHelper::EEncodingOptions::ForceUTF8`；这样生成的文件可以被 Python `csv` 模块、Excel、`csv-diff` 等工具无歧义地解析。
2. **不支持注释 / 空行 / 列分隔自定义**：把所有"为什么这一行特别"的诉求引导到 `Status` / `ErrorMessage` 列，而不是文件级别的 metadata。
3. **`SaveToFile` 自动 `MakeDirectory`**：Editor 扩展点写自己的 CSV 时不需要重复 mkdir 逻辑——这条便利性是允许 Editor 写 dump 表的前提。

**默认错误防御**：如果 Header 为空，`SaveToFile` 直接拒绝并返回 `OutError = "CSV header is empty."`。这阻止了 dump 子系统不小心写出"只有数据没有列名"的废表。

---

## 三、`DumpAll` 调度顺序：为什么是这个固定顺序

`DumpAll` 内部把 24 个核心表的调用以**固定顺序**串成一根直线。看似无聊，但这个顺序背后有强约束：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.cpp
// 函数: FAngelscriptStateDump::DumpAll（调度部分节选）
// 性质: 固定顺序——依赖关系决定，不可随意调整
// ============================================================================
FString FAngelscriptStateDump::DumpAll(FAngelscriptEngine& Engine, const FString& OutputDir)
{
    AS_PERF_SCOPE_DUMP_ALL();   // ★ Stat 分组 STATGROUP_Angelscript / "Angelscript.Dump.All"

    const FString ResolvedOutputDir = ResolveOutputDir(OutputDir);
    if (!EnsureOutputDir(ResolvedOutputDir)) {
        UE_LOG(LogAngelscriptStateDump, Error, ...);
        return FString();   // ★ 目录都建不出来，整次 dump 直接放弃
    }

    TArray<FTableResult> TableResults;
    TableResults.Reserve(18);   // 历史值，并不严格匹配 27；Reserve 保守即可

    // —— Phase A 引擎全景与配置（3 张）——
    TableResults.Add(DumpEngineOverview(Engine, ResolvedOutputDir));
    TableResults.Add(DumpRuntimeConfig(Engine, ResolvedOutputDir));
    // EngineSettings 在 Phase D 末尾，详见下文

    // —— Phase B 编译产物（6 张：Modules → Classes → Properties → Functions → Enums → Delegates）——
    TableResults.Add(DumpModules(Engine, ResolvedOutputDir));
    TableResults.Add(DumpClasses(Engine, ResolvedOutputDir));
    TableResults.Add(DumpProperties(Engine, ResolvedOutputDir));
    TableResults.Add(DumpFunctions(Engine, ResolvedOutputDir));
    TableResults.Add(DumpEnums(Engine, ResolvedOutputDir));
    TableResults.Add(DumpDelegates(Engine, ResolvedOutputDir));

    // —— Phase C 类型注册与绑定数据库（5 张）——
    TableResults.Add(DumpRegisteredTypes(Engine, ResolvedOutputDir));
    TableResults.Add(DumpDiagnostics(Engine, ResolvedOutputDir));
    TableResults.Add(DumpScriptEngineState(Engine, ResolvedOutputDir));
    TableResults.Add(DumpBindRegistrations(Engine, ResolvedOutputDir));
    TableResults.Add(DumpBindDatabaseStructs(Engine, ResolvedOutputDir));
    TableResults.Add(DumpBindDatabaseClasses(Engine, ResolvedOutputDir));
    TableResults.Add(DumpToStringTypes(Engine, ResolvedOutputDir));
    TableResults.Add(DumpDocumentationStats(Engine, ResolvedOutputDir));
    TableResults.Add(DumpEngineSettings(Engine, ResolvedOutputDir));

    // —— Phase D 诊断 / 调试器 / JIT / 覆盖率（7 张）——
    TableResults.Add(DumpHotReloadState(Engine, ResolvedOutputDir));
    TableResults.Add(DumpJITDatabase(Engine, ResolvedOutputDir));
    TableResults.Add(DumpPrecompiledData(Engine, ResolvedOutputDir));
    TableResults.Add(DumpStaticJITState(Engine, ResolvedOutputDir));
    TableResults.Add(DumpDebugServerState(Engine, ResolvedOutputDir));
    TableResults.Add(DumpDebugBreakpoints(Engine, ResolvedOutputDir));
    TableResults.Add(DumpCodeCoverage(Engine, ResolvedOutputDir));

    // —— Phase E 扩展（Editor 通过 OnDumpExtensions 贡献）——
    const bool bHadExtensionHandlers = OnDumpExtensions.IsBound();
    OnDumpExtensions.Broadcast(ResolvedOutputDir);

    AddExtensionTableResult(TEXT("EditorReloadState.csv"));
    AddExtensionTableResult(TEXT("EditorMenuExtensions.csv"));

    // —— Phase F 摘要 ——
    const FTableResult SummaryResult = DumpSummary(TableResults, ResolvedOutputDir);
    UE_LOG(LogAngelscriptStateDump, Log, TEXT("...wrote %d/%d CSV files..."), ...);
    return ResolvedOutputDir;
}
```

### 3.1 顺序依据：从"独立观察"到"复合状态"

调度顺序遵循**"先独立观察，后复合状态，最后摘要"**的层级关系：

```text
  EngineOverview / RuntimeConfig                       (零依赖：直接读 bool 字段)
                ↓ 提供"基线快照"
  Modules → Classes → Properties → Functions          (递进遍历：父表展开成子表)
                  ↓
  RegisteredTypes / BindDatabase_* / ToStringTypes    (类型层面快照：跨模块全局视图)
                  ↓
  Diagnostics / ScriptEngineState                     (运行态指标：含 GC 统计)
                  ↓
  HotReload / JIT / Precompiled / StaticJIT / Debug   (子系统状态：可能受 #if 编译开关影响)
                  ↓
  CodeCoverage                                        (可选模块：可能 Skipped)
                  ↓
  OnDumpExtensions.Broadcast                          (★ 必须在所有 Runtime 表落盘后才广播)
                  ↓
  AddExtensionTableResult                             (回填 RowCount，校验扩展者是否守约)
                  ↓
  DumpSummary                                         (★ 最后一张，包含前 26 张的 status)
```

### 3.2 为什么 `OnDumpExtensions.Broadcast` 必须在 Phase E 而不是更早

如果把扩展广播提前到 Phase A 之前，会出现两个问题：

1. **扩展者读不到完整 Runtime 状态**：Editor 端 `EditorReloadState.csv` 实际上反映的是"截至本次 dump 时，`FClassReloadHelper::ReloadState` 中累积的待重载映射"。这个状态本身受 Phase B 中 `DumpModules / DumpClasses` 同步运行时刻的影响——逻辑上这两张表是 Phase B 同期信息的"编辑器侧切片"，不能比 Phase B 更早。
2. **扩展表的 RowCount 回填**：`AddExtensionTableResult` 用 `LoadFileToString` 重新读回扩展表的内容、用 `ParseIntoArrayLines` 数行得到 `RowCount`。这个动作必须紧跟 Broadcast，否则 `DumpSummary` 就拿不到正确的行数。

### 3.3 `DumpSummary` 必须最后写

`DumpSummary` 接收前面累积的 `TArray<FTableResult>`，写出每张表的 `Table / RowCount / Status / ErrorMessage` 共 4 列：

```cpp
// 节选自 DumpSummary 实现
FCSVWriter Writer;
Writer.AddHeader({ TEXT("Table"), TEXT("RowCount"), TEXT("Status"), TEXT("ErrorMessage") });
for (const FTableResult& TableResult : TableResults) {
    Writer.AddRow({
        TableResult.TableName,
        LexToString(TableResult.RowCount),
        TableResult.Status,
        TableResult.ErrorMessage
    });
}

// 把 DumpSummary.csv 自己也作为最后一行加入
FTableResult SummaryRow;
SummaryRow.TableName = TEXT("DumpSummary.csv");
SummaryRow.RowCount  = TableResults.Num() + 1;
SummaryRow.Status    = TEXT("Success");
Writer.AddRow({ SummaryRow.TableName, LexToString(SummaryRow.RowCount), SummaryRow.Status, SummaryRow.ErrorMessage });

FTableResult SaveResult = SaveTable(OutputDir, TEXT("DumpSummary.csv"), Writer);
```

——`DumpSummary.csv` **既是摘要、也是 dump 完成的最后写盘动作**。任何"DumpAll 看似成功但 Summary 缺行"的情况立即说明上游 `DumpXXX` 提前 return 了；这是测试侧最强的契约校验点（见 §七）。

---

## 四、`SaveTable` / `SaveSummary` 的 helper 模式

24 个 `DumpXXX` 不直接调 `FCSVWriter::SaveToFile`，而是统一通过文件作用域内的匿名命名空间 helper `SaveTable`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.cpp
// 函数: anonymous namespace::SaveTable
// 角色: 把"写盘 + 返回 FTableResult"的样板代码集中到一处
// ============================================================================
FAngelscriptStateDump::FTableResult SaveTable(
    const FString& OutputDir, const FString& TableName, const FCSVWriter& Writer)
{
    FAngelscriptStateDump::FTableResult Result;
    Result.TableName = TableName;
    Result.RowCount  = Writer.GetRowCount();   // ★ 即使写盘失败也保留 RowCount

    FString ErrorMessage;
    if (!Writer.SaveToFile(FPaths::Combine(OutputDir, TableName), &ErrorMessage)) {
        Result.Status       = TEXT("Error");
        Result.ErrorMessage = MoveTemp(ErrorMessage);
    }
    return Result;
}
```

每个 `DumpXXX` 的固定形态是：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.cpp
// 函数: FAngelscriptStateDump::DumpModules（典型 DumpXXX 模板）
// ============================================================================
FAngelscriptStateDump::FTableResult FAngelscriptStateDump::DumpModules(
    FAngelscriptEngine& Engine, const FString& OutputDir)
{
    FCSVWriter Writer;
    Writer.AddHeader({ /* 列名... */ });

    const TArray<TSharedRef<FAngelscriptModuleDesc>> ActiveModules = Engine.GetActiveModules();
    for (const TSharedRef<FAngelscriptModuleDesc>& Module : ActiveModules) {
        Writer.AddRow({ /* 字段... */ });
    }

    return SaveTable(OutputDir, TEXT("Modules.csv"), Writer);
}
```

**模板五要素**：
1. 创建 `FCSVWriter`；
2. `AddHeader` 一次性给出列定义（**列定义即版本契约**，详见 §附录 A）；
3. 用公开 API（如 `Engine.GetActiveModules()`）取数据；
4. 循环 `AddRow`；
5. `return SaveTable(...)`。

**对"半成功"的语义补丁**：4 张表会在 `SaveTable` 之后**修改返回值的 Status**：

| 表 | 修补后 Status | 触发条件 |
|------|---------|---------|
| `ToStringTypes.csv` | `NotAvailable` | 始终（fork 暂未保留 ToString 的公开枚举 API） |
| `HotReloadState.csv` | `PartialExport` | 始终（仅写 public 队列；不暴露 ClassGenerator 内部映射） |
| `DebugServerState.csv` / `DebugBreakpoints.csv` | `Skipped` | `!WITH_AS_DEBUGSERVER` 或 `Engine.DebugServer == nullptr` |
| `CodeCoverage.csv` | `Skipped` | `!WITH_AS_COVERAGE` 或 `Engine.CodeCoverage == nullptr` |

实例（`DumpHotReloadState`）：

```cpp
FTableResult Result = SaveTable(OutputDir, TEXT("HotReloadState.csv"), Writer);
if (Result.Status == TEXT("Success")) {
    Result.Status       = TEXT("PartialExport");   // ★ 故意降级
    Result.ErrorMessage = TEXT("Private hot reload tracking data is not exported; only public reload queues are included.");
}
return Result;
```

——这个"先 Success 再降级"的写法保留了"如果写盘真的失败，Status 应当是 Error 而不是 PartialExport"的优先级。读者看到 `PartialExport` 时可以确定**写盘成功但语义不完整**，看到 `Error` 时可以确定**写盘本身失败**。

### 4.1 几个有代表性的 DumpXXX 截面

下面挑 4 个 DumpXXX 做"实现亮点"展示，其余请自行翻阅 `AngelscriptStateDump.cpp`：

**`DumpEngineOverview`：22 列的"总览快照"**

```cpp
// 节选 DumpEngineOverview，行 293-342
Writer.AddHeader({
    TEXT("bIsInitialCompileFinished"), TEXT("bDidInitialCompileSucceed"),
    TEXT("bSimulateCooked"),           TEXT("bUseEditorScripts"),
    /* ... */
    TEXT("ActiveModuleCount"), TEXT("TotalClassCount"), TEXT("TotalEnumCount"),
    TEXT("TotalDelegateCount"),
    TEXT("RegisteredTypeCount"), TEXT("BindRegistrationCount"), TEXT("JITFunctionCount"),
    TEXT("DebugServerClients"), TEXT("ScriptRootPaths"),
    TEXT("DiagnosticsCount"), TEXT("ContextPoolSize"), TEXT("DumpTimestamp")
});
Writer.AddRow({ /* 22 个字段一行——全引擎"一行总览"*/ });
```

——这是**唯一一张永远只有 1 行的核心表**。`DumpTimestamp` 用 `FDateTime::Now().ToString(TEXT("%Y-%m-%d %H:%M:%S"))` 写入；它不参与目录命名，但提供"这次 dump 是什么时刻取的"的人类可读时间戳，用于多次 dump 比对时排序。

**`DumpDebugServerState`：`#if WITH_AS_DEBUGSERVER` 双分支**

```cpp
// 节选 DumpDebugServerState
FTableResult FAngelscriptStateDump::DumpDebugServerState(FAngelscriptEngine& Engine, const FString& OutputDir)
{
    FCSVWriter Writer;
    Writer.AddHeader({ TEXT("Key"), TEXT("Value") });

#if WITH_AS_DEBUGSERVER
    if (Engine.DebugServer != nullptr) {
        Writer.AddRow({ TEXT("HasAnyClients"),    BoolToString(Engine.DebugServer->HasAnyClients()) });
        Writer.AddRow({ TEXT("BreakpointCount"),  LexToString(Engine.DebugServer->BreakpointCount) });
        Writer.AddRow({ TEXT("DataBreakpointCount"), LexToString(Engine.DebugServer->DataBreakpoints.Num()) });
        Writer.AddRow({ TEXT("bIsPaused"),        BoolToString(Engine.DebugServer->bIsPaused) });
        Writer.AddRow({ TEXT("bIsDebugging"),     BoolToString(Engine.DebugServer->bIsDebugging) });
        Writer.AddRow({ TEXT("DebugAdapterVersion"), LexToString(AngelscriptDebugServer::DebugAdapterVersion) });
        return SaveTable(OutputDir, TEXT("DebugServerState.csv"), Writer);
    }
#endif

    FTableResult Result = SaveTable(OutputDir, TEXT("DebugServerState.csv"), Writer);   // ★ 仅写 Header 也算成功
    if (Result.Status == TEXT("Success")) {
        Result.Status       = TEXT("Skipped");
        Result.ErrorMessage = TEXT("Debug server support is not compiled or no debug server instance is active.");
    }
    return Result;
}
```

——三件事值得注意：
- **空表也要写**。即使在 `Skipped` 状态下，文件也会落盘（只有 Header 没有 Row），这样测试侧的 `IFileManager::Get().FileExists` 校验始终通过。
- **`DebugAdapterVersion` 是 fork-specific 字段**。它对应 `RT_Debugger.md` 里描述的 V2 协议版本号；diff 工具看到这个字段变化即知道协议升级了。
- **`Engine.DebugServer->Breakpoints` 的迭代下放给 `DumpDebugBreakpoints`**。这两张表数据强相关（同一个 DebugServer 指针），但故意拆成两张以便差异比对时定位"是断点列表变了还是状态机变了"。

**`DumpEngineSettings`：通过 `TFieldIterator<FProperty>` 反射遍历**

```cpp
// 节选 DumpEngineSettings
UAngelscriptSettings& Settings = UAngelscriptSettings::Get();

FCSVWriter Writer;
Writer.AddHeader({ TEXT("Key"), TEXT("Value"), TEXT("Category") });

for (TFieldIterator<FProperty> PropertyIt(UAngelscriptSettings::StaticClass()); PropertyIt; ++PropertyIt) {
    FProperty* Property = *PropertyIt;
    if (Property == nullptr) continue;

    Writer.AddRow({
        Property->GetName(),
        ExportPropertyValue(*Property, &Settings),                  // ★ ExportTextItem_Direct
        Property->GetMetaData(TEXT("Category"))
    });
}
```

——这是"自动适配 UPROPERTY 增减"的典型写法：当未来在 `UAngelscriptSettings` 中加 / 删 UPROPERTY 字段时，dump 不需要改一行代码就能反映。`Category` 元数据被一并落地，方便人类在 Excel 中按分类排序。

**`DumpCodeCoverage`：可选编译开关 + 双重 nullptr 检查**

```cpp
#if WITH_AS_COVERAGE
if (Engine.CodeCoverage != nullptr) {
    const TArray<TSharedRef<FAngelscriptModuleDesc>> ActiveModules = Engine.GetActiveModules();
    for (const TSharedRef<FAngelscriptModuleDesc>& Module : ActiveModules) {
        const FLineCoverage* Coverage = Engine.CodeCoverage->GetLineCoverage(*Module);
        if (Coverage == nullptr) continue;
        for (const TPair<int, int>& HitPair : Coverage->HitCounts) {
            if (HitPair.Value <= 0) continue;        // ★ 只导出真的 hit 过的行
            Writer.AddRow({ Coverage->AbsoluteFilename, LexToString(HitPair.Key), LexToString(HitPair.Value) });
        }
    }
    return SaveTable(OutputDir, TEXT("CodeCoverage.csv"), Writer);
}
#endif

FTableResult Result = SaveTable(OutputDir, TEXT("CodeCoverage.csv"), Writer);
if (Result.Status == TEXT("Success")) {
    Result.Status       = TEXT("Skipped");
    Result.ErrorMessage = TEXT("Code coverage support is not compiled or no coverage recorder is active.");
}
return Result;
```

——`HitPair.Value <= 0` 的防御过滤值得注意：覆盖率记录器在重置后可能保留 key 但 value 为 0；dump 不应把这种"已知未命中"的行污染输出。

---

## 五、`OnDumpExtensions` 多播：Editor 端的注册与回填

`OnDumpExtensions` 是 Runtime 层暴露给 Editor 的**唯一扩展点**。它的工作流分四个阶段：

```text
Editor 端 StartupModule
   AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpExtensionHandle)
   └─ 内部: OutHandle = FAngelscriptStateDump::OnDumpExtensions.AddStatic(&DumpEditorState);
                                                                      ▲
                                                                      │
                                                                      │ 同一目录
Runtime 端 DumpAll                                                     │
   ...写完 24 张核心表... ───────────────────────────────────────────────┘
   OnDumpExtensions.Broadcast(ResolvedOutputDir)
   └─ Editor 静态函数 DumpEditorState(OutputDir):
       ├─ SaveEditorReloadState(OutputDir)    → EditorReloadState.csv
       └─ SaveEditorMenuExtensions(OutputDir) → EditorMenuExtensions.csv

Runtime 端 AddExtensionTableResult x2
   └─ FileExists? → ParseIntoArrayLines → 回填 RowCount

Runtime 端 DumpSummary
   └─ TableResults 含 EditorReloadState/EditorMenuExtensions 各一行

Editor 端 ShutdownModule
   AngelscriptEditor::Private::UnregisterStateDumpExtension(StateDumpExtensionHandle)
   └─ 内部: FAngelscriptStateDump::OnDumpExtensions.Remove(InOutHandle); InOutHandle.Reset();
```

### 5.1 注册端：幂等 + Handle 持有

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp
// 函数: AngelscriptEditor::Private::RegisterStateDumpExtension
//       AngelscriptEditor::Private::UnregisterStateDumpExtension
// 角色: Editor 端注册 / 反注册 OnDumpExtensions 回调
// ============================================================================
namespace AngelscriptEditor::Private
{
    void RegisterStateDumpExtension(FDelegateHandle& OutHandle)
    {
        if (!OutHandle.IsValid())   // ★ 幂等：重复注册返回同一句柄
            OutHandle = FAngelscriptStateDump::OnDumpExtensions.AddStatic(&DumpEditorState);
    }

    void UnregisterStateDumpExtension(FDelegateHandle& InOutHandle)
    {
        if (InOutHandle.IsValid()) {
            FAngelscriptStateDump::OnDumpExtensions.Remove(InOutHandle);
            InOutHandle.Reset();
        }
    }
}
```

——这两个函数被 `FAngelscriptEditorModule::StartupModule` 与 `ShutdownModule` 一一对应调用：

```cpp
// 节选 AngelscriptEditor/Core/AngelscriptEditorModule.cpp
void FAngelscriptEditorModule::StartupModule()
{
    // ...其它扩展点...
    UScriptEditorMenuExtension::InitializeExtensions();
    AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpExtensionHandle);    // ★ 注册
    // ...DirectoryWatcher / Settings / ...
}

void FAngelscriptEditorModule::ShutdownModule()
{
    // ...
    AngelscriptEditor::Private::UnregisterStateDumpExtension(StateDumpExtensionHandle);  // ★ 反注册
    // ...
}
```

`StateDumpExtensionHandle` 是 `FAngelscriptEditorModule` 的一个 `FDelegateHandle` 成员；`FAngelscriptEditorModuleTestAccess::HasStateDumpExtensionHandle()` 仅在 `WITH_DEV_AUTOMATION_TESTS` 下导出，用于生命周期测试断言。

### 5.2 Editor 端写出的 2 张表

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp
// 函数: SaveEditorReloadState（节选）
// 角色: 把 FClassReloadHelper::ReloadState() 的 6 类映射写成 (Category, Old, New) 三列
// ============================================================================
void SaveEditorReloadState(const FString& OutputDir)
{
    FCSVWriter Writer;
    Writer.AddHeader({ TEXT("Category"), TEXT("OldName"), TEXT("NewName") });

    FClassReloadHelper::FReloadState& ReloadState = FClassReloadHelper::ReloadState();
    for (const TPair<UClass*, UClass*>& ReloadClass : ReloadState.ReloadClasses)
        Writer.AddRow({ TEXT("ReloadClass"), GetObjectName(ReloadClass.Key), GetObjectName(ReloadClass.Value) });
    for (UClass* NewClass : ReloadState.NewClasses)
        Writer.AddRow({ TEXT("NewClass"), FString(), GetObjectName(NewClass) });
    for (UEnum* ReloadEnum : ReloadState.ReloadEnums)
        Writer.AddRow({ TEXT("ReloadEnum"), GetObjectName(ReloadEnum), GetObjectName(ReloadEnum) });
    for (UEnum* NewEnum : ReloadState.NewEnums)
        Writer.AddRow({ TEXT("NewEnum"), FString(), GetObjectName(NewEnum) });
    for (const TPair<UScriptStruct*, UScriptStruct*>& ReloadStruct : ReloadState.ReloadStructs)
        Writer.AddRow({ TEXT("ReloadStruct"), GetObjectName(ReloadStruct.Key), GetObjectName(ReloadStruct.Value) });
    for (const TPair<UDelegateFunction*, UDelegateFunction*>& ReloadDelegate : ReloadState.ReloadDelegates)
        Writer.AddRow({ TEXT("ReloadDelegate"), GetObjectName(ReloadDelegate.Key), GetObjectName(ReloadDelegate.Value) });

    Writer.SaveToFile(FPaths::Combine(OutputDir, TEXT("EditorReloadState.csv")), &ErrorMessage);
}
```

`SaveEditorMenuExtensions` 类似，遍历 `UScriptEditorMenuExtension::GetRegisteredExtensionSnapshots()`：

```cpp
void SaveEditorMenuExtensions(const FString& OutputDir)
{
    FCSVWriter Writer;
    Writer.AddHeader({ TEXT("ExtensionPoint"), TEXT("Location"), TEXT("SectionName") });

    const TArray<UScriptEditorMenuExtension::FRegisteredExtensionSnapshot> Snapshots
        = UScriptEditorMenuExtension::GetRegisteredExtensionSnapshots();
    for (const auto& Snapshot : Snapshots) {
        Writer.AddRow({
            Snapshot.ExtensionPoint.ToString(),
            GetExtensionLocationString(Snapshot.Location),
            Snapshot.SectionName.ToString()
        });
    }
    Writer.SaveToFile(FPaths::Combine(OutputDir, TEXT("EditorMenuExtensions.csv")), &ErrorMessage);
}
```

**关键点**：
- Editor 用**自己的 `FCSVWriter` 实例**——它包含在 `Dump/AngelscriptCSVWriter.h`，是 inline 模板而不是动态库符号，所以 Editor 端直接 include 即可使用。
- Editor 端**不调用 `SaveTable` helper**（那是 Runtime 文件作用域内的匿名 namespace）；直接用 `FCSVWriter::SaveToFile` 写盘。失败时只 `UE_LOG(Error)`，不抛异常——结果由 Runtime 侧的 `AddExtensionTableResult` 通过文件存在性回填。
- `UScriptEditorMenuExtension::GetRegisteredExtensionSnapshots()` 是为 dump 专门设计的**只读快照 API**，参见该类 `.h` 第 91-98 行。它返回的 `FRegisteredExtensionSnapshot` 结构体只暴露 Location / ExtensionPoint / SectionName 三个字段——这是 dump 系统"反向定义观察 API"的样板。

### 5.3 Runtime 端的回填校验

```cpp
// 节选 DumpAll 的扩展表回填代码
const bool bHadExtensionHandlers = OnDumpExtensions.IsBound();
OnDumpExtensions.Broadcast(ResolvedOutputDir);

auto AddExtensionTableResult = [&ResolvedOutputDir, &TableResults, bHadExtensionHandlers]
    (const FString& TableName)
{
    const FString Filename = FPaths::Combine(ResolvedOutputDir, TableName);
    if (!IFileManager::Get().FileExists(*Filename)) {
        if (bHadExtensionHandlers) {                           // ★ 期望生成但没生成 → Error
            FTableResult Result;
            Result.TableName    = TableName;
            Result.Status       = TEXT("Error");
            Result.ErrorMessage = TEXT("Expected editor dump extension table was not generated.");
            TableResults.Add(Result);
        }
        return;                                                 // ★ 没 handler → 既不计 Error 也不计 Success
    }

    FString FileContents;
    int32 RowCount = 0;
    if (FFileHelper::LoadFileToString(FileContents, *Filename)) {
        TArray<FString> Lines;
        FileContents.ParseIntoArrayLines(Lines, true);
        RowCount = FMath::Max(0, Lines.Num() - 1);             // ★ 减 1 = 减去 Header
    }
    /* ...构造 TableResult 加进去... */
};
AddExtensionTableResult(TEXT("EditorReloadState.csv"));
AddExtensionTableResult(TEXT("EditorMenuExtensions.csv"));
```

——`bHadExtensionHandlers` 区分了"扩展者期望注册"与"扩展者根本不在"两种情况：
- **`Editor` 进程 + 已 `RegisterStateDumpExtension`**：缺表 = Error。
- **Headless / Cooked + 没注册扩展**：缺表 = 干脆不写入 TableResults（DumpSummary 中也不会出现）。

但 `AngelscriptDumpTests.cpp` 中的 `GetExpectedPhaseOneCsvFiles` 始终列出这两张表——这意味着**Test 侧默认假定运行在 Editor 上下文**（Test 模块本身是 `"Type": "Editor"` UE 模块）。

---

## 六、`as.DumpEngineState` 控制台命令

Runtime 模块用一个 64 行小文件把 `DumpAll` 包装成可被自动化测试 / 控制台 / CI 调用的命令：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptDumpCommand.cpp
// 函数: ExecuteDumpEngineState + GAngelscriptDumpEngineStateCommand
// 角色: as.DumpEngineState [OutputDir] 的派发与参数清洗
// ============================================================================
namespace
{
    FString SanitizeOutputDirArg(FString OutputDir)
    {
        OutputDir.TrimStartAndEndInline();
        while (OutputDir.EndsWith(TEXT(";")))                    // ★ 历史残留：分号处理
        {
            OutputDir.LeftChopInline(1, EAllowShrinking::No);
            OutputDir.TrimEndInline();
        }
        if (OutputDir.Len() >= 2 && OutputDir.StartsWith(TEXT("\"")) && OutputDir.EndsWith(TEXT("\"")))
            OutputDir = OutputDir.Mid(1, OutputDir.Len() - 2);   // ★ 去掉成对引号
        return OutputDir;
    }

    void ExecuteDumpEngineState(const TArray<FString>& Args)
    {
        if (!FAngelscriptEngine::IsInitialized()) {              // ★ 防御：未启动 Engine 直接 reject
            UE_LOG(LogAngelscriptDumpCommand, Error,
                TEXT("Cannot dump Angelscript engine state because no global engine is initialized."));
            return;
        }

        if (Args.Num() > 1) {                                    // ★ 多余参数：仅 Warning，不 reject
            TArray<FString> ExtraArgs;
            for (int32 i = 1; i < Args.Num(); ++i) ExtraArgs.Add(Args[i]);
            UE_LOG(LogAngelscriptDumpCommand, Warning,
                TEXT("Ignoring extra as.DumpEngineState arguments after the output directory: '%s'."),
                *FString::Join(ExtraArgs, TEXT(" ")));
        }

        const FString RequestedOutputDir = Args.IsEmpty() ? FString() : SanitizeOutputDirArg(Args[0]);
        const FString ActualOutputDir    = FAngelscriptStateDump::DumpAll(FAngelscriptEngine::Get(), RequestedOutputDir);
        if (ActualOutputDir.IsEmpty()) {
            UE_LOG(LogAngelscriptDumpCommand, Error, TEXT("Angelscript engine state dump failed."));
            return;
        }
        UE_LOG(LogAngelscriptDumpCommand, Log,
            TEXT("Angelscript engine state dumped to '%s'."), *ActualOutputDir);
    }

    FAutoConsoleCommand GAngelscriptDumpEngineStateCommand(
        TEXT("as.DumpEngineState"),
        TEXT("Dump Angelscript engine state to CSV tables. Optional: as.DumpEngineState [OutputDir]"),
        FConsoleCommandWithArgsDelegate::CreateStatic(&ExecuteDumpEngineState));
}
```

### 6.1 命令行的三类用法

| 调用方式 | 输出位置 |
|---------|---------|
| `as.DumpEngineState` | `<ProjectSaved>/Angelscript/Dump/<YYYYMMDD_HHMMSS>/` |
| `as.DumpEngineState D:/diag/snapshot1` | `D:/diag/snapshot1/` |
| `as.DumpEngineState "C:/path with spaces/dump"` | `C:/path with spaces/dump/`（去掉成对引号） |

### 6.2 `SanitizeOutputDirArg` 的设计意图

UE 控制台 / 自动化命令对参数的处理方式不统一——同一个用户输入字符串经过 `IConsoleManager` / `IConsoleVariable` / 自动化框架后可能尾部带分号、可能整体被引号包裹。`SanitizeOutputDirArg` 用三个动作把这些噪声去除：
- `TrimStartAndEndInline`：去前后空白；
- 循环 `EndsWith(";")` 削尾分号：兼容某些 shell 的命令分隔符泄漏；
- 成对 `"` 剥离：兼容 Windows / Linux shell 的双引号转义路径。

如果未来 `IConsoleCommandWithArgs` 的解析行为变化，这个函数是"防御层"——保持它在控制台命令的最薄一层是合理的。

### 6.3 `Args.Num() > 1` 是 Warning 而非 Error

控制台命令对"多给参数"是宽容的：仅打印 Warning 后继续 dump。这一选择与 `as.` 控制台命令家族整体保持一致——人工调试时不希望命令因为多输入了一个空格被拒绝。

---

## 七、Test 模块的回归用法：差异比对的契约校验

`AngelscriptTest/Dump/AngelscriptDumpTests.cpp` 用 4 个测试覆盖三层契约。

### 7.1 CSVWriter 的最小行为校验

```cpp
// 节选 FAngelscriptCSVWriterEscapingTest
FCSVWriter Writer;
Writer.AddHeader({ TEXT("One"), TEXT("Two"), TEXT("Three") });
Writer.AddRow({ TEXT("Comma,Value"), TEXT("Quote \"Here\""), TEXT("Line1\nLine2") });
Writer.SaveToFile(OutputFilename, &ErrorMessage);

TestTrue(TEXT("CSV should quote comma-containing fields"),
    FileContents.Contains(TEXT("\"Comma,Value\"")));
TestTrue(TEXT("CSV should double embedded quotes"),
    FileContents.Contains(TEXT("\"Quote \"\"Here\"\"\"")));
TestTrue(TEXT("CSV should preserve multiline fields inside quotes"),
    FileContents.Contains(TEXT("\"Line1\nLine2\"")));
```

——三种特殊字符全打：逗号 / 双引号 / 换行。这个测试是 `FCSVWriter::EscapeField` 的"反向规范"——任何修改 escape 逻辑都会立刻被它捕获。

### 7.2 `DumpAll` 端到端：27 张表必须齐齐落地

```cpp
// 节选 GetExpectedPhaseOneCsvFiles + FAngelscriptStateDumpEndToEndTest
TArray<FString> GetExpectedPhaseOneCsvFiles()
{
    return {
        TEXT("EngineOverview.csv"), TEXT("RuntimeConfig.csv"),
        TEXT("Modules.csv"),        TEXT("Classes.csv"),
        TEXT("Properties.csv"),     TEXT("Functions.csv"),
        TEXT("Enums.csv"),          TEXT("Delegates.csv"),
        TEXT("RegisteredTypes.csv"),TEXT("Diagnostics.csv"),
        TEXT("ScriptEngineState.csv"), TEXT("BindRegistrations.csv"),
        TEXT("BindDatabase_Structs.csv"), TEXT("BindDatabase_Classes.csv"),
        TEXT("ToStringTypes.csv"),  TEXT("DocumentationStats.csv"),
        TEXT("EngineSettings.csv"), TEXT("HotReloadState.csv"),
        TEXT("JITDatabase.csv"),    TEXT("PrecompiledData.csv"),
        TEXT("StaticJITState.csv"), TEXT("DebugServerState.csv"),
        TEXT("DebugBreakpoints.csv"),TEXT("CodeCoverage.csv"),
        TEXT("EditorReloadState.csv"), TEXT("EditorMenuExtensions.csv"),
        TEXT("DumpSummary.csv")
    };
}

bool FAngelscriptStateDumpEndToEndTest::RunTest(const FString& Parameters)
{
    FString OutputDir;
    if (!RunDumpAll(*this, OutputDir)) return false;       // ★ AcquireProductionLikeEngine

    for (const FString& Expected : GetExpectedPhaseOneCsvFiles()) {
        const FString CsvPath = FPaths::Combine(OutputDir, Expected);
        TestTrue(*FString::Printf(TEXT("DumpAll should create '%s'"), *Expected),
                 IFileManager::Get().FileExists(*CsvPath));
    }
    return true;
}
```

——数组里的 27 个名字**就是 dump 系统的对外契约**：任何"重命名一张表"或"删一张表"必须同步改这一处，否则回归立即红灯。`Arch_EditorTestDumpCollaboration.md` §3.2 的清单与本数组一一对应。

### 7.3 `DumpSummary` 状态校验

```cpp
// 节选 GetExpectedSummaryStatus
FString GetExpectedSummaryStatus(const FString& TableName)
{
    if (TableName == TEXT("ToStringTypes.csv"))   return TEXT("NotAvailable");
    if (TableName == TEXT("HotReloadState.csv"))  return TEXT("PartialExport");
    if (TableName == TEXT("CodeCoverage.csv"))    return TEXT("Skipped");
    // UE 5.7 headless: DebugServer 可能未挂载，允许 Success 或 Skipped 二选一
    if (TableName == TEXT("DebugServerState.csv")
     || TableName == TEXT("DebugBreakpoints.csv")) return FString();
    return TEXT("Success");
}
```

——`FString()`（空字符串）作为哨兵值表示"两种状态都接受"。这是为 UE 5.7 headless 共享测试引擎下 `DebugServer` 默认未挂载的情形预留的。

### 7.4 Editor 模块的扩展点回归

`AngelscriptEditorStateDumpTests.cpp` 以**手动触发 Broadcast**的方式验证扩展点：

```cpp
// 节选 FAngelscriptEditorStateDumpRegisterAndWriteCsvTest
// 1. 备份现场
FClassReloadHelper::FReloadState SavedReloadState = FClassReloadHelper::ReloadState();
FAngelscriptStateDump::FDumpExtensionsDelegate SavedDumpExtensions;
Swap(SavedDumpExtensions, FAngelscriptStateDump::OnDumpExtensions);   // ★ 清空多播

// 2. 注入受控状态
FClassReloadHelper::ReloadState() = FClassReloadHelper::FReloadState();
FClassReloadHelper::ReloadState().ReloadClasses.Add(AActor::StaticClass(), APawn::StaticClass());
FAngelscriptEditorMenuExtensionTestAccess::RegisterExtension(SnapshotExtension);

// 3. 注册扩展（幂等性测试：调两次应返回同一个 handle）
AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpHandle);
const FDelegateHandle FirstRegisterHandle = StateDumpHandle;
AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpHandle);
TestTrue(..., StateDumpHandle == FirstRegisterHandle);

// 4. 手动 Broadcast，绕过 DumpAll
FAngelscriptStateDump::OnDumpExtensions.Broadcast(FirstOutputDir);

// 5. 验证表写出 + 头部稳定 + 行内容匹配
TestTrue(IFileManager::Get().FileExists(*ReloadStateCsvPath));
TestEqual(ReloadStateLines[0], FString(TEXT("Category,OldName,NewName")));
TestTrue(ReloadStateLines.Contains(BuildReloadClassRow(AActor::StaticClass(), APawn::StaticClass())));

// 6. 反注册后再次 Broadcast，文件不应再生成
AngelscriptEditor::Private::UnregisterStateDumpExtension(StateDumpHandle);
FAngelscriptStateDump::OnDumpExtensions.Broadcast(SecondOutputDir);
TestFalse(IFileManager::Get().FileExists(*FPaths::Combine(SecondOutputDir, TEXT("EditorReloadState.csv"))));

// 7. ON_SCOPE_EXIT 恢复 ReloadState 与 OnDumpExtensions
```

——用 `Swap` 暂存全局多播是这种测试的标准手法：执行期间 `OnDumpExtensions` 被独占；测试退出时再 swap 回去。这避免了"测试给 Runtime 注入了一个 stub，结果污染下一个测试"的串扰。

`AcquireProductionLikeEngine` 是 `AngelscriptTest/Shared/AngelscriptTestUtilities.h` 中的引擎获取 helper，确保 dump 测试拿到的是"production-like"——已完成 InitialCompile、绑定数据库 ready 的引擎实例（详见 `Test_Infrastructure.md`）。

### 7.5 Editor 模块的生命周期校验

`AngelscriptEditorModuleLifecycleTests.cpp` 使用 `FAngelscriptEditorModuleTestAccess::HasStateDumpExtensionHandle(Module)` 直接检查 module 私有字段：

```cpp
Module.StartupModule();
TestTrue(...startup..., FAngelscriptEditorModuleTestAccess::HasStateDumpExtensionHandle(Module));
Module.ShutdownModule();
TestFalse(...shutdown..., FAngelscriptEditorModuleTestAccess::HasStateDumpExtensionHandle(Module));
```

——这是"Editor 注册了扩展 / Editor 也清理了扩展"的端到端校验。配合 §5.1 的幂等注册，整个扩展点的"启停一致性"被测试侧死死锁住。

---

## 八、多 Engine 实例与并发的语义

### 8.1 多 Engine：路径同时落到不同目录

`FAngelscriptStateDump::DumpAll(Engine, OutputDir)` 是**纯函数式**入口——`Engine` 引用 + `OutputDir` 字符串显式传入，没有任何静态缓存。这意味着：

```cpp
// 假设有多个并行 Engine（如 Test 池中的 SharedEngine + 临时 Engine）
const FString DirA = FAngelscriptStateDump::DumpAll(EngineA, FPaths::Combine(BaseDir, TEXT("A")));
const FString DirB = FAngelscriptStateDump::DumpAll(EngineB, FPaths::Combine(BaseDir, TEXT("B")));
// DirA / DirB 互不干扰；Editor 的 OnDumpExtensions 会被各自 Broadcast 一次
```

但有一个**语义陷阱**：`OnDumpExtensions` 是全局多播。当两个 Engine 各自 dump 时，Editor 的 `DumpEditorState` 都会被回调——它访问 `FClassReloadHelper::ReloadState()`（也是全局单例）。所以**两个 Engine 的 EditorReloadState.csv 实际上记录的是同一份编辑器侧状态**，不区分是哪个 Engine 触发的 dump。

如果未来真有"按 Engine 切片 Editor 状态"的需求，扩展委托签名要改成 `void(FAngelscriptEngine&, const FString&)`——目前的实现假定"运行时只有一份关心 Reload 的 Editor 上下文"，这与插件当前的"primary engine + 测试用临时 engine"模型相符。

### 8.2 时间戳冲突的概率

默认目录命名 `MakeTimestampDirectoryName` 用 `FDateTime::Now().ToString(TEXT("%Y%m%d_%H%M%S"))`，**精度只到秒**。同一秒内两次 `as.DumpEngineState`（无显式 OutputDir）会落在同一目录——后一次覆盖前一次的部分文件。

这是"诊断输出，不要求每次都唯一"的有意妥协。Test 侧用 `FGuid::NewGuid()` 强制唯一：

```cpp
// 节选 MakeUniqueDumpTestPath
return FPaths::Combine(
    FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("StateDump"),
    FString::Printf(TEXT("%s_%s"), *Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits)));
```

——人工 dump 用秒级时间戳，自动化 dump 用 GUID。两套规则互不冲突。

### 8.3 并发线程

`DumpAll` 内部不加锁。它假定：
1. 调用线程是 Game Thread（`as.DumpEngineState` 命令派发即满足）；
2. 调用期间没有其它代码同时修改 `Engine` 的字段（如 `bIsHotReloading`、`Diagnostics`）。

这是"诊断快照"的合理假设——出现并发竞争时读到的是一个**时间上的不一致快照**，但因为每张表内部用 `TArray::Add` 这种 thread-safe-on-single-writer 的操作，不会崩。`Modules.csv` 的行数与 `EngineOverview.csv` 的 `ActiveModuleCount` 字段在并发场景下可能差 1，但这只影响诊断准确性，不影响进程稳定性。

---

## 九、性能：dump 的"hot path 中立"性

`DumpAll` 在头部用 `AS_PERF_SCOPE_DUMP_ALL()` 宏开了一个 stat scope：

```cpp
// 节选 AngelscriptPerformanceStats.h
DECLARE_CYCLE_STAT_EXTERN(TEXT("Angelscript.Dump.All"), STAT_AngelscriptDumpAll,
                          STATGROUP_Angelscript, ANGELSCRIPTRUNTIME_API);
#define AS_PERF_SCOPE_DUMP_ALL()  ANGELSCRIPT_PERF_SCOPE("Angelscript.Dump.All", STAT_AngelscriptDumpAll, Dump_All)
```

这个 stat 与 `Compile.Initial` / `RuntimeCall.BPVM.JIT` / `DebugServer.Tick` 等并列在 `STATGROUP_Angelscript` 分组——dump 的耗时**会出现在 stat 命令 / Insights 时间线上**，但只有在被人触发时才有数据。

### 9.1 dump 不在 hot path

`DumpAll` 没有任何 Tick 调用方。`as.DumpEngineState` 是控制台命令，自动化测试通过 `RunDumpAll` 直接调；正常游戏循环、热重载循环、JIT 编译循环都**不会**触发 dump。这与 `AS_PERF_SCOPE_DEBUG_SERVER_TICK`（每 Tick 触发）形成对比。

### 9.2 dump 的耗时构成

实测耗时主要由三部分组成（数量级取决于工程规模）：
1. **`DumpFunctions` / `DumpProperties`**：随脚本类数量平方增长（每个类内迭代所有 method/property）。中型工程（500+ 脚本类）下最重的两张表。
2. **磁盘 I/O**：27 次 `FFileHelper::SaveStringToFile`，机械硬盘上 100ms 量级，SSD 上几十 ms。
3. **`DumpCodeCoverage`**：覆盖率开启时与命中行数成正比；某些 CI 数据上是最大的单张表。

**优化空间**：当前实现是 27 次串行 I/O。可以改用 `TaskGraph` 并行化各 `DumpXXX`（每张表独立无副作用），但收益有限——dump 不在 hot path，每秒触发一次的频率都谈不上。

### 9.3 与 hot reload 的关系

`HotReloadState.csv` 仅导出 `Engine.FileChangesDetectedForReload` / `Engine.FileDeletionsDetectedForReload` 两个 public 队列（详见 `RT_HotReload.md`）。dump **不读取** ClassGenerator 内部的私有跟踪表（这些数据保持 private 是为了允许 ClassGenerator 在 hot path 自由修改其布局）。

如果某次 reload 后想看到完整的 reload 影响：
1. **运行 dump 的时机**：reload 完成后（`bIsHotReloading == false`）；
2. **EditorReloadState.csv** 的 `ReloadClass / NewClass / ...` 行展示了 reload 真正发生的对象映射（来自 `FClassReloadHelper::ReloadState()`）；
3. **HotReloadState.csv** 的 `PendingReload / PendingDeletion` 行只在"reload 已被触发但 Tick 还没消化队列"时有数据。

——所以 reload 后再 dump 时，`HotReloadState.csv` 一般是空的，而 `EditorReloadState.csv` 才是该次 reload 的真正影响清单。这是"区分 in-flight queue 与已发生事件"的合理拆分。

---

## 十、设计原则：为什么坚持"纯外部观察者"

`AGENTS.md` §"Build & Validation Principles" 一句话写明：

> Preserve the dump architecture as a pure external observer: prefer reading existing public APIs over adding intrusive dump hooks to runtime/editor classes.

这条原则在代码里有**四道闸门**：

1. **所有 `DumpXXX` 都是 `private`**：禁止外部"我自己拼一张子表"的旁门左道——只能整套 `DumpAll`，要么不 dump 要么 dump 全。
2. **零 friend / 零 internals 访问**：26 个 `DumpXXX` 的签名都是 `(FAngelscriptEngine& Engine, const FString& OutputDir)` —— 没有 `friend struct FAngelscriptStateDump`，没有 `EngineInternalAccess`，没有 `*ForTesting` 注入点。
3. **`FCSVWriter` 是受限工具**：不允许绕过它自己拼字符串。这把"输出格式不一致"的风险锁死在 99 行的 inline header 里。
4. **`OnDumpExtensions` 是唯一扩展点**：Editor 想加表 → 用多播；Editor 想读 Runtime 的某状态 → Runtime 加 const public getter（如 `Engine.GetActiveModules()` / `Engine.GetRuntimeConfig()`），dump 通过 getter 间接读。

### 10.1 当 dump 想读 private 字段时怎么办

历史上 dump 多次遇到这种诱惑：「我想读 `FAngelscriptEngine::SomePrivateField`，加个 friend 多省事」。正确做法是：

```text
诱惑：dump 想读 private 字段 X
   ↓
反问：X 现在为什么是 private？
   ↓
答 a：X 在 hot path 频繁修改，public 化担心被外部错误使用
       → 在 Engine 加一个 const getter GetX_Snapshot()（return by value）
       → DumpXXX 调 GetX_Snapshot()
答 b：X 是 ClassGenerator/ContextStack/PerEngineEnumDB 等子系统私有
       → 在子系统加 const getter，dump 通过子系统的 public getter 读
答 c：X 真的不该被任何外部知道（如 raw asIScriptEngine 内部链表）
       → 不 dump 这一项，或者让 X 的 owner 暴露摘要 API（如 GetGCStatistics）
```

——这条决策树的关键是：**dump 永远是 X 的"用户"，永远不是 X 的"维护者"**。任何"为了 dump 方便"的接口扩展，必须站在"public API 维护者"的视角先评估值不值得加。

### 10.2 为什么不加 `OnDumpEngineSnapshot` 之类的 Runtime hook

一个曾经被讨论的替代方案：让 Runtime 在每次"重要状态变更"时主动 push 一份摘要给 Dump 系统缓存，dump 时直接返回缓存。这个方案被否决，原因有三：
1. **状态膨胀**：缓存会让 Runtime 持有多份"快照副本"，违反"快照只在需要时才生成"的语义；
2. **Hot path 污染**：状态变更点都在 hot path，加 push 调用会拉慢正常路径；
3. **不一致风险**：缓存的字段是不是与现状一致依赖每个变更点都"记得"push，是脆弱的隐式契约。

当前的实现选择"dump 时一次性遍历公开 API"——慢但简单、慢但与现状强一致、慢但 hot path 零成本。这与 dump 系统"只在故障诊断时偶发使用"的语义匹配。

---

## 附录 A：CSV 表索引与"列定义即契约"

### A.1 27 张表的命名总表（仅速查；详尽语义见 `Arch_EditorTestDumpCollaboration.md` §3.2）

```text
Phase A 引擎全景（3）
  EngineOverview.csv       1 行 22 列总览
  RuntimeConfig.csv        FAngelscriptEngineConfig 全量 K/V
  EngineSettings.csv       UAngelscriptSettings UPROPERTY 反射

Phase B 编译产物（6）
  Modules.csv      Classes.csv      Properties.csv
  Functions.csv    Enums.csv        Delegates.csv

Phase C 类型与绑定（5）
  RegisteredTypes.csv       BindRegistrations.csv
  BindDatabase_Structs.csv  BindDatabase_Classes.csv
  ToStringTypes.csv         (NotAvailable)

Phase D 子系统状态（10）
  Diagnostics.csv           ScriptEngineState.csv
  HotReloadState.csv        (PartialExport)
  JITDatabase.csv           PrecompiledData.csv     StaticJITState.csv
  DebugServerState.csv      DebugBreakpoints.csv    (Skipped if 无 DebugServer)
  DocumentationStats.csv    CodeCoverage.csv        (Skipped if 无 WITH_AS_COVERAGE)

Phase E Editor 扩展（2）
  EditorReloadState.csv     EditorMenuExtensions.csv

Phase F 摘要（1）
  DumpSummary.csv           包含前 26 行 + 自身 1 行 = 27 行
```

### A.2 列定义的版本契约

**任何 `Writer.AddHeader({...})` 中列名的修改都是 dump 的破坏性变更**。理由：
- 测试侧 `AngelscriptEditorStateDumpTests.cpp` 用 `TestEqual(ReloadStateLines[0], FString(TEXT("Category,OldName,NewName")))` 对头部做精确比对。
- 任何 CI 系统、第三方 diff 工具、人工分析脚本可能依赖这些列名做 schema 解析。
- 每张表的列顺序也是契约（列顺序变化会让基于位置的 CSV 解析器误读）。

**安全的扩展方式**：在末尾追加列，不删除已有列。增列时同步更新表的 `Writer.AddHeader` 与所有 `Writer.AddRow` 的字段数。

**不安全的修改**：
- 删列（即使该列总是空）：破坏现有解析；
- 改列名：破坏 schema 比对；
- 调整列顺序：破坏位置解析。

如果一定要做破坏性变更（例如把 `Properties.csv` 的 `bReplicated / ReplicationCondition` 合并），必须**同步**：
1. 修改 `DumpProperties` 的 `AddHeader` 与 `AddRow`；
2. 修改 `AngelscriptDumpTests.cpp` 中的预期；
3. 修改 `AngelscriptEditorStateDumpTests.cpp` 中的硬编码头部串（如适用）；
4. 通知 CI / 内部诊断脚本的维护者。

### A.3 几张特殊表的语义快查

| 表 | 期望状态 | 关键字段 |
|------|---------|---------|
| `EngineOverview.csv` | 永远 1 行 | `bDidInitialCompileSucceed`、`ActiveModuleCount`、`DebugServerClients`、`DumpTimestamp` |
| `Diagnostics.csv` | 编译有错时才有行 | `bIsError`、`bIsInfo`、`Filename:Row:Column` |
| `ScriptEngineState.csv` | 永远多行 | `GCCurrentSize` / `GCTotalDestroyed` / 5 个 GC 统计 |
| `HotReloadState.csv` | reload 完成后通常空 | `State = PendingReload \| PendingDeletion`，状态永远 `PartialExport` |
| `EditorReloadState.csv` | 扩展点必须挂上才有 | 6 类映射：ReloadClass / NewClass / ReloadEnum / NewEnum / ReloadStruct / ReloadDelegate |
| `DumpSummary.csv` | 永远 27 行（含自己） | `Status` 列：Success / NotAvailable / PartialExport / Skipped / Error |

---

## 附录 B：调试技巧与避坑

### B.1 调试 dump 子系统的标准流程

1. **本地触发完整 dump**：
   ```
   ~ as.DumpEngineState
   ```
   日志中出现 `Angelscript engine state dumped to '<...>'.` 即成功。
2. **打开 `DumpSummary.csv`**：从第 4 列 `Status` 一眼看出哪张表 Error / Skipped / PartialExport。
3. **如果某张表 Error**：去 `ErrorMessage` 列看具体原因（一般是磁盘只读、目录权限、文件被占用）。
4. **如果想看代码层级耗时**：`stat angelscript` 控制台命令展开 STATGROUP_Angelscript，找 `Angelscript.Dump.All`。

### B.2 常见踩坑

1. **改了 `DumpXXX` 的 Header 列，但没改测试**
   `AngelscriptDumpTests.cpp` 不直接对 Header 比对，但 `AngelscriptEditorStateDumpTests.cpp` 对扩展表的 Header 字符串比对——改了 Editor 端两张表的列就会立即失败。
2. **新增一张 dump 表，但忘记加进 `GetExpectedPhaseOneCsvFiles`**
   端到端测试中"DumpSummary should contain a row for ..."的断言找不到对应行就失败。新增表必须**同步**两个测试文件中的 expected 列表。
3. **Editor 端的 `Save*` helper 写盘失败时只 log，不 throw**
   因此 Runtime 端 `AddExtensionTableResult` 看到 `FileExists == false` 时上报 `Error`。如果你发现 `EditorReloadState.csv` 状态是 `Error` 但日志里没看到 `LogAngelscriptEditorStateDump`——那就是**根本没注册扩展**（不是写盘失败）。看 `bHadExtensionHandlers` 的语义。
4. **多进程同时 dump 到同一目录**
   时间戳精度只到秒。两个 PIE 进程同秒触发会互相覆盖。诊断时显式带 OutputDir：`as.DumpEngineState C:/diag/server` / `as.DumpEngineState C:/diag/client`。
5. **Headless 模式下 Test 期望某表 `Skipped`**
   `GetExpectedSummaryStatus` 对 `DebugServerState/Breakpoints` 用 `FString()` 哨兵接受 Success/Skipped 双值。手动写 CI 校验脚本时也要遵守这条约定，否则 UE 5.7 headless 会假阳性失败。
6. **以为 `OnDumpExtensions` 是按 Engine 实例的**
   它是全局静态多播。多 Engine 各自 dump 时，Editor 写出的 `EditorReloadState.csv` 是同一份 ClassReloadHelper 状态——内容会出现在每个 Engine 的目录下，但语义上代表"全局编辑器侧 reload 状态"。如果将来要按 Engine 切片，得改委托签名。
7. **以为加 `friend struct FAngelscriptStateDump` 是 OK 的小动作**
   一旦开了第一个 friend，「纯外部观察者」原则就破了——后续每次重构 Engine 内部都要小心 dump 是不是依赖了它。正确做法见 §10.1 决策树。

### B.3 调试小工具：手写一份 dump diff

dump 是机器可比对的：

```python
# 小脚本：比对两次 dump 的差异（伪代码）
import csv, pathlib
def load(d): return {p.name: list(csv.reader(open(p))) for p in pathlib.Path(d).glob("*.csv")}
a, b = load("D:/diag/before"), load("D:/diag/after")
for table in sorted(a.keys() | b.keys()):
    if table not in a: print(f"+ {table}")
    elif table not in b: print(f"- {table}")
    elif a[table] != b[table]:
        print(f"~ {table}: {len(a[table])} -> {len(b[table])} rows")
```

——27 张表的全 diff 通常 5 秒内出结果；这是 hot reload 后"看到底什么变了"的最直接方法。

---

## 小结

- **入口契约最小化**：`FAngelscriptStateDump` 只暴露一个静态函数 `DumpAll` + 一个静态多播 `OnDumpExtensions`；24 个 `DumpXXX` 全 private，无任何 friend、无任何成员状态——多 Engine、多次调用、并发 dump 互不干扰。
- **CSVWriter 是受限工具**：99 行的 inline header 强制 UTF-8、`\r\n`、`,` 分隔与字段引号转义；空 Header 拒写。所有 dump 输出走它，不允许绕过。
- **调度顺序是依赖图的拓扑序**：先 EngineOverview 提供基线 → Phase B 递进遍历模块/类/属性/函数 → Phase C/D 子系统快照 → `OnDumpExtensions.Broadcast` 让 Editor 在同一目录写 2 张额外表 → `AddExtensionTableResult` 回填行数 → `DumpSummary` 写最后一张总表。
- **半成功状态的 5 种 Status 是契约**：Success / NotAvailable / PartialExport / Skipped / Error；每一种都对应一类已知的"读不到 / 没编译 / 部分导出 / 写盘失败"语义，测试侧字符串比对。
- **`OnDumpExtensions` 是唯一扩展点**：Editor 用 `RegisterStateDumpExtension(Handle)` 幂等注册，`UnregisterStateDumpExtension(Handle)` 反注册；Editor 用自己的 `FCSVWriter` 写到 Runtime 给的 `OutputDir`；Runtime 通过 `IFileManager::FileExists` + `LoadFileToString` 回填行数，不读 Editor 模块任何头。
- **`as.DumpEngineState` 是 Runtime 模块的薄包装**：64 行，做参数清洗（trim / 引号剥离）+ 引擎初始化校验 + 调 `DumpAll`；多余参数仅 Warning，未初始化引擎直接 reject。自动化测试以 `FGuid::NewGuid()` 命名的目录避开秒级时间戳冲突。
- **dump 不在 hot path**：`AS_PERF_SCOPE_DUMP_ALL` 让耗时进入 STATGROUP_Angelscript 但只在被人触发时才有数据；reload / JIT / Tick 链路完全感知不到 dump 子系统。
- **设计的最高纪律是"纯外部观察者"**：四道闸门——private DumpXXX、零 friend、受限 FCSVWriter、唯一扩展委托——把"为了 dump 方便给 Runtime 加 hook"的诱惑挡在门外。任何想加 friend / `*ForTesting` 的冲动，都应回到 §10.1 决策树重新走一遍。
