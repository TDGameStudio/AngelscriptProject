# Arch_UHTToolchain — UHT 工具链位置与边界

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 站在"构建期 vs 运行期"边界外侧看 `AngelscriptUHTTool` 这套 C# UBT plugin——读什么 C++ 头、产出哪些文件、怎么被 `AngelscriptRuntime` 模块消费、与手写 `Bind_*.cpp` 形成什么样的两层关系；不深入单个 `FBind` 内部如何把签名翻译成 `asITypeInfo*`（那是 `Type_BindSystem.md` / `AS_TypeRegistration.md` 的职责），也不深入反射 fallback 的具体绑定算法（那是 `Type_FunctionCaller.md` 的职责）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj` (~54 行，UBT plugin 项目文件)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs` (~173 行，`[UhtExporter]` 入口)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs` (~545 行，分片 / Summary / CSV 生成)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionSignatureBuilder.cs` (~135 行，签名抽取)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptHeaderSignatureResolver.cs` (~772 行，重载消歧 / API 宏识别)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` (~600+ 行，`AddFunctionEntry` / `FFuncEntry` 消费面)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h` (~430+ 行，`ERASE_*` 宏定义)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp` (~600+ 行，运行期消费 + 反射 fallback 入口)
> · `Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_*.cpp` (生成产物示例)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览（顶层视角，本文是其 §二.5 与 §三 关于 UHT 工具的细化展开）
> · `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — 模块清单与装载关系（本文 §二 与其 §六"AngelscriptUHTTool 不在 UE 模块加载体系内"互为参照）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — Bind 系统与 Native 绑定（运行期消费侧的内部细节）
> · `Documents/Knowledges/ZH/AS_TypeRegistration.md` — AngelScript 类型注册 API（被 `FBind` 间接调用的下层）

---

## 概览

本文聚焦一个核心问题：**`AngelscriptUHTTool` 这套 C# UBT plugin 在构建链路中究竟落在哪一段、读什么作为输入、写出哪三类产物、与运行期的 121 份手写 `Bind_*.cpp` 又如何在 `AngelscriptRuntime` 模块里组成"自动 + 手写"两层绑定？**

这是一道**边界题**而不是实现题。把这条边界讲清楚，三件事就一并讲清了：

```text
跨进程边界全景：构建期 (UBT) vs 运行期 (UE)
================================================================================
构建期（UnrealBuildTool 进程内，C# / .NET 8.0）
┌──────────────────────────────────────────────────────────────────────────────┐
│ ① 输入：12+ 个 UE 模块（AIModule / Engine / UMG / ...）的 UCLASS/UFUNCTION 头│
│        ▼ UnrealHeaderTool 解析成 UhtModule/UhtClass/UhtFunction              │
│                                                                              │
│ ② AngelscriptUHTTool（5 个 .cs）通过 [UhtExporter] 挂入                      │
│        Exporter / CodeGenerator / SignatureBuilder / HeaderResolver / 锚点  │
│        ▼ 写出 30 个分片 + Summary.json + 4 份 CSV                            │
│                                                                              │
│ ③ 产物落到 Plugins/Angelscript/Intermediate/Build/<Plat>/<Tgt>/Inc/          │
│        AngelscriptRuntime/UHT/AS_FunctionTable_*.cpp                         │
└──────────────────── ★ 构建期边界结束 ────────────────────────────────────────┘
                              │  [UhtExporter](ModuleName="AngelscriptRuntime")
                              ▼  →  UBT 编入 AngelscriptRuntime.dll/lib
运行期（UE 进程内，C++）
┌──────────────────────────────────────────────────────────────────────────────┐
│ ④ .dll 加载阶段：AS_FORCE_LINK 全局 FBind 注册到 EOrder::Late + 50           │
│ ⑤ FAngelscriptEngine::Initialize → CallBinds → 三层叠加：                    │
│     A. 121 个手写 Bind_*.cpp（直接调 AS API；与 ClassFuncMaps 无关）         │
│     B. UHT 直接绑定（ERASE_AUTO_*_PTR；FuncPtr.IsBound()==true）             │
│     C. UHT stub + 运行期反射 fallback（ERASE_NO_FUNCTION；走 UFunction Invoke）│
└──────────────────────────────────────────────────────────────────────────────┘
```

后续章节按"接入面 → 输入 → pipeline → 产物 → 运行期消费 → 与手写 Bind 的边界 → 增量与缓存 → BlueprintImpact 的非协同 → 边界总结"的顺序展开。

---

## 一、UBT plugin 的接入面：`.ubtplugin.csproj` 与 `[UhtExporter]`

### 1.1 项目类型与依赖：完全脱离 UE Module 体系

`AngelscriptUHTTool` 是**插件包内唯一不属于 UE Module 体系**的产物——`.NET 8.0` 类库 DLL，落在 `Binaries/DotNET/UnrealBuildTool/Plugins/AngelscriptUHTTool/` 下：

```xml
<!-- ============================================================================ -->
<!-- 文件: Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj
       角色: 把 5 个 .cs 编成 UnrealBuildTool 加载的旁路 DLL        -->
