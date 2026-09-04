# AS_TypedSemanticHIRToLLVM — Typed Semantic HIR 到 LLVM IR 的适用性研究

> 记录日期：2026-08-20  
> 文档性质：架构研究与验证路线，不代表 LLVM HIR 后端已经进入主线或具备生产支持  
> 前置阅读：`AS_TypedSemanticHIR.md`、`AS_ByteCode.md`、`RT_StaticJIT.md`

---

## 一、研究目标

本文研究以下问题：

1. 当前 AngelScript Typed Semantic HIR 和 LLVM IR 分别解决什么问题；
2. “AngelScript AST 直接生成 LLVM IR”与当前 HIR 路线有什么区别；
3. 当前 HIR 是否包含足够的信息生成 LLVM IR；
4. HIR 到 LLVM IR 的主要工程难点和预计工作量；
5. `W:\Temp\cppvm` 所谓“嵌入 LLVM IR 虚拟机”实际采用什么技术；
6. 本地 LLVM/Angelsea worktree 已经验证了哪些基础设施；
7. 如果要验证 HIR 的适用性，最小、可靠的实验路线是什么；
8. LLVM 应该替代 HIR、替代 VM，还是作为 HIR 的一个后端。

本文基于以下本地源码和研究资料：

- 当前主工作区的 Typed Semantic HIR 实现；
- 已完成的 `feature-as-typed-semantic-aot` 研究记录；
- `W:\Temp\cppvm` 及其内置 LLVM 11.1.0 源码；
- `W:\UnrealLLVM` 中的 LLVM 18.1.6 和旧 asllvm 参考实现；
- `.worktrees\feature-as-angelsea-llvm-jit-plugin` 中的 LLVM 22.1.8/ORC PoC；
- `Reference\daScript` 中 typed AST 到 LLVM IR 的实现。

---

## 二、结论摘要

结论如下：

1. **当前 Typed Semantic HIR 适合作为 LLVM 后端的输入。**
2. **HIR 与 LLVM IR 不是互相替代的两种方案，而是两个不同层级。**
3. HIR 是 AngelScript 语言语义层；LLVM IR 是 CFG、SSA、内存和目标后端层。
4. 对当前 TypedASTJIT 已支持的标量和结构化控制流子集，HIR 到 LLVM IR 的映射比较直接。
5. 真正困难的不是调用 LLVM API，而是保持 AngelScript 的精确语义、ABI、生命周期和运行时行为。
6. 如果所谓“AST 直接 LLVM”使用的是完成类型和符号解析的 Typed/Resolved AST，它与 HIR 直接 LLVM 在原理上很接近。
7. 如果使用的是原始 Parser AST，LLVM emitter 最终必须重新实现语义分析，长期不适合当前多后端架构。
8. `cppvm` 运行时使用的是修改过的 LLVM Interpreter，不是 LLVM ORC JIT，也不是以优化为主要目标的语言 VM。
9. Angelsea LLVM worktree 已验证 LLVM 22.1.8、LLVM Verifier、ORC LLJIT、宿主符号、代码租约和发布生命周期，但当前输入是 Bytecode，不是 HIR。
10. 该 worktree 当前没有接入明确的 `LLVMRunPasses`/PassBuilder 优化流水线，因此不能据此声称 LLVM 优化已经落地。
11. 第一阶段不必先设计新的 Typed CFG IR；可以直接做受限的 HIR 到 LLVM IR lowering，用实现结果验证是否需要中间优化层。
12. 长期如果需要复杂的 AngelScript 专用优化，建议在 HIR 与 LLVM IR 之间增加 backend-neutral Typed CFG/Optimization IR。
13. 生产路径更适合优先研究 HIR 到 LLVM object/AOT；Runtime ORC HIR JIT 还受到 HIR 仅在 source compile 期间存在的限制。
14. 现有 Bytecode/VM 必须继续保留为完整语义执行路径和逐函数 fail-closed fallback。

推荐的长期分层是：

```text
Source
  ↓
Parser AST
  ↓
Semantic Compiler
  ↓
Verified Typed Semantic HIR
  ├──────────────────────────────→ C++ TypedASTJIT emitter
  ├──────────────────────────────→ 静态分析/诊断
  ↓
可选：AS Typed CFG / Optimization IR
  ↓
LLVM IR
  ↓
LLVM Verifier
  ↓
LLVM Passes
  ↓
ORC JIT / Object / AOT

并行保留：Source → Bytecode → VM
```

---

## 三、AST、HIR、LLVM IR 分别是什么

### 3.1 Parser AST

Parser AST 的主要职责是表达源代码语法结构，例如：

```text
BinaryExpression("+")
CallExpression("Foo")
IdentifierExpression("Value")
IfStatement
WhileStatement
```

Parser AST 通常还不能完整回答：

- `+` 最终是整数运算、浮点运算、枚举运算还是重载调用；
- `Foo` 最终绑定到哪个函数；
- 是否插入隐式转换；
- receiver/implicit `this` 是什么；
- 属性是字段访问还是 getter/setter 调用；
- 默认参数、hidden argument 和普通参数如何求值；
- handle/ref/object 是否需要生命周期动作；
- return、break、continue 离开作用域时需要什么 cleanup。

