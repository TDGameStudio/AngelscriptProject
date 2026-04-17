param(
    [Parameter(Mandatory = $true)]
    [string]$Module,

    [int]$MaxIterations = 10,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace  = (Resolve-Path (Join-Path $scriptRoot '..\..') ).Path

Set-Location $workspace

# ── CodexHome ────────────────────────────────────────────────────────────────
if (-not $env:CODEX_HOME) {
    $iniPath = Join-Path $workspace 'AgentConfig.ini'
    if (Test-Path $iniPath) {
        foreach ($line in (Get-Content $iniPath -Encoding UTF8)) {
            if ($line -match '^\s*CodexHome\s*=\s*(.+)$') {
                $val = $Matches[1].Trim()
                if ($val -ne '') { $env:CODEX_HOME = $val; break }
            }
        }
    }
    if (-not $env:CODEX_HOME) {
        $env:CODEX_HOME = 'C:\Users\scottmei\.codex_test_nopro'
    }
}

# ── 共用工作指令模板 ─────────────────────────────────────────────────────────
$sharedInstructions = @'

## ⚠ 输入与输出的严格区分

**输出文件**（只写这个文件）：上面"输出"行指定的文件路径（在 Documents/AutoPlans/Plans/ 下）。
**输入文件**（只读不写）：上面"只读输入"列出的所有分析文档。

**绝对禁止向 DiscoveryPlans/、TestCoverage/、ArchitectureReview/、ReferenceComparison/ 目录下的任何文件写入内容。**
**绝对禁止向 Documents/AutoPlans/ 根目录下的 *_Analysis.md 文件写入内容。**

## 工作指令

1. 输出文件固定为上面"输出"行指定的路径（Documents/AutoPlans/Plans/Plan_<Module>.md）。不要写入任何其他文件。
2. 先读取输出文件（如果已存在），了解前面迭代已生成的 Plan 内容。
3. 在输出文件末尾追加本轮新增的条目，用 --- 分隔线和 ## 深化 (日期时间) 标题区分。
4. 不得删除或覆盖输出文件中已有内容，只在末尾追加。
5. 不重述前面已记录的条目，只写新增内容或深化已有条目。
6. 如果输出文件不存在，按 Documents/Rules/ImprovementPlannerRule_ZH.md 中定义的完整 Plan 结构创建文件。
7. **源码验证是硬性要求**：对每个候选改进项，必须读取实际源码文件，确认问题仍存在后才纳入 Plan。条目中必须包含文件路径和行号。
8. **多维度交叉引用是硬性要求**：每个条目至少引用 2 个分析维度的发现（用 [A]/[B]/[C]/[D]/[E] 标注）。
9. **每个改进条目必须附带对应的单元测试任务**（P*.N-T 后缀），包含测试文件路径、测试场景、测试命名。
10. 不凭空发明改进项——所有条目必须有分析产出支撑。
11. 先检查 Documents/Plans/ 中是否已有覆盖同一主题的活跃 Plan，避免重复。
12. 深度优于广度，5 个有完整执行细节和测试的条目优于 20 个粗略条目。
13. 所有文字中文，代码、路径、技术术语英文。
14. 使用 Plan 的 checkbox + Phase 格式（- [ ] **P1.1** ...），不要使用 Issue-N 格式。
'@

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    RuntimeCore = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_RuntimeCore.md

## 分析目标

RuntimeCore — 引擎生命周期、全局状态、上下文栈、Subsystem

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/RuntimeCore_Analysis.md | 引擎初始化/销毁流程的代码质量、隐藏 bug |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/RuntimeCore_Plan.md | 已识别的具体缺陷及解决方案 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/RuntimeCore_TestGaps.md | 哪些路径缺少测试、现有测试质量 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/ScriptLifecycle_ArchReview.md | 脚本生命周期架构改进建议 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/GapAnalysis.md + CrossComparison.md | Runtime 相关差距 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/Core/
$sharedInstructions
"@

    ClassGenerator = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_ClassGenerator.md

## 分析目标

ClassGenerator — 动态 UClass 生成、热重载、版本链

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/ClassGenerator_Analysis.md | 类生成代码质量、重复模式、大函数 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/ClassGenerator_Plan.md | 热重载缺陷、CDO 一致性、版本链断裂 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/ClassGenerator_TestGaps.md | 类生成/热重载哪些路径缺少测试 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/TypeSystem_ArchReview.md + HotReloadArch_ArchReview.md | 类型系统和热重载架构改进建议 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/GapAnalysis.md + CrossComparison.md | 参考插件的类型注册和热重载做法 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/
$sharedInstructions
"@

    BindSystem = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_BindSystem.md

## 分析目标

BindSystem — 123 个 Bind_*.cpp、API 覆盖、绑定基础设施

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/BindSystem_Analysis.md | 绑定代码质量、重复模式、null 检查缺失 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/BindSystem_Plan.md | 具体缺陷和解决方案、UEAS2 API 差距 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/BindSystem_TestGaps.md | 哪些绑定 API 缺少测试 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/BindingPipeline_ArchReview.md | 绑定管线架构、分片策略改进建议 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/CrossComparison.md + GapAnalysis.md + Hazelight_Analysis.md | 其他插件的绑定方式对比 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/Binds/
$sharedInstructions
"@

    Preprocessor = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_Preprocessor.md

## 分析目标

Preprocessor — import 解析、include 处理、模块系统

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/Preprocessor_Analysis.md | 预处理器代码质量、状态机复杂度 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/Preprocessor_Plan.md | import 边界缺陷、循环依赖、错误恢复 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/Preprocessor_TestGaps.md | 预处理器哪些路径缺少测试 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/ModuleStructure_ArchReview.md | 预处理器与编译管线的模块边界 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/CrossComparison.md | 参考插件的脚本加载/依赖管理 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/
$sharedInstructions
"@

    DebuggingAndJIT = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_DebuggingAndJIT.md

## 分析目标

DebuggingAndJIT — DebugServer V2 协议、StaticJIT 编译

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/DebuggingAndJIT_Analysis.md | 调试协议质量、JIT 代码生成正确性 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/DebuggingAndJIT_Plan.md | 协议边界缺陷、断点精度、JIT 一致性 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/DebuggingAndJIT_TestGaps.md | 调试和 JIT 哪些路径缺少测试 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/DebugAndToolchain_ArchReview.md | 调试线程模型、DAP 合规性、JIT 架构 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/CrossComparison.md | D5 调试体验、D8 性能策略对比 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/
Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/
$sharedInstructions
"@

    FunctionLibraries = @"
你正在从 AutoPlans 分析产出中生成改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_FunctionLibraries.md

## 分析目标

FunctionLibraries — 21+ 脚本辅助函数库

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/FunctionLibraries_Analysis.md | 函数库代码质量、参数检查、返回值一致性 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/FunctionLibraries_Plan.md | 具体函数缺陷和解决方案 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/FunctionLibraries_TestGaps.md | 哪些函数库缺少测试 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/ModuleStructure_ArchReview.md | 函数库组织分类是否合理 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/CrossComparison.md + Hazelight_Analysis.md | 参考插件缺失的 utility 函数 |

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/
$sharedInstructions
"@

    Architecture = @"
你正在从 AutoPlans 分析产出中生成跨领域架构改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_Architecture.md

## 分析目标

Architecture — 跨模块架构改进、扩展性增强、参考插件经验吸收

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/RuntimeCore_Analysis.md + ClassGenerator_Analysis.md + BindSystem_Analysis.md | 各模块中反复出现的跨模块架构问题 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/ 下 RuntimeCore_Plan.md + ClassGenerator_Plan.md + BindSystem_Plan.md | 多模块共同暴露的架构类缺陷 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/RuntimeCore_TestGaps.md | 架构不合理导致难以测试的模块 |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/ 下所有 8 个 *_ArchReview.md | 所有架构改进建议（核心输入） |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/ 下 CrossComparison.md + GapAnalysis.md + 5 个 *_Analysis.md | 参考插件架构模式（核心输入） |

## 重要约束

- 架构改进必须考虑当前项目约束（AngelScript 2.33.0 WIP、不修改引擎）
- 优先级必须考虑与 todo.md 当前主线的协调
- 大型架构变更需拆分为可增量推进的小 Phase

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptRuntime/（全模块）
$sharedInstructions
"@

    TestInfrastructure = @"
你正在从 AutoPlans 分析产出中生成测试基础设施改进 Plan。严格遵循 Documents/Rules/ImprovementPlannerRule_ZH.md。

## 输出（只写这个文件）

Documents/AutoPlans/Plans/Plan_TestInfrastructure.md

## 分析目标

TestInfrastructure — 测试框架、测试 helper、测试组织、测试覆盖

## 只读输入（读取但绝对不修改这些文件）

| 维度 | 文件（只读） | 关注什么 |
|------|------------|---------|
| [A] 迭代分析 | Documents/AutoPlans/RuntimeCore_Analysis.md | 迭代分析中发现的测试基础设施问题 |
| [B] 缺陷发现 | Documents/AutoPlans/DiscoveryPlans/TestInfrastructure_Plan.md | 测试框架缺陷、helper 问题、状态泄漏 |
| [C] 测试覆盖 | Documents/AutoPlans/TestCoverage/ 下所有 8 个 *_TestGaps.md | 所有模块的测试质量问题 + 缺失测试（核心输入） |
| [D] 架构评审 | Documents/AutoPlans/ArchitectureReview/ModuleStructure_ArchReview.md | 测试模块架构组织 |
| [E] 参考对比 | Documents/AutoPlans/ReferenceComparison/CrossComparison.md | D9 测试基础设施对比 |

## 特殊说明

本模块的 Plan 本身就是关于测试的改进计划。其中：
- 测试框架修复和 Helper 重构的条目，其 -T 测试任务是对改进本身的验证测试
- 测试覆盖扩展的条目，其内容本身就是需要新增的测试，-T 任务与主任务可合并

## 源码验证范围

Plugins/Angelscript/Source/AngelscriptTest/
$sharedInstructions
"@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "impplan_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "ImprovementPlanner $Module"
        PromptFile    = $promptFile
        MaxIterations = $MaxIterations
    }
    if ($ExtraArgs) {
        & $ralphLoop @params @ExtraArgs
    } else {
        & $ralphLoop @params
    }
}
finally {
    if (Test-Path $promptFile) { Remove-Item $promptFile -Force -ErrorAction SilentlyContinue }
}