<!-- ============================================================================ -->
<TargetFramework>net8.0</TargetFramework>
<OutputType>Library</OutputType>
<OutputPath>..\..\Binaries\DotNET\UnrealBuildTool\Plugins\AngelscriptUHTTool\</OutputPath>
<TreatWarningsAsErrors>true</TreatWarningsAsErrors>           <!-- ★ 警告即错误 -->
<Nullable>enable</Nullable>
<!-- 四个 Reference 全部指向 UE 引擎自带的 .dll，不引用任何 Angelscript* 程序集 -->
<Reference Include="EpicGames.Build">  <HintPath>$(EngineDir)\Binaries\DotNET\UnrealBuildTool\EpicGames.Build.dll</HintPath></Reference>
<Reference Include="EpicGames.Core">   <HintPath>...EpicGames.Core.dll</HintPath></Reference>
<Reference Include="EpicGames.UHT">    <HintPath>...EpicGames.UHT.dll</HintPath></Reference>
<Reference Include="UnrealBuildTool">  <HintPath>...UnrealBuildTool.dll</HintPath></Reference>
```

四条 Reference 全部指向 UE 引擎本体——构建期 UHT 跑这一段时 Angelscript 自家 `.dll` 还没构造。`$(EngineDir)` 由旁置的 `.ubtplugin.csproj.props` 兜底（默认 `C:\UnrealEngine\UE_5.7\Engine`）。

### 1.2 `[UhtExporter]` 协议：UBT 怎么发现这套工具

入口文件 `AngelscriptFunctionTableExporter.cs` 用类型级 `[UnrealHeaderTool]` + 方法级 `[UhtExporter]` 两个特性向 UnrealHeaderTool 自我注册：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs
// 函数: Export
// 性质: 构建期入口；CppFilters 决定生成 .cpp 命名约定，ModuleName 决定哪个 UE 模块编入
// ============================================================================
[UnrealHeaderTool]
internal static class AngelscriptFunctionTableExporter
{
    [UhtExporter(
        Name = "AngelscriptFunctionTable",
        Description = "Exports Angelscript function table data",
        Options = UhtExporterOptions.Default | UhtExporterOptions.CompileOutput,
        CppFilters = ["AS_FunctionTable_*.cpp"],          // ★ 决定输出文件命名 glob
        ModuleName = "AngelscriptRuntime")]                // ★ 产物作为这个 UE 模块的源码编入
    private static void Export(IUhtExportFactory factory) { /* 委托给 CodeGenerator.Generate */ }
}
```

四个特性参数同时锁死了"在哪生成、生成多少、谁来编、和谁同名"四件事——`CompileOutput` 表示产物要被 UBT 编入下游模块；`CppFilters` 是一组**白名单** glob，仅匹配这些模式的 `.cpp` 才会被本 Exporter 覆盖/清理；`ModuleName = "AngelscriptRuntime"` 决定生成的 `.cpp` 落到 `Plugins/Angelscript/Intermediate/Build/<Plat>/<Tgt>/Inc/AngelscriptRuntime/UHT/` 下。

### 1.3 没有 LoadingPhase；纯构建期

`Arch_ModuleLoading.md` §六已论证"`AngelscriptUHTTool` 不在 UE 模块加载体系内"。其时序边界：

```text
UnrealBuildTool 启动 → 扫 .ubtplugin.csproj 并 build/load C# 程序集
   → 运行 UnrealHeaderTool 解析 UCLASS/USTRUCT/UFUNCTION
       → 调所有 [UhtExporter] 标注的方法
           ★ AngelscriptFunctionTableExporter.Export 在此被调用
       → 写出 AS_FunctionTable_*.cpp / Summary.json / CSV
   → UBT 把上述 .cpp 编入 AngelscriptRuntime.dll/lib
                    │ 至此构建期结束
                    ▼
UE 进程启动 → PostDefault → AngelscriptRuntime.StartupModule()
                    │ AS_FunctionTable_*.cpp 已是 .dll 一部分；
                    │ 静态 FBind 在 .dll 加载时构造，回调被 Engine.Initialize 调用
                    ▼
FAngelscriptEngine::Initialize → CallBinds → ClassFuncMaps 已注册完毕
```

**关键结论**：UHT 工具没有 LoadingPhase（这是 UE 模块概念）；不出现在任何 `Build.cs` 的 ModuleNames；"在 StartupModule 里调 UHT 工具"在概念上就是错的——UHT 早已退出，进程边界都不一样。

---

## 二、输入面：BlueprintCallable / BlueprintPure 元数据

### 2.1 入口扫描与过滤双闸门

`Export()` 调 `Generate()` 后再走一次统计路径。两条路径的判定函数完全一致——`IsBlueprintCallable`：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs
// 函数: IsBlueprintCallable
// 角色: 唯一的入口过滤器；非 BlueprintCallable / Pure 完全不出现在产物里
// ============================================================================
internal static bool IsBlueprintCallable(UhtFunction function)
{
    string functionFlags = function.FunctionFlags.ToString();
    return function.FunctionType == UhtFunctionType.Function &&
        (functionFlags.Contains("BlueprintCallable", StringComparison.Ordinal) ||
         functionFlags.Contains("BlueprintPure",     StringComparison.Ordinal));
}
```

`AngelscriptFunctionTableCodeGenerator.ShouldGenerate` 在此之上叠四条排除规则：

```cs
// 文件: AngelscriptFunctionTableCodeGenerator.cs · 函数: ShouldGenerate（节选）
if (classObj.HeaderFile == null || !IsSupportedHeader(classObj.HeaderFile.FilePath)) return false;   // ① /Private/ 头排除
if (!AngelscriptFunctionTableExporter.IsBlueprintCallable(function)) return false;                   // ② 双闸门
if (function.MetaData.ContainsKey("NotInAngelscript") ||
    (function.MetaData.ContainsKey("BlueprintInternalUseOnly") && !function.MetaData.ContainsKey("UsableInAngelscript")))
    return false;                                                                                    // ③ 显式 meta 排除