因此，原始 Parser AST 不应该直接成为多个 native backend 的公共契约。

### 3.2 Typed Semantic HIR

当前 HIR 是完成语义分析后的函数级语义快照。它保存：

- 精确 `asCDataType`；
- symbol ID 和 symbol 类别；
- 已解析的调用目标；
- receiver 和调用 provenance；
- 隐式/显式转换；
- evaluation steps；
- mutation target/value；
- 结构化 statement 和控制转移目标；
- source span；
- cleanup plan 和验证状态；
- verifier 可检查的 arena ID 引用关系。

从表示分类看，它也是一种 typed semantic AST/HIR：statement 是结构化树，expression 是通过 ID 连接的有序 graph/DAG。这里把它称为 HIR，是为了强调它已经脱离 Parser AST 对象、完成语义规范化，并作为可验证的后端契约；不是声称 HIR 与 typed AST 必然属于两种互斥的数据结构。它与 daScript 最终 typed/normalized `Function + Expression` 图处在同一抽象层级，但当前实现使用独立 arena、基于 ID 且不依赖 Parser node 的 graph 引用、显式求值步骤和清理计划。注意 `asCDataType` 仍含 Engine-local `asCTypeInfo*`，所以 live HIR 不是整体可序列化的 pointer-free DTO。

关键定义位于：

```text
Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
    as_typed_semantic_ir.h
    as_typed_semantic_ir.cpp
```

HIR 回答的是：

> 这个 AngelScript 函数在完成语义解析以后，精确地“是什么意思”。

### 3.3 LLVM IR

LLVM IR 是面向优化和机器码后端的低级 IR。其核心概念是：

- function；
- basic block；
- SSA value；
- `phi`；
- `br`/`switch`；
- `alloca`；
- `load`/`store`；
- `call`；
- target triple；
- data layout；
- calling convention；
- LLVM undefined behavior 和 poison 规则。

LLVM IR 本身不知道：

- AngelScript handle；
- AS Context；
- script exception；
- GC root；
- property getter/setter；
- UObject；
- suspend/resume；
- AngelScript 的参数求值顺序；
- AngelScript 的对象 cleanup 规则。

这些必须在 HIR lowering 或 runtime helper 中显式表达。

---

## 四、HIR 与 LLVM IR 的层级差异

| 维度 | Typed Semantic HIR | LLVM IR |
|---|---|---|
| 主要职责 | 固定 AngelScript 语义 | 表达可优化的控制流、数据流和内存操作 |
| 抽象层级 | 语言级、中高层 | 后端级、低层 |
| 控制流 | 结构化 statement | Basic block、branch、switch |
| 值模型 | Expression ID、Symbol ID、language value | SSA value 或内存地址 |
| 类型 | `asCDataType` 和 AS 类型语义 | LLVM integer/float/vector/aggregate/pointer type |
| 变量 | 参数、局部、全局、属性、引用 | SSA value、alloca、load/store、global |
| 调用 | 已解析目标、receiver、参数计划、provenance | Function type、callee、arguments、calling convention |
| 求值顺序 | HIR `EvaluationSteps` | 必须由 LLVM 指令排列显式保持 |
| 生命周期 | Cleanup Plan、AS 对象/handle 语义 | cleanup blocks 和 helper calls |
| 异常 | AS Context/语言异常语义 | 显式状态边或 LLVM EH |
| 优化依据 | AS 语言规则 | LLVM IR flags、attributes、alias 和 UB 规则 |
| 目标相关性 | 大部分目标无关 | 受 triple、data layout、ABI 影响 |
| 验证 | HIR Verifier | LLVM Function/Module Verifier |
| 主要消费者 | C++ emitter、未来 LLVM emitter、分析器 | LLVM passes、ORC、object/codegen |

二者的正确关系是：

```text
HIR 负责不丢失语言语义
LLVM IR 负责将已固定的语义表达成可优化的 CFG/SSA
```

把 LLVM IR 当作第一层语言语义 IR，会迫使所有 AS 专用含义过早转换为：

- raw pointer；
- helper call；
- load/store；
- branch；
- opaque runtime state。

这样会降低高级语义优化、诊断、测试和多后端复用能力。

---

## 五、“AST 直接生成 LLVM IR”的两种情况

### 5.1 原始 Parser AST 直接 LLVM

如果 LLVM emitter 读取的是未经完整语义分析的语法树，它必须自行完成：

- 类型推导；
- overload resolution；
- 隐式转换；
- 调用解析；
- receiver 解析；
- property rewrite；
- 默认参数；
- 引用和 handle 规则；
- 求值顺序；
- cleanup；
- unsupported 判定。

这实际上把 semantic compiler 藏进了 LLVM CodeGen visitor。

主要问题是：

- LLVM 后端与 parser/compiler 内部状态耦合；
- 第二个 backend 容易复制语义逻辑；
- 很难单独 dump 和验证语义快照；
- unsupported 情况容易在模块生成一半时才失败；
- AST 生命周期和 arena 所有权容易影响异步/延后 codegen；
- 测试必须通过 LLVM 输出间接验证前端语义。

