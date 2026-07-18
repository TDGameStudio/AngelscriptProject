# Arch_ErrorDiagnostics — 报错机制：编译诊断、错误收集与输出链路

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 跨层错误收集与输出（不深入单一编译阶段或单一日志通道实现细节）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` — `FDiagnostic` / `FDiagnostics` 结构（行 328-335 / 505-511）；`Diagnostics` / `LastEmittedDiagnostics` / `bDiagnosticsDirty` / `bIgnoreCompileErrorDiagnostics` 字段（行 520-524）；`ScriptCompileError` / `FormatDiagnostics` / `EmitDiagnostics` / `ResetDiagnostics` 接口（行 337-339 / 526-529）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — `LogAngelscriptError` 全局回调（行 5444-5517，AS 内核错误进入插件的唯一入口）；`ScriptCompileError` 三路重载（行 5358-5442）；`FormatDiagnostics` / `EmitDiagnostics` / `ResetDiagnostics`（行 4875-4951）；`SetMessageCallback` 注册位置（行 891 / 1643）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Compilation/AngelscriptCompilationEvents.h` / `.cpp`（编译事件多播、`DiagnosticCount` / `Messages` 字段）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` 行 144-174（`FAngelscriptDiagnostic` / `FAngelscriptDiagnostics` 网络消息）
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h` 行 309-313 / 586-593（`asEMsgType` / `asSMessageInfo` AS SDK 入口）
> · `ThirdParty/angelscript/source/as_scriptengine.cpp:1375` (`asCScriptEngine::WriteMessage`，AS 内核侧写出发起点)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptAdditionalCompileChecks.h`（游戏模块自定义检查回调）
> · `Plugins/Angelscript/Source/AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp`（错误定位回链）
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h` / `.cpp`（`FAngelscriptCompileTraceSummary` 测试侧采样）
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionBindingExporter.cs`（UHT C# 阶段失败上报）
> **关联文档**:
> `Arch_RuntimeLifecycle.md` · `AS_Compiler.md` · `RT_HotReload.md` · `RT_Debugger.md` · `Test_Infrastructure.md`

---

## 概览

本文聚焦一个核心问题：**脚本从 `.as` 进入插件后，编译/链接/类型生成/绑定阶段产生的错误，是怎么被收集、归类、并输出到 UE Log / 编辑器 UI / 调试器 / Test 报告这四条出口的？**

```text
"AngelScript 报错路径" 的核心矛盾
================================

矛盾一：错误来源极度异构
    (a) AS 内核 (asCBuilder/asCCompiler/asCContext) 报错时只有 const char*
    (b) 插件桥接层 (ClassGenerator / 重启动检查 / 模块导入) 报错时已经在 UE 世界
    (c) UHT C# 工具阶段 报错时甚至连 UE 进程都没起来
    它们要被汇成"统一的诊断流"

矛盾二：消息既要"立刻能看见"，又要"事后能取回"
    立刻看见: UE_LOG 输出到 OutputLog / 控制台 / log file
    事后取回: 编译失败弹框 / DebugServer 推送给 IDE / Test 用例 AddExpectedError 校验
    这两套需求决定了"必须双写：UE_LOG + 内存中的 Diagnostics 表"

矛盾三：热重载场景下"一次解析失败"会引发雪崩式后续误报
    解决方案: bIgnoreCompileErrorDiagnostics 标志 + 模块级 bCompileError + 提早 EmitDiagnostics

矛盾四：错误的"位置信息"必须能往回反查到 .as 文件:行
    AS 内核给的 (section, row, col) 字符串不一定是绝对路径
    要靠插件的 FAngelscriptModuleDesc::Code[].AbsoluteFilename 重新关联
    最后由 SourceNavigation 把它变成 VSCode/IDE 的可点击跳转
```

为应对上述矛盾，插件采用**单一中心收集器 + 多源汇入 + 多目标分发**的辐辐结构：

```text
┌────────────────────────────────────────────────────────────────────────┐
│ 多源汇入 (Ingress)                                                     │
│ ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐        │
│ │ AS 内核         │   │ 插件桥接层      │   │ UHT C# 工具     │        │
│ │ asCScriptEngine │   │ ClassGenerator  │   │ FunctionBinding-  │        │
│ │ ::WriteMessage  │   │ 模块导入检查    │   │ Exporter.cs     │        │
│ │ → asSMessageInfo│   │ 用法限制检查    │   │ → Console.Write │        │
│ └────────┬────────┘   └────────┬────────┘   │   Line + CSV    │        │
│          │                     │             └────────┬────────┘        │
│          ▼                     ▼                      ▼                 │
│   LogAngelscriptError   ScriptCompileError      (脱离 UE 进程)          │
│   (asMSGTYPE_*)         (UClass / Module 视角)                          │
└────────┬─────────────────────┬──────────────────────────────────────────┘
         │                     │
         ▼                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 中心收集器 FAngelscriptEngine::Diagnostics                              │
