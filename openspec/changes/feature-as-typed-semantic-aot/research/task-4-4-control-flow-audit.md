# Task 4.4 控制流 emitter 渐进审计

日期：2026-08-17

## 本轮范围

本轮只关闭 task 4.4/4.5 中已经由真实源码暴露的两个纵向缺口：

1. `void` 函数的 early/multiple `return;` 无法由 verified HIR 生成 C++。
2. loop condition 或 for increment 内的 checked scalar 子表达式失败后，后续 operand、mutation target 或 store 仍可能被生成代码求值。

本轮没有宣称 task 4.4 或 4.5 整体完成。nested branch、完整 loop phase、switch disposition、verified transfer target、非空 cleanup plan 和 runtime exception/side-effect matrix 仍需继续按能力目录覆盖。普通 call argument 的逐参数失败屏障归 task 5.7，本轮没有借 scalar 修复提前扩张该边界。

## 既有覆盖审计

- `AngelscriptTypedASTJITGeneratedOutputTests.cpp` 已有 synthetic verified-HIR 的 `for`、`while`、`do-while`、`switch`、fallthrough 和 exhaustive-enum C++ 结构断言。
- `AngelscriptStaticJITAotTests.cpp` 已有 checked generated fixture 的 interpreter / BytecodeJIT / TypedASTJIT 基础控制流 parity。
- 上述覆盖没有使用真实编译器生成的 void-return HIR，也没有证明失败的左 operand/RHS 会在后续副作用前立即停止。
- 新测试按能力拆到 `StaticJIT/TypedASTJIT/ControlFlow/Returns/` 与 `ControlFlow/Loops/`，没有继续扩大原有大型测试文件。

## RED 证据

### 有效 RED：void early/multiple return

测试：

`Angelscript.TestModule.StaticJIT.TypedASTJIT.ControlFlow.Returns.FAngelscriptTypedASTJITReturnEmissionTests.VoidEarlyAndMultipleReturnsEmitWithoutAValueExpression`

报告：

`Saved/Tests/semantic-aot-task44-void-return-red/20260817_053424_410_baa2237c/`

结果：`0/1`，失败原因是：

```text
StopAtSelectedBranch control-flow emission failed:
Expression ID is outside the verified arena
```

对应 HIR 是合法的 void-return 形状：Return statement 有 explicit return safe-point、cleanup plan 与 exited-scope 计数，但 `valueExpression` 按设计无效。根因是 emitter 对所有 Return 无条件调用 `EmitExpression(Statement.valueExpression)`。

### 被丢弃的无效 fixture

初版 loop fixture 直接修改函数参数 `Counter`。 maintained compiler 将该参数视为只读，因此源码在进入 HIR/emitter 前就编译失败：

`Saved/Tests/semantic-aot-task44-loop-exception-red/20260817_053502_264_d42c56b8/`

该运行不是合法 behavior RED，不能作为 production 缺陷证据。fixture 随后改为先复制到可变局部变量 `LocalCounter`。

### 有效 RED：失败 operand/RHS 后仍有副作用

测试：

`Angelscript.TestModule.StaticJIT.TypedASTJIT.ControlFlow.Loops.Exceptions.FAngelscriptTypedASTJITLoopExceptionEmissionTests.FailingLoopOperandsStopBeforeLaterEffectsAndStores`

报告：

`Saved/Tests/semantic-aot-task44-loop-exception-valid-red/20260817_053606_958_e9e2f407/`

结果：`0/1`。真实源码、编译、HIR 验证和 emitter 调用都成功，两个生成输出断言失败：

- `(10 / Divisor) > ++LocalCounter` 的 checked left operand 后没有在 right increment 前检查 `Execution.bExceptionThrown`。
- `Counter = 10 / Divisor` 的 RHS 后没有在 mutation target/store 前检查 `Execution.bExceptionThrown`。

根因不是 loop lowering；Binary 和 Assignment emitter 虽然按 HIR 顺序物化临时值，却只依赖外层 statement/loop 完成后的函数级检查，检查点晚于同一表达式内部的后续副作用。

## 实现决策

生产修改位于：

`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEmitter.cpp`

### Void return

- `ReturnCppType == void` 且 HIR 没有 value expression：生成原生 `return;`。
- 非 void 返回缺少 value：emitter fail-closed，不生成部分 C++。
- void 返回意外携带 value：emitter fail-closed。

