# Angelscript 教学型可观测测试实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 按任务执行本计划。步骤使用 checkbox（`- [ ]`）语法跟踪。

**Goal:** 建立一套以“教学、解释、可观察”为目标的 Angelscript 自动化测试体系，让测试在运行时按阶段输出 AS ↔ UE 交互、编译、类生成、字节码、执行与调试信息，而不仅仅给出通过/失败结论。

**Architecture:** 方案以 `Plugins/Angelscript/Source/AngelscriptTest/` 为主落点，新增一个面向学习用途的 `Learning/` 主题根目录，并在其中继续按测试层级拆分为 `Learning/Native/`、`Learning/Runtime/`、`Learning/Scenario/`、`Learning/Editor/`。这样既保留“教学型测试”这一独立主题，又不破坏 `Documents/Guides/Test.md` 规定的层级边界。所有教学输出统一走“结构化 trace 事件 -> Automation `AddInfo` + `UE_LOG(Angelscript, Display/Log)` + 可选文件导出”三路同步，保证既适合在 Session Frontend 阅读，也适合保存为日志或材料。

**Tech Stack:** UE Automation (`IMPLEMENT_SIMPLE_AUTOMATION_TEST`)、`FAutomationTestBase::AddInfo/AddWarning/AddError`、`FAngelscriptEngine`、`FAngelscriptBinds`、`FAngelscriptClassGenerator`、`asIScriptEngine/asIScriptModule/asIScriptContext`、`AngelscriptDebugServer`、`FAngelscriptCodeCoverage`。

> **当前状态（2026-04-06 基于 `main` 审核）**：本计划并非未开始，`main` 上已经落地大部分 Learning Trace 实现，但状态块与尾项勾选未完全反映现状。
> - 已完成：`P0.1-P4.2`、`P4.3-P4.7`、`P5.1`、`P5.3`、`P5.5-P5.6`、`P6.1-P6.3`
> - 部分实现：`P5.2`、`P5.4`、`P5.8`、`P5.9`、`P6.4`
> - 待补尾项：`P5.7`
> - 实现偏差：原计划中一部分 `Scenario` / `Editor` 主题，当前主线实际更多落在 `Learning/Runtime/` 或既有 `Debugger/`、`Editor/`、`Examples/` 测试中，因此“有相关能力”不等于“已有独立 Learning 文件”。
> - 审核依据：`Learning/Native/*`、`Learning/Runtime/*`、`Shared/AngelscriptLearningTrace*`、`Documents/Guides/LearningTrace.md`、`Editor/AngelscriptSourceNavigationTests.cpp`、`Debugger/AngelscriptDebuggerSmokeTests.cpp`、容器示例测试等主线文件。
> - **归档判断**：当前**不满足归档条件**。根据 `Plan.md` 与 `Archives/README.md` 的规则，只有“已完成或已关闭”的 Plan 才能移入 `Archives/`；本计划仍保留明确未完成项与未满足的验收覆盖面。

---

## 背景与目标

当前仓库的自动化测试已经覆盖 Native、AngelScriptSDK、Compiler、ClassGenerator、Actor/Blueprint/Interface 等多个层级，但整体目标仍以“验证功能边界是否正确”为主：

- `Native/` 层更强调 AngelScript 公共 API 能否创建引擎、编译脚本、执行函数、注册类型。
  - `AngelScriptSDK/` 层更强调 parser / builder / compiler / bytecode / GC 等内部机制的正确性。

- `Compiler/`、`ClassGenerator/`、`Actor/Blueprint/Interface/Subsystem` 等目录更强调 AS 与 UE 的集成行为是否成立。

这些测试对回归保护已经很有价值，但它们大多不承担“把过程讲出来”的职责。用户现在需要的是另一类测试：

1. **目标不是只断言结果，而是解释过程** —— 例如绑定阶段注册了哪些类型、编译阶段经历了哪些步骤、类生成阶段产生了哪些 UClass/UFunction/FProperty。
2. **目标是让用户学习系统原理** —— 包括 AS 原生运行时、插件封装层、UE 反射桥接层分别做了什么。
3. **目标是形成可重复观看的输出** —— 同一个测试可反复运行，输出的阶段和信息组织保持稳定，适合教学、排错、对照版本差异。

本计划的最终目标不是替换现有测试，而是在现有分层测试体系旁边补一条“教学型 trace 流”：

- 让用户能从“创建引擎 → 设置属性 → 绑定类型 → 编译模块 → 分析类 → 生成 UClass → 执行函数 → 命中 line callback → 观察 callstack / variables / coverage”完整地看到每一步。
- 让测试输出既能在 Automation 界面中阅读，也能落到日志或导出文件中，便于整理成文档或学习资料。
- 让教学型测试仍保留最小必要断言，确保“输出不是噪声”，而是稳定、可验证的知识路径。

## 范围与边界

