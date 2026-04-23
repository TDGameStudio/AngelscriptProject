# Angelscript 插件机会全景索引

本文档是对当前 Angelscript 插件所有可执行方向的系统性盘点，涵盖 AS 2.38 合入、测试增强、缺陷重构、功能增强、工具链与架构演进六大类。每个条目标注优先级、已有 Plan 状态与建议动作。

**编制时间**：2026-04-05（数字基线更新于 2026-04-23 `bf99c93`）
**当前基线**：AS 2.33.0 WIP，文档化 C++ 基线为 `275/275 PASS`，当前 live automation / full-suite 状态以测试增强章节、`Documents/Guides/TestCatalog.md` 与 `Documents/Guides/TechnicalDebtInventory.md` 为准；当前可直接统计到 `124` 个 `Bind_*.cpp`、`417+` 个自动化测试定义（覆盖 `429` 个测试 .cpp 文件）、`27` 个脚本示例（`Script/Examples/`）。仅剩 `2` 个 Disabled 测试（均为 `#ue57-headless` 已知限制）。新增总览入口 `Plan_StatusPriorityRoadmap.md`，用于统一维护当前完成现状、Hazelight 差距与后续优先级。`Documents/Plans/` 根目录当前可见 `52` 份 `Plan_*.md`（含 `50` 份执行 Plan、`1` 份状态总览 Plan 和 `1` 份索引文档）；`Plan.md` 作为编写规则文档单独保留，`Archives/` 下另有 `7` 份已归档 Plan。
**Plan 状态快照**：50 份执行 Plan、1 份状态总览 Plan（`Plan_StatusPriorityRoadmap.md`）、1 份索引文档（`Plan_OpportunityIndex.md`）、1 份编写规则文档（`Plan.md`）、7 份已归档完成 Plan

---

## 一、AS 2.38 选择性合入

> 当前版本 2.33.0 WIP。2.38 跨 5 年积累了大量语言能力、性能改进和 Bug 修复。整体升级风险大、收益分散，策略是按需选择性回移。

### 1.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 | 优先级 |
|---|------|-----------|------|--------|
| A | 函数模板（`asFUNC_TEMPLATE`） | `Plan_FunctionTemplate.md` | 未开始 | P2 |
| B | Lambda / 匿名函数 | `Plan_AS238LambdaPort.md` | 未开始 | P3 |
| C | 非 Lambda 类型系统（TOptional/UStruct/BlueprintType） | `Plan_AS238NonLambdaPort.md` | 未开始 | P2 |

### 1.2 已创建 Plan（原为新建议，现已有独立文档）

| # | 方向 | Plan 文档 | 状态 | 优先级 |
|---|------|-----------|------|--------|
| D | foreach 语法（含评估 + 对齐） | `Plan_AS238ForeachPort.md` | 未开始 | **P1** |
| E | using namespace | `Plan_AS238UsingNamespacePort.md` | 未开始 | P3 |
| F | 上下文 bool 转换 | `Plan_AS238BoolConversionPort.md` | 未开始 | P3 |
| G | 默认拷贝语义 | `Plan_AS238DefaultCopyPort.md` | 未开始 | P3 |
| H | 成员初始化模式 | `Plan_AS238MemberInitPort.md` | 未开始 | P4 |
| I | 关键 Bug 修复回移（Sprint A-D） | `Plan_AS238BugfixCherryPick.md` | 未开始 | **P2** |
| J | JIT v2 接口 | `Plan_AS238JITv2Port.md` | 未开始 | P3 |
| K | Computed goto 运行时优化 | `Plan_AS238ComputedGotoPort.md` | 未开始 | P4 |

---

## 二、测试增强

> 当前 417+ 个自动化测试定义（429 个测试 `.cpp` 文件），覆盖了引擎核心、语言行为、绑定、场景集成等；其中 `275/275` 表示文档化 C++ 基线，live suite / known failures 由 `TechnicalDebtInventory.md` 继续维护。仅剩 2 个 Disabled 测试（`#ue57-headless`）。但仍有多个功能域缺乏专项测试。