### Expression failure barrier

- Assignment 在 RHS 临时值物化后、mutation target 解析/store 前插入表达式级异常返回。
- Binary 在左、右 operand 临时值物化后分别具备异常返回边界，保证后续 operand/native operation 不越过已失败子表达式。
- barrier 按当前 operand/RHS 的 HIR 子树判定，只在子树包含 checked `/`、`%`、`**` 时生成；不按“整个函数是否需要 Execution”粗粒度插入。
- 生成的 lambda 使用自身 expression C++ type 返回 `Type{}`，不错误复用外层函数返回类型。

### 回归中发现并修正的粒度问题

第一版按函数级 `bRequiresExecutionState` 在所有 Binary operand 后生成检查，造成纯 `CheckedPower(Symbol, Symbol)` 的两个无失败 operand 前出现冗余分支。完整 GeneratedOutput 首轮为 `24/25 PASS`，唯一失败：

`PowerEmitsOnlyCompilerProvenFloatingShapes`

报告：

`Saved/Tests/semantic-aot-task44-generated-output-regression/20260817_054412_270_ad4840e9/`

最终实现改为遍历刚完成求值的具体 HIR 子树；纯 symbol/literal 不生成屏障，嵌套 checked scalar 表达式仍生成。该决定避免无意义 C++ 膨胀，同时保持异常后的副作用隔离。

## GREEN 证据

官方构建入口：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label semantic-aot-task44-subtree-check-green-build `
  -TimeoutMs 1800000 -NoXGE
```

结果：PASS，4 个增量 action。

报告：

`Saved/Build/semantic-aot-task44-subtree-check-green-build/20260817_054606_364_584971af/`

Focused control-flow：

```text
Angelscript.TestModule.StaticJIT.TypedASTJIT.ControlFlow
2/2 PASS
```

报告：

`Saved/Tests/semantic-aot-task44-control-flow-green/20260817_054659_917_d785624f/`

TypedASTJIT GeneratedOutput：

```text
Angelscript.TestModule.StaticJIT.GeneratedOutput.TypedASTJIT
25/25 PASS
```

报告：

`Saved/Tests/semantic-aot-task44-generated-output-green/20260817_054739_527_f6e832aa/`

既有 AOT 控制流 parity：

```text
Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.
TypedASTStructuredControlFlowMatchesInterpreterAndBytecodeJIT
1/1 PASS
```

报告：

`Saved/Tests/semantic-aot-task44-aot-control-flow-green/20260817_054814_849_2c30321d/`

## 后续覆盖边界

task 4.4/4.5 下一批继续拆分为：

- `ControlFlow/Branches/`：nested if/else、condition failure 与 branch-side effects。
- `ControlFlow/Loops/`：for/while/do-while 的 condition/body/continue/increment phase 与 exception matrix。
- `ControlFlow/Switch/`：switch-in-loop、loop-in-switch、fallthrough/default/scoped case/exhaustive invalid enum。
- `ControlFlow/Returns/`：typed early/multiple return 与 runtime parity。
- `ControlFlow/Cleanup/`：loop-local scopes、exited-scope cleanup；非空 managed cleanup 仍由 task 4.17 打开。

## 2026-08-17 第二批：能力目录矩阵

新增的真实 compiler -> verified HIR -> TypedASTJIT emitter 测试继续按能力拆分，没有扩大原有大型测试文件：

- `ControlFlow/Branches/AngelscriptTypedASTJITBranchEmissionTests.cpp`
  - nested `if / else if / else`；
  - checked outer condition 的失败屏障必须先于分支选择；
  - 三个条件分别物化，且不生成 `goto` 或 `FAngelscriptJITExecutionContext`。
- `ControlFlow/Loops/AngelscriptTypedASTJITLoopPhaseEmissionTests.cpp`
  - `for` / `while` / `do-while` 的 `continue` 保留原生结构；
  - `for` 的第一个 increment 失败时，increment lambda 必须在第二个 increment 前 `return`。
- `ControlFlow/Switch/AngelscriptTypedASTJITSwitchEmissionTests.cpp`
  - switch-in-loop 与 loop-in-switch；
  - 显式 `fallthrough` case 到下一 case 之间不得插入隐式 `break`；
  - scoped case local、default 与 exhaustive enum invalid-value edge；
  - invalid edge 明确调用 `SetSwitchValueInvalidException(Execution)` 并返回确定性零值。
