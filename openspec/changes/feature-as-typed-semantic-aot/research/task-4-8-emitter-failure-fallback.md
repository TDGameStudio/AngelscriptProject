# Task 4.8：Emitter failure 原子回退闭环

## 要证明的合约

`specs/as-typed-ast-jit-backend/spec.md` 要求一个已经通过 TypedASTJIT
eligibility 的函数，如果在 emission 或最终验证阶段失败：

1. production generation 记录稳定原因 `EmitterFailure`；
2. 当前函数继续进入既有 TypedASTJIT -> BytecodeJIT -> VM 回退链；
3. 失败的 Typed attempt 不得留下半个 Provider registration 或半个 typed body；
4. AOT differential verifier 不得因为 Bytecode/VM 仍能生成或执行，就把意外回退当作成功；
5. 不得为测试增加 production `dual` backend、shadow execution 或 Runtime 测试后门。

## 测试落点与可击中的错误

新增场景位于能力归属明确的
`StaticJIT/AOT/Generation/AngelscriptStaticJITAotGenerationVerificationTests.cpp`：

`EmitterVerificationFailureFallsBackAtomicallyAndFailsVerification`

它通过 `RunForTesting(Verify, AdvertiseUnsupportedEmitterCapability)` 驱动真实的
generation Engine、`FAngelscriptStaticJITGenerator`、TypedASTJIT backend、BytecodeJIT
backend 和 Provider packager。测试会在以下任一生产回归发生时失败：

- capability closure 没有先通过 eligibility；
- Typed attempt 没有记录 `EmitterFailure`；
- generator 没有选择 BytecodeJIT；
- Bytecode attempt 没有生成最终函数；
- 同一稳定 FunctionKey 在 Provider 中出现零个或多个最终 registration；
- 失败的 Typed attempt 把 `{SymbolPrefix}_TypedBody` 泄漏到最终模块源码；
- differential verifier 放过了预期 eligible 函数的意外回退。

预期值独立于 emitter 实现构造：当前 EditorDevelopment 正常能力为
`FramePosition|RecursionBudget`，测试 variant 只额外声明一个合法、已知但当前 emitter
不生成的 `Coverage` capability。Execution requirements 仍为 `None`，因此 call closure
eligibility 可以通过；`EmitTypedASTJITFunction()` 在真实 emitter 边界返回
`UnsupportedInstrumentationCapabilities`，由 production backend 记录为
`EmitterFailure`。这个 variant 只允许 `Verify`，从不发布或覆盖 checked-in 生成文件。

## 原子性观测

`FStaticJITAotEmitterFailureFallbackObservation` 是 AngelscriptTest 内的 pointer-free
只读结果，不进入 AngelscriptRuntime ABI。它从 production generator 已经拥有的数据中
复制：

- exact stable FunctionKey；
- Typed call closure 的 `bEligible`；
- Typed/Bytecode backend attempts；
- 最终 `ActualBackendId` 与 disposition；
- Provider output 中该 FunctionKey 的精确出现次数；
- 最终 module source 是否包含同一 SymbolPrefix 的 `_TypedBody`。

最终 GREEN 中的实际关系是：

- `bTypedEligibilityPassed = true`；
- Typed diagnostic 以 `EmitterFailure:` 开头，并包含
  `UnsupportedInstrumentationCapabilities`；
- `FinalBackendId = bytecode`；
- final function 与 Bytecode attempt 均为 `Emitted`；
- `ProviderFunctionCountForKey = 1`；
- `bTypedBodyPresent = false`；
- `RunForTesting(...Verify...)` 的整体结果仍为失败，并明确包含
  `did not use the production TypedAST backend` 与 `EmitterFailure`。

当前标量 fixture 本身可由 BytecodeJIT 生成，所以这一场景确定性选择 BytecodeJIT；若
后续函数连 BytecodeJIT 也不支持，既有 generator 链继续以 VM 结束。这里没有新建第二
套选择器，也没有把 VM 伪装成 Provider entry。

## Production 边界审计

- `AngelscriptTypedASTJITEmitter.cpp::EmitTypedASTJITFunction()` 对不支持的
  instrumentation profile 返回一个全新的失败结果，没有 declaration/definition。
- `AngelscriptTypedASTJITBackend.cpp` 只在所有 closure member body/wrapper 与 root
  Provider emission 成功后才构造 `FAngelscriptJITGenerationFunction`；失败字符串只存在于
  当前 backend attempt 的局部结果中。
- `AngelscriptStaticJITGenerator.h` 只在某个 backend 返回 `Emitted` 且携带匹配
  FunctionKey 的完整 `EmittedFunction` 时替换最终结果；unsupported Typed attempt 只被
  追加为诊断，随后 Bytecode attempt 提供唯一最终函数。
- 本任务没有修改 Runtime emitter、backend、generator、Provider ABI 或 backend ID
  集合；production 仍只有 `typed-ast` 与 `bytecode`，没有 `dual`。

## RED / 调试记录

1. 测试侧 enum、pointer-free observation 和断言先落盘，production/test harness 尚未处理
   variant。
2. 官方 RED build：
   `Saved/Build/semantic-aot-task48-emitter-fallback-red-build/20260817_074235_434_bb16a043/`
   — PASS，证明新测试已注册进二进制。
3. 第一次使用只含 `TEST_METHOD` 名称的短 Automation 前缀没有命中 CQTest；该运行只记录
   runner 使用错误，不作为语义 RED。
4. 真实类前缀 RED：
   `Saved/Tests/semantic-aot-task48-emitter-fallback-red-class/20260817_074337_609_d044cf83/`
   — `3/4 PASS`，新增方法唯一失败，精确断言为
   `The production generator result must expose the exact fallback function`。另外三个既有方法
   全部通过，证明 RED 被隔离到缺失的新 variant/观测闭环。
5. 第一轮 GREEN build 被 UE format-string sanitizer 拒绝：fallback `LexToString()` 返回
   `const TCHAR*`，测试 harness 多解引用了一次。只修正两个 `%s` 参数类型后重跑，没有
   改变生产逻辑或测试期望。
6. 第一轮 exact runtime 已通过所有原子性断言，只因测试把
   `EmitterFailure` 与 `UnsupportedInstrumentationCapabilities` 错误要求为相邻文本而失败。
   真实结构化诊断中间保留了函数和 provider-body 上下文。测试随后改为分别断言稳定 reason
   与 detail token，避免把内部排版当作契约。

## 最终验证

- 官方 GREEN build：
  `Saved/Build/semantic-aot-task48-emitter-fallback-green-assert-build/20260817_075232_061_fb385e29/`
  — PASS。
- 新增 exact 场景：
  `Saved/Tests/semantic-aot-task48-emitter-fallback-green-exact-rerun/20260817_075256_313_7b6e0c65/`
  — `1/1 PASS`。
- 既有 eligibility-stage unexpected fallback：
  `Saved/Tests/semantic-aot-task48-existing-fallback-regression/20260817_075402_573_f5cd4957/`
  — `1/1 PASS`。
- backend contract：
  `Saved/Tests/semantic-aot-task48-backend-contract-regression/20260817_075440_836_ef2c0865/`
  — `9/9 PASS`。
- Typed emitter generated-output 回归：
  `Saved/Tests/semantic-aot-task48-emitter-output-regression/20260817_075515_243_7af52216/`
  — `25/25 PASS`。

结论：task 4.8 的 emitter-stage 失败、typed reason、原子 Provider 输出、Bytecode fallback
和 differential rejection 已由同一真实 generation 结果闭环，可以勾选。
