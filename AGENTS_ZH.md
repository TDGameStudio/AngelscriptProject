# AGENTS_ZH.md

> **本文件是 `AGENTS.md` 的中文翻译版本，内容应与英文版保持同步。**

## 项目概览

- 本文件用于指导在 `AngelscriptProject` 中工作的 AI Agent。
- 当前第一目标不是继续扩展一个普通游戏工程，而是把 `Plugins/Angelscript` 整理、验证并沉淀为可独立使用的 Angelscript 插件。当前仓库是插件开发与验证的承载工程；真正的主产物是 `Angelscript` 插件本身。
- 插件已经**不处于原型或底座搭建阶段**，而是进入了"核心运行时、编辑器集成、测试基础设施都已成型，但对外交付入口和若干关键能力闭环仍需收口"的成熟期。
- 当前基线：`AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` 三个 UE 模块已稳定，`121` 个 `Bind_*.cpp`、`27+` 张 CSV 状态导出表、`1518+` 个自动化测试定义分布在 `430` 个测试 `.cpp` 文件中、`DebugServer V2` 协议、`CodeCoverage`、`StaticJIT`、`BlueprintImpact Commandlet` 均已落地。`GameplayTags` 支持现在拆到可选的 `AngelscriptGameplayTags` 插件里，而 `AngelscriptGAS` 依赖它做 GAS 侧集成。仅余 `2` 个测试保持 Disabled（均为 `#ue57-headless` 已知限制）。
- AS 基线版本为 `2.33 + 选择性 2.38 兼容`，fork 已深度分叉，整体升级不可行，策略为从高版本选择性吸收改进。详见 `Documents/Guides/AngelscriptForkStrategy.md`。
- `Plugins/Angelscript/` 是核心工作区，绝大多数实现、修复、清理和测试都应优先落在这里。`Source/AngelscriptProject/` 仅保留宿主工程必须的最小内容，除非任务明确需要，不要把插件逻辑塞回项目模块。

## 项目目录结构

