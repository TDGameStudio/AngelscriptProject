# Tools

## 官方入口

标准入口只保留四类：

- `Tools\Bootstrap\BootstrapWorktree.bat`：初始化或规范化当前 worktree 的 `AgentConfig.ini`
- `Tools\Diagnostics\ResolveAgentCommandTemplates.bat`：生成给 AI Agent/脚本使用的官方命令模板
- `Tools\RunBuild.ps1`：标准构建入口
- `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1`：标准自动化测试入口

其它脚本只承担诊断、摘要、兼容或自测职责，不应在新文档中取代官方入口。

## 工具总览

| 工具 | 路径 | 用途 | 常用命令 | 主要输出 | 备注 |
| --- | --- | --- | --- | --- | --- |
| BootstrapWorktree | `Tools\Bootstrap\powershell\BootstrapWorktree.ps1` | 初始化当前 worktree，规范化 `AgentConfig.ini`，并按需预热 `TargetInfo.json` | `Tools\Bootstrap\BootstrapWorktree.bat` | `AgentConfig.ini`、`Intermediate\TargetInfo.json` | 新 worktree 优先使用 |
| ResolveAgentCommandTemplates | `Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1` | 输出官方 build/test/bootstrap 命令模板 | `Tools\Diagnostics\ResolveAgentCommandTemplates.bat` | `Status=...` + 一组命令模板 | 配置缺失时先返回 `BootstrapCommand`；配置就绪时返回 `BuildCommand`、`NoXgeBuildCommand`、`SerializedBuildCommand` |
| RunBuild | `Tools\RunBuild.ps1` | 标准 UBT 构建入口，支持多 worktree 并发与引擎级串行锁 | `Tools\RunBuild.ps1 -Label agent-build -TimeoutMs 180000` | `Saved/Build/<Label>/<RunId>/` | 自动写 `Build.log`、`UBT.log` 与 `RunMetadata.json`；内建 `-NoXGE`，并显式禁止 `-UniqueBuildEnvironment` |
| RunTests | `Tools\RunTests.ps1` | 标准自动化测试入口，负责日志、报告、摘要与超时清理 | `Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000` | `Saved/Tests/<Label>/<RunId>/` | 自动写 `Automation.log`、`Report/`、`Summary.json` |
| RunTestSuite | `Tools\RunTestSuite.ps1` | 按具名 suite 顺序执行一组标准测试前缀 | `Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000` | 多个 `Saved/Tests/<Label>/<RunId>/` 子目录 | 只做调度，底层仍调用 `RunTests.ps1` |
| Get-UbtProcess | `Tools\Diagnostics\powershell\Get-UbtProcess.ps1` | 枚举本机 UBT / `Build.bat` / `RunUBT.bat` 相关进程，帮助排查争用 | `Tools\Diagnostics\Get-UbtProcess.bat -CurrentWorktreeOnly` | 控制台列表 | 用于定位旧流程或残留进程 |
| GetAutomationReportSummary | `Tools\GetAutomationReportSummary.ps1` | 根据 `Report/` 与 `Automation.log` 生成轻量摘要 | `Tools\GetAutomationReportSummary.ps1 -ReportPath <dir> -LogPath <log>` | `Summary.json` 或 stdout 对象 | 用于识别假绿与失败详情 |
| PullReference | `Tools\PullReference\PullReference.bat` | 拉取或同步参考仓库 | `Tools\PullReference\PullReference.bat angelscript` / `hazelightdocs` / `unrealcsharp` / `unlua` / `puerts` / `sluaunreal` | `Reference\...` | 不参与默认 build/test 流程 |
| GenerateAgentConfigTemplate | `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` | 生成本机模板版 `AgentConfig.ini` | `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` | `AgentConfig.ini` | 仍可用，但新 worktree 更推荐 `Tools\Bootstrap\BootstrapWorktree.bat` |
| RunAutomationTests (legacy) | `Tools\RunAutomationTests.ps1` / `Tools\RunAutomationTests.bat` | 兼容旧脚本的过渡包装层 | 无 | 兼容旧产物布局 | 保留兼容，不作为官方入口 |
| RunToolingSmokeTests | `Tools\Tests\RunToolingSmokeTests.ps1` | 自测 bootstrap、模板解析、输出布局、超时与进程清理 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\RunToolingSmokeTests.ps1` | 控制台 PASS/FAIL | 不依赖 Pester |
| AutomationToolSelfTests | `Tools\Tests\AutomationToolSelfTests.ps1` | 自测自动化报告摘要与 legacy runner 包装层 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\AutomationToolSelfTests.ps1` | 控制台 PASS/FAIL | 主要覆盖兼容层 |
| PolicyAuditSmokeTests | `Tools\Tests\PolicyAuditSmokeTests.ps1` | 审计 live 文档与计划中的旧入口示例，防止回退到 `Build.bat` / 直调编辑器 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\PolicyAuditSmokeTests.ps1` | 控制台 PASS/FAIL | 覆盖 `Documents/Guides/`、`Documents/Plans/` 等 live 文档 |
| RunReferenceComparison | `Tools\ReferenceComparison\RunReferenceComparison.bat` / `Tools\ReferenceComparison\powershell\RunReferenceComparison.ps1` | 多轮迭代 AI 探索 Reference 中的 UE 脚本插件，输出对比分析文档 | `Tools\ReferenceComparison\RunReferenceComparison.bat` | `Documents\Comparisons\<yyyy-MM-dd>\` | 需要 Python 3.8+ 和 opencode CLI |
| ReferenceComparisonSelfTests | `Tools\ReferenceComparison\tests\ReferenceComparisonSelfTests.ps1` | 自测 Reference 对比工具文件结构、Python 导入、Preview/DryRun 模式 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\ReferenceComparison\tests\ReferenceComparisonSelfTests.ps1` | 控制台 PASS/FAIL | 需要 Python 3.8+ |
| RunIterationAnalysis | `Tools\IterationAnalysis\RunIterationAnalysis.bat` / `Tools\IterationAnalysis\powershell\RunIterationAnalysis.ps1` | 多轮迭代 AI 分析活跃 Plan，产出评估、任务分解与行动汇总文档 | `Tools\IterationAnalysis\RunIterationAnalysis.bat` | `Documents\Iterations\<yyyy-MM-dd>\` | 需要 Python 3.8+ 和 opencode CLI |
| IterationAnalysisSelfTests | `Tools\IterationAnalysis\tests\IterationAnalysisSelfTests.ps1` | 自测迭代分析工具文件结构、Python 导入、Preview/DryRun 模式 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\IterationAnalysis\tests\IterationAnalysisSelfTests.ps1` | 控制台 PASS/FAIL | 需要 Python 3.8+ |