这种方案不适合当前同时维护 VM、BytecodeJIT、C++ TypedASTJIT、StaticJIT 和未来 LLVM 的架构。

### 5.2 Typed/Resolved AST 直接 LLVM

如果所谓 AST 已经完成：

- type checking；
- symbol resolution；
- call resolution；
- conversion insertion；
- control-flow target resolution；
- lifetime planning；

那么它实际上已经接近 HIR。

本地 `Reference/daScript` 的 LLVM JIT 是类似参考：

```text
Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das
```

其中 `LlvmJitVisitor : AstVisitor` 遍历的是完成类型/符号处理后的 compiler AST，而不是纯 parser syntax tree。

因此，更准确的比较是：

```text
Typed/Resolved AST → LLVM IR

对比

Typed Semantic HIR → LLVM IR
```

两种方案都可以工作。当前 HIR 路线的额外价值是：

- 独立函数级所有权；
- 稳定 arena ID；
- 显式调用 provenance；
- 显式 evaluation plan；
- 显式 cleanup state；
- verifier；
- 多 backend 复用；
- 确定性 dump/fixture；
- 逐函数 fail-closed。

---

## 六、当前 HIR 到 LLVM IR 的直接映射

对当前标量和结构化控制流子集，可以建立以下 lowering：

| HIR 节点/语义 | LLVM lowering |
|---|---|
| Literal | `LLVMConstInt`、`LLVMConstReal`、null/zero constant |
| Parameter symbol | LLVM function argument |
| Local symbol | 初期使用 `alloca`/`load`/`store` |
| Conversion | `trunc`、`zext`、`sext`、`sitofp`、`uitofp`、受保护的 `fptosi` 或 helper |
| Unary | LLVM unary instruction 或 runtime helper |
| Binary | `add/sub/mul`、comparison、逻辑操作或 helper |
| Assignment | target address 单次求值后 `store` |
| Mutation | target 单次求值，随后 load-op-store |
| ShortCircuit | `condbr`、rhs/merge block、`phi` 或临时槽 |
| ResolvedCall | direct call、indirect call、native helper 或 VM bridge |
| Block | 顺序发射语句和必要 blocks |
| If | condition、then、else、merge blocks |
| While/For | header、body、latch、exit blocks |
| Switch | LLVM `switch` 或比较链 |
| Break/Continue | branch 到 HIR 已解析的控制转移目标 |
| Return | cleanup edge，随后 `ret` |
| Cleanup Plan | cleanup blocks、helper calls、异常/早退边 |

### 6.1 第一版不必手工构造完整 SSA

推荐第一版将 mutable local 降为内存槽：

```llvm
%value.addr = alloca i32
store i32 %initial, ptr %value.addr

%value = load i32, ptr %value.addr
%next = add i32 %value, 1
store i32 %next, ptr %value.addr
```

再运行 LLVM 的：

- mem2reg；
- SROA；
- InstCombine；
- SimplifyCFG。

这样可以把 dominance、循环回边和大部分 `phi` 构造交给 LLVM，降低第一版 emitter 的复杂度。

短路表达式或明确值合并既可以直接生成 `phi`，也可以先使用临时槽，再交给 mem2reg。

### 6.2 参数求值顺序必须来自 HIR

例如：

```angelscript
Foo(A(), B())
```

如果 AngelScript 语义要求普通参数按反向 formal order 求值，HIR evaluation plan 可能是：

```text
1. B()
2. A()
3. Foo(AResult, BResult)
```

正确的 LLVM IR 指令顺序应是：

```llvm
%b = call i32 @B()
%a = call i32 @A()
%result = call i32 @Foo(i32 %a, i32 %b)
```

LLVM call operand 的书写顺序不能代替语言求值顺序。带副作用的 operand value 必须提前按 HIR 指定的顺序产生。

### 6.3 Mutation target 必须只求值一次

类似：

```angelscript
GetArray()[NextIndex()] += Value();
```

不能在 load 和 store 时分别重新生成 target。Lowering 必须：

1. 按 HIR evaluation steps 计算 target address；
2. 保存 address；
3. 计算 value；
4. load old value；
5. 执行运算；
6. store 回同一个 address。

这也是 HIR 比直接递归遍历 parser AST 更安全的地方。

---

## 七、LLVM UB 与 poison 是主要语义风险

LLVM IR 的优化建立在严格的 undefined behavior、poison、flags 和 attributes 契约上。

AS 操作符不能机械地替换成同名 LLVM instruction。

### 7.1 整数溢出

如果 AngelScript 整数运算采用位宽 wraparound，则普通 LLVM `add/sub/mul` 可以表达自然截断。

不能无证明地添加：

```llvm
add nsw
add nuw
```

错误的 `nsw`/`nuw` 会让溢出产生 poison，随后 LLVM optimizer 可以基于“溢出不发生”的假设重写控制流。

### 7.2 有符号除法

LLVM `sdiv` 需要处理：

- 除数为零；
- `INT_MIN / -1`。

必须根据 AngelScript 现有语义：

- 设置 AS exception state；
- 进入显式 failure block；
- 或调用语义明确的 runtime helper。

