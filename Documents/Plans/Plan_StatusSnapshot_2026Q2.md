# 项目状态快照与任务路由（2026 Q2）

> **定位**：本文是对 `Plan_StatusPriorityRoadmap.md` 的**事实快照补充**，不引入新 roadmap。通过对 73 份 Plan + 代码事实的一次系统核对，给出：
> 1. 当前真实数字基线（替代 AGENTS.md 中已漂移的口径）
> 2. Plan 文档分类（已完成 / 进行中 / 未启动 / 已重叠 / 长期探索）
> 3. 真正的瓶颈与机会
> 4. 可立即执行的下一步任务清单（按 P0/P1/P2 排序）
>
> **读法**：
> - 要知道"整体状况"→ 读 §1
> - 要找"哪个 Plan 该做什么" → 读 §2 的分类表
> - 要"今天/本周开工" → 直接看 §4

---

## 1. 项目整体状态（事实摘要）

### 1.1 代码规模实测（2026-04-30 基线）

| 维度 | 实测值 | 文档中自称值 | 漂移 |
|------|-------|------------|-----|
| `Bind_*.cpp` 文件 | **124** | 124 | ✅ 一致 |
| AngelscriptTest `.cpp` 总数 | **405** | 429（AGENTS.md）| ⚠️ 轻微缩减 |
| AngelscriptTest 主题目录 | **24** | 28+ | ⚠️ 实际偏少 |
| Bindings 子主题 `.cpp` | **92** | — | — |
| Debugger 子主题 `.cpp` | **11** | — | — |
| HotReload 子主题 `.cpp` | **14** | — | — |
| StaticJIT 子主题 `.cpp` | **8** | 10 | ⚠️ 少 2 |
| Networking 子主题 `.cpp` | **1** | — | ⚠️ 薄弱点 |
| Editor 子主题 `.cpp` | **1** | 32 | ⚠️ **严重偏差**（AGENTS.md 称 32 指 Editor flag 测试，并非 `Editor/` 目录） |
| Learning 子主题 `.cpp` | **21**（Native 5 + Runtime 16） | — | — |
| Preprocessor 子主题 `.cpp` | **12** | — | — |
| `Source/AngelscriptProjectTest/` 测试 | **1** | 1 | ✅ |
| `Script/` 下 `.as` 文件 | **37** | 27 | ⚠️ 已增长但 AGENTS.md 未同步 |
| `Content/Test/` 下 `.umap` | **1** | 1 | ✅ |
| Disabled 测试数 | **2**（均 `#ue57-headless`）| 2 | ✅ |
| Plan 根目录 `.md` 数 | **73** | 62（OpportunityIndex）| ⚠️ **索引过期** |
| Plan Archives 数 | **7** | 7 | ✅ |

### 1.2 三类测试数字基线（防混用）

沿用 `Plan_StatusPriorityRoadmap.md` P0.1 约定的三套并行口径：

| 口径 | 数字 | 来源 |
|------|-----|------|
| **已编目基线** | `275/275 PASS` | `Documents/Guides/TestCatalog.md` |
| **Live full-suite 快照** | `443/436/7`（7 失败）| `Documents/Guides/TechnicalDebtInventory.md` |
| **源码扫描规模** | `405 cpp / 417+ 定义` | 实时扫描 |

> **禁止再把三者写成同一个数**。任何新 roadmap 都必须标注所用口径。

### 1.3 项目所处阶段

引用 AGENTS.md 的定义并与事实对齐：

- ✅ **核心运行时成熟**（124 Bind / 27 CSV Dump / DebugServer V2 / StaticJIT / CodeCoverage / BlueprintImpact Commandlet）
- ✅ **测试基础设施成熟**（CQTest 迁移完成 / TESTING_GUIDE.md 规范）
- ⚠️ **对外交付基线薄弱**（README=NULL / 无 CI workflow / `.uplugin` DocsURL 空）
- ⚠️ **关键能力未闭环**（网络多客户端 runtime 测试 / LocalPlayer+Engine Subsystem / GAS helper surface）
- ❌ **PIE 地图测试几乎为零**（仅 1 张测试地图 + 1 个用例）

---

## 2. Plan 分类盘点（73 份）

