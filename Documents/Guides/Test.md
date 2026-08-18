# Test 指南

当前测试框架问题、覆盖缺口和官方 suite 口径见 `Documents/Guides/TestFrameworkReview_20260813.md`。并行/Fast 入口契约见同日的 `Documents/Guides/TestBuildPowerShellToolingReview_20260813.md`。

## 强制规则

- 本仓库的标准自动化测试入口是 `Tools\RunTests.ps1`。
- 具名 suite 只能通过 `Tools\RunTestSuite.ps1` 调度；不要手写一组 `RunTests` 命令散落到文档里。
- 不再允许把 `UnrealEditor-Cmd.exe` 直调命令、`Start-Process UnrealEditor-Cmd.exe` 拼参命令、或旧的 `Tools\RunAutomationTests.ps1` 当作标准入口写入指南。
- 所有测试命令都必须显式带超时，且超时不得超过 `900000ms`。
- 默认测试超时来自 `AgentConfig.ini` 的 `Test.DefaultTimeoutMs`；仓库标准默认值为 `600000ms`。
- 测试过程必须实时输出；超时或异常退出后脚本必须清理整棵编辑器/UBT 进程树。
- 每次测试都必须写入自己的独立输出目录；禁止多个 run 共用同一份 `Automation.log` 或报告目录。
- 会主动触发崩溃的测试只能使用 `Angelscript.CrashOnly.*` 前缀，并且必须单独运行；不要把它们放进 `Angelscript.TestModule.*`、group、suite、All、Fast、Parallel 或 monolithic 普通回归。

## AgentConfig.ini 与 bootstrap

执行测试前，先读取项目根目录的 `AgentConfig.ini`。

关键配置项：

```ini
[Paths]
EngineRoot=<UE 根目录>
ProjectFile=<当前 worktree 的 .uproject>

[Test]
DefaultTimeoutMs=600000
```

如果当前 worktree 还没有配置，先执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1
```

批量补齐所有 worktree：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -AllRegisteredWorktrees
```

只想拿标准命令模板时，使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1
```

## 标准入口

### 按测试前缀运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings -TimeoutMs 600000
```

反射回退绑定缓存专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.ReflectiveFallbackCache" -Label reflective-fallback -TimeoutMs 600000
```

GeneratedFunctionBinding 三分类统计专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionBinding" -Label generated-binding -TimeoutMs 600000
```

Compilation hook / event 专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-hooks -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label compiler-events -TimeoutMs 600000
```

这两个前缀覆盖 `PreprocessorContext`、`Preprocess.ProcessChunks` / `Preprocess.PostProcessCode` summary-backed hook 事件、`Compile.Begin` / `Compile.End`、module stage events、JIT availability metadata，以及 per-run `FAngelscriptCompilationContext` 隔离语义。

AngelScript native SDK 分层前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Tokenizer" -Label sdk-tokenizer -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Parser" -Label sdk-parser -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.ScriptNode" -Label sdk-scriptnode -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Bytecode" -Label sdk-bytecode -TimeoutMs 600000
```

### Native Core 九个主题

完成一个完整代码批次并通过 `Tools\RunBuild.ps1 -TimeoutMs 1800000 -NoXGE` 后，按主题运行原生 AngelScript 核心回归。不要把 `sdk/add_on`、UE world/Actor 测试或 `FAngelscriptEngine` 集成场景混入这些前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Engine" -Label sdk-engine -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend" -Label sdk-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label sdk-compiler -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Runtime" -Label sdk-runtime -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module" -Label sdk-module -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.TypeSystem" -Label sdk-typesystem -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language" -Label sdk-language -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Embedding" -Label sdk-embedding -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Conformance" -Label sdk-conformance -TimeoutMs 600000
```

完整原生核心回归与 suite 入口保持为：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label sdk-full -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix native-core -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix all -TimeoutMs 600000
```

Standalone 使用独立的 CMake/CTest suite。它会依次执行 configure、build 和 19 个当前 gate，覆盖 native runtime、Standalone 私有 frontend、Compat、offline contract、UE compile-only analysis、template adapters、resources、allocator lifetime、architecture/privacy、package、corpus、soak 与 benchmark：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix standalone -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -TimeoutMs 1200000
```

结果写入 `Saved/StandaloneTests/<Label>/<RunId>/`，不能把其 `19/19` 与 UE Automation、NativeCore 前缀、`275/275` catalogued C++ 基线或 `All` suite 数字相加/替换。`Standalone` 的 Debug typed entry 已在 soak 稳定后加入 `All`；`StandaloneRelease` 会额外构建最终 package target，因此保持独立、不加入 `All`。

插件测试主题前缀也按目录直接运行，常用入口包括：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional." -Label functional-runtime-coverage -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Editor." -Label editor-diagnostics-editor -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Networking." -Label editor-diagnostics-networking -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.GC." -Label editor-diagnostics-gc -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Memory." -Label editor-diagnostics-memory -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Validation." -Label editor-diagnostics-validation -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump." -Label editor-diagnostics-dump -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Performance." -Label editor-diagnostics-performance -TimeoutMs 900000
```

Crash-only 测试会启动独立子进程并主动触发 UE crash，用来验证崩溃路径能落盘恢复信息。它们不属于普通 dump 回归，必须显式单跑：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.CrashOnly.CrashSnapshot" -Label crash-snapshot -TimeoutMs 600000
```

`Tools\RunTests.ps1` 会拒绝 `-TestPrefix Angelscript` 这类会覆盖 `Angelscript.CrashOnly.*` 的普通宽入口；需要全量普通回归时使用 suite/parallel/fast 入口或明确的非 crash-only 前缀。

`Bindings` 目录这轮补的是显式 coverage gap closure：被恢复的主题包括 `Box3f` / `Sphere3f`、`Paths` / `PlatformMisc` / `CpuProfiler`、`FString` / `FileAndDelegate` / `MemoryReader` / `MeshComponent`。如果后续还保留边界 case，应该在 test case 里写明具体缺失的 binding 或环境限制，而不是继续用静默跳过。

`Functional` 目录这轮补的是运行时行为断言收口：`Objects` 覆盖值类型构造/拷贝、反射默认值与 UFUNCTION 调用、zero-size object 布局，并把脚本类对象执行和 mutable global class variable 保留为显式负向边界；`Operators` 覆盖 `**` 正向执行，并把脚本类 operator overload、const method、显式 getter/setter 执行故障保留为 `Null pointer access` 边界；`Handles` 覆盖 `int &out` 写回和 native `UObject` null/non-null 参数，并把脚本类 handle 声明、factory-style handle、脚本类按值传参保留为显式边界；`Inheritance` 覆盖继承、virtual-like dispatch、interface、cast-op、mixin 的当前分支边界。后续修复这些边界时，应在同一主题文件里把负向 case 改成正向运行时断言，并保留现有前缀。

对应的 UHT 生成统计会在每次标准 build/UHT 运行时写入：

```text
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionBindingStatistics.json
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionBindingModuleStatistics.csv
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionBindingDiagnostics.csv
```

该文件当前至少包含这些字段：

- `totalAnalyzedFunctions`
- `totalNativeRuntimeLinkedCount`
- `totalReflectiveFallbackCount`
- `nativeRuntimeLinkedRate`
- `reflectiveFallbackRate`
- `totalShardCount`
- `configuredModuleMissCount`
- `modules[]`（逐模块 `totalAnalyzedFunctions/nativeRuntimeLinkedCount/reflectiveFallbackCount/skippedFunctionCount/shardCount`）

CSV 侧的用途区分如下：

- `AS_FunctionBindingModuleStatistics.csv`：按模块聚合，适合快速看分析数、Runtime-linked、反射 fallback、跳过数和 shard 数
- `AS_FunctionBindingDiagnostics.csv`：逐条函数明细，适合按 `ModuleName/ClassName/FunctionName/FunctionBindingCategory/EraseMacro/ShardIndex` 过滤查询

### 按测试组运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptDebugger -Label debugger -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptPerformance -Label perf -TimeoutMs 900000
```

