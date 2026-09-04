# AS_TypedSemanticHIR — Typed Semantic HIR 的职责、结构与 TypedASTJIT 链路

> **所属模块**：AS_（AngelScript 引擎内核族）  
> **关注层面**：Parser AST、语义编译器、Typed Semantic HIR、Bytecode、TypedASTJIT 之间的边界  
> **当前实现状态**：`feature-as-typed-semantic-aot` 已实现；HIR 当前是同一次源码编译产生的函数级内存 sidecar，不是 Cache V2 或 `SaveByteCode` 的持久化输入  
> **关键源码**：
> `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typed_semantic_ir.h/.cpp`  
> `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h/.cpp`  
> `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/`

---

## 一、结论

项目中确实存在位于 AST 与原生代码生成之间的 HIR。它在源码中的正式名称是 **Typed Semantic IR**，核心容器是 `asCTypedSemanticFunction`，项目设计和讨论中通常简称为 **Typed HIR**。

准确的数据流不是“后端遍历原始 Parser AST 并直接生成 C++”，而是：

```text
AngelScript Source
        │
        ▼
Parser AST                         短生命周期，只表达语法结构
        │
        ▼
Semantic Compiler
        ├──────────────► Bytecode ─────────► VM / BytecodeJIT
        │
        └──────────────► Typed HIR
                              │
                              ▼
                         HIR Verifier
                              │
                              ▼
                      TypedASTJIT Analyzer
                              │
                              ▼
                         C++ Emitter
                              │
                              ▼
                    平台 C++ 编译器 / Provider
```

语义编译器在完成类型检查、重载决议、隐式转换、求值顺序、控制流目标和调用 ABI 决策时，同时把这些已经确认的结论捕获到 HIR。TypedASTJIT 后端只消费验证通过的 HIR，不重新从原始 AST 或 Bytecode 猜测语义。

因此，HIR 的核心职责可以概括为：

> 把 AngelScript 语义编译器已经做出的、不能安全从原始语法树或低层 Bytecode 重新推断的决定，完整、显式、可验证地交给后续原生代码生成后端。

---

## 二、AST、Typed HIR、Bytecode 和生成 C++ 的区别

| 表示 | 主要职责 | 已知信息 | 主要不足 |
|---|---|---|---|
| Parser AST | 表达源码语法 | `if`、循环、声明、调用、运算符和字面量的语法形态 | 最终类型、重载、隐式转换、真实调用与求值顺序尚未全部确定 |
| Typed HIR | 保存语义编译结果 | 精确类型、符号身份、转换、已解析调用、求值顺序、结构化控制流、转移目标、来源和清理计划 | 不是可执行指令，不是 SSA/CFG，也不是机器码 |
| Bytecode | 驱动 AngelScript VM | 栈/寄存器槽操作、跳转、调用和运行时 helper | 高层表达式与控制流已被压平，后端若从中生成原生代码常需反推语义 |
| TypedASTJIT C++ | Static AOT 的平台工具链输入 | 已按当前目标 Profile 和 Provider ABI 物化的函数实现 | 已是具体后端产物，不适合作为语言级优化和跨后端共享表示 |

这里需要澄清一个容易造成错误二分的术语问题：**Typed HIR 在宽泛的编译器分类上，本身就是一种 typed semantic AST/HIR。** `AST` 描述它仍然具有高层树形结构，`HIR` 描述它作为语言相关高层中间表示的职责，两者并不互斥。

当前实现最准确的结构描述是：

```text
independent, normalized, verified
typed semantic statement tree + expression DAG snapshot
```

它的 statement 仍保留 `If`、`For`、`While`、`Switch` 和 `Return` 等结构，所以不是 CFG/SSA；expression 通过 arena ID 互相引用，并携带精确类型、resolved target、evaluation steps 和 mutation 信息。它与 daScript 的最终 typed/normalized AST 处于相近的抽象层级。

但它不是“在 `asCScriptNode` 上补几个类型字段”的 Parser AST：HIR 使用独立的 symbol/expression/statement/cleanup arenas 和稳定函数内 ID，不保留 Parser node 指针，并且在发布前必须通过 verifier。本文后面凡是将 AST 与 HIR 对比，`AST` 都特指**未经完整语义解析的 Parser AST**，不是否认 HIR 属于 typed AST 家族。

这里的 TypedASTJIT 名称容易产生两个误解：

