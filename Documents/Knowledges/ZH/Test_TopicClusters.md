# Test_TopicClusters — 主题测试簇映射

> **所属前缀**: Test_（测试架构族）
> **关注层面**: `AngelscriptTest` 下 22 个顶层主题目录 + 20 个 Functional 二级目录的能力面归属、彼此边界、典型测试模式与 Knowledges 文章的对应关系（不逐 case 列文件、不重述模块分层与 Helper 实现）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptTest/<Theme>/` (22 个顶层主题目录)
> · `Plugins/Angelscript/Source/AngelscriptTest/Functional/<Sub>/` (20 个二级主题目录)
> · `Plugins/Angelscript/Source/AngelscriptTest/Learning/{Native,Runtime}/`
> · `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/`
> · `Documents/Guides/TestCatalog.md` — 275/275 编目基线
> · `Documents/Guides/TestConventions.md` — 主题前缀与目录约定
> **关联文档**:
> `Documents/Knowledges/ZH/Test_Layering.md` — 三层骨架与 Build.cs 边界（本文是其主题视角的延伸）
> · `Documents/Knowledges/ZH/Test_Infrastructure.md` — Helper 层细节（本文不重复）
> · `Documents/Knowledges/ZH/Note_CQTest.md` — CQTest 框架使用笔记
> · `Documents/Knowledges/ZH/Index.md` — 知识库总览（本文末尾给反向映射）
> **外部参考**:
> `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE_ZH.md` — 模块内部速查
> · `Documents/Guides/TestPerformance.md` — 性能基线读法

---

## 概览

本文聚焦一个核心问题：**`AngelscriptTest` 下的 22 个顶层主题目录 + 20 个 Functional 二级目录，各自覆盖什么能力面、与其他簇的边界画在哪里、典型测试模式是哪一种、对应的 Knowledges 文章是哪一篇？**

这是 P5 Test_ 族的第三篇。它**不**重述模块的物理分层与 Build.cs 边界（去 `Test_Layering.md`），**不**展开 Helper 层的 40+ 工具与宏（去 `Test_Infrastructure.md`），**不**复述 CQTest 框架机制（去 `Note_CQTest.md`），**不**列单条 case（429+ 文件的枚举只会让本文成为索引垃圾）。它只回答"每个目录 = 一族能力，这族能力的边界与对外参照在哪"。

```text
                              ┌─────────────────────────────────┐
                              │  AngelscriptTest 主题簇（41 个）  │
                              └────────────────┬────────────────┘
                                               │
        ┌──────────────────────────────────────┼──────────────────────────────────────┐
        │                                      │                                      │
        ▼                                      ▼                                      ▼
┌──────────────────┐             ┌──────────────────────────┐             ┌────────────────────┐
│  按 UE 能力面     │             │  按 AS 语言机制 / 语法    │             │  按运行时子系统     │
│  (engine / actor) │             │  (Syntax / Compiler)     │             │  (RT_*) 切片        │
├──────────────────┤             ├──────────────────────────┤             ├────────────────────┤
│ Functional/Actor   │             │ Syntax/                  │             │ HotReload/         │
│ Functional/Component│             │ Functional/Inheritance  │             │ StaticJIT/ + AOT/   │
│ Functional/Animation│             │ Functional/Interface    │             │ Debugger/          │
│ Functional/Widget   │             │ Functional/Delegate     │             │ GC/                │
│ Functional/Rendering│             │ Functional/Operators    │             │ Memory/            │
│ Functional/Blueprint│             │ Functional/Handles      │             │ Performance/       │
│ Bindings/           │             │ Functional/Property     │             │ Functional/Subsystem│
│ ClassGenerator/    │             │ Functional/Types        │             │ Compiler/          │
│ Functional/Subsystem│             │ Functional/ControlFlow  │             │ Preprocessor/      │
│                  │             │ Functional/Execution    │             │                    │
│                  │             │ Functional/Functions    │             │                    │
│                  │             │ Functional/Objects      │             │                    │
└──────────────────┘             └──────────────────────────┘             └────────────────────┘

        ┌──────────────────────────────────────┬──────────────────────────────────────┐
        │                                      │                                      │
        ▼                                      ▼                                      ▼