### 按具名 suite 运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Debugger -LabelPrefix debugger -TimeoutMs 600000
```

### 需要真实渲染时

默认测试会追加 `-NullRHI`。只有明确需要真实渲染时才加 `-Render`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke-render -TimeoutMs 600000 -Render
```

## 脚本默认行为

`Tools\RunTests.ps1` 会自动：

- 读取当前 worktree 的 `AgentConfig.ini`
- 在启动编辑器前预热 `Intermediate/TargetInfo.json`
- 防御性等待外部旧流程留下的 `Build.bat` 全局锁，避免把整个超时都耗在不可见争用上
- 以统一参数启动 `UnrealEditor-Cmd.exe`
- 默认追加 `-BUILDMACHINE`、`-stdout -FullStdOutLogOutput -UTF8Output`、`-Unattended -NoPause -NoSplash -NOSOUND`
- 非渲染模式下追加 `-NullRHI`
- 通过 `-ABSLOG` 与 `-ReportExportPath` 把日志和报告写入当前 run 的独立目录
- 在超时或异常退出时结束整棵编辑器/UBT 进程树

`Tools\RunTestSuite.ps1` 是基于 `Tools\RunTests.ps1` 的官方调度层。它会顺序执行内置 suite 中的前缀，并把 `-TimeoutMs`、`-OutputRoot`、`-NoReport` 透传给每个子 run。

`GeneratedFunctionBinding` 相关验证除了自动化报告外，还应结合 `AS_FunctionBindingStatistics.json` 一起看；前者回答“测试是否通过”，后者回答“本次 UHT 分析了多少函数，以及 NativeRuntimeLinked/ReflectiveFallback 的模块分布”。

当需要定位“某个函数为什么是 NativeRuntimeLinked 还是 ReflectiveFallback”时，优先查询 `AS_FunctionBindingDiagnostics.csv`，不要再从 `AS_FunctionBinding_*.gen.cpp` shard 文件中手工 grep。前者是正式产物，后者是代码生成中间结果。

## 常用参数

### `Tools\RunTests.ps1`

```powershell
Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 120000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests." -Label runtime-unit -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label dump -TimeoutMs 600000
Tools\RunTests.ps1 -Group AngelscriptFunctional -Label functional -TimeoutMs 900000 -Render
Tools\RunTests.ps1 -Group AngelscriptFast -Label fast -TimeoutMs 600000 -- -log
```

- `-TestPrefix`：按测试名前缀运行
- `-Group`：按 `Config/DefaultEngine.ini` 中定义的 automation group 运行
- `-TimeoutMs`：本次测试超时，必须大于 `0` 且不超过 `3600000`
- `-Label`：输出目录标签
- `-OutputRoot`：自定义输出父目录；脚本会在其下再创建 `Tests/<Label>/<RunId>/`
- `-Render`：关闭 `-NullRHI`
- `-NoReport`：跳过 `Summary.json` 生成
- `-- <ExtraArgs>`：透传额外编辑器命令行参数

### `Tools\RunTestSuite.ps1`

```powershell
Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
Tools\RunTestSuite.ps1 -Suite Debugger -LabelPrefix debugger -TimeoutMs 600000 -DryRun
Tools\RunTestSuite.ps1 -Suite FunctionalSamples -LabelPrefix functional -TimeoutMs 900000 -OutputRoot "D:\Tmp\SuiteRuns"
```

- `-Suite`：具名 suite 名称
- `-LabelPrefix`：每一波子 run 的标签前缀
- `-TimeoutMs`：透传给每个 `RunTests` 子 run 的超时
- `-OutputRoot`：透传给每个 `RunTests` 子 run 的输出父目录
- `-NoReport`：透传给每个 `RunTests` 子 run
- `-ContinueOnFail`：某个前缀失败后继续跑剩余前缀（默认遇错即停）
- `-ListSuites`：列出内置 suite 与对应前缀
- `-DryRun`：只打印将要执行的命令

### `Tools\RunTestSuiteFast.ps1`（UE Automation 快速粗分片 ~5–8 分钟）

**不要开 RHI。** 默认已是 `-NullRHI`（关闭渲染、只用 CPU），比真实 RHI 更快。`-Render` 仅用于必须 GPU 的测试。

UE Automation 的主要瓶颈是多次 UE Editor 冷启动。Fast 入口把五个顶层前缀粗分片并行，wall time 接近最慢分片：

```powershell
Tools\RunTestSuiteFast.ps1 -LabelPrefix all-fast -TimeoutMs 900000 -ContinueOnFail
```

等价于：

```powershell
Tools\RunTestSuiteParallel.ps1 -Strategy Coarse -Fast -MaxParallelHeavy 4 -ContinueOnFail -TimeoutMs 900000
```

五个分片：`Angelscript.TestModule` / `Angelscript.Editor` /
`Angelscript.GAS` / `Angelscript.GameplayTags` / `Angelscript.Template`。该快速
入口不包含独立 Standalone CMake/CTest；发布前完整 `All` 使用下一节的
`CoarseDynamic`。

`-Fast` 追加启动参数：`-NoLoadStartupPackages`、`-NoLiveCoding`、`-NoScreenMessages`、`-DisableAutomaticShaderCompilerLaunch`（均与 `-NullRHI` 叠加）。

**耗时预期（Development Editor，NullRHI，warm 机器）：**

| 模式 | 冷启动次数 | 典型 wall time |
|------|-----------|----------------|
| `RunTestSuite.ps1 -Suite All`（逐项串行） | 37 左右 | 30–60+ min |
| `RunTestSuiteParallel -Strategy Fine` | 37 左右 | 15–30 min |
| `RunTestSuiteFast` / `Strategy Coarse` | 5 | **~5–8 min** |
| `Strategy Monolithic`（单次普通前缀组合，不含 `Angelscript.CrashOnly.*`） | 1 | ~6–12 min |

Debugger / Performance / HotReload 可能拖慢 `TestModule` 分片；CI 门禁可单独跑 Fast，慢套件夜间跑。

单次快速验证也可：

```powershell
Tools\RunTestSuiteParallel.ps1 -Strategy Monolithic -Fast -LabelPrefix all-monolithic -TimeoutMs 900000
```

### `Tools\RunTestSuiteParallel.ps1`

全量/大 suite 的并行入口。默认 `CoarseDynamic` 使用历史 timing hint 把全部
TestModule 主题、Editor/GAS/GameplayTags/Template 和独立 Standalone CTest
均衡分配到四个固定 slot；同一 slot 内串行，不同 slot 并行。Light/Heavy 的
默认全局并发上限都是 4，可按机器内存下调 Heavy。

```powershell
Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4 -LabelPrefix all-parallel -TimeoutMs 3600000 -ContinueOnFail
Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic -TestModuleWorkers 4 -MaxParallelHeavy 2 -DryRun
```

- `-MaxParallelLight`：Light tier 最大并发 worker 数，默认 `4`
- `-MaxParallelHeavy`：Heavy tier 最大并发 worker 数，默认 `4`；内存较小的机器建议降为 `1` 或 `2`
- `-TestModuleWorkers`：`CoarseDynamic` 的固定 worker/slot 数，默认 `4`
- `-ContinueOnFail`：某个 shard 失败后继续调度剩余前缀
- 每个 worker 通过 `RunTests.ps1 -ExecutionSlot <N>` 使用独立 mutex，可在同一 worktree 上并行
- 每个并行 UE worker 自动附加 `-NoAssetRegistryCacheWrite`：可读取现有 UE AssetRegistry 缓存，但不争写共享的 `Intermediate/CachedAssetRegistry` 临时/引用文件
- 汇总写入 `Saved/Tests/<LabelPrefix>_<timestamp>/ParallelSuiteSummary.json`

串行全量仍可用 `RunTestSuite.ps1 -Suite All -ContinueOnFail`；耗时高时优先用 Parallel 版本。

