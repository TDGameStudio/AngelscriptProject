param(
    [int]$MaxIterations = 1000,

    [int]$MaxConsecutiveFailures = 3,

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
                if ($val -ne '' ) { $env:CODEX_HOME = $val; break }
            }
        }
    }
    if (-not $env:CODEX_HOME) {
        $env:CODEX_HOME = 'C:\Users\scottmei\.codex_test_nopro'
    }
}

# ── 确保输出目录存在 ──────────────────────────────────────────────────────────
$historyDir = Join-Path $workspace 'Documents\ImplementTestCoverage'
if (-not (Test-Path $historyDir)) {
    New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
}

# ── 提示词 ───────────────────────────────────────────────────────────────────
$prompt = @'
你正在实现 Angelscript 插件的测试覆盖补全。

## 必读规则

1. **AGENTS.md**（项目根目录）— 项目总纲、架构决策、代码来源原则、测试文件规范。
2. **Plugins/Angelscript/AGENTS.md** — 插件内部测试分层与命名规范。
3. **Documents/Rules/ImplementTestCoverageRule_ZH.md** — 本工具的详细规则。

上述文件如有冲突，以 AGENTS.md 为准。

## 实现目标

从以下 8 个测试缺口文档中选取 NewTest 条目并实际编写 C++ 测试代码。跨全部模块统一选取，每轮只实现一个条目，按优先级 P0 > P1 > P2 > P3 选取。

## 测试缺口文档（全部只读）

| 模块 | 缺口文档 | 测试目标目录 | 对应源码 |
|------|---------|-------------|---------|
| RuntimeCore | Documents/AutoPlans/TestCoverage/RuntimeCore_TestGaps.md | AngelscriptTest/Core/, Subsystem/, GC/, FileSystem/ | AngelscriptRuntime/Core/ |
| ClassGenerator | Documents/AutoPlans/TestCoverage/ClassGenerator_TestGaps.md | AngelscriptTest/ClassGenerator/, HotReload/ | AngelscriptRuntime/ClassGenerator/ |
| BindSystem | Documents/AutoPlans/TestCoverage/BindSystem_TestGaps.md | AngelscriptTest/Bindings/ | AngelscriptRuntime/Binds/ |
| Preprocessor | Documents/AutoPlans/TestCoverage/Preprocessor_TestGaps.md | AngelscriptTest/Preprocessor/, Compiler/ | AngelscriptRuntime/Preprocessor/ |
| DebuggingAndJIT | Documents/AutoPlans/TestCoverage/DebuggingAndJIT_TestGaps.md | AngelscriptTest/Debugger/ | AngelscriptRuntime/Debugging/, StaticJIT/ |
| FunctionLibraries | Documents/AutoPlans/TestCoverage/FunctionLibraries_TestGaps.md | AngelscriptTest/Bindings/（分散） | AngelscriptRuntime/FunctionLibraries/ |
| LanguageFeatures | Documents/AutoPlans/TestCoverage/LanguageFeatures_TestGaps.md | AngelscriptTest/Angelscript/, Internals/, Interface/ | AngelscriptRuntime/Core/（语言层） |
| EditorAndTools | Documents/AutoPlans/TestCoverage/EditorAndTools_TestGaps.md | AngelscriptTest/Editor/ | AngelscriptEditor/ |

所有测试目录的完整前缀为 `Plugins/Angelscript/Source/`。

## 实现记录文档（读写）

Documents/ImplementTestCoverage/ImplementHistory.md

## 参考资源

- 测试 Helper: Plugins/Angelscript/Source/AngelscriptTest/Shared/
- 调试器 Fixture: Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.*
- 测试规范: Documents/Guides/TestConventions.md
- 测试指南: Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md
- 宏说明: Plugins/Angelscript/Source/AngelscriptTest/Shared/README_MACROS.md

## 工作流程（每轮必须严格遵守）

### 第一步：检查未完成工作

1. 读取 `Documents/ImplementTestCoverage/ImplementHistory.md`。
2. 搜索所有 `- [ ]` 标记的未完成条目。
3. 如果存在未完成条目，**跳过选择新测试**，直接进入第三步完成该条目的实现。
4. 如果所有条目都是 `- [x]`（或文件为空/不存在），进入第二步。

### 第二步：选择新测试并记录目标

1. 依次读取上表中全部 8 个缺口文档。
2. 收集所有 `NewTest-<编号>` 条目，跳过已在 `ImplementHistory.md` 中出现的（无论 `[x]` 还是 `[~]`）。
3. 按优先级 P0 > P1 > P2 > P3 跨模块统一排序，选择优先级最高的一个。同优先级时优先选择条目编号较小的。
4. **先写入 `Documents/ImplementTestCoverage/ImplementHistory.md`**，格式：

```markdown
- [ ] **NewTest-<编号>** (<模块名>) `<测试名>` — <一句话描述> (开始时间: YYYY-MM-DD HH:MM)
```

5. 写入后才开始实现。

### 第三步：实现测试

**使用并发 agent 加速**：尽量将可并行的子任务分发给并发 agent 同时执行。例如：
- 并行读取多个参考文件（已有测试、Helper、源码 API）
- 并行读取 TestGaps 文档和 TestConventions 规范
- 如果一个 NewTest 需要创建新文件 + 修改 Helper，可以并行准备两边的上下文

**但构建和测试必须严格串行**：
1. 先完成所有代码编写
2. 然后构建（使用 `Tools\RunBuild.ps1`，见 `Documents/Guides/Build.md`）
3. 构建通过后再运行测试（使用 `Tools\RunTests.ps1`，见 `Documents/Guides/Test.md`）
4. 测试通过后才标记完成

