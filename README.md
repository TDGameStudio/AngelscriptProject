# AngelscriptProject

Unreal Engine 5.7 的 AngelScript 集成插件开发工程。

本仓库的真正交付物是 `Plugins/Angelscript/` —— 一个让 AngelScript 成为 UE5 中与 Blueprint、C++ 并列的脚本语言的独立插件。仓库本身只是承载该插件开发与验证的 Host Project。

---

## 项目定位

| 维度 | 说明 |
|------|------|
| **目标** | 把 `Plugins/Angelscript` 维护为一个**独立可复用**的 AngelScript 插件 |
| **来源** | Fork 自 Hazelight Games 公开的 [Unreal Angelscript](http://angelscript.hazelight.se) 项目 |
| **基线** | AngelScript `2.33` + 选择性回 backport `2.38` 的 bugfix 与特性 |
| **引擎版本** | Unreal Engine `5.7` |
| **范围约束** | 不修改 UE 引擎核心代码（Hazelight 原版需要改引擎，本项目走"纯插件"路线） |
| **当前阶段** | 核心运行时、编辑器集成、测试基础设施已稳定；正在补齐若干能力闭环与对外交付入口 |

详见 `Documents/Guides/AngelscriptForkStrategy.md`。

---

## 插件架构

### 模块依赖图

```text
AngelscriptRuntime  (Runtime, 无插件内依赖)
    |
    +--> AngelscriptEditor  (Editor, public 依赖 Runtime)
    |
    +--> AngelscriptTest    (Editor, public 依赖 Runtime,
                             私有依赖 Editor [仅 bBuildEditor])

AngelscriptGameplayTags (Runtime, 独立插件; public 依赖 AngelscriptRuntime,
                         GameplayTags)
    |
    +--> AngelscriptGameplayTagsTest (Editor, GameplayTags 专项测试)

AngelscriptGAS      (Runtime, 独立插件; public 依赖 AngelscriptRuntime,
                     AngelscriptGameplayTags,
                     GameplayAbilities / GameplayTasks / GameplayTags)
    |
    +--> AngelscriptGASTest (Editor, GAS 专项测试)

AngelscriptUHTTool  (C# UBT 插件, 独立; 接入 Unreal Header Tool 流水线)
```

UE 模块默认在 `PostDefault` 阶段加载。`GameplayTags` 脚本绑定拆到可选的 `AngelscriptGameplayTags` 插件；`AngelscriptGAS` 同时依赖 `Angelscript`、`AngelscriptGameplayTags` 和 UE 的 `GameplayAbilities` / `GameplayTasks` / `GameplayTags` 模块。

### 核心子系统（AngelscriptRuntime）

| 子系统 | 目录 | 关键能力 |
|--------|------|---------|
| **引擎核心** | `Core/` | `AngelscriptEngine` 单例、4 阶段编译流（parse → preprocess → compile → link）、AS 与 UE 类型映射 |
| **类型绑定** | `Binds/` | `Bind_*.cpp` 暴露核心 UE 类型（数学/Actor/Component/Physics/UMG/Delegate/Container/JSON/EnhancedInput 等）+ `BlueprintCallableReflectiveFallback` 兜底 |
| **类生成器** | `ClassGenerator/` | AS class → 活跃 UClass/UStruct，支持属性布局、函数 stub、热重载版本链 |
| **预处理器** | `Preprocessor/` | `#include` / `#if` / 条件编译 / 注释式文档提取 |
| **Static JIT** | `StaticJIT/` | AS 字节码 → 优化的近原生执行；`PrecompiledData` 负责模块持久化 |
| **DAP 调试** | `Debugging/` | 兼容 DAP 协议的 TCP 调试服务器（断点/单步/变量检视/调用栈） |
| **脚本子系统** | `Subsystem/` | `ScriptWorldSubsystem` / `ScriptGameInstanceSubsystem` / `ScriptEngineSubsystem` / `ScriptLocalPlayerSubsystem` |
| **函数库** | `FunctionLibraries/` | Mixin 库为数学类型/Actor/Component/Widget 等增加辅助方法 |
| **状态导出** | `Dump/` | 27+ CSV 表导出器；纯外部观察者，不入侵运行时 |
| **代码覆盖率** | `CodeCoverage/` | AngelScript 行级覆盖率追踪 + HTML/JSON 报告 |
| **第三方 AS 内核** | `ThirdParty/angelscript/` | Vendored AngelScript 2.33 源码 + 本地补丁 |

### 可选扩展插件（AngelscriptGameplayTags / AngelscriptGAS）

| 插件 | 目录 | 关键能力 |
|------|------|---------|
| **AngelscriptGameplayTags** | `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTags/` | `FGameplayTag` / `FGameplayTagContainer` / `FGameplayTagQuery` 脚本绑定、缓存注册与 replay |
| **AngelscriptGameplayTagsTest** | `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest/` | `Angelscript.GameplayTags.*` 自动化测试 |
| **AngelscriptGAS** | `Plugins/AngelscriptGAS/Source/AngelscriptGAS/` | 脚本可继承的 GAS 基类、Ability/Attribute/Effect/Task 绑定与工具库 |
| **AngelscriptGASTest** | `Plugins/AngelscriptGAS/Source/AngelscriptGASTest/` | `Angelscript.GAS.*` 自动化测试 |

### 编辑器子系统（AngelscriptEditor）

| 子系统 | 能力 |
|--------|------|
| **HotReload** | `DirectoryWatcher` 监控 `.as` 文件 + `ClassReloadHelper` 在编辑器中实时 Reinstance 修改后的脚本类 |
| **CodeGen** | 编辑器期 IDE 支持与 API stub 生成 |
| **BlueprintImpact** | 扫描器 + Commandlet：分析脚本变更影响哪些 Blueprint，支持靶向重编 |
| **SourceNavigation** | 从 UE 编辑器元素直接跳转到对应 `.as` 源文件与行号 |
| **ContentBrowser** | 自定义 DataSource，让 `.as` 脚本出现在 UE Content Browser 中 |

### UHT 工具链（AngelscriptUHTTool）

C# 项目（`.ubtplugin.csproj`）接入 Unreal Build Tool 流水线。读取 C++ 头文件，提取 `UFUNCTION` / `UPROPERTY` 元数据，按 `FunctionBindingMethod` 生成 `AS_FunctionBinding_*.cpp` 分片，同时输出 `AS_FunctionBindingStatistics.json` 与各模块统计 CSV 报表。

### 测试模块（AngelscriptTest）

约 **390** 个测试 `.cpp`，按主题（Actor / Bindings / Blueprint / Compiler / ClassGenerator / Debugger / Delegate / GC / HotReload / Inheritance / Interface / Networking / Preprocessor / StaticJIT / Subsystem 等）组织。命名约定：

- `Angelscript.TestModule.<Theme>.*` — 集成测试
- `Angelscript.CppTests.*` — Runtime 内部 C++ 单元测试
- `Angelscript.Editor.*` — 编辑器测试

详见 `Plugins/Angelscript/AGENTS.md` 的分层规则。

---

## 仓库结构

```text
AngelscriptProject/
├── Plugins/Angelscript/         # 插件主体（真正的交付物）
│   └── Source/
│       ├── AngelscriptRuntime/  # Runtime 核心
│       ├── AngelscriptEditor/   # 编辑器集成
│       ├── AngelscriptTest/     # 测试模块
│       └── AngelscriptUHTTool/  # UBT C# 插件
├── Plugins/AngelscriptGameplayTags/ # 可选 GameplayTags 扩展插件
├── Plugins/AngelscriptGAS/      # 可选 GAS 扩展插件
├── Wiki/                        # TiddlyWiki 工作区（TDGameStudio/AngelscriptWiki 子模块）
├── Source/AngelscriptProject/   # Host Project 模块（最小化，仅为给 UE 一个有效 Target）
├── Script/                      # AngelScript 示例脚本（Examples/Core, EnhancedInput, Extended）
├── Extensions/                  # 项目维护的外部开发工具
│   └── AngelscriptVSCode/       # VS Code Language Server / Debug Adapter
├── Documents/                   # 项目文档
│   ├── Guides/                  # Build / Test / Fork 策略等指南
│   ├── Knowledges/              # 架构知识库（中文，按主题前缀组织）
│   ├── Plans/                   # 历史 Plan 文档（OpenSpec 前，仅作参考）
│   └── Rules/                   # Git 提交规则、参考对照规则等
├── .agents/                     # OpenSpec + Superpowers 项目技能适配说明
├── openspec/                    # OpenSpec change 产物目录（由 CLI 在存在 change 时维护）
├── Reference/                   # 外部参考仓库（不入库，仅本地比对用）
├── Tools/                       # 本地辅助脚本（构建/测试/引导/分析）
├── AgentConfig.ini              # 机器本地配置（已 gitignore，需 bootstrap 生成）
├── AGENTS.md / AGENTS_ZH.md     # AI Agent 工作指引（项目规范来源）
├── AngelscriptProject.uproject  # UE 工程文件
└── README.md                    # 本文件
```

---

## 快速开始

### 1. 前置条件

| 项 | 要求 |
|----|------|
| OS | Windows 10 / 11（命令以 PowerShell 与 cmd 为例） |
| Unreal Engine | 5.7（源码版本，需要本地完整构建） |
| Visual Studio | 2022 (Desktop development with C++) |
| .NET | UE 自带 .NET 8.0 SDK |
| PowerShell | 5.1+ 或 PowerShell Core 7+ |

### 1.1 AI 协作与计划管理依赖

本项目的计划管理与 AI 协作流程依赖 **OpenSpec** 和 **Superpowers**：

| 依赖 | 用途 |
|------|------|
| OpenSpec CLI | 管理 change 生命周期：`proposal.md`、`design.md`、`specs/*`、`tasks.md`、验证与归档 |
| Superpowers | 提供需求澄清、方案推导、TDD、系统调试、完成前验证等执行纪律 |

安装 / 检查 OpenSpec CLI：

```powershell
openspec --version

# 未安装时
npm install -g @fission-ai/openspec
```

Superpowers 由 AI 工具的插件/技能系统提供；本仓库的 OpenSpec 适配说明见 `.agents/skills/README.md`。

关键规则：如果用户请求创建/更新计划、方案、任务拆解或实施某个 change，使用 `openspec-work` skill（或 `/opsx:work`，也可经 `/opsx:propose` / `/opsx:apply` 触发）。它一体支持"记录"和"实现"，没有阶段墙——可只记录就停，也可边记边做。不要再为新工作创建 `Documents/Plans/Plan_*.md`；当前 change 的 `tasks.md` 是可随时重写的活记录。

### 2. Bootstrap：生成 `AgentConfig.ini`

先初始化插件子模块：

```powershell
git submodule update --init --recursive
```

`Wiki/` 是独立的 TiddlyWiki 子仓库，远端为 `TDGameStudio/AngelscriptWiki`。首次初始化后可按 Wiki 仓库自身的 `package.json` 运行开发服务：

```powershell
cd Wiki
pnpm install
pnpm dev
```

`Experiment/` 下的旧 MkDocs 备份和实验性 TiddlyWiki 工作区不属于当前 Wiki 子模块的初始内容；AS Wiki 功能将在后续变更中逐步迁移。

仓库根目录有大量自动化脚本（构建、测试、引导）依赖 `AgentConfig.ini` 中的本机路径配置。该文件已 `.gitignore`，每个 worktree 都需要先 bootstrap：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1
```

也可显式指定引擎根目录：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -EngineRoot "J:\UnrealEngine\UERelease"
```

Bootstrap 完成后，根目录会出现 `AgentConfig.ini`，其中关键配置：

```ini
[Paths]
EngineRoot=<UE 根目录>
ProjectFile=<当前 worktree 的 .uproject>

[Build]
EditorTarget=AngelscriptProjectEditor
Platform=Win64
Configuration=Development
DefaultTimeoutMs=180000

[Test]
DefaultTimeoutMs=600000
```

### 3. 构建

仓库**唯一标准构建入口**：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label first-build -TimeoutMs 180000
```

脚本会自动读取 `AgentConfig.ini`，并把日志写到独立目录。详见 `Documents/Guides/Build.md`（含规则约束、超时上限、并发安全策略）。

### 4. 运行测试

仓库**唯一标准测试入口**：

```powershell
# 跑全量测试
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Label first-test -TimeoutMs 600000

# 跑具名测试套件
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -SuiteName <suite> -TimeoutMs 600000
```

详见 `Documents/Guides/Test.md`。

### 5. 在编辑器中编辑 / 运行 `.as` 脚本

打开 `AngelscriptProject.uproject` 启动编辑器后：

- `.as` 文件出现在 Content Browser 中
- 修改后保存 → `DirectoryWatcher` 触发热重载 → 编辑器中正在运行的脚本类自动 Reinstance
- 编辑器菜单栏 **Angelscript** 提供调试服务器开关、状态 Dump 等工具入口

示例脚本位于：

```text
Script/Examples/Core/                  # 基础示例（Actor 生命周期、组件、Subsystem）
Script/Examples/EnhancedInput/         # 增强输入系统集成示例
Script/Examples/Extended/              # 进阶示例（GAS、子系统生命周期等）
```

---

## 文档导航

文档全部位于 `Documents/`，所有结构性文档使用**简体中文**编写。

### 入口文档

| 文档 | 用途 |
|------|------|
| `AGENTS.md` / `AGENTS_ZH.md` | AI Agent / 协作者的工作指引（**项目规范的权威来源**） |
| `.agents/skills/README.md` | OpenSpec + Superpowers 协作流程与项目技能适配说明 |
| `Documents/Knowledges/ZH/Index.md` | 知识库主索引，按主题前缀组织所有原理性文档 |
| `Documents/Guides/Build.md` | 构建规则、超时约束、并发安全 |
| `Documents/Guides/Test.md` | 测试入口与超时约束 |
| `Documents/Guides/AngelscriptForkStrategy.md` | Fork 策略、与上游 Hazelight 的差异哲学 |
| `Documents/Guides/VSCodeAngelscript.md` | 项目内 VS Code 扩展的构建、安装与 DebugServer 使用流程 |

### 知识库前缀分类（`Documents/Knowledges/ZH/`）

| 前缀 | 主题 |
|------|------|
| `Arch_` | 插件总体架构（模块划分、生命周期、错误诊断） |
| `AS_` | AngelScript 引擎内核（编译器、字节码、VM、GC、字符串工厂） |
| `Type_` | 类型系统与生成链路（类生成、Bind 系统、函数桥） |
| `RT_` | 运行时子系统（HotReload / StaticJIT / Debugger / Dump / Coverage） |
| `Test_` | 测试架构（分层、基础设施、主题簇） |
| `Syntax_` | 语法机制实现原理（`default` / `UPROPERTY` / `UFUNCTION` / `delegate` / `mixin` 等） |
| `Diff_` | 与 Hazelight 参考实现的差异分析 |
| `Guide_` | 实践指南（QuickStart、Mixin、调试、GAS、UI、网络模拟等） |
| `Note_` | 零散笔记（接口绑定现状、UBT 约束等） |

### OpenSpec 计划管理

OpenSpec 是当前项目的权威**记录**系统（轻量使用，非流程门禁）。新的需求、方案、计划、任务拆解、背景资料、性能数据与实施状态统一进入 `openspec/changes/<change>/`：

- `openspec-work`：探索+记录+实现+归档一体流程（合并了原 `openspec-explore`、`openspec-propose`、`openspec-apply-change`、`openspec-archive-change`）。可只探索/思考、只产出完整计划当交付物（先不实现）、边记录边实现、续做已有 change、或直接归档；产物与代码可同时、任意顺序修改，初始规划可随时推翻重写。记录深度由意图决定：plan-only 时产出达到 `superpowers:writing-plans` 严谨度的计划再停下，边记边做时可从 lean 记录起步。探索/思考用 `superpowers:brainstorming`；归档经 `openspec archive "<name>"` 完成，是普通收尾动作而非门禁。

`Documents/Plans/` 是 OpenSpec 引入前的历史 Plan 文档目录，仅作背景参考或迁移输入。

详细规则见 `AGENTS.md` 与 `.agents/skills/README.md`。

---

## 外部参考仓库

`Reference/` 目录用于本地比对、迁移分析和架构参考，**不会提交到 git**。索引详见 `Reference/README.md`。常用的：

| 名称 | 作用 |
|------|------|
| AngelScript v2.38 | 上游 AngelScript 的 backport 来源 |
| Hazelight Angelscript | 原版 Hazelight 引擎集成（架构对照） |
| Hazelight Docs | Hazelight 官方文档站源码 |
| Hazelight VS Code Angelscript | VS Code Language Server / Debug Adapter 参考；项目开发版本位于 `Extensions/AngelscriptVSCode/` |
| UnrealCSharp / UnLua / puerts / sluaunreal | 友邻脚本接入方案的对照 |

拉取参考仓库：

```powershell
Tools\PullReference\PullReference.bat <name>
```

---

## 贡献流程要点

详细规范见 `AGENTS.md` 与 `Documents/Rules/`。简要清单：

1. **不修改 UE 引擎核心**。所有改动落在 `Plugins/Angelscript/` 或本仓库内。
2. **计划/记录走 OpenSpec**。创建计划、方案、任务拆解或实施 change 时使用 `openspec-work`；当前 change 的 `tasks.md` 是可随时重写的活记录，背景资料/性能数据等可一并存于 change 目录。
3. **构建 / 测试只走标准入口**。直接调 `Build.bat` / `UnrealEditor-Cmd.exe` 等的命令不允许写入文档或脚本。
4. **测试覆盖**。新功能或 bugfix 必须配套测试（`Plugins/Angelscript/Source/AngelscriptTest/`）。
5. **Git 提交规范**。遵循 `Documents/Rules/GitCommitRule.md`，前缀如 `[Plugin/Angelscript] Feat:` / `[Test/Angelscript] Test:` / `[Docs] Docs:`。
6. **文档先行**。修改原理涉及的文档（`Documents/Knowledges/`）需要随代码同步更新。

---

## 许可证

- 本仓库代码：**MIT License**。详见根目录 `LICENSE`。
- `Plugins/Angelscript/`：**MIT License**（原始版权 Hazelight Games AB，Fork 修改版权 TDGameStudio）。详见 `Plugins/Angelscript/LICENSE.md`。
- `Plugins/AngelscriptGAS/`：**MIT License**。详见 `Plugins/AngelscriptGAS/LICENSE.md`。
- `Plugins/Angelscript/ThirdParty/angelscript/`：AngelCode Scripting Library，**zlib 协议**。详见 `Plugins/Angelscript/LICENSE.md`。

---

## 联系与反馈

- 项目状态分析：`Documents/ProjectStatusAnalysis.md`
- OpenSpec / Superpowers 协作说明：`.agents/skills/README.md`
- 历史优先级路线图：`Documents/Plans/Plan_StatusPriorityRoadmap.md`