### `RunTests.ps1` 并行 slot

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Syntax" -Label syntax-slot2 -ExecutionSlot 2 -TimeoutMs 600000
```

- `-ExecutionSlot`：并行 worker 编号（`0`=默认单进程模式）。同一 slot 仍互斥，不同 slot 可并行。

## 输出与产物

默认输出目录：

```text
Saved/Tests/<Label>/<RunId>/
  Automation.log
  Report/
  RunMetadata.json
  Summary.json
```

如果传入 `-OutputRoot D:\Tmp\TestRuns`，实际目录会变成：

```text
D:\Tmp\TestRuns\Tests\<Label>\<RunId>\
```

注意：

- `-OutputRoot` 只是父目录，不是最终目录
- 每次调用都会新建独立 `RunId`
- `Automation.log`、`Report/`、`RunMetadata.json`、`Summary.json` 都是 run 私有产物，不能手写成共享路径

## 常用 group 与 suite

常用 group 以 `Config/DefaultEngine.ini` 为准，典型入口包括：

- `AngelscriptSmoke`
- `AngelscriptNative`
- `AngelscriptRuntimeUnit`
- `AngelscriptDebugger`
- `AngelscriptFast`
- `AngelscriptFunctional`
- `AngelscriptEditor`
- `AngelscriptExamples`

常用 suite 以 `Tools\RunTestSuite.ps1 -ListSuites` 输出为准，当前重点包括：
推荐顺序：

1. 快速冒烟：`AngelscriptSmoke`
2. 无 world 的运行时回归：`AngelscriptRuntimeUnit`、`AngelscriptFast`
3. 需要 world / actor / subsystem 的集成回归：`AngelscriptFunctional`
4. 编辑器相关：`AngelscriptEditor`

### Commandlet 相关回归

本仓库的标准 commandlet 入口是 `Tools\RunCommandlet.ps1`。需要跑项目 commandlet 时，优先使用这个 runner，让 `AgentConfig.ini`、日志路径、超时和 worktree 单飞锁保持一致。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-scan -TimeoutMs 600000
```

额外 commandlet 参数通过 `-ExtraArgs` 传入：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-changed -TimeoutMs 600000 -ExtraArgs "-ChangedScript=Foo.as;Bar.as"
```

Standalone 离线声明/资产 Bundle 使用
`AngelscriptOfflineExport`。项目包默认导出完整最终符号表面和
`/Game` 资产作用域；Commandlet 不接受模块/插件符号过滤：

```powershell
$bundleArgs = @("-BundleKind=Project", "-Output=D:\Exports\MyProjectAS", "-AssetRoots=/Game,/MyPlugin")
& Tools\RunCommandlet.ps1 -Commandlet AngelscriptOfflineExport -Label offline-bundle-project -TimeoutMs 600000 -ExtraArgs $bundleArgs
```

为另一个消费项目导出时显式传入它的 `.uproject`；不传时仍使用 `AgentConfig.ini` 的默认项目：

```powershell
& Tools\RunCommandlet.ps1 -Commandlet AngelscriptOfflineExport -ProjectFile D:\Projects\MyGame\MyGame.uproject -Label offline-bundle-external -TimeoutMs 600000 -ExtraArgs $bundleArgs
```

若调用方必须使用 Windows PowerShell `powershell.exe -File` 且需要传多个以 `-` 开头的 Commandlet 参数，应把 JSON 字符串数组写入文件并使用 `-ExtraArgsFile <json>`，避免子 PowerShell 把后续参数解析成 runner 参数。发布态端到端验证使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStandaloneExternalSmoke.ps1 -TimeoutMs 1200000
```

该 smoke 生成无 C++ host module 的临时外部项目，验证默认/显式 Project Bundle 逐字节一致，并从最终 Release ZIP 解压 CLI 消费显式 Bundle。结果位于 `Saved/StandaloneExternalSmoke/<RunId>/Summary.json`。

未指定输出时写入已忽略的
`Saved/AngelscriptStandalone/project/` 或
`Saved/AngelscriptStandalone/default-engine/`。完整符号作用域是硬要求；
资产作用域不完整时必须显式传入 `-AllowIncompleteAssets`。Bundle
布局、隐私边界、版本与完整性规则见
`Documents/Guides/AngelscriptStandaloneOfflineBundle.md`。

`DefaultEngine` 仅表示 Standalone 省略 `--bundle` 时使用的发行默认值，
不会过滤项目或可选插件符号。官方包使用 UE 5.8
`AngelscriptProject` 的完整导出；其他项目应生成 `Project` Bundle 并显式传给
Standalone。

### Blueprint impact commandlet 相关回归

新增 Blueprint impact 相关功能后，优先使用以下入口：

- Editor 内部 scanner / commandlet 入口回归：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.BlueprintImpact" -TimeoutMs 300000
```

- Blueprint 场景与磁盘资产回归：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.BlueprintImpact" -TimeoutMs 300000
```

- commandlet 手工验证：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-scan -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-changed -TimeoutMs 600000 -ExtraArgs "-ChangedScript=Foo.as;Bar.as"
```

`Tools\RunCommandlet.ps1` 会从当前 worktree 的 `AgentConfig.ini` 读取 `<ProjectFile>`，不要在常规执行说明里写死其他 worktree 的 `.uproject` 路径。

### Cache V2 相关回归

增量 Cache 的快速功能回归使用独立前缀；测试通过测试专用虚拟 `.as` 输入、隔离
Store root 和多个完整 `FAngelscriptEngine` 实例覆盖生成、恢复、失效、发布、诊断和
损坏拒绝，不修改项目业务脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label cache-v2 -TimeoutMs 3600000
```

Python dump 是独立的只读工具，使用自己的 wrapper 测试，无需再复制一套 C++
decoder 测试：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCacheV2DumpTests.ps1
```

真实打包、多次进程启动和 benchmark 不属于普通 `All` 自动化进程，使用专用入口：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -TimeoutMs 3600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping -TimeoutMs 3600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptCacheBenchmark.ps1 -ArchiveRoot <Development-Archive> -Configuration Development -WarmupRuns 1 -MeasuredRuns 3 -TimeoutMs 3600000
```

package smoke 在 disposable archive 内生成专用 fixture 和 Cache root，覆盖 cold、
unchanged warm、函数体修改、非法源码、源码恢复以及结构 cold/warm；benchmark 另外
覆盖类型、模块状态、诊断档位和 4/16/64 MiB 串并行 writer 策略。完整运维、dump、
调试和失效语义见 `Documents/Guides/AngelscriptCacheV2_ZH.md`。

### StaticJIT AOT 相关回归

StaticJIT AOT 测试验证“编译权威 AS → 每 AS 模块生成一个 `.jit.cpp` → 二次构建 → Provider 注册 → 当前 Engine 稳定路由 → Native/VM 执行”整条链路。当前 owned output 不再发布 `.jit.hpp` 或测试专用 `.Cache`，也不再用 FunctionId/DataGuid 把 whole-cache 与 DLL 成对绑定；translator 内部若使用 `.jit.hpp` 命名的临时文本，不构成 UBT source 或运行期协议。

`typed-ast` AOT 只补充 BytecodeJIT/VM，不是 Runtime JIT。生成前必须打开 HIR capture，只消费同一次编译的内存 HIR。测试应把意外 Typed 回退当成失败，而不是引入生产 `dual` backend。普通调用实参按反向形式参数顺序；变异目标只求值一次；循环/switch 保留显式阶段和转移目标。位置帧不是 debugger/coverage/timeout 对等能力。直接递归需要 native frame 预算。`bExceptionThrown` 不是完整异常 payload。cleanup plan 必须显式、反向、只覆盖当时存活的槽。当前源级 `try`/`catch` 仍被拒绝。可变全局和 import 槽需要生命周期路由。native-form 显示名不能证明跨 DLL 可链接。