│ TMap<FString /*AbsoluteFilename*/, FDiagnostics>                        │
│ struct FDiagnostics { Filename / Diagnostics[] / bIsCompiling / ... }   │
│ struct FDiagnostic  { Message / Row / Column / bIsError / bIsInfo  }    │
│ 配套字段: bDiagnosticsDirty / bIgnoreCompileErrorDiagnostics            │
│                       LastEmittedDiagnostics（增量去重）                │
└────────┬────────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 多目标分发 (Egress)                                                    │
│ ┌─────────┐  ┌──────────────┐  ┌─────────────┐  ┌─────────────────┐    │
│ │ UE_LOG  │  │ FormatDiag-  │  │ EmitDiag-   │  │ Compilation-    │    │
│ │  到控制 │  │ nostics 拼  │  │ nostics 经  │  │ Events 多播      │    │
│ │  台/日 │  │ 字符串拼到   │  │ DebugServer  │  │ DiagnosticCount/│    │
│ │  志   │  │ 启动失败弹框 │  │ 推给 IDE    │  │ Messages         │    │
│ └─────────┘  └──────────────┘  └─────────────┘  └─────────────────┘    │
│                                          │                             │
│                                          ▼                             │
│                       Test 用例消费: CompileModuleWithSummary +        │
│                                      AddExpectedError +                │
│                                      FAngelscriptCompileTraceSummary   │
└────────────────────────────────────────────────────────────────────────┘
```

后续章节按 **来源 → 中心 → 出口 → 边角细节** 的顺序展开。

---

## 一、错误来源分类：哪三条流入"中心收集器"

### 1.1 AS 内核（`asCCompiler` / `asCBuilder` / `asCContext`）

AngelScript 内核唯一的错误入口是 `asIScriptEngine::WriteMessage(section, row, col, type, message)`，定义见 `as_scriptengine.cpp:1375`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp
// 函数: asCScriptEngine::WriteMessage（AS 内核所有错误/警告/信息的统一散发点）
// ============================================================================
int asCScriptEngine::WriteMessage(const char *section, int row, int col,
                                  asEMsgType type, const char *message)
{
    if (section == 0 || message == 0) return asINVALID_ARG;
    if (!msgCallback) return 0;          // 没注册回调就直接吞掉

    asSMessageInfo msg;
    msg.section = section;               // 通常是 .as 文件名（preprocessor 给的）
    msg.row     = row;  msg.col = col;
    msg.type    = type;                  // asMSGTYPE_ERROR/WARNING/INFORMATION
    msg.message = message;
    // 转给 SetMessageCallback 注册的回调（C 调用约定 / this-call 都支持）
    if (msgCallbackFunc.callConv < ICC_THISCALL)
        CallGlobalFunction(&msg, msgCallbackObj, &msgCallbackFunc, 0);
    else
        CallObjectMethod(msgCallbackObj, &msg, &msgCallbackFunc, 0);
    return 0;
}
```

`asEMsgType` 三种取值（`Core/angelscript.h:309-313`）：

| 枚举值 | 数值 | 含义 | 进入 UE_LOG 后的级别 |
|--------|------|------|----------------------|
| `asMSGTYPE_ERROR` | 0 | 编译错误，应当 abort 当前函数/类的编译 | `Error` |
| `asMSGTYPE_WARNING` | 1 | 编译警告，不阻断 | `Warning` |
| `asMSGTYPE_INFORMATION` | 2 | 上下文补充信息（如"前一个声明在 ..."） | `Log` |

`SetMessageCallback` 的注册位置在 `AngelscriptEngine.cpp:891` 的 `Initialize_AnyThread`（每个 `FAngelscriptEngine` 实例一次自己的注册）：

```cpp
Engine->SetMessageCallback(asFUNCTION(LogAngelscriptError), 0, asCALL_CDECL);
```

注意：**这是一个全局 C 函数**而非成员函数，因此它内部要靠 `FAngelscriptEngine::Get()`（栈顶引擎）找回当前归属。这种设计对"多 Engine 实例"场景隐含一个约束——参见 §七.1。

### 1.2 插件桥接层（`ClassGenerator` / 模块导入 / 用法限制）

插件代码自身不通过 AS 内核报错，而是直接调 `FAngelscriptEngine::ScriptCompileError`。它有三个重载，对应三种"报错时持有的句柄"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h（行 337-339）
// ============================================================================
// 重载 A：直接用绝对文件名 + 完整 FDiagnostic 结构（最低层）
void ScriptCompileError(const FString& AbsoluteFilename, const FDiagnostic& Diagnostic);
// 重载 B：知道 Module 描述符 + 行号 + 文本（最常用）
void ScriptCompileError(TSharedPtr<FAngelscriptModuleDesc> Module,
                         int32 LineNumber, const FString& Message, bool bIsError = true);
// 重载 C：UClass 视角（来源是某个 ASClass，行号靠 ClassDesc/MethodDesc 反查）
void ScriptCompileError(UClass* InsideClass, const FString& FunctionName,
                         const FString& Message, bool bIsError = true);
