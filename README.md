# AngelscriptProject

本仓库是 **Unreal AngelScript 1.0.0** 的宿主工程。真正交付物是 `Plugins/Angelscript/`：一份深度嵌入 Unreal Engine 5.8 的 AngelScript 方言与运行时，让脚本成为和 Blueprint、C++ 并列的选项。仓库本身只负责开发与验证。

---

## 项目定位

| 维度 | 说明 |
|------|------|
| **产品** | Unreal AngelScript `1.0.0`（编码 `10000`） |
| **目标** | 把 `Plugins/Angelscript` 维护为一个**独立可复用**的 AngelScript 插件 |
| **来源** | 最初来自 Hazelight Games 公开的 [Unreal Angelscript](http://angelscript.hazelight.se) 集成；本仓库走纯插件路线，不改 UE 引擎核心 |
| **引擎版本** | Unreal Engine `5.8` |
| **当前阶段** | 核心运行时、编辑器集成、测试基础设施已稳定；正在补齐若干能力闭环与对外交付入口 |

---

## AngelScript 版本

当前交付的不是外挂在 UE 上的原版 AngelScript，而是 **Unreal AngelScript 1.0.0**：语言、内核和对象模型都按 Unreal 改过。脚本类型会进入 UE 反射树，Blueprint、序列化、GC 和网络复制都能看见。接入方必须使用插件自带的公共头，不能拿官方 SDK 头创建引擎。

- **UE 方言语法**：`UFUNCTION` / `UPROPERTY`、`default`、mixin 函数、脚本子系统；对象引用按 UE 生命周期管理。
- **脚本类变成活的 `UClass`**：`.as` 类 / 结构体生成 `UASClass` / `UASStruct`，对编辑器和 Blueprint 透明。
- **引擎 API 绑定**：手写 `Bind_*.cpp`、UHT 生成函数表、反射回退；RPC / Net 走 UE 路由。
- **编辑器热重载**：改 `.as` 后重编译并 Reinstance，支持类改名 CoreRedirects。
- **DAP 调试**：断点、单步、变量、调用栈，可对齐 Blueprint 帧。
- **StaticJIT**：每个 AS 模块生成一个稳定 `.jit.cpp`，通过多 Provider/Engine-local 路由精确挂接 Native 入口，失配逐函数回退 VM。
- **增量缓存**：Cache V2 用稳定函数身份复用编译结果，缺原生条目回退 VM。
- **Standalone**：无 UE 的受限执行，以及离线 UE 声明校验（不模拟 UObject / World）。
- **可选扩展**：GameplayTags、GAS 拆成独立插件，不绑进核心。

版本身份和能力细节见 [AS_UEEmbeddedVersion.md](Documents/Knowledges/ZH/AS_UEEmbeddedVersion.md)，知识库总索引见 [Documents/Knowledges/ZH/Index.md](Documents/Knowledges/ZH/Index.md)。

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
| **Static JIT** | `StaticJIT/` | AS 字节码 → 每模块 C++ AOT；Provider Registry、稳定引用与 Engine-local Native/VM 路由 |
| **DAP 调试** | `Debugging/` | 兼容 DAP 协议的 TCP 调试服务器（断点/单步/变量检视/调用栈） |
| **脚本子系统** | `Subsystem/` | `ScriptWorldSubsystem` / `ScriptGameInstanceSubsystem` / `ScriptEngineSubsystem` / `ScriptLocalPlayerSubsystem` |
| **函数库** | `FunctionLibraries/` | Mixin 库为数学类型/Actor/Component/Widget 等增加辅助方法 |
| **状态导出** | `Dump/` | 27+ CSV 表导出器；纯外部观察者，不入侵运行时 |
| **代码覆盖率** | `CodeCoverage/` | AngelScript 行级覆盖率追踪 + HTML/JSON 报告 |
| **第三方 AS 内核** | `ThirdParty/angelscript/` | 与 Runtime 同模块编译的深度定制内核，不是可替换的官方 SDK |

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
├── .agents/                     # Harness + OpenSpec 项目技能适配说明
├── openspec/                    # OpenSpec change 产物目录（由 CLI 在存在 change 时维护）
├── Reference/                   # 外部参考仓库（不入库，仅本地比对用）
├── Tools/                       # 旧 wrapper 与诊断工具；Tools/openspec 是跟踪的源码例外
├── AgentConfig.ini              # 机器本地配置（已 gitignore，需 bootstrap 生成）
├── AGENTS.md                    # 唯一的项目级 AI Agent 工作入口
├── AngelscriptProject.uproject  # UE 工程文件
└── README.md                    # 本文件
```

---

## 快速开始

### 1. 前置条件

| 项 | 要求 |
|----|------|
| OS | Windows 10 / 11（命令以 PowerShell 与 cmd 为例） |
| Unreal Engine | 5.8（源码版本，需要本地完整构建） |
| Visual Studio | 2022 (Desktop development with C++) |
| .NET | UE 自带 .NET 8.0 SDK |
| PowerShell | 7.0+（Core） |

### 1.1 AI 协作与计划管理依赖

本项目的计划管理与 AI 协作流程依赖项目内的 **Harness** 与便携版 **OpenSpec**：

| 依赖 | 用途 |
|------|------|
| Harness | 选择一个精确 Git workspace、渐进加载 Skill，并管理显式 review、replan 与 closure 门禁 |
| Portable OpenSpec | 管理 Change 生命周期：`proposal.md`、`design.md`、`specs/*`、`tasks.md`、验证与归档 |

在当前 PowerShell 7 会话中直接导入 Harness 并检查项目内 OpenSpec；普通路由不会再启动一个 PowerShell 进程：

```powershell
Import-Module .\.agents\skills\harness\scripts\Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')
```

不要调用 `PATH` 中的同名程序、官方 Node CLI 或 `Tools/openspec/target` 构建；项目工作流说明见 `.agents/skills/README.md`。

关键规则：新特性、架构重构或重大行为变更只在创建目标 OpenSpec Change 之前使用 `brainstorming`（grilling 轮次逐题确认，每轮都记录到 `openspec/drafts/<domain>/<topic>/`），形成用户批准的 design、确认过的 talk/knowledge 携带清单与 decision-complete handoff 后，由 `openspec-create-change` 创建 Change 并把草稿副本、talks、knowledges 落进 attachments（草稿也可以 `parked`/`abandoned` 收尾而不建 Change）。Change 创建后使用 `openspec-apply-change`（先 `Ensure plan` 补齐规划产物，再实施 Ready 节点）与 `openspec-update-change`；实施中的局部探索留在当前 Ready task，执行阶段不向用户提问（tasks 未列出的新公开命名按约定取名并记 `Naming assumed` 供审查）；只有证据证明当前计划失效或冒出用户级决策时才由 Harness 触发 replan。不要再为新工作创建 `Documents/Plans/Plan_*.md`；`tasks.md` 是唯一执行状态，已完成节点不得取消勾选。

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

仓库根目录有大量自动化脚本依赖 `AgentConfig.ini` 中的本机路径配置和 workspace 身份。该文件已 `.gitignore`，每个 workspace 都需要通过 Harness 初始化，并在同一 PowerShell 7 会话中激活：

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness -Command workspace.bootstrap -Context $context
Invoke-Harness -Command workspace.activate -Context $context
```

也可通过受控配置入口设置引擎根目录：

```powershell
Invoke-Harness -Command workspace.config.set -Context $context -Parameters @{
  Section = 'Paths'
  Key = 'EngineRoot'
  Value = 'J:\UnrealEngine\UERelease'
}
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

UE 构建统一使用所选 workspace 的 Harness `ue.build` 路由。可先用 `PlanOnly` 检查完整命令，再去掉该开关执行：

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
  TimeoutMs = 180000
  PlanOnly = $true
}
```

Harness 会读取 `AgentConfig.ini`，并为每次运行创建独立记录和日志。详见 `.agents/skills/unreal-engine-develop/SKILL.md`；根 `Tools` PowerShell wrapper 是旧入口，不是回退入口。

### 4. 运行测试

UE Automation 与具名 suite 统一使用 Harness `ue.test` / `ue.suite.run` 路由：

```powershell
# 跑一个精确 Automation 前缀
Invoke-Harness -Command ue.test -Context $context -Parameters @{
  TestPrefix = 'Angelscript.TestModule.Bindings.'
  TimeoutMs = 600000
}

# 跑配置中的具名 suite
Invoke-Harness -Command ue.suite.run -Context $context -Parameters @{
  Suite = 'All'
  TimeoutMs = 600000
}
```

先用对应路由的 `PlanOnly` 检查选择和执行参数。Standalone、coverage、package、release、CachePackage 与完整 StaticJIT pipeline 仍是独立 deferred capability，不会回退到根 `Tools` wrapper。

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
| `AGENTS.md` | AI Agent / 协作者的唯一项目级入口；详细规则渐进路由到 Skills 与 OpenSpec specs |
| `.agents/skills/README.md` | Harness + OpenSpec 协作流程与项目技能适配说明 |
| `Documents/Knowledges/ZH/Index.md` | 知识库主索引，按主题前缀组织所有原理性文档 |
| `Documents/Guides/Build.md` | 构建规则、超时约束、并发安全 |
| `Documents/Guides/Test.md` | 测试入口与超时约束 |
| `Documents/Guides/OpenSpecSystemRefactor.md` | OpenSpec Rust 内核、Web 预览、独立 Skill 与 spec 重基线边界 |
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

对于明确采用 OpenSpec 的工作，活动 Change 是计划、任务与收口状态的权威记录；便携 CLI 负责确定性的记录操作，Harness 负责探索、执行、显式 review、replan 与 closure 策略。重构期的既有 current spec 仍需与代码、测试和最新有效 Change 交叉核对。相关工作统一进入 `openspec/changes/<domain>/<change>/`：

- `brainstorming`：以 grilling 轮次探索并把讨论、探索、命名全部记录到 `openspec/drafts/`，最终草稿为 designed / parked / abandoned 之一。
- `openspec-create-change`：从 designed 草稿创建 Change，并把草稿副本、用户确认的 talks 与 knowledge 候选、INDEX 一次性落进 attachments。
- `openspec-update-change`：在证据门禁下修订现有规划真相（缺失的规划产物由 `openspec-apply-change` 的 `Ensure plan` 步骤补齐）。
- `openspec-apply-change` / `openspec-verify-change`：按 Ready Task DAG 实施，并对固定快照验证。
- `openspec-sync-specs` / `openspec-archive-change`：显式同步 durable spec，并按 closure policy 归档。

Plan-only 是完整交付：proposal/spec/design/tasks 必须达到可直接执行的质量再停下。归档是显式 closure gate，不会自动合并 spec、Git 分支、推送或删除 worktree。

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
2. **计划/记录走 OpenSpec**。重大工作先在 Change 创建前完成 `brainstorming`（草稿留在 `openspec/drafts/`），再进入 continue/update/apply/verify/sync/archive 生命周期；`tasks.md` 是唯一 Task DAG 与执行状态，附件只保存按需加载的证据和决策。
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
- Harness / OpenSpec 协作说明：`.agents/skills/README.md`
- OpenSpec Rust 核心、Web 预览与 Skill 解耦重构记录：`Documents/Guides/OpenSpecSystemRefactor.md`
- 历史优先级路线图：`Documents/Plans/Plan_StatusPriorityRoadmap.md`