## BootstrapWorktree.ps1

## BlueprintImpactScanCommandlet

| 项目 | 说明 |
| --- | --- |
| 入口位置 | `Plugins\Angelscript\Source\AngelscriptEditor\BlueprintImpact\AngelscriptBlueprintImpactScanCommandlet.cpp` |
| 主要用途 | 扫描项目中的 Blueprint 资产，并报告哪些资产受给定 Angelscript 脚本变更影响。 |
| 依赖 | 当前 worktree 根目录 `AgentConfig.ini`、已成功初始化的 `FAngelscriptEngine`、`AssetRegistry` |
| 典型参数 | `-ChangedScript="Foo.as;Bar.as"`、`-ChangedScriptFile="<path>"` |
| 输出 | 日志摘要（扫描模式、变更脚本数、命中模块数、候选资产数、命中资产数、失败加载数）以及逐资产命中原因 |

### 使用示例

```powershell
J:\UnrealEngine\UERelease\Engine\Binaries\Win64\UnrealEditor-Cmd.exe <ProjectFile> -run=AngelscriptBlueprintImpactScan -stdout -FullStdOutLogOutput -Unattended -NoPause -NoSplash -NullRHI
J:\UnrealEngine\UERelease\Engine\Binaries\Win64\UnrealEditor-Cmd.exe <ProjectFile> -run=AngelscriptBlueprintImpactScan -ChangedScript="Foo.as;Bar.as" -stdout -FullStdOutLogOutput -Unattended -NoPause -NoSplash -NullRHI
J:\UnrealEngine\UERelease\Engine\Binaries\Win64\UnrealEditor-Cmd.exe <ProjectFile> -run=AngelscriptBlueprintImpactScan -ChangedScriptFile="J:\Temp\changed-scripts.txt" -stdout -FullStdOutLogOutput -Unattended -NoPause -NoSplash -NullRHI
```

`<ProjectFile>` 应来自当前 worktree 的 `AgentConfig.ini`，不要复用其他 worktree 的 `.uproject` 路径。