```

实际进入中心收集器的最底层实现：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::ScriptCompileError(AbsoluteFilename, Diagnostic) 行 5358
// ============================================================================
void FAngelscriptEngine::ScriptCompileError(const FString& AbsoluteFilename,
                                            const FDiagnostic& Diagnostic)
{
    bDiagnosticsDirty = true;                    // ★ 标脏：留给后续 EmitDiagnostics 决策
    auto& FileDiagnostics = Diagnostics.FindOrAdd(AbsoluteFilename);
    FileDiagnostics.Filename = AbsoluteFilename;
    FileDiagnostics.Diagnostics.Add(Diagnostic);

    if (Diagnostic.bIsError)  UE_LOG(Angelscript, Error,   TEXT("%s"), *Diagnostic.Message);
    else                       UE_LOG(Angelscript, Warning, TEXT("%s"), *Diagnostic.Message);
}
```

**关键观察**：插件桥接层的报错路径**不会经过 `LogAngelscriptError`**，它直接写入 `Diagnostics` 表 + `UE_LOG`。这就是"双写"模型——AS 内核错误经回调写两次（既 `UE_LOG` 也写表），桥接层错误也写两次。两条路径在内存收集器层汇合。

### 1.3 UHT C# 工具阶段

`AngelscriptUHTTool` 是 UE 构建期 C# 插件，它在 UE 进程之外运行，**完全不能用 `UE_LOG`、也不能写 `FAngelscriptEngine::Diagnostics`**。它的错误出口仅是构建产物：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionBindingExporter.cs（ExportClasses 末尾）
// ============================================================================
WriteSkippedDiagnosticsCsv(factory, skippedEntries);          // ★ 出口 1: skipped CSV
WriteSkippedDiagnosticsCsv(factory, skippedEntries);    // ★ 出口 2: 原因汇总 CSV
Console.WriteLine(
    "AngelscriptUHTTool exporter visited {0} packages, {1} classes, "
    + "{2} BlueprintCallable/Pure functions, reconstructed {3}, skipped {4}, "
    + "wrote {5} module files.",
    packageCount, classCount, functionCount,
    reconstructedCount, skippedCount, generatedFileCount);
```

错误**只出现在构建日志和 CSV**（产物中的 `AS_FunctionBindingStatistics.json` / 跳过条目 CSV）。它们和运行时的 `Diagnostics` 表完全解耦——诊断"运行时无法绑定到 C++ 函数"这类问题，**第一现场永远是构建日志而非编辑器 OutputLog**。

---

## 二、AS 内核错误回调：`LogAngelscriptError` 详解

`LogAngelscriptError` 是整个错误链路里**唯一被 AS 内核直接调用的函数**，它的实现细节决定了 UE_LOG 的格式和 `Diagnostics` 表的填充策略：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: LogAngelscriptError （行 5444-5517）
// 角色: AS 内核所有错误进入插件世界的唯一入口（C 风格全局函数）
// ============================================================================
void LogAngelscriptError(asSMessageInfo* Message, void* DataPtr)
{
    static FString PreviousSection;       // 函数级 static——同一文件连续多条
    static int32   PreviousType;          // 错误时只打一次 "Section:" 标头
    auto& Manager = FAngelscriptEngine::Get();

    if (Manager.bIgnoreCompileErrorDiagnostics)
        return;                            // ★ 雪崩抑制开关（见 §四.2）

    // 编译某些步骤会在 ParallelFor 工作线程上跑；CompilationLock 串行化写入
    FScopeLock MessageLock(&Manager.CompilationLock);

    const FString Section = ANSI_TO_TCHAR(Message->section);
    const bool bPrintSection = !Section.IsEmpty()
        && (PreviousSection != Section || PreviousType != Message->type);
    if (bPrintSection) { PreviousSection = Section; PreviousType = Message->type; }

    FString ErrorMessage = (Message->col || Message->row)
        ? FString::Printf(TEXT("(%d:%d): %s"), Message->row, Message->col,
                          ANSI_TO_TCHAR(Message->message))
        : FString(Message->message);

    // 按级别打 UE_LOG，先标头后正文
    if (Message->type == asMSGTYPE_INFORMATION) {
        if (bPrintSection) UE_LOG(Angelscript, Log, TEXT("%s:"), *Section);
        UE_LOG(Angelscript, Log, TEXT(" %s"), *ErrorMessage);
    } else if (Message->type == asMSGTYPE_ERROR) {
        if (bPrintSection) UE_LOG(Angelscript, Error, TEXT("%s:"), *Section);
        UE_LOG(Angelscript, Error, TEXT(" %s"), *ErrorMessage);
    } else {  // asMSGTYPE_WARNING
        if (bPrintSection) UE_LOG(Angelscript, Warning, TEXT("%s:"), *Section);
        UE_LOG(Angelscript, Warning, TEXT(" %s"), *ErrorMessage);
    }

    // ★ 选择性写入 Diagnostics 表：用 Find 而非 FindOrAdd——只接受
    //   CompileModules 启动期已预建 entry 的文件（过滤非编译期偶发警告）
    auto* FileDiagnostics = Manager.Diagnostics.Find(Section);
    if (FileDiagnostics != nullptr) {
        FileDiagnostics->Diagnostics.Add({
            ANSI_TO_TCHAR(Message->message),
            Message->row, Message->col,
            Message->type == asMSGTYPE_ERROR,
            Message->type == asMSGTYPE_INFORMATION
        });
        Manager.bDiagnosticsDirty = true;
    }
}
```

