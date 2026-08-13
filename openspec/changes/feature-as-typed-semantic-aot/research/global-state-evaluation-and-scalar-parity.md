# Typed Semantic AOT：全局状态、求值顺序与标量语义补充审计

## 结论

Typed Semantic AOT 的首期难点不是把 typed AST/HIR 打印成 C++，而是确保生成的
C++ 在以下边界仍然执行 maintained fork 的真实语义：

1. 调用的形式参数映射与实际求值顺序是两件事；当前 fork 的普通调用参数按形式
   参数倒序求值，不能写成“AngelScript 左到右”。
2. 可变全局变量不是一个可以直接内联的普通 symbol；它涉及模块存储、初始化顺序、
   hot reload 与稳定 relocation。
3. `import` 调用是可重新绑定的 slot，不是 resolved function id 指向的固定 callee。
4. C++ 的有符号溢出、移位、浮点转整数和函数参数求值不能直接充当 AS 语义。
5. 任意 direct/bridge call 即使不抛 C++ exception，也可能设置 script exception；调用者
   必须立刻停止后续副作用。

因此 v1 采用 fail-closed 策略：支持普通 receiver-free 标量函数，以及带可追溯来源的
primitive/enum pure constant；可变 global、global initializer、动态 imported route、
managed cleanup 与没有等价 conversion helper 的非便携转换全部 typed fallback。这个
边界不妨碍后续扩展，因为 HIR 现在就保留完整语义和 dependency provenance。

## 1. 当前 fork 的实际调用求值顺序

### 1.1 源码证据

`ThirdParty/angelscript/source/as_compiler.cpp` 中：

- `asCCompiler::CompileArgumentList()` 明确写着
  `Compile the arguments in reverse order`，并从 `node->lastChild` 向前编译；
- `CompileDefaultAndNamedArgs()` 对缺省参数也从最后一个 formal 向第零个 formal 编译；
- `PrepareFunctionCall()`/`MoveArgsToStack()` 按 VM stack 规则整理已经编译的参数；
- `MakeFunctionCall()` 会先准备参数，再把某些 method/object bytecode 接回调用序列，
  所以 receiver 不能一律假设在所有参数之前求值；
- `CompileAssignment()` 先编译 RHS，再编译 LHS；compound assignment 的 math/bitwise
  路径也保留 RHS-first 语义，而普通 eager binary expression 通常是 LHS-first。

`AngelscriptNativeEagerExpressionOrderTests.cpp` 已经是运行时 oracle。其
`UsesReverseEagerOperandOrder()` 对以下组合返回 true：

- call arguments；
- constructor arguments；
- index arguments；
- call chain；
- member/index chain。

该测试还覆盖 2、3、8 个 operand，以及第一个、中间、最后一个 operand 抛出 script
exception 的情况。Typed AOT 不应重新发明测试语义，应直接复用这套矩阵。

### 1.2 HIR 必须分开的三种顺序

Resolved-call HIR 不能只保存一个 `arguments[]`：

| 信息 | 含义 | 示例 |
|---|---|---|
| source role/order | 用户写出的 receiver、positional/named argument 及源码身份 | `F(A(), C: C())` |
| formal binding | overload/default/mixin/hidden rewrite 后，每个 formal 实际绑定哪个 expression | formal 0→A，1→default B，2→C |
| evaluation sequence | maintained compiler 最终执行 receiver/default/argument expression 的次序 | C、default B、A、receiver（视 call shape） |

推荐 call node 字段：

```text
ResolvedCall
  ResolvedTargetKind
  ResolvedTargetCoordinate
  ReceiverExpression?
  FormalArguments[]
    FormalIndex
    Expression
    Origin = SourcePositional|SourceNamed|Default|Hidden|MixinReceiver|AbiOnly
    SourceOrdinal?
    DefaultDeclarationOrigin?
  EvaluationSequence[]
    Role = Receiver|Argument|Hidden
    FormalIndex?
    Expression
  ResultType
  ProcessedSpan
```