// ④ 单点 hardcode 黑名单（UUniversalObjectLocatorScriptingExtensions 等已知边界 case）
return !function.FunctionExportFlags.ToString().Contains("CustomThunk", StringComparison.Ordinal);
```

`IsSupportedHeader` 进一步排除 `/Private/` 头与 `InstancedSkinnedMeshComponent.h`（前者是 UE 模块私有实现头，后者是已知签名解析问题点）。

### 2.2 模块白名单：从 `AngelscriptRuntime.Build.cs` 反推

UHT 的 Session 视野里有几百个 module（依赖图全展开），但本工具**只为 `AngelscriptRuntime` 自己 + 它在 `Build.cs` 里依赖的模块**生成绑定。这条白名单不是硬编码，而是构建期反向解析 `Build.cs`：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs
// 函数: LoadSupportedModules（节选）
// 角色: 反向解析 AngelscriptRuntime.Build.cs 抽取依赖模块名
// ============================================================================
factory.AddExternalDependency(buildCsPath);                              // ★ 把 Build.cs 也声明为输入
foreach (string rawLine in File.ReadAllLines(buildCsPath))
{
    string line = rawLine.Trim();
    if (line.StartsWith("if (Target.bBuildEditor)")) inEditorBlock = true;
    if (line.Contains("DependencyModuleNames.AddRange")) inDependencyBlock = true;
    if (inDependencyBlock)
    {
        foreach (Match match in QuotedStringPattern.Matches(line))
        {
            allModules.Add(match.Groups[1].Value);
            if (inEditorBlock) editorOnlyModules.Add(match.Groups[1].Value);   // ★ bBuildEditor 内打 EditorOnly
        }
        if (line.Contains("});")) inDependencyBlock = false;
    }
    if (inEditorBlock && line == "}") inEditorBlock = false;
}
```

实际效果：当 `Build.cs` 加新依赖 `"NewSubsystem"`，UHT 下次跑就**自动**为它生成绑定，无需修改任何 `.cs`。`bBuildEditor` 块下的依赖（`UnrealEd`、`UMGEditor`）会被打 `EditorOnly`，对应输出被 `#if WITH_EDITOR` 包围。`AddExternalDependency(buildCsPath)` 让 UBT 把 `Build.cs` 当本 Exporter 的输入——**`Build.cs` 改了 UHT 一定重跑**。

---

## 三、生成 pipeline：四个 `.cs` 文件的协作

`Exporter.Export` 通过 `CodeGenerator.Generate` 串起整条主链路，单个 `(class, function)` 的处理顺序：

```text
CollectEntries → SignatureBuilder.TryBuild
                       │
                       ├─ HeaderResolver.TryBuild        优先：读源 .h，access + API 宏 + 重载消歧
                       │      命中 → 简化签名 ERASE_AUTO_METHOD_PTR / ERASE_AUTO_FUNCTION_PTR
                       │
                       └─ failure ∈ {non-public, unexported-symbol, overloaded-unresolved}? 放弃 → stub
                          其他 failure → 显式签名 ERASE_METHOD_PTR / ERASE_FUNCTION_PTR
                                                                              （含完整参数 + 返回类型）
                          完全无解 → ERASE_NO_FUNCTION()                   ← 进入运行期反射 fallback
                                                                                                  ↓
BuildShard / WriteGenerationSummary / WriteCoverageDiagnostics    （每模块 256 entries/shard 切分）
```

### 3.1 签名抽取的两层 fallback

`AngelscriptFunctionSignatureBuilder.TryBuild` 是签名抽取的统一入口，但它**先委托** `AngelscriptHeaderSignatureResolver.TryBuild`，仅当后者返回特定失败原因才走自己的"显式签名"路径：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionSignatureBuilder.cs
// 函数: TryBuild
// 角色: 两层 fallback 调度——HeaderResolver 拿到简化签名为优先；按 failureReason 决定下一步
// ============================================================================
if (AngelscriptHeaderSignatureResolver.TryBuild(classObj, function, out signature, out failureReason))
    return true;                                                  // ① 简化签名命中
if (failureReason == "non-public" || failureReason == "unexported-symbol")
    return false;                                                 // ② 直接放弃 → 进入 stub
if (failureReason == "overloaded-unresolved" && !IsWhitelistedDirectBindFallback(classObj, function))
    return false;                                                 // ③ 重载未消歧也放弃
// ④ HeaderResolver 失败但不是 ②③：用反射类型重建完整签名（显式重载形式）
//    ParameterProperties → BuildParameterType；ReturnProperty → BuildReturnType
signature = new AngelscriptFunctionSignature(/* ..., UseExplicitSignature = true */);
return true;
```

签名形态有四种宏组合 + 一种 stub：

| 形态 | 宏 | 触发条件 |
|------|-----|---------|
| 简化方法 | `ERASE_AUTO_METHOD_PTR(Class, Func)` | HeaderResolver 单候选公开导出 |
| 简化函数 | `ERASE_AUTO_FUNCTION_PTR(Class::Func)` | 同上（静态） |
| 显式方法 | `ERASE_METHOD_PTR(Class, Func, (Args), ERASE_ARGUMENT_PACK(Ret))` | HeaderResolver 多候选成功消歧、或 SignatureBuilder fallback |
| 显式函数 | `ERASE_FUNCTION_PTR(Class::Func, (Args), ERASE_ARGUMENT_PACK(Ret))` | 同上（静态） |
| **Stub** | `ERASE_NO_FUNCTION()` | 双层全失败、或类是 `UCLASS_INTERFACE` —— 转运行期反射 fallback |

`CollectEntries` 内的兜底逻辑：

```cs
// 文件: AngelscriptFunctionTableCodeGenerator.cs · 函数: CollectEntries（节选）
string eraseMacro = (classObj.ClassType == UhtClassType.Interface || classObj.ClassType == UhtClassType.NativeInterface)
    ? "ERASE_NO_FUNCTION()"                                          // 接口直接 stub
    : (AngelscriptFunctionSignatureBuilder.TryBuild(classObj, function, out var signature, out _)
        ? signature!.BuildEraseMacro()
        : "ERASE_NO_FUNCTION()");                                    // 失败也 stub