值得记一笔的两个细节：

1. **静态 `PreviousSection` / `PreviousType`** 是函数级 static，跨线程共享（受 `CompilationLock` 保护）。它的目的是减少 `[FileA.as]:` 反复打印的视觉噪声。
2. **`Diagnostics.Find` 而不是 `FindOrAdd`** —— 内核回调**不主动创建** entry。这就要求"插件桥接层在调 `BuildParallelParseScripts` 之前**先**为每个待编译文件 `FindOrAdd` 一个空 entry"，否则内核错误会被当作"非编译期错误"丢弃。这一步在 §四.1 的 `CompileModules` 阶段做。

---

## 三、错误对象结构：`FDiagnostic` / `FDiagnostics`

中心收集器存储两层结构（见 `AngelscriptEngine.h` 行 328-335 / 505-511 / 520-524）：

```cpp
// 单条诊断（值类型，可拷贝）
struct FDiagnostic {
    FString Message;     // 错误正文（去掉了 (row:col) 前缀）
    int32   Row;         // 1-based 行号；0 = 未指定
    int32   Column;      // 1-based 列号；0 = 未指定
    bool    bIsError;    // true: error；false: warning
    bool    bIsInfo;     // true: information（与 bIsError 互斥时双 false 视作 warning）
};

// 单文件聚合（按绝对路径分组）
struct FDiagnostics {
    FString             Filename;          // 绝对路径
    TArray<FDiagnostic> Diagnostics;       // 该文件累积的所有条目
    bool                bHasEmittedAny;    // 是否曾推送过给 DebugServer
    bool                bIsCompiling;      // 当前是否正在编译该文件
};

// 容器（FAngelscriptEngine 成员）
TMap<FString, FDiagnostics> Diagnostics;            // 主表：当前 build 累积
TMap<FString, FDiagnostics> LastEmittedDiagnostics; // 上一次推送给 IDE 的快照
bool bDiagnosticsDirty           = false;           // 收到任意新 entry 时置 true
bool bIgnoreCompileErrorDiagnostics = false;        // 雪崩抑制开关
```

字段读写责任：

| 字段 | 谁写 | 谁读 |
|------|------|------|
| `Diagnostics` | `LogAngelscriptError` / `ScriptCompileError` 三路 | `FormatDiagnostics` / `EmitDiagnostics` / `CollectCompileTraceDiagnostics` |
| `bDiagnosticsDirty` | 任何写入 → `true`；`EmitDiagnostics` 末尾 → `false` | `CompileModules` 末尾决策是否再次推送 |
| `bIgnoreCompileErrorDiagnostics` | `CompileModules` stage1 失败时置 `true`；`BuildCompleted` 后置 `false`（行 4275） | `LogAngelscriptError` 第一行的提前 return |
| `bIsCompiling` | `CompileModules` 启动时置 `true`（行 3463）；下一轮编译开始前置 `false`（行 3442） | `EmitDiagnostics` 决定是否推送"空 entry"清空 IDE squiggle |
| `LastEmittedDiagnostics` | （字段保留位，当前主要用 `bHasEmittedAny`）| 增量推送场景 |

---

## 四、错误聚合策略：模块级 / 文件级 / 表达式级

### 4.1 文件级：`CompileModules` 启动期的 `FindOrAdd`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::CompileModules（节选，行 3441-3464）
// 角色: 为每一个待编译文件预先建好 Diagnostics entry，
//       这是 AS 内核回调能写入收集器的前置条件
// ============================================================================
for (auto& Elem : Diagnostics)
    Elem.Value.bIsCompiling = false;

while (CompilationQueue.Num() != 0) {
    auto CurrentCompileList = MoveTemp(CompilationQueue);
    CompilationQueue.Reset();
    for (auto Module : CurrentCompileList) {
        // ★ 关键：为本轮要编译的每个 .as code section 都预建一个空 entry
        for (auto Section : Module->Code) {
            auto& Diag = Diagnostics.FindOrAdd(Section.AbsoluteFilename);
            Diag.Diagnostics.Reset();          // 上一次的诊断清掉
            Diag.Filename     = Section.AbsoluteFilename;
            Diag.bIsCompiling = true;          // 标记"该文件本轮在编译中"
        }
    }
}
```

**含义**：`Diagnostics` 表是按**绝对文件名**（不是模块名）做主键。这样一个模块 `Foo` 由 `Foo.as` + `#include` 的 `Bar.as` 组成时，错误会被分别记录到两个 entry，IDE 端通过 `Filename` 直接定位行内标注。