不能直接执行会触发 LLVM UB 的 `sdiv`。

### 7.3 Shift count

LLVM shift count 大于等于整数位宽会产生 poison。

如果 AS 使用屏蔽后的 shift count，lowering 必须明确执行：

```text
i32: count & 31
i64: count & 63
```

### 7.4 浮点转整数

LLVM `fptosi`/`fptoui` 的超范围输入会产生 poison。

必须在 conversion 前：

- 检查 NaN；
- 检查上下界；
- 按 AS 语义截断、饱和或抛出异常；
- 只在安全区间执行 LLVM conversion。

### 7.5 NaN、`-0.0` 和浮点比较

必须逐项确认 AngelScript 比较语义和 LLVM ordered/unordered predicate 的对应关系。

不能仅按 C++ 直觉选择 `oeq`、`olt` 等 predicate。

### 7.6 Helper attributes

对 native/runtime helper 不能轻易标记：

- `readnone`；
- `readonly`；
- `nounwind`；
- `willreturn`；
- `nocapture`；
- `nonnull`；
- `noundef`。

如果 helper 可能：

- 设置 AS exception；
- 修改 Context；
- 触发 GC；
- 调用用户代码；
- suspend；
- 修改 global/import state；

就必须使用保守 attributes。错误 attribute 会导致优化器删除或重排必要调用。

---

## 八、`W:\Temp\cppvm` 的实际架构

### 8.1 仓库结构

```text
W:\Temp\cppvm
└── source
    ├── core
    │   ├── collect
    │   ├── gather
    │   ├── thunk
    │   ├── diff
    │   ├── patch
    │   └── vmlib
    └── llvm
        └── LLVM 11.1.0 source
```

### 8.2 数据流

```text
C++
  ↓ Clang
LLVM IR
  ↓ collect/gather/thunk passes
将调用重写为函数指针表间接调用
  ↓
旧 IR 与新 IR 做 diff
  ↓
patch 外部符号到宿主 RVA
  ↓
运行时加载变化 IR
  ↓
LLVM Interpreter 解释执行
  ↓
libffi closure 连接 native 与 interpreter
```

### 8.3 cppvm 不是 ORC JIT

关键实现：

```text
W:/Temp/cppvm/source/core/vmlib/VmLib.cpp
```

运行时：

- 使用 `parseIR` 读取 IR；
- 显式设置 `EngineKind::Interpreter`；
- 通过 `getPointerToFunction` 获取可调用入口。

native 到 interpreter 的桥接位于：

```text
W:/Temp/cppvm/source/core/vmlib/ExternalFunctions.cpp
```

其中使用：

- `ffi_closure_alloc`；
- libffi closure；
- proxy 进入 `runFunctionImpl`。

解释执行循环位于：

```text
W:/Temp/cppvm/source/core/vmlib/Execution.cpp
```

因此，cppvm 的“嵌入 LLVM IR 虚拟机”准确含义是：

> 将目标相关 LLVM IR 作为运行时中间代码，由修改过的 LLVM Interpreter 在宿主进程内解释，并通过函数指针表、RVA 和 libffi 与 native 代码互调。

### 8.4 对 AngelScript 的参考价值

值得参考：

- thunk table；
- 函数级热补丁；
- 外部 symbol/RVA patch；
- native/IR 双向桥接；
- code image 生命周期；
- IR diff 和变更函数选择；
- LLVM Interpreter 嵌入方式。

不适合直接移植为 AS 主执行路径：

- 它解释 LLVM instruction，不等于 ORC native 性能；
- LLVM 11.1.0 与当前 LLVM 22.1.8 API/IR 代际差异很大；
- 它共享原始宿主指针，不是 sandbox；
- IR 与 target/data layout/C++ ABI 绑定，不是通用跨平台 bytecode；
- 没有 AS Context、GC、suspend、debugger、coverage、timeout 语义；
- 修改 LLVM Interpreter 会产生长期升级和维护成本；
- runtime 没有以标准 LLVM 优化 pipeline 为核心。

因此，cppvm 更适合做热补丁架构参考或 differential oracle，不适合替换 AngelScript VM。

---

## 九、本地 LLVM 版本与参考实现

本地研究中存在三个 LLVM 代际：

| 位置 | LLVM 版本 | 用途 |
|---|---:|---|
| `W:\Temp\cppvm\source\llvm` | 11.1.0 | cppvm 修改过的 LLVM Interpreter 与 IR 热补丁 |
| `W:\UnrealLLVM` | 18.1.6 | UnrealLLVM SDK 和旧 Bytecode→LLVM/asllvm 参考 |
| `.worktrees\feature-as-angelsea-llvm-jit-plugin\Plugins\UnrealLLVM` | 22.1.8 | 当前本地 UE/ORC PoC SDK 契约 |

这三个版本不能混合看待：

- LLVM C API 会演进；
- typed pointer/opaque pointer 模型不同；
- ExecutionEngine/ORC 接口不同；
- bitcode/IR compatibility 不是长期稳定的产品存储契约；
- cppvm 对 LLVM 11 Interpreter 的修改不能直接应用到 LLVM 22。

未来 HIR LLVM backend 的 artifact key 至少应包含：

