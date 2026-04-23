# Angelscript 插件现状、Hazelight 差距与优先级推进计划

## 背景与目标

当前仓库已经不是一个"从零开始做脚本插件"的状态，而是一个**核心运行时、编辑器集成、测试基础设施都已成型**、但**对外交付入口、若干关键能力闭环、以及相对 Hazelight 基线的优先级收口仍然分散**的阶段。

一方面，`Plugins/Angelscript/` 已经具备 `Runtime / Editor / Test` 三模块、`DebugServer`、`CodeCoverage`、`StateDump`、大量 `Bind_*.cpp` 与成体系自动化测试；另一方面，当前状态快照分散在 `Plan_OpportunityIndex.md`、`TechnicalDebtInventory.md`、`Plan_HazelightCapabilityGap.md`、`Plan_PluginEngineeringHardening.md` 等多份文档中，导致执行时容易在"功能补齐""插件化硬化""Hazelight parity""测试债分流"之间来回切换。

本计划的目标不是再新增一条功能主线，而是把**当前完成现状、Hazelight 差距和下一阶段优先级顺序**收束成一个单入口：先校准事实，再先做真正阻塞插件可交付与可对齐的事项，最后才进入更深的能力扩展和架构演进。

## 范围与边界

- **范围内**
  - 当前工程完成现状的单点快照
  - 当前仓库与 `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot` 指向 Hazelight 基线的差距分层
  - 现有 sibling plan 的优先级重排与执行顺序
- **范围外**
  - 在本文直接展开具体实现方案、接口设计或代码改造细节
  - 把所有现有计划重新抄写一遍
  - 把结构差异误写成功能缺口，或把引擎补丁项误写成普通插件内待办
- **执行边界**
  - 本文优先回答"下一步先做什么、为什么先做、证据在哪"，而不是代替各 sibling plan 的详细实施说明
  - 具体实施仍回到对应 sibling plan：测试债、硬化、Hazelight parity、AS 2.38 迁移、Bind 扩展等分别由已有文档承接

## 当前事实状态快照

1. **仓库定位已经收口为插件优先，而不是宿主工程优先。**
   - 根指引 `AGENTS.md` 已明确 `Plugins/Angelscript/` 是核心交付物，`Source/AngelscriptProject/` 只保留最小宿主职责；后续优先级必须围绕插件本体组织，而不是把大量逻辑回流到宿主模块。

2. **插件核心骨架已经成熟，不属于"能力底座缺失"阶段。**
   - `Plugins/Angelscript/Angelscript.uplugin` 已形成 `AngelscriptRuntime`、`AngelscriptEditor`、`AngelscriptTest` 三模块。
   - `Plugins/Angelscript/Source/AngelscriptRuntime/` 已具备 `Core/`、`ClassGenerator/`、`Preprocessor/`、`Debugging/`、`CodeCoverage/`、`Dump/`、`StaticJIT/`、`FunctionLibraries/`、`Binds/` 等主体结构。
   - 当前 `Binds/` 下已有 **124 个 `Bind_*.cpp`** 与 **23 个头文件**，说明绑定面已经很广，不应继续用"插件还没建立绑定体系"的口径描述当前状态。

3. **测试与观测基础设施已经远强于普通原型阶段，但当前口径必须区分三套数字。**
   - `Documents/Guides/TestCatalog.md` 中的 **`275/275 PASS`** 是"已编目基线"。
   - `Documents/Guides/TechnicalDebtInventory.md` 中的 **`443/436/7`** 是当前 live full-suite 快照。
   - 源码扫描规模与实际执行规模不是同一件事；后续任何 status/roadmap 都不能把三者混写成一个数字。

4. **当前内部构建 / 测试 runner 与测试约定已经相当成熟，缺的不是内部工程能力，而是对外入口。**
   - `Tools/RunBuild.ps1`、`Tools/RunTests.ps1`、`Tools/RunTestSuite.ps1` 与 `Tools/Bootstrap/powershell/BootstrapWorktree.ps1` 已经把构建、suite 调度、超时、日志隔离、多 worktree 约束和 bootstrap 入口收口为统一流程。
   - `Documents/Guides/Build.md` 与 `Documents/Guides/Test.md` 已明确要求只通过这些官方脚本执行；`Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md` 还把测试宏、引擎创建模式和命名约定沉淀成了成体系规范。
   - 这说明当前仓库真正欠缺的是"让外部使用者看得见、跟得上"的文档和分发入口，而不是继续补更多内部 runner。