┌──────────────────┐             ┌──────────────────────────┐             ┌────────────────────┐
│  特殊场景         │             │  Native / 教学 / 编目     │             │  跨界回归            │
├──────────────────┤             ├──────────────────────────┤             ├────────────────────┤
│ Networking/       │             │ AngelScriptSDK/          │             │ Functional/Upgrade  │
│ Dump/             │             │ Learning/Native          │             │ Functional/Misc     │
│ Validation/       │             │ Learning/Runtime         │             │ Editor/             │
│ FileSystem/       │             │ Template/                │             │ Functional/Blueprint│
│ Core/             │             │                          │             │                    │
└──────────────────┘             └──────────────────────────┘             └────────────────────┘
```

后续章节按 "簇分类四轴 → UE 能力面簇 → AS 语言机制簇 → 运行时子系统簇 → 特殊场景簇 → Native/教学簇 → 跨簇协作 → 决策表 → 排错指南" 的顺序推进，最后用两张速查表收口。

---

## 一、簇分类四轴

`AngelscriptTest/` 下的目录命名既不严格按"语言层"也不严格按"模块层"，而是**沿着不同维度切片**——理解这一点比死记每个目录测什么更有用。本文采用四个正交轴，把 41 个簇映射到一个二维平面（每个簇可能落在 1–2 个轴上）。

### 1.1 四个分类轴

| 轴名 | 切的是什么 | 落点目录举例 |
|------|-----------|-------------|
| **A. UE 能力面** | UE 引擎对象/系统层级（Actor / Component / Blueprint / UI / Rendering / Subsystem） | `Functional/Actor`、`Functional/Component`、`Bindings/`、`ClassGenerator/` |
| **B. AS 语言机制** | AngelScript 语法/类型系统/编译器 pipeline | `Syntax/`、`Compiler/`、`Functional/Inheritance`、`Functional/Delegate`、`Preprocessor/` |
| **C. 运行时子系统** | RT_ 族对应的运行时切片（HotReload / JIT / Debugger / GC） | `HotReload/`、`StaticJIT/`、`Debugger/`、`GC/`、`Memory/`、`Performance/` |
| **D. 特殊场景** | 单点闭环或 commandlet / 控制台命令回归 | `Networking/`、`Dump/`、`Validation/`、`FileSystem/`、`Editor/` |

### 1.2 四轴并不互斥

举例说明：

- `Functional/Subsystem/` 同时落在 A（UE 能力面：四大子系统）+ C（运行时子系统：脚本 Subsystem 派生）。
- `ClassGenerator/` 主要落在 A（UClass/UStruct 生成），但与 C（HotReload / StaticJIT 共享 reload 路径）紧密协作。
- `Compiler/` 主要落在 B（AS 语言）+ D（commandlet pipeline 验证）。

这意味着"哪个簇覆盖某个能力"不是 1 对 1 映射——遇到一个新需求需要落 case，应先看本文 §八 的决策表，而不是按目录字面意思猜。

### 1.3 与 `Test_Layering` 的口径同步

本文延用 `Test_Layering.md` §三 的物理目录矩阵：

- **22 顶层目录**（含 Shared / Template / Functional / Learning，但 Shared / Template 不属于"被运行的簇"）。
- **20 Functional 二级目录**（在 §三 全量列出）。
- 测试规模口径（`275/275` 编目 / `1518+/430` 源码扫描 / `301/301` AngelScriptSDK live）见 `Test_Layering.md` §七，不重复。
- 命名约定（`Angelscript<Theme>{Topic}{Tests|Test}.cpp` + `Angelscript.TestModule.<Theme>.*`）见 `Test_Layering.md` §五，不重复。

---

## 二、UE 能力面簇（A 轴）

按 UE 引擎对象层级从外到内：Actor / Component / Animation / Widget / Rendering → Blueprint 互操作 → Bindings 全量覆盖 → ClassGenerator 动态类。

### 2.1 `Functional/Actor/` — Actor 生命周期与组件管理（9 文件）

覆盖什么：Actor 的 `BeginPlay/Tick/EndPlay` 序列、组件挂载/查找/销毁、Timer 与 SetTimerByEvent、AS-Spawn/Destroy、Trigger/Overlap 交互。

不覆盖：BP 派生（去 `Functional/Blueprint`）、Component 单组件行为（去 `Functional/Component`）、Subsystem 全局生命周期（去 `Functional/Subsystem`）。

典型测试模式：`FAngelscriptTestWorld` 起一个临时世界 → 反射 spawn AActor 派生 → `TickWorld(N)` → `ExpectGlobalInt("ActorBeginPlayCount", 1)`。

代表测试：`AngelscriptActorComponentManagementTests.cpp` / `AngelscriptActorComponentTests.cpp`。

对应 Knowledges：`Type_BaseClass.md`（脚本基类扩展 Actor 路径）、`Guide_QuickStart.md`（用户视角）。

### 2.2 `Functional/Component/` — 单组件行为（5 文件）

覆盖什么：StaticMeshComponent / SkeletalMesh / Camera / 自定义脚本 Component 的 default property 覆盖、组件 Tick、组件级生命周期（不依赖 Actor 串联）。

不覆盖：Actor 内组件挂载（去 `Functional/Actor`）、Animation 通知（去 `Functional/Animation`）。

典型测试模式：CQTest `BEFORE_ALL` 编一个最小脚本组件 → 反射读 default property → 检查 reload 后 default 是否保持。

代表测试：`AngelscriptComponentDefaultPropertyOverrideTests.cpp` / `AngelscriptComponentLifecycleExtendedTests.cpp`。

对应 Knowledges：`Type_BaseClass.md`、`Syntax_DefaultComponent.md`。

### 2.3 `Functional/Animation/` — AnimNotify / Montage（2 文件）

覆盖什么：AnimNotifyScript / AnimNotifyState / Montage Section 的 AS 派生与 BP 调用。

不覆盖：MovementComponent 物理（无专门测试）、AnimBP 编译（去 `Functional/Blueprint`）。

代表测试：`AngelscriptAnimationAnimNotifyScriptTests.cpp` / `AngelscriptAnimationAnimNotifyStateScriptTests.cpp`。

对应 Knowledges：暂无独立 Animation 主题文章。

### 2.4 `Functional/Widget/` + `Functional/Rendering/` — UI 与渲染（各 1 文件）

`Widget/`：UMG/SlateScript 的 BindWidget 注解与脚本派生。代表 `AngelscriptWidgetBindWidgetTests.cpp`。

`Rendering/`：动态材质参数集合在脚本内的访问。代表 `AngelscriptRenderingDynamicMaterialTests.cpp`。

两者都属于"轻覆盖"——只要保证脚本能创建/绑定/读写一次即可，不做大规模回归。

对应 Knowledges：`Guide_UIManagement.md`（用户视角）。

### 2.5 `Functional/Blueprint/` + `Bindings/` + `ClassGenerator/` — BP 互操作三元组

这三个簇是**互相协作的整体**：

- **`Functional/Blueprint/`（2 文件）**：BP 子类继承 AS 类、AS 继承 BP 父类、BP 调用 AS 函数、BP 改动后 AS 受影响列表。代表 `AngelscriptBlueprintChildTests.cpp` / `AngelscriptBlueprintImpactTests.cpp`。覆盖**互操作行为**。
- **`Bindings/`（90 文件）**：每个 UE C++ 类型（FVector / FColor / TSubclassOf / USceneComponent / UMG.Widget / FAssetData / FCollisionParams / ...）的脚本绑定**全量覆盖**。CQTest BEFORE_ALL 起引擎 + `FCoverageModuleScope` 编模块 + 一组 `TEST_METHOD` 逐个验证 ctor / op= / property / 静态方法 / mixin。
- **`ClassGenerator/`（28 文件）**：脚本 class/struct 反射成 UClass/UStruct 的**生成机制**——meta、property layout、UFUNCTION exposure、reload 时的 reinstance。代表 `AngelscriptASClassActorConstructionTests.cpp` / `AngelscriptASClassComponentConstructionTests.cpp`。

边界：

```text
源 (.as)        机制                        消费方
  ▼              ▼                           ▼
脚本 class ─► ClassGenerator ─► UClass ─► Bindings 提供 UE 类型 ─► Functional/Blueprint
                                                                       ↑
                                                                 BP 反向调用
