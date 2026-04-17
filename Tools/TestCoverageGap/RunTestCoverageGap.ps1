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
2. 先读取已有文件内容，了解前面已记录的发现。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 测试审查 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的内容，只写新发现。
6. 如果文件不存在，创建文件并写入标题和首次内容。
7. 每发现一个问题立即写入文件，不在内存中积攒。
8. **优先审查现有测试文件的质量**（断言充分性、隔离正确性、反模式、清理完整性），然后再分析缺失场景和无测试源码。
9. 读取每个测试 .cpp 文件的完整源码来判断质量，不要只看文件名和测试数量。
10. 现有测试问题必须附带修复建议；新增测试建议必须包含测试名、场景、断言、Helper。
11. 测试建议遵循项目规范：ASTEST_* 宏、Angelscript.TestModule.* 命名、单文件 300-500 行。
12. 每轮结束时输出汇总表（现有问题统计 + 新增建议统计）。
13. 跳过 ThirdParty/ 下的第三方代码。
14. 所有文字中文，代码、路径、技术术语英文。
'@

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    RuntimeCore = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

RuntimeCore -- 引擎核心相关测试
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Core/, Subsystem/, GC/, FileSystem/
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/Core/
输出: Documents/AutoPlans/TestCoverage/RuntimeCore_TestGaps.md

## 需要审查的现有测试文件（共约 12 个）

Core/ 目录: AngelscriptEngineCoreTests.cpp(6用例), AngelscriptEngineParityTests.cpp(15用例), AngelscriptEnginePerformanceTests.cpp(4用例), AngelscriptBindConfigTests.cpp(13用例), AngelscriptGeneratedFunctionTableTests.cpp(11用例), AngelscriptPerformanceArtifactTests.cpp(1用例), AngelscriptUhtCoverageTestTypes.cpp(无用例)
Subsystem/: AngelscriptSubsystemScenarioTests.cpp(4用例)
GC/: AngelscriptGCScenarioTests.cpp(3用例)
FileSystem/: AngelscriptFileSystemTests.cpp(8用例)

## 重点审查方向

1. 逐文件读取上述测试 .cpp，审查每个测试的断言是否充分、隔离是否正确
2. 检查 FAngelscriptEngineScope 的使用是否正确（是否有测试绕过了它）
3. 检查 AngelscriptEngineCoreTests 的 6 个用例是否覆盖了 FAngelscriptEngine 的关键生命周期
4. EngineParityTests(15用例) 断言是否精确还是只做了粗粒度检查
5. GCScenarioTests 是否真正触发了 GC 并验证了对象存活/回收
6. 然后扫描 Core/ 源码，发现完全无测试覆盖的关键文件（如 GAS 相关）
$sharedInstructions
"@

    ClassGenerator = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

ClassGenerator -- 类生成器与热重载相关测试
测试目录: Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/, HotReload/
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/
输出: Documents/AutoPlans/TestCoverage/ClassGenerator_TestGaps.md

## 需要审查的现有测试文件（共约 8 个）

ClassGenerator/: AngelscriptScriptClassCreationTests.cpp(8用例), ClassGeneratorTests.cpp(1用例)
HotReload/: AngelscriptHotReloadAnalysisTests.cpp(7用例), AngelscriptHotReloadFunctionTests.cpp(6用例), AngelscriptHotReloadPropertyTests.cpp(4用例), AngelscriptHotReloadScenarioTests.cpp(4用例), AngelscriptHotReloadPerformanceTests.cpp(4用例), AngelscriptNativeScriptHotReloadTests.cpp(3用例)

## 重点审查方向

1. 逐文件读取上述测试 .cpp，审查断言充分性和隔离正确性
2. ClassGeneratorTests 只有 1 个用例——是否有意义？断言了什么？
3. ScriptClassCreation 的 8 个用例是否覆盖了不同的类结构（空类、带属性、带函数、继承）
4. 热重载测试的 28 用例是否真正验证了版本链完整性、CDO 一致性
5. HotReloadPerformanceTests 的断言是否合理（性能阈值是否过于宽松）
6. 然后扫描 ClassGenerator/ 源码，发现未覆盖的公共 API（如 ASStruct 相关）
$sharedInstructions
"@

    BindSystem = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

BindSystem -- 绑定系统相关测试（测试文件数最多的区域之一）
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Bindings/ (24 个测试文件)
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/ (126 .cpp + 24 .h)
输出: Documents/AutoPlans/TestCoverage/BindSystem_TestGaps.md

## 需要审查的现有测试文件（共 24 个）

