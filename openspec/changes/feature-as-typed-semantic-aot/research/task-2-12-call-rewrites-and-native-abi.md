# Task 2.12：最终调用重写、参数来源与 Native ABI 记录

## 结论

Task 2.12 已经按 maintained compiler 的最终语义闭环。Typed semantic HIR
现在区分两类节点：

- `ResolvedCall` 只表示字节码最终仍会执行的 `CompileCalls`；
- `CallRewrite` 只表示 `CompileOutEntirely`、`ReplaceWithFirstParam` 或
  `CompileOutAsMethodChain` 的最终值，不携带可执行目标计划。

因此 TypedASTJIT 不会把 AS 编译器已经裁掉的调用重新发射成 C++ 调用。
保留下来的 receiver/值仍按最终 HIR 发射；完全裁掉的调用发射 `(void)0`。

## 权威捕获位置

捕获发生在 maintained fork 已经完成 overload、default/hidden argument、
determines-output-type 和 compile-out 决策之后：

- 普通最终调用通过 `AddResolvedCall()` 捕获；
- 三种 compile-out 分支在各自早退点通过 `AddCallRewrite()` 捕获；
- `CompileOutEntirely` 即使先调用 `SetVoidExpression()` 清除了旧 typed
  expression ID，也会发布一个新的最终 void rewrite marker；
- `ReplaceWithFirstParam` 保留被选择的最终参数值；
- `CompileOutAsMethodChain` 只保留真实 receiver，null marker 不被伪装成
  可执行 call。

捕获仍然是 sidecar observer，不参与 overload、bytecode 或 VM 语义决策。

## 参数的三种不同视图

每个最终 `ResolvedCall` 同时记录：

1. `operands`：编译器最终实际求值的 operand；
2. `formalParameterIndices`：每个 operand 对应的最终 formal；
3. `argumentOrigins`：`ScriptVisibleOrDefault`、`HostHidden` 或 `Receiver`；
4. `evaluationSequence`：权威求值顺序，不从 C++ 参数顺序反推。

`hiddenArgumentIndex` 和 `determinesOutputTypeArgumentIndex` 单独记录在
function header 和 call 上。WorldContext/host hidden default 因此不会被计入
AS 可见参数，也不会和 mixin/external receiver 混为一谈。Verifier 要求
hidden formal 恰好有一个 `HostHidden` origin，并要求 receiver alias 只映射
到唯一 formal zero。

## Pointer-free Native ABI 记录

系统函数的最终 call 额外携带 `asSTypedSemanticNativeCallRequirements`：

- call convention、base offset、script return/parameter size；
- `ScriptFunction` / `ScriptObjectType` first-param metadata；
- generic context、function user data、function caller；
- returns-on-stack 与 cleanup argument count。

这些字段只有标量、枚举和布尔事实，不保存 `asSSystemFunctionInterface*`、
函数指针、Engine-local object pointer 或可执行 closure。非 system call 必须
保持该记录为空；测试也覆盖 script call 从 system fixture 改写后必须清空
native-only plan。

## 实现期间发现的问题

### 1. Void rewrite 丢失最终 HIR identity

最初 `CompileOutEntirely` 在 `SetVoidExpression()` 后没有最终 expression ID，
导致 caller HIR 整体缺失。修复是在最终早退点发布独立 `CallRewrite`，而不是
复活原 call。

### 2. 隐藏参数不能从 formal/operand 数量猜测

WorldContext hidden default 与普通 default 都进入最终 formal 表，但语义来源
不同。新增 `argumentOrigins` 后，host-only 值可被 verifier、dump、analyzer
直接识别，不再依赖参数名或位置猜测。

### 3. 测试中的 implicit handle 写法先触发了语法错误

RED fixture 最初使用了不符合 maintained frontend 的显式 `@` 形状。修正为
真实 implicit-handle declaration 后才接受后续 RED，避免把 parser rejection
误当成 HIR 缺失。

### 4. 严格 verifier 暴露旧 synthetic fixture

受影响面回归最初为 eligibility `28/30`、generated output `19/25`。根因不是
生产 verifier 过严，而是旧测试把 `Symbol` 只改成 `PropertyAccess` 却没有
receiver/target、CompilerExceptionRegion header 没有稳定 marker，以及 script
call 残留 system native ABI 字段。夹具已改成合法 `Lambda` unsupported marker、
补齐 `compiler-exception-region` marker，并清空非 system native plan。

同一轮还同步了此前已实现且已记录的 emitter golden：普通 eager binary 先按
HIR 顺序物化左右值；integer divide 和 floating power 使用当前
`FScriptExecution` 的 checked helper。没有回退这些已经通过 differential 的
AS/VM 一致性修复。

### 5. Worktree 入口保护

一次测试从物理 worktree 路径启动，被 runner 正确拒绝，因为本 change 的
`ProjectFile` 是 `V:\AngelscriptProject.uproject`。后续全部命令从 `V:\` 启动；
这属于隔离保护生效，不是产品失败。

## RED / GREEN 证据

RED：

- build：`Saved/Build/typed-semantic-task212-call-red-build4/
  20260816_235041_068_435a499b/` — test fixture build PASS；
- combined call prefix：`Saved/Tests/typed-semantic-task212-call-red/
  20260816_234801_561_f1bd277c/` — `0/3`，三项均为预期 RED；
- hidden argument exact：`Saved/Tests/typed-semantic-task212-hidden-red2/
  20260816_235057_987_64b01237/` — `0/1`；
- native ABI exact：`Saved/Tests/typed-semantic-task212-nativeabi-red/
  20260816_235135_364_dc2c7d3a/` — `0/1`。

GREEN：

- production build：`Saved/Build/typed-semantic-task212-call-green-build/
  20260817_000551_801_742bd84d/` — PASS，29/29 actions；
- focused call partition：`Saved/Tests/typed-semantic-task212-call-green/
  20260817_000630_588_5f596b29/` — `3/3 PASS`；
- complete TypedSemanticIR：`Saved/Tests/typed-semantic-task212-full-green/
  20260817_000711_876_48b83539/` — `49/49 PASS`；
- affected eligibility/call closure：
  `Saved/Tests/typed-semantic-task212-staticjit-eligibility-green2/
  20260817_001720_443_e192105d/` — `30/30 PASS`；
- affected generated output：
  `Saved/Tests/typed-semantic-task212-staticjit-generated-output-green/
  20260817_002141_574_d899db91/` — `25/25 PASS`；
- final affected build：
  `Saved/Build/typed-semantic-task212-generated-golden-build/
  20260817_002121_636_34122258/` — PASS。

## 后续边界

- Task 2.13 继续补齐 ordinary call、constructor、index、chain、assignment、
  binary 和 nested cast 的完整 evaluation sequence oracle；本任务不提前把
  所有 call shape 宣称完成。
- Task 2.14 增加 named/default 的声明来源与 caller processed span；当前
  `ScriptVisibleOrDefault` 只完成 source/host/receiver 的第一层区分。
- Task 2.16 处理 imported binding slot，不能冻结 mutable `boundFunctionId`。
- Task 4.1 仍负责独立的 compile-out generated-output golden 扩展；本任务只
  完成 compiler capture、consumer acceptance 和受影响面回归。