Verifier 至少保证：formal index 唯一且完整；每个 effectful receiver/argument expression
在 evaluation sequence 中恰好出现一次；sequence 不引用 dangling expression；
`Default` 保留 callee declaration/parameter origin；mixin receiver 与 formal 0 映射一致。

### 1.3 C++ lowering 规则

不能生成：

```cpp
return Target(E0(), E1(), E2());
```

这会依赖 C++ 函数参数求值顺序，也无法在中间 script exception 后停止。必须按 HIR
evaluation sequence 生成独立 statement/temp，再按 formal order 组装调用：

```cpp
const int32 Eval2 = E2();
if (Execution.bExceptionThrown) return {};
const int32 Eval1 = E1();
if (Execution.bExceptionThrown) return {};
const int32 Eval0 = E0();
if (Execution.bExceptionThrown) return {};
const int32 Result = Target(Eval0, Eval1, Eval2);
if (Execution.bExceptionThrown) return {};
return Result;
```

Direct script、exported native、inline、Runtime thunk 和 scalar bridge 都必须消费同一个
pre-call materialization plan，不能各自决定顺序。

## 2. named/default/hidden 参数

`CompileDefaultAndNamedArgs()` 在 caller 编译期间重新解析 callee 保存的 default expression：

- 用临时 `asCScriptCode` 编译 default text；
- 使用 callsite 的 script section/line offset 产生诊断；
- 临时切换到 callee namespace 解析名字；
- 最终仍按 formal 倒序插入缺失/default argument。

所以 default expression 至少有两个 provenance：

1. 语义来源是 callee declaration + parameter index + canonical default text；
2. 本次实例化/诊断位置是 caller processed source span。

Cache V2 已经把 `CanonicalDefaultExpression` 写入 declaration signature hash；函数调用的
artifact dependency 也已包含 `Signature`。Semantic AOT 应消费并交叉核对这条权威依赖，
不再建立第二套 default-argument invalidation 算法。现有 hot-reload classification 测试也
已将 default argument change 归类为需要 full reload 的变更。

## 3. 全局变量与初始化

### 3.1 为什么 global initializer 不是普通函数

`asCBuilder::CompileGlobalVariables()` 单独管理全局初始化：

- 先 primitive、后 non-primitive；
- 每个 global 临时创建匿名 `asCScriptFunction`；
- 通过 `CompileGlobalVariable()` 编译 initializer；
- 最后建立 module init order。

这些匿名函数当前没有完整的 build-artifact invocation kind、UFUNCTION root、稳定函数
identity 或 provider publication contract。把它们顺便当成 Semantic helper 会漏掉初始化
顺序、销毁、模块重载和失败回滚。

### 3.2 v1 支持边界

| global use | v1 处理 | 原因 |
|---|---|---|
| primitive/enum `isPureConstant`，编译器已经折叠 | 可支持，但 HIR 必须保留 `FoldedGlobalConstant` origin，且 artifact 必须声明 `HardValue` dependency | 常量值改变必须使产物失效 |
| mutable primitive global read/write | `UnsupportedGlobalStorage` fallback | 需要稳定 storage relocation、模块生命周期与 hot reload route |
| object/container/handle global | `UnsupportedGlobalStorage` 或更具体 lifetime fallback | 涉及构造、GC、析构和 alias |
| global initializer body | `UnsupportedGlobalInitializer` | 尚无稳定 invocation identity/init-order provider contract |
| generated asset/singleton cache global | 按真实 receiver/global/storage 语义 fallback | generated naming 不是安全证明 |

折叠常量不能退化成一个无来源 literal。HIR 记录 engine-local global coordinate；Runtime
analyzer 在当前 engine 内把它映射到现有 Cache V2 stable key、ExpectedAbi 与 hard-value
fingerprint。HIR 本身不持久化这些 pointer/ID。

