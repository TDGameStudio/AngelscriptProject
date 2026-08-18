# Task 2.14：参数来源 provenance

## 结论

Typed Semantic HIR 现在把三类事实分开保存：

1. 调用者源码中写了什么：位置参数、具名参数及其 source ordinal/name；
2. 最终绑定到哪个 callee formal；
3. maintained compiler 实际采用什么求值顺序。

默认参数和 host-hidden 参数不再与源码可见参数合并成
`ScriptVisibleOrDefault`。它们保留被调用函数 ID、无默认值重复的完整声明、
正式参数下标/名称、编译器已经规范化的默认表达式，以及调用者 processed
call-site span。该 span 明确不是 callee declaration span，也不冒充 authored
source provenance。

## 权威路径

- `CompileArgumentList()` 已经按 maintained runtime 语义逆序编译源码参数，
  并保留 `asSNamedArgument::name`；本任务只在现有 `asCExprContext` sidecar 中
  附加 `SourcePositional` / `SourceNamed` provenance，不影响 bytecode。
- `CompileDefaultAndNamedArgs()` 是默认/hidden 表达式唯一编译权威。它直接消费
  `asCScriptFunction::defaultArgs[n]` 或 `hiddenArgumentDefault`，因此 HIR 复制的
  `canonicalExpression` 与编译器、Cache V2 使用的是同一份 canonical token text。
- `AddResolvedCall()` 在 overload、conversion、named/default placement 全部完成后
  才把 sidecar 投影到最终 formal binding，并继续由 task 2.13 的
  `evaluationSteps` 表达独立执行顺序。
- `asCBuilder::MarkDependency(asCScriptFunction*)` 已为调用者记录
  `asBUILD_ARTIFACT_DEPENDENCY_SIGNATURE`；Cache V2 codec 将其映射为 `Signature`。
  HIR provenance 只负责解释，不创建第二条 invalidation edge。

## 模型与 verifier

新增 `asSTypedSemanticArgumentProvenance`，包含：

- `origin`；
- `sourceArgumentOrdinal` / `sourceArgumentName`；
- `processedSpan`；
- `calleeFunctionId` / `calleeDeclaration`；
- `calleeParameterIndex` / `calleeParameterName`；
- `canonicalExpression`。

`argumentOrigins` 和 `sourceArgumentOrdinals` 暂时保留为兼容投影；
`argumentProvenance` 是来源权威。`InvalidArgumentProvenance` 会拒绝：

- provenance 与兼容投影不一致；
- 没有有效 processed span；
- named 参数缺少写出的名称；
- source 参数携带 callee-default 元数据；
- default/hidden 缺少精确 target/formal/canonical expression；
- receiver 与其 formal-zero operand 或来源记录不一致。

normalized dump 会同时显示 `origins`、完整 `provenance` 和 `steps`，因此读者
无需从求值序列反推来源。

## 测试分区

compiler capture 测试位于
`AngelScriptSDK/Compiler/TypedSemanticIR/ArgumentOrigins/`：

- `AngelscriptNativeTypedSemanticIRExplicitArgumentOriginTests.cpp`：位置与具名参数；
- `AngelscriptNativeTypedSemanticIRDefaultArgumentOriginTests.cpp`：默认来源、
  canonical text、call-site span 和唯一 Signature dependency；
- `AngelscriptNativeTypedSemanticIRArgumentOriginTestSupport.h`：只共享 call/formal、
  span 和 dependency 查询。

host-hidden 用例继续由相邻的 `CallMetadata/HiddenArgumentTests.cpp` 所有，避免同一
行为在两个目录重复建 Engine。TypedASTJIT synthetic consumer fixtures只补齐新的
已验证 HIR 形状，仍留在 Eligibility、CallClosure、GeneratedOutput 各自 owner。

## RED / 调试 / GREEN 证据

- RED build：
  `Saved/Build/typed-semantic-task214-argument-origin-red/
  20260817_010502_385_3fcc3bbf/`，预期因为新 enum、provenance struct/field 和
  verifier code 尚不存在而编译失败。
- 第一次 full HIR：
  `Saved/Tests/typed-semantic-task214-full-hir1/
  20260817_011604_531_ebc0b56f/`，`54/55`。唯一失败是既有 mixin 负例固定期待
  `InvalidCallEvaluationSequence`；新 verifier 更早、更精确地返回
  `InvalidArgumentProvenance`。负例仍要求 fail-closed，只同步诊断类别。
- 最终 build：
  `Saved/Build/typed-semantic-task214-argument-origin-green-build2/
  20260817_011658_948_e5d93963/`，PASS。
- 新参数来源 focused：
  `Saved/Tests/typed-semantic-task214-argument-origin-focused1/
  20260817_011453_058_9fb0835e/`，`2/2 PASS`。
- hidden exact：
  `Saved/Tests/typed-semantic-task214-hidden-argument1/
  20260817_011530_573_e5960dc2/`，`1/1 PASS`。
- 完整 TypedSemanticIR：
  `Saved/Tests/typed-semantic-task214-full-hir2/
  20260817_011715_391_0e422c01/`，`55/55 PASS`。
- 默认参数 Hot Reload exact：
  `Saved/Tests/typed-semantic-task214-default-hot-reload1/
  20260817_011758_835_b311feb4/`，`1/1 PASS`。
- Eligibility + CallClosure：
  `Saved/Tests/typed-semantic-task214-eligibility-closure1/
  20260817_011848_305_c43d7992/`，`30/30 PASS`。
- GeneratedOutput：
  `Saved/Tests/typed-semantic-task214-generated-output1/
  20260817_011924_934_d6d35524/`，`25/25 PASS`。

本任务没有需要新增外部 reference 的语义缺口；maintained fork 的
`CompileArgumentList()`、`CompileDefaultAndNamedArgs()`、`defaultArgs` 和 artifact
dependency 实现已经给出完整权威。