1. 它的真正输入不是未经语义解析的 Parser AST，而是 Typed Semantic HIR；
2. 它不是运行时将 HIR 即时编译成机器码的 Runtime JIT，而是 source-known Static AOT：先生成 `.jit.cpp`，再由平台 C++ 编译器构建 Provider。

---

## 三、为什么不能让后端直接使用原始 Parser AST

原始 AST 只记录“代码写成了什么样”，不能完整表示“语义编译器最后决定怎样执行”。

例如：

```angelscript
Foo(A(), B());
```

Parser AST 可以表达：

```text
Call Foo
├── A()
└── B()
```

但是原生后端还需要知道：

- `Foo` 最终选择了哪个重载；
- `A()` 和 `B()` 的精确返回类型；
- 每个参数是否插入隐式转换；
- 参数是普通值、引用、默认参数、隐藏参数还是 receiver；
- 调用目标是脚本函数、系统函数还是 import slot；
- 调用应走直接 Native、桥接 thunk、Provider，还是保留 VM 路由；
- 参数真实的求值顺序；
- 是否产生临时对象、异常边界和退出清理。

当前 maintained fork 的普通调用参数按**反向形式参数顺序**物化。因此 HIR 不仅要记录：

```text
formal[0] = A()
formal[1] = B()
```

还必须记录权威执行序列：

```text
evaluationSequence = [B(), A()]
```

如果 C++ 后端只依赖 AST 的子节点顺序，就可能在无副作用表达式上看起来正确，却在参数带副作用时产生与 VM 不同的结果。

另一个例子是：

```angelscript
Values[GetIndex()]++;
```

HIR 必须明确保存：

- mutation value 和 mutation target 的权威求值阶段；
- `GetIndex()` 只求值一次；
- target 只存储一次；
- postfix 表达式返回旧值，而不是写回后的新值；
- 中途失败时的异常状态和清理边界。

若没有 HIR，这些决策就必须由每个后端重新实现，相当于在 JIT 后端中再维护半套 AngelScript 语义编译器。

---

## 四、HIR 的数据结构

HIR 是**函数级、arena-backed、ID 引用**的数据结构。主要节点不构成一张互相持有的 Parser AST 裸指针图，而是使用函数内整数 ID：

```cpp
asTypedSemanticSymbolId
asTypedSemanticExpressionId
asTypedSemanticStatementId
asTypedSemanticCleanupPlanId
```

核心容器可概括为：

```text
asCTypedSemanticFunction
├── declaration
├── header
│   ├── body ownership / calling convention
│   ├── invocation kind
│   ├── receiver shape
│   ├── hidden/output argument traits
│   ├── returns-on-stack
│   ├── suspend / exception-cleanup traits
│   └── function cleanup plan
├── symbols[]
├── expressions[]
├── statements[]
├── cleanupPlans[]
└── rootStatement
```

### 4.1 Function Header

函数头不是简单的声明字符串。它保存后端正确构造入口 ABI 所需的信息，包括：

- declaration 与 raw trait 摘要；
- body owner 和调用约定；
- global、final instance、external implicit-this、mixin 等 invocation 形态；
- receiver 的来源与参数位置；
- hidden argument、output argument 和 returns-on-stack；
- suspend、exception-cleanup 和 cleanup-plan 状态；
- compile-out / call-rewrite 相关特征。

### 4.2 Symbols

Symbol 节点区分：

```text
Receiver
Parameter
Local
```

每个 symbol 保存函数内唯一 ID、名字、精确 `asCDataType` 和 source span。后端引用的是 symbol 身份，而不是靠变量名称匹配，因此能正确处理嵌套作用域、同名变量和隐式 receiver。

### 4.3 Expressions

当前主要 expression kind 包括：

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

表达式节点除精确类型和 operands 外，还可保存：

- literal 的确定性位表示；
- global property 身份；
- 已解析函数和稳定 target provenance；
- formal argument mapping；
- source/default/hidden/receiver argument origin；
- source ordinal 与权威 evaluation sequence；
- native call requirement；
- mutation target、mutation value 和 postfix-old-value；
- safepoint 和 processed/authored/generated source provenance；
- 明确的 unsupported reason。

### 4.4 Statements

当前 statement kind 包括：

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

statement tree 保留 Bytecode 中已经被跳转指令压平的结构信息，例如：

