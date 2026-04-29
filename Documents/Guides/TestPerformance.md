# Angelscript 性能采样与产物规范

## 目标

本文档定义启动 bind、编译、热重载和运行期关键路径的性能记录方案，先保证“能采、能落盘、能比较”，再考虑是否升级成强预算断言。

## 产物分层

### 自动化结果层

- 统一通过 `Tools\RunTests.ps1` 导出 JSON / HTML 自动化报告；脚本会为每次运行生成独立的 `Saved/Tests/<Label>/<RunId>/Report/` 目录。
- 自动化结果只负责通过/失败、测试名和标准报告结构，不承担详细时序原始数据。

### 原始日志层

- 统一通过 `Tools\RunTests.ps1` 输出完整运行日志；脚本会为每次运行生成独立的 `Saved/Tests/<Label>/<RunId>/Automation.log`。
- 启动 bind 与 reload 测试应输出统一前缀日志行，便于后处理脚本抽取指标。
- 原始日志保留一次执行的完整上下文，不以仓库提交形式长期保存。

### 人工摘要层

- 仓库内只登记命令模板、指标定义、最近一轮基线摘要与注意事项。
- 自动化报告与日志保存在 `Saved/Tests/<Label>/<RunId>/`，性能指标保存在 `Saved/Automation/AngelscriptPerformance/<RunId>/`；不直接提交易波动的大文件。

## 目录布局

自动化 runner 产物由 `Tools\RunTests.ps1` 统一写入：

```text
<Project>/Saved/Tests/<Label>/<RunId>/
  Automation.log
  Report/
  Summary.json
```

结构化性能指标仍按稳定 `RunId` 写入性能目录：

```text
<Project>/Saved/Automation/AngelscriptPerformance/<RunId>/
  Metrics/
  Artifacts/
```

- `Report/`：`Tools\RunTests.ps1` 导出的自动化报告。
- `Automation.log`：`Tools\RunTests.ps1` 输出的完整日志。
- `Metrics/`：结构化指标摘要，例如 `metrics.json`、`summary.md`。
- `Artifacts/`：可选的 CSV、额外诊断或截图索引，不要求首批一定启用。

## 首批指标定义

| 指标名 | 含义 | 首批用途 |
| --- | --- | --- |
| `startup.total_seconds` | 一次引擎初始化总时长 | 建立 Full / Clone / CreateForTesting 基线 |
| `startup.bind_script_types_seconds` | `BindScriptTypes()` 时长 | 区分总启动成本与 bind 成本 |
| `startup.call_binds_seconds` | `FAngelscriptBinds::CallBinds()` 时长 | 跟踪 bind family 数量变化带来的回退 |
| `reload.modify.soft_seconds` | modify 场景 soft reload 端到端时长 | 观察 body-only 改动成本 |
| `reload.rename_window.full_seconds` | rename-window 触发 full reload 的端到端时长 | 单独观察 rename 特有回退 |
| `reload.diagnostics_count` | 一次 reload 后的 diagnostics 数量 | 区分性能回退和失败路径 |
| `reload.generated_symbol_state` | generated class / struct / delegate 是否处于预期状态 | 为性能采样附带正确性锚点 |

## 推荐结构化摘要

`Metrics/metrics.json` 建议至少包含以下字段：

```json
{
  "run_id": "2026-04-03T120000Z-startup-bind",
  "test_group": "Angelscript.TestModule.Core.Performance",
  "environment": {
    "configuration": "Development Editor",
    "null_rhi": true,
    "warmup_runs": 1,
    "measurement_runs": 3
  },
  "metrics": [
    { "name": "startup.total_seconds", "samples": [0.0], "median": 0.0, "unit": "seconds", "source": "RuntimeInstrumentation" },
    { "name": "startup.bind_script_types_seconds", "samples": [0.0], "median": 0.0, "unit": "seconds", "source": "RuntimeInstrumentation" }
  ],
  "notes": [
    "Rename baseline is modeled as remove+add within deletion delay window."
  ]
}
```

首批不要求完全一致的字段顺序，但要求至少能表达 `run_id`、测试组、运行环境、样本集合、聚合值和备注。`metrics.json` 中的单项指标可以补充 `unit` 与 `source`，用于区分秒、毫秒、计数，以及手写采样、UE runtime instrumentation 或外部后处理来源。

## 采样策略

- 默认 `warmup` 至少 1 次，`measurement` 至少 3 次。
- 首轮只记录中位数、最小值、最大值和样本列表，不直接写死细粒度毫秒预算。
- 若存在首次初始化、文件缓存或并行运行噪声，应在摘要中明确注明，不把单次异常值直接升级成失败断言。

## UE 原生插桩入口