### 4.2 模块级：`bCompileError` 标志 + 雪崩抑制

每个模块描述符（`FAngelscriptModuleDesc`）有一个 `bCompileError` bool。它是 stage 间错误传染的载体：

```text
CompileModules 阶段表（节选）
================================

Stage 1: BuildParallelParseScripts（并行解析）
    Result != asSUCCESS → Module->bCompileError = true
                       → bHadCompileErrors = true

Stage 1.5: 雪崩抑制开关（行 3630-3631）
    if (bHadCompileErrors && CompileType != ECompileType::Initial)
        bIgnoreCompileErrorDiagnostics = true;  // ★ 后续 AS 内核错误丢弃

Stage 2: CompileModule_Functions_Stage2
    bCompileError 模块直接跳过（不再走代码生成）

Stage 后: ScriptEngine->BuildCompleted();
          bIgnoreCompileErrorDiagnostics = false; （行 4274-4275）
```

**为什么要抑制？** —— 一个 `.as` 文件解析失败，会导致它声明的所有类型在编译后续依赖它的模块时全部 unresolved，AS 内核会对**每一个引用都报一个 error**，量级可达数百条。第一波就足以让用户找到根因，后面纯属噪声。但这条策略只在 `SoftReloadOnly` / `FullReload` 下启用——**`Initial`（首次启动）不抑制**，因为首次启动失败必然要求全量诊断报告供用户决定要不要进入"重试编译"流程（见 §五.2）。

### 4.3 表达式级 + 自定义检查

- **表达式级**：`asCCompiler::CompileOperator` / `MatchFunctions` / `ImplicitConversion` 在 AS 内核内调 `WriteMessage` 报出，对插件而言它们和文件级错误没有任何形式区别——都经过 `LogAngelscriptError` 一条路径汇入 `Diagnostics`。详见 `AS_Compiler.md` 的"重载决议"节。
- **自定义检查**：游戏模块通过实现 `FAngelscriptAdditionalCompileChecks`（`ClassGenerator/AngelscriptAdditionalCompileChecks.h`）注入项目特定规则。在 `ScriptCompileAdditionalChecks` 内调 `FAngelscriptEngine::Get().ScriptCompileError(ModuleDesc, LineNumber, "msg")`，错误进入和 AS 内核同一张表。注册在 `FAngelscriptEngine::AdditionalCompileChecks`（`TMap<UClass*, ...>`）。

---

## 五、错误的三路输出

### 5.1 出口 1：`UE_LOG(Angelscript, ...)` —— 即时控制台

`Angelscript` 这个 log category 在 `AngelscriptEngine.h:34` / `.cpp:79` 声明并定义：

```cpp
ANGELSCRIPTRUNTIME_API DECLARE_LOG_CATEGORY_EXTERN(Angelscript, Log, All);
DEFINE_LOG_CATEGORY(Angelscript);
```

所有"错误立刻就看见"的需求（开发者控制台、log 文件、Output Log 标签）都通过 `UE_LOG(Angelscript, Error/Warning/Log, ...)` 满足。无论错误来自 AS 内核回调还是 `ScriptCompileError`，**都会一字不差地写一份 UE_LOG**。这是插件**唯一**约定的"立刻可见"机制。子 category 速查见附录 A.3。

### 5.2 出口 2：启动失败弹框 / `FormatDiagnostics`

`FormatDiagnostics()` 把 `Diagnostics` 表渲染成人类可读的多行字符串：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::FormatDiagnostics（行 4875-4894）
// ============================================================================
FString FAngelscriptEngine::FormatDiagnostics()
{
    FString Str;
    for (auto& FileDiagElem : Diagnostics) {
        if (FileDiagElem.Value.Diagnostics.Num() == 0) continue;
        Str += TEXT("\n") + FileDiagElem.Value.Filename + TEXT(":\n");
        for (auto& Diag : FileDiagElem.Value.Diagnostics) {
            if (Diag.Row || Diag.Column)
                Str += FString::Printf(TEXT("(%d:%d) "), Diag.Row, Diag.Column);
            Str += Diag.Message + TEXT("\n");
        }
    }
    return Str;
}
```

调用方主要是 `InitialCompile()` 失败分支（行 2381-2478），按部署形态分别决策：

- **非桌面平台 / 桌面但 Slate 未初始化**：`UE_LOG([StartupCompileFailure] ...)` + `FMessageDialog::Open` + `RequestExit(true)`。
- **桌面 + Slate 可用**：弹 Slate retry 模态窗，用户可以现场修脚本、点 Retry 触发热重载——这正是"开发模式启动失败但能现场修"的关键体验。

`FormatDiagnostics` 也被编辑器测试代码用作"测试断言失败时把当前所有诊断打入 `Test.AddError(...)`"（见 `AngelscriptBlueprintImpactScanTests.cpp:84/95`）。

### 5.3 出口 3：DebugServer / IDE 端 `EmitDiagnostics`

`EmitDiagnostics` 把诊断转成 `FAngelscriptDiagnostics` 网络消息推给 DAP 客户端：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::EmitDiagnostics（行 4901-4951，节选）
// ============================================================================
void FAngelscriptEngine::EmitDiagnostics(class FSocket* Client)
{
    for (auto Iterator = Diagnostics.CreateIterator(); Iterator; ++Iterator) {
        if (Iterator->Value.Diagnostics.Num() == 0) {
            // ★ 空 entry：曾推过 (bHasEmittedAny) 或本轮在编 (bIsCompiling)
            //    主动推一条"清空"消息让 IDE 取消旧的 squiggle
            if (Iterator->Value.bHasEmittedAny || Iterator->Value.bIsCompiling)
                EmitDiagnostics(Iterator->Value, Client);
            // ... 然后从主表里 RemoveCurrent，避免无限增长 ...
        } else {
            EmitDiagnostics(Iterator->Value, Client);
            Iterator->Value.bHasEmittedAny = true;
        }
    }
    bDiagnosticsDirty = false;
}
```