- loop condition/body/increment 等显式 phase；
- `continue` 应进入 increment 还是 condition；
- `break` 和 `continue` 对应的确切 loop/switch statement ID；
- switch normalization 和 case 元数据；
- 控制转移退出了哪些作用域；
- 转移需要执行哪个 cleanup plan。

### 4.5 Cleanup Plans

HIR 不假设 C++ 自动生命周期必然等价于 AngelScript。函数和控制转移都可以关联显式 cleanup plan，并记录 cleanup plan 是：

- 已验证为空；
- 已验证并包含清理动作；
- 尚未证明；
- 当前后端不支持。

当前 TypedASTJIT 的初始支持面仍以 scalar/control-flow 为主，通常要求 cleanup 已被证明为空。数据模型先明确表达生命周期边界，后端再决定支持或回退。

---

## 五、HIR 如何产生和发布

HIR 不是编译完成后重新遍历 AST 的独立 pass，而是由 `asCTypedSemanticIRBuilder` 在现有语义编译路径中同步捕获：

```text
编译某个 AST 节点
    ├── 解析符号和重载
    ├── 做类型检查与隐式转换
    ├── 决定真实求值顺序
    ├── 生成 Bytecode
    └── 把已确认语义写入 Typed HIR builder
```

单函数捕获使用事务式发布：

1. Engine 在 `Create()` 前冻结是否启用 Typed Semantic IR capture；
2. `asCCompiler::CompileFunction()` 为捕获开启的函数创建 builder；
3. Parser AST 只在函数编译期间存在；
4. 语义编译器正常产生 Bytecode，同时通过 `asCExprContext` 等路径传播 HIR expression ID 和参数来源；
5. Bytecode 正常完成 `FinalizeFunction()`；
6. HIR builder 完成 root、cleanup、control target 和函数 trait；
7. `VerifyTypedSemanticFunction()` 验证整份 HIR；
8. 只有验证通过，才通过 `SetTypedSemanticFunction()` 一次性发布到 `asCScriptFunction`；
9. 编译失败、验证失败或捕获关闭时，不留下半份 HIR。

Bytecode 和 HIR 是同一语义编译过程的两个产物，但 HIR 当前不是 Bytecode 生成的输入。Capture 开关不得改变原始 Bytecode，项目用 capture-on/capture-off parity 测试保持这一点。

---

## 六、所有权与生命周期

当前所有权关系是：

```text
asCScriptFunction
    └── owns asCTypedSemanticFunction
```

函数销毁时会先丢弃 HIR，再释放 HIR 中非 owning 的类型和函数语义引用。当前内存 HIR 虽然主要使用 arena ID，但仍可能包含：

- `asCDataType`；
- Engine-local function ID；
- 只在当前 Engine/module graph 中有意义的非 owning 语义坐标。

因此它目前不是可以直接 memcpy 或原样序列化到另一个 Engine 的 pointer-free DTO。稳定 module/function/type provenance 与 Engine-local lookup ID 必须严格区分。

当前规则是：

- 不进入公开 `angelscript.h` ABI；
- 不进入 `SaveByteCode`；
- 不从 `.hir.txt` / `.hir.json` Dump 回读；
- 不从 Bytecode 重建；
- TypedASTJIT 只同步消费同一次源码编译产生并验证通过的内存 HIR。

`refactor-as-primary-engine-typed-ast-generate` 计划引入可 remap 的 Cache V2 TypedHIR sidecar，但该 change 当前仍是 plan-only，不能当成现有实现。

---

## 七、HIR Verifier 的职责

Verifier 是 TypedASTJIT 的安全边界，而不是仅供调试的检查器。它验证的主要不变量包括：

- root statement 存在；
- arena ID 连续且引用不悬空；
- expression/statement/cleanup 节点形态合法；
- statement 只有一个所有者且整棵树无环；
- symbol、expression 和 statement 的精确类型一致；
- receiver 与 invocation kind 合法；
- call target、body owner 和 target provenance 一致；
- formal mapping、argument origin 和 evaluation sequence 完整；
- 每个调用参数恰好求值一次；
- mutation target/value 的顺序与单次求值成立；
- loop phase、switch normalization 和 case 关系合法；
- `break`/`continue` 指向最近的合法祖先；
- 控制转移、exited scopes 与 cleanup plan 相容；
- processed/authored/generated source provenance 没有伪造。

必须区分两个判断层次：