```
AngelscriptProject/
├── AGENTS.md                                # AI 指引（英文）
├── AGENTS_ZH.md                             # AI 指引（中文）— 本文件
├── CLAUDE.md                                # 重定向 → AGENTS.md
│
├── Plugins/Angelscript/                     # ★ 核心交付物（1619 个文件）
│   ├── README.md                            # 插件对外 README
│   ├── Angelscript.uplugin
│   └── Source/
│       ├── AngelscriptRuntime/              # 运行时模块（209 .cpp）
│       │   ├── Core/                        # 引擎核心、类型系统、编译流程
│       │   ├── Binds/                       # 121 个 Bind_*.cpp（引擎 API 绑定）
│       │   ├── ClassGenerator/              # 动态类生成、热重载、版本链
│       │   ├── Debugging/                   # DebugServer V2（DAP 协议）
│       │   ├── StaticJIT/                   # 静态 JIT 编译
│       │   ├── Preprocessor/                # 脚本预处理器（#include、#if）
│       │   ├── FunctionLibraries/           # 21 个 mixin 辅助函数库
│       │   ├── Subsystem/                   # 脚本子系统基类
│       │   ├── Dump/                        # 27+ 张 CSV 状态导出表
│       │   ├── CodeCoverage/                # 逐行覆盖率追踪
│       │   ├── Testing/                     # 运行时测试支持
│       │   └── ThirdParty/                  # AngelScript 2.33 内嵌源码
│       ├── AngelscriptEditor/               # 编辑器模块（49 .cpp）
│       │   ├── HotReload/                   # 文件监控与类重建实例
│       │   ├── CodeGen/                     # 编辑器时代码生成
│       │   ├── BlueprintImpact/             # BP 变更扫描与 Commandlet
│       │   ├── SourceNavigation/            # 跳转到源码支持
│       │   └── ContentBrowser/              # .as 文件在内容浏览器中显示
│       ├── AngelscriptTest/                 # 测试模块（430 .cpp，28+ 个主题）
│       └── AngelscriptUHTTool/              # UHT C# 代码生成工具链
│
├── Plugins/AngelscriptGameplayTags/         # 可选 GameplayTags 扩展插件
│   ├── Source/
│   │   ├── AngelscriptGameplayTags/         # GameplayTag 运行时绑定与 replay
│   │   ├── AngelscriptGameplayTagsEditor/   # GameplayTag 变更监听与 reload
│   │   └── AngelscriptGameplayTagsTest/     # GameplayTags 专项自动化测试
│
├── Source/                                  # 宿主工程（最小化，8 个文件）
├── Script/                                  # AngelScript 示例（37 个 .as）
│   ├── Examples/                            # Core / EnhancedInput / Extended
│   ├── Automation/                          # 脚本自动化入口
│   └── Tests/                               # 脚本级测试
│
├── Reference/
│   └── README.md                            # 参考仓库索引、拉取命令、优先级
│
├── .agents/skills/
│   └── README.md                            # OpenSpec 工作流与技能适配说明
│
├── openspec/                                # ★ 活跃变更生命周期（48 个文件）
│   ├── changes/                             # 进行中与已归档的变更
│   └── specs/                               # 共享规格文档
│
├── Documents/
│   ├── Guides/
│   │   ├── Build.md                         # 构建命令与执行
│   │   ├── Test.md                          # 测试运行器与 Suite 用法
│   │   ├── TestCatalog.md                   # 已编目测试基线（275/275）
│   │   ├── TestConventions.md               # 测试命名与组织约定
│   │   ├── TestPerformance.md               # 性能基准
│   │   ├── TestMacroStatus.md               # 宏迁移状态
│   │   ├── TestFixSummary_20260430.md       # 修复快照 2026-04-30
│   │   ├── TechnicalDebtInventory.md        # 技术债与 live suite 状态
│   │   ├── AngelscriptForkStrategy.md       # Fork 策略（选择性吸收）
│   │   ├── ASSDK_Fork_Differences.md        # ASSDK fork 差异分析
│   │   ├── GlobalStateContainmentMatrix.md  # 全局状态收容分析
│   │   ├── BindGapAuditMatrix.md            # 绑定差距审计
│   │   ├── BlueprintTypeBindingsOptimization.md # BP 类型绑定优化
│   │   └── UE_Search_Guide.md               # UE 知识查询
│   ├── Rules/
│   │   ├── GitCommitRule.md                 # 提交规范（英文）
│   │   └── ASInlineFormattingRule.md        # C++ 测试中内联 AS 格式规则
│   ├── Plans/                               # ⚠ 仅历史参考 — 新工作用 openspec/
│   │   ├── Plan_StatusPriorityRoadmap.md    # 历史状态快照
│   │   ├── Plan_OpportunityIndex.md         # 历史机会索引
│   │   ├── Archives/                        # 已归档 Plan
│   │   └── ...                              # 84 份历史 Plan_*.md
│   ├── Knowledges/ZH/
│   │   ├── Index.md                         # 知识库索引（32 篇）
│   │   └── ...                              # AS 内核、语法、类型系统等
│   ├── Reports/                             # 生成的审查报告（505 份）
│   ├── Hazelight/                           # Hazelight 参考笔记（3 份）
│   └── Tools/
│       └── Tool.md                          # 内部工具说明
│
├── Tools/                                   # 构建/测试/诊断脚本
│   ├── RunBuild.ps1                         # 构建入口
│   ├── RunTests.ps1                         # 测试入口
│   ├── RunTestSuite.ps1                     # Suite 运行器
│   ├── Bootstrap/                           # 首次配置
│   ├── Shared/                              # 共享工具模块
│   ├── Diagnostics/                         # 健康检查与调试
│   └── PullReference/                       # 参考仓库拉取
│
└── Config/                                  # UE 工程配置（4 个 .ini）
```

## 架构概览

本项目是一个 **Unreal Engine 5.7 插件**，将 AngelScript 脚本语言集成为 Blueprint 和 C++ 的一等替代方案。该插件最初由 Hazelight Games 创建；本仓库维护一个基于 AS 2.33 并选择性回移 2.38 改进的分叉版本。

### 模块依赖关系

```
AngelscriptRuntime  (Runtime 模块，无插件内依赖)
       │
       ├──► AngelscriptEditor  (Editor 模块，公开依赖 Runtime)
       │
       └──► AngelscriptTest    (Editor 模块，公开依赖 Runtime，
                                bBuildEditor 时私有依赖 Editor)

AngelscriptGameplayTags  (Runtime 模块，公开依赖 Runtime；可选)
       │
       ├──► AngelscriptGameplayTagsEditor  (Editor 模块，GameplayTags 监听 / reload 桥接)
       └──► AngelscriptGameplayTagsTest    (Editor 模块，GameplayTags 专项测试)

AngelscriptGAS  (Runtime 模块，公开依赖 Runtime + AngelscriptGameplayTags)

AngelscriptUHTTool  (C# UBT 插件，独立 — 接入 Unreal Header Tool 管线)
```

