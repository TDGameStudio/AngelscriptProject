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
3. 如果 Documents/Comparisons/2026-04-07/ 下有对应的 CrossComparison 文档，先读取作为背景输入。
4. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 架构分析 (日期时间) 标题区分。
5. 不得删除或覆盖已有内容，只在末尾追加。
6. 不重述前面已记录的发现或已有对比文档中的内容，只写新的深入分析。
7. 如果文件不存在，创建文件并写入标题和首次内容。
8. 每个发现必须包含三段：当前架构现状（引用插件源码）、参考插件对比（引用 Reference/ 源码）、改进方案（具体步骤）。
9. 通过读取实际源代码收集证据，不凭印象描述参考插件的架构。
10. 改进方案必须可增量实施，标注向后兼容影响。
11. 每轮结束时输出优先级汇总表。
12. 深度优于广度，2 个有完整三段的发现优于 6 个只有现状没有方案的观察。
13. 所有文字中文，代码、路径、技术术语英文。
'@

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    ModuleStructure = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

ModuleStructure -- 模块划分与依赖拓扑
输出: Documents/AutoPlans/ArchitectureReview/ModuleStructure_ArchReview.md

## 当前架构

插件包含以下模块（来自 .uplugin 和各 Build.cs）：
- AngelscriptRuntime — 运行时核心
- AngelscriptEditor — 编辑器
- AngelscriptTest — 测试
- AngelscriptNativeBinds / AngelscriptNativeBindsEditor — 绑定基础设施
- ASRuntimeBind_0~110（12个分片）— Runtime 绑定并行构建
- ASEditorBind_0~30（4个分片）— Editor 绑定并行构建

## 重点分析

1. 读取 Plugins/Angelscript/Angelscript.uplugin 了解模块声明和依赖
2. 读取每个模块的 Build.cs（至少 AngelscriptRuntime, AngelscriptEditor, AngelscriptTest, 绑定分片的几个代表），分析 PublicDependencyModuleNames / PrivateDependencyModuleNames
3. 绘制依赖拓扑：哪些模块依赖哪些，有没有反向依赖或循环
4. 对比 Reference/UnLua/ 和 Reference/puerts/ 的模块拆分策略（它们的 .uplugin 和 Build.cs）
5. 对比 Reference/UnrealCSharp/ 的模块结构
6. 评估当前绑定分片（12+4=16 个模块）策略的优劣：编译并行度 vs 模块管理复杂度
7. 提出改进方案：模块边界是否需要调整、依赖是否需要反转
$sharedInstructions
"@

    BindingPipeline = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

BindingPipeline -- 绑定注册管线与可扩展性
输出: Documents/AutoPlans/ArchitectureReview/BindingPipeline_ArchReview.md

## 当前架构

绑定注册入口: Core/AngelscriptBinds.h/cpp, Core/AngelscriptBindDatabase.h/cpp
绑定实现: Binds/ 目录下 126 个 Bind_*.cpp（手写绑定）
绑定分片: ASRuntimeBind_*/ASEditorBind_* 模块把绑定分散到多个编译单元

## 重点分析

1. 读取 AngelscriptBinds.h/cpp 和 AngelscriptBindDatabase.h/cpp，理解绑定注册流程
2. 读取 2-3 个典型 Bind_*.cpp（如 Bind_UObject, Bind_AActor），理解绑定的编写模式
3. 对比 Reference/UnrealCSharp/ 的绑定管线：它如何通过代码生成自动产出绑定
4. 对比 Reference/puerts/ 的声明文件生成策略
5. 对比 Reference/UnLua/ 的反射绑定机制
6. 评估当前手写绑定模式的扩展性：新增一个 UE 类型需要几步？能否自动化？
7. 评估用户（脚本开发者）能否注册自定义绑定而不修改插件源码
$sharedInstructions
"@

    TypeSystem = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

TypeSystem -- 类型系统与反射集成架构
输出: Documents/AutoPlans/ArchitectureReview/TypeSystem_ArchReview.md

## 当前架构

类型核心: Core/AngelscriptType.h/cpp — AS 类型到 UE 类型的桥接
类生成器: ClassGenerator/ASClass.h/cpp, ASStruct.h/cpp — 动态 UClass/UStruct 生成
反射集成: UHT 工具 AngelscriptUHTTool/ 生成辅助代码

## 重点分析

1. 读取 AngelscriptType.h/cpp，理解 AS 与 UE 类型系统的映射架构
2. 读取 ASClass.h，理解动态 UClass 生成的架构
3. 对比 Reference/UnLua/ 的类型桥接方式（Lua table ↔ UObject）
4. 对比 Reference/puerts/ 的 TypeScript ↔ UE 类型映射
5. 对比 Reference/UnrealCSharp/ 的 C# ↔ UE 类型系统集成
6. 评估类型系统的扩展性：添加新类型映射（如新的容器类型）需要改动多少地方
7. 评估 UInterface 支持的架构障碍（关联 P10 当前主线）
$sharedInstructions
"@

    HotReloadArch = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

HotReloadArch -- 热重载架构与状态保持
输出: Documents/AutoPlans/ArchitectureReview/HotReloadArch_ArchReview.md

## 当前架构

热重载核心: ClassGenerator/AngelscriptClassGenerator.h/cpp — 类版本链管理
变更检测: 文件系统监控（AngelscriptEditor 的 DirectoryWatcher）
状态保持: CDO（Class Default Object）迁移

## 重点分析

