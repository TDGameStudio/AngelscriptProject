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

# ── 读取 Hazelight 路径 ──────────────────────────────────────────────────────
$hazelightRoot = ''
$iniPath = Join-Path $workspace 'AgentConfig.ini'
if (Test-Path $iniPath) {
    foreach ($line in (Get-Content $iniPath -Encoding UTF8)) {
        if ($line -match '^\s*HazelightAngelscriptEngineRoot\s*=\s*(.+)$') {
            $val = $Matches[1].Trim()
            if ($val -ne '') { $hazelightRoot = $val; break }
        }
    }
}

# ── 共用工作指令模板 ─────────────────────────────────────────────────────────
$sharedInstructions = @'

## 工作指令

1. 输出文件固定为上面指定的路径。
2. 先读取已有文件内容，了解前面迭代已记录的分析。
3. 在文档末尾追加本轮新发现，用 --- 分隔线和 ## 深化分析 (日期时间) 标题区分。
4. 不得删除或覆盖已有内容，只在末尾追加。
5. 不重述前面已记录的分析，只写新增发现或更深层次的补充。
6. 如果文件不存在，按规则文档中定义的文档结构创建文件并写入完整骨架和首次分析。
7. 每个维度必须包含至少一张 ASCII 架构/调用链图和带注释的关键源码引用。
8. 通过读取实际源代码收集证据，引用具体文件路径和行号。
9. 对比结论必须有源码证据支撑，不能只说"A 比 B 好"。
10. 差距判断区分"没有实现" vs "实现方式不同" vs "实现质量差异"。
11. 深度优于广度，3 个有深入源码分析的维度优于 11 个浅尝辄止的维度。
12. 所有正文和代码注释中文，代码、路径、技术术语英文。
13. 不生成 TodoList 章节。
'@

# ── 维度速查 ─────────────────────────────────────────────────────────────────
$dimensionRef = @'

## 对比维度速查 (D1-D11)

| 编号 | 维度 | 分析重点 |
| --- | --- | --- |
| D1 | 插件架构与模块划分 | 模块数量与职责、Build.cs 依赖关系、第三方库集成方式 |
| D2 | 反射绑定机制 | UClass/UStruct/UEnum/UInterface/Delegate 暴露方式、绑定代码生成 vs 手写 |
| D3 | Blueprint 交互 | 脚本覆写 Blueprint 事件、脚本调用 Blueprint 函数、混合继承链 |
| D4 | 热重载 | 脚本变更检测机制、重载粒度、状态保持策略、失败恢复 |
| D5 | 调试与开发体验 | 调试协议、断点与单步、IDE 集成、日志诊断 |
| D6 | 代码生成与 IDE 支持 | 类型声明文件生成、智能提示、代码补全、跳转定义 |
| D7 | 编辑器集成 | 编辑器菜单/面板扩展、资产浏览器集成、Commandlet 支持 |
| D8 | 性能与优化 | JIT/AOT、调用开销、内存管理、批量绑定优化 |
| D9 | 测试基础设施 | 测试框架选择、测试分层组织、CI 集成、覆盖率 |
| D10 | 文档与示例组织 | 用户文档结构、API 参考生成、教程与示例项目 |
| D11 | 部署与打包 | 脚本打包方式、加密/签名、平台适配、版本兼容性 |
'@

