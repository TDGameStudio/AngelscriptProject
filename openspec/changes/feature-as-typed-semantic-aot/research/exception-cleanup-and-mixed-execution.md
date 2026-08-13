# Exception、cleanup 与 mixed execution：Typed Semantic AOT 的落地边界

## 1. 结论先行

Typed Semantic AOT 的第一版 scalar slice 可以继续复用当前
`FScriptExecution::bExceptionThrown` 作为“立即停止后续效果”的快速信号，但不能把它当成完整的
异常协议。当前 Runtime/Legacy StaticJIT 的真实结构是：

- VM context 拥有异常文本、函数、section/line/column、是否会被 catch、callback 和 call stack；
- JIT execution 只拥有一个 `bool bExceptionThrown`，异常 helper 立即写日志；
- direct JIT→JIT 调用共享同一个 `FScriptExecution`，所以 flag 会自然向上传播；
- dynamic JIT→VM bridge 只把非 finished 状态折叠成外层 flag，不复制异常文本或来源；
- Legacy StaticJIT 依赖 bytecode 的 object-liveness 表和 cleanup label 做异常析构；
- 当前源码语言明确拒绝 `try/catch` 和 bare `throw;`，fork 内的 `tryCatchInfo`
  是没有 source compiler producer 的 dormant/restore plumbing，不能被误写成当前语言能力。

因此本 change 应把两个层次分开：

1. **v1 scalar eligibility**：不拥有对象、return-on-stack、argument cleanup 或 catch region；每个
   `MaySetScriptException` 边界之后立即检查 flag，并在任何后续效果发生前返回。
2. **未来 object/lifetime slice**：先定义结构化 primary exception、bridge adoption、cleanup plan
   和 destructor-isolation 协议，再开放 eligibility；不能只在生成 C++ 时依赖 RAII 猜测 AS 语义。

本轮还发现并以 test-first patch 修复了一个独立 Legacy 问题：VM 异常展开明确按逆声明顺序
析构，Legacy cleanup label 原先按正序发出析构。详见第 8 节和
`patches/exception-cleanup-and-bridge-test-first-patch.md`。

## 2. 当前三条异常路线

### 2.1 VM route

`asCContext::SetInternalException()` 会：

- 设置 `m_status = asEXECUTION_EXCEPTION`；
- 保存 `m_exceptionString` 和 `m_exceptionFunction`；
- 从当前 function/program pointer 保存 section、line、column；
- 计算 `m_exceptionWillBeCaught`；
- 调用已安装的 exception callback。

随后 `CleanStack()` / `CleanStackFrame()` 使用
`objVariableInfo`、`objVariablePos` 和当前 bytecode position 判断哪些对象已经构造且仍然 live，
先清理 call arguments，再按逆声明顺序清理 local/value storage，最后清理 owned 参数。VM 的
异常 payload 和 cleanup 状态都在同一个 `asCContext` 中。

### 2.2 direct JIT route

顶层 VM entry 和 nested `asCContext::CallScriptFunction()` 都创建
`FScriptExecution`，调用 JIT `VMEntry`，然后只检查 `Execution.bExceptionThrown`。Generated
direct raw calls把同一个 `Execution&` 传入 callee，callee 置 flag 后 caller 会进入自己的
cleanup/return edge。

这个路线有两个有意的优点：

- flag 不需要复制就能跨 direct closure 传播；
- 每个生成函数可以在 call/error edge 立即禁止后续效果。

但它没有保留 VM public exception API 所需的数据：`FScriptExecution` 没有 exception
string/function/line/column/callback disposition。`FAngelscriptEngine::Throw()` 在 active JIT
时只置当前 active execution 的 flag，然后 `HandleExceptionFromJIT()` 立即写日志。

### 2.3 JIT→VM dynamic bridge

Legacy generated code为 dynamic target 创建一个新的 `FAngelscriptContext`，prepare/marshal 后
执行。若 inner context 不是 `asEXECUTION_FINISHED`，它只执行：

```cpp
Execution.bExceptionThrown = true;
```

outer execution 不会 adoption `CallContext->GetExceptionString()`、exception function 或
source location。inner context 的 callback/logging 可能已经发生，因此未来补 payload 时也不能
简单再次调用 outer `SetException()`，否则会重复 callback/log 并把来源错误归到 caller。

## 3. `bExceptionThrown` 能做什么，不能做什么