### A. 已完成 / 应归档（5 份，**立即移入 Archives**）

| Plan | 完成证据 | 建议 |
|------|---------|-----|
| `Plan_DisabledTestReenablement.md` | 文档头标 `✅ 已关闭（2026-04-21）`；剩余 2 个均 `#ue57-headless` 已知限制 | 移入 Archives |
| `Plan_FunctionLibrariesCleanup.md` | OpportunityIndex 标 `✅ 5 个 Phase 全部收口` | 移入 Archives |
| `Plan_ScriptExamplesExpansion.md` | 已落 28 个 `.as` 示例，超过 Hazelight 26 个基线 | 移入 Archives |
| `Plan_FullDeGlobalization.md` | 头部已明示"⚠️ 已被 `Plan_DeGlobalizationV2.md` 替代" | 移入 Archives 标 superseded |
| `Plan_TestEngineIsolation.md` | Phase 1 完成，Phase 2-4 已合并到 DeGlobalizationV2 | 移入 Archives 标 superseded |

### B. 已接近完成（4 份，**执行收尾后归档**）

| Plan | 剩余工作 | 估计工时 |
|------|---------|---------|
| `Plan_RemoveScenarioNaming.md` | Phase 1-4 完成，剩 Phase 5（文档同步） | 0.5d |
| `Plan_FunctionalGapClosure.md` | Phase 1-3 完成（2026-04-22）；剩 LocalPlayer / Engine Subsystem 场景验证 | 1d |
| `Plan_GlobalVariableAndCVarParity.md` | 大部分已落地，剩 FConsoleCommand workflow + 文档 | 1d |
| `Plan_ASSDKTestIntegration.md` | SDK 测试基础已完成，剩边角 bind 和说明文档 | 1d |

### C. 进行中（当前焦点，8 份）

| Plan | 当前状态 | 阻塞判定 |
|------|---------|---------|
| `Plan_StatusPriorityRoadmap.md` | P0.1/P0.2 未勾；P1.2/P3.1 已勾；其余 9 项待推进 | ✅ **全局入口，持续维护** |
| `Plan_OpportunityIndex.md` | 自报 62 份 vs 实际 73 份，数字基线过期 | ⚠️ **数字刷新** |
| `Plan_KnownTestFailureFixes.md` | 7 个 live failure 全未勾选 | 🔴 **承接 P1.1，P0 优先** |
| `Plan_PluginEngineeringHardening.md` | README/CI/uplugin 元数据全空 | 🔴 **承接 P1.3，P1 优先** |
| `Plan_TechnicalDebtRefresh.md` | 未开始 | ⚠️ **P1 闸门**，未做则后续数字不可信 |
| `Plan_TestSuiteAccumulationStability.md` | OpportunityIndex 标"执行中" | 持续推进 |
| `Plan_HazelightCapabilityGap.md` | Subsystem / 网络 RPC 已闭环；剩引擎侧 + GAS/EI parity | 长期维护 |
| `Plan_HazelightScriptFeatureParity.md` | 现状盘点为主，9 类特性大部分已支持，差测试覆盖 | **保留为参考** |

### D. 未启动但有价值（按 OpportunityIndex 优先级排序，15+ 份）

**P1 级**（应该尽快进入排期）：

| Plan | 主题 | 预期产出 |
|------|-----|---------|
| `Plan_AS238ForeachPort.md` | foreach 选择性回移 | AS 2.38 能力关键项 |
| `Plan_NetworkReplicationTests.md` | 网络复制专题测试 | StatusRoadmap P3.1 深化 |
| `Plan_ReferenceBasedTestExpansion.md` | 第一轮测试扩展（28 主题 / 49 用例）| 本轮刚完成规划 |
| `Plan_ReferenceBasedTestExpansion_Round2.md` | 第二轮（15 主题 / 52→219 用例）| 同上 |
| `Plan_PIEMapBasedTestExpansion.md` | PIE 地图测试（35→227 用例）| 同上 |
| `Plan_TestCoverageExpansion.md` | 覆盖率扩展 | 已有覆盖率基线 |

**P2 级**：

