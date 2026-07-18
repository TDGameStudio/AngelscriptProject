# Build 指南

## 强制规则

- 本仓库的标准构建入口只有 `Tools\RunBuild.ps1`。
- 不再允许把 `Build.bat`、`RunUBT.bat` 或 `dotnet UnrealBuildTool.dll` 直接写进日常操作指引、Agent 提示词或自动化外壳。
- 所有构建命令都必须显式带超时，且超时不得超过 `3600000ms`。
- 默认构建超时来自 `AgentConfig.ini` 的 `Build.DefaultTimeoutMs`；仓库标准默认值为 `180000ms`。
- 构建过程必须实时输出；超时或异常退出后，脚本必须清理整棵 UBT 进程树。
- 每次构建都必须写入自己的独立日志目录；禁止把多个 worktree 的构建日志写到同一个共享文件。

## AgentConfig.ini 与 bootstrap

执行任何构建命令前，先读取项目根目录的 `AgentConfig.ini`。

关键配置项：

```ini
[Paths]
EngineRoot=<UE 根目录>
ProjectFile=<当前 worktree 的 .uproject>

[Build]
EditorTarget=AngelscriptProjectEditor
Platform=Win64
Configuration=Development
Architecture=x64
DefaultTimeoutMs=180000

[Test]
DefaultTimeoutMs=600000
```

如果当前 worktree 还没有 `AgentConfig.ini`，优先执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1
```

常用 bootstrap 方式：

```powershell
# 初始化当前 worktree
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1

# 初始化所有已注册 worktree
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -AllRegisteredWorktrees

# 显式指定引擎目录并跳过预热
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -EngineRoot "J:\UnrealEngine\UERelease" -NoPrewarm
```

`Tools\Bootstrap\powershell\BootstrapWorktree.ps1` 会：

- 生成或规范化当前 worktree 的 `AgentConfig.ini`
- 回填 `Build.DefaultTimeoutMs=180000` 与 `Test.DefaultTimeoutMs=600000`
- 把 `Paths.ProjectFile` 固定到当前 worktree 的 `.uproject`
- 预热 `Intermediate/TargetInfo.json`，避免首次 build/test 把时间浪费在旧的 `Build.bat` 查询阶段

只想给 Agent 生成官方命令模板时，使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1
```

该脚本在配置缺失时会先返回 `BootstrapCommand`，配置正常时才返回构建与测试模板。

## 标准入口

### 并发开发默认模式

多个 worktree 共享同一个引擎目录时，默认使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label agent-build -TimeoutMs 180000
```

默认行为：

- 直接调用 `dotnet <EngineRoot>\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll`
- 自动读取 `AgentConfig.ini`
- 默认追加 `-NoMutex -NoEngineChanges`
- 对同一 worktree 加单飞锁，禁止同一 worktree 内重复 build/test
- 通过 `-Log=` 把 UBT 日志重定向到当前 run 的私有目录，避免写入共享 `Log.txt`
- 不依赖 `Build.bat` 的全局脚本锁，因此允许不同 worktree 并发构建

常用命令模板也可以通过 `Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1` 直接获取；当前会同时返回：

- `BuildCommand`
- `NoXgeBuildCommand`
- `SerializedBuildCommand`

### 需要改动引擎输出时

如果本次构建会改写共享引擎产物，必须显式切换到串行模式：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine
```

该模式会基于 `EngineRoot` 获取命名互斥锁，避免多个 worktree 同时写引擎输出。

## 常用参数

```powershell
Tools\RunBuild.ps1 -Label compile-bindings -TimeoutMs 120000
Tools\RunBuild.ps1 -Label compile-bindings -TimeoutMs 180000 -NoXGE
Tools\RunBuild.ps1 -Label compile-bindings -TimeoutMs 180000 -- -Verbose
Tools\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine
Tools\RunBuild.ps1 -Label local-log-root -TimeoutMs 180000 -LogRoot "D:\Tmp\AngelscriptLogs"
```

参数说明：

- `-TimeoutMs`：本次构建超时，必须大于 `0` 且不超过 `3600000`
- `-Label`：输出目录标签
- `-LogRoot`：自定义输出根目录；脚本会把它当成父目录，再创建独立的 `Build/<Label>/<RunId>/`
- `-NoXGE`：禁用 XGE / Incredibuild 入口，避免外部分布式执行器容量影响验证结果
- `-SerializeByEngine`：启用引擎级串行锁
- `-- <ExtraArgs>`：透传少量非常用 UBT 参数；常用的 `-NoXGE` / `-UniqueBuildEnvironment` 不再推荐通过 `ExtraArgs` 传递