entries.Add(new AngelscriptGeneratedFunctionEntry(classObj.SourceName, function.SourceName, eraseMacro));
```

### 3.2 HeaderResolver 的核心机制

`AngelscriptHeaderSignatureResolver`（~772 行）是整条管线最复杂的部分——它直接读源 `.h` 做轻量级 C++ 词法解析。三件关键事：

- **去注释化的字符级扫描**：`GetSanitizedHeader()` 把行注释 / 块注释替换为等长空白（保留换行），结果按文件路径缓存——同一 `.h` 在 UHT session 中只读盘一次。
- **access 推断**：在 class body 内从开头扫到候选位置，状态机跟踪 `public:` / `protected:` / `private:`，仅 public 候选有资格走"直接 link"路径；否则记 `failureReason = "non-public"` 直接 stub。
- **API 宏判定 = 能否跨模块 link**：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptHeaderSignatureResolver.cs
// 函数: IsLinkVisible
// 角色: 决定能否直接拿 &Class::Func 作为函数指针——若不能则只能走 stub
// ============================================================================
bool functionHasApiMacro = ApiMacroPattern.IsMatch(declarationPrefix);   // ENGINE_API / UE_API / RequiredAPI
bool classHasApiMacro    = ApiMacroPattern.IsMatch(classDeclaration);
bool classIsMinimalApi   = classDeclaration.Contains("MinimalAPI", StringComparison.Ordinal);
bool isInlineDefinition  = declarationPrefix.Contains("inline ") ||
    declarationPrefix.Contains("FORCEINLINE") ||
    declarationPrefix.Contains("constexpr ") ||
    normalizedDeclaration.Contains('{');                                 // 内联实现也可 link
if (functionHasApiMacro || isInlineDefinition) return true;              // ★ 直接 link OK
return classHasApiMacro && !classIsMinimalApi;                           // ★ 类导出 + 非 MinimalAPI 也 OK
```

`UCLASS(MinimalAPI)` 是 UE 常见标注："只导出 RTTI 但不导出方法"——此类强制走 stub，否则跨 dll 调用未解析符号。`AngelscriptRuntime` 自身的类有短路：同模块没有 dll 边界，全部 public 方法默认可 link。

**重载消歧**：当类内有 N 个同名候选，HeaderResolver 用 UE 反射元数据（`UhtFunction.ParameterProperties.TypeTokens`）作基准，逐个候选解析声明、做 `NormalizeTypeText` 归一比较，恰好匹配 1 个则消歧成功；否则记 `overloaded-unresolved` 转 stub。

### 3.3 输出分片与 BuildShard

`MaxEntriesPerShard = 256` —— 单个 UE 模块的 entry 列表按这个上限切分，避免单文件过大拖慢编译（`Engine` 的 4054 entry 切出 16 个分片：`AS_FunctionTable_Engine_000.cpp` … `_015.cpp`）。

每个分片产物的骨架完全模板化——首部 `#include` 收齐、中部一行一个 `AddFunctionEntry`、尾部 timing 记录：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs
// 函数: BuildShard（节选）
// 角色: 单个 .cpp 分片源码模板；EOrder::Late + 50 让它在所有手写 Bind 之后跑
// ============================================================================
if (editorOnly) builder.AppendLine("#if WITH_EDITOR");                  // ★ EditorOnly 模块整体 #if 包围
builder.AppendLine("PRAGMA_DISABLE_DEPRECATION_WARNINGS");
builder.AppendLine("#include \"CoreMinimal.h\"");
builder.AppendLine("#include \"Core/AngelscriptBinds.h\"");
builder.AppendLine("#include \"Core/AngelscriptEngine.h\"");
builder.AppendLine("#include \"Core/FunctionCallers.h\"");
foreach (string include in includes)                                    // 排序去重的最短 include 路径
    builder.Append("#include \"").Append(include).AppendLine("\"");
builder.Append("AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AS_FunctionTable_")
    .Append(moduleShortName).Append('_').Append(shardIndex.ToString("D3"))
    .AppendLine("((int32)FAngelscriptBinds::EOrder::Late + 50, []()");  // ★ EOrder::Late + 50
// ... { AddFunctionEntry × N + RecordGeneratedFunctionTableShardTiming + UE_LOG }
```

`EOrder::Late + 50` 是设计核心：手写 `Bind_*.cpp` 大多用 `EOrder::Normal` / `Late` / `Late - 1`，UHT 生成的总比它们都晚——意味着 UHT 写入 `ClassFuncMaps` 后，再由 `Bind_BlueprintCallable.cpp`（最末批次）反查表完成真正的 AS 注册。

---

## 四、产物三类六文件

实际生成的产物（来自 `Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/`）：

| 文件名 | 类别 | 数量 | 写入函数 | 消费方 |
|--------|------|------|----------|--------|
| `AS_FunctionTable_<Module>_<NNN>.cpp` | 编译产物（C++） | 30 个分片，覆盖 12 个 UE 模块 | `BuildShard` | UBT 编入 `AngelscriptRuntime` 模块 |
| `AS_FunctionTable_Summary.json` | 总目录 | 1 | `WriteGenerationSummary` | 人工 / 监控脚本 / OpenSpec 验证 |
| `AS_FunctionTable_ModuleSummary.csv` | 每模块汇总 | 1 | `WriteModuleSummaryCsv` | 同上 |
| `AS_FunctionTable_Entries.csv` | 逐条目清单 | 1 | `WriteEntryCsv` | 覆盖率分析、回归比对 |
| `AS_FunctionTable_SkippedEntries.csv` | 跳过逐条 | 1 | `WriteSkippedEntriesCsv` | 排查"为什么这个函数没绑" |
| `AS_FunctionTable_SkippedReasonSummary.csv` | 跳过原因聚合 | 1 | `WriteSkippedReasonSummaryCsv` | 全局原因分布 |

### 4.1 分片 .cpp 长什么样

下面是一个真实分片首部 + 几行 entry 的样子：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_AIModule_000.cpp
// 性质: UHT 生成产物示例（156 entries / 1 shard for AIModule）
// ============================================================================
PRAGMA_DISABLE_DEPRECATION_WARNINGS
#include "CoreMinimal.h"
#include "Core/AngelscriptBinds.h"
#include "Core/AngelscriptEngine.h"
#include "Core/FunctionCallers.h"
#include "AIController.h"
// ... 27 行 include 省略

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AS_FunctionTable_AIModule_000(
    (int32)FAngelscriptBinds::EOrder::Late + 50, []()
{
    const double GeneratedFunctionTableStartSeconds = FPlatformTime::Seconds();
    FAngelscriptBinds::AddFunctionEntry(AAIController::StaticClass(), "ClaimTaskResource",
        { ERASE_AUTO_METHOD_PTR(AAIController, ClaimTaskResource) });        // ★ 直接绑定
    FAngelscriptBinds::AddFunctionEntry(AAIController::StaticClass(), "GetAIPerceptionComponent",
        { ERASE_NO_FUNCTION() });                                            // ★ stub（unexported-symbol）
    // ... 153 行省略
    const double GeneratedFunctionTableElapsedMilliseconds =
        (FPlatformTime::Seconds() - GeneratedFunctionTableStartSeconds) * 1000.0;
    FAngelscriptBinds::RecordGeneratedFunctionTableShardTiming(
        TEXT("AIModule"), 1, 1, 156, GeneratedFunctionTableElapsedMilliseconds);
    UE_LOG(Angelscript, Log, TEXT("[UHT] Registered %d generated BlueprintCallable entries for module %s shard %d/%d in %.3f ms"),
        156, TEXT("AIModule"), 1, 1, GeneratedFunctionTableElapsedMilliseconds);
});
PRAGMA_ENABLE_DEPRECATION_WARNINGS
```