- **纳入范围**
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/` 下新增一个面向教学/解释的主题根目录，并按层级继续拆分为 `Learning/Native/`、`Learning/Runtime/`、`Learning/Scenario/`、`Learning/Editor/`。
  - 在 `Shared/` 下新增测试专用 trace helper，用于记录阶段、步骤、键值信息、代码片段、字节码摘要、生成类摘要、执行轨迹等。
  - 最小范围内扩展现有 runtime seam，使测试能够读到本来已经存在但未结构化暴露的信息，例如编译阶段结果、reload requirement、绑定清单、类生成摘要、line callback 命中信息。
  - 更新中文文档，明确这种教学型测试的命名、运行方式、输出读取方式、日志参数建议。
- **不纳入范围**
  - 不把生产代码中的普通日志无条件升级为海量详细日志；教学输出优先在测试 helper 中组织，必要的 runtime seam 也应尽量是测试可控、默认安静的。
  - 不在第一版就建设完整 IDE/DAP 教学前端；首批以 Automation + 日志 + 可选导出文件为主。
  - 不默认修改 ThirdParty AngelScript 核心行为；如确需访问内部信息，优先通过已有 public/internal API 读取，只有完全缺 seam 时才最小化补点。
  - 不将所有现有回归测试重写为教学型测试；只挑选最有代表性的路径建立“课程型”样例。

## 当前事实状态快照

### 现有测试层级与可复用模式

- `Documents/Guides/Test.md` 已明确三层结构：Native Core、Runtime Integration、UE Scenario。
- `Plugins/Angelscript/AGENTS.md` 已明确 `Native/` 只能使用 `AngelscriptInclude.h` / `angelscript.h` 公共 API，不能把 `FAngelscriptEngine` 或 `source/as_*.h` 带进去。
- `Plugins/Angelscript/Source/AngelscriptTest/Examples/` 已经接近“教学型案例”模板：每个文件围绕一个主题嵌入小脚本、验证编译或执行结果，但仍缺少统一的阶段化输出模型。
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptBytecodeTests.cpp`、`...CompilerTests.cpp` 已证明内部层测试可以直接读取 bytecode/function metadata。
- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptScriptClassCreationTests.cpp` 已证明可以稳定构造“脚本类 -> 生成 UClass -> Spawn -> BeginPlay -> Blueprint child”这条 UE 侧故事线。

### 已存在的关键可观测 hook

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  - `LogAngelscriptError()`：编译诊断回调，已把 message callback 输出转成 UE 日志并缓存到 `Diagnostics`。
  - `AngelscriptLineCallback()`：运行时逐行回调，已串接 debug values、debug server、code coverage。
  - `AngelscriptStackPopCallback()`：函数返回/栈弹出回调。
  - `GetStackTrace()` / `LogAngelscriptException()`：已有调用栈与异常输出能力。
  - `CompileModules()` 与分阶段编译函数（Stage1-4）：天然适合教学输出“现在在哪个编译阶段”。
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h/.cpp`
  - `OnClassReload`、`OnEnumCreated`、`OnStructReload`、`OnPostReload`、`OnFullReload` 等 delegate。
  - `Analyze()` 中已读取 script property、method、override、reload requirement 等核心元数据。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp`
  - 已有 `DebugBreak()`、`ensure()`、`check()`、`GetAngelscriptCallstack()`、`FormatAngelscriptCallstack()`。
- `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp`
  - 已有“可执行行映射 + HitLine(line)”逻辑，说明 line-level 教学输出不需要从零开始建。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`
  - 已支持 breakpoint、variables、evaluate、callstack、break filters，可作为“深层执行可观察性”的后续阶段。
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h`
  - 已有 message collector、module/function declaration 收集、原生 `PrepareAndExecute()` helper，适合做最小可解释原生样例。

### 上游 AngelScript 官方能力边界

外部资料确认，首批教学型测试并不需要先发明新的“解释器可视化层”，因为 AngelScript 官方接口本身已经提供了大量可观测面：

- `asIScriptEngine`
  - 可枚举 global functions、global properties、object types、enums、typedefs、funcdefs，适合做“绑定后引擎里到底注册了什么”的课程输出。
- `asIScriptModule`
  - 可枚举 module 内函数、全局变量、对象类型，并支持 `SaveByteCode/LoadByteCode`，适合做“模块编译结果”课程输出。
- `asIScriptFunction`
  - 可读取 `GetDeclaration()`、`GetParam()`、`GetVarCount()`、`GetVarDecl()`、`GetDeclaredAt()`、`FindNextLineWithCode()`、`GetByteCode()`，适合做“函数元数据 + bytecode 摘要 + 可执行行映射”课程输出。
- `asIScriptContext`
  - 可读取 `GetCallstackSize()`、`GetFunction()`、`GetLineNumber()`、`GetVar*()`、`GetAddressOfVar()`、`GetThisPointer()`、异常信息，说明“执行中观察调用栈与局部变量”是有官方 API 基础的。
- 官方 debugger add-on / line callback
  - 官方已有 line callback 与 debugger add-on 思路，说明“逐行解释执行”和“请求变量/调用栈”不是逆天 hack，而是沿着官方能力延伸。

同时也要明确一个边界：官方暴露了 bytecode buffer 与 instruction 文档，但**首批计划不应假设仓库里已有现成人类可读的反汇编器**。因此第一版应该优先输出稳定的 bytecode 长度、opcode/dword 摘要和函数行映射；若后续验证上游或本地参考仓库已有可复用 disassembler，再扩展到 mnemonic 级输出。

### 为什么需要单独的 Learning 主题目录

虽然 `Examples/` 和 `AngelScriptSDK/` 已经有一部分“可读性强”的测试，但教学型测试和普通回归测试的价值密度不同：

- 普通回归测试追求信息最少、定位最稳；教学型测试追求“阶段、上下文、观测值都显式可见”。
- 如果直接把大量 `AddInfo()` / `UE_LOG()` 散落进现有回归测试，会增加噪声，降低老用例的维护体验。
- 单独建 `Learning/` 主题根目录，并在其下继续按 `Native / Runtime / Scenario / Editor` 分桶，可以让这类测试在命名、运行参数、日志风格、导出物格式上自成体系，同时继续遵守现有层级边界。

## 文件结构与职责

### 新增文件（首批 + 扩展建议）

- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h`
  - 定义教学 trace event、阶段枚举、step builder、输出 sink 接口。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.cpp`
  - 实现 `AddInfo` / `UE_LOG` / 文件导出三路输出与统一排版。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/AngelScriptSDK/AngelscriptLearningNativeBootstrapTests.cpp`
  - 讲“原生 AS 引擎创建、属性设置、message callback、模块 build、函数元数据”的最小故事线。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/AngelScriptSDK/AngelscriptLearningNativeBindingTraceTests.cpp`
  - 讲“原生 `asIScriptEngine` 注册 API”这一步具体注册了什么；**这里只演示 AngelScript 原生注册，不引入 `FAngelscriptBinds` 或 UE 类型绑定**。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningCompilerTraceTests.cpp`
  - 讲“预处理、CompileModules、diagnostics、reload requirement”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/AngelScriptSDK/AngelscriptLearningBytecodeTraceTests.cpp`
  - 讲“函数声明、局部变量、bytecode buffer、可执行行”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningClassGenerationTraceTests.cpp`
  - 讲“脚本类如何生成 UClass/UFunction/FProperty，如何映射到 UE 反射”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningExecutionTraceTests.cpp`
  - 讲“Prepare/Execute、line callback、callstack、异常/ensure/check”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Scenario/AngelscriptLearningUEBridgeTraceTests.cpp`
  - 讲“脚本类实例化、ProcessEvent、BlueprintOverride、BeginPlay、属性回读”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/AngelScriptSDK/AngelscriptLearningHandleAndScriptObjectTraceTests.cpp`
  - 讲“handle/reference 语义、script object 属性枚举、对象复制与对象内省”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/AngelScriptSDK/AngelscriptLearningDebuggerContextTraceTests.cpp`
  - 讲“callstack、locals、`this` 指针、line callback、debugger evaluate 的基础观察面”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningPreprocessorTraceTests.cpp`
  - 讲“宏检测、chunk 拆分、import 解析、module name 规范化、生成代码拼装”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningFileSystemAndModuleTraceTests.cpp`
  - 讲“按路径发现脚本、按文件名/模块名查找 module、部分失败隔离、skip rules”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningHotReloadDecisionTraceTests.cpp`
  - 讲“软重载/全量重载分析的判定依据与结构变化边界”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningRestoreAndBytecodePersistenceTests.cpp`
  - 讲“SaveByteCode/LoadByteCode、restore round-trip、debug info strip 的影响”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningInterfaceDispatchTraceTests.cpp`
  - 讲“脚本类实现 native UInterface、`ImplementsInterface` 验证、实现类 dispatch、C++ `Execute_` bridge”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Scenario/AngelscriptLearningDelegateBridgeTraceTests.cpp`
  - 讲“unicast/multicast delegate、BindUFunction/AddUFunction、事件广播跨桥接过程”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Scenario/AngelscriptLearningGCTraceTests.cpp`
  - 讲“GC 统计、cycle detect、actor/component/world teardown 与 AS/UE 对象图关系”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Scenario/AngelscriptLearningTimerAndLatentTraceTests.cpp`
  - 讲“System::SetTimer、world tick、latent/multi-frame 行为如何驱动脚本”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Scenario/AngelscriptLearningSubsystemLifecycleTraceTests.cpp`
  - 讲“WorldSubsystem/GameInstanceSubsystem 的创建条件、Initialize/PostInitialize/BeginPlay/Tick/Deinitialize”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Editor/AngelscriptLearningSourceNavigationTraceTests.cpp`
  - 讲“生成 `UASFunction` 如何保留源文件路径与行号，以及 Source Navigation 如何利用这些信息”。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningContainerAndDebuggerValueTraceTests.cpp`
  - 讲“容器绑定、DebuggerValue 摘要、`TMap/TSet/TOptional/TSubclassOf` 等桥接类型如何被观察与调试”。
- `Documents/Guides/LearningTrace.md`
  - 说明这些教学型测试怎么运行、看什么、日志参数怎么配。

### 可能修改文件

- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
  - 如 `Learning/` helper 需要额外 include path 或模块依赖，在这里最小补充。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h/.cpp`
  - 如需要暴露统一的“编译结果摘要 / reload requirement 摘要 / generated symbol 摘要” helper，可在这里补轻量 API。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h/.cpp`
  - 仅当现有 `CompileModules()` 阶段结果、line callback、diagnostics 无法以测试可控方式读取时，补极小 seam。
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h/.cpp`
  - 仅当现有 delegate 无法携带足够上下文时，补最小测试可消费信息。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptScenarioTestUtils.h/.cpp`
  - 如扩展的 Learning 测试需要统一的 world fixture、tick、spawn、property snapshot、multi-frame helper，可在这里补最小测试夹具能力。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h/.cpp`
  - 如需要稳定触发 evaluate / callstack / break filters / variables 相关 smoke trace，可在这里补极小测试入口或摘要接口。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/LatentAutomationCommand.h/.cpp`
  - 若某些 Learning 测试需要多帧教学步骤，优先复用或包装现有 latent command 基础设施，而不是自建异步调度。
- `Documents/Guides/Test.md`
  - 增加 `Learning/` 主题目录与运行参数建议。
- `Documents/Guides/TestCatalog.md`
  - 新增 Learning 目录导航。

## 第二批建议主题矩阵

除首批“引擎启动 / 绑定 / 编译 / 字节码 / 类生成 / 执行 / UE bridge”之外，建议把以下主题纳入第二批或第三批 Learning 测试版图：

- **Preprocessor / Import**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/PreprocessorTests.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h`
  - 教学价值：让用户看见 `UPROPERTY/UFUNCTION` 宏如何被记录、代码如何被 chunk 化、`import` 如何形成 module dependency。
