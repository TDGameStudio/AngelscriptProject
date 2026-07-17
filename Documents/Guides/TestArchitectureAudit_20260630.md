# AngelscriptTest 模块架构问题盘点 — 2026/06/30

## 0. 元数据

- **日期**：2026/06/30
- **范围**：`Plugins/Angelscript/Source/AngelscriptTest/` 全模块、相关运行器脚本（`Tools/RunTests*.ps1`、`Tools/Shared/TestSuiteDefinitions.ps1`）、相关测试文档（`Documents/Guides/Test*.md`、`Documents/Knowledges/ZH/Test_*.md`）以及进行中的 OpenSpec 变更 `test-coverage-matrix-consolidation`。
- **方法**：派发 5 个并行只读调查 agent，分别从「目录结构」「框架与宏」「构建与运行器」「已记录债务」「Coverage 矩阵」五个维度独立调查后做交叉印证。本盘点不修改任何源代码。
- **基线**：430 测试 `.cpp` 文件 / 1518+ 自动化测试定义 / 28+ 主题目录 / 21 个模块依赖（公共 8 + 私有 6 + 编辑器条件 7）/ 仅 2 个 `#ue57-headless` Disabled 测试。
- **目的**：把分散在多份文档与源码中的架构层债务汇总到单一索引；不给改进建议，仅描述现状。改进路径走 OpenSpec 单独立项。

## 1. 调查范围与边界

本盘点**只**关注架构层问题（模块边界、抽象层、命名/分类体系、全局状态、运行成本），不重复列举：

- 单个测试用例失败（属 `TechnicalDebtInventory.md §17` 范畴）。
- 单个 binding gap（属 `TestFixSummary_20260430.md` "绑定缺口" 表）。
- 文档措辞、链接修复等细节。

## 2. 问题地图（按架构层切分）

### A. 目录与主题分类层

| 编号 | 问题 | 证据 |
|------|------|------|
| A1 | **极端文件分布失衡** | `Coverage/` 90 文件 vs `Networking/` 1 文件，前 3 目录吃掉 59% 文件；`GC/`、`Memory/`、`Delegate/`、`Editor/` 各 1–2 文件接近失活。 |
| A2 | **主题越界 / 跨目录重叠** | `AngelScriptSDK/` 76 文件中混入 Compiler/Parser/Tokenizer 测试，与 `Compiler/`、`Syntax/` 职责并行；矩阵层面 `FVector` 同时出现在 02-math-structs / 03-containers / 05-uclass 三份矩阵，未划定边界；UINTERFACE 在 `07-macros-enum-function-interface.md` 与 `Note_InterfaceBinding.md` 用两套不兼容模型描述。 |
| A3 | **`Functional/` 空目录、`Template/` 不是测试** | `Functional/` 无 `.cpp` 文件；`Template/` 9 个文件文件头注释 "Teaching template"，本质是教学示例，却与测试目录并列。 |
| A4 | **物理目录 ↔ 逻辑主题是 N:M 映射且未归一化** | `Documents/Knowledges/ZH/Test_TopicClusters.md §一` 自陈"四轴正交切片，但簇可同时落在两个轴上"，落点决策依赖 §八 决策表而非确定性规则。 |
| A5 | **测试数字基线长期漂移** | Catalog 基线 275/275 vs 源码扫描 1518+ 定义/430 文件 vs SDK prefix 301/301，`Documents/Guides/TechnicalDebtInventory.md §1 (L9-14)` 自陈"三组口径不得互相替代"但未关闭。 |

### B. 测试框架 / 抽象层