### 2.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 |
|---|------|-----------|------|
| A | 系统性补测（Bind/GAS/StaticJIT/Editor/Network） | `Plan_TestCoverageExpansion.md` | 未开始 |
| B | 测试分层/目录/命名整理 | `Plan_AngelscriptUnitTestExpansion.md` | 未开始 |
| C | 情景矩阵与模板 | `Plan_AngelscriptTestScenarioExpansion.md` | 未开始 |
| D | 内部类单元测试 | `Plan_ASInternalClassUnitTests.md` | 未开始 |
| E | SDK 上游测试桥接 | `Plan_ASSDKTestIntegration.md` | 部分完成，未归档（P0-P5 已落地，P3.2 因 fork 差异关闭，P6/P7 待收口） |
| F | Native 核心测试重构 | `Plan_NativeAngelScriptCoreTestRefactor.md` | 未开始 |
| G | Learning trace 教学测试 | `Plan_AngelscriptLearningTraceTests.md` | 部分完成，未归档（`P4.2` 已按现状关闭；`P5.2/P5.4/P5.8/P5.9/P6.4` 部分实现；`P5.7` 待补） |
| H | 调试器单元测试 | `Plan_ASDebuggerUnitTest.md` | 未开始 |
| I | Engine Bind 与 FileWatch 验证 | `Plan_AngelscriptEngineBindAndFileWatchValidation.md` | 未开始 |
| J | 网络复制与 RPC 验证闭环 | `Plan_NetworkReplicationTests.md` | 未开始 |
| K | Static JIT 单元测试 | `Plan_StaticJITUnitTests.md` | 未开始 |
| L | 测试模块规范化 | `Plan_TestModuleStandardization.md` | 部分完成 |
| M | 测试体系规范化 | `Plan_TestSystemNormalization.md` | 未开始 |
| N | 全局变量 / Console Variable 对齐与专项测试 | `Plan_GlobalVariableAndCVarParity.md` | 部分完成（`FConsoleVariable` bool/string + 首批 `Bindings` 测试已落地，`FConsoleCommand` 与剩余矩阵待收口） |
| O | Disabled 测试重新启用 | `Plan_DisabledTestReenablement.md` | 基本完成（仅剩 2 个 `#ue57-headless` Disabled 测试，其余已通过 UE 5.7 迁移修复批量重新启用） |

### 2.2 新建议 Plan

| # | 方向 | 价值说明 | 优先级 | 建议 Plan 名 |
|---|------|----------|--------|-------------|
| K | **GAS 集成测试** | 当前有 6 个 GAS 相关 Bind 文件（`Bind_FGameplayAttribute/Spec/EffectSpec`、`Bind_AngelscriptGASLibrary` 等）以及 `AngelscriptAbilitySystemComponent`、`AngelscriptAttributeSet` 等核心类，但 **AngelscriptTest 中零个 GAS 专项测试**。GAS 是项目额外新增的能力（UEAS2 没有），更需要验证。 | **P1** | `Plan_GASIntegrationTests` |
| L | **Enhanced Input 测试** | 3 个 Bind 文件（`Bind_FInputActionValue`、`Bind_FInputBindingHandle`、`Bind_UEnhancedInputComponent`）为 AngelPortV2 新增，无任何测试覆盖。Enhanced Input 是 UE5 的标准输入框架。 | **P2** | `Plan_EnhancedInputTests` |
| M | **Editor 功能测试扩展** | `Editor/` 目录仅 1 个文件（源码导航，83 行）。`AngelscriptEditor` 模块有代码着色、目录监视、编译通知、调试器集成等功能均未覆盖。 | P3 | `Plan_EditorFeatureTests` |
| N | **热重载稳健性测试** | 已有 5 个 HotReload 测试文件，但 `BurstChurnLatency` 测试已知失败（需 full reload 环境）。需补充边界场景：属性类型变更、函数签名变更、类层次变更等。 | P3 | `Plan_HotReloadRobustnessTests` |