```

对应 Knowledges：`Type_ClassGeneration.md`（生成机制）、`Type_BindSystem.md`（绑定系统）、`Note_InterfaceBinding.md`（接口部分）。

### 2.6 `Functional/Subsystem/` — 四大子系统（2 文件）

覆盖什么：`UAngelscriptScriptSubsystem` / `UScriptWorldSubsystem` / `UScriptGameInstanceSubsystem` / `UScriptLocalPlayerSubsystem` 的脚本派生、生命周期 hook、彼此的所有权关系。

不覆盖：编辑器子系统（无脚本派生路径）。

典型测试：`AngelscriptGameInstanceSubsystemRuntimeTests.cpp`（GameInstance 子系统 Tick 互斥与所有权）/ `AngelscriptSubsystemTests.cpp`（四档全覆盖）。

对应 Knowledges：`Type_Core.md`、`Guide_SubsystemUsage.md`。

---

## 三、AS 语言机制簇（B 轴）

按 AS 编译器 pipeline 从外到内：预处理器 → 语法 → 编译器中端 → 类型/继承/接口 → 控制流/执行 → 委托/算子 → 句柄/属性。

### 3.1 `Preprocessor/` — 预处理器（15 文件）

覆盖什么：`#include` / `#if` / `#pragma` / 异步预处理 / class 注解 / module 边界。

不覆盖：编译器后续步骤（去 `Compiler/`）。

代表测试：`AngelscriptPreprocessorBasicTests.cpp`（基础宏）/ `AngelscriptPreprocessorAsyncTests.cpp`（异步 include）/ `AngelscriptPreprocessorClassTests.cpp`（class 注解展开）。

对应 Knowledges：`Type_Preprocessor.md`。

### 3.2 `Syntax/` — AS 语法（19 文件）

覆盖什么：access 修饰符、类型转换、容器语法、default 语句、mixin、f-string、属性访问器、运算符等所有"AS 语法关键字"。

不覆盖：UFUNCTION / UPROPERTY 注解（去 `ClassGenerator/` 与 `Bindings/`）、对应运行时（去 `Functional/Operators` 等）。

典型测试：`AngelscriptSyntaxAccessSpecifierTests.cpp` / `AngelscriptSyntaxCastingTests.cpp` / `AngelscriptSyntaxContainerTests.cpp`。

对应 Knowledges：整个 `Syntax_*` 族（13+ 篇）——`Syntax_DefaultStatement.md`、`Syntax_TArray.md`、`Syntax_Mixin.md`、`Syntax_FString.md` 等。

### 3.3 `Compiler/` — 编译器 pipeline（31 文件）

覆盖什么：编译事件钩子、模块编译顺序、UFUNCTION 包装器、class 层级、宏验证。

不覆盖：单独语法解析（去 `Syntax/`）、字节码执行（去 `Core/` 或 `Performance/`）。

典型测试：`AngelscriptCompilationEventsTests.cpp`（编译完成事件）/ `AngelscriptCompilerPipelineBlueprintEventWrapperTests.cpp`（BlueprintEvent 包装器）/ `AngelscriptCompilerPipelineClassHierarchyTests.cpp`。

对应 Knowledges：`AS_Compiler.md`（编译器原理）、`AS_Parser.md`、`Arch_ErrorDiagnostics.md`（编译诊断收集）。

### 3.4 `Functional/Inheritance/` — 多继承与接口装配（2 文件）

覆盖什么：脚本类多继承 BP/AS 父类、接口装配的运行时行为。代表 `AngelscriptInheritanceFunctionalTests.cpp` / `AngelscriptInheritanceTests.cpp`。

对应 Knowledges：`Type_BaseClass.md`。

### 3.5 `Functional/Interface/` — 接口实现（6 文件）

覆盖什么：脚本接口在脚本侧实现 / 在 BP 实现后被脚本调用 / 与 native interface bridge 互通。

代表测试：`AngelscriptInterfaceNativeBindingTests.cpp` / `AngelscriptInterfaceNativeBridgeTests.cpp`。

对应 Knowledges：`Note_InterfaceBinding.md`（现状记录）、`Type_BaseClass.md`（基类视角）。

### 3.6 `Functional/Delegate/` — 委托运行时（2 文件）

覆盖什么：单播 / 多播委托的注册、广播、参数传递、跨语言（C++/AS/BP）调用。

代表测试：`AngelscriptDelegateBroadcastWithParamsTests.cpp` / `AngelscriptDelegateTests.cpp`。

对应 Knowledges：`Syntax_DelegateEvent.md`、`Guide_DelegateSystem.md`。

### 3.7 `Functional/Operators/` + `Functional/Handles/` + `Functional/Property/` — 类型化能力点

- **`Operators/`（1）**：运算符重载（`opAdd` / `opIndex` / `opCast`）。代表 `AngelscriptOperatorTests.cpp`。
- **`Handles/`（1）**：weak / soft 句柄行为。代表 `AngelscriptHandleTests.cpp`。
- **`Property/`（2）**：属性默认值、PropertyAccessor 移除、复制条件、meta 矩阵。代表 `AngelscriptPropertyAccessorRemovalTests.cpp` / `AngelscriptPropertyMetaMatrixTests.cpp`。

对应 Knowledges：`Syntax_PropertyAccessor.md`、`Syntax_TWeakObjectPtr.md`、`Syntax_TSoftObjectPtr.md`。

### 3.8 `Functional/Types/` + `Functional/ControlFlow/` + `Functional/Execution/` + `Functional/Functions/` + `Functional/Objects/` — 基础语义簇

这五个二级目录文件量都不大（1–6 文件），但承担"语言基础语义保险"职责，跨越编译器与 VM 两侧：

- **`Types/`（5）**：类型互操作、auto 推断、值/引用类型行为。代表 `AngelscriptAutoTypeTests.cpp` / `AngelscriptTypeConversionTests.cpp`。
- **`ControlFlow/`（1）**：if/for/while/switch/break/continue 行为。代表 `AngelscriptControlFlowTests.cpp`。
- **`Execution/`（6）**：函数调用 / 异常 / 早返回 / 参数 marshalling。代表 `AngelscriptCoreExecutionTests.cpp` / `AngelscriptExecutionArgumentMarshallingTests.cpp`。
- **`Functions/`（2）**：全局函数注册、Mixin 函数引用矩阵。代表 `AngelscriptFunctionMixinReferenceMatrixTests.cpp` / `AngelscriptFunctionTests.cpp`。
- **`Objects/`（1）**：通用对象操作（构造/赋值/比较/复制）。代表 `AngelscriptObjectModelTests.cpp`。