```text
HIR Verifier
    “这份 HIR 是否自洽、完整并忠实表达了编译器语义？”

TypedASTJIT Eligibility Analyzer
    “当前 C++ 后端是否已实现这组合法语义的安全 lowering？”
```

HIR 合法但当前后端不支持是正常情况。该函数会得到稳定的不适配原因，并按函数回退 BytecodeJIT 或 VM；这不是编译器错误。

---

## 八、TypedASTJIT 如何消费 HIR

TypedASTJIT 生成任务要求：

- BackendId 为 `typed-ast`；
- capture profile 为 `VerifiedTypedHIR`；
- snapshot 中的 `VerifiedTypedHIR` 与 `asCScriptFunction::GetTypedSemanticFunction()` 是同一份对象；
- 函数、模块和 Engine graph 来自这次 source compile；
- 不接受 serialized/reconstructed/stale/cross-Engine HIR。

随后按以下步骤处理：

```text
Verified Typed HIR
    │
    ├── 建立 UFUNCTION root 和脚本调用 closure
    ├── 从 HIR 收集稳定依赖和 Native route requirement
    ├── Analyzer 判断当前函数是否可 lower
    ├── Emitter 生成结构化 C++ body
    ├── 生成 VM/Raw/Parms Provider entry
    └── 不支持的函数保留 VM/BytecodeJIT fallback
```

Analyzer 和 Emitter 不使用 `GetByteCode()` 重新解释函数语义。Bytecode 仍是独立正确性基线和后备执行层。

---

## 九、简化示例

源码：

```angelscript
int Calculate(int A, int B)
{
    int X = A + B;

    if (X > 10)
        return X * 2;

    return X - 1;
}
```

概念化 HIR 如下；这不是正式 Dump 格式：

```text
FunctionHeader
  Declaration: int Calculate(int, int)
  ReturnType: int32
  InvocationKind: Global
  CleanupPlan: VerifiedEmpty

Symbols
  S0 = Parameter A : int32
  S1 = Parameter B : int32
  S2 = Local X     : int32

Expressions
  E0 = Symbol S0                  : int32
  E1 = Symbol S1                  : int32
  E2 = Binary Add(E0, E1)         : int32

  E3 = Symbol S2                  : int32
  E4 = Literal 10                 : int32
  E5 = Binary Greater(E3, E4)     : bool

  E6 = Symbol S2                  : int32
  E7 = Literal 2                  : int32
  E8 = Binary Multiply(E6, E7)    : int32

  E9  = Symbol S2                 : int32
  E10 = Literal 1                 : int32
  E11 = Binary Subtract(E9, E10)  : int32

Statements
  T0 = LocalDeclaration S2, initializer E2
  T1 = Return E8
  T2 = Block [T1]
  T3 = If condition E5, then T2
  T4 = Return E11
  T5 = Root Block [T0, T3, T4]
```

后端不需要重新判断 `+` 是整数还是浮点运算，也不需要通过跳转反推 `if`，因为这些结论已经由语义编译器固化在 HIR 中。

---

## 十、当前支持面和回退边界

当前 TypedASTJIT 的实现核心偏向 scalar/control-flow，包括：

- bool、整数、浮点和 enum；
- literal、symbol、conversion；
- unary/binary、comparison、bitwise、short-circuit；
- 局部变量；
- assignment/inc/dec 的单次求值；
- `if`、`for`、`while`、`do-while`；
- `switch/case`；
- `break`、`continue`、`return`；
- 一部分经过审查的脚本调用和 Native bridge；
- 调用依赖闭包、Provider entry、execution profile；
- 直接递归所需的 native frame budget 和异常状态边界。

当前仍会 fail-closed 或回退的典型能力包括：

- 复杂对象构造、析构和非空 cleanup plan；
- reference/out、handle 和 container；
- 普遍的 property/object access；
- mutable global 和未闭合的 import/global 生命周期；
- lambda 和 synthesized lifecycle；
- suspend/coroutine；
- source-level `try/catch`；
- 无法证明 ABI 安全的 Native 调用；
- 必须保留 Blueprint、RPC、virtual dispatch 或反射路由的调用。

这些边界不一定意味着 HIR 永远无法表达，而是当前 HIR 捕获、runtime contract 或 C++ emitter 尚未形成可验证的完整闭环。

---

## 十一、HIR 不是什么

### 11.1 不是 LLVM IR

