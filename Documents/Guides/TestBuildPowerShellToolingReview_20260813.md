# 构建与测试 PowerShell 工具链 Review

> 日期：2026-08-13
> 范围：`Tools/RunBuild.ps1`、`Tools/RunTests.ps1`、`Tools/RunTestSuite*.ps1`、`Tools/Shared/`、相关诊断/自测工具，以及约束 AI Agent 执行方式的仓库文档与技能
> 方法：静态调用链审查、PowerShell 语法解析、自测执行、`-DryRun` 最小复现、Git 历史检查、现有 `Saved/Tests` 工件对比
> 性质：只读审计与实施就绪建议；本报告不修改任何 PowerShell 行为，不等同于已经完成工具改造
> OpenSpec：本次仅新增一份审计报告，不改变行为、架构或公共 API，因此未创建 OpenSpec change；后续实施建议单独立项

## 1. 执行摘要

当前很多 AI Agent 在执行“全量测试”时选择逐项串行，并不是因为它们不知道并行，也不主要是因为 Unreal Automation 天生只能串行，而是因为仓库的**治理层、官方入口、命令模板和历史任务记录共同把串行路径定义成了标准路径**。

最直接的因果链是：

```text
AGENTS / Test.md / Tool.md / openspec-work / agent prompt
                         │
                         ▼
       “官方 suite 入口 = Tools\RunTestSuite.ps1”
                         │
                         ▼
           for 循环同步调用 RunTests.ps1
                         │
                         ▼
            ExecutionSlot=0，共用 worktree mutex
                         │
                         ▼
                      串行执行
```

仓库确实已有两条并行路径：

- `Tools/RunTestSuiteParallel.ps1`
- `Tools/RunTestSuiteFast.ps1`

它们也确实能够缩短 wall time。现有工件显示：

- 2026-08-09 的标准串行 `All`，35 个 UE bucket 连续执行约 `41.86` 分钟，随后另跑 Standalone；
- 2026-08-12 的 `CoarseDynamic` 4-slot 全量，37 个 shard、`3090/3090 PASS`，wall time 为 `18.25` 分钟；
- 该并行运行中，单个 Cache shard 就耗时 `17.44` 分钟，因此文档中的稳定 `5–8` 分钟全量目标已经不符合当前测试规模。

但是，Parallel/Fast 目前没有被列入完整的官方入口集合，而且还存在若干必须先解决的契约缺陷：

1. `CoarseDynamic` 不遵守 `MaxParallelHeavy`；
2. 默认策略下 `-Suite` 可能被静默忽略并实际运行 `All`；
3. `RunTestSuiteFast.ps1` 的实现与文档描述不是同一种分片模型；
4. parallel slot 绕过了 build/test 的同 worktree 排他锁，理论上允许同一 checkout 一边构建、一边启动 Editor 测试；
5. 并行自测只验证基础调度，没有验证实际峰值并发、资源上限和 build/test 互斥；
6. `-DryRun` 会因调度轮询无意义地等待约 40 秒；
7. 自定义 `OutputRoot` 下的聚合查找仍硬编码扫描 `Saved/Tests`；
8. 超时、恢复、重试、运行状态、孤儿进程、策略等价性等运维能力缺少统一契约。

因此，本报告的核心建议不是简单地“告诉 Agent 下次记得跑 Parallel”，而是：

> 将并发策略合并进唯一的官方 `RunTestSuite.ps1`，让 `-Suite All` 在明确、可验证、资源受控的条件下默认走并行；把串行变成显式诊断/资源受限模式；同时建立 suite 级 build/test 排他协调、统一摘要、恢复重试和完整的调度自测。

## 2. 关键结论与优先级

| 优先级 | 结论 | 影响 |
| --- | --- | --- |
| P0 | 仓库治理层只正式认可 `RunTestSuite.ps1`，而该脚本实现为同步串行 | Agent 遵守规则时自然选择串行 |
| P0 | `CoarseDynamic` 固定 slot 分支不检查 `MaxParallelHeavy` | 参数显示已限流，实际仍可启动多个 Heavy Editor |
| P0 | `-Suite` 只在 `Fine` 策略中真正生效 | `-Suite Smoke` 配默认策略可能意外运行 `All` |
| P0 | parallel test slot 与 build 的 worktree mutex 不互斥 | 同一 checkout 的 DLL/Intermediate 可能被构建和 Editor 同时访问 |
| P0 | 应统一官方 suite 入口，而不是继续维护三个相互漂移的公开入口 | 消除文档、技能、模板和实现之间的长期漂移 |
| P1 | Fast wrapper 与 Test.md 的 strategy、shard 数、Standalone/slow-suite 范围不一致 | “Fast 全量”语义不可靠，Agent 无法判断是否满足正式验证要求 |
| P1 | 当前调度自测不验证真实并发契约 | 并发上限失效仍能全部自测通过 |
| P1 | 缺少 suite 级总超时、恢复、失败重跑和运行状态工具 | 长跑被中断后只能靠临时脚本和人工判断续跑 |
| P1 | 官方 agent 命令模板不输出 parallel/fast/full-suite 命令 | 自动化提示持续强化串行入口 |
| P2 | DryRun 会进入 polling/sleep 路径 | 计划预览和自测无意义地多等待约 40 秒 |
| P2 | timing、resume、entry-point audit 已有临时工具，但各自硬编码旧模型 | 容易形成第二份 catalog 和过期结论 |
| P2 | Tool.md 声称存在的三份 `Tools/Tests/*.ps1` 当前不存在 | 工具文档不能作为可靠的可执行索引 |
| P2 | `GetAutomationReportSummary.ps1` 定义了两次同名 `Get-LogFailureHints` | 前一个实现被后一个覆盖，维护者容易误判实际日志规则 |
| P2 | 当前环境没有 `PSScriptAnalyzer` | 缺少统一、可重复的 PowerShell 静态检查入口 |

## 3. 审计范围与边界

### 3.1 重点审查文件

构建入口：

- `Tools/RunBuild.ps1`
- `Tools/Shared/UnrealCommandUtils.ps1`
- `Documents/Guides/Build.md`

测试入口与调度：

- `Tools/RunTests.ps1`
- `Tools/RunTestSuite.ps1`
- `Tools/RunTestSuiteParallel.ps1`
- `Tools/RunTestSuiteFast.ps1`
- `Tools/RunTestSuiteEntry.ps1`
- `Tools/Shared/TestSuiteDefinitions.ps1`
- `Tools/Shared/TestSuiteEntryRunner.ps1`
- `Tools/Shared/TestShardPlanner.ps1`
- `Tools/Shared/TestLaunchProfile.ps1`
- `Tools/GetAutomationReportSummary.ps1`

诊断与自测：

- `Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1`
- `Tools/Diagnostics/powershell/AnalyzeTestRunTiming.ps1`
- `Tools/Diagnostics/powershell/RunRemainingAllSuite.ps1`
- `Tools/Diagnostics/powershell/Test-AutomationEntryPoints.ps1`
- `Tools/Diagnostics/powershell/Get-UbtProcess.ps1`
- `Tools/Diagnostics/tests/RunBuildSelfTests.ps1`
- `Tools/Diagnostics/tests/RunTestSuiteSelfTests.ps1`
- `Tools/Diagnostics/tests/RunTestSuiteParallelSelfTests.ps1`
- `Tools/Diagnostics/tests/TestAutomationEntryPointsSelfTests.ps1`

Agent 治理与提示：

- `AGENTS.md`
- `AGENTS_ZH.md`
- `Documents/Guides/Test.md`
- `Documents/Tools/Tool.md`
- `.agents/skills/README.md`
- `.agents/skills/openspec-work/SKILL.md`
- `Tools/ImplementTestCoverage/RunImplementTestCoverage.ps1`
- 非 archive `openspec/changes/**/*.md`

### 3.2 本报告不做的事情

- 不修改 PowerShell 脚本；
- 不调整 UE Automation 测试本身；
- 不创建或切换 git worktree；
- 不运行真实 UBT build；
- 不重新执行 UE 全量测试；
- 不把现有工件当成严格的同代码版本 A/B benchmark；
- 不假设增加 worker 就一定缩短 wall time，尤其不忽略内存、I/O 和共享 Engine/Intermediate 争用。

## 4. 当前工具地图

### 4.1 官方或近似官方入口

| 工具 | 当前角色 | 并发行为 | 主要产物 | 审计结论 |
| --- | --- | --- | --- | --- |
| `Tools/RunBuild.ps1` | 标准 UBT build runner | 同 worktree 单飞；不同 worktree 默认可并发；可用 `SerializeByEngine` 加 EngineRoot 锁 | `Saved/Build/<Label>/<RunId>/` | 基础设计清晰，需补行为型自测和与 parallel tests 的互斥协调 |
| `Tools/RunTests.ps1` | 单前缀/单 group Automation runner | 默认 slot 0 单飞；非零 slot 可并发 | `Saved/Tests/<Label>/<RunId>/` | 日志、摘要、超时和进程树清理较完整；slot 语义不应直接暴露给普通调用者 |
| `Tools/RunTestSuite.ps1` | 具名 suite 官方调度器 | 严格串行 | 多个测试目录；没有统一 serial suite summary | 当前 Agent 运行全量串行的直接执行层原因 |
| `Tools/RunTestSuiteParallel.ps1` | 另立的并行 suite runner | 多 PowerShell/Editor 进程；支持固定 slot 或 tier slot pool | `ParallelSuiteSummary.json`、`WorkerPlan.json` | 有价值但未完全官方化，且存在参数契约缺陷 |
| `Tools/RunTestSuiteFast.ps1` | Parallel 的便捷 wrapper | 当前实际为 `CoarseDynamic + 4 workers + Fast` | 同 Parallel | 文件头、实际参数和 Test.md 描述不一致 |
| `Tools/RunCommandlet.ps1` | 标准 commandlet runner | 本次未深入审查其业务参数 | 独立 commandlet 工件 | 可作为统一 runner 设计风格参考 |

### 4.2 已有共享能力

`Tools/Shared/UnrealCommandUtils.ps1` 已经提供了大量可复用基础设施：

- INI 读取与规范化；
- timeout 解析、deadline 和剩余预算；
- UTF-8 JSON 输出；
- 独立 output layout；
- 命名 mutex；
- 参数引用与进程命令行构造；
- process-tree 枚举和强制清理；
- 流式 stdout/stderr；
- UBT/.NET 路径解析；
- `AgentConfig.ini` 解析；
- `TargetInfo.json` prewarm；
- `Build.bat` lock 等待；
- Automation group 解析；
- worktree/UBT 进程诊断。

因此后续改造不应再创建第二套进程、超时、JSON、日志目录或 mutex helper。真正缺的是在这些低层能力上建立**suite 级协调模型和稳定的公开 CLI**。

### 4.3 当前 All catalog

审计时从 `Tools/Shared/TestSuiteDefinitions.ps1` 动态读取：

| 指标 | 当前值 |
| --- | ---: |
| All entry 总数 | 37 |
| UE Automation entry | 36 |
| CMake/CTest entry | 1 |
| Heavy tier | 18 |
| Light tier | 19 |

这组数字应由工具动态输出，不应继续手工写死在恢复脚本、文档表格或 Agent prompt 中。

## 5. 为什么 Agent 经常跑串行全量

### 5.1 治理规则直接把 Parallel/Fast 排除在官方集合外

`Documents/Guides/Test.md` 开头的强制规则规定：

- 标准自动化入口是 `Tools/RunTests.ps1`；
- 具名 suite 只能通过 `Tools/RunTestSuite.ps1` 调度。

而 `RunTestSuite.ps1` 恰好是串行实现。

更强的约束来自 `.agents/skills/openspec-work/SKILL.md`。该技能在验证规则和完成验证章节都只允许：

```powershell
Tools\RunBuild.ps1
Tools\RunTests.ps1
Tools\RunTestSuite.ps1
```

Parallel/Fast 没有进入这个合法集合。Agent 一旦在执行 OpenSpec，就应优先遵守技能，因此选择串行是合规行为，不是能力缺失。

同样的入口集合还出现在：

- `.agents/skills/README.md`
- `Documents/Tools/Tool.md`
- `Tools/Agents.md`
- 根目录 `AGENTS.md` / `AGENTS_ZH.md` 的工具结构描述

### 5.2 最早、最醒目的全量示例就是串行命令

`Documents/Guides/Test.md` 在并行章节之前先给出：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite All `
  -LabelPrefix all `
  -TimeoutMs 600000