- **HotReload Decision Engine**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadAnalysisTests.cpp`
  - 教学价值：解释“为什么某次改动只需 soft reload，而另一次必须 full reload”。
- **GC / Object Graph**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptGCScenarioTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptGCInternalTests.cpp`
  - 教学价值：解释 AS 对象、script actor/component、UE world teardown 与引用环检测的关系。
- **Delegate / Event Bridge**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/Delegate/AngelscriptDelegateScenarioTests.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h`
  - 教学价值：解释脚本事件如何变成 UE delegate，以及 AngelScriptSDK/script 双向触发路径。
- **Interface Dispatch**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/Interface/AngelscriptInterfaceNativeBridgeTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Interface/AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp`
  - 教学价值：解释 native UInterface 继承链、脚本实现类、`Execute_` bridge 与 GC-safe dispatch。
- **FileSystem / Module Discovery**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/FileSystem/AngelscriptFileSystemTests.cpp`
  - 教学价值：解释脚本文件如何被发现、命名、定位，以及坏模块为何不应污染好模块。
- **Debugger Context / Variables / Callstack**
  - 依据：`Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDebugValue.h`
  - 教学价值：解释执行中的局部变量、调用栈、evaluate、break filter、data breakpoint 能观察到什么。
- **Subsystem / Timers / Multi-frame**
  - 依据：`Plugins/Angelscript/Source/AngelscriptRuntime/BaseClasses/ScriptWorldSubsystem.h`、`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp`
  - 教学价值：解释脚本如何融入 UE 的 subsystem lifecycle 和 timer-driven gameplay loop。
- **Editor Metadata / Source Navigation**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp`
  - 教学价值：解释生成函数为何能被 Source Navigation 识别，以及脚本源码位置信息如何贯穿到编辑器。
- **Bindings / Container Debugger View**
  - 依据：`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptContainerCompareBindingsTests.cpp`
  - 教学价值：解释复杂桥接类型在脚本与调试器中的可视化差异，而不是只验证功能返回值。

## 输出模型约定

### 统一 trace 事件结构

所有教学型测试统一把输出组织成以下结构，而不是散落字符串：

- `Phase`：如 `EngineBootstrap`、`Binding`、`Compile`、`Bytecode`、`ClassGeneration`、`Execution`、`UEBridge`。
- `StepId`：阶段内顺序编号，例如 `Binding.03`。
- `Action`：执行了什么，例如“调用 SetMessageCallback”“枚举 script methods”“命中 line callback”。
- `Observation`：观测到了什么，例如类型名、函数声明、bytecode 长度、callstack、property 列表。
- `Evidence`：必要时附关键路径、行号、返回码、声明串、源码片段、导出值。

为了让 `P1.1` 可以直接照着编码，建议把内部数据模型固定成下面这组最小字段：

- `Phase`：推荐先收敛到 `EngineBootstrap`、`Binding`、`Compile`、`Bytecode`、`Execution`、`ClassGeneration`、`UEBridge`、`Debug`、`GC`、`Editor` 十个主类。
- `StepId`：固定使用 `Phase.XX` 两位编号格式，例如 `Compile.02`、`Execution.05`，便于 Automation 输出和导出文件排序一致。
- `Action`：一句动词短语，描述“做了什么”，例如 `RegisterGlobalFunction`、`BuildModule`、`PrepareContext`、`SpawnScriptActor`。
- `Observation`：一句或多句结构化摘要，描述“看到了什么结果”，例如返回码、函数列表、reload requirement、生成类名。
- `Evidence`：键值对或代码块，承载较长信息；优先用于 declaration、diagnostic 列表、bytecode 摘要、property 快照，而不是把所有内容塞进 `Observation`。
- `DetailLevel`：至少支持 `Summary` 与 `Verbose` 两档；默认 Automation 走 `Summary`，只有明确启用 verbose 时才打印扩展数据。
- `Timestamp/Sequence`：首版不用追求真实时间戳，但至少保留 session 内递增顺序号，保证多 sink 输出时顺序可重建。

首版实现不要过度设计成通用 tracing 平台；只要这几个字段足以稳定表达“阶段 → 步骤 → 观测 → 证据”，就先固定下来。

### 三路输出约定

- **Automation `AddInfo()`**：给 Session Frontend 和 JSON 报告用，适合读“课程步骤”。
- **`UE_LOG(Angelscript, Display/Log, ...)`**：给引擎日志文件和命令行跑批用，适合保留完整痕迹。
- **可选导出文件**：导出到 `Saved/Automation/AngelscriptLearning/` 下的 `*.json` / `*.md`，便于后续整理文档或 diff 两次运行结果。

三路输出的职责也要固定，避免 helper 做着做着变成三套风格：

- `AddInfo()` 只输出课程摘要级内容，每条最好 1~3 行，适合在 Automation 报告中直接阅读。
- `UE_LOG` 保留完整展开版，可接受更长的 declaration 列表、diagnostic 细节和代码块片段。
- 文件导出优先走结构化 `json`，`md` 作为后续教学材料友好视图；首版若时间紧，可先只落 `json`，但字段命名要与内存事件结构一致。
- 同一条 trace event 进入不同 sink 时，不允许改写语义；差异只体现在展示粒度和排版层，而不是字段含义。

### 教学型测试的断言策略

这类测试不能沦为“只打印，不验证”。每个测试至少验证：

1. 关键 phase 是否按预期顺序出现。
2. 关键观测值是否非空或满足最小稳定边界（如存在至少一个函数、至少一个 property、bytecode length > 0、callstack 非空）。
3. 教学输出是否真的包含本测试宣称要讲的事实，而不是仅靠人工翻日志。

首版断言模式建议固定为两层：

- **结构断言**：检查 phase 顺序、step 数量、关键关键词是否出现。这一层用于保证“课程流程存在”。
- **语义断言**：检查最小必要事实，例如 `CompileResult == Success`、`GetFunctionCount() > 0`、`GeneratedClass != nullptr`、`CallstackSize > 0`。这一层用于保证“课程内容不是噪声”。

不要在首版把所有细节做成硬断言，例如完整 bytecode 序列、每条 property 的地址值、完整日志全文；这些更适合作为 `Evidence` 输出，而不是失败条件。

### Detail Level 与输出开关约定

在 `P1.1` helper 中建议预留轻量配置，而不是等后续文件越写越多再回头改：