注意三件事：`AS_FORCE_LINK` 防止链接器 dead-strip（`__attribute__((used, retain))`）；`AddFunctionEntry` 一行一个 entry——它**不**直接调 AS 注册 API，只把 `(UClass*, FunctionName) → FFuncEntry` 塞进 `ClassFuncMaps`（真正的 AS 注册在更晚阶段，详见 §五）；`RecordGeneratedFunctionTableShardTiming` + `UE_LOG` 让每个 shard 在 `Bind` 阶段打一条 ms 级耗时日志。

### 4.2 `Summary.json`：当前产物的全局视图

`Summary.json` 是一份人类可读的总目录，给 OpenSpec / Reports / CI 检视用：

```json
// 文件: AS_FunctionTable_Summary.json（节选）
{
  "totalGeneratedEntries": 5684,
  "totalDirectBindEntries": 3180,
  "totalStubEntries": 2504,
  "directBindRate": 0.5594651653764954,
  "stubRate": 0.44053483462350457,
  "totalShardCount": 30,
  "moduleCount": 12,
  "modules": [
    { "moduleName": "AIModule", "editorOnly": false, "totalEntries": 156, "directBindEntries": 109, "stubEntries": 47, "shardCount": 1 },
    { "moduleName": "Engine",   "editorOnly": false, "totalEntries": 4054, "directBindEntries": 1946, "stubEntries": 2108, "shardCount": 16 },
    { "moduleName": "UMG",      "editorOnly": false, "totalEntries": 753, "directBindEntries": 661, "stubEntries": 92, "shardCount": 3 },
    { "moduleName": "AngelscriptRuntime", "editorOnly": false, "totalEntries": 284, "directBindEntries": 180, "stubEntries": 104, "shardCount": 2 }
    // ... 8 个模块省略
  ]
}
```

——`directBindRate ≈ 56%` 是当前 baseline，剩 44% 走运行期反射 fallback。**这条比例**就是 OpenSpec 提案里"提升 BlueprintCallable 直接绑定覆盖率"类工作的度量目标。

### 4.3 跳过原因聚合

`AS_FunctionTable_SkippedReasonSummary.csv` 在 baseline 期非常干净——只有三类：

```text
FailureReason,SkippedCount
non-public,2314                 // 函数声明在 protected/private，不属于本工具的目标面
unexported-symbol,1263          // class 没有 _API 宏（如 MinimalAPI），跨 dll 拿不到指针
overloaded-unresolved,287       // 重载消歧失败（多候选签名都对不上反射类型）
```

三条原因彼此正交，定位"我加的 UFUNCTION 怎么没出现在 Direct entry 里"时，直接看 `AS_FunctionTable_SkippedEntries.csv` 找类名即可。

---

## 五、Runtime 端消费链路

UHT 生成的 `AS_FunctionTable_*.cpp` 编入 `AngelscriptRuntime.dll` 之后，运行期消费分两步：**(1) `.dll` 加载阶段**静态构造 `FBind` 对象，把 `(UClass*, Name) → FFuncEntry` 注入 `ClassFuncMaps`；**(2) `FAngelscriptEngine::Initialize`** 通过 `CallBinds` 触发所有 `FBind` 的 lambda 执行 + 接着用 `BindBlueprintCallable` 反向查表完成真正的 AS 注册。

### 5.1 `FFuncEntry` / `AddFunctionEntry`：表结构

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 角色: ClassFuncMaps 的 value 类型；ERASE_* 宏展开后填充这两/三个字段
// ============================================================================
struct FFuncEntry
{
    FGenericFuncPtr FuncPtr;                      // ★ 类型擦除的函数指针
    ASAutoCaller::FunctionCaller Caller;          // ★ 同上的"调用器"模板对象
    bool bReflectiveFallbackBound = false;        // 运行期反射 fallback 命中后置 true
};