| 编号 | 问题 | 证据 |
|------|------|------|
| B1 | **4 套并行命名空间** | `Shared/AngelscriptTestExecute.h`（1265 行）同时维护 `AngelscriptTestSupport`（Phase 1 旧版，3 函数）/ `AngelscriptTest`（Phase 3 新版，强制使用）/ `AngelscriptReflectiveAccess`（Phase 2/3 兼容）/ `AngelscriptTestBindings`（Phase 2/3 兼容，9 个 `ExpectGlobal*` 别名）。 |
| B2 | **新旧宏体系并存** | 历史 `ANGELSCRIPT_TEST` / `ANGELSCRIPT_ISOLATED_TEST` 与当前 `ASTEST_*` 共存（`Documents/Guides/TestMacroStatus.md §2`）；`SHARE` / `SHARE_CLEAN` / `SHARE_FRESH` 三层 helper 语义易混。 |
| B3 | **抽象级别两极分化** | 仅 7 个 `ASTEST_*` 宏；`BEFORE_ALL { ASTEST_CREATE_ENGINE(); }` + `AFTER_ALL { ASTEST_RESET_ENGINE(...); }` 样板在 86+ 文件中字面重复，未做模板化收敛。 |
| B4 | **`Shared/` 是杂物间** | 30 文件无层级混合：执行工具（`AngelscriptTestEnginePool.h`、`AngelscriptTestEngineHelper.h`）、Fixture（`AngelscriptDebuggerScriptFixture.*`、`AngelscriptTestWorld.h`）、Mock（`AngelscriptMockDebugServer.h`）、探针（`AngelscriptTestMemoryProbe.h`、`AngelscriptConstructionContextProbe.h`）、领域类型（`AngelscriptNativeInterfaceTestTypes.*`），甚至混入了独立测试用例（`AngelscriptBindingsExampleSection*`、`AngelscriptTestEngineHelperTests.cpp`）。 |
| B5 | **Include 链 4+ 层** | `AngelscriptTestModuleScope.h` → `AngelscriptTestUtilities.h`（umbrella，含 8+ header）→ `AngelscriptTestExecute.h`（44 KB）→ 底层工具；曾尝试拆 umbrella 又被 `TestExecute.h` 强行收回。 |
| B6 | **AS 内联格式化规则形同虚设** | `Documents/Rules/ASInlineFormattingRule.md` 589 行规范，实际仅 `AngelscriptOptionalBindingsTests.cpp` 一个文件使用 `ASTEST_AS()` 7 次；`ASTEST_AS_ANSI()` 在 Bindings 测试中 0 调用；AngelScriptSDK 测试完全绕过规则使用裸 `R"AS(...)"` 或 `std::string` 拼接。 |

### C. 构建 / 运行器 / 模块边界

| 编号 | 问题 | 证据 |
|------|------|------|
| C1 | **测试模块依赖肿胀** | `AngelscriptTest.Build.cs` 公共 8（含 GameplayTags、Json、JsonUtilities、PropertyBindingUtils）+ 私有 6（含 Slate、SlateCore、UMG）+ 编辑器条件 7（含 BlueprintGraph、CQTest、LevelEditor、Networking、Sockets、UnrealEd、AngelscriptEditor）= 21 个模块依赖。 |
| C2 | **入口模块带运行期副作用** | `AngelscriptTestModule.cpp:17` 全局 `TUniquePtr<FAngelscriptEngine> GAngelscriptTestStartupOverrideEngine`；`StartupModule()` 通过 `UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting()` 改动引擎子系统初始化路径；模块加载即调用 `StartupTestEnginePool(bPrewarmEngine)` 触发引擎预热。 |

> **后续状态（2026-07-17）**：C2 中“Test 改写生产 Subsystem 初始化路径”的部分已关闭。`AngelscriptTestModule` 只负责可选的 TestEnginePool 预热；scan-free engine 由 CQTest fixture 按用例创建，Subsystem 不再暴露测试注入接口。
| C3 | **3 套测试 prefix 边界混淆** | `Angelscript.TestModule.*` / `Angelscript.CppTests.*` / `Angelscript.Editor.*` 三套并存；`HotReload` 等 editor-only 主题挂在 `TestModule.*` 下；`Tools/Shared/TestSuiteDefinitions.ps1:39,54` 中 `Editor` 同时作为 `Angelscript.Editor.*` 与 `Angelscript.TestModule.Editor.*` 出现。 |
| C4 | **运行器缺少环境能力声明** | `Tools/Shared/TestSuiteDefinitions.ps1` 硬编码 37 个 suite 定义，无字段表达"需 editor / 需 PIE / 可 headless"；当前 2 个 `#ue57-headless` Disabled 测试（`SourceNavigationTests.cpp:102`、`AngelscriptTestEngineHelperTests.cpp:1024`）的环境约束信息只能埋在源码注释。 |

### D. 全局状态与运行成本

| 编号 | 问题 | 证据 |
|------|------|------|
| D1 | **全局引擎污染链未断绝** | `FAngelscriptEngine::Get()` + `CurrentWorldContext` 跨 57 文件 / 325 处使用（`Documents/Guides/TechnicalDebtInventory.md §5 L66-80`），containment 现状仅"足以稳定 full-suite"，未实现真正去全局化。 |
| D2 | **200+ 引擎周期 × 800MB 瞬时分配** | `Documents/Guides/ASTestSuiteMemoryPeakRootCause.md §三 L187-213、§四 L236-318` 已确认每测试新建 `FAngelscriptEngine` + 完整 bind 是内存峰值根因，仅 GAS Functional 子树试点（87 binds → 1 bind），Debugger（31 binds）、Performance（13 binds）等仍保留原模式。 |
| D3 | **Helper 命名与实际行为不符** | `GetOrCreateSharedCloneEngine()` 实际产出的是 shared **Full** engine 而非 clone（`Documents/Guides/TechnicalDebtInventory.md §2 L33-51`）。 |

