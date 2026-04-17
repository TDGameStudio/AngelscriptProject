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

## 工作指令

1. 输出文件固定为上面指定的路径。
2. 先读取已有文件内容，了解前面已记录的发现和方案。
3. 如果对应的 Documents/AutoPlans/<Module>_Analysis.md 存在，也读取它以避免重复发现。
4. 在文档末尾追加本轮新发现和方案，用 --- 分隔线和 ## 发现与方案 (日期时间) 标题区分。
5. 不得删除或覆盖已有内容，只在末尾追加。
6. 不重述前面已记录的发现，只写新内容。
7. 如果文件不存在，创建文件并写入标题和首次内容。
8. 每发现一个问题立即写入文件（含问题描述和解决方案），不在内存中积攒。
9. 通过读取实际源代码收集证据，引用具体文件路径和行号。
10. 每个发现必须附带具体可执行的解决方案，不允许只列问题不给方案。
11. 深度优于广度，3个有完整方案的发现优于10个没有方案的观察。
12. 每轮结束时输出优先级汇总表。
13. 所有文字中文，代码、路径、技术术语英文。
'@

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    RuntimeCore = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

RuntimeCore -- 引擎生命周期、全局状态、上下文栈
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Core/
入口: AngelscriptEngine.h, AngelscriptEngine.cpp, AngelscriptGameInstanceSubsystem.cpp
输出: Documents/AutoPlans/DiscoveryPlans/RuntimeCore_Plan.md

## 重点发现方向

**Defect**: 引擎初始化/销毁顺序错误、GC 追踪遗漏导致悬空指针、ContextStack push/pop 不配对、subsystem 生命周期与引擎生命周期不同步
**Refactoring**: 引擎初始化步骤过于集中的大函数、重复的状态检查逻辑、可提取为独立 helper 的代码段
**Architecture**: 引擎与 subsystem 的职责边界是否清晰、ContextStack 的并发安全性、模块间的隐式依赖
$sharedInstructions
"@

    ClassGenerator = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

ClassGenerator -- 动态 UClass 生成、热重载、版本链
源码: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/
入口: ASClass.h, ASClass.cpp
输出: Documents/AutoPlans/DiscoveryPlans/ClassGenerator_Plan.md

## 重点发现方向

**Defect**: 热重载时旧版本类未正确清理导致内存泄漏、类型注册顺序导致的依赖未满足、CDO（Class Default Object）状态不一致、版本链断裂导致的 crash
**Refactoring**: 类生成流程中重复的模板代码、过长的注册函数、可提取为 builder 模式的顺序操作
**Architecture**: 版本链管理是否应该独立为子模块、热重载策略与 UE 原生热重载的交互模式、类型系统的扩展性
$sharedInstructions
"@

    BindSystem = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

BindSystem -- 123 个 Bind_*.cpp 文件，API 覆盖对比 UEAS2
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/
入口: Bind_UObject.cpp, Bind_AActor.cpp, Bind_UWorld.cpp
输出: Documents/AutoPlans/DiscoveryPlans/BindSystem_Plan.md

## 重点发现方向

**Defect**: null 指针未检查直接解引用、错误的参数类型转换、返回值语义与 UE 原生 API 不一致、缺失的错误处理导致静默失败
**Refactoring**: 绑定注册宏的重复模式可提取为统一 helper、多个 Bind 文件中的相似错误检查逻辑可合并、命名不一致的绑定函数
**Architecture**: 绑定分片策略是否合理、与 UEAS2 的 API 覆盖差距（缺失 11 个文件的影响）、绑定层与 Runtime Core 的耦合度
$sharedInstructions
"@

    TestInfrastructure = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

TestInfrastructure -- AngelscriptTest 模块、隔离性、覆盖率
源码: Plugins/Angelscript/Source/AngelscriptTest/
入口: AngelscriptEngineCoreTests.cpp, AngelscriptTestHelpers.h
输出: Documents/AutoPlans/DiscoveryPlans/TestInfrastructure_Plan.md

