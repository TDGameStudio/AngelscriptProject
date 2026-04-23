# Plan 归档目录

本目录存放已完成或已关闭的 Plan 文档。

- 活跃中的 Plan 继续保留在 `Documents/Plans/` 根目录。
- 已完成或已关闭的 Plan 统一移动到 `Documents/Plans/Archives/`。
- 归档前必须在文档顶部补齐 `归档状态`、`归档日期`、`完成判断` 与 `结果摘要`。
- 归档后必须同步更新 `Documents/Plans/Plan_OpportunityIndex.md` 以及相关导航/规则文档中的状态与路径。

## 当前已归档 Plan

| Plan | 归档日期 | 完成摘要 |
| --- | --- | --- |
| `Plan_AngelscriptTestExecutionInfrastructure.md` | 2026-04-04 | 完成了测试 group taxonomy、统一 runner、结构化摘要与执行文档收口，当前主干以 `Tools/RunTests.ps1` / `Tools/RunTestSuite.ps1` 作为正式入口。 |
| `Plan_BuildTestScriptStandardization.md` | 2026-04-04 | 完成了共享执行层、direct UBT 构建 runner、自动化测试 runner、UBT 进程查询与 tooling smoke tests，为后续构建/回归提供了统一脚本基础设施。 |
| `Plan_CallfuncDeadCodeCleanup.md` | 2026-04-04 | 移除了无效 `callfunc` `.lib` 引用，补充了旧汇编路径的废弃说明，并保留了后续 AS 2.38 合入时需要复查的替代链路。 |
| `Plan_ASEngineStateDump.md` | 2026-04-05 | 完成了 Runtime / Editor / Test 三侧状态 dump 导出链路、`as.DumpEngineState` 控制台命令、27 张 CSV 表与 `Angelscript.TestModule.Dump` 自动化回归，并在验证中修复了 worktree 作用域 `TargetInfo.json` 预热失配问题。 |
| `Plan_TestMacroOptimization.md` | 2026-04-05 | 完成了 `BEGIN/END` 批量接入、`SHARE_CLEAN` / `SHARE_FRESH` 宏与验证测试补齐，以及最终 build、关键前缀回归和 `AngelscriptFast` / `AngelscriptScenario` group 收口。 |
| `Plan_TechnicalDebt.md` | 2026-04-04 | 完成了 Phase 0-6 的技术债收口，将高风险问题分流到 sibling plan，并同步了相关构建、测试与清单文档。 |
| `Plan_UFunctionReflectiveFallbackBinding.md` | 2026-04-07 | 完成了 BlueprintCallable reflective fallback 后端、shared duplicate guard、三分类统计与 representative 正负例验证；收口阶段进一步把 shared reflective invocation helper 统一接入 Blueprint event / interface dispatch，并通过构建、native interface、GeneratedFunctionTable 前缀与完整 `Bindings` suite 回归。 |
| `Plan_InterfaceParityWithCpp.md` | 2026-04-24 | 完成了接口方法签名完整校验（参数数量/类型/返回值/const）、`TScriptInterface<UIFoo>` 本地变量 + C++ UPROPERTY round-trip 桥接、C++ 原生多接口实现类的指针偏移修复、接口方法 `BlueprintNativeEvent` / `BlueprintImplementableEvent` / `BlueprintCallable` / `BlueprintPure` 修饰符传递、`Obj.Implements<T>()` 预处理器语法糖五个方向的一致性补齐；ThirdParty 零新增修改；最终 Interface 41/41 + Preprocessor.Interface 3/3 测试通过；同步更新 `Documents/Knowledges/InterfaceBinding.md` 的能力矩阵与未覆盖 surface 标注、扩展 `Script/Examples/Extended/Example_ScriptInterface.as` 示例脚本。 |
