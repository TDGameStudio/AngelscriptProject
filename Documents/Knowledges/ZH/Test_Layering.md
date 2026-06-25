# Test_Layering — 测试模块总体分层

> **所属前缀**: Test_（测试架构族）
> **关注层面**: `AngelscriptTest` 模块的目录骨架、命名空间与依赖边界（不深入单条 case 的实现细节，也不重复 CQTest 框架原理）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` (~57 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp` (~60 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/` (~40+ Helper 头/源)
> · `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_*.cpp` (7 个基线模板)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` (64 个 Native/ASSDK 文件)
> · `Plugins/Angelscript/Source/AngelscriptTest/Bindings/` (90 个绑定覆盖文件)
> · `Plugins/Angelscript/Source/AngelscriptTest/Functional/<Theme>/` (20 个二级主题)
> **关联文档**:
> `Documents/Knowledges/ZH/Note_CQTest.md` — CQTest 框架使用笔记（本文不重复其内容，只引用宏与基类）
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — Editor / Test / Dump 协作边界（本文是其 Test 视角的延伸）
> · `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — `FAngelscriptTestModule::StartupModule` 的装载顺序
> · `Documents/Knowledges/ZH/Test_Infrastructure.md` — Helper 层细节（Shared/ 子目录的 7 大类拆解）
> · `Documents/Knowledges/ZH/Test_TopicClusters.md` — 主题测试簇映射（每个目录到底测什么）
> **外部参考**:
> [Epic 官方 CQTest 文档](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/cqtest-test-framework-for-unreal-engine)
> · `Documents/Guides/TestConventions.md` — 命名与组织规范
> · `Documents/Guides/Test.md` — 测试运行器与 suite 用法
> · `Documents/Guides/TestCatalog.md` — 275/275 编目基线

---

## 概览

本文聚焦一个核心问题：**`AngelscriptTest` 模块在源代码层面如何分层组织，它的物理目录、Automation 命名空间与对其他模块的依赖边界各自由谁决定，以及这套分层与 `AngelscriptRuntime/Tests/` 和 `AngelscriptEditor/Tests/` 之间的关系是怎样的？**

这是 P5 Test_ 族的入口文章。它**不**复述 CQTest 框架的实现机制（去 `Note_CQTest.md`），**不**深入每个 Helper 的可观察 API（去 `Test_Infrastructure.md`），**不**逐个解释每个主题目录测的是什么（去 `Test_TopicClusters.md`）。它只回答"分层骨架长什么样"。

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│   AngelscriptRuntime（运行时模块，无插件内依赖）                            │
│   ├── Tests/   ← Runtime 内部 C++ 单测（Angelscript.TestModule.CppTests.*） │
│   └── ...      ← 公开 API：FAngelscriptEngine / ClassGenerator / Dump      │
└──────────────────────────────▲──────────────────────────────────────────────┘
                               │ public 依赖
       ┌───────────────────────┴───────────────────┐
       │                                           │
┌──────┴───────────────┐         ┌─────────────────┴──────────────────────┐
│ AngelscriptEditor    │         │ AngelscriptTest                        │
│ (Editor 模块)        │         │ (Editor 模块, bBuildEditor 守卫)       │
│                      │         │                                        │
│ Tests/  ← 编辑器测试 │  ◀───── │ private 依赖 Editor（仅 bBuildEditor） │
│         (Angelscript │         │                                        │
│          .Editor.*)  │         │ Spec 层：22 顶层主题 + 20 Functional   │
└──────────────────────┘         │ Template 层：7 个 Template_*.cpp 模板  │
                                 │ Helper 层：Shared/ 40+ helper 文件     │
                                 └────────────────────────────────────────┘

Automation 命名空间（与代码物理位置一一映射）：
  Angelscript.TestModule.CppTests.*    → AngelscriptTest/Core/* 中的运行时探针
  Angelscript.CppTests.*               → 同上的早期变体（少量历史 case 仍在用）
  Angelscript.Editor.*                 → AngelscriptEditor/Tests/* 中的 49 个
  Angelscript.TestModule.<Theme>.*     → AngelscriptTest/<Theme>/* 中的 spec
  Angelscript.TestModule.AngelScriptSDK.* → AngelscriptTest/AngelScriptSDK/*
  Angelscript.Template.*               → AngelscriptTest/Template/* 教学样板
```

后续章节按"三层骨架 → Build.cs 依赖 → 物理目录矩阵 → 命名空间与文件名约定 → 跨家族协作 → 测试规模口径"的顺序推进，最后用三张速查表收口。

---

## 一、三层骨架：Spec / Template / Helper

### 1.1 一句话定义

`AngelscriptTest` 内部的 C++ 文件可以按"它是被运行的还是被引用的"切成三类：

- **Spec 层**：每个主题目录下的 `*Tests.cpp` / `*Test.cpp`，注册一条或多条 Automation Test 入口。它们是**被 Automation 框架枚举**的对象，运行 `RunBuild.ps1 → RunTests.ps1` 时会逐个执行。
- **Template 层**：`Template/Template_*.cpp` 共 7 份，每份对应一种**典型测试形态**（CQTest / WorldTick / GameLifetime / GlobalFunctions / ReflectionAccess / Blueprint / BlueprintWorldTick）。它们也注册 Automation 入口（前缀 `Angelscript.Template.*`），但定位是"读完就能上手"的教学样本。
- **Helper 层**：`Shared/` 下的 40+ 头文件 / 源文件，外加 `Bindings/` 同级提供给 CQTest 绑定覆盖的支持类。它们**不**注册 Automation 入口，只暴露给 Spec / Template 层调用。

### 1.2 三层的物理布局

```text
AngelscriptTest/
├── AngelscriptTest.Build.cs          // 模块定义（依赖边界唯一来源）
├── AngelscriptTestModule.cpp         // StartupModule / ShutdownModule
├── TESTING_GUIDE.md                  // 模块内英文速查
├── TESTING_GUIDE_ZH.md               // 模块内中文速查
│
├── Shared/                           ◀── Helper 层（40+ files）
│   ├── AngelscriptTestEngineHelper.* // 共享 / 隔离 / 完整三档引擎
│   ├── AngelscriptTestEnginePool.*   // 引擎池（启动期 prewarm）
│   ├── AngelscriptTestMacros.h       // ASTEST_CREATE_/GET_/RESET_ENGINE
│   ├── AngelscriptTestWorld.h        // FAngelscriptTestWorld（actor 生命周期）
│   ├── AngelscriptFunctionalTestUtils.h
│   ├── AngelscriptDebuggerTest{Session,Client,Monitor,Fixture}.*
│   ├── AngelscriptBindingsCoverage.h / ModuleBuilder.h / Assertions.h
│   ├── AngelscriptLearningTrace.*
│   ├── AngelscriptGlobalFunctionInvoker.h / ReflectiveAccess.h
│   └── README_MACROS{,_ZH}.md
│
├── Template/                         ◀── Template 层（7 files）
│   ├── Template_CQTest.cpp
│   ├── Template_WorldTick.cpp
│   ├── Template_BlueprintWorldTick.cpp
│   ├── Template_GameLifetime.cpp
│   ├── Template_GlobalFunctions.cpp
│   ├── Template_ReflectionAccess.cpp
│   └── Template_Blueprint.cpp
│
├── Core/                             ◀── Spec 层（34 files，引擎/绑定/钩子）
├── Compiler/                         ◀── Spec 层（31 files，编译器 pipeline）
├── ClassGenerator/                   ◀── Spec 层（28 files，UClass 生成）
├── Bindings/                         ◀── Spec 层（90 files，CQTest 绑定覆盖）
├── AngelScriptSDK/                   ◀── Spec 层（64 files，Native + ASSDK）
├── Debugger/                         ◀── Spec 层（11 files，DAP 协议链路）
├── HotReload/                        ◀── Spec 层（14 files，热重载行为）
├── Functional/                       ◀── Spec 层（20 个二级主题，48 files）
│   ├── Actor/      Animation/    Blueprint/    Component/
│   ├── ControlFlow/ Delegate/    Execution/   Functions/
│   ├── Handles/    Inheritance/  Interface/   Misc/
│   ├── Objects/    Operators/    Property/    Rendering/
│   ├── Subsystem/  Types/        Upgrade/     Widget/
│
├── Learning/                         ◀── Spec 层（Native + Runtime 两档教学测试）
│   ├── Native/   (6 files)
│   └── Runtime/  (16 files)
│
├── Preprocessor/                     ◀── Spec 层（15 files，预处理器）
├── Syntax/                           ◀── Spec 层（19 files，语言语法）
├── StaticJIT/                        ◀── Spec 层（11 files + AOT/）
├── Networking/                       ◀── Spec 层（1 file，RPC 编译）
├── GC/                               ◀── Spec 层（2 files）
├── Memory/                           ◀── Spec 层（2 files）
├── FileSystem/                       ◀── Spec 层（5 files）
├── Performance/                      ◀── Spec 层（3 files）
├── Validation/                       ◀── Spec 层（2 files）
├── Editor/                           ◀── Spec 层（1 file，源码导航回归）
└── Dump/                             ◀── Spec 层（2 files，as.DumpEngineState）
```

### 1.3 三层的"调用方向"

任何一条 Automation 测试在跑起来时大体走这条链：

```text
UE Automation Framework
   │ 枚举所有已注册的 FAutomationTestBase
   ▼
Spec 层（某个主题目录下的 *Tests.cpp）
   │ 通过 IMPLEMENT_SIMPLE_AUTOMATION_TEST 或 TEST_CLASS_WITH_FLAGS 注册自己
   │ 内部调用 ASTEST_CREATE_ENGINE / FAngelscriptTestWorld / FCoverageModuleScope ...
   ▼
Helper 层（Shared/ 下的 utility）
   │ 提供"创建引擎 / 编译模块 / 起世界 / 跑帧 / 比较断言"等可观察封装
   │ 调用 FAngelscriptEngine 公开 API；不私自打补丁到 Runtime 内部
   ▼
AngelscriptRuntime 公开 API（FAngelscriptEngine / ClassGenerator / Dump 等）
```

Template 层位置特殊：它**也属于 Spec 层**（注册的 Automation 入口前缀是 `Angelscript.Template.*`），但同时充当"复制粘贴起手式"。文件夹本身不是 Automation 测试落点——`Documents/Guides/TestConventions.md §1` 明确写了：

> Template/ 目录中的文件视为**夹具模板**，不是新的 Automation 测试文件落点。

也就是说，新的主题 case **不应**继续往 `Template/` 里加，而应去对应主题目录新建文件。

---

## 二、Build.cs 依赖边界

### 2.1 模块定位

```cs
// ============================================================================
// 文件: AngelscriptTest/AngelscriptTest.Build.cs
// 角色: 唯一的依赖边界来源；Spec / Helper 都受这个清单约束
// ============================================================================
public class AngelscriptTest : ModuleRules
{
    public AngelscriptTest(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PrivateDefinitions.Add("AS_ENABLE_EDITOR_JITTED_CODE=1"); // ★

        PublicIncludePaths.Add(ModuleDirectory);
        PrivateIncludePaths.Add(ModuleDirectory);
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Debugger"));
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Dump"));
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "AngelScriptSDK"));
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Preprocessor"));
        PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "ClassGenerator"));
        // ...
    }
}
```

`AS_ENABLE_EDITOR_JITTED_CODE=1` 是关键的私有宏：测试模块允许调起 StaticJIT 已编译的字节码，从而覆盖 JIT 路径。Runtime 模块自己没有这个宏；这意味着 Test 不只是一个被动的"看客"，它**显式拉起 Runtime 的某些只在带宿主时才走的分支**。

### 2.2 Public 依赖：跨模块"看得见"的边界

```cs
PublicDependencyModuleNames.AddRange(new string[]
{
    "Core",
    "CoreUObject",
    "Engine",
    "GameplayTags",
    "Json",
    "JsonUtilities",
    "PropertyBindingUtils",
    "AngelscriptRuntime",     // ★ 唯一插件内 public 依赖
});
```

含义：

- `AngelscriptTest` 把 `AngelscriptRuntime` 作为**第一公民**。Spec 层可以无障碍调用 `FAngelscriptEngine` / `FAngelscriptClassGenerator` / `FAngelscriptStateDump` 等公开符号。
- 不在 public 列表里的模块（比如 `AngelscriptEditor`），**Helper 层不能把它的头文件 include 进 `Shared/*.h`**——否则非编辑器构建会编译错。
- `GameplayTags` / `Json` / `PropertyBindingUtils` 三个 UE 子模块出现在 public 列表，是因为 Helper 层（`AngelscriptBindingsCoverage.h` / `AngelscriptLearningTrace.h` 等）在头文件就用到了它们的类型。

### 2.3 Private 依赖：headless 也能用的运行时支撑

```cs
PrivateDependencyModuleNames.AddRange(new string[]
{
    "AIModule",
    "EnhancedInput",
    "UMG",
});
```

- `AIModule` / `EnhancedInput` / `UMG` 都是**运行时子模块**，且不带 Editor 标签。它们出现在 private 列表是因为某些 Spec（如 `Functional/Widget/`、`Functional/Inheritance/AAIController*`、`Bindings/AngelscriptEnhancedInputBindingsTests.cpp`）需要真实的 UMG / Input / AI 类型来跑通脚本编译。
- 这部分依赖**对外不可见**——Helper 层即便用到 UMG 的类型，也只能在 `.cpp` 里 include，不能进 `Shared/*.h`，否则会污染 Bindings/ 主题的"轻头"。

### 2.4 Editor-only 依赖：bBuildEditor 守卫块

```cs
if (Target.bBuildEditor)
{
    PrivateDependencyModuleNames.AddRange(new string[]
    {
        "BlueprintGraph",
        "CQTest",
        "Networking",
        "Sockets",
        "UnrealEd",
        "AngelscriptEditor",   // ★ 仅在 Editor 构建里成立的反向依赖
    });
}
```

这是**全模块最关键的一条规则**：

- `AngelscriptEditor` 出现在 `Test` 的 private 依赖里，但只在 `bBuildEditor==true` 时才挂上去。这意味着 Test 模块在 cooked / shipping 构建里**完全看不见** Editor 模块。
- 这一行让若干 Spec（例如 `HotReload/AngelscriptHotReloadTests.cpp`、`Editor/AngelscriptSourceNavigationTests.cpp`、`Bindings/AngelscriptEditorMenuExtensionsTests.cpp` 由 Editor 模块自己持有）可以**调用 Editor 模块的公开符号**，做 hot reload / source navigation / blueprint impact 等场景的端到端验证。
- `CQTest` / `Networking` / `Sockets` 也是 Editor-only 依赖：CQTest 是 UE 自带的 Developer 模块，只在 Editor / Program 链接；Debugger 测试需要 `Networking + Sockets` 起 socket 服务端。
- `BlueprintGraph` / `UnrealEd` 提供 Blueprint 反射类型与编辑器辅助。

> 从这里看，所谓"测试模块对 Editor 是 optional 依赖"——并非靠运行时反射拿；而是靠 **bBuildEditor 守卫**让模块在不同构建配置下"长成不同形状"。如果 cooked target 里挂上 Editor 依赖，UBT 会直接拒绝。

### 2.5 与其他模块的对比

| 模块 | 性质 | 插件内 public 依赖 | 插件内 private 依赖 | 启动 phase |
|------|------|-------------------|--------------------|--------|
| `AngelscriptRuntime` | Runtime | 无 | 无 | `PostDefault` |
| `AngelscriptEditor` | Editor | `AngelscriptRuntime` | 无 | `PostDefault` |
| `AngelscriptTest` | Editor | `AngelscriptRuntime` | `AngelscriptEditor`（仅 `bBuildEditor`） | `PostDefault` |

含义重述：

- Runtime 不依赖 Editor / Test；它是基石。
- Editor 依赖 Runtime；它是单向 build-up。
- Test 同时挂 Runtime + 可选 Editor；它是**唯一可以同时观察两边**的模块。

---

## 三、物理目录矩阵：22 顶层主题 + 20 Functional 二级

### 3.1 顶层目录（除 `Shared` / `Template` 外的主题）

文件计数（截至本文）：

| 主题目录 | .cpp 文件数 | 主要前缀 | 关键 Helper | 一句话定位 |
|---------|------------|---------|------------|-----------|
| `AngelScriptSDK/` | 64 | `Angelscript.TestModule.AngelScriptSDK.*` | `AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h` | Native AS API + ASSDK 适配层（不 import `FAngelscriptEngine`） |
| `Bindings/` | 90 | `Angelscript.TestModule.Bindings.<Type>.*` | `AngelscriptBindingsCoverage.h` / `ModuleBuilder.h` / `Assertions.h` | 按类型的绑定覆盖（CQTest BEFORE_ALL/AFTER_ALL） |
| `Functional/<Theme>/` | 48 | `Angelscript.TestModule.Functional.<Theme>.*` | `FAngelscriptTestWorld` / `AngelscriptFunctionalTestUtils.h` | UE 功能测试（actor / world / 完整生命周期） |
| `Core/` | 34 | `Angelscript.TestModule.CppTests.*` 与 `Angelscript.CppTests.*` | `AngelscriptTestEngineHelper.*` / `AngelscriptTestEnginePool.h` | Runtime 引擎隔离 / 多引擎 / 子系统所有权 |
| `Compiler/` | 31 | `Angelscript.TestModule.Compiler.*` 与 `Angelscript.Compile.*` | `AngelscriptTestEngineHelper.*` | AS 编译器 pipeline 的端到端验证 |
| `ClassGenerator/` | 28 | `Angelscript.TestModule.ClassGenerator.*` 与 `Angelscript.ClassGenerator.*` | `AngelscriptTestEngineHelper.*` | UClass / UStruct 动态生成与 reload 路径 |
| `Syntax/` | 19 | `Angelscript.TestModule.Syntax.*` | `AngelscriptTestEngineHelper.*` | AS 语法（default / mixin / f-string 等）端到端 |
| `Learning/` | 0 + (Native 6 + Runtime 16) | `Angelscript.TestModule.Learning.<Layer>.*` | `AngelscriptLearningTrace.*` | 教学/可观测 trace 测试（结构化输出） |
| `Preprocessor/` | 15 | `Angelscript.TestModule.Preprocessor.*` | `AngelscriptPreprocessorTestHelpers.h` | 预处理器（#include / #if / #pragma） |
| `HotReload/` | 14 | `Angelscript.TestModule.HotReload.*` | `FAngelscriptTestWorld` + ScriptVx 比对 | V1 → V2 重载行为与状态保持 |
| `Debugger/` | 11 | `Angelscript.TestModule.Debugger.*` | `AngelscriptDebuggerTestSession.*` 全家桶 | DAP 握手 / 断点 / 步进的端到端 |
| `StaticJIT/` | 11 + AOT | `Angelscript.TestModule.StaticJIT.*` 与 `Angelscript.StaticJIT.*` | `AngelscriptTestEngineHelper.*` | StaticJIT 预编译产物 + AOT 路径 |
| `Template/` | 7 | `Angelscript.Template.*` | 自身即模板 | 教学样板，不接受新增 case |
| `FileSystem/` | 5 | `Angelscript.TestModule.FileSystem.*` | `AngelscriptTestEngineHelper.*` | 文件解析 / 路径搜索 |
| `Performance/` | 3 | `Angelscript.TestModule.Performance.*` 与 `Angelscript.RuntimeCall.*` | `AngelscriptPerformanceTestUtils.h` | 调用开销基线（BPVM / JIT / Parms） |
| `Dump/` | 2 | `Angelscript.Dump.*` | 直接调 `FAngelscriptStateDump::DumpAll` | `as.DumpEngineState` 控制台命令回归 |
| `GC/` | 2 | `Angelscript.TestModule.GC.*` | `AngelscriptTestEngineHelper.*` | GC 路径与对象生命周期 |
| `Memory/` | 2 | `Angelscript.TestModule.Memory.*` | `AngelscriptTestEngineHelper.*` | 分配器 / 字节码 buffer 行为 |
| `Validation/` | 2 | `Angelscript.TestModule.Validation.*` | — | 启动后状态自检 |
| `Networking/` | 1 | `Angelscript.TestModule.Networking.*` | `AngelscriptTestEngineHelper.*` | RPC 修饰符的编译验证 |
| `Editor/` | 1 | `Angelscript.TestModule.Editor.*` | `AngelscriptTestEngineHelper.*` | 源码导航回归（与 AngelscriptEditor/Tests 不同） |
| `AngelScriptSDK/AOT/` | (StaticJIT 子) | — | — | StaticJIT AOT 二级 |

总和：**22 个顶层目录**（含 Shared / Template / Functional / Learning），其中 `Functional/` 与 `Learning/` 自身含子目录、文件被打散到二级。

### 3.2 Functional/ 的二级主题

`Functional/` 是个**二级主题容器**——`Documents/Guides/TestConventions.md §4` 把它定为 Round1 计划落地的例外，前缀显式带 `Functional.`。20 个子目录：

```text
Functional/
├── Actor/         (9)   ← Actor 生命周期 / 组件管理 / 计时器 / 交互
├── Animation/     (2)   ← 动画 montage / blendspace
├── Blueprint/     (2)   ← BP-AS 互操作
├── Component/     (5)   ← Mesh / Skeletal / Camera 组件
├── ControlFlow/   (1)   ← if / for / while / switch 行为
├── Delegate/      (2)   ← 单播 / 多播运行时
├── Execution/     (6)   ← 函数调用 / 异常 / 早返回
├── Functions/     (2)   ← 全局函数注册
├── Handles/       (1)   ← weak / soft 句柄
├── Inheritance/   (2)   ← 多继承 / 接口装配
├── Interface/     (6)   ← 接口实现与 BP 调用
├── Misc/          (1)   ← 杂项
├── Objects/       (1)   ← 通用对象操作
├── Operators/     (1)   ← 运算符重载
├── Property/      (2)   ← 属性 default / 复制条件
├── Rendering/     (1)   ← 渲染相关脚本
├── Subsystem/     (2)   ← Subsystem 派生
├── Types/         (5)   ← 类型互操作
├── Upgrade/       (1)   ← 跨版本升级
└── Widget/        (1)   ← UMG / SlateScript
```

20 个二级目录加上 22 个顶层（去掉 Functional 自身），构成 **41 个潜在主题落点**。`Plugins/Angelscript/AGENTS.md`（仓库根 AGENTS）保守地写 "**28+ 主题目录**"——这是因为 22 顶层之外只把 Functional 算作 6 个常用类（Actor / Component / Delegate / Interface / Subsystem / 其他），属于历史口径，新文档应以本节实测数字为准。

### 3.3 Learning/ 的双层划分

`Learning/` 的设计目的不在于覆盖率，而在于**教学可观测**：每条 case 通过 `AngelscriptLearningTrace.*` 把内部状态以结构化 trace 写出来，便于读者理解 AS 行为。两个子目录：

```text
Learning/
├── Native/    (6)   ← 不挂 FAngelscriptEngine，只用原生 SDK 的最小循环
└── Runtime/   (16)  ← 挂上完整 Runtime，trace 编译/绑定/执行联动链路
```

其前缀严格区分层级：

```text
Angelscript.TestModule.Learning.Native.*
Angelscript.TestModule.Learning.Runtime.*
```

`Documents/Guides/TestConventions.md` 也明确把它们划入"层级优先"前缀——目录已表达层级时，Automation 路径不再追加额外的 `<Theme>` 段。

---

## 四、Automation 命名空间：三大前缀的边界

### 4.1 三大前缀

`AGENTS.md`（仓库根，行 151）写得最简洁：

> 430 test `.cpp` files organized into 28+ thematic directories... Tests use the Automation prefix convention `Angelscript.TestModule.<Theme>.*` for integration tests, `Angelscript.CppTests.*` for runtime C++ unit tests, and `Angelscript.Editor.*` for editor tests.

落到当前代码里更精确：

| Automation 前缀 | 物理位置 | 用途 |
|----------------|---------|------|
| `Angelscript.TestModule.<Theme>.*` | `AngelscriptTest/<Theme>/` 主题目录 | UE 集成测试 / 端到端验证 |
| `Angelscript.TestModule.CppTests.*` | `AngelscriptTest/Core/`（部分 case）+ `AngelscriptRuntime/Tests/`（运行时内部） | Runtime 内部 C++ 单测的"混合落点" |
| `Angelscript.CppTests.*` | `AngelscriptTest/Core/AngelscriptEngineTypeInteropTests.cpp` 等少量历史 case | 早期未带 `TestModule.` 段的同义前缀 |
| `Angelscript.Editor.*` | `AngelscriptEditor/Tests/` 编辑器模块自带的 49 个 spec | 编辑器专有行为（HotReload / SourceNav / BlueprintImpact） |
| `Angelscript.Template.*` | `AngelscriptTest/Template/` 教学模板 | 演示 case，不算入主回归量 |
| `Angelscript.TestModule.AngelScriptSDK.*` | `AngelscriptTest/AngelScriptSDK/` | Native AS / ASSDK 适配层（含 `.ASSDK.` 二级） |
| `Angelscript.TestModule.Dump.*` | `AngelscriptTest/Dump/AngelscriptDumpTests.cpp` | Runtime dump 控制台命令与 CSV 输出回归 |

历史上还存在一批"短前缀"（`Angelscript.Compile.*` / `Angelscript.Binds.*` / `Angelscript.Reload.*` / `Angelscript.Startup.*` / `Angelscript.RuntimeCall.*` 等），实测仍在 grep 中出现 ~595 个独立前缀字符串。它们大多落在 `Core/` / `Compiler/` / `Performance/` / `ClassGenerator/`，是早期没有强制 `TestModule.` 段时遗留下来的。`TestConventions.md §3` 已经把"新写测试统一带 `TestModule.`"列为规范，但兼容保留项不强制重命名。

### 4.2 三个层级在代码里的样子

**`Angelscript.TestModule.HotReload.*` —— 主题集成测试**

```cpp
// ============================================================================
// 文件: AngelscriptTest/HotReload/AngelscriptHotReloadTests.cpp
// 节选自: 第 23-41 行（4 条 Automation 入口注册）
// ============================================================================
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FAngelscriptTestHotReloadPropertyPreservedTest,
    "Angelscript.TestModule.HotReload.PropertyPreserved",  // ★ 主题前缀
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FAngelscriptTestHotReloadAddPropertyTest,
    "Angelscript.TestModule.HotReload.AddProperty",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FAngelscriptTestHotReloadFunctionChangeTest,
    "Angelscript.TestModule.HotReload.FunctionChange",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
```

特征：传统 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 宏，每条 case 单独注册一个 `FAutomationTestBase` 派生类。

**`Angelscript.TestModule.Bindings.<Type>.*` —— CQTest 绑定覆盖**

```cpp
// ============================================================================
// 文件: AngelscriptTest/Bindings/AngelscriptColorBindingsTests.cpp
// 节选自: 第 16-28 行（CQTest 测试类 + 两个 TEST_METHOD）
// ============================================================================
static const FBindingsCoverageProfile GColorProfile{
    TEXT("Color"), TEXT(""), TEXT("ASColor"), TEXT("Color"), TEXT("ColorBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptColorBindingsTest,
    "Angelscript.TestModule.Bindings.Color",                // ★ 主题前缀（CQTest 会再追加方法名）
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
    AFTER_ALL() { FAngelscriptEngine& E = ASTEST_GET_ENGINE(); ASTEST_RESET_ENGINE(E); }

    TEST_METHOD(FColorConstruction)              // → Angelscript.TestModule.Bindings.Color.FColorConstruction
    {
        FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
        // ...
    }
};
```

特征：`TEST_CLASS_WITH_FLAGS` + 多个 `TEST_METHOD`，CQTest 会把每个方法注册成独立 Automation case（最终路径是 `<class-prefix>.<method-name>`）。

**`Angelscript.TestModule.AngelScriptSDK.*` —— Native 单测**

```cpp
// ============================================================================
// 文件: AngelscriptTest/AngelScriptSDK/AngelscriptNativeSmokeTest.cpp
// 节选自: 第 10-15 行（不挂 FAngelscriptEngine 的最小 SDK 测试）
// ============================================================================
TEST_CLASS_WITH_FLAGS(FAngelscriptNativeSmokeTest,
    "Angelscript.TestModule.AngelScriptSDK",                // ★ 不挂 .Smoke 子段，CQTest 用方法名补齐
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    TEST_METHOD(Smoke)
    {
        FNativeMessageCollector Messages;
        asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);  // ★ 原生 SDK，不经 FAngelscriptEngine
        // ...
    }
};
```

特征：直接调用 AS 原生 API（`asIScriptEngine` / `asIScriptModule`），目的是把 ThirdParty 内核的"裸"行为隔离出来——避免 Runtime 改动牵连 Native 行为。

**`Angelscript.Editor.*` —— Editor 模块自带的 spec**

```cpp
// 节选自: AngelscriptEditor/Tests/AngelscriptBlueprintImpactScannerCoreTests.cpp
"Angelscript.Editor.BlueprintImpact.BuildImpactSymbols.CollectsDelegatesAndSkipsNulls"
"Angelscript.Editor.BlueprintImpact.MatchChangedScriptsToModuleSections.EmptyInputReturnsAllModules"
```

这些 case **不在 AngelscriptTest 模块里**——它们住在 `AngelscriptEditor/Tests/` 下，由 `AngelscriptEditor.Build.cs` 自己挂 `bBuildEditor` 守卫块。本文不展开它们的内部细节（去 `Test_RuntimeInternal.md`），只是说明：

> `Angelscript.Editor.*` 是**与 Test 模块平级的第二条测试通道**——它的存在让 `AngelscriptEditor` 在不依赖 `AngelscriptTest` 的前提下也能自测。这也解释了为什么 `AngelscriptTest` 的 Editor 依赖是 private 而不是 public：Editor 不需要"通过 Test 反向访问"。

### 4.3 与 Runtime/Tests 的并存

`AngelscriptRuntime/Tests/` 在仓库当前 baseline 里**不存在**实体目录（`ls` 返回空）。`Documents/Guides/TestConventions.md §1` 把 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 标为 `Angelscript.TestModule.CppTests.*` 的"理想落点"，但实际历史 case 都在 `AngelscriptTest/Core/` 里：

```cpp
// 节选自: AngelscriptTest/Core/AngelscriptEngineExtensionRegistryTests.cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptEngineExtensionRegistryTests,
    "Angelscript.TestModule.CppTests.Engine.Extension",  // ★ TestModule.CppTests
    ...);

// 节选自: AngelscriptTest/Core/AngelscriptEngineTypeInteropTests.cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptEngineTypeInteropTests,
    "Angelscript.CppTests.Engine.TypeInterop",            // ★ 直接 CppTests，无 TestModule.
    ...);
```

含义：`Angelscript.TestModule.CppTests.*` 与 `Angelscript.CppTests.*` 在当前 baseline 是**同一族的两种写法**。`Test_RuntimeInternal.md` 会专门讨论这块的取舍。

---

## 五、文件命名约定

### 5.1 通用规则（`TestConventions.md §2`）

- 文件名一律以 `Angelscript` 开头。`PreprocessorTests.cpp` 这种缺少前缀的写法在 2026-04 已批量改名。
- 单一聚焦 case 用 `*Test.cpp`；多 case 集合用 `*Tests.cpp`。例如 `AngelscriptNativeSmokeTest.cpp`（单 case）vs `AngelscriptColorBindingsTests.cpp`（多 case）。
- `Template/` 不接受新增；新主题必须落在对应主题目录。
- ASSDK / Native：纯原生 API 用 `AngelscriptNative*Tests.cpp`，ASSDK 适配层用 `AngelscriptASSDK*Tests.cpp`。

### 5.2 文件名 → Automation 路径的映射

文件名前缀和 Automation 路径**故意不一一对应**——文件名表达"这个文件测什么家族"，Automation 路径表达"这个 case 在 Automation Tree 里挂在哪儿"。常见 mapping：

| 文件名（去掉 Angelscript 前缀） | Automation 入口 | 说明 |
|----------------------------|---------------|------|
| `HotReload/AngelscriptHotReloadTests.cpp` | `Angelscript.TestModule.HotReload.{PropertyPreserved, AddProperty, FunctionChange, ...}` | 4-5 条 case 共享一个文件，每条 case 路径以行为命名 |
| `Bindings/AngelscriptColorBindingsTests.cpp` | `Angelscript.TestModule.Bindings.Color.{FColorConstruction, FLinearColorConstruction, ...}` | CQTest 类 + 多 TEST_METHOD |
| `AngelScriptSDK/AngelscriptNativeSmokeTest.cpp` | `Angelscript.TestModule.AngelScriptSDK.Smoke` | 单 case |
| `AngelScriptSDK/AngelscriptASSDKExecuteTests.cpp` | `Angelscript.TestModule.AngelScriptSDK.ASSDK.Execute.*` | ASSDK 二级前缀 |
| `Compiler/AngelscriptCompilerPipelineDelegateTests.cpp` | `Angelscript.TestModule.Compiler.Pipeline.Delegate.*` 或 `Angelscript.Compile.Modules.*`（看具体 case） | Compiler 主题，前缀有历史变体 |
| `Functional/Actor/AngelscriptActorLifecycleTests.cpp` | `Angelscript.TestModule.Functional.Actor.Lifecycle.*` | Functional 例外段保留 `Functional.` |
| `Learning/Runtime/Angelscript*RuntimeTrace*Tests.cpp` | `Angelscript.TestModule.Learning.Runtime.*` | 层级优先前缀 |

### 5.3 反例：什么不是合法的命名

```text
✗ PreprocessorTests.cpp                  # 缺 Angelscript 前缀（已被纠正）
✗ Template/MyNewTopicTests.cpp           # 不在 Template/ 下新增 case
✗ AngelscriptHotReload.cpp               # 文件名未带 Test/Tests 后缀
✗ Bindings/AngelscriptVectorTest.cpp     # 多 TEST_METHOD 不应该用单数 Test
✗ "Angelscript.HotReload.PropertyPreserved"   # 缺 TestModule. 段（新写不允许）
```

---

## 六、跨家族协作：与 Editor / Runtime / Dump 的粘合

### 6.1 三方测试通道

```text
                         ┌────────────────────────────────┐
                         │ AngelscriptRuntime/Tests/      │
                         │ （当前为占位；CppTests case    │
                         │  实际落在 AngelscriptTest/Core）│
                         └─────────────▲──────────────────┘
                                       │
                                       │ 同前缀族 Angelscript.{TestModule.}CppTests.*
                                       │
┌──────────────────────┐   public dep  │      private dep (bBuildEditor)
│ AngelscriptTest      │ ──────────────┴───────────────► AngelscriptEditor
│  Spec / Template /   │                                 │
│  Helper 三层         │ ◀── Editor 的 spec 不在这里 ──┤
│                      │     而在 AngelscriptEditor/    │
│ Angelscript.TestModule.<Theme>.* │ Tests/             │
│ Angelscript.Template.*           │                    │
└──────────────────────┘             └─Angelscript.Editor.* ┘
```

三条测试通道并存的好处：

- **关注点分离**：Editor 改动不会强制重新编译 `AngelscriptTest`；Runtime 改动不会触动 Editor 的测试。
- **跨界 fixture 不需要**：Test 模块通过 private Editor 依赖直接拿到 `FClassReloadHelper` / `FAngelscriptDirectoryWatcher` 等编辑器符号，无需 Editor 反向把测试 fixture 暴露出来。
- **观察方向收敛**：只有 Test 既能看 Runtime 又能看 Editor。Editor 不允许反向依赖 Test（`AngelscriptEditor.Build.cs` 不挂 `AngelscriptTest`）。

### 6.2 Test 模块的启动职责

`AngelscriptTestModule.cpp` 在启动期做两件事：

```cpp
// ============================================================================
// 文件: AngelscriptTest/AngelscriptTestModule.cpp
// 函数: FAngelscriptTestModule::StartupModule（节选）
// 角色: 测试模块的"装载 hook"，影响 Engine 子系统的初始化顺序
// ============================================================================
void FAngelscriptTestModule::StartupModule()
{
    const bool bUseScanFreeStartupEngine = FParse::Param(FCommandLine::Get(),
        TEXT("AngelscriptTestUseScanFreeStartupEngine"));
    if (bUseScanFreeStartupEngine)
    {
        // ★ 在 Engine 初始化前，把 UAngelscriptEngineSubsystem 的 init 路径替换成
        //   一个不扫描 Editor script root 的轻量引擎，便于裁剪 headless 测试环境。
        GAngelscriptTestStartupOverrideEngine = AngelscriptTestSupport::CreateScriptScanFreeFullEngineForTesting(...);
        UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting([]() -> FAngelscriptEngine*
        {
            return GAngelscriptTestStartupOverrideEngine.Get();
        });
    }

    const bool bPrewarmEngine = FParse::Param(FCommandLine::Get(),
        TEXT("AngelscriptTestPrewarmEngine"));
    AngelscriptTestSupport::StartupTestEnginePool(bPrewarmEngine);  // ★ 引擎池
}
```

两个命令行开关（详见 `Arch_ModuleLoading.md`）：

- `-AngelscriptTestUseScanFreeStartupEngine`：用一个不扫描脚本根的引擎接管启动，跳过 cooked-style script 编译，加快 headless 启动。
- `-AngelscriptTestPrewarmEngine`：在启动期把 `FAngelscriptTestEnginePool` 预热（创建 N 个空闲引擎），让首批 spec 的 `ASTEST_CREATE_ENGINE_FULL` 不必等 reset。

`ShutdownModule` 则反向解除：归还 prewarm 引擎、清空 override 指针。

### 6.3 与 Dump 的关系

Dump 子系统的入口在 Runtime 模块（`FAngelscriptStateDump::DumpAll`），`as.DumpEngineState` 控制台命令也由 Runtime 注册。`AngelscriptTest/Dump/AngelscriptDumpTests.cpp` 负责验证命令已注册，并跑一次 `DumpAll` 断言生成的 CSV 文件存在。本文不展开 27 张表的字段——去 `RT_StateDump.md`。这里只点出**它在分层里的位置**：

```text
RT_StateDump 链路（在 Runtime 内部）
        │
        ▼
FAngelscriptStateDump::DumpAll()  ←──── 被 AngelscriptTest/Dump/ spec 调用做回归
        │
        ▼  (OnDumpExtensions 多播)
AngelscriptEditor/Dump/  贡献额外表；AngelscriptTest/Dump/  验证输出契约
```

> Test 模块对 Dump 的"消费"是单向的：验证命令 → 调用 dump → 断言文件 → 清理。它**不**被允许往 `OnDumpExtensions` 注册新行（注册是 Editor 模块的活）。

---

## 七、测试规模口径：三个数字的区分

`AGENTS.md`（仓库根，行 184–189）的"Test Number Baselines"明确要求**三个口径不能混用**：

```text
口径 1: 275/275 PASS         ← 编目过的 C++ 基线（TestCatalog.md）
                              针对的是"被严格盘点、批准入册"的子集，
                              不是全部 case。

口径 2: 1518+ across 430 .cpp ← 源码扫描后的"自动化定义总数"
                              按 IMPLEMENT_*_AUTOMATION_TEST + TEST_METHOD
                              一次扫一次，由 test-as-native-sdk-coverage 计入。
                              430 是 .cpp 文件总数。

口径 3: 301/301 PASS         ← Native AS / ASSDK 子前缀的最新一次跑全
                              专指 Angelscript.TestModule.AngelScriptSDK.*
                              （含 151 个新 Tokenizer/Parser/ScriptNode/
                              Bytecode/Reference 覆盖 case）。

补充: 2 Disabled              ← TestEngineHelperTests.cpp:106
                              + SourceNavigationTests.cpp:125
                              均为 #ue57-headless 已知限制。

实际 live-suite 数字          ← 以 TechnicalDebtInventory.md 为准。
```

**为什么必须区分？**

- 275 是"已编目"的概念，不会随新 case 增加而自动膨胀；只有走过 `TestCatalog.md` 入册流程才计入。
- 1518+ 是源码扫描总量，新增 spec 立刻反映；但其中包括 disabled / 互斥 / 仅在某 build target 跑的。
- 301 是子前缀 live 跑通的快照；和总量 / 编目都不是一回事。

> 文档写作时**不要**说"AngelscriptTest 模块共 275 个测试"——这同时混淆了三种口径。规范写法是"AngelscriptTest 模块下源码扫描得到 1518+ Automation 定义，分布在 430 个 .cpp 文件、22 个顶层主题目录与 20 个 Functional 二级目录里；其中 275 已纳入 TestCatalog 编目基线，301 隶属于 AngelScriptSDK 子前缀"。

---

## 附录 A：测试目录速查

按"主题 → Automation 前缀 → 主要 helper"快速对应：

| 主题目录 | Automation 前缀 | 主要 Helper / Macro | 备注 |
|---------|---------------|--------------------|------|
| `AngelScriptSDK/` | `Angelscript.TestModule.AngelScriptSDK.*`（含 `.ASSDK.*`） | `AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h` / `ASTEST_CREATE_ENGINE_NATIVE` | 不挂 `FAngelscriptEngine` |
| `Bindings/` | `Angelscript.TestModule.Bindings.<Type>.*` | `CQTest.h` / `AngelscriptBindings{Coverage,ModuleBuilder,Assertions}.h` / `FCoverageModuleScope` | 90 文件，CQTest 主战场 |
| `Functional/<Theme>/` | `Angelscript.TestModule.Functional.<Theme>.*`（保留例外段） | `FAngelscriptTestWorld` / `AngelscriptFunctionalTestUtils.h` | 20 二级，actor/world 完整生命周期 |
| `Core/` | `Angelscript.TestModule.{CppTests,}.*` 等 | `AngelscriptTestEngineHelper.*` / `AngelscriptTestEnginePool.h` | Runtime 内部行为 |
| `Compiler/` | `Angelscript.TestModule.Compiler.*` / `Angelscript.Compile.*` | `AngelscriptTestEngineHelper.*` | 编译器 pipeline |
| `ClassGenerator/` | `Angelscript.TestModule.ClassGenerator.*` / `Angelscript.ClassGenerator.*` | 同上 | UClass 生成 + reload |
| `Syntax/` | `Angelscript.TestModule.Syntax.*` | 同上 | AS 语法 |
| `Learning/Native/` | `Angelscript.TestModule.Learning.Native.*` | `AngelscriptLearningTrace.*` + `AngelscriptNativeTestSupport.h` | 教学，Native |
| `Learning/Runtime/` | `Angelscript.TestModule.Learning.Runtime.*` | `AngelscriptLearningTrace.*` + `AngelscriptTestEngineHelper.*` | 教学，Runtime |
| `Preprocessor/` | `Angelscript.TestModule.Preprocessor.*` | `AngelscriptPreprocessorTestHelpers.h` | 预处理器 |
| `HotReload/` | `Angelscript.TestModule.HotReload.*` / `Angelscript.Reload.*` | `FAngelscriptTestWorld` + V1/V2 模板 | 热重载 |
| `Debugger/` | `Angelscript.TestModule.Debugger.*` / `Angelscript.DebugServer.*` | `AngelscriptDebuggerTest{Session,Client,Monitor,Fixture}.*` | DAP 协议 |
| `StaticJIT/` | `Angelscript.TestModule.StaticJIT.*` / `Angelscript.StaticJIT.*` | `AngelscriptTestEngineHelper.*` | 含 AOT/ |
| `Template/` | `Angelscript.Template.*` | 自身即模板 | 不接受新增 |
| `FileSystem/` | `Angelscript.TestModule.FileSystem.*` | `AngelscriptTestEngineHelper.*` | 文件 / 路径 |
| `Performance/` | `Angelscript.TestModule.Performance.*` / `Angelscript.RuntimeCall.*` | `AngelscriptPerformanceTestUtils.h` | 性能基线 |
| `Dump/` | `Angelscript.Dump.*` | `FAngelscriptStateDump::DumpAll` | `as.DumpEngineState` |
| `GC/` `Memory/` `Validation/` `Networking/` `Editor/` | `Angelscript.TestModule.{GC,Memory,Validation,Networking,Editor}.*` | `AngelscriptTestEngineHelper.*` | 各 1–5 文件 |

---

## 附录 B：命名约定速查

```text
文件命名:
  Angelscript<Theme>{Topic}{Tests|Test}.cpp      # 标准
  AngelscriptNative<Topic>Tests.cpp              # Native AS 公共 API
  AngelscriptASSDK<Topic>Tests.cpp               # ASSDK 适配层
  Template_<TopicSnake>.cpp                      # Template/ 例外（无 Angelscript 前缀）

Automation 前缀（按优先级写法）:
  Angelscript.TestModule.<Theme>.<Case>          # 默认（主题优先）
  Angelscript.TestModule.AngelScriptSDK.<Sub>.*  # Native + ASSDK 二级
  Angelscript.TestModule.Functional.<Theme>.*    # Functional/ 例外段（保留）
  Angelscript.TestModule.Learning.<Layer>.*      # 层级优先
  Angelscript.TestModule.CppTests.*              # Runtime 内部 C++ 单测
  Angelscript.Editor.*                            # AngelscriptEditor/Tests/ 内
  Angelscript.Template.*                          # Template/ 教学
  Angelscript.{Compile,Reload,Binds,...}.*       # 历史短前缀（不再新增）

Helper 引用顺序（include 风格）:
  #include "CQTest.h"                              // 框架在最前
  #include "Shared/AngelscriptTestMacros.h"        // 引擎宏
  #include "Shared/AngelscriptBindingsCoverage.h"  // 主题专属 Helper
  #include "Shared/AngelscriptBindingsModuleBuilder.h"
  #include "Shared/AngelscriptBindingsAssertions.h"
  #include "Misc/AutomationTest.h"                 // UE 标准
  #include "Misc/ScopeExit.h"
```

---

## 附录 C：避坑清单

1. **新主题不要落进 Template/**。`Template/` 是教学样板专用，新增需求请去对应主题目录或新建主题目录；模板自身不要随业务膨胀。
2. **不要在 Helper 头文件 include 编辑器符号**。`AngelscriptEditor` 是 private + bBuildEditor 双守卫；任何把 Editor 类型搬到 `Shared/*.h` 的写法都会让 cooked target 编译失败。
3. **AngelScriptSDK/ 下不要 import `FAngelscriptEngine`**。这一目录的存在意义是测原生 SDK 的"裸"行为；引入 Runtime 引擎会破坏隔离。需要 Runtime 行为请去 `Core/` 或 `Compiler/`。
4. **Automation 路径不要漏 `TestModule.` 段**。新 case 必须落在 `Angelscript.TestModule.<Theme>.*` 之下；除非显式延续历史 `Angelscript.Compile.*` / `Angelscript.Reload.*` 这类兼容族。
5. **不要在文档里把 275 / 1518 / 301 三个数字混用**。三种口径见 §七；新写文档遇到"测试总数"先确认是哪种口径。
6. **Functional/ 的二级前缀是例外，不要扩散到其他主题**。`Angelscript.TestModule.Functional.<Theme>.*` 是 Round1 计划落地的保留段，其他主题（Actor / Component / Delegate / Interface 等）已直接挂在顶层 `<Theme>.*`，不要画蛇添足。
7. **`Editor/` 子目录与 `AngelscriptEditor/Tests/` 不是一回事**。前者是 `AngelscriptTest/Editor/`（1 个 source navigation 回归），后者是 `AngelscriptEditor/Tests/`（49 个 spec、`Angelscript.Editor.*` 前缀）。命名相近但模块不同。
8. **`Template/Template_*.cpp` 注册的 Automation 入口是 `Angelscript.Template.*`，不是 `Angelscript.TestModule.Template.*`**。这是历史保留，不要"贴心"地改成对齐前缀。
9. **新增 Helper 优先放进 `Shared/`，不要散在主题目录里**。`Shared/` 是 Helper 层的唯一物理落点，跨主题 Helper 散落到主题目录会让 `Test_Infrastructure.md` 的"40+ Helper 一键速查"塌掉。
10. **`AngelscriptTest.Build.cs` 修改前先核对依赖语义**。把某模块从 `bBuildEditor` 块里搬到 public 列表会让 cooked target 拒绝编译；反过来把 Runtime 模块挪到 private 也会让头文件无法被其他模块 include。改 Build.cs 时同步看本文 §二。

---

## 小结

- `AngelscriptTest` 内部按 **Spec / Template / Helper** 三层组织：Spec 散布在 22 个顶层主题 + 20 个 Functional 二级；Template 是 7 份教学样板；Helper 是 `Shared/` 下的 40+ utility。
- **Build.cs 是依赖边界的唯一真相**：public 仅一个 `AngelscriptRuntime`，private + `bBuildEditor` 守卫块挂上 `AngelscriptEditor` / `CQTest` / `Networking` / `Sockets` / `UnrealEd` / `BlueprintGraph`。这套结构让 Test 成为同时观察 Runtime 与 Editor 的唯一窗口。
- **三大 Automation 前缀** 与代码位置一一对应：`Angelscript.TestModule.<Theme>.*` 落在 `AngelscriptTest/<Theme>/`，`Angelscript.{TestModule.}CppTests.*` 是 Runtime 内部单测的同义族，`Angelscript.Editor.*` 住在 `AngelscriptEditor/Tests/` 不归本模块管。
- **测试规模有三种口径**——`275/275`（编目）、`1518+ / 430`（源码扫描）、`301/301`（AngelScriptSDK 子前缀），写文档时必须区分。
- 后续兄弟文章会继续展开：`Test_Infrastructure.md` 拆 Helper 层、`Test_TopicClusters.md` 拆主题映射、`Test_RuntimeInternal.md` 拆 Runtime/Editor 内部测试通道。本文是这三篇的入口。
