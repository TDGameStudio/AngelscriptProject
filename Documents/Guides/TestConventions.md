# Angelscript 测试模块规范

## 目标

这份文档用于把当前项目的测试模块整理成一套**可复用、可扩展、可执行**的统一规范，重点解决三类问题：

1. **测试层级不够清晰**：`CppTests`、`TestModule`、`Editor` 三条线同时存在，但放置与前缀边界容易混淆。
2. **命名不够稳定**：部分文件名没有 `Angelscript` 前缀，部分 ASSDK 测试文件名没有显式带 `ASSDK`，部分目录/前缀/类名之间存在冗余或不对齐。
3. **流程入口不够标准**：虽然已有 `RunTests.ps1`，但常用 smoke / native / functional 波次还没有统一成具名入口。

## 当前规范总则

### 1. 测试层级矩阵

| 层级 | 代码路径 | Automation 前缀 | 用途 | 推荐 helper |
| --- | --- | --- | --- | --- |
| Runtime 内部 C++ | `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` | `Angelscript.TestModule.CppTests.*` | 运行时内部状态、共享引擎、隔离、覆盖率、预编译数据等 | Runtime 私有头 + `StartAngelscriptHeaders.h` |
| Editor 内部 | `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` | `Angelscript.Editor.*` | Editor 专有行为，例如 watcher / source navigation / debugger seam | Editor 私有实现 + editor-only helper |
| Native Core | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/<Domain>/` | `Angelscript.TestModule.AngelScriptSDK.<Domain>.*` | 只验证 AngelScript 核心/已公开原生接口，不引入 `FAngelscriptEngine` 或 `sdk/add_on` | `Support/AngelscriptNativeCoreTestSupport.h`、`Support/AngelscriptNativeExecutionTestSupport.h`、`AngelscriptTestAdapter.h` |
| Runtime 集成 | `Plugins/Angelscript/Source/AngelscriptTest/Core/`、`Angelscript/`、`Bindings/`、`AngelScriptSDK/`、`Compiler/`、`Preprocessor/`、`FileSystem/`、`Generator/` | `Angelscript.TestModule.*` | 基于 `FAngelscriptEngine` 的编译、绑定、语言行为与内部机制验证；`Generator/` 内按 `ASClass` / `ASFunction` / `ASStruct` / `ReloadPlanning` 等子目录区分脚本生成后行为与 generator 能力 | `AngelscriptTestEngineHelper.*`（`Shared/` 已在 Build.cs include 路径） |
| Debugger 场景 | `Plugins/Angelscript/Source/AngelscriptTest/Debugger/` | `Angelscript.TestModule.Debugger.*` | 附着运行中的 production-like engine，验证握手、断点、步进等调试链路 | `AngelscriptDebuggerTestSession.*` / `AngelscriptDebuggerTestClient.*` / `AngelscriptDebuggerScriptFixture.*` |
| UE 功能测试层 | `Plugins/Angelscript/Source/AngelscriptTest/Actor/`、`Blueprint/`、`Component/`、`Delegate/`、`GC/`、`HotReload/`、`Interface/`、`Subsystem/` 等 | `Angelscript.TestModule.<Theme>.*` | 在 UObject / World / Actor / Component / HotReload 语义中验证最终行为 | `AngelscriptFunctionalTestUtils.h` + `AngelscriptTestWorld.h`（actor / world tick / 完整生命周期） |
| Learning | `Plugins/Angelscript/Source/AngelscriptTest/Learning/Native/`、`Learning/Runtime/` | `Angelscript.TestModule.Learning.<Layer>.*` | 结构化 trace / 教学型可观测测试 | `AngelscriptLearningTrace.*` |
| Bindings Contract (CQTest) | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/` | `Angelscript.TestModule.Bindings.<Type>.*` | AS 可见手写 / 默认绑定入口的契约冒烟：声明、解析、代表性 native dispatch；大型语义矩阵放到 `Coverage/` | `CQTest.h` + `AngelscriptTestModuleScope.h` + `AngelscriptTestExecute.h` + 按需 `Bindings/Angelscript*TestHelpers.h` |
| Crash-only 子进程 | `Plugins/Angelscript/Source/AngelscriptTest/<Theme>/` | `Angelscript.CrashOnly.<Theme>.*` | 主动触发崩溃并验证崩溃路径产物；必须单独运行，不能进入普通 suite/group/full-run | 独立 child process + `Tools\RunTests.ps1 -TestPrefix "Angelscript.CrashOnly.<Theme>"` |

### 2. 文件命名规则

#### 通用规则

- 测试源文件统一以 `Angelscript` 开头。
- 同一文件内包含多个 case 时，使用 `*Tests.cpp`；只有单一聚焦 case 时才使用 `*Test.cpp`。
- 不再新增 `PreprocessorTests.cpp` 这类“缺少项目前缀”的文件名。
- `Template/` 目录中的文件视为**夹具模板**，不是新的 Automation 测试文件落点。

#### Native Core 规则