5. **当前分支仍然是"2.33-based + 选择性吸收 2.38 能力"的状态，而不是已经完整升到 2.38。**
   - `Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptFunctionTests.cpp` 仍明确把 function template 负例描述为"`2.33-based branch`"。
   - `ThirdParty/angelscript/source/` 中则已有多处"stock 2.38 compatibility"注释，说明当前状态更接近"2.33 主体 + 2.38 局部兼容/回移"，后续优先级必须继续按选择性迁移推进，而不是假设整包 parity 已完成。

6. **当前运行时观测、调试和热重载基础设施已经足够深，不应再被写成"原型级能力"。**
   - `Dump/AngelscriptStateDump.h` 当前已声明 **24** 类导出表，覆盖 engine / modules / classes / functions / delegates / bind database / hot reload / precompiled data / debug server / code coverage 等状态面。
   - `Debugging/AngelscriptDebugServer.h` 当前公开的是 **Version 2** 调试协议，消息类型覆盖 `Diagnostics`、`Pause`、`RequestCallStack`、`RequestVariables`、`GoToDefinition`、`BreakOptions`、`SetDataBreakpoints` 等完整调试工作流骨架。
   - `AngelscriptEditor/HotReload/ClassReloadHelper.*`、`CodeCoverage/`、`StaticJIT/`、`PrecompiledData.*` 也都表明这个仓库已经进入"复杂能力如何收口和对外说明"的阶段，而不是"先把底座搭出来"的阶段。

7. **当前对外交付基线仍明显偏弱。**
   - 根 `README.md` 仍然只有 `NULL`。
   - 当前仓库没有 `.github/workflows/`。
   - `Plugins/Angelscript/Angelscript.uplugin` 中 `DocsURL`、`MarketplaceURL`、`SupportURL` 仍为空。
   - 这意味着当前仓库"适合持续研发"，但还没有进入"插件可直接对外消费/协作"的交付状态。

8. **相对 Hazelight，当前脚本上手资产和公开工作流仍薄。**
   - 当前仓库 `Script/Examples/` 下已统计到 **27 个 `.as` 示例**，按 `Core/`（20 个）、`EnhancedInput/`（2 个）、`Extended/`（5 个）分组。
   - Hazelight `J:\UnrealEngine\UEAS2\Script-Examples/` 下有 **26 个 `.as` 示例**，并且按 `Examples/`、`GASExamples/`、`EnhancedInputExamples/`、`EditorExamples/` 分组。
   - 示例数量上当前仓库已经**达到 Hazelight 同等规模**；剩余差距主要在 GAS 专项示例和对外消费路径（缺少 `Script/Examples/README.md` 使用说明）。

9. **当前 Script Subsystem 已从"负例测试"推进到"编译正例"状态。**
   - `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/AngelscriptSubsystemScenarioTests.cpp` 中，`UScriptWorldSubsystem` 与 `UScriptGameInstanceSubsystem` 的四个场景测试已改为 `FullReload` 编译，断言编译成功并验证 UClass 物化（2026-04-22 由 `Plan_FunctionalGapClosure.md` Phase 2 完成）。
   - 根因确认：之前编译失败是因为测试使用 `SoftReloadOnly` 编译全新类，而非功能缺失。ClassGenerator 和 Preprocessor 中没有显式拒绝子系统子类的逻辑。