日常执行使用专用入口；它会完成基线 Editor 构建、固定 `AngelscriptTestJIT` fixture 生成、二次构建、Verify 和 focused tests：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -LabelPrefix staticjit-aot
```

只运行 AOT 子集时追加 `-AotOnly`。默认运行完整 `Angelscript.TestModule.StaticJIT` 前缀，同时覆盖 Provider ABI/Registry、稳定引用、多 Provider、Editor 路由、UASFunction、诊断和 AOT 执行。

测试 Provider 是插件内固定的 Editor-only `AngelscriptTestJIT` UE 模块，不依赖项目名、项目 scaffold 或项目 `Source/AngelscriptJIT`。如需单独排查，使用 `AngelscriptTestJIT` commandlet 的 `Generate|Verify` 模式；正常情况下优先使用上述 runner，避免跳过必要的二次构建。

项目自己的 Provider workflow 独立使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label project-jit-generated -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Verify -Profile EditorDevelopment
```

生成器通过 `OwnedFiles.generated.json`、版本化 owner marker 和内容比较保证只改 owned files；同一 AS 模块的全局函数和类方法都进入唯一 `<AS相对目录>/<源文件名>.<短StableModuleKey>.<Profile>.jit.cpp`。模块头和函数入口注释可直接反查 canonical AS 声明与虚拟源位置，完整稳定键和内部 symbol 不缩短。重复 Generate 必须保持未变化文件的字节与时间戳。新增/删除 AS 模块或从旧 `Private/Generated/<Profile>`、`Private/Generated/Profiles/<Profile>` 迁移都会改变 UBT source set，必须普通完整构建；Verify 对旧目录只读报错。当前项目载体固定在 `Source/AngelscriptJIT/Generated/<Profile>`，TestJIT 固定在 `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/EditorDevelopment`，两者都不保留 `Private`/`Public` 包装目录。

StaticJIT 与 Cache V2 是独立层：测试先通过源码编译或隔离 Cache V2 root 建立当前 Engine 权威状态，再验证同一个 Provider 能否按稳定键在 source-engine、fresh cache-engine 和多 Engine 中得到相同路由。Provider 不保存 Cache 的瞬时 FunctionId，单个函数内容或引用不匹配只让该 route 回退 VM。

运行期诊断与离线 Schema inspector：

```powershell
python Tools\Diagnostics\InspectStaticJITDump.py <dump.json>
python Tools\Diagnostics\InspectStaticJITDump.py <dump.json> --fail-on-mismatch
```

真实 Editor Live Coding smoke 需要在不关闭 Editor 的同一会话中观察 changed function 在 patch 前为 VM、严格更新 ProviderGeneration 的 patch 后为 Native；普通保存不会自动触发 C++ 生成/Live Coding。Development/Shipping package multi-start smoke 是独立发布门，不计入普通 `All` 单进程自动化数量。

package smoke 要求对应 Profile 已经 Generate 并编译进 Game target；它会检查 manifest、
Game link response、archive 模块表面，并启动两个独立进程证明选择不受 FunctionId、指针、
publication ordinal 或 Cache root 创建顺序影响：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile GameDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJITPackageSmoke.ps1 -Configuration Development -TimeoutMs 3600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile GameShipping
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJITPackageSmoke.ps1 -Configuration Shipping -TimeoutMs 3600000
```

成功证据写入 `Saved/StaticJITPackage/<Label>-<Configuration>/<RunId>/Summary.json`。
`-SkipPackage -OutputRoot <exact-prior-run-root>` 只用于重放已有 archive 的两次启动检查，
不能替代最终发布构建。当前生产 direct script-call emission 显式关闭；package smoke
验证的是完整 Native binding route，不得把它描述成已启用跨 `.jit.cpp` 的直接调用。

常用具名 suite 以 `Tools\RunTestSuite.ps1 -ListSuites` 的输出为准，当前重点包括：

- `Smoke`
- `NativeCore`
- `RuntimeCpp`
- `Debugger`
- `Bindings`
- `HotReload`
- `FunctionalSamples`
- `All`

## AngelScript 反射测试类

AngelScript 脚本测试使用一个原生基类 `UAngelscriptTestSuite`，写法借鉴
CQTest 的 class/fixture、生命周期和命令队列，但不在脚本中使用
`TEST_` 命名约定，也不使用 `UFUNCTION(Test)`。每个测试方法都是一个普通
`void()` 方法，通过 `meta=(AngelscriptTest)` 标记：

职责分为两层：suite 实例保存 fixture 状态、生命周期、`Fail`、`Assert*` 和
`ExpectError*`；无字段的 `FAngelscriptTest` USTRUCT 以同名 AS namespace
提供 World/Spawn/Tick 工具，`FAngelscriptTest::Commands()` 返回同样无字段的
值类型 Builder。两个 facade 都不会保存 suite、World 或上下文指针，每次调用
都从当前脚本 callback 的严格作用域栈解析正在执行的 leaf。

硬迁移映射：

| 旧 Suite 调用 | 新调用 |
|---|---|
| `CreateTestWorld` / `DestroyTestWorld` / `GetTestWorld` | `FAngelscriptTest::CreateTestWorld` / `DestroyTestWorld` / `GetTestWorld` |
| `SpawnObject` / `SpawnActor` / `SpawnComponent` | `FAngelscriptTest::SpawnObject` / `SpawnActor` / `SpawnComponent` |
| `BeginPlay*` / `Tick*` / `AdvanceTime` / `DestroyActor` | 对应的 `FAngelscriptTest::...` 全局函数 |
| `Do` / `Then` / `Until` / `WaitDelay` / cleanup aliases | `FAngelscriptTest::Commands().<Command>(...)` |
| `AddLatentCommand(Command, Timeout)` | `FAngelscriptTest::Commands().AddLatentCommand(Command, Timeout)` |

`Assert*`、`Fail`、`ExpectError*` 和生命周期 override 不迁移，仍直接写在 suite
实例上。旧环境/命令别名已硬删除，没有 deprecated 兼容层。

```angelscript
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UInventoryScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void AddingAnItemUpdatesTheCount()
	{
		AssertEquals(2, 1 + 1);
	}

	// 未标记的方法只是本 fixture 的 helper，不会注册为测试。
	void BuildInventory()
	{
	}
}
```

公开 Automation 路径为：

```text
Angelscript.ScriptTests.<Module>.<Suite>.<Method>
```

对普通 `Script/` 源码，`<Module>` 来自相对脚本路径：去掉 `.as`，再把目录
分隔符替换成 `.`；`<Suite>` 与 `<Method>` 则使用反射类名和标记方法名。
例如文件
`Script/Tests/Test_ReflectedScriptSuites.as` 中的 fixture 测试完整路径是：

```text
Angelscript.ScriptTests.Tests.Test_ReflectedScriptSuites.UReflectedFixtureScriptTests.FirstLeafGetsFreshFixtureState
```

因此既可以运行整个 root，也可以把 `-TestPrefix` 精确到 module、suite 或
单个 method。自定义 source provider 下若不确定 module 名，以 Editor 的
Automation 列表或 `Saved/Tests/<Label>/.../Report/index.json` 里的
`fullTestPath` 为准。

宿主仓库运行全部脚本测试：

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.ScriptTests" `
  -Label script-tests `
  -TimeoutMs 600000
```

完整可运行示例见
`Script/Tests/Test_ReflectedScriptSuites.as`。它同时覆盖纯逻辑、
fixture 生命周期与状态隔离、预期错误、无 World 的 `SpawnObject`、
GameInstance 模式、World/Spawn/Tick、fluent 延迟命令、高级
`ULatentAutomationCommand`、Runtime 多上下文 flags 和 Editor-only 编译。

### fixture 与生命周期隔离

这里的 **fixture** 不是一张地图或一个额外 UObject 类型，而是“测试类及其为
一条测试保存的成员状态、setup/teardown 和 helper”。框架只需要一个
`UAngelscriptTestSuite` fixture 基类和无状态的 `FAngelscriptTest` 工具 facade，
不需要
`UAngelscriptTestWorld`、`UAngelscriptTestMap` 或
`UAngelscriptTestNetwork`。

可重载的生命周期方法是：