## GenerateAgentConfigTemplate.bat

| 项目 | 说明 |
| --- | --- |
| 工具路径 | `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` |
| 主要用途 | 为当前 worktree 创建或规范化 `AgentConfig.ini`，并预热 `TargetInfo.json` |
| 常用参数 | `-AllRegisteredWorktrees`、`-EngineRoot`、`-NoPrewarm`、`-Force` |
| 推荐场景 | 新建 worktree、发现 `ProjectFile` 指向了其他 worktree、缺少默认超时配置 |

示例：

```powershell
Tools\Bootstrap\BootstrapWorktree.bat
Tools\Bootstrap\BootstrapWorktree.bat -AllRegisteredWorktrees
Tools\Bootstrap\BootstrapWorktree.bat -EngineRoot "J:\UnrealEngine\UERelease" -NoPrewarm
```

## ResolveAgentCommandTemplates.ps1

| 项目 | 说明 |
| --- | --- |
| 工具路径 | `Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1` |
| 主要用途 | 输出当前 worktree 的 bootstrap/build/test 官方命令模板 |
| 输出模式 | `Status=BootstrapRequired` 或 `Status=Ready` |
| 关键字段 | `BootstrapCommand`、`BuildCommand`、`NoXgeBuildCommand`、`SerializedBuildCommand`、`TestCommand`、`TestSuiteSmokeCommand` |

说明：

- 当 `AgentConfig.ini` 缺失或不属于当前 worktree 时，脚本不会再把调用方导向旧入口，而是先返回 `BootstrapCommand`
- 当配置就绪时，所有模板都显式包含超时，并且只引用官方 runner

## RunBuild.ps1

| 项目 | 说明 |
| --- | --- |
| 工具路径 | `Tools\RunBuild.ps1` |
| 主要用途 | 通过 `dotnet + UnrealBuildTool.dll` 执行标准构建 |
| 关键参数 | `-TimeoutMs`、`-Label`、`-LogRoot`、`-SerializeByEngine`、`-NoXGE` |
| 默认输出 | `Saved/Build/<Label>/<RunId>/Build.log`、`UBT.log`、`RunMetadata.json` |
| 关键保护 | worktree 单飞锁、引擎级串行锁、实时日志、超时后清理进程树 |

示例：

```powershell
Tools\RunBuild.ps1 -Label agent-build -TimeoutMs 180000
Tools\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine
Tools\RunBuild.ps1 -Label noxge -TimeoutMs 180000 -NoXGE
```

## RunTests.ps1

| 项目 | 说明 |
| --- | --- |
| 工具路径 | `Tools\RunTests.ps1` |
| 主要用途 | 运行单条前缀或单个 automation group，并生成日志、报告、摘要 |
| 关键参数 | `-TestPrefix`、`-Group`、`-Label`、`-OutputRoot`、`-TimeoutMs`、`-Render`、`-NoReport` |
| 默认输出 | `Saved/Tests/<Label>/<RunId>/Automation.log`、`Report/`、`RunMetadata.json`、`Summary.json` |
| 关键保护 | `TargetInfo.json` 预热、旧 `Build.bat` 锁防御等待、worktree 单飞锁、超时后清理进程树 |

示例：

```powershell
Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings -TimeoutMs 600000
Tools\RunTests.ps1 -Group AngelscriptFunctional -Label functional -TimeoutMs 900000 -Render
```

## RunTestSuite.ps1

| 项目 | 说明 |
| --- | --- |
| 工具路径 | `Tools\RunTestSuite.ps1` |
| 主要用途 | 顺序执行内置 suite 中的一组标准前缀 |
| 关键参数 | `-Suite`、`-LabelPrefix`、`-TimeoutMs`、`-OutputRoot`、`-NoReport`、`-ListSuites`、`-DryRun` |
| 输出行为 | 每个子 run 仍按 `RunTests.ps1` 生成独立输出目录 |

示例：

```powershell
Tools\RunTestSuite.ps1 -ListSuites
Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
Tools\RunTestSuite.ps1 -Suite Debugger -LabelPrefix debugger -TimeoutMs 600000 -DryRun
```

## legacy 兼容层

| 工具 | 说明 |
| --- | --- |
| `Tools\RunAutomationTests.ps1` | 旧 PowerShell 兼容层，内部仍会转到新测试 runner |
| `Tools\RunAutomationTests.bat` | 旧 batch 兼容层，仅做参数转发 |