| Plan | 主题 |
|------|-----|
| `Plan_AS238BugfixCherryPick.md` | 关键 Bug 修复回移 |
| `Plan_AS238NonLambdaPort.md` | 非 Lambda 类型系统 |
| `Plan_DebugAdapter.md` | DAP 完整实现 |
| `Plan_CQTestFullMigration.md` | CQTest 全量迁移（部分完成） |
| `Plan_CppInterfaceBinding.md` | C++ 接口绑定增强 |
| `Plan_UhtArtifactExpansion.md` | UHT 产物扩展 |
| `Plan_ASBlueprintImpactScanCommandlet.md` | 蓝图影响扫描 |
| `Plan_StaticJITOfflineGeneration.md` | 离线 JIT 生成 |

**P3+ 级**：

| Plan | 主题 |
|------|-----|
| `Plan_AS238LambdaPort.md` | Lambda |
| `Plan_AS238JITv2Port.md` | JIT v2 |
| `Plan_AS238UsingNamespacePort.md` | using namespace |
| `Plan_AS238ComputedGotoPort.md` | computed goto |
| `Plan_AS238DefaultCopyPort.md` | default copy |
| `Plan_AS238MemberInitPort.md` | member init |
| `Plan_AS238BoolConversionPort.md` | bool 转换 |
| `Plan_DeGlobalizationV2.md` | 全去全局化 v2 |
| `Plan_UnrealCSharpArchitectureAbsorption.md` | UnrealCSharp 架构参考 |
| `Plan_AngelscriptModSupportExploration.md` | Mod 支持探索 |
| `Plan_StructUtilsMigration.md` | StructUtils 迁移 |
| `Plan_UnityBuildConflictResolution.md` | Unity 构建冲突 |

### E. 主题重叠 / 可 superseded（3 份）

| Plan | 重叠 | 建议 |
|------|-----|-----|
| `Plan_AngelscriptUnitTestExpansion.md` | 与 `Plan_TestCoverageExpansion.md` 大量重叠 | 合并或明确分工 |
| `Plan_ASInternalClassUnitTests.md` | 与 `Plan_NativeAngelScriptCoreTestRefactor.md` 重叠 | 评估合并 |
| `Plan_AngelscriptTestScenarioExpansion_Appendix.md` | 已被主 Plan 吸收 | 可移入 Archives |

### F. 长期探索（保留原位，低优先级）

- `Plan_AngelscriptResearchRoadmap.md` —— 研究路线图
- `Plan_ASClassLookupSemanticsAndAcceleration.md` —— 类查找加速
- `Plan_DetachedClassEagerCleanup.md` —— 分离类清理
- `Plan_BlueprintTypeBindingsOptimization.md` —— BP 类型绑定优化
- `Plan_ContainerToStringFormat.md` —— 容器格式化
- `Plan_AngelscriptLearningTraceTests.md` —— 学习追踪
- `Plan_AngelscriptEngineBindAndFileWatchValidation.md` —— Bind 审计
- `Plan_ManualBindCsvDump.md` —— 手工 CSV dump
- `Plan_MathScriptMixinReenablement.md` —— Math mixin
- `Plan_ContainerToStringFormat.md` —— 容器 ToString

---

## 3. 真正的瓶颈与机会

### 3.1 瓶颈 #1：对外交付基线缺失（P0 级阻塞）

**证据**：
- `README.md = NULL`（根 + Plugins 根）
- 无 `.github/workflows/`
- `Plugins/Angelscript/Angelscript.uplugin` 中 `DocsURL / MarketplaceURL / SupportURL` 均空

**影响**：仓库被定性为"内部研发中"，无法外部分享、无法对齐 Marketplace、CI 无法建立。

**对应 Plan**：`Plan_PluginEngineeringHardening.md`（P1.3）

### 3.2 瓶颈 #2：PIE 地图测试几乎为零

**证据**：
- 项目侧 `Source/AngelscriptProjectTest/Tests/` 仅 1 个测试
- `Content/Test/` 仅 1 张地图
- 插件已有完整 `FAngelscriptIntegrationTest` 框架但**无业务 AS 函数使用**
- `IntegrationTestMapRoot` ini 配置缺失

**影响**：运行时行为（网络复制、多客户端、地图切换、HotReload × PIE）完全未验证。

**对应 Plan**：`Plan_PIEMapBasedTestExpansion.md`（本轮刚完成规划，未实施）