- HIR schema/version；
- HIR content hash；
- backend revision；
- LLVM version；
- target triple；
- data layout；
- CPU/features；
- optimization pipeline/version；
- Runtime ABI revision；
- helper/export environment identity。

---

## 十、Angelsea LLVM JIT worktree 已验证的内容

相关 worktree：

```text
D:\Workspace\AngelscriptProject\.worktrees\feature-as-angelsea-llvm-jit-plugin
```

主要本地插件：

```text
Plugins/UnrealLLVM
Plugins/AngelseaLLVMJIT
```

### 10.1 当前数据流

```text
AngelScript Runtime JIT Bytecode Snapshot
  ↓
AngelseaLLVMIREmitter
  ↓ LLVM C API
LLVM Module
  ↓
LLVMVerifyModule
  ↓
LLVM ORC LLJIT
  ↓
发布 VMEntry binding
```

### 10.2 已验证的基础设施

- LLVM 22.1.8 SDK 打包和版本检查；
- LLVM C API context/module；
- target/data layout；
- LLVM Module Verifier；
- ORC LLJIT session；
- absolute helper symbols；
- ResourceTracker；
- code lease；
- compile/publish/discard 生命周期；
- async/lazy-first-call 路由实验；
- 标量 Bytecode opcode 子集；
- division guard；
- shift mask；
- float-to-int defined lowering。

### 10.3 尚未证明的内容

- 它不是 HIR→LLVM；
- 当前仍是 Bytecode→LLVM；
- 没有通用 calls；
- 没有 objects/handles/UObject；
- 没有真实 suspend/resume；
- 没有完整 exception/debug/coverage parity；
- 没有 packaged/Shipping 生产闭环；
- 没有显式 `LLVMRunPasses` 或 PassBuilder 优化 pipeline；
- benchmark 不能证明整体性能收益。

2026-08-20 检查时，worktree change tasks 状态为：

```text
79 completed
4 remaining
```

剩余内容包括：

- 仅在被要求时 commit；
- 仅在被要求时 archive；
- optional broad tests；
- calls/objects/suspend/UObject/package/Shipping 作为新的第二阶段 change；
- HIR Runtime JIT 明确属于另一个新 change。

因此，它是本地未落地主线的基础设施 PoC，不能写成当前产品能力。

### 10.4 对 HIR 后端可以直接复用什么

可以复用：

- `Plugins/UnrealLLVM`；
- LLVM 版本与 payload 契约；
- `AngelseaLLVMJITSession` 的 ORC session；
- verifier；
- symbol registration；
- resource tracker；
- code lease；
- UE 模块加载/卸载边界；
- division/shift/fp conversion 的语义 guard 模式。

需要替换：

```text
当前 Bytecode decoder/emitter
        ↓
未来 Verified HIR visitor/lowerer
```

---

## 十一、现有 benchmark 的正确解读

worktree 附带的单一 `Add` 样例记录：

```text
LLVM SDK       22.1.8
compile_us     2157
first_call_us  2180.401
second_call_us 8.799
ns_per_op      210.240
```

证据：

```text
.worktrees/feature-as-angelsea-llvm-jit-plugin/
  openspec/changes/feature-as-angelsea-llvm-jit-plugin/
    benchmarks/angelsea-llvm.csv
    notes/2026-08-15-93-benchmark.md
```

该数据只说明以下链路曾在记录环境中跑通：

```text
request → compile → ORC publish → native hit → lease/discard
```

不能从中得出 LLVM 比 VM/StaticJIT 更快的结论，因为：

- corpus 只有一个 `Add`；
- `ns/op` 包含 `ExecuteInt2` Context create/release；
- `code_bytes` 是 emitter placeholder；
- `session_bytes` 是进程物理内存，不是隔离 JIT heap；
- 当前未运行明确的 LLVM pass pipeline；
- 没有 VM、BytecodeJIT、C++ TypedASTJIT、LLVM O0/O2 的同环境对照；
- 没有 calls/object/lifetime 等真实负载。

它是“存在性验证”，不是性能结论。

---

## 十二、当前 HIR 的适用性矩阵

### 12.1 绿色：已经适合开始 LLVM lowering

- scalar literal；
- scalar parameters；
- scalar locals；
- 明确的 numeric conversions；
- unary/binary expressions；
- assignment；
- mutation target/value；
- short-circuit；
- block；
- if；
- while/for；
- switch；
- break/continue；
- return；
- 受限 resolved call；
- exact evaluation steps；
- source span；
- HIR verifier；
- function-level unsupported/fallback。

### 12.2 黄色：可以支持，但需要先定义契约

- mutable globals；
- import slots；
- direct call ABI；
- VM/context bridge ABI；
- native helper attributes；
- recursion frame budget；
- AS exception flag 和 early exit；
- source position/debug frame；
- coverage；
- timeout；
- HIR artifact identity；
- ORC code lease 与 provider publication；
- Cache V2/HIR sidecar；
- alias/effect/purity 信息。

### 12.3 红色：当前不能声称完整支持