- `Summary`：默认模式，仅输出课程步骤、关键声明、关键结果值。
- `Verbose`：展开更长的 declaration/property/function 列表、bytecode dword 摘要、diagnostic 完整列表。
- `bEmitToAutomation` / `bEmitToLog` / `bEmitToFile`：三路 sink 独立开关，测试可按场景选择。
- `OutputRoot`：默认落到 `Saved/Automation/AngelscriptLearning/`，避免和普通 Automation 报告混在一起。

首版不要做任意层级过滤或复杂模板系统；保持“少量枚举 + 明确默认值”即可。

### 编号约定说明

本计划遵循 `Documents/Plans/Plan.md` 的约定：**每个执行任务后紧跟一个 `📦 Git 提交` checkbox，二者共享同一任务编号**。因此像 `P2.1` + `P2.1 📦 Git 提交` 属于一组，不应被理解为重复编号。

### Phase 与测试层级的关系

本计划中的 `Phase` 是按**教学叙事顺序**组织，不等同于 `Documents/Guides/Test.md` 中的测试层级。真正实现时，文件路径与可用 API 必须继续服从层级规则：

- `Learning/Native/`：只使用 AngelScript 公共 API，不引入 `FAngelscriptEngine`、`source/as_*.h` 之外的插件封装层能力。
- `Learning/Runtime/`：处理 `FAngelscriptEngine`、preprocessor、compiler、module、hot reload analysis、reflection summary 等封装层主题。
- `Learning/Scenario/`：处理 world、actor、component、Blueprint、delegate、interface、GC、timer、subsystem 等 UE 场景主题。
- `Learning/Editor/`：处理 source navigation、editor metadata、仅 EditorContext 可用的观察主题。

## 分阶段执行计划

### Phase 0：冻结目录、命名与输出契约

> 目标：先把这套“教学型测试”与现有回归测试区分清楚，避免后续实现时把大量教学日志混进普通用例。

- [x] **P0.1** 确认新增主题目录与命名约定
  - 建议新增 `Plugins/Angelscript/Source/AngelscriptTest/Learning/Native/`、`Learning/Runtime/`、`Learning/Scenario/`、`Learning/Editor/`，测试名前缀统一用 `Angelscript.TestModule.Learning.*`。
  - 不把这批教学用例塞进 `Examples/`、`AngelScriptSDK/`、`Compiler/` 原有文件，避免原目录语义膨胀。
  - 若某个教学主题跨越多个层级（如 GC、class generation + world spawn），优先拆成成对文件，而不是把 AngelScriptSDK/Runtime/Scenario 能力混进一个测试文件。
- [x] **P0.1** 📦 Git 提交：`[Test/Learning] Docs: freeze learning trace test taxonomy`

- [x] **P0.2** 固定 trace 事件模型与输出层级
  - 在计划执行前先写清楚 `Phase/StepId/Action/Observation/Evidence` 五段式，避免实现时每个测试自创输出格式。
  - 确定三路输出：Automation `AddInfo`、`UE_LOG`、可选文件导出。
  - 确定 detail level：默认输出课程摘要；如开启 verbose 配置，再打印扩展信息（例如更完整的 property/method 列表或字节码 hex/opcode 细节）。
- [x] **P0.2** 📦 Git 提交：`[Test/Learning] Docs: define educational trace event contract`

### Phase 1：建立共享的教学 trace helper

> 目标：先把“如何打印、如何分阶段、如何导出”的基础设施做出来，避免后续每个学习测试都手写输出格式。

- [x] **P1.1** 创建 `Shared/AngelscriptLearningTrace.h/.cpp`
  - 定义 `FAngelscriptLearningTraceSession`、`FAngelscriptLearningTraceEvent`、`FAngelscriptLearningTraceSinkConfig` 一类轻量 helper。
  - 支持 `BeginPhase()`、`AddStep()`、`AddKeyValue()`、`AddCodeBlock()`、`FlushToAutomation()`、`FlushToLog()`、`FlushToFile()` 这类基础接口。
  - 这一步只解决“如何收集与输出”，不解决编译/绑定/类生成细节。
- [x] **P1.1** 📦 Git 提交：`[Test/Learning] Feat: add shared educational trace helpers`

- [x] **P1.2** 为 helper 补统一格式化器
  - 至少覆盖以下常用展示：engine property 列表、compiler diagnostic 列表、函数声明列表、property 列表、生成类摘要、bytecode dword 摘要、callstack 行列表。
  - 格式化器应偏向稳定字符串，不依赖易变地址值或平台差异大的输出。
  - 先做“最小稳定版”，不要第一步就追求华丽文档导出。
- [x] **P1.2** 📦 Git 提交：`[Test/Learning] Feat: add educational trace pretty-printers`

- [x] **P1.3** 增加 trace 完整性断言 helper
  - 提供类似“断言 Phase 顺序”“断言某一步包含关键词”“断言至少存在 N 个观测项”的辅助函数。
  - 让教学型测试验证的是“课程结构有没有输出完整”，而不是把所有细节值都写死。
- [x] **P1.3** 📦 Git 提交：`[Test/Learning] Test: add educational trace structure assertions`

### Phase 2：打通 Native Core 课程线

> 目标：先在最稳定、最少 UE 干扰的原生层讲清楚 AngelScript 引擎最基本的创建、配置、编译、执行与 message callback。

- [x] **P2.1** 创建 `Learning/AngelscriptLearningNativeBootstrapTests.cpp`
  - 基于 `AngelscriptNativeTestSupport.h`，讲清楚 `asCreateScriptEngine()`、`SetEngineProperty()`、`SetMessageCallback()`、`GetModule(..., asGM_ALWAYS_CREATE)`、`Build()` 的最小链路。
  - 每一步打印“调用了什么 API、返回码是什么、当前 engine property 是什么”。
  - 该测试的价值是让用户先脱离 UE 封装，看懂 AngelScript 原生生命周期。
- [x] **P2.1** 📦 Git 提交：`[Test/Learning] Feat: add native bootstrap learning trace test`

- [x] **P2.2** 创建 `Learning/AngelscriptLearningBindingTraceTests.cpp`
  - 通过 `RegisterGlobalFunction`、`RegisterGlobalProperty`、`RegisterObjectType`、`RegisterObjectBehaviour` 等路径，讲清楚“原生绑定是怎么让脚本看见 C++ 能力”的。
  - 打印绑定声明串、返回码、模块里可见的函数声明、必要时打印 type id / type info 基础摘要。
  - 不在这一步引入 `FAngelscriptEngine`；保持原生层课程线的纯净度。
- [x] **P2.2** 📦 Git 提交：`[Test/Learning] Feat: add native binding learning trace test`

- [x] **P2.3** 创建 `Learning/AngelscriptLearningBytecodeTraceTests.cpp`
  - 先用原生模块编译一个最小函数，打印 `GetDeclaration()`、`GetParamCount()`、`GetVarCount()`、`GetByteCode()` 长度与前几项摘要。
  - 如果首批没有可靠 mnemonic disassembler，就先稳定输出“长度 + dword/opcode 摘要 + FindNextLineWithCode 结果”，把“可读反汇编”留作后续扩展。
  - 同时演示 `Prepare()` / `Execute()` / `GetReturnDWord()` 的调用链，形成“编译后如何执行”的完整闭环。
- [x] **P2.3** 📦 Git 提交：`[Test/Learning] Feat: add native bytecode and execution learning trace test`

- [x] **P2.4** 创建 `Learning/AngelscriptLearningHandleAndScriptObjectTraceTests.cpp`
  - 使用原生 `asIScriptObject` / handle 相关 API，讲清楚对象句柄、引用语义、对象属性枚举、属性地址访问、对象复制等核心概念。
  - 输出重点是“handle identity vs value equality”“script object 如何暴露 property metadata”，而不是仅验证脚本结果值。
- [x] **P2.4** 📦 Git 提交：`[Test/Learning] Feat: add handle and script-object learning trace tests`