序列化用的是 `FAngelscriptDiagnostic` / `FAngelscriptDiagnostics`（见 `Debugging/AngelscriptDebugServer.h:144-174`）：

```cpp
struct FAngelscriptDiagnostic : FDebugMessage  { FString Message; int32 Line, Character; bool bIsError, bIsInfo; };
struct FAngelscriptDiagnostics: FDebugMessage  { FString Filename; TArray<FAngelscriptDiagnostic> Diagnostics; };
```

通过 DAP 协议推送到 IDE 客户端（VSCode AS 扩展等），客户端拿到后对应到当前打开文件的行级 squiggle。详见 `RT_Debugger.md`。

`EmitDiagnostics` 的调用时机有三处：

| 位置 | 动机 |
|------|------|
| `CompileModules` 类生成成功前（行 4349） | 类生成可能耗时数秒，先把诊断推出去让 IDE 已显示错误 |
| `CompileModules` 末尾，`bDiagnosticsDirty == true` 时（行 4533） | 类生成期间又新增了诊断（如 `VerifyPropertySpecifiers` 失败） |
| `PerformHotReload` 预处理失败分支（行 2789） | 早退路径，避免诊断丢失 |

### 5.4 出口 4：`FAngelscriptCompilationEvent` 多播事件

编译期间还有一条结构化的事件流，专为"自动化测试 / 运维监控"设计：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/Compilation/AngelscriptCompilationEvents.h
// 类型: FAngelscriptCompilationEvent（节选）
// ============================================================================
struct FAngelscriptCompilationEvent
{
    EAngelscriptCompilationEventType Type;     // CompileBegin/End, ModuleParse, ...
    ECompileType   CompileType;
    ECompileResult CompileResult;
    int32 ModuleCount, FileCount, ClassCount, FunctionCount;
    int32 DiagnosticCount;                     // ★ 来自 AddDiagnosticSummary
    TArray<FString> Messages;                  // ★ 全部 Diagnostic.Message 的扁平拷贝
    // ...
};
DECLARE_MULTICAST_DELEGATE_OneParam(FAngelscriptCompilationEventDelegate, const FAngelscriptCompilationEvent&);
```

填充逻辑见 `AngelscriptEngine.cpp:137-147` 的 `AddDiagnosticSummary`（遍历 `Diagnostics` 表，把 `++Event.DiagnosticCount` + `Event.Messages.Add(...)` 扁平化）。

**测试侧消费**：`CompileModuleWithSummary` 用类似方式生成 `FAngelscriptCompileTraceSummary` 给单元测试断言（见 `AngelscriptTestEngineHelper.cpp:35-53` 的 `CollectCompileTraceDiagnostics`）。两条流的字段镜像，但作用域不同：`CompilationEvent` 是全局多播（适合长期监听器），`CompileTraceSummary` 是按调用一次性返回的快照（适合单测断言）。

---

## 六、定位回链：从错误到 .as 文件:行的可点击跳转

错误对象里只有 `Filename + Row + Column` 字符串，要变成"点击 OutputLog 中的错误行能跳转到 VSCode 对应位置"还需要一层：**`AngelscriptSourceCodeNavigation`**。

```cpp
// ============================================================================
// 文件: AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp
// 类型: FAngelscriptSourceCodeNavigation : ISourceCodeNavigationHandler
// ============================================================================
virtual bool NavigateToFunction(const UFunction* InFunction) override
{
    auto* ASFunc = Cast<const UASFunction>(InFunction);
    if (ASFunc == nullptr) return false;
    FString Path = ASFunc->GetSourceFilePath();
    if (Path.Len() == 0) return false;
    OpenFile(Path, ASFunc->GetSourceLineNumber());   // ★ 经 OpenVsCode
    return true;
}
// 同样覆盖 NavigateToClass / NavigateToProperty / NavigateToStruct
// OpenVsCode 内部最终调 FPlatformMisc::OsExecute(nullptr, TEXT("code"), Params)，
// 用系统的 `code` 命令拉起 VSCode（参数携带 --goto File:Line）
```

注册位置 `RegisterAngelscriptSourceNavigation`（行 243）调 `FSourceCodeNavigation::AddNavigationHandler` 接入 UE 全局。之后编辑器内对脚本类/函数/属性的"打开源码"操作（蓝图右键 → Open Source File、Class Picker 等）都会路由到这里。

**关键边界**：这条 Handler 是给"**反射对象 → 源码**"用的（`UFunction*` / `UStruct*` 入参），它**不是**直接给 `Diagnostics` 表里的 `(Filename, Row)` 用的——后者由 IDE 端（VSCode AS 扩展）自行解析诊断消息字符串中的 `(row:col)`，是 IDE 协议层的责任。测试覆盖在 `SourceNavigationTests.cpp`，其中一例（line 125）是 `#ue57-headless` 已知 Disabled。