三个 UE 模块均在 `PostDefault` 阶段加载。`AngelscriptRuntime` 通过 `UAngelscriptEngineSubsystem` 负责 Editor/Commandlet 主启动初始化，`FAngelscriptRuntimeModule::InitializeAngelscript()` 保留为兼容 API 并在 `GEngine` 可用时路由到该 Subsystem。`UAngelscriptGameInstanceSubsystem` 管理 World/GameInstance 上下文，当存在活跃 GameInstance tick owner 时会抑制 EngineSubsystem 的回退 tick。宿主工程模块 `AngelscriptProject` 有意保持最小化 — 仅为 UE 提供有效 Target，所有实际逻辑归属插件。

### 编辑器子系统 (AngelscriptEditor)

- **热重载** (`HotReload/`)：`DirectoryWatcher` 监控 `.as` 文件；`ClassReloadHelper` 处理编辑器中已修改脚本类的实时重建实例。
- **代码生成** (`CodeGen/`)：编辑器时代码生成（~84 KB），用于 IDE 支持和 API 桩。
- **Blueprint 影响分析** (`BlueprintImpact/`)：扫描器和 Commandlet，分析哪些 Blueprint 受脚本变更影响，实现定向重编译。
- **源码导航** (`SourceNavigation/`)：允许从 UE 编辑器元素直接跳转到对应 `.as` 源文件和行号。
- **内容浏览器** (`ContentBrowser/`)：自定义数据源，使 `.as` 脚本出现在 UE Content Browser 中。

### UHT 工具 (AngelscriptUHTTool)

C# 项目（`.ubtplugin.csproj`），接入 Unreal Build Tool 管线。读取 C++ 头文件，提取 `UFUNCTION`/`UPROPERTY` 元数据，生成 `AS_FunctionTable_*.cpp` 分片（direct-bind 或 stub 条目）。构建产物包括 `AS_FunctionTable_Summary.json` 和逐模块 CSV 细分。

### 测试模块 (AngelscriptTest)

430 个测试 `.cpp` 文件，组织在 28+ 个主题目录中（Actor、AngelScriptSDK、Bindings、Blueprint、Component、Debugger、Delegate、GC、HotReload、Inheritance、Interface、Networking、Preprocessor、StaticJIT、Subsystem 等）。测试使用自动化前缀约定：`Angelscript.TestModule.<Theme>.*` 用于集成测试，`Angelscript.CppTests.*` 用于运行时 C++ 单元测试，`Angelscript.Editor.*` 用于编辑器测试。Native AngelScript SDK 覆盖的最新验证结果为 `Angelscript.TestModule.AngelScriptSDK` `301/301 PASS`，其中包含 151 个新增 Tokenizer/Parser/ScriptNode/Bytecode/Reference 覆盖项。分层规则参见根目录测试指南。

### 脚本示例 (`Script/`)

Angelscript `.as` 示例脚本，演示核心模式（Actor 生命周期、子系统、输入绑定、GAS Ability）。组织在 `Script/Examples/Core/`、`Script/Examples/EnhancedInput/` 和 `Script/Examples/Extended/` 下。

### 关键数据流

1. **编译**：`.as` 文件 → 预处理器 → AS 编译器 → 字节码 → （可选）StaticJIT → 可执行模块
2. **类注册**：AS 类定义 → 类生成器 → 带 UProperty 和 UFunction 的活跃 UClass/UStruct → Blueprint 和 C++ 可见
3. **绑定**：C++ 类型 → `Bind_*.cpp` 手动绑定 + UHT 生成函数表 + 跨模块 direct-bind feature 表 + 反射回退 → AS 脚本可调用
4. **热重载**：文件监控器检测变更 → 重编译受影响模块 → ClassReloadHelper 在编辑器中重建实例

### 绑定路径维护说明