## 输出与产物

默认输出目录：

```text
Saved/Build/<Label>/<RunId>/
  Build.log
  UBT.log
  RunMetadata.json
```

如果传入 `-LogRoot D:\Tmp\Logs`，实际目录会变成：

```text
D:\Tmp\Logs\Build\<Label>\<RunId>\
```

注意：

- `-LogRoot` / 自定义目录只是父目录，不是最终运行目录
- 每次调用都会新建独立 `RunId`，防止多个 worktree 或多次重跑把日志写进同一文件
- `Build.log` 是脚本流式日志，`UBT.log` 是 UBT 自己的日志，`RunMetadata.json` 记录参数、阶段、超时与退出码

## Angelscript 编译选项

Angelscript 编译期策略放在项目级专用文件：

```ini
; Config/DefaultAngelscriptCompileOptions.ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
bCompileAngelscriptUnitTests=true
FunctionBindingMethod=NativeRuntimeLinked
+NativeRuntimeLinkedModules=Engine
+NativeRuntimeLinkedModules=UMG
```

本仓库是 Angelscript 插件开发工程，checked-in 默认值保持 `bCompileAngelscriptUnitTests=true`。此时 `AngelscriptTest.Build.cs` 会定义 `WITH_ANGELSCRIPT_UNITTESTS=1`，Angelscript C++ automation 测试会向 Unreal Automation 注册，测试模块启动时也会保留 test engine pool 预热和测试初始化 override。

如需模拟插件消费者或本地轻量构建，可临时把该值改为 `false` 后重新构建。此时 `WITH_ANGELSCRIPT_UNITTESTS=0`，`AngelscriptTest` 模块仍在既有 plugin module layout 中构建，但 Angelscript C++ automation 测试不会向 Unreal Automation 注册，测试模块启动时也不会预热 test engine pool 或安装测试初始化 override。

保持默认值后，直接重新构建并运行 Angelscript C++ automation 测试：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-tests-enabled -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -TimeoutMs 600000
```

`AngelscriptTest.Build.cs` 将 `Config/DefaultAngelscriptCompileOptions.ini` 注册为 `ExternalDependencies`。修改该文件后，包含 `AngelscriptTest` 的目标会因为该外部依赖变化而让 UBT makefile 失效。这个 gate 控制测试注册和测试专用编译路径，不表示 UBT 完全跳过扫描或包含 `AngelscriptTest` 模块；完整模块级排除需要单独的 target/plugin-level module gate。

`FunctionBindingMethod` 是全局自动绑定策略，可选 `None`、`NativeRuntimeLinked` 和 `NativeModuleFunctionAddress`。前者关闭所有 UHT 自动注册；Runtime-linked 模式从 `NativeRuntimeLinkedModules` 动态增加 Runtime 依赖并生成 wrapper；target-module 模式从 `NativeModuleFunctionAddressModules` 生成目标模块 shard，并定义 `WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS=1`。target-module 模式只支持源码版引擎：编辑器中修改时会弹错并拒绝保存，直接改 ini 时 UBT 和 UHT 都会硬失败；构建版、安装版以及无法识别的引擎都按非源码处理。

## 查询当前 UBT 进程

排查卡死、残留 UBT 或多 worktree 并发情况时使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\Get-UbtProcess.ps1
```

只看当前 worktree：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\Get-UbtProcess.ps1 -CurrentWorktreeOnly
```

## 多 worktree 故障排除

### XGE 槽位争抢

症状：

- 构建启动后长时间没有 `[N/M] Compile`
- 日志出现 `Using XGE executor` 后停住
- 当前 worktree 没有残留 UBT，但其他 worktree 正在活跃构建
- 或者直接在日志里看到 `Maximum number of concurrent builds reached.`

处理方式：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label noxge -TimeoutMs 180000 -NoXGE
```

补充说明：

- `2026-04-05` 的专用 `main` worktree 并发构建验证表明，`RunBuild.ps1` 已经能把每次构建的 `UBT.log` 隔离到各自的 run 目录，但 **XGE executor 仍然可能因为机器上的并发容量限制拒绝第二个构建**。
- 这类失败不是 `Build.bat` 锁，也不是共享 `UBT.log` 路径冲突，而是 XGE / Incredibuild 侧的资源上限问题。
- `PowerShell.exe -File ... -- -NoXGE` 容易在多层转发时被误解析；标准 runner 现在提供一等参数 `-NoXGE`，不要再手写 `-- -NoXGE`。
- 对“两个 worktree 同时构建是否互不干扰”的验证，建议优先使用 `-NoXGE` 复现脚本层并发能力，先把分布式执行器容量这个外部变量排掉。

