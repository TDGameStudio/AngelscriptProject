# Canonical lambda storage boundary gate（2026-08-25）

## 1. “捕获 lambda”通俗解释

lambda 是一个写在表达式里的匿名函数。如果它只使用自己的参数和全局可见内容，
它就是**非捕获 lambda**：

```angelscript
StoredLambdaCallback@ Callback = function() {
    return 42;
};
```

如果 lambda 使用了外层函数的局部变量，它就是**捕获 lambda**：

```angelscript
int X = 42;
StoredCaptureCallback@ Callback = function() {
    return X; // X 来自外层作用域，所以被捕获
};
```

“捕获”的本质不是复制一段源码，而是匿名函数执行时还需要一份外层状态：

```text
非捕获 lambda
  funcdef value = { FunctionIdentity }

捕获 lambda
  完整闭包值 = { FunctionIdentity, CaptureEnvironment }
                                      |
                                      +-- X = 42
```

还要区分“捕获”和“逃逸”：捕获 lambda 在原地立即调用时，编译器可以把 `X` 作为
隐藏参数传给匿名函数，不需要长期保存环境；当 lambda 被存入变量、作为返回值离开
当前函数，或者传给可能在稍后调用的代码时，捕获环境必须跟着函数身份一起存活，这才
需要真正的 closure/闭包运行时表示。

## 2. 当前语言和 Runtime ABI 边界

当前 AngelScript `funcdef` 值保存的是可调用函数身份，间接调用使用 `CallPtr`；它
没有一个同时保存 capture environment 的槽位。因此当前 Canonical 编译器支持：

```text
非捕获 lambda -> 存入 funcdef -> 稍后 CallPtr 调用       支持

捕获 lambda   -> 在当前表达式直接调用/IIFE
              -> 把 sealed captures 作为隐藏参数传入     支持

捕获 lambda   -> 存入 funcdef/返回/逃逸
              -> 需要 {函数, 环境} 的堆闭包 ABI           当前明确拒绝
```

这不是 AST 表达不了捕获：sealed Canonical AST 已经记录 lambda declaration、精确
capture 列表和直接调用的 resolved declaration。缺少的是一种新的语言值语义、对象
生命周期、GC/引用追踪和调用 ABI。为了完成现有 AST 编译体系改造，本次没有暗中改变
AngelScript `funcdef` ABI，也没有发明未经设计的堆闭包对象。

## 3. AST-first / TDD gate

### 3.1 测试与 fixture

Sema gate 位于：

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

- `ParserStoredCapturingLambdaReportsDirectCallOnlyDiagnostic`
- 注册 host funcdef `int StoredCaptureCallback()`；测试 fork 当前 tokenizer 不产生
  `@` token，因此 fixture 使用 `asOBJ_IMPLICIT_HANDLE` 表达同一 funcdef value 边界。
- sealed dump 必须先证明 AST 中存在 `<lambda>` 和 `captures=X`。
- 然后必须得到精确、稳定的 Sema 诊断
  `capturing-lambda-cannot-escape`。

Production CodeGen gates 位于 Canonical ProductionCodeGen 测试组：

- `CanonicalStoredNonCapturingLambdaBuildPublishesCodeGenAndExecutes`
  - 非捕获 lambda 存入 funcdef local；
  - `Build()` 成功并由 `CANONICAL_CODEGEN` 发布；
  - 后续间接调用返回 `42`；
  - 函数 `F` 的 bytecode 包含 `asBC_CallPtr`。
- `CanonicalStoredCapturingLambdaRejectedBeforePublication`
  - 捕获 `X` 的 lambda 尝试存入 funcdef local；
  - `Build()` 必须在 Sema/seal publication 前失败；
  - Engine message 必须包含稳定诊断；
  - Canonical 与 legacy compiler publisher 均不得发布函数。

### 3.2 RED 证据

测试构建：

`Saved/Build/cta-lambda-storage-gates-red-build/20260825_081013_429_fc98c145`

有效 Sema RED：

`Saved/Tests/cta-stored-capture-sema-red2/20260825_081140_037_18ef350b`

- 新测试正确失败：sealed AST 已有 `captures=X`，但诊断为空；
- 该 class run 共 `283` 个测试，另有一个与本切片无关的既有
  `StringLiteralUsesEngineStringTypeForNativeCallResolution` 失败，因此本记录只把新测试
  的预期失败作为 RED 证据，后续用 exact focused run 证明 GREEN。

Production RED：

`Saved/Tests/cta-stored-capture-production-red/20260825_081320_646_24fbc252`

- `Build()` 原本也会失败，但失败发生得太晚；
- 后端报 `Canonical CodeGen failed code=-6 ... error=-6`；
- 没有 `capturing-lambda-cannot-escape`；
- 这证明旧行为只是由 Runtime 函数签名不匹配偶然拦住，并非稳定的语言语义边界。

## 4. 最小 production 实现

### `as_sema.h` / `as_sema_decl.cpp`

新增 `asCSema::ValidateCapturedLambdaUses()`：

1. 枚举带 `asAST_TRAIT_LAMBDA` 且 capture 列表非空的 declaration；
2. 在整个 sealed candidate graph 中查找 `asAST_EXPR_CALL`；
3. 只有 `resolvedDecl` 精确指向该 lambda declaration 的直接 call 才属于当前支持
   的隐藏参数调用；
4. 如果捕获 lambda 没有这种精确直接调用，就产生 range-keyed、幂等的
   `capturing-lambda-cannot-escape`。

采用 whole-graph 检查而不是只看 lambda 的父节点，是为了让 assignment、conversion、
return、call-argument 等 wrapper 无法隐藏逃逸。

### `as_parser.cpp` / `as_builder.cpp`