### 3.3 复用已有依赖权威

maintained compiler 已捕获：

- type declaration/value layout；
- object property layout；
- function signature 与 hard-content；
- mutable global 的 `GlobalStorage`；
- pure constant global 的 `HardValue`。

Semantic analyzer 需要产生 `SemanticUseManifest`，再与
`ScriptFunctionData::artifactDependencies` 做覆盖核对：

- 每个 HIR semantic use 必须存在兼容的权威 compiler dependency；
- compiler 多捕获的依赖继续保留，不能因 HIR 没有直接 node 就丢弃；
- 缺失、kind 不兼容、stable mapping 失败时返回 `SemanticDependencyMismatch`；
- 不允许用 bytecode reference scan 补洞。

这不是让 Semantic emitter 依赖 bytecode，而是复用 frontend 同次编译已经产生的语义依赖。

## 4. imported、shared 与 external

### 4.1 imported function 是动态 binding slot

编译器对 `asFUNC_IMPORTED` 生成 `asBC_CALLBND`。`sBindInfo` 保存 imported signature、
`importFromModule` 和可变化的 `boundFunctionId`；`BindImportedFunction()` 可以重新绑定，
`UnbindImportedFunction()` 可以使其变为 unbound。

因此 HIR 的 resolved target 必须区分：

- concrete script function；
- imported binding slot；
- interface/virtual route；
- system/native function。

Imported node 保存 source module + canonical signature + engine-local binding-slot coordinate，
不能把当前 `boundFunctionId` 固化成 direct helper。v1 只有 provider/current-function bridge
能够证明“每次调用读取当前 binding”时才可支持，否则 `UnsupportedImportedRoute` fallback。

### 4.2 shared/external body ownership

`shared` function/type 可能复用 engine 中已有 identity；`external` 要求找到已有 shared
declaration/body，本模块未必拥有可发射 body。Semantic closure planner 必须把
`body owner`、`declaration owner` 和 `calling module` 分开：

- 当前 module 不因为看见 declaration 就拥有 body emission 权；
- 复用 shared body 时使用稳定 declaration/content identity；
- provider 刷新由 body owner 发布，consumer 仅保存 stable reference/route；
- body 缺失或 owner 不确定时 typed fallback，不复制或猜测 body。

## 5. source provenance

Preprocessor 会重写源码并生成 asset/singleton 等辅助声明。HIR 的最小权威 span 是 compiler
实际消费的 processed section/offset/length；不能把 processed offset 假装成 authored file
offset。推荐来源结构：

```text
ProcessedSpan                 // 必有，compiler authoritative
AuthoredOrigin?               // 只有 preprocessor 有可靠映射时才有
GeneratedOrigin?
  Kind
  GeneratorName
  AuthoredAnchor?
```

诊断选择顺序为 authored origin（若精确）→ generated anchor → processed span。任何缺失映射
只影响显示质量，不能改变语义 identity、eligibility 或 bytecode。

## 6. 标量 C++ 语义需要显式 helper

### 6.1 整数与移位

- signed add/sub/mul 必须在对应宽度的 unsigned bit domain 中运算，再按位解释/收窄；
  不能触发 C++ signed-overflow UB。
- signed division/mod 在执行运算前检查除零，以及 `INT_MIN / -1` overflow。
- shift count 对 32/64 位分别显式 `& 31` / `& 63`。现有 native operator tests 已把
  `-1` 等 invalid count 的 masked behavior 固化为当前 fork oracle。
- logical right shift 使用 unsigned bit pattern。
- arithmetic right shift显式构造 sign fill，不能依赖 signed `>>` 的 implementation-defined
  行为。
- bool 输出规范化为 `0` 或 `VALUE_OF_BOOLEAN_TRUE`。