约束：

- 这两者只用于兼容已有脚本或历史 CI
- 新文档、新计划、新提示词不再提供它们的可执行命令示例
- 需要标准入口时，一律回到 `RunTests.ps1` / `RunTestSuite.ps1`

## 自测脚本

| 脚本 | 重点覆盖 |
| --- | --- |
| `Tools\Tests\RunToolingSmokeTests.ps1` | bootstrap、超时预算、输出目录隔离、命令模板回退、suite 参数透传 |
| `Tools\Tests\AutomationToolSelfTests.ps1` | `GetAutomationReportSummary.ps1` 与 legacy runner 兼容性 |
| `Tools\Tests\PolicyAuditSmokeTests.ps1` | 文档/计划里的旧入口、错误输出路径、共享日志示例 |
| `Tools\PullReference\tests\PullReferenceSelfTests.ps1` | `PullReference.bat` 的 list/usage 输出与可选真实拉取回归 |
| `Tools\Review\tests\ReviewLauncherSelfTests.ps1` | Review 启动器 Preview 模式、bat 参数转发 |
| `Tools\ReferenceComparison\tests\ReferenceComparisonSelfTests.ps1` | Reference 对比工具文件结构、Python 导入、Preview/DryRun 模式、规则文档完整性 |

推荐在修改构建/测试工具后依次执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\RunToolingSmokeTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\AutomationToolSelfTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Tests\PolicyAuditSmokeTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\PullReference\tests\PullReferenceSelfTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Review\tests\ReviewLauncherSelfTests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\ReferenceComparison\tests\ReferenceComparisonSelfTests.ps1
```

## Review 快捷入口

| 工具 | 路径 | 用途 | 常用命令 | 主要输出 | 备注 |
| --- | --- | --- | --- | --- | --- |
| RunMainBranchReview | `Tools\Review\RunMainBranchReview.bat` / `Tools\Review\powershell\RunMainBranchReview.ps1` | 一键触发主干全面审核，并要求遵循 `Documents\Rules\ReviewRule_ZH.md` | `Tools\Review\RunMainBranchReview.bat` | `Documents\Reviews\Review_<yyyy-MM-dd_HH-mm-ss>.md`、`Documents\Reviews\run.log` | 便捷包装入口，不替代官方 build/test runner |

说明：

- 默认调用 `opencode run --agent Hephaestus --model codez-gpt/gpt-5.4 --variant xhigh --command ralph-loop`
- 默认把审核产物写到 `Documents\Reviews\Review_<yyyy-MM-dd_HH-mm-ss>.md`
- 默认把控制台输出同步写到 `Documents\Reviews\run.log`，每次运行覆盖上一次内容
- 若需附加限制，可在命令后继续追加文本参数，例如 `Tools\Review\RunMainBranchReview.bat 仅聚焦 Dump 与 Test 模块`

## Reference 对比分析

| 工具 | 路径 | 用途 | 常用命令 | 主要输出 | 备注 |
| --- | --- | --- | --- | --- | --- |
| RunReferenceComparison | `Tools\ReferenceComparison\RunReferenceComparison.bat` / `Tools\ReferenceComparison\powershell\RunReferenceComparison.ps1` | 多轮迭代 AI 探索 Reference 中的 UE 脚本插件，输出对比分析文档 | `Tools\ReferenceComparison\RunReferenceComparison.bat` | `Documents\Comparisons\<yyyy-MM-dd>\` | 需要 Python 3.8+ 和 opencode CLI |

### 前置依赖

- **Python 3.8+**：确保 `python` 在 PATH 中
- **opencode CLI**：确保 `opencode` 在 PATH 中，且已配置 `ralph-loop` command
- **AgentConfig.ini**：Hazelight 分析需要配置 `References.HazelightAngelscriptEngineRoot`
- **Reference 仓库**：不存在时自动调用 `Tools\PullReference\PullReference.bat` 拉取（Hazelight 除外，走 AgentConfig.ini）

### 工作原理

通过 `opencode run --command ralph-loop` 调用 AI，多轮迭代探索（生成 → 读取 → 深入补充）逐步加深文档：

```
Round 1: 扫描源码 → 生成文档骨架
Round 2: 读取 Round 1 产出 → 识别薄弱处 → 就地补充深化
Round 3: 读取 Round 2 产出 → 填充剩余空白 → 最终深化
```

三阶段流程：

```
Phase 1: 按仓库纵向分析 → 每个 Reference 独立文档
Phase 2: 按维度横向对比 → 跨仓库同一维度对比
Phase 3: 差距分析        → 整合为 GapAnalysis 建议
```

规则文档：`Documents\Rules\ReferenceComparisonRule_ZH.md`

### 覆盖范围

**5 个参考仓库：**

| Key | 名称 | 路径来源 |
| --- | --- | --- |
| `hazelight` | Hazelight-Angelscript | `AgentConfig.ini` → `References.HazelightAngelscriptEngineRoot` |
| `unrealcsharp` | UnrealCSharp | `Reference\UnrealCSharp`（自动拉取） |
| `unlua` | UnLua | `Reference\UnLua`（自动拉取） |
| `puerts` | puerts | `Reference\puerts`（自动拉取） |
| `sluaunreal` | sluaunreal | `Reference\sluaunreal`（自动拉取） |

**11 个对比维度：**

| ID | 维度 |
| --- | --- |
| D1 | 插件架构与模块划分 |
| D2 | 反射绑定与类型映射 |
| D3 | Blueprint 互操作 |
| D4 | 热重载 / 热更新机制 |
| D5 | 调试与诊断能力 |
| D6 | 代码生成管线 |
| D7 | 编辑器集成 |
| D8 | 性能优化策略 |
| D9 | 测试基础设施 |
| D10 | 文档与示例组织 |
| D11 | 部署与分发策略 |

### 参数说明

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `-Repos` | 全部 5 个 | 指定分析哪些仓库，空格分隔 |
| `-Dimensions` | 全部 11 个 | 指定维度，空格分隔 |
| `-MaxIterations` | `3` | 每篇文档的迭代探索轮数（轮数越多越深入，耗时成正比） |
| `-Timeout` | `600` | 每次 opencode 调用的超时秒数 |
| `-DateSuffix` | 今天日期 | 自定义输出子目录名（YYYY-MM-DD） |
| `-Preview` | — | 只打印配置信息，不执行 |
| `-DryRun` | — | 模拟运行，记录命令但不调用 opencode |
| `-VerboseLog` | — | 开启 DEBUG 级别日志 |

### 使用示例
```powershell
# 全量扫描（5 个仓库 × 11 个维度，默认 3 轮迭代）
Tools\ReferenceComparison\RunReferenceComparison.bat