- [x] **P2.5** 创建 `Learning/AngelscriptLearningDebuggerContextTraceTests.cpp`
  - 使用 `asIScriptContext` 的 callstack / line number / local variable API 组织“执行中观察”课程，讲清楚如何读 `GetCallstackSize()`、`GetFunction()`、`GetVar*()`。
  - 若首批不直接引入完整 debugger add-on，也至少做“callstack + locals + exception unwind”级别的课程线。
- [x] **P2.5** 📦 Git 提交：`[Test/Learning] Feat: add debugger context learning trace test`

### Phase 3：打通插件封装层的编译/分析课程线

> 目标：从“原生 AS”过渡到“插件里的 FAngelscriptEngine”，把预处理、模块描述、分阶段编译、诊断与热重载分析讲清楚。

- [x] **P3.1** 创建 `Learning/AngelscriptLearningCompilerTraceTests.cpp`
  - 基于 `Shared/AngelscriptTestUtilities.h` 与 `Shared/AngelscriptTestEngineHelper.cpp`，讲清楚 `BuildModule()` / `CompileModuleFromMemory()` / `CompileAnnotatedModuleFromMemory()` 的差异。
  - 输出至少包括：输入脚本名、是否走 preprocessor、得到多少 `FAngelscriptModuleDesc`、`CompileModules()` 返回什么 `ECompileResult`、收到了哪些 diagnostics。
  - 如果脚本故意写一个小错误，应把 `LogAngelscriptError()` 产生的 section/row/col/message 组织成教学输出，而不是只断言失败。
- [x] **P3.1** 📦 Git 提交：`[Test/Learning] Feat: add compiler pipeline learning trace test`

#### P3.1 补充：`CompileModules()` / 四阶段编译流观察细化任务

> 当前 `P3.1` 已经让 Learning 测试能讲清楚 `BuildModule()` / `CompileModuleFromMemory()` / `CompileAnnotatedModuleFromMemory()` 的入口差异、`ECompileResult` 与 diagnostics，但它仍主要停留在“API 输入/输出”视角。若要把 `FAngelscriptEngine` 的真正编译总线讲透，需要把 `CompileModules()` 与 `CompileModule_Types_Stage1()` / `CompileModule_Functions_Stage2()` / `CompileModule_Code_Stage3()` / `CompileModule_Globals_Stage4()` 拆成独立课程片段，并把夹在阶段之间的 parse / layout / reload 分析半步显式输出。

- [ ] **P3.1A** 为 `CompileModules()` 总编排器补一层结构化摘要
  - 目标不是直接暴露整段 `CompileModules()` 内部状态，而是给 Learning 测试一个“总线视角”的稳定观察面：至少记录 `CompileType`、输入 module 数、参与编译的绝对/相对文件名、`OutCompiledModules` 数量、最终 `ECompileResult`、以及是否走到了 class generation / swap-in / queued full reload 分支。
  - 优先修改 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h` 与 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp`，在现有 `FAngelscriptCompileTraceSummary` 基础上扩成“编译总线摘要”；只有 helper 无法稳定拿到阶段边界时，才评估最小 runtime seam。
  - Learning 输出里要明确说明：`CompileModules()` 不是简单 `for module -> compile`，而是统一驱动首编译、热重载与预编译恢复的阶段调度器。
- [ ] **P3.1A** 📦 Git 提交：`[Test/Learning] Chore: extend compile trace summary with CompileModules orchestration data`

- [ ] **P3.1B** 为 Stage 1（Types）补独立课程片段
  - 围绕 `CompileModule_Types_Stage1()` 增加结构化观察：临时模块名是否变成 `*_NEW_*`、导入模块数量、`CombinedDependencyHash` 是否折叠依赖、是否命中 precompiled stage1、是否写入 `AddPreClassData()` / delegate userdata tag、以及加入了多少 script sections。
  - 重点不是复述源码，而是讲清楚 Stage 1 为什么是“模块壳 + 类型世界 + 依赖导入”的装配入口。测试应至少准备一组带 import 的模块样本，以及一组带 `UCLASS()` / delegate 的 annotated 脚本样本，让输出能同时覆盖 pre-class data 和 delegate tag 语义。
  - 相关代码落点以 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 的 Stage 1 路径为主；测试落点优先继续使用 `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningCompilerTraceTests.cpp`，若单文件过重再拆出 `AngelscriptLearningCompileStagesTraceTests.cpp`。
- [ ] **P3.1B** 📦 Git 提交：`[Test/Learning] Feat: trace type-stage module assembly in compiler learning tests`

- [ ] **P3.1C** 把 Stage 1 之后的 parse / type-generate 半步显式课程化
  - 当前四阶段文档已经确认 `CompileModules()` 在 Stage 1 后还会做 `BuildParallelParseScripts()` 与 `BuildGenerateTypes()`；这两步不属于单独的 Stage 函数，但对理解“类型何时真正成立”极关键。
  - 计划中应明确：不要把这部分偷塞进 Stage 1 的一句话说明，而是要在 Learning trace 里单独打印“脚本已装载 section”与“类型已生成可见”的边界，例如生成类型数、builder 是否进入 type generation、以及 annotated 脚本的类型何时开始可被后续函数阶段引用。
  - 如果当前代码没有现成可读摘要，应优先通过测试侧对比 Stage 1 结束前后、Stage 2 进入前后的可见性差异来证明，而不是第一步就加大量 runtime 日志。
- [ ] **P3.1C** 📦 Git 提交：`[Test/Learning] Feat: document parse and type-generation half-steps after stage1`

- [ ] **P3.1D** 为 Stage 2（Functions）与后续 layout / reload 判定桥段补课程输出
  - `CompileModule_Functions_Stage2()` 本身很短，但它后面紧跟的 `CollectUpdatedTypeReferences()`、`DiffForReferenceUpdate()`、`BuildLayoutClasses()`、`BuildAllocateGlobalVariables()`、`BuildLayoutFunctions()` 才是热重载语义真正分叉的地方。Learning 课程必须把这一整段看成“Stage 2 后桥段”，而不是误导用户以为 Stage 2 完就直接进 Stage 3。
  - 输出至少覆盖：函数生成是否成功、哪些模块进入 references update、哪些模块被判成 structural change / code-only change、class/function layout 是否成功、何时分配 global variables、旧模块 bytecode 何时被替换引用。
  - 测试样本应至少包含一组 code-only 变化与一组结构变化（例如新增 `UPROPERTY()` / 改函数签名）脚本，用于解释为什么某些输入会把 `SoftReloadOnly` 推成 `PartiallyHandled` 或 `ErrorNeedFullReload`。
- [ ] **P3.1D** 📦 Git 提交：`[Test/Learning] Feat: trace function-stage follow-up layout and reload analysis`

- [ ] **P3.1E** 为 Stage 3（Code）补 builder -> JIT 课程线
  - 围绕 `CompileModule_Code_Stage3()` 输出 `BuildCompileCode()` 成功/失败、builder 何时被销毁、`JITCompile()` 是否执行、以及这一阶段为什么必须建立在“类型/函数/layout 已稳定”之后。
  - 如果测试不方便直接观察 builder 生命周期，可通过结果型证据表达：Stage 3 前不可执行、Stage 3 后可 `Prepare()` / `Execute()`；必要时补一条最小 helper，把“是否走了 JIT compile 路径”折成稳定布尔摘要，而不是泄露内部指针。
  - 这一步的重点是把“字节码可执行体真正何时落定”讲清楚，不是重复 `P2.3` 的原生 bytecode 课程。
- [ ] **P3.1E** 📦 Git 提交：`[Test/Learning] Feat: trace code-generation and jit handoff in compiler learning tests`

