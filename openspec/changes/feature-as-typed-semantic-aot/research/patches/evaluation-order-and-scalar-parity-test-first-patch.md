# Test-first patch：call evaluation、exception boundary 与 scalar parity

## 状态

这是后续 production implementation 可直接照着落地的 patch recipe；当前只把研究夹具和
验证器放入 OpenSpec，不修改正在并行重构的 Runtime/provider。实现时先落测试，确认 VM
oracle，再写 HIR/emitter helper。

## Patch A：HIR call contract

目标文件：

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`

### 先加失败测试

用一个 side-effect trace helper 捕获：

```angelscript
int Trace = 0;

int Step(int Id)
{
    Trace = Trace * 10 + Id;
    return Id;
}

int Collect(int A, int B, int C)
{
    return A * 100 + B * 10 + C;
}

int Entry()
{
    int Value = Collect(Step(1), Step(2), Step(3));
    return Trace * 1000 + Value;
}
```

当前 fork 的 VM oracle 是 `Trace == 321`、`Value == 123`。HIR 断言：

```text
formal[0] -> Step(1)
formal[1] -> Step(2)
formal[2] -> Step(3)
evaluation -> formal[2], formal[1], formal[0]
```

再增加 table cases：

| case | 必须断言 |
|---|---|
| positional 2/3/8 args | evaluation 为 reverse formal order |
| named args | source ordinal 与 formal index 分离 |
| missing/default args | origin=Default，保留 callee parameter 与 caller span |
| mixin method syntax | receiver 只出现一次并映射 formal 0 |
| instance method | receiver 在 sequence 中有显式位置 |
| constructor/index/call chain | 与 `AngelscriptNativeEagerExpressionOrderTests` 一致 |
| assignment | RHS 在 LHS 之前 |
| compound assignment | RHS-first，目标地址只求值一次 |
| ordinary binary | 采用该 operator 的 authoritative order，不套用 call 规则 |

Verifier negative cases：

- duplicate formal index；
- missing formal binding；
- dangling argument expression；
- evaluation sequence 缺少 effectful input；
- 同一 input 出现两次；
- receiver/formal-zero mapping 不一致；
- default origin 缺少 callee parameter；
- imported target 被错误标为 concrete body。

稳定错误码优先为：

```text
DuplicateFormalArgument
MissingFormalArgument
DanglingExpressionId
InvalidCallEvaluationSequence
InvalidDefaultArgumentOrigin
InvalidImportedTarget
```

### 最小 production 数据结构

```cpp
enum class asETypedSemanticCallInputOrigin : asBYTE
{
    SourcePositional,
    SourceNamed,
    Default,
    Hidden,
    MixinReceiver,
    AbiOnly,
};

struct asSTypedSemanticFormalArgument
{
    asUINT formalIndex;
    asTypedSemanticExpressionId expression;
    asETypedSemanticCallInputOrigin origin;
    int sourceOrdinal;
    int defaultParameterIndex;
    asSTypedSemanticSourceOrigin defaultDeclarationOrigin;
};

enum class asETypedSemanticEvaluationRole : asBYTE
{
    Receiver,
    Argument,
    Hidden,
};

struct asSTypedSemanticEvaluationStep
{
    asETypedSemanticEvaluationRole role;
    int formalIndex;
    asTypedSemanticExpressionId expression;
};
```

`asSTypedSemanticExpression::ResolvedCall` 保存 target kind/coordinate、可选 receiver、
formal arguments 与 evaluation steps。不要把 `operands[]` 顺序复用成这三种不同含义。

Capture 点必须在 overload、mixin、named/default/hidden、compile-out 和 determines-output
rewrite 全部完成之后。可以在 `CompileArgumentList()` 创建 expression context identity，但
只有 final call builder 才发布 formal/evaluation mapping。

## Patch B：generated C++ materialization

目标文件：

- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptSemanticAOTGeneratedOutputTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITNativeBridgeTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTCallPlan.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTCallPlan.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/SemanticAOT/AngelscriptSemanticAOTEmitter.cpp`

### Golden 先失败

给上面的三参数调用断言生成文本的相对顺序：

```cpp
const int32 EvalFormal2 = Step(int32(3));
if (Execution.bExceptionThrown) return {};
const int32 EvalFormal1 = Step(int32(2));
if (Execution.bExceptionThrown) return {};
const int32 EvalFormal0 = Step(int32(1));
if (Execution.bExceptionThrown) return {};
const int32 Result = Collect(EvalFormal0, EvalFormal1, EvalFormal2);
if (Execution.bExceptionThrown) return {};
```

断言 target invocation 中没有 `Step(`，以防 emitter 看似建立 temp、实际又把 expression
内联求值一次。DirectScript、DirectExported、DirectInline、RuntimeThunk、Bridge 各跑同一
测试，只允许最后一行的 invocation spelling 不同。

### Exception suppression 测试

脚本 helper：

```angelscript
int Trace = 0;

int StepOrFail(int Id, int FailAt)
{
    Trace = Trace * 10 + Id;
    if (Id == FailAt)
        throw("stop");
    return Id;
}
```

对 3-argument reverse order 验证：

| FailAt | trace | 不允许发生 |
|---|---:|---|
| 3 | 3 | Step(2)、Step(1)、target body |
| 2 | 32 | Step(1)、target body |
| 1 | 321 | target body |
| none | 321 | 无 |

比较 VM、Legacy、Semantic 的 return/default-return、`bExceptionThrown`、exception text、
trace、target-entry counter 与 callstack top。不能只比较 exception flag。