---

## 三、缺陷修复与重构

> 基于对 Runtime 源码的 TODO/FIXME/HACK 扫描、代码结构分析和现有技术债记录。

### 3.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 |
|---|------|-----------|------|
| A | 技术债全景 | `Archives/Plan_TechnicalDebt.md` | 已归档（已完成） |
| B | Callfunc 死代码清理 | `Archives/Plan_CallfuncDeadCodeCleanup.md` | 已归档（已完成） |
| C | 去全局化 | `Plan_FullDeGlobalization.md` | 未开始 |
| D | 测试引擎隔离 | `Plan_TestEngineIsolation.md` | 部分完成 |
| E | 文件系统重构 | `Plan_ScriptFileSystemRefactor.md` | 未开始 |
| F | Hazelight Bind 模块迁移 | `Plan_HazelightBindModuleMigration.md` | 未开始 |
| G | 新一轮技术债刷新与分流 | `Plan_TechnicalDebtRefresh.md` | 未开始（先校准 debt baseline 与 owner，再进入下一批实施） |
| H | StructUtils 运行时边界迁移 | `Plan_StructUtilsMigration.md` | 未开始 |

### 3.2 新建议 Plan

| # | 方向 | 价值说明 | 优先级 | 建议 Plan 名 |
|---|------|----------|--------|-------------|
| G | **Bind 逐文件对齐审计** | UEAS2 有 114 个 `.cpp` Bind 文件，当前工程全部对应但内容可能漂移。需逐文件 diff 出行为差异，确认哪些是有意改动、哪些是无意遗漏。当前无系统性审计流程。 | **P2** | `Plan_BindFileAlignmentAudit` |
| H | **Runtime 观测代码分离** | `AngelscriptBindExecutionObservation.h` 等测试/观测代码当前混在 Runtime 模块中，与生产代码同编译。如果目标是"瘦 Runtime"，应将这些代码移入 `AngelscriptTest` 或用条件编译隔离。 | P3 | `Plan_RuntimeObservationSeparation` |
| I | **废弃 UE API 迁移** | `PrecompiledData.cpp` 使用 `FCrc::StrCrc_DEPRECATED`，`Bind_FName.cpp` 有 `Ugly hack` 绕过 `ComparisonIndex` 布局等。随 UE 版本演进，这些会逐步断编译。需系统扫描并迁移到推荐 API。 | P3 | `Plan_DeprecatedUEAPIMigration` |
| J | **大文件拆分** | 多个测试文件超过 500 行（`AngelscriptBlueprintSubclassRuntimeTests` 853 行、`AngelscriptInterfaceAdvancedTests` 782 行、`AngelscriptEngineParityTests` 697 行等），违反项目自身的 300-500 行规范。Runtime 侧 `AngelscriptEngine.cpp`、`AngelscriptType.cpp`、`AngelscriptPreprocessor.cpp` 也是超大文件。 | P3 | `Plan_LargeFileSplit` |
| K | **Bind Hack 清理** | 源码中标记了多个 HACK（`Bind_BlueprintEvent.cpp:805 "This is a hack!"`、`Bind_FName.cpp:83 "Ugly hack"`、`Bind_USceneComponent.cpp:172 "Small hack"` 等），部分与 UE API 限制相关，需评估是否有更正规的替代方案。 | P4 | `Plan_BindHackCleanup` |
| L | **Bind 分片收口（Batch F）** | `todo.md` 中 §3 Batch F 定义了 21 个任务（7.E.1–7.E.21）：审计 shard、迁入主模块、停 `BindModules.Cache`、删 `ASRuntimeBind_*` 等。这是影响面大的结构性变更，当前无独立 Plan 文档。 | **P1** | `Plan_BindShardConsolidation` |