- [ ] **P3.1F** 为 Stage 4（Globals）补全局初始化与 coverage 映射课程线
  - 围绕 `CompileModule_Globals_Stage4()` 讲清楚 `ResetGlobalVars(0)` 与 `CodeCoverage->MapExecutableLines(*Module)` 为什么必须最后发生，并把“全局变量真正活起来”与“可执行行映射建立完成”作为独立观察点输出。
  - 课程样本至少要有一个依赖全局初始化的脚本，以及一个能展示 executable lines / line mapping 的多行函数脚本；这样才能把 `Globals` 阶段和后续 `P5.2` 的 line callback / coverage 课程自然接上。
  - 若当前 `LearningCompilerTraceTests.cpp` 无法承载这部分叙事，可把它拆成“CompilePipeline”与“CompileStages”两组 Learning 测试文件，避免单文件无限增长。
- [ ] **P3.1F** 📦 Git 提交：`[Test/Learning] Feat: trace global initialization and executable-line mapping after stage4`

- [ ] **P3.1G** 把最终 `ECompileResult`、diagnostics 与 reload 后果回收成结尾课程
  - 在阶段级观察全部补齐后，最后再统一解释 `FullyHandled` / `PartiallyHandled` / `Error` / `ErrorNeedFullReload` 各自代表什么，以及它们如何对应 `QueuedFullReloadFiles`、`PreviouslyFailedReloadFiles`、`EmitDiagnostics()`、class generation / swap-in 成败。
  - 这一步的目标是避免 Learning 输出只讲阶段局部，却没把“为什么最终是这个 compile result”收束起来。输出应明确区分：编译错误、需要 full reload 但当前不能 full reload、soft reload 成功但仍需后续 full reload 三种情况。
  - 相关验证既要看返回枚举，也要看 diagnostics / synthetic errors / queued reload side effects 是否与课程叙事一致。
- [ ] **P3.1G** 📦 Git 提交：`[Test/Learning] Test: explain compile result outcomes after four-stage pipeline`

- [x] **P3.2** 在 `Shared/AngelscriptTestEngineHelper.h/.cpp` 按需补轻量摘要 helper
  - 若直接在测试文件里重复读取 `Diagnostics`、`ECompileResult`、`AnalyzeReloadFromMemory()` 输出会显得散乱，可抽成少量 helper。
  - helper 只做“提取摘要”，不做新的业务层；避免把 Learning 逻辑反向侵入普通测试基础设施。
- [x] **P3.2** 📦 Git 提交：`[Test/Learning] Chore: add helper summaries for compile trace tests`

- [x] **P3.3** 创建 `Learning/AngelscriptLearningReloadAndClassAnalysisTests.cpp`
  - 基于 `AnalyzeReloadFromMemory()`，讲清楚某段带 `UCLASS/USTRUCT/UENUM` 注解的脚本在软重载分析阶段为什么得到 `SoftReload` / `FullReloadSuggested` / `FullReloadRequired`。
  - 输出 reload requirement、影响它的属性/函数变化点、是否需要 full reload。
  - 这是“编译正确”之外，用户理解插件为何这样组织类生成的关键课程点。
- [x] **P3.3** 📦 Git 提交：`[Test/Learning] Feat: add reload analysis learning trace test`

- [x] **P3.4** 创建 `Learning/AngelscriptLearningPreprocessorTraceTests.cpp`
  - 基于 `PreprocessorTests.cpp` 与 `FAngelscriptPreprocessor::OnProcessChunks/OnPostProcessCode`，讲清楚 chunk 拆分、macro 记录、`FilenameToModuleName()`、`import` 移除与 `ImportedModules` 记录。
  - 输出至少包括：原始脚本、chunk 类型、检测到的宏、生成后的 module name、处理后代码与 import 依赖结果。
- [x] **P3.4** 📦 Git 提交：`[Test/Learning] Feat: add preprocessor learning trace test`

- [x] **P3.5** 创建 `Learning/AngelscriptLearningFileSystemAndModuleTraceTests.cpp`
  - 基于 `AngelscriptFileSystemTests.cpp`，讲清楚脚本文件发现、按文件名/模块名查找 module、disk compile、partial failure isolation、skip rules 的行为。
  - 输出重点是“路径 -> module name -> module desc -> compile result”的映射过程。
- [x] **P3.5** 📦 Git 提交：`[Test/Learning] Feat: add file-system and module-resolution learning trace test`

- [x] **P3.6** 创建 `Learning/AngelscriptLearningRestoreAndBytecodePersistenceTests.cpp`
  - 讲清楚 bytecode/save-load 与 restore round-trip：哪些信息能保留，strip debug info 后哪些教学信息会减少。
  - 这条课程线应明确区分“可执行结果仍正确”和“调试/教学信息完整度变化”两类结果。
- [x] **P3.6** 📦 Git 提交：`[Test/Learning] Feat: add restore and bytecode persistence learning trace test`

- [x] **P3.7** 创建 `Learning/AngelscriptLearningHotReloadDecisionTraceTests.cpp`
  - 基于 `AngelscriptHotReloadAnalysisTests.cpp` 与相关 scenario，用多组脚本变更样本讲清楚：body-only、property count、super class、class added/removed、signature changed 分别触发什么 reload requirement。
  - 输出不仅要有最终枚举值，还要解释“判定触发点是什么”。
- [x] **P3.7** 📦 Git 提交：`[Test/Learning] Feat: add hot-reload decision learning trace test`

### Phase 4：打通类生成与 UE 反射课程线

> 目标：把脚本类怎么变成 `UClass` / `UFunction` / `FProperty` 讲出来，而不是只看最终能否 spawn。

- [x] **P4.1** 创建 `Learning/AngelscriptLearningClassGenerationTraceTests.cpp`
  - 以最小 `UCLASS()` 脚本为例，输出 `FindGeneratedClass()`、`FindGeneratedFunction()`、生成属性名/类型、默认值、super class、是否是 actor-derived。
  - 如果需要，订阅 `FAngelscriptClassGenerator` 的 `OnClassReload` / `OnPostReload` 等 delegate，在测试里记录生成时机与类名。
  - 输出重点是“脚本声明 -> 分析 property/method -> 生成 Unreal metadata”这条链路。
- [x] **P4.1** 📦 Git 提交：`[Test/Learning] Feat: add class generation learning trace test`

- [x] **P4.2** 必要时补最小 class-generator seam（按现状关闭）
  - `main` 复核结果显示，`P4.1` 的 `AngelscriptLearningClassGenerationTraceTests.cpp` 已经能基于现有 `FindGeneratedClass()`、`FindGeneratedFunction()`、默认对象与反射枚举完成首批课程线，当前没有证据表明还需要额外 class-generator seam 才能支撑已落地用例。
  - 因此本项在主线现状下按“无需新增 seam”关闭；只有未来新增 Learning 用例确实拿不到现有上下文时，才重新打开并补最小 seam。
- [x] **P4.2** 📦 Git 提交：`[Test/Learning] Chore: close conditional class-generation seam task after main-branch audit`

- [x] **P4.3** 补一条 Blueprint/脚本类联动课程路径
  - 复用 `ClassGenerator/AngelscriptScriptClassCreationTests.cpp` 的模式，展示脚本父类生成后如何创建 Blueprint child，Blueprint child 又如何保留脚本 override 行为。
  - 输出至少包括：生成类名、Blueprint child 名、BeginPlay 命中情况、关键 property 回读结果。
- [x] **P4.3** 📦 Git 提交：`[Test/Learning] Feat: add script-class-to-blueprint learning trace test`

- [x] **P4.4** 创建 `Learning/Runtime/AngelscriptLearningInterfaceDispatchTraceTests.cpp`
  - 基于 native interface 测试，讲清楚脚本类实现 C++ native UInterface、`ImplementsInterface`、实现类 dispatch、以及 `Execute_` bridge 的过程。
  - 输出重点是“native interface 绑定 -> 脚本实现类 -> C++/script 调用方看到的行为”。