### 最小 call plan

```cpp
enum class EAngelscriptSemanticCallExceptionBehavior : uint8
{
    CannotSetScriptException,
    MaySetScriptException,
    MaySuspend,
    RequiresCleanup,
};

struct FAngelscriptSemanticMaterializedInput
{
    int32 EvaluationOrdinal = INDEX_NONE;
    int32 FormalIndex = INDEX_NONE;
    FAngelscriptSemanticExpressionId Expression;
    FString TemporaryName;
};
```

Analyzer 创建一次 materialization plan；各 call disposition 只消费它。`MaySuspend` 和
`RequiresCleanup` 在 v1 eligibility 阶段拒绝。`MaySetScriptException` 强制 emitter 在
operation 后插入 check，不能由 call spelling 自行决定。

## Patch C：integer/shift helper

目标测试：

- `AngelscriptNativeOperatorFailureTests.cpp`
- `AngelscriptNativeBitwiseOperatorTests.cpp`
- `AngelscriptStaticJITExceptionTests.cpp`
- 新增/扩展 `AngelscriptSemanticAOTScalarParityTests.cpp`

目标实现：

- `StaticJIT/SemanticAOT/AngelscriptSemanticAOTScalarOps.h`
- `StaticJIT/SemanticAOT/AngelscriptSemanticAOTScalarOps.cpp`（仅非模板/exception bridge）

建议 header-only width helper：

```cpp
template <typename UInt>
FORCEINLINE UInt MaskShiftCount(UInt Count)
{
    static_assert(std::is_unsigned_v<UInt>);
    return Count & UInt(sizeof(UInt) * 8 - 1);
}

template <typename UInt>
FORCEINLINE UInt ArithmeticShiftRightBits(UInt Bits, UInt RawCount)
{
    const UInt Count = MaskShiftCount(RawCount);
    if (Count == 0)
        return Bits;
    const UInt Logical = Bits >> Count;
    const UInt Sign = Bits >> (sizeof(UInt) * 8 - 1);
    const UInt Fill = Sign ? (~UInt(0) << (sizeof(UInt) * 8 - Count)) : UInt(0);
    return Logical | Fill;
}
```

实际代码应使用项目支持的 type-traits/include 风格；上面只冻结算法。Add/Sub/Mul 同样在
`uint32/uint64` 上完成，再通过明确 bit conversion 返回 signed result。不要先 cast 成 signed
再运算。

测试轴：

- width 32/64；
- signed/unsigned；
- count `-1,0,1,width-1,width,width+1,2*width+3`；
- `0,1,-1,MIN,MAX,high-bit-only`；
- `<<`, logical `>>`, arithmetic `>>>` 及 compound variants；
- division/remainder by zero 与 `MIN/-1`；
- exception 后 counter 不再变化。

## Patch D：float conversion policy

不要先实现新算法。第一步把 Semantic 路径接到一个单一 adapter：

```cpp
EAngelscriptSemanticNumericConversionResult TryConvertScalar(
    EAngelscriptNumericType SourceType,
    uint64 SourceBits,
    EAngelscriptNumericType TargetType,
    uint64& OutBits);
```

adapter 的测试直接复用：

- `AngelscriptNativeNumericBoundaryConversionTests.cpp`；
- `AngelscriptNativeNumericConversionTests.cpp`。

分类：

| input | 首期行为 |
|---|---|
| finite、target range 内 | shared helper + exact differential |
| signed zero/subnormal | shared helper + bit/result differential |
| NaN/infinity/out-of-range | 只有 VM/Legacy/Semantic 同一 reviewed helper 或严格 toolchain oracle 时支持；否则 `NonPortableNumericConversion` |

## Patch E：global/dependency/import tests

目标文件：

- `AngelscriptNativeTypedSemanticIRTests.cpp`
- `AngelscriptSemanticAOTEligibilityTests.cpp`
- `AngelscriptSemanticAOTDependencyTests.cpp`
- `AngelscriptSemanticAOTCallBridgeTests.cpp`

最小 fixtures：

1. pure `const int`/enum 被折叠：HIR 有 global origin，manifest 有 `HardValue`，可发射；
2. 删除 origin 或把 dependency 改成 `GlobalStorage`：
   `SemanticDependencyMismatch`；
3. mutable `int` read/write：`UnsupportedGlobalStorage`；
4. object/container global：typed lifetime/storage fallback；
5. global initializer：`UnsupportedGlobalInitializer`，不产生 provider symbol；
6. imported scalar function：bind A→call、rebind B→call、unbind→exception、bind A→call；
7. 如果 v1 没有 current-binding bridge，整个 imported fixture稳定返回
   `UnsupportedImportedRoute`，而不是跳过 rebind 测试；
8. shared/external declaration从非 body-owner module 可见时，不产生重复 helper body。

Dependency reconciliation 断言是“HIR use 被 compiler dependency 覆盖”，不是两个集合必须
完全相等；额外 compiler dependency 要原样保留。

## 验证顺序

1. OpenSpec synthetic fixture validator（无需 UE build）；
2. maintained SDK eager/operator/conversion oracle；
3. HIR capture/verifier tests；
4. pure Semantic generated-output tests；
5. NativeBridge direct/bridge runtime matrix；
6. Dual AOT fixture；
7. focused StaticJIT prefix、Standalone、modular Editor link。

生产实现完成前，任何 synthetic JSON/golden PASS 都只能证明契约自洽，不能标记 production
Semantic AOT 为完成。
