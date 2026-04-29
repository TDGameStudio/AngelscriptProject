# Agents_ZH.md

此文档需要同步到 AGENTS.md

## 目的

- 本文件用于指导在 `AngelscriptProject` 中工作的 AI Agent。
- 当前第一目标不是继续扩展一个普通游戏工程，而是把 `Plugins/Angelscript` 整理、验证并沉淀为可独立使用的插件版本 AS 插件。
- 当前仓库是插件开发与验证的承载工程；真正的主产物是 `Angelscript` 插件本身。

## 当前项目阶段

- 插件已经**不处于原型或底座搭建阶段**，而是进入了"核心运行时、编辑器集成、测试基础设施都已成型，但对外交付入口和若干关键能力闭环仍需收口"的成熟期。
- 当前基线：`AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` 三个 UE 模块已稳定，`123` 个 `Bind_*.cpp`、`27+` 张 CSV 状态导出表、`452+` 个自动化测试定义、`DebugServer V2` 协议、`CodeCoverage`、`StaticJIT`、`BlueprintImpact Commandlet` 均已落地；编辑器和 Commandlet 启动期初始化由 Runtime 内的原生 `UAngelscriptEngineSubsystem` 承接。
- AS 基线版本为 `2.33 + 选择性 2.38 兼容`，fork 已深度分叉，整体升级不可行，策略为从高版本选择性吸收改进。详见 `Documents/Guides/AngelscriptForkStrategy.md`。
- 近期优先级顺序：**已知阻塞项与交付基线 → 上手资产与工作流入口 → 功能 parity 与验证闭环 → AS 2.38 选择性迁移与长期架构**。详见 `Documents/Plans/Plan_StatusPriorityRoadmap.md`。

## 当前项目定位

- `Plugins/Angelscript/` 是核心工作区，绝大多数实现、修复、清理和测试都应优先落在这里。
- `Source/AngelscriptProject/` 仅保留宿主工程必须的最小内容，除非任务明确需要，不要把插件逻辑塞回项目模块。

## 关键路径

- `Plugins/Angelscript/Source/AngelscriptRuntime/`：运行时模块，插件核心能力优先落在这里。
  - `Core/`：引擎核心、绑定管理器、类型系统；`UAngelscriptEngineSubsystem` 负责 Editor/Commandlet 主启动初始化与无 GameInstance tick owner 时的主引擎 tick。
    - `Core/GAS/`：GAS（Gameplay Ability System）脚本化基类、组件、工具库（18 个文件）。
    - `Core/Commandlets/`：工具类 Commandlet 入口（4 个文件）。
  - `ClassGenerator/`：动态类生成、热重载、版本链。
  - `Binds/`：123 个 `Bind_*.cpp`，覆盖引擎 API 绑定面。
  - `Debugging/`：DebugServer V2 协议。
  - `StaticJIT/`：静态 JIT 编译支持。
  - `Dump/`：27+ 张 CSV 状态导出表，纯外部观察者架构。
  - `CodeCoverage/`：代码覆盖率追踪。
  - `FunctionLibraries/`：21+ 个脚本辅助函数库。