- 纯原生 AngelScript 核心测试：`AngelscriptNative*Tests.cpp`，按 `Engine`、`Frontend`、`Compiler`、`Runtime`、`Module`、`TypeSystem`、`Language`、`Embedding`、`Conformance` 子目录归属。
- 不新增 `ASSDK`、flat `Smoke` 或历史兼容别名作为 SDK 测试身份；ID 以行为主题而非来源品牌命名。

示例：

- `AngelscriptNativeExecutionTests.cpp`
- `AngelscriptASSDKExecuteTests.cpp`
- `AngelscriptASSDKGlobalVarTests.cpp`

### 3. Automation 前缀规则

- `Angelscript.TestModule.CppTests.*`：只用于 `AngelscriptRuntime/Tests/`
- `Angelscript.Editor.*`：只用于 Editor 内部测试
- `Angelscript.TestModule.*`：只用于 `AngelscriptTest` 模块
- `Angelscript.CrashOnly.*`：只用于会主动 crash 的隔离测试；必须通过 `Tools\RunTests.ps1 -TestPrefix "Angelscript.CrashOnly..."` 单独运行，测试本体应要求 runner 注入的显式 opt-in flag

### 4. 前缀命名策略

#### 层级优先

用于 Native / Learning：

- `Angelscript.TestModule.AngelScriptSDK.Runtime.*`
- `Angelscript.TestModule.AngelScriptSDK.Embedding.*`
- `Angelscript.TestModule.Learning.Native.*`
- `Angelscript.TestModule.Learning.Runtime.*`

#### 主题优先

用于 UE 功能测试与运行时集成主题目录：

- `Angelscript.TestModule.Actor.*`
- `Angelscript.TestModule.Component.*`
- `Angelscript.TestModule.Delegate.*`
- `Angelscript.TestModule.Interface.*`
- `Angelscript.TestModule.HotReload.*`

> 目录已经表达功能测试层时，Automation 路径中不再重复追加层级名；目录、helper、fixture 和测试注释都应使用具体主题语义。

#### 兼容保留项

以下前缀是当前项目已经大面积使用、且对外可见性较强的历史前缀，本轮不强制整体改名，但后续新增 case 仍需沿用其现有家族：

- `Angelscript.TestModule.WorldSubsystem.*`
- `Angelscript.TestModule.GameInstanceSubsystem.*`

#### 例外：Functional 主题层（Round1 gap-fill）

`Documents/Plans/Plan_ReferenceBasedTestExpansion.md` 的 Round1 落地（参见 `Plugins/Angelscript/Source/AngelscriptTest/Functional/<Theme>/Angelscript<Theme><Topic>Tests.cpp`，目录段为 `Animation` / `GAS` / `Property` / `Rendering` / `Widget` 等）按计划保留 **`Angelscript.TestModule.Functional.<Theme>.<Topic>.*`** 这一额外的 `Functional.*` 主题层级，与默认的 `Angelscript.TestModule.<Theme>.*`（`Actor/Component/Delegate/...`）并存。该例外只覆盖该计划落地的 15 个用例（详见 `TestCatalog.md` 12.16 节），其它新增主题集成测试仍使用默认的 `<Theme>.*` 形态。

## 新增测试的标准流程

### Step 1：先定层级，不要先写文件

先回答这三个问题：

1. 它是否需要 `FAngelscriptEngine`？
2. 它是否需要真实 `UObject` / `World` / `Actor` 生命周期？
3. 它是否只是 Editor 内部行为？

依据答案选择 `CppTests` / `Editor` / `Native` / 运行时集成 / UE 功能测试 / Learning。

### Step 2：再定目录和主题

- 先复用已有主题目录，不要为了单个 case 新建宽泛目录。
- 若 case 横跨多个主题，优先放在“最终行为发生处”，不要为 helper 所在处命名。
- `Generator/` 新增测试要先判断测试族别：如果目标是“脚本生成后的 `UASClass` / `UASFunction` / `UASStruct` 行为”，放到 `ASClass/`、`ASFunction/`、`ASStruct/` 或 `ScriptClass/`；如果目标是 `FAngelscriptClassGenerator` 自身能力、reload classification 或纯 reload planning seam，放到 `Core/` 或 `ReloadPlanning/`。Automation 前缀使用 `Angelscript.TestModule.Generator.*`，生产 runtime 头路径和类型名仍沿用 `ClassGenerator`。

### Step 3：统一文件名与前缀

- 文件名要能一眼说明测试族别。
- Automation 前缀要先区分模块层，再区分主题，再区分 case。
- 不要混用 `Angelscript.TestModule.CppTests.*` 与 `Angelscript.TestModule.*`。
- 会主动崩溃的测试不要使用 `Angelscript.TestModule.*`；放在 `Angelscript.CrashOnly.*` 下，避免被普通主题、group、suite 或全量回归带入。

### Step 4：优先复用 helper