当前 HIR 没有 LLVM IR 的基本块、SSA value、Phi、dominance、显式 load/store、target data layout 和异常落地结构。它保留表达式与结构化 statement，属于语言语义层的高层 IR。

### 11.2 不是第二套 Bytecode

HIR 不能直接交给 AngelScript VM 执行，也没有替代已有 Bytecode。Bytecode 始终是正确性基线和普遍 fallback。

### 11.3 不是 Runtime JIT 输入

当前 TypedASTJIT 是生成 C++ 的 Static AOT。它不在游戏运行时把 HIR 编译成机器码，也没有 Runtime 热度、OSR 或 deoptimization 生命周期。

### 11.4 不是原始 AST 的长期保存版本

HIR 保存语义结果，不保存所有 parser 细节、表面括号、糖语法原貌或完整 token tree。

### 11.5 当前不是持久化缓存格式

内存 HIR 仍带 Engine 语义坐标。未来若进入 Cache V2，必须使用独立版本的 pointer-free sidecar DTO、稳定 key 和 restore 后 verifier，不能直接序列化当前对象布局。

---

## 十二、HIR 的设计价值

### 12.1 避免后端重新发明语义编译器

所有后端共享前端已经确定的类型、重载、转换、求值顺序和控制流语义，减少 C++、LLVM、MIR 等后端之间的语义漂移。

### 12.2 建立前端与后端边界

前端负责“程序是什么意思”，后端负责“如何在目标执行模型中实现”。后端不应重新做名称解析和重载决议。

### 12.3 保留 Bytecode 已经压平的信息

结构化控制流、receiver、argument origin、call rewrite、mutation 单次求值、cleanup 和 source provenance 可以直接用于代码生成和诊断。

### 12.4 提供确定性验证和测试面

arena ID、snapshot、deterministic dump 和 verifier negative cases 让 HIR 可以独立于某个后端验证；capture-on/off parity 保证它不会反向改变 Bytecode。

### 12.5 支持逐函数安全降级

合法且受支持的函数进入 TypedASTJIT；合法但后端尚不支持的函数回退；缺失、过期或验证失败的 HIR 不进入原生后端。

---

## 十三、关键源码索引

| 主题 | 路径/入口 |
|---|---|
| Typed ID、node kind、function arena | `ThirdParty/angelscript/source/as_typed_semantic_ir.h` |
| HIR verifier、dump、snapshot | `ThirdParty/angelscript/source/as_typed_semantic_ir.cpp` |
| HIR builder | `ThirdParty/angelscript/source/as_compiler.cpp` 中 `asCTypedSemanticIRBuilder` |
| 单函数编译和发布 | `asCCompiler::CompileFunction()` / `TakeVerifiedFunction()` / `SetTypedSemanticFunction()` |
| expression HIR 身份传播 | `asCExprContext::typedSemanticExpression` |
| HIR 函数所有权 | `as_scriptfunction.h/.cpp` |
| capture 冻结配置 | `as_scriptengine.h/.cpp`、`Core/AngelscriptEngine.h/.cpp` |
| generation snapshot | `StaticJIT/AngelscriptStaticJITGenerationSnapshot.h/.cpp` |
| TypedASTJIT eligibility | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITAnalyzer.cpp` |
| TypedASTJIT C++ 发射 | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEmitter.cpp` |
| TypedASTJIT 编排和 Provider 输出 | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITBackend.cpp` |
| HIR 编译器测试 | `AngelscriptTest/AngelScriptSDK/Compiler/TypedSemanticIR/` |
| TypedASTJIT 测试 | `AngelscriptTest/StaticJIT/TypedASTJIT/` |

---

## 十四、最终判断

当前实现可以准确描述为：

> AngelScript 原有语义编译器在正常生成 Bytecode 的同时，捕获一份函数级 Typed Semantic HIR；HIR 经过严格 verifier 后，由 TypedASTJIT 直接生成结构化 C++，接入 StaticJIT Provider，并对不支持的函数保留 BytecodeJIT/VM 回退。

HIR 的目标不是增加一层抽象，而是保证：

```text
TypedASTJIT 生成的原生实现
        ≡
AngelScript 语义编译器已经确认的真实语义
```

它最重要的价值集中在重载与转换、参数求值顺序、mutation 单次求值、receiver、结构化控制转移、cleanup、source provenance 和 Native ABI 等容易产生隐蔽语义差异的边界上。
