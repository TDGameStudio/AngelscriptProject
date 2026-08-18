# Task 2.11 — `mixin` 调用语义闭环

日期：2026-08-16

## 结论

Task 2.11 已通过真实 maintained compiler source、VM 执行、HIR capture 和
verifier 负向篡改完成闭环。`Object.Mixin(...)` 仍由现有 overload selection
把 source receiver 插入最终实参数组的 formal 0；HIR 只在该权威改写完成后，
额外把同一个、已经存在的表达式 ID 记录为 dedicated receiver。它不会复制或
重新求值 receiver，也不会把 mixin 与 `external_implicit_this` 合并成同一种
receiver。

现有语言行为保持不变：mixin 只能通过 method syntax 调用，作为普通 global
free-call 仍以 `No matching signatures` 拒绝；打开 capture 不会发布失败函数或
partial HIR。

## 编译器和 verifier 的最小实现

`as_compiler.cpp` 在 `CompileFunctionCall()` 中继续以 maintained compiler 的
现有顺序执行：receiver 插入、overload selection、named/default argument
归位、`MakeFunctionCall()`。capture 不参与这些决定。调用已最终确定时：

- 普通实例调用继续从 `ctx->typedSemanticExpression` 记录独立 receiver；
- mixin 调用从最终 `args[0]->typedSemanticExpression` 记录 receiver；
- `AddResolvedCall()` 继续把最终 `args[]` 写成 effective formal mapping，并按
  `PrepareFunctionCall()` 的权威逆 formal 顺序记录 evaluation rank。

`VerifyTypedSemanticFunction()` 增加一个通用、窄的调用不变量：如果 dedicated
receiver 与某个 effective operand 使用同一个表达式 ID，则只能出现一次，且
该 operand 必须绑定 formal 0。实例方法的独立 receiver 不与 operands 重合，
所以不受此规则改变。测试把合法 mixin receiver 篡改为 formal 1 的表达式，
verifier 稳定返回 `InvalidCallEvaluationSequence`。

## 测试分区

测试没有继续堆入根目录或既有大文件，而是按能力归属放在：

`AngelScriptSDK/Compiler/TypedSemanticIR/Mixin/`

- `AngelscriptNativeTypedSemanticIRMixinCallTests.cpp`：真实 method syntax、
  capture-off/on VM parity、receiver 单次求值、mixin/external receiver 区分、
  named/default/formal 映射、逆 formal evaluation sequence 和 verifier 篡改；
- `AngelscriptNativeTypedSemanticIRMixinFreeCallTests.cpp`：capture-off/on 的
  现有 free-call rejection、精确诊断和零 partial publication；
- `AngelscriptNativeTypedSemanticIRMixinTestSupport.h`：只共享精确函数查找、
  resolved-call/formal 查询、字面量识别和执行 observation。

运行时 oracle 返回 `321120252`。其中 `321` 证明求值顺序是 named `C`、默认
`B`（无副作用）、named `A`、receiver；receiver count 为 1，argument count
为 2，mixin 结果为 252。HIR formal 绑定固定为 receiver→0、A→1、默认 B→2、
C→3，evaluation rank 固定为 3、2、1、0。

## 调试中暴露的 Adaptive Unity 隐式依赖

第一轮 RED build 没有到达新增测试。既有
`AngelscriptNativeFunctionDirectionDefaultTests.cpp` 调用
`AppendGeneratedAsLine` / `PrintGeneratedAsSource`，但没有直接 include 声明
它们的 `AngelscriptNativeLanguageCaseTestSupport.h`。旧 Unity composition
偶然从相邻 translation unit 泄漏了声明；新增测试改变 Adaptive Unity 分组后，
该文件以自己的真实 include graph 编译并产生 `C3861`。

修复只增加缺失的直接 include，不移动 helper、不改变测试行为。重新构建仅需
四个 action 并通过，证明根因是 include ownership，而不是 JIT 或引擎锁。

## TDD 与验证证据

- 无效 RED build（记录但不作为功能 RED）：
  `Saved/Build/typed-semantic-task211-mixin-red-build/
  20260816_232206_390_1fafc9e9/` — `DirectionDefaults` 的 Unity include leakage；
- include 根因修复后的 RED build：
  `Saved/Build/typed-semantic-task211-mixin-red-build2/
  20260816_232756_816_ec30c31f/` — PASS；
- 有效功能 RED：
  `Saved/Tests/typed-semantic-task211-mixin-red/
  20260816_232827_409_7c5cbfeb/` — `1/2 PASS`；free-call 已满足，method syntax
  唯一失败是缺少 dedicated source receiver；
- production GREEN build：
  `Saved/Build/typed-semantic-task211-mixin-green-build/
  20260816_233005_894_65dd7140/` — PASS；
- focused GREEN：
  `Saved/Tests/typed-semantic-task211-mixin-green/
  20260816_233019_313_eb823903/` — `2/2 PASS`，zero failed/skipped；
- 完整 compiler-HIR regression：
  `Saved/Tests/typed-semantic-task211-regression/
  20260816_233103_970_a4b191c8/` — `46/46 PASS`，zero failed/skipped。

## 后续边界

本任务没有抢先实现 task 2.12–2.14 的通用 source-role、hidden/default origin
或 native ABI rewrite 模型。当前 arrays 只记录编译器已经完成的 effective
formal mapping 与 evaluation rank；下一阶段将分别补最终 call rewrite、完整
source provenance 和 default-origin，而不是把它们隐式猜进 mixin 特例。