---

## 四、功能增强

> 在当前已有能力之上的增量功能，提升脚本开发者体验或插件实用性。

### 4.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 |
|---|------|-----------|------|
| A | C++ UInterface 绑定 | `Plan_CppInterfaceBinding.md` | 未开始（P1 优先级） |
| B | 接口绑定总设计 | `Plan_InterfaceBinding.md` | 未开始（P1 优先级） |
| C | UHT Exporter 插件 | `Plan_UhtPlugin.md` | 未开始 |
| D | Bind 并行化 | `Plan_BindParallelization.md` | 分析完成，未实施 |
| E | 状态 Dump | `Archives/Plan_ASEngineStateDump.md` | 已归档（已完成） |
| F | Mod 支持探索 | `Plan_AngelscriptModSupportExploration.md` | 未开始 |
| G | UnrealCSharp 架构吸收 | `Plan_UnrealCSharpArchitectureAbsorption.md` | 未开始 |
| H | UFunction 反射回退绑定 | `Plan_UFunctionReflectiveFallbackBinding.md` | 未开始（P2 优先级） |

### 4.2 新建议 Plan

| # | 方向 | 价值说明 | 优先级 | 建议 Plan 名 |
|---|------|----------|--------|-------------|
| H | **脚本 API 文档自动生成** | 当前 148 个 Bind 文件暴露了大量 UE API 给脚本，但缺少面向脚本开发者的 API 参考文档。可以从 `RegisterObjectMethod` / `RegisterGlobalFunction` 等注册调用中自动提取函数签名、参数类型、所属类，生成可浏览的 HTML/Markdown 文档。参考 `AngelscriptDocs.cpp` 已有的框架。 | **P2** | `Plan_ScriptAPIDocGeneration` |
| I | **编译错误信息改善** | 脚本开发者最常接触的是编译错误。当前错误信息直接透出 AngelScript 引擎的内部描述，对不熟悉底层的用户不够友好。可以在预处理器/编译管线中增加更具指导性的错误消息（如"你是否忘了 import？"、"该类型需要 handle 语义"等）。 | P3 | `Plan_CompilerErrorImprovement` |
| J | **性能基准框架** | 当前有 `AngelscriptEnginePerformanceTests` 和 `PerformanceArtifactTests`，但缺少系统性基准：引擎启动时间、脚本编译吞吐、函数调用开销、GC 暂停时间等。需要可重复执行、结果可对比的框架，用于后续优化决策（如 AS 2.38 性能对比）。 | **P2** | `Plan_PerformanceBenchmarkFramework` |
| K | **脚本 IntelliSense / 补全数据导出** | 配合 `Plan_DebugAdapter.md` 的 VS Code 扩展，可以将注册的类型、函数、属性导出为 JSON/LSP 格式，为 IDE 补全和悬停提示提供数据。这是提升脚本开发者体验的关键一步。 | P3 | `Plan_ScriptIntelliSenseExport` |
| L | **脚本模块依赖可视化** | 基于 `FAngelscriptPreprocessor` 的模块发现与 import 关系，生成模块依赖图（可 dump 为 DOT/Mermaid）。帮助理解大型脚本项目的模块结构，也可用于检测循环依赖。 | P4 | `Plan_ModuleDependencyVisualization` |
| M | **脚本断言库增强** | 当前测试中大量使用 `TestEqual` / `TestTrue` 等 UE 自动化测试断言。为脚本侧提供更丰富的断言库（`ExpectThrows`、`ExpectCompileError`、结构化对比等），简化测试编写。 | P4 | `Plan_ScriptAssertionLibrary` |

---

## 五、工具链与开发体验