**实现步骤**：

1. 根据 `NewTest` 条目的详细描述（测试文件、场景、输入、期望行为、Helper），编写实际的 C++ 测试代码。
2. 测试代码必须遵循项目测试规范（见 AGENTS.md §8 测试文件规范）：
   - 使用 `ASTEST_*` 宏（`ASTEST_BEGIN` / `ASTEST_END` 等）
   - 命名前缀 `Angelscript.TestModule.<Theme>.*`
   - 单文件 300-500 行，单职责
   - 文件名以 `Angelscript` 开头，后缀 `Tests.cpp`
3. 如果 `NewTest` 建议创建新文件，就创建新文件。
4. 如果 `NewTest` 建议追加到已有文件，就追加到已有文件。
5. 参考 `Plugins/Angelscript/Source/AngelscriptTest/Shared/` 下的 Helper 和已有测试文件风格。
6. 参考 `Documents/Guides/TestConventions.md` 的测试规范。
7. 在写新测试之前，先读取目标目录下已有的测试文件，了解 include、helper 用法、宏风格，确保风格一致。

### 第三步 B：构建验证

**必须严格遵循 `Documents/Guides/Build.md` 和 AGENTS.md 中的构建规则。**

- 唯一标准入口：`Tools\RunBuild.ps1`。禁止直接调用 `Build.bat`、`RunUBT.bat` 或 `dotnet UnrealBuildTool.dll`。
- 必须显式带超时且不超过 `900000ms`。
- 构建前先确认 `AgentConfig.ini` 存在；如不存在，先执行 `Tools\Bootstrap\powershell\BootstrapWorktree.ps1`。

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label implcov -TimeoutMs 180000
```

1. 代码写完后执行上述构建命令。
2. 如果构建失败，修复编译错误后重新构建，直到通过。
3. 构建通过后进入测试。

### 第三步 C：测试验证

**必须严格遵循 `Documents/Guides/Test.md` 和 AGENTS.md 中的测试规则。**

- 唯一标准入口：`Tools\RunTests.ps1`。禁止直接调用 `UnrealEditor-Cmd.exe`。
- 必须显式带超时且不超过 `900000ms`。
- 用 `-TestPrefix` 只跑新增测试的 Automation 前缀。

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.<新测试前缀>" -Label implcov -TimeoutMs 600000
```

1. 构建通过后，运行新增测试。
2. 如果测试失败，修复代码后重新构建、重新测试。
3. 测试通过后进入第四步。

### 第四步：标记完成

1. 构建通过且测试通过后，将 `ImplementHistory.md` 中对应条目从 `- [ ]` 改为 `- [x]`，并追加完成时间：

```markdown
- [x] **NewTest-<编号>** (<模块名>) `<测试名>` — <一句话描述> (开始: YYYY-MM-DD HH:MM, 完成: YYYY-MM-DD HH:MM)
  - 文件: `<实际创建/修改的文件路径>`
  - 用例数: <N>
  - 备注: <简短说明实现中的决策或注意点>
```

2. 如果实现过程中发现 `NewTest` 条目的描述有误或不可行，标记为：

```markdown
- [~] **NewTest-<编号>** (<模块名>) `<测试名>` — 跳过: <原因> (YYYY-MM-DD HH:MM)
```

然后回到第二步选择下一个。

3. 同时更新 `ImplementHistory.md` 顶部的统计表。

## 关键约束

1. **每轮只实现一个 NewTest**。不要一次实现多个。
2. **先记录再实现**。ImplementHistory.md 必须先有 `- [ ]` 记录，然后才开始写代码。
3. **完成后才标记**。代码写完并确认正确后，才把 `- [ ]` 改为 `- [x]`。
4. **不修改 TestGaps 文件**。`Documents/AutoPlans/TestCoverage/*.md` 是只读输入。
5. **不修改已有通过的测试**。只新增测试，不修改已有测试的逻辑（除非 NewTest 明确要求修复 Issue）。
6. **遵循 AGENTS.md 中的全部规则**：代码来源原则、测试文件规范（单文件单职责、300-500 行）、第三方代码修改注释格式等。
7. **参考已有测试风格**：在写新测试之前，先读取同目录下已有的测试文件，了解 include、helper 用法、宏风格。
8. **所有文字中文，代码、路径、技术术语英文。**
9. **跳过 ThirdParty/ 下的第三方代码相关测试。**
10. 如果 `NewTest` 依赖的源码 API 不存在或已变更，在 ImplementHistory.md 记录跳过原因，选择下一个。
11. **不要主动停止**。完成一个 NewTest 后立即开始下一个。某个模块的 NewTest 全部做完后，继续从其他模块选取。只有当所有 NewTest 条目都已完成或跳过时，才声明工作全部结束。
12. **遇到问题不卡死**。如果某个 NewTest 实现困难（缺少 API、依赖不满足、描述不清），立刻标记 `[~]` 跳过并选下一个，不要在一个条目上反复尝试超过一轮。
'@

# ── 写入临时提示词文件 ───────────────────────────────────────────────────────
$promptFile = Join-Path $env:TEMP "implcov_$PID.txt"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[IO.File]::WriteAllText($promptFile, $prompt, $utf8Bom)

# ── 调用 ralph-loop.ps1 ─────────────────────────────────────────────────────
$ralphLoop = Join-Path $workspace 'Tools\RalphLoop\ralph-loop.ps1'

try {
    $params = @{
        Prompt                 = 'ImplementTestCoverage'
        PromptFile             = $promptFile
        MaxIterations          = $MaxIterations
        MaxConsecutiveFailures = $MaxConsecutiveFailures
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