- `ControlFlow/Cleanup/AngelscriptTypedASTJITTransferCleanupTests.cpp`
  - switch 内 `continue` 的 target 是外层 `for`，switch 内 `break` 的 target 是 switch，switch 后 `break` 的 target 是 `for`；
  - 每个 break/continue/return 都引用唯一 compiler-authored `VerifiedEmpty` universal plan；
  - 至少一个 transfer 明确记录 exited scope，但 plan 的 reverse-live slot 集为空；
  - 篡改 continue target 或清空 cleanup plan 时，pipeline 在生成任何 C++ 前 fail-closed。

### 一次有效的 fixture RED 与边界归属

首轮矩阵为 `5/6 PASS`：

`Saved/Tests/semantic-aot-task44-control-flow-matrix-red/20260817_060155_290_ad3e8d92/`

唯一失败 fixture 先写了：

```angelscript
EFlowMode Mode = EFlowMode(RawMode);
```

真实 HIR 同时保留 resolved enum Conversion child 和外层
`Unsupported(ConstructionOrLifetime)` marker；local initializer 以外层 marker 为执行节点，TypedASTJIT 因此正确拒绝，而不是绕过 marker 猜测可执行 conversion。该现象属于 task 4.6 的 enum conversion/representation 边界，不是 switch lowering 缺陷。4.4 fixture 改为直接接收 enum 参数，只隔离验证 exhaustive switch 语义；没有为让测试变绿而放宽 production eligibility。

### GREEN 证据

新增源码后的官方构建：

`Saved/Build/semantic-aot-task44-control-flow-matrix-build/20260817_060113_687_c59d163f/` — PASS，5 actions。

fixture 修正后的官方构建：

`Saved/Build/semantic-aot-task44-control-flow-fixture-green-build/20260817_060251_548_bb878379/` — PASS，4 actions。

switch exact：

`Saved/Tests/semantic-aot-task44-switch-fixture-green/20260817_060312_469_766b94b7/` — `1/1 PASS`。

完整 capability-owned control-flow prefix：

`Saved/Tests/semantic-aot-task44-control-flow-matrix-green/20260817_060352_181_16f6cde4/` — `6/6 PASS`，zero failed/skipped。

这批证据闭环了生成侧的结构、target gate 和 scalar empty cleanup gate，但尚未单独执行每个 loop phase 的 AOT exception/side-effect runtime differential，也没有打开 non-empty managed cleanup。因此 task 4.4/4.5 继续保持未勾选。

## 2026-08-17 第三批：AOT 阶段矩阵与最终审计

### 最终缺口审计

第二批只证明生成结构，最终审计没有直接把它当成运行等价证据。逐项对照 task 4.4 后确认还缺少：

- `do-while` 的 body、continue 到 condition 和 condition 异常运行路径；
- `while` continue 回 condition、while body 和 `for` condition 的运行异常路径；
- nested early/multiple return 的所有生成入口运行结果；
- switch fallthrough/default/scoped case local 的所有生成入口运行结果。

现有 `SemanticCloneableState` 是已经拥有独立 Interpreter、BytecodeJIT Raw/VM、TypedASTJIT Raw/VM/Parms 载体的 cloneable fixture，因此继续扩展它的 mode 表，而没有在旧的 7000 行 AOT 文件中新增第二个大测试方法。异常能力仍由独立的 `AOT/ControlFlow/AngelscriptTypedASTJITControlFlowExceptionParityTests.cpp` 所有。

### 有效 RED

只扩展期望矩阵、尚未增加 AS mode 时：

- `Saved/Tests/semantic-aot-task44-runtime-matrix-exceptions-red/20260817_064553_122_6a475e4f/` — `0/1`；第一个新增 `do-while-continue-to-condition` case 仍走旧 default，没有产生预期异常。
- `Saved/Tests/semantic-aot-task44-runtime-matrix-values-red/20260817_064634_273_43d8e01f/` — `0/1`；新增正常 `do-while` mode 实际返回旧 default `-1`，而测试要求 `553`。