### 5.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 |
|---|------|-----------|------|
| A | DAP 调试适配器 | `Plan_DebugAdapter.md` | 未开始 |
| B | Hazelight 能力差距盘点 | `Plan_HazelightCapabilityGap.md` | 未开始 |
| C | 手动 Bind 函数与成员 CSV 导出 | `Plan_ManualBindCsvDump.md` | 未开始 |
| D | AS 变更蓝图影响扫描 Commandlet | `Plan_ASBlueprintImpactScanCommandlet.md` | 未开始 |
| E | Script 示例恢复与扩展 | `Plan_ScriptExamplesExpansion.md` | 基本完成（27 个 `.as` 示例已落入 `Script/Examples/`，按 Core/EnhancedInput/Extended 分组；首波 Coverage 真实资产、伴侣目录与 file-backed 综合测试已就位） |

### 5.2 新建议 Plan

| # | 方向 | 价值说明 | 优先级 | 建议 Plan 名 |
|---|------|----------|--------|-------------|
| C | **插件工程硬化基线** | 当前仓库已有测试、指南与计划底座，但仍缺顶层 README、`.uplugin` 对外元数据、`BuildPlugin` 打包入口、CI workflow、兼容矩阵、发布 / 安全 / 贡献入口等“可交付”闭环。需要一份总计划把这些 hardening 缺口收口为可验证基线。 | **P1** | `Plan_PluginEngineeringHardening` |
| D | **Bind 注册性能分析工具** | `Plan_BindParallelization.md` 提到需要先测量各 Bind 的注册耗时。可开发一个轻量 profiling 工具，在 `CallBinds` 过程中记录每个 Bind 函数的耗时，输出 CSV 排行榜。为后续优化提供数据基础。 | P3 | `Plan_BindRegistrationProfiler` |
| E | **脚本热重载体验优化** | 当前热重载的 `BurstChurnLatency` 测试已知失败。从用户体验角度，热重载应该：保留对象状态、增量编译仅变更模块、提供进度反馈、失败时回退到上一版本。 | P3 | `Plan_HotReloadUXImprovement` |

---

## 六、架构演进

> 长期方向，影响面大但对插件可维护性至关重要。

### 6.1 已有 Plan

| # | 方向 | Plan 文档 | 状态 |
|---|------|-----------|------|
| A | 去全局化 | `Plan_FullDeGlobalization.md` | 规划阶段 |
| B | 测试引擎隔离 | `Plan_TestEngineIsolation.md` | 部分完成 |
| C | 文件系统重构 | `Plan_ScriptFileSystemRefactor.md` | 未开始 |
| D | UnrealCSharp 架构吸收 | `Plan_UnrealCSharpArchitectureAbsorption.md` | 未开始 |
| E | 调研结论整合执行闸门 | `Plan_AngelscriptResearchRoadmap.md` | 未开始 |

### 6.2 新建议 Plan

| # | 方向 | 价值说明 | 优先级 | 建议 Plan 名 |
|---|------|----------|--------|-------------|
| E | **Bind 注册 API 统一化** | 当前 148 个 Bind 文件使用多种注册模式（`RegisterObjectMethod`、`METHODPR_TRIVIAL`、手写 lambda、`ERASE_METHOD_PTR` 等），风格不统一。统一为一套宏/模板框架，降低新 Bind 的编写门槛，减少 copy-paste 错误。 | P3 | `Plan_BindRegistrationUnification` |
| F | **AngelscriptEditor 模块化拆分** | `AngelscriptEditor` 当前是单一模块，包含代码着色、调试集成、目录监视、编译通知等。随功能增长，可考虑按职责拆分（如 `AngelscriptEditorDebug`、`AngelscriptEditorCodeAssist`），各自独立编译和测试。 | P4 | `Plan_EditorModuleSplit` |
| G | **ThirdParty AngelScript 修改追踪体系** | 当前靠 `//[UE++]` 注释和 `AngelscriptChange.md` 手动追踪。可建立自动化 diff 工具：将 ThirdParty 目录与官方 2.33 基线做 diff，自动生成修改清单，确保每次合入 2.38 功能时不遗漏已有修改。 | **P2** | `Plan_ThirdPartyModificationTracking` |