```angelscript
UFUNCTION(BlueprintOverride)
void BeforeAll() {}

UFUNCTION(BlueprintOverride)
void BeforeEach() {}

UFUNCTION(BlueprintOverride)
void AfterEach() {}

UFUNCTION(BlueprintOverride)
void AfterAll() {}
```

生命周期契约如下：

- 每条测试拥有一个全新的瞬态 suite 实例。`BeforeEach`、标记方法、延迟
  callback 和 `AfterEach` 使用同一个实例，因此成员状态可以在这一条 leaf
  内传递，但不会泄漏到下一条测试。
- `BeforeAll` / `AfterAll` 使用另一个独立的 suite-scope 实例，按 Automation
  worker、suite 和脚本注册表 generation 各执行一次；普通成员状态不会从
  `BeforeAll` 复制到 method fixture。
- All hooks 必须保持同步，不能调用 leaf-bound 断言、期望日志、World 或命令
  队列 API。测试状态的初始化通常放在 `BeforeEach`。
- 无论测试成功、断言失败、普通异常、超时、显式取消还是热更新失效，
  `AfterEach`、LIFO cleanup 和 World 清理都会被尝试执行。
- `BeforeAll` 抛出普通异常时，本 generation 的 leaf 不会继续执行，但仍会尝试
  `AfterAll`；`BeforeAll` / `AfterAll` 异常都会保留脚本文件、行号和原始异常
  文本。`AfterAll` 是 suite/session 失败，不会回写已经提交给 UE 的旧 leaf。

下面是状态隔离的核心写法；完整可运行版本还用 `OnCleanup` 验证 cleanup 确实
位于 `AfterEach` 之后：

```angelscript
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UFixtureIsolationTests : UAngelscriptTestSuite
{
	int SetupCount = 0;
	int Value = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		SetupCount += 1;
		Value = 10;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FirstLeafCanMutateItsFixture()
	{
		AssertEquals(1, SetupCount);
		Value = 20;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void SecondLeafStartsFresh()
	{
		AssertEquals(1, SetupCount);
		AssertEquals(10, Value);
	}
}
```

### 精确 Automation flags

`AngelscriptTestFlags` 是以分号分隔的
`EAutomationTestFlags` **精确掩码**，不是标签或模糊默认值。解析器会：

- 去掉 token 两侧空白；
- 拒绝空、重复或未知 token；
- 要求至少一个运行上下文；
- 要求且只允许一个 filter；
- 保留 UE 原生 feature、priority 和 `Disabled` 语义。

常用声明：

```angelscript
// 只允许编辑器 Automation 执行。
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UEditorAutomationTests : UAngelscriptTestSuite
{
}

// 同一 suite 可被 editor/client/server/commandlet 上下文选择。
UCLASS(meta=(AngelscriptTestFlags=
	"EditorContext;ClientContext;ServerContext;CommandletContext;EngineFilter"))
class URuntimeCapableTests : UAngelscriptTestSuite
{
}
```

支持的 context 包括 `EditorContext`、`ClientContext`、`ServerContext`、
`CommandletContext`、`ProgramContext`；常用 filter 包括 `SmokeFilter`、
`EngineFilter`、`ProductFilter`、`PerfFilter`、`StressFilter` 和
`NegativeFilter`。`NonNullRHI`、`RequiresUser`、`Disabled`、
`SupportsAutoRTFM` 以及 UE priority flags 也保留原义。

`#if EDITOR` 与 `EditorContext` 解决的是两件不同的事：

- `#if EDITOR` 决定代码在非编辑器 target 中是否参与 **编译**。引用
  Editor-only 类、属性或函数的声明必须放在这个编译块中。
- `EditorContext` 决定已经成功编译的测试是否可在 Editor Automation
  上下文中 **执行**。

因此只写 `EditorContext` 不能使 Editor-only API 在 Runtime target 中合法；
只写 `#if EDITOR` 也不会自动赋予 Automation 执行 flags。
脚本类的 `StaticClass()` 就是一个容易踩到的例子：当前绑定把它视作
Editor-only 函数，所以使用
`FAngelscriptTest::SpawnObject(UMyScriptObject::StaticClass())` 的声明也要放进
`#if EDITOR`；`EditorContext` 本身不会绕过编译检查。

### 断言和预期日志

suite 原生支持：

- `Fail`
- `AssertTrue` / `AssertFalse`
- `AssertNull` / `AssertNotNull`
- `AssertSame` / `AssertNotSame`
- `AssertEquals` / `AssertNotEquals`
- `AssertNear`
- `AssertLessThan` / `AssertLessThanOrEqual`
- `AssertGreaterThan` / `AssertGreaterThanOrEqual`
- `ExpectError` / `ExpectErrorRegex`，可指定匹配次数

断言覆盖常用整数、`float32`、`float64`、字符串、名称、UObject 和 UE 数学
类型；`FTransform` 也支持 equality/near。失败会记录脚本文件与调用行并用受控
异常结束当前 callback，不会把同一个断言重复报告为普通 AS 异常。期望日志
规则不能“吃掉”断言失败。`ExpectError` / `ExpectErrorRegex` 不依赖当前是否
正运行一个外层 UE Automation leaf；Automation bridge、Commandlet 和热更新
自动调度都会对各自的独立结果做相同的日志捕获、次数核对和终态结算。
普通 AS 异常同样适用于 fluent callback 与高级
`ULatentAutomationCommand` 的 `Before` / `Update` / `After`：异常会进入
当前 leaf 结果并停止后续主命令，不会因为 callback 同时受热更新保护而被静默
忽略。即使 leaf 已经记录了主失败，后续 `AfterEach` 或
`OnTearDown` / `OnCleanup` callback 抛出的普通异常仍会作为独立、带脚本
位置的错误保留；只有框架内部用于终止当前 callback 的受控断言异常会去重。

`ExpectError` 使用 contains 匹配，`ExpectErrorRegex` 使用正则匹配；最后一个
参数是期望次数，实际次数少或多都会让 leaf 失败：

```angelscript
UFUNCTION(meta=(AngelscriptTest))
void MatchesExpectedErrors()
{
	ExpectError("intentional warning", 1);
	ExpectErrorRegex("item-[0-9]+ unavailable", 2);
	Error("prefix intentional warning suffix");
	Error("item-12 unavailable");
	Error("item-34 unavailable");
}
```

### 显式本地 World、Spawn 和 Tick

纯逻辑测试不会隐式创建 World。需要时由当前 leaf 显式创建：

```angelscript
UFUNCTION(meta=(AngelscriptTest))
void ActorTicksExactlyThreeTimes()
{
	FAngelscriptTest::CreateTestWorld(false);
	AMyProbeActor Actor = Cast<AMyProbeActor>(
		FAngelscriptTest::SpawnActor(
			AMyProbeActor::StaticClass()));

	FAngelscriptTest::BeginPlay(Actor);
	FAngelscriptTest::TickActor(Actor, 0.01, 3);
	AssertEquals(3, Actor.TickCount);

	FAngelscriptTest::DestroyActor(Actor, true);
	FAngelscriptTest::DestroyTestWorld();
}
```

普通 UObject 不需要先创建 World；默认 Outer 是当前 leaf fixture，并且对象仍由
终态清理跟踪：

```angelscript
#if EDITOR
UReflectedPlainTestObject Object = Cast<UReflectedPlainTestObject>(
	FAngelscriptTest::SpawnObject(
		UReflectedPlainTestObject::StaticClass()));
AssertSame(this, Object.GetOuter());
AssertNull(FAngelscriptTest::GetTestWorld());
#endif
```

需要 GameInstance 与 subsystem 初始化上下文时才选择较重的模式：

```angelscript
FAngelscriptTest::CreateTestWorld(true);
AssertNotNull(FAngelscriptTest::GetTestWorld());
AssertNotNull(FAngelscriptTest::GetTestWorld().GetGameInstance());
FAngelscriptTest::DestroyTestWorld();
```

`FAngelscriptTest::` namespace 中的工具包括：

- `CreateTestWorld(bool bInitializeGameSubsystems = true)`、
  `GetTestWorld()`、`DestroyTestWorld()`；