### 3.3 瓶颈 #3：AGENTS.md / OpportunityIndex 数字基线过期

**证据**：
- AGENTS.md 称"28+ 主题目录"—— 实际 24
- AGENTS.md 称"429 test cpp"—— 实际 405
- AGENTS.md 称"27 .as"—— 实际 37
- OpportunityIndex 称"62 份 Plan"—— 实际 73

**影响**：`Plan_StatusPriorityRoadmap.md` P0.1 要求的"三套并行数字"前提被破坏，后续决策易基于错位数字。

**对应 Plan**：`Plan_TechnicalDebtRefresh.md`（基线刷新未启动）

### 3.4 瓶颈 #4：7 个 live test failure 未修

**证据**：
- `TechnicalDebtInventory.md`：`443/436/7`
- `Plan_KnownTestFailureFixes.md` 全部条目未勾选

**影响**：任何新测试增加都可能被误归因到这 7 个存量问题，套件可信度下降。

**对应 Plan**：`Plan_KnownTestFailureFixes.md`（P1.1）

### 3.5 机会 #1：本轮规划产出的 3 份测试扩展 Plan

三份新 Plan 共规划 **227 + 219 + 49 = 495 个细粒度测试用例 + 40+ 张新地图**：

- `Plan_ReferenceBasedTestExpansion.md`（28 主题 / 49 用例）—— 已有
- `Plan_ReferenceBasedTestExpansion_Round2.md`（15 主题 / 219 用例含变体）—— 本会话产出
- `Plan_PIEMapBasedTestExpansion.md`（12 主题 / 227 用例含变体 + 代码骨架 + CI 拓扑 + 5 月里程碑）—— 本会话产出

**机会**：规划很完整，但**未分发到 issue / 未分配 owner**。下一步最大价值动作是把它们拆成可执行任务。

### 3.6 机会 #2：Plan 索引治理

73 份 Plan 里 **5 份可立即归档 / 4 份近收尾 / 3 份主题重叠 / 12 份 P3+ 长期**，若不治理则新人进入仓库看到的是"60+ 份看似并行"的列表。

---

## 4. 推荐的下一步任务安排

> 所有任务都承接已有 Plan，不新增 roadmap 主线。每条标注：对应 Plan / 估计工时 / 联动项。

### 4.1 本周（P0，共 ~2 人日）

| # | 任务 | 对应 Plan | 工时 | 联动 |
|---|------|----------|-----|------|
| T1 | **刷新 AGENTS.md / OpportunityIndex 数字基线**（按 §1.1 表替换所有实测值） | `Plan_TechnicalDebtRefresh.md` | 0.5d | 同步 `Plan_StatusPriorityRoadmap.md` P0.1 |
| T2 | **归档 5 份已完成 Plan**（§2.A 列表）+ 更新 `Plan_OpportunityIndex.md` 数字 | `Plan_OpportunityIndex.md` | 0.5d | — |
| T3 | **把 3 份测试扩展 Plan 挂接到 `Plan_StatusPriorityRoadmap.md`** P1/P2 段落 | 三份 ReferenceBased / PIEMap | 0.5d | — |
| T4 | **修 7 个 live test failure** 的前 3 个（热重载输入路径 / source navigation / script example 模块冲突） | `Plan_KnownTestFailureFixes.md` | 0.5d | 其余 4 个进 T5 |

### 4.2 本月（P1，共 ~10 人日）

| # | 任务 | 对应 Plan | 工时 |
|---|------|----------|-----|
| T5 | **修剩余 4 个 live test failure** | `Plan_KnownTestFailureFixes.md` | 2d |
| T6 | **补齐插件交付基线**：根 README + `.uplugin` 元数据 + CI workflow 最小集（headless unit 测试） | `Plan_PluginEngineeringHardening.md` | 3d |
| T7 | **完成 `Plan_FunctionalGapClosure.md` 收尾**：LocalPlayer + Engine Subsystem 场景验证 | `Plan_FunctionalGapClosure.md` | 1d |
| T8 | **完成 `Plan_GlobalVariableAndCVarParity.md` 收尾**：FConsoleCommand workflow + 使用文档 | `Plan_GlobalVariableAndCVarParity.md` | 1d |
| T9 | **PIE 测试 M1-W1**（执行 `Plan_PIEMapBasedTestExpansion.md` 第一周）：4 张模板地图 + helper 落地 + 第一个参考测试 | `Plan_PIEMapBasedTestExpansion.md` §M1 | 3d |