---

## 优先级总结

### 🔴 P1（高优先，近期应启动）

| # | 方向 | 类别 | 建议 Plan |
|---|------|------|-----------|
| 1 | foreach 语法支持 | AS 2.38 | `Plan_AS238ForeachPort` |
| 2 | GAS 集成测试 | 测试 | `Plan_GASIntegrationTests` |
| 3 | Bind 分片收口 | 重构 | `Plan_BindShardConsolidation` |
| 4 | 插件工程硬化基线 | 工具链 / 交付 | `Plan_PluginEngineeringHardening` |

> 注：C++ UInterface（已有 `Plan_CppInterfaceBinding.md`）和 Bind API GAP（已有 `Plan_AS238NonLambdaPort.md`）也是 P1，但已有完整 Plan 文档。
>
> 建议先完成 `Plan_TechnicalDebtRefresh.md` 的 baseline 校准与 owner 分流，再继续推进新的 P1 立项，避免继续基于过期的 active-plan 数、已知失败口径或 Hazelight parity 入口展开工作。

### 🟠 P2（重要，应在 P1 之后或并行推进）

| # | 方向 | 类别 | 建议 Plan |
|---|------|------|-----------|
| 5 | 关键 Bug 修复回移 | AS 2.38 | `Plan_AS238BugfixCherryPick` |
| 6 | Enhanced Input 测试 | 测试 | `Plan_EnhancedInputTests` |
| 7 | 网络复制专项测试 | 测试 | `Plan_NetworkReplicationTests` |
| 8 | StaticJIT 专项测试 | 测试 | `Plan_StaticJITUnitTests` |
| 9 | Bind 逐文件对齐审计 | 重构 | `Plan_BindFileAlignmentAudit` |
| 10 | 脚本 API 文档自动生成 | 功能 | `Plan_ScriptAPIDocGeneration` |
| 11 | 性能基准框架 | 功能 | `Plan_PerformanceBenchmarkFramework` |
| 12 | ThirdParty 修改追踪体系 | 架构 | `Plan_ThirdPartyModificationTracking` |
| 13 | StructUtils 运行时边界迁移 | 重构 | `Plan_StructUtilsMigration` |

### 🟡 P3（有价值，可根据需求插入）

| # | 方向 | 类别 |
|---|------|------|
| 13 | using namespace 支持 | AS 2.38 |
| 14 | 上下文 bool 转换 | AS 2.38 |
| 15 | 默认拷贝语义 | AS 2.38 |
| 16 | JIT v2 接口 | AS 2.38 |
| 17 | Editor 功能测试 | 测试 |
| 18 | 热重载稳健性测试 | 测试 |
| 19 | Runtime 观测代码分离 | 重构 |
| 20 | 废弃 UE API 迁移 | 重构 |
| 21 | 大文件拆分 | 重构 |
| 22 | 编译错误信息改善 | 功能 |
| 23 | IntelliSense 数据导出 | 功能 |
| 24 | Bind 注册 API 统一化 | 架构 |
| 25 | Bind 注册性能分析工具 | 工具链 |
| 26 | 热重载体验优化 | 工具链 |

### ⚪ P4（Backlog，需求驱动）

| # | 方向 | 类别 |
|---|------|------|
| 27 | Member init mode | AS 2.38 |
| 28 | Computed goto 优化 | AS 2.38 |
| 29 | Bind Hack 清理 | 重构 |
| 30 | 模块依赖可视化 | 功能 |
| 31 | 脚本断言库增强 | 功能 |
| 32 | AngelscriptEditor 模块化拆分 | 架构 |

---

## 推荐执行路径