测试矩阵至少包含 count `-1, 0, width-1, width, width+1, large`，32/64 位、负数、
最高位、compound assignment，以及 exception 后不继续执行。

### 6.2 float/double 转整数

现有 numeric boundary tests 已覆盖 signed zero、subnormal、infinity、NaN 和超界；另一些
conversion tests 明确把 exact result 标为 current-fork nonportable。Legacy helper 当前依赖
C++ cast 与特定工具链行为。

首期可选策略：

1. 优先抽出/复用一个 Runtime scalar-conversion helper，让 VM/Legacy/Semantic 在支持的 UE
   toolchain 上调用同一实现；
2. 在 helper 尚未形式化 nonfinite/out-of-range 规则前，将这些动态转换标为
   `NonPortableNumericConversion`，或仅在严格 toolchain fingerprint + differential gate 下支持；
3. 禁止 emitter 内散落 `static_cast<int32>(FloatExpr)` 并声称跨平台等价。

## 7. exception、cleanup 与 suspension

第一标量 slice 没有 managed temporary/destructor，但每个 call plan 仍应明确：

```text
CannotSetScriptException
MaySetScriptException
MaySuspend
RequiresCleanup
```

- `MaySuspend`、`RequiresCleanup` 在 v1 fallback；
- `MaySetScriptException` 在 direct/bridge call 返回后立即检查
  `Execution.bExceptionThrown`；
- check 必须位于下一个 operand/side effect 之前；
- 返回沿用现有 VM/raw/parameter entry 的空/default return contract，并保留 failing
  source site 与 call stack；
- `noexcept` 只描述 C++ exception，不代表不会设置 AngelScript exception；UE 通常禁用
  C++ exceptions，不能用 throw/catch 实现脚本错误。

未来支持 managed object 时，必须先把 Legacy
`FStaticJITContext::ExceptionCleanupAndReturn()` 的 live-object/bytecode metadata 能力替换成
HIR-owned lifetime/cleanup regions；不能在没有该模型时扩大 eligibility。

## 8. 可提前执行的验证

本 change 的 `research/fixtures/semantic-aot-v1/` 增加两类 call vector：

- valid reverse-evaluation call：formal binding 为 `0,1,2`，evaluation sequence 为
  `2,1,0`，golden C++ 必须先 materialize `2,1,0` 再以 `0,1,2` 调用；
- invalid duplicate evaluation：同一个 argument 在 sequence 出现两次，validator 必须以
  `InvalidCallEvaluationSequence` 拒绝。

`research/patches/evaluation-order-and-scalar-parity-test-first-patch.md` 给出生产测试文件、
用例矩阵和 helper patch 顺序。这些附件不修改 Runtime，也不与正在进行的 provider 架构
工作建立临时 API。

`research/probes/Test-SemanticDependencyContract.ps1` 另外使用虚拟 stable key 验证
semantic-use reconciliation：folded constant 必须匹配 `HardValue`，mutable global 匹配
`GlobalStorage` 但仍被 v1 eligibility 拒绝，额外 compiler dependency 被保留，imported slot
的 signature coverage 与 current-binding route 分开判断，shared/external declaration visibility
不等于 body ownership。

## 9. 后续实现检查表

1. 先让 existing eager-expression-order/operator/conversion tests 成为 Semantic differential
   oracle，不复制一套宽松期望。
2. HIR verifier 先检查 formal/evaluation/provenance，再进入 eligibility。
3. dependency reconciliation 发生在 emission 之前；失败不生成 partial C++。
4. 所有 call form 使用同一 materialization + exception-check plan。
5. v1 只开放 folded primitive/enum pure constant；mutable global 与 initializer 保持 fallback。
6. imported call 只有 current-binding route 可证明时才开放。
7. source diagnostic 同时保存 processed authority 与可选 authored/generated provenance。
8. provider identity、reference slot、publication、refresh 仍由
   `refactor-as-static-jit-multi-provider` 提供，本 change 不复制。