## 重点发现方向

**Defect**: 测试间状态泄漏导致的不稳定结果、FAngelscriptEngineScope 使用不正确导致的引擎上下文混乱、cleanup 缺失导致后续测试失败
**Refactoring**: 测试 helper 中的重复代码、过长的测试函数应拆分为更小的测试用例、测试数据构造逻辑可提取为 fixture
**Architecture**: 测试引擎（Full vs Clone）选择是否合理、共享测试引擎的生命周期管理、测试模块对 Runtime 内部实现的依赖
$sharedInstructions
"@

    Preprocessor = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

Preprocessor -- import 解析、include 处理、模块系统
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/
入口: AngelscriptPreprocessor.cpp, AngelscriptPreprocessor.h
输出: Documents/AutoPlans/DiscoveryPlans/Preprocessor_Plan.md

## 重点发现方向

**Defect**: import 路径解析的边界情况（相对路径、符号链接、大小写不敏感文件系统）、循环 import 未检测导致无限递归、错误恢复路径中的资源泄漏
**Refactoring**: 路径解析逻辑中的重复字符串操作、过长的解析状态机函数、可用正则表达式简化的手写解析器
**Architecture**: 预处理器与编译管线的耦合度、模块描述符的缓存策略、增量预处理的可行性
$sharedInstructions
"@

    DebuggingAndJIT = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

DebuggingAndJIT -- DebugServer V2 协议、JIT 编译
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/ 和 StaticJIT/
输出: Documents/AutoPlans/DiscoveryPlans/DebuggingAndJIT_Plan.md

## 重点发现方向

**Defect**: 调试协议消息解析的边界情况、断点命中判定的 off-by-one 错误、JIT 编译产物与解释执行结果不一致、调试会话异常断开时的资源泄漏
**Refactoring**: 协议消息处理中的重复 switch/case 分支、JIT 代码生成中的重复模式、可用表驱动替代的条件分支
**Architecture**: 调试服务器的线程模型安全性、JIT fallback 到解释执行的切换机制、DAP 协议合规性缺口
$sharedInstructions
"@

    FunctionLibraries = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

FunctionLibraries -- 21+ 脚本辅助函数库
源码: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/
输出: Documents/AutoPlans/DiscoveryPlans/FunctionLibraries_Plan.md

## 重点发现方向

**Defect**: 函数参数边界检查缺失、返回值类型与 UE 原生函数不一致、数学函数精度问题、字符串函数的编码处理错误
**Refactoring**: 不同函数库中的重复 utility 实现、可合并到同一函数库的相关函数、缺失文档注释的公共 API
**Architecture**: 函数库的分类标准是否合理、与 UE BlueprintFunctionLibrary 的对齐程度、缺失的高频 utility 函数
$sharedInstructions
"@

    UHTTool = @"
你正在执行 Angelscript 插件的缺陷发现与解决方案规划。严格遵循 Documents/Rules/DiscoveryPlannerRule_ZH.md。

## 分析目标

UHTTool -- 生成函数表、头文件签名解析器
源码: Plugins/Angelscript/Source/AngelscriptUHTTool/
入口: AngelscriptHeaderSignatureResolver.cs
输出: Documents/AutoPlans/DiscoveryPlans/UHTTool_Plan.md

## 重点发现方向

**Defect**: 代码生成输出不正确（缺失分号、括号不配对）、增量构建判断失效导致不必要的全量重建、头文件签名解析对特殊 UE 宏的处理缺陷
**Refactoring**: 代码生成中的字符串拼接可改用模板引擎、重复的签名模式匹配逻辑、错误消息格式不统一
**Architecture**: 与 UE5.x UHT API 的适配边界、生成代码的版本化策略、增量构建支持的完备性
$sharedInstructions
"@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "dp_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "DiscoveryPlanner $Module"
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