10. **当前仓库并非全面落后于 Hazelight，反而在若干基础设施上已经更强。**
   - 测试组织明显更系统，`AngelscriptTest/` 已按 `Actor`、`Bindings`、`Blueprint`、`Component`、`Debugger`、`HotReload`、`Subsystem` 等主题拆分。
   - `Plugins/Angelscript/Source/AngelscriptTest/` 下直接统计到 **417+** 个自动化测试定义（覆盖 **429** 个测试 `.cpp` 文件），且 `TESTING_GUIDE.md` 已把测试分层和引擎生命周期宏使用沉淀成统一规范。仅剩 **2 个 Disabled 测试**（均为 `#ue57-headless`）。
   - `Dump/AngelscriptStateDump.h` 已建立比对和盘点都很好用的状态导出体系。
   - `Interface` 相关主题测试已存在，而 `UINTERFACE` 支持不应再被误判为落后项。

## 当前与 Hazelight 的差距分层

### 一、引擎侧差距：需要单独承认边界，不能误写成普通插件待办

- Hazelight 基线本身是"引擎分支 + 插件 + 配套工作流"，而不只是 `Engine/Plugins/Angelscript/`。
- 涉及 UHT、Blueprint 编译链、`CoreUObject` 反射链路等能力时，必须先判断其是否属于 `J:\UnrealEngine\UEAS2\Engine/Source/` 侧的引擎补丁，而不是继续在当前插件里开一个"补某个类/某个 bind"式的假任务。
- 这条边界由 `Plan_HazelightCapabilityGap.md` 持续维护；本总览只把它列为长期约束，不把它排进近期插件内 P1 任务。

### 二、插件侧功能差距：当前最该优先收口的，是"已暴露但未闭环"的表面

- **Script Subsystem**：`WorldSubsystem` / `GameInstanceSubsystem` 仍停留在负例测试阶段，是目前最直接的"接口在、能力没闭环"案例。
- **网络复制与 RPC 验证闭环**：当前已有底座，但验证强度、专题测试、示例与文档仍弱于 Hazelight 的公开能力面；优先由 `Plan_NetworkReplicationTests.md` 及其 sibling tasks 承接。
- **Console / 全局变量工作流**：当前"global variable 完全缺失"已经不是事实，真实剩余差距收敛到 `FConsoleCommand` 与更完整的控制台工作流可见性，继续由 `Plan_GlobalVariableAndCVarParity.md` 收口。
- **GAS / EnhancedInput helper surface**：当前主插件已经内建 GAS 和 EnhancedInput 依赖，也已有 `21` 个本地 `FunctionLibraries` 头文件，但相对 Hazelight 的 `AngelscriptGAS/Source/Public/Mixin/` 下 **17** 个 mixin、`FunctionLibraries/` 下 **4** 个 GAS function libraries、以及 `AngelscriptEnhancedInput/Source/Public/Mixin/` 下 **2** 个 EnhancedInput mixin，当前脚本友好 helper 面仍然偏薄；这更像"API 表面与工作流差距"，而不只是"有没有基类/有没有 bind"。

### 三、工具链与上手差距：这部分最直接影响外部可用性，优先级应高于很多"看起来更酷"的底层扩展

- **根 README / BuildPlugin / CI / Compatibility / Release / Security / Contribution**：当前仍不完整，直接阻塞插件可交付基线。
- **Script-Examples**：当前只有零散示例与测试脚本，缺少像 Hazelight 一样可直接复制使用的示例分组。
- **VS Code / Debug / API 可见性**：当前已有 `DebugServer` 与 Source Navigation 基础，但没有对外工作流入口、workspace 组织和脚本 API 文档入口。
- **公开承诺差距**：Hazelight 官网把"`Script/` + VS Code + 保存即重载 + 自动补全/诊断/重命名/引用 + 调试器 + Script API Reference"直接作为用户承诺；当前仓库虽然内部已经具备调试、测试、覆盖率和 build/test runners，但缺少一套面向外部使用者的总入口来承接这些能力。

### 四、结构差异：应记录，但不应一上来当成最高优先级缺口

- Hazelight 使用 `AngelscriptCode + AngelscriptEditor + AngelscriptLoader`，并把 `AngelscriptGAS`、`AngelscriptEnhancedInput` 独立成插件。
- 当前仓库使用 `AngelscriptRuntime + AngelscriptEditor + AngelscriptTest`，并把 GAS / EnhancedInput 直接并入主插件依赖。
- 这更像**工程边界选择**，不是立即阻塞当前插件使用的功能缺口；近期优先级应先做"功能和验证闭环"，结构重拆放在后面。