对应 Knowledges：`AS_LanguageSyntax.md`、`AS_VirtualMachine.md`、`Syntax_Mixin.md`。

---

## 四、运行时子系统簇（C 轴）

按 RT_ 族切片：HotReload / StaticJIT / Debugger / GC / Memory / Performance。

### 4.1 `HotReload/` — 热重载（14 文件）

覆盖什么：脚本变更后 Engine 重新编译、UClass 反射 reinstance、property 保留 / 新增 / 删除、delegate / enum 变更影响。

不覆盖：HotReload 在 Editor 内的 file watcher 触发链路（`AngelscriptEditor/Tests/` 的 Editor 范围）、StaticJIT reload（`StaticJIT/`）。

典型测试：`AngelscriptHotReloadChangeClassificationTests.cpp`（变更分类）/ `AngelscriptHotReloadDelegateTests.cpp` / `AngelscriptHotReloadEnumDelegateTests.cpp`。

对应 Knowledges：`RT_HotReload.md`。

### 4.2 `StaticJIT/` + `StaticJIT/AOT/` — 静态 JIT（11 + AOT 子目录）

覆盖什么：StaticJIT 预编译产物的加载、AOT 字节码归档、commandlet 触发的 AOT 生成、JIT vs 解释器两条路径的等价性。

不覆盖：JIT 内部 codegen（去 `RT_StaticJIT.md` 文档侧）。

典型测试：`AngelscriptPrecompiledAllocatorTests.cpp` / `AngelscriptPrecompiledDataArchiveTests.cpp` / `AngelscriptStaticJITAotGeneration.cpp`（AOT commandlet fixture）。

对应 Knowledges：`RT_StaticJIT.md`。

### 4.3 `Debugger/` — DAP 调试协议（11 文件）

覆盖什么：DebugServer V2 协议握手、断点设置、step in/over/out、调用栈观察、多客户端、BP 帧、绑定变量观察。

不覆盖：IDE 端 VSCode 扩展（不在仓库内）。

典型测试：`AngelscriptDebuggerBindingTests.cpp`（绑定变量观察）/ `AngelscriptDebuggerBlueprintFrameTests.cpp`（BP 帧反射）/ `AngelscriptDebuggerBreakpointTests.cpp`（断点）。

对应 Knowledges：`RT_Debugger.md`、`Guide_Debugging.md`。

### 4.4 `GC/` + `Memory/` — 内存与生命周期（2 + 2 文件）

- **`GC/`**：脚本对象 GC 路径、Engine 释放后的 type 清理、循环引用检测。代表 `AngelscriptEngineMemoryLifecycleTests.cpp` / `AngelscriptGCTests.cpp`。
- **`Memory/`**：分配器行为、字节码 buffer 释放证据、全局容器循环边界。代表 `BindFreeEvidenceTests.cpp` / `GlobalContainerCycleBoundedTests.cpp`。

边界：`GC/` 偏对象生命周期与多引擎隔离；`Memory/` 偏底层分配器与"是否调用了 Free"的可观测证据。

对应 Knowledges：`AS_GarbageCollector.md`、`AS_ObjectLifecycle.md`、`RT_GlobalState.md`。

### 4.5 `Performance/` — 调用开销基线（3 文件）

覆盖什么：脚本-C++ 互调的运行时开销（解释器 vs JIT vs ProcessEvent vs RuntimeCall）、参数 marshalling 成本、反射 fallback 与直接绑定的对比。

不覆盖：脚本内部计算性能（不在范围内，AS 自身是非性能优先语言）。

典型测试：`AngelscriptPerformanceTestTypes.cpp` / `AngelscriptReflectiveFallbackBenchmarkTests.cpp`。

对应 Knowledges：`Documents/Guides/TestPerformance.md`、`Type_FunctionCaller.md`。

---

## 五、特殊场景簇（D 轴）

### 5.1 `Networking/` — RPC 编译（1 文件）

覆盖什么：`Server` / `Client` / `NetMulticast` / `WithValidation` / `Unreliable` 等 RPC 修饰符的脚本端**编译验证**——脚本声明这些 RPC 后，AS 编译器是否能把它们映射成有效 UFUNCTION，以及是否绑定到对应的网络通道。

**不覆盖**：实际网络发送 / 接收的运行时验证（仓库内目前没有 FakeNetDriver 等模拟器跑端到端 RPC，只有编译期检查）。

代表测试：`AngelscriptNetworkRPCTests.cpp`。

对应 Knowledges：暂无独立 Networking 主题文章；规划中由 `Guide_NetworkSimulation.md`（FakeNetDriver 视角）覆盖用户层。

### 5.2 `Dump/` — 状态导出回归（2 文件）

覆盖什么：`as.DumpEngineState` 控制台命令触发 `FAngelscriptStateDump::DumpAll()`、CSV 文件生成、表行数 sanity。

不覆盖：CSV 表内每个字段的语义（去 `Arch_EditorTestDumpCollaboration.md` / `RT_StateDump.md`）。

代表测试：`AngelscriptDumpCommand.cpp`（命令注册）/ `AngelscriptDumpTests.cpp`（DumpAll 自动化）。

对应 Knowledges：`RT_StateDump.md`、`Arch_EditorTestDumpCollaboration.md`。

### 5.3 `Validation/` — 启动后状态自检（2 文件）

覆盖什么：宏展开正确性、编译器 macro 验证、启动后引擎不变量。

代表测试：`AngelscriptCompilerMacroValidationTests.cpp` / `AngelscriptMacroValidationTests.cpp`。

对应 Knowledges：暂无；属于"自检"轻覆盖，紧急时可作为冒烟。

### 5.4 `FileSystem/` — 文件解析（5 文件）

覆盖什么：`.as` 文件磁盘加载、路径搜索优先级（脚本根 / Plugin 路径 / 模块）、文件重命名后的引用追踪。

代表测试：`AngelscriptDiskCompileTests.cpp`（磁盘编译入口）/ `AngelscriptFileSystemLookupPrecedenceTests.cpp` / `AngelscriptFileSystemRenameTests.cpp`。

对应 Knowledges：`Type_Preprocessor.md`（include 解析路径）、`Arch_RuntimeLifecycle.md`。