```

Agent 通常会按“强制规则 → 标准入口 → 第一个完整示例”的顺序选择命令。三者都指向串行。并行说明虽然存在，但位置更后，而且和“具名 suite 只能通过 RunTestSuite.ps1”存在规则冲突。

### 5.3 标准 suite runner 的实现就是同步 for 循环

`Tools/RunTestSuite.ps1`：

1. 通过 `Get-AngelscriptTestSuiteEntries` 展开 suite；
2. 使用普通 `for` 循环逐项处理；
3. 同步调用 `Invoke-AngelscriptTestSuiteEntry`；
4. UE entry 最终同步执行 `& powershell.exe @arguments | Out-Host`；
5. 只有子进程退出后才进入下一个 entry。

该脚本没有 `Mode`、`Workers`、`MaxParallelTotal` 或类似参数。`All` 的业务含义只是“完整 catalog”，不包含“如何调度”的含义。

### 5.4 普通 RunTests 默认会拒绝同 worktree 手工并发

`RunTests.ps1` 默认 `ExecutionSlot=0`。两个 Agent 手工同时运行普通命令时，它们会竞争相同的 `ue-command-worktree` mutex，其中一个得到：

```text
Another build or test command is already running for this worktree.
```

只有 Parallel runner 会给子进程分配非零 slot。因此，Agent 过去即使尝试并行执行两个 focused prefix，也可能遇到互斥错误，然后形成“同一 worktree 的测试必须串行”的经验。

准确表述应当是：

> 普通调用者使用默认 slot 时必须单飞；官方 suite orchestrator 可以在取得 suite reservation 后，为受控 worker 分配内部 slot。

### 5.5 Agent prompt 把阶段顺序写成了“构建和测试必须严格串行”

`Tools/ImplementTestCoverage/RunImplementTestCoverage.ps1` 一边鼓励并发 Agent 读取和实现，一边明确写着：

> 但构建和测试必须严格串行

它实际想保护的正确顺序是：

```text
完成代码 → build → build 通过 → test
```

但这句话也可以被解释成：

```text
test A → test B → test C → ...
```

后续应改为：

> 构建阶段与测试阶段不得重叠。构建成功后，focused test 默认单进程；完整 suite 使用官方 runner 的受控并发模式，除非任务明确要求串行复现。

### 5.6 非 archive OpenSpec 持续下发串行 All 命令

本次扫描非 archive `openspec/changes/**/*.md`：

- 23 个文件包含 `RunTestSuite.ps1 -Suite All`；
- 0 个文件提到 `RunTestSuiteParallel.ps1` 或 `RunTestSuiteFast.ps1`。

这 23 个文件中既有待执行任务，也有历史验证记录。已完成的历史证据不应被篡改，但仍未完成的任务会继续直接指导 Agent 使用串行入口。

### 5.7 官方命令模板没有全量并行模板

`Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1` 当前只输出：

- `TestCommand`
- `TestSuiteSmokeCommand`

其中 Smoke 也使用串行 `RunTestSuite.ps1`。没有：

- `TestSuiteAllCommand`
- `TestSuiteAllParallelCommand`
- `TestSuiteAllSerialCommand`
- `TestSuiteFastCommand`

因此“只使用官方模板”的 Agent 不会自然发现并行入口。

## 6. 调用链与锁模型

### 6.1 串行 All 调用链

```text
RunTestSuite.ps1 -Suite All
  └─ Get-AngelscriptTestSuiteEntries(All)
      └─ for entry in 37 entries
          └─ Invoke-AngelscriptTestSuiteEntry
              ├─ UnrealAutomation
              │   └─ powershell.exe RunTests.ps1
              │       ├─ ExecutionSlot=0
              │       ├─ acquire mutex(project root)
              │       ├─ prewarm / Build.bat lock wait
              │       ├─ UnrealEditor-Cmd.exe
              │       ├─ Summary.json
              │       └─ release mutex
              └─ CMakeCTest
                  └─ configure → build → ctest