### 五、不应再误判为差距的项目

- `CodeCoverage` 与 `Commandlet`：当前插件均已具备。
- 编辑器菜单扩展与 `ScriptEditorSubsystem`：当前插件已具备。
- `UINTERFACE` 支持：当前插件已有专门测试，不再按 Hazelight 公共限制文档倒推成缺口。
- "完全没有绑定体系""还没有测试基础设施""仍是纯实验性原型"这类描述，都不再符合当前事实。

## 分阶段执行计划

### Phase 0：先校准现状口径与 owner 路由，避免继续基于错位事实排优先级

> 目标：先让所有后续计划都站在同一套事实基线上；不先做这一步，后续每一条 P1/P2 都会继续引用不同数字和不同问题归属。

- [ ] **P0.1** 固定"当前现状"口径与数字基线
  - 统一采用三套并行数字：`275/275` 已编目基线、live full-suite（需实际运行确认）、以及实时源码扫描规模（`417+` 定义 / `429` 文件）；禁止后续 roadmap 再把它们混写成一个"当前测试数"。
  - 同时把当前结构事实固定为：主插件三模块、`README.md = NULL`、无 `.github/workflows/`、`DocsURL/SupportURL` 为空、当前脚本样例 27 个（`Script/Examples/` 按 Core/EnhancedInput/Extended 分组）、Hazelight 样例 26 个、当前 `Bind_*.cpp` 数量 124、Disabled 测试仅剩 2 个（`#ue57-headless`）。
  - 这一步只做口径冻结与索引同步，不在同一任务里顺手实施功能修复，避免再次把 status 文档和 feature 实施混成一个阶段。
- [ ] **P0.1** 📦 Git 提交：`[Docs/Roadmap] Docs: freeze current status baseline and evidence anchors`

- [ ] **P0.2** 固定问题 owner 与 sibling plan 路由
  - 已知 live failures 统一进入 `Plan_KnownTestFailureFixes.md`，zero/weak coverage 进入 `Plan_TestCoverageExpansion.md`，硬化缺口进入 `Plan_PluginEngineeringHardening.md`，Hazelight parity 继续由 `Plan_HazelightCapabilityGap.md` 与具体能力 plan 承接。
  - 把 `WorldSubsystem/GameInstanceSubsystem` 明确标记为"当前功能闭环缺口"，不要再与普通弱覆盖或文档缺口混写。
  - 目标是让后续执行者看到本计划时，可以直接知道下一步该去哪份 sibling plan，而不是重新做一次归类。
- [ ] **P0.2** 📦 Git 提交：`[Docs/Roadmap] Chore: route roadmap items to sibling plans and owners`

### Phase 1：优先收口真正阻塞当前可信度和可用性的事项

> 目标：先解决"当前明知没闭环/没收口"的问题，而不是急着继续扩新功能面。

- [ ] **P1.1** 清掉当前 live full-suite 失败并稳定 negative-test 边界
  - 先按 `Plan_KnownTestFailureFixes.md` 收口当前 `443/436/7` 中的失败项，特别是 hot-reload 输入路径、source navigation 产物路径和 script example 模块冲突等历史遗留问题。
  - 同时把"故意保留的负例边界"和"应当通过但仍失败"的测试继续拆开维护，避免未来又把 subsystem 负例、2.33 负例和真实回归失败混成一组。
  - 若某项失败与当前计划主线无关，也必须显式标注"不阻塞本阶段 closeout"的理由，而不是留成模糊状态。
- [ ] **P1.1** 📦 Git 提交：`[Test/Roadmap] Test: close live failures and preserve negative-test boundaries`

- [x] **P1.2** 把 Script Subsystem 从"有类型"推进到"有闭环"
  - `UScriptWorldSubsystem` 与 `UScriptGameInstanceSubsystem` 已通过 `Plan_FunctionalGapClosure.md` Phase 2 完成修复（2026-04-22）：根因是测试使用 `SoftReloadOnly` 编译全新类，改为 `FullReload` 后编译通过。四个场景测试已从负例转为正例，验证 UClass 物化和基类继承。
  - `UScriptLocalPlayerSubsystem` 与 `UScriptEngineSubsystem` 仍待补足场景验证，不阻塞本阶段。

