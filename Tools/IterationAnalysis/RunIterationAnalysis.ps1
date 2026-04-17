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

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    RuntimeCore = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

RuntimeCore -- 引擎生命周期、全局状态、上下文栈
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Core/
重点: 引擎生命周期正确性、全局状态收口完整性、GC追踪覆盖、ContextStack使用模式、subsystem集成边界
入口: AngelscriptEngine.h, AngelscriptEngine.cpp, AngelscriptGameInstanceSubsystem.cpp
输出: Documents/AutoPlans/RuntimeCore_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/RuntimeCore_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    ClassGenerator = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

ClassGenerator -- 动态UClass生成、热重载、版本链
源码: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/
重点: 热重载正确性、版本链内存安全、UClass生成一致性、类型注册顺序、构造函数/析构函数对称性
入口: ASClass.h, ASClass.cpp
输出: Documents/AutoPlans/ClassGenerator_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/ClassGenerator_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    BindSystem = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

BindSystem -- 123个Bind_*.cpp文件，API覆盖对比UEAS2
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/
重点: API覆盖缺口、null安全检查、错误处理一致性、绑定命名规范、缺失重载
入口: Bind_UObject.cpp, Bind_AActor.cpp, Bind_UWorld.cpp
输出: Documents/AutoPlans/BindSystem_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/BindSystem_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    TestInfrastructure = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

TestInfrastructure -- AngelscriptTest模块、隔离性、覆盖率
源码: Plugins/Angelscript/Source/AngelscriptTest/
重点: 测试隔离度、FAngelscriptEngineScope使用、覆盖缺口、测试间依赖、cleanup正确性、遗漏边界条件
入口: AngelscriptEngineCoreTests.cpp, AngelscriptTestHelpers.h
输出: Documents/AutoPlans/TestInfrastructure_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/TestInfrastructure_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    Preprocessor = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

Preprocessor -- import解析、include处理、模块系统
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/
重点: import路径解析边界情况、循环依赖检测、错误恢复路径、模块描述符一致性、预处理性能
入口: AngelscriptPreprocessor.cpp, AngelscriptPreprocessor.h
输出: Documents/AutoPlans/Preprocessor_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/Preprocessor_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    DebuggingAndJIT = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

DebuggingAndJIT -- DebugServer V2协议、JIT编译
源码: Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/ 和 StaticJIT/
重点: 调试协议完整性、DAP合规、断点/步进正确性、JIT覆盖的脚本功能范围、fallback安全性
输出: Documents/AutoPlans/DebuggingAndJIT_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/DebuggingAndJIT_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    FunctionLibraries = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

FunctionLibraries -- 21+脚本辅助函数库
源码: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/
重点: API完整性、与UE原生函数的一致性、文档覆盖、重复实现检测、缺失高频utility
输出: Documents/AutoPlans/FunctionLibraries_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/FunctionLibraries_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@

    UHTTool = @'
你正在执行 Angelscript 插件的迭代式代码深度分析。严格遵循 Documents/Rules/IterationAnalysisRule_ZH.md。

## 分析目标

UHTTool -- 生成函数表、头文件签名解析器
源码: Plugins/Angelscript/Source/AngelscriptUHTTool/
重点: 代码生成正确性、增量构建支持、错误诊断质量、与UE5.x UHT API的适配边界
入口: AngelscriptHeaderSignatureResolver.cs
输出: Documents/AutoPlans/UHTTool_Analysis.md

## 工作指令

1. 输出文件固定为 Documents/AutoPlans/UHTTool_Analysis.md。
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的发现，只写新内容。
6. 如果文件不存在，创建文件并写入标题和首次分析内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. 通过读取实际源代码收集证据。
9. 深度优于广度，5个有证据的发现优于20个表面观察。
10. 所有文字中文，代码、路径、技术术语英文。
'@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "ia_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "IterationAnalysis $Module"
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