- `TRACE_CPUPROFILER_EVENT_SCOPE_STR`：进入 Unreal Insights 的 CPU timeline，用稳定低基数字符串命名，例如 `Angelscript.Compile.Modules`。
- `DECLARE_STATS_GROUP` / `DECLARE_CYCLE_STAT_EXTERN` / `SCOPE_CYCLE_COUNTER`：进入 `stat Angelscript`，用于本地编辑器或命令行观察。
- `CSV_DEFINE_CATEGORY_MODULE` / `CSV_SCOPED_TIMING_STAT`：进入 CSV profiler 的 `Angelscript` category，用于长跑或自动化后处理。
- 插桩集中在 `Core/AngelscriptPerformanceStats.h` / `.cpp`，新增阶段时先补 scope catalog，再接入具体调用点。

## 首批 telemetry 决策

- 默认方案：保留 `FPlatformTime::Seconds()` + 统一格式日志行 + `Tools\RunTests.ps1` 产物留痕，作为自动化 artifact 的稳定基础。
- Runtime instrumentation：启动 bind、CallBinds、initial compile、CompileModules、hot reload、class generator、BPVM JIT 调用、参数 context fallback、StaticJIT precompiled data、DebugServer tick、DumpAll、BlueprintImpact commandlet 已接入 UE 原生插桩。
- 可选增强：若后续验证表明当前 UE 版本能稳定从自动化测试写入 telemetry，再增量接入 `AddTestTelemetryData`；CSV profiler 已作为 runtime 侧插桩路径接入，不再作为首批前置风险。
- `UAutomationPerformanceHelper` 和重量级 Functional Test 依赖不作为首批必选项，避免在建立基线前先把执行入口复杂化。

## 推荐命令模板

执行路径应从 `AgentConfig.ini` 的 `Paths.EngineRoot` 读取引擎目录；自动化报告和日志路径由 `Tools\RunTests.ps1` 生成，不要手写 `-ABSLOG` / `-ReportExportPath`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptPerformance -Label perf -TimeoutMs 900000
```

只跑运行期微基准时：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Performance." -Label perf-runtime -TimeoutMs 600000
```

### 当前已落地的性能测试前缀

- `Angelscript.TestModule.Performance.ScriptSelf`
- `Angelscript.TestModule.Performance.NativeProperty`
- `Angelscript.TestModule.Performance.NativeFunction`
- `Angelscript.TestModule.Core.Performance.Startup.Full`
- `Angelscript.TestModule.Core.Performance.Startup.Clone`
- `Angelscript.TestModule.Core.Performance.Startup.CreateForTestingFallbackFull`
- `Angelscript.TestModule.Core.Performance.Startup.CreateForTestingClone`
- `Angelscript.TestModule.HotReload.Performance.SoftReloadLatency`
- `Angelscript.TestModule.HotReload.Performance.FullReloadLatency`
- `Angelscript.TestModule.HotReload.Performance.RenameWindowLatency`
- `Angelscript.TestModule.HotReload.Performance.BurstChurnLatency`
- `Angelscript.TestModule.Core.Performance.ArtifactGeneration`
- `Angelscript.TestModule.Core.Performance.InstrumentationScopeCatalog`

### 推荐运行波次

- 运行期微基准：`Automation RunTests Angelscript.TestModule.Performance`
- 启动基线：`Automation RunTests Angelscript.TestModule.Core.Performance.Startup`
- 热重载延迟：`Automation RunTests Angelscript.TestModule.HotReload.Performance`
- 产物回归：`Automation RunTests Angelscript.TestModule.Core.Performance.ArtifactGeneration`

### 当前产物示例

#### P3 基线样本

- `Saved/Automation/AngelscriptPerformance/P3_1_StartupPerformance_Full/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_1_StartupPerformance_Clone/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_1_StartupPerformance_CreateForTestingFallback/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_1_StartupPerformance_CreateForTestingClone/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_2_HotReloadPerformance_Soft/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_2_HotReloadPerformance_Full/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_2_HotReloadPerformance_RenameWindow/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_4_HotReloadPerformance_BurstChurn/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/P3_4_PerformanceArtifactGeneration/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_ScriptSelf/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeProperty/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeFunction/Metrics/metrics.json`

#### P5/P6 回归与执行证据样本

- `Saved/Automation/AngelscriptPerformance/P5_NativeScriptHotReload_Rerun2/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P5_ClassRename_Rerun2/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P5_AddModifyLookupFlow_Rerun2/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P5_FailureKeepsOldCode_Rerun2/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_FileSystem/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_MultiEngine/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_DependencyInjection/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_Subsystem/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_BindConfig/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_Parity/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_EditorDirectoryWatcher/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_HotReload/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_ScriptClass/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_NativeScriptHotReload/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_PerfStartup/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_PerfHotReload/Reports/index.json`
- `Saved/Automation/AngelscriptPerformance/P6_PerfArtifactGeneration/Reports/index.json`

## 结果复核清单

- 自动化报告目录已生成，且包含可读 JSON / HTML 报告。
- 原始日志目录已生成，且能定位到本次运行的结构化性能日志行。
- `Metrics/metrics.json` 至少包含运行元数据、样本值和聚合值。
- 人工摘要只记录稳定结论与命令模板，不提交原始大文件。
- 若某次运行包含 rename-window 或 full reload，摘要中应显式标记该场景，不与普通 modify 混写。
