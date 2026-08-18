# Task 4.6 数值与转换渐进记录

日期：2026-08-17

本附件记录 task 4.6 的增量缺口和证据。该任务尚未整体完成；枚举表示和一个浮点窄化缺口已经闭环，但完整 divide/remainder、`INT_MIN/-1`、shift、signed/unsigned、bool、NaN/Infinity/out-of-range 矩阵仍需最终逐项审计。

## 枚举显式转换被误分类为对象构造

真实 fixture：

```angelscript
ETypedASTControlMode Mode = ETypedASTControlMode(RawMode);
```

编译器已经产生正确的 scalar `Conversion`，但 construct-call 收尾逻辑仅因 enum 拥有 `TypeInfo` 又包了一层 `Unsupported(ConstructionOrLifetime)`。这使有效 exhaustive enum 函数回退，Generate 首个诊断是 `Expression kind is outside the scalar slice`。

能力测试：`StaticJIT/TypedASTJIT/EnumConversions/AngelscriptTypedASTJITEnumConversionTests.cpp`。

- RED：`Saved/Tests/semantic-aot-enum-conversion-red/20260817_061742_444_e93f734d/` — `0/1`，只失败于意外 construction/lifetime marker。
- 修复：maintained compiler 的两个 construct-call wrapper 只对非 by-value scalar 的真实对象/lifetime 工作添加 unsupported marker；enum 保留 authoritative Conversion。VM bytecode不变。
- GREEN build：`Saved/Build/semantic-aot-enum-conversion-green-build/20260817_061832_614_90d09179/`。
- GREEN：`Saved/Tests/semantic-aot-enum-conversion-green/20260817_061846_215_d717efaf/` — `1/1 PASS`。
- 生成后 enum Raw/VM/Parms：`Saved/Tests/semantic-aot-task44-runtime-matrix-enum-regression/20260817_065357_628_e47a4d58/` — `1/1 PASS`，包含 exhaustive invalid-value exception edge。

## `float64 -> float32` reviewed native conversion

当前 fork 的 AS `float` 是 64 位，而真实 `Print` duration Bind 需要 32 位浮点。原 analyzer 只允许 `float32 -> float64`，因此 `TypedASTPrintShowcase` 在 Generate 中以 source token `82/8` 到 target token `81/4` 回退。

能力测试：`StaticJIT/TypedASTJIT/FloatingConversions/AngelscriptTypedASTJITFloatingConversionTests.cpp`。

- RED build：`Saved/Build/semantic-aot-floating-conversion-red-build/20260817_062304_874_deefcc85/`。
- RED：`Saved/Tests/semantic-aot-floating-conversion-red/20260817_062323_795_63e589e8/` — `1/2`；VM/native edge-domain oracle 已通过，只有 emitter eligibility 失败。
- 修复：reviewed floating conversion 同时承认 float32/float64 两方向；emitter 使用原生 `static_cast<float>`，未添加 execution context 或包装算术 helper。浮点与整数互转仍保持 `NonPortableNumericConversion` 边界。
- GREEN build：`Saved/Build/semantic-aot-floating-conversion-green-build/20260817_062424_539_e5a40f17/`。
- GREEN：`Saved/Tests/semantic-aot-floating-conversion-green/20260817_062441_348_0af63c1d/` — `2/2 PASS`；覆盖 signed zero、subnormal、float max、out-of-range double、Infinity 与 NaN。
- 真实导出 Runtime `Print` Raw/VM/Parms：`Saved/Tests/semantic-aot-task44-print-bridge-regression/20260817_064217_384_2a456dab/` — `1/1 PASS`。

## 编译器 HIR 回归中发现的测试 oracle 漂移

完整 TypedSemanticIR 回归首轮为 `61/62`：

`Saved/Tests/semantic-aot-task44-compiler-hir-regression/20260817_063520_102_ad549e29/`

唯一失败的手工 `MakeScalarBranch()` 模型只填了 literal 文本，没有填已经成为 authoritative model 一部分的 `literalBits`，黄金文本也遗漏 `bits=`。真实 compiler capture、enum conversion 和其余 61 项均正常。测试模型现在为 `10/2/1` 填写对应位值，黄金断言在失败时同时打印 Expected/Actual。