---

## 七、几条容易踩的坑

1. **`LogAngelscriptError` 全局静态 + `FAngelscriptEngine::Get()` 的"当前栈顶"耦合**
   - AS 内核在 worker 线程上回调时，必须保证该线程已经 push 了正确的 `FAngelscriptEngineScope`，否则 `Get()` 会 check 失败。
   - 多 Engine 实例（生产 Editor + N 个 PIE）并发编译时，谁先 push 谁就"接住"内核错误。`Initialize_AnyThread` 内部也走 `FAngelscriptEngineScope`（见 `Arch_RuntimeLifecycle.md` §四），所以这条耦合在正确架构内是闭合的。
   - 测试代码自建 Engine 时若忘了 `FAngelscriptEngineScope`，第一个内核错误就会触发 `[EngineResolve]` 失败日志。

2. **`bIgnoreCompileErrorDiagnostics` 的两个易混淆边界**
   - 仅在 `CompileType != ECompileType::Initial` 时启用。Initial（首次启动）失败时**不抑制**，必须给用户全量诊断。
   - 在 `BuildCompleted()` 之后立即复位（行 4275）。所以热重载结束后再触发的错误（例如 `CheckUsageRestrictions` 行 4301、`VerifyPropertySpecifiers` 行 4338）**会**正常进入收集器。

3. **内核错误进 `Diagnostics` 表必须有"预建空 entry"**
   - `LogAngelscriptError` 用 `Diagnostics.Find` 不是 `FindOrAdd`，所以**没在 `CompileModules` 启动期被预建 entry 的 .as 文件**，其内核错误会被丢弃只剩 `UE_LOG`。这是有意的过滤（避免绑定阶段的偶发警告污染编辑器 UI），但调试"为什么我的某个错误在 IDE 里看不到"时要记得这一层。

4. **`FormatDiagnostics` 输出顺序不稳定 / `CompilationLock` 颗粒度**
   - `Diagnostics` 是 `TMap`，遍历顺序由内部哈希决定，不是按编译顺序、不是按字典序。"启动失败弹框"截图比对测试要敏感这一点。
   - `LogAngelscriptError` 全程持有 `CompilationLock`，worker 线程的并行编译期间错误回调是串行的，大量错误（数百条）的场景下会拉慢"打印阶段"，偶有"编译似乎卡死"的错觉来自此。

5. **UHT 工具链的错误完全不在运行时收集器内**
   - UHT C# 失败只能从构建日志和 `AS_FunctionBindingStatistics.json` / 跳过 CSV 看到。运行时阶段拿到的"绑定缺失错误"实际是**症状**（脚本里 `FunctionA(...)` 未声明），根因要回构建日志里查 UHT 阶段是否报了 skip。

---

## 八、调试技巧与子系统耦合速查

### 8.1 常见 AS 错误模式

| 错误模式 | 切入点 |
|---------|-------|
| `unresolved type / no matching declaration` | 看 `[FileA.as]:` 标头**第一条**（其余多半是雪崩）；确认 `Bind_*.cpp` 是否注册类型；UFUNCTION 反射回退见 `AS_FunctionBindingStatistics.json` 与跳过 CSV |
| `ambiguous overload` | 看 `MatchFunctions` 代价表（`AS_Compiler.md`）；显式 cast 或加 alias 排除歧义 |
| `missing super() / property writable from non-init` | UE Fork 扩展（`allowEditPropertyAccess`）；搜 `ScriptCompileError` 调用点（`AngelscriptEngine.cpp:2870/2888/2906/...`） |
| `Could not find module ... to import` | 行号永远是 1（`ScriptCompileError(Module, 1, ...)` 行 3525），是模块级错误 |
| `Restricted usage of module X within Y` | 来自 `CheckUsageRestrictions`（行 5029），是用法限制规则；查 `UsageRestriction` 元数据 |

### 8.2 与其它子系统耦合