```

每个 UE entry 都产生一次 Editor 冷启动，且进程之间没有重用。

### 6.2 Parallel 调用链

```text
RunTestSuiteParallel.ps1
  ├─ Strategy → worker plan
  ├─ preferred/floating slot
  └─ Start-Process powershell.exe
      └─ RunTests.ps1 -ExecutionSlot N
          ├─ acquire mutex(project root#slot-N)
          ├─ UnrealEditor-Cmd.exe
          └─ release mutex
```

不同 slot 使用不同 mutex，因此可以并发。这也意味着它们不再与 build 使用的 `project root` mutex 冲突。

### 6.3 Build 调用链

```text
RunBuild.ps1
  ├─ acquire mutex(project root)
  ├─ optional acquire mutex(EngineRoot) when SerializeByEngine
  ├─ dotnet UnrealBuildTool.dll
  │   ├─ -NoMutex
  │   └─ -NoEngineChanges unless SerializeByEngine
  ├─ inspect process exit + UBT log
  └─ release mutex
```

普通 test slot 0 与 build 互斥，但 parallel slot N 不与 build 互斥。`RunTests.ps1` 等待的是 `Build.bat` 文件锁，而 `RunBuild.ps1` 直接调用 UBT，不会持有该文件锁。

## 7. 已确认的并行 runner 问题

### 7.1 P0：CoarseDynamic 不遵守 MaxParallelHeavy

`RunTestSuiteParallel.ps1` 的参数和文件头已经出现漂移：

- 文件头说 `MaxParallelHeavy` 默认 `1`；
- 参数实际默认 `4`；
- `Documents/Guides/Test.md` 也说默认 `4`。

更严重的是，在 `CoarseDynamic` 固定 worker 模式中：

- entry 依据 `PreferredSlot` 放入固定 queue；
- scheduler 看到 slot 空闲就直接启动下一项；
- 该分支没有调用 `Test-CanScheduleTier`；
- `MaxParallelHeavy` 只在非固定 slot 分支生效。

最小复现：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuiteParallel.ps1 `
  -Suite All `
  -Strategy CoarseDynamic `
  -TestModuleWorkers 4 `
  -MaxParallelLight 4 `
  -MaxParallelHeavy 1 `
  -TimeoutMs 600000 `
  -DryRun
```

输出显示 `MaxParallelHeavy : 1`，但 Heavy entry 仍分布在 slot 1–4，包括 Editor、GAS、GameplayTags、AngelScriptSDK、Bindings、Cache、Engine、Standalone 等。

在修复前，限制真实并发只能下调：

```powershell
-TestModuleWorkers 1
```

或：

```powershell
-TestModuleWorkers 2
```

不能依赖 `-MaxParallelHeavy 1/2`。

### 7.2 P0：默认策略下 Suite 参数可能被静默忽略

策略行为当前为：

| Strategy | entry 来源 |
| --- | --- |
| `CoarseDynamic` | `Get-AngelscriptCoarseDynamicPlan`，内部硬编码读取 `All` |
| `Coarse` | 固定顶层 Angelscript shards |
| `Monolithic` | 固定 Angelscript 组合前缀 |
| `Fine` | 才真正调用 `Get-AngelscriptTestSuiteEntries -SuiteName $Suite` |

因此：

```powershell
Tools\RunTestSuiteParallel.ps1 -Suite Smoke
```

在默认 `CoarseDynamic` 下不是“并行 Smoke”，而是动态 All。当前脚本只在控制台把 Suite 显示为 `<n/a>`，没有拒绝这个误用。

这是高风险接口问题。至少应采取一种方案：

1. `Suite != All` 且 strategy 不支持 suite 时立即报错；或
2. 所有 strategy 都以 selected suite 为输入，不再内部硬编码 All。

推荐第 2 种。

### 7.3 P1：Fast wrapper 与文档语义不一致

`RunTestSuiteFast.ps1` 当前实际传入：

```powershell
-Strategy CoarseDynamic
-TestModuleWorkers 4
-Fast
-MaxParallelLight 4
-MaxParallelHeavy 4
```

但 `Documents/Guides/Test.md` 说它等价于：

```powershell
RunTestSuiteParallel.ps1 -Strategy Coarse -Fast ...
```

文档还说 Fast：

- 是五个顶层 shard；
- 不包含 Standalone；
- Debugger / Performance / HotReload 可单独跑。

实际 `CoarseDynamic`：

- 从 All 获取所有 entry；
- 包含 Standalone；
- 包含 Debugger、Performance、HotReload；
- 当前总计 37 个 entry；
- 每个 UE prefix 仍是独立 Editor 进程，只是分配到四条 lane。

后续必须明确选定一个正式定义：

**定义 A：Fast 是快速 UE gate。**

- 使用真正的 Coarse 顶层 shard；
- 不包含 Standalone；
- 可以排除明确的 slow suites；
- 不可作为正式发布 All 的替代。

**定义 B：Fast 是带快速启动参数的完整 All。**

- 使用动态完整 catalog；
- 包含 Standalone 和 slow suites；
- 只是减少启动工作，不缩减验证范围。

推荐保留两个明确名字，而不是一个 Fast 同时承担两种语义：

- `Mode=FastGate`
- `Mode=Full`

### 7.4 P0：parallel tests 与 build 缺少 suite 级互斥

当前锁 key：

| 操作 | mutex key |
| --- | --- |
| Build | `<ProjectRoot>` |
| 普通 Test | `<ProjectRoot>` |
| Parallel Test slot 1 | `<ProjectRoot>#slot-1` |
| Parallel Test slot 2 | `<ProjectRoot>#slot-2` |
| ... | ... |

parallel worker 与 build 的 mutex 名不同，所以不互斥。可能出现：

```text
Agent A: RunBuild.ps1 正在替换 DLL/Intermediate
Agent B: RunTestSuiteParallel.ps1 启动多个 UnrealEditor-Cmd.exe
```

这不是期望的并发。正确模型应当是：

```text
同一 worktree：
  Build          = exclusive
  Test suite     = shared reservation owner
  Test workers   = reservation 内部 slots 1..N
```

也就是说：

- 测试 worker 之间可以并行；
- build 与任何测试都不能重叠；
- 同一 worktree 最多只能有一个 suite orchestrator；
- suite 在整个生命周期持有 reservation，不是在每个 entry 之间释放；
- 资源冲突时必须输出 owner PID、命令、开始时间和建议操作。

### 7.5 P1：自测没有验证实际并发契约

当前 Parallel 自测覆盖：

1. `Shards` 是 JSON array；
2. Fine Standalone 正确走 typed entry 且不 prewarm Unreal；
3. 并行 UE worker会附加 `-NoAssetRegistryCacheWrite`。

这些测试全部通过，但以下问题仍不会被发现：

- Heavy cap 是否生效；
- Light cap 是否生效；
- total cap 是否生效；
- 实际峰值并发是多少；
- `-Suite Smoke` 是否真的只运行 Smoke；
- build 是否能与 parallel suite 重叠；
- Fast 的 entry inventory 是否符合文档；
- slow exclusions 是否实际应用；
- 多 suite 同时启动如何处理；
- worker 无 metadata、崩溃或被取消时 summary 是否完整。

### 7.6 P2：DryRun 会进入两秒轮询

DryRun 时 `Start-PlannedRunProcess` 返回 `$null`，调度器不会把 `scheduledAny` 设为 true，随后每轮仍执行 `Start-Sleep -Seconds 2`。

本次实测：

| 命令 | 用时 |
| --- | ---: |
| 串行 All `-DryRun` | 约 0.63 秒 |
| CoarseDynamic All `-DryRun` | 约 39.45 秒 |

Parallel 自测约 49.8 秒，也主要受该等待影响。DryRun 应只构造并序列化计划，不应进入 process polling scheduler。

### 7.7 P2：自定义 OutputRoot 的聚合查找不完整

子 runner 会接收 `OutputRoot`，但 Parallel runner 查找 Unreal `RunMetadata.json` 时仍硬编码扫描：

```text
<ProjectRoot>\Saved\Tests
```

当调用者把输出写到自定义目录时，entry 本身可能成功，但 `ParallelSuiteSummary.json` 无法聚合 passed/failed/total 或 metadata path。

正确做法是：

- child 在启动时获得确定的 output/run identity；
- child 完成后通过显式 result path 返回 metadata/summary 路径；
- orchestrator 不再递归猜测目录。

### 7.8 P2：suite timeout 语义不完整

当前 `RunTestSuite.ps1 -TimeoutMs` 和 Parallel runner 的同名参数都是**每 entry timeout**，不是 suite wall-time budget。

这会产生两个问题：

- Agent 看到 `TimeoutMs=3600000` 可能误以为整套测试最多一小时；
- 串行 37 entry 的理论上限远高于一小时。

应拆成：

```powershell
-EntryTimeoutMs 3600000
-SuiteTimeoutMs 7200000
```

suite deadline 到达后：

1. 停止调度新 entry；
2. 给 active workers 一个有限 grace period；
3. 终止剩余 process tree；
4. 将未启动项标记为 `Cancelled`；
5. 将正在执行但超时的项标记为 `TimedOut`；
6. 始终写出完整 suite summary。

## 8. 构建工具 Review

### 8.1 当前设计中值得保留的部分

`Tools/RunBuild.ps1` 已具备：

- 同 worktree 单飞 mutex；
- 不同 worktree 默认允许并发；
- 默认使用 `-NoMutex -NoEngineChanges`；
- 需要写共享 Engine 产物时显式 `-SerializeByEngine`；
- 每次 run 使用独立 `Build.log`、`UBT.log`、`RunMetadata.json`；
- timeout deadline 和剩余预算；
- 超时/异常后的 process-tree cleanup；
- 进程退出码为 0 但日志出现 `Result: Failed` 时提升为失败；
- 共享 Engine UHT Timestamp 冲突检查；
- 明确禁止 `-UniqueBuildEnvironment`；
- 当前工作区新增的 `Target` / `Configuration` override 与 metadata 记录。

这些边界应继续作为统一 suite 协调器的基础，不应另造第二套 build runner。

### 8.2 当前 Build self-test 仍偏静态

`Tools/Diagnostics/tests/RunBuildSelfTests.ps1` 当前主要检查：

- PowerShell AST 无解析错误；
- `Target` / `Configuration` 参数存在；
- `PositionalBinding=false`；
- 源码字符串中包含预期变量和 argument 顺序。

这能捕获结构性回归，但不能证明真实参数和 metadata 行为。后续应增加 fake UBT fixture：

- 使用临时 `AgentConfig.ini`；
- fake dotnet/UBT 只记录 argv，不编译 UE；
- 验证 default target/config；
- 验证 override；
- 验证非法 configuration；
- 验证 `--` 后参数不绑定到 Target；
- 验证 timeout 和非零退出；
- 验证 `Result: Failed` 提升；
- 验证 `SerializeByEngine` 与普通模式的 mutex/argument 差异。

### 8.3 Build 和 suite 应共享一个协调层

当前 Build 和 Test 各自直接拼 mutex key。后续应把协调逻辑集中到共享模块，例如建议的新文件：

```text
Tools/Shared/ExecutionCoordination.ps1
```

它负责：

- worktree exclusive build lease；
- worktree suite reservation；
- suite 内 worker slots；
- EngineRoot serialized build lease；
- owner metadata；
- stale owner 检测；
- 等待/快速失败策略；
- 用户可读的冲突诊断。

## 9. 已有但需要升级或正式化的工具

这一节很重要：并非所有能力都需要新建脚本。仓库已经存在若干临时工具，正确方向是吸收到统一契约中，而不是继续维护第二份 catalog。

### 9.1 AnalyzeTestRunTiming.ps1

路径：

```text
Tools/Diagnostics/powershell/AnalyzeTestRunTiming.ps1
```

已有能力：

- 扫描 `Saved/Tests` 的 metadata 和 summary；
- 按 prefix 输出最新 duration；
- 估算串行耗时、coarse wall time 和小 prefix 启动开销。

当前问题：

- 只扫描目录名匹配 `^All_\d+_` 的历史串行布局；
- 通过每个 prefix 的“最后一条”推断，没有 run/suite identity；
- top-level 列表缺少当前 GameplayTags/Standalone 等 entry；
- 输出仍写死“36 boot”“33 prefixes”等历史数字；
- 没有 JSON/CSV 输出；
- 没有区分 cold/warm、Fast/normal、Engine 版本、代码 revision；
- 控制台存在 `Unique prefixes :</>` 这类明显文本错误；
- planner 读取自己的 timing 逻辑，分析脚本又实现另一套逻辑。

建议：

- 不再扩展这个脚本的硬编码模型；
- 将 timing ingestion 提炼成 `Tools/Shared/TestTimingStore.ps1`；
- 提供正式诊断入口 `Tools/Diagnostics/powershell/Get-TestSuiteTimingReport.ps1`；
- planner 和 report 共用同一 timing store；
- 支持 `-SuiteRun <SummaryPath>`、`-LatestSuccessful`、`-JsonPath`、`-CsvPath`；
- timing sample 记录 `Strategy`、`FastLaunch`、`EngineVersion`、`Commit`、`MachineClass`、`TestCount` 和时间戳；
- 使用 rolling median/有限窗口，不让一次异常长跑永久污染 planner。

### 9.2 RunRemainingAllSuite.ps1

路径：

```text
Tools/Diagnostics/powershell/RunRemainingAllSuite.ps1
```

已有能力：

- 从指定 index 开始串行续跑历史 All；
- 收集简单 exit-code 表。

当前问题：

- 自带一份手工 `AllEntries`；
- catalog 已过期，仍包含 `ClassGenerator` / `ScriptClass`，缺少当前 Cache/Generator/GameplayTags/Standalone 等条目；
- 只按 index 恢复，不根据实际 summary/metadata 判断完成状态；
- 只支持串行；
- 没有校验原 suite definition 是否在中断后变化；
- 没有结构化 resume manifest。

建议：

- 标记为 deprecated；
- 不再修补其中的手工列表；
- 由统一 `RunTestSuite.ps1 -ResumeFrom <SuiteSummary.json>` 替代；
- resume 必须读取原始 `SuitePlan.json` 和 entry identity，而不是读取当前 catalog 后猜 index；
- catalog 发生变化时明确报出 added/removed/changed entries，让用户选择继续原计划或重新规划。

### 9.3 Test-AutomationEntryPoints.ps1

路径：

```text
Tools/Diagnostics/powershell/Test-AutomationEntryPoints.ps1
```

已有能力：

- 扫描 C++ Automation 和 CQTest 名称；
- 读取 group/suite prefix；
- 检查 stale Native prefix；
- 检查 suite/group prefix 是否匹配至少一个测试；
- 已有独立 self-test。

应保留并升级：

- 用执行 `TestSuiteDefinitions.ps1` 后的结构化结果取代文本行 regex；
- 验证每个 entry 的唯一 label、kind、tier 和 prefix；
- 验证 CrashOnly 永不进入普通 suite；
- 验证 All 与 FastGate/Full strategy 的覆盖关系；
- 验证 suite strategy 不会静默替换 selected suite；
- 验证 serial/parallel plan 的 entry identity 等价；
- 检测当前文档、技能、OpenSpec 中的过期正式命令；
- 输出 JSON，供 CI 和 policy audit 使用。

### 9.4 Get-UbtProcess.ps1

路径：

```text
Tools/Diagnostics/powershell/Get-UbtProcess.ps1
```

已有能力：

- 枚举 UBT 相关进程；
- 解析 branch/worktree/project/target/config；
- 可只看当前 worktree。

当前不足：

- 看不到 `UnrealEditor-Cmd.exe` test workers；
- 看不到 suite orchestrator；
- 看不到 execution slot；
- 看不到 named mutex/lease owner；
- 看不到 run output/summary path；
- 看不到进程属于 build、focused test 还是哪个 suite。

建议扩展成统一的 `Get-UnrealExecutionState.ps1`，并保留现有 UBT wrapper 兼容。

### 9.5 GetAutomationReportSummary.ps1

已有能力：

- 优先读取结构化 Automation JSON；
- 规范化 passed/failed/skipped；
- 记录 failed tests 和日志提示；
- 当进程 exit 0 但缺少 summary 或报告有失败时，由 caller 提升最终退出码。

当前问题：

- 文件中定义了两次同名 `Get-LogFailureHints`；PowerShell 后定义覆盖前定义；
- 两份 pattern 不一致，第一份包含中文/不同日志通道，实际执行的是第二份；
- 没有独立 self-test 覆盖两组日志 pattern；
- suite summary 还需要自己再次读取/聚合这些结果。

建议：

- 合并成唯一实现；
- 把 blocking log patterns 声明成可测试的数据表；
- 增加 report-summary fixture；
- 统一由 `Write-Utf8JsonFile` 输出；
- 让每个 entry 的 result contract 明确返回 summary path，不再靠目录扫描。

## 10. 文档声称存在、但当前缺失的工具

`Documents/Tools/Tool.md` 当前多处列出：

```text
Tools/Tests/RunToolingSmokeTests.ps1
Tools/Tests/AutomationToolSelfTests.ps1
Tools/Tests/PolicyAuditSmokeTests.ps1
```

审计时三份文件都不存在，`Tools/Tests/` 目录本身也不是当前实际自测布局。现有自测主要位于：

```text
Tools/Diagnostics/tests/
```

这需要明确选择一种修复方式。

推荐方案：

1. 保留现有细粒度自测在 `Tools/Diagnostics/tests/`；
2. 新增一个正式聚合入口：

   ```text
   Tools/RunPowerShellToolingSelfTests.ps1
   ```

   聚合实现负责调度 `Tools/Diagnostics/tests/` 内的真实子测试，不是空转发 wrapper。
3. 将 Tool.md 中不存在的三份工具改为真实入口和真实子测试清单；
4. 如果仍需要 policy/summary/tooling 三个逻辑组，让聚合入口支持 `-Group`，不要凭空创建另一个平行目录；
5. 加一条“文档中的可执行路径必须存在”的 policy test，防止再次漂移。

不推荐仅为了匹配旧文档而创建三个空 wrapper，因为这会继续扩大入口数量。

## 11. 确实缺失的工具与能力

下面的名称是**建议目标名称**，当前并不存在。优先选择“整合进官方入口或共享模块”，只有独立读操作才建议成为新脚本。

### 11.1 统一官方 suite runner

目标：扩展现有 `Tools/RunTestSuite.ps1`，不再让调用者在 Serial/Parallel/Fast 三个脚本之间自行选择。

建议参数：

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -Workers 4 `
  -MaxParallelTotal 4 `
  -MaxParallelHeavy 2 `
  -EntryTimeoutMs 3600000 `
  -SuiteTimeoutMs 7200000 `
  -ContinueOnFail
```

建议模式：

| Mode | 语义 |
| --- | --- |
| `Auto` | All/大 suite 默认资源受控并行；单 entry/小 suite 默认串行；正式推荐值 |
| `Parallel` | 显式使用 selected suite 的并行计划 |
| `Serial` | 严格逐 entry 运行，用于资源受限或并发污染复现 |
| `Monolithic` | 单 Editor session 的组合前缀，用于检查同进程状态污染 |
| `FastGate` | 明确缩减范围的快速 UE gate，不宣称等价于完整 All |

兼容策略：

- `RunTestSuiteParallel.ps1` 变成薄 wrapper，转发到 `RunTestSuite.ps1 -Mode Parallel`；
- `RunTestSuiteFast.ps1` 变成薄 wrapper，转发到 `-Mode FastGate`；
- wrapper 输出 deprecation/compatibility 信息，但暂不立即删除；
- 所有 suite definition、plan、dispatch、summary 只保留一份实现。

### 11.2 ExecutionCoordination 共享模块

建议路径：

```text
Tools/Shared/ExecutionCoordination.ps1
```

职责：

- build exclusive lease；
- suite reservation；
- suite worker slot lease；
- EngineRoot serialized build lease；
- owner PID / parent PID / command / worktree / output root / start time；
- stale lease 判断；
- wait/fail-fast；
- lease 清理和 process-tree cleanup 协作。

推荐状态模型：

```text
Idle
 ├─ acquire build-exclusive ─► Building
 └─ acquire test-suite      ─► Testing

Building
 └─ release ─► Idle

Testing
 ├─ acquire worker slots 1..N
 ├─ release worker slots
 └─ release suite ─► Idle
```

关键不变量：

- `Building` 与 `Testing` 互斥；
- 一个 worktree 只允许一个 suite owner；
- suite owner 可以拥有 N 个 worker；
- worker 不能脱离 suite reservation 单独使用内部 slot；
- abandoned mutex/lease 必须可以诊断并安全恢复；
- 不允许普通用户通过随意传 `ExecutionSlot` 绕开协调层。

### 11.3 Suite preflight

优先整合为：

```powershell
Tools\RunTestSuite.ps1 -Suite All -PreflightOnly
```

同时可提供只读诊断 wrapper：

```text
Tools/Diagnostics/powershell/Test-TestSuitePreflight.ps1
```

检查项：

- `AgentConfig.ini` 可解析；
- ProjectFile/EngineRoot/Editor-Cmd 存在；
- suite 存在且 entry 非空；
- prefix 能匹配测试；
- CrashOnly 不在普通 suite；
- typed entry 所需工具可用，例如 cmake/ctest；
- output root 可创建且剩余空间达到配置阈值；
- 当前 worktree 无 build/suite 冲突；
- `TargetInfo.json` 可预热；
- selected mode 真正支持 selected suite；
- worker 数不超过资源/策略上限；
- plan 可以完整序列化；
- entry labels/identities 唯一。

Preflight 必须生成结构化 `Preflight.json`，不能只输出控制台文本。

### 11.4 测试执行容量探测器

建议路径：

```text
Tools/Diagnostics/powershell/Get-TestExecutionCapacity.ps1
```

作用：给 `Mode=Auto` 提供机器资源建议，而不是让所有 Agent 无条件使用 4 个 Heavy Editor。

建议输入：

- `-RequestedWorkers`
- `-RequestedHeavyWorkers`
- `-MinimumFreeMemoryGiBPerHeavyWorker`
- `-MinimumFreeDiskGiB`

建议输出：

- logical CPU；
- physical/available RAM；
- output volume free space；
- 当前 UE/UBT worker 数；
- recommended total workers；
- recommended heavy workers；
- limiting reason；
- JSON 输出。

注意：容量探测只能给建议。最终 runner 必须有硬并发上限，不能因为探测结果变化而无限增加 worker。

### 11.5 Suite 运行状态查看器

建议路径：

```text
Tools/Diagnostics/powershell/Get-TestSuiteRun.ps1
```

能力：

- 通过 `-Latest`、`-SummaryPath` 或 `-RunId` 定位 suite；
- 显示 planned/running/passed/failed/timed-out/cancelled/missing-metadata；
- 显示 slot、PID、持续时间、日志路径；
- 显示 suite 剩余 deadline；
- 显示当前峰值并发和资源建议；
- 支持 `-Watch`，但轮询应基于状态变化，不做无限阻塞 sleep；
- 支持 `-Json`。

### 11.6 恢复与失败重跑

推荐集成到官方 runner：

```powershell
Tools\RunTestSuite.ps1 -ResumeFrom <SuiteSummary.json>
Tools\RunTestSuite.ps1 -RetryFailedFrom <SuiteSummary.json>
```

语义：

- `ResumeFrom`：只调度原计划中未完成、取消或缺少可信 summary 的 entry；
- `RetryFailedFrom`：只调度 Failed/TimedOut/InfrastructureError；
- 默认保留原 mode、workers、fast profile 和 timeout；
- 可显式 override，但 summary 必须记录差异；
- 原 catalog hash 与当前 catalog 不一致时，不得静默恢复；
- 每次恢复生成新的 suite run，并通过 `ParentRunId` 关联原运行；
- 最终可以生成跨 attempt 的 consolidated summary。

这样可以完全替代硬编码的 `RunRemainingAllSuite.ps1`。

### 11.7 统一 SuiteSummary 与 SuitePlan

每次 suite 在启动任何 child 前必须写出：

```text
Saved/Tests/Suites/<Label>/<RunId>/
  SuitePlan.json
  SuiteMetadata.json
  SuiteSummary.json
  Events.jsonl
```

建议字段：

```text
SchemaVersion
RunId
ParentRunId
Suite
Mode
CatalogHash
PlanHash
Label
ProjectRoot
ProjectFile
EngineRoot
Commit
DirtyWorktree
FastLaunch
StartedAtUtc
CompletedAtUtc
EntryTimeoutMs
SuiteTimeoutMs
RequestedWorkers
EffectiveWorkers
RequestedHeavyWorkers
EffectiveHeavyWorkers
ActualPeakConcurrency
ExpectedEntryCount
StartedEntryCount
CompletedEntryCount
PassedEntryCount
FailedEntryCount
TimedOutEntryCount
CancelledEntryCount
InfrastructureErrorCount
MissingMetadataCount
AggregatedPassed
AggregatedFailed
AggregatedSkipped
AggregatedTotal
Entries[]
```

每个 entry 至少记录：

```text
Index
Identity
Kind
Label
Prefix
Tier
Status
Slot
ProcessId
Attempt
StartedAtUtc
CompletedAtUtc
DurationMs
ProcessExitCode
FinalExitCode
TimedOutPhase
MetadataPath
SummaryPath
LogPath
ReportPath
RerunCommand
```

统一 summary 后，Serial/Parallel/Fast/Resume 不应再各自发明不同字段。

### 11.8 运行事件流

建议新增 append-only：

```text
Events.jsonl
```

事件示例：

```text
SuitePlanned
SuiteStarted
EntryQueued
EntryStarted
EntryCompleted
EntryFailed
EntryTimedOut
EntryCancelled
SuiteStopping
SuiteCompleted
```

用途：

- 状态查看器不必递归扫描目录；
- suite 被强制中止时仍保留最后状态；
- 可以重建 summary；
- 可以准确计算实际峰值并发；
- 为后续 CI adapter/MCP 可观测性提供稳定数据源。

### 11.9 Unreal 执行状态与孤儿进程诊断

建议路径：

```text
Tools/Diagnostics/powershell/Get-UnrealExecutionState.ps1
Tools/Diagnostics/powershell/Repair-UnrealExecutionState.ps1
```

`Get` 是纯只读工具，应显示：

- UBT/dotnet/Build.bat；
- UnrealEditor/UnrealEditor-Cmd；
- suite/worker PowerShell；
- worktree、project、slot、suite/run ID；
- owner lease；
- orphan suspicion；
- output/log path。

`Repair` 是显式变更工具，默认只报告，不自动 kill。建议参数：

```powershell
-DryRun
-RunId <id>
-TerminateOrphans
-ClearStaleLeases
```

安全规则：

- 只能终止能证明属于指定 worktree/run 的进程树；
- 不能按进程名批量终止所有 Editor/UBT；
- 清理 lease 前验证 owner PID 已不存在或 process command 不再匹配；
- 输出修复前后 JSON；
- 任何终止操作必须记录是否可恢复。

### 11.10 Strategy parity 审计

建议路径：

```text
Tools/Diagnostics/powershell/Test-TestSuiteStrategyParity.ps1
```

最低成本静态 parity：

- 对同一 selected suite 生成 Serial 和 Parallel plan；
- 比较 entry identity multiset；
- 比较 typed entry 参数；
- 验证无重复、无遗漏、无额外 entry；
- 验证 FastGate 的缩减范围和声明一致；
- 验证 CrashOnly exclusion。

可选昂贵动态 parity：

- 仅在夜间/发布前运行；
- 比较同 revision 的 serial 与 parallel discovered/pass/fail/skip；
- 区分真正行为差异、顺序污染和基础设施错误；
- 不要求每次普通开发都跑两遍全量。

### 11.11 PowerShell 工具链自测聚合入口

建议路径：

```text
Tools/RunPowerShellToolingSelfTests.ps1
```

职责：

- 解析所有正式 PowerShell 文件；
- 运行 build runner self-tests；
- 运行 test/suite/parallel self-tests；
- 运行 commandlet/self-test；
- 运行 automation entry point audit；
- 运行文档路径/policy audit；
- 运行 duplicate-function-name audit；
- 可选调用 PSScriptAnalyzer；
- 输出单一 JSON summary 和稳定 exit code。

建议 group：

```text
Syntax
BuildRunner
TestRunner
SuiteScheduler
ReportSummary
Commandlet
Policy
All
```

### 11.12 PowerShell 静态检查 wrapper

当前环境没有 `PSScriptAnalyzer`，因此不能把“本机恰好安装模块”作为隐式前提。

建议由上述聚合入口实现两层检查：

1. 永远可用：PowerShell AST parse、重复函数名、危险命令、文档路径存在性、参数帮助/默认值一致性；
2. 可选增强：发现固定版本 PSScriptAnalyzer 后执行 repository ruleset。

如果项目决定强制 PSScriptAnalyzer，应增加明确的 bootstrap/install 文档和版本锁定，而不是让 Agent临时在线安装最新版。

### 11.13 Agent 命令模板扩展

更新：

```text
Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1
```

建议输出：

```text
BuildCommand
NoXgeBuildCommand
SerializedBuildCommand
TestFocusedCommand
TestSuiteSmokeCommand
TestSuiteAllCommand
TestSuiteAllParallelCommand
TestSuiteAllSerialCommand
TestSuiteFastGateCommand
TestSuitePreflightCommand
TestSuiteStatusCommand
```

最终如果 `RunTestSuite.ps1 -Mode Auto` 成为可靠默认，可以逐步收敛为：

```text
TestSuiteAllCommand = RunTestSuite.ps1 -Suite All -Mode Auto ...
```

并保留 Serial/Parallel 模板供诊断，不再让 Agent 自己猜策略。

## 12. 推荐目标架构

### 12.1 单一公开入口

```text
                         RunTestSuite.ps1
                                │
               ┌────────────────┼────────────────┐
               │                │                │
             Plan           Coordinate        Aggregate
               │                │                │
      SuiteDefinitions     worktree lease    SuiteSummary
      Strategy planner     worker slots       Events.jsonl
      Timing store         suite deadline     rerun commands
               │                │                │
               └────────────────┼────────────────┘
                                │
                         Typed Entry Runner
                    ┌───────────┴───────────┐
                    │                       │
                RunTests.ps1          CMake/CTest/etc.
```

公开调用者只需要理解：

- 跑哪个 suite；
- 要哪种验证模式；
- 机器最多允许多少 worker；
- entry/suite timeout；
- 是否 continue/retry/resume。

公开调用者不应直接理解：

- `ExecutionSlot`；
- preferred slot；
- metadata 目录猜测；
- Heavy/Light slot pool 编号；
- child PowerShell wrapper；
- mutex key 构造。

### 12.2 内部组件边界

建议拆分：

| 组件 | 建议文件 | 单一职责 |
| --- | --- | --- |
| Suite catalog | `Tools/Shared/TestSuiteDefinitions.ps1` | 声明 typed entries，不负责调度 |
| Strategy planner | `Tools/Shared/TestSuitePlanner.ps1` | selected suite + mode + timing → immutable plan |
| Timing store | `Tools/Shared/TestTimingStore.ps1` | 读取/规范化 timing samples |
| Coordination | `Tools/Shared/ExecutionCoordination.ps1` | build/suite/slot lease |
| Entry execution | `Tools/Shared/TestSuiteEntryRunner.ps1` | 执行一个 typed entry |
| Scheduler | `Tools/Shared/TestSuiteScheduler.ps1` | 根据 plan、资源 cap 和 deadline 调度 |
| Result model | `Tools/Shared/TestSuiteResults.ps1` | events、summary、resume/retry |
| CLI | `Tools/RunTestSuite.ps1` | 参数解析、组件组合、最终 exit code |

现有 `TestShardPlanner.ps1` 可演化为 `TestSuitePlanner.ps1`，但不应继续把 All、timing ingestion、计划输出和特定 strategy 混在一起。

### 12.3 错误分类

统一 summary 应区分：

| 分类 | 示例 | 是否代表测试失败 |
| --- | --- | --- |
| `Passed` | structured report 全绿 | 否 |
| `TestFailed` | Automation case failure | 是 |
| `TimedOut` | entry 或 suite deadline | 不一定，需单独归类 |
| `InfrastructureError` | Editor 未启动、缺少 report、worker crash、cmake 不存在 | 不应伪装成测试失败 |
| `Cancelled` | fail-fast 或 suite timeout 后未执行 | 否，但 suite 不完整 |
| `ConfigError` | suite/mode/参数不合法 | 否，命令无效 |
| `ResourceBlocked` | build/suite lease 被占用、容量不足 | 否，环境阻塞 |

最终 suite exit code 可以保持简单，但 JSON 必须保留具体分类。

## 13. 推荐 CLI 契约

### 13.1 完整验证

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -LabelPrefix all `
  -EntryTimeoutMs 3600000 `
  -SuiteTimeoutMs 7200000 `
  -ContinueOnFail
```

### 13.2 资源受限并行

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Parallel `
  -Workers 2 `
  -MaxParallelTotal 2 `
  -MaxParallelHeavy 1 `
  -EntryTimeoutMs 3600000 `
  -SuiteTimeoutMs 10800000
```

### 13.3 明确串行复现

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Serial `
  -LabelPrefix all-serial-repro `
  -EntryTimeoutMs 3600000 `
  -SuiteTimeoutMs 14400000 `
  -ContinueOnFail
```

串行模式应要求调用者或报告记录理由，例如：

- 机器内存不足；
- 复现 parallel-only flake；
- 对照测试顺序污染；
- 用户明确要求。

### 13.4 快速门禁

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode FastGate `
  -LabelPrefix all-fast-gate `
  -EntryTimeoutMs 900000 `
  -SuiteTimeoutMs 1800000
```

输出必须明确：

- `CompleteSuite=false`；
- 实际包含/排除的 entry；
- 不可作为 release All 的替代。

### 13.5 计划预览

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -PlanOnly `
  -PlanPath Saved\Tests\Plans\all-plan.json
```

PlanOnly 应在一秒量级完成，不 prewarm Unreal，不进入 scheduler polling。

### 13.6 恢复与重试

```powershell
Tools\RunTestSuite.ps1 -ResumeFrom <SuiteSummary.json>
Tools\RunTestSuite.ps1 -RetryFailedFrom <SuiteSummary.json>
```

## 14. 自测与故障注入矩阵

### 14.1 Planner tests

- selected suite 只生成自身 entry；
- All serial/parallel identity multiset 相等；
- typed entry 不丢失字段；
- FastGate inventory 与声明一致；
- CrashOnly 永不进入普通 plan；
- duplicate label/prefix identity 被拒绝；
- timing 缺失时 deterministic fallback；
- timing 异常值不会生成负权重/NaN；
-同一输入生成相同 `PlanHash`。

### 14.2 Scheduler tests

使用 mock worker，记录每个任务的 start/end timestamp：

- `MaxParallelTotal=2` 时峰值不超过 2；
- `MaxParallelHeavy=1` 时 Heavy 峰值不超过 1；
- Light/Heavy 同时存在时不饿死某一类；
- preferred slot 不能绕过 global cap；
- fail-fast 停止调度并标记 Cancelled；
- ContinueOnFail 会完成所有 entry；
- suite timeout 终止 active workers 并写完整 summary；
- worker 非零退出；
- worker crash；
- worker 不写 metadata；
- malformed result JSON；
- orchestrator 被中断后 event log 可恢复。

### 14.3 Coordination tests

- build exclusive 阻止 suite；
- suite reservation 阻止 build；
- suite 内 N 个 worker 可并行；
- 第二个 suite 明确返回 ResourceBlocked；
- abandoned owner 可检测；
-仍活跃 owner 不可被误清理；
-不同 worktree 可并发；
-共享 Engine serialized build 仍按 EngineRoot 互斥。

### 14.4 Result tests

- serial/parallel 生成同 schema；
- custom OutputRoot 正确传播；
- Summary 中 array 永远为 array；
- missing structured report 不能被 exit 0 掩盖；
- ResumeFrom 只选择未完成项；
- RetryFailedFrom 只选择失败/超时/基础设施错误；
- catalog hash 改变时明确失败；
- rerun command 可复制执行；
-跨 attempt consolidated summary 正确。

### 14.5 Build runner tests

- default/override target/config；
-参数引用和 `--`；
- fake UBT exit code；
- timeout cleanup；
- log-level failure promotion；
- worktree mutex；
- EngineRoot serialization；
-与 suite reservation 的 shared/exclusive 行为。

### 14.6 Policy tests

- Tool.md 中列出的可执行路径存在；
-正式文档不直接调用 UnrealEditor-Cmd/Build.bat/UBT；
- OpenSpec skill 合法入口包含统一 suite runner；
-新非 archive OpenSpec 不使用 legacy Parallel/Fast wrapper；
-待执行完整验证使用 `-Mode Auto/Parallel/Serial` 的明确契约；
-帮助文本、参数默认值和 Test.md 一致；
-不存在同一文件重复 function name；
-PowerShell 全文件 AST parse 通过。

## 15. 实施路线

### Phase 0：修正文档和危险接口误导

目标：在不重写架构前先避免新的误用。

1. 修正 `RunTestSuiteParallel.ps1` 帮助中 `MaxParallelHeavy` 默认值；
2. 对 `Suite != All` + 不支持 suite 的 strategy 立即报错；
3. 修正 Fast wrapper 与 Test.md 的实际 strategy/范围；
4. 在指南顶部明确“build 与 test 阶段不重叠，但 full suite 内可受控并行”；
5. 将 Parallel/Fast 标为当前受支持还是 experimental，不能保持半官方状态；
6. 修正 Tool.md 中不存在的 `Tools/Tests` 文件；
7. 合并重复的 `Get-LogFailureHints`；
8. 修复 Parallel DryRun sleep。

验收：

- 所有参数帮助与默认值一致；
- `-Suite Smoke` 不会意外运行 All；
- PlanOnly/DryRun 一秒量级完成；
- 文档中的每个可执行路径存在。

### Phase 1：建立统一 plan/result contract

1. 定义版本化 `SuitePlan` / `SuiteSummary` schema；
2. 将 selected suite 作为所有 strategy 的显式输入；
3. child 使用明确 `ResultPath` 返回结果；
4. serial runner 也生成 suite summary；
5. custom OutputRoot 不再靠递归扫描；
6. 增加 plan/parity/result self-tests。

验收：

- Serial/Parallel 对 All 生成同 entry identity set；
- 所有模式生成同一 schema；
- summary 中没有 guessed metadata path；
- 自定义 OutputRoot 聚合完整。

### Phase 2：建立 suite 级协调与真实并发上限

1. 新增 `ExecutionCoordination.ps1`；
2. build/test 使用 shared/exclusive 模型；
3. scheduler 实现 total/heavy/light 硬上限；
4. 记录 actual peak concurrency；
5. 增加并发和故障注入 fixture。

验收：

- Heavy cap 测试能在旧实现上失败、在新实现上通过；
- build 与 parallel suite 无法重叠；
-不同 worktree 的合法并发不被破坏；
-所有中止路径写出完整 summary。

### Phase 3：统一官方入口

1. `RunTestSuite.ps1` 增加 Mode/Workers/timeout contract；
2. 把 Parallel/Fast 变为 compatibility wrappers；
3. 更新 Agent 模板、skills、AGENTS、Test.md、Tool.md；
4. 更新未完成 OpenSpec 任务中的正式命令；
5. 加 policy audit，阻止入口再次漂移。

验收：

- Agent 只需使用 `RunTestSuite.ps1 -Suite All -Mode Auto`；
-合法入口文档只有一套；
-wrapper 与主入口计划完全一致；
-新 OpenSpec 不再下发 legacy wrapper。

### Phase 4：恢复、重试、状态和 timing

1. Events.jsonl；
2. Get-TestSuiteRun；
3. ResumeFrom / RetryFailedFrom；
4. timing store 与 report；
5. execution capacity 建议；
6.孤儿进程/lease 诊断与显式修复。

验收：

- 人为中断 suite 后可从原 plan 恢复；
-失败 shard 可一条命令重跑；
- timing planner 与 report 使用同一数据源；
-状态工具不依赖递归猜目录。

### Phase 5：真实性能与稳定性基线

1. 同 revision、同机器分别跑 Serial/Parallel/Monolithic/FastGate；
2. 记录 cold/warm 两组；
3. 记录 CPU/RAM/peak editor count/I/O；
4. 检查 parallel-only flakes；
5. 根据真实数据更新默认 worker 和文档 wall-time；
6. 将 Cache 长尾单独分析，不用盲目增加 worker 掩盖。

验收：

- 文档不再写固定、失真的 `5–8 min`；
-默认 worker 有机器资源与稳定性证据；
- Full 与 FastGate 的范围和时间分别记录。

## 16. 建议的后续 OpenSpec 拆分

不要把所有内容塞进一个巨大改动。建议按依赖顺序拆为：

1. `fix-test-suite-runner-contract-drift`
   - 帮助/默认值、Suite 误用、Fast 文档、DryRun、重复 summary function、Tool.md 假路径；
2. `refactor-test-suite-plan-and-result-contract`
   - selected-suite planning、统一 schema、显式 ResultPath、strategy parity；
3. `feature-test-suite-execution-coordination`
   - suite reservation、build/test shared-exclusive、真实并发 cap；
4. `refactor-unified-test-suite-entrypoint`
   - Mode Auto/Parallel/Serial/FastGate、wrapper 兼容、agent/skill/docs 迁移；
5. `feature-test-suite-resume-and-observability`
   - Events、status、resume/retry、execution doctor、timing store。

每个 change 都应在父仓库落 OpenSpec；若只修改根 `Tools/` 和文档，不需要 Angelscript submodule commit。只有改动插件测试行为时才进入 dual-repo 流程。

## 17. Agent 与文档治理同步清单

中文文档优先，然后同步英文。至少更新：

- `AGENTS_ZH.md`
- `AGENTS.md`
- `Documents/Guides/Test.md`
- `Documents/Guides/Build.md` 中 build/test 协调说明
- `Documents/Tools/Tool.md`
- `.agents/skills/README.md`
- `.agents/skills/openspec-work/SKILL.md`
- `Tools/ImplementTestCoverage/RunImplementTestCoverage.ps1`
- `Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1`

对 OpenSpec 文档：

- archive 保留历史命令；
-已完成 verification 保留事实，不改写成从未执行过的新命令；
-未完成 tasks 中的 full-suite gate 更新为统一官方入口；
-记录 Serial 的任务必须写原因；
- policy audit 只约束 live/non-archive 指令，不扫描并拒绝历史证据。

## 18. 工具修复前的临时操作建议

### 18.1 完整并行验证

机器资源足够时：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunTestSuiteParallel.ps1 `
  -Suite All `
  -Strategy CoarseDynamic `
  -TestModuleWorkers 4 `
  -LabelPrefix all-parallel `
  -TimeoutMs 3600000 `
  -ContinueOnFail
```

注意：当前 `-Suite All` 在 CoarseDynamic 中只是与内部硬编码一致，不代表 Suite 参数已经普遍生效。

### 18.2 内存受限机器

```powershell
-TestModuleWorkers 2
```

当前不要依赖：

```powershell
-MaxParallelHeavy 1
```

因为它在 CoarseDynamic 固定 slot 分支中没有实际限流作用。

### 18.3 串行模式适用场景

继续使用：

```powershell
Tools\RunTestSuite.ps1 -Suite All -ContinueOnFail ...
```

只适合：

- 明确复现并发相关污染；
- 机器无法承载多个 Editor；
- 用户要求严格顺序；
- 作为 serial/parallel 对照基线。

### 18.4 运行期间的安全规则

- 先完成 build，再启动 parallel suite；
- parallel suite 运行期间不要在同一 checkout 启动 build；
- 不要让两个 Agent 在同一 worktree 同时启动两个 parallel suite；
- 不要手工给普通 `RunTests.ps1` 随意分配 slot 来绕过锁；
- 要验证同一 Editor session 的顺序污染时使用 Monolithic，而不是把 37 个独立 Editor 进程简单串行；
- Fast wrapper 的范围在文档和实现统一前，不作为正式 release All 的唯一证据；
- 所有结果以 `Summary.json` / `ParallelSuiteSummary.json` 为准，不只看进程 exit 0。

## 19. 运行工件证据

### 19.1 串行 All

2026-08-09 现有串行 UE bucket：

- 首项：`Saved/Tests/All_01_Editor/20260809_021748_076_367c4a53/RunMetadata.json`
- 末项：`Saved/Tests/All_35_WorldSubsystem/20260809_025909_932_004ff3e2/Summary.json`
- 首项开始：约 `02:17:48`
- 末项完成：约 `02:59:39`
- UE bucket wall time：约 `41.86` 分钟
- 该次随后还有独立 Standalone entry

### 19.2 Parallel All

2026-08-12 最终并行工件：

- `Saved/Tests/cache-v2-merged-main-all-final_20260812_040301/ParallelSuiteSummary.json`
- `Saved/Tests/cache-v2-merged-main-all-final_20260812_040301/WorkerPlan.json`

摘要：

| 字段 | 值 |
| --- | ---: |
| Strategy | CoarseDynamic |
| Worker count | 4 |
| Shards | 37 |
| Passed | 3090 |
| Failed | 0 |
| Total | 3090 |
| Wall time | 18.25 min |
| Cache shard | 17.44 min / 536 tests |

这些不是同代码版本、同测试数量的严格 A/B benchmark，但足以证明：

- Parallel runner 能完成当前完整 catalog；
- wall time 明显低于现有串行样本；
- 当前长尾已经被 Cache shard 主导；
- 文档中的 `5–8 min` 不应继续作为当前完整 All 的通用承诺。

### 19.3 历史并发可靠性背景

历史上并行 Editor 曾竞争：

```text
Intermediate/CachedAssetRegistry/CachedAssetRegistry_*.bin
```

后续通过 `-NoAssetRegistryCacheWrite` 规避共享 AssetRegistry cache 写竞争。当前 Fast launch profile 和 Parallel worker 都会追加该参数。

历史记录也出现过一次 GC parallel flake，focused rerun 通过。这说明并行模式需要持续保留：

- serial 对照；
- parallel-only flake 分类；
- strategy parity；
- 可复制的 failed-shard rerun 命令。

但最终 `3090/3090` 结果也证明并行不是不可用或原则上不安全，而是需要正式协调与可观测性。

## 20. 本次验证记录

### 20.1 执行通过的检查

PowerShell 语法解析通过：

- `Tools/RunBuild.ps1`
- `Tools/RunTests.ps1`
- `Tools/RunTestSuite.ps1`
- `Tools/RunTestSuiteParallel.ps1`
- `Tools/RunTestSuiteFast.ps1`
- `Tools/Shared/TestSuiteDefinitions.ps1`
- `Tools/Shared/TestSuiteEntryRunner.ps1`
- `Tools/Shared/TestShardPlanner.ps1`

自测：

- `Tools/Diagnostics/tests/RunBuildSelfTests.ps1`：PASS；
- `Tools/Diagnostics/tests/RunTestSuiteSelfTests.ps1`：全部 PASS；
- `Tools/Diagnostics/tests/RunTestSuiteParallelSelfTests.ps1`：3 个案例全部 PASS。

最小复现：

- 标准 `All -DryRun`：当前 37 个 entry；
- `CoarseDynamic -MaxParallelHeavy 1 -DryRun`：Heavy entry 仍使用 slot 1–4；
- 并行 DryRun：约 39.45 秒；
- 串行 DryRun：约 0.63 秒。

其他事实：

- `ResolveAgentCommandTemplates.ps1` 当前只生成 focused test 和串行 Smoke suite 模板；
- 非 archive OpenSpec 中，串行 All 命令远多于并行入口，且未发现 Parallel/Fast 指令；
- 当前环境未安装/未发现 PSScriptAnalyzer；
- Tool.md 所列三份 `Tools/Tests/*.ps1` 当前不存在；
- `GetAutomationReportSummary.ps1` 存在重复的 `Get-LogFailureHints` 定义。

### 20.2 未执行的验证

- 未执行真实 UBT build；
- 未执行新的 UE full suite；
- 未运行新的 serial/parallel 同 revision benchmark；
- 未做真实 concurrent build-vs-test 破坏性复现；
- 未修改或验证任何修复后的行为，因为本报告只做审计。

## 21. 在线调研：主流 AI Agent 对可调用 CLI / PowerShell 的共同要求

本节是 2026-08-13 的在线资料补充，重点回答：如果 `RunBuild.ps1`、`RunTests.ps1`、`RunTestSuite.ps1` 要被 Codex、Claude Code、GitHub Copilot、Gemini CLI 等 Agent 稳定调用，工具本身还应满足什么契约。

这里讨论的主要方向是：

```text
AI Agent -> shell tool -> project PowerShell entrypoint -> UBT / UnrealEditor-Cmd / CMake / CTest
```

不是把 Codex 或其他模型嵌入构建脚本。后者属于另一种自动化场景，只在 24.12 节补充最小边界。

### 21.1 OpenAI Codex 官方建议

OpenAI 的 Agent-friendly CLI 用例明确建议：

- 把重复的读取、搜索、下载、导出、草稿、写入或轮询工作做成可组合 CLI；
- CLI 应能从任意目录调用，而不是依赖源码目录作为当前工作目录；
- 默认返回窄化、可预测的 JSON；
- 大日志、大导出和完整 payload 写入文件，只在终端返回路径和短摘要；
- 拆分 setup、discovery、exact read、download、draft、live write、poll 等动作；
- 缺失认证时通过 setup check 清楚失败；
- live write 不应在没有明确授权时执行；
- 用 companion skill 记录“什么时候用、第一条命令是什么、如何控制输出、哪些写操作需要批准”。

来源：[Create a CLI Codex can use](https://learn.chatgpt.com/use-cases/agent-friendly-clis)

Codex 非交互模式本身也采用了值得项目工具复用的接口模式：

- 普通模式把进度放到 `stderr`，最终结果放到 `stdout`；
- `--json` 输出 JSONL 事件流；
- `--output-schema` 约束最终结果结构；
- `--output-last-message` 把最终结果写到明确路径；
- sandbox 和权限级别显式配置；
- 自动化默认最小权限，广泛访问只用于受控环境；
- 认证只传给单次受信任进程，不把 key 暴露给会执行仓库代码的整个 job。

来源：[Codex non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode)

Codex 会按目录层级发现 `AGENTS.md`，并让更靠近当前目录的说明覆盖上层说明。默认项目说明总量有限，因此命令规则应该短、明确、无冲突，不能把唯一正确的完整验证入口藏在长篇背景中。

来源：[Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

Codex 还明确区分 sandbox 与 approval：前者是 OS/文件/网络技术边界，后者决定何时暂停询问。项目脚本应让常规、低风险命令可以在 workspace 边界内完成，而不是要求 Agent 为普通运行切到不受限环境。

来源：[Codex sandbox](https://learn.chatgpt.com/docs/sandboxing)

### 21.2 Anthropic Claude Code 官方行为

Claude Code 的非交互模式同样提供：

- stdin 管道输入；
- text、JSON、stream-JSON 三种输出；
- JSON Schema 约束；
- 明确允许工具和 permission mode；
- non-interactive / bare 模式用于 CI 和可重复脚本。

来源：[Run Claude Code programmatically](https://code.claude.com/docs/en/headless)

与本项目更直接相关的是 Claude Code 的 shell 限制：

- 一般成功命令的内联结果约 30,000 字符，超出后会依赖文件路径和预览；
- 一般失败命令的内联结果约 10,000 字符，过长时主要得到首尾摘录；
- shell 命令有宿主级默认/最大超时；
- 超时命令可能被移到后台，而 non-interactive 会话结束后后台任务可能很快终止；
- exit code `1` 对绝大多数命令都被视为失败，只对少数已知查询工具有特殊语义。

来源：[Claude Code tools reference — timeout and output limits](https://code.claude.com/docs/en/tools-reference#timeout-and-output-limits)

因此，全量 UE 测试不能把数十万行 Editor 日志当作 Agent 的主要返回值，也不能假设外层 shell 工具一定会持续等待 20–60 分钟。工具必须主动写日志/summary/state 文件，并提供可靠的 wait/status 接口。

Claude Code 当前也有原生 PowerShell tool，但不同安装环境的行为并不完全相同：

- native Windows 没有 Git Bash 时自动使用 PowerShell；
- 有 Git Bash 时 PowerShell tool 可能仍处于逐步启用状态；
- Linux/macOS/WSL 需要 PowerShell 7+ 并显式启用；
- Windows 上优先 `pwsh.exe`，找不到时回退 `powershell.exe` 5.1；
- PowerShell tool 预览模式不加载 profile；
- 当前 native Windows PowerShell tool 不提供 sandbox；
- permission rule 会解析 PowerShell AST，并分别检查 compound command 的每个子命令。

来源：[Claude Code PowerShell tool](https://code.claude.com/docs/en/tools-reference#powershell-tool)、[Claude Code permissions](https://code.claude.com/docs/en/permissions)

这说明项目不能依赖某个 Agent 用户 profile 里的 alias、module import、函数或环境变量，也不应把标准命令写成复杂的一行 compound shell。一个稳定的 `powershell.exe ... -File <entry.ps1>` 或 `pwsh ... -File <entry.ps1>` 调用比动态拼接 `-Command` 更适合权限审查和跨 Agent 复用。

### 21.3 GitHub Copilot 官方行为

Copilot cloud agent 在 GitHub Actions 驱动的临时环境中工作，默认是 Ubuntu。要运行 Windows/UE 专用工具链，仓库必须显式切换到 Windows runner，并预装依赖。官方也建议 setup steps 使用最小权限、可重复安装依赖，并为 setup workflow 配置明确 timeout。

来源：[Configure the development environment for Copilot cloud agent](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment)

这对当前仓库有一个重要结论：

> 根 `Tools/*.ps1` 可以对 local Agent 和 Windows self-hosted/cloud runner 友好，但不能假设任意 Copilot cloud agent 默认就拥有 UE 5.7、`AgentConfig.ini` 和 Windows Editor。工具应在 preflight 阶段快速返回 `unsupported_platform` / `missing_engine`，而不是在几十分钟后模糊失败。

Copilot CLI 能发现 `AGENTS.md`、`CLAUDE.md`、`GEMINI.md` 和 `.github/copilot-instructions.md`，但多个说明会被合并，而且没有通用优先级保证。因此，共享规则应只在一个权威文档中定义，其他文件引用它或保持完全一致，不能分别声明不同的 full-suite 命令。

来源：[Adding custom instructions for GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)

Copilot hooks 还使用 JSON 输入、显式 `cwd`、环境变量和 timeout，并分别支持 Unix `bash` 与 Windows `powershell` 路径。Hook 是同步的，官方建议尽量控制在 5 秒以内。这证明“短 preflight / policy check”和“长 suite execution”应是不同命令，不能让一个 session-start hook 启动完整验证。

来源：[About hooks for GitHub Copilot](https://docs.github.com/en/copilot/concepts/agents/hooks)

### 21.4 Google Gemini CLI 官方行为

Gemini CLI 在 Windows 上通过：

```text
powershell.exe -NoProfile -Command
```

执行 shell command。返回值明确分为：

- command；
- directory；
- stdout；
- stderr；
- exit code；
- background PIDs。

它还支持 command prefix / regex policy，compound command 会拆分后逐项验证。

来源：[Gemini CLI shell tool](https://geminicli.com/docs/tools/shell/)

Gemini headless mode则提供 JSON、streaming JSON 和明确退出码。这再次说明项目工具应把标准结果设计成 schema，而不是要求 Agent 正则解析彩色 console 文本。

来源：[Gemini CLI headless mode](https://geminicli.com/docs/cli/headless/)

Gemini 会给子进程设置 `GEMINI_CLI=1`；Claude 也有 `CLAUDECODE=1`。这些环境变量最多可用于 telemetry，不应控制正确性，因为：

- Codex、Copilot 或自定义 Agent 未必设置对应变量；
- 同一个脚本可能从 CI、人类终端或另一个 wrapper 调用；
- Agent-specific 自动检测会让结果随宿主变化，破坏可重复性。

项目应使用显式的 `-OutputFormat`、`-Caller` 或 command mode，而不是通过 Agent 品牌猜行为。

### 21.5 PowerShell 官方语义

PowerShell 官方文档确认了几个容易被 Agent wrapper 误用的点：

- `-NoProfile` 避免机器个人配置影响运行；
- `-NonInteractive` 会让 `Read-Host`、确认提示等交互尝试直接失败，而不是无限挂起；
- `-File` 比动态 `-Command` 更适合稳定传参，但 `-File` 后的内容都被解释为脚本路径/参数；
- 正常脚本不会自动返回业务 exit status，必须显式 `exit <code>`；
- PowerShell success、error、warning、verbose、debug、information/progress 是不同 stream；
- `Write-Host` 属于 information stream，不应作为 JSON stdout 协议；
- PSScriptAnalyzer 可以检查 parse error、兼容性和规则问题，并用 `-EnableExit` 为 CI 返回非零状态；
- 会改变状态的 PowerShell function 应考虑 `SupportsShouldProcess` / `-WhatIf` / `-Confirm`。

来源：[about_Pwsh](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh)、[about_Scripts](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts)、[about_Output_Streams](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams)、[Invoke-ScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/module/psscriptanalyzer/invoke-scriptanalyzer)、[Everything about ShouldProcess](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess)

## 22. 跨 Agent 执行环境矩阵

| Agent / 宿主 | Windows shell 行为 | 结构化结果能力 | 指令/策略发现 | 对本项目的直接影响 |
| --- | --- | --- | --- | --- |
| Codex local / CLI | native Windows 命令处于 sandbox/approval 边界；当前本机会话实际使用 PowerShell | `codex exec` 支持 JSONL、JSON Schema、final output file | 分层 `AGENTS.md` | 把唯一 full-suite 命令写进 AGENTS/skill；stdout/stderr 分离；不要要求 danger-full-access 才能测试 |
| Claude Code native Windows | 可能走 Git Bash，也可能启用原生 PowerShell；PowerShell 7 优先，5.1 fallback；profile 不加载 | text / JSON / stream-JSON / schema；shell 输出有明显截断和超时边界 | `CLAUDE.md`、skills、permissions、hooks | 标准调用显式使用 `powershell.exe -File`；大日志必须落盘；完整 suite 需要可续接状态 |
| GitHub Copilot cloud agent | 默认 Ubuntu；需要显式 Windows runner 才能运行 UE Windows 工具 | 依赖 Actions/Agent 工具结果与 hooks JSON | `AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、Copilot instructions | preflight 必须快速识别平台/Engine 缺失；setup 与验证分离；规则不能冲突 |
| Gemini CLI native Windows | 官方 shell tool 使用 `powershell.exe -NoProfile -Command` | stdout/stderr/exit code 分离；headless 支持 JSON/JSONL | GEMINI/config/policy | PowerShell 5.1 仍是重要兼容基线；命令面应适合 prefix policy |
| 人类本地 PowerShell | 可能加载 profile、alias、颜色和交互设置 | PowerShell objects / text | Build.md、Test.md、Get-Help | Human 默认保持可读；Agent/CI 显式切 JSON；相同业务语义不能随 caller 改变 |

### 22.1 项目支持边界建议

当前 Unreal Editor、UBT、`Global\` mutex、Win64 executable path 和 `AgentConfig.ini` 都是 Windows 工具链的一部分。建议明确声明：

```text
Supported execution platform: Windows x64
Minimum shell: Windows PowerShell 5.1
Compatibility target: PowerShell 7.x on Windows
Unsupported by default: Ubuntu/macOS agent without a configured Windows runner
```

不建议为了“看起来跨平台”而把 UE runner 改成半兼容状态。更可靠的做法是：

1. Windows 专用入口通过 `-Describe` 返回 platform capability；
2. 非 Windows 立即返回结构化 `unsupported_platform`；
3. 独立 Standalone CMake/CTest 若未来真正支持 Linux，再给该 entry 单独声明平台矩阵；
4. 在 Windows PowerShell 5.1 和 PowerShell 7 两个宿主中运行 tooling contract tests。

## 23. 推荐的 Agent-Friendly PowerShell 工具契约

### 23.1 P0：非交互契约

所有 Agent 可调用入口必须满足：

- 不调用 `Read-Host`、`PromptForChoice`、GUI dialog 或需要键盘输入的外部程序；
- 不默认触发 `-Confirm`；
- 缺参数、缺配置、锁冲突、平台不支持时立即失败并给出结构化原因；
- 提供明确的 `-DryRun` / `-PlanOnly`，不能让 Agent 通过阅读 console 猜是否会改状态；
- 可在以下宿主命令下运行：

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -OutputFormat Json
```

PowerShell 7 compatibility：

```powershell
pwsh -NoLogo -NoProfile -NonInteractive `
  -File Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -OutputFormat Json
```

`-ExecutionPolicy Bypass` 只作用于当前 Windows 进程，并不能覆盖组织 Group Policy；若组织要求遵守签名策略，应由环境配置决定，而不是脚本尝试修改机器 policy。

### 23.2 P0：标准输出契约

建议所有顶层入口支持：

```powershell
-OutputFormat Human|Json|Jsonl
-ResultPath <absolute-or-project-relative-path>
-Quiet
-NoColor
```

语义：

| 模式 | stdout | stderr / information | 工件 |
| --- | --- | --- | --- |
| Human | 人类可读摘要 | progress、warning、error | 完整 log/metadata/summary |
| Json | 只输出一个最终 JSON document | 有界 progress 与诊断，不混入 stdout | 完整 log/metadata/summary |
| Jsonl | 每行一个 versioned event，最后一行必须是 result event | 只放无法编码为事件的宿主错误 | 完整 log/metadata/summary |
| Quiet | 只保留最终 JSON 或绝对 result path | fatal error | 完整工件不变 |

当前大量 `Write-Host` 可保留给 Human mode，但 JSON/JSONL mode 必须通过共享 writer 禁止任何非 JSON 文本进入 stdout。

不建议 Agent 直接消费完整 UBT / Editor console stream。建议默认只输出：

- phase；
- runId；
- elapsed；
- bounded warning/error 摘要；
- final exit/status；
- absolute summary/log/result path。

完整日志继续写文件。需要实时观察时显式使用 `-Follow`，并仍要限制每阶段输出量。

### 23.3 P0：统一结果 schema

建议新增 `Tools/Schemas/AgentToolResult.v1.schema.json`，最小结构为：

```json
{
  "schemaVersion": "angelscript.agent-tool-result/v1",
  "tool": "RunTestSuite",
  "operation": "run",
  "runId": "20260813_123456_789_abcd1234",
  "status": "succeeded",
  "exitCode": 0,
  "rawExitCode": 0,
  "startedAtUtc": "2026-08-13T04:34:56.789Z",
  "durationMs": 1095000,
  "summaryPath": "D:\\Workspace\\AngelscriptProject\\Saved\\Tests\\...\\SuiteSummary.json",
  "logPath": "D:\\Workspace\\AngelscriptProject\\Saved\\Tests\\...\\Suite.log",
  "artifacts": [],
  "counts": {
    "passed": 3090,
    "failed": 0,
    "skipped": 0,
    "total": 3090
  },
  "retry": {
    "retryable": false,
    "afterMs": 0
  },
  "error": null
}
```

失败结果必须仍然写完整 JSON，不能只抛一个字符串：

```json
{
  "status": "busy",
  "exitCode": 4,
  "retry": {
    "retryable": true,
    "afterMs": 5000
  },
  "error": {
    "code": "worktree_busy",
    "message": "Another build or test execution owns this worktree.",
    "detailsPath": "D:\\...\\ExecutionState.json"
  }
}
```

`message` 供人读，`error.code` 供 Agent/CI 分支。Agent 不应根据英文句子识别 timeout、busy 或 config error。

### 23.4 P0：稳定退出码

保留现有数值基本合理，但必须在 help、schema 和文档中统一：

| Exit | 稳定语义 | Agent 行为 |
| ---: | --- | --- |
| 0 | succeeded | 接受结果，读取 summary |
| 1 | build/test/domain failure | 读取 failure summary；可 focused rerun |
| 2 | timeout | 读取 timeout phase；仅在策略允许时重试 |
| 3 | invalid configuration / unsupported environment | 不盲重试；先修配置或换 runner |
| 4 | worktree/suite busy | 根据 `retry.afterMs` 等待或换 worktree |
| 5 | shared engine/resource busy | 等待 engine lease 或切 dedicated EngineRoot |
| 6 | cancelled | 不自动当成测试失败；保留 partial summary |
| 7 | internal tooling error | 运行 tooling doctor/self-tests，不能把它算成产品测试失败 |

外部进程的 raw exit code必须放到独立字段。顶层稳定 exit code不应随着 UBT、CTest 或 UnrealEditor 的任意 raw code 漂移。

### 23.5 P0：能力发现与帮助

每个公开入口都应有完整 comment-based help：

- `.SYNOPSIS`；
- `.DESCRIPTION`；
- 每个 `.PARAMETER`；
- 至少一个 Human、一个 Agent JSON、一个 DryRun 示例；
- `.OUTPUTS`；
- `.NOTES` 中的 exit-code / platform / side-effect / artifact contract。

此外建议统一支持：

```powershell
Tools\RunTestSuite.ps1 -Describe -OutputFormat Json
Tools\RunTestSuite.ps1 -ListSuites -OutputFormat Json
Tools\RunTestSuite.ps1 -Suite All -PlanOnly -OutputFormat Json
```

`-Describe` 返回：

```json
{
  "tool": "RunTestSuite",
  "toolVersion": "1.0.0",
  "schemaVersions": ["angelscript.agent-tool-result/v1"],
  "supportedPlatforms": ["windows-x64"],
  "minimumPowerShell": "5.1",
  "operations": ["describe", "list", "plan", "run", "resume", "wait", "cancel"],
  "sideEffects": ["writes-project-saved", "starts-unreal-editor"],
  "defaultMode": "Auto"
}
```

Agent 可以先做一次廉价 discovery，而不需要打开 1,000 行 `.ps1` 源码判断参数。

### 23.6 P0：长任务生命周期

完整 All 当前已有 18–42 分钟样本，超过不少 Agent shell 的默认命令时限。推荐两种受支持模式：

1. foreground：外层 tool timeout 明确大于 `SuiteTimeoutMs + cleanup grace`；
2. managed async：suite supervisor 持有 lease，立即返回 runId，Agent 通过 wait/status 续接。

建议 CLI：

```powershell
# foreground
Tools\RunTestSuite.ps1 -Suite All -Mode Auto -SuiteTimeoutMs 3600000

# managed async
Tools\RunTestSuite.ps1 -Suite All -Mode Auto -Async -OutputFormat Json
Tools\GetExecutionStatus.ps1 -RunId <run-id> -OutputFormat Json
Tools\WaitExecution.ps1 -RunId <run-id> -TimeoutMs 3600000 -OutputFormat Jsonl
Tools\StopExecution.ps1 -RunId <run-id> -WhatIf
```

`-Async` 不能只是裸 `Start-Process`：

- 必须记录 supervisor PID、child PID、lease owner、command line hash、startedAt、heartbeat；
- Agent 会话退出后执行仍可被状态工具接管；
- stale heartbeat 有明确诊断/repair 流程；
- `StopExecution` 只终止属于该 runId 的进程树；
- 取消后写 partial summary，exit/status 为 cancelled。

### 23.7 P0：并发与 busy 协议

锁冲突不能只写：

```text
Another build or test command is already running.
```

建议支持：

```powershell
-OnBusy Fail|Wait
-BusyTimeoutMs <int>
-BusyPollIntervalMs <int>
```

并返回：

- owner runId；
- owner PID / phase；
- resource type：worktree、suite、engine、execution slot；
- owner startedAt / heartbeat；
- retryable；
- retry-after；
- status command。

这样多个 Agent 才不会因为一次 mutex 拒绝就推导出“测试只能串行”，也不会通过手工换 slot 绕过安全边界。

### 23.8 P1：安全与权限策略友好

Agent permission engine通常按 command、prefix 或解析后的子命令授权。标准调用应保持短而稳定：

```powershell
powershell.exe -NoProfile -NonInteractive -File Tools\RunTestSuite.ps1 ...
```

不要让官方路径要求：

- `Invoke-Expression`；
- 多层 `cmd /c` + PowerShell + batch 拼接；
- 动态下载后直接执行；
- shell 字符串中嵌入 secret；
- 大量 `;`、`&&`、重定向和 command substitution；
- 为普通 build/test 请求 unrestricted host access。

`ExtraArgs` / `ValueFromRemainingArguments` 应被视为高级 escape hatch：

- 正常验证需求优先增加命名参数；
- passthrough args 做显式 deny/allow validation；
- command echo 和 metadata 对 secret-like 参数做 redaction；
- 禁止的 engine/build flags 在 JSON error 中返回稳定 code；
- 文档不要把任意 passthrough 作为标准 Agent 示例。

删除、覆盖、上传、发布、kill/repair 等状态改变操作使用 `SupportsShouldProcess` 或等价的 `-WhatIf`，并在 Agent guidance 中标记需要用户授权的操作。

### 23.9 P1：确定性与宿主隔离

工具正确性不能依赖：

- 当前目录；
- PowerShell profile；
- 用户 alias/function；
- 之前 shell command 设置但未持久化的环境变量；
- 当前 UI culture；
- ANSI color；
- 在线安装“最新版”模块；
- Agent 品牌环境变量。

应当：

- 使用 `$PSScriptRoot` 和 resolved absolute path；
- `Set-StrictMode -Version Latest`；
- `$ErrorActionPreference = 'Stop'`，同时显式检查 native `$LASTEXITCODE`；
- 用 UTF-8 no BOM 写 JSON/JSONL；
- 时间统一 UTC ISO-8601，duration 用整数毫秒；
- schema/tool version 显式；
- 可选依赖固定版本并在 bootstrap/preflight 验证；
- 同时验证带空格、Unicode 和长路径的临时 workspace。

### 23.10 P1：幂等、恢复和重试

Agent 可能因为网络、上下文压缩、shell timeout 或用户中断重新发起同一命令。工具应支持：

- 调用方可传 `-RequestId` / `-IdempotencyKey`；
- 同 key 且正在运行时返回原 runId，而不是再开一套 Editor；
- 同 key 已完成时返回原 summary，除非显式 `-ForceNewRun`；
- retry 只重跑失败/timeout shard；
- plan hash、suite catalog hash、revision、runner version不匹配时拒绝错误 resume；
- partial state原子写入，避免半截 JSON 被误读为有效结果。

### 23.11 P1：输入规模和输出规模有界

Agent shell 都会对时间、stdout 或上下文做截断。建议：

- list/discovery 支持 `-Limit`、`-Offset` 或 filter；
- exact read 通过 stable runId/shardId 获取；
- full log 只返回路径、byte count、SHA-256 和首尾摘要；
- failure summary 输出最相关 N 个错误，并给 `detailsPath`；
- summary 记录 `truncated: true/false`；
- console progress做节流，例如 5–15 秒一次，而不是每 100ms 重绘；
- 不把 37 个子进程的全部 stdout同时灌给 Agent。

### 23.12 如果未来由 PowerShell 调用 Codex/Claude/Gemini

如果另一个自动化脚本需要反向调用 AI Agent，应遵守各自 headless接口，而不是启动交互 TUI：

- Codex：`codex exec --json` 或 `--output-schema`；
- Claude：`claude --bare -p --output-format json/stream-json`；
- Gemini：headless `-p --output-format json/stream-json`；
- sandbox / permission / allowed tools显式；
- credential 只注入单次受信任进程；
- 不把模型自然语言 stdout 当作 build/test truth；
- 最终仍以项目 `Summary.json`、exit code 和 JSON Schema 验证为准。

这不是当前构建/测试工具改造的前置需求，不建议把 AI 调用加入 UBT 或 test runner 主路径。

## 24. 当前工具对 Agent-Friendly 契约的符合度

### 24.1 已经做得较好的部分

| 契约 | 当前状态 | 证据 |
| --- | --- | --- |
| 路径不依赖调用目录 | 基本符合 | 顶层脚本通过 `$PSScriptRoot` 解析 project/shared runner |
| 明确参数 | 基本符合 | `RunBuild.ps1` / `RunTests.ps1` 使用 advanced parameter，suite runner有命名参数 |
| 严格错误处理 | 符合 | `Set-StrictMode -Version Latest` + `$ErrorActionPreference='Stop'` |
| native process timeout | 符合 | `Invoke-StreamingProcess` 有 deadline、timeout和 process-tree cleanup |
| 显式 exit code | 基本符合 | build/test/parallel runner均显式 `exit`，并提升“raw 0 但 summary failure”为失败 |
| 完整日志落盘 | 符合 | build/test/CTest都有独立 log path |
| JSON 工件 | 部分符合 | RunMetadata、Summary、ParallelSuiteSummary、WorkerPlan 已存在 |
| 并发隔离 | 部分符合 | execution slot、mutex、label/output root 已存在 |
| 无显式交互 prompt | 当前符合 | 核心 runner 未发现 `Read-Host` / GUI prompt |
| DryRun | 部分符合 | suite/parallel支持 DryRun，但尚非统一 plan contract |

### 24.2 主要差距

| Priority | Agent-Friendly 缺口 | 当前表现 | 后果 |
| --- | --- | --- | --- |
| P0 | 没有 `-OutputFormat Json/Jsonl` | stdout 主要是大量 `Write-Host` 和 child stdout | Agent 只能解析人类文本；输出易截断 |
| P0 | 没有统一 final result schema | metadata/summary结构各自不同 | build/test/suite wrapper需要写多套解析逻辑 |
| P0 | 没有 managed async + wait/status contract | full suite 只能绑定一个长 shell call | 外层 10 分钟级 timeout 会丢失控制或制造 orphan |
| P0 | busy 只返回人类错误 | 缺 owner/retry/status path | Agent 不知道该等待、换 worktree还是重试 |
| P0 | suite总 deadline不清晰 | `TimeoutMs` 多为 entry timeout | Agent 无法给外层 tool设置可靠 deadline |
| P0 | 并行语义仍有已确认 P0 bug | Suite ignored、heavy cap失效 | 结构化接口上线前必须先修正确性 |
| P1 | Build/RunTests无完整 comment-based help | `Get-Help` 主要显示语法，没有业务说明 | Agent需要读源码或错误文档 |
| P1 | list/describe不是 JSON capability discovery | `-ListSuites` 只打印 catalog | Agent不能安全探测 suite/platform/side effect |
| P1 | console输出无上限 | child stdout/stderr逐行回放到 console | UE日志吞噬上下文；失败首尾信息可能丢失 |
| P1 | `ExtraArgs` 是开放 passthrough | typo和危险 flag可能绕过显式参数面 | permission policy难审计；命令复现不稳定 |
| P1 | 没有 request id/idempotency | Agent重试会创建新 run | 重复 full suite、锁冲突、成本浪费 |
| P1 | 没有 PS 5.1 + PS 7 contract matrix | 当前主要在默认 powershell解析 | Claude/Gemini/Codex不同宿主可能出现编码/语法差异 |
| P1 | 静态检查未成为可重复入口 | 当前环境没有 PSScriptAnalyzer | Agent可能临时联网装最新版，结果漂移 |
| P2 | 没有 `-NoColor` / progress节流模式 | Write-Host颜色与长 console混用 | JSON wrapper、日志和上下文容易污染 |
| P2 | Agent-specific policy未测试 | 没有 command-prefix/compound-command audit | 明明安全的标准命令也可能反复触发 approval |

### 24.3 一个容易忽略的输出问题

`Invoke-StreamingProcess` 当前把 child stdout逐行写到 console stdout，把 stderr逐行写到 console stderr，同时写完整 log。这对人类观察很方便，但对 Agent full suite不理想：

- 同一份大日志既写文件又消耗 Agent tool output；
- parallel mode会交错多个 child结果；
- JSON mode无法保证 stdout纯净；
- Claude等宿主会在成功/失败时用不同截断窗口；
- 关键 final summary可能排在截断区之外。

建议给 `Invoke-StreamingProcess` 增加：

```powershell
-ConsoleMode Stream|Errors|Summary|Silent
-MaxConsoleLines <int>
-MaxConsoleBytes <long>
-ProgressIntervalMs <int>
```

默认：

- Human：`Stream`；
- Agent Json：`Errors` 或 `Summary`；
- Agent Jsonl：只发布结构化 phase/error/progress event；
- 完整 stdout/stderr始终保留在 log。

## 25. 还应补充的 Agent 适配工具

以下工具是对第 11 节缺失清单的扩展。名称是建议，实施时可根据最终 OpenSpec 调整，但能力不应遗漏。

### 25.1 `Tools/Shared/AgentToolProtocol.ps1`

职责：

- 创建 versioned result/event object；
- Human/Json/Jsonl 输出路由；
- stdout/stderr纯净保证；
- UTC timestamp、duration、runId；
- stable error code/exit code mapping；
- path规范化；
- secret redaction；
- bounded preview；
- atomic JSON write。

建议公开 helper：

```powershell
New-AgentToolResult
New-AgentToolError
Write-AgentToolEvent
Write-AgentToolResult
Write-AgentToolDiagnostic
Write-AtomicUtf8JsonFile
Protect-AgentToolSecret
```

它应建立在现有 `UnrealCommandUtils.ps1` 上，不能再复制一套 timeout、path、process逻辑。

### 25.2 `Tools/Schemas/*.schema.json`

至少需要：

- `AgentToolResult.v1.schema.json`；
- `AgentToolEvent.v1.schema.json`；
- `ToolCapabilities.v1.schema.json`；
- `ExecutionState.v1.schema.json`；
- `SuitePlan.v1.schema.json`；
- `SuiteSummary.v1.schema.json`。

每份工件都写 `schemaVersion`。Self-test要用 schema验证真实样本，而不是只做 `ConvertFrom-Json`。

### 25.3 `Tools/GetToolCapabilities.ps1`

提供统一 discovery：

```powershell
Tools\GetToolCapabilities.ps1 -OutputFormat Json
Tools\GetToolCapabilities.ps1 -Tool RunTestSuite -OutputFormat Json
```

返回：

- tool / version / schema version；
- supported platform/PowerShell；
- required config；
- side effects；
- operations；
- default timeout；
- output formats；
- exit code table；
- known compatibility limits。

### 25.4 `Tools/TestAgentEnvironment.ps1`

这是轻量 preflight，不启动 UBT或 Editor：

```powershell
Tools\TestAgentEnvironment.ps1 `
  -Capability Build,UnrealAutomation,Standalone `
  -OutputFormat Json
```

检查：

- OS/architecture；
- Windows PowerShell / pwsh version；
- `AgentConfig.ini`；
- EngineRoot、uproject、UBT、dotnet、EditorCmd；
- CMake/CTest；
-磁盘空间、内存/CPU建议；
-输出目录可写；
- worktree/engine lease；
- PSScriptAnalyzer availability；
- 预计可用 strategy/worker cap。

它只返回 capability，不自动在线安装或修改配置。

### 25.5 `Tools/Diagnostics/powershell/Test-AgentToolContract.ps1`

用于对单个入口做 black-box contract test：

- 从 repo root外目录调用；
- `-NoProfile -NonInteractive`；
- Windows PowerShell 5.1；
- PowerShell 7；
- 路径含空格/Unicode；
- missing config；
- invalid parameter；
- busy lock；
- timeout/cancel；
- stdout为纯 JSON或有效 JSONL；
- stderr不污染 JSON；
- exit code与 result.exitCode一致；
- absolute artifact path存在；
- schema validation；
- console output size上限；
- secrets不出现在 console/metadata/log preview。

### 25.6 `Tools/RunPowerShellToolingSelfTests.ps1`

把当前分散的自测和新增 contract audit统一起来：

```powershell
Tools\RunPowerShellToolingSelfTests.ps1 `
  -ShellMatrix WindowsPowerShell,PowerShell7 `
  -OutputFormat Json
```

包含：

- AST parse；
- PSScriptAnalyzer（可用 pinned module时）；
- runner self-tests；
- planner/scheduler/coordination；
- schema tests；
- Agent tool contract；
- policy audit；
- documentation command parity。

### 25.7 managed execution命令

与第 11.9 节的执行状态能力合并，建议：

```text
Tools/GetExecutionStatus.ps1
Tools/WaitExecution.ps1
Tools/StopExecution.ps1
Tools/RepairExecutionState.ps1
```

不建议为 build/test/suite分别复制一套 status工具。统一以 runId和 typed execution state工作。

### 25.8 `Tools/Diagnostics/powershell/Test-AgentCommandPolicy.ps1`

验证标准命令是否适合 Codex/Claude/Gemini/Copilot 类型的 permission policy：

- 官方模板只有一个 PowerShell process + 一个 `-File` entry；
- 不包含 `Invoke-Expression`；
- 不包含动态网络下载；
- 不通过 `cmd /c` 重包；
- 不在标准路径使用 arbitrary compound command；
- destructive/repair命令有 `-WhatIf`；
- ExtraArgs不含禁止项；
- command template与 AGENTS/skill/Test.md一致。

这不是模拟每个厂商私有 classifier，而是检查最稳定的共同子集。

### 25.9 `Tools/Diagnostics/powershell/Export-AgentCommandCatalog.ps1`

把当前 `ResolveAgentCommandTemplates.ps1` 升级为结构化 catalog，或由新工具替代：

```json
{
  "commands": [
    {
      "id": "test.full.auto",
      "intent": "complete-verification",
      "command": "powershell.exe -NoProfile -NonInteractive -File Tools\\RunTestSuite.ps1 -Suite All -Mode Auto -OutputFormat Json",
      "expectedMaxDurationMs": 3600000,
      "sideEffect": "writes-local-artifacts",
      "requiresApproval": false,
      "platform": "windows-x64"
    }
  ]
}
```

AGENTS、OpenSpec skill和文档从同一 catalog生成/校验示例，避免命令再次漂移。

### 25.10 GitHub Copilot Windows setup示例

如果项目计划让 Copilot cloud agent运行真正的 UE build/test，需新增并单独验证：

```text
.github/workflows/copilot-setup-steps.yml
```

但这不是普通文档任务可以直接完成的，因为还需要选择：

- Windows larger/self-hosted runner；
- Engine 5.7获取方式；
- `AgentConfig.ini`安全生成；
- submodule/LFS；
- cache容量；
- license与网络策略；
- 单次运行成本和 59 分钟 setup timeout边界。

在这些条件未具备前，应在 capability中明确 `cloud-ue-build: unavailable`，而不是给 Agent一个注定失败的命令。

## 26. Agent 适配的推荐 CLI 形态

### 26.1 人类默认调用

```powershell
Tools\RunTestSuite.ps1 -Suite All -Mode Auto
```

### 26.2 Agent foreground调用

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass `
  -File Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -OnBusy Wait `
  -BusyTimeoutMs 600000 `
  -SuiteTimeoutMs 3600000 `
  -OutputFormat Json `
  -NoColor
```

### 26.3 Agent managed async调用

```powershell
$start = Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -Async `
  -OutputFormat Json | ConvertFrom-Json

Tools\WaitExecution.ps1 `
  -RunId $start.runId `
  -TimeoutMs 3600000 `
  -OutputFormat Jsonl
```

### 26.4 机器可读计划

```powershell
Tools\RunTestSuite.ps1 `
  -Suite All `
  -Mode Auto `
  -PlanOnly `
  -OutputFormat Json
```

计划结果至少包含：

- resolved suite；
- catalog hash；
- strategy；
- shard list；
- tier；
- expected worker cap；
- estimated wall time；
- required leases；
- artifact root；
- unsupported/missing prerequisites；
- side-effect summary。

### 26.5 focused failure重跑

```powershell
Tools\RunTestSuite.ps1 `
  -ResumeFrom <run-id> `
  -Retry Failed,TimedOut `
  -OutputFormat Json
```

Agent不需要从 console手工复制 37 条 shard命令。

## 27. 实施顺序补充

### Phase A：先建立协议，不改变测试调度

1. 新增 result/event/capability schema；
2. 新增 `AgentToolProtocol.ps1`；
3. 给 RunBuild/RunTests/RunTestSuite增加完整 comment help；
4. 增加 `Human|Json|Jsonl` 输出；
5. 明确并自测 exit-code table；
6. 增加 `GetToolCapabilities` / `TestAgentEnvironment`；
7. 保持现有串/并行行为不变，避免一次 change同时改协议和调度。

### Phase B：修正 suite正确性并统一入口

1. 修复 Suite ignored；
2. 修复 heavy cap；
3. 增加 SuiteTimeoutMs；
4. 统一 plan/summary；
5. `RunTestSuite.ps1 -Mode Auto|Parallel|Serial|Monolithic|FastGate`；
6. Parallel/Fast变成 compatibility wrapper。

### Phase C：长任务和多 Agent协调

1. typed execution state；
2. suite/build shared-exclusive lease；
3. `-OnBusy` 与 owner/retry协议；
4. managed async supervisor；
5. status/wait/cancel/repair；
6. idempotency和 resume/retry。

### Phase D：跨宿主与 policy验证

1. Windows PowerShell 5.1 contract；
2. PowerShell 7 contract；
3. NoProfile/NonInteractive；
4. output truncation/failure-tail测试；
5. command-policy audit；
6. pinned PSScriptAnalyzer；
7. AGENTS/skill/Test.md/Tool.md command catalog parity。

### Phase E：可选 cloud Agent接入

只有在 Windows runner、UE安装、license、secrets、网络、cache和成本方案批准后，再增加 Copilot/其他 cloud Agent setup。它不应阻塞本地 Agent-friendly CLI改造。

## 28. 在线资料索引

OpenAI：

- [Create a CLI Codex can use](https://learn.chatgpt.com/use-cases/agent-friendly-clis)
- [Codex non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode)
- [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Codex sandbox](https://learn.chatgpt.com/docs/sandboxing)

Anthropic：

- [Run Claude Code programmatically](https://code.claude.com/docs/en/headless)
- [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference)
- [Claude Code permissions](https://code.claude.com/docs/en/permissions)

GitHub：

- [Configure the Copilot cloud agent development environment](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment)
- [Adding custom instructions for GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
- [About hooks for GitHub Copilot](https://docs.github.com/en/copilot/concepts/agents/hooks)

Google：

- [Gemini CLI shell tool](https://geminicli.com/docs/tools/shell/)
- [Gemini CLI headless mode](https://geminicli.com/docs/cli/headless/)

Microsoft PowerShell：

- [about_Pwsh](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh)
- [about_Scripts](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts)
- [about_Output_Streams](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams)
- [Invoke-ScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/module/psscriptanalyzer/invoke-scriptanalyzer)
- [Everything about ShouldProcess](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess)

## 29. 最终建议

短期最重要的动作不是增加更多 wrapper，而是修复官方契约：

1. 立即阻止 `-Suite` 被静默忽略；
2. 修复 CoarseDynamic 的真实并发 cap；
3. 明确 FastGate 与 Full 的范围；
4. 建立 build-exclusive / suite-shared 的协调模型；
5. 统一 `RunTestSuite.ps1` 为唯一公开入口；
6. 让 Serial/Parallel/Fast/Resume 使用同一个 plan 和 summary；
7. 给 Agent、OpenSpec skill、命令模板和中文/英文指南同步同一条规则；
8. 用 mock worker 自测峰值并发，而不是只验证命令字符串；
9. 将已有 timing/resume/audit 临时脚本吸收到统一模型，删除手工 catalog；
10. 补齐自测聚合入口、运行状态、恢复重试、孤儿进程诊断和 policy audit；
11. 增加 Human/Json/Jsonl 输出，并保证 Json stdout纯净；
12. 建立 versioned AgentToolResult/Event/Capabilities schema；
13. 发布稳定 exit code、busy/retry、timeout/cancel契约；
14. 增加 managed async + status/wait/cancel，解决 Agent外层 timeout短于 UE full suite的问题；
15. 在 Windows PowerShell 5.1 和 PowerShell 7 中做 NoProfile/NonInteractive contract test；
16. 把 full log留在文件，只向 Agent返回有界摘要和绝对工件路径；
17. 让标准命令保持简单、可被 command-prefix policy审计，不依赖复杂 shell拼接；
18. 将 Agent适配规则编码进唯一命令 catalog，再由 AGENTS、skills和文档校验一致性。

最终期望的 Agent 行为应当非常简单：

```powershell
# focused verification
Tools\RunTests.ps1 -TestPrefix <prefix> ...

# complete verification
Tools\RunTestSuite.ps1 -Suite All -Mode Auto -OutputFormat Json ...

# explicit serial diagnosis
Tools\RunTestSuite.ps1 -Suite All -Mode Serial ...
```

当正确选择已经编码进唯一官方入口、命令模板和技能规则后，Agent 就不再需要从相互冲突的文档中猜“这次该串行还是并行”。

结合外部 Agent官方资料，最终目标还应再加一句：

> Agent 不需要阅读 PowerShell源码、解析彩色长日志或猜 mutex含义；它只需调用一个稳定入口，依据 schema、exit code、runId和 artifact path继续工作。