### 5.5 `Editor/` — 源码导航回归（1 文件，与 `AngelscriptEditor/Tests/` 不同）

覆盖什么：仅一个文件 `AngelscriptSourceNavigationTests.cpp`，验证从 UE Editor 跳到 .as 源码 + 行号的最小回归。

> **注意**：这里是 `AngelscriptTest/Editor/`（隶属测试模块）。`AngelscriptEditor/Tests/`（49 个 spec）是另一码事——见 `Test_Layering.md` §四 与 `Test_RuntimeInternal.md`（待写）。两者命名相近但模块不同。

对应 Knowledges：`Arch_EditorTestDumpCollaboration.md`。

### 5.6 `Core/` — Runtime 引擎内部（34 文件）

`Core/` 不属于"业务能力面"，但承担**所有 Runtime 内部行为的端到端探针**：bind 数据库、bind 配置、模块缓存、类型互操作、引擎扩展注册表、子系统所有权。

覆盖什么：
- Bind 数据库与缓存（`AngelscriptBindDatabaseTests.cpp` / `AngelscriptBindModuleCacheTests.cpp`）
- Bind 配置流程（`AngelscriptBindConfigTests.cpp`）
- Engine extension registry / type interop（`AngelscriptEngineExtensionRegistryTests.cpp` / `AngelscriptEngineTypeInteropTests.cpp`）
- 多引擎隔离与所有权