- [ ] **P1.3** 补齐插件对外交付基线
  - 以 `Plan_PluginEngineeringHardening.md` 为主线，优先补 `README.md`、`BuildPlugin`、CI workflow、兼容矩阵、发布说明、安全/贡献入口和 `.uplugin` 对外字段。
  - 这一步的价值不是"文档好看"，而是把仓库从"内部继续研发工程"推进到"外部可消费的插件工程"，因此优先级高于大多数新的 2.38 特性移植。
  - 所有支持声明都必须绑定已有构建/测试/打包证据，不允许把"希望支持"写成"当前已支持"。
- [ ] **P1.3** 📦 Git 提交：`[Docs/Hardening] Docs: land plugin delivery baseline and support contract`

### Phase 2：补齐 Hazelight 最可见的上手与工作流差距

> 目标：先把"别人看得见、用得着、上手就会碰到"的差距补起来，让当前插件不仅能研发，也能被更低成本地理解和试用。

- [ ] **P2.1** 建立插件级 `Script-Examples` 基线
  - 以 Hazelight `Script-Examples/` 的目录分组为参考，先挑最有代表性的 10~15 个主题建立本仓库的最小示例集，优先覆盖 Actor、Component、Delegate、Subsystem、GAS、EnhancedInput、Editor 扩展。
  - 这一步不是把测试脚本复制成示例，而是把"可学、可跑、可迁移"的脚本入口独立出来；当前 `Script/Example_Actor.as` 只能算起点，不能承担完整 examples 职责。
  - 同时把 Hazelight `Script-Examples/README.md` 那种"复制到项目 `Script/` 目录即可使用"的最小消费路径也同步补上，避免示例存在但依然缺少进入姿势。
  - 示例一旦进入仓库，就必须挂接到 README / Test / Release 指引，而不是继续藏在零散目录里。
- [ ] **P2.1** 📦 Git 提交：`[Examples/Roadmap] Feat: establish plugin script examples baseline`

- [ ] **P2.2** 补齐 VS Code / Debug / API 工作流入口
  - 当前 `DebugServer` 与 Source Navigation 底座已存在，但用户层面仍缺少"怎么接 VS Code、怎么发现脚本 API、怎么做基本调试"的入口文档和最小工作流。
  - 这一步的口径应至少对齐 Hazelight 官网公开承诺的最小集合：VS Code 扩展接入、保存后编译/重载路径、基本调试能力、脚本 API 参考入口、常见限制与排障路径。
  - 先补使用路径、workspace 约定、debugger 入口、常见故障排查，再决定是否追加独立的 DAP / IntelliSense / API-doc 自动生成计划。
  - 这一步优先提升"能力可见性"，不把 scope 扩展成新的 IDE 平台开发项目。
- [ ] **P2.2** 📦 Git 提交：`[Docs/Workflow] Docs: publish script debugging and IDE workflow entrypoints`

- [ ] **P2.3** 收口脚本 API 可见性与控制台工作流差距
  - `global variable` 与 `FConsoleVariable` 已不再属于"完全缺失"状态；本阶段重点转为 `FConsoleCommand`、控制台工作流可见性、脚本 API 索引入口以及更可读的使用导航。
  - 对 GAS / EnhancedInput，则优先补"用户怎么用得顺手"的 helper / mixin / guide，而不是急着讨论是否把它们拆成独立插件；当前差距主要是脚本侧 helper surface 不够厚，而不是底层完全没有接入。
  - 如果要新增 API 文档生成或 CSV 导出，应把产物直接挂接到 README / guides，而不是只生成一次性内部工具输出。
  - 这一步以"减少对隐性知识的依赖"为目标，而不是单纯增加更多 bind 文件数量。
- [ ] **P2.3** 📦 Git 提交：`[Docs/API] Docs: improve script API and console workflow visibility`

### Phase 3：再推进真正会影响能力边界的 parity 与验证闭环