# 只分析 Hazelight，只看架构维度，迭代 2 轮
Tools\ReferenceComparison\RunReferenceComparison.bat -Repos hazelight -Dimensions D1 -MaxIterations 2

# 分析 UnLua 和 puerts，多维度，深度 5 轮
Tools\ReferenceComparison\RunReferenceComparison.bat -Repos unlua puerts -Dimensions D1 D2 D5 -MaxIterations 5

# 快速单轮扫描所有仓库的热重载维度
Tools\ReferenceComparison\RunReferenceComparison.bat -Dimensions D4 -MaxIterations 1

# 增加超时（适合深度探索大型仓库）
Tools\ReferenceComparison\RunReferenceComparison.bat -Repos hazelight -MaxIterations 3 -Timeout 900

# 预览配置（不执行）
Tools\ReferenceComparison\RunReferenceComparison.bat -Preview

# Dry-run（记录 prompt 但不调用 opencode）
Tools\ReferenceComparison\RunReferenceComparison.bat -DryRun -VerboseLog
```

### 输出目录结构

```
Documents\Comparisons\2026-04-06\
├── run.log                              ← 完整运行日志（含时间戳和每步进度）
├── _prompts\
│   ├── call_001_prompt.md               ← 每次 opencode 调用的完整 prompt
│   ├── call_002_prompt.md
│   └── ...
├── 00_Hazelight-Angelscript_Analysis.md ← Phase 1: 纵向分析
├── 01_UnrealCSharp_Analysis.md
├── 02_UnLua_Analysis.md
├── 03_puerts_Analysis.md
├── 04_sluaunreal_Analysis.md
├── 05_CrossComparison_Architecture.md   ← Phase 2: 横向对比
├── 06_CrossComparison_ReflectionBinding.md
├── ...
└── Summary_GapAnalysis.md               ← Phase 3: 差距分析
```

### 耗时参考

- 单个仓库 + 单个维度 + 1 轮迭代 ≈ 5-10 分钟
- 全量扫描（5 仓库 × 11 维度 × 3 轮迭代）≈ 数小时
- 建议首次使用时先用少量范围试跑：`-Repos hazelight -Dimensions D1 -MaxIterations 1`

---

## RunIterationAnalysis

### 路径

- BAT 入口：`Tools\IterationAnalysis\RunIterationAnalysis.bat`
- PS1 编排器：`Tools\IterationAnalysis\powershell\RunIterationAnalysis.ps1`
- Python 核心：`Tools\IterationAnalysis\python\IterationAnalysis\main.py`
- 规则文档：`Documents\Rules\IterationAnalysisRule_ZH.md`

### 用途

自动扫描 `Documents/Plans/` 下的活跃 Plan，通过多轮 AI 迭代分析，产出三类文档：

1. **评估文档**（Phase 1）：对每个 Plan 的任务逐项核实实际完成状态，标注偏差
2. **分解文档**（Phase 2）：对未完成任务生成具体文件修改步骤和 unified diff
3. **行动汇总**（Phase 3）：跨 Plan 优先级排序、文件影响矩阵和建议执行顺序

### 依赖

- Python 3.8+
- `opencode` CLI（PATH 中可用）
- `Documents/Rules/IterationAnalysisRule_ZH.md`

### 参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `-Plans` | 全部活跃 Plan | 指定分析哪些 Plan（空格分隔 topic 名） |
| `-MaxIterations` | `3` | 每篇文档的迭代探索轮数 |
| `-Timeout` | `600` | 每次 opencode 调用的超时秒数 |
| `-DateSuffix` | 今天日期 | 自定义输出子目录名 |
| `-Preview` | - | 只打印配置信息，不执行 |
| `-DryRun` | - | 模拟运行，记录命令但不调用 opencode |
| `-AssessmentOnly` | - | 只运行 Phase 1 |
| `-SkipAssessment` | - | 跳过 Phase 1，直接从 Phase 2 开始 |
| `-VerboseLog` | - | 开启 DEBUG 级别日志 |

### 快捷入口

- `RunIterationAnalysis_KnownFixes.bat`：只分析 `KnownTestFailureFixes` Plan
- `RunIterationAnalysis_Roadmap.bat`：只分析 `StatusPriorityRoadmap` Plan

### 常用命令

```powershell
# 预览配置
Tools\IterationAnalysis\RunIterationAnalysis.bat -Preview