- `SpawnObject`、`SpawnActor`、`SpawnComponent`；
- `BeginPlay`、`BeginPlayAll`；
- `TickWorld`、`TickActor`、`TickComponent`、`AdvanceTime`；
- `DestroyActor`。

这些名字不再作为 `UAngelscriptTestSuite` 成员暴露；旧的无限定调用会编译失败，
应显式写成 `FAngelscriptTest::...`。suite 的 `GetWorld()` override 仍保留，因为
它是 UObject/UE WorldContext 语义；测试工具入口使用
`FAngelscriptTest::GetTestWorld()`，两者在活动本地 World 上返回同一对象。

`CreateTestWorld(true)` 还建立 GameInstance/subsystem 上下文；
`CreateTestWorld(false)` 更轻。第二次创建会直接失败，不会悄悄替换已有 World。
`TickWorld` / `AdvanceTime` 驱动 World scheduler；需要严格
`TickCount == NumTicks` 时使用直接派发的 `TickActor` /
`TickComponent`。所有创建对象都由 leaf 跟踪，并在终态反向清理。

这套工具只创建本地测试 World，不自动加载 Map、不启动 PIE，也不建立
server/client 网络参与者。需要真实 Map、PIE 或网络 session 的测试继续使用
C++ Automation fixture 或显式高级基础设施。

### 延迟操作：队列，不是 await

常见延迟流程不需要为每一步写一个 `ULatentAutomationCommand` 子类：

```angelscript
UFUNCTION(meta=(AngelscriptTest))
void LoadsInSteps()
{
	FAngelscriptTest::Commands()
		.OnCleanup(n"RestoreState")
		.Do(n"StartLoad")
		.WaitDelay(0.05, "let async work start")
		.Until(n"IsLoaded", 5.0, "asset loaded")
		.Then(n"VerifyLoaded");

	// 这一行现在就执行，不会等待上面的命令。
}

void StartLoad() {}
bool IsLoaded() { return true; }
void VerifyLoaded() { AssertTrue(IsLoaded()); }
void RestoreState() {}
```

别名与顺序：

- `Do` / `Then`：普通 `void()` helper，主队列 FIFO；
- `StartWhen` / `Until`：普通 `bool()` helper，每次 Automation update
  轮询；
- `WaitDelay`：按单调真实时间等待，不推进测试 World；
- `OnTearDown` / `OnCleanup`：teardown 队列 LIFO，即使主队列失败仍执行。

Builder 是可复制但不携带状态的值；即使先保存到局部变量，每次方法调用仍会
重新解析当前 callback 的 leaf。测试方法和 `BeforeEach` 的职责是**一次性构造
队列**。enqueue 后面的语句会
立刻继续；依赖等待结果的逻辑必须放进后续 `Then` callback。队列运行期间不
允许再修改主队列。轮询默认超时 5 秒，安全上限 15 秒；确定性游戏时间应使用
`FAngelscriptTest::AdvanceTime`，不要用 `WaitDelay` 假装 World 在 tick。

更复杂的兼容场景仍可继承 `ULatentAutomationCommand`，重载
`Before` / `Update` / `After` / `Describe`，用
`FAngelscriptTest::Commands().AddLatentCommand(Command, TimeoutSeconds)`
排队。服务器侧命令阶段也会建立当前 leaf callback 作用域；命令执行期间可通过
`GetCurrentSuite()` 取回所属 fixture。`bAlsoRunOnClient` 只复用已存在且具备
网络能力的 World，不会自动启动 PIE 或创建客户端。这里的 timeout 覆盖从
client executor 创建到 `AfterOnClient` 收尾的完整生命周期；即使命令允许
timeout，也会立即执行 server `After`、销毁 executor、解除 suite 关联并结束
leaf，而不会卡在 `FinishClient`。executor 在中途失效时会报告所在阶段并走
同一终态清理，不会解引用空指针。

### 热更新语义

注册表只在 class generation 成功后原子发布新 generation。失败的脚本编译
保留 last-good 测试列表；成功重载可以增删 marker、重命名方法或把 suite
移动到新的精确 flags bridge。

若 affected module 正有 latent leaf：

1. 等当前脚本 callback 返回并弹出当前 leaf 作用域，绝不在活动 AS 栈中重入编译；
2. 用旧 generation 执行 `AfterEach` 和 LIFO teardown；
3. 释放高级命令并清理对象/GameInstance/World；
4. 编译、发布新 generation；
5. 自动热更新调度只保存稳定 ID，取消并替换更旧 generation 的待执行工作。

编辑器仅在 AutomationController 已经加载时刷新列表；测试运行中多次重载会
合并为一次 idle refresh。缓存的旧 leaf 命令不会调用旧函数指针，而会提示
刷新并重新运行。若重载发生在一个仍打开的 Automation suite section 中，
框架会在编译前关闭旧 generation 的 All-hook session，并在下一条 leaf 开始
时按新 generation 懒创建 session；自动调度的失败结果只上报一次，后续 idle
tick 不会重复制造同一诊断。若拥有活动 leaf 或 All-hook session 的
`FAngelscriptEngine` 被关闭，框架会在该 Engine 释放脚本函数之前，仅取消其
自己的 leaf、执行旧 Engine cleanup 并关闭 session，不把悬空回调留到
`ShutDownAndRelease()` 之后。

### commandlet、旧协议迁移与明确非目标

Runtime commandlet 和热更新自动测试都使用同一份 reflected registry 和同一
同步/latent runner。宿主仓库可直接运行：

```powershell
Tools\RunCommandlet.ps1 `
  -Commandlet AngelscriptTest `
  -Label script-tests-commandlet `
  -TimeoutMs 600000
```

`AngelscriptTest` commandlet 只选择精确 flags 含
`CommandletContext` 且未 `Disabled` 的 leaf，结束时固定输出
`selected` / `executed` / `passed` / `failed` 四项统计。没有任何 eligible
leaf、没有执行完所有已选择 leaf、leaf 失败或 suite lifecycle 失败都会返回
失败；诊断保留脚本源文件、行号和原始错误。若 `AfterAll` 是唯一失败，摘要会
把一个原本通过的已执行 leaf 归入 `failed`，因此始终满足
`passed + failed == executed`。

旧的全局协议已移除：

```angelscript
// 旧：不再发现
void Test_Add(FUnitTest& T) {}
void IntegrationTest_Map(FIntegrationTest& T) {}