- Parser 在 `ResolveDeferredCalls()` 之后执行该验证；
- Builder 在读取 Sema diagnostics 并发布 seal 之前再次执行，覆盖 staged Builder 和
  `CompileFunction` 路径；
- 诊断以 source range 为键，因此重复运行不会产生不稳定的重复消息。

## 5. GREEN 和回归证据

- 构建：
  `Saved/Build/cta-lambda-storage-boundary-green-build/20260825_081443_293_cf4ca6b6`
- exact Sema：
  `Saved/Tests/cta-stored-capture-sema-green/20260825_081516_230_93475acf`
  — **1/1 PASS**
- stored non-capturing lambda：
  `Saved/Tests/cta-stored-noncapture-green/20260825_081554_307_ed3a544b`
  — **1/1 PASS**，真实 `CallPtr` 执行返回 `42`
- stored capturing lambda rejection：
  `Saved/Tests/cta-stored-capture-production-green/20260825_081633_219_751a57d3`
  — **1/1 PASS**，在 CodeGen/publication 前得到稳定 Sema 诊断
- 完整 Canonical ProductionCodeGen：
  `Saved/Tests/cta-production-codegen-after-lambda-storage-boundary/20260825_081716_692_911b123f`
  — **96/96 PASS**
- `CompileFunction` 直接捕获/IIFE 回归：
  `Saved/Tests/cta-compilefunction-capture-after-storage-boundary/20260825_081824_192_fa7e1164`
  — **1/1 PASS**
- StaticJIT CanonicalASTIdentity：
  `Saved/Tests/cta-staticjit-identity-after-lambda-storage-boundary/20260825_081900_886_9d3e2338`
  — **12/12 PASS**

因此当前结论不是“捕获 lambda 不支持”，而是：

```text
直接捕获调用        已支持、已回归
非捕获 lambda 存储 已支持、已执行
捕获 lambda 逃逸   在 Sema 明确拒绝
真正的堆闭包 ABI    独立未来语言/Runtime 设计，不属于本次偷渡范围
```

## 6. 对 Task 9.5 的影响

这关闭了 Task 9.5 中“lambda 存储边界不明确、只能靠晚期 CodeGen 错误偶然失败”的
缺口，但 **Task 9.5 继续保持未完成**。仍需覆盖 object/temporary、container/template、
delegate/funcdef 其他生命周期、global/import、generated/list factory、exceptional cleanup
与 suspend/resume 等完整语言面。一个未来的 heap closure 特性如需引入，必须独立定义：

- closure value layout；
- capture-by-value / capture-by-reference 语义；
- capture object construction/destruction；
- GC/refcount rooting；
- copy/move/assignment 和 equality 规则；
- direct/indirect call ABI；
- exception、suspend、hot reload 和 snapshot 行为。

本 OpenSpec 当前不以实现该新语言特性作为 Canonical AST 默认切换的前置条件；它要求
现有 ABI 的支持范围被精确表达、稳定诊断并经过 AST-first 测试。

## 7. 产品范围决定（用户确认，2026-08-25）

项目实际脚本很少使用 lambda，因此本次 Canonical AST/编译体系改造采用**最小兼容、
不扩张语言**的策略：

```text
保留  非捕获 lambda 的存储和间接调用
保留  捕获 lambda 的 direct/IIFE 调用
保留  AST dump/query/diagnostic 对 lambda 与 capture 的可见性
拒绝  捕获 lambda 的存储、返回或其他逃逸
延期  heap closure / capture environment 新 ABI
```

这意味着完整 heap closure 不是默认切换、HIR 清退或 Task 9.5 完成的前置条件。
Task 9.5 对 lambda family 的验收以本附件已经通过的三个稳定结果为准：直接捕获调用
可执行、非捕获存储可执行、捕获逃逸在 Sema 明确拒绝。后续资源优先用于项目实际依赖
的 import/global、object lifecycle、exceptional cleanup、suspend/debug metadata 和生产
入口收口。若未来真实脚本提出“保存捕获 lambda”的需求，再以独立 OpenSpec 设计
closure value layout、生命周期、GC 和调用 ABI。

## 8. 为什么项目很少使用 lambda，本次改造却频繁遇到它

lambda 在这次工作里主要是一个**编译器协议压力测试**，不代表产品代码突然需要大量
使用 lambda。普通顶层函数只需要证明“一个源码声明对应一个 Runtime 函数”；lambda
同时穿过了更多边界：

```text
外层函数
  +-- 嵌套匿名声明        -> 稳定 DeclId / FunctionKey
  +-- 外层局部变量捕获    -> 词法作用域 / Sema capture 列表
  +-- 隐藏捕获参数        -> 源语言签名与 Runtime ABI 分层
  +-- prepared shell      -> Builder 与 Canonical CodeGen 的职责边界
  +-- 多个 sibling lambda -> 不能依靠名称或顺序猜身份
  +-- 生成中途失败        -> shell、FunctionId、模块库存必须一起回滚
```

因此，lambda 暴露的问题往往不是“lambda 功能的问题”，而是所有嵌套声明、生成函数、
热重载、StaticJIT 和快照发布都会依赖的底层正确性问题。用少量 lambda 测试把这些协议
修正，是为了让整个 Canonical AST 编译链更可靠；这与鼓励业务脚本使用 lambda 是两件事。

最终范围仍按“语言兼容最小集”处理：已有、成本低且 ABI 清楚的形式继续支持；需要新
closure value、GC 和生命周期协议的捕获逃逸不进入本次改造。也就是说，删掉所有 lambda
支持会造成已有语法兼容回退，并失去一个很有价值的编译器回归探针；实现完整 C++ 式闭包
又没有当前产品收益。保留当前已验证的中间范围，是本次改造的最优取舍。