### E. 已识别但未关闭的能力缺口

| 编号 | 问题 | 证据 |
|------|------|------|
| E1 | **Preprocessor 不完整** | import 语句解析/移除未实现，文件发现行为与预期不符，3 个测试失败（`TechnicalDebtInventory.md §17 L278-287`）。 |
| E2 | **Testing-Full Engine 元数据空** | `CreateTestingFullEngine()` 的 `InitializeForTesting()` 仅做最小初始化、不执行完整绑定，导致 `FAngelscriptTypeDatabase` 为空，3 个测试失败（`TechnicalDebtInventory.md §17 L259-268`）。 |
| E3 | **15 个 `TODO(binding-gap)` 跳过** | 例如 `FBox::IsValid`、`FPlane(FVector, float)` 构造、`NumberOfCores()` 等绑定缺失（`Documents/Guides/TestFixSummary_20260430.md §⏸️ 绑定缺口 L31-51`），绑定补完后去掉 `#if 0` 即可恢复。 |
| E4 | **容器类型参数覆盖分裂** | OpenSpec `test-coverage-matrix-consolidation` 的 `coverage-gaps.md` `G5`（TArray 越界访问语义）、`G6`（TMap 异构 USTRUCT 值）显示标量容器与结构体容器测试路径未统一。 |

## 3. 三个最值得首先动刀的根问题

按"先动它能解锁多少其它清理"的逻辑排序：

1. **抽象层（B1 + B2 + D3）—— 4 套命名 + 新旧宏 + 名实不符 helper**
   后续任何目录/分类调整都会被这套抽象拖累；不先收敛，A 段整理会持续被旧入口绑回原状态。

2. **分类体系（A1 + A2 + A4 + A5）—— 物理目录 ↔ 逻辑主题 N:M 漂移**
   Catalog / 源码 / 矩阵三套口径互不对齐，本质是缺**确定性映射规则**而不是缺文档。OpenSpec `test-coverage-matrix-consolidation` 是修这个的现成入口。

3. **运行模型（C2 + D1 + D2）—— 测试模块入口 + 全局引擎 + 200+ 周期内存**
   把所有架构问题焊死在原模式上的力学根源；不解决，B/A 的整理都会被力学拖回退。

## 4. 与现有文档的关系

- 与 `Documents/Guides/TechnicalDebtInventory.md` 的关系：本盘点是 TDI 的**架构切片视图**。TDI 按编号编排所有债务（含失败用例、binding gap），本盘点只抽取其中"架构层"条目，并补充 Build/Module/Macro/Naming 维度 TDI 未覆盖的内容。
- 与 `Documents/Guides/TestMacroStatus.md` 的关系：本盘点 §B1–B3 引用 TestMacroStatus 中关于宏迁移的描述，并把它放在更广的抽象层语境中。
- 与 OpenSpec `test-coverage-matrix-consolidation` 的关系：A4 / A5 / E4 是该变更目标范围；该变更在 proposal.md L9-11 已宣告"从规划文档驱动 → 测试代码权威驱动"的根本性假设修正。
- 与 `Documents/Knowledges/ZH/Test_Layering.md`、`Test_TopicClusters.md` 的关系：A4 直接来源于这两份文档自陈的"四轴可重叠"观察。

## 5. 下一步可选项

不强制顺序，留给后续 OpenSpec 立项或路线图阶段决策：

- 写一份针对 §3.1（抽象层收敛）的 OpenSpec change proposal。
- 把 §A 的 5 条问题映射到 `test-coverage-matrix-consolidation` 已有任务，看哪些已落入它的范围、哪些需要新立。
- 围绕 §3.3 评估"测试模块入口 + 引擎池"重设计的可行性（成本与现有 200+ 周期模式的迁移路径）。
- 把本盘点编号（A1–E4）回写到 `TechnicalDebtInventory.md`，用作架构层债务的稳定锚点。

## 6. 修订记录

- 2026/06/30：基于 5 个并行调查 agent 的交叉印证创建初版。