### 4.3 Q2 剩余（P2，共 ~15 人日）

| # | 任务 | 对应 Plan | 工时 |
|---|------|----------|-----|
| T10 | **Script-Examples README + 入口文档** | `Plan_StatusPriorityRoadmap.md` P2.1 | 2d |
| T11 | **VS Code / DebugAdapter 入口文档** | `Plan_StatusPriorityRoadmap.md` P2.2 + `Plan_DebugAdapter.md` | 3d |
| T12 | **PIE 测试 M2**（清理 + 时序用例，44 用例） | `Plan_PIEMapBasedTestExpansion.md` §M2 | 5d |
| T13 | **Reference 测试 P0 批次**（access 进阶 / f-string 完整 / property 完整，14 用例） | `Plan_ReferenceBasedTestExpansion_Round2.md` W1 | 3d |
| T14 | **网络复制多客户端 runtime 测试**（PIE_ListenServer + 2 client） | `Plan_NetworkReplicationTests.md` + `Plan_PIEMapBasedTestExpansion.md` §4.3 | 2d |

### 4.4 Q3（P3，背景推进）

| # | 任务 | 对应 Plan |
|---|------|----------|
| T15 | `foreach` 2.38 回移 | `Plan_AS238ForeachPort.md` |
| T16 | 关键 Bugfix cherry-pick | `Plan_AS238BugfixCherryPick.md` |
| T17 | GAS / EnhancedInput helper surface 扩展 | `Plan_StatusPriorityRoadmap.md` P3.2 |
| T18 | Bind 审计收口 | `Plan_HazelightBindModuleMigration.md` + `Plan_UEBindGapRoadmap.md` |
| T19 | PIE 测试 M3–M5（错误恢复 / 网络拓扑 / 跨场景）| `Plan_PIEMapBasedTestExpansion.md` §M3-M5 |

---

## 5. 任务优先级依据（为什么是这个顺序）

沿用 `Plan_StatusPriorityRoadmap.md` 的闸门逻辑：

```
Phase 0（口径刷新 T1/T2）
  → Phase 1（live failure T4/T5 + 交付基线 T6）
    → Phase 2（上手资产 T9/T10/T11）
      → Phase 3（功能 parity T12/T13/T14 + GAS/EI T17）
        → Phase 4（2.38 迁移 T15/T16 + 架构）
```

**硬闸门**：
- T1/T2 不做 → 所有后续数字不可信
- T6 不做 → 仓库仍是"内部研发"不能对外
- T9/T10 不做 → PIE + Examples 基线未立，T12/T13/T14 无落地支点

**软闸门**：
- T3 是治理动作，不做也不阻塞，但强烈建议与 T1/T2 同步完成
- T17 (GAS helper) 依赖 T9 (PIE 模板)，因为 GAS 专项测试需要 PIE 地图

---

## 6. 本快照的后续维护

| 条件 | 动作 |
|------|-----|
| 每月第一周 | 重跑 §1.1 数字实测表 |
| 有 Plan 完成 | 移入 §2.A，更新 §4 任务表 |
| 新增 Plan | 先填 §2 分类表，避免 73 份变 80 份 |
| 每季度 | 刷新本快照为 `Plan_StatusSnapshot_<YYYY>Q<N>.md`（保留历史，不覆盖） |

---

## 7. 一句话总结

> 项目已从"搭插件"进入"收口交付"阶段。**73 份 Plan 里 5 份可立即归档 / 4 份近收尾 / 8 份在推进 / 剩余按 P1→P3 排队**。当前真正阻塞不是"还差什么能力"，而是 **①README/CI/uplugin 元数据对外基线 ②7 个 live failure ③PIE 地图测试从零起步 ④ AGENTS.md 数字基线刷新**。本快照列出 19 条可执行任务（T1–T19）按 P0/P1/P2/P3 排好，直接承接已有 Plan，不引入新 roadmap 主线——执行者拿 T1–T4 这周即可开工。