- focused：`Saved/Tests/semantic-aot-task44-hir-oracle-green/20260817_063945_513_fdd7b1e7/` — `1/1 PASS`。
- complete HIR：`Saved/Tests/semantic-aot-task44-compiler-hir-regression-green/20260817_064020_504_50fb5ab2/` — `62/62 PASS`。

## 2026-08-17 — 完整边界审计与新增 capability tests

已有 `AngelscriptTypedASTJITScalarOps.h` 实现均在 unsigned bit domain 中定义，未依赖
有符号 C++ 溢出、负数右移或超宽移位：

- `WrapAdd` / `WrapSubtract` / `WrapMultiply` / `WrapNegate`；
- `ShiftLeft` / `LogicalShiftRight` / `ArithmeticShiftRight`，先将 count 归一化为
  `count & (width - 1)`，算术右移显式补符号位；
- `CheckedDivide` / `CheckedRemainder`，除数为零与 signed `MIN/-1` 都先写入
  当前 `FScriptExecution`，再返回确定性零值；
- `ConvertInteger` / `WrapNarrow`，按 AS 的 low-target-bits 与 sign/zero extension
  规则工作。

过去只有少量示例测试，无法证明所有 width/source-sign/count 组合。新增能力测试文件：

`StaticJIT/TypedASTJIT/NumericBoundaries/AngelscriptTypedASTJITIntegralBoundaryTests.cpp`

它覆盖 `int8/uint8/int16/uint16/int32/uint32/int64/uint64`：

- wrapping add/subtract/multiply；
- shift count `-1|0|width-1|width|width+1|100000`；
- signed/unsigned left shift、logical right shift、signed arithmetic right shift；
- 所有 8 种类型的 divide/remainder by zero；
- `int8/int16/int32/int64` 的 `MIN/-1` divide/remainder。

首个 build 暴露的是测试 oracle 自己在未选中的 ternary 分支仍编译 `1ull << 64`，
并非生产 helper 失败：

- RED build：`Saved/Build/semantic-aot-task46-integral-helper-matrix-build/20260817_071404_072_5d4c1eda/`；
- 修复：oracle 用 `if constexpr` 为 64 位宽直接返回 `MAX_uint64`；
- GREEN build：`Saved/Build/semantic-aot-task46-integral-helper-matrix-build-green/20260817_071432_838_70f41d61/`；
- GREEN：`Saved/Tests/semantic-aot-task46-numeric-boundaries/20260817_071450_772_2ce165e9/` — `4/4 PASS`。

`AngelscriptNativeBitwiseOperatorTests.cpp` 的右操作数矩阵从 5 个扩为 7 个，补上
`width+1` 与 large `100000`；总数断言改为从维度计算，不再保留会随矩阵漂移的
硬编码 `1200`。现在运行 `8 integer types * 6 operators * 7 right counts * 5
operand categories = 1680` 个组合：

- 首次 RED：`Saved/Tests/semantic-aot-task46-bitwise-matrix/20260817_070828_984_32051e06/`；
  所有新增操作语义已通过，唯一失败是旧 `1200` 完整性断言；
- GREEN：`Saved/Tests/semantic-aot-task46-bitwise-matrix-green/20260817_070931_630_5fbab1c6/`
  — `1/1 PASS`，1680 cells 全部执行。

`AngelscriptNativeOperatorFailureTests.cpp` 新增 `SignedRemainderOverflow`，证明
`INT64_MIN % -1` 设置 `Overflow in integer division`、抑制后续 side effect，并在
cleanup/recovery 后继续工作。矩阵总数同样改为维度计算：`17 * 2 * 3 = 102`。

- 首次运行：`Saved/Tests/semantic-aot-task46-operator-failure-matrix/20260817_071008_074_37583a3f/`；
  新路径全部通过，唯一失败是旧 `96` 总数断言；
- GREEN：`Saved/Tests/semantic-aot-task46-operator-failure-green/20260817_071758_351_8f6ce7a9/`
  — `1/1 PASS`，102 cells 全部执行。