> 目标：在基础可信度、交付基线和上手入口稳定后，再补齐那些确实影响功能对齐的主题能力。

- [x] **P3.1** 建立 Network / RPC / PushModel 的专题验证闭环
  - 标准 UE RPC（Server/Client/NetMulticast）和属性复制（Replicated/ReplicatedUsing/ReplicationCondition）已通过 `Plan_FunctionalGapClosure.md` Phase 3 建立编译正例测试（2026-04-22），覆盖 FUNC_Net*/CPF_Net 标志验证。
  - WithValidation 和 Unreliable 组合也已有编译测试覆盖。
  - Push Model Replication 确认依赖引擎侧（Hazelight `ASClass.cpp` 中的 `PushModelReplicatedProperties`），不在插件内收口范围。
  - 完整多人网络栈运行时调度测试（跨进程 client/server）仍待后续推进。

- [ ] **P3.2** 完成 GAS / EnhancedInput 的专项验证与边界决策
  - 当前主插件已经集成 GAS / EnhancedInput 依赖，但这不等于工作流已经对齐 Hazelight；需要补齐专项测试、示例与文档，先确保"并入主插件"的当前策略有完整证据支撑。
  - 只有当当前 bundled 模式已经被验证稳定之后，才进入"是否拆成独立插件"的结构性决策；不要把结构美观优先级排在验证闭环前面。
  - 相关工作继续挂接到 `Plan_TestCoverageExpansion.md`、建议新增的 `Plan_GASIntegrationTests` 与 EnhancedInput sibling plan。
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptTest] Test: validate GAS and enhanced input parity paths`

- [ ] **P3.3** 跑完 Bind 审计与 Hazelight delta 收口
  - 继续依赖 `BindGapAuditMatrix.md`、`Plan_HazelightBindModuleMigration.md` 与 `Plan_UEBindGapRoadmap.md`，把"本地有意差异""无意遗漏""仅结构不同"三类项拆清楚。
  - 这一步的目标是减少未来长期维护中的"是不是漏绑了"不确定性，而不是为了追求 bind 数量看起来比 Hazelight 更多。
  - 若审计发现高频 gameplay 面的实用缺口，优先形成主题化 bind + 测试闭环，不要直接展开大而全搬运。
- [ ] **P3.3** 📦 Git 提交：`[AngelscriptRuntime] Refactor: audit and route bind deltas against Hazelight`

### Phase 4：最后再进入选择性 2.38 能力扩展与长期架构演进

> 目标：把"好做但不急""重要但不应先于交付/闭环"的事项放到后段，避免 roadmap 被长期技术兴趣牵着走。

- [ ] **P4.1** 继续按价值驱动推进 2.38 迁移
  - `foreach`、non-lambda 类型系统补齐、关键 bugfix cherry-pick、interface binding 等已有 sibling plan 保持独立推进，但排位必须服从前面三阶段已经建立的交付与可用性闸门。
  - 当某项 2.38 能力能直接减少脚本用户痛点时，才允许插队提升优先级；否则仍按既有 P2/P3/P4 排程推进。
  - 这一步仍坚持"选择性吸收"，不把当前 roadmap 重新改写成一次性整包升级。
- [ ] **P4.1** 📦 Git 提交：`[ThirdParty/AS238] Feat: advance selective 2.38 parity work after baseline gates`

- [ ] **P4.2** 推进长期架构收口而不是一次性重构冲动
  - `Plan_FullDeGlobalization.md`、`Plan_TestEngineIsolation.md`、`Plan_ThirdPartyModificationTracking` 等长期项继续推进，但只在前面阶段不再被当前阻塞项占满时进入主线。
  - 目标是降低维护成本、提高 future-port 能力，而不是在当前还有 README/CI/subsystem/examples 缺口时就启动大规模内部重写。
  - 任何这类长期项进入实施前，都必须能说明它解决了哪个仍在影响交付或稳定性的现实问题。
- [ ] **P4.2** 📦 Git 提交：`[Runtime/Architecture] Refactor: advance long-horizon maintainability work`

## 阶段依赖关系

```text
Phase 0（口径与 owner）
  -> Phase 1（已知阻塞项 + 交付基线）
    -> Phase 2（上手资产 + 工作流入口）
      -> Phase 3（功能 parity 与验证闭环）
        -> Phase 4（AS 2.38 选择性迁移 + 长期架构）