#define ERASE_NO_FUNCTION()                FGenericFuncPtr{}, ASAutoCaller::FunctionCaller{}
#define ERASE_AUTO_METHOD_PTR(c,m)         MakeAutoMethodPtr(&c::m), ASAutoCaller::MakeFunctionCaller(&c::m)
#define ERASE_AUTO_FUNCTION_PTR(f)         MakeAutoFunctionPtr(&f), ASAutoCaller::MakeFunctionCaller(&f)
#define ERASE_METHOD_PTR(c,m,p,r)          /* 显式签名版本（含重载消歧），略 */
#define ERASE_FUNCTION_PTR(f,p,r)          /* 同上静态版本，略 */
```

`AddFunctionEntry` 只是 `TMap<UClass*, TMap<FString, FFuncEntry>>` 的一次插入——不调用任何 AS API；重复键的 entry **不覆盖**，先到先得（给"用户自己再生成一份补丁分片"留口子）。

### 5.2 `BindBlueprintCallable`：三层 fallback 在哪触发

真正"把 `FFuncEntry` 翻译成 AS 函数注册"是 `Bind_BlueprintCallable.cpp` 的活：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp
// 函数: BindBlueprintCallable（节选）
// 角色: 对每个 BlueprintCallable UFunction 查 ClassFuncMaps，命中 → 直接绑；否则反射 fallback
// ============================================================================
UClass* OwningClass = CastChecked<UClass>(Function->GetOuter());
FFuncEntry* Entry = nullptr;
if (OwningClass != nullptr)
{
    auto* map = FAngelscriptBinds::GetClassFuncMaps().Find(OwningClass);
    if (map) Entry = map->Find(Function->GetFName().ToString());
}
if (Entry == nullptr) return;                                  // ★ Layer 0: 表里没有 → 完全不绑

const bool bHasDirectNativePointer = Entry->FuncPtr.IsBound();
if (!bHasDirectNativePointer)
{
    // ★ Layer C: 反射 fallback —— UHT 写入了 ERASE_NO_FUNCTION() stub 时走这里
    if (!BindBlueprintCallableReflectionFallback(InType, Function, Signature, *Entry))
        return;
    return;
}
Entry->bReflectiveFallbackBound = false;                       // ★ Layer B: 直接绑定路径
// FGenericFuncPtr 是 asSFuncPtr 的镜像；直接 memcpy 进 ASFuncPtr，调 BindMethod / BindGlobalFunction
```

回到顶层视角，整个绑定面其实是**三层叠加**：

| 层 | 来源 | 注册时序 | 触发条件 | 适合 |
|----|------|---------|---------|------|
| A | 121 个手写 `Bind_*.cpp` | `EOrder::Normal` / `Late` / `Late - 1` | 直接调 `Method / BindGlobalFunction / ValueClass / ...` | 值类型 / 模板 / Mixin / 命名空间投影 / 时序敏感内核 |
| B | UHT 直接绑定 | `EOrder::Late + 50` | `ERASE_AUTO_*_PTR`，`FuncPtr.IsBound() == true` | `BlueprintCallable / Pure` 公开导出方法（~56%） |
| C | UHT stub + 运行期反射 fallback | 同上 + 当帧 fallback | `ERASE_NO_FUNCTION()`，`bReflectiveFallbackBound = true` | `non-public` / `unexported` / 重载未消歧（~44%） |

A 层与 B/C 层并列，B 与 C 互斥。手写 Bind 通常完全不进 `ClassFuncMaps`，bypass 掉 B/C 的 fallback 决策。

### 5.3 `LogGeneratedFunctionTableTimingSummary`：可观测出口

所有分片在 `BuildShard()` 里都内嵌一行 `RecordGeneratedFunctionTableShardTiming`。Engine 初始化收尾时统一打印——`FAngelscriptEngine::BindScriptTypes` 调 `ResetGeneratedFunctionTableTiming` → `CallBinds` → `LogGeneratedFunctionTableTimingSummary`，输出"最慢 shard / 最慢 module / total ms"三类指标，便于"哪条 UHT 分片导致 Editor 启动变慢"的快速定位。

---

## 六、与手写 `Bind_*.cpp` 的边界对比

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下有 121 个手写 `Bind_*.cpp` 与 UHT 生成的 `AS_FunctionTable_*.cpp` 共存。它们看着像（都是 `FBind` 静态对象），实际目标完全不同。

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp.cpp
// 性质: 手写 Bind_*.cpp 的极简形态——FApp 是纯静态命名空间，UHT 处理不了
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FApp((int32)FAngelscriptBinds::EOrder::Late, []
{
    FAngelscriptBinds::FNamespace ns("FApp");
    FAngelscriptBinds::BindGlobalFunction("bool CanEverRender()", FUNC_TRIVIAL(FApp::CanEverRender));
    FAngelscriptBinds::BindGlobalFunction("FString GetProjectName()", []() -> FString
    {
        return FApp::GetProjectName();
    });
});
```

`Bind_Console.cpp` 进一步走 `ValueClass<FScriptConsoleVariable<int32>>` + 4 个 Constructor 重载 + Destructor + 多个 Method —— 这种带模板特化、显式 lambda 包装的注册 UHT 工具完全做不了，只能手写。这就是手写 Bind 的底盘价值。

| 维度 | 手写 `Bind_*.cpp` | UHT 生成 `AS_FunctionTable_*.cpp` |
|------|---------------------|----------------------------------|
| 文件数 | 121（成熟期 baseline） | 30 个分片（按模块切分） |
| 输入源 | 直接的 C++ 类型 / 自定义结构 / 模板 | UE 反射元数据（`UCLASS` + `UFUNCTION(BlueprintCallable/Pure)`） |
| 命名约定 | `Bind_<Topic>.cpp`（命名自由） | `AS_FunctionTable_<Module>_<NNN>.cpp`（强制） |
| 注册方式 | 直接调 `Method / BindGlobalFunction / ValueClass / ReferenceClass / ...` | 仅调 `AddFunctionEntry`，由 `Bind_BlueprintCallable.cpp` 反查表完成真正注册 |
| 触发顺序 | `EOrder::Normal` / `Late` / `Late - 1`，按主题精细控制 | `EOrder::Late + 50`，统一在所有手写之后 |
| 类型覆盖 | 值类型、模板、Mixin、Delegate、Subsystem、Component、Math、Container、... | 只 `BlueprintCallable / BlueprintPure` |
| 直接 / Stub 比 | 几乎全部 100% 直接（手写时已知签名） | ~56% Direct + ~44% Stub（未来优化目标） |
| 维护权 | 人工 review；OpenSpec 一人一改 | 自动；只能调输入或调过滤规则间接改 |

**经验法则**：能机械推导的 UFUNCTION 留给 UHT；UHT 处理不了的（不在 `BlueprintCallable` 面、需要类型转换、需要包装 lambda、需要 mixin 投影）一律手写。

---

## 七、增量、缓存与外部依赖

`AngelscriptUHTTool` 没有自己实现 hash / mtime 增量——它直接依赖 UBT 的标准机制：

- `factory.AddExternalDependency(headerPath)` 把读到的每个源 `.h` 标记为本 Exporter 的输入；
- `factory.AddExternalDependency(buildCsPath)` 把 `AngelscriptRuntime.Build.cs` 也标记为输入（§二.2）；
- `factory.CommitOutput(outputPath, contents)` 走 UBT 的"内容 hash 比对"——文件没变就不写盘，从而不触发下游重编译。

```cs
// 文件: AngelscriptFunctionTableCodeGenerator.cs · 函数: CollectEntries（节选）
if (classObj.HeaderFile != null)
{
    factory.AddExternalDependency(classObj.HeaderFile.FilePath);                      // ★ UBT 增量依赖
    string includePath = factory.GetModuleShortestIncludePath(classObj.HeaderFile.Module, classObj.HeaderFile.FilePath);
    includes.Add(includePath.Replace('\\', '/'));
}
```

**心智模型**：UHT 工具看作"输入：所有依赖模块的 `.h` + `Build.cs`；输出：30 个分片 + 6 个 summary"的纯函数。任何上游变化都通过 UBT 的依赖追踪反映；UHT 自己不维护任何运行期状态。

**`DeleteStaleOutputs`** 处理"上轮生成、本轮不生成"的孤儿分片：枚举 `outputDirectory/AS_FunctionTable_*.cpp`，凡不在本轮 `generatedPaths` 集合内的全部删除——白名单 glob 与 `[UhtExporter](CppFilters)` 完全对齐。

**头文件去注释化的进程内缓存**：`AngelscriptHeaderSignatureResolver.GetSanitizedHeader` 用一个进程内 `Dictionary<string, string>` 把读过、去过注释的 `.h` 内容缓存住——同一 UHT session 内 N 个 class 引用同一 `.h` 时只读盘一次。生命周期就是 UHT session 自己（一次构建 = 一次 session），不需要持久化。

---

## 八、与 BlueprintImpact 的非协同

`Arch_EditorTestDumpCollaboration.md` 里 BlueprintImpact 是 Editor 路径的资产扫描器——按 `.as` 文件变更预测哪些 BP 需要重编。读者可能预期"UHT 生成的 function table 改了 BP 也要重扫"，**实际不是**。

```text
.as 文件改动                 UHT 工具改动 / 头文件改动
   │                             │
   ▼                             ▼