`AngelscriptStaticJITExceptionTests.cpp` 新增 Typed scalar helper 与原有异常 wrapper
共用合约的运行测试：`CheckedDivide<int32>(7, 0)` 与
`CheckedRemainder<int64>(MIN, -1)` 都使用当前线程/Engine 的
`FScriptExecution`，写入既有消息并恢复临时 execution registration。聚焦前缀：

- `Saved/Tests/semantic-aot-task46-exception-contract/20260817_071834_198_6a3a31c9/`
  — `5/5 PASS`。

## `NonPortableNumericConversion` 的 typed fallback

Analyzer 枚举已经声明 `NonPortableNumericConversion`，但真实 float/integer
转换此前落入笼统的 `UnsupportedExpression`。这既不满足 typed diagnostic，也可能
让以后误开未经审查的原生 cast。

新增
`TypedASTJIT/NumericBoundaries/AngelscriptTypedASTJITNumericConversionFallbackTests.cpp`
通过真实 compiler HIR 检查四个方向：float64→signed、float32→unsigned、
signed→float64、unsigned→float32。当前没有经过审查、跨平台一致的 AS shared
primitive，因此四者必须 ineligible，且精确原因为 `NonPortableNumericConversion`。

- RED build：`Saved/Build/semantic-aot-task46-nonportable-red-build/20260817_070410_251_12a1b0ae/`；
- RED：`Saved/Tests/semantic-aot-task46-nonportable-red/20260817_070428_578_ae647ce8/`
  — `0/1`，第一项实际为旧的 generic reason；
- 修复：在所有已审查 conversion form 与 power 特例都不匹配之后，精确识别
  float↔integer，并返回 `NonPortableNumericConversion`；未扩大 emitter eligibility；
- GREEN build：`Saved/Build/semantic-aot-task46-nonportable-green-build/20260817_070521_960_d5cb9767/`；
- GREEN：`Saved/Tests/semantic-aot-task46-nonportable-green/20260817_070539_351_2e46124a/`
  — `1/1 PASS`。

## 浮点、enum、bool 与真实 AOT 差分证据

- Typed float native/VM edge domain：
  `Saved/Tests/semantic-aot-task46-floating-boundaries/20260817_072004_153_b1220f2d/`
  — `2/2 PASS`；覆盖 `+0/-0`、subnormal、最大有限值、out-of-range double、
  Infinity、NaN，并验证只生成已审查的 float64→float32 `static_cast<float>`。
- maintained fork numeric construction/range matrix：
  `Saved/Tests/semantic-aot-task46-native-numeric-boundaries/20260817_072040_233_ebf7d7ab/`
  — `3/3 PASS`；覆盖 assignment/argument/return/explicit-cast 形式。
- enum representation：fixture 扩为 underlying `int8` 的 `-128/0/1/127`，要求
  生成 `WrapNarrow<int8>` 与精确 switch case：
  `Saved/Tests/semantic-aot-task46-enum-representation/20260817_071921_738_9a2d41e6/`
  — `1/1 PASS`。
- native bool normalization/context matrix：
  `Saved/Tests/semantic-aot-task46-bool-normalization/20260817_072119_273_0d2de8c9/`
  — `1/1 PASS`；所有接受路径的观察值严格归一化为 `0/1`。
- 真实 AOT differential：
  `Saved/Tests/semantic-aot-task46-aot-numeric-differential/20260817_072219_359_0a5dfd4c/`
  — `1/1 PASS`；同一 fixture 比较 Interpreter、Bytecode Raw/VM/Parms、Typed
  Raw/VM/Parms，覆盖 wrapping、masked shifts、checked divide/remainder 与 bool
  normalization。unexpected fallback 会使测试失败。

## 结论

Task 4.6 已闭环。所有可生成整数操作都有显式、无 UB 的 shared helper 和宽度矩阵；
异常 helper 进入既有 `FScriptExecution` 合约；float/enum/bool 边界均有 native、
Typed/VM 或 AOT differential 证据。没有 reviewed shared primitive 的 float↔integer
转换继续 fail closed，并稳定报告 `NonPortableNumericConversion`，未用平台相关 C++
cast 扩大能力面。
