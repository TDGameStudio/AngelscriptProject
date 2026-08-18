# Task 2.10 — `external_implicit_this` 真实编译器闭环

日期：2026-08-16

## 结论

Task 2.10 已通过真实 maintained compiler source、字节码、运行时和 HIR
验证闭环。`external_implicit_this` 仍然是全局函数；声明参数 0 不会从
AS ABI、VM 参数或符号表中消失，只在 HIR header 中额外作为
`ExternalImplicitThis` receiver alias。显式 `this`、未限定字段、兼容
property accessor 和未限定方法都携带指向该参数符号的 receiver expression。

这次实现没有改变 parser、overload selection、bytecode emission、VM null
exception 或调用约定。新增信息是 compiler-owned sidecar HIR；capture off/on
在只归一化 documented Engine-local pointer operands 后保持相同字节码，并且
运行结果相同。

## 生产实现

### HIR model

`asSTypedSemanticExpression` 新增独立的 `receiverExpression`。receiver 不混入
普通 formal operands，因而不会把 external receiver parameter 0 擅自删除、
重排或重复成 source argument。

verifier 要求：

- receiver 必须指向当前表达式之前已经发布的 expression；
- 只有 `ResolvedCall` 可以携带 dedicated receiver；
- global/static call 不得伪造 receiver；
- instance target 没有 receiver 时 fail closed，不发布损坏 HIR。

normalized dump 只在 receiver 有效时输出 `receiver=E#`，既有 global-call
golden text 不被无意义的 `receiver=none` 扰动。

### Compiler capture

`as_compiler.cpp` 的最小变更为：

- parameter declaration 完成后验证 external receiver；缺参数 0 或参数 0
  非对象类型时保留成功 bytecode/frontend policy，但 HIR transaction 以稳定
  `InvalidEffectiveReceiver` 诊断丢弃；
- 将原只接收 global call 的 capture helper 泛化为 resolved call，并接收独立
  receiver expression；
- implicit method call、explicit/effective receiver 和 property-accessor get 在
  现有 `MakeFunctionCall` 前后保存 receiver，再写入最终 resolved-call HIR；
- formal operands 和 evaluation sequence 仍只描述声明参数，receiver 继续是
  独立位置。

## 测试分区

测试没有继续堆到根目录单文件，而是按场景放在：

`AngelScriptSDK/Compiler/TypedSemanticIR/ExternalImplicitThis/`

- `AngelscriptNativeTypedSemanticIRExternalImplicitThisBodyTests.cpp`：有效 value
  receiver、显式 `this`、字段、accessor、method、parameter/local shadowing；
- `AngelscriptNativeTypedSemanticIRExternalImplicitThisNullTests.cpp`：class handle
  null exception 与 capture bytecode parity；
- `AngelscriptNativeTypedSemanticIRExternalImplicitThisMalformedTests.cpp`：缺参数
  和 primitive parameter 0 的 fail-closed publication；
- `AngelscriptNativeTypedSemanticIRExternalImplicitThisTestSupport.h`：仅共享精确
  function lookup、运行 observation、receiver-chain 检查以及 pointer-aware
  bytecode normalization/debug dump。

有效 body 的 VM 结果固定为 `108`，同时证明：

- public parameter count 是 3；
- function object type 仍为空，即调用形态仍是 global；
- header receiver symbol 就是声明名为 `Self` 的 parameter 0；
- 同名参数 `RawValue` 优先于 receiver field；
- `LocalShadow` 保持普通 local；
- accessor 和 method resolved call 都有独立 receiver expression；
- capture off/on 的规范化字节码与 VM 结果一致。

## 调试中发现并保留的边界

### 已移除的 script `property` decorator

最初测试错误地写了 `int get_PropertyValue() const property`。maintained fork
已经永久移除该 decorator，因此 RED 首先是合法的 frontend rejection，而不是
HIR failure。最终测试没有恢复旧语法；它显式把两个裸 SDK Engine 的
`asEP_PROPERTY_ACCESSOR_MODE` 设置为 `2`，以 `int GetPropertyValue() const`
覆盖 compiler 中仍维护的 accessor selection/call path。默认 mode 3 下的旧
decorator rejection 仍由既有 property tests 保持。

### class handle 不能再写 `&`

最初 null fixture 使用 `FExternalNullCarrier& Self`。该 class 已是 implicit
handle，再加 `&` 表示对 handle storage 的引用；external receiver 读取的是非空
slot address，而不是 slot 中的 null object，因而正常返回 0。真实 generated
shape 与已有 probe 都是 `FExternalNullCarrier Self`。改为 handle-by-value 后，
`this.Value` 继续走现有 `LoadThisR`/`RDR4` VM null boundary，两边都产生
`asEXECUTION_EXCEPTION` 和精确 `Null pointer access`。

### 跨 Engine 原始 pointer word 不可直接比较

两个独立 Engine 的 opcode 完全相同；唯一原始 word 差异来自 `FREE` 内嵌的
Engine-local type pointer：

```text
off: FREE[...,5f4ff900,...]
on : FREE[...,5f4ff000,...]
```

因此测试复用项目既有 capture-parity 规则，只归一化 documented
pointer-bearing opcodes 的 pointer words，仍逐字比较所有 opcode 与非指针
operand。该规则不会掩盖真实 VM body、stack offset 或 branch 变化。

## TDD 与验证证据

- feature-missing RED build：
  `Saved/Build/typed-semantic-task210-external-receiver-red/
  20260816_225001_959_9da79a9b/`；测试因 model 尚无
  `receiverExpression` 无法编译，证明 RED 命中新需求；
- production patch build：
  `Saved/Build/typed-semantic-task210-external-receiver-green-build/
  20260816_225413_859_21dc103d/` — PASS；
- fixture/root-cause RED：
  `Saved/Tests/typed-semantic-task210-external-receiver-focused/
  20260816_225453_001_24867736/` — `1/3 PASS`，暴露 removed decorator 和错误
  reference-to-handle shape；
- pointer-word diagnostic：
  `Saved/Tests/typed-semantic-task210-null-bytecode-diagnostic/
  20260816_230307_569_5ca11189/` — 唯一差异定位到 `FREE` 的 Engine-local
  pointer operand；
- 最终 affected build：
  `Saved/Build/typed-semantic-task210-external-receiver-green2/
  20260816_230502_198_442c1f34/` — PASS；
- 最终 focused：
  `Saved/Tests/typed-semantic-task210-external-receiver-green2/
  20260816_230522_312_bf7768c0/` — `3/3 PASS`，zero failed/skipped；
- 完整 compiler-HIR regression：
  `Saved/Tests/typed-semantic-task210-regression/
  20260816_230607_621_fb80272f/` — `44/44 PASS`，zero failed/skipped。

## 后续边界

Task 2.11 将单独处理 `mixin` receiver→formal 0 映射。它不能复用
external-implicit-this 的 invocation kind：external receiver 在被调用函数的
声明 ABI 中已经是 parameter 0，而 mixin 是 call-site method syntax 对普通
global formal 0 的显式映射。两者必须在 HIR 中保持可区分。
