## Why

现有 `test-as-script-corpus-and-functional-coverage` 把教学语料、脚本测试、驱动、函数库、代码生成和多个实验方向混在同一个计划中，无法为 `TestSource` 提供可审查、可追踪的手写源码中心。当前 change 已经详细整理了手写 Bind 与反射式 AngelScript 测试框架，却让 `TestSource` 看起来只有 `Bindings` 和 `TestFramework` 两个主题；语言、反射定义、容器、UE 方言、World、Gameplay、Optional、HotReload 和 Debugger 等现有测试范围没有获得相同深度的逐文件记录。

2026-08-21 的初次实现复审确认：614 个计划路径和符号已经全部落盘，但当时 576 个 Bind 文件中的 2,420 个 `Observe_*` 全部是无参数 `void` 函数。随后的源码整改已经消除丢失 oracle、丢弃局部值、恒真式和 permissive-null 结构问题；当前复查为 571 个 `StructurallyComplete`、5 个 `UnsafeForDefaultExecution`，TestFramework 38 个仍为 provisional。结构检查通过仍不等于人工语义验收、编译、执行或外部 oracle 通过，因此当前 accepted 仍为 0。

## What Changes

- 建立核心手写 Bind 的完整清单：204 个物理分片归并为 127 个逻辑 Bind 单元。
- 从当前 Bind 源码中的 AS-facing 使用表和补充注册中登记 3,015 条脚本表面，并记录返回类型、参数模式、环境、源码位置和未来任务。
- 建立当前 C++ 测试参考表，引用精确路径、`TEST_CLASS` 和 `TEST_METHOD`；无代表性现有测试时显式记录 `NoCurrentTest`，不制造证据。
- 规划 `TestSource/Bindings/<LogicalBindName>/Test_<ScenarioFamily>_<Part>.as`，每个文件只承担一个语义场景家族。
- 规划独立的 `TestSource/TestFramework/` 自测体系，覆盖 Discovery、Assertions、Lifecycle、Commands、World、Automation、HotReload 和 SelfHosted。
- 将 `Bindings` 和 `TestFramework` 明确为 TestSource 的两个正式一级主题，而不是整个 TestSource 的全部范围。
- 增加 `Language`、`Definitions`、`Containers`、`Feature`、`World`、`Gameplay`、`Optional`、根级 `HotReload` 和 `Debugger` 主题注册表、当前证据清单及逐 `.as` 任务。
- 把 `TestSource` 确立为可复用手写 AS 测试源码的唯一真源；插件 Fixtures、runner 内联字符串和 release 文件是后续消费结果。
- 对核心、GameplayTags 和 GAS 测试模块中的每个当前 `TEST_METHOD`、每个候选 raw-string AS block 及 `Script/**/*.as` 建立稳定 ReferenceId 和明确 disposition。
- 使用“路径 + `TEST_CLASS` + `TEST_METHOD` + block ordinal + 起始行 + SHA-256”作为脚本参考点，并记录声明符号与 C++ oracle hint，避免只靠目录名或易漂移行号。
- 将 Native AngelScript SDK 作为 `Language` 的参考证据而不是独立 TestSource 主题；同质表达式、定义组合和随机程序明确路由到独立生成 OpenSpec。
- 将 Cache、StaticJIT、RuntimeJIT、Core、Dump 等宿主测试显式标记为 `HostOnly` 或提取到语义主题，禁止按 C++ 目录机械创建虚假 AS 主题。
- 要求每个非 void 调用消费返回值，每个 void 调用观察副作用，每个 out/inout、引用返回和对象句柄验证其特殊语义。
- 要求未来 AS 源码使用英文知识型注释解释测试目的、输入、输出、边界、生命周期和诊断，但不强制固定元数据模板。
- 记录 2026-08-21 初次实现复审：保留 614/614 路径与符号的结构成果；当时 576/576 Bind 文件因 observation contract 不足而被阻断，38/38 TestFramework 文件被判定为等待 C++ 外部 oracle 的 provisional 状态；后续 current recheck 必须覆盖而不是抹除该历史结论。
- 记录整改后的 current recheck：2,420 个 Bind `Observe_*` 全部具有非 void 结果，571 个文件自动结构检查无剩余 issue，5 个高影响宿主文件仍需隔离策略；不把自动结构检查升级为人工语义接受。
- 为每个计划 callable 增加 runner 可读的观察通道、fixture/setup/cleanup 所有权、执行安全策略和外部 oracle 准入条件；局部 bool、恒真式、日志或 `void` 成功返回均不算测试结果。
- 在原逐文件任务之前增加复审整改 gate，并用逐文件 review CSV 记录问题编号与所需动作；所有原任务继续保持未勾选。
- 当前复审只修改本 OpenSpec 和审计产物，不直接重写 `TestSource/**`，不进行编译或运行。
- 当前主题扩展同样只修改本 OpenSpec；新增主题源码仍保持未落盘、未编译、未执行状态。
- 代码生成器、AS 到 C++ 内联导出、编译/运行驱动和插件 release 产物由后续独立 OpenSpec 处理。
- 不修改或归档旧 `test-as-script-corpus-and-functional-coverage`，只将其视为非权威研究输入。

## Capabilities

### New Capabilities

- `as-manual-bind-source-coverage`: 定义 TestSource 对核心手写 Bind 和 Runtime AS 测试框架的逐表面、逐源码文件覆盖与追踪合同。
- `as-test-source-theme-coverage`: 定义 TestSource 全主题、唯一真源、当前测试证据 disposition 和逐手写源码任务合同。

### Modified Capabilities

- None.

## Impact

- 当前实现已经包含 `TestSource/Bindings/**`、`TestSource/TestFramework/**` 和 `TestSource/README.md`；本轮不修改它们，只把接受状态、缺失主题和未来逐文件任务记录到 `openspec/changes/test-as-manual-bind-source-coverage/**`。
- 614 个现有 `.as` 文件目前只是结构落盘：Bind 层 0/576 被语义接受，TestFramework 层 0/38 被外部 oracle 接受。
- 全主题扫描为缺失主题规划 2,427 个新的手写 `.as` 路径；它们全部处于 `PlannedNotMaterialized`，与 614 个现有路径合计 3,041 个 TestSource 源码任务。
- 4,645 个真实测试方法、3,672 个 raw-string 候选和 651 个独立 `.as` 参考已获得稳定身份或 disposition；54 个生成器候选和 50 个 FMath blocked 参考不会伪装成手写任务。
- 当前不修改 Runtime 公共 API、UE 模块、插件源码、`Script/**`、测试 runner、构建脚本或发布内容。
- GameplayTags 和 GAS 进入 `Optional` 主题规划，但本轮不修改 optional plugin 源码；UHT 生成绑定、StaticJIT/AOT 实现和 Standalone 仍不在本变更内。