这两次都是合法行为 RED：构建成功，旧生成 artifact 与同版本 Interpreter 一致，只是尚未存在新增 fixture 行为。

### Fixture 扩展

`SemanticCloneableState` 新增彼此独立的 mode：

- `8`：`do-while` body 的 `continue` 必须进入 checked condition；
- `10`：`do-while` body 的 checked division 必须抑制后续 `Trace += 100`；
- `11`：`while` 第一次短路通过，body `continue` 后第二次 condition 才发生 checked failure；
- `12`：`for` condition checked failure；
- `13`：`while` body checked failure；
- `14`：正常 `do-while` body/continue/condition phase 与局部变量作用域；
- `15`：nested if/else、early return 和 multiple return；
- `16`：switch fallthrough、default、scoped case local 和 break。

旧 mode `4/5/6/7` 继续分别拥有 while condition、for body、for continue-to-increment 和 switch selector failure。mode `3` 继续覆盖 while、for、switch-in-loop、break/continue 和 loop-local scope。exhaustive enum 的非法值继续由独立 enum differential 覆盖。

### GREEN 与正式产物证据

- fixture/build：`Saved/Build/semantic-aot-task44-runtime-matrix-fixture-build/20260817_064751_646_a5ec302d/` — PASS。
- deterministic Generate：`Saved/Commandlet/semantic-aot-task44-runtime-matrix-generate/20260817_064810_481_449669e7/` — PASS，0 errors。
- generated C++ build：`Saved/Build/semantic-aot-task44-runtime-matrix-generated-build/20260817_064936_855_92d40a41/` — PASS；独立 Bytecode/Typed cloneable artifacts、模块 `.jit.cpp` 和 Provider 均实际编译链接。
- 九个异常 phase：`Saved/Tests/semantic-aot-task44-runtime-matrix-exceptions-green/20260817_064948_805_e9ebd1d3/` — `1/1 PASS`；每个 phase 均比较 Interpreter 与 Bytecode Raw/VM、Typed Raw/VM/Parms，并要求 first exception 与确定性失败值。
- 正常控制流值矩阵：`Saved/Tests/semantic-aot-task44-runtime-matrix-values-green/20260817_065026_385_ff51806a/` — `1/1 PASS`；所有六条执行路线逐 case 等值。
- current artifact Verify：`Saved/Commandlet/semantic-aot-task44-runtime-matrix-verify/20260817_065112_276_f5a0be22/` — PASS。
- capability-owned golden/control-flow：`Saved/Tests/semantic-aot-task44-runtime-matrix-control-flow-regression/20260817_065239_784_d92f643e/` — `6/6 PASS`。
- complete Typed generated-output：`Saved/Tests/semantic-aot-task44-runtime-matrix-generated-output-regression/20260817_065315_824_d38d3ed1/` — `25/25 PASS`。
- exhaustive enum Raw/VM/Parms differential：`Saved/Tests/semantic-aot-task44-runtime-matrix-enum-regression/20260817_065357_628_e47a4d58/` — `1/1 PASS`。

### Task 4.5 implementation authority

最终源码审计确认：

- `EmitStatement` 递归消费 verified HIR 的 block/then/else/body/initializer/increment/case 关系；
- loop condition 与 for increment 只使用 HIR phase/children/evaluation sequence；
- break/continue 的 target ID 与 cleanup plan 在 analyzer/verifier 先验校验，篡改任一字段都在产生部分 C++ 前失败；
- case 的 `fallsThrough` 决定是否生成 `break`，不从 bytecode offset 或生成标签反推；
- exhaustive enum 明确生成 `default -> SetSwitchValueInvalidException(Execution) -> deterministic failure return`；
- Typed emitter 不读取 BytecodeJIT control-flow analysis，也不生成 `goto`。

### 清理边界

task 4.4 的 exited-scope cleanup 在当前 scalar slice 由 compiler-authored `VerifiedEmpty` universal plan、每条 transfer 的 plan ID/exited-scope count、篡改 fail-closed 和真实作用域运行结果共同证明。它不声称对象/句柄已有空清理。non-empty managed lifetime slot、partial construction、reverse-live destruction 和 cleanup failure 仍严格归 task 4.17，保持未勾选。

因此 task 4.4 与 4.5 在当前既定 scalar TypedASTJIT 范围内闭环并勾选完成。