| 能力 | 当前 JIT flag | VM context | Semantic v1 决策 |
| --- | --- | --- | --- |
| 停止后续 operand/effect | 可以 | 可以 | 必须复用 |
| direct callee 向 caller 传播失败 | 可以，共享引用 | 可以，call stack | 必须复用 |
| exception text | 不保留，只立即日志 | 保留 | differential test 必须揭示差异；生产开放前定协议 |
| exception function/source | 不保留结构化 ID | 保留 | 不得仅用 root function 冒充 origin |
| callback exactly once | 无结构化状态 | context 管理 | bridge adoption 不能重报 |
| caught/uncaught disposition | 无 | 有 dormant catch plumbing | 当前 source surface 没有 catch；载入 metadata fail-closed |
| cleanup ownership | 生成 label 自己负责 | context unwind | v1 非 trivial lifetime fallback |

`exception state` 的 Dual 对比不能只比较 `asEXECUTION_EXCEPTION` 或 bool。至少应记录：

- exact message；
- throwing function/stable origin；
- processed source span，能可靠映射时再加 authored origin；
- route：`DirectSemantic|DirectLegacy|VMBridge|NativeBridge`；
- callback/log count；
- cleanup sequence 和 live-object count；
- failure 后没有发生的 effects。

## 4. 建议的结构化异常协议

不要直接给外部 provider 暴露可变的 `FString`/`asCString` ABI。先在 Runtime 内定义一个
call-scoped、set-once 的 primary record，entry ABI 只携带稳定 pointer/handle 或通过 Runtime
helper 操作。概念模型如下：

```cpp
enum class EAngelscriptJITFailureKind : uint8
{
	None,
	ScriptThrow,
	NullPointer,
	DivideByZero,
	IntegerOverflow,
	OutOfBounds,
	UnboundFunction,
	InvalidSwitchValue,
	RecursionLimit,
	RuntimeBridgeFailure,
};

struct FAngelscriptJITFailureRecord
{
	EAngelscriptJITFailureKind Kind = EAngelscriptJITFailureKind::None;
	const char* StableMessage = nullptr;
	FAngelscriptStableFunctionKey OriginFunction;
	FAngelscriptSourceSpan OriginSpan;
	EAngelscriptSemanticCallDisposition OriginRoute;
	bool bReported = false;
};
```

实际实现可使用 Runtime-owned sidecar，避免立刻改变 generated/provider-visible
`FScriptExecution` layout。若最终选择给 `FScriptExecution` 加字段，则必须同步：

- provider entry ABI/layout revision；
- artifact profile/content identity；
- generated Runtime/Test provider；
- packaged provider compatibility checks；
- mixed old/new artifact rejection测试。

协议规则：

1. 第一个 failure 是 primary；cleanup/destructor 期间发生的次级 failure 不替换它。
2. direct caller/callee 共享 record；callee 只 set-once，不在每层重新报告。
3. VM bridge adoption 复制/映射 inner payload，但保留 `bReported`，不重新触发 callback/log。
4. outer VM entry 在 native body返回后把 record 映射回 context public exception metadata。
5. source position来自 throwing safe point/frame，不使用 outer root 当前 program pointer伪造。
6. 若当前 entry/profile 无法保留 required metadata，则 route 到 VM 或报告
   `UnsupportedExecutionObservability`，不能静默降级成只有 bool。

## 5. cleanup 不能只用 C++ scope RAII

当前 VM/Legacy 的 object liveness 不是“函数内所有已经声明对象”这么简单。它区分：

- 当前 may-throw operation 是执行前失败还是执行后失败；
- constructor 是否已经完成；
- object 是否已经正常析构；
- 当前 block 是否已退出；
- call argument 是否已被移入 VM stack；
- return-on-stack storage 是否由 caller 拥有；
- heap/ref/script-object/value storage 的不同释放动作；
- catch region 前、region 内和 region 后声明的对象。

Legacy `ExceptionCleanupAndReturn(bAfterCurrentOp, ...)` 会根据 bytecode position 计算 live set，并
把相同 cleanup set 去重为 label。Semantic HIR没有 bytecode position，因此未来 lifetime slice
必须在 HIR/lowering 中显式保存：

```text
LifetimeSlotId
DeclarationOrder
StorageKind
ConstructionState: Uninitialized | Constructing | Live | Destroyed
OwningScopeStatementId
NormalExitAction
ExceptionalExitAction
CallArgumentTransferState
ReturnSlotOwnership
```