HotReload + ClassReloadHelper    UBT / UHT 增量
   │                             │
   ▼                             ▼
BlueprintImpact 扫描受影响 BP    AS_FunctionTable_*.cpp 重生成 → AngelscriptRuntime.dll 重编
   │                             │
   ▼                             ▼
BP 重新打开 / 重编译需要         整个 UE 进程重启（不是 reload）
```

UHT 跑在 UBT 进程内，结果作为 `.cpp` 编入 `.dll`；改动一定意味着 `.dll` 整体重链接，需要 UE 进程关掉再重起。**没有任何机制能在 UE 进程内热重载 UHT 产物**。所以"绑定面变化"不需要也无法触发 BP 重扫——UE 重启时所有 UClass 被重建，BP 自然按新反射元数据走过编译流程。这一段的潜台词是：UHT 工具链是"构建期一次性产物"，迭代节奏与 UE 进程内 HotReload / DirectoryWatcher / BlueprintImpact 完全脱钩。

---

## 九、边界总结

| 类别 | 做（Yes） | 不做（No） |
|------|-----------|-----------|
| 输入 | 读所有 UCLASS / UFUNCTION 头；读 `AngelscriptRuntime.Build.cs` 反推白名单 | 不读 `.as` 脚本（脚本侧反射在 Runtime 阶段） |
| 接入 | 通过 `[UhtExporter]` 协议挂入 UHT 流水线 | 不出现在任何 `Build.cs` 的 ModuleNames；没有 LoadingPhase |
| 产出 | 生成分片 `.cpp` + `Summary.json` + 4 份 CSV | 不直接调 AngelScript API（连 `EpicGames.UHT.dll` 之外都不引） |
| 时序 | 编入 `AngelscriptRuntime`；`EOrder::Late + 50` 在所有手写 Bind 之后跑 | 不参与 UE 模块装载；不与 BlueprintImpact / HotReload 联动 |
| 覆盖面 | `BlueprintCallable` / `BlueprintPure`（直接 ~56% / stub ~44%） | 不绑 `Event` / `NetMulticast` / 普通 `UFUNCTION`；不替代手写 Bind |

---

## 附录 A：构建产物速查表

| 路径模式 | 由谁写 | 何时写 | 由谁读 | 用途 |
|---------|--------|--------|--------|------|
| `Plugins/Angelscript/Source/AngelscriptUHTTool/*.cs` | 人工 | OpenSpec 提案 | UnrealBuildTool | UHT plugin 源码 |
| `Plugins/Angelscript/Source/AngelscriptUHTTool/*.csproj` | 人工 | 几乎不改 | UnrealBuildTool | C# 项目文件 |
| `Plugins/Angelscript/Binaries/DotNET/UnrealBuildTool/Plugins/AngelscriptUHTTool/*.dll` | UBT | 构建期 | UnrealBuildTool / UnrealHeaderTool | UHT plugin 程序集 |
| `Plugins/Angelscript/Intermediate/Build/<Platform>/<Target>/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_<Module>_<NNN>.cpp` | UHT | 头文件或 Build.cs 改动后 | UBT 编译进 `AngelscriptRuntime` | 分片绑定源码 |
| `<同上>/AS_FunctionTable_Summary.json` | UHT | 同上 | 人工 / OpenSpec / 监控脚本 | 全局指标 |
| `<同上>/AS_FunctionTable_ModuleSummary.csv` | UHT | 同上 | 同上 | 每模块覆盖率 |
| `<同上>/AS_FunctionTable_Entries.csv` | UHT | 同上 | 回归比对工具 | 逐条目快照 |
| `<同上>/AS_FunctionTable_SkippedEntries.csv` | UHT | 同上 | 排查"为什么没绑" | 跳过逐条 |
| `<同上>/AS_FunctionTable_SkippedReasonSummary.csv` | UHT | 同上 | 全局原因分布 | 优化目标排序 |

`<Platform>` = `Win64` 等；`<Target>` = `UnrealEditor` / `UnrealGame` / 自定义 target。

---

## 附录 B：常见问题与避坑

1. **新加的 `UFUNCTION(BlueprintCallable)` 没出现在分片里**——查 `AS_FunctionTable_SkippedEntries.csv`：常见原因是 `non-public`、`unexported-symbol`（`MinimalAPI` 类的方法）、或 `overloaded-unresolved`（重载未消歧）。前两者属于"刻意 stub"，第三者可考虑改类层 API 宏或显式重命名其中一个重载。
2. **修改了 `AngelscriptRuntime.Build.cs` 加新依赖但 UHT 没生成对应分片**——确认 `Build.cs` 改动后 UBT 真的重跑了 UHT。`AddExternalDependency(buildCsPath)` 让 Build.cs 进入依赖图；若改动后立即 build 但 UHT 未重跑，往往是 IDE 缓存问题——清 `Intermediate/Build` 后再来。
3. **手写 Bind 与 UHT 生成"双重注册"了同一个函数**——不会冲突。`AddFunctionEntry` 内 `if (!Map.Contains(Name)) Add(...)` 保证后到的不覆盖，而手写 Bind 通常不调 `AddFunctionEntry`，走 `BindGlobalFunction / Method` 直接到 AS。冲突的是 AS 层的"同名同签名"重复注册，需要手写时显式跳过该函数。
4. **想让 UHT 不为某个特定函数生成 stub**——加 meta `UFUNCTION(BlueprintCallable, meta=(NotInAngelscript))` 或 `meta=(BlueprintInternalUseOnly)`（不带 `UsableInAngelscript`），见 `ShouldGenerate` 的 ③。
5. **`directBindRate` 突然下降**——回归对比 `AS_FunctionTable_SkippedReasonSummary.csv` 的三类原因分布。`unexported-symbol` 涨了往往是 UE 升级时某些类改成 `MinimalAPI`；`non-public` 涨了通常是上游把 public 方法改成 protected；`overloaded-unresolved` 涨了大概率是新增重载未消歧。
6. **新加的 UE 模块不在 UHT 的 supported 白名单里**——确认它出现在 `AngelscriptRuntime.Build.cs` 的 `PublicDependencyModuleNames` 或 `PrivateDependencyModuleNames` 里。`LoadSupportedModules` 只识别这两类 + `bBuildEditor` 块；其他声明位置（如 `AddRange` 之外的写法）不会被扫描到。
7. **`AS_FunctionTable_*.cpp` 编译失败**——往往是某个 `#include "..."` 的相对路径在当前 target 配置下不可达。复查 `GetModuleShortestIncludePath` 输出与 UE 模块的 PublicIncludePaths；必要时把对应类加到 `IsSupportedHeader` 的硬黑名单（如 `InstancedSkinnedMeshComponent.h` 的处理方式）。
8. **想热重载 UHT 工具的改动**——做不到。改 `.cs` 必须重启 UBT 进程；改完之后通常需要 clean rebuild `AngelscriptRuntime`，因为 `AS_FunctionTable_*.cpp` 内容的变化会触发整模块重编。

---

## 小结

- **UHT 工具是一套构建期 C# UBT plugin**，通过 `[UhtExporter]` 协议挂入 UnrealHeaderTool 流水线，**不属于** UE Module 体系，没有 LoadingPhase，与 `AngelscriptRuntime` 的 StartupModule 无运行时关联。
- **输入**：UE 反射元数据（标记 `UFUNCTION(BlueprintCallable/Pure)` 的 C++ 头）+ `AngelscriptRuntime.Build.cs`（反向解析得到模块白名单）；**不读** `.as` 脚本。
- **生成 pipeline 四件套**：`Exporter`（入口 + 跳过统计）、`HeaderSignatureResolver`（去注释 / access / API 宏 / 重载消歧）、`SignatureBuilder`（HeaderResolver 失败时的显式签名 fallback）、`CodeGenerator`（按模块分片、Summary / CSV 写盘）。
- **产物三类六文件**：`AS_FunctionTable_<Module>_<NNN>.cpp`（30 个分片、5684 entries、`MaxEntriesPerShard = 256`）+ `Summary.json` + 4 份 CSV；通过 `[UhtExporter](ModuleName="AngelscriptRuntime")` 编入 Runtime 模块。
- **运行期消费三层**：Layer A 121 个手写 `Bind_*.cpp` 直接调 AS API；Layer B UHT 直接绑定（`ERASE_AUTO_*_PTR` ~56%）；Layer C UHT 写 stub 后由运行期反射 fallback 处理 ~44%。`EOrder::Late + 50` 让 UHT 注册在所有手写 Bind 之后；`AddFunctionEntry` 不覆盖同键。
- **手写与生成是互补，不是替代**：手写处理值类型 / 模板 / Mixin / 命名空间投影等机械不可推导面；UHT 处理 BlueprintCallable 公开方法的反射注册。121 这个数字不会因 UHT 覆盖率提升而下降——两者是不同维度的覆盖。
- **增量靠 UBT**：`AddExternalDependency(.h) + AddExternalDependency(Build.cs) + CommitOutput(hash 比对)` 三件让 UHT 自身无需维护 mtime；`DeleteStaleOutputs` 处理依赖被删时的孤儿分片。
- **与 BlueprintImpact / HotReload 不联动**：UHT 产物的变化只能通过 UE 进程重启来生效；BP 重扫与 UHT 工具属于完全独立的两条链路。
