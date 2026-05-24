# RT_CodeCoverage — 代码覆盖率统计

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 站在"`asCContext` 每跑一行 `.as` 字节码、`AngelscriptLineCallback` 都会顺带把这一行喂给 Coverage 子系统"的视角，看 `CodeCoverage/AngelscriptCodeCoverage.{h,cpp}` 与 `CoverageReportGenerator.{h,cpp}` 这两组文件如何把"per-module per-line hit count"维护成一棵 `FCoverageNode` 目录树、再渲染为分层 HTML + 顶层 `coverage_summary.json`。本文不重写 AS 字节码 VM 主循环（那是 `AS_VirtualMachine.md` 的事），不重写 Debugger 的断点状态机（那是 `RT_Debugger.md` 的事），不重写 `Dump/AngelscriptStateDump.cpp::DumpCodeCoverage` 周边的 27 表落盘契约（那是 `RT_StateDump.md` 与 `Arch_EditorTestDumpCollaboration.md` 的事）；本文聚焦的是"**Coverage 子系统怎么按行追踪 `.as` 脚本的执行覆盖率、和 `asCContext` line callback 与 Debugger / StaticJIT 互相协调、报告输出格式、以及 Test Automation 框架是怎么通过两个事件信号驱动整条记录-写盘流水线的**"。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.{h,cpp}` (~74 行 .h + ~217 行 .cpp，`FAngelscriptCodeCoverage` / `MapExecutableLines` / `HitLine` / `StartRecording` / `StopRecordingAndWriteReport`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/LineCoverage.h` (~48 行，`FLineCoverage` / `NumExecutableLines` / `NumLinesHit` / `PruneGeneratedCode`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/CoverageReportGenerator.{h,cpp}` (~63 行 .h + ~338 行 .cpp，`FCoverageCounts` / `FCoverageNode` / `WriteFileCoverageReportHtml` / `AddCoverageLeaf` / `ComputeCoverage` / `WriteCoverageSummaryHtml` / `WriteTopLevelCoverageJson`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (Coverage 入口集中在 `~1661–1666` / `~1853–1861` / `~4823–4828` / `~5859–5874` / `~5952–5965` 五段，分别对应实例化、测试钩子安装、编译产物 → 行表映射、`UpdateLineCallbackState` 静态门控、`AngelscriptLineCallback` 中的 hit 上报)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (~22 行 `WITH_AS_COVERAGE` 宏、~52 行 `struct FAngelscriptCodeCoverage;` 前置声明、~614 行 `CodeCoverage` 成员)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSettings.h` (~67–80 行，`bEnableCodeCoverage` / `CoverageExcludePatterns`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.{h,cpp}` (`CanEverRunLineCallback` / `ShouldAlwaysRunLineCallback` 静态门控、`asBC_SUSPEND` 的 line callback 触发点)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp::FindNextLineWithCode` (~883–917 行，构造函数 line 排序的特殊路径)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp::DumpCodeCoverage` (~1147–1194 行，CSV 表 `CodeCoverage.csv` 的字段映射)
> **关联文档**:
> `Documents/Knowledges/ZH/RT_Debugger.md` — DebugServer V2 同样借用 `AngelscriptLineCallback` / `UpdateLineCallbackState`（本文 §三专门给出三方协同矩阵）
> · `Documents/Knowledges/ZH/RT_StateDump.md` — Coverage 数据通过 `DumpCodeCoverage` 落到 `CodeCoverage.csv`，Dump 体系把它视为可选 / 跳过表
> · `Documents/Knowledges/ZH/RT_StaticJIT.md` — JIT 走 `jitFunction` 快路径会绕过 `asBC_SUSPEND`，Coverage 在 JIT 模块上处于失明状态
> · `Documents/Knowledges/ZH/RT_HotReload.md` — `CompileModule_Globals_Stage4` 末尾会重新 `MapExecutableLines`，hit counts 会被该次重映射重置
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — `CodeCoverage.csv` 在 27 表清单中的位置与 `Skipped` 默认期望

---

## 概览

本文聚焦一个核心问题：**当 `bEnableCodeCoverage = true`（或命令行带 `-as-enable-code-coverage`）时，`FAngelscriptCodeCoverage` 怎么在不改 AS 内核字节码、不增加额外采样线程、也不写自己的执行追踪开关的前提下，仅靠搭车 `AngelscriptLineCallback` 把每个 `.as` 脚本里"哪一行可执行 / 这一行被命中了几次"统计出来？又如何与 Debugger 共用同一个钩子、与 StaticJIT 形成天然互斥、并被 UE Automation Controller 自动驱动整条 `Reset → Record → Write` 流水线？**

Coverage 子系统的全景骨架可以拆成**五个层次**：底部是 AS 内核的 `asBC_SUSPEND` 触发器与 `m_lineCallback` 静态门控，上一层是 `FAngelscriptEngine` 在 `Initialize` 时按宏与设置实例化的 `CodeCoverage` 单例，中间层是"per-module 行号映射"`FilesToCoverage` 与"per-line hit count"`HitCounts`，再上一层是 `WriteReportHtml` / `WriteCoverageSummaryHtml` / `WriteTopLevelCoverageJson` 三件套报告生成器，最顶层是 `IAutomationControllerModule::OnTestsAvailable` / `OnTestsComplete` 两个委托完成的"测试运行边界对齐"。

```text
┌────────────────────────────────────────────────────────────────────────────┐
│ 第 4 层（外部驱动）：UE Automation Controller                              │
│   IAutomationControllerModule.GetAutomationController()                    │
│     OnTestsAvailable.AddRaw(this, &OnTestsStarting)  ─── Running 状态时    │
│         → StartRecording()  (ResetHits + bRecording = true)                │
│     OnTestsComplete.AddRaw(this, &OnTestsStopping)                         │
│         → StopRecordingAndWriteReport(ProjectSavedDir/CodeCoverage)        │
└──────────────────────────────────────┬─────────────────────────────────────┘
                                       │
┌──────────────────────────────────────▼─────────────────────────────────────┐
│ 第 3 层：报告生成（CoverageReportGenerator.cpp）                           │
│   每文件: WriteFileCoverageReportHtml → ".as.html"，绿/红行标注 + title    │
│   目录树: AddCoverageLeaf → FCoverageNode（按 / 与 \ 分割路径）             │
│   后序遍历: ComputeCoverage 把叶子 hit 累加到目录                          │
│   index.html + coverage_summary.json（顶层目录百分比）                     │
└──────────────────────────────────────┬─────────────────────────────────────┘
                                       │
┌──────────────────────────────────────▼─────────────────────────────────────┐
│ 第 2 层：覆盖数据存储（FAngelscriptCodeCoverage / FLineCoverage）          │
│   TMap<FString, FLineCoverage> FilesToCoverage   (key=RelativeFilename)    │
│   FLineCoverage:                                                           │
│     TMap<int, int> HitCounts          // 行号 → 命中次数（值=0 表示 miss） │
│     FString        AbsoluteFilename   // 渲染 HTML 时打开源文件用          │
│   bool bRecording                     // Hit 期间的总开关                  │
└──────────────────────────────────────┬─────────────────────────────────────┘
                                       │
┌──────────────────────────────────────▼─────────────────────────────────────┐
│ 第 1 层：AS 内核钩子（AngelscriptEngine.cpp::AngelscriptLineCallback）     │
│   if (CodeCoverage != nullptr) {                                           │
│       int Line = Context->GetLineNumber(0, &Column, nullptr);              │
│       FString ModuleName = ANSI_TO_TCHAR(Function->GetModuleName());       │
│       Module = AngelscriptManager.GetModule(ModuleName);                   │
│       CodeCoverage->HitLine(*Module, Line);  // ★ 加 1                     │
│   }                                                                        │
│                                                                            │
│   UpdateLineCallbackState():                                               │
│     if (CodeCoverage != nullptr) {                                         │
│       bEverRunLineCallback   = true;                                       │
│       bAlwaysRunLineCallback = true;   // ★ 强制全模块都触发 SUSPEND       │
│     }                                                                      │
└──────────────────────────────────────┬─────────────────────────────────────┘
                                       │
┌──────────────────────────────────────▼─────────────────────────────────────┐
│ 第 0 层：AS 内核 SUSPEND 触发（as_context.cpp::ExecuteNext）               │
│   case asBC_SUSPEND:                                                       │
│     if (CanEverRunLineCallback)                                            │
│       if (ShouldAlwaysRunLineCallback || module->hasBreakPoints)           │
│         m_lineCallback(this);                                              │
└────────────────────────────────────────────────────────────────────────────┘
```

Coverage 与 Debugger 都接在第 0/1 层的同一个 `m_lineCallback` 上，所以**它们是"并行而非互斥"的**——同一行字节码上 `AngelscriptLineCallback` 会先把帧栈刷给 Debugger（如果在调试），再给 Coverage 加 1。但二者驱动 `ShouldAlwaysRunLineCallback` 的条件不同：Debugger 仅在 step / pause / data breakpoint 时把它拉高，平时它依赖 `module->hasBreakPoints` 局部门控；而 Coverage 一开机就把它**永远拉高**，因此哪怕脚本里没有任何断点，每条 `asBC_SUSPEND` 也都会派发 callback。

后续章节按"**编译期映射 → 运行期统计 → 钩子门控与三方协同 → 报告输出格式 → Test Automation 集成 → 与 StaticJIT / HotReload / StateDump 的互动 → 限制与避坑**"的顺序展开。

---

## 一、概念：行号映射与 Hit Count

### 1.1 什么是"可执行行"

Coverage 关心两个数：**总可执行行数 NumExecutableLines** 与 **被命中的行数 NumLinesHit**。它们都来自同一份 `TMap<int, int> HitCounts`：键是 `.as` 源文件中的 1-based 行号，值是该行被 callback 命中的次数（值 = 0 表示该行**已映射但从未执行**）。`FLineCoverage` 把这些数据按文件（`RelativeFilename`）一组一组地维护：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/LineCoverage.h
// 类型: FLineCoverage（per-file 覆盖数据载体）
// ============================================================================
struct FLineCoverage
{
    int NumExecutableLines() const { return HitCounts.Num(); }
    int NumLinesHit() const
    {
        int LinesHit = 0;
        for (const TPair<int, int>& Hit : HitCounts)
            if (Hit.Value > 0) LinesHit++;
        return LinesHit;
    }

    void PruneGeneratedCode(int Cutoff);  // 按"源文件实际行数"截掉生成代码
    TMap<int, int> HitCounts;             // ★ 行号 → 命中次数
    FString        AbsoluteFilename;      // 渲染 HTML 时载入源码
};
```

`PruneGeneratedCode` 是关键的"去除噪声"动作：AngelScript 的预处理器 / 编译器会把 `default` 语句、`mixin` 注入、内置 stub 等生成代码绑到一个**超出源文件真实行数的虚行号**（往往是几万行外的某个保留区段）。这些行不应被算进可执行总数，否则覆盖率会被生成代码稀释。Prune 在 `WriteFileCoverageReportHtml` 把源文件读到 `Lines` 数组之后被调用，那时才能拿到"原始行数"作为 cutoff。

### 1.2 数据结构总览

`FAngelscriptCodeCoverage` 的状态非常少，但每个字段都承载一种"模块级"或"文件级"的索引：

| 字段 | 类型 | 含义 |
|------|------|------|
| `FilesToCoverage` | `TMap<FString, FLineCoverage>` | 主存储；key = `Module->Code[0].RelativeFilename` |
| `bRecording` | `bool` | 总开关；`HitLine` 在它为 false 时直接 return |

从源码可以看到，这个子系统**没有任何 per-function 索引、也没有 per-line bitmap 的 packed 表示**——它直接用 `TMap<int, int>` 存稀疏行号映射，因为 AS 字节码里能成为 SUSPEND 触发点的"可执行行"远比文件总行数稀疏（参考 `FindNextLineWithCode` 的实现），而且 hit count 需要持续累加（不是 bool），因此 bitmap 反而不合适。

### 1.3 为什么是 hit count 而不是 boolean

`HitLine` 把 `*Count` 累加而不是简单置位：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp
// 函数: FAngelscriptCodeCoverage::HitLine
// ============================================================================
void FAngelscriptCodeCoverage::HitLine(FAngelscriptModuleDesc& Module, int Line)
{
    if (!bRecording) return;
    const FString& RelativeFilename = Module.Code[0].RelativeFilename;
    FLineCoverage* FileCoverage = FilesToCoverage.Find(RelativeFilename);
    if (FileCoverage == nullptr) {
        UE_LOG(Angelscript, Display,
            TEXT("Coverage: hit line %d in unmapped file %s"), Line, *RelativeFilename);
        return;
    }
    int* Count = FileCoverage->HitCounts.Find(Line);
    if (Count != nullptr) (*Count)++;       // ★ 累加而非置 1
}
```

保留次数有两个用途：① 在 HTML 报告里把命中数写进 `<span title="The line was hit %d times">`，方便定位"循环里大量命中的热行"；② 单元测试（特别是 `Angelscript.TestModule.AngelScriptSDK.*` 那种内核覆盖测试）有时用 hit count 作为"这条字节码至少执行了 N 次"的弱断言。

### 1.4 行号映射的来源：FindNextLineWithCode

`HitCounts` 不是 hit 时才插入，而是在编译完成时通过 **`MapExecutableLines` → `MapFunction` → `asCScriptFunction::FindNextLineWithCode`** 预先填充：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp
// 函数: FAngelscriptCodeCoverage::MapFunction
// ============================================================================
void FAngelscriptCodeCoverage::MapFunction(asCScriptFunction* F, TMap<int, int>& HitCounts)
{
    int DeclaredAt = F->scriptData->declaredAt & 0xFFFFF;
    int FirstExecutableLine = F->FindNextLineWithCode(DeclaredAt);
    int Current = FirstExecutableLine;
    int Last = Current;
    while (Current != -1) {
        HitCounts.Add(Current, 0);                   // ★ 0 = 已映射但未命中
        Last = Current;
        Current = F->FindNextLineWithCode(Current + 1);
    }

    if (F->GetReturnTypeId() == asTYPEID_VOID)
    {
        // void 函数末尾的隐式 return 也是一条字节码，但视觉上让"空 void"
        // 看起来"有一条不可执行的行"很怪——直接砍掉最后一行。
        HitCounts.Remove(Last);
    }
}
```

`FindNextLineWithCode(line)` 来自 AS 内核 `asCScriptFunction`：它扫 `scriptData->lineNumbers`（编译期产出的"字节码偏移 → 源行号"双数组），返回 `>= line` 的第一条**有字节码**的行。一些细节：
- 构造函数的 line numbers 因成员"声明处即初始化"会乱序，所以 AS 内核内部会先把它们 `qsort` 再线性查找（详见 `as_scriptfunction.cpp:888` 的特殊路径）。
- 行号的低 20 位 (`& 0xFFFFF`) 是行号本身，高位预留给 section 索引——`MapFunction` 进来前已经做了掩码。
- 全局函数与类方法分两路调用：`MapExecutableLines` 先遍历 `ScriptModule->GetFunctionCount()`（全局函数），再遍历 `GetObjectTypeCount` × `GetMethodCount`（类方法），并通过 `Method->objectType != Type` 判断滤掉继承下来的"实际不在该类声明的方法"。

### 1.5 一个文件 ≠ 一个模块

`MapExecutableLines` 用 `Module->Code[0].RelativeFilename` 作为 key——这是一个**简化模型**：每个 `FAngelscriptModuleDesc` 在该 fork 下事实上是 1 模块 1 入口文件 + 若干 `#include`/Section 段，但 Coverage 只索引 `Code[0]` 那个入口文件。这意味着：
- 通过 `#include` 拼进同一模块的子文件，目前**不会出现在 Coverage 报告中**——它们的行号会被映射到主文件里去（这是 AS 编译器自己的 source mapping 行为）。
- 多模块共享同一物理 `.as` 文件的场景几乎不存在（AS 模块语义就是按文件组织的），但万一发生，会触发 `FilesToCoverage.Contains` 后的 `HitCounts.Empty()` 重映射。

---

## 二、运行期统计：HitLine 的触发链路

### 2.1 SUSPEND 触发器：AS 内核侧的入口

AS 内核没有"逐字节码 line callback"——它只在 `asBC_SUSPEND` 这个**专用 opcode** 上触发：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.cpp
// 函数: asCContext::ExecuteNext (节选 SUSPEND 分支)
// ============================================================================
case asBC_SUSPEND:
    if (CanEverRunLineCallback) {
        if (ShouldAlwaysRunLineCallback ||
            (m_currentFunction->module && m_currentFunction->module->hasBreakPoints))
        {
            if (m_lineCallback) {
                m_regs.programPointer    = l_bc;
                m_regs.stackPointer      = l_sp;
                m_regs.stackFramePointer = l_fp;
                m_lineCallback(this);   // ★ 唯一入口
            }
        }
    }
    if (++m_loopDetectionCounter > 100000) { /* loop detection */ }
    break;
```

编译器在每条"行尾"（语句结束）插入一条 `asBC_SUSPEND`，作为**"可观测点"**。这条 opcode 在没人看的时候是廉价的：仅做两次静态布尔检查 + loop-detection 计数；只有当 `CanEverRunLineCallback && (ShouldAlwaysRunLineCallback || module->hasBreakPoints)` 同时成立时，才走真正的 callback 调用。

这两个布尔是 `asCContext` 上的**静态成员**：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.h:185
// 类型: asCContext 静态门控（单进程全局）
// ============================================================================
static bool CanEverRunLineCallback;       // 是否有任何 callback 注册
static bool ShouldAlwaysRunLineCallback;  // 是否对全部模块强制触发
```

它们由 `FAngelscriptEngine::UpdateLineCallbackState()` 统一管理（详见本文 §3.2）。

### 2.2 第二级派发：AngelscriptLineCallback

`AngelscriptLineCallback` 是 fork 在 UE 这一侧注册到 context 上的统一入口（见 `AngelscriptEngine.cpp:5876`）。它会**串行**地把请求转给三个互不相干的子系统：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: AngelscriptLineCallback（节选三方派发）
// ============================================================================
void AngelscriptLineCallback(asCContext* Context)
{
    if (!IsInGameThread()) return;
    if (GAngelscriptLineReentry) return;
    GAngelscriptLineReentry = true;

    FAngelscriptEngine& AngelscriptManager = FAngelscriptEngine::Get();

#if WITH_AS_DEBUGVALUES
    // ── (a) 同步 GAngelscriptStack 调用栈快照（VS 本地 watch 用）……
#endif
#if WITH_AS_DEBUGSERVER
    if (auto* DebugServer = AngelscriptManager.DebugServer)
        DebugServer->ProcessScriptLine(Context);   // (b) DAP 协议侧
#endif
#if WITH_AS_COVERAGE
    if (AngelscriptManager.CodeCoverage != nullptr)
    {
        int Column;
        int Line = Context->GetLineNumber(0, &Column, nullptr);
        asIScriptFunction* CurrentFunction = Context->GetFunction(0);
        FString ModuleName = ANSI_TO_TCHAR(CurrentFunction->GetModuleName());
        TSharedPtr<struct FAngelscriptModuleDesc> Module
            = AngelscriptManager.GetModule(ModuleName);
        if (Module != nullptr)
            AngelscriptManager.CodeCoverage->HitLine(*Module, Line);   // ★
    }
#endif
    GAngelscriptLineReentry = false;
}
```

注意几个细节：
- **`IsInGameThread` 守护**：脚本理论上可以在异步任务里跑（虽然主线程绑定占绝大多数），非主线程不计入 Coverage——这是一种保守选择，避免并发写 `TMap`。
- **`GAngelscriptLineReentry` 重入保护**：line callback 内部如果又触发脚本（如 `ProcessScriptLine` 评估 watch 表达式时调用脚本函数），新一层执行不再回流 callback。否则 hit count 会被"自循环重复加"。
- **Coverage 是最后一棒**：先 DebugValues，后 DebugServer，最后 Coverage。三者顺序无关性来自"它们各写各的状态、互不读对方"，但顺序固定有助于 Debugger 用 stale stack 去查 hit 之前的状态。
- **行号查询代价**：`Context->GetLineNumber(0, &Column, nullptr)` 走的是 AS 内核 `asCScriptFunction::lineNumbers` 二分查找——按字节码偏移找 line，而不是把 line 写在 SUSPEND 操作数里。这是 SUSPEND 廉价的代价：每次命中要查一次。

### 2.3 模块查找：按 ModuleName 字符串

Coverage 拿到 `CurrentFunction->GetModuleName()` 之后用 **string lookup** 找 `FAngelscriptModuleDesc`：

```text
asIScriptFunction.GetModuleName()       (ANSI char*)
       ↓ ANSI_TO_TCHAR
FString ModuleName                       ("Examples.Core.MyActor")
       ↓
AngelscriptManager.GetModule(Name)       (TMap<FString, TSharedPtr<...>>)
       ↓
FAngelscriptModuleDesc                   (Code[0].RelativeFilename)
       ↓
CodeCoverage->HitLine(Module, Line)
       ↓
FilesToCoverage[Code[0].RelativeFilename].HitCounts.Find(Line) ← ★ ++
```

每条 SUSPEND 都做一次 `FString` 构造 + 哈希查找。这是 Coverage 开机后的"恒定开销"，见 §九避坑清单的实测建议。

---

## 三、钩子门控：与 Debugger 的三方协同矩阵

### 3.1 UpdateLineCallbackState：两个布尔的真值表

`FAngelscriptEngine::UpdateLineCallbackState` 是**唯一**改写 `asCContext::CanEverRunLineCallback` / `ShouldAlwaysRunLineCallback` 的入口，每次门控变化都要调用它：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::UpdateLineCallbackState
// ============================================================================
void FAngelscriptEngine::UpdateLineCallbackState()
{
    bool bEverRunLineCallback = false;
    bool bAlwaysRunLineCallback = false;

#if WITH_AS_DEBUGSERVER
    if (DebugServer != nullptr) {
        if (DebugServer->bIsDebugging)              bEverRunLineCallback   = true;
        if (DebugServer->DataBreakpoints.Num() != 0) bEverRunLineCallback   = true;
        if (DebugServer->bBreakNextScriptLine)       bAlwaysRunLineCallback = true;
    }
#endif

#if WITH_AS_COVERAGE
    if (CodeCoverage != nullptr) {
        bEverRunLineCallback   = true;       // ★
        bAlwaysRunLineCallback = true;       // ★ Coverage 强制全模块触发
    }
#endif

#if WITH_AS_DEBUGVALUES
    bEverRunLineCallback   = true;
    bAlwaysRunLineCallback = true;
#endif

    asCContext::CanEverRunLineCallback     = bEverRunLineCallback;
    asCContext::ShouldAlwaysRunLineCallback = bAlwaysRunLineCallback;
}
```

把这个函数的输入条件画成真值矩阵，更容易看清三方共存的代价分布：

| 状态组合 | CanEverRun | ShouldAlwaysRun | SUSPEND 行为 |
|---------|------------|-----------------|---------------|
| Coverage off + Debugger off + 无 DebugValues | false | false | **仅 loop detection 计数**，不查 callback 指针 |
| Coverage off + Debugger 已连接 / step / 有 data BP | true | true* | 全模块逐行回调 |
| Coverage off + Debugger 仅装载（未 step、无 data BP） | true | false | 只在 `module->hasBreakPoints` 模块逐行回调 |
| **Coverage on（任何组合）** | **true** | **true** | **全部 .as 模块每行触发 → CoverageHitLine** |
| WITH_AS_DEBUGVALUES（多见于编辑器构建） | true | true | 同上，并多一次帧栈刷新 |

(* 当 `bBreakNextScriptLine` 被 step / pause 拉高时为 true，平时仅 BP 模块。)

### 3.2 共享而非互斥

Coverage 与 Debugger 都接在 `m_lineCallback` 上、并通过 `UpdateLineCallbackState` 协作：
- **Coverage 单方面把 ShouldAlwaysRunLineCallback 拉成 true**——这导致"开了 Coverage 就等同于全程 step"——Debugger 端不会因此报错，反而省了一次 `module->hasBreakPoints` 局部判断；
- Debugger 在 step 状态结束后会把它落回 false，但只要 Coverage 实例存在，下一次 `UpdateLineCallbackState` 又会重新拉高。

这种"共享一个 callback、Coverage 永久强制全开"的策略，让 Coverage 永远拿到完整的执行轨迹，但代价是：**只要 Coverage 实例化，每个 .as 函数的每条字节码 SUSPEND 都会触发一次主线程 callback**——比 Debugger 的"按需开" 重得多。这也是为什么 `bEnableCodeCoverage` 默认关闭、且 `CoverageEnabled()` 在 `FAngelscriptEngine::Initialize` 里被读取一次后就把 CodeCoverage 实例化（不存在"运行期切开关"）。

### 3.3 与 ASBC_SUSPEND 在 StaticJIT 中的命运

JIT 里的 SUSPEND 是 no-op：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp:3827
// 节选: asBC_SUSPEND 的 JIT 翻译（直接返回 true）
// ============================================================================
IMPL_BYTECODE_BEGIN(asBC_SUSPEND)
{
    bool Implement(FStaticJITContext& Context) const override
    {
        return true;       // ★ JIT 翻译时 SUSPEND 直接被吞掉
    }
};
IMPL_BYTECODE_END(asBC_SUSPEND)
```

这意味着**只要某个脚本函数走了 jitFunction 快路径，它的所有 SUSPEND 就不会被执行**——Coverage 子系统对该函数的所有行**都看不到 hit**。详细互斥规则见本文 §六。

---

## 四、启用入口：CVar、配置与生命周期

### 4.1 CoverageEnabled 的双开关

`FAngelscriptCodeCoverage::CoverageEnabled` 是唯一的"是否启用"判定点：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp:45
// 函数: FAngelscriptCodeCoverage::CoverageEnabled
// ============================================================================
bool FAngelscriptCodeCoverage::CoverageEnabled()
{
    // 命令行（适合 CI）或 EditorPerProject 配置（适合本地）二选一
    return (GetDefault<UAngelscriptTestSettings>()->bEnableCodeCoverage ||
            FParse::Param(FCommandLine::Get(), TEXT("as-enable-code-coverage")));
}
```

`UAngelscriptTestSettings::bEnableCodeCoverage` 标记了 `Meta=(ConfigRestartRequired=true)`——意味着 Editor 改这个开关需要重启 Editor 才能生效，它**不是动态的**。原因很直白：Coverage 实例只在 `Initialize` 时创建一次。

### 4.2 实例化时机

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:1661
// 节选: FAngelscriptEngine::Initialize 里的 CodeCoverage 实例化
// ============================================================================
#if WITH_AS_COVERAGE
    if (FAngelscriptCodeCoverage::CoverageEnabled())
    {
        CodeCoverage = new FAngelscriptCodeCoverage;
    }
#endif
```

注意：
- `WITH_AS_COVERAGE` 的定义是 `#define WITH_AS_COVERAGE WITH_AS_DEBUGSERVER`（即 `(!UE_BUILD_TEST && !UE_BUILD_SHIPPING)`）。Shipping 与 Test 构建里**整个 Coverage 子系统不存在**——`CodeCoverage` 字段都不会被声明。
- 创建即"全程开启" `bEverRunLineCallback / bAlwaysRunLineCallback = true`，但 `bRecording = false`——也就是 `MapExecutableLines` 在 module 编译完后就跑（积累映射），`HitLine` 早期被忽略，等到 `StartRecording` 才开始累加。

### 4.3 测试钩子的 PostEngineInit 注册

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:1853
// 节选: 测试自动化钩子的延迟注册
// ============================================================================
#if WITH_EDITOR && WITH_AS_COVERAGE
    FCoreDelegates::OnPostEngineInit.AddLambda([&]()
    {
        if (CodeCoverage != nullptr)
            CodeCoverage->AddTestFrameworkHooks();
    });
#endif
```

`AddTestFrameworkHooks` 必须在 Engine 完整初始化之后执行，因为 `IAutomationControllerModule` 需要 `LoadModuleChecked` 才能拿到。这条注册仅在 `WITH_EDITOR` 环境（包括 PIE / Commandlet 编辑器）成立——因此 CI 用 Editor + `-as-enable-code-coverage` 是标准跑法。

### 4.4 排除模式：CoverageExcludePatterns

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp:206
// 函数: FAngelscriptCodeCoverage::IgnoredForCodeCoverage
// ============================================================================
bool FAngelscriptCodeCoverage::IgnoredForCodeCoverage(const FString& AsFilePath) const
{
    for (const FString& IgnoredPattern :
         GetDefault<UAngelscriptTestSettings>()->CoverageExcludePatterns)
    {
        if (AsFilePath.MatchesWildcard(IgnoredPattern))
            return true;
    }
    return false;
}
```

注意它**不影响 hit 统计**（被排除的文件依然在 `FilesToCoverage` 里、依然在 callback 里被加分）——只在 `WriteCoverageSummaries` 阶段决定"该不该把它放进 `FCoverageNode` 目录树"。也就是说：**单文件 HTML 仍然会写出**，但**目录 index.html / coverage_summary.json 不会汇总**它。这是一个微妙的设计：让你能临时浏览到某个被排除文件的覆盖率，但又不让它污染聚合数字。

---

## 五、报告输出：HTML 树 + JSON 摘要

### 5.1 输出目录结构

`StopRecordingAndWriteReport(OutputDir)` 默认把 `OutputDir = ProjectSavedDir/CodeCoverage`：

```text
Saved/CodeCoverage/
├── index.html                      ← 顶层目录摘要（COVERAGE_SUMMARY_HTML_HEAD）
├── coverage_summary.json           ← {total: {...}, coverage: [{name, ...}]}
├── Examples/
│   ├── index.html                  ← Examples/ 子目录摘要
│   ├── Core/
│   │   ├── index.html
│   │   ├── MyActor.as.html         ← per-file 报告（绿/红高亮）
│   │   └── MyComponent.as.html
│   └── Extended/
│       ├── index.html
│       └── ...
└── Tests/
    ├── index.html
    └── _SomeTest.as.html
```

每一层子目录都有 `index.html`，由 `WriteCoverageSummaryHtmlInternal` 后序遍历生成——叶子（`.as` 文件）已有自己的 HTML，目录则按"目录优先 + 字典序"排列子节点。

### 5.2 单文件 HTML：行内绿/红高亮

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/CoverageReportGenerator.cpp:50
// 函数: WriteFileCoverageReportHtml（节选高亮逻辑）
// ============================================================================
for (FString& Line : Lines)
{
    const int* HitCount = HitCounts.Find(CurrentLine);
    Line = Line.Replace(TEXT("<"), TEXT("&lt;"));
    Line = Line.Replace(TEXT(">"), TEXT("&gt;"));
    if (HitCount != nullptr)
    {
        if (*HitCount > 0)
        {
            Line = FString::Printf(
                TEXT("<span class=\"covered\" title=\"The line was hit %d times\">%s</span>"),
                *HitCount, *Line);
        }
        else
        {
            Line = FString::Printf(
                TEXT("<span class=\"not-covered\" title=\"This line was not hit\">%s</span>"),
                *Line);
        }
    }
    CurrentLine++;
}
```

注意：
- **HTML 编码只做 `<` / `>`**——AS 源码里 `&` 不会被显式转义，但 ASCII 源码下罕见有歧义；
- **`title` 属性带 hit count**——读者鼠标悬停到行上能看到具体次数；
- **`HitCount == nullptr`** 表示这一行**根本没被映射**（注释、空行、声明、`{` 单独一行等），UI 上不染色——这就是为什么报告里大段灰色行不算 miss。

### 5.3 目录 index.html 的样式分级

`StyleClassForCoverage` 决定行底色：

| 阈值 | 类名 | 颜色 |
|------|------|------|
| `> 80%` | `great` | 深绿 |
| `> 50%` | `good` | 浅绿 |
| `> 20%` | `ok` | 黄 |
| `≤ 20%` 或全为 0 | `bad` | 红（白字） |
| 总执行行 = 0 | （空） | 不染色 |

每行同时打了**stale-warning** JS：把 `Date.parse('{0}')` 当生成时间，超过 2 天就在页头红字提示 "This report is stale (N days old)!"。CI 跑出来的报告若被人当成快照查（而不是当天再跑），这个警告就会显眼。

### 5.4 JSON 摘要：coverage_summary.json

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/CoverageReportGenerator.cpp:300
// 函数: WriteTopLevelCoverageJson
// ============================================================================
TArray<TSharedPtr<FJsonValue>> Directories;
for (const TPair<FString, FCoverageNode*>& Child : Root.Children)
{
    auto Node = CountsToJson(Child.Value->Counts);
    Node->SetStringField(TEXT("name"), Child.Key);
    Directories.Add(MakeShared<FJsonValueObject>(Node));
}

auto Json = MakeShared<FJsonObject>();
Json->SetObjectField(TEXT("total"), CountsToJson(Root.Counts));
Json->SetArrayField(TEXT("coverage"), Directories);
```

`CountsToJson` 输出形如：

```json
{
  "total":    { "coverage_pct": 73.5, "lines_hit": 4321, "lines_total": 5878 },
  "coverage": [
    { "name": "Examples", "coverage_pct": 81.0, "lines_hit": 1620, "lines_total": 2000 },
    { "name": "Tests",    "coverage_pct": 0.0,  "lines_hit": 0,    "lines_total":  500 }
  ]
}
```

只有**顶层目录**进 JSON——这是面向 CI 仪表盘的"摘要"输出，并不替代 HTML 那种细粒度浏览。CI 一般把 `coverage_summary.json` 抓出来跟阈值比，再把整个 `Saved/CodeCoverage/` 作为 build artifact 上传。

### 5.5 目录树构建：AddCoverageLeaf 的多分隔符策略

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/CoverageReportGenerator.cpp:88
// 函数: AddCoverageLeaf
// ============================================================================
static const TCHAR* PathDelimiters[] = { TEXT("/"), TEXT("\\") };
TArray<FString> PathComponents;
Path.ParseIntoArray(PathComponents, PathDelimiters, 2, false);

FCoverageNode* Current = &Root;
for (const FString& Component : PathComponents)
{
    if (!Current->Children.Contains(Component))
        Current->Children.Add(Component, new FCoverageNode);
    Current = Current->Children[Component];
}

Current->Counts.NumLinesHit = Coverage.NumLinesHit();
Current->Counts.NumExecutableLines = Coverage.NumExecutableLines();
```

`/` 与 `\` **两种分隔符同时识别**——跨 Windows 与 Linux 路径不会因斜杠风格分裂出两棵不同的子树。`ComputeCoverage` 是后序遍历：叶子已经在 `AddCoverageLeaf` 里写了 counts，目录在递归回溯时把孩子们累加上来。

---

## 六、与 StaticJIT / HotReload / StateDump 的互动

### 6.1 与 StaticJIT 的天然互斥

如 §3.3 所述，JIT 翻译里 `asBC_SUSPEND` 是 no-op，因此**JIT 化的脚本函数不会触发 line callback、不会被 Coverage 看到**。具体表现：

| 场景 | jitFunction 是否存在 | Coverage 看到的覆盖率 |
|------|---------------------|------------------------|
| 标准 Editor 构建（无 cooked PrecompiledData） | `nullptr`（解释器执行） | 准确 |
| Cooked 构建 + PrecompiledData 装载成功 | 非空（直接调用 .exe 中 transpile 后的 C++） | **0%**（看不到任何 hit） |
| Cooked 构建 + DataGuid 不匹配 → `FJITDatabase::Clear()` | `nullptr`（fallback 解释器） | 恢复准确 |
| `bScriptDevelopmentMode` | `nullptr`（HotReload 路径不走 JIT） | 准确 |

实践含义：**Coverage 报告应在 Editor 内 / 非 cooked 构建上跑**。CI 的 cook 构建走 JIT 路径，跑 Coverage 等于得到全 0 覆盖率。详见 `RT_StaticJIT.md` 的"`bUsePrecompiledData` 何时成立"判定式。

### 6.2 与 HotReload 的关系

`MapExecutableLines` 在 `CompileModule_Globals_Stage4`（即 `CompileModules` 链路的末尾）调用：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:4823
// 节选: 编译完成后重新映射 hit 表
// ============================================================================
#if WITH_AS_COVERAGE
    if (CodeCoverage != nullptr && !Module->bCompileError)
    {
        CodeCoverage->MapExecutableLines(*Module);   // ★ 重映射 → 旧 hit 被清零
    }
#endif
```

`MapExecutableLines` 内部对该模块的 `HitCounts.Empty()` 后再重写——**热重载会把该 `.as` 文件的 hit count 全部归零**。这是合理的：行号布局可能已经变了，旧 hit 失去意义。

但要注意：**reload 不影响 `bRecording`**。如果你在 Test Run 中途改动并保存了一个文件，HotReload 会把它的 hit 清零，但其他模块的 hit 仍然在累计——这通常不是问题，因为一次 Test Run 不会跨越 reload。

### 6.3 与 StateDump 的关系

`FAngelscriptStateDump::DumpCodeCoverage` 把 `FilesToCoverage` 拉成 CSV：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.cpp:1147
// 函数: FAngelscriptStateDump::DumpCodeCoverage
// ============================================================================
FCSVWriter Writer;
Writer.AddHeader({ TEXT("Filename"), TEXT("LineNumber"), TEXT("HitCount") });
#if WITH_AS_COVERAGE
    if (Engine.CodeCoverage != nullptr)
    {
        const TArray<TSharedRef<FAngelscriptModuleDesc>> ActiveModules
            = Engine.GetActiveModules();
        for (const TSharedRef<FAngelscriptModuleDesc>& Module : ActiveModules)
        {
            const FLineCoverage* Coverage = Engine.CodeCoverage->GetLineCoverage(*Module);
            if (Coverage == nullptr) continue;
            for (const TPair<int, int>& HitPair : Coverage->HitCounts)
            {
                if (HitPair.Value <= 0) continue;     // ★ 仅命中行入 CSV
                Writer.AddRow({
                    Coverage->AbsoluteFilename,
                    LexToString(HitPair.Key),
                    LexToString(HitPair.Value)
                });
            }
        }
        return SaveTable(OutputDir, TEXT("CodeCoverage.csv"), Writer);
    }
#endif

FTableResult Result = SaveTable(OutputDir, TEXT("CodeCoverage.csv"), Writer);
if (Result.Status == TEXT("Success"))
{
    Result.Status = TEXT("Skipped");
    Result.ErrorMessage = TEXT("Code coverage support is not compiled or no coverage recorder is active.");
}
return Result;
```

几个值得记住的契约点：
- **`CodeCoverage.csv` 只写命中行**（HitCount > 0）；未映射 / 未命中的行不在 CSV 里，需要回 HTML 报告才能看到 miss 详情。
- 默认 `Status = "Skipped"`（见 `AngelscriptDumpTests.cpp:90`）——Test 模块在 `GetExpectedSummaryStatus("CodeCoverage.csv")` 中显式期望 `Skipped`，因为 Dump 体系的端到端测试不开 Coverage。
- 一旦开了 Coverage 并且有数据，CSV 才会变成 `Success`。

详见 `RT_StateDump.md` 的"DumpAll 默认契约"和 `Arch_EditorTestDumpCollaboration.md` 的 27 表清单。

---

## 七、Test Automation 集成：Reset / Record / Write 三阶段

### 7.1 钩子注册与事件语义

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp:21
// 函数: FAngelscriptCodeCoverage::AddTestFrameworkHooks
// ============================================================================
void FAngelscriptCodeCoverage::AddTestFrameworkHooks()
{
    IAutomationControllerModule& AutomationModule =
        FModuleManager::LoadModuleChecked<IAutomationControllerModule>("AutomationController");
    IAutomationControllerManagerRef AutomationController
        = AutomationModule.GetAutomationController();

    AutomationController->OnTestsAvailable().AddRaw(this, &FAngelscriptCodeCoverage::OnTestsStarting);
    AutomationController->OnTestsComplete().AddRaw(this, &FAngelscriptCodeCoverage::OnTestsStopping);
}

void FAngelscriptCodeCoverage::OnTestsStarting(EAutomationControllerModuleState::Type Type)
{
    if (Type == EAutomationControllerModuleState::Type::Running)
        StartRecording();
}

void FAngelscriptCodeCoverage::OnTestsStopping()
{
    FString OutputDir = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("CodeCoverage"));
    StopRecordingAndWriteReport(OutputDir);
}
```

注意：
- `OnTestsAvailable` 在 Automation Controller 状态切换时多次触发，但 Coverage 只在 `Running` 状态那一刻 reset + 开始记录——避免 `Refreshing` / `Idle` 等中间态污染数据；
- `OnTestsComplete` 只触发一次，会做 `bRecording = false → WriteReportHtml → WriteCoverageSummaries` 三步；
- `AddRaw` 没有 `Remove`——`FAngelscriptCodeCoverage` 与 `FAngelscriptEngine` 的生命周期对齐，不存在中途反注册。

### 7.2 一次 Test Run 的时间线

```text
T0  EditorPostInit + FParse::Param(-as-enable-code-coverage)
    → CodeCoverage 实例化（bRecording = false）
T1  各 .as 模块 InitialCompile → CompileModule_Globals_Stage4
    → MapExecutableLines for each module
    → FilesToCoverage 填好行表（值全 0）
    → UpdateLineCallbackState：Can/ShouldAlways = true（永久）
T2  用户启动 "Run All Tests" / 命令行 -ExecCmds="Automation RunTests ..."
    → IAutomationControllerModule 内部状态 Refreshing → Running
    → OnTestsAvailable(Running) → StartRecording → ResetHits + bRecording=true
T3  AS 脚本逐行执行 → AngelscriptLineCallback → HitLine ++ HitCounts
T4  最后一个 test 跑完 → OnTestsComplete
    → StopRecordingAndWriteReport(ProjectSaved/CodeCoverage)
       ├─ bRecording = false
       ├─ WriteReportHtml（每个 .as → .as.html，并执行 PruneGeneratedCode）
       └─ WriteCoverageSummaries
            ├─ AddCoverageLeaf（按 IgnoredForCodeCoverage 过滤）
            ├─ ComputeCoverage（后序累加）
            ├─ WriteTopLevelCoverageJson（coverage_summary.json）
            └─ WriteCoverageSummaryHtmlInternal（每层 index.html）
```

### 7.3 ResetHits：值清零而不是表重建

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp:160
// 函数: FAngelscriptCodeCoverage::ResetHits
// ============================================================================
void FAngelscriptCodeCoverage::ResetHits()
{
    for (TPair<FString, FLineCoverage>& FileCoverage : FilesToCoverage)
        for (TPair<int, int>& Line : FileCoverage.Value.HitCounts)
            Line.Value = 0;
}
```

注意：**只清值，不动键**——`FilesToCoverage` / `HitCounts` 的 entry 集合是从编译期得到的，reset 时没有理由重新 map。这让 reset 成本只与"已映射行数"成正比，O(N) 但 N 不会因为 hit 多而变大。

### 7.4 没有 Test Framework 时的手动入口

`StartRecording` / `StopRecordingAndWriteReport` 是 `ANGELSCRIPTRUNTIME_API`，可以在自动化框架之外手动调用。比如某些 CI 用 commandlet 跑非 automation 的脚本批处理、想统计这一段的覆盖率：

```cpp
auto& Engine = FAngelscriptEngine::Get();
if (Engine.CodeCoverage != nullptr)
{
    Engine.CodeCoverage->StartRecording();
    // ... 跑你的脚本 ...
    Engine.CodeCoverage->StopRecordingAndWriteReport(OutputDir);
}
```

但这条路径的钩子 (`AddTestFrameworkHooks`) 仍然挂着——别忘了 Automation Controller 一旦进入 Running 状态，它会**再次** `ResetHits` 抢走你已经累计的数据。

---

## 八、限制与边界

### 8.1 不计入 Coverage 的代码

下列代码**永远不会**有 hit count，也不会染色：

1. **生成代码（generated AS）**：`default` 语句、`UPROPERTY ScriptMixin`、内置 stub 等，编译期被映射到一个超出源文件真实行数的"虚行"。这些行号会被填进 `HitCounts`，但 `WriteFileCoverageReportHtml` 跑完后会调 `PruneGeneratedCode(NumLinesInOriginal)` 把它们从表里移除——**HTML 第一次写出时它们还在，但 prune 是顺手的**（`WriteReportHtml` 循环里写完 HTML 紧接着 `PruneGeneratedCode`）。
2. **JIT 化函数**：见 §6.1，cooked + PrecompiledData 路径下整个函数失明。
3. **非游戏线程脚本**：`AngelscriptLineCallback` 头部 `IsInGameThread` 守护直接 return，跨线程 task 中跑的字节码不计。
4. **重入触发**：`GAngelscriptLineReentry` 防护下，line callback 内部触发的脚本不计 hit。
5. **`#include` 进同模块的子文件**：所有行被映射到 `Module->Code[0].RelativeFilename`（即主文件），子文件不会出现在报告里。
6. **空 void 函数末尾的隐式 return**：`MapFunction` 显式 `HitCounts.Remove(Last)` 把它砍掉，避免视觉噪声。
7. **`asTYPEID_VOID` 之外的函数尾行**：相反对于有返回值的函数，最后一行 `return X;` 会被保留——这是 hit 的"自然终点"。

### 8.2 不能指望的事

- **不要指望 Coverage 数据精确到列**：虽然 `AngelscriptLineCallback` 调 `GetLineNumber(0, &Column, nullptr)` 拿了列，但 Coverage 完全忽略 Column——因为 SUSPEND 是行级的。
- **不要指望 Coverage 替代 profiler**：hit count 是"行被 SUSPEND 的次数"，不是"该行真实执行了多少字节码"。同一行的多个表达式只算一次。
- **不要指望 Coverage 在 packaged shipping 里能用**：`WITH_AS_COVERAGE = WITH_AS_DEBUGSERVER`（即 `(!UE_BUILD_TEST && !UE_BUILD_SHIPPING)`），shipping 构建里整个子系统不存在。
- **不要指望关闭后零开销**：即使 `CoverageEnabled() == false`，`asBC_SUSPEND` 仍然在每条行尾被执行；只不过它在 `CanEverRunLineCallback == false` 时会快速跳过。

### 8.3 性能数量级估算

开启 Coverage 的运行期开销可拆为 4 部分：
1. **AS 内核 SUSPEND 检查** —— 始终在跑（无论开关），开销 < 1 ns / opcode；
2. **`AngelscriptLineCallback` 进入** —— 一次全局原子读 `GAngelscriptLineReentry`、一次 `IsInGameThread`、一次 `FAngelscriptEngine::Get()`，~10 ns；
3. **`CurrentFunction->GetModuleName()` + `ANSI_TO_TCHAR` + `GetModule(FString)`** —— 一次 ANSI→TCHAR 拷贝 + 哈希查找，几十 ns；
4. **`HitLine` 的 `TMap<int, int>::Find`** —— 哈希 + 比较，~20 ns。

合计每行 ~100–200 ns，对于一个一秒跑 1e6 SUSPEND 的负载，约 10–20% 主线程开销。这就是为什么 Coverage 默认关、且 ConfigRestartRequired——它是测试 / CI 工具，不是常驻开关。

---

## 附录 A：报告输出格式速查

| 文件 | 路径 | 内容 |
|------|------|------|
| 单文件 HTML | `Saved/CodeCoverage/<RelPath>.as.html` | 行内绿/红高亮的源码 |
| 目录 index | `Saved/CodeCoverage/<dir>/index.html` | 该层子节点列表 + 百分比 + stale-warning |
| 顶层 index | `Saved/CodeCoverage/index.html` | 顶层目录摘要 |
| 顶层 JSON | `Saved/CodeCoverage/coverage_summary.json` | `{ total: {...}, coverage: [{name, ...}] }` |
| Dump CSV | Dump 输出目录 / `CodeCoverage.csv` | `Filename, LineNumber, HitCount`（仅命中行） |

颜色阈值速查：

| 行覆盖率 | 类名 | 颜色（在 index.html）|
|---------|------|---------------------|
| `> 80%` | `great` | 深绿 |
| `> 50%` | `good` | 浅绿 |
| `> 20%` | `ok` | 黄 |
| `≤ 20%` 或全 0 | `bad` | 红（白字）|

`FCoverageCounts::ToString` 输出：
- `NumExecutableLines == 0` → `"N/A"`
- 否则 → `"%.1f%% (%d/%d)"`（命中%、命中数、总数）

---

## 附录 B：避坑清单 / 调试技巧

1. **Coverage 全空 / 报告写出但都是红色** → 检查是不是 cooked 构建走了 JIT 路径（见 §6.1）；或者 `CoverageEnabled()` 返回了 false（确认 `bEnableCodeCoverage` 配置文件落地、Editor 重启）。
2. **某个 `.as` 文件不在报告里** → 检查 `CoverageExcludePatterns`；或者它通过 `#include` 进了其他模块（行号被映射到主文件去了）。
3. **`Coverage: hit line N in unmapped file X` 日志刷屏** → 该 `.as` 模块编译错误（`bCompileError = true`），`MapExecutableLines` 被跳过；修编译错误即可。
4. **目录 index.html 与 .as.html 行数不一致** → `WriteReportHtml` 之后才会 `PruneGeneratedCode`，前者用的是 prune 前的总数、后者已 prune；这是已知现象，不是 bug。
5. **CI 报"This report is stale"** → JS 里硬编码 2 天阈值，调整脚本要去 `CoverageReportGenerator.cpp` 的 `COVERAGE_SUMMARY_HTML_HEAD` 模板。
6. **想跑 Coverage 但不通过 Automation Controller** → 直接调 `Engine.CodeCoverage->StartRecording() / StopRecordingAndWriteReport(dir)`，但要让 Automation 钩子停手，否则 Running 状态会再次 `ResetHits`。
7. **多 `FAngelscriptEngine` 实例（编辑器 + commandlet）共存** → `AngelscriptLineCallback` 通过 `FAngelscriptEngine::Get()` 解析当前 manager（依赖 `GAngelscriptEngineContextStack`），跨实例共用同一份 Coverage 时数据可能交错；当前 fork 默认场景下只有一个 manager，这个角落极少触发，但要排查时记得检查 `GetCurrentEngine()` 返回值。
8. **想在 Shipping / Test 构建里用 Coverage** → 不可能，整个子系统未编译进二进制，宏门控彻底；如果真有需要，得改 `WITH_AS_COVERAGE` 的定义并接受 SUSPEND 开销。
9. **`CodeCoverage.csv` 是 `Skipped`** → 默认契约：未启用 Coverage 时 Dump 该表落"跳过"，与端到端 Dump 测试期望一致；启用后才会变 `Success` 并真正写行。
10. **报告太大 / 难浏览** → 用 `coverage_summary.json` 配 CI 阈值检查；HTML 用作"挑出低覆盖率目录后局部下钻"。

---

## 小结

- Coverage 子系统的本质是"**搭车 line callback**"：它不写自己的字节码追踪，仅靠 `AngelscriptLineCallback` 在 `asBC_SUSPEND` 上打的钩子，把 `(ModuleName, Line) → HitCount++` 的累加做完。
- 数据布局极简：`TMap<FString, FLineCoverage>` 顶到底，`FLineCoverage::HitCounts` 是 `TMap<int, int>` 的稀疏行号映射；编译完成后由 `MapExecutableLines / FindNextLineWithCode` 一次性填好键集合，运行期只改值。
- 与 Debugger **共享同一个 `m_lineCallback`**、**并行不互斥**；与 Static JIT **天然失明**（jitFunction 跳过 SUSPEND）；与 HotReload **重映射时清零旧 hit**；与 StateDump 通过 `CodeCoverage.csv` 暴露命中行。
- 启用是单向票：`bEnableCodeCoverage` 或 `-as-enable-code-coverage` → `Initialize` 实例化 → `UpdateLineCallbackState` 永久把 `ShouldAlwaysRunLineCallback = true`；不存在运行时切开关。
- 报告输出三件套：每文件 HTML（绿/红行内高亮 + hit count tooltip）+ 每目录 `index.html`（按 80/50/20% 阈值染色 + stale-warning 脚本）+ 顶层 `coverage_summary.json`（CI 仪表盘消费）。
- Test Automation 集成走 `IAutomationControllerModule` 的 `OnTestsAvailable` / `OnTestsComplete` 两个委托，自动把 "Reset → Record → WriteReport" 串成一条流水线；也支持 `StartRecording` / `StopRecordingAndWriteReport` 手动触发。