AngelscriptBlueprintCallableReflectiveFallbackTests.cpp(4用例), AngelscriptClassBindingsTests.cpp(6用例), AngelscriptCompatBindingsTests.cpp(4用例), AngelscriptConsoleBindingsTests.cpp(5用例), AngelscriptContainerBindingsTests.cpp(6用例), AngelscriptContainerCompareBindingsTests.cpp(4用例), AngelscriptCoreMiscBindingsTests.cpp(3用例), AngelscriptEngineBindingsTests.cpp(5用例), AngelscriptFileAndDelegateBindingsTests.cpp(4用例), AngelscriptGameplayTagBindingsTests.cpp(3用例), AngelscriptGlobalBindingsTests.cpp(1用例), AngelscriptIteratorBindingsTests.cpp(2用例), AngelscriptMathAndPlatformBindingsTests.cpp(3用例), AngelscriptNativeEngineBindingsTests.cpp(3用例), AngelscriptObjectBindingsTests.cpp(2用例), AngelscriptUtilityBindingsTests.cpp(5用例) 等

## 重点审查方向

1. 逐文件读取已有 24 个测试，审查每个用例的断言质量
2. 很多测试文件只有 2-5 个用例但对应的 Bind_*.cpp 可能注册了 20-50 个函数——断言是否只验证了少数函数
3. GlobalBindingsTests 只有 1 个用例——是否有实际意义
4. 检查绑定测试是否测试了 null 输入、无效类型、空容器等边界情况
5. 检查测试是否验证了绑定函数的返回值语义与 UE 原生 API 一致
6. 然后统计 126 个 Bind_*.cpp 中哪些有对应测试、哪些完全没有
$sharedInstructions
"@

    Preprocessor = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

Preprocessor -- 预处理器与编译管线相关测试
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/, Compiler/
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/
输出: Documents/AutoPlans/TestCoverage/Preprocessor_TestGaps.md

## 需要审查的现有测试文件（共 2 个）

Preprocessor/: AngelscriptPreprocessorTests.cpp(3用例)
Compiler/: AngelscriptCompilerPipelineTests.cpp(8用例)

## 重点审查方向

1. 读取 AngelscriptPreprocessorTests.cpp 的完整源码，审查 3 个用例分别测试了什么，断言是否充分
2. 读取 AngelscriptCompilerPipelineTests.cpp 的完整源码，审查 8 个用例的覆盖范围
3. 预处理器只有 3 个用例——是否覆盖了 import 解析、include 处理、错误恢复等关键路径
4. 编译管线 8 个用例是否覆盖了从源码到可执行字节码的完整流程
5. 检查这些测试是否测试了边界情况：空文件、语法错误、循环 import、超长文件
6. 然后扫描源码，发现 Helper_CommentFormat.h 等无测试覆盖的文件
$sharedInstructions
"@

    DebuggingAndJIT = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

DebuggingAndJIT -- 调试器相关测试
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Debugger/
测试基础设施: Plugins/Angelscript/Source/AngelscriptTest/Shared/ (DebuggerScriptFixture, DebuggerTestSession, DebuggerTestClient)
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/ + StaticJIT/
输出: Documents/AutoPlans/TestCoverage/DebuggingAndJIT_TestGaps.md

## 需要审查的现有测试文件（共 3 个）

Debugger/: AngelscriptDebuggerBreakpointTests.cpp(3用例), AngelscriptDebuggerSteppingTests.cpp(3用例), AngelscriptDebuggerSmokeTests.cpp(1用例)

## 重点审查方向

1. 读取 3 个调试器测试文件的完整源码，审查 7 个用例分别测试了什么
2. 断点测试(3用例)是否覆盖了：设置断点、命中断点、删除断点、条件断点
3. 步进测试(3用例)是否覆盖了：step in、step over、step out、跨文件步进
4. 冒烟测试(1用例)验证了什么——是否只是"调试器能启动"
5. 审查 Shared/ 下的调试器 fixture/session/client 代码质量：是否正确处理连接超时、是否有清理
6. 然后评估 StaticJIT/ 的 14 个文件是否有任何测试覆盖（高风险缺口）
$sharedInstructions
"@

    FunctionLibraries = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

FunctionLibraries -- 函数库相关测试（分散在多个测试目录）
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/ (1 .cpp + 20 .h)
测试: 分散在 AngelscriptTest/ 的多个子目录中，需要通过搜索函数名定位
输出: Documents/AutoPlans/TestCoverage/FunctionLibraries_TestGaps.md

## 分析方法

由于函数库测试分散，本模块需要先建立映射：
1. 读取每个函数库 .h，列出导出的函数名
2. 在 AngelscriptTest/ 全目录搜索每个函数名，找到覆盖它的测试文件
3. 对找到的测试文件，读取并审查相关用例的质量

## 需要定位并审查的函数库（20 个 .h）