# Dry-run（记录 prompt 但不调用 opencode）
Tools\IterationAnalysis\RunIterationAnalysis.bat -DryRun

# 只分析一个 Plan，1 轮迭代
Tools\IterationAnalysis\RunIterationAnalysis.bat -Plans KnownTestFailureFixes -MaxIterations 1

# 全量分析（48 Plan × 3 轮 × 3 阶段）
Tools\IterationAnalysis\RunIterationAnalysis.bat

# 只运行评估阶段
Tools\IterationAnalysis\RunIterationAnalysis.bat -AssessmentOnly

# 跳过评估，使用已有结果做分解和汇总
Tools\IterationAnalysis\RunIterationAnalysis.bat -SkipAssessment
```

### 输出目录结构

```
Documents\Iterations\2026-04-06\
├── run.log                                      ← 完整运行日志
├── _prompts\
│   ├── call_001_prompt.md                       ← 每次 AI 调用的完整 prompt
│   └── ...
├── _outputs\
│   ├── call_001_output.md                       ← 每次 AI 调用的完整输出
│   └── ...
├── 00_Assessment_KnownTestFailureFixes.md       ← Phase 1: 计划评估
├── 00_Assessment_StatusPriorityRoadmap.md
├── 01_Decomposition_KnownTestFailureFixes.md    ← Phase 2: 任务分解
├── 01_Decomposition_StatusPriorityRoadmap.md
└── Summary_ActionPlan.md                        ← Phase 3: 行动汇总
```

### 耗时参考

- 单个 Plan + 1 轮迭代 ≈ 5-10 分钟
- 全量扫描（48 Plan × 3 轮迭代 × 3 阶段）≈ 数小时
- 建议首次使用时先用少量范围试跑：`-Plans KnownTestFailureFixes -MaxIterations 1`

### 自测

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\IterationAnalysis\tests\IterationAnalysisSelfTests.ps1
```

