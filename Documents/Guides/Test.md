# Test 指南

## 强制规则

- 本仓库的标准自动化测试入口是 `Tools\RunTests.ps1`。
- 具名 suite 只能通过 `Tools\RunTestSuite.ps1` 调度；不要手写一组 `RunTests` 命令散落到文档里。
- 不再允许把 `UnrealEditor-Cmd.exe` 直调命令、`Start-Process UnrealEditor-Cmd.exe` 拼参命令、或旧的 `Tools\RunAutomationTests.ps1` 当作标准入口写入指南。
- 所有测试命令都必须显式带超时，且超时不得超过 `900000ms`。
- 默认测试超时来自 `AgentConfig.ini` 的 `Test.DefaultTimeoutMs`；仓库标准默认值为 `600000ms`。
- 测试过程必须实时输出；超时或异常退出后脚本必须清理整棵编辑器/UBT 进程树。
- 每次测试都必须写入自己的独立输出目录；禁止多个 run 共用同一份 `Automation.log` 或报告目录。

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

反射回退绑定专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.BlueprintCallableReflectiveFallback" -Label reflective-fallback -TimeoutMs 600000
```

GeneratedFunctionTable 三分类统计专项前缀：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionTable" -Label generated-table -TimeoutMs 600000
```

对应的 UHT 生成统计会在每次标准 build/UHT 运行时写入：

```text
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_Summary.json
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_ModuleSummary.csv
Plugins/Angelscript/Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_Entries.csv
```

该文件当前至少包含这些字段：

- `totalGeneratedEntries`
- `totalDirectBindEntries`
- `totalStubEntries`
- `directBindRate`
- `stubRate`
- `totalShardCount`
- `moduleCount`
- `modules[]`（逐模块 `totalEntries/directBindEntries/stubEntries/directBindRate/stubRate/shardCount`）

CSV 侧的用途区分如下：

- `AS_FunctionTable_ModuleSummary.csv`：按模块聚合，适合快速看 `total/direct/stub/rate/shards`
- `AS_FunctionTable_Entries.csv`：逐条函数明细，适合按 `ModuleName/ClassName/FunctionName/EntryKind/EraseMacro/ShardIndex` 过滤查询

### 按测试组运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptDebugger -Label debugger -TimeoutMs 600000
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

`GeneratedFunctionTable` 相关验证除了自动化报告外，还应结合 `AS_FunctionTable_Summary.json` 一起看；前者回答“测试是否通过”，后者回答“本次 UHT 生成了多少条格式绑定，以及 direct/stub 的模块分布”。

当需要定位“某个函数为什么是 direct 还是 stub”时，优先查询 `AS_FunctionTable_Entries.csv`，不要再从 `AS_FunctionTable_*.cpp` shard 文件中手工 grep。前者是正式产物，后者是代码生成中间结果。

## 常用参数

### `Tools\RunTests.ps1`

```powershell
Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 120000
Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests." -Label runtime-unit -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump" -Label dump -TimeoutMs 600000
Tools\RunTests.ps1 -Group AngelscriptFunctional -Label functional -TimeoutMs 900000 -Render
Tools\RunTests.ps1 -Group AngelscriptFast -Label fast -TimeoutMs 600000 -- -log
```

- `-TestPrefix`：按测试名前缀运行
- `-Group`：按 `Config/DefaultEngine.ini` 中定义的 automation group 运行
- `-TimeoutMs`：本次测试超时，必须大于 `0` 且不超过 `900000`
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
- `-ListSuites`：列出内置 suite 与对应前缀
- `-DryRun`：只打印将要执行的命令

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
J:\UnrealEngine\UERelease\Engine\Binaries\Win64\UnrealEditor-Cmd.exe <ProjectFile> -run=AngelscriptBlueprintImpactScan -stdout -FullStdOutLogOutput -Unattended -NoPause -NoSplash -NullRHI
J:\UnrealEngine\UERelease\Engine\Binaries\Win64\UnrealEditor-Cmd.exe <ProjectFile> -run=AngelscriptBlueprintImpactScan -ChangedScript="Foo.as;Bar.as" -stdout -FullStdOutLogOutput -Unattended -NoPause -NoSplash -NullRHI
```

其中 `<ProjectFile>` 应由当前 worktree 的 `AgentConfig.ini` 提供，不要在常规执行说明里写死其他 worktree 的 `.uproject` 路径。

常用具名 suite 以 `Tools\RunTestSuite.ps1 -ListSuites` 的输出为准，当前重点包括：

- `Smoke`
- `NativeCore`
- `RuntimeCpp`
- `Debugger`
- `Bindings`
- `HotReload`
- `FunctionalSamples`
- `All`

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
2. 配置缺失或 worktree 路径不匹配时先跑 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1`
3. 单条测试只通过 `Tools\RunTests.ps1`
4. suite 波次只通过 `Tools\RunTestSuite.ps1`
5. 显式传入或继承一个不超过 `900000ms` 的超时
6. 不要手写 `UnrealEditor-Cmd.exe`、`RunAutomationTests.ps1` 或共享日志路径

## 推荐提示词

```text
请先读取项目根目录的 AgentConfig.ini；如果缺失或 ProjectFile 不属于当前 worktree，先执行 Tools\Bootstrap\powershell\BootstrapWorktree.ps1。自动化测试只能通过 Tools\RunTests.ps1 或 Tools\RunTestSuite.ps1 执行，并显式带一个不超过 900000ms 的超时。不要手写 UnrealEditor-Cmd.exe 命令，也不要手写 -ABSLOG / -ReportExportPath 共享路径；日志、报告和摘要必须写入当前 run 的独立目录。除非明确需要真实渲染，否则保持默认 headless 模式。
```