### 旧 `Build.bat` 锁争用

旧流程走 `Build.bat` 时，会在共享引擎目录上占用全局脚本锁。标准构建已经绕过这条路径；如果仍遇到锁争用，说明还有旧文档、旧脚本或其他 worktree 没切到 `Tools\RunBuild.ps1`。

处理顺序：

1. 用 `Tools\Diagnostics\powershell\Get-UbtProcess.ps1` 找出还在跑旧流程的 worktree
2. 用 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -AllRegisteredWorktrees` 统一补齐配置
3. 只通过 `Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1` / 本文档下发构建命令

### UBT 共享日志冲突

UBT 默认会写共享 `Log.txt`。`RunBuild.ps1` 已通过 `-Log=` 把它重定向到当前 run 的 `UBT.log`；如果仍看到共享日志冲突，说明调用方绕过了 `Tools\RunBuild.ps1`。

### UHT Timestamp 共享写冲突

症状：

- 构建日志里出现 `Couldn't write Timestamp file: ...\UHT\Timestamp ... being used by another process`
- 或在 header 阶段直接出现 `IOException: ...\UHT\Timestamp ... being used by another process`
- 进程退出码有时仍然是 `0`，但日志已经说明本次共享引擎 intermediate 发生了竞争

根因：

- `-NoEngineChanges` 只覆盖 action graph 里“已存在的引擎产物改写”
- UBT 的 `ExternalExecution.UpdateTimestamps()` 会在 header 阶段后额外读写 `...\UHT\Timestamp`
- 当 editor target 仍使用 shared build environment 时，这批 timestamp 默认落在共享 `Engine\Intermediate\Build\...\UHT\Timestamp`

处理方式：

```powershell
# 低成本兜底：共享引擎继续共用，但在引擎级串行
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine
```

已评估但禁止采用的方案（`2026-04-05`）：

- `-UniqueBuildEnvironment` 确实能把共享 `UHT\Timestamp` 改到当前 worktree 私有 `Intermediate\Build\...`
- 但这会触发一轮 worktree 私有的巨型首次编译；实测在 `AngelscriptProjectEditor` 上直接进入约 `3571` actions 的大规模构建
- 用户已明确要求**禁止使用**这条路径，因此标准 runner、模板和文档都不再下发或推荐 `-UniqueBuildEnvironment`
- 当前允许的官方策略只保留两种：
  - 继续共享引擎输出，但使用 `-SerializeByEngine`
  - 给需要强隔离的 worktree 分配独立 `EngineRoot`

## 对 AI Agent 的要求

1. 先读取根目录 `AgentConfig.ini`
2. 配置缺失时先跑 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1`；新 worktree 需要显式传 `-EngineRoot`（从主 workspace `AgentConfig.ini` 读取）
3. bootstrap 现在会自动初始化子模块（标准 init + fallback 本地对象库 worktree）；如果仍有子模块缺失，参考 `Documents/Guides/SubmoduleWorktreeWorkflow.md`
4. 仅通过 `Tools\RunBuild.ps1` 执行构建
5. 显式传入或继承一个不超过 `3600000ms` 的超时
6. 默认使用并发模式；只有确认会写引擎共享输出时才加 `-SerializeByEngine`
7. 不要使用 `-UniqueBuildEnvironment`；这会触发 worktree 私有的引擎级重编
8. 不要手写 `Build.bat` / `RunUBT.bat` / `dotnet UnrealBuildTool.dll`

## 推荐提示词

```text
请先读取项目根目录的 AgentConfig.ini；如果缺失或 ProjectFile 不属于当前 worktree，先执行 Tools\Bootstrap\powershell\BootstrapWorktree.ps1（新 worktree 需要 -EngineRoot 参数）。bootstrap 会自动初始化子模块；如果子模块目录仍然为空，参考 Documents/Guides/SubmoduleWorktreeWorkflow.md 中的 fallback 策略。构建只能通过 Tools\RunBuild.ps1 进行，并显式带一个不超过 3600000ms 的超时。默认保持并发模式；只有确认要写共享引擎输出时才追加 -SerializeByEngine。常用的 -NoXGE 不要再通过 ExtraArgs 透传，直接使用一等参数。不要使用 -UniqueBuildEnvironment，因为它会触发 worktree 私有的引擎级重编。日志必须实时输出，并写入当前 run 的独立目录；不要手写 Build.bat、RunUBT.bat 或 dotnet UnrealBuildTool.dll 命令。
```
