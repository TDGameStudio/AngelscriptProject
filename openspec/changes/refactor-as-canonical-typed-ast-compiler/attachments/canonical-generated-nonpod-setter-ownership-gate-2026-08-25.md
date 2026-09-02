# Canonical generated non-POD setter ownership gate（2026-08-25）

## 结论

Canonical Typed AST 已经能够为 generated non-POD setter 封存精确的赋值与
by-value 参数所有权计划，AST verifier 会在进入后端前拒绝不完整计划，Canonical
Bytecode CodeGen 则按照同一计划完成 copy construction、ownership transfer、
`opAssign` 和析构释放。

这条纵向切片已经通过 focused runtime test 和完整 Canonical ProductionCodeGen
前缀。真实 StaticJIT generation 也已越过 setter 生命周期问题，当前最早失败点
前移到 snapshot freeze 阶段的 constructor/factory declaration identity 绑定。

## 为什么这不是普通字段写入

对于标量或 POD，generated setter 可以按已知宽度写入 backing field。非 POD
值对象不同：

- 调用方传递 lvalue 时必须调用精确 copy constructor；
- by-value 参数必须有唯一、明确的所有者；
- setter 内必须调用字段类型的精确 `opAssign`，不能裸 `memcpy`；
- 正常返回和异常展开都不能泄漏、重复析构或重复求值实参。

因此 sealed AST 需要承载语义决定，而不能让 Bytecode 后端根据类型名称重新猜测。

## 现在的闭环

```text
lvalue source
     |
     v
Sema seals Construct(exact copy constructor)
     |
     v
caller: ALLOC(copy constructor)             caller owns temporary
     |
     v
script CALL / by-value ownership transfer   callee becomes owner
     |
     v
callee parameter is pointer-bound storage
     |
     v
generated setter calls exact opAssign(backing field, parameter)
     |
     v
callee FREE                                 exact destructor, once
```

具体约束如下：

1. Sema 对 non-POD by-value lvalue argument 封存
   `Cleanup(MaterializeTemporary(Construct(copyCtor, source)))`。
2. generated setter declaration 封存 backing field、parameter 和 exact `opAssign`
   三者组成的 assignment plan。
3. verifier 校验 copy constructor、字段、参数和 assignment operator 的精确身份，
   malformed plan fail-closed。
4. caller 使用 VM `ALLOC` 和精确 copy constructor 建立 exception-safe heap object。
5. script call 成功建立后，所有权从 caller 转移到 callee；callee 参数直接绑定该
   object pointer，不再 inline-copy。
6. setter 使用 sealed assignment plan 发出 `opAssign`；正常 epilogue 通过 `FREE`
   销毁 owned parameter。异常清理由既有 runtime parameter unwind 协议负责。
7. POD/by-scalar 既有路线不受影响。

## TDD 与回归证据

### RED

- Sema RED：
  `Saved/Tests/cta-generated-nonpod-setter-sema-red/20260825_070128_387_659f5baa`
- verifier RED：
  `Saved/Tests/cta-generated-nonpod-setter-verifier-red/20260825_070208_965_11f2f1e9`
- caller lowering RED：
  `Saved/Tests/cta-generated-nonpod-setter-codegen-red/20260825_071308_199_b73b224b`
- missing copy-plan AST RED：
  `Saved/Tests/cta-generated-nonpod-setter-call-plan-red/20260825_071746_925_36608d71`

### GREEN

- Sema/verifier build：
  `Saved/Build/cta-generated-nonpod-setter-sema-verifier-green-build/20260825_070751_435_fca8b1a7`
- focused SemaAuthority：**1/1 PASS**：
  `Saved/Tests/cta-generated-nonpod-setter-sema-green/20260825_070832_504_1f94dce2`
- verifier prefix：**30/30 PASS**：
  `Saved/Tests/cta-generated-nonpod-setter-verifier-green/20260825_070917_105_4ea3bd49`
- final focused ownership/lifecycle：**1/1 PASS**：
  `Saved/Tests/cta-generated-nonpod-setter-ownership-green2/20260825_072522_006_d6c6adb7`
- Canonical ProductionCodeGen：**94/94 PASS**：
  `Saved/Tests/cta-production-codegen-after-generated-nonpod-setter/20260825_072601_586_16cad32a`

focused runtime oracle 验证了 `2` 次 default construction、`1` 次 copy
construction、`1` 次 assignment 和 `3` 次 destruction，并同时检查 Bytecode 的
精确 `ALLOC(copyCtor)`、setter call、`opAssign` 与 `FREE`。

## 新暴露的最早生产边界

真实 generation 测试：

`Saved/Tests/cta-generation-after-generated-nonpod-setter/20260825_072642_912_87269c90`

仍为 **0/1**，但已经不再失败于 generated setter。当前最早错误是 snapshot
freeze 对 producer-carried declaration identity 的校验：

```text
StaticJIT canonical function
'FJITGenerationOnlyRawBox_65C28A FJITGenerationOnlyRawBox_65C28A()'
did not bind its producer-carried declaration identity
'FJITGenerationOnlyRawBox_65C28A::FJITGenerationOnlyRawBox_65C28A()'.
```

这表明工作点已经从“AST 是否能表达 setter 生命周期”前移到“runtime
constructor/factory 表示与 canonical constructor declaration stable identity 是否
一致”。下一步必须先区分该 runtime function 到底是 constructor、factory 还是
constructor 的 runtime wrapper，再以 focused declaration-binding RED 固定协议；
不能通过放宽 snapshot validator 掩盖身份不一致。

## 对 OpenSpec 任务进度的含义

这条切片为 `5.7/5.8/9.5/13.6` 等广义任务提供了关键证据，但尚不能单独关闭它们，
因为这些任务还要求覆盖其他对象、容器、异常和生产入口组合。它说明剩余任务的
性质是跨层验收同一语言语义，而不是继续添加新的 AST 数据结构。

