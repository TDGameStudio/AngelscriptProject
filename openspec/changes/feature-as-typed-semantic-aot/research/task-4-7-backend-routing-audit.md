# Task 4.7 per-task backend 与 generator 路由审计

日期：2026-08-17

## 结论

Task 4.7 已闭环。生产 `typed-ast` 不存在常驻 backend 单例，也没有绕过统一
generator 的第二条 project-generation 路径。Runtime registry 保存的是静态 factory；
`FAngelscriptStaticJITGenerator::Generate()` 对参与本次任务的每个 backend 最多调用一次
`CreateBackend()`，把完整 compiled graph 与独立 emit set 交给它，并在本次
`Generate()` 返回前销毁实例。

## 生产边界

- `FAngelscriptStaticJITBackendId::TypedAST()` 的稳定拼写是 `typed-ast`；空值、大小写
  变体、`typed_ast`、`dual` 和未知值均被拒绝。
- `RegisterAngelscriptTypedASTJITBackend()` 显式、幂等地把
  `AngelscriptTypedASTJITBackend_Private::GFactory` 注册到 Runtime-owned registry；
  同 ID 的其他 factory 会确定性失败。
- 全部 `AngelscriptRuntime` 生产源码只有 factory 的
  `MakeUnique<FAngelscriptTypedASTJIT>()` 一个实例构造点。项目 builder、commandlet、
  diagnostics 和 Provider packaging 都通过 `GenerateStaticJITProviderArtifacts()` →
  `FAngelscriptStaticJITGenerator` → `IAngelscriptStaticJITBackend::Generate()`。
- programmatic boundary 在 Engine 创建/源编译前冻结 backend profile：`bytecode`
  需要 `Bytecode` capture，`typed-ast` 需要 `VerifiedTypedHIR`；不匹配时在构造 backend
  前失败。
- `FAngelscriptTypedASTJIT` 自身是一枪式对象。第二次调用返回
  `TypedASTJITTaskInstanceAlreadyConsumed`；跨 Engine function 返回
  `TypedASTJITEngineMismatch`；不是该 function 当前 `GetTypedSemanticFunction()` 的 HIR
  返回 `TypedASTJITSameCompilationHIRRequired`。实例不在返回后保留 Engine/HIR 指针。
- Typed backend 的 body analysis、call closure 和 emission 只消费 immutable graph、
  exact Engine-local function/HIR 和统一 entry/provider plan。没有调用 BytecodeJIT
  `AnalyzeScriptFunction()`、bytecode reference resolver、`GetByteCode()`、
  `FStaticJITContext` 或 opcode dispatch；emitter 中出现 `FStaticJITContext` 仅是
  generated-source forbidden-token validator 的拒绝列表，不是依赖。

## TDD 沿革

该实现先前随 profile/generation 里程碑落盘，但当前任务表尚未做完成性审计。保留的
历史 RED/GREEN 证据包括：

- `Saved/Build/typed-ast-jit-profile-red/20260814_110554_151_0b85c1fa/`：
  缺少 frozen StaticJIT generation profile API；
- `Saved/Build/typed-ast-jit-capture-red/20260814_110853_772_8f5ef619/`：
  缺少 profile application/capture-view API；
- `Saved/Tests/typed-ast-jit-profile-validation-red/20260814_111627_848_d6c6aa99/`：
  unknown ID 诊断不完整，且 capture profile 被 lossy boolean 错误接受；
- `Saved/Tests/typed-ast-jit-aot-profile-red/20260814_112512_711_a2a84e76/`：
  旧 AOT fixture 用 typed HIR capture 请求 bytecode，精确匹配后产生预期 RED；
- `Saved/Build/typed-ast-jit-profile-final/20260814_113102_501_2ef83cc6/`：
  生产 per-task typed factory/generator 路径 build PASS；
- `Saved/Tests/typed-ast-jit-profile-final-engine/20260814_113139_550_624a0351/`
  与 `Saved/Tests/typed-ast-jit-profile-final-backend-rerun/20260814_113248_582_dc57e211/`：
  当时的 generation Engine `6/6`、backend contract `8/8 PASS`。

## 2026-08-17 新鲜完成性验证

- build（包含下面的 test-oracle 修正）：
  `Saved/Build/semantic-aot-task47-project-slot-oracle-green-build/20260817_073118_353_3e55d8bc/`
  — PASS，4 actions；
- backend contract：
  `Saved/Tests/semantic-aot-task47-backend-contract/20260817_072718_979_75534986/`
  — `9/9 PASS`；覆盖稳定 ID、注册去重、one instance/whole graph、独立 emit set、
  per-function fallback 与 capture mismatch 构造前拒绝；
- active Bytecode isolation sentinel：
  `Saved/Tests/semantic-aot-task47-bytecode-isolation/20260817_072756_023_ad274a96/`
  — `1/1 PASS`。配对 Bytecode probe 的 analysis/reference scan/GetByteCode/dispatch
  四个计数都大于零，证明哨兵有效；Typed generation scope 内四个计数全部为零；
- real project Generate + read-only Verify：
  `Saved/Tests/semantic-aot-task47-project-builder-lifecycle-green-rerun/20260817_073140_752_72381ca7/`
  — `1/1 PASS`。Generate 与 Verify 每次都精确
  `Created=1, GenerateInvocation=1, Destroyed=1, Accepted=1, Rejected=0`，消费同次
  编译 HIR，并把 `ProjectEntry`/`ProjectHelper` 组织为一个 AS module `.jit.cpp`。

## 本轮发现并修正的测试问题

第一次 lifecycle 命令误用了 `Angelscript.Editor...` 前缀，runner 明确报告
`No automation tests matched`；它没有执行产品代码，不计作 RED。正确前缀随后暴露
一个真实测试失败：旧断言搜索单行
`GetScriptFunction(Execution, 0u)`，而当前 helper wrapper 为可读性输出多行
`GetScriptFunction(\n...Execution, 0u)`。

这不是 slot/identity 回归。修正后的测试先从 `FAngelscriptJITGeneratedFunction` 检查
`ProjectEntry` 恰有一个 `ScriptFunction` reference、slot 为 `0`、ExpectedAbi 非零，
再检查生成模块中的多行调用。这样继续严格验证稳定引用身份和 slot 顺序，同时不把
空白格式误当运行语义。首次正确前缀失败证据：

`Saved/Tests/semantic-aot-task47-project-builder-lifecycle-green/20260817_072927_700_a6b5e0af/`

修正后即为上面的 lifecycle GREEN。

