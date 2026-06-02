# Arch_Overview — 插件总体概览与模块职责

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 站在"整个仓库"和"插件交付边界"的最外层视角，回答"由哪几个 UE 模块组成、各自承担什么职责、对外交付物是什么、整体如何与 UE 集成"——不深入任一子系统的实现细节
> **关键源码**:
> `Plugins/Angelscript/Angelscript.uplugin` (~50 行，三模块装载阶段定义)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` (~92 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs` (~46 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` (~57 行)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj` (~54 行)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs` (~UE 构建期 C# Exporter 入口)
> · `Source/AngelscriptProject/AngelscriptProject.cpp` (~6 行，仅 `IMPLEMENT_PRIMARY_GAME_MODULE` 一行有效代码)
> · `AGENTS.md`（本文项目语境与"插件即交付物"准则的来源）
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — Runtime 总控与生命周期（深入 §三/四 Tick 与 Initialize）
> · `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — 模块清单与装载关系（细化每个模块的依赖头）
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — Editor / Test / Dump 协作边界
> · `Documents/Knowledges/ZH/Arch_ErrorDiagnostics.md` — 报错机制：编译诊断、错误收集与输出链路
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — UHT 工具链位置与边界

---

## 概览

本文聚焦一个核心问题：**这份仓库的"对外可交付物"边界在哪？哪些是插件本体、哪些只是宿主壳子？四个 UE 模块 + 一个 UHT C# 工具是怎样在装载阶段、依赖关系、运行时角色三个维度上拼成一个整体的？**

```text
仓库视角 vs 交付物视角
================================================================

┌──────────────────────── 仓库 AngelscriptProject ─────────────────────┐
│                                                                       │
│  Source/AngelscriptProject/      ← 宿主项目模块（最小壳）            │
│      AngelscriptProject.cpp      仅一行 IMPLEMENT_PRIMARY_GAME_MODULE │
│      存在的唯一意义：让 .uproject 编得过、跑得起来                    │
│                                                                       │
│  ┌──────────────────────── ★ 真正的交付物 ─────────────────────────┐  │
│  │ Plugins/Angelscript/         ← 1619 文件、可独立移植的插件本体  │  │
│  │   Source/                                                        │  │
│  │     AngelscriptRuntime/      Runtime 模块（209 .cpp）            │  │
│  │     AngelscriptEditor/       Editor 模块（49  .cpp）             │  │
│  │     AngelscriptTest/         Test  模块（430 .cpp）              │  │
│  │     AngelscriptUHTTool/      UHT C# 工具（5 .cs，构建期）        │  │
│  │   Angelscript.uplugin                                            │  │
│  │   README.md                  插件消费者文档                      │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  Script/   Tools/   Documents/   openspec/   Config/                  │
│      验证、构建、文档、变更提案 —— 不进入插件包                      │
└────────────────────────────────────────────────────────────────────────┘
```

```text
交付物内部三层结构（按角色而非按依赖）
=====================================

┌──────────────────────────────────────────────────────────────────────┐
│ Layer 1: 构建期工具 ─ AngelscriptUHTTool（C# / UBT plugin）          │
│   读 C++ 头 → 生成 AS_FunctionTable_*.cpp + Summary.json + 跳过 CSV  │
│   完全脱离 UE 进程，hook 进 UnrealHeaderTool 流水线                  │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼ （生成文件作为 Runtime 的输入）
┌──────────────────────────────────────────────────────────────────────┐
│ Layer 2: 运行时核心 ─ AngelscriptRuntime                             │
│   FAngelscriptEngine + 121 Bind_*.cpp + ClassGenerator + Debugger    │
│   + StaticJIT + Preprocessor + Subsystem + Dump + CodeCoverage       │
│   所有进程形态（Editor / Game / Commandlet / Headless）都加载        │
└──────────────────────────────────────────────────────────────────────┘
                                  │
            ┌─────────────────────┴───────────────────────┐
            ▼                                              ▼
┌──────────────────────────────┐  ┌────────────────────────────────────┐
│ Layer 3a: AngelscriptEditor  │  │ Layer 3b: AngelscriptTest          │
│   仅 GIsEditor / Commandlet  │  │   编辑器 + Headless 自动化两栖     │
│   HotReload / SourceNav /    │  │   28+ 主题、1518+ 测试定义、      │
│   ContentBrowser / CodeGen / │  │   430 个 .cpp                      │
│   BlueprintImpact            │  │   (`Type`: "Editor" 限定)          │
└──────────────────────────────┘  └────────────────────────────────────┘
```

后续章节按"交付边界 → 物理布局 → 依赖与装载 → 交付物清单 → UE 接合点 → 边界与导航"的顺序展开。

---

## 一、插件作为对外交付物的定位

`AGENTS.md` 在第一段就明确了这条最高层规则：

> The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine. This repository serves as the host project for plugin development and validation; **the real deliverable is the `Angelscript` plugin itself**.

落到目录上意味着三件事：

```text
角色判定速查
================================================================

Plugins/Angelscript/        ← 真理在这里
  - 所有运行时实现、绑定、测试基础设施
  - 跨项目可移植：拷到任何 UE 5.7 工程的 Plugins/ 即可启用
  - 被 OpenSpec 变更视为"submodule scope"

Source/AngelscriptProject/  ← 验证壳，最小化
  - 仅一行 IMPLEMENT_PRIMARY_GAME_MODULE
  - 不放业务逻辑；放在这里意味着"无法被插件消费者继承"
  - 任何把 plugin 逻辑往 host module 推的改动，都要在 OpenSpec 中显式说明

```

宿主项目模块 `AngelscriptProject` 的全部代码：

```cpp
// ============================================================================
// 文件: Source/AngelscriptProject/AngelscriptProject.cpp
// 角色: 让 .uproject 编得过；除此以外不承担任何职责
// ============================================================================
#include "AngelscriptProject.h"
#include "Modules/ModuleManager.h"

IMPLEMENT_PRIMARY_GAME_MODULE(FDefaultGameModuleImpl, AngelscriptProject, "AngelscriptProject");
```

```cs
// ============================================================================
// 文件: Source/AngelscriptProject/AngelscriptProject.Build.cs
// 角色: 仅依赖 Core / CoreUObject / Engine 三件套，故意空置 Private
// ============================================================================
public class AngelscriptProject : ModuleRules
{
    public AngelscriptProject(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine" });
        PrivateDependencyModuleNames.AddRange(new string[] {  });
        // 注释掉的几行（Slate / OnlineSubsystem）保持原状，避免误导消费者
    }
}
```

——这条"只依赖最少 + 没有任何 plugin 反向引用"的边界让插件可以被任意 UE 5.7 项目以"零侵入"方式启用：消费者只需把 `Plugins/Angelscript/` 拷过去、在自己的 `.uproject` 里 `"Enabled": true` 即可。

---

## 二、四个 UE 模块 + UHT 工具：物理布局

### 2.1 模块清单一览

| 模块 / 工具 | 类型 | 文件位置 | 规模 | 加载形态 |
|------------|------|---------|------|---------|
| `AngelscriptRuntime` | UE Runtime Module（C++） | `Plugins/Angelscript/Source/AngelscriptRuntime/` | 209 `.cpp`，11 个子目录 | 所有进程形态都加载 |
| `AngelscriptEditor` | UE Editor Module（C++） | `Plugins/Angelscript/Source/AngelscriptEditor/` | 49 `.cpp`，11 个子目录 | 仅 `GIsEditor \|\| IsRunningCommandlet()` |
| `AngelscriptTest` | UE Editor Module（C++） | `Plugins/Angelscript/Source/AngelscriptTest/` | 430 `.cpp`，22 个子目录 | 与 Editor 同；headless 自动化下亦可 |
| `AngelscriptUHTTool` | C# UBT plugin | `Plugins/Angelscript/Source/AngelscriptUHTTool/` | 5 `.cs` + `.csproj` | 构建期，UnrealBuildTool 进程内 |
| `AngelscriptProject` | 宿主 Game Module | `Source/AngelscriptProject/` | 3 文件（含 `.h`/`.cpp`/`.Build.cs`） | 仅本仓库 .uproject 编译时 |

### 2.2 `AngelscriptRuntime/` 子目录与职责

```text
AngelscriptRuntime/
├── Core/                    引擎核心：FAngelscriptEngine / Subsystem / 类型系统 / 编译入口
├── Binds/                   ★ 121 个 Bind_*.cpp，C++↔AS 手工绑定数据库
├── ClassGenerator/          脚本类 → UClass/UStruct/UFunction 生成（含热重载支撑）
├── Preprocessor/            脚本预处理：#include / #if / 模块描述符构建
├── Debugging/               DebugServer V2（DAP 协议）
├── StaticJIT/               静态 JIT 编译，发布构建可选启用
├── CodeCoverage/            按行覆盖率统计（受 WITH_AS_COVERAGE 控制）
├── FunctionLibraries/       21 个 mixin helper library
├── Subsystem/               Script Subsystem 基类（World/Engine/LP/GI 四种形态）
├── Dump/                    27 张 CSV 表的统一入口（FAngelscriptStateDump）
├── Hash/                    类型哈希与元数据辅助
├── Testing/                 Runtime 自带的测试支撑（不依赖 AngelscriptTest 模块）
└── ThirdParty/angelscript/  AngelScript 2.33 + 选择性 2.38 的 vendored 内核源码
```

### 2.3 `AngelscriptEditor/` 子目录与职责

```text
AngelscriptEditor/
├── Core/                    模块入口（FAngelscriptEditorModule）
├── HotReload/               DirectoryWatcher + ClassReloadHelper（热重载触发与重实例化）
├── BlueprintImpact/         BP 受影响扫描器 + Commandlet（CI/编辑器双前端）
├── SourceNavigation/        UE "Go to Source" 接入 .as 文件:行
├── ContentBrowser/          .as 作为虚拟资产出现在内容浏览器
├── CodeGen/                 IDE 桩与 API 文档生成（编辑器命令触发）
├── EditorMenuExtensions/    UE 编辑器菜单/工具栏扩展
├── BaseClasses/             编辑器侧基类支撑
├── FunctionLibraries/       编辑器侧 mixin helper
├── Dump/                    挂入 OnDumpExtensions，贡献 2 张额外 CSV 表
└── Tests/                   编辑器侧测试（依赖 UnrealEd）
```

### 2.4 `AngelscriptTest/` 子目录与职责

```text
AngelscriptTest/
├── AngelscriptTestModule.cpp 模块入口
├── Shared/                  ★ 60+ 文件的测试基础设施（按 7 大类组织，详见 Test_Infrastructure.md）
├── Template/                7 份基线测试样板（拷贝改名即可起新主题测试）
├── Bindings / Compiler / Core / Debugger / Dump / Editor / FileSystem
├── Functional / GC / HotReload / Learning / Memory / Networking
├── Performance / Preprocessor / Shared / StaticJIT / Syntax / Validation
├── ClassGenerator / AngelScriptSDK
└── TESTING_GUIDE.md / TESTING_GUIDE_ZH.md
```

### 2.5 `AngelscriptUHTTool/` 文件清单

```text
AngelscriptUHTTool/                   （C# / .NET 8.0 / UBT plugin）
├── AngelscriptUHTTool.cs                       命名空间锚点（无实质代码）
├── AngelscriptFunctionTableExporter.cs         ★ [UnrealHeaderTool] [UhtExporter] 入口
├── AngelscriptFunctionTableCodeGenerator.cs    生成 AS_FunctionTable_*.cpp
├── AngelscriptFunctionSignatureBuilder.cs      函数签名重建
├── AngelscriptHeaderSignatureResolver.cs       头文件签名解析
├── AngelscriptUHTTool.ubtplugin.csproj         项目文件，引用 EpicGames.UHT.dll 等
└── AngelscriptUHTTool.ubtplugin.csproj.props   构建参数
```

UHT 工具的入口是单个静态 `Export` 方法 —— 它注册为 UE Header Tool 的导出器（`[UhtExporter]`），构建期遍历所有反射函数并生成 `AS_FunctionTable_*.cpp` 分片：

```cs
// ============================================================================
// 文件: AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs
// 函数: Export
// 性质: 构建期入口；CppFilters="AS_FunctionTable_*.cpp" 决定输出文件命名
// ============================================================================
[UhtExporter(
    Name = "AngelscriptFunctionTable",
    Description = "Exports Angelscript function table data",
    Options = UhtExporterOptions.Default | UhtExporterOptions.CompileOutput,
    CppFilters = ["AS_FunctionTable_*.cpp"],
    ModuleName = "AngelscriptRuntime")]
private static void Export(IUhtExportFactory factory)
{
    // ★ 遍历所有 module / class / function，识别 BlueprintCallable & BlueprintPure
    // ★ 重建签名 -> 生成直接绑定代码 / 无法重建则记录到跳过 CSV
    int generatedFileCount = AngelscriptFunctionTableCodeGenerator.Generate(factory);
    // ... 累计 packageCount / classCount / functionCount / reconstructedCount / skippedCount
    WriteSkippedEntriesCsv(factory, skippedEntries);          // 出口 1: 逐条跳过明细
    WriteSkippedReasonSummaryCsv(factory, skippedEntries);    // 出口 2: 原因汇总
    Console.WriteLine("AngelscriptUHTTool exporter visited {0} packages, ...", ...);
}
```

——UHT 工具产出的 `.cpp` 文件**编译进 `AngelscriptRuntime` 模块**（`ModuleName = "AngelscriptRuntime"`），所以"`Bind_*.cpp` 总数 121"指的是手工撰写的固定绑定；自动生成的 `AS_FunctionTable_*.cpp` 是另一类，与 Bind 在同一进程加载但分文件管理。

---

## 三、模块依赖图与 LoadingPhase

### 3.1 依赖图

`AGENTS.md` 给出的结构性事实：

```text
AngelscriptRuntime  (Runtime 模块，无任何 plugin 内依赖)
       │
       ├──► AngelscriptEditor  (Editor 模块，public 依赖 Runtime)
       │
       └──► AngelscriptTest    (Editor 模块，public 依赖 Runtime
                                + bBuildEditor 时 private 依赖 Editor)

AngelscriptUHTTool  (C# UBT plugin，独立 — 构建期 hook 入 UHT pipeline)
```

落到 `Build.cs` 上的依赖列表：

| 模块 | `PublicDependencyModuleNames` 关键项 | `PrivateDependencyModuleNames` 关键项 | `bBuildEditor` 追加 |
|------|--------------------------------------|---------------------------------------|---------------------|
| `AngelscriptRuntime` | `Core` / `CoreUObject` / `Engine` / `EngineSettings` / `DeveloperSettings` / `Json` / `JsonUtilities` / `GameplayTags` / `StructUtils` | `AIModule` / `Slate` / `SlateCore` / `UMG` / `EnhancedInput` / `NetCore` / `Sockets` / `AssetRegistry` / ... | Public: `UnrealEd`, `EditorSubsystem`；Private: `UMGEditor` |
| `AngelscriptEditor` | `Core` / `CoreUObject` / `Engine` / `UnrealEd` / `EditorSubsystem` / **`AngelscriptRuntime`** / `BlueprintGraph` / `Kismet` / `DirectoryWatcher` / `Slate` / `AssetTools` | `Projects` / `Settings` / `LevelEditor` / `PlacementMode` / `PropertyEditor` / `ContentBrowser` / `ContentBrowserData` / `ToolMenus` | — |
| `AngelscriptTest` | `Core` / `CoreUObject` / `Engine` / `GameplayTags` / `Json` / `PropertyBindingUtils` / **`AngelscriptRuntime`** | `AIModule` / `EnhancedInput` / `UMG` | Private: `BlueprintGraph` / `CQTest` / `Networking` / `Sockets` / `UnrealEd` / **`AngelscriptEditor`** |

**关键观察**：

- `AngelscriptRuntime` 在 `bBuildEditor` 下**会**追加 `UnrealEd` 等编辑器依赖到 Public——这是因为 ClassGenerator 在编辑器构建里需要触发 reinstancer，但接口本身不暴露给 Editor 模块以外的消费者。
- `AngelscriptTest` 对 `AngelscriptEditor` 的依赖是 **private + bBuildEditor 限定**——意味着 Test 模块的 `.h` 不能 leak Editor 类型，且 headless 构建里 Test 跑不到 Editor 那部分代码。
- `AngelscriptUHTTool` 在 `Build.cs` 上完全不出现——它通过 `.ubtplugin.csproj` 引用 `EpicGames.UHT.dll` 接入 UBT，**不属于 UE Module 系统**。

### 3.2 三个 UE 模块的 LoadingPhase 全部 `PostDefault`

`Angelscript.uplugin` 中只有一个 `Modules` 数组：

```json
// ============================================================================
// 文件: Plugins/Angelscript/Angelscript.uplugin
// 角色: 模块装载阶段定义；三个模块齐心选 PostDefault
// ============================================================================
"Modules": [
    { "Name": "AngelscriptRuntime", "Type": "Runtime", "LoadingPhase": "PostDefault" },
    { "Name": "AngelscriptEditor",  "Type": "Editor",  "LoadingPhase": "PostDefault" },
    { "Name": "AngelscriptTest",    "Type": "Editor",  "LoadingPhase": "PostDefault" }
]
```

为什么是 `PostDefault`：

```text
UE LoadingPhase 时序 (节选)
================================================================

EarliestPossible ─► PostConfigInit ─► PreEarlyLoadingScreen ─► ...
                                                                  │
                                          ... ─► PostEngineInit  │
                                                       ▲          │
                                                       │          ▼
              ┌────────────────────────────────────────┴─── Default ─►
              │                                                   │
              │  ┌──── ★ PostDefault（插件三模块的窗口） ────┐    │
              │  │ 已可用：CoreUObject 反射、Subsystem 框架、 │    │
              │  │         模块管理器、CDO 注册              │    │
              │  │ 还没用：GEngine 不必然存在（极早期场景下）│    │
              │  │ 适合做：注册回调、点亮模块入口           │    │
              │  │ 不适合：立即创建 FAngelscriptEngine 重对象│    │
              │  └────────────────────────────────────────────┘    │
              │                                                   │
              └─► PostEngineInit ─► PostDefault*之后 ─► 业务运行 ─►
```

三个模块都在这个窗口被点亮，但**真正的 `FAngelscriptEngine::Initialize()` 被推迟到 Bootstrap 阶段**——具体 Bootstrap 链路（`UAngelscriptEngineSubsystem::Initialize` / `UAngelscriptGameInstanceSubsystem::Initialize` / `FAngelscriptRuntimeModule::InitializeAngelscript` 三条互斥路径）见 `Arch_RuntimeLifecycle.md` §二。本文不展开。

### 3.3 `Angelscript.uplugin` 还声明了三个外部依赖插件

```json
"Plugins": [
    { "Name": "StructUtils",          "Enabled": true },
    { "Name": "PropertyBindingUtils", "Enabled": true },
    { "Name": "EnhancedInput",        "Enabled": true }
]
```

这意味着消费者启用 `Angelscript` 时这三个 UE 自带插件会被强制启用。它们的用途分别是：

- **StructUtils**：`FInstancedStruct` 与 PropertyBag 支撑（详见 `Syntax_FInstancedStruct.md`）。
- **PropertyBindingUtils**：属性绑定工具，AS 的 `BindWidget` 等实现要靠它。
- **EnhancedInput**：增强输入系统接入（详见 `Guide_InputSystem.md`）。

---

## 四、对外交付物清单：成熟期能力锚点

`AGENTS.md` 在 §"Project Overview" 与 §"Recently Completed Milestones" 给出了当前 baseline，本节把它们聚合成一份"插件消费者拿到的具体能力清单"：

```text
能力维度速览（AGENTS.md 当前 baseline）
================================================================

[语言运行时]
  - AngelScript 2.33 + 选择性 2.38 兼容（不做整版升级；策略见 Documents/Guides/AngelscriptForkStrategy.md）
  - 121 个 Bind_*.cpp 手工绑定（覆盖 Actor / Component / Math / Container / Networking / ...）
  - 自动生成 AS_FunctionTable_*.cpp（UHT 工具产出，编入 AngelscriptRuntime）
  - 反射回退绑定（UFunction Reflective Fallback，已落地里程碑）
  - 21 个 mixin helper library（FunctionLibraries/）

[类型与生成]
  - ClassGenerator: 脚本类 → 活的 UClass/UStruct/UFunction
  - 与 Blueprint / C++ 全双向互通（脚本类型可被 BP 继承、可在 BP 节点参数中使用）
  - DefaultStatement / DefaultComponent / Mixin / FString / 自定义 access 修饰符等扩展语法

[运行时子系统]
  - DebugServer V2（DAP 协议；多客户端、StackFrame、变量查看、断点）
  - StaticJIT（静态 JIT 编译；发布构建提速）
  - CodeCoverage（行级覆盖率，WITH_AS_COVERAGE 控制；可导出报告）
  - HotReload（编辑器内修改 .as 立即重实例化）
  - Subsystem 基类四件套：World / Engine / LocalPlayer / GameInstance

[可观测性 / 编辑器集成]
  - 27 张 CSV State Dump 表（`as.DumpEngineState` 控制台命令）
  - Source Navigation（UE "Go to Definition" 路由到 .as 文件:行）
  - Content Browser DataSource（.as 以虚拟资产形式可见）
  - BlueprintImpact Commandlet（CI 路径）+ Editor Scanner（交互路径）
  - Editor 菜单 / 工具栏扩展（EditorMenuExtensions/）

[质量基础]
  - 28+ 主题、1518+ 自动化测试定义、430 个测试 .cpp（仅 2 个 Disabled，均 #ue57-headless 已知限制）
  - 275/275 编目 C++ baseline（TestCatalog.md）
  - 301/301 原生 SDK 测试套件（Angelscript.TestModule.AngelScriptSDK）

[构建期工具链]
  - AngelscriptUHTTool: C# .NET 8.0 / UBT plugin
  - 产物：AS_FunctionTable_*.cpp / AS_FunctionTable_Summary.json /
          跳过明细 CSV / 原因汇总 CSV
```

这份清单的"用法说明书"侧重在 `Wiki/`（待抽离）与 `Documents/Guides/`；**实现原理**则散落在 `RT_*` / `Type_*` / `Syntax_*` 三族文档（详见 §七）。

---

## 五、与 UE 系统的接合点

下表把 Runtime / Editor / Test 三方"对 UE 内置子系统的接入点"列出来——这些是**没有它们插件就跑不起来的关键接合**：

| UE 系统 | 接入符号 | 接入方 | 作用 |
|---------|---------|--------|------|
| `UEngineSubsystem` | `UAngelscriptEngineSubsystem` | Runtime/Core | Editor + Commandlet 进程的 Bootstrap 主控 |
| `UGameInstanceSubsystem` | `UAngelscriptGameInstanceSubsystem` | Runtime/Core | Game / PIE 世界的 Tick 所有者 |
| `FTickableGameObject` | 上述两个 Subsystem 都实现 | Runtime/Core | 让 `FAngelscriptEngine::Tick` 被驱动 |
| `UDeveloperSettings` | `UAngelscriptSettings` | Runtime/Core | Project Settings 暴露 ScriptRoot / VSCodeWorkspace 等配置 |
| `UCommandlet` | `UAngelscriptBlueprintImpactScanCommandlet` 等 | Editor/BlueprintImpact | CI 路径（`-run=AngelscriptBlueprintImpactScan` 等命令行模式） |
| `UContentBrowserDataSource` | `UAngelscriptContentBrowserDataSource` | Editor/ContentBrowser | `.as` 以虚拟资产形式出现在内容浏览器 |
| `ISourceCodeNavigationHandler` | `FAngelscriptSourceCodeNavigation` | Editor/SourceNavigation | UE "Go to Definition" 路由到 .as 文件:行 |
| `IDirectoryWatcher` | `OnScriptFileChanges` 回调 | Editor/HotReload | OS 文件变更 → 待重载队列 |
| `FCoreDelegates::OnPostEngineInit` | `OnEngineInitDone` 静态回调 | Editor/Core | ContentBrowser DataSource 注册时机 |
| `FAutoConsoleCommand` | `as.DumpEngineState` 等 | Test/Dump | 控制台命令 |
| `UnrealHeaderTool` `[UhtExporter]` | `AngelscriptFunctionTableExporter.Export` | UHTTool | 构建期生成绑定函数表分片 |
| Slate 编辑器 UI | 启动失败弹框 / 编辑器菜单扩展 | Runtime + Editor | 可视化错误处理与命令触发 |

这些接合点的共同模式：**Runtime 用 UE Subsystem 接管生命周期；Editor 用 UE 已有扩展点（NavigationHandler / DataSource / Watcher / ConsoleCommand）插入而不打补丁；UHTTool 用 UBT 既定的 Exporter 协议**。换句话说，整个插件**没有任何"hack 进 UE 内核"的代码**，全部接合都用官方扩展位。

---

## 六、边界：宿主项目模块

宿主项目模块的边界已经在 §一描述。这里补一条**在 OpenSpec 与日常修改中反复要重申**的规则：

```text
"插件优先" 原则（AGENTS.md §"Project Overview"）
================================================================

✗ 禁止: 把 plugin 逻辑（绑定、子系统、helper）放到 Source/AngelscriptProject/
✗ 禁止: 在 host module 加 UE_LOG 类别、添加新的 .h/.cpp
✓ 允许: 在 host module 加 PIE 启动时的最小桩代码（仅当 plugin 本身无法
        在不修改宿主的前提下生效——目前无此场景）
✓ 鼓励: 任何"我以为该写在 host"的代码先停一下，问一句"它能否搬到 Plugins/Angelscript/" ——
        几乎所有情况下答案是"能"。
```

---

## 七、读哪本：从本文向后的文档导航

本文写完后，读者按"想深入哪一面"决定下一篇。常见路径：

```text
我刚到这个项目，想搞清楚...
================================================================

[A. 引擎是怎么被创建/驱动的]
   → Arch_RuntimeLifecycle.md
        ├─ §二 Bootstrap 三条路径与 InitializeAngelscript 入口
        ├─ §三 EngineSubsystem ↔ GameInstanceSubsystem Tick 让位
        └─ §四 Initialize 主流程的 12 个里程碑

[B. 模块装载顺序、依赖头清单、PostDefault 的精确含义]
   → Arch_ModuleLoading.md（细化版）

[C. Editor / Test / Dump 三方协作边界]
   → Arch_EditorTestDumpCollaboration.md
        ├─ §一 Editor 5 个扩展点与各自切入点
        ├─ §二 Test Shared/ 7 大类 Helper
        └─ §三 27 张 CSV 表清单与 OnDumpExtensions 协作通道

[D. 编译/绑定/类型生成报错时数据流是怎么走的]
   → Arch_ErrorDiagnostics.md（三源汇入 / 一表中心 / 四路出口）

[E. UHT 工具到底做了什么、与运行时绑定如何衔接]
   → Arch_UHTToolchain.md

[F. 单一子系统的实现细节]（不属于 Arch_，去对应前缀）
   → RT_HotReload.md / RT_Debugger.md / RT_StaticJIT.md / RT_StateDump.md
   → RT_GlobalState.md / RT_CodeCoverage.md / RT_HashMetadata.md / RT_ThirdPartyKernel.md

[G. 类型生成与绑定数据库]
   → Type_ClassGeneration.md / Type_BindSystem.md / Type_FunctionCaller.md
   → Type_StructGeneration.md / Type_Preprocessor.md / Type_BaseClass.md

[H. AS 内核（asCScriptEngine 等）原貌与 Fork 差异]
   → AS_ScriptEngine.md / AS_Compiler.md / AS_Parser.md / AS_ByteCode.md
   → AS_VirtualMachine.md / AS_GarbageCollector.md / AS_ForkDifferences.md

[I. 单一关键字 / 容器类型的语法机制]
   → Syntax_*（DefaultStatement / UFUNCTION / TArray / TMap / FString / ...）

[J. 测试模块怎么组织、如何写新测试]
   → Test_Layering.md / Test_Infrastructure.md
   → Guide_TestWriting.md（用户向使用指南）

[K. 与 Hazelight / Verse 等参考实现的差异]
   → Diff_HazelightDefaultStatement.md / Diff_HazelightInsightsToBorrow.md
   → Diff_VerseArchitecture.md
```

九个 prefix 的边界详见 `Documents/Knowledges/ZH/Rule.md` §一。

---

## 附录 A：模块速查表

| 维度 | `AngelscriptRuntime` | `AngelscriptEditor` | `AngelscriptTest` | `AngelscriptUHTTool` | `AngelscriptProject`（宿主） |
|------|---------------------|---------------------|-------------------|---------------------|------------------------------|
| 类型 | UE Runtime Module | UE Editor Module | UE Editor Module | C# UBT plugin | UE Game Module |
| 加载形态 | 全形态 | `GIsEditor \|\| Commandlet` | 同 Editor | 构建期 UBT | 仅本仓库 .uproject |
| LoadingPhase | `PostDefault` | `PostDefault` | `PostDefault` | — | 默认 |
| Public 依赖 Runtime | — | ✓ | ✓ | — | — |
| Private 依赖 Editor | — | — | bBuildEditor 时 ✓ | — | — |
| 文件规模 | 209 `.cpp` | 49 `.cpp` | 430 `.cpp` | 5 `.cs` | 3 文件 |
| 入口符号 | `FAngelscriptRuntimeModule` | `FAngelscriptEditorModule` | `FAngelscriptTestModule` | `Export()` static | `IMPLEMENT_PRIMARY_GAME_MODULE` |
| 典型对外交付 | `FAngelscriptEngine` / 121 Bind / Subsystem / Dump | HotReload / SourceNav / ContentBrowser / BlueprintImpact | 1518+ 测试定义 + Shared/ Helper | `AS_FunctionTable_*.cpp` + Summary | 无 |
| 是否在 plugin 包内 | ✓ | ✓ | ✓ | ✓ | ✗（宿主项目） |

---

## 附录 B：术语对照表（全 Knowledges 通用）

下面这份术语表是后续所有 `Arch_` / `Type_` / `RT_` / `Syntax_` 等文档反复引用的概念。统一在这里定一份口径，避免每篇文章再重述。

| 术语 | 中文 / 解释 | 出处 / 关键源 |
|------|-------------|---------------|
| **Engine** | 指 `FAngelscriptEngine`——AS 引擎在 UE 侧的"重对象"，USTRUCT，包含 `Initialize/Tick/Shutdown`、ScriptEngine、ContextStack 等。一个进程可有多实例（PrimaryEngine + N 个 PIE 克隆）。 | `Core/AngelscriptEngine.h` |
| **EngineSubsystem** | `UAngelscriptEngineSubsystem`，`UEngineSubsystem` 子类，Editor/Commandlet 的 Bootstrap 主控；**不**指 UE 的 `UEngineSubsystem` 基类本身。 | `Core/AngelscriptEngineSubsystem.h` |
| **GameInstanceSubsystem** | `UAngelscriptGameInstanceSubsystem`，`UGameInstanceSubsystem` 子类，Game/PIE 世界的 Tick 所有者，通过 `ActiveTickOwners` 让位机制与 EngineSubsystem 协调。 | `Core/AngelscriptGameInstanceSubsystem.h` |
| **Module** | 在本仓库语境下需要二义消歧。**UE Module** = `AngelscriptRuntime` 这种 `.Build.cs` 模块；**AS Module** = `FAngelscriptModuleDesc`，一个或多个 `.as` 文件聚合成的编译单元。 | `Core/AngelscriptEngine.h` 中 `FAngelscriptModuleDesc` |
| **ContextStack** | `FAngelscriptEngineContextStack`，进程级 `TArray<FAngelscriptEngine*>`，提供 Push/Pop/Peek。`TryGetCurrentEngine() = Stack.Last()`，回答"当前我属于哪个 Engine"。 | `Core/AngelscriptEngine.h` |
| **EngineScope** | `FAngelscriptEngineScope`，RAII 包装类，构造时 Push、析构时 Pop ContextStack。所有"切换当前 Engine"的代码必须用它。 | `Core/AngelscriptEngine.h` |
| **Bind** | C++ 类型/函数到 AS 类型系统的手工绑定，落在 `Binds/Bind_*.cpp`（121 份）。每份 `Bind_*.cpp` 通过 `FAngelscriptBinds::SetPreviousNamespaces` 等 API 注册一组类型。 | `Binds/Bind_*.cpp` |
| **FunctionTable** | UHT 工具产出的"AS_FunctionTable_*.cpp"，自动绑定 BlueprintCallable / BlueprintPure 函数。与手工 Bind 不冲突，由 UHT 在构建期生成。 | `AngelscriptUHTTool/` |
| **ScriptRoot** | AS 脚本根目录列表，由 `FAngelscriptEngine::MakeAllScriptRoots()` 返回；DirectoryWatcher 注册回调时使用；默认包含 `Script/` 与项目级配置。 | `UAngelscriptSettings` |
| **ClassGenerator** | `FAngelscriptClassGenerator`，把 AS 类声明翻译成活的 `UClass`/`UStruct`/`UFunction`/`UEnum` 的子系统；暴露 5 个 `OnXXXReload` 多播给 Editor 订阅。 | `ClassGenerator/` |
| **HotReload** | 文件变更 → 重新编译 → ClassGenerator 触发 reinstance 的全链路。Editor 端由 DirectoryWatcher 触发；Runtime 端在 `Tick` 内读 `FileChangesDetectedForReload` 队列。 | `RT_HotReload.md` |
| **DebugServer** | `FAngelscriptDebugServer`，DAP 协议实现的远程调试服务器，"V2" 指当前版本（多客户端、StackFrame、断点）。 | `Debugging/AngelscriptDebugServer.h` |
| **StaticJIT** | 静态 JIT 编译子系统，发布构建可选启用；与 AS 内核 JIT 配合提速。 | `StaticJIT/` |
| **DumpTable** | `FAngelscriptStateDump` 的"一表一职责" CSV 输出。共 27 张：24 张 Phase A-D 核心表 + 2 张 Editor 扩展表（EditorReloadState / EditorMenuExtensions）+ 1 张 DumpSummary。 | `Dump/AngelscriptStateDump.cpp` |
| **DumpExtension** | Editor 通过 `FAngelscriptStateDump::OnDumpExtensions` 多播挂入的扩展回调，使其能在 dump 流程中贡献额外 CSV 表。 | `Editor/Dump/AngelscriptEditorStateDump.cpp` |
| **CodeCoverage** | 行级覆盖率统计子系统，由 `WITH_AS_COVERAGE` 宏控制。 | `CodeCoverage/` |
| **BlueprintImpact** | 脚本变更后扫描受影响蓝图资产的子系统，分 Scanner（编辑器交互）+ Commandlet（CI）两个前端，共用 `ScanBlueprintAssets` 核心。 | `Editor/BlueprintImpact/` |
| **PrecompiledData** | Cooked 路径下使用的预编译数据，避免运行时再做 InitialCompile。 | `Core/AngelscriptEngine.cpp` |
| **AmbientWorldContext** | `GAmbientWorldContext`，全局当前 World 指针；脚本调用涉及 World 的 API 前必须 Push、调用后必须 Pop（用 RAII Scope）。`Tick` 末尾若非空触发 Fatal。 | `Core/AngelscriptEngine.cpp` |
| **AdditionalCompileChecks** | `FAngelscriptAdditionalCompileChecks` 接口，让游戏模块注入项目特定的编译检查规则。 | `ClassGenerator/AngelscriptAdditionalCompileChecks.h` |

---

## 小结

- **交付物的边界很硬**：`Plugins/Angelscript/` 是真理，`Source/AngelscriptProject/` 仅一行 `IMPLEMENT_PRIMARY_GAME_MODULE`；任何"往 host 推业务"的改动都必须显式说明。
- **物理布局五件套**：`AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` 三个 UE 模块 + `AngelscriptUHTTool` 一个 C# UBT plugin + 宿主项目的 `AngelscriptProject` minimal harness。
- **依赖图严格**：Runtime 是底座、不依赖 plugin 内任何东西；Editor 与 Test 都 public 依赖 Runtime；Test 在 `bBuildEditor` 下 private 依赖 Editor；UHT 工具完全独立、走 UBT 接入。
- **统一选 `PostDefault` 装载**：三个 UE 模块齐心选这个窗口，原因是 CoreUObject 已就绪但 `GEngine` 不必然存在——正合"点亮模块入口、推迟创建重对象"的策略。
- **能力锚点 = 121 Bind + 27 CSV + 1518+ 测试 + DebugServer V2 + StaticJIT + BlueprintImpact Commandlet**：成熟期 baseline，不是原型；新文档与 OpenSpec 都应基于这条基线讨论。
- **接合点全部用 UE 官方扩展位**：UEngineSubsystem / UGameInstanceSubsystem / UDeveloperSettings / UCommandlet / UContentBrowserDataSource / ISourceCodeNavigationHandler / IDirectoryWatcher / FAutoConsoleCommand / `[UhtExporter]`——没有任何 hack。
- **导航**：本文写完后，按"我想搞清楚 X"分支去 `Arch_RuntimeLifecycle` / `Arch_ModuleLoading` / `Arch_EditorTestDumpCollaboration` / `Arch_ErrorDiagnostics` / `Arch_UHTToolchain` 与 `RT_*` / `Type_*` / `Syntax_*` 三族。