- `Plugins/Angelscript/Source/AngelscriptEditor/`：编辑器相关支持（菜单扩展、热重载 UI、BlueprintImpact Commandlet）。
- `Plugins/Angelscript/Source/AngelscriptTest/`：插件测试与验证（按 Actor/Bindings/Blueprint/Component/Debugger/HotReload/Subsystem 等主题组织）。
- `Plugins/Angelscript/Source/AngelscriptUHTTool/`：UHT 代码生成工具链。
- `Documents/Guides/`：构建、测试、查询指南（13 份）。
- `Documents/Rules/`：Git 提交等规则文档。
- `Documents/Plans/`：多阶段任务计划文档（47 份执行 Plan + 1 份状态总览 + 1 份索引 + 6 份已归档）。
- `Documents/Plans/Archives/`：已完成或已关闭 Plan 的归档目录与摘要。
- `Documents/Knowledges/`：33+ 份架构知识库文档。
- `Tools/`：本地辅助脚本 — 根目录运行器（`RunBuild.ps1`、`RunTests.ps1`、`RunTestSuite.ps1`、`RunAutomationTests.ps1`/`.bat`、`GetAutomationReportSummary.ps1`）、`Tools\Shared\UnrealCommandUtils.ps1`、集中测试在 `Tools\Tests\`；分组入口在 `Tools\Bootstrap\`（如 `BootstrapWorktree.bat`、`GenerateAgentConfigTemplate.bat`）、`Tools\PullReference\PullReference.bat`、`Tools\Diagnostics\`、`Tools\Review\`、`Tools\ReferenceComparison\`。
- `Script/`：Angelscript 示例脚本。
- `Reference/`：外部参考仓库（不提交，仅本地比对使用）。

## 外部参考仓库

- 外部参考仓库不属于当前项目提交内容，只用于对照、迁移分析和架构参考。
- 本节只保留索引信息；具体说明、用途边界、优先级判断统一维护在 `Reference/README.md`。

| 名称 | 入口与说明 |
| --- | --- |
| AngelScript v2.38.0 | 使用 `Tools\PullReference\PullReference.bat angelscript` 默认拉取到 `Reference\angelscript-v2.38.0`；详情见 `Reference/README.md` |
| Hazelight Angelscript | 通过 `AgentConfig.ini` 的 `References.HazelightAngelscriptEngineRoot` 获取；详情见 `Reference/README.md` |
| Hazelight Docs | 使用 `Tools\PullReference\PullReference.bat hazelightdocs` 默认拉取到 `Reference\Docs-UnrealEngine-Angelscript`；用于参考 Hazelight 公开文档站源码与内容组织；详情见 `Reference/README.md` |
| Hazelight VS Code Angelscript | 使用 `Tools\PullReference\PullReference.bat hazelightvscode` 默认拉取到 `Reference\vscode-unreal-angelscript`；用于参考 VS Code Language Server、Debug Adapter、错误展示与断点调试工作流；详情见 `Reference/README.md` |
| UnrealCSharp | 使用 `Tools\PullReference\PullReference.bat unrealcsharp` 默认拉取到 `Reference\UnrealCSharp`；详情见 `Reference/README.md` |
| Tencent UnLua | 使用 `Tools\PullReference\PullReference.bat unlua` 默认拉取到 `Reference\UnLua`；用于参考 Lua 反射接入、事件覆写与示例组织；详情见 `Reference/README.md` |
| Tencent puerts | 使用 `Tools\PullReference\PullReference.bat puerts` 默认拉取到 `Reference\puerts`；用于参考 TypeScript/JavaScript 脚本运行时与声明生成；详情见 `Reference/README.md` |
| Tencent sluaunreal | 使用 `Tools\PullReference\PullReference.bat sluaunreal` 默认拉取到 `Reference\sluaunreal`；用于参考 Lua 静态导出、性能取舍与热更新工作流；详情见 `Reference/README.md` |

- 后续新增参考仓库时，优先先更新 `Reference/README.md`，再回到本表补索引。

## 本地配置

- 项目根目录的 `AgentConfig.ini` 存放本机引擎路径等配置，已被 `.gitignore` 忽略。
- 首次使用运行 `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` 生成模板，再填入本机路径。
- 构建、测试命令中的引擎路径统一从 `AgentConfig.ini` 的 `Paths.EngineRoot` 获取。

## 构建与验证原则

- 构建说明统一参考 `Documents/Guides/Build.md`。
- 测试说明统一参考 `Documents/Guides/Test.md`。
- 状态导出入口：`FAngelscriptStateDump::DumpAll()`（`Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`），控制台命令 `as.DumpEngineState`（`Plugins/Angelscript/Source/AngelscriptTest/Dump/`）。
- 保持 dump 架构为纯外部观察者：优先通过已有 public/runtime API 读取，不要为 dump 侵入原有业务类型。
- 若文档与当前插件化目标不一致，应先更新文档，再继续扩展实现。

## 测试数字基线

- 当前测试数字需区分三套口径，后续文档与 roadmap 不能混写：
  - `275/275 PASS`：已编目 C++ 基线（`TestCatalog.md`）。
  - `452+` 自动化测试定义：源码扫描规模。
  - live full-suite 运行结果：以 `TechnicalDebtInventory.md` 中的实际数字为准。

## 文档维护原则

- 当插件边界、模块职责、构建方式、测试入口发生变化时，相关文档要同步更新。
- 中文说明优先更新到 `Agents_ZH.md` 或对应中文指南，避免只更新英文版。
- 若某个旧工程信息仍然重要，应总结为迁移规则或结构说明，而不是保留为零散背景备注。
- 如果新增了新的外部参考仓库或本机参考路径，应在本文件中补充"用途 + 路径 + 优先级"，避免后续检索成本持续上升。

## Git 与提交

- Git 提交格式与示例统一参考 `Documents/Rules/GitCommitRule.md`。
- 本仓库的 GitHub 标准远端为 `origin -> git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git`。
- 默认发布分支为 `main`；如果本地仓库仍停留在 `master`，首次推送前先创建或切换到 `main`。
- 首次配置 GitHub 远端时，优先使用 `git remote add origin git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git`，然后执行 `git push -u origin main` 建立 upstream 跟踪关系。
- 如果 `origin` 已存在但指向了其他仓库，应使用 `git remote set-url origin git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git` 更新地址，而不是再添加一个重复远端。
- 除非用户明确要求，否则不要对 `main` 执行 force push。

## 计划与 TODO

- 需要多阶段推进的任务，在 `Documents/Plans/` 下创建 Plan 文档，编写规则见 `Documents/Plans/Plan.md`。
- 已完成或已关闭的 Plan 从 `Documents/Plans/` 移入 `Documents/Plans/Archives/`；归档时必须补齐归档状态、归档日期、完成判断和结果摘要，并同步更新索引文档。
- TODO 应按"插件目标"拆解，避免把旧工程遗留问题混成一个大任务。
- 涉及重命名、模块迁移、对外 API 调整时，要同步梳理受影响文件和文档。
- 当前活跃 Plan 的优先级与执行顺序统一由 `Documents/Plans/Plan_StatusPriorityRoadmap.md` 管理。
- 各主题 Plan 的概况与路由统一由 `Documents/Plans/Plan_OpportunityIndex.md` 维护。

## 近期已完成里程碑

- ✅ 测试执行基础设施（统一 runner、group taxonomy、结构化摘要） — 已归档
- ✅ 构建/测试脚本标准化（共享执行层、`RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`） — 已归档
- ✅ Callfunc 死代码清理 — 已归档
- ✅ 引擎状态导出体系（27 张 CSV 表、控制台命令、自动化回归） — 已归档
- ✅ 测试宏优化（`BEGIN/END`、`SHARE_CLEAN/SHARE_FRESH`、group 收口） — 已归档
- ✅ 技术债 Phase 0-6 收口 — 已归档
- ✅ UHT 工具插件生成函数表与 legacy shard 移除 — main 已合入
- ✅ BlueprintImpact Commandlet 与编辑器集成 — main 已合入
- ✅ UE 5.7 绑定与调试器适配 — main 已合入

## 文档导航

| 文档 | 用途 |
| --- | --- |
| `AGENTS.md` | 英文版总纲 |
| `Plugins/Angelscript/AGENTS.md` | 插件内部测试分层与命名约定 |
| `Reference/README.md` | 外部参考仓库索引与详细说明 |
| `Documents/Plans/Plan_StatusPriorityRoadmap.md` | 当前完成现状、Hazelight 差距与优先级总览 |
| `Documents/Plans/Plan_OpportunityIndex.md` | 所有可执行方向全景索引 |
| `Documents/Guides/Build.md` | 构建与命令执行指南 |
| `Documents/Guides/Test.md` | 测试指南 |
| `Documents/Guides/TestCatalog.md` | 已编目测试基线清单 |
| `Documents/Guides/TestConventions.md` | 测试命名与组织约定 |
| `Documents/Guides/TechnicalDebtInventory.md` | 技术债与 live suite 状态 |
| `Documents/Guides/AngelscriptForkStrategy.md` | AngelScript Fork 演进策略（选择性吸收，非整体升级） |
| `Documents/Guides/BindGapAuditMatrix.md` | 绑定差距审计矩阵 |
| `Documents/Guides/UE_Search_Guide.md` | UE 知识查询指南 |
| `Documents/Rules/GitCommitRule.md` | 英文提交规范 |
| `Documents/Plans/Plan.md` | Plan 文档编写规则 |
| `Documents/Plans/Archives/README.md` | 已归档 Plan 清单与摘要 |
| `Documents/Tools/Tool.md` | 内部工具说明 |
