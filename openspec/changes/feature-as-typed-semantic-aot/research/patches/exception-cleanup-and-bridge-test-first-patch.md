# Test-first patch：exception payload、mixed bridge 与 cleanup

> 状态：research-only 候选，未应用到当前 `Plugins/Angelscript` checkout。曾用临时 CQTest 得到
> 预期 RED 后验证最小循环反转方向；随后按范围要求精确撤销了测试文件和源码 hunk。本文用于
> 将来获得明确实现授权后重新按 TDD 应用，不表示生产代码已修改。

## 1. patch 目标

这个候选 patch 分成一个可独立实施的 Legacy 修复和两个未来 Semantic checkpoint：

1. Legacy exception cleanup 按逆声明顺序析构 live locals；
2. scalar Semantic route 精确抑制 exception 后的 effects；
3. mixed JIT/VM route 保留 public exception metadata，并为未来 lifetime cleanup 建立显式协议。

## 2. Patch 0：Legacy reverse cleanup（探索 RED 已保存，源码/测试未应用）

### test file

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITExceptionCleanupTests.cpp`

测试使用真实 `GenerateStaticJITSourceText()`，不读取 generator source，也不 mock bytecode。fixture：

```angelscript
void RaiseAfterTwoLocals()
{
    FString First = "first";
    FString Second = "second";
    throw("StaticJIT exception cleanup order sentinel");
}
```

期望 generated exception block 中 `Second` destructor早于 `First`。

### candidate production edit（未应用）

`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp`

```diff
- for (int i = 0, Count = Cleanup.Positions.Num(); i < Count; ++i)
+ for (int i = Cleanup.Positions.Num() - 1; i >= 0; --i)
```

### 后续补强

- checked-in AOT fixture `ObjectLifetimeEntryForAOT` 的 cleanup block也应重新生成并验证逆序；
- 实际执行测试使用 recorder value type，不只检查文本；
- nested scope与partial-construction分别覆盖 1/2/3 live slots；
- normal exit和exception exit应得到同一逆序序列。

## 3. Patch 1：先写 exception metadata characterization

在 `AngelscriptStaticJITAotTests.cpp` 的真实 generated exception case 增加独立 test method，记录当前
结果而不是立刻猜实现：

```cpp
ASSERT_THAT(AreEqual(asEXECUTION_EXCEPTION, Context->Execute()));
ASSERT_THAT(AreEqual(
    FString(TEXT("StaticJITAotNestedFailure")),
    UTF8_TO_TCHAR(Context->GetExceptionString())));
ASSERT_THAT(IsNotNull(Context->GetExceptionFunction()));
ASSERT_THAT(IsTrue(Context->GetExceptionLineNumber(&Column, &Section) > 0));
```

矩阵至少包括：

- top generated throw；
- generated root → direct generated helper throw；
- generated root → dynamic VM helper throw；
- generated root → provider-private native bridge调用 `FAngelscriptEngine::Throw()`；
- VM root → generated helper throw；
- exception callback absent/installed/replaced；
- debug metadata on/off。

预计当前 direct/dynamic JIT case会暴露空/stale context payload。先保存 RED report，再决定
Runtime record layout；不要为了让测试过而用 outer root function/line伪造 callee origin。

## 4. Patch 2：Runtime-owned primary failure record

建议新文件：

- `StaticJIT/AngelscriptJITFailure.h`
- `StaticJIT/AngelscriptJITFailure.cpp`
- `StaticJIT/AngelscriptJITFailureTests.cpp`

最小 API：

```cpp
bool TrySetPrimaryJITFailure(
    FScriptExecution& Execution,
    EAngelscriptJITFailureKind Kind,
    const ANSICHAR* Message,
    const FAngelscriptStableFunctionKey* Origin,
    const FAngelscriptSourceSpan* Span,
    EAngelscriptJITCallRoute Route);

void AdoptContextFailure(
    FScriptExecution& Outer,
    const asCContext& Inner,
    EAngelscriptJITCallRoute Route);

void PublishJITFailureToContext(
    asCContext& Context,
    const FScriptExecution& Execution);
```

测试顺序：

1. first failure wins；
2. direct callee共享 record；
3. cleanup failure不替换 primary；
4. bridge adoption保留 inner message/function/line；
5. `bReported` 防止 duplicate callback/log；
6. record在 `FScriptExecution` scope结束时不泄漏；
7. multi-engine/thread-local isolation；
8. Shipping profile不依赖 dangling source pointers。

如果 record改变 `FScriptExecution` layout，先让 provider ABI/version test RED；更稳妥的第一步是
Runtime-owned sidecar pointer/handle。

## 5. Patch 3：Semantic HIR failure edges

建议 HIR字段：

```cpp
enum class asETypedSemanticFailureBehavior : asBYTE
{
    CannotFail,
    MaySetScriptException,
    MaySuspend,
    RequiresCleanup,
};

struct asSTypedSemanticEffectEdge
{
    asTypedSemanticExpressionId Producer;
    asTypedSemanticStatementId SuccessContinuation;
    asTypedSemanticCleanupPlanId FailureCleanup;
};
```

verifier负例：

- may-fail node没有 failure edge；
- effectful successor不依赖 success edge；
- non-empty cleanup plan进入 scalar profile；
- bridge call声称 `CannotFail` 但 target descriptor允许 `FAngelscriptEngine::Throw()`；
- return-on-stack call没有 ownership transfer；
- catch region metadata非空但 profile宣称 scalar eligible。

emitter golden必须展开成逐步 temporary + check，不把多个 effectful operands塞进一个 C++ call。

## 6. Patch 4：lifetime slot / cleanup plan

建议模型：

```cpp
struct asSTypedSemanticLifetimeSlot
{
    asUINT Id;
    asUINT DeclarationOrder;
    asETypedSemanticStorageKind StorageKind;
    asTypedSemanticStatementId OwningScope;
    asCDataType Type;
};

struct asSTypedSemanticCleanupAction
{
    asTypedSemanticLifetimeSlotId Slot;
    asETypedSemanticCleanupKind Kind;
};
```

builder在 constructor完成后才从 `Constructing` 转 `Live`，normal destructor完成后转
`Destroyed`。所有 exit edge的 cleanup action必须按 `DeclarationOrder` 逆序。

第一阶段只接受空 action list。第二阶段先开放 native non-throwing value destructor，再开放
script destructor；return-on-stack、argument-copy 和 catch region最后开放。

## 7. 验证命令

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExceptionCleanupSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-SemanticExceptionCleanupContract.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunBuild.ps1 `
  -Label semantic-aot-exception-cleanup-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.ExceptionCleanup" `
  -Label semantic-aot-exception-cleanup-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" `
  -Label semantic-aot-exception-metadata -TimeoutMs 600000
```