- Native：`AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h`
- Runtime 集成：`AngelscriptTestEngineHelper.*`
- UE 功能测试：`AngelscriptFunctionalTestUtils.h`
- UE 功能测试 actor / world tick / 完整生命周期：`AngelscriptTestWorld.h::FAngelscriptTestWorld`（`SpawnActorOfClass` / `BeginPlay` / `Tick` / `TickViaManager` / `DispatchActorTick` / `DispatchComponentTick` / `DestroyAndDrain`，详见 `Documents/Guides/Test.md` "Actor / World Tick 测试推荐 harness" 章节，模板见 `Template_WorldTick.cpp` / `Template_GameLifetime.cpp`）
- Learning：`AngelscriptLearningTrace.*`
- CQTest 绑定契约：`CQTest.h` + `AngelscriptTestMacros.h` + `AngelscriptTestModuleScope.h` + `AngelscriptTestExecute.h`；只验证 AS 可见入口能编译、解析并代表性 dispatch，类型 / 值域 / 边界大矩阵放到 `Coverage/`（详见 `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md` 与 `Shared/README.md`）

### Step 5：同步流程入口和文档

- 至少更新 `Documents/Guides/TestCatalog.md`
- 如果新增了新的回归波次或推荐入口，同步更新 `Documents/Guides/Test.md` 与 `Documents/Tools/Tool.md`
- 如果改变了目录/命名边界，同步更新 `Plugins/Angelscript/AGENTS.md`

## 典型测试场景（标准样本）

| 场景 | 推荐层级 / 目录 | 标准前缀 | 核心流程 | 推荐命令 |
| --- | --- | --- | --- | --- |
| Native Core smoke | `Source/AngelscriptTest/AngelScriptSDK/` | `Angelscript.TestModule.AngelScriptSDK.Smoke` | 创建独立 AngelScript 引擎 → 编译/执行最小脚本 → 验证返回值/消息回调 | `.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK"` |
| Runtime 引擎隔离 | `Source/AngelscriptTest/Core/` | `Angelscript.TestModule.Engine.MultiEngine.*` / `Angelscript.TestModule.Engine.DependencyInjection.*` / `Angelscript.TestModule.Engine.EngineSubsystem.*` | 创建 full / testing 引擎 → 校验共享状态、模块隔离、依赖注入与 subsystem ownership | `.\Tools\RunTestSuite.ps1 -Suite Smoke` |
| Debugger 协议与调试场景 | `Source/AngelscriptTest/Core/`、`Source/AngelscriptTest/Debugger/` | `Angelscript.TestModule.Engine.Debugger.AutoEvaluate.*` / `Angelscript.TestModule.Debugger.*` | 连接调试客户端 → 启动调试会话 → 断言自动求值、握手、断点、步进与停止状态 | `.\Tools\RunTestSuite.ps1 -Suite Debugger` |
| UE 功能测试 Actor / Component | `Actor/`、`Component/` | `Angelscript.TestModule.Actor.*` / `Angelscript.TestModule.Component.*` | `FAngelscriptTestWorld W(*TestRunner, Engine)` → `W.SpawnActorOfClass` → `W.BeginPlay` → `W.Tick` / `W.DispatchActorTick` / `W.DispatchComponentTick` → `ReadPropertyValue` 读回断言 | `.\Tools\RunTestSuite.ps1 -Suite FunctionalSamples` |
| UE 完整 Actor 生命周期 | `Actor/` 或主题目录 | `Angelscript.TestModule.Actor.Lifecycle.*` 等 | `FAngelscriptTestWorld` → `SpawnActorOfClass`（触发 `UserConstructionScript`）→ `BeginPlay` → `Tick` × N → `DestroyAndDrain`（同步派发 `EndPlay(Destroyed) + Destroyed`）→ 断言计数 / 顺序 / `LastEndPlayReason` | `.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor."` |
| HotReload 回归 | `HotReload/` | `Angelscript.TestModule.HotReload.*` | 编译 V1 → 生成对象/状态 → 编译 V2 → 断言 soft/full reload 结果与状态保持 | `.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload"` |
| 绑定契约 (CQTest) | `Bindings/` | `Angelscript.TestModule.Bindings.<Type>.*` | CQTest `BEFORE_ALL` 获取引擎 → 每个 `TEST_METHOD` 编译最小 AS 模块 → 验证绑定入口存在、声明可解析、代表性调用到达 native；大型语义矩阵改放 `Coverage/` | `.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings."` |

## 本轮规范化落点

本轮先做三件低风险、收益高的事情：

1. **把流程入口标准化**：新增 `Tools\RunTestSuite.ps1`，把常用 smoke / native / functional 波次固化成具名 suite。
2. **把规范写成文档**：由这份文档统一说明层级、命名和典型场景。
3. **修正典型命名异常**：优先处理 ASSDK Native 文件名和缺少 `Angelscript` 前缀的 Preprocessor 测试文件。

更大范围的批量重命名（例如 `WorldSubsystem`、`GameInstanceSubsystem` 这类历史前缀）仍保持兼容优先，后续若要整体改，需要单独计划、分批迁移、并同步更新回归入口与文档。