| 子系统 | 耦合点 | 方向 |
|--------|--------|------|
| **HotReload** | `bIgnoreCompileErrorDiagnostics` 抑制；`PreviouslyFailedReloadFiles` 失败重试（行 2370/2788） | 错误**反向影响**热重载（失败 → 标记重试） |
| **DebugServer** | `EmitDiagnostics` 出口；`FAngelscriptDiagnostic` 序列化 | 错误**前向输出**到 IDE |
| **BlueprintImpact** | 不直接消费 `Diagnostics`，但测试用 `FormatDiagnostics()` 做断言诊断（见 `AngelscriptBlueprintImpactScanTests.cpp:84/95`） | BP 重扫**复用编译事件**而非诊断 |
| **测试框架** | `AddExpectedError` + `CompileModuleWithSummary` | 测试**主动消费**诊断验证 |
| **State Dump** | 27 张 CSV 中**不包含** `Diagnostics`（瞬态不导出） | 解耦 |

---

## 附录 A：速查表

### A.1 AS 内核 `asEMsgType` ↔ `FDiagnostic` 映射

| 枚举 | 值 | UE_LOG 级别 | `bIsError` | `bIsInfo` |
|------|----|-------------|------------|-----------|
| `asMSGTYPE_ERROR` | 0 | `Error` | `true` | `false` |
| `asMSGTYPE_WARNING` | 1 | `Warning` | `false` | `false` |
| `asMSGTYPE_INFORMATION` | 2 | `Log` | `false` | `true` |

`FDiagnostic` 字段：`Message`（去除 `(row:col)` 前缀的原始文本）/ `Row`（1-based, 0=未指定）/ `Column`（同上）/ `bIsError` / `bIsInfo`。

### A.2 关键 log 前缀（搜索定位用）

| 前缀 / 关键短语 | 出现位置 | 含义 |
|-----------------|---------|------|
| `[StartupCompileFailure]` | `AngelscriptEngine.cpp:2387/2401` | 启动期编译失败导致非弹框 fallback |
| `[RuntimeStartup]` / `[EngineSubsystemStartup]` / `[EngineLifecycle]` | Bootstrap 链 | 见 `Arch_RuntimeLifecycle.md` |
| `[SourceNavigation]` | `AngelscriptSourceCodeNavigation.cpp:191` | SourceNavigation 缺当前 Engine |
| `Hot reload failed in preprocessing.` | `AngelscriptEngine.cpp:2787` | 热重载预处理失败 |
| `Hot reload failed due to script compile errors.` | `AngelscriptEngine.cpp:4295` | 热重载编译失败但已收集到诊断 |
| `Cannot run when angelscript has failed to compile.` | `AngelscriptEngine.cpp:2359` | Commandlet 模式下硬退出 |

### A.3 测试侧 API 速查

| API | 头文件 | 作用 |
|-----|--------|------|
| `CompileModuleWithSummary(...)` | `AngelscriptTestEngineHelper.h:48` | 编译单模块，返回结构化 `FAngelscriptCompileTraceSummary` |
| `CompileModuleWithResult(...)` | 同上 行 47 | 简化版，仅返回 `ECompileResult` |
| `FAngelscriptCompileTraceDiagnosticSummary` | 同上 行 10 | 测试侧 Diagnostic POD |
| `TestRunner->AddExpectedError(...)` | UE Automation API | 声明期望 Pattern 出现 N 次；命中扣除，未命中则测试失败 |
| `FAngelscriptEngine::ScriptCompileError(...)` | `AngelscriptEngine.h:337-339` | 测试也可主动注入诊断 |

---

## 小结

- **三源汇入 / 一表中心 / 四路出口**：AS 内核 `WriteMessage` + 插件 `ScriptCompileError` + UHT C# Console 输出，最终（除 UHT 外）都汇入 `FAngelscriptEngine::Diagnostics` 表，向 UE_LOG / 启动失败弹框 / DebugServer / 编译事件多播四路分发。
- **双写模型**：每条诊断都同时写 `UE_LOG`（即时看见）和 `Diagnostics` 表（事后取回）。两者**不**互相依赖，是平行的。
- **预建 entry 的契约**：AS 内核回调用 `Find` 而非 `FindOrAdd`——只有 `CompileModules` 阶段提前建好的 entry 才能接住内核错误。这是过滤偶发非编译期警告的关键。
- **雪崩抑制**：`bIgnoreCompileErrorDiagnostics` 在热重载场景下"一次解析失败后吞掉所有后续误报"，但首次启动不抑制——保留全量信息供失败弹框展示。
- **位置回链分两层**：`Diagnostics` 表给 IDE（DAP 协议）做行级 squiggle；UE 编辑器自身的"打开源码"操作走 `FSourceCodeNavigation` + `AngelscriptSourceCodeNavigation` Handler，调用系统 `code` 命令打开 VSCode。
- **解耦 UHT**：构建期的绑定生成失败永远不出现在运行时 `Diagnostics` 表中，去 `AS_FunctionBindingStatistics.json` 与跳过 CSV 看。
- **测试可观测**：`CompileModuleWithSummary` + `AddExpectedError` 两个机制让单测能精确断言"哪些错误必出现"和"哪些错误不应出现"。