1. 读取 AngelscriptClassGenerator.h/cpp，理解热重载的版本链架构
2. 读取编辑器侧的 ClassReloadHelper.h/cpp 和 DirectoryWatcher 相关代码
3. 对比 Reference/UnLua/ 的热重载架构（Lua require 缓存刷新策略）
4. 对比 Reference/puerts/ 的热重载实现
5. 评估当前架构的增量重载能力：修改一个函数是否需要重载整个类
6. 评估状态保持的健壮性：哪些场景下状态会丢失
7. 评估与 UE 原生热重载（C++ Live Coding）的交互
$sharedInstructions
"@

    ScriptLifecycle = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

ScriptLifecycle -- 脚本编译-加载-执行管线架构
输出: Documents/AutoPlans/ArchitectureReview/ScriptLifecycle_ArchReview.md

## 当前架构

预处理: Preprocessor/AngelscriptPreprocessor.h/cpp — import 解析、模块发现
编译: Core/angelscript.h（AS 引擎 API）→ AngelscriptEngine 驱动编译
执行: FAngelscriptEngine 管理脚本模块的编译和执行
生命周期: UAngelscriptGameInstanceSubsystem 持有引擎，通过 subsystem tick 驱动

## 重点分析

1. 读取 AngelscriptEngine.h/cpp 中编译和执行的关键流程
2. 读取 AngelscriptPreprocessor.h 了解预处理管线
3. 对比 Reference/puerts/ 的 JS/TS 模块系统（import/require 解析、模块缓存）
4. 对比 Reference/UnLua/ 的 Lua chunk 管理（require、package.path）
5. 评估编译管线的可扩展性：能否插入自定义编译阶段（如 lint、优化 pass）
6. 评估模块系统的能力：是否支持条件编译、版本化模块、模块热替换
7. 评估脚本加载的延迟策略：是否支持按需加载而非启动全量编译
$sharedInstructions
"@

    DebugAndToolchain = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

DebugAndToolchain -- 调试与工具链架构
输出: Documents/AutoPlans/ArchitectureReview/DebugAndToolchain_ArchReview.md

## 当前架构

调试服务器: Debugging/AngelscriptDebugServer.h/cpp — V2 协议
JIT: StaticJIT/ — 静态 JIT 编译（14 个文件）
代码生成: AngelscriptUHTTool/ — UHT 扩展工具
文档生成: Core/AngelscriptDocs.h/cpp

## 重点分析

1. 读取 AngelscriptDebugServer.h，理解调试协议架构（自定义 vs DAP）
2. 读取 StaticJIT 几个关键文件，理解 JIT 编译架构
3. 对比 Reference/puerts/ 的 V8 Inspector 集成——它如何复用 Chrome DevTools 协议
4. 对比 Reference/UnLua/ 的调试器集成方式
5. 评估调试架构的可扩展性：能否支持远程调试、能否支持多种 IDE 前端
6. 评估 JIT 架构：当前 StaticJIT 的覆盖范围和 fallback 策略是否合理
7. 评估工具链架构：UHT 工具、文档生成、代码导航是否有统一的管线设计
$sharedInstructions
"@

    ExtensionPoints = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

ExtensionPoints -- 插件扩展点与用户可定制性
输出: Documents/AutoPlans/ArchitectureReview/ExtensionPoints_ArchReview.md

## 当前架构

设置: Core/AngelscriptSettings.h
Subsystem: Core/AngelscriptGameInstanceSubsystem.h/cpp
委托/事件: 散布在各模块中
引擎配置: FAngelscriptEngineConfig, FAngelscriptEngineDependencies（依赖注入）

## 重点分析

1. 搜索插件源码中所有 DECLARE_MULTICAST_DELEGATE / DECLARE_DELEGATE / OnXxx 事件
2. 搜索所有可通过 ini/settings 配置的行为
3. 搜索所有 virtual 函数——用户子类化的扩展点
4. 对比 Reference/UnrealCSharp/ 的扩展模式：用户如何自定义 C# 绑定行为
5. 对比 Reference/UnLua/ 的模块钩子：用户如何在不修改插件源码的情况下介入
6. 对比 Reference/puerts/ 的扩展机制
7. 评估：脚本开发者想做以下事情需要改插件源码吗？
   - 添加自定义全局函数
   - 修改编译行为（如自定义 import 解析）
   - 添加自定义类型绑定
   - 订阅编译/热重载事件
$sharedInstructions
"@

    EditorArch = @"
你正在执行 Angelscript 插件的架构与扩展性分析。严格遵循 Documents/Rules/ArchitectureReviewRule_ZH.md。

## 分析目标

EditorArch -- 编辑器集成架构
输出: Documents/AutoPlans/ArchitectureReview/EditorArch_ArchReview.md

## 当前架构

编辑器模块: AngelscriptEditor/（15 .cpp + 16 .h）
关键组件: EditorModule, ContentBrowserDataSource, DirectoryWatcher, ClassReloadHelper, SourceCodeNavigation
菜单扩展: EditorMenuExtensions/（4 对 .h/.cpp）
蓝图影响扫描: BlueprintImpact/

## 重点分析

1. 读取 AngelscriptEditorModule.cpp，理解编辑器模块的初始化和功能注册
2. 读取 ContentBrowserDataSource，理解脚本资产在编辑器中的展示
3. 对比 Reference/UnLua/ 的编辑器集成（工具栏、面板、资产管理）
4. 对比 Reference/puerts/ 的编辑器集成
5. 对比 Reference/UnrealCSharp/ 的编辑器集成
6. 评估编辑器功能的可扩展性：用户能否通过 Editor Subsystem 扩展编辑器功能
7. 评估与 UE 编辑器框架的集成深度：是否充分利用了 Slate/工具注册/命令系统
$sharedInstructions
"@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "ar_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "ArchitectureReview $Module"
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