- [x] **P4.4** 📦 Git 提交：`[Test/Learning] Feat: add interface dispatch learning trace test`

- [x] **P4.5** 创建 `Learning/AngelscriptLearningDelegateBridgeTraceTests.cpp`
  - 基于 `Delegate/AngelscriptDelegateScenarioTests.cpp` 与 `Bind_Delegates.h`，分别讲 unicast 和 multicast：storage、BindUFunction/AddUFunction、native -> script broadcast、script -> native callback。
  - 输出重点是“delegate signature 如何被保存”“绑定时对象和函数名如何落入 UE delegate 存储”。
- [x] **P4.5** 📦 Git 提交：`[Test/Learning] Feat: add delegate bridge learning trace test`

- [x] **P4.6** 创建 `Learning/AngelscriptLearningComponentHierarchyTraceTests.cpp`
  - 复用 `Component/AngelscriptComponentScenarioTests.cpp` 与 `Examples/AngelscriptScriptExamplePropertySpecifiersTest.cpp`，讲 default component、attach、root component、component BeginPlay/Tick 的过程。
  - 输出重点是 actor/component 组合关系与 property specifier 如何影响生成结果。
- [x] **P4.6** 📦 Git 提交：`[Test/Learning] Feat: add component hierarchy learning trace test`

- [x] **P4.7** 创建 `Learning/AngelscriptLearningBlueprintSubclassTraceTests.cpp`
  - 进一步拆开“脚本类 -> Blueprint child -> 运行时 override”课程线，讲清楚 Blueprint 侧继承并非只是编译通过，而是会影响 BeginPlay / property defaults / dispatch。
  - 这一步可与 `Blueprint/AngelscriptBlueprintSubclassActorTests.cpp` 互为参考，但应保留教学型输出，不只是场景断言。
- [x] **P4.7** 📦 Git 提交：`[Test/Learning] Feat: add blueprint-subclass learning trace test`

### Phase 5：打通执行、调试与 UE 调用桥课程线

> 目标：让用户看到“编译之后的脚本是怎么真正跑起来的，以及运行时还能观察到什么”。

- [x] **P5.1** 创建 `Learning/AngelscriptLearningExecutionTraceTests.cpp`
  - 讲清楚 `CreateContext()`、`Prepare()`、`Execute()`、返回值读取、异常/错误返回码。
  - 如测试使用 `FAngelscriptEngine` 路径，应输出 `FScopedTestEngineGlobalScope`、模块名、目标函数声明、执行结果码。
  - 至少补一条异常分支，演示 `LogAngelscriptException()` / `GetAngelscriptCallstack()` 能提供什么信息。
- [x] **P5.1** 📦 Git 提交：`[Test/Learning] Feat: add execution lifecycle learning trace test`

- [ ] **P5.2** 创建 `Learning/AngelscriptLearningLineTraceTests.cpp`
  - 以一段多行函数脚本为例，讲清楚 line callback 何时触发、coverage 如何记录 executable line、`FindNextLineWithCode()` 如何帮助理解“哪一行是可执行代码”。
  - 如果首批不想改 runtime，可以先通过现有 `FAngelscriptCodeCoverage::MapFunction/HitLine` 和 line callback 命中后的可见副作用来组织输出；如果信息还不够，再补最小 seam。
  - `main` 当前属于**部分实现**：`Learning/AngelScriptSDK/AngelscriptLearningBytecodeTraceTests.cpp` 与 `Learning/AngelScriptSDK/AngelscriptLearningDebuggerContextTraceTests.cpp` 已覆盖字节码、执行上下文和部分可执行行观察面，但还没有独立的 Learning line-trace / coverage 课程文件来把这些信息收束成单条课程线。
- [ ] **P5.2** 📦 Git 提交：`[Test/Learning] Feat: add line callback and coverage learning trace test`

- [x] **P5.3** 创建 `Learning/AngelscriptLearningUEBridgeTraceTests.cpp`
  - 讲清楚脚本类实例化、`UASFunction` / `ProcessEvent` 调用、`BlueprintOverride`、`BeginPlay`、属性读写回到 UE 对象这条路径。
  - 优先复用 `ExecuteGeneratedIntEventOnGameThread()`、`SpawnScriptActor()`、`ReadPropertyValue()` 等现有 helper，避免重新发明世界/对象夹具。
  - 输出重点是“脚本函数如何变成 UE 可调用事件”和“UE 对象状态如何反向证明脚本逻辑执行过”。
- [x] **P5.3** 📦 Git 提交：`[Test/Learning] Feat: add UE bridge learning trace test`

- [ ] **P5.4** 评估并接入 DebugServer 作为第二层深度观察手段
  - 这一步不是首批必需，但建议在计划中保留：利用 `AngelscriptDebugServer` 的 callstack / variables / evaluate 能力，为后续“单步执行课程”做准备。
  - 首批可以只做 smoke：连接调试端口、请求 callstack 或 break filters、输出返回内容；不强求完整 IDE 协议课程。
  - `main` 当前属于**部分实现**：`Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebuggerSmokeTests.cpp` 已经有真实 DebugServer handshake / break filters smoke，但这些能力还没有被包装成 `Learning/*` 课程输出。
- [ ] **P5.4** 📦 Git 提交：`[Test/Learning] Feat: add debugger-backed learning trace smoke test`

- [x] **P5.5** 创建 `Learning/AngelscriptLearningGCTraceTests.cpp`
  - 基于 `GC/AngelscriptGCScenarioTests.cpp`、`AngelScriptSDK/AngelscriptGCInternalTests.cpp` 与 runtime GC seam，讲清楚 actor destroy、component destroy、world teardown、cycle detection、manual collect、GC statistics 的差异。
  - 输出至少包括：对象图变化、GC 前后弱引用状态、统计计数、是否存在 cycle detect 或 undestroyed report。
- [x] **P5.5** 📦 Git 提交：`[Test/Learning] Feat: add GC learning trace test`

- [x] **P5.6** 创建 `Learning/AngelscriptLearningTimerAndLatentTraceTests.cpp`
  - 基于 `Bind_SystemTimers.cpp` 与 world tick helper，讲清楚 `System::SetTimer()`、pause/unpause、clear/invalidate 与 world time 推进的关系。
  - 如需要多帧叙事，优先复用 latent automation/fixture 模式，把“第 0 帧绑定 / 第 N 帧回调 / 清理 timer”输出成课程步骤。
- [x] **P5.6** 📦 Git 提交：`[Test/Learning] Feat: add timer and latent learning trace test`

- [ ] **P5.7** 创建 `Learning/AngelscriptLearningSubsystemLifecycleTraceTests.cpp`
  - 基于 `ScriptWorldSubsystem.h` / `Bind_Subsystems.cpp` 与现有 scenario，讲清楚 `ShouldCreateSubsystem()`、`Initialize()`、`PostInitialize()`、`OnWorldBeginPlay()`、`Tick()`、`Deinitialize()` 的顺序与 world-type 条件。
  - 如果当前脚本侧 subsystem 能力存在边界，也要把“不支持/需 full reload/仅特定 world type 创建”明确讲出来，作为边界课程而非忽略。
  - `main` 复核未发现对应的 Learning 测试文件或等价课程输出；本项仍视为**未实现**。
- [ ] **P5.7** 📦 Git 提交：`[Test/Learning] Feat: add subsystem lifecycle learning trace test`

- [ ] **P5.8** 创建 `Learning/AngelscriptLearningSourceNavigationTraceTests.cpp`
  - 基于 `Editor/AngelscriptSourceNavigationTests.cpp`，讲清楚 `UASFunction` 如何保留 source file path / source line number，以及编辑器为何能导航到脚本位置。
  - 这条课程线非常适合解释“编译/生成结果里哪些元数据真正流到了 Editor”。
  - `main` 当前属于**部分实现**：`Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp` 已验证 source file path / line number / navigation 能力，但还没有独立的 `Learning/Editor/` 教学型封装。