- object value lifetime；
- handle addref/release；
- ref/out；
- property 的完整 lvalue/address 模型；
- array/set/map/container；
- constructor/destructor；
- 非空 cleanup plan；
- UObject/GC root；
- native/script exception unwind；
- suspend/resume；
- source `try`/`catch`；
- debugger/coverage/timeout 完整对等；
- 复杂 dynamic call/import；
- hot reload 下对象和代码生命周期；
- packaged/Shipping 的完整 artifact/cache 兼容。

当前 TypedASTJIT 对许多红色范围也会 fail closed。LLVM 第一阶段应保持相同或更窄的能力边界，不能因为 LLVM 能表达 `load/store/call` 就提前声称支持完整语言。

---

## 十三、HIR 现在不是通用优化 IR

当前 HIR 是 Structured Typed Semantic HIR，不是完整的 CFG/SSA 优化 IR。

它目前没有系统化提供：

- predecessor/successor；
- dominance；
- SSA value；
- block argument/`phi`；
- liveness；
- alias analysis；
- effect summary；
- purity；
- escape information；
- GC root set；
- exception edge；
- suspend edge；
- 统一 address/lvalue model；
- 统一 memory effect；
- 可持久化、版本化 Runtime HIR artifact。

### 13.1 适合在 HIR 层做的优化

- constant folding；
- 恒定分支消除；
- 明确的代数化简；
- 冗余隐式 conversion 消除；
- 基于 resolved call 的高层 rewrite；
- property/call 的语义级诊断；
- unreachable 检查；
- 保守的 AS 专用 inline/devirtualization 决策。

### 13.2 适合交给 LLVM 的优化

- mem2reg；
- SROA；
- InstCombine；
- GVN；
- DCE；
- SimplifyCFG；
- loop rotation；
- LICM；
- inlining；
- vectorization；
- target-specific codegen。

### 13.3 何时增加 Typed CFG

当真实实现出现以下现象时，再增加 backend-neutral Typed CFG：

- 多个 backend 重复构造相同 CFG；
- cleanup/exception/suspend 需要统一 edge model；
- 高层优化需要 dominance/liveness；
- call effects/alias/escape 无法在 structured HIR 上清楚表达；
- HIR visitor 中充满 backend-independent 临时 block 逻辑；
- 需要在 LLVM/C++/MIR 多个 backend 之间共享优化。

推荐的三层模型是：

```text
1. Structured Typed Semantic HIR
   保留 AS 源语言语义

2. Backend-neutral Typed CFG IR（未来可选）
   blocks、values、effects、lifetime、exception/suspend edges

3. Backend IR
   LLVM IR、C++、MIR 或其他目标
```

第一版 HIR→LLVM 不应被 Typed CFG 设计阻塞。

---

## 十四、HIR 生命周期对 Runtime JIT 的限制

当前 HIR 的一个关键限制是：

> 它主要存在于同一次 source compile 的内存中，不是普遍持久化的 Runtime artifact。

### 14.1 Source-time HIR→LLVM AOT

```text
Editor/Generation Source Compile
  ↓
Verified HIR
  ↓
LLVM IR
  ↓
LLVM object/native code
  ↓
现有 StaticJIT Provider/Router 发布
```

优点：

- HIR 在 source compile 时天然可用；
- 最终游戏不必携带 LLVM；
- 可以复用现有 provider ABI、route、lease；
- 适合 cooked/package/Shipping；
- LLVM version 只影响构建工具链和 artifact identity。

这是更现实的第一生产候选。

### 14.2 Source-time HIR→LLVM ORC

```text
Editor Source Compile
  ↓
Verified HIR
  ↓
LLVM IR
  ↓
ORC JIT
```

优点：

- 反馈快；
- 可以直接复用 worktree ORC 基础设施；
- 适合 differential tests 和 benchmark；
- 不必先定义持久化 HIR sidecar。

这是最适合第一轮技术验证的路线。

### 14.3 Packaged Runtime HIR→LLVM ORC

```text
Cache V2/Bytecode restore
  ↓
需要 HIR
```

这里目前存在缺口。Bytecode-only restore 不天然恢复 HIR。

未来需要至少选择一种：

1. Runtime 重新从 source compile 并捕获 HIR；
2. Cache V2 保存版本化 HIR sidecar；
3. generation 阶段保存可持久化 Typed CFG artifact；
4. Runtime 继续使用 Bytecode→LLVM，而不是 HIR→LLVM。

因此，不能把“HIR 能生成 LLVM IR”直接等同于“packaged Runtime HIR JIT 已经可用”。

---

## 十五、难度估算

以下估算以一名同时熟悉 LLVM 和当前 AngelScript fork 的工程师为参考，是研究级粗估，不是交付承诺。

| 范围 | 难度 | 粗略工作量 |
|---|---:|---:|
| HIR→LLVM 文本 IR，dump + verifier，不执行 | 中低 | 1–3 周 |
| 标量表达式、局部变量、if/loop/return，ORC 执行 | 中等 | 4–8 周 |
| 覆盖当前 TypedASTJIT 子集，加入调用、递归、provider、差异测试和 LLVM passes | 中高 | 2–4 人月 |
| 对象、handle、ref/out、container、复杂 cleanup、globals/imports | 高 | 额外 4–8+ 人月 |
| exception/suspend/debugger/coverage/timeout/hot reload/cache/package/Shipping 完整闭环 | 很高 | 总体 9–18+ 人月，并持续承担 LLVM 升级成本 |

