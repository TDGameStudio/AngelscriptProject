# Task 2.13：Typed Semantic HIR 求值顺序闭环

## 结论

Task 2.13 以维护中的
`AngelScriptSDK/Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp`
为运行时 oracle，把编译器已经实际采用的 eager evaluation 顺序记录为可验证、
可 dump、可由 TypedASTJIT 消费的 HIR 数据。此次实现不改变 AngelScript
bytecode 或 VM 求值规则，只把原本隐含在 `asCCompiler` 临时 bytecode 拼接顺序中的
事实显式化。

最容易误判的规则是：普通 call、constructor、multi-argument `opIndex`、call
chain 和 member/index chain 的 eager operands 按最终 formal 参数的反向顺序执行，
不是按源码从左到右。普通 eager binary、assignment/compound-assignment 的 RHS
表达式和 nested casts 则保持从左到右的内部 operand 顺序。赋值节点自身明确记录
`MutationValue` 在 `MutationTarget` 之前；这不允许 consumer 根据 C++ 常见写法自行
猜测 target/value 顺序。

## 维护中 oracle

oracle 的 `UsesReverseEagerOperandOrder()` 明确列出以下五类反向求值组合：

| 组合 | 2 operands | 3 operands | 8 operands | HIR 结论 |
| --- | --- | --- | --- | --- |
| ordinary call arguments | `2,1` | `3,2,1` | `8..1` | reverse final formal order |
| constructor arguments | `2,1` | `3,2,1` | `8..1` | reverse final formal order |
| index arguments | `2,1` | `3,2,1` | `8..1` | reverse args, receiver last |
| call chain | `2,1` | `3,2,1` | `8..1` | nested receiver graph preserves oracle |
| member/index chain | `2,1` | `3,2,1` | `8..1` | nested receiver graph preserves oracle |

以下组合使用非反向的 eager operand 顺序：

| 组合 | 2 operands | 3 operands | 8 operands | HIR 结论 |
| --- | --- | --- | --- | --- |
| binary | `1,2` | `1,2,3` | `1..8` | binary child zero before child one |
| assignment RHS | `1,2` | `1,2,3` | `1..8` | RHS graph first, then mutation target/store |
| compound-assignment RHS | `1,2` | `1,2,3` | `1..8` | RHS graph first, target evaluated once |
| nested casts | `1,2` | `1,2,3` | `1..8` | each conversion consumes its one child |

测试通过 `Mark(N)` resolved calls 递归展开 HIR，而不是只比较新数组中的数字；因此
它同时证明 `evaluationSteps` 与实际 expression graph 指向同一批 operand，并复用
维护中 VM oracle 的 2/3/8 规模和顺序规则。

## HIR 模型

`asSTypedSemanticExpression` 新增两组事实：

- `sourceArgumentOrdinals`：与 call operands 平行，保存 operand 来自哪个显式源码
  argument；hidden/receiver-only operand 使用 `-1`；
- `evaluationSteps`：完整、权威的求值步骤序列，每一步包含 `role`、`expression`、
  `formalParameterIndex` 和 `sourceArgumentOrdinal`。

`asETypedSemanticEvaluationRole` 当前区分：

- `Operand`：普通 unary/conversion/binary child；
- `Receiver`：独立对象 receiver，或 mixin formal zero 的 receiver 角色；
- `Argument`：AS-visible argument；
- `HiddenArgument`：编译器/native ABI 注入的非源码 argument；
- `MutationValue`：assignment/compound-assignment RHS；
- `MutationTarget`：一次求值的写入目标。

旧的 `evaluationSequence` 暂时保留为 call operand 的兼容投影：它只回答每个 binding
的 evaluation rank，无法表示不属于 operand 数组的独立 instance receiver。完整
consumer 必须使用 `evaluationSteps`；不能再从 operand 数组、源码顺序或 C++ 参数
列表猜测执行顺序。

### Receiver 规则

- 普通全局 call 和 constructor 没有独立 source receiver；
- instance method、`opIndex` 和 object `opCall` 在反向 argument steps 之后追加一个
  `Receiver` step；这与维护中 `MakeFunctionCall()` 先准备 argument bytecode、再追加
  object bytecode 的顺序一致；
- mixin source receiver 已经映射为 effective formal zero，所以它作为 formal-zero
  operand 的 `Receiver` step 出现一次，不得再追加第二个 receiver step；
- receiver 的 HIR expression ID 必须与 `receiverExpression` 一致。

### Constructor 与 Unsupported 边界

当前 scalar TypedASTJIT 仍不宣称支持对象 construction/lifetime。编译器现在会先保存
已选择 constructor 的 `ResolvedCall`，再把它保留在
`Unsupported(ConstructionOrLifetime)` 节点下面。这样 HIR 可以回答 constructor
参数的真实 formal/evaluation 顺序，同时 eligibility 继续诚实 fallback。只有实际是
`ResolvedCall` 的 construction child 才会被 wrapper 保留，普通 object cast/conversion
不会被误标成 constructor call。