AngelscriptActorLibrary.h, AngelscriptComponentLibrary.h, AngelscriptMathLibrary.h, AngelscriptWorldLibrary.h, AngelscriptHitResultLibrary.h, AngelscriptLevelStreamingLibrary.h, AngelscriptScriptLibrary.h, AngelscriptFrameTimeMixinLibrary.h, GameplayLibrary.h, GameplayTagContainerMixinLibrary.h, GameplayTagMixinLibrary.h, GameplayTagQueryMixinLibrary.h, InputComponentScriptMixinLibrary.h, RuntimeCurveLinearColorMixinLibrary.h, RuntimeFloatCurveMixinLibrary.h, SoftReferenceStatics.h, SubsystemLibrary.h, UAssetManagerMixinLibrary.h, WidgetBlueprintStatics.h, WorldCollisionStatics.h

## 重点审查方向

1. 对找到的测试，检查断言是否覆盖了函数的关键行为和返回值语义
2. 检查是否测试了无效输入（null Actor, 空容器, 无效 Tag 等）
3. 判断哪些函数库有测试、哪些完全没有——完全没有的优先建议新增
4. 高频使用的库（Math, Actor, World）的测试质量比冷门库更重要
$sharedInstructions
"@

    LanguageFeatures = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

LanguageFeatures -- 语言特性与内部组件测试（测试数量最大的区域）
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Angelscript/ (18文件), Internals/ (14文件), Interface/ (6文件)
对应源码: Plugins/Angelscript/Source/AngelscriptRuntime/Core/（语言运行时层）
输出: Documents/AutoPlans/TestCoverage/LanguageFeatures_TestGaps.md

## 需要审查的现有测试文件（共约 38 个，~130 用例）

Angelscript/ (18文件): TypeTests(11), ControlFlowTests(5), ExecutionTests(9), CoreExecutionTests(6), FunctionTests(8), InheritanceTests(5), OperatorTests(4), HandleTests(4), ObjectModelTests(6), MiscTests(5), UpgradeCompatibilityTests(5), NativeScriptHotReloadTests(3) 等
Internals/ (14文件): BuilderTests(4), BytecodeTests(4), CompilerTests(4), DataTypeTests(4), GCInternalTests(6), MemoryTests(5), ParserTests(4), RestoreTests(4), ScriptNodeTests(3), TokenizerTests(4), StructCppOpsTests(1) 等
Interface/ (6文件): DeclareTests(2), CastTests(3), ImplementTests(3), AdvancedTests(9), NativeTests(3)

## 重点审查方向

1. 这是测试最多的区域——逐文件审查断言质量，特别关注 TypeTests(11用例) 和 ExecutionTests(9用例) 是否对每个语言特性都有精确断言
2. Internals/ 的每个组件测试（Parser, Tokenizer, Compiler 等）是否测试了错误输入和边界情况
3. Interface/ 测试是否覆盖了 UInterface 完整生命周期（关联 P10 UInterface 支持主线）
4. ControlFlowTests(5用例) 是否覆盖了所有控制流结构: if/else, switch, for, while, foreach, break, continue, 嵌套
5. StructCppOpsTests 只有 1 个用例——是否合理
6. 检查测试间是否有隐式依赖（某个测试依赖前一个测试创建的类型）
$sharedInstructions
"@

    EditorAndTools = @"
你正在执行 Angelscript 插件的测试质量审查与覆盖补全。严格遵循 Documents/Rules/TestCoverageGapRule_ZH.md。

## 分析目标

EditorAndTools -- 编辑器相关测试（测试最少的区域）
测试目录: Plugins/Angelscript/Source/AngelscriptTest/Editor/, Plugins/Angelscript/Source/AngelscriptEditor/Private/Tests/
对应源码: Plugins/Angelscript/Source/AngelscriptEditor/ (15 .cpp + 16 .h)
输出: Documents/AutoPlans/TestCoverage/EditorAndTools_TestGaps.md

## 需要审查的现有测试文件（仅 3 个）

AngelscriptTest/Editor/: AngelscriptSourceNavigationTests.cpp(1用例)
AngelscriptEditor/Private/Tests/: AngelscriptBlueprintImpactScannerTests.cpp, AngelscriptDirectoryWatcherTests.cpp

## 重点审查方向

1. 读取 3 个测试文件的完整源码，审查每个用例的断言质量
2. SourceNavigationTests 只有 1 个用例——测试了什么？断言是否有意义？
3. BlueprintImpactScannerTests 是否覆盖了扫描器的关键场景（有影响/无影响/部分影响）
4. DirectoryWatcherTests 是否正确处理了文件系统事件的异步性和 cleanup
5. 然后扫描编辑器源码，统计 31 个文件中哪些有对应测试、哪些完全没有
6. 重点关注: EditorModule 生命周期、ClassReloadHelper、ContentBrowserDataSource、EditorMenuExtensions 均无测试
$sharedInstructions
"@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "tcg_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "TestCoverageGap $Module"
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