其中，HIR visitor 调用 LLVM C/C++ API 只占一部分工作量。

主要成本来自：

```text
AngelScript 语义对等
+ Runtime/native/bridge ABI
+ LLVM UB/poison 安全
+ object/handle/GC lifetime
+ exception/suspend
+ code publication/lease/hot reload
+ cache/artifact identity
+ debugger/coverage/timeout
+ differential tests
```

---

## 十六、推荐的最小验证路线

### 阶段 1：纯 HIR→LLVM dump

新增实验性 lowerer：

```text
asCTypedSemanticFunction
  ↓
FAngelscriptHIRToLLVM
  ↓
LLVMModuleRef
  ↓
LLVMVerifyModule
  ↓
.ll dump
```

第一阶段支持：

- scalar arguments；
- scalar locals；
- literals；
- numeric conversions；
- unary/binary；
- assignment/mutation；
- short-circuit；
- if；
- loops；
- switch；
- break/continue；
- return；
- cleanup 必须 `VerifiedEmpty`。

成功门槛：

- 不读取 `GetByteCode()`；
- 输入必须先通过 HIR verifier；
- 输出必须通过 LLVM verifier；
- unsupported 在函数 lowering 前完整判定；
- 不允许发布部分函数；
- 相同 HIR/配置输出确定性 LLVM IR；
- 失败只回退该函数到 VM。

### 阶段 2：接入 ORC

复用 `feature-as-angelsea-llvm-jit-plugin` 的：

- UnrealLLVM 22.1.8 SDK；
- ORC session；
- helper symbols；
- resource tracker；
- code lease；
- verifier；
- discard 生命周期。

同一个函数执行：

```text
VM
BytecodeJIT（若适用）
C++ TypedASTJIT
HIR→LLVM O0
```

先作为显式测试后端，不替代生产默认路径。

### 阶段 3：显式 LLVM 优化 pipeline

至少区分：

```text
O0
default<O1>
default<O2>
```

在优化前后都运行 LLVM verifier，并对所有 backend 做同输入差异测试。

如果 O0 正确而 O1/O2 错误，优先检查：

- poison；
- UB；
- flags；
- helper attributes；
- alias assumptions；
- AS exception early-exit；
- evaluation order。

### 阶段 4：逐步增加调用

建议顺序：

1. 同 module 标量 direct call；
2. direct recursion；
3. 明确 native helper；
4. AS Context/VM bridge call；
5. global/import；
6. method/receiver；
7. property；
8. object/handle。

调用、异常和 cleanup 是从玩具 emitter 进入真实 backend 的分水岭。

### 阶段 5：决定是否增加 Typed CFG

完成一批真实函数以后，评估：

- emitter 是否重复大量 backend-neutral CFG 逻辑；
- C++/LLVM backend 是否开始复制优化；
- cleanup/exception/suspend 是否需要统一 edge；
- 是否需要跨 backend 的 effect/alias/escape analysis；
- 是否需要持久化优化 IR。

只有证据表明确实需要时，才正式设计 Typed CFG。

---

## 十七、差异测试语料要求

HIR→LLVM 不能只测试 `Add(int,int)`。

至少应覆盖：

### 17.1 整数

- signed/unsigned add/sub/mul overflow；
- division by zero；
- `INT_MIN / -1`；
- modulo edge cases；
- shift count 为 0、31、32、63、64 和负值来源；
- narrow/widen conversions；
- enum conversions；
- comparison signedness。

### 17.2 浮点

- NaN；
- infinity；
- `-0.0`；
- ordered/unordered comparison；
- float/double conversion；
- float-to-int 上下界和超范围；
- int-to-float precision edge。

### 17.3 求值顺序

- 普通参数逆序求值；
- receiver 与参数顺序；
- default argument；
- hidden argument；
- short-circuit 副作用；
- assignment target 单次求值；
- prefix/postfix mutation；
- property getter/setter 副作用。

### 17.4 控制流

- nested if；
- while/for；
- zero-iteration loop；
- nested break/continue；
- switch；
- return from nested scopes；
- unreachable block；
- recursion frame budget。

### 17.5 Runtime 状态

- AS exception flag；
- helper failure early exit；
- global read/write；
- import slot；
- provider discard；
- Engine shutdown；
- code lease while active；
- unsupported deterministic fallback。

建议比较矩阵：

| Backend | 用途 |
|---|---|
| VM | 当前完整语义基准 |
| BytecodeJIT | 现有低层 native 路线对照 |
| C++ TypedASTJIT | 同一 HIR 的既有后端对照 |
| LLVM O0 | 验证 lowering 本身 |
| LLVM O1/O2 | 验证优化后语义稳定性 |

---

## 十八、推荐架构决策

### 18.1 保留 HIR

不要用 LLVM IR 替代 Typed Semantic HIR。

HIR 继续作为：

- frontend/backend 语义边界；
- 多 backend 公共输入；
- verifier 和 fixture 表面；
- 高层 AS 优化输入；
- unsupported/fallback 判定输入。