每个 may-throw expression、call、conversion、constructor phase 和 control transfer 都引用一个
verified cleanup plan。plan按逆声明顺序列出当前 live slots；emitter 不能从 C++ 局部变量出现
顺序、变量名或 RAII 自动推导。

第一版 scalar slice 应明确验证 `CleanupPlan=[]`，而不是仅验证“H​​IR中没有 object expression”。
一个 scalar-return function 仍可能通过 by-value argument、hidden argument、native call
return-on-stack 或 compiler temporary 获得非 trivial cleanup，因此 eligibility 要看 normalized
function/call shape。

## 6. destructor during exception cleanup 的额外风险

Legacy generated function prolog 目前含：

```cpp
SCRIPT_ASSUME_NO_EXCEPTION()
```

script-struct cleanup destructor 使用 `FCallScriptFunction(..., bIgnoreExceptions=true)`。当 cleanup
label 已处于 `Execution.bExceptionThrown == true` 时，若它走 direct generated destructor 并共享
同一 `Execution&`，callee prolog 的 assume 与真实状态冲突；即使不触发 optimizer UB，callee
内部普通 exception checks 也会看到 pre-existing failure，可能提前退出 destructor body。

这不是候选逆序 patch 能解决的问题。开放 Semantic object lifetime 前必须先做以下
characterization：

- native trivial destructor；
- native system destructor；
- script-struct direct destructor；
- script-struct dynamic VM destructor；
- destructor 自己触发 AS exception；
- primary exception + cleanup exception；
- normal return cleanup 与 exception cleanup；
- partially constructed local/temporary/return slot。

更安全的候选方案是：exception cleanup 中的 script destructor 使用隔离的 child execution/context，
child 从无异常状态开始，完成后丢弃 secondary failure并保留 outer primary；或强制此路线经过 VM
cleanup bridge。不能靠临时把 outer flag 清零后再恢复，因为 direct nested calls、diagnostic frame
和 concurrent provider binding lifetime也需要一起隔离。

## 7. 当前 `try/catch` 的准确边界

项目已有
`AngelscriptNativeExceptionHandlingRejectionTests.cpp`，按 placement 和 LF/CRLF 矩阵明确证明：

- `try { } catch { }` 被编译器拒绝；
- try without catch 被拒绝；
- catch without try 被拒绝；
- bare `throw;` rethrow 被拒绝；
- 拒绝后同名 module 可以恢复编译。

fork 内仍有 `tryCatchInfo`、`FindExceptionTryCatch()`、catch-aware `CleanStackFrame()` 和
bytecode save/restore 字段；`asCByteCode::TryBlock()` 使用内部 marker `250`。但当前 Runtime
source tree 中没有任何 `.TryBlock()` 调用，tokenizer/parser 也没有 source syntax producer。

因此 OpenSpec 使用以下措辞：

- 当前 source-known Semantic AOT **不需要实现可写 try/catch 语法**；
- HIR header 若看到非空 catch-region metadata（例如未来 fork backport 或 restored bytecode）必须
  标记 `UnsupportedExceptionRegion`/`MissingTypedIR` 并 fail closed；
- 未来 fork 真正开放 syntax 时，必须作为 language-version/profile 变化重新设计 capture、cleanup、
  identity 和 differential tests，不能因为 dormant fields 存在就自动宣称支持。

## 8. Research-only Legacy cleanup 顺序候选 patch

本节记录一次短暂的 test-first 探索。它用于验证问题与最小修正方向，但不属于本轮获准的
源码实现范围。探索完成后，新增 CQTest 和 `AngelscriptStaticJIT.cpp` 循环改动都已从当前
`Plugins/Angelscript` checkout 精确撤销；当前源码仍是正序 cleanup。可重新应用的设计保存在
`research/patches/exception-cleanup-and-bridge-test-first-patch.md`，不得把本节当成已落地状态。

### RED

探索时曾临时新增、现已撤销
`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITExceptionCleanupTests.cpp`：

- 编译一个拥有 `FString First`、`FString Second` 后抛错的真实 AS function；
- 通过 `GenerateStaticJITSourceText()` 获取真实 Legacy generated C++；
- 定位最终 exception cleanup block；
- 要求 `v_Second` destructor 出现在 `v_First` 之前。

RED 报告：