不覆盖：脚本侧业务行为（去 Functional/* 各簇）。

典型 Automation 前缀：`Angelscript.TestModule.CppTests.*` 与 `Angelscript.CppTests.*`（混合落点，见 `Test_Layering.md` §四.3）。

对应 Knowledges：`Type_BindSystem.md`、`Arch_RuntimeLifecycle.md`、`RT_GlobalState.md`。

### 5.7 `Functional/Misc/` + `Functional/Upgrade/` — 跨界回归（各 1 文件）

- **`Misc/`**：杂项行为（暂无独立主题归属的兜底）。代表 `AngelscriptMiscTests.cpp`。
- **`Upgrade/`**：跨版本升级兼容性（脚本字节码 / API 演化）。代表 `AngelscriptUpgradeCompatibilityTests.cpp`。

边界提醒：`Misc/` **不应膨胀**——任何能放进现有主题的就放过去，新建独立主题也优于扩张 Misc。

---

## 六、Native / 教学 / 编目簇（独立轴）

这三类不切"能力"，切的是"测试角色"。

### 6.1 `AngelScriptSDK/` — Native AS + ASSDK 适配（64 文件）

覆盖什么：原生 `asIScriptEngine` / `asIScriptModule` / `asIScriptContext` API、tokenizer / parser / scriptnode / bytecode / reference 全覆盖、ASSDK 适配层。

**特殊约束**：本目录下**不挂 `FAngelscriptEngine`**——任何引入 Runtime 引擎的写法都会破坏隔离意义。需要 Runtime 行为请去 `Core/` 或 `Compiler/`。

典型测试：`AngelscriptASSDKFunctionTests.cpp`（ASSDK 函数）/ `AngelscriptASSDKOperatorTests.cpp` / `AngelscriptASSDKTypeTests.cpp` / `AngelscriptNativeSmokeTest.cpp`（最小 Native 烟测）。

测试规模：`Angelscript.TestModule.AngelScriptSDK.*` 是 `301/301 PASS` 的子前缀（含 151 个新覆盖 case）。

对应 Knowledges：`AS_ScriptEngine.md`、`AS_Parser.md`、`AS_ByteCode.md`、`AS_VirtualMachine.md`、`AS_TypeRegistration.md`、`AS_CallingConventions.md`、`AS_StringFactory.md`、`AS_ForkDifferences.md`。

### 6.2 `Learning/Native/` + `Learning/Runtime/` — 教学可观测（6 + 16 文件）

覆盖什么：每条 case 通过 `AngelscriptLearningTrace.*` 把内部状态以**结构化 trace** 写出来——目的不是覆盖率，而是让读者通过测试代码看到"AS 行为是什么"。

层级前缀严格区分（详见 `Test_Layering.md` §三.3）：

```text
Learning/Native/  → Angelscript.TestModule.Learning.Native.*
Learning/Runtime/ → Angelscript.TestModule.Learning.Runtime.*
```

代表测试：
- Native: `AngelscriptLearningBytecodeTraceTests.cpp` / `AngelscriptLearningGuideBytecodeVmTests.cpp`
- Runtime: `AngelscriptLearningCompilerTraceTests.cpp` / `AngelscriptLearningClassGenerationTraceTests.cpp` / `AngelscriptLearningBlueprintSubclassTraceTests.cpp`

对应 Knowledges：每篇 Learning trace 与某个 AS_/RT_/Type_ 文章对位。新增 Learning case 时应同步评估"对应 Knowledges 是否需要补一段"。

### 6.3 `Template/` — 教学样板（7 文件，**不接受新增**）

7 份教学模板：`Template_CQTest.cpp` / `Template_WorldTick.cpp` / `Template_BlueprintWorldTick.cpp` / `Template_GameLifetime.cpp` / `Template_GlobalFunctions.cpp` / `Template_ReflectionAccess.cpp` / `Template_Blueprint.cpp`。

**严禁向 `Template/` 新增 case**——它是"复制粘贴起手式"专用，新主题应去对应主题目录或新建主题目录。前缀也历史保留为 `Angelscript.Template.*`，不应改成 `Angelscript.TestModule.Template.*`。

对应 Knowledges：`Note_CQTest.md`（CQTest 模板用法）、`Test_Infrastructure.md`（Helper 调用约定）。

---

## 七、跨簇协作矩阵

某些簇是**集成测试**——它们要跑通必须先确保多个其他簇 pass，否则失败原因会被"上游模块"掩盖。下表给出主要跨簇依赖。

### 7.1 集成测试依赖矩阵

| 测试簇 | 必须先 pass 的上游簇 | 失败时先排查谁 |
|-------|--------------------|--------------|
| `Functional/Subsystem/` | `Compiler/` + `ClassGenerator/` + `Core/` (engine extension registry) | `ClassGenerator/` UClass 生成 |
| `Functional/Blueprint/` | `Bindings/` + `ClassGenerator/` + `Compiler/` + `HotReload/` | `Bindings/` BP 类型 |
| `Functional/Actor/` | `Bindings/` (Actor / Component 类型) + `ClassGenerator/` | `ClassGenerator/Actor*Tests` |
| `Functional/Interface/` | `ClassGenerator/` (interface 反射) + `Bindings/` (Native bridge) | `ClassGenerator/` interface 路径 |
| `HotReload/` | `Compiler/` + `ClassGenerator/` (reinstance) + `GC/` | `ClassGenerator/` reload 路径 |
| `StaticJIT/` | `Compiler/` (字节码生成) + `Core/` (engine pool) | `Compiler/` 字节码完整性 |
| `Debugger/` | `Compiler/` + `Core/` (DebugServer 启动) + `Networking/` (Sockets) | `Core/` DebugServer 注册 |
| `Performance/` | `Compiler/` + `StaticJIT/` (JIT 路径) + `Bindings/` (调用链) | `StaticJIT/` 路径决断 |
| `Functional/Animation/` | `Bindings/` (USkeletalMeshComponent / UAnimMontage) | `Bindings/AngelscriptAnimMontage*` |
| `Dump/` | `Core/` (engine reset) + `RT_StateDump`（不在 Test 模块） | `RT_StateDump` 实现 |

### 7.2 "排查顺序"原则

发生回归时，按 **Compiler → ClassGenerator → Bindings → 业务簇** 的方向倒推：

```text
业务簇失败（如 Functional/Actor）
   │
   ▼ 先看
Bindings/<相关类型>Tests.cpp   ←  类型本身绑定是否过
   │
   ▼ 若 Bindings 也挂
ClassGenerator/AS<相关类型>Tests.cpp  ←  动态类是否生成
   │
   ▼ 若 ClassGenerator 也挂
Compiler/AngelscriptCompiler*Tests.cpp  ←  编译器 pipeline 是否过
   │
   ▼ 若 Compiler 也挂
Preprocessor/  /  Syntax/             ←  预处理 / 语法层是否过
   │
   ▼ 若都挂
AngelScriptSDK/AngelscriptNativeSmokeTest.cpp  ←  Native SDK 自身是否裸过
```

如果 Native Smoke 也挂——基本是 ThirdParty 内核或 build 环境出了问题，不是测试本身的事。

### 7.3 跨簇互斥（不要同时跑）

两类互斥：

- **`Performance/` vs 其他**：Performance 跑时占用引擎池，会显著影响其他簇时序。Performance 应单独 suite 跑。
- **`Networking/Debugger`**（Sockets 占用同端口）：Debugger 与某些 Networking case 同时跑会因 socket 冲突失败。CI 上分开 suite。

---

## 八、决策表："新增能力 → 新增哪个簇"

下表是常见的新需求 → 落点决策。落点不唯一时按"覆盖目标"挑。

| 需求类型 | 主落点 | 副落点（可能） | 不要去 |
|---------|-------|---------------|-------|
| 新增 UE C++ 类型的脚本绑定 | `Bindings/Angelscript<Type>BindingsTests.cpp` | 若是 Subsystem → `Functional/Subsystem/` | `Core/` |
| 新增 UClass 反射元字段 | `ClassGenerator/AngelscriptASClass<Topic>Tests.cpp` | `Functional/Property/` | `Core/` |
| 新增脚本语法关键字 | `Syntax/AngelscriptSyntax<Keyword>Tests.cpp` | `Compiler/`（若涉及中端） | `Functional/*` |
| 新增预处理器指令 | `Preprocessor/Angelscript<Topic>Tests.cpp` | — | `Compiler/` |
| 新增 Actor 行为 | `Functional/Actor/Angelscript<Topic>Tests.cpp` | `Bindings/` (若涉及新类型) | `Core/` |
| 新增 UMG / Slate 行为 | `Functional/Widget/` | `Bindings/AngelscriptUMG*` | `Functional/Rendering` |
| 新增网络 RPC 修饰符 | `Networking/AngelscriptNetwork*Tests.cpp` | `Compiler/`（编译期检查） | — |
| 新增 HotReload 场景 | `HotReload/AngelscriptHotReload<Topic>Tests.cpp` | `ClassGenerator/`（reinstance） | `Functional/*` |
| 新增 Debugger 协议消息 | `Debugger/AngelscriptDebugger<Topic>Tests.cpp` | — | `Core/` |
| 新增 GC 路径 | `GC/Angelscript<Topic>Tests.cpp` | `Memory/`（分配器） | `Core/` |
| 新增 StaticJIT 路径 | `StaticJIT/Angelscript<Topic>Tests.cpp` | `Performance/` | `Compiler/` |
| 新增 Dump 表 | `Dump/AngelscriptDumpTests.cpp`（追加 case）+ Editor/Test Helper 注册 | — | `Core/` |
| 新增脚本子系统 hook | `Functional/Subsystem/` | `Core/` (所有权) | `ClassGenerator/` |
| 新增编译诊断信息 | `Compiler/AngelscriptCompilation<Topic>Tests.cpp` | `Validation/` | `Syntax/` |
| 新增 Native AS API 覆盖 | `AngelScriptSDK/AngelscriptNative<Topic>Tests.cpp` 或 `AngelscriptASSDK<Topic>Tests.cpp` | — | `Core/` |
| 新增教学 / 可观测 trace | `Learning/Native/` 或 `Learning/Runtime/` | — | `Template/` |
| 新主题（不在表中） | 先看本文 §一 决定按哪个轴归属，再选择新建顶层目录 vs 落入 Functional 二级 | — | `Misc/` |

### 8.1 何时新建顶层目录 vs 落 Functional 二级

判断准则：

- **新顶层目录**：该主题是"运行时子系统切片"或"特殊场景"，跨多种 UE 对象，且预期 ≥ 5 文件。例如 `HotReload/` / `StaticJIT/` / `Debugger/`。
- **新 Functional 二级**：该主题是"UE 能力面"内部的一个新组件类型 / 行为族，预期 1–6 文件。例如 `Functional/Animation/` / `Functional/Widget/`。
- **既不是新顶层也不是新二级**：先尝试落入现有目录。`Misc/` 是兜底而非新主题孵化器。

---

## 九、排错快速指南："这个症状 → 跑哪个簇"

按"症状"反向定位**第一时间应该跑哪一组测试**。

| 症状 | 第一波跑 | 第二波（若第一波过） |
|------|---------|--------------------|
| AS 脚本编译报语法错误 | `Syntax/` + `Preprocessor/` | `Compiler/` |
| AS 类型未注册 / 找不到符号 | `Bindings/` + `Core/` (BindDatabase) | `ClassGenerator/` |
| BP 子类化 AS 类失败 | `Functional/Blueprint/` + `ClassGenerator/` | `Bindings/` |
| Actor `BeginPlay` 没触发 | `Functional/Actor/` | `Functional/Subsystem/` |
| 子系统派生失败 | `Functional/Subsystem/` + `Core/` (extension registry) | `ClassGenerator/` |
| HotReload 后 property 丢失 | `HotReload/AngelscriptHotReloadChangeClassificationTests.cpp` | `ClassGenerator/` (reinstance) |
| StaticJIT 输出与解释器不同 | `StaticJIT/` + `Performance/` (双路径对比) | `Compiler/` (字节码) |
| Debugger 连不上 / 断点不生效 | `Debugger/AngelscriptDebuggerBreakpointTests.cpp` | `Core/` (DebugServer 启动) |
| GC 后对象异常 / 多引擎污染 | `GC/` + `Memory/` | `Core/` (引擎隔离) |
| Dump 命令崩溃 / CSV 缺行 | `Dump/AngelscriptDumpTests.cpp` | `RT_StateDump` 文档 |
| 接口实现未被识别 | `Functional/Interface/` | `ClassGenerator/` (interface 反射) |
| 委托广播参数错位 | `Functional/Delegate/` | `Bindings/AngelscriptDelegate*` |
| Native AS API 异常（独立于插件） | `AngelScriptSDK/` + `AngelscriptNativeSmokeTest.cpp` | ThirdParty 自检 |
| 启动慢 / 启动卡死 | `Validation/` + 启动期开关（`-AngelscriptTestUseScanFreeStartupEngine`） | `Core/` 引擎池 |
| RPC 修饰符不识别 | `Networking/AngelscriptNetworkRPCTests.cpp` | `Compiler/` |
| 文件路径解析错误 | `FileSystem/AngelscriptFileSystemLookupPrecedenceTests.cpp` | `Type_Preprocessor.md` 路径策略 |
| 性能回归 | `Performance/AngelscriptReflectiveFallbackBenchmarkTests.cpp` | `StaticJIT/` |
| 源码导航跳错位置 | `Editor/AngelscriptSourceNavigationTests.cpp` | `AngelscriptEditor/Tests/AngelscriptSourceNavigation*` |

### 9.1 跑全 vs 跑簇

- **跑全**：用 `RunTestSuite.ps1`，覆盖所有簇；首次 PR / nightly 必跑。
- **跑单簇**：用 `RunTests.ps1 -TestFilter "Angelscript.TestModule.<Theme>.*"`，调试特定簇时使用。
- **跑跨簇**：用前缀 grep 拼合，例如同时调试 `HotReload` 与 `ClassGenerator`：`-TestFilter "Angelscript.TestModule.HotReload.*+Angelscript.TestModule.ClassGenerator.*"`（具体语法见 `Documents/Guides/Test.md`）。

---

## 附录 A：簇 → Knowledges 文章映射速查

按簇名首字母排序：

| 簇 | 主映射 Knowledges 文章 | 辅映射 |
|---|----------------------|--------|
| `AngelScriptSDK/` | `AS_ScriptEngine.md` | `AS_Parser.md` / `AS_ByteCode.md` / `AS_VirtualMachine.md` / `AS_TypeRegistration.md` / `AS_CallingConventions.md` / `AS_StringFactory.md` / `AS_ForkDifferences.md` |
| `Bindings/` | `Type_BindSystem.md` | `Type_FunctionLibrary.md` |
| `ClassGenerator/` | `Type_ClassGeneration.md` | `Type_StructGeneration.md` |
| `Compiler/` | `AS_Compiler.md` | `Arch_ErrorDiagnostics.md` |
| `Core/` | `Type_BindSystem.md` + `Arch_RuntimeLifecycle.md` | `RT_GlobalState.md` |
| `Debugger/` | `RT_Debugger.md` | `Guide_Debugging.md` |
| `Dump/` | `RT_StateDump.md` | `Arch_EditorTestDumpCollaboration.md` |
| `Editor/`（测试模块内） | `Arch_EditorTestDumpCollaboration.md` | — |
| `FileSystem/` | `Type_Preprocessor.md`（path 策略部分） | `Arch_RuntimeLifecycle.md` |
| `Functional/Actor/` | `Type_BaseClass.md` | `Guide_QuickStart.md` |
| `Functional/Animation/` | （暂无） | `Bindings/AngelscriptAnimMontage*` |
| `Functional/Blueprint/` | `Type_ClassGeneration.md` + `Note_InterfaceBinding.md` | `Type_BindSystem.md` |
| `Functional/Component/` | `Type_BaseClass.md` | `Syntax_DefaultComponent.md` |
| `Functional/ControlFlow/` | `AS_LanguageSyntax.md` | `AS_VirtualMachine.md` |
| `Functional/Delegate/` | `Syntax_DelegateEvent.md` | `Guide_DelegateSystem.md` |
| `Functional/Execution/` | `AS_VirtualMachine.md` | `Type_FunctionCaller.md` |
| `Functional/Functions/` | `Syntax_Mixin.md` | `Type_FunctionLibrary.md` |
| `Functional/Handles/` | `Syntax_TWeakObjectPtr.md` | `Syntax_TSoftObjectPtr.md` |
| `Functional/Inheritance/` | `Type_BaseClass.md` | — |
| `Functional/Interface/` | `Note_InterfaceBinding.md` | `Type_BaseClass.md` |
| `Functional/Misc/` | （兜底，无固定映射） | — |
| `Functional/Objects/` | `AS_ObjectLifecycle.md` | `AS_GarbageCollector.md` |
| `Functional/Operators/` | `AS_LanguageSyntax.md` | — |
| `Functional/Property/` | `Syntax_UPROPERTY.md` + `Syntax_PropertyAccessor.md` | — |
| `Functional/Rendering/` | （暂无） | — |
| `Functional/Subsystem/` | `Type_Core.md` + `Guide_SubsystemUsage.md` | — |
| `Functional/Types/` | `AS_LanguageSyntax.md` | — |
| `Functional/Upgrade/` | `Documents/Guides/AngelscriptForkStrategy.md` | — |
| `Functional/Widget/` | `Guide_UIManagement.md` | — |
| `GC/` | `AS_GarbageCollector.md` + `AS_ObjectLifecycle.md` | `RT_GlobalState.md` |
| `HotReload/` | `RT_HotReload.md` | — |
| `Learning/Native/` | 多对多（按 trace 主题） | `AS_*` 系列 |
| `Learning/Runtime/` | 多对多（按 trace 主题） | `RT_*` / `Type_*` 系列 |
| `Memory/` | `AS_ObjectLifecycle.md` | `RT_GlobalState.md` |
| `Networking/` | （暂无独立 Knowledges；规划走 `Guide_NetworkSimulation.md`） | — |
| `Performance/` | `Type_FunctionCaller.md` + `Documents/Guides/TestPerformance.md` | `RT_StaticJIT.md` |
| `Preprocessor/` | `Type_Preprocessor.md` | — |
| `StaticJIT/` + `AOT/` | `RT_StaticJIT.md` | — |
| `Syntax/` | 整个 `Syntax_*` 族 | — |
| `Template/` | `Note_CQTest.md` + `Test_Infrastructure.md` | — |
| `Validation/` | （暂无） | — |

---

## 附录 B：簇命名规范

```text
顶层目录命名:
  <PascalCase>/                        # 业务名 / 子系统名
  例: HotReload/  StaticJIT/  AngelScriptSDK/  ClassGenerator/

  Functional/                          # 唯一允许的"二级容器"
  Functional/<PascalCase>/              # 二级主题
  例: Functional/Actor/  Functional/Subsystem/

  Learning/<Layer>/                     # 教学层级
  例: Learning/Native/  Learning/Runtime/

  StaticJIT/AOT/                        # 子系统内部子目录（少见）

Automation 前缀（与本文簇映射）:
  Angelscript.TestModule.<Theme>.<Case>            # 默认（顶层主题）
  Angelscript.TestModule.AngelScriptSDK.<Sub>.*    # AS SDK 二级
  Angelscript.TestModule.Functional.<Theme>.*      # Functional 例外段
  Angelscript.TestModule.Learning.<Layer>.*        # 层级优先
  Angelscript.TestModule.CppTests.*                # Core/ 部分 case
  Angelscript.{Compile,Reload,Binds,...}.*         # 历史短前缀（不再新增）

代表测试命名:
  Angelscript<Theme><Topic>Tests.cpp     # 多 case 集合（CQTest TEST_CLASS_WITH_FLAGS）
  Angelscript<Theme><Topic>Test.cpp      # 单 case 聚焦
  AngelscriptNative<Topic>Tests.cpp      # AngelScriptSDK 子族
  AngelscriptASSDK<Topic>Tests.cpp       # ASSDK 适配子族
  AngelscriptLearning<Topic>TraceTests.cpp # Learning 子族（带 Trace 后缀）

不允许的命名:
  ✗ <Theme>Tests.cpp                     # 缺 Angelscript 前缀
  ✗ Template/<NewTheme>Tests.cpp         # 不在 Template/ 新增
  ✗ Misc/<SpecificTopic>Tests.cpp        # Misc 不孵化主题
  ✗ <Theme>/Test.cpp                     # 文件名缺前缀也缺主题
```

### B.1 簇 → 模块对应

```text
AngelscriptTest 内的 22 个顶层目录 + 20 Functional 二级 + 3 子目录（Learning/Native, Learning/Runtime, StaticJIT/AOT）
   ▼  41+ 个独立簇
   ▼
均属 AngelscriptTest 模块（Editor 模块，bBuildEditor 守卫）

AngelscriptEditor/Tests/  ← 不算簇，属于"Editor 模块自带的 spec 通道"，前缀 Angelscript.Editor.*
AngelscriptRuntime/Tests/ ← 当前为占位（Test_Layering §四.3）
```

---

## 附录 C：法定 / 历史 / 废弃簇标记

| 簇 | 状态 | 说明 |
|---|------|------|
| `Template/` | **法定**（不接受新增） | 教学样板专用，前缀保留 `Angelscript.Template.*` |
| `Functional/Misc/` | **法定**（兜底） | 不孵化新主题，能归属现有就归过去 |
| `Functional/<其他二级>/` | **法定** | Round1 计划落地的"Functional 例外段"，保留 `Angelscript.TestModule.Functional.<Theme>.*` |
| `Editor/`（测试模块内） | **法定**（轻覆盖） | 仅 1 个文件，不要混淆 `AngelscriptEditor/Tests/` |
| 历史短前缀 `Angelscript.Compile.*` / `.Reload.*` / `.Binds.*` / `.Startup.*` 等 | **历史保留** | `TestConventions.md` 已规定不再新增；现有 case 不强制重命名 |
| `Angelscript.TestModule.CppTests.*` 与 `Angelscript.CppTests.*` | **同义共存** | 见 `Test_Layering.md` §四.3，新写优先带 `TestModule.` 段 |
| 当前没有"已废弃"的物理目录 | — | 简记此项以备未来 ARCHIVE |

---

## 小结

- **41 个簇按四轴切片**：UE 能力面（A）/ AS 语言机制（B）/ 运行时子系统（C）/ 特殊场景（D）。簇可同时落在两个轴上，新需求落点决策见 §八 决策表。
- **三元组互依**：`Functional/Blueprint` ↔ `Bindings/` ↔ `ClassGenerator/` 互相协作；任一簇失败先到 `ClassGenerator/` 回溯。
- **Native / 教学 / 编目独立轴**：`AngelScriptSDK/`（Native API + ASSDK）严禁挂 `FAngelscriptEngine`；`Learning/`（Native + Runtime）以可观测 trace 为目的；`Template/` 不接受新增。
- **每个簇都映射到一篇 Knowledges 文章（见附录 A）**：新增能力时，既要落 case 也要看是否需要补对应文档；Networking / Animation / Rendering / Validation / Misc 当前无独立 Knowledges 是已知缺口。
- **测试规模口径** 已在 `Test_Layering.md` §七 给出，本文不重复——记得 275 / 1518+ / 301 三个数字不能混用。
- 排错时按 **Compiler → ClassGenerator → Bindings → 业务簇** 的方向倒推，详见 §九 与 §七.2。