```
当前 → UInterface 补齐 (已有 Plan)
     → Bind API GAP (已有 Plan)
     ↓
P1 批次 → 插件工程硬化基线 ← 先把仓库从“可研发”推进到“可交付”
        ↓
P1 批次 → foreach 语法 ← 脚本用户体验最大提升
        → GAS 集成测试 ← 验证 AngelPortV2 独有能力
        → Bind 分片收口 ← 结构性变更，越早做越好
      ↓
P2 批次 → Bug 修复回移 + ThirdParty 追踪体系 ← 安全网
        → Enhanced Input / Network / StaticJIT 测试 ← 补齐覆盖
        → 性能基准框架 ← 为后续 2.38 性能对比提供基线
        → API 文档生成 ← 降低脚本开发者门槛
      ↓
P3/P4 → 按需求穿插
```

---

## 已归档完成 Plan

| Plan | 归档日期 | 状态 | 摘要 |
| --- | --- | --- | --- |
| `Archives/Plan_AngelscriptTestExecutionInfrastructure.md` | 2026-04-04 | 已归档（已完成） | 已完成测试 group taxonomy、统一 runner、结构化摘要与执行文档收口，当前主干以 `Tools/RunTests.ps1` / `Tools/RunTestSuite.ps1` 作为正式入口。 |
| `Archives/Plan_BuildTestScriptStandardization.md` | 2026-04-04 | 已归档（已完成） | 已完成共享执行层、direct UBT 构建 runner、测试 runner、UBT 进程查询与 tooling smoke tests，后续 build/test 全部基于该脚本底座。 |
| `Archives/Plan_CallfuncDeadCodeCleanup.md` | 2026-04-04 | 已归档（已完成） | 已移除无效 `callfunc` `.lib` 引用并补充旧汇编路径的废弃说明，保留了后续 AS 2.38 合入时的兼容注意点。 |
| `Archives/Plan_ASEngineStateDump.md` | 2026-04-05 | 已归档（已完成） | 已完成 Runtime / Editor / Test 三侧状态 dump 导出链路、`as.DumpEngineState` 控制台命令、27 张 CSV 表与 `Angelscript.TestModule.Dump` 自动化回归，并在验证中补齐了 worktree 作用域 `TargetInfo.json` 预热收口。 |
| `Archives/Plan_TestMacroOptimization.md` | 2026-04-05 | 已归档（已完成） | 已完成 `ASTEST_BEGIN_* / ASTEST_END_*` 主迁移、`SHARE_CLEAN` / `SHARE_FRESH` 宏与验证测试补齐，并以标准脚本入口完成 build、关键前缀回归和 `AngelscriptFast` / `AngelscriptScenario` group 收口。 |
| `Archives/Plan_TechnicalDebt.md` | 2026-04-04 | 已归档（已完成） | 已完成 Phase 0-6 技术债收口，并将文档同步、sibling plan 分流与最终回归摘要沉淀到位。 |
| `Archives/Plan_UFunctionReflectiveFallbackBinding.md` | 2026-04-07 | 已归档（已完成） | 已完成 BlueprintCallable reflective fallback 后端、shared duplicate guard、三分类统计与 representative 正负例验证；收口阶段进一步把 shared reflective invocation helper 统一接入 Blueprint event / interface dispatch，并通过构建、native interface、GeneratedFunctionTable 前缀与完整 Bindings suite 回归。 |

---

## 与现有 Plan 的关系

- 本索引**不替代**活跃 Plan 与归档 Plan 文档，而是补充它们之间的空白。
- 标记为"已有 Plan"且状态为"已归档（已完成）"的条目无需继续推进；如需复盘，直接查阅 `Documents/Plans/Archives/` 中的原文与摘要。
- 标记为"已有 Plan"但尚未归档的条目不需要再创建新文档，只需按原 Plan 推进。
- 标记为"新建议 Plan"的条目，建议在决定启动时按 `Plan.md` 格式创建独立文档。
- 优先级标注基于当前项目状态（2026-04-04），应随进展调整。
