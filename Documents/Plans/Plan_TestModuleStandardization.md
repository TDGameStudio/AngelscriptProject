# 测试模块规范化计划

## 背景与目标

当前项目的测试体系已经具备较完整的覆盖面，但在“目录落点、文件命名、Automation 前缀、执行入口”四个维度上仍存在明显的历史漂移：

1. `AngelscriptRuntime/Tests`、`AngelscriptEditor/Tests`、`AngelscriptTest` 三条测试线已经形成事实分层，但规则更多散落在代码和历史文档中，没有单一规范入口。
2. 部分 Native / ASSDK 测试文件名没有显式带 `ASSDK`，部分测试文件缺少统一的 `Angelscript` 前缀，后续搜索和维护成本偏高。
3. `RunTests.ps1` 已经能稳定执行单前缀，但常用 smoke / native / scenario 波次还没有具名 suite，导致执行流程仍依赖手工拼命令。

本计划的目标是：

- 固定测试层级与命名规则；
- 补齐标准流程入口；
- 先整理几个典型测试场景，作为后续扩测与批量迁移的模板。

## 当前事实状态

- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 事实前缀为 `Angelscript.TestModule.CppTests.*`
- `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` 事实前缀为 `Angelscript.Editor.*`
- `Plugins/Angelscript/Source/AngelscriptTest/` 事实前缀为 `Angelscript.TestModule.*`
- Native 层原先存在未显式带 `ASSDK` 的历史文件名：`AngelscriptSmokeTest.cpp`、`AngelscriptEngineTests.cpp`、`AngelscriptExecuteTests.cpp`、`AngelscriptGlobalVarTests.cpp`；本轮已统一迁为 `AngelscriptASSDK*Tests.cpp`
- `Preprocessor/PreprocessorTests.cpp` 原先缺少统一的 `Angelscript` 前缀；本轮已迁为 `AngelscriptPreprocessorTests.cpp`

## 分阶段执行计划

### Phase 0：梳理现状与规范边界

- [x] 盘点测试目录、Automation 前缀与运行入口
- [x] 识别主要命名异常与流程缺口
- [x] 确定首轮以“低风险代表性修正 + 文档/脚本固化”为边界，不做全仓大规模前缀改名

### Phase 1：固定规则与流程入口

- [x] 新增 `Documents/Guides/TestConventions.md`，统一记录测试分层、目录矩阵、文件命名、Automation 前缀与典型场景
- [x] 更新 `Documents/Guides/Test.md`，加入标准流程和 suite 入口说明
- [x] 新增 `Tools/RunTestSuite.ps1`，提供具名 suite 的标准执行入口
- [x] 更新 `Documents/Tools/Tool.md`，登记新脚本参数与使用方式

### Phase 2：首轮命名规范化（代表性样本）

- [x] 把 ASSDK Smoke / Engine / Execute / GlobalVar 文件名补齐 `ASSDK` 标记
- [x] 把 `PreprocessorTests.cpp` 改为带 `Angelscript` 前缀的文件名
- [x] 同步更新直接引用这些文件名的 Guide / Plan 文档

### Phase 3：后续批量治理 backlog

- [ ] 评估是否需要统一 `ScriptExamples` / `Examples` 的对外命名口径
- [ ] 评估是否需要为 `WorldSubsystem` / `GameInstanceSubsystem` 单独补充目录映射说明或迁移计划
- [ ] 结合真实回归数据，继续扩展 `RunTestSuite.ps1` 的 suite 覆盖范围（例如 Learning、Performance、Editor 专项波次）

## 验收标准

1. 新人只看 `Documents/Guides/Test.md` 与 `Documents/Guides/TestConventions.md`，就能知道测试层级、命名规则、典型场景和标准执行入口。
2. `Tools/RunTestSuite.ps1` 可以作为固定 smoke / native / scenario 样本波次的统一入口。
3. ASSDK / Preprocessor 这几类最典型的命名异常已经得到修正，并且相关文档没有残留旧路径。
4. `Plugins/Angelscript/AGENTS.md` 明确了未来新增测试的落点与命名边界。