- 跨模块 direct bind 通过 UHT 在目标模块 OutputDirectory 生成 `AS_FunctionTable_<Module>_CrossModule_*.cpp` 分片，并经 Core `IModularFeatures` 发布 POD payload；`AngelscriptRuntime` 不得为了这些条目新增任何引擎模块 link 依赖。
- 跨模块 emit 当前只覆盖 safe signatures。out-param、WorldContext 注入、ref return、static array，以及 `TArray` / `TSet` / `TMap` 容器继续走 fallback 或后续 OpenSpec 扩展。
- RPC/Net UFunction 必须继续走 `BlueprintCallableReflectiveFallback`；raw thunk 直调会绕过 Unreal RPC 路由。
- 任何修改 `FAngelscriptCrossModuleEntry` 或 `FAngelscriptCrossModuleFeatureReader` layout 的变更，都必须 bump `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`，并同步 runtime 头、generator emit 与测试。

## 外部参考仓库

- 完整索引、拉取命令、用途边界与优先级说明见 `Reference/README.md`。

## 本地配置

- 项目根目录的 `AgentConfig.ini` 存放本机引擎路径等配置，已被 `.gitignore` 忽略。
- 首次使用运行 `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` 生成模板，再填入本机路径。
- 构建、测试命令中的引擎路径统一从 `AgentConfig.ini` 的 `Paths.EngineRoot` 获取。

## 构建与验证原则

- 构建说明统一参考 `Documents/Guides/Build.md`。
- 测试说明统一参考 `Documents/Guides/Test.md`。
- 状态导出入口：`FAngelscriptStateDump::DumpAll()`（`Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`），控制台命令 `as.DumpEngineState`（`Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`）。Dump API 还提供 `CaptureSnapshot`、`DiffSnapshots`、`DumpSnapshot` 和 `DumpDiff`；`DumpAll()` 会写出 `EngineStateSnapshot.csv` 与分类 snapshot 表，diff helper 会写出 `StateDiff.csv` 和 `StateDiffSummary.csv`。
- 保持 dump 架构为纯外部观察者：优先通过已有 public/runtime API 读取，不要为 dump 侵入原有业务类型。
- 若文档与当前插件化目标不一致，应先更新文档，再继续扩展实现。

## 测试数字基线

- 当前测试数字需区分三套口径，后续文档与 roadmap 不能混写：
  - `275/275 PASS`：已编目 C++ 基线（`TestCatalog.md`）。
  - `1518+` 个自动化测试定义分布在 `430` 个测试 `.cpp` 文件中：`test-as-native-sdk-coverage` 后的源码扫描规模。
  - `301/301 PASS`：native AngelScript SDK 前缀（`Angelscript.TestModule.AngelScriptSDK`），包含 151 个新增 Tokenizer/Parser/ScriptNode/Bytecode/Reference 覆盖项。
  - live full-suite 运行结果：以 `TechnicalDebtInventory.md` 中的实际数字为准。
  - 仅余 `2` 个测试保持 Disabled（`#ue57-headless`）：`TestEngineHelperTests.cpp:106` 和 `SourceNavigationTests.cpp:125`。

## 文档维护原则

- 当插件边界、模块职责、构建方式、测试入口发生变化时，相关文档要同步更新。
- 中文说明优先更新到 `Agents_ZH.md` 或对应中文指南，避免只更新英文版。
- 若某个旧工程信息仍然重要，应总结为迁移规则或结构说明，而不是保留为零散背景备注。
- 如果新增了新的外部参考仓库或本机参考路径，应在本文件中补充"用途 + 路径 + 优先级"，避免后续检索成本持续上升。

## Git 与提交

- Git 提交格式与示例统一参考 `Documents/Rules/GitCommitRule.md`。
- 格式：`[<Scope>] <Type>: <description>` — Scope 可选（模块/功能区域），Type 必填（`Fix`、`Feat`、`Refactor`、`Docs`、`Test`、`Chore`），description 为精炼的面向结果摘要。示例：`[Angelscript] Feat: add FTransform mixin bindings for script access`。
- 不要追加工具生成的提交尾部标记（例如 `Made-with: Cursor`），除非用户明确要求。
- 默认发布分支为 `main`；如果本地仓库仍停留在 `master`，首次推送前先创建或切换到 `main`。
- 首次配置 GitHub 远端时，优先使用 `git remote add origin <your-remote-url>`，然后执行 `git push -u origin main` 建立 upstream 跟踪关系。
- 如果 `origin` 已存在但指向了其他仓库，应使用 `git remote set-url origin <your-remote-url>` 更新地址，而不是再添加一个重复远端。
- 除非用户明确要求，否则不要对 `main` 执行 force push。