- [ ] **P5.8** 📦 Git 提交：`[Test/Learning] Feat: add source-navigation learning trace test`

- [ ] **P5.9** 创建 `Learning/AngelscriptLearningContainerAndDebuggerValueTraceTests.cpp`
  - 基于 bindings/container debugger 相关测试，讲清楚 `TArray/TSet/TMap/TOptional/TSubclassOf` 等桥接类型在脚本、UE 类型系统和调试输出中的差异。
  - 输出重点不是所有 API，而是“为何某类桥接类型在 debugger summary 里这样显示、脚本迭代时这样表现”。
  - `main` 当前属于**部分实现**：容器与桥接类型的行为已在 `Examples/AngelscriptScriptExampleArrayTest.cpp`、`Examples/AngelscriptScriptExampleMapTest.cpp` 等既有测试/示例中出现，debugger value 也有独立 Debugger 计划与基础设施，但尚未汇成独立 Learning trace 课程。
- [ ] **P5.9** 📦 Git 提交：`[Test/Learning] Feat: add container and debugger-value learning trace test`

### Phase 6：文档、运行入口与验证矩阵

> 目标：让这套教学型测试可以被稳定运行、稳定阅读，而不是只在代码里存在。

- [x] **P6.1** 更新 `Documents/Guides/Test.md`
  - 增加 `Learning/` 主题目录说明，明确它的目标是“教学型 trace”，不是普通功能回归。
  - 写明推荐运行方式：`Automation RunTests Angelscript.TestModule.Learning`；需要更完整日志时如何配 `-ABSLOG`、`-ReportExportPath`、`-LogCmds`。
  - 明确建议的日志级别，例如 `-LogCmds="Angelscript Display,LogAutomationTest Verbose"`。
- [x] **P6.1** 📦 Git 提交：`[Docs] Feat: document learning trace automation tests`

- [x] **P6.2** 新增 `Documents/Guides/LearningTrace.md`
  - 专门说明每个 Learning 测试在讲什么、运行后应该看哪些 phase、如何从日志读出“绑定阶段 / 类生成阶段 / 执行阶段 / UE bridge 阶段”的关键知识点。
  - 如果实现阶段支持导出 `json/md`，在文档里明确导出目录和字段说明。
- [x] **P6.2** 📦 Git 提交：`[Docs] Feat: add learning trace reading guide`

- [x] **P6.3** 更新 `Documents/Guides/TestCatalog.md`
  - 增加一个 `Learning — 教学型可观测测试` 目录段，至少按 `NativeBootstrap / Binding / Bytecode / Handles / DebuggerContext / Compiler / Preprocessor / FileSystem / HotReload / ClassGeneration / Interface / Delegate / GC / Timers / Subsystems / SourceNavigation / UEBridge` 列出条目和教学目标。
  - 目录条目要写“这个测试在解释什么”，不要只写文件名。
- [x] **P6.3** 📦 Git 提交：`[Docs] Feat: catalog learning trace tests`

- [ ] **P6.4** 分批验证教学型测试矩阵
  - 先跑 Native 层学习测试，再跑 Compiler/ClassGeneration，再跑 Execution/UEBridge，最后跑总前缀 `Angelscript.TestModule.Learning`。
  - 每一批不仅确认通过/失败，还要抽查输出是否真的包含阶段标题、关键观测项和稳定的可读顺序。
  - 如果某个测试输出过于嘈杂或缺核心信息，应优先修输出结构，而不是继续堆更多日志。
  - `main` 当前属于**部分实现**：单项 Learning 测试、`Shared/AngelscriptLearningTraceTests.cpp` 与阅读文档都已存在，但计划内尚无一条明确记录过的“分批矩阵验证”结果来证明全前缀输出质量已经系统复核。
- [ ] **P6.4** 📦 Git 提交：`[Test/Learning] Test: verify educational trace test matrix`

## 推荐实施顺序

如果需要分里程碑交付，建议按下面三段推进：

1. **M1 = Phase 0 + Phase 1 + Phase 2**
   - 先把 trace helper、Native bootstrap、bytecode、handles、debugger context 建起来，最快得到“能看见 AS 原生引擎过程”的第一批价值。
2. **M2 = Phase 3**
   - 聚焦插件封装层：compiler、preprocessor、file system、restore、hot reload decision，解释“脚本进入插件管线后发生了什么”。
3. **M3 = Phase 4**
   - 聚焦类生成与 UE 元数据：class generation、Blueprint child、interface、delegate、component hierarchy，解释“为什么 AS 能变成 UE 可用类型和事件”。
4. **M4 = Phase 5 + Phase 6**
   - 最后补执行、调试、GC、timer、subsystem、source navigation 与文档化运行入口。

## 验收标准

1. `Plugins/Angelscript/Source/AngelscriptTest/` 下存在独立的 `Learning/` 主题目录，且命名与运行前缀统一。
2. 存在共享 trace helper，至少能统一输出阶段、步骤、观测值，并支持 `AddInfo` + `UE_LOG` 两条主路径。
3. 计划至少覆盖 10 类以上教学主题：原生引擎启动、绑定、字节码、handles/script object、debugger context、compiler/preprocessor、file system/module resolution、hot reload、class generation、interface/delegate、GC、timers/subsystems、source navigation、UE bridge。
4. 每个教学型测试既能打印过程，也保留最小必要断言，保证输出结构完整且非空。
5. `Documents/Guides/Test.md` 与 `Documents/Guides/TestCatalog.md` 已同步收录这类测试，且中文文档优先更新。
6. 至少一部分扩展主题明确覆盖“边界知识”，例如 subsystem 当前支持边界、debug info strip 对教学信息的影响、soft/full reload 判定阈值。

## 风险与注意事项

### 风险 1：教学输出侵入生产日志

如果直接在 runtime 大量增加常驻日志，容易污染正常开发与 CI 输出。应优先把输出组织在测试 helper 层；必要的 runtime seam 也应尽量设计为“测试主动拉取”或“仅在测试配置下启用”。

### 风险 2：输出太多，反而失去教学价值

教学型测试不是越多日志越好。每个 phase 只应保留能解释机制的关键信息，例如类型名、函数声明、line number、reload requirement、生成类摘要，而不是把全部内部结构无差别打印。

### 风险 3：把脆弱实现细节写死成断言

像内存地址、完整 opcode 序列、某些热重载时序、delegate 触发顺序，未来可能因为上游同步或平台差异变化。教学型测试应优先锁住“结构与边界”，不要把偶然细节全部做成硬失败条件。

### 风险 4：目录定位不清，和现有 `Examples/` / `AngelScriptSDK/` 重叠

实现时要持续记住：`Learning/` 目录的职责是“解释”，`Examples/` 更偏“功能示例”，`AngelScriptSDK/` 更偏“内部正确性验证”。同一机制可以跨目录存在，但每个目录承担的叙事职责要清晰。

### 风险 5：为了教学方便过度暴露内部 seam

如果某个信息只能靠新增 runtime seam 才能拿到，要先判断它是不是首批课程真的必须知道。优先复用 `Diagnostics`、delegate、existing helper、public/internal API；只有在“完全没有替代路径”时，才做最小测试导出点。

### 风险 6：生命周期/多帧测试易受时序影响

像 timer、subsystem、world teardown、hot reload、delegate 广播这类主题，天然比纯编译/反射测试更容易受帧推进、world 状态、editor context 影响。实现时应优先复用现有 world fixture、latent command 与 scenario helper，避免每个 Learning 测试自建一套时序驱动逻辑。