## Verifier 与 consumer

`VerifyTypedSemanticFunction()` 现在验证：

- source ordinal、formal binding 和 evaluation rank 在其有效域内唯一；
- call argument steps 与 operand、origin、formal、source ordinal 和兼容投影完全一致；
- independent receiver 只能是最后一个额外 step；
- binary 固定为 left/right 两个 `Operand` steps；
- conversion/unary 固定为一个 `Operand` step；
- assignment/compound 固定为 `MutationValue, MutationTarget`；
- increment/decrement 只记录一次 `MutationTarget`；
- short circuit 不伪装成 flat eager sequence；控制流仍由其结构化语义拥有；
- constructor wrapper 若保留 child，该 child 必须是 `ResolvedCall`。

deterministic dump 输出 source ordinals 和完整 steps。TypedASTJIT call-closure 从
`evaluationSteps` 追踪可达表达式，避免遗漏独立 receiver；emitter 按 step materialize
参数。当前 scalar emitter 遇到 formal `-1` 的独立 object receiver 仍明确 fail closed，
不会静默改变执行顺序或错误生成对象调用。

## 测试分区

新增测试按长期能力 ownership 分拆，没有继续扩充根级大文件：

- `EvaluationOrder/Calls/AngelscriptNativeTypedSemanticIROrdinaryCallOrderTests.cpp`
  — ordinary 2/3/8 call、source/formal/step uniqueness 及 verifier mutation negative；
- `EvaluationOrder/Calls/AngelscriptNativeTypedSemanticIRConstructorIndexOrderTests.cpp`
  — constructor 与 multi-argument `opIndex`；
- `EvaluationOrder/Chains/AngelscriptNativeTypedSemanticIRChainOrderTests.cpp`
  — call/member/index chain 与显式 receiver step；
- `EvaluationOrder/Expressions/AngelscriptNativeTypedSemanticIRExpressionOrderTests.cpp`
  — binary、assignment、compound assignment、nested cast；
- `EvaluationOrder/AngelscriptNativeTypedSemanticIREvaluationOrderTestSupport.h`
  — 只共享 HIR lookup、formal binding 和 marker-stage graph traversal，不拥有 Engine。

四个 `.cpp` 各只有一个 CQTest method，物理行数分别为 201、184、164、237；支持
header 为 246 行。没有文件接近 500 行 review trigger，也没有因为拆分而重复昂贵的
全局测试 Engine fixture；每个场景使用自己的 raw SDK Engine，保持隔离。

## TDD 与验证证据

### RED

正式 RED build：

`Saved/Build/typed-semantic-task213-evaluation-red/
20260817_003850_876_40f78841/Build.log`

测试在 production model 尚无 `evaluationSteps`、`sourceArgumentOrdinals` 和
`asETypedSemanticEvaluationRole` 时按预期无法编译。日志包含明确的 `C2039`/
`C2653` 失败，证明测试不是在旧模型上偶然通过。

同一次 adaptive non-unity build 还暴露了一个独立的历史 include/namespace leak：
`AngelscriptNativeExceptionRecoveryTests.cpp` 的 private static source builder 使用
`AppendGeneratedAsLine`，但没有在自己的 lexical scope 引入
`AngelscriptNativeTestSupport`；unity 编译时此前由其他 translation unit 偶然提供。
最小修复是在该 helper 内加入
`using AngelscriptNativeTestSupport::AppendGeneratedAsLine;`。没有改变异常测试行为，
只是让文件在 adaptive non-unity 下自包含。

### GREEN

- build：`Saved/Build/typed-semantic-task213-evaluation-green-build1/
  20260817_005137_850_5ce8a20f/` — PASS，30 actions；
- focused EvaluationOrder：`Saved/Tests/
  typed-semantic-task213-evaluation-focused1/
  20260817_005218_200_e8238afb/` — `4/4 PASS`；
- complete TypedSemanticIR：`Saved/Tests/typed-semantic-task213-full-hir1/
  20260817_005255_252_231d452a/` — `53/53 PASS`；
- TypedASTJIT eligibility + call closure：`Saved/Tests/
  typed-semantic-task213-eligibility-closure1/
  20260817_005343_275_d96c8eb5/` — `30/30 PASS`；
- TypedASTJIT generated output：`Saved/Tests/
  typed-semantic-task213-generated-output1/
  20260817_005419_007_62c8e372/` — `25/25 PASS`。

## 后续边界

Task 2.13 只冻结“哪个表达式何时求值”和 receiver 的明确位置。Task 2.14 仍负责把
named/default/hidden argument 的来源做成更完整的独立 provenance：尤其 default
argument 的 callee declaration、parameter、canonical expression、caller processed
span 和 Signature dependency 不能从本任务的 source ordinal 推断。Imported mutable
binding slot 与 shared/external body ownership 仍属于 task 2.16。