```

补充依赖：

- `P1.2` 必须在 `P0.2` 之后执行，否则 subsystem gap 仍会继续被写进错误 owner。
- `P2.1/P2.2/P2.3` 依赖 `P1.3` 的插件交付基线至少建立最小 README / guide / metadata 入口，否则 examples 与 workflow 仍然没有稳定挂点。
- `P3.2` 依赖 `P2.1` 的 examples 与 `P2.2` 的 workflow 先落最小入口，否则 GAS / EnhancedInput parity 仍难以对外证明。
- `P4.*` 默认不应抢在 `P1` 前执行，除非某项 2.38 或架构工作被证明直接解除当前主线 blocker。

## 验收标准

1. 仓库内存在一份单独 roadmap，能同时回答"现在完成到哪一步""相对 Hazelight 真正差在哪""下一步先做什么"。
2. 当前状态数字口径被明确固定，后续不再混用 `275/275`、`443/436/7` 和实时扫描规模。
3. 本计划能把当前主要事项明确路由到已有 sibling plan，而不是重新制造一份和现有计划并列但无 owner 的清单。
4. 近期优先级顺序明确体现为：**先现状与阻塞项 → 再交付基线 → 再 examples/workflow → 再 parity/迁移/架构**。
5. 文档中已显式区分：引擎侧差距、插件侧差距、工具链/上手差距、结构差异、非差距项。
6. 新进入仓库的人只看本计划和被引用的 sibling plan，就能快速知道下一阶段应该从哪里开始，而不是重新遍历几十份文档做二次整理。

## 风险与注意事项

### 风险

1. **继续用错基线排优先级**：如果后续任务仍然把不同测试数字当成一个数字，roadmap 很快又会失真。
   - **缓解**：所有 status/roadmap/closeout 文档都显式注明所用数字属于哪一类基线。

2. **被"更多 bind / 更多 2.38 特性"吸走优先级**：当前最容易让 roadmap 偏航的，就是继续优先做能力扩面，而不是先收口 README/CI/examples/subsystem 这些真实 blocker。
   - **缓解**：坚持先过 `P1` 与 `P2` 闸门，再进入大规模 parity/迁移扩面。

3. **把结构差异误判成功能缺失**：`Loader` 模块拆分、`AngelscriptGAS`/`AngelscriptEnhancedInput` 独立插件化，都很容易被误写成"必须立即补"的高优先级缺口。
   - **缓解**：所有这类事项先回答"当前 bundled 方案是否真的不能用"，若没有直接 blocker，就降级到后段结构决策。

4. **把引擎补丁项继续塞回插件计划**：Hazelight 基线存在引擎侧能力，如果不先承认边界，后续会持续出现"插件里为什么还没补完"的伪问题。
   - **缓解**：凡涉及 UHT、Blueprint 编译链、引擎对象生命周期钩子等主题，先回 `Plan_HazelightCapabilityGap.md` 判断是否属于引擎侧差距。

### 已知行为变化

1. **后续优先级口径将不再以"功能看起来最酷"为先，而以"当前是否阻塞插件可交付/可验证/可上手"为先。**
   - 影响文档：所有新增 roadmap、closeout 与 sibling plan 优先级说明。

2. **`WorldSubsystem` / `GameInstanceSubsystem` 已从显式 blocker 转为已闭环状态（2026-04-22）。**
   - 编译路径已修复（`SoftReloadOnly` → `FullReload`），四个场景测试已从负例转为正例。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptTest/Subsystem/AngelscriptSubsystemScenarioTests.cpp`、`Documents/Plans/Plan_FunctionalGapClosure.md`、`Documents/Plans/Plan_HazelightCapabilityGap.md`

3. **README / examples / workflow / compatibility 将前置到 parity 扩面之前。**
   - 影响计划：`Plan_PluginEngineeringHardening.md`、后续 examples/workflow/API 可见性相关 sibling plans。