// 新：迁移到 suite class
UCLASS(meta=(AngelscriptTestFlags="CommandletContext;EngineFilter"))
class UCommandletScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void Add() { AssertEquals(2, 1 + 1); }
}
```

旧 `Angelscript.UnitTests` / `Angelscript.IntegrationTests` Automation root、
`FUnitTest`、`FIntegrationTest`、全局 `GetParam`、隐式 Map/PIE 启动和旧的
可变 current-test API 不再是可用入口。

当前版本有意不提供：

- 参数化 data provider；
- 自动 Map/PIE/network session；
- lambda 或 function-handle callback；
- 可恢复 VM `await`。

有重复输入矩阵时先拆成具名测试方法或普通 helper；确实需要以上能力时使用
C++ Automation/CQTest fixture，而不是在 AS suite 中引入隐式全局状态。

## C++ CQTest 框架使用指南

### 概述

CQTest 是 UE 5.x 引入的声明式自动化测试框架（`Engine/Source/Developer/CQTest/`），相比传统 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 提供更简洁的语法和更好的 setup/teardown 结构化支持。本项目已在 `AngelscriptTest.Build.cs` 中加入 `CQTest` 依赖（editor builds），当前作为 PoC 在绑定测试中使用。

引入头文件：

```cpp
#include "CQTest.h"
```

### 核心宏

| 宏 | 作用 | 映射 |
|---|---|---|
| `TEST_CLASS(Name, Path)` | 声明测试类，Path 为 Automation ID 前缀 | 生成 `FAutomationTestBase` 子类 |
| `TEST_CLASS_WITH_FLAGS(Name, Path, Flags)` | 同上，但可指定 `EAutomationTestFlags` | 同上 |
| `TEST_METHOD(Name)` | 在类内声明一个测试方法 | 每个方法注册为独立 Automation Test |
| `BEFORE_ALL()` | **静态方法**，整个测试类执行前调用一次 | `static void BeforeAll(const FString&)` |
| `AFTER_ALL()` | **静态方法**，整个测试类执行后调用一次 | `static void AfterAll(const FString&)` |
| `BEFORE_EACH()` | 每个 `TEST_METHOD` 执行前调用 | `virtual void Setup() override` |
| `AFTER_EACH()` | 每个 `TEST_METHOD` 执行后调用 | `virtual void TearDown() override` |
| `ASSERT_THAT(expr)` | 断言失败时 `return`，不继续执行 | `if (!this->Assert.expr) { return; }` |

### 与 Angelscript 引擎集成的推荐模式

由于 `ASTEST_BEGIN/END_SHARE_CLEAN` 等宏展开为大括号对（包含 `FAngelscriptEngineScope` RAII），无法跨 CQTest 的 `Setup()/TearDown()/TEST_METHOD()` 边界拆分。推荐的适配模式如下：

```cpp
TEST_CLASS_WITH_FLAGS(FMyBindingsTest,
    "Angelscript.TestModule.Bindings.MyType",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
    BEFORE_ALL()
    {
        // 整个类开始时一次性获取干净的共享引擎
        ASTEST_CREATE_ENGINE_SHARE_CLEAN();
    }

    AFTER_ALL()
    {
        // 整个类结束后一次性重置引擎
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
        AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
    }

    TEST_METHOD(SomeSection)
    {
        // 获取共享引擎（无 reset，因为 BEFORE_ALL 已经清理过）
        FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
        FAngelscriptEngineScope Scope(Engine);

        // FCoverageModuleScope 自动在析构时 DiscardModule
        FCoverageModuleScope Mod(*TestRunner, Engine, Profile, TEXT("Section"), TEXT(R"(
            // AS code here
        )"));
        if (!Mod.IsValid()) return;
        auto& M = Mod.GetModule();

        // 断言
        ExpectGlobalInts(*TestRunner, Engine, M, Profile, Cases);
    }
};
```

关键设计决策：

- **`BEFORE_ALL` / `AFTER_ALL`（推荐）**：引擎获取和重置只执行各一次。由于它们是 `static` 方法，不能直接设置实例成员变量，但可以操作进程级共享引擎单例。
- **`BEFORE_EACH` / `AFTER_EACH`（避免）**：每个 `TEST_METHOD` 前后都执行，会导致不必要的引擎重置。`FCoverageModuleScope` 的 RAII 析构已经负责每个测试的模块清理，无需额外的整引擎重置。
- **`FCoverageModuleScope`**：每个 `TEST_METHOD` 内通过 RAII 创建和销毁 AS 模块，测试结束时自动 `DiscardModule`，保证测试间的模块隔离。
- **`TestRunner` 指针**：CQTest 将 `TestRunner` 暴露为 `static` 指针（类型为 `TTestRunner<FNoDiscardAsserter>*`），传给需要 `FAutomationTestBase&` 的函数时需要解引用为 `*TestRunner`。

### setup 层级选择

| 层级 | 用途 | 示例 |
|---|---|---|
| `BEFORE_ALL` / `AFTER_ALL` | 引擎获取/重置、重量级资源创建 | `ASTEST_CREATE_ENGINE_SHARE_CLEAN()` |
| `BEFORE_EACH` / `AFTER_EACH` | 每个测试必须隔离的状态（如 `AddExpectedError`） | 仅在特殊需要时使用 |
| `TEST_METHOD` 内 RAII | 模块创建/销毁、局部作用域 | `FCoverageModuleScope`、`FAngelscriptEngineScope` |

### 跨边界 FString 测试模式

绑定测试中常见三种 C++ ↔ AS 数据传递路径：

**1. AS 内部比较，返回 int**（最常用）：

```cpp
// AS 代码
int MyTest() {
    FString S = "Hello".ToUpper();
    return (S == "HELLO") ? 1 : 0;
}

// C++ 断言
ExpectGlobalInts(*TestRunner, Engine, M, Profile, Cases);
```

**2. AS 返回 FString，C++ 验证内容**：

```cpp
// AS 代码
FString MyReturnTest() {
    return "Hello".ToUpper();
}

// C++ 断言
ExpectGlobalReturnCustom<FString>(*TestRunner, Engine, M, Profile,
    TEXT("FString MyReturnTest()"),
    TEXT("ToUpper returns HELLO"),
    [](FAutomationTestBase& T, const FString& V) -> bool {
        return T.TestEqual(TEXT("upper"), V, TEXT("HELLO"));
    });
```

**3. C++ 传入 FString 参数，AS 处理**：

```cpp
// AS 代码
FString Pass_Upper(const FString& in S) {
    return S.ToUpper();
}

// C++ 调用
FString Input = TEXT("hello");
FASGlobalFunctionInvoker Inv(*TestRunner, Engine, M,
    TEXT("FString Pass_Upper(const FString& in)"));
Inv.AddArgRef(Input);
if (Inv.Call()) {
    FString Result;
    if (Inv.ReadReturnStruct(Result)) {
        TestRunner->TestEqual(TEXT("upper"), Result, TEXT("HELLO"));
    }
}
```

### 现有 CQTest PoC 参考

| 文件 | 测试数 | 覆盖范围 |
|---|---|---|
| `AngelscriptFStringBindingsTests.cpp` | 17 个 TEST_METHOD，300+ 用例 | FString 全 API + 全局函数 + 跨边界传参/返回 |

## 测试模板（Template/ 目录）

`Plugins/Angelscript/Source/AngelscriptTest/Template/` 下保存了一组「教学型」测试模板，作为新测试的起点。它们本身也是 Automation 测试、会随回归一起运行，但首要价值是**演示标准做法**。新增同类测试时优先 copy-paste 改写一个模板，而不是从零拼接。

| 模板 | 主题 | Automation 前缀 | 推荐起点的场景 |
|---|---|---|---|
| `Template_CQTest.cpp` | CQTest 骨架（编译 / 单 / 多断言 / 错误处理） | `Angelscript.Template.CQTest.*` | 任何要写 AS 编译执行回归的纯 C++ 测试，先看它 |
| `Template_GlobalFunctions.cpp` | 通过 `FASGlobalFunctionInvoker` 调用 AS 全局函数 | `Angelscript.Template.GlobalFunctions.*` | C++ 直接调 AS 全局函数（非 `UFUNCTION`）传参 / 返回 |
| `Template_ReflectionAccess.cpp` | 通过 `ReadPropertyValue` / `GetEnumByPath` 读 AS 端 UPROPERTY / UFUNCTION | `Angelscript.Template.Reflection.*` | UE 5.x 反射读 AS-side 属性，含 `float` ↔ `FDoubleProperty` 注意点 |
| `Template_WorldTick.cpp` | World.Tick / Actor.Tick / Component.Tick 三种驱动方式 | `Angelscript.Template.WorldTick.*` | 任何与「逐帧推进」绑定的 actor / component 测试 |
| `Template_GameLifetime.cpp` | 完整 Actor 生命周期：Construction → BeginPlay → Tick → EndPlay → Destroyed | `Angelscript.Template.GameLifetime.*` | 验证生命周期事件链 / 顺序、Destroy 后属性读取 |
| `Template_Blueprint.cpp` | 以 AS 类为父的瞬态 Blueprint 子类 | `Angelscript.Template.Blueprint.*` | Blueprint 继承 / 参数链 / 编译验证 |
| `Template_BlueprintWorldTick.cpp` | Blueprint actor child 在 world tick 下的回调链 | `Angelscript.Template.Blueprint.*` | Blueprint 子类的 BeginPlay / Tick 集成 |
| `Template_PIE.cpp` | CQTest + AS GameMode / AS LevelScriptActor 父类的真实 Editor PIE 启停 | `Angelscript.Template.PIE.*` | 需要覆盖 `FStartPIEForAutomationCommand`、PIE world context、Level Blueprint 父类和显式 EndPIE 清理路径的测试 |
| `Template_MultiplayerPIE.cpp` | CQTest + AS GameMode / AS LevelScriptActor 父类的多人 Editor PIE 启停 | `Angelscript.Template.MultiplayerPIE.*` | 需要覆盖 2/3/4 player listen server PIE、client PIE world、NetDriver、AS GameMode、Level Blueprint 父类和显式 EndPIE 清理路径的测试 |

约定：

- 模板文件位于 `Template/`，**不**作为新增功能 case 的最终落点。新功能 case 仍按 `Documents/Guides/TestConventions.md` 第 3 节的层级落到对应主题目录（`Actor/`、`Bindings/` 等）。
- 模板的 Automation 前缀统一使用 `Angelscript.Template.*`，避免与功能测试主题冲突。
- 新增 / 修改模板时同步更新本表与 `TestCatalog.md`。

### Actor / World Tick 测试推荐 harness

`Shared/AngelscriptTestWorld.h::FAngelscriptTestWorld` 是当前 actor / component 类功能测试的标准 harness（在 `FActorTestSpawner` 之上做组合扩展，自带 `FAngelscriptEngineScope`）。`Template_WorldTick.cpp` 与 `Template_GameLifetime.cpp` 是它的两份示范用法；harness 自身契约由 `Shared/AngelscriptTestWorldTests.cpp`（前缀 `Angelscript.TestModule.Shared.TestWorld.*`）锁定。

构造与基本用法：

```cpp
FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
FAngelscriptEngineScope Scope(Engine);

FAngelscriptTestWorld W(*TestRunner, Engine);
ASSERT_THAT(IsTrue(W.IsValid()));

AActor* Actor = W.SpawnActorOfClass(ScriptClass);
W.BeginPlay(*Actor);
```

三种 tick 驱动方式必须按场景区分使用：

| 方法 | 行为 | 适合的断言 |
|---|---|---|
| `W.Tick(Dt, N)` | `World.Tick` + 手动 `TActorIterator` 派发 actor / component tick | `>= N` 弱断言；多 actor / 含 component 场景 |
| `W.TickViaManager(Dt, N)` | 仅调用 `World.Tick`，由 UE world scheduler 决定派发 | `>= 1` 弱断言；演示 UE 调度路径 |
| `W.DispatchActorTick(Actor, Dt, N)` / `W.DispatchComponentTick(Comp, Dt, N)` | 直接循环 `Actor->Tick` / `Component->TickComponent`，绕开调度器 | **`== N` 严格断言**；首选用于精确 tick 计数 |

> **常见坑**：在 test world 里 `World.Tick` 不保证每一帧都派发 `ReceiveTick`。任何要做 `TickCount == NumTicks` 严格断言的测试必须用 `DispatchActorTick` / `DispatchComponentTick`，否则会出现实际跑了 N 帧但 AS 端只记录 1 次的偏差。

完整生命周期（Construction → BeginPlay → Tick → EndPlay → Destroyed）的标准模式：

```cpp
FAngelscriptTestWorld W(*this, Engine);
AActor* Actor = W.SpawnActorOfClass<AActor>(ScriptClass);  // 触发 UserConstructionScript
W.BeginPlay(*Actor);                                       // 触发 BeginPlay
W.Tick(0.016f, 3);                                         // 触发 Tick × N
W.DestroyAndDrain(*Actor);                                 // 同步触发 EndPlay + Destroyed
```

要点：

- AS 中的 `UFUNCTION(BlueprintOverride) void UserConstructionScript()` 才是 Spawn 阶段的构造回调，**不是** `ConstructionScript`。
- `Actor->Destroy()` 会同步派发 `EndPlay(EEndPlayReason::Destroyed)` 与 `Destroyed`，actor 随后被标记 `PendingKill`；但 UObject 内存仍存活，`FProperty::GetPropertyValue_InContainer`（即 `ReadPropertyValue`）依然可读，所以 `DestroyAndDrain` 之后断言阶段计数与 `LastEndPlayReason` 是合法做法。`TWeakObjectPtr::IsValid()` 在 `PendingKill` 后返回 `false`，不要把它当存活检查。
- AS 声明的 `float UPROPERTY` 在 UE 5.x 下被反射为 `FDoubleProperty`；C++ 侧必须用 `ReadPropertyValue<FDoubleProperty>` + `double`，否则 `FFloatProperty` 查找会返回空。
- Component tick 需要在 spawn 后手动开启，AS 不会自动翻 flag：

```cpp
Component->PrimaryComponentTick.bCanEverTick = true;
Component->SetComponentTickEnabled(true);
```

- BeginPlay 通过 harness 调用是幂等的（内部依赖 `AActor::HasActorBegunPlay()` 守卫），重复调用不会重派发。

新增 actor / component 测试时，不要再手写 `FActorTestSpawner` + 局部 `FAngelscriptEngineScope` + 局部 dispatch helper，统一用 `FAngelscriptTestWorld`。模块清理仍按现行 RAII 模式手写：

```cpp
static const FName ModuleName(TEXT("MyTestModule"));
ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };
```

## 与 Gauntlet 的边界

- `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` 负责仓库内标准自动化测试入口、日志、摘要和超时收口。
- `Gauntlet` 只在需要 outer shell、多进程会话编排、联网拓扑或更复杂生命周期管理时使用。
- 常规本地回归、AI Agent 执行和普通 CI 不要绕过官方 runner 去手写 `RunUAT` / `UnrealEditor-Cmd.exe`。

## 故障排除

### 测试前卡在构建阶段

如果日志里长时间没有任何编译推进，优先排查：

1. 是否有其他 worktree 还在跑旧的 `Build.bat` 路径
2. 是否需要在对应 build 中透传 `-NoXGE`
3. `Intermediate/TargetInfo.json` 是否已通过 bootstrap 正常预热

### 测试无输出直到超时

按以下顺序排查：

1. 确认参数名正确，前缀用 `-TestPrefix`，不是 `-Filter`
2. 用 `Tools\Diagnostics\powershell\Get-UbtProcess.ps1` 检查是否有残留 UBT / Editor
3. 确认同一 worktree 内没有第二个 build/test 正在运行
4. 检查当前 run 的 `RunMetadata.json`，看是否卡在 `TargetInfo` 预热、`Build.bat` 锁等待或编辑器执行阶段

## 对 AI Agent 的要求

1. 先读取根目录 `AgentConfig.ini`
2. 配置缺失或 worktree 路径不匹配时先跑 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1`；新 worktree 需要显式传 `-EngineRoot`
3. bootstrap 会自动初始化子模块；如果子模块仍缺失，参考 `Documents/Guides/SubmoduleWorktreeWorkflow.md`
4. 单条测试只通过 `Tools\RunTests.ps1`
5. suite 波次只通过 `Tools\RunTestSuite.ps1`
6. 显式传入或继承一个不超过 `900000ms` 的超时
7. 不要手写 `UnrealEditor-Cmd.exe`、`RunAutomationTests.ps1` 或共享日志路径

## 推荐提示词

```text
请先读取项目根目录的 AgentConfig.ini；如果缺失或 ProjectFile 不属于当前 worktree，先执行 Tools\Bootstrap\powershell\BootstrapWorktree.ps1（新 worktree 需要 -EngineRoot 参数）。bootstrap 会自动初始化子模块；如果子模块目录仍然为空，参考 Documents/Guides/SubmoduleWorktreeWorkflow.md 中的 fallback 策略。自动化测试只能通过 Tools\RunTests.ps1 或 Tools\RunTestSuite.ps1 执行，并显式带一个不超过 3600000ms 的超时。不要手写 UnrealEditor-Cmd.exe 命令，也不要手写 -ABSLOG / -ReportExportPath 共享路径；日志、报告和摘要必须写入当前 run 的独立目录。除非明确需要真实渲染，否则保持默认 headless 模式。
```