# ── 模块定义 ─────────────────────────────────────────────────────────────────
$modules = @{
    Hazelight = @"
你正在执行 Reference 对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

Hazelight Angelscript (UEAS2) — 纵向分析文档
源码路径: 通过 AgentConfig.ini 中 References.HazelightAngelscriptEngineRoot 定位，值为: $hazelightRoot
对比基准: Plugins/Angelscript/
输出: Documents/AutoPlans/ReferenceComparison/Hazelight_Analysis.md

## 参考插件概述

Hazelight 是当前 Angelscript 插件的直接上游参考源。其集成深入 UE 引擎层面，包含：
- 三模块结构：AngelscriptCode (Runtime)、AngelscriptEditor、AngelscriptLoader
- 125 个 Bind_*.cpp 绑定文件
- AngelScript 2.33.0 WIP 嵌入式集成
- 引擎侧 UHT 修改（10 个 C# + 22 个 C++ 文件）

## 重点分析方向

1. **模块架构差异** (D1)：UEAS2 三模块 vs AngelPortV2 多模块结构（Runtime + Editor + Test + NativeBinds + 绑定分片），分析各自的优劣
2. **反射绑定** (D2)：125 vs 123 个绑定文件的差异，缺失的 11 个文件和新增的 9 个文件分别覆盖什么能力
3. **Blueprint 交互** (D3)：Mixin/覆写/继承链的实现差异
4. **热重载** (D4)：AngelscriptLoader 在 UEAS2 中的角色 vs AngelPortV2 移除 Loader 后的替代方案
5. **调试** (D5)：DebugServer V2 协议一致性
6. **引擎侧修改** (D8/D11)：UEAS2 的 UHT 修改意味着什么、AngelPortV2 如何不依赖引擎修改达到类似能力
$dimensionRef
$sharedInstructions
"@

    UnrealCSharp = @"
你正在执行 Reference 对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

UnrealCSharp — 纵向分析文档
源码路径: Reference/UnrealCSharp/
对比基准: Plugins/Angelscript/
输出: Documents/AutoPlans/ReferenceComparison/UnrealCSharp_Analysis.md

## 参考插件概述

UnrealCSharp 是 UE 的 C# 脚本插件，基于 Mono/.NET 运行时。特点：
- 自动化反射绑定（UHT 驱动的 C# 声明生成）
- 完善的类型桥接系统
- 成熟的工程组织和模块划分

## 重点分析方向

1. **插件架构** (D1)：模块划分策略、Build.cs 依赖图、第三方运行时（Mono/.NET）的集成方式，对比 AngelScript ThirdParty 的嵌入式集成
2. **反射绑定** (D2)：UHT 自动生成 C# 声明 vs Angelscript 手写 Bind_*.cpp、绑定注册时机与生命周期管理差异
3. **Blueprint 交互** (D3)：C# 如何覆写 Blueprint 事件、P/Invoke 桥接 vs Angelscript 的直接注册
4. **代码生成** (D6)：C# 类型声明自动生成流程、IDE 智能提示如何实现
5. **性能策略** (D8)：JIT/AOT 编译路径、GC 策略、与 Angelscript 解释/StaticJIT 的性能特征差异
6. **部署打包** (D11)：C# 程序集的打包、AOT 编译部署 vs Angelscript 脚本打包
$dimensionRef
$sharedInstructions
"@

    UnLua = @"
你正在执行 Reference 对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

UnLua (Tencent) — 纵向分析文档
源码路径: Reference/UnLua/
对比基准: Plugins/Angelscript/
输出: Documents/AutoPlans/ReferenceComparison/UnLua_Analysis.md

## 参考插件概述

UnLua 是腾讯的 UE Lua 脚本方案，特点：
- 零胶水反射暴露（直接利用 UE 反射系统）
- Blueprint 事件覆写机制
- 内置调试器与智能提示支持
- 丰富的教程和示例组织

## 重点分析方向

1. **反射绑定** (D2)：零胶水反射接入 vs Angelscript 手写绑定，UnLua 如何直接利用 UProperty/UFunction、对比 Angelscript 的显式注册开销
2. **Blueprint 交互** (D3)：UnLua 的 Blueprint 覆写机制（通过 UnLuaInterface + GetModuleName()）vs Angelscript 的 Mixin，分析优劣
3. **热重载** (D4)：Lua 天然的 require 刷新 vs Angelscript 的全量重编译热重载
4. **调试** (D5)：UnLua 内置调试器的 DAP 协议实现 vs Angelscript DebugServer V2
5. **文档与示例** (D10)：UnLua 的 Docs/ 和 Tutorials/ 组织方式，Angelscript 可借鉴的文档组织模式
6. **测试** (D9)：UnLua 的测试基础设施、CI 集成方式
$dimensionRef
$sharedInstructions
"@

    puerts = @"
你正在执行 Reference 对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

puerts (Tencent) — 纵向分析文档
源码路径: Reference/puerts/unreal/ (UE 插件部分)
对比基准: Plugins/Angelscript/
输出: Documents/AutoPlans/ReferenceComparison/puerts_Analysis.md

## 参考插件概述

puerts 是腾讯的 TypeScript/JavaScript UE 脚本方案，特点：
- 支持多后端（V8、QuickJS、Node.js）
- TypeScript 声明文件自动生成
- 类型安全的脚本开发体验
- 脚本与宿主引擎解耦设计

## 重点分析方向

1. **插件架构** (D1)：多后端抽象层设计（V8/QuickJS/Node.js 切换）vs Angelscript 单一引擎嵌入，模块化解耦的工程策略
2. **反射绑定** (D2)：puerts 的自动声明生成 + 运行时绑定 vs Angelscript 的手写绑定文件
3. **代码生成与 IDE 支持** (D6)：TypeScript .d.ts 声明文件生成流程，如何实现完整的类型安全和 IDE 智能提示，对比 Angelscript 的 IDE 支持策略
4. **性能** (D8)：V8 JIT vs Angelscript 解释/StaticJIT，调用桥接开销对比
5. **热重载** (D4)：JS 模块的 HMR（Hot Module Replacement）vs Angelscript 的全量热重载
6. **部署** (D11)：脚本打包与加密策略、多平台后端选择
$dimensionRef
$sharedInstructions
"@

    sluaunreal = @"
你正在执行 Reference 对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

sluaunreal (Tencent) — 纵向分析文档
源码路径: Reference/sluaunreal/
对比基准: Plugins/Angelscript/
输出: Documents/AutoPlans/ReferenceComparison/sluaunreal_Analysis.md

## 参考插件概述

sluaunreal 是腾讯的另一套 UE Lua 方案，偏向静态导出和性能优化，特点：
- 静态代码生成（CppBinding）+ 动态反射的混合绑定策略
- 性能分析工具集成
- 线上热更新工作流
- Profiler 支持

## 重点分析方向

1. **反射绑定** (D2)：静态 CppBinding 生成 + 动态反射的混合策略 vs Angelscript 纯手写绑定，分析性能与维护性的取舍
2. **性能** (D8)：sluaunreal 的静态导出如何减少调用开销、Profiler 集成方式、与 Angelscript StaticJIT 的理念对比
3. **热重载/热更新** (D4)：sluaunreal 的线上热更新工作流（网络下发 Lua 脚本）vs Angelscript 的开发期热重载，两种场景的差异
4. **Blueprint 交互** (D3)：sluaunreal 的 Blueprint 反射接入方式
5. **部署与打包** (D11)：Lua 脚本加密、签名、热更包分发，对比 Angelscript 的打包策略
6. **插件架构** (D1)：sluaunreal 的 Source/ 和 Tools/ 组织方式
$dimensionRef
$sharedInstructions
"@

    CrossComparison = @"
你正在执行 Reference 横向对比分析。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

横向对比 — 所有参考插件 + Angelscript 的逐维度横向对比
输出: Documents/AutoPlans/ReferenceComparison/CrossComparison.md

## 前置依赖

**先读取以下已有的纵向分析文档**（如果存在）：
- Documents/AutoPlans/ReferenceComparison/Hazelight_Analysis.md
- Documents/AutoPlans/ReferenceComparison/UnrealCSharp_Analysis.md
- Documents/AutoPlans/ReferenceComparison/UnLua_Analysis.md
- Documents/AutoPlans/ReferenceComparison/puerts_Analysis.md
- Documents/AutoPlans/ReferenceComparison/sluaunreal_Analysis.md

利用纵向分析的已有结论作为素材，但横向对比需要从**比较视角**重新组织，不是简单复制粘贴。

## 分析结构

对 D1-D11 的每个维度，产出以下内容：
1. **各插件实现概览**：ASCII 对比图或表格，一眼看出各方案差异
2. **详细对比**：按子维度逐项对比每个插件的做法、优劣
3. **对比矩阵**：功能点 × 插件的表格，标注支持程度（Full / Partial / None / N/A）
4. **小结与建议**：哪些做法值得 Angelscript 吸收，优先级建议

## 对比范围

- Hazelight (UEAS2)
- UnrealCSharp
- UnLua
- puerts
- sluaunreal
- **当前 Angelscript (Plugins/Angelscript/)**
$dimensionRef
$sharedInstructions
"@

    GapAnalysis = @"
你正在执行 Angelscript 插件差距分析与经验吸收建议汇总。严格遵循 Documents/Rules/ReferenceComparisonRule_ZH.md。

## 分析目标

差距分析 — 汇总所有对比结论，产出最终改进路线建议
输出: Documents/AutoPlans/ReferenceComparison/GapAnalysis.md

## 前置依赖

**必须先读取以下文档**（如果存在）：
- Documents/AutoPlans/ReferenceComparison/Hazelight_Analysis.md
- Documents/AutoPlans/ReferenceComparison/UnrealCSharp_Analysis.md
- Documents/AutoPlans/ReferenceComparison/UnLua_Analysis.md
- Documents/AutoPlans/ReferenceComparison/puerts_Analysis.md
- Documents/AutoPlans/ReferenceComparison/sluaunreal_Analysis.md
- Documents/AutoPlans/ReferenceComparison/CrossComparison.md

同时也读取以下项目现有的分析产出（如果存在）：
- Documents/AutoPlans/DiscoveryPlans/ 下的 *_Plan.md
- Documents/AutoPlans/ArchitectureReview/ 下的 *_ArchReview.md

## 文档结构

按照规则文档的差距分析文档结构产出：

1. **执行摘要**：3-5 条关键发现
2. **差距矩阵**：维度 × 差距等级（无差距 / 实现差异 / 能力缺失）的总览表
3. **按维度详细分析**：每个维度包含
   - 当前状态（引用 Plugins/Angelscript/ 源码）
   - 差距描述（与最佳参考方案的具体差异）
   - 参考方案（哪个参考插件的哪个实现值得借鉴，附源码路径）
   - 吸收建议（具体实施方向）
   - 优先级（P0/P1/P2/P3，附理由）
4. **值得吸收的设计模式**：跨维度的通用模式提炼
5. **改进路线建议**：按优先级排序的实施路线图

## 重要约束

- 差距判断必须区分"没有实现" vs "实现方式不同" vs "实现质量差异"
- 吸收建议必须考虑当前项目的实际约束（AngelScript 2.33.0 WIP、不修改引擎等）
- 优先级必须考虑与 todo.md 中当前主线（P10 UInterface、Bind API GAP 补齐）的协调
- 不能笼统说"建议参考"，必须指出参考谁的什么实现、在哪个文件
$sharedInstructions
"@
}

# ── 校验模块 ─────────────────────────────────────────────────────────────────
if (-not $modules.ContainsKey($Module)) {
    $valid = ($modules.Keys | Sort-Object) -join ', '
    throw "Unknown module: $Module. Valid modules: $valid"
}

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "refcmp_${Module}_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $modules[$Module], $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt        = "ReferenceComparison $Module"
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