`Saved/Tests/semantic-aot-exception-cleanup-red-assertion/20260813_102515_234_f235579f/Report`

结果为 `0/1`，失败原因精确为 reverse declaration order 断言。

### 候选 minimal production change（未应用）

候选修改是把 `AngelscriptStaticJIT.cpp` 中 cleanup label emission 从 `0..Count-1` 改为
`Count-1..0`，与 `asCContext::CleanStackFrame()` 和 normal scope cleanup 一致。该修改已经从
当前 checkout 撤销。

### 当前验证状态

RED 前的 test build 成功：

`Saved/Build/semantic-aot-exception-cleanup-red-assertion/20260813_102456_248_d2024def/Build.log`

探索期间的 GREEN 重建被同工作区另一条 diagnostics API/header-test 不一致阻塞，错误位于
`AngelscriptStaticJITDiagnosticsTests.cpp` 对已移除 snapshot/json members 的引用，与本 patch
无关。未来获得明确实现授权、重新应用候选 patch 且并行 change 稳定后，必须重新跑：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunBuild.ps1 `
  -Label semantic-aot-exception-cleanup-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.ExceptionCleanup" `
  -Label semantic-aot-exception-cleanup-green -TimeoutMs 600000
```

在上述命令真实通过前，本附件不把 patch 标记为 GREEN；当前状态是“RED 证据已保存、候选
源码与测试均未应用”。

## 9. Typed Semantic AOT 的分阶段 patch map

### Phase A：scalar failure boundary

- HIR：每个 expression/call 写 `CannotFail|MaySetScriptException|MaySuspend|RequiresCleanup`。
- verifier：may-fail node必须有 source safe point；之后的 effect依赖 exception-success edge。
- emitter：每一步 materialization 后立即检查 failure state；failure edge只到 function exit。
- eligibility：`MaySuspend|RequiresCleanup|ReturnOnStack|ExceptionRegion` 全部 typed fallback。
- tests：first/middle/last operand failure、short circuit、assignment RHS/target、loop phase、switch
  invalid enum、direct/bridge helper。

### Phase B：structured payload and bridge adoption

- Runtime：call-scoped primary record/helper，先不扩大 public AS SDK API。
- entry：top VM entry把 JIT record映射到 context metadata；nested direct不重报。
- bridge：inner context payload adoption；保存 exact origin和 reported state。
- diagnostics：dump failure kind/origin route/source，Shipping 中不保留昂贵字符串时仍保留 stable kind。
- tests：`GetExceptionString/Function/LineNumber`、callback count、log count、mixed call stack。

### Phase C：non-trivial lifetime

- HIR：lifetime slots、construction transitions、cleanup plans、return/argument ownership。
- verifier：所有 normal/return/break/continue/failure edge 对每个 owned slot恰好一次 cleanup。
- emitter：逆声明顺序、partial construction、primary exception preservation。
- bridge：script destructor isolation 和 return-on-stack contract。
- eligibility：按 storage/call shape逐项开放，不使用单个 `hasObject` 开关。

## 10. 最值得复用的现有 oracle

- `AngelscriptNativeExceptionMetadataTests.cpp`：message/function/line/column/callback。
- `AngelscriptNativeExceptionOriginTests.cpp`：global/member/imported/native callback/constructor/destructor origin。
- `AngelscriptNativeExceptionRecoveryTests.cpp`：exception 后 context recovery 与 stale metadata 清除。
- `AngelscriptNativeExceptionHandlingRejectionTests.cpp`：当前无 try/catch/rethrow source syntax。
- `AngelscriptNativeDestructorExitTests.cpp`：normal/return/break/continue/exception/abort/unprepare/global
  生命周期与 event order。
- `AngelscriptNativeDestructorPartialConstructionTests.cpp`：constructor boundary、partial construction、
  cleanup exactly once。
- `AngelscriptStaticJITAotTests.cpp::NestedGeneratedExceptionPropagates`：真实 generated nested JIT
  exception/log path，但当前只断言 status/log，不足以证明 public exception metadata。
- 候选 `AngelscriptStaticJITExceptionCleanupTests.cpp`：Legacy generated exception cleanup逆序回归；
  当前仅保存在 research patch 说明中，未留在子模块源码树。

这些 oracle 应在 Semantic 测试中复用同一 source/input matrix，并明确比较 VM、Legacy、Semantic，
不要重新发明只看 entry counter 或 bool 的弱化测试。