## 子模块与 Worktree

- 默认编辑位置是当前 workspace / 主干 checkout。除非用户明确要求本次任务新建或使用 worktree，否则不要创建、切换到、或继续在 git worktree 中工作。
- 插件目录（`Plugins/Angelscript`、`Plugins/AngelscriptGameplayTags`、`Plugins/AngelscriptGAS`）是 **git 子模块**，不是普通目录。`git worktree add` 不会自动初始化子模块。
- 一键流程：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\NewWorktree.ps1 -Name <change-name>` 一次性完成"父 worktree + 所有子模块 init/fallback + AgentConfig.ini + `openspec/changes/<change-name>/` 空骨架"。
- `BootstrapWorktree.ps1` 仍是"对*已存在*的 worktree 重新初始化"的入口（如切换 EngineRoot 后），并被 `NewWorktree.ps1` 内部调用；只在修复已有 worktree 时直接执行它。
- 当目标代码在子模块中时，属于双仓库变更：OpenSpec artifacts 在父仓库，源码在子模块。先提交子模块，再更新父仓库的 gitlink。
- 完整工作流、回退策略、scope guard 和故障排查参见 **`Documents/Guides/SubmoduleWorktreeWorkflow.md`**。

## OpenSpec 与 TODO

- `Documents/Plans/` **已废弃** — 仅保留作历史参考。所有新的计划、设计、任务跟踪与归档生命周期使用 `openspec/changes/<change>/` 下的 OpenSpec 产物。
- OpenSpec 是轻量**记录**，不是流程门禁。只有一个技能 `openspec-work`，覆盖完整生命周期（探索 + 记录 + 实现 + 归档，一体流程）。原 `openspec-explore`、`openspec-propose`、`openspec-apply-change`、`openspec-archive-change` 已全部合并进它；探索/思考阶段在 `openspec-work` 内用 `superpowers:brainstorming` 承担。
- 使用 `openspec-work`（或 `/opsx:work`，也可经 `/opsx:propose` / `/opsx:apply` / `/opsx:archive` 触发）创建、继续或归档变更。没有阶段墙：可以只记录意图就停、边记录边实现、稍后再继续实现、或直接归档已完成的变更——OpenSpec 产物与代码可同时、任意顺序修改。初始规划是可丢弃的，随认知推进可随时推翻并重写 `tasks.md`。
- 记录深度由意图决定。**只规划不实现（plan-only）**是一等模式：产出一份完整、可直接照做的计划（文件映射、bite-sized 任务、精确验证命令，达到 `superpowers:writing-plans` 的严谨度），然后停下、先不实现——不是草草的最小骨架。而"边记边做"模式才可以从 lean 记录起步、按需扩展。
- 继续积极使用 Superpowers 方法（brainstorming、TDD、systematic-debugging、verification-before-completion）。放宽的是 OpenSpec 自身的仪式，不是工程纪律。在关键里程碑验证即可（不必每步验证）；"验证"本身可作为 `tasks.md` 里的显式任务。
- change 目录为**自由存储**：除 `proposal/design/specs/tasks` 外，可在 `openspec/changes/<name>/` 下保留背景笔记、调研、性能/基准数据（`benchmarks/*.csv`）、日志等。`tasks.md` 保持干净清单，附加说明/数据放单独文件。
- 归档是 `openspec-work`（`/opsx:archive`）内的普通收尾动作，经 `openspec archive "<name>"` 完成——不是验证门禁。未完成任务或被重写的规划都不阻塞归档。
- 对于不影响行为、架构或对外 API 的小型、局部、低风险修改，先询问用户是否跳过 OpenSpec。如用户明确要求跳过，简要记录原因。
- TODO 应围绕插件目标拆解。涉及重命名、模块迁移、对外 API 调整时，同步梳理受影响文件和文档。

## 最近完成里程碑

- ✅ 移除 inactive `WITH_ANGELSCRIPT_HAZE` 分支、清理 Haze-only RPC 语法、移除 debugger Haze flag，并恢复 UE 原生 actor instigator 命名 — 已在 `refactor-as-audit-remove-with-angelscript-haze` 实施