### 18.2 LLVM 作为后端

LLVM 负责：

- CFG/SSA；
- 通用标量优化；
- 内存优化；
- 循环优化；
- inlining/vectorization；
- machine code generation；
- ORC/object emission。

### 18.3 VM 继续作为语义基准和 fallback

不能因为增加 LLVM backend 就删除或弱化 Bytecode/VM：

- VM 是完整语言语义路径；
- unsupported HIR 函数需要回退；
- debugger/suspend/exception 等仍依赖 VM；
- differential tests 需要 VM oracle；
- hot reload/Cache V2 仍以当前 Engine authoritative functions 为基础。

### 18.4 优先顺序

推荐优先级：

```text
1. HIR→LLVM dump/verifier
2. Editor/source-time ORC differential backend
3. 显式 O1/O2 pipeline 和语义测试
4. calls/recursion/bridge
5. HIR→LLVM object/AOT 生产评估
6. 根据证据决定 Typed CFG
7. 最后才考虑 packaged Runtime HIR sidecar/JIT
```

### 18.5 不推荐的起点

- 不从 cppvm LLVM Interpreter 替换 AS VM 开始；
- 不从完整对象/GC/suspend 开始；
- 不先设计庞大的全语言 SSA IR；
- 不直接把 Bytecode→LLVM PoC 宣称为 HIR backend；
- 不在没有 O0/O2 differential tests 时开启 LLVM 优化；
- 不把单一 `Add` benchmark 当作性能结论；
- 不在 HIR 不可用的 packaged restore 路径中假设 Runtime HIR 已存在。

---

## 十九、关键源码与资料索引

### 19.1 当前 HIR

```text
Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
    as_typed_semantic_ir.h
    as_typed_semantic_ir.cpp
    as_compiler.cpp
    as_scriptfunction.h
```

### 19.2 HIR/TypedASTJIT 研究

```text
openspec/changes/feature-as-typed-semantic-aot/research/
    typed-semantic-native-pipeline-survey.md
    typed-semantic-source-evidence.md
    typed-semantic-staticjit-engine-impact.md
    exception-cleanup-and-mixed-execution.md
    execution-observability-and-control-flow.md
    task-2-13-evaluation-order.md
    task-4-3-scalar-emitter-audit.md
    task-4-4-control-flow-audit.md
    typed-native-call-vm-bridge.md
```

### 19.3 cppvm

```text
W:/Temp/cppvm/source/core/vmlib/VmLib.cpp
W:/Temp/cppvm/source/core/vmlib/ExternalFunctions.cpp
W:/Temp/cppvm/source/core/vmlib/Execution.cpp
W:/Temp/cppvm/source/core/thunk/thunk.cpp
W:/Temp/cppvm/source/llvm/llvm/docs/LangRef.rst
W:/Temp/cppvm/source/llvm/llvm/lib/IR/Verifier.cpp
```

### 19.4 LLVM/Angelsea worktree

```text
.worktrees/feature-as-angelsea-llvm-jit-plugin/Plugins/UnrealLLVM/README.md
.worktrees/feature-as-angelsea-llvm-jit-plugin/Plugins/AngelseaLLVMJIT/
  Source/AngelseaLLVMJIT/Private/AngelseaLLVMIREmitter.cpp
  Source/AngelseaLLVMJIT/Private/AngelseaLLVMJITSession.cpp
  Source/AngelseaLLVMJIT/Private/AngelseaLLVMEligibility.cpp
.worktrees/feature-as-angelsea-llvm-jit-plugin/
  openspec/changes/feature-as-angelsea-llvm-jit-plugin/
    tasks.md
    benchmarks/angelsea-llvm.csv
    notes/2026-08-15-93-benchmark.md
```

### 19.5 其他参考

```text
W:/UnrealLLVM
Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das
Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das
Reference/numba
Reference/luau
Reference/Cython
Reference/angelsea
```

---

## 二十、最终判断

当前 HIR 已经具备成为 LLVM 前端输入的关键条件：

- 它由正式语义编译器产生；
- 保存精确类型和符号；
- 保存已解析调用；
- 保存求值顺序；
- 保存 mutation 单次求值计划；
- 保存结构化控制流；
- 保存 cleanup 状态；
- 有 verifier；
- 有确定性 dump/fixture；
- 有当前 C++ TypedASTJIT 后端作为可行性证明；
- 可以按函数 fail closed 到 VM。

它尚未直接成为通用优化 IR，也尚未解决完整 AS runtime/native parity。这并不说明 HIR 设计不适用，而说明正确的下一步是定义并验证 lowering 契约。

最终建议是：

> 保持 Typed Semantic HIR 作为 AngelScript 语言语义层；以现有 LLVM 22.1.8/ORC worktree 为基础，新增严格受限、只消费 verified HIR 的 LLVM emitter；先完成 O0 differential correctness，再开启 O1/O2；根据真实实现中 CFG、effect、cleanup、exception 和多 backend 复用的压力，决定是否增加 backend-neutral Typed CFG。不要从 cppvm Interpreter 替换 VM 开始，也不要把 LLVM IR 当作 HIR 的替代品。
