# AS_TypedSemanticHIRLLVMDiscussionLog — HIR、LLVM 与 JIT 会话讨论记录

> 状态：持续更新的会话记录
> 首次整理：2026-08-20
> 最近更新：2026-08-21
> 主题范围：Typed Semantic HIR、canonical AST、SourceManager/Lexer/Parser/Sema、TypedASTJIT、LLVM IR、Runtime JIT、Static AOT、`cppvm`、daScript 及相关编译器架构
> 维护方式：在本次会话中继续讨论上述主题时，在回答问题后同步把问题、结论、证据和未决事项追加到本文

---

## 一、本文用途

本文不是第三篇重复介绍 HIR 或 LLVM 的专题文章，而是本次会话的持续讨论日志。它解决以下问题：

1. 把用户在会话中提出的问题按时间和因果关系保留下来；
2. 把当时给出的结论、判断依据和估算集中在同一个入口；
3. 区分已经存在于主线的能力、其他 worktree 中尚未落地主线的 PoC、外部参考项目以及建议方案；
4. 记录讨论后形成的架构倾向和仍需验证的问题；
5. 当会话上下文被压缩或以后重新打开仓库时，可以先读本文恢复讨论背景。

两篇专题文档仍是具体技术事实的主要说明：

- [`AS_TypedSemanticHIR.md`](AS_TypedSemanticHIR.md)：说明 Typed Semantic HIR 是什么、如何捕获和验证、TypedASTJIT 如何消费它；
- [`AS_TypedSemanticHIRToLLVM.md`](AS_TypedSemanticHIRToLLVM.md)：说明 HIR 与 LLVM IR 的分层、`cppvm` 和 LLVM ORC 参考、转换难度与建议验证路线；
- 本文：保留问题脉络、阶段性判断、决策记录和后续追问。

如果本文的简述与源码或专题文档中的更新事实冲突，应重新检查当前源码，并同步修订本文；不能仅凭旧会话结论覆盖新证据。

---

## 二、记录规则与事实标签

### 2.1 后续追加格式

后续每个相关问题至少记录：

- 用户问题；
- 简明结论；
- 关键依据；
- 对当前架构判断的影响；
- 尚未解决或需要实验验证的事项。

如果只是对既有问题的补充追问，可直接追加到原问题；如果产生了新的架构判断，则新增一条问题记录，并更新“决策账本”。

### 2.2 本文使用的事实标签

| 标签 | 含义 |
|---|---|
| **主线现状** | 当前 `D:\Workspace\AngelscriptProject` 主工作区中能够由源码直接确认的能力 |
| **本地 PoC** | 其他本地 worktree 中存在，但尚不能当作主线产品能力的实现或实验 |
| **外部参考** | `Reference/` 或 `W:\Temp\cppvm` 中用于研究的项目，不是本插件依赖 |
| **建议** | 基于现有证据得出的设计方向，尚未等于已实现能力 |
| **粗略估算** | 用于安排验证规模的工程量级判断，不是承诺排期 |

特别注意：

- “存在 LLVM worktree”不等于“主线已经有 LLVM 后端”；
- “HIR 能映射到 LLVM IR”不等于“完整 AngelScript 语义已经被证明可正确映射”；
- “LLVM 能优化 IR”不等于“把 IR 交给默认优化管线就一定保持 AngelScript 语义”；
- “daScript 从 AST 生成 LLVM IR”中的 AST 是完成类型推导、名称绑定和规范化后的 typed/resolved AST，不应理解成原始 Parser AST；
- benchmark 数字只能证明当时的特定样例能够运行，不能直接外推为完整后端性能结论。

---

## 三、本次讨论的核心问题

截至 2026-08-21，本次会话围绕一个中心问题展开：

> 当前的 Typed Semantic HIR 是否适合作为 LLVM 后端和后续 IR 优化的输入？如果适合，应该怎样验证，而不是过早把它改造成 LLVM IR 或另一套虚拟机字节码？

讨论形成的短答案是：

> **当前 sidecar HIR 已经证明 high-level typed semantic contract 的必要性，并足以开始标量、表达式和结构化控制流的 LLVM lowering 实验；长期则由一套 canonical typed AST 接管这项职责，避免 Parser AST、HIR 和 Bytecode 语义重复。LLVM IR 仍应是可选后端 IR，生产难点主要在 AngelScript 语义、ABI、对象生命周期、异常/挂起边界和运行时发布，而不是创建 LLVM 指令本身。**

建议的数据流是：

```text
AngelScript Source
        │
        ▼
SourceManager / RawLexer / TokenBuffer-Cursor
        │
        ▼
Parser + Sema
        │
        ▼
Verified Canonical Typed AST
        ├──────────────► Bytecode / VM
        │
        ├──────────────► TypedASTJIT C++ emitter
        │
        ├──────────────► future LLVM lowering
        │                     │
        │                     ▼
        │               LLVM IR + verifier
        │                     │
        │                     ├──► ORC JIT
        │                     └──► object / Static AOT
        │
        └──────────────► optional future Typed CFG

Current sidecar Typed Semantic HIR remains a migration/differential oracle until canonical AST consumers converge; existing Bytecode / VM remains the semantic baseline and per-function fallback.
```

---

## 四、问题 1：是不是有一个 HIR？它是做什么的？

### 4.1 用户问题

> 之前做过从 AST 转 HIR 再进行 JIT，是不是有一个中间数据结构 HIR？它具体是做什么的？

### 4.2 结论

有。当前代码中的核心函数级结构是：

```cpp
asCTypedSemanticFunction
```

它是编译器在完成语义分析后，为某个函数生成的、由编译器拥有的 **typed semantic function snapshot**。可以把它理解为“后端不再需要重新猜语义的函数级输入”。

它保存的不是源代码语法外形，而是已经确定的语义，例如：

- 精确类型；
- 参数、局部变量和隐式对象等符号；
- 已解析的调用目标和调用元数据；
- 表达式和语句的语义节点；
- 明确的求值步骤与顺序；
- mutation target 的单次求值语义；
- `if`、循环、`switch`、`break`、`continue`、`return` 等结构化控制流；
- 生命周期清理计划及其逆序、live-only 执行约束；
- 源位置和诊断来源。

### 4.3 它在编译链中的位置

概念上可以写成：

```text
Source
  → Parser AST
  → semantic analysis / type resolution
  → Typed Semantic HIR
  → HIR verifier
  → TypedASTJIT C++ emitter
```

Bytecode 仍由现有编译器路径产生，VM 仍然存在。HIR 不是为了删除 Bytecode/VM，而是给 typed/native 后端建立一个比原始 AST 更稳定、比 Bytecode 更保留高级语义的边界。

### 4.4 HIR 不是什么

它不是：

- 原始 Parser AST 的别名；
- LLVM IR；
- 第二套通用 Bytecode；
- SSA CFG；
- 当前普通 Runtime JIT 的输入；
- 当前 Cache V2 中默认持久化、可在 packaged runtime 随时恢复的格式。

因此，当前 HIR 更接近“source compile 期间产生并验证的短生命周期语义快照”。这也是为什么 source-time AOT 或 editor-time ORC 比 packaged runtime HIR JIT 更容易先落地。

### 4.5 为什么需要它

如果后端直接使用原始 AST，就需要重复完成或隐式依赖以下工作：

- 重载解析；
- 隐式转换；
- 默认参数来源；
- 参数实际求值顺序；
- 属性访问与调用重写；
- 隐式 `this`；
- 临时值和对象清理；
- `break` / `continue` / `return` 穿越作用域时的清理；
- 不支持语义的安全拒绝。

HIR 的价值就是把这些前端已经确定的事实显式交给后端，防止不同后端各自实现一套不完全一致的“第二语义编译器”。

### 4.6 关键依据

主线源码入口：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.cpp`

主线测试入口：

- `Plugins/Angelscript/Standalone/Tests/AngelscriptTypedSemanticIRTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/TypedSemanticIR/`

完整说明见 [`AS_TypedSemanticHIR.md`](AS_TypedSemanticHIR.md)。

### 4.7 对当前决策的影响

保留 HIR。未来新增 LLVM 后端时，默认应消费 verified HIR，而不是回到 Parser AST 重做语义推断，也不应先从 Bytecode 反推已经丢失的高级语义。

---

## 五、问题 2：朋友的方案是 AST 直接转 LLVM IR，我们与它有什么区别？HIR 转 LLVM IR 有多难？

### 5.1 用户问题

> 有朋友做的 AngelScript 方案是 AST 直接生成 LLVM IR。我们现在的方式与 LLVM IR 有什么区别？HIR 转换到 LLVM IR 的难度有多大？是否能用它验证 HIR 的适用性，并把很多优化放到 IR 中？

### 5.2 首先区分两种“AST 直接 LLVM”

“AST 直接生成 LLVM IR”可能表示两件非常不同的事情：

1. 原始 Parser AST 在类型、符号、调用和生命周期尚未完全确定时直接生成 LLVM IR；
2. 一个已经完成 infer、resolve、normalize 和 lowering 的 typed/resolved AST 通过 visitor 生成 LLVM IR。

第二种在架构上常常已经有一个“隐式 HIR”，只是项目仍沿用 AST 类型和命名。daScript 就更接近第二种。

因此不能只比较类名叫 `AST` 还是 `HIR`；应该比较 LLVM emitter 收到的数据是否已经具备：

- 确定类型；
- 确定符号和调用目标；
- 确定求值顺序；
- 确定生命周期与清理；
- 已经降低的语言糖和隐式行为；
- 可验证的 unsupported boundary。

### 5.3 HIR 与 LLVM IR 的核心区别

| 维度 | Typed Semantic HIR | LLVM IR |
|---|---|---|
| 层级 | AngelScript 语言语义层 | 通用低级代码生成和优化层 |
| 主要形态 | 函数、符号、表达式、结构化语句、清理计划 | basic block、SSA value、指令、phi、terminator |
| 类型含义 | 保留 AngelScript 类型、handle、引用、对象和值语义 | 整数、浮点、指针、聚合及目标数据布局 |
| 控制流 | `if`、循环、`switch`、跳转意图 | 显式 CFG 分支和合流 |
| 生命周期 | 语言级清理计划和所有权语义 | 通常需要调用、landing/cleanup block 或 runtime helper 表达 |
| 求值顺序 | 可显式记录 | lowering 必须按顺序构造指令和临时值 |
| 优化目标 | 语言感知、确定性和跨后端一致性 | SSA、CFG、标量、循环、向量化和机器码优化 |
| 可执行性 | 自身不是目标机器 IR | 可解释、JIT、AOT 或生成 object |

两者不是竞争关系，合理分层是：

```text
Typed Semantic HIR
        │  language-aware lowering
        ▼
LLVM IR
        │  verifier + optimization passes
        ▼
ORC JIT / object / native code
```

### 5.4 哪部分容易，哪部分难

相对直接的映射包括：

- 布尔、整数、浮点常量；
- 算术、比较和逻辑表达式；
- 参数和局部变量；
- `if` / `else`；
- `while` / `for`；
- `break` / `continue`；
- 普通 `return`；
- 一部分已解析的直接调用。

第一版甚至不需要手工构造完整 SSA。可以先给局部变量生成 entry-block `alloca`，通过 load/store 表达赋值，再让 LLVM 的 mem2reg/SROA 等 pass 做提升。

真正困难的是：

- AngelScript 整数溢出、除法、shift、浮点转整数等语义与 LLVM poison/UB 的差异；
- handle、引用、对象值、临时对象、copy/move/destruct；
- 调用约定、hidden argument、隐式 `this`、native binding 和 UE 反射桥；
- 全局变量和 import slot 生命周期；
- 异常状态、挂起、超时、调试帧、coverage；
- `try` / `catch` 等当前 HIR 明确拒绝的区域；
- 热重载、函数替换、代码图像 lease 和活动调用安全；
- source compile 之外如何获得可信 HIR；
- 每个不支持函数如何安全回退 VM，而不是产生部分错误 native code。

所以“发出 LLVM 指令”不是最大工作量，语言语义和 Runtime 集成才是。

### 5.5 粗略工程量估算

下面只是为研究分段提供的量级，不是交付承诺：

| 阶段 | 目标 | 粗略量级 |
|---|---|---:|
| HIR dump + LLVM verifier | 标量、表达式、简单 CFG，只输出 `.ll` | 1–3 周 |
| 最小 ORC 执行 | 纯标量函数、O0、差异测试 | 4–8 周 |
| 覆盖当前 TypedASTJIT 已支持子集 | 调用、清理、Runtime bridge、回退 | 2–4 人月 |
| 接近完整语言和生产生命周期 | 对象模型、异常/挂起、调试、热重载、缓存、平台 | 9–18+ 人月且会持续演进 |

这些估算的前提是可以复用已有 HIR、测试基础以及本地 LLVM PoC 的装载与 ORC 基础设施。

### 5.6 对“优化都从 IR 进行”的判断

不能把所有优化都推给 LLVM：

- 语言语义相关优化更适合在 HIR 或未来 Typed CFG 层做，例如已解析调用去虚化、语言内建识别、确定无副作用的常量折叠、cleanup 简化；
- 通用低级优化适合交给 LLVM，例如 mem2reg、SROA、GVN、instcombine、CFG simplification、loop optimization、vectorization；
- 必须先确保 LLVM IR 的 flags、attributes、helper declaration 和 control flow 没有引入比 AngelScript 更强的 UB 假设。

结论不是“HIR 或 LLVM 二选一”，而是让两层各自做擅长的优化。

### 5.7 对当前决策的影响

当前 HIR 的适用性已经足够支持一个严谨的 HIR→LLVM 验证项目。第一目标应是语义等价和逐函数安全回退，不应把峰值性能作为第一验收标准。

完整说明见 [`AS_TypedSemanticHIRToLLVM.md`](AS_TypedSemanticHIRToLLVM.md)。

---

## 六、问题 3：`W:\Temp\cppvm` 的“嵌入 LLVM IR 虚拟机”是怎么做的？

### 6.1 用户关注点

用户希望参考 `cppvm` 中嵌入 LLVM IR 虚拟机的方式，判断是否可以把 LLVM IR 作为 AngelScript 的执行或热更新载体。

### 6.2 实际数据流

`cppvm` 的主要思路可以概括为：

```text
C++ source
   │
   ▼
Clang / LLVM frontend
   │
   ▼
LLVM IR
   │
   ├── collect / gather / diff / patch / thunk
   │
   ▼
LLVM ExecutionEngine Interpreter
   │
   ▼
libffi/native bridge
```

`W:\Temp\cppvm\source\core\vmlib\VmLib.cpp` 中的关键行为包括解析 LLVM IR，并选择 `EngineKind::Interpreter`。因此它的核心不是现代 ORC optimizing JIT，而是把 Clang 生成的 LLVM IR 作为可解释执行和热补丁基础。

仓库还包含：

- `source/core/collect/`
- `source/core/gather/`
- `source/core/diff/`
- `source/core/patch/`
- `source/core/thunk/`

它们围绕符号收集、变化检测、补丁和调用桥工作。

### 6.3 可借鉴之处

可以借鉴：

- 把 IR 当作编译产物和运行时执行载体；
- 符号收集和函数替换；
- 调用边界的 thunk/FFI 设计；
- 热更新中的 diff/patch 思路；
- 模块装载与运行时代码切换的工程拆分。

### 6.4 不应直接照搬之处

它不能直接成为 AngelScript LLVM 后端的主架构，原因包括：

- 它从 C++/Clang 语义出发，不负责 AngelScript 对象、handle、GC、调用和异常语义；
- 它使用较老的 LLVM 11.1.0 体系，而当前本地 LLVM worktree 已经在 LLVM 22.1.8 上验证 ORC；
- LLVM Interpreter 不是理想的生产性能终点；
- IR 和 native bridge 仍受目标 ABI、数据布局和符号环境约束；
- 嵌入 LLVM IR 不天然构成安全沙箱；
- 当前插件已经有 VM、Bytecode、StaticJIT provider 和热重载生命周期，不能绕开这些既有契约。

### 6.5 对当前决策的影响

把 `cppvm` 视为“LLVM IR 执行、符号桥和热补丁”的外部工程参考，不把 LLVM Interpreter 作为新的 AngelScript 主 VM。对当前项目更直接的起点是 verified HIR→LLVM IR→ORC/object，同时保留现有 VM fallback。

---

## 七、问题 4：本地 LLVM worktree 已经证明了什么？

### 7.1 用户问题

> 记得有一个 worktree 中有 LLVM 源码，可以找过去分析，并进一步比较当前 HIR 和 LLVM IR。

### 7.2 worktree 身份

本地存在：

```text
D:\Workspace\AngelscriptProject\.worktrees\feature-as-angelsea-llvm-jit-plugin
```

该 worktree 使用 LLVM 22.1.8，并包含 `Plugins/UnrealLLVM`。它是 **本地 PoC**，不能等同于当前主线产品能力。

### 7.3 它当前验证的数据流

该实验的核心路径是：

```text
AngelScript bytecode snapshot
        │
        ▼
LLVM C API emitter
        │
        ▼
LLVM module verifier
        │
        ▼
ORC LLJIT
        │
        ▼
VMEntry-compatible function entry
```

它已经为以下问题提供了实际证据：

- Unreal 中可以集成目标 LLVM 版本；
- 可以创建和验证 LLVM module；
- ORC LLJIT 可以发布并查询函数；
- 可以建立宿主符号解析；
- 可以做资源跟踪、替换和释放；
- 可以接入现有 VMEntry 风格执行入口；
- 可以建立 runtime guards 和 fallback；
- 可以围绕代码映像和活动执行建立 lease/lifecycle 机制。

截至 2026-08-20，当时检查到对应变更记录为 79 项完成、4 项剩余。这只是该 worktree 的阶段状态，不是主线任务进度。

### 7.4 它还没有证明什么

该 PoC 没有自动证明：

- 当前 Typed Semantic HIR 已经有 LLVM emitter；
- 完整 AngelScript 类型和对象语义已经映射；
- Bytecode→LLVM 是最终推荐架构；
- 已配置明确且可靠的生产优化 pass pipeline；
- benchmark 已证明比现有 VM 或 StaticJIT 更快；
- 代码已经合并、归档或适合发布。

当时未在该插件中找到明确的完整 `LLVMRunPasses`/PassBuilder 优化管线接入，因此不能把“使用 LLVM”误写成“已经获得 LLVM 优化收益”。

### 7.5 对 HIR→LLVM 最有价值的复用

应优先复用：

- UnrealLLVM SDK 和 Build.cs 集成；
- target initialization 和 data layout；
- LLVM verifier；
- ORC LLJIT session；
- host symbol allowlist/resolution；
- resource tracker 与卸载；
- code-image lease；
- VMEntry/Raw/Parms 入口桥；
- runtime guard、版本校验和失败回退；
- 差异测试和 microbenchmark 脚手架。

最应该替换的是：

```text
Bytecode snapshot emitter
```

替换为：

```text
Verified Typed Semantic HIR visitor / lowering
```

### 7.6 benchmark 的正确读法

当时样例出现过约 `2157 µs` 的编译测量。这种数字只能作为“这条实验路径确实执行过”的存在性证据，不能用于得出以下结论：

- 编译开销已经可接受；
- native execution 已经覆盖完整语言；
- 优化后的 steady-state 性能优于其他后端；
- 热重载成本已经满足编辑器体验要求。

性能结论必须分别测量 capture、lowering、verify、optimize、ORC materialization、lookup、第一次调用和稳定执行，并与 VM、BytecodeJIT、TypedASTJIT/StaticJIT 做相同语义语料对比。

### 7.7 对当前决策的影响

这个 worktree 大幅降低了“把 LLVM 放进 UE 并安全发布代码”的未知量，但没有替代 HIR lowering 设计。合理路线是复用其 LLVM/ORC/runtime 基础设施，重新以 HIR 作为前端输入。

---

## 八、问题 5：推荐怎样验证 HIR→LLVM？

### 8.1 第一阶段：只生成和验证 LLVM IR

先建立独立、可 dump、可 golden-test 的 lowering：

```text
verified asCTypedSemanticFunction
        │
        ▼
HIRToLLVMFunctionLowerer
        │
        ▼
LLVM Module
        │
        ├──► LLVMVerifyModule
        └──► deterministic textual .ll dump
```

第一阶段建议只覆盖：

- `void`、`bool`、定宽整数、`float`、`double`；
- 参数和局部变量；
- 常量、基本算术和比较；
- 赋值和复合赋值；
- `if`；
- 简单循环；
- `break` / `continue`；
- `return`；
- 明确的 unsupported diagnostics。

此时不需要 ORC，也不需要 UE 对象模型。目标是验证 HIR 是否包含正确 lowering 所需的信息，并暴露信息缺口。

### 8.2 第二阶段：ORC O0 差异执行

把已通过 verifier 的最小子集接入 ORC，以 O0 与 VM 做差异测试：

```text
same source
   ├──► VM result/state
   └──► HIR→LLVM→ORC result/state
                  │
                  ▼
             exact comparison
```

差异测试不仅比较返回值，还应比较：

- 参数和 out/ref 状态；
- 全局状态；
- 调用次数和调用顺序；
- 副作用顺序；
- 清理顺序；
- 异常/失败状态；
- 对 NaN、`-0.0`、边界整数和非法 shift 的行为。

### 8.3 第三阶段：引入明确优化管线

O0 语义稳定之后，再分别验证 O1/O2 或自定义 pipeline。所有开启的 flags 和 attributes 都必须有语义依据，尤其避免随意添加：

- `nsw` / `nuw`；
- 过强的 `nonnull`；
- 不真实的 `noalias`；
- 不真实的 `readonly` / `readnone`；
- 会改变浮点语义的 fast-math flags。

任何只在优化后失败的语料都应被视为 lowering contract 或 attribute contract 问题，而不是简单归咎于 LLVM。

### 8.4 第四阶段：逐步增加调用和生命周期

建议顺序：

1. 纯 HIR 内部 direct call；
2. 递归和 native frame budget；
3. allowlist runtime helper；
4. native binding；
5. script object/handle/reference；
6. cleanup plan；
7. mutable globals 和 import slots；
8. debug/coverage/timeout；
9. 热重载和 provider 生命周期。

每一步都保留逐函数 fallback，不把整个 module 的成功与否绑定在一个尚未支持的函数上。

### 8.5 何时引入 Typed CFG

当前 HIR 足够直接构造 LLVM basic blocks，因此验证前期不需要先设计一套大型通用 CFG/SSA IR。

只有出现以下重复需求时，才值得抽出 backend-neutral `TypedCFG`：

- C++ emitter 和 LLVM emitter 都在重复拆结构化控制流；
- cleanup edge 很难在多个后端保持一致；
- 需要跨 basic block 的语言级数据流分析；
- 需要在 LLVM 之前做语言感知优化；
- 异常、挂起或复杂 `switch` 使结构化 HIR 直接 lowering 变得脆弱。

此时的 Typed CFG 应保留语言语义和 cleanup edge，不应只是模仿 LLVM IR 的另一套 SSA。

### 8.6 HIR 生命周期决定了交付顺序

当前 HIR 主要在同一次 source compile 中产生并以内存形式消费。由此得到：

1. **source-time HIR→object/Static AOT** 最自然；
2. **editor/source-time HIR→ORC** 适合实验和快速差异验证；
3. **packaged runtime HIR→ORC** 需要额外解决 HIR sidecar、可信恢复、版本、校验、缓存和安全策略。

如果运行时只有 Cache V2 bytecode restore，不能假设 HIR 会自然存在。要么在同次 source compile 捕获 HIR，要么设计有版本和 verifier 的持久化 HIR sidecar；后者本身是独立产品能力。

### 8.7 对当前决策的影响

优先做 HIR→LLVM `.ll` + verifier，然后做 editor/source-time ORC O0 差异测试；不要从 packaged Runtime JIT、完整对象模型或 LLVM Interpreter 起步。

---

## 九、问题 6：daScript 的 LLVM 后端具体如何工作？什么结构与我们的 HIR 对应？

### 9.1 用户问题

> daScript 的 LLVM 后端是 `AstVisitor` 直接生成 LLVM IR。它具体是怎么做的？daScript 中和我们的 HIR 对应的结构是什么？

### 9.2 最重要的结论

daScript 中没有一个与 `asCTypedSemanticFunction` 一一对应、名字就叫 HIR 的单独类型。

它最接近我们 HIR 的东西是：

> **完成类型推导、名称/调用解析、规范化、优化、alias 分析和 stack allocation 之后的 `Function + body Expression tree + Variable + TypeDecl` 图。**

换句话说，daScript 把 AST 和 HIR 的类型层合并了：最终的 typed/normalized AST 就是它事实上的高层 IR。LLVM 后端虽然叫 `AstVisitor`，但它消费的不是刚解析完成的原始语法树。

### 9.3 daScript 编译前端如何把 AST 变成可生成代码的结构

可观察到的主流程包括：

```text
parse AST
   │
   ▼
infer / resolve types and symbols
   │
   ▼
normalize / transform / optimize
   │
   ▼
alias analysis / stack allocation / semantic hash
   │
   ▼
final typed Expression graph
   ├──► SimNode interpreter IR
   ├──► AOT paths
   └──► LLVM AstVisitor
```

相关入口包括：

- `Reference/daScript/src/ast/ast_parse.cpp`
- `Reference/daScript/src/ast/ast_infer_type.cpp`
- `Reference/daScript/include/daScript/ast/ast.h`
- `Reference/daScript/include/daScript/ast/ast_expressions.h`

`ast_parse.cpp` 中的编译流程会先进行 infer、optimize、alias 和 stack allocation 等步骤；`ast_infer_type.cpp` 通过 visitor 完成大量语义确定和树改写。因此后端拿到的是“已经编译过的树”。

### 9.4 与当前 HIR 的概念映射

| 当前 AngelScript Typed Semantic HIR | daScript 最接近的结构 | 说明 |
|---|---|---|
| `asCTypedSemanticFunction` | `Function` + `Function::body` | 函数签名、参数、结果和最终函数体 |
| HIR symbols | `Variable` | 参数、局部和相关声明信息 |
| 精确类型 | `TypeDecl` | typed AST 的类型描述 |
| 已解析变量引用 | `ExprVar::variable` | 表达式直接关联解析后的 `Variable*` |
| 已解析调用目标 | `ExprCallFunc::func` 等 | 调用表达式直接关联目标 `Function*` |
| statements/body | `ExprBlock::list` | 函数体表达式/语句序列 |
| cleanup plan | `ExprBlock::finalList`、`ExprDelete`、move/return flags 等 | daScript 将清理信息分布在树节点和标志中 |
| source spans | `LineInfo at` | 节点源位置 |
| EvaluationSteps | 无独立等价表 | 主要依赖树形顺序、visitor callback 和前端改写后的节点结构 |
| 稳定 ID / 独立所有权 | 大量 GC 管理的原始对象指针 | daScript LLVM emitter 使用 `Expression*`、`Variable*` 等作为映射 key |

这个对比说明：二者传递给 native 后端的信息类型相近，但组织方式不同。

我们的 HIR 更明确地强调：

- 函数级独立快照；
- stable symbol/expression identity；
- explicit evaluation steps；
- explicit cleanup plans；
- verifier 和 unsupported boundary；
- 后端与 Parser AST 对象所有权解耦。

daScript 的优势是：

- typed AST 本身已经是所有后端共享的丰富图；
- visitor 覆盖面大；
- 省去复制为另一套 HIR node 的转换；
- `Expression*` 和 `Variable*` 可以直接作为 LLVM 映射 key。

### 9.5 daScript 的 LLVM emitter 怎样工作

核心实现在：

```text
Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das
```

其中 `LlvmJitVisitor` 维护两个关键映射：

```text
e2v : Expression* -> LLVM value
v2v : Variable*   -> LLVM address/value slot
```

大致 lowering 方式是：

- `generate_llvm` 创建 LLVM module、target 和 visitor；
- 对函数调用 `visit(fn)`；
- `preVisitFunction` 建立 LLVM function、entry block、wrapper/prologue；
- 参数和局部变量被放入 LLVM value 或 `alloca` slot；
- `ExprVar` 从 `v2v` 找到地址并 load；
- 常量和算术表达式生成对应 LLVM value，并写入 `e2v`；
- `if`、循环和逻辑短路创建 basic block 与 branch；
- 已解析调用表达式使用其 `func` 目标生成 call；
- `return` 前处理 `finalList` 等清理逻辑；
- 最后通过 `LLVMRunPasses` 运行指定 pass pipeline。

这是一种很典型的 typed tree→LLVM visitor：边遍历高层树，边建立 CFG 和 LLVM value 映射。

### 9.6 LLVM 代码如何装回 daScript Runtime

daScript 的 interpreter 执行层是 `SimNode`，定义和构造路径可见：

- `Reference/daScript/include/daScript/simulate/simulate.h`
- `Reference/daScript/src/ast/ast_simulate.cpp`

JIT 安装桥位于：

```text
Reference/daScript/src/builtin/module_jit.cpp
```

`SimNode_Jit` 保存 native function pointer，并在执行时调用它。安装 JIT 代码时，Runtime 可以用 `SimNode_Jit` 包装或替换原来的解释节点，同时保留旧节点/路径作为必要的 fallback。这意味着它不是删除 interpreter，而是在同一执行框架里替换特定函数入口。

### 9.7 daScript 的 `Cfg` 和 `SimNode` 是否等于我们的 HIR

都不完全等于。

#### `Cfg`

`Reference/daScript/include/daScript/ast/ast_cfg.h` 中的 CFG 是 statement-level analysis graph，具有 successor/predecessor 等关系。它更像控制流分析辅助结构：

- 不是 LLVM emitter 的主要输入；
- 不是 SSA IR；
- 不承载全部表达式类型、求值和生命周期语义；
- 如果我们未来引入 Typed CFG，它可以作为“控制流骨架”层面的参考。

#### `SimNode`

`SimNode` 是 daScript tree interpreter 的可执行节点 IR，位置已经比 typed AST/HIR 更低：

- 它面向解释执行；
- 它已经带有 Runtime frame 和执行语义；
- 它更接近我们的 Bytecode/VM executable representation，而不是 typed semantic HIR。

因此最准确的对应关系是：

```text
Our Typed Semantic HIR
    ≈ daScript final typed/normalized Function + Expression graph

Our optional future Typed CFG
    ≈ daScript Cfg 的部分控制流职责，但会需要更多类型和 cleanup 语义

Our Bytecode/VM executable form
    ≈ daScript SimNode tree interpreter layer（只做概念类比，不是相同设计）
```

### 9.8 值得借鉴和应保留的差异

可以借鉴 daScript：

- visitor-based lowering；
- `Expression → LLVMValue` 和 `Variable → address` 映射；
- entry-block `alloca` 后交给 mem2reg；
- structured tree 直接构造 LLVM basic blocks；
- 为 cleanup/finalization 建立统一路径；
- 不支持节点显式拒绝并保留 interpreter fallback；
- native 入口替换但保留原执行节点的设计。

当前 HIR 自己更值得保留的能力：

- explicit evaluation order；
- single-evaluation mutation target；
- explicit reverse/live-only cleanup plan；
- verified function snapshot；
- independent ownership 和稳定 ID；
- 明确的 unsupported diagnostics；
- 不依赖 AST GC/raw pointer 生命周期的后端边界。

### 9.9 对当前决策的影响

daScript 证明“typed high-level tree 直接 visitor 到 LLVM IR”是一条可行路线，但它不证明“原始 AST 不需要 HIR”。它反而支持当前判断：只要前端结构已经 typed、resolved、normalized 并携带完整生命周期信息，就可以直接构造 LLVM CFG。

对本项目而言，最自然的实现不是删除 `asCTypedSemanticFunction`，而是实现一个与 daScript `LlvmJitVisitor` 类似的 HIR visitor，并保留我们已有的 verifier、求值顺序、清理计划和 fallback 边界。

---

## 十、问题 7：我们的 HIR 本质上是不是也是 typed AST？

### 10.1 用户问题

> 我们的 HIR 本质其实也是类型 AST 吧？

### 10.2 精确结论

**从编译器表示的宽泛分类看，是。当前 HIR 本质上是一种独立、规范化、可验证的 typed semantic tree IR，可以归入 typed AST 家族。**

但如果“typed AST”特指“在原始 Parser AST 节点上附加类型和符号信息”，那么答案是 **不是**。

最准确的说法是：

> 当前 HIR 是从 AngelScript 编译器的 Parser AST 和语义编译状态中同步捕获出来的、函数级的 typed semantic statement tree + expression DAG snapshot；它在抽象层级上属于 typed AST/HIR，在数据结构和生命周期上不是 Parser AST。

这里没有真正的矛盾，因为：

- **AST** 主要描述表示的形状和它仍然保留多少源语言结构；
- **typed AST** 表示树上的类型、符号和调用等语义已经确定；
- **HIR** 主要描述它在编译流水线中的职责：作为高层、语言相关的后端输入；
- **IR** 是所有编译器中间表示的总称，typed AST 本身也可以是一种 IR。

所以 `typed AST` 与 `HIR` 不是互斥概念。一个 HIR 完全可以是 tree-shaped typed AST；当前实现就是这种情况，只是又增加了独立快照和 verifier 契约。

### 10.3 为什么说它具有 typed AST/HIR 的本质

`asCTypedSemanticFunction` 仍然保留高层源语言结构：

```cpp
asCArray<asSTypedSemanticSymbol> symbols;
asCArray<asSTypedSemanticExpression> expressions;
asCArray<asSTypedSemanticStatement> statements;
asCArray<asSTypedSemanticCleanupPlan> cleanupPlans;
asTypedSemanticStatementId rootStatement;
```

它的 statement kind 仍然是：

```text
Block
LocalDeclaration
Expression
If
For
While
DoWhile
Switch
Case
Break
Continue
Return
Unsupported
```

这不是 LLVM basic block/SSA 指令，也不是线性 Bytecode；它明显保留了源语言的结构化语句树。

表达式也仍然是高层语义节点：

```text
Literal
FoldedGlobalConstant
GlobalStorage
Symbol
Conversion
Assignment
Unary
Binary
ShortCircuit
ResolvedCall
CallRewrite
Unsupported
```

每个 expression 有精确 `asCDataType`，每个 symbol 也有精确类型；因此它显然是 typed 的。它还保留 source span，所以仍然能够关联源代码位置。

从形态上看：

- statements 通过 `children`、`thenStatement`、`elseStatement`、`bodyStatement` 等 ID 组成一棵由 `rootStatement` 拥有的结构化树；
- verifier 明确检查 statement 多重所有权和 ownership cycle；
- expressions 存放在 arena 中，通过 operand ID、receiver ID、mutation target/value 和 evaluation step 互相引用，因此更准确地说是有序 expression graph/DAG，而不必强行称作纯树；
- verifier 要求引用的表达式已经被捕获，并检查求值次序和节点形状。

因此它不是低级 CFG IR，而是非常典型的 high-level typed semantic tree/graph IR。

### 10.4 为什么它又不等于 Parser AST 加类型

原始 Parser AST 是 `asCScriptNode`：

```cpp
class asCScriptNode
{
    eScriptNode nodeType;
    eTokenType tokenType;
    size_t tokenPos;
    size_t tokenLength;
    asCScriptNode* parent;
    asCScriptNode* firstChild;
    asCScriptNode* next;
    // ...
};
```

它的节点直接反映语法，例如：

```text
snIdentifier
snParameterList
snExprTerm
snArgList
snNamedArgument
snScope
snFunctionCall
snAssignment
```

当前 HIR 与它有以下关键差异：

| 维度 | Parser AST (`asCScriptNode`) | Typed Semantic HIR |
|---|---|---|
| 节点身份 | parent/child/sibling 原始指针 | 连续 arena + typed ID |
| 主要内容 | token、语法类别、语法层级 | 精确类型、符号、语义表达式、结构化语句 |
| 调用 | 名称、参数语法仍需解析 | `ResolvedCall` + resolved function/provenance |
| 转换 | 源语法可能没有显式节点 | 显式 `Conversion` |
| 默认/隐藏参数 | 不一定直接存在于用户语法 | argument provenance + evaluation steps |
| 求值顺序 | 需要编译器解释语法和语言规则 | 显式 evaluation steps/sequence |
| mutation | AST 只有赋值/运算符语法 | target/value 和返回旧值语义显式化 |
| 生命周期 | 不能直接证明完整退出清理 | cleanup plan + state + exited scopes |
| 不支持边界 | 可能只能在后端临时发现 | typed unsupported category + verifier |
| 所有权 | Parser/编译事务节点 | 独立函数快照，由编译函数发布 |
| 后端稳定性 | 依赖 Parser node 生命周期和内部形状 | graph 引用使用 ID，不依赖 Parser node；`asCDataType` 仍含 Engine-local type 指针 |

源码也表明 HIR 不是事后遍历 Parser AST 做一次简单拷贝：

- `asCCompiler::Reset` 收到 `asCScriptNode*`，用它建立函数 source span 和 capture transaction；
- `asCTypedSemanticIRBuilder` 与现有语义编译、表达式上下文和 Bytecode 生成同步工作；
- `asCExprContext` 在重载、转换、属性和调用处理过程中携带 `typedSemanticExpression`；
- resolved call、argument provenance、mutation、conversion 和 cleanup 是在编译器已经知道最终语义的位置记录的；
- 编译成功后必须通过 `VerifyTypedSemanticFunction`，才由 `SetTypedSemanticFunction` 发布；
- HIR 自身没有保存 `asCScriptNode*`、`asCExprContext*` 或 `sVariable*` 作为后端表示。

所以它是“从 AST 和 semantic compiler state 捕获的独立 typed semantic IR”，不是“原始 AST 对象被改名为 HIR”。

### 10.5 它和 daScript 最终 typed AST 到底是什么关系

在抽象层级和后端用途上，两者非常接近：

```text
daScript final typed/normalized Function + Expression graph
                       ≈
our verified asCTypedSemanticFunction
```

二者都处在：

```text
parse syntax
   → semantic resolution
   → typed high-level representation
   → LLVM/native lowering
```

主要差异不在“一个是 AST、一个绝对不是 AST”，而在表示契约：

| 项目 | daScript | 当前 HIR |
|---|---|---|
| 类型层 | 复用最终 typed AST 类型 | 单独复制为 HIR DTO |
| 节点引用 | `Expression*`、`Variable*`、`Function*` | expression/symbol/statement ID |
| 生命周期 | 依赖 Program/GC AST 图 | 函数级独立快照 |
| 求值次序 | 树顺序、visitor 和前端 rewrite | explicit evaluation steps |
| 清理 | 分布在 `finalList`、节点和 flags | explicit cleanup plan |
| 调用目标 | typed AST 上的 resolved pointer | pointer-free target metadata + generation-time coordinate |
| 正确性门 | visitor 支持面和编译流程 | 独立 verifier + unsupported contract |

因此，之前“daScript 的最终 typed AST 是它事实上的 HIR”这一判断，也同样意味着：

> 我们的 HIR 是我们自己显式建模、独立拥有并可验证的 typed AST/HIR，而不是与 typed AST 完全不同的一种神秘表示。

### 10.6 这是不是一个设计问题

**不是问题本身，反而是很常见的 HIR 设计。**

HIR 并不要求必须是 CFG 或 SSA。许多编译器的高层 IR 仍然是树形的；只要它已经完成语义解析、具有明确契约，并适合作为后端输入，就可以叫 HIR。

真正需要警惕的是以下问题：

1. 是否只是原始 AST 换名字，后端仍要重做类型和调用解析；当前实现不是；
2. 是否直接依赖 Parser node 指针和短暂状态；当前 graph 已复制为 Parser-node-independent ID 模型，但精确类型仍引用 Engine-local `asCTypeInfo*`；
3. 是否缺少求值次序和清理信息；当前已有显式字段和 verifier，但完整语言支持仍在扩展；
4. 是否为了名称上的“HIR”过早再造一套 CFG/SSA；当前没有必要；
5. 是否把 tree-shaped HIR 当作适合所有优化的形式；不能，跨块数据流优化更适合 LLVM 或未来 Typed CFG。

### 10.7 对 LLVM 后端的直接影响

这个定位使 LLVM 路线更清楚，而不是更危险：

- 可以像 daScript 一样写 visitor/lowerer，从 structured statement tree 创建 LLVM basic blocks；
- 可以用 expression ID 建立 `ExpressionId → LLVMValueRef` 映射；
- 可以用 symbol ID 建立 `SymbolId → LLVM address/value` 映射；
- 第一版局部变量可以使用 entry-block `alloca`，再交给 mem2reg/SROA；
- 不能仅按 operands 递归生成代码，必须尊重 `evaluationSteps`，避免重复执行共享表达式和 mutation target；
- cleanup plan 必须转成明确的 cleanup edge/block 或 runtime helper 调用；
- verifier/unsupported 仍然是 lowering 之前的强制门；
- 如果未来多后端开始重复构造 CFG，再考虑从这层派生 Typed CFG。

### 10.8 对“HIR 适用性”的修正判断

当前 HIR 的适用性不应该按“它是不是 AST”来判断，而应按以下问题判断：

- 它是否包含后端所需的最终语义？
- 它是否脱离 Parser AST 生命周期？
- 它是否能确定性 dump 和验证？
- 它是否把求值、调用、mutation 和 cleanup 契约说清楚？
- 它是否允许对不支持函数安全拒绝和回退？
- 两个独立后端是否能从它生成相同行为？

当前答案是：标量和一部分结构化控制流已经满足；对象、引用、handle、容器、构造/析构、异常/挂起和完整 Runtime ABI 仍需继续扩展和验证。

所以最终回答是：

> **对，我们的 HIR 本质上就是一套“经过语义编译并独立快照化的 typed AST/HIR”。这不会削弱它作为 LLVM 输入的合理性；恰恰相反，daScript 的做法表明这类 typed high-level tree 可以直接 lower 到 LLVM。真正的差异和价值在于 graph 不依赖 Parser node、求值与清理显式、发布前可验证；当前对象并非整体可持久化的 pointer-free DTO。**

### 10.9 关键源码依据

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.cpp`

---

## 十一、问题 8：能否删除独立 HIR，重建原有 AST 体系？

### 11.1 用户问题

> 如果想去掉 HIR，直接改造 AngelScript 原有 AST 体系是否可行？这样是否反而更整洁？当前 fork 完全可定制，不必受原版 AngelScript 架构限制；能否以 LLVM/Clang 的成熟编译器体系为主、daScript 为辅，重新设计 AST？原版很多代码偏 C 风格，是否值得重构？

### 11.2 结论先行

这个方向的**长期目标是合理的**，但需要把“去掉 HIR”改写成更准确的目标：

> **删除“Parser AST 之外另存一份 sidecar HIR”的重复表示，把当前 HIR 的语义契约提升并融入一套 canonical typed AST；所有 Bytecode、C++ AOT、LLVM 和分析后端统一消费该 typed AST。**

不建议的做法是：

> 先删除 `asCTypedSemanticFunction`，然后直接给现有 `asCScriptNode` 增加类型、调用和生成字段。

原因是，当前主要架构债务并不在 `asCScriptNode` 类本身，而在 `asCCompiler` 将语义分析、临时值管理和 Bytecode 生成揉在同一次过程里。只扩充旧节点，会让 Parser 语法、Sema 状态和 Bytecode 状态堆在同一个对象体系中，未必比现在整洁。

推荐目标是：

```text
SourceManager / Lexer
          │
          ▼
Parser + Sema
          │
          ▼
Canonical Typed ASTContext
  ├── Decl / Type / QualType
  ├── Stmt / Expr
  ├── explicit implicit conversions
  ├── resolved calls and declarations
  ├── explicit evaluation / single-evaluation nodes
  ├── cleanup and lifetime nodes
  └── verifier + deterministic dumper
          │
          ├────────► Bytecode CodeGen / VM
          ├────────► Typed C++ AOT
          ├────────► LLVM IR CodeGen
          └────────► derived CFG / language-aware analysis
```

在这个终态中，可以说“独立 HIR 被删除了”，但不能说“语言语义 IR 层被删除了”：canonical typed AST 自己就是新的 HIR。

### 11.3 当前架构为什么会出现 sidecar HIR

当前 Parser AST 的结构非常小：

- `as_scriptnode.h`：约 142 行；
- `as_scriptnode.cpp`：约 155 行。

`asCScriptNode` 只有：

```cpp
eScriptNode nodeType;
eTokenType tokenType;
size_t tokenPos;
size_t tokenLength;

asCScriptNode* parent;
asCScriptNode* next;
asCScriptNode* prev;
asCScriptNode* firstChild;
asCScriptNode* lastChild;
```

节点由 `asCParser::CreateNode` 从 `FMemStackBase` 分配，主要表达 token 和通用 parent/child/sibling 语法结构。它没有：

- expression exact type；
- value category；
- resolved declaration；
- resolved call target；
- implicit conversion；
- argument provenance；
- evaluation order；
- temporary materialization；
- cleanup；
- control-flow target；
- 后端验证契约。

真正的语义存在于 `asCCompiler` 的瞬时状态里：

```cpp
struct asCExprContext
{
    asCByteCode bc;
    asCExprValue type;
    asCScriptNode* exprNode;
    // property/call/deferred parameter state...
    asTypedSemanticExpressionId typedSemanticExpression;
};
```

这一个结构同时装着：

- 语法节点引用；
- 已推导类型和值位置；
- property/call 等 Sema 状态；
- 已经生成的 Bytecode；
- HIR sidecar expression ID。

实测当前相关源码规模：

| 文件/指标 | 当前规模 |
|---|---:|
| `as_parser.cpp` | 约 5,070 行 |
| `as_compiler.cpp` | 约 22,952 行 |
| `as_bytecode.cpp` | 约 3,045 行 |
| `as_typed_semantic_ir.h/.cpp` | 合计约 3,953 行 |
| `as_compiler.cpp` 中 `asCScriptNode` 引用 | 约 145 处 |
| `as_compiler.cpp` 中 Bytecode member access | 约 672 处 |
| `as_compiler.cpp` 中 TypedSemantic 引用 | 约 962 处 |
| Typed Semantic IR 专项测试文件 | 约 41 个 |
| HIR/TypedASTJIT 相关测试消费者文件 | 约 77 个 |

这说明当前 HIR 不是凭空增加的一层：它是在已有 compiler pass 同时生成 Bytecode 时，把即将消失的最终语义复制出来。

如果简单删除 HIR 而不重构 `asCCompiler`，这些最终语义不会自动进入 Parser AST，只会重新消失在 `asCExprContext` 和 Bytecode emission 过程中。

### 11.4 首先纠正：“LLVM AST”实际是 Clang AST

严格来说：

- **LLVM core 没有源语言 AST**；
- Clang 是 C/C++/Objective-C 前端，拥有 AST、Sema、CFG 和 CodeGen；
- LLVM core 从 `llvm::Module`、`llvm::Function`、`llvm::BasicBlock` 和 LLVM instruction 开始。

本次检查的首要参考是本地：

```text
Reference/llvm-project
commit 9bc4fd0fafb58ff1fb50231e39a882a678542dac
date   2026-08-09
```

该仓库使用 sparse checkout，仅把 ThinLTO/LTO 路径放入工作树，但完整 Clang/LLVM 源码仍在 Git `HEAD` 中，可通过：

```powershell
git -C Reference/llvm-project show HEAD:clang/include/clang/AST/ASTContext.h
```

等命令读取。因此本次结论使用的是仓库内的 Clang/LLVM 主线源码，而不是把 `W:\Temp\cppvm` 中的 LLVM 11 当作最新前端设计。

### 11.5 Clang 的真实前端分层

Clang 的关键关系是：

```text
Preprocessor
     │
     ▼
Parser ──calls──► Sema Actions
                       │
                       ├── name lookup
                       ├── type checking
                       ├── overload resolution
                       ├── implicit node construction
                       └── AST building
                                │
                                ▼
                           ASTContext
                     Decl + Type + Stmt + Expr
                                │
                                ├──► CodeGenFunction → LLVM IR
                                └──► CFG::buildCFG on demand
```

源码中的直接证据包括：

- `Parser` 构造函数接收 `Sema &Actions`；
- `Parser` 注释明确说明 Actions 是解析构造时调用的 callback；
- `Sema.h` 文件标题和注释是 `Semantic Analysis & AST Building`；
- `ASTContext` 注释是保存可供整个文件语义分析引用的 long-lived AST nodes；
- `Expr` 直接保存 `QualType`；
- `CodeGenFunction::EmitStmt` 接收 `const Stmt*`；
- `CodeGenFunction::EmitScalarExpr` 接收 `const Expr*`；
- `CFG::buildCFG` 从 `Decl*`、`Stmt*` 和 `ASTContext*` 派生 CFG。

也就是说，Clang 并没有要求在 typed AST 和 LLVM IR 之间必须再有一套通用 HIR。它的 typed AST 本身就是高层语义表示，CodeGen 直接将其 lowering 到 LLVM IR。

### 11.6 Clang 为什么能直接从 AST 生成 LLVM IR

关键不只是 AST 节点有类型，而是 Sema 把隐式语义也物化成了 AST 节点。典型节点包括：

| Clang 节点 | 解决的问题 | 当前 HIR 中最接近的契约 |
|---|---|---|
| `ImplicitCastExpr` | 源码没写出的转换 | `Conversion` |
| `CXXConstructExpr` | 最终构造函数和参数 | resolved construction/call + future lifetime support |
| `OpaqueValueExpr` | 一个子表达式被语义复用但只计算一次 | expression ID + evaluation steps + mutation target |
| `ExprWithCleanups` | full-expression 结束时的清理 | cleanup plan |
| `MaterializeTemporaryExpr` | 临时对象实体化及生命周期延长 | future construction/lifetime nodes |
| `DeclRefExpr` / resolved call nodes | 名称已经绑定到声明 | symbol ID / resolved call target |

Clang CodeGen 不需要从 token 或字符串重新猜这些语义，因为 Sema 已经把它们写入 typed AST。

这正是新 AngelScript canonical typed AST 应借鉴的核心：

> 让 implicit semantics 变成 explicit AST semantics，使所有后端都只做 lowering，不再做第二遍 Sema。

### 11.7 Clang 值得参考的数据结构原则

建议参考：

1. **ASTContext 统一所有权**：arena/bump allocation，节点随 context 整体释放；
2. **Decl / Type / Stmt / Expr 分层**：声明、类型和可执行表达式不再塞进一个通用 token node；
3. **canonical type / qualified type**：相同语义类型可比较、可缓存，并保留 const/ref/handle 等限定；
4. **Sema 建 AST**：重载、转换、属性访问、调用和生命周期只由 Sema 决定；
5. **implicit semantic nodes**：隐式转换、临时值、单次求值和清理都成为节点；
6. **后端只读 AST**：Bytecode、C++、LLVM 不修改或补全语义；
7. **CFG 按需派生**：AST 是语义真相，CFG 是分析/优化视图，不必一开始就永久存储；
8. **dumper + verifier**：每个后端之前都有确定性结构和不变量检查；
9. **SourceManager 独立**：source location/range 不依赖把整段 token 结构保留在每个节点里；
10. **批量生命周期**：避免每个 AST 节点独立 `shared_ptr`/delete。

### 11.8 不应机械复制 Clang 的部分

Clang 是 C++ 全语言前端，复杂度远超 AngelScript。不要复制：

- C++ template/instantiation 体系；
- Objective-C、OpenMP、CUDA、HLSL 等节点；
- PCH/Modules 的完整序列化复杂度；
- Clang 宏生成的全部 Decl/Stmt class hierarchy；
- 为数十年兼容形成的特殊 case；
- 不符合当前 Hot Reload/Cache V2 稳定身份需求的裸指针外部契约。

同时，不能因为原版 AngelScript “看起来像 C”就认为 Clang 是普通面向对象 C++：

- `Stmt` 使用手工 `StmtClass` tag；
- 节点禁用普通 copy/move；
- `ASTContext` 使用 `BumpPtrAllocator`；
- 节点通常不单独析构；
- LLVM/Clang 使用 `isa/cast/dyn_cast`、`StringRef`、`ArrayRef`、`SmallVector` 和 `TrailingObjects`；
- 它刻意避免每个节点都有虚函数、`shared_ptr` 和独立堆分配。

因此应学习的是**强类型语义模型、所有权和分层**，而不是为了“更 C++”而堆继承、虚函数和智能指针。

### 11.9 daScript 提供的补充证据

daScript 更接近轻量脚本语言的现实参考：

```text
Parser/Infer/Normalize/Optimize
           │
           ▼
final typed Function + Expression graph
           ├──► SimNode interpreter
           ├──► AOT
           └──► LLVM AstVisitor
```

它证明一套最终 typed AST 可以同时承担 HIR 和多后端输入职责，不一定要单独复制第二套 HIR DTO。

但它大量使用 `Expression*`、`Variable*`、`Function*` 和 GC-owned AST 图；当前项目还需要 Cache V2、Hot Reload、StableModuleKey、provider identity 和多 Engine remap，因此不能直接照搬其 raw-pointer identity。

### 11.10 三条可选路线

| 路线 | 做法 | 优点 | 主要问题 | 判断 |
|---|---|---|---|---|
| A. 直接扩充 `asCScriptNode` | 在原通用语法节点上加 type、symbol、call、cleanup、Bytecode 等字段 | 初看文件少、迁移入口直接 | 通用节点膨胀；Parser/Sema/CodeGen 更耦合；节点生命周期和语义阶段混杂 | 不推荐 |
| B. 保留现有 Parser AST + sidecar HIR | 继续同步捕获，给 C++/LLVM 使用 | 风险最低；已有 verifier 和大量测试 | 双表示、捕获代码多；Bytecode仍不消费 HIR；长期维护重复 | 适合短期稳定，不是最整洁终态 |
| C. Canonical Typed AST v2 | 新建/演进 ASTContext、Decl/Type/Stmt/Expr；Sema 构建；所有后端统一消费 | 最清晰；最接近 Clang/daScript；真正消除重复语义 | 迁移规模大；必须先拆 Sema 与 Bytecode | 长期推荐 |

### 11.11 推荐的 canonical typed AST v2

建议至少包含以下组件：

```text
asCSourceManager
  - file/section/logical source identity
  - authored/processed/generated source mapping

asCASTContext
  - arena ownership
  - canonical type table
  - Decl/Stmt/Expr allocation
  - stable local NodeId/DeclId

Decl
  - ModuleDecl / NamespaceDecl
  - TypeDecl / ClassDecl / InterfaceDecl / EnumDecl
  - FunctionDecl / MethodDecl / ConstructorDecl / DestructorDecl
  - VarDecl / ParamDecl / PropertyDecl / ImportDecl

Type / QualType
  - primitive / enum / value object / ref object
  - const / reference / handle / in-out
  - canonical identity + target profile ABI view

Stmt / Expr
  - strongly typed concrete semantic nodes
  - implicit conversion nodes
  - resolved decl/call references
  - explicit sequencing/single-evaluation
  - construction/materialization/cleanup
  - structured control flow + resolved transfer targets

asCSema
  - lookup / overload / conversion / access / lifetime
  - builds only verified typed nodes

ASTVerifier / ASTDumper
CFGBuilder
BytecodeCodeGen
CppAOTCodeGen
LLVMCodeGen
```

### 11.12 指针、ID 和序列化的推荐折中

Clang 在同一 `ASTContext` 内大量使用 arena raw pointer，这对遍历速度和表达力很好；当前 HIR 使用 function-local ID，这对 dump、验证和 sidecar 更方便。

当前项目更适合混合模型：

- ASTContext 内部可以使用稳定 arena pointer 或 compact handle；
- graph ownership 和 verifier 使用 `NodeId` / `DeclId`；
- 跨 module、Hot Reload、Cache V2 和 provider 使用稳定 declaration/type key；
- Engine-local `asCTypeInfo*`、function ID 和 property ID 只存在于已解析 runtime view；
- 持久化格式必须是独立版本的 DTO，不直接写 C++ 对象内存。

本次检查也修正了之前一处过度简化：当前 live HIR 的 expression/statement/symbol graph 不保存 Parser node 指针，但 `asSTypedSemanticExpression::type` 和 symbol type 使用 `asCDataType`，而 `asCDataType` 内含 `asCTypeInfo*`。所以当前 live HIR 不是整体 pointer-free，也不能原样跨 Engine 序列化。

### 11.13 推荐迁移方式：提升 HIR 契约，不要先删除 HIR

建议采用 strangler/convergence 迁移：

#### 阶段 0：冻结语义契约

- 把现有 41 个 HIR compiler tests 和 77 个相关消费者当作语义需求，不当作必须保留的数据布局；
- 建立 current AST/HIR/Bytecode normalized dump 对照；
- 明确 source order、reverse formal order、mutation single-evaluation、cleanup、imports、hidden args 和 native ABI。

#### 阶段 1：建立 ASTContext 与最小 typed AST

- 只覆盖 scalar、local、conversion、resolved call 和结构化控制流；
- Parser AST 仍存在；
- 当前 `asCCompiler` 在产生 Bytecode/HIR 时额外构造 AST v2 shadow model；
- verifier 和 deterministic dumper 先行。

#### 阶段 2：让 C++ AOT 和 LLVM 消费 AST v2

- 把 TypedASTJIT C++ emitter 从旧 HIR 切到 canonical typed AST；
- LLVM emitter 同时消费同一 AST；
- VM、旧 Bytecode 和旧 HIR 继续作为差异基准；
- AST v2 unsupported 时逐函数回退。

#### 阶段 3：抽离 Sema

- 把 overload、conversion、call/property resolution、argument planning、lifetime analysis 从 Bytecode emission 中搬到 `asCSema`；
- `asCExprContext` 不再携带已经生成的 `asCByteCode`；
- Sema 输出 immutable typed AST。

#### 阶段 4：Bytecode 也改为 AST 后端

- 新 `BytecodeCodeGen` 只遍历 typed AST；
- 与旧 Bytecode 路径做 function-by-function byte/behavior parity；
- Runtime、SaveByteCode、Cache V2 和调试元数据保持明确版本边界。

#### 阶段 5：删除重复表示

- 所有函数都由 typed AST 驱动 Bytecode/C++/LLVM 后，删除同步 HIR builder；
- 删除旧 `asCExprContext` 中的 codegen/Sema 混合字段；
- Parser 可以像 Clang 一样直接调用 Sema actions，或仅保留短命 syntax tree；
- 最后删除不再使用的 `asCScriptNode` 语义路径。

这条路线的关键是：**删除发生在消费者迁移之后，不是之前。**

### 11.14 为什么不建议原地改造 `asCScriptNode`

如果坚持原地改造，需要至少给一个通用节点同时容纳：

- syntax token；
- exact type；
- value/reference/handle category；
- declaration/call target；
- overload result；
- implicit conversions；
- property rewrite；
- default/hidden/named arguments；
- sequencing；
- construction/destruction；
- cleanup；
- Bytecode temporary/stack slots；
- LLVM/C++ backend temporary state。

这样会形成一个巨大的 tagged union 或可选字段集合。Parser 创建时大多为空，Sema 中途反复修改，Bytecode 又附加目标相关状态；结果是阶段边界更模糊。

更整洁的做法是：

```text
parsed syntax node != typed semantic node != backend value
```

允许 parser syntax 很简单，但 typed AST 必须是独立的强类型模型；backend value 必须由每个 CodeGen session 自己维护映射，不能写回 AST。

### 11.15 对“原版代码偏 C”的判断

这个观察部分成立：

- `asCScriptNode` 是通用 tag + 裸指针链；
- `asCCompiler` 是超大过程式文件；
- `asCExprContext` 同时承载多个阶段；
- Parser/Sema/Bytecode 缺少明确组件边界。

但重构理由不应只是“没有使用足够 C++ 特性”。成熟 Clang 本身也使用 arena、raw pointer、手工 class tag、宏生成节点和非虚 visitor。

真正应该追求的是：

- ownership 清楚；
- phase boundary 清楚；
- semantic fact 只有一个权威；
- backend 不修改 AST；
- 类型和节点强约束；
- 错误状态可验证；
- 文件职责可拆分；
- 可测试、可 dump、可差异执行。

### 11.16 定制 fork 给了什么自由，仍需保留什么约束

检查公共头文件 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`：

- 不公开 `asCScriptNode`；
- 不公开 `asCExprContext`；
- 不公开 `asCTypedSemanticFunction`。

因此内部 AST/Sema 重构不必直接破坏公共 C API/ABI，这是可行性的正面证据。

但是“完全可定制”不能等于忽略：

- 现有 AngelScript 语言行为；
- public API 和 embedding ABI；
- Bytecode/SaveByteCode/Cache V2；
- UE binding 和 ClassGenerator；
- Hot Reload；
- debugger、coverage、timeout；
- StaticJIT provider；
- Standalone compiler；
- 691+ SDK 回归和完整测试体系。

此外，当前 fork 策略仍写明会从高版本 AngelScript 选择性吸收改进。彻底重建 frontend 后不是不能 backport，而是未来 backport 必须从 cherry-pick 进一步变成“读上游语义改动后手工移植到新 Sema/AST”。如果正式选择此方向，应同步更新 fork strategy。

### 11.17 对现有 OpenSpec 的直接影响

当前已有：

```text
openspec/changes/refactor-as-primary-engine-typed-ast-generate
```

它已经完成 proposal/design/tasks，但实现任务是 `0/36`。其前两阶段计划：

- 为当前 HIR 设计 Cache V2 `TypedHIRSidecar`；
- encode/decode/remap `asCTypedSemanticFunction`；
- 把 sidecar 重新挂到 restored function。

如果 canonical typed AST v2 成为近期方向，不建议现在开始这 36 项中的 HIR codec/schema 工作，否则会先把当前 sidecar arena 形状固化成持久化格式，随后又在 AST v2 中重做一次。

推荐先做产品选择：

- 若 AST v2 是长期但一年后才开始：继续 sidecar change 有现实价值；
- 若 AST v2 是下一阶段主线：应暂停/重写该 change，让 Cache 持久化目标指向 canonical typed AST 的稳定 DTO，而不是当前 live HIR layout。

`feature-as-typed-semantic-aot` 已完成的 124 项任务不应丢弃；其测试、evaluation order、cleanup、provenance、verifier 和 fallback 规则应转化为 AST v2 的验收基线。

### 11.18 粗略工程量

以下是架构级粗估，不是交付承诺：

| 范围 | 粗略量级 |
|---|---:|
| ASTContext + Decl/Type/Stmt/Expr 最小模型、dump、verifier | 1–2 人月 |
| scalar/control-flow shadow typed AST + C++/LLVM 双后端 spike | 2–4 人月 |
| 抽出相对完整 Sema，覆盖调用、属性、对象和生命周期 | 6–12 人月 |
| Bytecode 完全改为 typed AST 后端并达到语言行为 parity | 9–18 人月 |
| frontend 全面替换、缓存/热重载/调试/工具链生产闭环 | 12–24+ 人月，持续演进 |

直接给 `asCScriptNode` 加字段可能较快做出 scalar demo，但无法绕过完整迁移规模。

### 11.19 最终推荐

最终建议可以压缩为四句话：

1. **赞成长远收敛成一套 canonical typed AST。**
2. **不建议原地把 `asCScriptNode` 变成语法、语义和 CodeGen 的大杂烩。**
3. **不要先删除 HIR；把它的契约和测试提升进 AST v2，所有后端迁移完成后再删重复表示。**
4. **以 Clang 的 Parser+Sema+ASTContext+CodeGen 分层为主，以 daScript 的轻量 typed AST 多后端实践为辅，不照搬 Clang 的全量复杂度。**

推荐的终态命名甚至可以不再使用 HIR：

```text
AngelScript Canonical Typed AST
```

但它在编译器理论上仍然承担 HIR 的职责。

---

## 十二、问题 9：创建 Clang 风格 canonical AST/编译器 OpenSpec

### 12.1 用户问题

> 创建一个 OpenSpec，用来完整改造 AngelScript 的 AST 和编译体系。采用 Clang 的 AST/frontend 架构替换当前 Parser AST + 混合式 Compiler + sidecar HIR；完善 AST StaticJIT，并兼顾未来 LLVM IR lowering，但本次只创建 OpenSpec，不实现源码。

### 12.2 最终范围

本次选择的是一个完整迁移、长期维护的单一 change：

```text
refactor-as-canonical-typed-ast-compiler
```

它记录的终态是：

```text
asCSourceManager
       │
       ▼
asCParser ──Sema Actions──► asCSema
                                │
                                ▼
                           asCASTContext
                 Decl / Type / QualType / Stmt / Expr
                                │
                ┌───────────────┼────────────────┐
                ▼               ▼                ▼
       BytecodeCodeGen   AST TypedASTJIT   Public/Cache Views
```

“采用 Clang 架构”已经锁定为：

- 使用 Clang 的 SourceManager、Parser+Sema、ASTContext、Decl/Type/Stmt/Expr、implicit nodes、read-only CodeGen、derived CFG 等结构原则；
- 自研 AngelScript 专用节点、类型和生命周期；
- 不链接 `clangAST/clangSema`；
- 不复制或裁剪 Clang 源码；
- 不引入 C++ template/PCH/Objective-C/CUDA/HLSL 等无关复杂度。

### 12.3 兼容性与后端边界

本 change 的兼容目标是：

- 保持现有 AngelScript 语言和 public embedding 行为；
- 保持 VM/UE 可观察行为、已固定诊断、Hot Reload、debugger、coverage、timeout 和路由语义；
- 允许新旧 Bytecode 指令形状不同，但必须使用版本化持久化和行为差异测试；
- canonical AST/Sema/Bytecode 最终覆盖当前所有合法语义，不能在 cutover 后回退旧 frontend；
- AST StaticJIT 只迁移现有能力，不借本 change 扩张到所有对象/容器/lambda/协程等 native emit；未证明的 native form 继续逐函数 `TypedASTJIT -> BytecodeJIT -> VM` fallback；
- LLVM 只作为未来 lowering 边界约束，本 change 不实现 LLVM emitter、ORC、object cache 或 LLVM 测试。

### 12.4 AST 生命周期、公共 API 和 Cache V2

每次 source compile 都构建 module-owned `ASTContext`：

- `capture-off/discard`：Bytecode CodeGen 后允许释放函数体 AST；
- `capture-on/retain`：发布完整 sealed module snapshot；
- Hot Reload 原子发布新 module/snapshot；旧快照通过 AddRef lease 保活并报告 stale generation；
- 公共 V1 使用 `asIASTSnapshot`、opaque Decl/Stmt/Expr/Type ID 和带 `structSize/apiVersion` 的 POD view；
- 不向 public/cache 暴露 arena pointer、`asCTypeInfo*`、`asCScriptFunction*` 或 Engine-local numeric ID。

Cache V2 不保存 live C++ AST 内存，也不把整个 module AST 压成单一 blob：

- SourceIndex/ModuleInterface/TypeSchema/ModuleState 提供 source/decl/type/global 重建语义；
- FunctionBody 可链接 pointer-free `ASTBodySidecar`；
- retain-policy ExactStartup 只有在完整 AST 可 remap、seal、verify 时才原子发布；
- discard-policy 可以只恢复 VM；
- `SaveByteCode`、VM FunctionBody bytes、`.hir.txt/.hir.json` 和 AST dump 都不是 AST 输入。

### 12.5 迁移策略

选择 Shadow Convergence，而不是 Big Bang 或把 HIR 包装成新 AST：

1. 冻结 Parser/Sema/HIR/Bytecode/VM/StaticJIT 语义基线；
2. 建立 SourceManager、ASTContext、Type/QualType、verifier、dump；
3. shadow-build declaration/type AST；
4. shadow-build expression/statement/call/lifetime AST；
5. 建立公共 snapshot 和 Cache V2 DTO；
6. 迁移 TypedASTJIT；
7. 实现只读 canonical BytecodeCodeGen 并做隔离 Engine 差异执行；
8. canonical pipeline 成为默认和唯一生产路径；
9. 最后删除 HIR builder/accessor、`asCExprContext::bc` 混合状态和生产 `asCScriptNode` semantic path。

Shadow 模式只是迁移工具，不是终态；生产版本不保留永久 dual compiler。

### 12.6 OpenSpec 记录结果

新 change 已包含：

- `proposal.md`；
- `design.md`；
- Clang 本地源码证据附件；
- 旧 change 吸收映射附件；
- 9 个 capability delta spec；
- 12 个实施里程碑、93 项全部未勾选的未来任务。

关键入口：

- `openspec/changes/refactor-as-canonical-typed-ast-compiler/proposal.md`
- `openspec/changes/refactor-as-canonical-typed-ast-compiler/design.md`
- `openspec/changes/refactor-as-canonical-typed-ast-compiler/specs/`
- `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md`
- `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/clang-ast-reference.md`
- `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/superseded-change-map.md`

### 12.7 旧 OpenSpec 的处理

原 `refactor-as-primary-engine-typed-ast-generate` 的目标被完整吸收，包括：

- `TypedHIRSidecar`/capture/restore 计划改为 canonical AST retention 和 `ASTBodySidecar`；
- primary matching-profile Generate；
- non-matching generation Engine；
- Hot Reload freeze/containment；
- native-form catalog；
- dump/diagnostics和最终验证。

原 change 在实现仍为 `0/36` 时通过：

```powershell
openspec archive "refactor-as-primary-engine-typed-ast-generate" --skip-specs -y
```

归档为：

```text
openspec/changes/archive/2026-08-20-refactor-as-primary-engine-typed-ast-generate
```

`--skip-specs` 确保旧 `TypedHIRSidecar` 等冲突 delta 不写入当前 specs。已完成的 `feature-as-typed-semantic-aot` 不归档，其 124 项语义、verifier、fallback 和 TypedASTJIT 测试继续作为新 change 的历史基线。

### 12.8 本次没有实现什么

本次是 record-only：

- 没有修改 `Plugins/Angelscript` 源码；
- 没有实现 AST、Sema、Bytecode、StaticJIT、Cache 或公共 API；
- 没有运行 UE build/Automation；
- 没有创建或切换 worktree；
- 没有提交或推送。

---

## 十三、问题 10：词法分析体系是否也应参考 Clang 改造？

### 13.1 用户问题

> 在 canonical typed AST 和新编译体系的背景下，现有 AngelScript 词法分析体系是否也应参考 Clang 进行修改？

### 13.2 结论先行

建议改。正式落档时采用一个可独立验证的 `refactor-as-source-aware-lexical-pipeline` OpenSpec，但它被明确定位为 `refactor-as-canonical-typed-ast-compiler` 的前置/协同层，而不是与 canonical frontend 竞争的第二套 SourceManager、Parser 或 AST 架构。

但“参考 Clang”的准确含义是：

- 参考 `SourceManager -> raw Lexer -> preprocessing/token source -> token buffer/cursor -> Parser` 的分层、所有权和源位置契约；
- 保留 AngelScript 自己的 token kind、字面量、handle/reference、heredoc、`!is`、UE 扩展以及当前可观察诊断语义；
- 使用 AngelScript-native standard C++ 实现，不链接 `clangLex`/`clangBasic`，不复制 Clang 源码；
- 不引入 C/C++ 宏展开、header include、trigraph、PCH/module 等与本语言无关的复杂度。

这项改造不是 HIR→LLVM 的技术前置：LLVM backend 只需要正确的 typed semantic AST。它是 canonical frontend 的源码真值、诊断、工具、Hot Reload 和未来 incremental parsing 基础，因此值得在 Parser/Sema 大迁移时一起完成。

### 13.3 当前实际上存在两套词法判断

第一套是 maintained fork 中的正式 tokenizer：

```text
asCTokenizer::GetToken(raw pointer, remaining length)
    -> eTokenType + tokenLength + optional asETokenClass
    -> asCParser::GetToken
    -> sToken { type, pos, length }
    -> asCScriptNode
```

它的特征是：

- `asCTokenizer` 每次只识别当前字节指针处的一个 token；
- `sToken` 只有 `type/pos/length`，`pos` 是当前 processed buffer 的局部偏移；
- Parser 直接保有 `sourcePos`，遇到回退时通过 `RewindTo`/`SetPos` 重设字节偏移；
- 只有一个 `lastToken` 缓存，更深回看可以重新 tokenize 同一段源文本；
- Parser 自己跳过 whitespace/comment，诊断时调 `asCScriptCode::ConvertPosToRowCol`；
- raw identifier 识别、keyword 分类和部分 literal 形状判断混在同一类中；
- `asIScriptEngine::ParseToken` 是现有公开嵌入 API，只返回 `asETokenClass` 和长度，迁移时不能无意破坏。

第二套在 UE `FAngelscriptPreprocessor::ParseIntoChunks` 中。它并不调用正式 tokenizer，而是逐 `TCHAR` 自己维护：

- line/block comment 状态；
- string 和 escape 状态；
- brace/parenthesis/scope 深度；
- identifier/keyword 边界；
- `#if/#ifdef/#elif/#else/#endif` 指令；
- `class/struct/enum/namespace/import`、`UCLASS/UFUNCTION/UPROPERTY/UMETA`、delegate、name literal 和 format string 识别；
- 源文本替换、生成代码以及 processed↔authored/generated provenance 范围。

这意味着当前不只是“Tokenizer API 比较简单”，而是 compiler 和 UE preprocessor 可以对同一段文本做不同的字符分类。当前 `IsStartOfIdentifier` 甚至有 `PrevChar >= '0' && PrevChar <= '1'` 这样只覆盖 `0..1` 的边界检查；不论该分支当前是否能被有效程序频繁触发，它都证明复制词法规则已产生 drift 风险。

### 13.4 Clang 真正值得借鉴的词法分层

本地 Clang 研究源码显示的重点不是某个扫描算法，而是五个边界：

| Clang 结构 | 主要职责 | AngelScript 应借鉴的契约 |
|---|---|---|
| `SourceManager` / `SourceLocation` | 管理 buffer、file ID、spelling/expansion 位置和行列映射 | source identity/location 不再是 Parser 中的裸 `size_t pos` |
| `Token` | 保存 kind、location、length、少量 flags 和短生命词法 payload | token 是可传递的值，不是立即制造 AST node 的副作用 |
| raw `Lexer` | 在一个 SourceManager-owned buffer 上顺序识别 raw token | 只负责词法边界，不做名字查找、类型、重载或 AST 构造 |
| `Preprocessor` / token source | 处理 directive、标识符实例化、keyword/macro 和 token cache/lookahead | 把 raw lexing 与条件处理、keyword 政策和 Parser token 流分开 |
| `Parser` | 保有一个 current `Token`，通过 token source 消费和 lookahead | Parser 使用 token index/checkpoint，不自己重新扫描 raw bytes |

Clang raw Lexer 先产生 `raw_identifier`，再由 Preprocessor/IdentifierTable 实例化 identifier 并设置 keyword token kind。这个分层对 AngelScript 尤其有价值：硬关键字可以表驱动分类，contextual word 仍作为 identifier 交给 Parser/Sema，不应让 raw scanner 根据语义上下文猜测。

Clang 还将 broad numeric/string token 与后续 literal parser 分开。AngelScript 不必完全复制它的 token kind 粒度，但 literal 文本边界、escape/格式验证、数值解码和最终 Sema type 不应继续混成一个阶段。

### 13.5 推荐的 AngelScript-native 目标结构

概念管线建议修正为：

```text
authored source buffers
          |
          v
   asCSourceManager
          |
          v
      asCRawLexer
          |
          v
AS/host source preparation and directive token source
(conditionals, UE annotations/generation, exact provenance)
          |
          v
 asCTokenBuffer / asCTokenCursor
 (keyword policy, trivia policy, lookahead, checkpoint/restore)
          |
          v
 asCParser -------- Sema actions --------> asCSema
                                             |
                                             v
                                        asCASTContext
```

具体边界建议如下。类名只是设计占位，在正式 OpenSpec 修订前不构成 ABI 承诺。

1. `asCSourceManager`
   - 拥有 authored、processed 和 generated buffer 的生命期与稳定逻辑 source key；
   - 产生紧凑 `asCSourceLocation/asCSourceRange`；
   - 负责 line/column、authored/processed/generated provenance 映射；
   - 取代 `asCScriptCode` 上 HIR-specific provenance 和 Parser-local row/column 换算职责。

2. `asCRawLexer`
   - 仅在一个 immutable SourceManager buffer 上向前扫描；
   - 产生 token kind、source range、length 和 `StartOfLine/LeadingSpace/Malformed` 等最小 flags；
   - 可选保留 comment/whitespace trivia，但默认 Parser 视图不消费 trivia；
   - 不持有 AST/Sema/Bytecode/UE 对象，不做 symbol lookup 或 runtime type 决策。

3. `asCToken`
   - 是短生命、可复制的紧凑值，不是 `asCScriptNode`；
   - 内部可引用 snapshot-local identifier/literal table，但不把 `asCTypeInfo*`、AST pointer 或 Engine numeric ID 变成 durable identity；
   - 不直接进入公共 AST V1 或 Cache V2 `ASTBodySidecar`。AST/cache 保留 source range 与 stable spelling/key 即可。

4. identifier/keyword/literal 层
   - raw identifier 先识别文本边界，再按 AngelScript language options 和 token definition table 实例化；
   - hard keyword 进入 keyword token kind；contextual keyword 保持 identifier，由 Parser/Sema 解释；
   - numeric/string/heredoc/name/format literal 由专门 literal parser 验证和解码，最终类型与宽度属于 Sema；
   - 迁移期先保持现有 token kind 和诊断，不顺便修改 Unicode 或数字字面量语义。

5. `asCTokenBuffer/asCTokenCursor`
   - 每个 processed source 至少 lex 一次，Parser 使用 token index；
   - 支持 O(1) lookahead、checkpoint、commit 和 restore；
   - 取代 `sourcePos + lastToken + RewindTo` 的字节级重扫描模式；
   - 错误恢复使用 token kind/source range 作为同步点，不通过任意 `pos + 1` 尝试重新切 token。

6. AS/host source preparation
   - `FAngelscriptPreprocessor` 继续拥有 UE-specific descriptor、reflection metadata、conditional flag、generated helper 和 source-provider 协调；
   - 它应逐步改为消费共享 raw token/source 事件，不再自己实现另一套 comment/string/identifier/bracket scanner；
   - UE types 留在 host adapter，maintained frontend 仍为 standard C++；
   - `UCLASS/UFUNCTION/UPROPERTY` 等最终是保留 source-preparation 变换，还是提升为 Parser/Sema 可见的语言属性，可在后续实现证据下分项决定；这些都不应塞进 raw Lexer。

### 13.6 三种路线对比

#### 路线 A：保留现有 `asCTokenizer`，只补 SourceManager wrapper

优点是改动小，可以更快开始 AST/Sema 构造。缺点是 Parser 仍使用裸字节位置和重 tokenize，UE preprocessor 仍保留重复扫描器，新 SourceManager 最后可能只是包装而不是源码权威。

该路线可作为第一个迁移适配器，不适合作为终态。

#### 路线 B：Clang-inspired、AngelScript-native 词法基础

即上述 `SourceManager + raw Lexer + TokenBuffer/Cursor + host token source` 结构。它保持语言语义和公共 API 兼容，却把 source/token/parser 边界一次做正确。

这是推荐路线。工程量明显高于 wrapper，但它与 canonical Parser/Sema 原本就是同一迁移边界；如果先把 Parser 全部改完后再换 token contract，反而会产生第二次大规模前端改造。

#### 路线 C：直接移植/复制 Clang Lexer + Preprocessor

该路线会引入 C/C++ token、macro expansion、include stack、pragma、language mode、header/module 和大量 LLVM ADT 依赖，而仍无法直接表示 AngelScript/UE 语义。它的维护和二进制成本远大于收益。

该路线明确拒绝。

### 13.7 不应照搬 Clang 的部分

- 不需要 Clang C preprocessor 的 object/function macro expansion、token paste、stringize、include search 和 header guards；
- 不需要 trigraph、escaped-newline translation phase、C/ObjC 多语言 token mode；
- 不应立即复制 Clang annotation token。AngelScript 语法歧义较小，Sema 结果应直接进入 canonical AST；只在未来 IDE/reparse 有证据时才加短生命 annotation；
- 不应把 Clang `Token::PtrData` 的指针设计复制到 public/cache contract。短生命编译内部可以用 interned pointer，持久化和公共查看必须仍是 ID/stable key；
- 不应为了“像 Clang”改变当前 AngelScript Unicode、literal、comment、keyword 或错误恢复行为。语义改善应在 parity 迁移完成后单独记录。

### 13.8 与公共 API、Cache V2 和 LLVM 的边界

#### 公共 `ParseToken`

`asIScriptEngine::ParseToken` 可继续存在。实现可改为在单个临时 SourceBuffer 上调用新 raw Lexer，再映射回旧 `asETokenClass + tokenLength` 契约。这是兼容 facade，不应反向限制新 Parser 的内部 token 表达。

#### 公共 AST V1

默认不向 `asIASTSnapshot` 暴露完整 token buffer 和 trivia。AST 节点拥有 source range，SourceManager 可解析逻辑路径/行/列/生成来源已足够。如果未来 formatter/refactoring 需要 token/trivia snapshot，应另设版本化只读 lexical view，不冻结内部 `asCToken` C++ layout。

#### Cache V2

不建议在当前 `ASTBodySidecar` 中持久化 live token buffer、identifier pointer 或 Parser cursor。`SourceIndex`、稳定 source key、processed/generated mapping、source hash 和 AST source ranges 仍是持久化边界。只有未来通过测量证明磁盘 token cache 对 incremental parse 有明确价值时，才应增加独立 schema。

#### LLVM

LLVM lowering 不消费 token。词法改造对 LLVM 的价值是间接的：它保证 canonical AST 有可靠 source range、隐式/生成语义来源和稳定诊断，却不应让 LLVM backend 看到 lexer/token/preprocessor 内部状态。

### 13.9 推荐的迁移顺序

1. 冻结现有 tokenizer、Parser source range/error recovery、公共 `ParseToken`、UE preprocessor 变换与 provenance 差异基线。
2. 在 `asCSourceManager` 里建立 authored/processed/generated buffer 与紧凑 location/range，先适配当前 `ProcessedCode`。
3. 引入 `asCToken/asCRawLexer/asCTokenBuffer/asCTokenCursor`，用旧 tokenizer 做 differential oracle，保持 token kind、长度、trivia 和错误类别一致。
4. 让新 Parser/Sema actions 只消费 TokenCursor；旧 Parser 在 shadow mode 中继续读 `asCTokenizer`。
5. 把 identifier/keyword/literal 分层迁入新 lexical pipeline，使用诊断和 VM 差异测试保证语义。
6. 让 `FAngelscriptPreprocessor` 逐步消费共享 raw token/source 事件，先移除 comment/string/identifier/bracket 重复识别，再按证据调整 UE syntax transform。
7. 让公共 `ParseToken` 转到新 Lexer 兼容 facade，在所有内部消费者迁移后删除旧 Parser 的 byte-position tokenizer path。
8. 只在 canonical frontend 成为唯一生产路径后，才删除旧 tokenizer 实现或将其收缩为 API compatibility adapter。

这个顺序使 lexical 迁移成为 Shadow Convergence 的一部分，不需要先停下 AST/Sema 工作进行一次 big-bang preprocessor rewrite。

### 13.10 对现有 canonical AST OpenSpec 的影响与正式处理

现有 OpenSpec 已经定义 `asCSourceManager`，但管线文字直接从 SourceManager 跳到 Parser，任务 2 也没有定义 Token/Lexer/TokenCursor 的产品边界。2026-08-21 的后续请求已经把本建议正式记录为独立 change：

- `refactor-as-source-aware-lexical-pipeline` 负责 SourceManager 的 lexical substrate、Token/RawLexer、identifier/keyword/literal 分层、TokenBuffer/Cursor、当前 Parser 输入迁移、公共 `ParseToken` compatibility facade 和 UE preprocessor lexical adapter；
- `refactor-as-canonical-typed-ast-compiler` 继续负责 Parser-to-Sema actions、ASTContext、Decl/Type/Stmt/Expr、Bytecode/TypedASTJIT、公共 AST snapshot、Cache V2 AST DTO 及旧 HIR/semantic tree 退役；
- 两者只实现一套 `as_source_manager.h/.cpp`。正式改源码前，必须先协调 canonical tasks 2.1/2.2 的所有权和验收边界；
- lexical change 可以先让当前 `asCParser` 使用 TokenCursor、仍暂时生成 `asCScriptNode`，因此能够独立完成和验证；
- lexical change 通过并不自动勾选 canonical change 的任务，canonical Sema/AST/Bytecode/Cache 要求仍需独立证据。

这样拆分的理由不是建立第二套前端，而是把可由当前 Parser/Preprocessor 独立验证的词法迁移从 93 项语义/后端迁移中抽出来，同时用 coordination attachment 防止 SourceManager 重复实现。正式 change 的完整内容见问题 11。

### 13.11 本问题的最终判断

一句话总结：

> 我们应当参考 Clang 重建词法层的边界，但不应移植 Clang 词法器；目标是一套 AngelScript-native、SourceManager-aware、可缓存/回看、为 Parser/Sema 服务的 token 管线，并让 UE preprocessor 逐步共享同一套 lexical truth。

---

## 十四、问题 11：创建 source-aware lexical pipeline OpenSpec

### 14.1 用户问题

> 为“词法分析体系是否应参考 Clang 改造”创建一个 OpenSpec，用来正式说明目的、架构边界和后续实施计划。

### 14.2 处理结果

已创建 plan-only、record-only OpenSpec：

```text
openspec/changes/refactor-as-source-aware-lexical-pipeline/
```

当前状态是：

- proposal、design、specs、tasks 四类 artifact 已齐全；
- `openspec status --change refactor-as-source-aware-lexical-pipeline --json` 报告 `isComplete: true`，表示规划 artifact 完整，不表示源码实现完成；
- `openspec validate refactor-as-source-aware-lexical-pipeline --strict` 已通过；
- tasks 为 `0/87`，其中 65 项标记为 TDD、22 项为 Non-TDD；
- 本轮没有修改 `Plugins/Angelscript` 子模块源码，没有运行 UE build/test，也没有实现新的 Lexer。

### 14.3 为什么单独建 change，但它不是竞争架构

上一问题最初倾向把 Lexer 直接补入 93-task canonical compiler change；继续拆解后，正式落档采用独立 change，原因是词法迁移可以在 canonical AST/Sema 尚未实现前就完成闭环：

```text
现有 asCParser
  从 byte-position tokenizer
  迁到 SourceManager + RawLexer + TokenBuffer/Cursor
  仍可暂时生成 asCScriptNode
```

这样可以独立证明：

- 同一 immutable buffer 不再因 Parser rewind 重复 tokenize；
- public `ParseToken` 保持兼容；
- Parser acceptance/recovery/diagnostics/source range 保持一致；
- UE preprocessor 逐步删除重复 comment/string/identifier/delimiter scanner；
- Standalone 和 UE 对相同 processed buffer 使用同一 core lexical semantics。

它之所以不是竞争架构，是因为 OpenSpec 明确规定：

- 只允许一套 `asCSourceManager` 和 source identity；
- lexical change 的输出就是 canonical Parser/Sema 后续要消费的输入；
- lexical change 不创建 Decl/Type/Stmt/Expr、Sema、Bytecode、HIR replacement 或 LLVM backend；
- canonical change 仍是 high-level semantic authority 的唯一长期 change；
- 两份 change 在真正改 `as_source_manager.h/.cpp` 前必须先协调 tasks 2.1/2.2，不能并行创建重复实现。

### 14.4 OpenSpec artifact 组成

| Artifact | 内容 |
|---|---|
| `proposal.md` | 说明为什么当前 `sToken + byte rewind` 和 UE 独立 scanner 需要收敛、变更边界、capability 与影响 |
| `design.md` | 定义两阶段 host/core source flow、SourceManager、Token、RawLexer、identifier/keyword/literal、TokenBuffer/Cursor、Parser、`ParseToken`、Cache V2、迁移和 rollback |
| `specs/as-source-aware-lexical-pipeline/spec.md` | 12 项 requirement、28 个 scenario，覆盖 core lexical contract、Parser、public API、lifecycle、limits、shadow convergence 和 Standalone |
| `specs/as-host-preprocessor-lexical-integration/spec.md` | 10 项 requirement、20 个 scenario，覆盖 UE adapter、host ownership、output/provenance、clustered migration、transaction containment 和 scanner retirement |
| `tasks.md` | 9 个里程碑、87 项未来任务，从行为基线、SourceManager、RawLexer、TokenCursor、Parser、UE preprocessor 到 cutover、文档和全量验证 |
| `attachments/current-state-and-clang-reference.md` | 当前源码证据、现有测试入口、Clang pinned path 与明确不采纳项 |
| `attachments/canonical-change-coordination.md` | 与 canonical compiler change 的所有权、重叠任务、顺序 gate、Cache V2 边界和完成条件映射 |

### 14.5 正式确认的目标管线

Core processed-source 路径：

```text
immutable processed source buffer
              |
              v
      asCSourceManager
              |
              v
         asCRawLexer
              |
              v
classifier / identifier table / literal parser
              |
              v
   asCTokenBuffer / asCTokenCursor
              |
              v
         asCParser
              |
              v
current asCScriptNode -> future Parser+Sema canonical AST
```

UE authored-source preparation 路径：

```text
authored source + logical key
              |
              v
SourceManager + RawLexer lexical facts
              |
              v
FAngelscriptPreprocessorLexicalAdapter
              |
              v
FAngelscriptPreprocessor
directives / descriptors / provider / rewrites / generated source
              |
              v
processed/generated buffer + provenance mapping
              |
              v
core processed-source path
```

这里 authored buffer 被 host preparation 扫描一次、processed buffer 被 Parser pipeline 扫描一次是合理的，因为它们是不同 immutable generation；禁止的是 Parser 为了回退而对同一个 buffer generation 重新扫描。

### 14.6 关键产品边界

1. **RawLexer 不负责 UE 语义**：`UCLASS/UFUNCTION/UPROPERTY`、conditionals、include/provider、descriptor、generated declaration 和 ClassGenerator metadata 继续由 host 管理。
2. **Token 不是 AST/HIR**：token 只包含 kind、source range、flags 和短生命 identifier/literal ref，不携带 Sema、Runtime、UE、Clang 或 LLVM object。
3. **Cache V2 不缓存 live token stream**：只持久化 stable logical source key、hash、authored/processed/generated mapping、source range 和必要 lexical compatibility identity。
4. **公共 API 先兼容**：`asIScriptEngine::ParseToken` 保留原签名和行为，由新 lexer 提供 compatibility facade；未来 tooling token snapshot 必须另行版本化。
5. **语言语义不顺便改变**：keyword、Unicode identifier、numeric/string/heredoc/comment 规则首先保持 parity；任何语言改进单独立项。
6. **不引入 Clang/LLVM 依赖**：只参考 compact source location、token、monotonic lexer、token source 和 Parser consumption 分层。
7. **迁移采用 Shadow Convergence**：old/new path 只能在隔离的 development/test Engine 中对比，只有选中的一条路径可以发布 processed source 或 executable module；最终 Shipping 不保留 dual lexer。

### 14.7 计划的实施顺序

正式 tasks 将工作分为九组：

1. 协调 canonical change 的 SourceManager 所有权并冻结 lexical/Parser/preprocessor/public API/performance 基线；
2. 实现共享 SourceManager lexical substrate；
3. 实现 compact token、RawLexer、identifier/keyword/literal 分类和 deterministic dump；
4. 实现 TokenBuffer/Cursor，并让当前 Parser 不再 byte-position retokenize；
5. 按 feature cluster 迁移 UE preprocessor 到 lexical adapter；
6. 闭合 Runtime、Hot Reload、Standalone、Cache V2 和生命周期边界；
7. 通过 malformed input、并发、determinism 和 performance gate；
8. 切换唯一 production lexical path、删除重复 scanner，并把稳定输入交给 canonical compiler change；
9. 更新中英文文档并运行 focused/build/Standalone/All/OpenSpec 验证。

计划中明确要求 plugin 是子模块：未来实现先提交 `Plugins/Angelscript`，再更新父仓库 OpenSpec/docs/gitlink；本轮没有创建 worktree 或提交。

### 14.8 对当前判断的影响

本问题把 D17 从“建议、待同步”提升为正式 record，并新增一个重要的组织决策：

> 词法迁移可以独立成 change，但必须是 canonical frontend 的下层协同 change；“独立可验证”不等于“独立 source/compiler authority”。

因此，后续若开始 implement，应先执行 lexical tasks 1 的 baseline/ownership reconciliation，不能直接删除 `asCTokenizer`、改写 `ParseIntoChunks` 或在 canonical worktree 中另造 SourceManager。

---

## 十五、问题 12：AST/语法分析之后，AngelScript 内部还有哪些值得重构的地方？

### 15.1 用户问题

> AngelScript 内部是否还有许多可以重构和利用的地方？为什么看起来没有很多内部 `Ixx` 集成、通常只有一个具体类？在已经改造 AST 和语法分析之后，接下来还可以重构什么，并借此支持哪些功能？

### 15.2 核心结论

有，而且剩余机会主要不在“再增加一批 `Ixx` 接口”，而在于把几个已经过度膨胀的具体类拆成**明确所有权、显式输入输出、可验证 artifact 和真实扩展点**。

AngelScript 当前不是没有接口。它拥有两种已经有价值的接口：

1. public embedding ABI facade，例如 `asIScriptEngine`、`asIScriptModule`、`asIScriptContext`、`asITypeInfo`；
2. UE 插件中位于真实变化点的窄接口，例如 source provider、Cache V2 resolver/codec/storage、JIT backend/provider、engine extension。

很多 public `asI*` 只有一个具体实现是正常的，因为它们首先用于：

- 隔离公开 ABI 与内部布局；
- 管理引用计数和句柄生命期；
- 允许宿主以稳定 API 嵌入引擎；
- 隐藏 `asC*` 实现；
- 在少数位置提供 mock、provider 或第三方实现能力。

它们不是为内部 dependency injection 设计的。反过来，如果为了“看起来像现代 C++”给 Parser、Sema、ASTContext、GC、VM 每一层都添加一个只有一个实现的纯虚接口，通常只会增加间接调用、所有权模糊和调试成本。

当前真正的结构性问题是：

```text
少数超大 concrete class
  = public facade
  + mutable registry
  + compilation session
  + artifact owner
  + runtime activation
  + diagnostics/tooling hook
  + host integration
```

因此推荐原则是：

> 保留稳定 public facade；内部优先采用 concrete composition、immutable artifact、显式 session/transaction 和 narrow consumer/capability。只有存在真实替换实现、外部插件点、跨 ABI 边界或测试替身时，才增加 `Ixx`。

### 15.3 “没有很多 Ixx”这一观察应怎样解释

当前 public `asI*` 与内部实现大体对应如下：

| Public API | 当前主要实现 | 该接口的真实价值 |
|---|---|---|
| `asIScriptEngine` | `asCScriptEngine final` | embedding ABI、引擎句柄、公开配置和工厂入口 |
| `asIScriptModule` | `asCModule` | module public API、引用/生命周期隔离 |
| `asIScriptContext` | `asCContext final` | execution context API、调用与异常边界 |
| `asIScriptGeneric` | `asCGeneric final` | generic native-call ABI |
| `asITypeInfo` | `asCTypeInfo` | runtime type metadata public handle |
| `asIScriptFunction` | `asCScriptFunction final` | function metadata/public handle |
| `asIScriptObject` | `asCScriptObject` | script object public handle |
| `asILockableSharedBool` | `asCLockableSharedBool` | 弱引用/线程安全共享状态契约 |
| `asIASTSnapshot` | `asCASTSnapshot` | 新 canonical AST 的版本化 snapshot lease |
| `asIJITCompiler` | Runtime JIT coordinator | 外部 JIT integration seam |
| `asIStringFactory` | UE `FString` factory | host string representation seam |
| `asIBinaryStream` | Cache/bytecode streams | serialization I/O seam |

public header 中还存在值得单独处理的边界：

- `asISemanticObserver` 已经是扩展概念，但旧 Compiler 通过 magic engine user-data ID 找到单个 observer，不是明确的 compilation-session consumer；
- `asIThreadManager` 当前几乎是空壳，公开的线程 API 与实际 UE 宿主线程设施之间尚未形成完整实现；这一问题已经被 `feature-as-multithreaded-type-registration` 覆盖，不应重复立项；
- 全局内存函数 API 与当前 UE fork 直接使用 `FMemory` 的实现并不对称，更适合以后收敛成 per-engine host-service contract，而不是继续添加 process-global hook。

另外，UE 插件层其实已经在正确的位置使用了接口：

- `IAngelscriptSourceProvider`：磁盘、冻结输入和测试 provider；
- Cache V2 resolver、codec、storage、file-ops：替换实现、测试和持久化边界；
- StaticJIT/RuntimeJIT backend、factory、session 和 artifact provider；
- `IAngelscriptExtension`：Coverage、CrashSnapshot、ClassReload、Editor menu 等生命周期扩展。

这说明项目已经有一个可复用的判断标准：**在 variation、host boundary、lifetime 和测试替换点使用接口；在 Parser/Sema/AST/registry 内部使用清晰的具体组件。**

### 15.4 当前 AST/Sema 改造的实际完成度

本次检查以以下位置的用户工作为准：

```text
.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/
```

主 checkout 的 `Plugins/Angelscript` 仍保持干净基线，因此下面是对该 worktree 当前快照的判断，不代表相应 OpenSpec 已完成。

已经建立的结构包括：

- `asCASTContext`；
- Decl/Stmt/Expr/Type 节点；
- `asCQualType` 和 Runtime type bridge；
- `asCSourceManager`；
- `asCSema`；
- AST verifier；
- internal AST 与 public view/snapshot 的初步分层；
- Parser 的 `SetSema` 接口和测试入口。

但当前仍是一个重要的 scaffold/milestone，而不是已经成为 production authority 的完整 Parser→Sema→AST 流水线。关键证据是：

1. `asCParser::sema` 默认是空指针，production 路径尚未调用 `SetSema`；目前可见调用只在新测试里；
2. `ParseScript` 是先完成旧 `asCScriptNode` parse，再调用 `ActOnParsedScript`；
3. `asCSema` 当前仍递归遍历旧 `asCScriptNode` 进行转换，不是 Parser 在识别语法时发出细粒度 Sema action；
4. canonical Bytecode CodeGen readiness 仍明确返回 `false`，选择 canonical pipeline 会被 module build 拒绝；
5. `PublishCanonicalASTSnapshot` 当前新建并发布一个只包含 TranslationUnit 的空 context，而不是发布本次 build 中由 Sema 构建的完整 AST；
6. Runtime type bridge 目前主要覆盖 `void`、primitive 和 qualifier，named/runtime/host type 尚未闭合；
7. SourceManager 仍是最小实现，lookup 主要为线性路径，也没有完整 authored→processed→generated provenance/content identity；
8. verifier 只覆盖基础 ID/range/kind，不足以证明 ownership、parent-child 对称、cycle、exact type/value category、stable reference 和 public snapshot invariants；
9. public snapshot 的 immutable/thread/versioned ABI 契约还未闭合，例如 mutable context 暴露、generation state 和 `structSize/apiVersion` 写入规则；
10. Cache V2 `ASTBodySidecar`、Hot Reload generation 和旧 snapshot lease 尚未与这套 AST 真正接通。

因此，最优先的工作不是马上再拆另一个 subsystem，而是先在现有两个 OpenSpec 中把这条链闭合：

```text
SourceManager/TokenCursor
        ↓
Parser actions → Sema → build-owned ASTContext
        ↓
complete + verify + seal
        ↓
Bytecode / TypedASTJIT / public snapshot / Cache DTO
        ↓
module generation atomic publish
```

尤其要禁止“类已经存在，所以功能已经完成”的判断。只有 production Parser、build session、artifact publication 和 consumer 都连接后，canonical AST 才是真正的 compiler authority。

### 15.5 第一优先级：Compiler Session 与 Module Activation Transaction

这是在 canonical AST 正确性之后，价值最高的新重构方向。

当前核心大文件规模说明了职责聚集：

| 文件 | 当前约行数 | 混合的主要职责 |
|---|---:|---|
| `as_compiler.cpp` | 22,952 | 语义分析、表达式 lowering、Bytecode、HIR capture、diagnostics |
| `as_builder.cpp` | 7,637 | declaration/type/function/global build、staging、module mutation、cache/build callbacks |
| `as_restore.cpp` | 7,414 | format read、validation、symbol/relocation、layout rebuild、commit |
| `as_scriptengine.cpp` | 6,582 | registries、modules、configuration、diagnostics、GC/JIT/lifecycle |
| `as_context.cpp` | 6,383 | public context、VM loop、stack/frame、exception、debug hooks、JIT |
| `as_parser.cpp` | 5,077 | parse、rewind/recovery、node construction |
| `as_module.cpp` | 3,136 | public module、compile state、declarations、runtime globals/imports、publish/hot reload |

UE 宿主的 `Core/AngelscriptEngine.cpp` 也约有 9,122 行；`CompileModules` 及相关 phase helpers 同时协调 source、parallel parse、module build、type/function/layout/global phases、Cache V2、JIT、reference replacement、Hot Reload 和 module swap。

建议形成三层明确职责：

```text
asCCompilationSession                 native AS core
  输入：invocation/options + immutable sources + engine service views
  输出：verified, immutable module/function compile artifact

FAngelscriptCompileCoordinator        UE host
  职责：多 module dependency/order/parallelism、诊断汇总、Cache/JIT policy

FAngelscriptModuleActivationTransaction
  职责：validate → prepare → commit/rollback → publish generation
        连接 Hot Reload、Cache restore、JIT binding 和旧 generation lease
```

`FAngelscriptEngine` 和 `asIScriptEngine` 继续作为生命周期/public facade，不需要再造一个同样巨大的 `ICompilerService`。

这个拆分可以直接支持：

- 编译失败不污染 live module；
- Cache restore 与 source compile 产生同一种 verified artifact；
- Hot Reload 原子提交或回滚；
- 多 module 并行 compile 后有序 activation；
- compiler-free packaged runtime；
- 未来 canonical AST→LLVM/Object 后端复用相同输入和 commit contract；
- 更精确的增量函数编译和 generation lease。

上游 `as_module.h` 已有把 compiler 独立出来、允许完整 module 或单函数编译的 TODO，但不建议直接把这个 TODO 实现成一个巨型 public `asIScriptCompiler`。先用 internal session 和 artifact 证明边界，确有外部 consumer 时再稳定 public ABI。

### 15.6 第二优先级：显式 Engine ownership 与内部 registry composition

`asCScriptEngine final : asIScriptEngine` 本身没有问题；问题是它同时持有 type/function/global/module/configuration registries、builder slot、tokenizer、GC、diagnostics、JIT、namespace、callbacks、properties 和 shutdown state，并通过多个 `friend` 让 Builder、Compiler、Context、Module、Restore、ByteCode 直接访问内部状态。

可逐步组合为具体的 owned component：

- `asCTypeRegistry` / type-system state；
- `asCFunctionRegistry`；
- `asCModuleRegistry`；
- `asCConfigurationRegistry`；
- `asCDiagnosticEngine`；
- `asCBuildCoordinator` 或 build-slot state；
- `asCHostServices`，封装 allocator/object/thread/platform callbacks。

这些组件初期不需要 public interface。它们应由 `asCScriptEngine` 明确拥有，并只向 Compiler/Builder/Context 暴露 narrow mutable/read-only view。

当前 Runtime 中仍有大量 `FAngelscriptEngine::Get()` ambient lookup。检查到约 195 个调用点，分布在 Binds、ClassGenerator、Core、ThirdParty、Cache、Dump、Debugging、Preprocessor 和 StaticJIT。正确迁移不是机械删除，而是分类：

1. compiler/generator/cache 的 engine-bound 工作：显式传入 Engine 或所需 service；
2. 已经持有 AS context/engine 的 runtime callback：通过 owner map/`TryGetByScriptEngine` 找准确 owner；
3. console、Editor UI 和“当前 primary engine”产品边界：允许保留带明确语义的 ambient facade。

这项工作可以减少多 Engine、parallel build、Standalone 和测试隔离中的隐式耦合。它必须与现有 `refactor-as-subsystem-typeinfo-bind-cache`、type correctness 和 multithreaded registration changes 协调，不能重复改同一 ownership boundary。

### 15.7 第三优先级：把 `FAngelscriptType` 从巨型虚接口改造成 capability model

`FAngelscriptType` 是当前最值得进行 interface segregation 的类型之一。它约有 58 个 virtual method，并混合：

- 类型 identity 和 declaration；
- `UClass`/`UStruct`/`FProperty` 反射桥；
- construct/copy/destruct、GC、equality/hash/order；
- VM/native call argument/return marshalling；
- default-value conversion；
- debugger visualization；
- C++/StaticJIT name、ABI 和 codegen form。

各派生类型通过大量 `CanX()` + `X()` 方法表达能力，容易形成“所有类型都继承一个不断增长的接口”的问题。

建议保留一个小的 type descriptor/identity 核心，再通过可查询 capability 或 immutable ops table 提供：

- Property/Reflection Adapter；
- Value Lifecycle/Equality/Hash/Order Ops；
- VM/Native Call Marshaller；
- Debugger Adapter；
- Native Codegen/ABI Form Provider。

不建议为每个 capability 建立复杂多继承树；更适合让 descriptor 持有可选 capability pointer/ops，并在 registration 时完成验证。它可以带来：

- 新容器/host type 只实现真正需要的能力；
- binding 错误在注册阶段暴露，而不是执行时发现 `CanX=false`；
- debugger、StaticJIT、LLVM、reflection marshalling 不再同时扩充基类；
- 更容易构建 `TypeBindInfo` cache 和 immutable per-engine type adapter。

这项重构必须排在现有 TypeBindInfo/type-correctness 工作之后，先稳定行为和缓存身份，再改变 capability 表示。

### 15.8 第四优先级：Function Body Generation 与 Module Artifact/Instance 分离

`asCScriptFunction` 当前同时承担：

- public signature/function handle；
- Bytecode、debug/local/try-catch metadata；
- typed HIR 和 artifact dependencies；
- JIT binding、retirement、reader/lease synchronization；
- delegate 和 GC 行为。

建议的长期结构是：

```text
asCScriptFunction                 稳定 public handle + immutable declaration/signature
        |
        +-- current generation --> asCFunctionBody
                                   bytecode/debug/exception/relocation/dependency
                                   canonical AST body reference
                                   JIT binding + code-image lease
```

类似地，`asCModule` 应逐步区分：

- compilation artifact：声明、类型、函数 body、globals/import schema、stable refs；
- live module instance/generation：runtime global storage、imports、initialization、published functions；
- activation transaction：新旧 generation 的 validate/commit/rollback。

这能支持原子 Hot Reload、仍在栈上的旧函数 body 保活、tiered JIT、Cache restore、未来同一 artifact 的多个 runtime instance，以及真正的 compiler-free runtime。它与前述 Compiler Session 是同一方向的后续里程碑，不宜在 canonical AST 尚未闭合时先大规模改函数 ABI。

### 15.9 第五优先级：Semantic/Diagnostic Consumer，而不是 magic observer

现有 `asISemanticObserver` 说明项目已经有工具化需求，但其旧集成方式是通过 engine user-data 的固定 ID 获取单个 observer，并且尚未自然接入新的 `asCSema`。

建议由 compilation session 显式持有：

- `asCSemanticConsumerSet`：零个或多个只读 consumer；
- `asCDiagnosticEngine`：typed diagnostic record、source range、category、stable ID、related notes/fix-it；
- immutable semantic event/index records，而不是 consumer 回调时读取 mutable Compiler 内部对象。

可支持的功能包括：

- symbol/reference/call/dependency index；
- unused declaration、dead code、deprecation 和 API lint；
- IDE rename/refactoring、go-to-reference、semantic token；
- Blueprint impact 和 incremental rebuild 的更准确 dependency；
- MCP/编译器查询工具；
- 诊断去重、stable comparison、结构化测试和 Cache provenance。

`FAngelscriptCompilationEvents` 适合保留为 coarse phase telemetry，`IAngelscriptExtension` 适合 host lifecycle extension；它们不应与 statement/expression 级 semantic consumer 合并成一个全能接口。

### 15.10 第六优先级：序列化、Cache V2 与 restore phase 分层

当前 `asCReader/asCWriter` 已经把读写入口分开，但 `as_restore.cpp` 仍混合格式解析、validation、symbol table、relocation、stack adjustment、object layout rebuild、detached restore 和 commit。Cache V2 又在外层提供 pointer-free manifest/debug codec。

建议在 canonical module/function artifact 稳定后拆成：

```text
versioned DTO codec
      ↓
schema/semantic verifier
      ↓
symbol resolver + relocator
      ↓
detached artifact builder
      ↓
module activation transaction
```

这不是创建第二套 Cache。目标是让 source compile 和 cache restore 最终汇入同一个 artifact verifier/activator，并确保不匹配输入在触碰 live module 前失败。

### 15.11 第七优先级：VM Context 内部数据化，但不为每个 opcode 增加虚接口

`asCContext` 约 6,383 行，混合 public context API、interpreter loop、VM stack、call frame、exception state、debug/line/loop/stack-pop/instruction callbacks、JIT dispatch 和 TLS activation。

可以逐步把内部状态拆成：

- execution state；
- VM stack/frame storage；
- exception state；
- debug/safepoint hooks；
- call dispatcher/JIT entry；
- active-context/TLS scope。

但 `asIScriptContext` 应继续作为 public facade，而且不能为每条 Bytecode 指令添加 virtual dispatcher；hot loop 应继续使用直接分派、POD policy 或 safepoint function table。当前 process-static 的 line-callback capability 也应最终成为 engine/context policy，避免一个 Engine 的 debugger 配置影响其他 Engine。

这属于高风险后期工作，必须以 VM differential、exception、debugger、timeout、coverage、JIT 和性能基线为前提。

### 15.12 其他可利用但不应过早抽象的区域

#### GC

`asCGarbageCollector` 已是独立具体组件。当前没有第二种 GC 算法，也没有必要创建 `IGarbageCollector`。优先增加可选 observer、snapshot、quota/budget 和 diagnostics，只有出现真实算法替换需求时再定义接口。

#### Bytecode

`asCByteCode` 同时包含 builder、局部优化、jump resolution 和 metadata extraction，但 canonical AST OpenSpec 已负责新的 AST→Bytecode CodeGen。不要另开竞争式 Bytecode 重构；可以在该 change 中逐步形成 immutable verified bytecode artifact 和明确 pass boundary。

#### Native call ABI

`asSSystemFunctionInterface` 已经接近 immutable call descriptor。未来更值得演进为经过验证的 `asCCallPlan`/descriptor，用来统一 VM、StaticJIT 和 LLVM 的 marshalling，而不是每次 native call 经过 `INativeCaller` virtual dispatch。

#### Internal header boundary

UE Runtime 中 ThirdParty 目录之外有大量文件直接 include AngelScript internal headers。抽样统计为约 87 个文件、283 条 include，主要位于 Binds、StaticJIT、ClassGenerator 和 Core。建议逐步建立 compiler/type/execution/JIT 的 boundary-specific internal view/header；不要再建一个 mega internal header，也不要禁止 binding 实现访问其确实需要的 ABI 信息。

#### 死字段和 process-global state

检查中还发现若干适合先做证据化清理的候选，例如未见有效使用的 raw `asCScriptEngine::Manager`，以及 function delegate 相关静态字段、process-global profiler/line-callback state、object allocation hook。它们不能只凭文本搜索立即删除，但可以用编译、链接、测试和 runtime instrumentation 做一轮 dead-state/ownership audit。这是低风险减负项，不应和架构重写混为一项大变更。

### 15.13 对照 Clang 后得到的边界判断

Clang 并没有为每一层创建 `IParser`、`ISema` 或 `IASTContext`：

- `Parser` 是具体类；
- `Sema` 是具体/final 核心；
- `ASTContext` 是具体 arena/context；
- `CompilerInstance` 是具体 composer/facade，拥有 Diagnostics、FileManager、SourceManager、Preprocessor、ASTContext、ASTConsumer 和 Sema；
- `CompilerInvocation` 是显式、可复制/序列化方向的配置；
- `ASTConsumer`、`DiagnosticConsumer`、`FrontendAction`、`CodeGenerator` 才是 variation/consumer/backend 边界。

这给 AngelScript 的直接映射是：

| Clang 概念 | AngelScript 建议 |
|---|---|
| `CompilerInvocation` | explicit compile request/options/profile，避免 ambient config |
| concrete `CompilerInstance` | `asCCompilationSession` + UE coordinator composition |
| concrete Parser/Sema/ASTContext | 保持具体、专用、可直接检查的数据结构和算法 |
| `ASTConsumer` | semantic/index/tooling consumer |
| `DiagnosticConsumer` | typed diagnostic sink |
| `CodeGenerator` | AST→Bytecode/TypedASTJIT/未来 LLVM 的 backend boundary |
| `FrontendAction` | 有界 compile/analyze/index action，而不是全局 service locator |

Clang 自己也区分：短小工具可复用 `CompilerInstance` 统一组装；长生命周期工具应显式取得真正需要的对象。这个原则非常适合当前 UE host：`FAngelscriptEngine` 可以继续负责产品生命周期，但长编译链不应通过它和 `Get()` 访问所有可变状态。

### 15.14 推荐顺序与现有 OpenSpec 协调

#### P0：先完成已经开始的 canonical frontend

1. 让 production Parser 真正绑定 Sema 和 build-owned ASTContext；
2. 发布本次 build 的完整、verified、sealed AST，而不是空 TranslationUnit snapshot；
3. 闭合 public snapshot immutable/thread/versioned ABI；
4. 与 lexical change 合并唯一 SourceManager/provenance 实现；
5. 完成 Runtime type bridge 和 verifier；
6. 接通 Bytecode、TypedASTJIT、Cache V2 和 Hot Reload generation。

#### P1：最高价值的新架构边界

1. `asCCompilationSession`；
2. `FAngelscriptCompileCoordinator`；
3. `FAngelscriptModuleActivationTransaction`；
4. 继续显式 Engine ownership/global-state containment。

#### P2：建立可扩展功能面

1. `FAngelscriptType` capability model；
2. Function body generation/module artifact-instance 分离；
3. Semantic/Diagnostic consumer system；
4. restore/serialization phases 和 internal include boundary。

#### P3：风险较高的 runtime 内部重构

1. VM execution state 分解；
2. verified native call plan/ABI；
3. GC observability 和剩余 process-global containment。

当前已有 canonical AST、lexical、multithreaded type registration、Hot Reload、incremental function cache、TypeBindInfo cache 和 type correctness 等活跃 change。不要同时新建五六个重叠 OpenSpec。若下一步只选择一个新的 architecture change，建议聚焦：

```text
refactor-as-compiler-session-and-module-activation
```

但本问题只是探索和记录，没有创建该 OpenSpec。

### 15.15 明确不建议做的事情

- 不创建 `IParser`、`ISema`、`IASTContext`；
- 不为每个 registry 创建 public virtual interface；
- 不让每个 VM opcode/native call 经过虚函数；
- 不因为 GC 目前只有一个实现就创建 `IGC`；
- 不用一个新的全局 `ServiceLocator`/`Manager` 替换旧 `Get()`；
- 不向 public AST 暴露 mutable internal pointer；
- 不把 LLVM type/IR object 放进 canonical AST；
- 不在 lexical 与 AST change 中各自创建一套 SourceManager；
- 不重新添加一层长期独立 HIR；canonical typed AST 应是高层语义权威；
- 不在这个阶段拆 public `asIScriptEngine`/`asIScriptModule` 大 vtable；先在 facade 后面组合。未来 public API 继续增长时，可考虑版本化 capability query，而不是无限追加 virtual method。

### 15.16 本问题的最终判断

一句话总结：

> AngelScript 下一阶段最有价值的现代化，不是接口数量现代化，而是编译与运行状态的所有权现代化：让 Parser/Sema/AST 保持具体，让 compile session 产生可验证 immutable artifact，让 activation transaction 原子发布 generation，并只在真正的 consumer、backend、host 和 capability 边界使用接口。

这条路线既能清理结构，也能直接释放增量编译、Cache V2、Hot Reload、工具化、StaticJIT/LLVM 多后端、多 Engine 并发和 compiler-free runtime 等产品能力。

---

## 2026-08-21 — 问题 13：review `refactor-as-canonical-typed-ast-compiler` worktree 当前实现

### 用户问题

> Review `refactor-as-canonical-typed-ast-compiler` worktree 目前的实现。

### 结论

本轮结论是 **Request changes / 当前不可按“canonical compiler 已完成 cutover”合入或归档**。

这份实现不是没有价值。它已经建立了一批值得保留并继续演进的骨架：标准 C++ 的 AST 节点与 Context、SourceManager、Parser→Sema 接线、Verifier、public snapshot、AST dump、独立 Bytecode CodeGen 原型、Cache record kind、TypedASTJIT canonical visitor、StaticJIT generation 接线和大量测试入口。这些工作足以作为下一轮真实迁移的实验平台。

但是，源码实际状态与 change 的核心 specs、设计叙述和任务勾选状态发生了严重分叉：

- worktree 的 `tasks.md` 已有 `90/93` 项被勾选；
- 第 10 节后来被改写为“保留 `asCCompiler`、HIR oracle 和 `asCScriptNode` grammar tree”；
- 同一 change 的 capability specs 仍明确要求 canonical AST 是唯一 source-level semantic authority、Bytecode 只消费 sealed canonical AST、最终删除 production legacy/HIR/`asCScriptNode` semantic path；
- 生产源码实际上仍由旧 Parser/Builder/`asCCompiler` 形成可执行语义和 Bytecode，新 AST/Sema/CodeGen 目前是附着在旧路径上的 side graph/subset prototype；
- 因而 `90/93` 只能解释为“当前改写后任务表的勾选数”，不能解释为“原 OpenSpec 已实现 96.8%”，更不能解释为 production cutover 完成。

### 审查边界与当时状态

- 目标 worktree：`.worktrees/refactor-as-canonical-typed-ast-compiler/`，短路径 junction 为 `D:\as-cta`；
- 目标插件 submodule：`.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/`；
- 审查方式：只读源码、OpenSpec、测试与构建证据审查；未修改目标 worktree 或插件；
- `openspec validate refactor-as-canonical-typed-ast-compiler`：通过；
- parent 与 plugin 的 `git diff --check`：通过；
- parent worktree 有修改/未跟踪的 OpenSpec 与文档，plugin submodule 有约 `98` 个 status entry，仍是大规模未提交工作集；
- tasks 状态：`90/93`，未完成 `12.2`、`12.4`、`12.6`；
- `canonical-ast-final-all` 全量 suite 在审查结束时仍运行到 Cache prefix，不能记录为通过；
- 当前 `AgentConfig.ini` 与实际 `UnrealEditor-Cmd.exe` 使用 UE `5.8`，而仓库 `AGENTS.md`/`AGENTS_ZH.md` 仍把产品描述为 UE `5.7` plugin；若 5.7 仍是支持基线，现有 UE 5.8 结果不能替代 5.7 验证。

### 阻断项 1：所谓 canonical production default 只是选择标志，生产 Bytecode 仍由旧 `asCCompiler` 生成

这是最核心的阻断项。

源码证据：

- `as_scriptengine.cpp:787` 把 `canonicalCompilerPipeline` 默认设为 `true`；
- `as_scriptengine.h:232-251` 把该 bool 暴露为 `GetCompilerPipeline()==CANONICAL`，并让 `IsCanonicalBytecodeCodeGenReady()` 无条件返回 `true`；
- `as_module.cpp:393-406` 的正式 `Build()` 仍调用 `builder->BuildCompileCode()`；
- `as_builder.cpp:863-896`、`1508-1644` 的 `BuildCompileCode()`/`CompileFunctions()` 仍实例化 `asCCompiler` 并调用 `CompileFunction`、`CompileFactory`、默认构造/析构编译等旧后端；
- `as_builder.cpp:1015-1141` 的 public `CompileFunction()` 同样直接调用旧 `asCCompiler`；
- 全源码没有 production call site 调用 `asCBytecodeCodeGen::Generate()`；调用者只存在于新测试；
- `AngelscriptNativeCanonicalASTCutoverTests.cpp:23-158` 只验证 pipeline flag 和最终执行结果，没有证明执行 Bytecode 来自 canonical CodeGen；
- 同文件 `252-274` 甚至明确把“canonical default 下仍通过 internal compiler 编译 value object”固化为预期。

这意味着当前命名把“Parser 后额外生成一份 canonical side graph”描述成了“canonical Parser/Sema/Bytecode pipeline”。后续任何性能、Cache、LLVM 或 StaticJIT 决策如果信任这个标志，都会把旧编译器的结果误认为新 AST 已经通过生产语义闭环。

与 specs 的直接冲突：

- `specs/as-canonical-compiler-pipeline/spec.md:16-25` 要求 Bytecode CodeGen 只消费 sealed canonical AST；
- 同文件 `41-59` 要求最终 cutover 后禁止 legacy executable fallback，并删除旧 HIR/`asCScriptNode` semantic production path；
- worktree `tasks.md:107-116` 却把第 10 节改写成保留上述 residuals。

建议：在真正替换前把该状态命名为 `SHADOW`/`CANONICAL_CAPTURE` 或保持 legacy production default，不能继续以 `CANONICAL` + hard-coded ready 对外宣称完成切换。

### 阻断项 2：当前 Sema 是解析后的语法树转换器，不是语义权威

源码证据：

- `as_parser.cpp:2321-2335` 先完整构造 `scriptNode = ParseScript(false)`，随后才调用 `sema->ActOnParsedScript(scriptNode, script)`；
- `as_sema_decl.cpp` 直接 include `as_scriptnode.h`，并递归遍历 `asCScriptNode`；
- `as_sema.cpp:6-11` 虽保存 `engine`，但构造函数立即以 `(void)engine` 表示不使用它；
- `as_sema_expr.cpp:29-49` 的 lookup 只沿 parent 链按名字返回第一个 child，不做 overload/signature、namespace/import/mixin/access 或 receiver resolution；
- `as_sema_expr.cpp:70-170` 把默认表达式类型设为 `int`，string literal 也标成 `int`，null 被表示成带 handle qualifier 的 `int`，调用返回类型取“第一个同名 declaration”；
- 调用参数虽然在 `136-153` 构造了 reverse 数组，但随即丢弃，真正写入 AST 的仍是原 `args`；
- `as_sema_decl.cpp:201-238` 对 named type 取第一个 identifier，默认分类为 value object，仅凭 handle qualifier 改成 reference object；无法可靠表达 enum、funcdef、template instance、完整 namespace/type identity；
- `as_runtime_type_bridge.cpp:95-115` 的 `FromDataType()` 只支持 primitive/void，所有 named runtime type 都返回 invalid。

因此当前 AST 不包含 specs 所要求的 exact overload/call/constructor selection、implicit conversion、property/mixin rewrite、argument origin、effective receiver、lifetime/cleanup、import/global dependency 和 ABI route。它不能安全地成为未来 LLVM lowering 或 TypedASTJIT 的唯一输入。

这不是“还有少数语言节点未补齐”，而是 Sema 的职责尚未真正从 `asCCompiler` 迁移。只要旧 `asCCompiler` 仍独立完成上述决定，canonical AST 就仍然是另一个 typed-ish syntax side graph，而不是 canonical semantic authority。

### 阻断项 3：declaration stable key 与 StaticJIT AST 绑定在重载场景会碰撞，可能生成错误 native body

源码证据：

- `as_sema.cpp:13-32` 的 `FinishDecl()` 仅用 `parentStableKey + "::" + declName` 生成 stable key；
- key 不包含 declaration kind、namespace canonical identity、参数类型、返回类型、const/method qualifier、overload ordinal、module/profile；
- 同名重载函数会得到完全相同的 key；构造函数、lambda `<lambda>` 等也会碰撞；
- `as_ast_sidecar.cpp:271-303` 使用这个 key 作为 per-function sidecar record identity；
- `AngelscriptStaticJITGenerationSnapshot.cpp:1139-1157` 把 runtime function 映射到 AST declaration 时只比较 `Function->GetName()` 与 `Decl->name`，遇到重载直接取第一个；
- generation snapshot 只保存 raw `SealedAST` 与 `CanonicalFunctionDeclValue`，没有验证该 declaration 的完整 runtime signature 与 `FAngelscriptStableFunctionKey` 一致。

后果不只是 diagnostic 不准确：重载 B 可能拿到重载 A 的 canonical body，再以 B 的 runtime FunctionKey/ABI 参与 TypedASTJIT 分析和生成。这属于潜在错误代码生成，需要 P0 修复和专门 overload/constructor/operator/mixin test matrix。

### 阻断项 4：Cache V2 `ASTBodySidecar` 当前是占位 envelope，不是可恢复 canonical function-body DTO

源码证据：

- `as_ast_sidecar.cpp:62-113` 编码 textual dump 和 declaration table，没有编码 SourceManager、canonical types、Stmt/Expr、function body、children、resolved call/reference、cleanup、dependencies或 provenance；
- `116-224` 解码时读取但完全不使用 dump，只重建 declaration；所有 named type 都按 `VALUE_OBJECT` 重建，失败时退化成 `int`；
- decoder 不要求 `offset == length`，也没有完整 unknown kind/table/reference 验证；
- `AngelscriptCacheASTBodySidecar.cpp:39-72` 只检查 `Sidecar.CanonicalAstBytes` 非空，随后忽略其中的所有字节，创建一个只有 TU 的新 Context 并编码；
- 同文件 `75-101` decode 后把 envelope 原字节写回 `CanonicalAstBytes`，不是恢复调用者原 canonical AST payload；
- production 源码中 `ASTBodySidecar` 仅进入 record enum、archive/diagnostic name 和独立 wrapper/tests；没有真实 FunctionBody optional link、ExactStartup module reconstruction 或 atomic activation 消费路径；
- 测试 `AngelscriptCacheASTBodySidecarTests.cpp:118-136` 只用 `{1}` 作为“AST bytes”，没有验证 payload byte fidelity，因此没有发现实现把输入丢弃。

这与 `specs/as-incremental-script-cache/spec.md:3-34` 的 per-function pointer-free body DTO、complete module reconstruction、zero frontend ExactStartup 和 module-atomic publication完全不符。当前文档不应宣称 Cache V2 已支持 exact retained AST restore。

### 阻断项 5：public AST V1 同时存在旧客户端 ABI 破坏、size negotiation 内存覆盖和契约信息缺失

源码证据：

- `Core/angelscript.h:1045-1063` 在 `asIScriptModule` vtable 中间插入 `SetASTRetentionPolicy`、`GetASTRetentionPolicy`、`AcquireASTSnapshot` 三个 virtual；旧二进制客户端此后的所有 vtable slot 都会移位；
- plugin `Angelscript.uplugin` 仍是 `VersionName 1.0.0` / `Version 10000`，公共 AngelScript API version 也没有对应 breaking ABI bump；
- `asSAST*View` 虽有 caller-facing `structSize`/`apiVersion` 字段，但 `as_ast_public_view.cpp:64-142` 不读取、不验证 caller 提供的值，而是无条件按最新版 struct 写满；旧/较小 caller buffer 会被越界写；
- public tests 在 `AngelscriptNativeASTSnapshotAPITests.cpp:45-54` 传入全零 view，然后期待实现覆盖 `apiVersion`，反而把错误的 negotiation contract 固化下来；
- V1 views 目前不公开 source range、children/operands、value category、resolved declaration/call、statement owner/target、stable dependencies 等 specs 要求的基本 traversal 信息；一旦承诺长期保留 V1，就会冻结一套无法完成真实 AST consumer 的接口；
- opaque ID 只是一个 1-based `asUINT`；snapshot A 的 `id=1` 传给 snapshot B 会被解释为 B 的节点 1，无法真正 fail-closed 地检测 foreign ID。

建议：不要在该阶段冻结 public V1。先确定 ABI 扩展策略（例如尾部 extension interface/query-interface 或显式新 module interface），让 caller 初始化 `structSize/apiVersion`，实现按 `min(callerSize, knownSize)` 写入并拒绝不兼容版本，再补齐可遍历但不泄露 concrete layout 的 view/child/range API。

### 阻断项 6：snapshot publication、并发 Acquire 和 generation 状态不满足原子/异步 lease 契约

源码证据：

- `as_module.cpp:1997-2008` 对普通 raw `astSnapshot` 先读取再 `AddRef()`，没有 mutex 或 atomic retained-pointer protocol；publisher 可在两者之间 Release/delete；
- `as_ast_public_view.h:27-36` 的 `currentGeneration` 是普通 `bool`，Hot Reload writer 与异步 reader会形成 C++ data race；
- `as_module.cpp:2044-2052` 发布新 snapshot 前先把旧 snapshot 标为过期并 Release，之后才 seal/allocate 新 graph；若新 graph verify 或 allocation 失败，最后成功 snapshot 已被丢失；
- `2076-2084` 在 retain policy 下若根本没有 canonical context，会伪造一个只有 TU 的空 AST 并发布，掩盖 Sema/分配失败；
- `as_builder.cpp:652-672` canonical AST/Sema allocation 失败只静默 return，旧编译器仍可成功 Build；
- public `CompileFunction()` 在 `as_module.cpp:1893-1957` 和 `as_builder.cpp:1015-1141` 生成 canonical local Context 后既不 `TakeCanonicalAST`，也不合并或发布；模块可以新增可执行函数，而 retained snapshot 仍自称 current 且不包含该函数；
- `AngelscriptNativeCanonicalASTCutoverTests.cpp:213-249` 明确把 generation key 不变固化为预期，测试的是“快照未被替换”，没有测试“快照是否仍完整描述模块”；
- StaticJIT generation 的 `FAngelscriptStaticJITGenerationFunction` 只保存 raw `const asCASTContext* SealedAST`，没有 `asIASTSnapshot` lease；`BuildAngelscriptStaticJITGenerationSnapshot()` 也未调用 `AcquireASTSnapshot()`。

这里需要一个真正的 retained generation handle：publisher 在新 snapshot 完整构造/verify 后原子交换；Acquire 在同一同步域中取得引用；old snapshot 的 current flag 使用 atomic；generation consumer 持有明确 lease，而不是裸 Context 指针。

### 重要问题 7：设计要求 arena + sealed immutable graph，实际是逐节点 heap allocation + 可恢复写权限

源码证据：

- design `64-82` 明确说节点不能逐个 heap-owned，并要求 ASTContext arena/batch lifetime；
- `as_ast_context.cpp:17-40` 对 Decl/Stmt/Expr/Type 逐项 `asDELETE`；
- `62-172` 对每个节点/类型逐项 `asNEW`，不存在 arena/slab/bump allocator；
- `as_ast_context.h:18-35` 公开 mutable SourceManager、mutable `GetDecl/GetStmt/GetExpr`；
- `DestroyAll()` 是 public，并会把 `sealed=false`；
- `as_ast_public_view.h:27-29` 的 internal concrete snapshot 暴露 mutable `GetContext()`；
- seal 只阻止 `Create*`/新 type intern，不能阻止调用者直接改公开 node fields、children、range、type、resolved target 或 SourceManager。

`AngelscriptNativeCanonicalASTContextTests.cpp:18-46` 的 “ArenaOwnership” 只验证创建/销毁和空 foreign context，没有验证 allocator；它不能证明 arena 或 immutable graph 已实现。

### 重要问题 8：Verifier 尚不足以保护 backend、Cache 或 public publication

`as_ast_verifier.cpp:13-188` 当前主要检查表项存在、部分 kind/range、简单 break/continue target kind 和 duplicate case。它没有完整验证：

- Stmt/Expr 自身 ID 与表 index 一致；
- Expr operands/children 的存在与 kind；
- Decl parent↔children、Stmt tree ownership 的双向一致性；
- graph cycle、multiple owner、ancestor/nearest-control-target；
- return owner/target、fallthrough ordering、完整 switch case/default 结构；
- executable expr 必须具有 exact valid type/value category；
- resolved declaration kind/signature 与表达式/调用类型一致；
- cleanup/materialization/transfer plan 与 live value 的一致性；
- stable cross-module reference、sealed state 和 immutable publication invariant。

此外，`as_ast_type.cpp:5-12` 的 qualifier validator 只检查 direction mask 的四种数值，没有拒绝 unknown bits、auto-handle without handle、direction without reference、void handle/reference 等组合；测试还明确认为 `int` + `asAST_QUAL_IN` without reference 是 valid。

在 AST 真正驱动 Bytecode、LLVM 或 native generation 前，Verifier 必须成为完整 semantic graph firewall，而不是基本 table sanity check。

### 重要问题 9：独立 Bytecode CodeGen 的失败路径会留下部分 module mutation

`as_bytecode_codegen.cpp:1362-1490` 虽对 pending function 做局部 rollback，但在完整 emission 成功前已经：

- `1403-1410` 调用 `module->AddFuncDef()`；
- `1412-1434` 调用 `module->AllocateGlobalProperty()`；
- 随后任一 signature/emitter `asNOT_SUPPORTED` 或 OOM 只调用 `DiscardPending(engine, pending)`，没有撤销 funcdef/global mutation。

这违反 task `9.1` 写明的“failure produces no partial function/module state”，也说明 CodeGen 需要输出 detached artifact/transaction，验证完整后再一次性安装进 module。

### 重要问题 10：SourceManager 尚未成为共享 source truth，且 remap 可复用错误 buffer

源码证据：

- `as_source_manager.*` 的调用者集中在新 AST/Sema/CodeGen；旧 Parser/Builder/Compiler diagnostic path 没有通过它，task `2.2` 的“route current parser/compiler diagnostics”尚未实现；
- 当前 Section 只有 `logicalKey + origin + bytes + lineOffset`，没有 authored→processed→generated provenance/mapping graph；
- `as_source_manager.cpp:192-204` 的 `RemapLogical()` 只要 logical key 和 origin 相同就返回原 FileID，不比较新 bytes、byteCount 或 lineOffset，因此同一 logical source 的变化可能复用旧 buffer 和 line table；
- public snapshot/Cache sidecar 当前也没有完整暴露或持久化 SourceManager coordinate。

它可以保留为第一版骨架，但暂时不能宣称已经达到 Clang-inspired unified source-coordinate contract。

### 测试与记录审计结论

已有测试数量很多，但若测试只证明旧编译器仍能执行、pipeline bool 为 canonical、envelope kind 正确或 TU view 存在，就不能证明新架构完成：

- cutover execution 仍来自旧 `asCCompiler`；
- public snapshot test 只验证 TU，不验证 function/body/children/range/exact type 完整性；
- size-version view test 用全零 struct，掩盖旧 caller buffer overflow；
- foreign ID test 的另一个 Context 为空；若另一个 Context 也有同 index，错误 ID 会被接受；
- arena test 不检查 allocation；
- Cache test 不检查 `CanonicalAstBytes` fidelity；
- CompileFunction test 把 stale/incomplete snapshot 视为正确；
- Hot Reload test预先 Acquire A 后再 reload，没有覆盖 Acquire 与 publication 同时发生的 race；
- 没有看到能阻止 stable-key/name-only overload 错配的测试。

OpenSpec 本身能通过 validation，`git diff --check` 也干净，但这两项只证明 artifact/schema 和 whitespace 基本有效，不证明 capability requirements 已实现。当前最严重的记录问题是 tasks 被改写后仍保持原 specs 和“cutover 完成”叙述，导致 milestone evidence 与 normative requirements 相互矛盾。

### 值得保留的实现方向

虽然当前不能接受 cutover 结论，以下方向是正确的，建议继续保留：

- canonical AST、SourceManager、Sema、Verifier、CodeGen 保持标准 C++，不依赖 UE/Clang/LLVM；
- internal concrete nodes 与 public opaque snapshot/view 分离；
- snapshot 使用 refcount、module retention policy、generation/current 概念；
- Bytecode 与 future LLVM/TypedASTJIT 都以相同 sealed semantic graph 为长期目标；
- TypedASTJIT canonical visitor 与 fallback 分类先在测试中演进；
- Cache 使用 pointer-free stable DTO，而不是持久化 live node 或 dump；
- 通过独立 Engine 做 differential behavior/diagnostic testing；
- StaticJIT published binding 最终只保留 stable identity/artifact/code-image lease，不保留 AST pointer。

问题不是这些方向，而是当前实现和记录过早把 scaffold/subset prototype 声明为 production authority。

### 建议修正顺序

1. **先纠正 OpenSpec 状态与产品叙述**：撤销第 2-11 节中没有被真实源码满足的勾选；或者把当前 change 明确重定义为 phase-1 scaffold/shadow capture change，同时同步 proposal/design/specs，另建后续 cutover change。不能只改 tasks 来规避原 requirements。
2. **恢复真实 pipeline 命名**：旧 `asCCompiler` 仍生产 Bytecode 时，默认 selection 应保持 legacy，或改名为 canonical capture/shadow；移除 hard-coded `IsCanonicalBytecodeCodeGenReady()==true`。
3. **先完成语义权威迁移**：建立真实 scope/symbol/overload/type/conversion/access/call/lifetime/control model；stable declaration/function key 必须采用完整 canonical signature，并建立 runtime function↔AST decl exact mapping。
4. **完成 AST ownership/immutability/verifier**：实现真正 arena/batch lifetime；seal 后只允许 const traversal；补齐 source/type/child/reference/cleanup/control/stable-key verifier。
5. **以 detached artifact + activation transaction 接入 Bytecode CodeGen**：CodeGen 不直接修改 live module，完整成功后一次性 publish；建立旧/新 VM behavior 与 metadata parity gates。
6. **重新设计 public ABI**：避免在现有 vtable 中间直接插 virtual；实现真实 struct size/version negotiation；在语义与 traversal shape 稳定前不要冻结 V1。
7. **最后完成 snapshot/Hot Reload/async lease**：原子 publication、线程安全 Acquire/current flag、失败保留上一代、CompileFunction 完整快照策略和 generation consumer lease。
8. **最后接入真实 Cache V2 sidecar**：序列化完整 per-function DTO 与 SourceManager/type/decl stable references；ExactStartup 先重建+verify detached module graph，再原子激活。
9. **重新运行验证矩阵**：增加 overload、foreign same-index ID、old-small-view ABI、concurrent Acquire/publish、allocation failure、CodeGen partial mutation、Cache payload fidelity/corruption、CompileFunction snapshot completeness；再跑目标 UE 支持版本与 Standalone Debug/Release。

### 对当前决策的影响

- 强化 D20：当前 worktree 不再只是早期空骨架，但仍是 shadow/scaffold + subset prototypes，不是 production semantic authority；
- 新增 D23：当前 implementation review 结论为 Request changes，不能依据 `90/93` 勾选数合入、归档或开始 LLVM backend；
- 新增 D24：只要 production Bytecode 仍由 `asCCompiler` 产生，就必须把 canonical AST 视为迁移 side graph，并保留真实 legacy/canonical distinction；
- 新增 D25：public AST V1 和 Cache AST sidecar 都必须等 exact semantic graph、stable identity、immutability 和 verifier 成熟后再冻结；
- 当前仍坚持“先 canonical semantic authority，后 LLVM lowering”的总路线。本次 review 没有推翻该路线，反而证明不能跳过语义闭环直接把当前 AST 接到 LLVM。

### 未决事项

- 用户希望当前 change 继续承担“完整 cutover”，还是拆成“scaffold/shadow capture”与“production cutover”两个 change；
- public module ABI 的正式兼容策略与产品 major/minor/version bump 规则；
- `CompileFunction(asCOMP_ADD_TO_MODULE)` 是发布新完整 module snapshot、增量合并 snapshot，还是明确使旧 snapshot stale/unavailable；
- 目标 UE 支持基线究竟是 5.7、5.8，还是两者都必须验证；
- 仍在运行的 `canonical-ast-final-all` 最终结果；无论其是否全绿，都不能消除上述源码架构阻断。

### 2026-08-21 后续落档

用户要求把 review 结论写入对应 worktree 的 OpenSpec review 目录，方便在原 change 中修正。已新增：

- `.worktrees/refactor-as-canonical-typed-ast-compiler/openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/implementation-review-2026-08-21.md`

该 artifact 共 `434` 行，包含 review decision、normative record divergence、R01-R10 findings、影响、required correction、rereview gate、建议修正顺序和 minimum rereview matrix。新增后目标 worktree 的 `openspec validate` 仍通过，tasks 保持 `90/93`，未修改 proposal/design/specs/tasks checkbox 或插件源码。

### 2026-08-21 通俗版：问题、进展与 ASCII 图示

一句话总结：

> 这次不是“canonical AST 没做”，而是“AST 基础设施已经做出不少，但它仍挂在旧编译器旁边作为影子数据；任务和文档却提前把它写成了正式生产编译器”。

原 OpenSpec 的目标是：

```text
AngelScript 源码
      |
      v
Lexer / Parser
      |
      v
权威 Sema：完成类型、重载、转换、调用、生命周期等决定
      |
      v
Sealed Canonical Typed AST（唯一高层语义真相）
      |
      +----------------+----------------+----------------+----------------+
      |                |                |                |
      v                v                v                v
Bytecode CodeGen   TypedASTJIT       Cache V2       Public AST API
      |                |                |                |
      v                v                v                v
     VM            Native C++       精确恢复          工具/分析器

未来再增加：Canonical AST -> LLVM IR -> 优化/机器码
```

当前真实实现是：

```text
AngelScript 源码
      |
      v
旧 Parser
      |
      v
asCScriptNode 旧语法树
      |
      +-----------------------------------------------+
      |                                               |
      v                                               v
旧 Builder + asCCompiler                         新 Sema post-pass
      |                                               |
      | 真正做类型/重载/转换/调用/生命周期             | 读取旧树，生成近似 typed AST
      v                                               v
生产 Bytecode                                  Canonical AST side graph
      |                                               |
      v                          +--------------------+-------------------+
     VM                          |                    |                   |
                            subset CodeGen      TypedASTJIT 原型      Cache/Public 外壳

结论：真正可执行语义仍在左边；右边还不是生产权威。
```

最核心的五类问题：

```text
1. 名称问题
   “CANONICAL” flag = true
          |
          v
   实际仍调用 asCCompiler
          |
          v
   测试看见执行成功，就误判新 CodeGen 已切换

2. 语义问题
   新 Sema 只按名字找第一个声明，大量表达式默认 int
          |
          v
   AST 不知道精确重载、转换、receiver、cleanup、ABI
          |
          v
   不能直接作为 LLVM/TypedASTJIT 的可靠输入

3. 身份问题
   StableKey = Parent::Name
          |
          v
   同名重载发生碰撞
          |
          v
   StaticJIT 可能把函数 B 绑定到函数 A 的 AST body
          |
          v
   潜在错误 native code

4. 生命周期/API 问题
   Snapshot raw pointer + 非原子 AddRef + 普通 bool
          |
          v
   Hot Reload/异步读取可能产生 use-after-free/data race

   Public module vtable 中间插 virtual
          |
          v
   旧二进制客户端 ABI 可能整体错位

5. 持久化问题
   Cache wrapper 收到 CanonicalAstBytes
          |
          v
   忽略其内容，只编码一个空 TU
          |
          v
   当前不能从 Cache 恢复函数 AST/body 语义
```

当前进展不能按 `90/93` 直接理解，应该按能力层看：

```text
记录层
  tasks.md                            [90/93 checked]
  但第 10 节已改写，且没有同步改掉相反的 specs

实现层
  ASTContext / Decl / Stmt / Expr     [已有原型骨架]
  SourceManager                       [已有基础表，未统一全管线]
  Parser -> Sema 接线                 [已接，但属于旧树 post-pass]
  Sema semantic authority             [未完成]
  Type/overload/call/lifetime facts   [未完成]
  Verifier                            [基础 sanity check，未完整]
  Arena + sealed immutable            [未实现]
  Canonical Bytecode CodeGen          [独立 subset 原型]
  Production Bytecode cutover         [实质未完成]
  TypedASTJIT canonical visitor       [部分接入，identity/lease 有风险]
  Public AST snapshot                 [API 外壳，ABI/并发/遍历未稳定]
  Cache AST sidecar                   [占位 envelope，不可完整恢复]
  Hot Reload atomic generation        [未完成线程安全闭环]
  LLVM backend                        [本 change 明确未开始]
```

因此可以把进展理解成：

```text
                    基础结构        语义正确性       生产接管
                    --------        ----------       --------
AST 数据结构           已有              部分             否
SourceManager          已有              部分             否
Sema                   已接线            很早期           否
Bytecode CodeGen       有 subset         不完整           否
TypedASTJIT            有适配            有阻断           否
Public Snapshot        有外壳            有阻断           否
Cache Sidecar          有 record         占位             否

整体状态：可继续开发的迁移平台，不是已经切换完成的编译器。
```

建议的修正顺序：

```text
阶段 0：先把记录说实话
  CANONICAL production -> LEGACY + CANONICAL_SHADOW/CAPTURE
  specs / tasks / attachments / docs 对齐
                         |
                         v
阶段 1：迁移真正的 Sema 权威
  scope -> symbol -> type -> overload -> conversion -> call plan
  -> lifetime/cleanup -> control target -> stable dependencies
                         |
                         v
阶段 2：把 AST 做成可信输入
  完整 stable signature identity
  + arena ownership
  + sealed const traversal
  + 完整 verifier
                         |
                         v
阶段 3：让新 Bytecode 真正接管生产
  sealed AST -> detached Bytecode artifact -> atomic module activation
  与旧 compiler 做完整差异测试
                         |
                         v
阶段 4：修正公共与并发边界
  ABI extension + size/version negotiation
  + atomic snapshot publication + generation lease
                         |
                         v
阶段 5：实现真实 Cache V2 AST DTO
  per-function body sidecar -> cross-Engine remap
  -> complete verify -> ExactStartup atomic restore
                         |
                         v
阶段 6：正式删除旧生产路径
  asCCompiler/HIR/asCScriptNode semantic dependency 退出 production
                         |
                         v
阶段 7：再把 canonical AST 接到 LLVM
```

最通俗的类比是：

```text
目标：换发动机

当前：
  新发动机已经摆进机舱，仪表盘也显示“新发动机模式”；
  但真正带动车轮的传动轴仍连在旧发动机上。

所以：
  不是新发动机不存在；
  而是还没有接管动力，仪表盘却提前显示切换完成。
```

最终判断保持为：保留并修正当前骨架，不应推倒重来；先恢复真实的 shadow/capture 身份，再依次完成 Sema、AST invariant、Bytecode、snapshot/public ABI、Cache 和最终 cutover。当前不适合作为正式 LLVM backend 的稳定输入，但可继续承担 isolated LLVM lowering 实验。

---

## 2026-08-21 — 问题 14：第二轮 review `refactor-as-canonical-typed-ast-compiler` 完成得怎么样

### 用户问题

> 再 review 下 `refactor-as-canonical-typed-ast-compiler` 这个完成得怎么样？

### 结论

第二轮结论仍是 **Request changes**，但需要明确承认第一轮之后已经发生了几项实质改进：

- production default 已恢复为 `LEGACY`；
- `IsCanonicalBytecodeCodeGenReady()` 已恢复为 false；
- Bytecode publisher provenance 已可观察，Cutover 测试明确承认当前 production Bytecode 仍来自 `asCCompiler`；
- OpenSpec 从第一轮的 `90/93` 虚高状态重开为 `51/105`，13.1–13.12 全部保持未完成；
- function stable key 已加入参数类型，StaticJIT 不再直接绑定第一个同名 declaration；
- `asCASTContext` 已改成 block arena，sealed 后 mutable node getter 会拒绝访问；
- shadow Sema 新增 overload/conversion/namespace/operator/mixin/named/default args/lambda/control/cleanup fixtures。

因此，当前不再是“带虚假完成标志的危险切换”，而是一个更诚实、继续可用的 **canonical typed AST migration platform / shadow semantic compiler**。

但完整目标依然没有完成：

```text
当前 production：
source -> asCScriptNode -> legacy Builder/asCCompiler -> Bytecode -> VM
                    \
                     -> shadow Sema -> canonical AST prototypes

OpenSpec 终态：
source -> Parser actions + authoritative Sema
       -> complete verified sealed canonical typed AST
       -> canonical Bytecode / TypedASTJIT / Cache / future LLVM
```

生产 `Build()` 仍调用 `BuildCompileCode()` 并创建 `asCCompiler`；`asCBytecodeCodeGen::Generate()` 仍没有 production caller。Sema 仍在 Parser 完整构造 `asCScriptNode` 后遍历旧树，尚未成为 lookup、overload、conversion、receiver、lifetime、cleanup、import/global 和 ABI 的唯一权威。

### 当前任务完成度应怎样理解

第二轮 tasks 状态为：

- total：`105`；
- checked：`51`；
- unchecked：`54`；
- checklist 算术完成度：`48.6%`；
- section 13 review gates：`0/12` 完成。

任务权重并不相等，不能把 48.6% 解释为 production compiler 已切换一半。分层判断更准确：

| 层次 | 判断 |
| --- | --- |
| AST/Sema/dump/test/scaffold | 已形成较大规模，约 60–70% |
| shadow semantic coverage | 有明显进展，但不完整且不是 production authority |
| canonical production Bytecode cutover | 未完成 |
| Public ABI/Snapshot concurrency/Cache restore 等交付闭环 | 多项仍阻塞 |
| 完整 OpenSpec 总体 | 粗略约 40–50%，不可归档 |

### 本轮 fresh 验证

#### Build

`canonical-ast-rereview-build-20260821` 通过；UBT 报 target up to date。复审期间另一个实现进程仍在修改并构建同一 worktree；最终吸收了 13:51 Runtime DLL、13:52 CanonicalAST 结果和 13:54 Compiler 结果，以 13:55 为 point-in-time 快照。

#### SemaAuthority

实现进程先运行 `goal-wave-b-gaps-green2`，中间结果：

- total：17；
- passed：15；
- failed：2；
- skipped：0。

失败项：

1. `BreakTargetsNearestSwitchNotOuterLoop`：source build 成功，但 retained canonical AST context 为 null，控制流图不能完成 sealed publication。
2. `PropertyReadWriteRewritesToAccessors`：getter 已改写成 `T::GetValue()`，setter `T::SetValue(int)` 没有进入 graph。

实现进程随后修正这两个 fixture，最新结果为：

- `goal-canonical-ast-wave-b`：CanonicalAST `32/32 PASS`，0 failed，0 skipped；
- `goal-wave-b-compiler`：Compiler `220/220 PASS`，0 failed，0 skipped；
- `goal-jit-identity-reject`：TypedASTJIT CanonicalASTMigration `8/8 PASS`。

因此 nested switch break publication 与 property setter rewrite 的直接 fixture 已修绿。通过项包括基础 exact overload、constructor overload、namespace/operator overload、int/float conversion、named/default args、mixin、multiple lambda key、temporary cleanup、control target 等。这说明 shadow Sema 确实在增长，但仍不能证明 R02 semantic authority 完成：Sema 仍 post-walk `asCScriptNode`，production Bytecode 仍由 legacy `asCCompiler` 产生。

#### 新发现的 Critical：Canonical CodeGen funcdef/lambda teardown crash

最新 DLL 上单独运行：

```text
Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.
FCanonicalASTCodeGenTests.CodeGenEmitsFuncdefCallAndLambda
```

测试主体能够算出 `Invoke(Double,3)+L(4) == 11`，但退出 scope 执行 `Engine.Destroy()` 时稳定崩溃：

```text
EXCEPTION_ACCESS_VIOLATION reading address 0xffffffffffffffff
asCScriptEngine::~asCScriptEngine() ... as_scriptengine.cpp:1025
asCScriptEngine::ShutDownAndRelease()
FCanonicalASTCodeGenTests::CodeGenEmitsFuncdefCallAndLambda() ... :753
```

此前复现分别落在 `funcDefs[n]->ReleaseInternal()` 和 `functionBehaviours.ReleaseAllFunctions()` 邻域，说明 funcdef/function handle/lambda 引用或 ownership 已被成功 CodeGen/执行路径破坏。该问题必须先最小化为 funcdef-only、function-reference-only、lambda-only、indirect-call-only 测试，再对照 legacy compiler 的 metadata/refcount/cleanup 协议修正。不能通过跳过 teardown 或泄漏 Engine 让测试变绿。

### 第一轮 R01–R10 的变化

- R01：**部分解决**。虚假默认/Ready/provenance 已修；production cutover 仍未发生。
- R02：**部分解决**。shadow Sema coverage 增加，最新 CanonicalAST 32/32、Compiler 220/220；仍遍历 `asCScriptNode`，不是唯一语义权威。
- R03：**显著缓解但未闭环**。参数类型与唯一匹配降低 wrong-body 风险；qualifier/owner/module/profile/lambda source identity 仍不完整。
- R04：**未解决**。Cache sidecar 仍不能重建完整 source/type/decl/body/reference/dependency graph，wrapper 仍忽略真实 payload。
- R05：**未解决**。Public AST virtual 仍插入旧 vtable 中间，caller `structSize/apiVersion` bounded write 与 smaller-view canary 仍缺。
- R06：**未解决**。raw pointer→AddRef race、plain current bool、replace-before-verify、CompileFunction incomplete snapshot 仍存在。
- R07：**实质改善**。block arena 和 sealed mutable node getter 已落地；mutable SourceManager/internal Context surface 仍需关闭。
- R08：**部分解决**。verifier 检查增加，但 cycle/ownership/expr children/type-value-category/signature/cleanup firewall 仍缺。
- R09：**未解决且风险升级**。CodeGen 会在成功前修改 funcdef/global/Engine function state，失败不能完整回滚；现又发现成功路径 teardown crash。
- R10：**未解决**。legacy diagnostics 未统一，changed-content remap、public/cache source persistence 未完成。

### 对当前决策的影响

- 第一轮“不能接受 production cutover”的判断不变；
- 第一轮关于 arena 完全未实现的证据已过时，应更新为“arena 已实现，sealed immutability 仍部分未完成”；
- stable identity 从“直接选错 body”改善为“常见 overload 唯一匹配，歧义多数 fail closed”，但仍不能冻结 Cache/native identity；
- 新增最高优先级约束：任何 production CodeGen 工作前必须先修 funcdef/lambda teardown crash，并补完整 success/failure ownership transaction；
- 当前实现应保留并继续演进，不应推倒重来，也不应开始正式 LLVM production backend。

### 正式落档

第二轮完整复审已写入目标 worktree：

- `.worktrees/refactor-as-canonical-typed-ast-compiler/openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/implementation-rereview-2026-08-21-second-pass.md`

报告包含 point-in-time verification、R01–R10 resolution matrix、新 R11 Critical finding、分层完成度和下一轮最小门禁。本轮没有修改 plugin implementation，也没有替实现者勾选 tasks。

### 未决事项

- funcdef/lambda teardown 崩溃的第一个 ownership 失衡点；
- Wave B 已修绿的 fixture 是否能扩展到 access/ref-handle/template/import/global/完整 cleanup 等对抗矩阵，同时保持 verifier fail-closed；
- Sema 从 `asCScriptNode` post-walk 迁移为 action-driven authoritative environment 的具体边界；
- Public ABI、snapshot protocol、Cache DTO 和 SourceManager truth 的独立 closure；
- 最终 production `Build()` 切到 canonical CodeGen 后的 focused/Standalone/All 结果。

---

## 十六、当前决策账本

以下是本次讨论截至 2026-08-21 形成的架构倾向。它们是研究决策和已落档规划，不表示所有实现已经完成。

### D1（迁移期）：保留作为差异基准的 Typed Semantic HIR

理由：它在形态上属于 typed semantic AST/HIR，但不是 Parser AST 本身；它已经验证 Parser-node-independent graph、显式求值/清理和 verifier 的必要性。新 OpenSpec 启动后，它只作为 Shadow Convergence 的语义/测试基准保留；所有消费者迁入 canonical AST 后整体删除，不再是长期独立后端契约。当前 `asCDataType` 仍保留 Engine-local type pointer，因此 live HIR 不是完整 pointer-free DTO。

### D2：把 LLVM IR 定位为后端 IR

LLVM IR 负责低级 CFG/SSA、通用优化和机器码生成；它不替代语言级 HIR，也不应该成为需要 UE/LLVM 才能完成前端语义分析的依赖。

### D3（LLVM 后续研究）：直接 high-level semantic AST/HIR→LLVM，再按证据决定是否增加 Typed CFG

当前结构化语义已经足够生成第一批 LLVM basic blocks。新 compiler OpenSpec 不实现 LLVM；未来 LLVM change 应直接消费 canonical AST。只有多后端重复 lowering、cleanup edge 或语言级数据流优化产生明确压力时，才抽取 backend-neutral Typed CFG。

### D4：保留 Bytecode/VM 作为语义基准和逐函数 fallback

LLVM 后端必须是增量能力。任何函数在 HIR capture、verify、lowering、LLVM verify、symbol resolve 或 Runtime guard 任一阶段失败，都应只回退该函数，而不是破坏整个 module。

### D5：不以 `cppvm` 的 LLVM Interpreter 作为起点

`cppvm` 用于参考 IR 执行、符号桥和热补丁。当前项目更适合基于本地 LLVM 22 ORC PoC 的基础设施开始验证。

### D6：复用 LLVM worktree 的基础设施，替换前端 emitter

复用 SDK、ORC、verifier、symbol、resource tracker、lease、VMEntry bridge 和 guards；把 Bytecode snapshot emitter 替换为 verified HIR lowering。

### D7（LLVM 后续研究）：生产交付优先考虑 source-time AOT/object

canonical AST 生命周期天然匹配同次 source compile 的 Static AOT/object 生成。editor-time ORC 仍适合未来快速验证；packaged runtime LLVM JIT 必须在另一个 change 中定义版本、目标环境和安全边界。

### D8：优化前先建立语义差异测试

O0 正确性是 O1/O2 的前提。LLVM flags、attributes 和 runtime helper 声明都属于语言契约的一部分，不能用性能目标替代语义证明。

### D9：长期目标收敛为 canonical typed AST

允许最终删除独立 sidecar HIR，但必须先把 exact type、resolved target、evaluation order、single-evaluation mutation、cleanup、source provenance、verifier 和 fallback 全部提升到 canonical typed AST；不能先删再补。

### D10：参考 Clang frontend，而不是抽象的“LLVM AST”

主参考分层是 Parser→Sema→ASTContext→CodeGen→LLVM IR；daScript 用于补充轻量脚本语言如何让最终 typed AST 同时服务 interpreter/AOT/LLVM。

### D11（已执行）：AST v2 决策先于当前 HIR sidecar schema 实现

`refactor-as-primary-engine-typed-ast-generate` 在实现 `0/36` 时被新 canonical AST change 完整吸收并以 `--skip-specs` 归档，避免把 live HIR arena shape 固化为 Cache V2 schema。

### D12：正式建立 canonical typed AST/Compiler 单一长期 OpenSpec

`refactor-as-canonical-typed-ast-compiler` 记录从 SourceManager、Parser+Sema、ASTContext 到 Bytecode/TypedASTJIT/Cache/public snapshot 的完整迁移；不拆成互相竞争的 frontend changes。

### D13：采用 Clang architecture，使用 AngelScript-native implementation

终态结构与 Clang frontend 同构，但不链接/复制 Clang 节点或 Sema；内部使用 AngelScript 专用 Decl/Type/QualType/Stmt/Expr、arena、tag 和 Runtime type bridge。

### D14：公共 AST 采用版本化引用计数快照

公共 V1 是 module-level immutable `asIASTSnapshot`、opaque ID 和 size/versioned POD view；Hot Reload 后旧快照由 lease 保活并报告不再 current，不暴露内部/Engine 指针。

### D15：Cache V2 持久化 canonical AST DTO，不持久化 HIR/live 对象

source/decl/type/global 与现有 module records 对齐，函数体使用 `ASTBodySidecar`；retain-policy 必须完整 remap/verify 后原子发布，discard-policy 可只恢复 VM。

### D16：当前 compiler OpenSpec 不实现 LLVM

AST 必须保留未来 LLVM lowering 所需完整语义，但本 change 不引入 LLVM 类型、库、emitter、ORC、object cache 或测试。

### D17（已落档，尚未实施）：词法层采用 Clang-inspired、AngelScript-native 分层

目标路径补全为 `SourceManager -> raw Lexer -> source preparation/token source -> TokenBuffer/Cursor -> Parser + Sema -> ASTContext`。保留当前 AngelScript token/诊断语义和公共 `ParseToken` compatibility facade，不链接/复制 Clang，不引入 C preprocessor 复杂度。UE preprocessor 仍拥有 host-specific 转换，但应逐步消费共享 lexical source，消除字符级重复扫描。

### D18：lexical change 独立验证，但服从 canonical frontend 单一权威

正式 change 为 `refactor-as-source-aware-lexical-pipeline`，当前 `0/87` 且 strict validation 通过。它拥有 SourceManager lexical substrate、RawLexer、TokenBuffer/Cursor、当前 Parser 输入和 UE adapter；`refactor-as-canonical-typed-ast-compiler` 继续拥有 Sema/AST/Bytecode/TypedASTJIT/public/cache semantic authority。两者共享唯一 SourceManager 实现，lexical completion 不自动等于 canonical compiler completion。

### D19：public `asI*` 保留为 ABI facade，内部不追求接口数量

`asIScriptEngine`、`asIScriptModule`、`asIScriptContext` 等即使只有一个实现，仍然具有 public ABI、handle/lifetime 和 implementation hiding 价值。内部 Parser、Sema、ASTContext、registry 和 VM hot path 优先使用 concrete composition；只在真实 provider、consumer、backend、host、capability 和测试替换点增加接口。

### D20：当前 canonical AST/Sema worktree 已扩展为 shadow/scaffold + subset prototypes，仍未成为 production authority

截至 2026-08-21 review，worktree 已增加 ASTContext、节点、SourceManager、Sema、Verifier、public snapshot、AST sidecar、Bytecode CodeGen、TypedASTJIT canonical visitor、StaticJIT/Cache 接线与大量测试；但 production Bytecode 仍由旧 `asCCompiler` 生成，Sema 仍是 `asCScriptNode` post-pass，Cache sidecar 与 public/concurrency contract 尚未闭合。`90/93` tasks 勾选不代表原 capability specs 完成。

### D21：canonical frontend 之后最高价值的新边界是 compiler session + activation transaction

建议用 native `asCCompilationSession` 产生 verified immutable artifact，由 UE `FAngelscriptCompileCoordinator` 负责多 module orchestration，并由 `FAngelscriptModuleActivationTransaction` 负责 validate/commit/rollback/generation publication。`asIScriptEngine` 和 `FAngelscriptEngine` 保持 facade，不引入新的巨型 compiler interface。

### D22：能力拆分和显式所有权优先于通用 service abstraction

`FAngelscriptType` 适合在现有 TypeBindInfo/type correctness 稳定后改为 descriptor + optional capability/ops；ambient Engine lookup 应按 owner 分类逐步显式化；function body/module artifact 与 live generation 应长期分离。禁止用新的 global ServiceLocator、过度纯虚层或第二套 HIR/SourceManager 替换当前问题。

### D23：当前 canonical compiler implementation review 结论是 Request changes

在 production compiler authority、stable identity、public ABI、snapshot lease、Cache DTO 和 verifier 阻断解除前，不依据任务勾选或旧编译器回归测试把 change 视为可合入、可归档或可供 LLVM production lowering 使用。

### D24：旧 `asCCompiler` 仍生成生产 Bytecode 时，canonical AST 只能被称为迁移 side graph

可以保留 shadow/capture 与 subset CodeGen 原型，但 pipeline 名称、ready flag、文档和测试必须准确反映真实 authority；不能用 canonical selection bool 把旧 compiler 的成功伪装成新 pipeline 的 parity。

### D25：public AST V1 与 Cache AST sidecar 延后冻结

先完成 exact semantic graph、完整 stable signature identity、sealed immutability、deterministic verifier 和 generation lease，再冻结 public traversal ABI 与 pointer-free Cache V2 DTO。当前占位 view/envelope 不作为长期兼容基线。

### D26：第二轮复审把当前实现定位为“诚实的 shadow migration platform”

LEGACY 默认、Ready false、publisher provenance 和任务重开关闭了第一轮最危险的虚假 cutover；arena、stable key 和 shadow Sema coverage 也有实质进展。但 production `Build()`、semantic authority、Cache/Public/Snapshot closure 仍未完成，因此保持 Request changes，不能归档。

### D27：funcdef/function handle/lambda teardown safety 是 production CodeGen 的前置门禁

Canonical CodeGen 即使执行结果正确，只要会在 module/Engine teardown 破坏引用或所有权状态，就不得接入 production `Build()`。必须先建立最小生命周期矩阵、完整 metadata/refcount/cleanup 合同，以及 detached install/rollback transaction。

---

## 十七、仍待回答的问题

### 17.1 未来 LLVM change 的首个真实交付物是什么

需要在后续设计中明确选择：

- editor-only ORC 实验后端；
- source-time object/Static AOT 后端；
- 两者共享 lowering、先 ORC 验证再 AOT 交付。

当前倾向是第三种，但尚未形成正式变更方案。

### 17.2 packaged runtime LLVM 是否需要额外持久化输入

canonical compiler 已决定由 Cache V2 持久化 AST DTO，而不是 HIR sidecar。如果未来目标包含 packaged runtime LLVM JIT，仍必须在独立 change 中定义：

- schema/version；
- target profile 和 native environment；
- semantic hash；
- verifier；
- source/cache identity；
- 不可信或不匹配 sidecar 的拒绝策略；
- 与 Cache V2 的关系。

### 17.3 何时需要 backend-neutral Typed CFG

应通过未来 canonical AST→LLVM spike 统计重复 lowering 和缺失信息，不应先假设必须有 SSA HIR。

### 17.4 LLVM ABI 和 Runtime bridge 的边界

需要明确：

- VMEntry、Raw、Parms 三种入口的覆盖顺序；
- native binding 与反射 fallback；
- hidden args 和 external implicit `this`；
- handle/ref/object 的内存布局；
- mutable global 和 import slot；
- cross-module direct call；
- hot reload 时旧代码图像的活动调用 lease。

### 17.5 LLVM poison/UB 测试语料

需要建立覆盖以下行为的可重复语料：

- 有符号/无符号溢出；
- `INT_MIN / -1`；
- 除零；
- 过大和负 shift count；
- 浮点转整数越界；
- NaN、infinity、`-0.0`；
- 短路和副作用顺序；
- 参数 reverse formal order；
- mutation target 单次求值；
- cleanup reverse/live-only；
- loop/switch transfer phases。

### 17.6 LLVM 与现有 StaticJIT provider 的产品关系

需要决定 LLVM 产物是否：

- 作为新的 provider 类型；
- 复用现有 ABI Revision 2 表；
- 只作为 build-time object 被现有 provider 承载；
- 与 TypedASTJIT C++ emitter 共用 HIR capture、verifier 和稳定 key。

### 17.7 canonical typed AST OpenSpec 的实施起点

正式 architecture OpenSpec 已创建，实施任务仍为 `0/93`。真正开始源码工作时，应从 tasks 1 的语义/差异基线开始，而不是直接删除 HIR 或先写 LLVM emitter。每个里程碑需要在同一个 change 中根据证据更新后续任务。

### 17.8 lexical implementation 的首个 UE preprocessor cutover cluster

正式 lexical OpenSpec 已经创建，但尚未决定 comment/string boundary 之后首先切换 directives、descriptor headers 还是 delimiter matching。实施前应根据现有缺陷密度、测试覆盖和输出差异风险选择第一个 cluster；无论选择哪项，都必须保留 exact processed text、descriptor、provenance 和 diagnostic differential gate。

### 17.9 下一项 architecture OpenSpec 是否以及何时创建

如果 canonical frontend 的 P0 production wiring 已经闭合，下一项候选是 compiler session/module activation；但创建前必须重新核对 Hot Reload、incremental function cache、TypeBindInfo cache 和 subsystem ownership changes 的实时状态，避免把已有 task 重复搬入新 change。当前只完成探索，不创建该 OpenSpec。

---

## 十八、源码与研究入口

### 18.1 当前 Typed Semantic HIR

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.cpp`
- `Plugins/Angelscript/Standalone/Tests/AngelscriptTypedSemanticIRTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/TypedSemanticIR/`

### 18.2 当前专题文档

- `Documents/Knowledges/ZH/AS_TypedSemanticHIR.md`
- `Documents/Knowledges/ZH/AS_TypedSemanticHIRToLLVM.md`

### 18.3 `cppvm`

- `W:\Temp\cppvm\source\core\vmlib\VmLib.cpp`
- `W:\Temp\cppvm\source\core\collect\`
- `W:\Temp\cppvm\source\core\gather\`
- `W:\Temp\cppvm\source\core\diff\`
- `W:\Temp\cppvm\source\core\patch\`
- `W:\Temp\cppvm\source\core\thunk\`

### 18.4 LLVM/Angelsea 本地 PoC

- `.worktrees/feature-as-angelsea-llvm-jit-plugin/Plugins/UnrealLLVM/`
- `.worktrees/feature-as-angelsea-llvm-jit-plugin/openspec/`

注意：这些是另一个 worktree 的研究内容，读取时必须先重新检查其 Git 状态和最新任务记录，不能把这里记录的 2026-08-20 快照长期当作实时状态。

### 18.5 daScript

- `Reference/daScript/include/daScript/ast/ast.h`
- `Reference/daScript/include/daScript/ast/ast_expressions.h`
- `Reference/daScript/include/daScript/ast/ast_cfg.h`
- `Reference/daScript/src/ast/ast_parse.cpp`
- `Reference/daScript/src/ast/ast_infer_type.cpp`
- `Reference/daScript/src/ast/ast_simulate.cpp`
- `Reference/daScript/include/daScript/simulate/simulate.h`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das`
- `Reference/daScript/src/builtin/module_jit.cpp`

daScript 是跨语言架构参考，不是 AngelScript 语义、ABI 或当前插件产品行为的权威来源。

### 18.6 当前 AngelScript Lexer/Preprocessor/Parser/Sema/Bytecode

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptcode.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptcode.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_datatype.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`

### 18.7 Clang/LLVM 主参考

本地 `Reference/llvm-project` 使用 sparse checkout；以下文件存在于 Git `HEAD`，读取示例：

```powershell
git -C Reference/llvm-project show HEAD:clang/include/clang/AST/ASTContext.h
```

关键 Git object path：

- `clang/include/clang/AST/ASTContext.h`
- `clang/include/clang/AST/DeclBase.h`
- `clang/include/clang/AST/Stmt.h`
- `clang/include/clang/AST/Expr.h`
- `clang/include/clang/AST/ExprCXX.h`
- `clang/include/clang/Basic/TokenKinds.h`
- `clang/include/clang/Basic/TokenKinds.def`
- `clang/include/clang/Basic/SourceLocation.h`
- `clang/include/clang/Basic/SourceManager.h`
- `clang/include/clang/Lex/Token.h`
- `clang/include/clang/Lex/Lexer.h`
- `clang/include/clang/Lex/Preprocessor.h`
- `clang/include/clang/Parse/Parser.h`
- `clang/include/clang/Frontend/CompilerInvocation.h`
- `clang/include/clang/Frontend/CompilerInstance.h`
- `clang/include/clang/Frontend/FrontendAction.h`
- `clang/include/clang/AST/ASTConsumer.h`
- `clang/include/clang/Basic/Diagnostic.h`
- `clang/include/clang/CodeGen/ModuleBuilder.h`
- `clang/lib/Lex/Lexer.cpp`
- `clang/lib/Lex/Preprocessor.cpp`
- `clang/include/clang/Sema/Sema.h`
- `clang/lib/CodeGen/CodeGenFunction.h`
- `clang/lib/CodeGen/CGStmt.cpp`
- `clang/lib/CodeGen/CGExpr.cpp`
- `clang/include/clang/Analysis/CFG.h`
- `llvm/include/llvm/IR/Module.h`
- `llvm/include/llvm/IR/BasicBlock.h`

研究快照：`9bc4fd0fafb58ff1fb50231e39a882a678542dac`，提交时间 2026-08-09。

### 18.8 canonical AST/Compiler OpenSpec

- `openspec/changes/refactor-as-canonical-typed-ast-compiler/`
- `openspec/changes/feature-as-typed-semantic-aot/`
- `openspec/changes/archive/2026-08-20-refactor-as-primary-engine-typed-ast-generate/`
- `Documents/Guides/AngelscriptForkStrategy.md`

### 18.9 source-aware lexical pipeline OpenSpec

- `openspec/changes/refactor-as-source-aware-lexical-pipeline/proposal.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/design.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/specs/as-source-aware-lexical-pipeline/spec.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/specs/as-host-preprocessor-lexical-integration/spec.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/tasks.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/attachments/current-state-and-clang-reference.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/attachments/canonical-change-coordination.md`

### 18.10 本次内部重构审计入口

当前用户 AST/Sema 工作快照：

- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.h`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_public_view.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_source_manager.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_bridge.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_sidecar.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheASTBodySidecar.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`
- `.worktrees/refactor-as-canonical-typed-ast-compiler/Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp`

其他核心边界：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_restore.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h`

worktree 内容仍会变化；所有“已完成/未完成”判断在真正规划或实施前必须重新核对 Git 状态和 production call path。

---

## 2026-08-21 — 问题 15：第三轮 review canonical typed AST 实现

### 用户问题

> 再 review 下；先做 review，不要继续构建，因为另一个 agent 仍在同一 worktree 实现。

### 结论

第三轮对 2026-08-21 16:14（Asia/Shanghai）的中间快照仍给出 **Request changes**。这不是否定当前方向：实现已经成为一套可继续演进的 canonical typed AST migration platform / shadow semantic compiler，第二轮发现的 funcdef/lambda teardown Critical 也已经真实修复；但它仍未成为 production compiler authority，不能归档，也不能切换 production default。

收到“另一个 agent 仍在实现”的说明后，停止一切后续 build/test，不占用编译锁。第三轮正式报告和下述验证数字都只代表 16:14 快照，不是另一个 agent 完工后的最终验收。

### 相较第二轮的关键变化

1. **R11 已关闭，不再作为当前 Critical。**
   - funcdef/lambda 组合用例不再执行正确后于 `Engine.Destroy()` 崩溃；
   - `Frontend.CanonicalAST` 最新 `56/56 PASS`，覆盖 24 个 CodeGen 用例及 funcdef/lambda 最小化、组合、执行和 teardown 生命周期；
   - 修正内容涉及 funcdef conversion、function handle metadata、argument ordering、compatible funcdef lookup，以及 `DiscardPending()` 在未 `AddReferences()` 时避免 extra-release；
   - R11 应保留为回归门禁，但 tasks 13.6 中“仍会 AV”的说明已经过期；13.6 仍不能勾选，因为 R09 transaction 和 production routing 尚未完成。

2. **新增 R04 的结构性 Blocking：Cache function content hash 不包含函数体。**
   - `asCASTCollectFunctionRecords()` 只 hash function key、decl type/quals/traits/origin/default arg/dependencies；
   - `decl->body`、stmt/expr、literal、resolved references、cleanup/liveness 和 source-content identity 都没有进入 hash；
   - `profile` 被 `(void)profile` 显式忽略；
   - 所以保持 signature/dependencies 不变、只把 `return 1` 改成 `return 2` 时，当前 planner 可能错误复用旧 sidecar；
   - 名为 ChangedFunction 的现有 fixture 实际只把 `G` 的返回类型改成 `const int`，没有创建或修改函数体，不能覆盖这个风险。

3. **当前 sidecar decode 不是完整 AST reconstruction。**
   - encode 写 textual dump + declaration table；
   - decode 读取 dump 但不消费它，只重建 translation unit/declarations/type key；
   - stmt/expr/body/reference/source/cleanup graph 没有恢复；
   - 因此尚不能支持规范要求的 ExactStartup：不运行 Parser/Sema 就恢复等价 verified module AST。

4. **当前 Cache prefix 为 `5/7 PASS`。**
   - 两个直接失败来自测试仍只接受旧 stable keys `F/H` 或 `IncMod::F/DepMod::H`，而实现已产生 `F()/H()`；
   - 即使修正这两个 fixture，body-less hash 与 incomplete decode 仍然存在，不能据此关闭 R04。

5. **production 路径仍未切换。**
   - `asCModule::Build()` 仍进入 `asCBuilder::BuildCompileCode()`；
   - production 仍实例化 `asCCompiler`；
   - `asCBytecodeCodeGen::Generate()` 仍是隔离测试 subset，没有 production caller；
   - LEGACY default、Ready=false 与 publisher provenance 是诚实性修正，不是 cutover 完成证据。

6. **R05/R06/R09 仍为 Blocking。**
   - public AST 方法仍插入 `asIScriptModule` 旧 vtable 中部，view 写入不尊重 caller `structSize/apiVersion`，ID 无 snapshot domain；
   - snapshot Acquire 仍有 raw pointer → AddRef race，publication 在验证 candidate 前释放 previous，失败会丢失 last-good，current-generation 是普通 bool；
   - CodeGen 仍在所有 body emission 成功前分配 module global 并注册 Engine function，failure cleanup 不是覆盖所有 mutation 的 detached transaction。

7. **R07/R08 有真实进展，但仍未完成。**
   - block arena、sealed mutable getter rejection、const snapshot traversal 和更多 verifier checks 已落地；
   - verifier 已覆盖大量 ID/parent/range/control/type/duplicate-case 约束；
   - 仍缺 stmt/expr graph cycle/multiple ownership、nearest target、完整 per-kind/call/cleanup/liveness/dependency/ABI 约束；
   - 实现过程中 public view 曾因 sealed Context 选中 non-const getter 而使 HotReload `3/5`，显式转 const 后 fresh `5/5`。当前失败已关闭，但说明“同名 const/non-const + runtime null”仍是容易误用的 API 形状。

### 16:14 中间快照验证证据

这些命令在用户要求停止构建之前已经完成；此后不再执行构建或测试：

| 范围 | 结果 |
| --- | ---: |
| UE incremental build | exit 0 / target up to date |
| `Frontend.CanonicalAST` | `56/56 PASS` |
| `Compiler.CanonicalAST` | `37/37 PASS` |
| `Module.CanonicalAST.Snapshot` | `4/4 PASS` |
| `HotReload.CanonicalAST` | `5/5 PASS` |
| full `AngelScriptSDK.Compiler` | `225/225 PASS` |
| `TypedASTJIT.CanonicalASTMigration` | `8/8 PASS` |
| `Cache.ASTBodySidecar` | `5/7 PASS`，2 fail |
| Standalone Debug CTest | `21/21 PASS` |
| `openspec validate ... --strict` | valid |
| parent/plugin tracked `git diff --check` | pass |

Standalone 编译出现多条新增 AST header 的 MSVC C4819（CP936 无法表示字符）警告；不影响 21/21，但 release/跨区域构建前应统一 UTF-8 source encoding。

### 当前任务完成度

- tasks：`51/105` checked，`54` open；
- 13.1–13.12：全部未勾选；
- scaffold/isolated prototype 已有较大规模；
- production authority/cutover 仍未完成；
- 完整 OpenSpec 粗略约 45–55%，不能按 checkbox 算术解释为 production compiler 完成 48.6%。

### 推荐继续顺序

1. 先让 Cache key fixture 匹配新的 complete stable key，并新增真正的 body-only/hash/profile/decode equality 红测试；
2. 完成 R07/R08 construction/read-only 分离和 verifier adversarial matrix；
3. 实现 R09 detached CodeGen artifact + atomic installer，再扩完整语言子集；
4. 完成 R05 public ABI 与 R06 snapshot retain/exchange protocol；
5. 重做 R04 pointer-free complete AST DTO；
6. 完成 R10 content-aware SourceManager；
7. 最后才把 production `Build()` 从 `asCCompiler` 切到 canonical CodeGen。

R11 已从第一优先级移除，改为贯穿上述工作的回归门禁。

### 记录位置

第三轮正式 findings-first 报告：

- `.worktrees/refactor-as-canonical-typed-ast-compiler/openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/implementation-rereview-2026-08-21-third-pass.md`
- 短路径：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-21-third-pass.md`

本轮只新增/更新 review 与本会话记录，没有修改插件实现，也没有替实现者勾选 tasks。

### 对当前决策的影响

- 推翻问题 14 中“R11 是当前 Critical”的时态判断：它是第二轮真实历史问题，但第三轮当前快照已修复；
- 不改变“canonical typed AST 方向正确、当前仍是 shadow/scaffold 而非 production authority”的主判断；
- 新增“Cache body must participate in per-function content identity”作为 R04 的明确验收条件；
- 再次确认不应从 happy-path test count 或 legacy compatibility prefixes 推导 cutover 完成。

### 未决事项

- 另一个 agent 完成后，需重新读取最新 diff 和 call path；本文不能代替最终复审；
- body-only edit 是否已在后续实现中进入 content hash；
- CodeGen 是否改为 detached artifact 并完整回滚 globals/functions/funcdefs/types；
- public ABI/snapshot concurrency adversarial tests 是否落地；
- production `Build()` 是否真正以同一 sealed snapshot 为唯一语义输入。

---

## 2026-08-21 — 问题 16：第四轮 review 持续实现中的 canonical typed AST

### 用户问题

> 又实现了一段时间了，再帮我 review 下；仍以 review 为主，不主动构建正在被另一个 agent 修改的 worktree。

### 结论

第四轮对 **2026-08-21 19:35（Asia/Shanghai）** 的共享 worktree 中间快照继续给出 **Request changes**。实现确有进展：arena/seal 边界、type bridge、Verifier 基础、Parser ActOn、R09 global rollback 和 CodeGen regression tests 都继续增加；但本轮发现默认 LEGACY production path 的 lambda recovery-tree consumer contract 已被新 Parser shape 破坏，因此当前不仅是“canonical 尚未 cutover”，还存在一个应立即止血的 compatibility regression。

本轮遵守用户“不急着构建、另一个 agent 仍在实现”的边界：没有运行 build/test，只读取实现者已保存的 JSON test reports。报告数字是已有证据，不是本 reviewer 对 19:35 快照重新构建的独立验收。

### 第四轮关键发现

1. **Critical/Blocking：`ParseLambda()` 无条件改变了 legacy tree layout。**
   - 新 layout 为 `snFunction -> snIdentifier("function") + snParameterList + snStatementBlock`；
   - `asCCompiler::ImplicitConvLambdaToFunc()` 仍按旧 layout 直接遍历 `snFunction` 的平铺参数；
   - 它会把 `function` identifier 错算成一个参数，并完全跳过 `snParameterList` 的真实 children；
   - 默认 production 仍走 LEGACY `asCCompiler`，所以这是当前生产兼容性回归，不是未来 canonical 风险；
   - 现有 lambda action/dump/canonical CodeGen 测试没有覆盖默认 Engine module Build + execute。

2. **Verifier 的 `2.8` / `13.5` closure 过早。**
   - break/continue 只验证 target 是 ancestor，不拒绝跳过最近 loop/switch 的 `skipped-nearer`；
   - expression graph 没有 cycle/multi-owner 验证；
   - CALL/CONSTRUCT 缺失 required resolved callee 仍可 seal；
   - CLEANUP 缺失 destructor target 仍可 seal；
   - FALLTHROUGH 只要求任意 switch ancestor，不验证 next case/nearest switch/order；
   - stable references、resolved signature compatibility、cleanup/live edge plan 仍未覆盖；
   - 这些都是 capability spec 明文要求，不能以“留给 later Sema/Wave F”为由同时把 firewall 标成 closed。

3. **`namespace A::B` 的增量 action hierarchy 有静态可证明的缺口。**
   - Parser 读到第一个 identifier `A` 后就 NotifySema + push `A`，之后才解析 `::B`；
   - Sema 的 `WalkOne(snNamespace)` 也只取第一个 identifier；
   - 所以 qualified namespace declaration 可能生成 `A::F()` 而不是 `A::B::F()`；
   - 当前测试只覆盖 `namespace A { namespace B { ... } }`，没有覆盖 `namespace A::B { ... }`。

4. **重新启用 `interface` / `typedef` 是语言行为变化。**
   - `as_tokendef.h` 把两个原本注释的 keyword token 重新启用；
   - 这既会接受此前 tokenizer 不可达的 declaration syntax，也可能拒绝此前把这些词当 identifier 的脚本；
   - 当前 OpenSpec 明确把 changing accepted syntax 列为 non-goal；
   - 若产品决定恢复语法，应先修订 spec、增加兼容/迁移/release gate；若只是 AST 架构重构，应还原 token set。

5. **R09 Task 1 有进展，但 success ownership 仍可疑。**
   - 已保存 Transaction `3/3`、CodeGen `27/27`；
   - global failure rollback 已加入；
   - successful canonical Generate 在把新 function push 到 module 后仍额外 `AddRefInternal()`；正常新 function 注册路径明确说明 constructor 已持有 internal ref；
   - module reset 可能只释放到 ref=1，造成 object/Engine slot leak 或 stale registry；
   - detached artifact、FuncPtr/REFCPY fail-after-emit、same-module retry 和 production routing 仍未完成。

6. **R04/R05/R06/R01 仍是原 Blocking。**
   - Cache content hash 仍不含 body且忽略 profile，decode 仍只重建 declaration skeleton；
   - public AST API 仍 mid-vtable insertion，view 不尊重 caller size/version，ID 无 snapshot domain；
   - snapshot Acquire 仍有 raw pointer→AddRef race，publication 先丢 previous 再验证 candidate；
   - production `Build()` 仍由 legacy `asCCompiler` 发布 Bytecode，canonical selection 仍只是 capture/shadow attach。

### 保存测试证据

只读解析实现者已有 report：

| 范围 | 保存结果 |
| --- | ---: |
| Verifier | `13/13 PASS` |
| Frontend CanonicalAST | `63/63 PASS` |
| Compiler CanonicalAST（Wave C） | `37/37 PASS` |
| R09 Transaction | `3/3 PASS` |
| CodeGen | `27/27 PASS` |
| Parser expression SemaAuthority | `57/57 PASS` |
| Parser expression CanonicalAST | `72/72 PASS` |
| Parser return/statement SemaAuthority | `61/61 PASS` |
| Parser statement CanonicalAST | `76/76 PASS` |

这些是已实现断言的正向证据，但不覆盖上述 lambda legacy consumer、qualified namespace、keyword compatibility、完整 verifier 或 transaction/publication adversarial contract。

### 当前任务状态

- worktree tasks：`56/105` checked，`49` open；
- 本轮认为 `2.8` 和 `13.5` 应重开；纠正后应为 `54/105` checked、`51` open；
- `2.4` / `13.4` 的 arena+seal closure 可保留；
- `2.6` 可按 runtime type bridge foundation 的 scoped 含义保留；
- R11 teardown crash 继续保持 closed，但应新增 successful Generate → module reset → Engine teardown refcount gate。

### 推荐顺序

1. 先修 legacy lambda layout/consumer compatibility；
2. 明确 `interface` / `typedef` 是否属于本 change 的语言决策；
3. 增加 `namespace A::B::C` red tests；
4. 重开并补齐 verifier matrix；
5. 修 success function ownership，完成 detached CodeGen artifact + atomic installer；
6. 完成 public ABI、snapshot protocol、Cache DTO、SourceManager/Sema/identity；
7. 最后才切 production Build、跑 final differential/All，并删除 duplicate HIR/legacy production path。

### 记录位置

第四轮正式报告：

- `.worktrees/refactor-as-canonical-typed-ast-compiler/openspec/changes/refactor-as-canonical-typed-ast-compiler/reviews/implementation-rereview-2026-08-21-fourth-pass.md`
- 短路径：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-21-fourth-pass.md`

本轮只新增 review 和本会话记录，没有修改插件源码、没有改 tasks checkbox、没有运行 build/test。

### 对当前决策的影响

- 保持“canonical typed AST 方向正确、当前仍是 shadow/scaffold 而非 production authority”的主判断；
- 新增“Parser recovery-tree shape 是仍在服役的 legacy consumer contract，不能为 canonical Sema action 单边改写”作为迁移硬约束；
- 新增“Verifier checkbox 必须按 spec invariant matrix 验收，测试数量不能替代需求覆盖”；
- 新增“token keyword set 是语言兼容面，compiler architecture change 不得隐式修改”；
- 将 `namespace A::B` 加入 Parser ActOn / stable identity 的必要 differential matrix。

### 未决事项

- 后续 agent 是否已修复 lambda flat layout 或同步迁移 legacy compiler consumer；
- `interface` / `typedef` 是否由产品明确决定恢复；
- qualified namespace action 是否按完整 path 分段创建 context；
- verifier 是否新增 skipped-nearer、expr cycle/multi-owner、required callee/cleanup/next-case 检查；
- CodeGen extra internal ref 是否被 success teardown test 证伪或修复；
- production Build、Cache DTO、public ABI 和 snapshot atomicity 是否真正闭环。

---

## 2026-08-21 — 问题 17：什么叫增量 Parser 破坏了 LEGACY lambda 节点协议

### 用户问题

> “增量 Parser 改造已经破坏了当前仍在使用的 LEGACY 编译路径中的 lambda 节点协议”是什么意思，应该怎么理解和表达？

### 结论

这里的“节点协议”不是网络协议或公开 ABI，而是 **Parser producer 与 Compiler consumer 之间没有被类型系统显式表达的 AST 子节点布局契约**。更准确的说法是：

> Parser 现在生成的 `snFunction` lambda 子节点序列，与 `asCCompiler::ImplicitConvLambdaToFunc()` 仍然假定的旧子节点序列不一致。

旧 compiler 没有通过 `GetParameters()` 之类的稳定接口读取 lambda，而是依赖 `firstChild/next`、node kind 和 child ordering 直接解释 Parser tree。只要 Parser 单边改变节点层级，legacy compiler 就会把同一棵树解释成另一种含义。

### 旧节点布局

旧 `ParseLambda()` 把参数平铺在 `snFunction` 下：

```text
function(int X) { return X; }

snFunction
  snDataType(int)
  snDataType(type-mod)
  snIdentifier(X)
  snStatementBlock
```

零参数 lambda 则基本是：

```text
snFunction
  snStatementBlock
```

`asCCompiler::ImplicitConvLambdaToFunc()` 从 `firstChild` 开始，一直走 `next` 到 `snStatementBlock`：看到 `snDataType` 就检查参数类型，看到 `snIdentifier` 就把参数数目加一。这段 consumer 逻辑实际上把上面的 layout 当成了隐式协议。

### 新节点布局

为了让 canonical Sema 得到更清晰的 Clang-shaped 参数结构，新的 `ParseLambda()` 改成：

```text
snFunction
  snIdentifier("function")
  snParameterList
    snDataType(int)
    snDataType(type-mod)
    snIdentifier(X)
  snStatementBlock
```

这个结构本身更整洁，适合新 Sema；问题在于它对 `sema == nullptr` 的 LEGACY parse 也无条件生效，而旧 compiler 没有同步修改。

旧 compiler 读取新 layout 时：

1. 看到第一个 `snIdentifier("function")`，错误地把它计为一个 parameter；
2. 看到 `snParameterList`，既不识别它为参数，也不递归遍历其 children；
3. 真实的 `int X` 因此没有进入旧 parameter type/name 逻辑；
4. 零参数 lambda 会从 0 被错算成 1；
5. 单参数 lambda 可能在数量上偶然仍是 1，但真实类型检查被跳过；
6. 两个及以上参数通常会因为仍只数到 `function` 这个 identifier 而发生数量不匹配；
7. 后续 `RegisterLambda` / lambda function compilation 也可能继续收到不符合旧假设的 tree。

它不一定表现为立即崩溃，更可能表现为：

- 合法 lambda 被拒绝；
- 错误类型的 lambda 被错误接受到更晚阶段；
- 参数数量/类型诊断异常；
- 后续 lambda registration/compilation 出错。

### 为什么称为“增量 Parser 改造”导致

这次 Parser 不再只在整棵 syntax tree 完成后让 Sema post-walk，而是在读到 declaration/parameter/call/statement 的阶段就执行 `ActOn...`。为了让这些 action 看到结构化参数，lambda 被改成 `snParameterList`。

问题不在“增量 action”思想本身，而在迁移期间同时存在两个消费者：

```text
Parser tree
  ├─ 新 canonical Sema：期待结构化 ParameterList
  └─ 旧 legacy Compiler：期待平铺 children
```

producer 为新 consumer 改了 shape，却没有保留旧 consumer contract，也没有提供 compatibility adapter。

### 更准确、通俗的表达

面向实现者可以说：

> `ParseLambda()` 已把 lambda 参数从 `snFunction` 的平铺 children 改为 `snParameterList` 子树，并额外插入了 `function` identifier；但 production `asCCompiler::ImplicitConvLambdaToFunc()` 仍按旧平铺顺序扫描 `firstChild/next`。Parser producer 与 legacy compiler consumer 的 AST layout contract 已不一致。

面向非编译器背景可以说：

> Parser 改了数据格式，但旧编译器还在按旧格式读。新格式把参数放进了一个“参数列表文件夹”，旧编译器不会打开这个文件夹，反而把前面的 `function` 标签当成了一个参数。

### 推荐修法

迁移期有三种选择：

1. **兼容 adapter，优先推荐。**
   - 定义一个集中 helper，例如 `ForEachLambdaParameter()` / `GetLambdaParameterList()`；
   - 在过渡期同时识别旧 flat layout 和新 `snParameterList`；
   - legacy compiler、RegisterLambda、Sema 共用这个 adapter；
   - canonical cutover 完成、legacy consumer 删除后再只保留新 layout。

2. **Parser 保留旧 recovery tree，Sema action 使用独立参数 payload。**
   - legacy `asCScriptNode` 不变；
   - Parser action 把结构化 parameter descriptors 直接传给新 Sema；
   - 更符合“Parser recovery tree 最终会删除，不再继续扩它”的方向，但当前改动量可能略大。

3. **同步迁移所有旧 consumer。**
   - 修改 `ImplicitConvLambdaToFunc`、`RegisterLambda`、lambda compile 等所有读取点理解新 layout；
   - 必须通过完整 legacy lambda compatibility test；
   - 这种方案会继续投资即将退役的 legacy compiler，适合作为短期修复但不宜继续扩散节点知识。

当前不适合用“立即 canonical cutover”来绕开，因为 canonical Sema/CodeGen/publication/Cache 还没有达到 production gate。

### 必要测试

至少应增加默认 LEGACY Engine 下的：

```text
function()
function(int X)
function(float X) 绑定 int callback 时拒绝
function(int A, int B)
in/ref/out 修饰参数
Build + execute + module reset + Engine teardown
```

还应在 canonical attach/shadow 模式下运行同一 source，证明增量 Sema action 没有改变 legacy observable behavior。

### 对当前决策的影响

- 不否定 `snParameterList` 作为新 canonical Parser/Sema 结构的合理性；
- 新增一条迁移硬约束：在旧 consumer 仍服役期间，Parser recovery-tree shape 是兼容协议，不能单边改变；
- 更长期的正确方向是让 Parser action 使用明确 typed API/payload，而不是让多个阶段继续猜 `firstChild/next` 的布局。

### 未决事项

- 实现者会选择 dual-layout adapter、独立 action payload，还是同步迁移旧 consumers；
- `RegisterLambda()` 和 lambda compile 的其他读取点是否还有同类 flat-layout 假设；
- active legacy lambda test 是否已经覆盖参数数量、类型不匹配、执行和 teardown。

---

## 2026-08-21 — 问题 18：`asCScriptNode` 现在是否还会使用

### 用户问题

> `asCScriptNode` 这个现在还会用吗？

### 结论

**会，而且截至当前 `refactor-as-canonical-typed-ast-compiler` worktree，它仍是 source build 的关键生产数据结构，不能删除。**

它现在同时承担三类职责：

1. Parser 仍用它构造完整的临时语法树；
2. Builder 和 production legacy `asCCompiler` 仍直接读取它完成声明注册、类型建立、函数/全局初始化编译和现行 Bytecode 生成；
3. 新 canonical Sema 目前也仍通过 `ActOn*FromNode(asCScriptNode*)` 把这棵旧 Parser tree 翻译成 `asCASTContext`。

因此它不是已经退出生产路径的“遗留死代码”，也不只是错误恢复节点。上一问题所说的 lambda layout regression 之所以严重，正是因为 production legacy consumer 仍在解释这棵树。

但它的生命周期是**一次编译会话内的临时 Parser/Builder tree**，不是运行期 VM IR，也不是新 canonical typed AST，更不是准备持久化到 Cache V2 或交给未来 LLVM 后端的正式语义表示。

### 当前真实调用链

```text
.as source
    │
    ▼
asCParser
    │  CreateNode(...)，节点分配在 Parser 的 FMemStackBase
    ▼
asCScriptNode tree
    ├──────────────────────────────────────┐
    │                                      │
    ▼                                      ▼
legacy Builder / asCCompiler           canonical asCSema
声明注册、类型/布局、                   ActOnParsedScript/
函数与全局初始化、                      ActOn*FromNode
现行 production Bytecode                   │
    │                                      ▼
    │                                 asCASTContext
    │                                 sealed snapshot
    ▼
VM Bytecode

BuildCompileCode 完成
    │
    └─ 删除 parsers，Parser MemStack 随之释放 asCScriptNode tree
```

这说明当前是“一棵旧 Parser tree，喂给两个消费者”：

- legacy compiler 是当前可执行 Bytecode 的权威消费者；
- canonical Sema 是迁移中的 shadow/capture 消费者。

它不是“两套 production compiler 已经完成切换”。即使把 Engine pipeline 设置为 `CANONICAL`，当前该开关主要触发 canonical Sema/AST 构造；module `Build()` 最后仍调用 `BuildCompileCode()`，而该函数仍实例化 `asCCompiler`（没有命中单函数 build-artifact restore 时）并调用现行 compile routines。

### 源码依据

1. `as_scriptnode.h` 对它的定义就是 “A node in the script tree built by the parser for compilation”，其节点类型覆盖 script、function、datatype、statement、expression、lambda 所用的 `snFunction` 等完整语法结构。
2. `asCParser::CreateNode()` 从 Parser 自己的 `FMemStackBase` 分配 `asCScriptNode`，`GetScriptNode()` 返回整棵树的 root。
3. `asCBuilder::BuildParallelParseScripts()` 为每个 source 建立 Parser；`BuildGenerateTypes()` 随后直接从 `GetScriptNode()` 取得 root，并调用 `RegisterTypesFromScript()`。
4. Builder description 仍保存 `asCScriptNode*`，用于 function、factory、global/property initializer、source range/canonical-token identity 和后续编译。
5. `asCModule::Build()` 依次执行 parse、generate types/functions、layout，最后调用 `BuildCompileCode()`；后者仍通过 `asCCompiler` 编译 factory/functions，并在末尾删除 parsers。
6. canonical Sema 的公开内部入口仍包括 `ActOnParsedDeclaration(asCScriptNode*)`、`ActOnExprFromNode(asCScriptNode*)`、`ActOnStmtFromNode(asCScriptNode*)` 和 `ActOnParsedScript(asCScriptNode*)`。这证明新 Sema 仍在翻译旧 tree，而不是由 Parser action 直接构造完备 canonical semantics。
7. 新 `asCBytecodeCodeGen::Generate()` 已只接收 sealed `asCASTContext`，不接收 `asCScriptNode`；但当前调用点仍在 Canonical AST tests 中，production module `Build()` 尚未切到它。
8. `ScriptFunctionData` 没有长期保存 Parser node pointer；`asCScriptFunction` 只在编译期 helper（例如 list pattern conversion）短暂接收节点。编译完成后保留的是 function metadata、Bytecode、转换后的 list-pattern/runtime 数据，以及按策略保留的 canonical AST snapshot，而不是 Parser tree。

截至本次静态检查，maintained fork 的 `source/*.h,*.cpp` 中仍有约 `851` 处 `asCScriptNode` 文本引用。这个数字不是架构质量指标，但足以说明它还不是可以直接删掉的孤立类型。

### “现在保留”和“最终保留”应怎样区分

当前必须保留：

- Parser source-build output；
- legacy Builder 的 declaration/type/layout 输入；
- production `asCCompiler` 的 statement/expression/Bytecode 输入；
- canonical Sema 的过渡性 `FromNode` 输入；
- 编译期 diagnostics、source range、default argument、list-pattern 等兼容 helper。

最终架构不应再保留的部分：

- `asCCompiler`、Builder 或任一 production backend 把它当 semantic body；
- canonical Sema 通过遍历 `firstChild/next` 重新猜语义；
- Cache V2 持久化它；
- StaticJIT、Bytecode CodeGen 或未来 LLVM lowering 直接读取它；
- 为旧测试单独保留第二棵 production semantic tree。

最终是否需要把 `asCScriptNode` 这个 C++ class 本身彻底删除，则是另一个问题。合理的 cutover 目标首先是**删除它的 production semantic authority**。Parser 仍可能短期保留一个更小的 syntax/recovery node 结构，用于错误恢复、语法测试或兼容的 public parse helper；也可以最终被 token cursor + Parser actions 完全取代。不能把“生产语义消费者归零”和“源文件里不再存在这个类型”混成同一个门禁。

### OpenSpec 中的目标状态

当前 change 已明确把以下事项保持为未完成：

- `10.3`：Parser nodes 最多可以是 recovery input；sealed canonical graph 必须已经含有所有 backend decision；
- `10.6`：cutover 后不得有 production compiler path 使用 `asCScriptNode` 作为 semantic body representation；
- `13.2`：以真正的 Sema environment 取代 `asCScriptNode` syntax walk；
- design 的最终迁移步骤：删除旧 `asCScriptNode` production consumers，而不是在 canonical coverage 尚未完成时先删 producer。

所以当前正确的迁移顺序是：

```text
先补齐 canonical Parser actions + Sema environment
    ↓
让 sealed asCASTContext 含全部语义/控制流/生命周期/backend decisions
    ↓
production Bytecode / StaticJIT / Cache 改读 canonical graph
    ↓
通过 legacy differential、runtime、teardown、cache restore 门禁
    ↓
删除 Builder/asCCompiler/asCSema 的 asCScriptNode production consumers
    ↓
最后再决定 Parser recovery node class 是否整体重命名、缩减或删除
```

### 对当前决策的影响

- 进一步确认当前 worktree 仍是 canonical migration/shadow platform，不是已经完成的 canonical production compiler；
- `asCScriptNode` 当前仍是生产兼容协议，Parser 改 shape 必须同步 legacy consumers 或提供 adapter；
- 不应现在直接删除 `asCScriptNode`；应先消除 production semantic consumers；
- Cache V2、StaticJIT 和未来 LLVM 后端应只消费 sealed canonical AST/后续 lowering IR，不应把 `asCScriptNode` 固化成新的长期接口。

### 未决事项

- Parser actions 何时能直接向 Sema 提交 typed payload，而不再 post-walk `asCScriptNode`；
- production Bytecode 何时从 `asCCompiler` 切到 transactional canonical CodeGen；
- 全部 declaration/default-arg/list-pattern/diagnostic helper 中哪些需要迁到新 frontend service；
- cutover 后 Parser recovery tree 是否保留、缩减、重命名，还是由 token cursor + explicit invalid nodes 完全取代。

---

## 十九、后续问题追加模板

以后在本次会话继续讨论相关问题时，按下面格式追加：

```markdown
## YYYY-MM-DD — 问题 N：问题标题

### 用户问题

> 用户问题的必要摘要

### 结论

本次回答的核心判断。

### 关键依据

- 当前源码证据；
- 本地 PoC 或外部参考证据；
- 必要的版本、路径和状态说明。

### 对当前决策的影响

是否新增、修改或推翻“当前决策账本”中的某项判断。

### 未决事项

仍需通过代码检查、实验、测试或产品选择回答的问题。
```

如果后续问题只是更正既有事实，应直接修正文中错误，并在对应问题下说明更正日期和原因，避免保留相互矛盾的结论。

---

## 二十、截至本次整理的最终判断

1. 当前确实存在独立的 `asCTypedSemanticFunction` Typed Semantic HIR；
2. 它的职责是冻结前端已经确定的语言语义，给 native 后端一个可验证输入；
3. high-level typed semantic AST/HIR 与 LLVM IR 属于不同层，最佳关系是“canonical AST/HIR lowering 到 LLVM IR”，不是互相取代；
4. 当前 HIR 已足以开始标量和结构化控制流的 LLVM 实验；
5. 完整后端的主要难点是语义、ABI、生命周期和 Runtime 集成，不是 LLVM builder API；
6. `cppvm` 适合参考 IR 执行和热补丁，但不适合作为新的 AngelScript 主 VM；
7. 本地 LLVM worktree 已降低 LLVM/UE/ORC 集成风险，但仍只是尚未落地主线的 PoC；
8. daScript 没有独立命名的 HIR，它的最终 typed/normalized AST 图承担了事实上的 HIR 职责；
9. 当前 HIR 在宽泛分类上同样是一种 typed AST/HIR，但它不是 Parser AST 加类型，而是独立、规范化、可验证且 graph 不依赖 Parser node 的 statement tree + expression DAG 快照；其 `asCDataType` 仍含 Engine-local type pointer，所以不是整体 pointer-free DTO；
10. HIR→LLVM 是此前确认可行的研究路线；当前正式 change 先把 high-level semantic authority 收敛为 canonical AST，并用 Bytecode/TypedASTJIT 验证，不在其中实现 LLVM；
11. 现有 Bytecode/VM 必须继续作为语义基准和逐函数 fallback；
12. 长期可以把 Parser AST、sidecar HIR 和多后端收敛为一套 canonical typed AST，但不应直接扩充 `asCScriptNode` 或先删除 HIR；
13. 成熟主参考是 Clang 的 Parser+Sema+ASTContext+CodeGen 分层，LLVM core 本身没有源语言 AST；
14. canonical typed AST 已成为正式规划：`refactor-as-canonical-typed-ast-compiler` OpenSpec 有 12 个里程碑、93 项任务；截至 2026-08-21 worktree tasks 为 `90/93`，但第 10 节已被改写为保留 legacy residuals，而 capability specs 仍要求完整 cutover；任务勾选与规范/production call path 不一致，不能把 `90/93` 当作真实完成度；
15. 原 `0/36` primary-engine TypedHIR change 已被完整吸收并以 `--skip-specs` 归档，Cache V2 目标改为 canonical AST DTO/`ASTBodySidecar`；
16. 公共 AST 使用 module-level、引用计数、版本化 immutable snapshot；内部仍可采用 Clang 式 arena pointer/tag，public/cache 只使用 opaque ID 和 stable key；
17. 完整迁移采用 Shadow Convergence：先建立语义/差异基线，迁移 AST/Sema/StaticJIT/Bytecode/Cache 消费者，最后删除 HIR 和旧 Parser/Compiler 生产路径；
18. 词法层已正式规划采用 Clang-inspired、AngelScript-native 分层：在 SourceManager 与 Parser 之间加入 raw Lexer、host/source-preparation token source 和 TokenBuffer/Cursor，保留公共 `ParseToken` 兼容入口；
19. UE `FAngelscriptPreprocessor` 不应继续长期维护一套独立 comment/string/identifier/bracket 扫描器，但 UE descriptor/生成语义不属于 raw Lexer，应通过 host adapter 逐步消费共享 lexical truth；
20. `refactor-as-source-aware-lexical-pipeline` 已作为 canonical compiler 的前置/协同 OpenSpec 建立，当前有 9 个里程碑、87 项未来任务、2 个新 capability spec，并已通过 strict validation；它不建立第二套 AST/Sema 权威；
21. 截至问题 11，只创建和验证了 OpenSpec/会话记录，没有由该轮修改插件源码、运行 UE build/test、改变 public `ParseToken` 行为或开启 LLVM 后端；
22. AngelScript 并不缺少 `Ixx`：public `asI*` 主要是 embedding ABI facade/handle，只有一个 concrete implementation 并不构成设计缺陷；
23. 内部现代化应以 concrete composition、显式 ownership、immutable artifact、session/transaction 和 narrow consumer/capability 为主，而不是为 Parser、Sema、ASTContext、GC 和 VM hot path批量增加纯虚接口；
24. 当前 AST/Sema worktree 已扩展为 ASTContext、节点、SourceManager、Sema、Verifier、public snapshot、AST sidecar、Bytecode CodeGen、TypedASTJIT canonical visitor 与 StaticJIT/Cache 接线，但 production Bytecode 仍由旧 `asCCompiler` 生成，Sema 仍 post-walk `asCScriptNode`，因此它仍是 shadow/scaffold + subset prototypes，不是 canonical production authority；
25. canonical frontend 正确性完成后，最高价值的新重构是 `asCCompilationSession + FAngelscriptCompileCoordinator + FAngelscriptModuleActivationTransaction`，使 source compile/cache restore 产生同类 verified artifact，并原子发布 live generation；
26. `asCScriptEngine` 应保留 public facade，同时把 registry、diagnostics、build state 和 host services 收敛为明确 owned component；ambient `FAngelscriptEngine::Get()` 应按真实 owner 分类迁移，而不是机械删除或换成另一个 service locator；
27. `FAngelscriptType` 是最值得做 capability segregation 的真实候选，但应在当前 TypeBindInfo cache/type correctness changes 稳定后再实施；
28. function public handle 与 generation-owned function body、module compilation artifact 与 live module instance 的分离，是 Hot Reload、tiered JIT、Cache V2、旧栈帧 lease 和 compiler-free runtime 的长期基础；
29. Semantic/Diagnostic consumer、restore phase、VM state、native call plan 和 internal include boundary 都有价值，但应按 P2/P3 顺序推进，并避免与当前活跃 OpenSpec 重复；
30. 问题 12 只完成只读架构审计并更新本文，没有创建新的 OpenSpec、修改用户 AST worktree 或改动插件源码；
31. 问题 13 对 `refactor-as-canonical-typed-ast-compiler` 做了只读实现 review：结论为 Request changes；P0 阻断包括虚假的 canonical cutover、非权威 Sema、重载 stable-key/StaticJIT 错配、占位 Cache sidecar、public ABI/size negotiation、snapshot 并发/原子性；后续按用户要求把同一结论写入目标 change 的 `reviews/implementation-review-2026-08-21.md`，没有修改插件源码或 tasks checkbox；
32. 即使当前或后续全量旧测试全部通过，也只能证明兼容回归良好；只有 production call path、exact semantic graph、stable identity、immutable/verifier、Cache reconstruction 和 public/concurrency contract 都满足 specs，才能宣布 canonical cutover 完成。
33. 问题 14 的第二轮复审确认第一轮之后已有实质改进：LEGACY 默认、Ready false、Bytecode publisher provenance、任务重开为 `51/105`、parameter-aware stable key、StaticJIT unique match、block arena 和更丰富的 shadow Sema fixtures；因此当前应称为“诚实的 canonical typed AST migration platform / shadow semantic compiler”，而不是虚假 cutover，也仍不是 production compiler；
34. 第二轮 `SemaAuthority` 中间结果曾为 `15/17 PASS`，实现进程随后修正 nested switch break retained publication 与 property setter rewrite；最终 CanonicalAST `32/32`、Compiler `220/220`、TypedASTJIT CanonicalASTMigration `8/8`，但这些仍是 shadow/dump/legacy-compatible 证据，不代表 production authority 已切换；
35. 第二轮在 13:51 最新 Runtime DLL 上再次稳定复现 Canonical CodeGen funcdef/lambda teardown 访问违规：执行值正确，但 `Engine.Destroy()` 在 `asCObjectType::ReleaseAllFunctions` / `asCScriptEngine` funcdef/function-behaviour 清理附近崩溃；该 ownership/refcount 问题是 production CodeGen 的新增 Critical 前置门禁；
36. 第二轮正式报告位于目标 worktree `reviews/implementation-rereview-2026-08-21-second-pass.md`；结论仍为 Request changes，不归档、不勾选 section 10/13，不推倒现有 scaffold，建议按 R11 crash → Wave B remaining → arena/verifier → transactional CodeGen → public/snapshot → Cache/SourceManager → final cutover 的顺序继续。
37. 问题 15 的第三轮复审推翻了第 35 条的“当前时态”但保留其历史事实：R11 funcdef/lambda teardown crash 已在 16:14 快照修复，`Frontend.CanonicalAST 56/56` 覆盖组合与最小化生命周期；它现在是回归门禁，不再是当前第一阻断；
38. 第三轮新增确认 R04 的核心结构缺陷：`asCASTCollectFunctionRecords()` 没有把 `decl->body`、stmt/expr/literal/reference/cleanup/source-content 写入 per-function content hash，且忽略 profile；因此 pure body edit 可能错误复用旧 Cache sidecar；
39. 当前 sidecar encode/decode 仍是 textual dump + declaration skeleton，不是能恢复 body/reference/source/cleanup graph 的 pointer-free complete DTO，不能满足 ExactStartup 无 Parser/Sema reconstruction；
40. 第三轮 fresh Cache prefix 为 `5/7`，两个直接失败是测试仍匹配旧 key `F/H` 而实现返回 `F()/H()`；修 fixture 只能解决当前红项，不能关闭 body-less hash 与 incomplete decode；
41. 第三轮其他中间快照证据为 Frontend `56/56`、Compiler Canonical `37/37`、Module Snapshot `4/4`、HotReload `5/5`、Compiler full `225/225`、TypedASTJIT migration `8/8`、Standalone `21/21`；这些证明平台和回归质量提高，但 production `Build()` 仍由 `asCCompiler` 发布 Bytecode；
42. 第三轮正式报告位于目标 worktree `reviews/implementation-rereview-2026-08-21-third-pass.md`，仍为 Request changes；用户说明另一个 agent 仍在实现后已停止所有后续 build/test，因此报告严格限定为 16:14 中间快照，不是最终验收。
43. 问题 16 的第四轮复审继续给出 Request changes，并新增当前 production compatibility blocker：`ParseLambda()` 无条件把参数收进 `snParameterList` 且加入 `function` identifier，但 legacy `asCCompiler::ImplicitConvLambdaToFunc()` 仍按旧平铺 layout 计数/读类型；默认 LEGACY pipeline 的零参数和有参 lambda 都可能被错误匹配；
44. 第四轮认为 `2.8` 与 `13.5` 勾选过早：Verifier 仍不拒绝 skipped-nearer transfer target、expression cycle/multi-owner、required CALL/CONSTRUCT callee 缺失、CLEANUP destructor target 缺失和不正确 fallthrough next-case，并未覆盖完整 stable reference/cleanup plan；
45. 第四轮确认 qualified namespace action 缺口：Parser 在 `namespace A::B` 只读到 `A` 后就 push Sema context，Sema `WalkOne(snNamespace)` 也只转换第一个 identifier；当前 nested namespace 测试使用两层独立 declaration，不能证明 `A::B` 正确；
46. 第四轮确认 `as_tokendef.h` 重新启用 `interface` / `typedef` 会改变 accepted syntax 和 identifier set，与当前 OpenSpec “不改变语言行为”的 non-goal 冲突；若保留必须先显式修订 scope并补兼容/迁移证据；
47. 第四轮保存证据为 Verifier `13/13`、Frontend `63/63`、Compiler Canonical `37/37`、Transaction `3/3`、CodeGen `27/27`、Parser/SemaAuthority 最新 `61/61`、CanonicalAST `76/76`；这些数字来自实现者已有 JSON report，本轮未主动 build/test；
48. R09 Task 1 的 global rollback 是真实进展，但 successful canonical Generate 仍比正常新 function 注册路径多一次 `AddRefInternal()`，且没有 detached artifact / atomic installer；需要 success Generate→module reset→Engine teardown 的 refcount/registry gate；
49. 第四轮仍确认 R04/R05/R06/R01 未闭环：Cache 不含 body/profile complete identity且只能 decode declaration skeleton；public API mid-vtable/size negotiation 不安全；snapshot Acquire/publish 非原子；production Build 仍由 `asCCompiler` 发布；
50. 第四轮可保留 `2.4/13.4` arena+seal 与 scoped `2.6` type bridge closure，R11 teardown crash 也继续保持关闭；若重开 `2.8/13.5`，tasks 诚实计数应从 `56/105` 调整为 `54/105`；
51. 第四轮正式报告位于目标 worktree `reviews/implementation-rereview-2026-08-21-fourth-pass.md`，严格限定为 19:35 中间快照；另一个 agent 仍在修改源码，因此后续变化必须重新 point-in-time review；
52. 第四轮只写 review 和会话记录，没有修改插件实现、没有替实现者改 checkbox、没有运行 build/test。
53. “lambda 节点协议”更准确地指 Parser producer 与 legacy Compiler consumer 之间隐式的 AST child-layout contract，不是网络协议或公开 ABI；旧 consumer 通过 `firstChild/next`、node kind 和 child ordering 直接解释 tree；
54. 旧 lambda layout 将参数类型/修饰/名字平铺在 `snFunction` 下；新 layout 加入 `snIdentifier("function")` 并把真实参数收进 `snParameterList`；`ImplicitConvLambdaToFunc()` 仍只扫描直接 children，因此会把 `function` 标签当参数并跳过真实参数子树；
55. 零参数 lambda 会被错算为一个参数；单参数 lambda 可能数量偶合但跳过真实类型检查；多参数 lambda 通常数量不匹配；问题可能表现为错误接受/拒绝/诊断或后续 registration failure，而不一定立即崩溃；
56. 问题不在增量 Parser/Sema action 本身，而在新旧两个 consumer 并存时 producer 单边改 shape 且没有 compatibility adapter；迁移期优先应集中定义 dual-layout parameter adapter，或让 Sema action 使用独立 parameter payload；
57. 问题 17 的通俗表述是：“Parser 把参数放进了参数列表文件夹，但旧编译器不会打开这个文件夹，反而把前面的 `function` 标签当成一个参数。”
58. 截至问题 18 的当前 worktree，`asCScriptNode` 仍是 source build 的关键生产数据结构：Parser 创建完整 tree，Builder/legacy `asCCompiler` 直接消费，新 canonical Sema 也仍以 `ActOn*FromNode` 翻译它；不能现在删除；
59. `asCScriptNode` 是编译会话内、由 Parser `FMemStackBase` 承载的临时 syntax/grammar tree；`BuildCompileCode()` 结束后 parsers 被删除，运行期 VM 不把该 tree 当作 IR，`ScriptFunctionData` 也不长期保存 Parser node pointer；
60. 当前 `CANONICAL` pipeline 选择会触发 canonical Sema/AST 捕获，但 production `Build()` 仍进入 `BuildCompileCode()` 并由 legacy `asCCompiler` 产生现行 Bytecode；新 `asCBytecodeCodeGen(asCASTContext)` 仍主要由 Canonical AST tests 调用；
61. cutover 的首要目标是让 production Sema/Bytecode/StaticJIT/Cache/未来 LLVM consumers 不再读取 `asCScriptNode`，而不是立即要求源码中彻底删除这个 class；Parser recovery/testing node 是否最终保留应在 semantic consumer 归零后单独决定；
62. OpenSpec `10.3`、`10.6`、`13.2` 仍保持 open，分别要求 Parser node 降为 recovery input、production semantic-body consumer 归零，以及用真正 Sema environment 替代旧 syntax walk；
63. 问题 18 只进行了当前 worktree 的静态源码核验并更新本会话记录，没有修改 plugin/worktree 实现，也没有运行 build/test。

本文从此作为本次会话相关技术讨论的持续入口；后续结论应同时保持“源码证据”和“当时状态”两条边界。

---

## 2026-08-22 — 问题 19：Canonical Typed AST Compiler 第五轮实现复审

### 用户问题

> 在另一实现 agent 又工作了一段时间后，再次 review `refactor-as-canonical-typed-ast-compiler` worktree 的当前实现。

### 结论

第五轮仍为 **Request changes**，不能归档、不能切 production default。

但相对第四轮需要更新一个重要事实：显式选择 `CANONICAL` 的 `asCModule::Build()` 已经真正绕过 legacy `BuildCompileCode()`，把同一次 parse/seal 产生的 `asCASTContext` 交给 `asCBytecodeCodeGen::Generate()`。保存的 ProductionCodeGen `3/3`、Cutover `5/5`、Differential `2/2` 证明最小 `int F()` module 能经这条路径发布并执行。第四轮“CANONICAL module Build 仍由 `asCCompiler` 发布”的结论，对 2026-08-22 00:39 快照已不再成立。

新路由尚未达到 production completeness，并产生了更直接的 fail-open 风险：

- CodeGen 只收集有 body 的 function/method/constructor/destructor；列表为空时直接成功，因此 global-only、type-only、interface/enum/funcdef/import-only 等 module 可能 Build 成功却不安装声明；
- method/constructor/destructor 虽被收集，却没有设置 runtime `objectType`，并被统一提交到 module global function tables，支持子集内的成员函数可能被错误发布成全局函数；
- types、funcdefs、imports、namespace ownership、global initializer、generated lifecycle/layout 没有完整安装语义；
- public `CompileFunction()` 仍走 legacy Builder/Compiler，Cutover test 还明确认可“module Build 用 CodeGen、CompileFunction 用 Compiler”的混合 authority，与 OpenSpec 10.1/10.3/10.4/13.1 不一致；
- CodeGen artifact 在 Generate 阶段已经调用 `AllocateGlobalProperty()`、保留 function ID、`AddScriptFunction()`，仍不是 detached artifact + atomic install；
- 默认 LEGACY lambda node-layout 回归、Verifier、Cache DTO、snapshot 原子 lease、public ABI、Sema/SourceManager/stable identity 等既有阻断未关闭。

因此当前准确定位从第四轮的“isolated Bytecode CodeGen prototype”推进为：

> **已接入 opt-in production call path 的 canonical scalar Bytecode prototype + 仍在迁移中的 canonical AST/Sema platform。**

### 关键依据

1. `as_module.cpp:395-428` 在 CANONICAL 分支执行 parse → seal → take context → `asCBytecodeCodeGen::Generate()` → JIT/prepare/publish；LEGACY 分支仍执行旧 Builder stages。
2. `as_bytecode_codegen.cpp:1558-1567` 在没有 body-bearing function-like declaration 时直接返回成功；globals 的处理位于这个早退之后。
3. `as_bytecode_codegen.cpp:28-34` 收集 method/ctor/dtor；`1439-1478` 只填函数签名；`1624` 固定 module default namespace；`1517-1536` 把全部 functions 加入 global function tables，没有 member owner install。
4. `as_module.cpp:1930-1981` 的 public `CompileFunction()` 仍调用 `funcBuilder.CompileFunction()`。
5. `as_parser.cpp:1722-1807` 与 `as_compiler.cpp:11521-11570` 之间的 lambda child-layout 生产者/消费者协议仍不一致，而默认 pipeline 仍为 LEGACY。
6. Verifier 仍允许 required control/call/cleanup target 缺失、skipped-nearer target、expression ownership/cycle 和不完整 fallthrough semantics。
7. Cache wrapper 不读取传入的 `CanonicalAstBytes`，只 encode 空 TranslationUnit；fork sidecar 只恢复 declaration skeleton，function content hash 不含 body且忽略 profile。
8. Snapshot Acquire 是 raw-load 后 AddRef；publication 先 release previous 再 seal/allocate candidate，不能保证并发安全和 failed replacement 保留 last-good；Build 还在 snapshot publication 后才初始化 globals。
9. Public AST methods仍插在 module mid-vtable，view getters不尊重 caller `structSize`/`apiVersion`，ID也没有 snapshot identity。
10. 实现者保存的宽范围 Compiler `331/331` 报告生成于 00:20，早于 00:27 的新 production Build route，不能作为当前路由的 fresh broad regression evidence。

### 对当前决策的影响

- 更新此前“CANONICAL Build 尚未接入 production CodeGen”的当前时态：module Build 的最小真实路由现已存在；
- 保留“canonical compiler 尚未完成”的总体判断，原因从“没有 route”转为“route 不完整、可能成功漏装/错装、且不原子”；
- `Ready=true` 目前只能表示“存在一个最小 scalar route”，不能作为完整 compiler capability；
- 继续禁止默认切换和 archive；
- `2.8`、`13.5` 至少必须重开；`3.5`、`3.6`、`12.6` 也与当前事实不符，`6.7`、`7.6`、`8.4` 应按宽泛任务文字重新审计；
- 下一步优先级应是整模块 declaration preflight/fail-closed 和 legacy lambda 回归，而不是先扩大更多 opcode emission。

### 未决事项

- global-only/type-only/namespace/import/funcdef module 是完整安装还是整模块 fail-closed；
- member/constructor/destructor 的 owner、behaviour table、namespace 和 lookup 如何 transactionally install；
- global initializer、generated lifecycle/default/accessor/list factory 如何从 canonical AST 生成；
- `CompileFunction` 是迁到 canonical，还是显式修订 OpenSpec 接受独立 legacy capability；
- CodeGen detached artifact、Engine/module atomic installer 和 failure no-mutation 如何实现；
- Snapshot/Public ABI/Cache DTO/Sema authority/SourceManager identity 如何依序闭环；
- 真实 Hot Reload、generation、commandlet、Standalone 与 final All suite 的验收结果。

### 正式产物与操作边界

- 第五轮正式报告：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-fifth-pass.md`；
- 本轮只进行了静态源码核验、只读解析实现者保存的 JSON reports，并写入 review/讨论文档；
- 没有运行 build/test，没有修改 plugin 实现，没有更改 `tasks.md` checkbox。

### 当前决策账本追加

64. 第五轮确认 CANONICAL module `Build()` 已真实调用 `asCBytecodeCodeGen::Generate()`；此前“module Build 始终由 legacy Compiler 发布”的当前时态已被新实现推翻；
65. 保存的 ProductionCodeGen `3/3`、Cutover `5/5`、Differential `2/2` 证明最小 scalar route 成立，但不覆盖完整 declaration/lifetime/host surface；
66. 新路由在没有 body-bearing function-like declaration 时直接成功，可能让 global/type/interface/enum/funcdef/import-only module 成功但漏装；
67. method/ctor/dtor 当前没有正确 runtime owner install，可能被统一提交为 module global function，这是 fail-open semantic corruption blocker；
68. `CompileFunction()` 仍使用 legacy Compiler，当前测试认可混合 publisher，与现有 OpenSpec cutover contract 冲突；
69. extra `AddRefInternal()` 问题已关闭，但 CodeGen 仍直接修改 Engine/module，不是 detached artifact/atomic install；
70. 默认 LEGACY lambda layout、Verifier、Cache DTO、snapshot atomic lease、public ABI、Sema/SourceManager/stable identity blockers 继续存在；
71. OpenSpec mechanical 状态仍为 `56/105`；至少纠正 `2.8/13.5` 后是 `54/105`，其余过宽 checked tasks仍需审计，不能把该比例当 production readiness；
72. 第五轮正式判定仍是 Request changes，不归档、不切默认；优先修整模块 preflight/fail-closed，再修 legacy lambda 和 transaction；
73. 第五轮未运行 build/test、未修改 plugin 源码和 task checkbox，只写正式 review 与本会话持续记录。

---

## 2026-08-22 — 问题 20：Canonical Typed AST Compiler 当前整体进度

### 用户问题

> 现在整体进度怎么样了？

### 结论

截至 **2026-08-22 02:17（Asia/Shanghai）**，该 change 已经从“canonical AST scaffold + isolated CodeGen”推进到“opt-in CANONICAL module Build 能执行一批真实语言切片”的阶段。若必须用一个数概括，诚实的架构加权进度约为 **45%–50%**；它处在整体半程附近，但离 production default/归档仍明显较远，而且剩余部分包含 Sema authority、完整语言面、原子发布、Cache/Public ABI 等高风险工作，不能按线性工时理解。

用户随后要求只给一个百分比；本轮统一采用 **48%** 作为当前架构加权完成度。该数字衡量的是“距离完整 canonical production cutover”的综合进度，不是 `tasks.md` checkbox 的简单除法。

机械 checklist 仍是 `56/105 = 53.3%`。第五轮复审认为至少 `2.8/3.5/3.6/12.6/13.5` 不应保持 checked，`6.7/7.6/8.4` 也需严格复核；因此经过质量修正后的 checklist 大约是 **46%–49%**，与架构加权判断基本一致。

分层状态更有解释力：

| 层级 | 当前状态 | 粗略判断 |
| --- | --- | ---: |
| Baseline、ASTContext/arena、dump、测试骨架、文档 | 大体形成，仍有 Verifier/SourceManager 缺口 | `70%–80%` |
| Parser→Sema/canonical graph | action 覆盖扩大，但仍 post-walk `asCScriptNode`，不是 sole authority | `40%–50%` |
| Canonical Bytecode CodeGen | module Build 已接入；标量、控制流、部分 value/ref/lambda/global 可执行 | `30%–40%` 语言面 |
| Production cutover | opt-in module Build 已通；默认仍 LEGACY，CompileFunction/真实 host 路径未切 | `20%–30%` |
| Cache V2 / public AST / snapshot concurrency | 有 scaffold 和局部 tests，核心 DTO/ABI/atomic lease 未闭环 | `25%–35%` |
| LLVM readiness | high-level boundary方向正确，但 canonical semantics 尚不完整；LLVM 本身仍为本 change non-goal | 还不能进入正式 backend 实现 |

### 02:17 前新增的真实进展

- `asCBytecodeCodeGen` 已继续支持/验证 value object、temporary、named VALUE local、const global、非捕获 lambda IIFE、`&in`、`&out` 和 while `SUSPEND`；
- ProductionCodeGen 最新为 `11/11 PASS`，Cutover 在 `&out` 后仍为 `5/5 PASS`；
- 保存的 `d95-green10` Build 为 exit 0；
- 当前 code 已增加 `RegisterCanonicalScriptTypes()`，尝试把 method/ctor/dtor 绑定到 runtime `objectType`，Commit 只把 `objectType == 0` 的函数放进 global function tables；
- 第五轮看到的 `functionDecls == 0` 提前成功返回已经移除，types/globals 会在没有 function body 时继续处理；因此第五轮 F1 的两个具体实现点已部分修复，但 declaration completeness/owner correctness 仍无完整测试矩阵；
- `&in` 的 caller/callee ABI 用 `PSF` + `RDR4` 验证，`&out` 用 `PSF` + `WRTV4` 验证，并有 RED→GREEN 保存证据；
- tasks 明确保持 9.5、9.1、13.2、13.3、13.6、10.2、10.4 为 open，没有把 11 个生产切片虚标成完整语言面。

### 仍决定能否切 production 的关键剩余项

1. **完整语言面**：handles、capturing closures/funcdefs、containers/templates、imports、generated lifecycle/default/accessor/list factory、exception/cleanup、debug/coverage/timeout metadata 等；
2. **Sema sole authority**：当前仍从 `asCScriptNode` post-walk，backend 所需 exact call/conversion/lifetime/control facts尚未完全成为 immutable AST facts；
3. **CompileFunction 和真实 host purpose**：public `CompileFunction` 仍是 legacy Compiler，commandlet/Standalone/HotReload/generation tests 仍多为 helper aliases；
4. **Detached/atomic CodeGen**：emission 期间仍保留 Engine function slots并修改 registry，不是完整 detached artifact；
5. **Verifier**：required targets、skipped-nearer、expr ownership/cycle、cleanup/signature/stable refs 等 firewall 不完整；
6. **Snapshot/Public ABI**：Acquire/publish 原子性、last-good preservation、mid-vtable、caller size/version 和 foreign ID；
7. **Cache V2**：完整 pointer-free body DTO、source/profile/body hash 和 ExactStartup reconstruction；
8. **稳定 identity/SourceManager**：完整 owner/type/lambda identity 和 content-aware source remap；
9. **最终验证**：必须在 canonical CodeGen 真正覆盖生产语言面后重跑 focused、Standalone Debug/Release 和 All；现有大范围绿结果主要证明 legacy-compatible scaffold 没回归。

### 对当前决策的影响

- 当前不再只是实验性 isolated backend，已经有真实 opt-in module Build production route；
- 但 `Ready=true` 仍只能表示 binary 中存在该子集 route，不能解释为完整语言 ready；
- 默认必须继续保持 LEGACY，不能归档；
- 接下来继续做 9.5 语言切片是合理的，但必须并行保持 F1 declaration completeness、13.6 transaction、13.2 Sema authority等硬门禁，不能只靠增加 ProductionCodeGen 测试数量宣布 cutover；
- 整体工作量处在半程附近，剩余工作的架构风险和集成成本高于前半程。

### 当前决策账本追加

74. 02:17 快照的机械进度仍是 `56/105`，质量修正和架构加权后更接近 `45%–50%`；
75. CANONICAL CodeGen 的生产语言切片已扩到 ProductionCodeGen `11/11`：标量、部分 value/temporary/const-global/lambda/ref/suspend；
76. 第五轮 F1 的具体实现已有部分修复：移除 no-function 早退、注册 script types、绑定 objectType、member 不再无条件进入 global tables；但完整声明矩阵和 owner assertions 仍未完成；
77. section 10 仍只有 `1/9` checked，默认 LEGACY、CompileFunction legacy 和真实 host entry 未切，说明 production cutover 仍是低完成度层；
78. section 4+5 机械上只有 `4/17` checked，Sema authority仍是 compiler architecture 的主要剩余工作；
79. 9.5、9.1、13.2、13.3、13.6、10.2、10.4 保持 open 是正确的，11/11 的局部绿不能替代完整任务文字；
80. 当前最合适的管理表述是“基础平台已过半、最小生产链已贯通、完整 production compiler 尚未完成”，而不是“接近收尾”。

### 操作边界

本次进度回答只读取了最新源码时间、OpenSpec tasks/attachments 和实现者保存的 JSON reports；没有修改 worktree plugin/tasks，也没有主动运行 build/test。实现方在 02:17 仍处于活跃工作状态，因此这里是 point-in-time 状态，不是最终验收。

---

## 2026-08-22 — 问题 21：当前实现方向是否存在根本问题

### 用户问题

> 现在实现的方向问题不大吧？

### 结论

**架构大方向没有根本问题，不需要推倒重来。** 当前选择的主线——Parser/Sema 建立一份 sealed canonical typed AST，Bytecode/TypedASTJIT/未来 LLVM 等后端只消费这份高层语义事实，LEGACY 在迁移期间保留为 oracle/fallback，Cache/Public API 使用稳定 DTO/ID 而不是内部 pointer——是正确且适合本项目长期演进的方向。

当前风险主要是实现边界和推进顺序，而不是 canonical AST 这个总体选择。需要避免把以下临时做法固化成最终架构：

1. Sema 仍 post-walk `asCScriptNode` 时就过快扩大 CodeGen 语言面；这会让 backend 被迫补猜不完整的语义；
2. CodeGen/Build 内直接注册 runtime type/function/global，而没有先形成 complete detached module artifact 和 atomic activation transaction；
3. backend 从 `defaultArg` 字符串等 syntax residue 自行解释 initializer，而不是读取 Sema 已解析的 exact initializer expression/value；
4. `Ready=true` 只表示存在 opt-in 子集 route，却可能被误读为完整 compiler readiness；
5. 用窄范围 ProductionCodeGen 绿测试替代 Verifier、snapshot、Cache、public ABI、真实 host entry 和 full-language differential 门禁。

因此应保持当前代码和测试资产，在此基础上调整优先级：先让 canonical graph 成为完整语义权威，并补 detached/atomic publication 与 verifier firewall；随后继续扩大 CodeGen，最后切默认和删除 legacy/HIR consumers。

### 对当前决策的影响

- 不建议重写或放弃当前 canonical AST worktree；
- 不建议改成 AST 直接生成 LLVM IR，也不建议恢复独立长期 HIR 作为第二套语义权威；
- 建议保留当前 opt-in scalar/value/ref vertical slices作为验证资产；
- 接下来应把 Sema authority、module artifact transaction、Verifier、snapshot/ABI/Cache 提到和 9.5 CodeGen breadth 同等或更高优先级；
- “方向正确”不改变当前 `48%`、Request changes、LEGACY default 和不可归档的判断。

### 当前决策账本追加

81. 当前 canonical typed AST + multi-backend lowering 的总体架构方向正确，不需要推倒重来；
82. 主要偏差是 backend/activation 正在承担部分本应由 Sema/module transaction 冻结的职责，而不是 canonical AST 选型错误；
83. 应保留已完成 vertical slices，但避免在 Sema authority、detached artifact、Verifier、snapshot/Cache/Public ABI 未闭环前把局部 CodeGen 绿测试解释为 production readiness；
84. 方向判断不改变当前单值进度 `48%`，也不改变 Request changes、LEGACY default 和禁止归档/默认切换的结论。

---

## 2026-08-22 — 问题 22：Canonical Typed AST Compiler 第六轮实现复审

### 用户问题

> 另一实现 agent 又持续工作了很久，再次 review `refactor-as-canonical-typed-ast-compiler` worktree 的当前实现。

### 结论

第六轮仍为 **Request changes**，不能归档、不能切 production default，也不能把 `Ready=true`、ProductionCodeGen `25/25` 或 checklist `56/105` 解读为完整 compiler readiness。

相对第五轮有显著的真实进展：

- 第五轮的 no-function early success 已移除，canonical CodeGen 会继续处理 type/global；
- method/constructor/destructor 已尝试绑定 runtime `objectType`，`Commit()` 不再把所有 member 无条件加入 global function table；
- positive verifier error code 被 Build 当成功的问题已修正；
- production CodeGen 切片扩到 `25/25 PASS`，覆盖 value/temporary/ref/suspend/host funcdef/`array<int>`/import/generated accessor/destructor/default ctor/list factory/capture/overload call；
- 最新 Parser→Sema 相关保存证据为 SemaAuthority `170/170`、CanonicalAST `210/210`、Compiler `398/398`（397 success + 1 succeeded-with-warning）。

但本轮的核心判断是：实现宽度增长快于语义、安全性和 ABI 证明，部分“已支持”实际上是把 `int` fixture 的实现推广成通用路径，形成 silent corruption 风险：

1. `RegisterCanonicalScriptTypes()` 把所有 direct-TU script class 注册成 `asOBJ_VALUE | asOBJ_NOINHERIT`，而 legacy Builder 只有 `struct` 是 value；普通 script class 是 ref + implicit handle；
2. canonical class alignment 固定为 4，property type/add 失败会静默跳过，最终 size不按最大 property alignment收尾；nested namespace class也未处理；
3. 同名 type 已存在时注册逻辑直接跳过，method owner查找又按裸名 fallback到 Engine type；随后 `FillFunctionSignature()` 会修改 constructor/destructor/method behaviour table，可能污染 host或其他 module type；
4. integer global initializer 使用 `atoi(defaultArg)` 并经 `int*` 固定写 32 bit；表达式、hex、enum/cast/named constant和 int64/uint64 都可能静默错误；
5. generated accessor 固定 `RDR4/WRTV4` 和单 dword return；list factory固定 `4 + 4*N` buffer与 4-byte element；现有 tests恰好只有 `int Value` 与 `{repeat int}`；
6. capture set由 CodeGen重新遍历 AST 推断，而不是 Sema显式 capture plan；所有 lambda共用一个全局去重数组，两个 lambda捕获同一外部变量时第二个会得到零 capture；
7. type/global/import/function/object behaviour 已在 emission完成前写入 live Engine/module，`Abandon()` 不撤销 type/import/behaviour/method table，因此不是 detached artifact/atomic install；
8. Sema action数量虽增加，但 unresolved call/member/assign/index/unary/binary/init-list/lambda等仍大量默认 `int`；sealed graph可能携带 placeholder type，而非 exact semantics；
9. 默认 LEGACY lambda producer/consumer child-layout 回归仍未修复，当前 `Compiler 398/398` 没有覆盖缺失的 legacy lambda→funcdef compatibility fixture；
10. Verifier、Cache DTO、snapshot publication、public ABI、CompileFunction、SourceManager和完整 stable identity等第五轮 blocker没有实质变化。

### 对 OpenSpec 状态的影响

- 机械 checklist仍为 `56/105`；
- 至少应重新打开 `2.8`、`3.5`、`3.6`、`12.6`、`13.5`，纠正后为 `51/105`；
- `tasks.md` 一处写 CALL/CONSTRUCT missing callee 是“Hard no”，另一处勾选 13.5并写“CALL-without-callee not required”，与 capability spec要求拒绝 unresolved required stable target直接冲突，因此 12.6 的 reconcile声明不成立；
- 若严格按原文重开 Cache/generation/orchestration 的 `6.7`、`7.6`、`8.4`，则为 `48/105`；
- `9.1`、`9.5`–`9.7`、section 10未闭环项和 `13.1`–`13.3`、`13.6`–`13.12` 保持 open 是正确的。

### 修复优先级

1. 先冻结/收紧当前只对 int成立的泛化 surface：class flags/layout/collision、global initializer、accessor/list ABI、capture；
2. 修复默认 LEGACY lambda layout compatibility；
3. 让 Sema显式产出 exact type/call/conversion/capture/lifetime/control/init facts，禁止 unresolved默认 int后 seal；
4. 建立 complete detached module artifact 与 atomic Engine/module activation，并做全 failure injection no-mutation matrix；
5. 再依序闭环 Verifier、snapshot/public ABI、Cache DTO、CompileFunction/真实 host entry和 final differential/Standalone/All。

当前不需要推倒 canonical typed AST 总体架构；应保留已有 vertical slices 和 action tests，但必须纠正 semantic/type/transaction boundary 后再继续扩大语言面。

### 正式产物与操作边界

- 第六轮正式报告：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-sixth-pass.md`；
- point-in-time：2026-08-22 08:01:55（Asia/Shanghai）；parent/plugin HEAD 仍分别为 `fd16e5b...` / `ed22fbdf...`，实现全部位于 dirty worktree；
- 本轮只做静态源码核验、解析实现者保存的 JSON reports，并写 review/讨论记录；没有运行 build/test，没有修改 plugin 实现，没有修改 `tasks.md` checkbox。

### 当前决策账本追加

85. 第六轮确认 CodeGen/Sema breadth 有显著真实增长，最新保存证据为 ProductionCodeGen `25/25`、Cutover `5/5`、SemaAuthority `170/170`、CanonicalAST `210/210`、Compiler `398/398`；
86. 第五轮的 no-function early success 与 member无条件 global发布已被局部修正，但新增 type registration暴露了更严重的 class/ref-vs-value、alignment、property drop和同名 host type污染风险；
87. `atoi(defaultArg)` + `int*` 不是 canonical initializer lowering，必须由 Sema exact initializer/constant plan替换；
88. generated accessor与 list factory当前只证明 int形态，固定 4-byte ABI不得解释为通用 feature completion；
89. CodeGen module-global capture去重会让第二个捕获同一变量的 lambda丢 capture；capture plan应由 Sema逐 lambda显式冻结；
90. CodeGen transaction仍遗漏 type/import/object behaviour/method table rollback，不能关闭 9.1/13.6；
91. Sema独立 action增多不等于 sole authority；大量 unresolved/default-int路径说明 sealed graph仍可能包含猜测语义；
92. legacy lambda、Verifier、Cache、snapshot/public ABI、CompileFunction和SourceManager blockers继续存在；
93. 第六轮正式判定仍为 Request changes；不归档、不切默认，先修 exact semantic/type/transaction boundary；
94. 第六轮没有运行 build/test、没有修改 plugin或 task checkbox，只写正式 review与本会话持续记录。

---

## 2026-08-22 — 问题 23：Canonical Typed AST Compiler 第七轮实现复审

### 用户问题

> 实现方继续工作后，再次 review `refactor-as-canonical-typed-ast-compiler` worktree 的当前实现。

### 结论

第七轮仍为 **Request changes**：不能归档，不能把 CANONICAL 切为默认，也不能把 `Ready=true`、ProductionCodeGen `33/33`、CanonicalAST `251/251` 或 checklist `56/105` 解释成完整 compiler ready。

这轮有一批真实关闭项：

- class/struct runtime flags 已按 `asAST_TRAIT_VALUE` 分成 ref+implicit-handle class 与 value struct；
- global `40+1`、`0x29` 的窄 int fixture 已经改为 Sema常量求值和按 storage width写入；
- accessor/list的 int64/double 8-byte slice已落地；
- sibling lambda捕获同一外部变量的 module-global去重 bug 已关闭，capture列表开始由 Sema逐 lambda持有；
- 默认 LEGACY lambda的 `snParameterList` 消费协议已修复，0/1参数 build+execute保存结果为 `2/2`；
- after-name function declaration + incremental Param intern 的 constructor overload/in-flight identity回归已关闭；13:07 enumerator action之后最新保存结果为 Build exit 0、SemaAuthority `203/203`、CanonicalAST `251/251`。

但第七轮也确认了若干仍会产生 silent wrong code/memory corruption 的 Critical 路径：

1. canonical accessor/list helper只有 4/8-byte分支：`bool/int8/int16`会被 `RDR4/WRTV4` 越界读写，12/16-byte value会被 `RDR8/WRTV8` 截断；
2. handle property仍做 raw pointer copy，没有 AddRef/Release；value-object list element没有 construct/assign/destroy；当前 nullptr/double fixtures不能证明对象 lifetime；
3. script type registration仍固定 alignment 4、只扫描 direct-TU class、静默跳过 property失败、按裸名复用 Engine type，并在 emission完成前修改 live registry/behaviour/method table；
4. global int64/uint64在 Sema中仍通过 `Format("%d", (int)value)`截断；generated member default仍取表达式第一个数字并用 `atoi()`，例如 `40+1` 可被生成为 `40`；
5. CodeGen仍不是 detached artifact/atomic install，失败回滚不覆盖 type/import/object behaviour/method table；
6. unresolved call/member/index/unary/binary等仍可冻结为合法 `int` placeholder，Verifier又允许 CALL/CONSTRUCT缺失 callee；
7. snapshot/public ABI/CompileFunction、Cache V2 body DTO、Verifier firewall和 SourceManager content authority没有实质变化。

此外，13:02 的参数 replay去重虽然解决了本轮两条红测，但 `ActOnStartParamDecl()` 当前只按 owner+参数名复用已有 Param。这会把“同一参数被 incremental action与 WalkOne重放”与“源码真的写了两个同名参数”混在一起，后者可能绕过 `ActOnParamDecl()` 的 `duplicate-param` 诊断。应改为按 same source range/token identity去重。

### 对当前进度与方向的影响

- canonical typed AST + multi-backend lowering 的架构方向仍正确，不需要推倒；
- 当前已是“有真实 opt-in Build route和大量 vertical slices的 compiler prototype”，不是只画结构；
- 但 production replacement readiness仍约 **35%–40%**；若只看架构资产，可说约 `50%`。两个尺度必须分开；
- checklist `56/105`仍含 false-complete；按第六/七轮明确不成立项严格审计，记录诚实度更接近 `48/105`；
- 下一步优先顺序应是：收紧危险 support gate → 统一 typed initializer plan → 完成 module artifact transaction → Sema exact/fail-closed → Verifier → snapshot/public ABI/Cache/SourceManager/CompileFunction → 最后扩大完整语言面和切默认。

### 正式产物与操作边界

- 第七轮正式报告：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-seventh-pass.md`；
- point-in-time：2026-08-22 13:09:38（Asia/Shanghai）；parent/plugin HEAD仍为 `fd16e5b...` / `ed22fbdf...`，parent/plugin dirty paths为 `20` / `108`；
- reviewer没有主动运行 build/test，没有修改 plugin实现或 `tasks.md` checkbox；只读核验实现者保存报告，并写正式 review与本会话记录。

### 当前决策账本追加

95. 第七轮确认 class-vs-struct flag、sibling capture全局去重、默认 LEGACY lambda 0/1参数协议和增量 Param in-flight identity等具体回归已关闭；
96. 最新 exact-current保存证据为 Build exit 0、SemaAuthority `203/203`、CanonicalAST `251/251`；较早 broad Compiler `437/437` 与 ProductionCodeGen `33/33` 有价值，但早于最新 Sema/Parser变更；
97. accessor/list的 8-byte slice落地不代表完整 width ABI：当前 1/2-byte会被4-byte越界读写，>8-byte会被8-byte截断；
98. non-null handle ownership与 value-object construct/copy/destroy仍未实现，nullptr/double fixtures是窄证明；
99. class type registration仍有 alignment 4、property静默丢弃、direct-TU-only、裸名 host collision和 live registry提前污染风险；
100. global initializer虽不再由 CodeGen直接 `atoi(source text)`，但 Sema `%d/(int)`仍截断 int64/uint64；generated member default仍是 first-number + `atoi()`；
101. CodeGen transaction仍不撤销 type/import/object behaviour/method table，9.1/13.6不能关闭；
102. unresolved→int与 CALL-without-callee继续说明 Sema/Verifier authority未完成，2.8/13.5/12.6仍不诚实；
103. 参数 replay去重必须按 source identity而非 bare name，否则真实 duplicate-param可能被吞掉；
104. Cache body DTO、snapshot atomic lease、public ABI size/version、CompileFunction canonical parity与 SourceManager content truth仍是 blocking work；
105. 当前建议区分“架构资产约50%”与“production替换ready约35%–40%”，避免把 checklist或测试数量当单一完成度；
106. 第七轮最终判定仍为 Request changes；方向正确、不推倒，但默认继续 LEGACY，不归档；
107. 第七轮没有主动 build/test，没有修改 plugin或 task checkbox，只写 review和会话持续记录。

---

## 2026-08-22 — 问题 24：Canonical Typed AST Compiler 第八轮实现复审

### 用户问题

> 实现方继续工作后，再次 review `refactor-as-canonical-typed-ast-compiler` worktree 的当前实现。

### 结论

第八轮仍为 **Request changes**：不能归档，不能把 CANONICAL 切成默认，也不能把 Parser action数量、`Ready=true`、CanonicalAST前缀全绿或 checklist `56/105`解释成完整compiler ready。

相对第七轮，本轮有真实Frontend进展：

- Enumerator独立action落地；保存结果SemaAuthority `203/203`、CanonicalAST `251/251`；
- DeclRef剥离到 `InternParsedDeclRef()`；保存结果SemaAuthority `205/205`、CanonicalAST `253/253`、Compiler合计443且0失败；
- Call剥离到 `InternParsedCall()`；保存结果SemaAuthority `206/206`、CanonicalAST `254/254`、Compiler合计444且0失败；
- 截止快照时 `InternParsedExprTerm()` 已开始接入，说明实现方继续减少父kind直接intern的FromNode路径。

测试数字需要精确表述：DeclRef Compiler JSON是`442 success + 1 succeededWithWarnings`，Call Compiler是`443 success + 1 succeededWithWarnings`；不是所有用例都处于纯Success。warning来自既有TypedSemanticIR SourceProvenance integration。13:28–13:30的ExprTerm源码/测试修改晚于13:25–13:26的Call reports，因此当前WIP没有exact-current保存验证。

本轮最严重的新问题是成员调用action协议：

1. `ParseExprPostOp()`解析`.`后的`Get(args)`时会进入`ParseFunctionCall()`；
2. `ParseFunctionCall()`在receiver未知时已经调用`ActOnParsedExpr(snFunctionCall)`；
3. Sema先创建一个receiver-less free CALL；找不到free callee时仍创建合法int placeholder CALL；
4. 外层ExprTerm完成后才以receiver再次创建正确`T::Get()` CALL；
5. 错误CALL留在arena，Verifier不检查expression reachability，也允许CALL缺callee；
6. 正确member CALL又同时把receiver放在CALL children、`literalBits` side-channel和ExprTerm sequence中；CodeGen sequence先执行receiver，`EmitCall()`遍历children再执行一次，随后按`literalBits`还会执行一次。`Make().Method()`一类side-effectful receiver可能被多次求值。

现有member测试只断言正确callee substring存在，不统计所有CALL、不拒绝orphan，也不执行side-effectful member receiver。CodeGen中已经出现“跳过Parser产生的receiver-less CALL”的特殊分支，这说明backend正在补猜frontend污染；未来LLVM backend不能复制这种模式。

本轮还确认：

- scoped `Game::F()` 的CALL range从`Game`开始，但查重key使用`F`的identifier offset，Parser action与后续replay不能匹配，会生成重复CALL；
- unresolved CALL被去重逻辑刻意排除，replay必然再生成invalid CALL；
- 一般expression去重只按kind+file+begin offset，忽略end/owner/semantic role并拒绝offset 0，不是可靠action identity；
- `ConstructFromCallee()`把class和struct构造结果一律标成VALUE_OBJECT，与刚修好的class ref+implicit-handle runtime descriptor冲突；
- member overload精确匹配失败后，仍按第一个同名同参数数量method fallback，可把ambiguous/no-viable call静默绑定到声明顺序中的第一个；
- `ActOnDeclRefExpr()` unresolved仍创建int lvalue；unresolved→int问题未关闭；
- Param和Enumerator都只按owner+bare name复用，真实duplicate declaration可被当成incremental replay吞掉。

### 第七轮阻断项状态

`as_bytecode_codegen.cpp`、Verifier、Cache sidecar、snapshot/public view和SourceManager核心文件本轮未修改，因此以下问题全部继续存在：

- type registration固定alignment 4、direct-TU-only、property失败静默跳过、裸名host collision和live registry提前污染；
- accessor/list对1/2-byte越界读写、>8-byte截断，non-null handle无AddRef/Release，value-object list无完整lifetime；
- global int64/uint64经`%d/(int)`截断，generated member default仍first-number+`atoi()`；
- CodeGen不是detached artifact+atomic install，失败不能撤销type/import/behaviour/method table；
- Verifier允许missing callee/target、orphan/duplicate expr和不完整cleanup/signature；
- Cache V2不是完整body DTO，snapshot publish/acquire/public ABI、CompileFunction canonical parity和SourceManager content identity未闭环。

### 对当前方向和进度的影响

canonical typed AST + multi-backend lowering方向仍正确，不应推倒，也不应改成legacy AST直接发LLVM。问题在于当前过渡实现仍是：

```text
asCScriptNode多阶段replay
   → arena扫描猜测复用
   → unresolved默认int
   → backend跳过可疑节点
```

目标应是：

```text
Parser action identity/semantic operands
   → Sema pending→complete exact plan
   → Verifier唯一ownership+required facts
   → sealed snapshot
   → Bytecode / TypedASTJIT / future LLVM
```

当前建议区分：

- mechanical checklist：`56/105 = 53.3%`，仍有false-complete；
- 架构资产：约`50%–52%`；
- production替换ready：仍约`35%–40%`。

新增action资产不应让production readiness显著上调；本轮反而要求重审checked 9.4，因为ordinary/member call lowering还没有single-evaluation和干净call plan。

### 修复优先级

1. 先修member call action timing与receiver single-evaluation，增加`Make().Method()`执行trace和无orphan断言；
2. 用明确source/action identity替换arena扫描去重，覆盖scoped/unresolved/reparse/offset-zero；
3. 删除member same-arity-first fallback与unresolved→int，让class/struct construction产生exact type；
4. 完成Verifier expression ownership、required callee/target/type firewall；
5. 收紧危险CodeGen支持门，再闭环typed initializer和module atomic transaction；
6. 最后处理snapshot/public ABI/Cache/SourceManager/CompileFunction、完整语言面和默认切换。

### 正式产物与操作边界

- 第八轮正式报告：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-eighth-pass.md`；
- point-in-time：2026-08-22 13:32:53（Asia/Shanghai）；parent/plugin HEAD仍为`fd16e5b...`/`ed22fbdf...`，dirty paths为`20`/`108`；
- reviewer没有主动运行build/test，没有修改plugin实现或`tasks.md` checkbox；只读核验源码/保存reports并写review与持续讨论记录。

### 当前决策账本追加

108. Enumerator、DeclRef、Call dedicated action/intern peel是真实Frontend进展，保存基线已增长到SemaAuthority `206/206`、CanonicalAST `254/254`；
109. Compiler保存结果应精确写为Call `443 success + 1 warning + 0 failed`，不是纯`444/444 PASS`；ExprTerm WIP晚于该报告，当前缺exact-current验证；
110. member `ParseFunctionCall()`在receiver未知时先创建free/unresolved CALL，外层ExprTerm再创建member CALL，错误节点会留在arena；
111. receiver同时出现在sequence、CALL children和`literalBits`，当前CodeGen可多次求值side-effectful `Make().Method()` receiver；
112. scoped call range与identifier-offset查重key不一致，unresolved call又被排除在去重外，两者都会产生重复canonical nodes；
113. `FindExistingExpr()`按kind+source begin扫描arena不是稳定action identity，也不覆盖offset 0、owner、range end或semantic role；
114. `ConstructFromCallee()`仍把class/struct一律标成VALUE_OBJECT，和class ref runtime descriptor冲突；
115. member overload失败后same-name+same-arity first fallback以及DeclRef/Call unresolved→int继续违反exact/fail-closed Sema contract；
116. Param/Enumerator bare-name复用会吞真实duplicate declaration，必须按source/action identity区分replay；
117. CodeGen宽度/lifetime/type layout/initializer/transaction和Verifier/Cache/snapshot/public ABI/CompileFunction/SourceManager blockers本轮均未关闭；
118. 当前架构方向仍正确，但production readiness仍约35%–40%，默认继续LEGACY，不归档，不开始正式LLVM backend；
119. 第八轮没有主动build/test、没有修改plugin或task checkbox，只写正式review和会话持续记录。

---

## 2026-08-22 — 问题 25：距离切换到新版 Canonical Typed AST 还差什么

### 用户问题

> 现在距离切换我们的新版的 AST 还差什么？

### 先区分两种“切换”

这个问题有两个不同目标，距离差别很大：

1. **AST 构建/保留切换**：每次 source build 都生成、Seal并可选保留新版 canonical AST，但生产 Bytecode仍可暂时由legacy `asCCompiler`产生；
2. **完整 production compiler切换**：新版AST成为唯一语义权威，生产Bytecode只由`asCBytecodeCodeGen`从同一sealed snapshot生成，所有入口切换，旧semantic AST/HIR路径不再参与production decision。

第一种已经相对接近；第二种仍不能翻默认开关。当前机械checklist为`56/105 = 53.3%`，但真正production cutover readiness仍约`35%–40%`。剩余工作不是“再迁几个AST节点”，而是若干必须同时成立的安全门槛。

### 问题 24 后的最新进展

实现方已直接修复第八轮F1的Frontend部分：

- `.` postfix中的`ParseFunctionCall(false)`不再在receiver未知时创建free/unresolved CALL；
- ExprTerm取得receiver后才建立member call；
- member postfix Sequence不再保留receiver前置part；
- 保存结果：SemaAuthority `214/214`、CanonicalAST `262/262`、Frontend CanonicalAST `85/85`；
- Verifier/body owner修复保存结果为Verifier `16/16`、Compiler CanonicalAST `261/261`。

因此第八轮指出的“receiver-less orphan CALL”Frontend污染已有针对性修复。但真正执行层single-evaluation仍未关闭：新增`CanonicalMemberPostfixCallEvaluatesReceiverOnce`测试当前保存结果为`4 success / 1 failed`，失败点是`Make().Get()`没有得到期望trace `1,2`。CodeGen已尝试复用CALL children里已有receiver offset，但当前最新保存运行仍是RED。

第八轮其余三个Sema问题仍可在当前源码中看到：

- scoped call仍用identifier offset与CALL range begin查重，`Game::F()` identity不一致；
- `ConstructFromCallee()`仍把class/struct一律intern为`asAST_TYPE_VALUE_OBJECT`；
- member overload精确匹配失败后仍有same-name + same-arity first fallback。

### 距离完整切换还差七道硬门槛

#### 1. Frontend/Sema必须成为唯一且exact的语义权威

当前Parser action和dedicated intern已覆盖大量声明、表达式和控制流，最近增长到SemaAuthority `214/214`，这是真实资产。但仍未达到cutover标准：

- Sema仍大量从`asCScriptNode`递归提取语义，Parser node还不是“仅grammar/recovery输入”；
- scoped/unresolved call identity仍不稳定；
- class/struct construction type仍冲突；
- member same-arity fallback仍可能选择错误overload；
- unresolved DeclRef/Call等仍可退化为合法`int`；
- Param/Enumerator replay仍需完整source/action identity；
- conversion、lifetime、cleanup、call route、control target和initializer必须全部成为sealed AST中的required facts。

达到该门槛的标准不是“dump里能找到正确substring”，而是旧syntax walk被扰动/移除后，新Sema仍能独立产生完整、唯一、exact graph。

#### 2. Single-evaluation与lifetime plan必须在AST和CodeGen中真实执行

当前5.4已有OpaqueValue/Sequence等显式节点和dump，但OpaqueValue CodeGen一度只是passthrough；最新`Make().Get()`执行测试仍RED。切换前至少需要：

- receiver、index base、compound mutation target、named/default/hidden argument等只求值一次；
- temporary/materialization/cleanup、handle ownership、value object copy/move/destroy、return/transfer cleanup是显式plan；
- `try/catch`继续按当前语言边界明确拒绝，不得出现半支持；
- Bytecode与未来LLVM都只执行该plan，不重新猜测求值顺序或lifetime。

#### 3. Canonical Bytecode CodeGen必须覆盖当前production语言面

CANONICAL module `Build()`已经真实调用`Generate()`，ProductionCodeGen已有约`33/33` vertical slices；这证明链路成立，但不是完整语言面。仍缺或未证明的核心包括：

- 1/2-byte与大于8-byte value的正确load/store；
- non-null handle AddRef/Release；
- value-object list/accessor/generated bodies；
- containers/templates；
- stored capturing closures、delegates/funcdefs；
- imports和完整native/member/mixin/property ABI；
- globals/generated lifecycle/default initializer；
- exception/suspend、debug、coverage、timeout、安全点和metadata parity；
- 完整active SDK/script corpus differential。

任何未支持shape必须整模块fail-closed，不能Build成功后静默截断、越界或丢lifetime。

#### 4. CodeGen必须变成detached artifact + atomic install

当前type/import/global/function ID/object behaviour/method table仍会在完整emission结束前写入live Engine/module state；失败回滚不完整。切换前必须做到：

```text
sealed AST
   → detached module artifact
   → 完整emit/relocate/verify
   → 一次no-fail activation
```

或者建立覆盖所有live mutation的transaction journal。每个failure injection point都必须证明Engine/module/type/import/behaviour/method/global/function状态不变，并保留last-good generation。

#### 5. Verifier、Snapshot、Public ABI、Cache和SourceManager必须闭环

最近Verifier增加safe-point、skipped-nearer、default/fallthrough和body-owner检查是进展，但仍需要按production firewall重新审计：

- expression唯一owner/reachability/cycle；
- CALL/CONSTRUCT/DeclRef required target和signature/receiver/arg role；
- cleanup/lifetime required facts；
- snapshot publish/acquire atomic retain、failed candidate保留last-good；
- public API移出mid-vtable或采用兼容extension，尊重caller `structSize/apiVersion`并校验snapshot domain；
- Cache V2保存完整pointer-free body DTO，ExactStartup可不跑Parser/Sema恢复同一verified AST；
- SourceManager logical remap校验content identity；
- stable key覆盖module/namespace/type/signature/lambda/source/profile。

#### 6. 所有生产编译入口必须切到同一pipeline

当前真正接入的是CANONICAL module `Build()`的subset route；以下仍未完成统一：

- primary source build；
- Hot Reload；
- public `CompileFunction()`，目前仍由legacy Compiler发布；
- generation/StaticJIT；
- commandlet；
- Standalone；
- Cache restore后的canonical snapshot与CodeGen provenance。

每个入口都必须证明Bytecode来自同一sealed AST，而不是仅设置CANONICAL enum后仍执行legacy Bytecode。

#### 7. 必须在真实canonical provenance下完成最终回归

已有All `3632/3632`、Standalone `21/21`等结果主要证明当前legacy-compatible baseline没有回归，不能作为新版compiler切换证据。最终需要：

- canonical-vs-legacy独立Engine differential，覆盖active SDK和项目Script corpus；
- focused SDK、Cache、HotReload、StaticJIT、Debugger、CodeCoverage；
- Standalone Debug/Release；
- All suite；
- failure/no-mutation、concurrency、small-public-view、foreign-ID等adversarial matrix；
- 默认开关翻转后仍保留一个明确、可逆的LEGACY opt-out，直到稳定期结束。

### 推荐采用三阶段切换

不要一次性把“构建新AST”“新CodeGen”“删除旧路径”绑在一个开关上：

```text
阶段 A：Canonical AST always-built / verified
  - 每次编译都生成并Seal新版AST
  - production Bytecode暂时仍可LEGACY
  - 做shadow diff、snapshot/cache/public observer验证

阶段 B：Canonical CodeGen opt-in / supported-module dogfood
  - 只有完整支持且Verifier通过的module使用新CodeGen
  - unsupported整模块fail-closed或明确回到LEGACY
  - 收集真实Hot Reload/Cache/Editor运行证据

阶段 C：Canonical default
  - Sema sole authority
  - full-language CodeGen + atomic activation
  - 所有入口与最终测试通过
  - 默认翻到CANONICAL，LEGACY作为暂时可逆opt-out
```

当前处于阶段A后半段、阶段B早中期：AST/测试/opt-in Build route已经真实存在，但阶段A的exact authority/Verifier/持久化边界和阶段B的full-language/atomic install都还没有完成，因此不能进入阶段C。

### 最短关键路径

如果目标是尽快安全切换，而不是继续横向增加fixture，优先顺序应是：

1. 关闭当前`Make().Get()` eval-once RED；
2. 修F2 scoped/unresolved identity、F3 class construction type、F4 same-arity fallback与unresolved→int；
3. 完成5.7/5.8/5.9 exact lifetime/full-language Sema与Verifier required-fact gate；
4. 收紧危险CodeGen shape并完成full-language lowering；
5. 完成detached artifact + atomic activation；
6. 闭环snapshot/public ABI/Cache/SourceManager/CompileFunction；
7. 统一所有host entry并在真实canonical provenance下跑focused/Standalone/All；
8. 最后翻默认开关，暂时保留LEGACY opt-out。

### 当前决策账本追加

120. “切换新版AST”必须区分always-build/retain AST与完整production compiler cutover；前者相对近，后者仍约35%–40% ready；
121. 第八轮F1 receiver-less orphan CALL的Frontend部分已修复，保存结果为SemaAuthority `214/214`、CanonicalAST `262/262`、Frontend `85/85`；
122. 真正`Make().Get()` single-evaluation执行测试当前仍RED，保存结果`4 success / 1 failed`，因此5.4和member call CodeGen不能关闭；
123. F2 scoped/unresolved call identity、F3 class/struct construction type和F4 member same-arity fallback仍存在；
124. Sema sole authority的标准是旧syntax walk被移除/扰动后仍产生完整exact graph，不是dump substring数量；
125. 新CodeGen必须闭环完整语言面、exact ABI/lifetime和unsupported fail-closed，当前约33个vertical slices只证明链路；
126. type/import/global/function/behaviour必须通过detached artifact + atomic activation发布，当前partial live mutation仍阻止切换；
127. Verifier、snapshot atomic lease、public ABI、Cache DTO、SourceManager和stable identity是AST跨代/嵌入/缓存切换门槛；
128. public `CompileFunction`、Hot Reload、generation、commandlet和Standalone必须和module Build使用同一canonical provenance；
129. 当前All/Standalone大范围绿主要是legacy baseline证据，最终必须在真实canonical CodeGen默认路径下重跑；
130. 推荐三阶段切换：A always-built verified AST，B opt-in supported-module CodeGen，C canonical default；当前位于A后半段/B早中期；
131. 最短关键路径是eval-once→F2/F3/F4→exact lifetime/full Sema→full CodeGen→atomic install→snapshot/cache/ABI/entrypoints→真实canonical final gates；
132. 默认开关只能在阶段C翻转，并应暂时保留明确、可逆的LEGACY opt-out。

---

## 2026-08-22 — 问题 26：第九轮复审 `refactor-as-canonical-typed-ast-compiler`

### 用户问题

> 再review下。

### 复审结论

本轮仍是 **Request changes**，不能归档、不能默认CANONICAL、不能删除LEGACY/HIR。不过相对第八轮已经有一组明确的实质进展，production cutover readiness可由约`35%–40%`上调到约`40%–45%`。

最重要的变化是：第八轮F1–F5已经不能原样继续列为未修复。

- `.` postfix使用`ParseFunctionCall(false)`，receiver未知时不再创建receiver-less orphan CALL；
- `Make().Get()` canonical execute已从`4/5` RED变成`5/5` GREEN，trace为`1,2`，该具体single-evaluation路径已关闭；
- scoped/unresolved CALL按完整begin/end range去重，支持offset 0和unresolved replay；
- construction type已区分script class的reference/implicit handle与struct的value semantics；
- script member同名同arity fallback已删除，native template method先实例化subtype再ranking；
- Param/Enumerator只复用same owner+same range，distinct-range duplicate会保留并诊断；
- CANONICAL `asCModule::Build()`已经真实执行`SealCanonicalAST()`和`asCBytecodeCodeGen::Generate()`，不再只是把legacy bytecode标为canonical。

### 本轮时间点与保存证据

- point-in-time cutoff：2026-08-22 16:54:26（Asia/Shanghai）；
- parent/plugin HEAD：`fd16e5b...` / `ed22fbdf...`；dirty paths仍为`20`/`108`；
- reviewer没有主动运行build/test，没有改plugin实现或`tasks.md`checkbox；
- exact-current保存Build：`wave-b-54-1070` exit `0`；
- SemaAuthority：`236 success / 0 warning / 0 failed`；
- Compiler.CanonicalAST：`285 success / 0 warning / 0 failed`；
- Verifier：`16 success / 0 warning / 0 failed`；
- broad Compiler：`474 success + 1 succeeded-with-warning + 0 failed`，合计475，不能写成纯`475/475 PASS`。

### 当前最严重的十个问题

#### 1. CodeGen artifact和module activation仍不原子

`asCModule::Build()`在新candidate成功前先`InternalReset()`擦除旧module。Generate过程中又提前写live type registry、module class types、imports、Engine function table、object behaviours、constructors、methods和methodTable。`Artifact::Abandon()`只完整处理部分function/global，`types/funcdefs`只是清空数组，也不撤销imports/behaviours/method tables。

因此failure可能留下partial live state，且无法保留last-good module/snapshot。13.6/9.1/10.4继续open是正确的。

#### 2. CodeGen会丢掉Sema exact target，再按name+arity重新选native/member/constructor

`EmitCall()`在找不到canonical DeclId bind时遍历Runtime methods，只比较名字和三种参数数量关系并返回第一个method；`EmitConstruct()`也有按argument count找constructor的fallback。Sema即使正确选择`insertLast(const int&in)`，backend仍可能执行同名同arity的错误overload。

这违反“backend不重跑overload resolution”，说明checked 9.4仍是false-complete。需要stable canonical target到exact Runtime callable的binding table，bind失败必须fail-closed。

#### 3. type layout、窄/宽值和object lifetime仍不安全

script type registration只扫TU direct child、按裸名查冲突、alignment固定4、property失败静默跳过。读写helper仍主要只有4/8-byte路径；1/2-byte会覆盖邻接数据，>8-byte会截断；`StoreGlobal()`和多条member store固定`WRTV4`。handle/value-object/list的AddRef/Release/construct/copy/destroy/failure cleanup也未闭环。

危险shape必须先整模块fail-closed，再逐步开放支持。

#### 4. literal/default/global/member initializer仍以字符串为语义协议

integer literal/default用`strtoul()`；Windows上`unsigned long`为32-bit，64-bit值可能丢失。generated member default用`atoi()`，`40+1`会被解释为40。global initializer从`defaultArg` string再`strtoll()`并直接写内存，无法完整表达uint64、enum、constant expression、conversion和overflow diagnostics。

这些必须改成canonical typed Expr/ConstValue/InitPlan，source string只能用于诊断。

#### 5. 一般expression identity仍是arena扫描，Sema仍大量FromNode replay

Call的full-range修复是局部正确，但`FindExistingExpr()`仍只匹配kind+begin，不含end/owner/role/operands/callee/generation，并拒绝offset 0。静态扫描`as_sema*.cpp`仍有223行命中`asCScriptNode`/`ActOnParsed*`/FromNode相关路径，call args、index、cast、binary、control、initializer等仍递归从syntax node提取meaning。

13.2仍不是Clang式Parser semantic operands→Sema exact action，而是dedicated actions与syntax replay混合。

#### 6. Verifier仍不是publication firewall，13.5不应checked

Verifier只在`resolvedDecl`有效时检查是否dangling，不要求CALL/CONSTRUCT/DeclRef必须有target，也不检查exact target kind/signature/receiver/arg roles。Stmt有multi-owner/cycle，但Expr没有single-owner/reachability/cycle。unresolved CALL可以用ERROR type作为普通CALL节点Seal并发布。

应区分construction verifier和publication verifier；后者必须拒绝所有reachable error/recovery node及缺required semantic facts的executable graph。

#### 7. Cache ASTBodySidecar仍是占位envelope

UE wrapper只用`CanonicalAstBytes.Num()!=0`判断非空，随后新建一个空TU Context并编码，实际传入的`CanonicalAstBytes`内容完全没写入输出。fork codec只写dump和decl skeleton，没有source/type table、Stmt/Expr/body/ref/dependency/cleanup/call plan；decode还把named type一律重建为VALUE_OBJECT。

测试中的`CanonicalAstBytes={1}`正说明当前不是body DTO fidelity。13.9/6.3/6.4/6.6继续open。

#### 8. Public AST ABI与snapshot并发协议不安全

AST methods仍插在`asIScriptModule` vtable中间；GetDecl/GetStmt/GetExpr/GetType不读取caller `structSize/apiVersion`，直接写完整当前struct，small view可越界。Acquire先读raw snapshot再AddRef，与publish/release并发有UAF窗口；`currentGeneration`是普通bool；publish先release old再构造candidate，失败会丢last-good；ID也没有snapshot domain token。

13.7/13.8/13.11继续open。

#### 9. SourceManager remap不校验content identity

`RemapLogical()`只按logical key+origin复用FileID，完全忽略bytes、byteCount、lineOffset。同路径内容改变时会静默复用旧source table；Lexer/Parser/diagnostics也尚未统一以SourceManager为唯一坐标事实。

#### 10. production入口与consumer未统一，Ready仍无条件true

public`CompileFunction()`仍走legacy Builder/Compiler；default仍LEGACY；TypedASTJIT、HIR retirement、Cache、snapshot和all-entry cutover未闭环。`IsCanonicalBytecodeCodeGenReady()`当前直接`return true`，与13.1“must not be unconditionally true”冲突，也无法表达binary capability、module eligibility和last-build provenance的区别。

### OpenSpec状态与完成度

机械状态仍为`56/105 = 53.3%`，本轮没有动checkbox。

需要重新审查的checked任务至少包括：

- 13.5：Verifier publication firewall不完整；
- 9.4：backend仍按name/arity重做call target selection；
- 9.2：exact width/global/member/value reads-writes与marshalling未完整；
- 11.3：文档应更新为“default LEGACY；explicit CANONICAL Build使用CodeGen subset；CompileFunction仍Compiler”；
- 12.1/12.5：保存build/validation不代表当前dirty实现已final-ready。

当前建议指标：

- mechanical checklist：`53.3%`；
- architecture assets：约`56%–60%`；
- production compiler cutover readiness：约`40%–45%`。

当前已推进到阶段B中期：canonical module Build是real backend route，但仍不具备默认切换条件。

### 下一条最短关键路径

1. 先把Sema selected stable target精确绑定到Runtime callable，删除CodeGen name/arity search；
2. 完成detached candidate+atomic module activation，覆盖type/import/behaviour/method/global/function failure injection并保留last-good；
3. 把Verifier升级为strict publication firewall；
4. 收紧CodeGen ABI/lifetime支持门，完成width/layout/handle/value lifetime；
5. 把initializer/default改成typed AST plan；
6. 以action identity/semantic operands替代arena scan与FromNode replay；
7. 闭环public snapshot、Cache DTO、SourceManager content identity；
8. 最后统一CompileFunction/HotReload/generation/commandlet/Standalone并跑真实canonical provenance final gates。

### 正式产物

第九轮正式报告：

`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-ninth-pass.md`

### 当前决策账本追加

133. 第八轮F1的receiver-less orphan与`Make().Get()`具体single-evaluation路径已关闭，Semantics保存结果`5/5`；
134. scoped/unresolved CALL full-range identity、class/struct construction type、script same-arity fail-closed、native template ranking和Param/Enumerator source-range identity均有新GREEN证据；
135. CANONICAL module Build已真实调用sealed-AST CodeGen，是本轮production readiness上升的主要原因；
136. broad Compiler最新结果应写为`474 success + 1 warning + 0 failed`，不是纯`475/475 PASS`；
137. 当前首要Critical已转为detached artifact/atomic activation：Build先Reset旧module，Generate期间仍提前写live registries/tables且rollback不完整；
138. CodeGen按name+arity重新选择native/member/constructor会丢失Sema exact target，9.4仍false-complete；
139. type layout、1/2/>8-byte读写、global/member固定WRTV4、handle/value/list lifetime仍是内存与ABI blocker；
140. `strtoul/atoi/defaultArg string`不能作为64-bit/default/global/member initializer的canonical semantic contract；
141. Call full-range修复没有解决一般`FindExistingExpr(kind+begin)`和大量FromNode replay，13.2仍open；
142. Verifier缺required callee/DeclRef target和Expr ownership/cycle/reachability，13.5应重新打开；
143. Cache wrapper忽略输入CanonicalAstBytes，fork codec只恢复decl skeleton，13.9仍是占位；
144. public mid-vtable/small-view/snapshot race/last-good和SourceManager content identity仍未关闭；
145. `CompileFunction`仍legacy、default仍LEGACY、Ready仍无条件true，all-entry cutover未完成；
146. 当前估计architecture assets约56%–60%，production cutover readiness约40%–45%，阶段位于B中期；
147. 下一关键路径优先exact callable binding→atomic module artifact→strict Verifier→ABI/lifetime→typed initializer→Sema action identity→snapshot/cache/source→all-entry final gates；
148. 第九轮只读审查保存证据，没有主动build/test、没有修改plugin实现或tasks checkbox。

## 2026-08-22 — 问题 27：第十轮复审，当前实现又推进到了哪里

### 用户问题

> 再review 下, 看看现在的进展

### 结论先行

第十轮仍为 **Request changes**。方向没有偏，CANONICAL Bytecode CodeGen 的 executable slice 又扩大了一步，但还没有关闭任何一个系统级 cutover blocker，因此不能切默认、不能删除LEGACY/HIR、不能归档。

本轮最大的真实进展：

- `OpaqueValue`已成为CodeGen-local memo，index compound assignment可以保持base single-evaluation并write-through；
- non-void return改为先写`returnSlot`、再执行destructor、最后恢复return register；
- logical short-circuit、conditional arm、property/index mutation和value temporary都有更明确的LEGACY/CANONICAL publisher+trace测试；
- property `RunLocal`和四个isolated trace在单跑/一组运行中出现GREEN。

本轮最重要的新问题：相同源码/二进制下，`IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace`单跑为GREEN，但完整Semantics前缀为`11/12`，CANONICAL返回`13733`而不是`42`。源码复核定位为：存在用户构造函数时，member `int Value = 41` initializer没有被注入该构造函数，`FValue().Value`读取未初始化VM local；单跑绿色只是栈内存偶然命中期望值。

### 当前证据边界

- primary cutoff：`2026-08-22 18:07:52 +08:00`；post-cutoff增补检查到`18:11:22`；
- parent/plugin HEAD仍为`fd16e5b...` / `ed22fbdf...`；
- dirty paths仍为`20 / 108`；
- cutoff时没有UnrealEditor进程；
- reviewer没有主动运行build/test，没有改plugin或tasks checkbox；
- 相对第九轮，核心变化仅在`as_sema_expr.cpp`、`as_bytecode_codegen.cpp`和两组CanonicalAST tests；module/verifier/public/cache/source文件未变。

当前关键hash：

```text
as_sema_expr.cpp        49E546C6930D
as_bytecode_codegen.cpp 25644DE66757
as_module.cpp           FF912191C238
as_ast_verifier.cpp     173CA1EF3A30
as_ast_public_view.cpp  1A0C04E85712
as_source_manager.cpp   EB60196F8967
as_ast_sidecar.cpp      D2266F259F6E
```

### 最新保存验证证据

最新`wave-b-54-remain` Build在当前源码之后完成，exit 0、Result Succeeded，但UBT执行0 action，只能证明binary up-to-date。

运行证据：

| label | 结果 | 解释 |
| --- | --- | --- |
| `wave-b-54-remain-prop-g` | `1/1` | property单跑GREEN |
| `wave-b-54-remain-temp-g` | `1/1` | value temporary单跑GREEN |
| `wave-b-54-remain-iso` | `4/4` | 四个isolated trace一次GREEN |
| `wave-b-54-remain-sem` | `11/12`, 1 failed | 当前broad Semantics RED |

失败：

```text
IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace
CANONICAL FValue().Value+1 got=13733
```

较早`SemaAuthority 236/236`发生在17:59 CodeGen修改之前，不是exact-current broad evidence；当前没有最新CodeGen之后完整绿色的SemaAuthority/CanonicalAST/Compiler broad report。

### 为什么member initializer会丢失

`FillGeneratedConstructorDefaults()`读取`member->defaultArg`，用`atoi()`生成assignment。但`EnsureGeneratedLifecycle()`只在没有用户ctor时创建generated ctor并填充defaults：

```text
发现用户 FValue()
  → hasCtor=true
  → generatedCtor invalid
  → 不调用 FillGeneratedConstructorDefaults
  → 用户 ctor body只有Trace(1)
  → Value local未初始化
```

正确设计不是清零local或在测试ctor中手写`Value=41`，而是为每个constructor建立Sema-owned typed initialization plan：member default按声明顺序在user body前执行，显式initializer覆盖default，并携带conversion/construction/cleanup。

### Post-cutoff增补：18:11 constructor-default tactical patch

最终文档核验期间，implementer又修改了`as_bytecode_codegen.cpp`，新增`EmitConstructorMemberDefaults()`，在每个`DECL_CONSTRUCTOR` body前枚举parent class members，以`atoi(defaultArg)`建立常量并写入integer/unsigned/bool property。

这可能局部修复当前`int Value=41`症状，但不是最终架构闭环：

- initializer语义仍由backend解析字符串，违反Sema-only authority；
- 只支持integer/unsigned/bool；
- `40+1`、64-bit、enum/object/list/conversion/lifetime仍错或被跳过；
- generated ctor原本已有`FillGeneratedConstructorDefaults()` body，可能重复写default；
- unsupported property/type被静默continue；
- 写入仍经过4/8-byte粗粒度路径。

随后保存验证完成：`wave-b-54-remain-ctorinit`执行`68/68` build actions，exit 0、Result Succeeded；`wave-b-54-remain-iso2`为`4/4`；post-patch broad Semantics为`12/12`、0 failed。因此pre-patch `11/12` RED是定位缺口的已证实事实，当前integer member-default fixture已局部修复。该结果仍不能把backend string workaround解释成typed initializer架构完成。

### 第九轮F1–F10当前状态

1. detached artifact/atomic activation：未变；Build仍先InternalReset，Generate仍提前修改live registries/tables；
2. exact callable binding：只有高质量research attachment，源码仍name+arity/first-match；
3. layout/width/lifetime：returnSlot局部进展，但1/2/>8 byte和value/handle lifetime仍不完整；
4. typed initializer：未完成，且最新`13733`已给出runtime错误证据；
5. Sema identity：OpaqueValue lowering进展，但`FindExistingExpr(kind+begin)`仍在；
6. strict verifier：文件未变，CALL/CONSTRUCT/DeclRef required target与Expr ownership/cycle/reachability仍缺；
7. Cache DTO：未变，仍是decl skeleton/facade；
8. public ABI/snapshot：未变，mid-vtable、view negotiation、Acquire race和last-good仍缺；
9. SourceManager truth：未变，content identity不校验；
10. all-entry cutover：未变，CompileFunction legacy、default LEGACY、Ready无条件true。

### OpenSpec一致性

机械进度仍为`56/105 = 53.3%`。9.2、9.4、13.5仍被checked，但分别与当前width/marshalling、name+arity backend relookup和Verifier实现冲突，应由实现方重新打开或拆成明确的subset task。本轮review没有主动改checkbox。

### 当前百分比

- architecture/scaffold assets：约`59%–62%`；
- production cutover readiness：约`42%–45%`，中心估计约`43%`；
- 阶段仍是B中期。

expression executable slice可以小幅上调架构资产，但production readiness不应上调：系统级blocker没有关闭，最新broad Semantics还是RED。

### 推荐下一步

1. typed member-init plan，稳定关闭单跑/前缀顺序差异；
2. exact Runtime callable binding，删除global/method/ctor/factory/opIndex的name+arity/first-match；
3. exact layout/value-operation/lifetime plan；
4. detached artifact+atomic module activation；
5. strict executable Verifier；
6. action identity替代arena replay；
7. public snapshot/Cache DTO/Source truth；
8. all-entry canonical provenance gates后才考虑default、HIR retirement和LLVM backend。

### 正式产物

第十轮正式报告：

`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-tenth-pass.md`

### 当前决策账本追加

149. OpaqueValue已使用CodeGen-local ExprId memo，index compound assignment的base single-evaluation和write-through有真实执行进展；
150. returnSlot-before-dtor方向正确，generated getter和primitive return寄存器覆盖问题得到局部修复；
151. logical/conditional/property/index/value temporary tests开始明确区分LEGACY COMPILER与CANONICAL_CODEGEN publisher，是比flag/dump更可信的oracle；
152. 最新Build exit 0且binary up-to-date，但这不是语义通过证据；
153. 最新broad Semantics为`11/12`，失败值是`13733`，不能写成当前全部绿色；
154. 同一value temporary测试单跑GREEN、broad RED，说明单跑结果具有顺序/内存布局依赖；
155. 用户ctor存在时member default initializer未被注入，读取未初始化VM local是当前最强源码解释；
156. `atoi/strtoul/strtoll/defaultArg string`不应继续作为initializer/default canonical contract；
157. exact callable binding attachment方向正确但尚未实现，global/method/ctor/factory/opIndex relookup仍存在；
158. 9.4仍是false-complete；9.2对exact width/marshalling也仍false-complete；
159. OpaqueValue memo不等于Sema identity完成，通用`FindExistingExpr(kind+begin)`未变；
160. verifier/module/public/cache/source关键文件未变，第九轮对应blocker全部继续成立；
161. 13.5仍false-complete，Verifier不是完整executable publication firewall；
162. CompileFunction仍legacy、default仍LEGACY、Ready仍无条件true；
163. post-patch当前估计architecture assets约59%–62%，production cutover readiness约42%–45%，中心约43%；
164. 下一顺序为typed member-init→exact callable→layout/lifetime→atomic artifact→strict verifier→Sema identity→snapshot/cache/source→all-entry gates；
165. 第十轮只读复审，没有主动build/test、没有修改plugin实现或tasks checkbox。
166. 文档核验期间CodeGen新增`EmitConstructorMemberDefaults()`，当前`int Value=41`缺失已进入局部修复；
167. 新patch仍使用`atoi(defaultArg)`且只写integer/bool property，不是Sema-owned typed initializer plan；
168. generated ctor既有default assignment body与新emitter前置写入存在重复语义风险；
169. post-patch `68/68` build、isolated `4/4`、broad Semantics `12/12`已关闭当前integer fixture的具体回归；
170. 第十轮正式报告已更新为primary cutoff + post-cutoff addendum；系统级blocker不变，production readiness仅小幅上调至约42%–45%。

## 2026-08-22 — 问题 28：实现已经进行了30小时，当前进展和投入产出如何

### 用户问题

> 你感觉实现的进展怎么样? 现在已经进行了30h了

### 结论先行

30小时没有白花，方向也没有明显走偏：工程已经从“Canonical Typed AST设计和脚手架”进入“真实CANONICAL Bytecode后端可以执行一部分语言、并能用LEGACY/CANONICAL差分测试暴露真实语义错误”的阶段。这是编译器重构里很关键的一道坎。

但如果目标是“默认切换到新版AST/编译器，并安全删除LEGACY/HIR”，那当前仍没有过半。以生产切换为口径，当前估计约`43%–46%`，中心值约`44%`；机械checkbox仍是`56/105 = 53.3%`，且9.2、9.4、13.5存在false-complete，不能把53.3%当成真实完成度。

因此，对30小时的评价要分两种目标：

- 如果目标是做出一个可运行、能验证Canonical AST适用性的编译器原型，那么已经完成约`75%–80%`，成果是实的；
- 如果目标是把它变成AngelScript/UE的生产默认编译路径，那么大约只到`43%–46%`；
- 如果目标还包括删除LEGACY AST/HIR及所有旧consumer，整体约`30%–35%`。

如果最初预期是“30小时内完成生产切换”，那现在明显落后；如果预期是“建立一套可证明的新版编译器架构，并开始替代旧路径”，这30小时的进度是合理但效率不均匀。

### 这30小时实际换来了什么

已经得到的不是单纯的类和接口，而是以下真实资产：

1. Canonical Typed AST的Context、Decl/Stmt/Expr/Type、SourceManager、ID、Seal、Verifier、Dump、public snapshot等基础设施已经存在；
2. Parser/Builder/Sema已经能产生越来越多的canonical semantic facts，控制目标、部分调用、DeclRef、OpaqueValue、temporary等不再只是概念；
3. CANONICAL module `Build()`已经真实调用`asCBytecodeCodeGen::Generate()`，不是只设置flag后仍偷偷使用旧`asCCompiler`；
4. scalar表达式、局部变量、部分控制流、property/index mutation、部分native/script call、temporary/return cleanup已经拥有可执行slice；
5. publisher provenance和LEGACY/CANONICAL隔离差分测试能证明实际由哪个backend发布bytecode；
6. 测试已经暴露并定位了真实编译器错误，例如value temporary在prefix运行中读取未初始化member并返回`13733`，随后当前integer fixture被局部修复；
7. 任务记录已经开始明确区分“一个测试绿了”和“某个编译器架构契约真的闭环”，这会降低后续误判完成度的风险。

从验证HIR/Canonical AST是否适合作为优化和LLVM入口的角度看，原型目标已经得到正面答案：这套结构可以承载类型、控制流、调用、lifetime和consumer视图；当前问题主要是语义事实还不够完整、发布边界还不够安全，而不是AST方案本身不可行。

### 18:14以后又发生的增量

截至本次检查的`2026-08-22 18:36 +08:00`，实现方在第十轮review之后又推进了两小步：

- statement/control的SemaAuthority扩到`239/239`，Verifier为`17/17`；Switch default-last、无expr default、continue skipped-nearer等事实有了更多oracle；
- 新增了exact callable binding的同名同参数数量红测。`CanonicalNativeSameArityMember...`和`CanonicalNativeSameArityMethod...`当前为`0/2`，证明CodeGen仍会按name+arity选择错误或找不到正确Runtime callable。

`as_bytecode_codegen.cpp`在红测后于18:31又发生修改，但截至检查时没有对应的post-change build/green test证据。因此这部分只能算“正确进入TDD红灯阶段”，不能算exact binding已完成。

这些增量提高了语义契约覆盖，但没有关闭系统级cutover blocker，所以生产百分比只适合从第十轮中心值约43%微调到约44%，不能因为`239/239`和`17/17`就大幅上调。

### 当前阶段图

```text
目标：新版AST成为唯一生产语义事实和编译入口

Stage A  AST/Source/Type/Seal基础设施       [#########-]  基本成形
Stage B  Sema语义事实 + 可执行CodeGen子集  [######----]  当前主战场
Stage C  全语言/精确ABI/初始化/lifetime    [###-------]  明显未闭环
Stage D  detached artifact + atomic install [##--------]  只有局部事务设施
Stage E  snapshot/cache/source/JIT consumers [##--------]  多数仍是桥接或占位
Stage F  全入口切换 + 全量验证              [#---------]  尚未开始真正切换
Stage G  删除LEGACY/HIR                     [----------]  尚未开始
```

这解释了为什么“代码量和测试量看起来已经很多”，生产完成度仍只有约44%：后半段不是继续增加几个AST node，而是要关闭ABI、对象生命周期、失败回滚、并发snapshot、Cache恢复、Hot Reload和所有编译入口的一致性。这些问题比前端脚手架更难，也更不能靠单个绿色fixture代替。

### 当前效率问题在哪里

最大的问题不是方向错误，而是执行过程中多次先扩大CodeGen executable slice，再由backend用字符串、name/arity、first-match或范围扫描补足Sema缺失事实。这会出现以下循环：

```text
新增可执行fixture
  -> CodeGen发现缺语义事实
  -> backend临时重新猜测/解析
  -> 单测变绿
  -> broad prefix暴露顺序、重载、初始化或lifetime错误
  -> 再回头补Sema/AST contract
```

`atoi(defaultArg)`初始化和name+arity callable lookup就是典型例子。这种推进能快速扩大demo，但会产生返工；30小时里真正需要控制的是这部分消耗，而不是质疑Canonical AST总体方向。

后续应停止无边界地扩展新语法slice，优先把下面三个“语义地基”做实：

1. Sema-selected exact callable必须能无猜测地映射到Runtime callable；
2. initializer、conversion、construction、cleanup必须成为typed AST/Sema plan，backend不得解析`defaultArg`字符串；
3. CodeGen必须生成detached candidate，并以atomic install/rollback保留last-good module。

这三项不闭环，继续增加for/switch/container/lambda fixture会继续放大返工。

### 后续时间判断

编译器迁移后半程是非线性的，不能简单用`30h / 44%`推导剩余38小时。按当前范围和风险，更现实的区间是：

| 目标 | 从现在起的粗略投入 | 前提 |
| --- | ---: | --- |
| exact callable + typed initializer/lifetime的受控子集稳定 | `8–15h` | 不同时扩展新语言面 |
| explicit CANONICAL在受控Compiler/Frontend prefixes中稳定 | `12–20h` | 上述语义地基先闭环 |
| 达到可讨论生产默认切换的完整门槛 | `35–60h+` | atomic install、strict publication、ABI、snapshot/cache/source和入口统一都完成 |
| default切换后删除LEGACY/HIR | 另加`10–20h+` | 全量回归、StaticJIT/Cache/Hot Reload已使用canonical truth |

所以整个工作更像`70–110h`级别的重构，而不是30小时任务。这个估算不是工期承诺；如果对象/容器/lambda/import/异常语义或UE Hot Reload暴露新的ABI问题，上界还会增加。

### 建议设置一个8–12小时止损检查点

建议下一阶段只给`8–12h`的聚焦窗口，并要求至少出现以下可审计结果：

1. 当前same-arity exact-binding `0/2`红测转绿，且CodeGen不再name+arity/first-match重选；
2. integer member default不再依赖`atoi(defaultArg)`，有Sema-owned typed initializer plan和表达式/64-bit/object negative or positive evidence；
3. 至少一个production CANONICAL failure-injection测试证明candidate失败后旧module和last-good snapshot仍可用；
4. 相应broad prefix在exact-current source上通过，而不是只单跑fixture。

如果再投入8–12小时仍然主要是在`as_bytecode_codegen.cpp`添加更多特例、而上述三项没有实质关闭，就应该暂停扩面，重画Sema call/init/lifetime plan和module transaction边界。反之，如果三项能按顺序关闭，当前方向值得继续投入。

### 本轮操作边界

本轮只读取当前worktree源码、OpenSpec任务和实现方保存的build/test结果，没有主动运行build/test，没有修改plugin实现或tasks checkbox。当前worktree仍在实现中，18:31后的CodeGen修改尚无绿色证据。

### 当前决策账本追加

171. 用户给出的实现投入已经达到约30小时；评价必须区分原型、生产切换和LEGACY/HIR删除三个口径；
172. 当前机械checkbox仍为`56/105 = 53.3%`，但9.2、9.4、13.5存在false-complete，不能作为生产完成度；
173. 可运行Canonical AST/CodeGen原型约`75%–80%`，生产cutover约`43%–46%`、中心约44%，含LEGACY/HIR删除的整体约`30%–35%`；
174. 30小时已经获得真实Canonical AST、Sema facts、production Build CodeGen route、差分publisher和可执行语义slice，不是只有文档与脚手架；
175. 测试开始稳定暴露真实编译器错误，说明工程已经进入语义替换阶段；
176. 18:14后SemaAuthority为`239/239`、Verifier为`17/17`，控制流语义oracle继续扩充；
177. same-arity native/member exact binding新红测当前`0/2`，再次证实CodeGen name+arity lookup不是Sema exact target；
178. `as_bytecode_codegen.cpp`在红测后又修改，但截至18:36没有post-change绿色证据，不能把F2计为完成；
179. 系统级blocker没有关闭，因此新测试数量只使生产中心估计从约43%微调到约44%；
180. 当前方向正确，但执行效率被backend字符串解析、name/arity猜测和first-match特例造成的返工拖慢；
181. 后续应优先exact callable、typed init/lifetime、detached artifact/atomic install，暂缓无边界扩大语言slice；
182. 不能按线性比例估工，生产默认切换从现在起仍可能需要`35–60h+`，删除LEGACY/HIR还需额外验证和清理；
183. 建议设置下一`8–12h`止损检查点，以exact-binding转绿、typed initializer取代字符串和last-good failure-injection为硬结果；
184. 本轮没有主动build/test，没有改plugin或checkbox，只读取实现方保存证据并记录30小时投入产出判断。

## 2026-08-22 — 问题 29：第十一轮复审，30小时之后又推进到了哪里

### 用户问题

> 再看下现在的进展

### 结论先行

第十一轮仍为 **Request changes**，但第十轮之后出现了两段真实进展：

1. native method/member、constructor、factory、`opIndex` 的same-arity poison执行矩阵曾达到ProductionCodeGen `38/38`，SemaAuthority同期为`239/239`；
2. member default initializer开始从CodeGen `atoi(defaultArg)`迁移为Canonical AST中的typed `Decl.inits` graph，SemaAuthority扩到`240/240`。

这说明实现已经从“CodeGen按名字和参数数量猜调用”“backend解析initializer字符串”向正确的Sema/AST authority前进。方向没有偏，Canonical AST的适用性得到进一步验证。

primary cutoff时ProductionCodeGen是`36/39`，有三个active failure：

```text
CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes
CanonicalGeneratedInt64AccessorUsesRdr8NotRdr4
CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody
```

前两个证明caller仍会绕过generated getter，直接以内联`ADDSi/RDR4/RDR8`读取字段；第三个证明typed `40+1` init graph虽然已生成并出现在constructor Bytecode中，最终执行仍返回`0`而不是`42`。

post-cutoff `wave-b-initplan-exec-g2`重新执行7-action build并成功，随后ProductionCodeGen为`38/39`：两个generated accessor CALL失败已经转绿，当前唯一失败是typed user-ctor initializer。

因此当前从B中期推进到B中后段，但尚未跨过production cutover边界。production readiness建议从上一轮中心约`44%`上调到约`47%`，合理区间`46%–49%`。不能因为focused `38/39`或当前Sema `240/240`就上调到50%以上。

### 当前审查边界

- source cutoff：`2026-08-22 20:22:03 +08:00`；post-cutoff build/test addendum检查到`20:26:54`；
- parent/plugin HEAD仍为`fd16e5b...` / `ed22fbdf...`；
- parent/plugin dirty path count仍为`20 / 108`；
- cutoff时没有`UnrealEditor` / `UnrealBuildTool`进程；
- reviewer没有主动build/test，没有修改plugin实现或tasks checkbox；
- primary cutoff时最新成功build完成于20:08:49，而`as_bytecode_codegen.cpp`在20:10:23又发生修改；随后post-cutoff `wave-b-initplan-exec-g2`重新执行7-action build并成功，ProductionCodeGen复跑为`38/39`。因此当前源码已有exact-current focused compile/test证据。

### Exact callable的真实进展和边界

相对第十轮，CodeGen新增了`FindExactRegisteredMethod()`和`FindExactRegisteredConstructor()`：

- 比较return type、parameter type、reference/handle和in/out qualifier；
- 处理template instance；
- constructor/factory要求唯一的user-visible signature匹配；
- `EmitIndex()`必须从`resolvedDecl`映射到`opIndex`，缺失则fail-closed；
- `EmitCall()`已删除上一轮通用`FindMethodUntil(name)+arity` fallback。

对应execute evidence：

| 证据 | 结果 |
| --- | --- |
| method/member exact binding | ProductionCodeGen `35/35` |
| constructor/factory/opIndex扩展 | ProductionCodeGen `38/38`，多次重复绿色 |
| focused Sema | `239/239` |

但完整9.4仍未闭环：

- native global仍由`FindRegisteredGlobalFunction()`按`name + parameter count`选择；
- method/constructor仍由CodeGen在mutable Engine registry中重新枚举和比较签名，不是Sema直接交付稳定Runtime callable identity；
- zero-arg constructor/factory仍有arity fallback；
- list factory仍直接使用behaviour slot；
- generated accessor binding失败时没有fail-closed，而是caller直接内联字段访问。

所以可以说“当前same-arity method/ctor/factory/opIndex具体fixture已关闭”，不能说“exact callable架构已完成”。

### Typed initializer的真实进展和当前RED

新增流程：

```text
member Decl.inits
  -> AttachConstructorMemberInits()
  -> DeclRef(member) + typed RHS + Assign
  -> constructor Decl.inits
  -> CodeGen在constructor body之前EmitExpr(init)
```

`asCDecl`新增`inits`，Context提供`AddDeclInit()`，Dump输出`init=<ExprId>`。`int Value = 40 + 1`已经成为typed binary/assign graph，不再只有字符串。这是正确方向。

但ProductionCodeGen连续多次为`38/39`，失败值稳定为`got=0`。constructor dump中能看到SetV4、member address、WRTV4和body中的读取/ADDi/WRTV4，Entry中也有CALL；这说明当前缺口已经从“没有init plan”转成“init plan、value-object constructor ABI、behaviour identity或object slot install/调用不一致”。

下一步必须直接断言Entry CALL operand等于预期user constructor ID，并检查：

- hidden `this` push/pop；
- `beh.construct`和`beh.constructors[]`是否有placeholder/generated/user重复；
- constructor call后对象slot是否被清零或覆盖；
- init assignment是否写到Entry实际对象地址。

### 新initializer edge尚未成为完整compiler contract

`as_ast_verifier.cpp`、`as_ast_sidecar.cpp`和`as_ast_public_view.cpp`均未变化，也没有遍历`decl->inits`。

因此当前不会验证或保留：

- dangling/foreign init ExprId；
- init cycle/owner/type错误；
- member/constructor generation不匹配；
- init中的required callee/cleanup target；
- Cache restore和public consumer的initializer graph。

这使13.5、13.9和public AST完整性继续不成立。typed init不只要能Dump和CodeGen，还必须通过Verifier/public/Cache保持同一个图。

### Accessor和宽度问题

新测试正确拒绝此前的false green：caller必须CALL `GetValue/SetValue`，不能直接内联字段访问。post-cutoff这两个fixture已经转绿，说明当前测试场景已进入generated accessor CALL；但callee缺失时的字段内联fallback源码仍在，尚未fail-closed。

当前generated accessor自身已经使用`ValueDwords()`和`EmitReadValue/EmitWriteValue`，但caller在callee bind缺失时仍直接`ADDSi + RDR4/RDR8`。同时通用路径仍存在固定4-byte操作：

- member assignment `WRTV4`；
- `EmitMemberStore()` `WRTV4`；
- `LoadGlobal()` `CpyGtoV4`；
- `StoreGlobal()` `WRTV4`。

double/handle getter fixture绿色不能外推到setter、global、copy/refcount/destruct，9.2仍为false-complete。

### 系统级blocker没有变化

`as_module.cpp`未变化，CodeGen仍在完整成功前写Engine/module live state，`Artifact::Abandon()`不能回滚全部function/type/global/import/behaviour/method-table修改；Build仍先Reset旧module，失败不能保留last-good。

以下也未推进：

- strict executable Verifier；
- public mid-vtable和view size/version；
- snapshot Acquire/publish并发协议；
-完整Cache DTO；
- SourceManager content identity；
- public `CompileFunction()` canonical route；
- default CANONICAL；
- HIR/LEGACY retirement。

因此不能切默认、不能删除HIR/LEGACY、不能archive。

### OpenSpec和完成度

`tasks.md`仍停留在18:24，checkbox仍为`56/105 = 53.3%`，没有记录之后的`38/38`、`240/240`和最新`38/39`。9.2、9.4、13.5仍被checked，与当前实现和active RED冲突。

当前建议指标：

| 口径 | 当前估计 |
| --- | ---: |
| 机械checkbox | `53.3%`，含false-complete |
| 可运行Canonical原型 | `83%–86%` |
| architecture/scaffold assets | `64%–67%` |
| production compiler cutover readiness | `46%–49%`，中心约`47%` |
| 默认切换并删除LEGACY/HIR | `33%–38%` |

### 下一条最短关键路径

1. 暂停增加语言breadth，先将当前`38/39`真正变成`39/39`；
2. 保持generated accessor exact CALL绿色，并删除caller字段内联fallback；
3. 通过CALL operand/behaviour identity定位user value ctor init执行为0的问题；
4. global exact binding不再name+arity，最终停止CodeGen registry re-selection；
5. Verifier/public view/Cache DTO加入`decl->inits`；
6. 用typed graph替代global/member `defaultArg` string；
7. 收紧1/2/4/8/pointer/value-object ABI和lifetime；
8. 立即进入detached artifact + atomic install failure-injection；
9. 最后完成snapshot/cache/source/all-entry/default/HIR retirement。

### 正式产物

第十一轮正式报告：

`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-eleventh-pass.md`

### 当前决策账本追加

185. 第十轮后same-arity method/member/constructor/factory/opIndex执行矩阵曾达到ProductionCodeGen `38/38`；
186. exact-binding的具体行为有真实进展，不能再笼统描述为完全未实现；
187. CodeGen已删除通用method name+arity fallback，`opIndex`要求从`resolvedDecl`取得callee；
188. native global仍按name+parameter-count匹配，method/constructor也仍由CodeGen重扫Engine registry，因此完整9.4仍未关闭；
189. `asCDecl::inits`、`AddDeclInit()`、constructor前置init emission和dump `init=`已落地；
190. SemaAuthority `240/240`证明`40+1`已经形成typed init graph，这是正确架构进步；
191. typed init production execution仍稳定返回0，最新对应fixture持续RED；
192. 当前需核对Entry CALL operand、value-object hidden-this ABI、behaviour table和object slot lifetime；
193. generated accessor caller仍以内联字段访问绕过callee，新强断言揭露两个false green；
194. primary cutoff时ProductionCodeGen为`36/39`；post-cutoff复跑为`38/39`，当前唯一active failure是typed user-ctor initializer；
195. `decl->inits`尚未进入Verifier、Cache sidecar和public view，不能作为完整publication/cache contract；
196. member/global固定WRTV4/CpyGtoV4路径仍存在，9.2继续false-complete；
197. detached artifact/atomic install、public snapshot、Cache、SourceManager和all-entry文件未变化；
198. tasks仍为`56/105 = 53.3%`且记录停在18:24，未吸收之后的GREEN/RED边界；
199. 当前production readiness建议约`46%–49%`、中心约47%，阶段进入B中后段；
200. 下一checkpoint应先关闭`38/39`中的typed init RED、删除accessor fallback，再进入atomic install；
201. primary cutoff时成功build早于当前CodeGen源码；post-cutoff `wave-b-initplan-exec-g2`已补上当前源码7-action compile证据和随后ProductionCodeGen `38/39`结果；
202. 第十一轮只读源码和保存证据，没有主动build/test、没有修改plugin或checkbox；
203. 第十一轮正式review已写入对应worktree的OpenSpec `reviews/`；
204. Canonical AST适用性继续得到正面验证，当前主要风险是同一semantic identity无法贯穿Runtime binding、ABI、publication和Cache，而不是AST数据模型方向错误。
205. post-cutoff build成功且ProductionCodeGen由`36/39`恢复为`38/39`，两个accessor RED关闭；production中心估计微调为约47%。

## 2026-08-22 — 问题 30：通俗说明现在做到哪里，以及完成百分比

### 用户问题

> 你告诉通俗的告诉我下现在什么进展, 以及现在完成的进度百分比

### 通俗结论

把这次重构想成“把一栋还在营业的旧工厂，换成全新的自动化生产线”：

- 新厂房骨架已经基本搭好；
- 新生产线已经真的能生产一部分产品，不是模型或PPT；
- 一部分关键工序已经能和旧生产线对照，产出的结果也一致；
- 但复杂工序、安全停机、失败回滚、仓库恢复和所有入口切换还没有完成；
- 因此现在能试运行，不能把旧生产线拆掉。

以“最终可以默认使用新版编译器，并删除旧AST/HIR/LEGACY路径”为100%，当前建议完成度是：

```text
约47%
合理区间：46%–49%
```

如果只看“做出一个可以运行、可以验证Canonical AST设计的新编译器原型”，则已经约`83%–86%`。两个百分比不矛盾：原型接近完成，但生产切换后半段包含大量ABI、对象生命周期、失败回滚、Cache、Hot Reload和全入口工作。

### 已经完成的部分

1. 新AST骨架基本完成：Decl/Stmt/Expr/Type、Source、Seal、Dump、部分Verifier和snapshot都有了；
2. 新Sema已经能记录越来越多的类型、调用、控制流、临时对象和initializer事实；
3. 新CodeGen已经真的能从Canonical AST生成Bytecode并执行一部分脚本；
4. ordinary expression、局部变量、部分循环/分支、property/index、temporary、部分native/script call已经能跑；
5. 同名、同参数数量但类型不同的method/constructor/factory/opIndex测试曾达到`38/38`，说明错误重载选择得到明显修复；
6. `int Value = 40 + 1`已经开始以typed AST graph表示，不再只有`atoi(defaultArg)`字符串思路；
7. 当前源码最新7-action build已成功。

### 当前正卡住的部分

最新ProductionCodeGen保存结果已经从`36/39`恢复为`38/39`。generated int/int64 accessor的真实CALL测试已转绿，现在只剩一个关键失败：

1. typed member initializer虽然生成了Bytecode，但value-object constructor执行后仍返回0，而不是42。

这说明generated accessor当前fixture已经接通，但typed initializer仍卡在“对象地址怎么传、初始化写到哪个对象、constructor behaviour如何发布”的连接处。源码中的getter字段内联fallback仍应删除，防止未来binding缺失时再次出现false green。

此外还有几项更大的生产门槛尚未完成：

- 编译失败后保留旧module的atomic install/rollback；
- 完整的1/2/4/8字节、handle、value object ABI和lifetime；
- Verifier验证全部可执行边；
- Cache V2恢复完整AST body；
- public snapshot并发安全；
- SourceManager内容版本一致性；
- `CompileFunction`、Hot Reload、StaticJIT等所有入口切换；
- 最后才能切default CANONICAL并删除HIR/LEGACY。

### 一眼看懂的进度图

```text
新AST基础设施                  90%  [#########-]
Sema语义事实                  65%  [######----]
新Bytecode CodeGen语言覆盖    55%  [#####-----]
精确调用/初始化/ABI           43%  [####------]
失败回滚/原子发布             20%  [##--------]
Cache/snapshot/全入口切换      15%  [#---------]
删除旧HIR/LEGACY               0%  [----------]

综合生产完成度：约47%
```

这些分项是工程判断，不是机械加权；OpenSpec机械checkbox仍是`56/105 = 53.3%`，但里面有几个任务被过早勾选，所以真实生产完成度低于53.3%。

### 下一阶段什么时候能明显超过50%

要真正越过50%，至少应看到：

1. 当前`38/39`变成稳定的`39/39`；
2. typed initializer在用户value constructor中真实执行为42；
3. generated accessor保持真实CALL，native global也进入统一exact binding，并删除字段内联fallback；
4. 至少一个failure-injection证明新编译失败后旧module仍可用。

前三项关闭后可以估计到`49%–50%`；atomic install/last-good真正关闭后，才适合上调到`53%–55%`。

### 当前判断

现在不是“做错了需要推倒重来”，而是已经做到最容易暴露编译器深层问题的阶段。方向仍然正确，Canonical AST也已经证明可以承载后续优化和LLVM lowering需要的语义；当前要控制的是不要继续扩大表面语法覆盖，而是先把调用identity、initializer ABI和atomic publication三条主干接牢。

### 当前决策账本追加

206. 通俗口径下，新编译器已经能试运行，但旧生产编译路径还不能拆除；
207. 以默认切换并删除LEGACY/HIR为100%，当前生产完成度约47%，合理区间46%–49%；
208. 只看可运行Canonical编译器原型，完成度约83%–86%；
209. 新AST基础设施约90%，Sema facts约65%，CodeGen覆盖约55%，exact init/ABI约43%；
210. 最新ProductionCodeGen为`38/39`，generated accessor真实CALL已转绿，唯一失败是typed user-ctor initializer执行；
211. 当前源码7-action build和focused复跑已有证据，明确证明accessor修复及typed init剩余RED；
212. atomic install、Cache/snapshot/source/all-entry和HIR retirement仍是后半程主要工作；
213. 当前`56/105 = 53.3%`机械checkbox包含false-complete，不应替代约47%的生产判断；
214. 稳定`39/39`加exact init/call可接近50%，atomic last-good关闭后才适合估计53%–55%。

## 2026-08-22 — 问题 31：第十二轮复审，typed init关闭之后的最新进展

### 用户问题

> 再看下进展

### 结论先行

这轮相对上次的约`47%`又有一段明显推进，production compiler cutover readiness建议上调到约：

```text
50%
合理区间：49%–51%
```

如果只看“Canonical AST + Sema + 新Bytecode CodeGen能否作为一个可运行、可继续验证设计的原型”，现在已经约`89%–91%`。原型已经接近成熟，生产切换仍在中段；两种口径不能混为一谈。

本轮正式review仍是 **Request changes**，不是因为方向有问题，而是已经做成的语义slice尚未跨过完整ABI、原子安装、Cache/public/snapshot和全入口切换这道production wall。

### 从47%推进到约50%的主要原因

#### 1. 上一轮唯一typed initializer RED已经关闭

上一轮：

```text
int Value = 40 + 1;
constructor body: Value = Value + 1;
expected 42, got 0
```

本轮ProductionCodeGen从`38/39`推进到`39/39`，这个用户value constructor fixture已经真实执行为42。它证明`Decl.inits`不再只是dump里能看到的typed graph，而是在当前受控路径上接通了constructor binding、hidden object address、member store和body execution。

#### 2. zero-arg constructor/factory和native global选择更精确

新增poison tests证明：

- zero-arg constructor不能再靠dummy argument或arity猜测；
- zero-arg factory必须选择interned exact callee；
- native global即使同名、同参数数量，也必须按完整return/parameter/ref/handle/in-out签名唯一匹配；
- generated accessor caller保持真实`CALL`，不能再由caller静默内联字段访问来制造false green。

对应ProductionCodeGen先后达到`41/41`、`42/42`，最后阶段性达到`48/48`。

#### 3. field identity和1/2/4/8-byte访问明显增强

新增/加强的测试覆盖：

- script value type的第二个字段；
- native type不是第一个property的字段；
- int64、double、handle accessor；
- packed int8/int16 offset和`RDR1/2`、`WRTV1/2`；
- list factory double element。

CodeGen开始优先使用`resolvedDecl`和sealed field offset，并新增`EmitReadValue()` / `EmitWriteValue()`按1/2/4/8字节选择具体Bytecode。这说明字段访问正在从“名字/顺序猜测”变成“identity + typed width”。

#### 4. Sema开始有真正的DeclContext环境

新增：

```text
declContextStack
PushDeclContext / PopDeclContext
CurrentDeclContext
LookupInScope / LookupCandidatesFrom
```

lookup开始沿Canonical AST中的`Decl.children`和parent hierarchy寻找，而不再只依赖一个扁平辅助symbol表。SemaAuthority推进到`250/250`，局部value object default construct也被记录到变量自己的`Decl.inits`。

#### 5. 阶段性broad prefix继续扩大

实现方保存的阶段性绿色证据包括：

| Prefix | 阶段性结果 |
| --- | ---: |
| ProductionCodeGen | `48/48` |
| SemaAuthority | `250/250` |
| CanonicalAST | `320/320` |
| 完整 Compiler | `510/510` |

cutoff前又出现了CanonicalAST `321/321`和完整Compiler `511/511`。但这两项是在packed真实执行断言被删除之后取得的，因此只是exact-current broad-prefix绿色，不是packed缺陷修复证明。

### 为什么当前511/511仍不能覆盖保存的47/48

实现方随后把packed `int8/int16`测试从“只检查Bytecode中是否有`WRTV1/WRTV2`”升级为真实执行：

```angelscript
struct FPackedBytes
{
    int8 A;
    int8 B;
    int8 C;
    int8 D;
}

int RunPacked()
{
    FPackedBytes p;
    p.A = 1;
    p.B = 2;
    p.C = 3;
    p.D = 4;
    p.B = 9;
    return p.A * 1000 + p.B * 100 + p.C * 10 + p.D;
}
```

正确结果应为`1934`，直接执行得到`0`。当时ProductionCodeGen是：

```text
47/48
known execution failure:
CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4
```

这不是旧功能退步，而是更强的execution oracle揭露了此前opcode-only测试的false green。随后测试文件在`23:51:58`删除了`PackedValue==1934`和`PairValue==902`执行断言，而`as_bytecode_codegen.cpp`没有修改；之后才得到CanonicalAST `321/321`和Compiler `511/511`。所以当前broad GREEN是移除失败oracle后的绿色，不能解释为实现已经修复。

当前证据只说明：

- 编译成功；
- packed property offset查询正确；
- Bytecode出现了窄宽度load/store opcode；
- 但从member read、integral promotion、binary operation、local value lifetime到return marshalling的端到端语义仍不正确。

仅凭`got=0`还不能断言根因一定是`WRTV1`、`RDR1`或某一个具体opcode。应先恢复并永久保留执行断言，再最小化、dump Canonical AST、比较legacy/canonical Bytecode和逐段执行结果。

### 当前最大的生产阻塞仍不是这个known packed defect

packed defect和被移除的oracle都需要处理，但production cutover最大的墙仍是atomic install/last-good：

```text
当前Build：
  先InternalReset旧module
      -> CodeGen直接修改live Engine/module
      -> 中途失败只能部分Abandon
      -> 旧module已经不在，mutation也未完整回滚

目标Build：
  保留active generation A
      -> 在detached candidate B中完成全部CodeGen/verify
      -> 成功后原子A -> B
      -> 任一点失败都保持A可执行且Engine registry逐项不变
```

当前CodeGen在`Commit()`前仍会：

- 注册script type和property；
- 写`allRegisteredTypesByName`、`classTypes`、`allLocalTypes`；
- allocate global；
- add import；
- add script function；
- 修改constructor/destructor behaviour和method table。

`Artifact::Abandon()`只清理一部分function/global，`types`和`funcdefs`只是清空记录，没有完整撤销live mutation。`as_module.cpp`也没有last-good transaction变化。因此之前说“atomic install关闭后才适合报53%–55%”的判断仍然成立。

### 新增AST事实还没有成为完整contract

`asCDecl`现在新增：

```text
Decl.inits
Decl.byteOffset
```

Dump和CodeGen已经读取它们，但：

```text
as_ast_verifier.cpp     不认识inits/byteOffset
as_ast_sidecar.cpp      不序列化inits/byteOffset
as_ast_public_view.cpp  不暴露inits/byteOffset
```

所以目前仍无法保证：

- initializer ExprId不是dangling/foreign；
- initializer graph没有cycle且owner/type/callee/cleanup正确；
- Cache V2恢复同一份executable init graph；
- public/StaticJIT/LLVM consumer看到与Bytecode完全相同的fact；
- layout在不同target profile上仍成立。

尤其`byteOffset`直接放在`Field Decl`中需要继续斟酌。参考Clang，更稳妥的长期分层是：

```text
Field DeclId                 target-neutral identity
    |
    +--> LayoutSnapshot(profile/DataLayout)
           DeclId -> offset / size / alignment / ABI class
```

Clang通常由`ASTContext::getASTRecordLayout()` / `ASTRecordLayout`保存target-specific field offset，而不是让`FieldDecl`本身永久绑定某一个target layout。这样以后接LLVM `DataLayout`、多target Cache和StaticJIT更稳妥。

### Sema authority和exact binding仍然只是中间态

本轮`DeclContext`是正确进步，但Sema仍有大量：

```text
ActOnExprFromNode(asCScriptNode*)
ActOnStmtFromNode(asCScriptNode*)
ActOnLambdaFromNode(asCScriptNode*)
ActOnParsedScript(asCScriptNode*)
```

Parser仍构造完整`asCScriptNode` recovery tree，Sema仍从该tree读取表达式、语句、lambda和scope结构。CodeGen也仍通过`FindRegisteredGlobalFunction`、`FindExactRegisteredMethod`、`FindExactRegisteredConstructor`重扫当前Engine registry。

因此当前形态是：

```text
AST resolvedDecl已经控制越来越多identity
            +
CodeGen仍做一次更严格的Runtime rebind
```

最终形态应是Sema/installation plan产生sealed callable/layout/ABI record，Verifier验证，Bytecode/LLVM/StaticJIT只消费，backend不再重新做overload resolution或按名称找property。

### 当前分项进度

```text
新AST基础设施                  91%  [#########-]
Sema语义事实                  72%  [#######---]
新Bytecode CodeGen语言覆盖    63%  [######----]
精确调用/初始化/ABI           55%  [#####-----]  当前packed执行RED
失败回滚/原子发布             20%  [##--------]
Cache/snapshot/全入口切换      15%  [#---------]
删除旧HIR/LEGACY               0%  [----------]

可运行原型：约89%–91%
综合生产切换完成度：约50%，区间49%–51%
```

这些分项是工程判断，不是简单平均。OpenSpec checkbox仍为`56/105 = 53.3%`；9.2、9.3、9.4、13.5等包含scaffold-level或false-complete项，所以不能用53.3%替代约50%的生产判断。若只看实现功能而忽略测试oracle回撤，可估约51%；生产口径需要把已知缺陷未被门禁的风险算进去。

### 下一条最短关键路径

1. 先恢复packed execution断言，把`RunPacked()==1934`和`RunPair16()==902`真实执行修绿，并永久保留opcode + execution双重oracle；
2. 补narrow signed/unsigned promotion、param/global/return/copy矩阵，不再只验证字段store；
3. 保持typed initializer、zero-arg ctor/factory、global/method poison全绿；
4. 将callable/property/layout从CodeGen registry scan迁移为sealed binding/layout snapshot；
5. Verifier/public view/Cache DTO同步覆盖`Decl.inits`和layout facts；
6. 暂停扩展更多语言breadth，进入真正的detached artifact；
7. 添加type/global/import/function/behaviour各阶段failure-injection，证明失败后旧module仍执行且registry不变；
8. atomic last-good关闭后，再做public snapshot并发、Cache ExactStartup、Source content identity和all-entry；
9. 最后切default CANONICAL，再迁移/删除HIR和LEGACY。

### 当前判断

方向仍然正确，而且本轮成果进一步证明Canonical Typed AST适合作为未来Bytecode、LLVM IR lowering和优化pass的共同语义输入。现在的问题不是“要不要推倒新AST”，而是：

- executable fact是否真的满足完整VM ABI；
- 同一个resolved identity是否贯穿Sema、Runtime binding、Bytecode、Cache、LLVM和Hot Reload；
- candidate失败时是否能做到零污染并保留last-good。

保存的47/48提醒第一件事尚未完成；之后删除oracle得到的321/321和511/511没有改变这一事实。完全没动的atomic install提醒第三件事仍是最大production blocker。下一checkpoint应以“恢复packed执行oracle并全绿 + complete fact firewall + atomic last-good failure injection”为硬目标，而不是继续只增加fixture数量。

### 本轮操作边界

本轮review只读取当前worktree源码、OpenSpec和实现方保存的build/test结果；没有主动运行build/test，没有修改plugin实现或tasks checkbox。保存证据cutoff为`2026-08-22 23:57:38 +08:00`。packed直接执行在`23:47:53`得到ProductionCodeGen `47/48`；断言于`23:51:58`被删除；随后最新测试为`23:53:05` CanonicalAST `321/321`和`23:54:21`完整Compiler `511/511`。

### 正式产物

第十二轮正式报告：

`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\reviews\implementation-rereview-2026-08-22-twelfth-pass.md`

### 当前决策账本追加

215. 第十一轮唯一typed user-constructor initializer RED已经关闭，ProductionCodeGen从`38/39`推进到`39/39`；
216. typed `40+1` initializer当前已在用户value constructor中真实执行为42；
217. zero-arg constructor/factory poison矩阵达到ProductionCodeGen `41/41`，dummy/arity guessing active路径被继续收紧；
218. script/native多字段identity、generated accessor CALL和field offset矩阵推进到ProductionCodeGen `42/42`；
219. `EmitReadValue`/`EmitWriteValue`已按1/2/4/8-byte选择RDR/WRT opcode；
220. Sema新增DeclContext stack和沿sealed Decl hierarchy的scope lookup，这是13.2方向上的真实基础进步；
221. local value default construction现在记录到变量自己的`Decl.inits`，SemaAuthority达到`250/250`；
222. native global exact matching已比较return/parameter/typeinfo/ref/handle/in-out并要求唯一候选；
223. 阶段性绿色达到ProductionCodeGen `48/48`、CanonicalAST `320/320`、Compiler `510/510`；
224. 最新packed执行oracle将ProductionCodeGen变为`47/48`，`RunPacked()`预期1934、实际0；
225. 最新RED是更强execution测试揭露opcode-only false green，不应描述成旧功能回归；
226. 当前证据不足以把packed失败归因于某一个具体opcode，需先最小化和对比trace；
227. `CopyVar`、return、PushValue和global load/store仍主要固定4/8-byte，完整scalar/value ABI未闭环；
228. CodeGen仍重扫mutable Engine registry，exact matching尚不是Sema-owned sealed Runtime binding record；
229. generated accessor implementation仍按Get/Set名称反推字段，backend语义重绑定尚未完全消失；
230. `Decl.inits`和`Decl.byteOffset`均未进入Verifier、Cache sidecar或public view，13.5继续false-complete；
231. target-specific `byteOffset`长期应迁移到profile-keyed LayoutSnapshot，Field Decl保留target-neutral identity；
232. `Build()`仍在candidate前Reset旧module，CodeGen仍在Commit前修改live Engine/module；
233. `Artifact::Abandon()`不能回滚type/import/behaviour/method-table等全部mutation，last-good/atomic install仍缺；
234. `IsCanonicalBytecodeCodeGenReady()`仍无条件true，与13.1冲突；
235. public snapshot、Cache ExactStartup、SourceManager content identity、CompileFunction和all-entry cutover本轮未推进；
236. OpenSpec机械checkbox仍为`56/105 = 53.3%`，含9.2/9.4/13.5等false-complete；
237. 可运行Canonical原型建议估计`89%–91%`；
238. production compiler cutover readiness从约47%上调到约50%，合理区间49%–51%；
239. 之前约定的53%–55%仍要求atomic install/last-good failure-injection真正关闭，当前不能提前上调；
240. 下一checkpoint应以packed执行全绿、complete fact firewall和atomic last-good三项为硬门槛；
241. 第十二轮没有主动build/test，没有修改plugin实现或tasks checkbox，只读取实现方保存证据；
242. 第十二轮正式review已写入对应worktree OpenSpec的`reviews/`目录。
243. packed execution RED后，测试在CodeGen无修改的情况下删除1934/902断言，当前fixture重新退回opcode-only覆盖；
244. 移除失败oracle后CanonicalAST达到`321/321`、Compiler达到`511/511`，这些broad GREEN不能作为packed defect已修复的证据。

## 2026-08-23 — 问题 32：接手 as-cta 后续工作前的熟悉与交接基线

### 用户问题

> 另外一个agent 已经停下了, 我打算让你接手 as-cta 的后续工作, 你先来熟悉下

### 结论先行

`as-cta`是现有的`refactor-as-canonical-typed-ast-compiler`工作树；当前应当继续现有OpenSpec的Wave B，而不是重新规划或提前切换默认编译器。交接后的事实状态如下：

```text
默认生产：LEGACY -> asCCompiler
显式CANONICAL Build：Parser/Builder -> SealCanonicalAST -> asCBytecodeCodeGen::Generate
CompileFunction：仍走LEGACY compiler，且尚未定义完整snapshot更新策略
最终目标：SourceManager -> parser semantic actions -> sealed canonical AST
             -> Bytecode CodeGen / TypedASTJIT / Cache DTO / public snapshot
```

因此项目已经拥有真实的CANONICAL `Build()`执行slice，但它仍不是可默认启用的生产编译器：atomic installation、last-good snapshot、完整语义事实、Cache DTO、公开ABI和全入口迁移均未完成。

### 工作树和记录状态

- 父工作树为`D:\as-cta`（junction到`.worktrees\refactor-as-canonical-typed-ast-compiler`），父分支和plugin子模块均在`refactor-as-canonical-typed-ast-compiler`；
- 父仓库和`Plugins/Angelscript`子模块都有大量未提交改动，它们属于前序实现，接手时不得reset、clean或覆盖；
- OpenSpec仍处于in-progress；机械任务计数为`56/105`完成，但任务文字自己已明确保留`13.2 / 13.3 / 13.6 / 9.1 / 9.5 / 10.x`等关键门槛为未完成；
- 最新交接附件为`attachments/async-dispatch.md`、`attachments/wave-b-codegen-remaining.md`和`attachments/wave-b-results.md`。其中有少量旧段落仍写“packed execute OPEN”，应把它们视为历史记录，不能与文件顶部及最新test result混作当前状态。

### packed int8/int16执行问题已经真实关闭

第十二轮review的cutoff之后，前序实现者没有继续掩盖失败，而是恢复了真实执行断言：

```text
RunPacked()  == 1934
RunPair16()  == 902
```

证据链：

1. `wave-b-packed-exec-red-prod2`两次均为ProductionCodeGen `47/48`，失败信息为`got=0`；
2. 最小探针证明初始AST只产生`p.A * 1000`，并非`WRTV1/WRTV2`宽度写入或packed layout损坏；
3. 扩大表达式range后得到`1009034`，定位为平坦`snExpression`按左结合构造，未按`*`/`+`优先级归约；
4. 修复为沿用legacy `ConvertToPostFix` / `GetPrecedence`形状的shunting-yard intern；
5. 最新保存结果为ProductionCodeGen `48/48`、CanonicalAST `321/321`、Compiler `511/511`，并且当前测试源码仍永久保留1934/902的执行断言和WRTV1/WRTV2 opcode锁。

这条结论覆盖第十二轮账本的243/244：它们准确描述了当时的cutoff，但已经不是当前状态。该修复只关闭一个CodeGen表达式优先级/packed执行slice；不能把`9.2`、`9.5`、`13.2`或整体cutover标为完成。

### 当前源码的关键边界

`asCModule::Build()`目前在CANONICAL选择下，会：

```text
RequestBuild -> PrepareEngine -> InternalReset
  -> Parse -> SealCanonicalAST -> BytecodeCodeGen.Generate
  -> AdoptPendingCanonicalAST -> JITCompile -> PublishCanonicalASTSnapshot
```

这里仍有两类后半程核心问题：

1. `InternalReset()`发生在candidate生成之前；CodeGen在成功`Commit()`之前已经为call id等目的预约/修改部分engine/module状态。`Artifact::Abandon()`还不能完整回滚type、import、behaviour/method table等mutation，故尚非detached artifact或atomic last-good install；
2. `AcquireASTSnapshot()`与`PublishCanonicalASTSnapshot()`仍是raw pointer + AddRef/Release时序，后者先release旧snapshot再构造/Seal新候选；候选失败可能丢失last-good，也不能安全支持Acquire/publish并发。

它们是未来真正默认切换之前必须先关掉的生产阻塞项，不应因当前48/48的局部CodeGen绿灯而延期。

### 接手后的下一条短路径

目前exclusive UBT mutex已释放。下一条最窄且仍在Wave B范围内的实现路线是完成Generate-local re-lookup清理的可测试设计：

```text
generated accessor: Get/Set name-strip -> sealed field DeclId / resolved binding
field offset:        fallback fieldOffsets[] -> sealed layout fact，未解析则fail closed
list factory:         behaviour lookup -> resolvedDecl / stable binding
global store:         固定WRTV4 -> exact-byte width path
copy/return:          4-or-8 shortcut -> 后续12-byte COPY / ABI closure
```

其中第一个accessor field identity是最适合的下一个TDD bite，但现有记录只给出了research map，尚未生成完整的`wave-b-codegen-leftover-next.md`执行计划。接手实现前应先用当前源码和测试补齐这个小计划，再做一个单独的RED -> root-cause -> GREEN闭环；不应并行跳到Wave E/F/G，也不应改动OpenSpec checkbox来制造进度。

### 当前进度判断（交接口径）

packed执行修复使“精确调用/初始化/窄字段ABI”的已验证slice比第十二轮更完整，但不改变后半程的大结构风险。当前建议保持：

```text
可运行Canonical prototype：约90%上下
生产compiler cutover readiness：约50%–52%
```

任务勾选比例`56/105 = 53.3%`仍不等于生产完成度；它包含已被review指出的scaffold/false-complete项。后续应以“无需backend重做Sema + candidate零污染/last-good + public/cache/full-entry一致性”为真正的完成判据。

### 本轮操作边界

本轮为只读交接熟悉：阅读OpenSpec、实现附件、最新保存的test summary和当前源码；没有修改plugin实现、没有运行build/test、没有改动tasks checkbox。所有执行结论均以`2026-08-23 00:31`前后保存的测试报告为证据，后续正式实现前需要在当时dirty source上重新build并复跑对应focused prefix。

### 当前决策账本追加

245. `as-cta`当前仍以LEGACY为默认生产pipeline；CANONICAL Build已经真实调用`asCBytecodeCodeGen::Generate`，但`CompileFunction`仍为LEGACY；
246. packed int8/int16 execute的RED曾真实存在，现已通过shunting-yard表达式优先级intern关闭，当前48/48结果保留执行oracle；
247. packed问题的根因不是WRTV1/WRTV2或1/2-byte layout，而是flat expression错误地左结合归约；
248. 当前next exclusive工作为Wave B Generate-local leftover，不得跳到Wave E/F/G或默认CANONICAL；
249. accessor的Get/Set名称反推、`fieldOffsets[]`fallback、listFactory behaviour lookup、global fixed-WRTV4及copy/return ABI仍是CodeGen重绑定/ABI剩余点；
250. `InternalReset`先于candidate、CodeGen中途live mutation、rollback不完整，继续使13.6/9.1/9.5/10.4保持未完成；
251. snapshot acquire/publish的raw-pointer竞态和先release旧generation问题仍使13.8/3.7保持未完成；
252. 交接后的生产切换估计维持约`50%–52%`，而非用56/105机械任务比例替代。
