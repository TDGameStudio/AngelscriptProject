# CANONICAL Parser/Sema 编译生命周期复核

日期：2026-08-27  
Worktree：`D:\as-cta`  
Change：`refactor-as-canonical-typed-ast-compiler`

## Review 结论

当前实现已经做到：sealed Canonical AST 是 CANONICAL Bytecode CodeGen、
TypedASTJIT/AOT 和 public snapshot 的直接输入；dump 与已经退役的 HIR 都不在
生产输入链上。

当前实现尚未做到：CANONICAL Sema 完全由 pointer-free typed Parser actions
构造。原生 Parser 在任何路线下都会创建 `asCScriptNode`；CANONICAL Parser
虽然已经直接发布大量 declaration/type actions，但函数体、表达式、语句和
若干 initializer/default 仍通过 `ActOnParsed*`、`*FromNode` 和
`InternParsed*` 遍历 native node 的 kind、token 与 child 链来重建 Canonical
Expr/Stmt。这是“Parser-node semantic replay”，不是简单的命名转换，也不是
dump/readback。

保留 `asCScriptNode`、Parser、Builder、`asCCompiler` 和显式 LEGACY 是当前
change 的明确范围。需要删除的是 CANONICAL 对 native tree 的语义依赖，而
不是 native tree 本身。

## 当前主编译生命周期（UE staged build）

1. UE 预处理源码，创建临时 `asCModule`，导入依赖，并通过
   `AddScriptSectionWithSourceProvenance()` 安装 processed source 与 authored /
   generated provenance。
2. `BuildParallelParseScripts()` 按 section 创建 `asCParser`。当 Engine 显式
   选择 CANONICAL，或 module 要求保留 AST snapshot 时，Builder 创建
   `asCASTContext + asCSema`，并把同一个 Sema 挂到各 Parser。
3. Parser 始终构造 native `asCScriptNode`。与此同时，已有 typed action 的
   declaration/type 直接进入 Sema；尚未迁移的 body/expr/stmt 则在 node 完成
   后进入 semantic replay adapter。
4. `BuildGenerateTypes()` 和 `BuildGenerateFunctions()` 仍通过 Builder/native
   parse tree 建立 Engine-local Runtime type/function/global/import shells。Canonical
   declaration 通过 stable key 与 generation-local Runtime bridge 绑定这些对象。
5. 全模块完成 class layout、global storage allocation 和 function layout。
   CANONICAL 使用不调用旧 global-initializer compiler 的 layout 路线；LEGACY
   保持原实现。
6. CANONICAL Stage 3 调用 `SealCanonicalAST()`：解析 deferred name、lexical
   scope、field layout 与 lambda capture，拒绝 Sema diagnostics，验证并冻结
   AST，再绑定 exact generated Runtime identities。
7. CANONICAL 从 Builder `TakeCanonicalAST()`，调用
   `asCBytecodeCodeGen::GeneratePreparedModule(AST, Builder)`；LEGACY 则调用
   `BuildCompileCode()` / `asCCompiler`。一次 build 只有一个 Bytecode publisher，
   CANONICAL 失败不得静默 fallback 或合并 LEGACY facts。
8. 成功后 module 收养 pending Canonical context，删除 Builder。Builder 析构
   释放 Parser 及其 `FMemStack` native tree；module JIT compile，并按 retention
   policy 发布 sealed snapshot lease。
9. Stage 4 初始化 globals，并映射 coverage executable lines。

默认选择目前仍为 LEGACY；这属于最终 cutover 前的门禁，不表示 CANONICAL
CodeGen 不存在。

## “命名适配器读取 asCScriptNode”具体指什么

当前主要适配器分为四层：

- `ActOnParsedExpr()` / `ActOnParsedStmt()`：Parser 完成一个 native 节点后调用
  的入口 dispatcher；
- `ActOnExprFromNode()` / `ActOnStmtFromNode()`：递归检查 `nodeType`、
  `tokenType`、`firstChild/lastChild/next` 并创建 Canonical Expr/Stmt；
- `InternParsedDeclRef()`、`InternParsedCall()`、`InternParsedExprTerm()` 和
  compound/control helpers：从 native scope/name/argument/operator/child 排列
  重新执行 lookup、优先级、receiver、control 与去重逻辑；
- `ActOnFunctionBodyFromNode()`、parameter/enumerator/variable initializer
  `*FromNode`：把事后重建出的 Expr/Stmt 附着到 Canonical Decl。

例如 `return A + 1;`：Parser 会先得到 `snReturn`，其 child 是扁平的
`snExpression`/term/operator/term native 结构；`ActOnParsedStmt()` 再进入
`ActOnStmtFromNode(snReturn)`，后者调用 `ActOnExprFromNode()`；表达式 adapter
从 child 链重新识别 `A`、`+`、`1`，对 `A` 做 decl lookup，对 `1` 创建 typed
literal，按自己的 precedence 逻辑创建 binary Expr，最后创建 return Stmt。
因此 Canonical AST 虽是独立存储，语义构造仍依赖旧树的内部形状。

`BindParsedExpressionIdentity()` / `FindParsedExpressionIdentity()` 是过渡期
桥接：它把 native node pointer（并带 section/offset fallback）映射到已经直接
创建的 `ExprId`，让后续 replay 尽量复用 typed action 的结果。该桥接可以减少
重复创建，但只要 Sema 仍遍历 node child 来决定语义，action-only 边界就没有
完成。

当前源码快照中，Parser 有 111 个 `sema->ActOn*` 调用，其中 19 个
`ActOnParsedExpr`、48 个 `ActOnParsedStmt`，另有 6 个显式 `*FromNode` 调用。
这些数字只描述迁移边界规模，不是 API 或完成率。

## 已迁移部分与未迁移部分

已经明显向 typed-action 迁移的部分包括 translation unit、namespace、enum、
typedef、import、record/function/lambda header、parameter、declaration QualType、
cast/construct target、局部 declaration identity 等。Parser 在识别这些语法时
构造 action payload，Sema 返回 DeclId/Type/ExprId，而不是由 Sema 再遍历完整
declaration node。

仍属高风险过渡边界的部分包括 function/lambda body、通用 literal/decl-ref/
call/unary/binary/assignment/condition/postfix 表达式、block/return/if/loop/
foreach/switch/transfer 语句，以及部分 default/initializer/property/lifetime
附着。Builder 的 CANONICAL Runtime-shell 准备也尚未完全收窄为“只投影 Sema
已经决定的事实”。

## 目标生命周期

目标不是停止创建 native AST，而是让 Parser 同时维护两条互不授权的输出：

```text
tokens / grammar
    |\
    | +--> asCScriptNode                  LEGACY / recovery / reference
    |
    +----> pointer-free action + IDs
               -> Sema lookup/rewrite/conversion/lifetime/control
               -> Canonical Decl/Type/Expr/Stmt
               -> verify + seal
               -> Bytecode CodeGen / TypedASTJIT-AOT / snapshot views
```

表达式父节点应直接接收 child `ExprId` 与 operator；语句父节点应接收 condition
`ExprId`、body/branch `StmtId`；控制流使用显式 begin/phase/finish handle；function
body 直接接收完成的 block `StmtId`。Sema 不再接收 `asCScriptNode*` 来决定生产
语义。native tree 可以继续完整构造并服务 LEGACY。

## 当前判断

后端边界已经是 AST-first，AOT 不需要 dump；前端仍是 hybrid。该 hybrid 在
迁移期可用，但不能作为最终 CANONICAL default 的完成证明，因为它保留了两套
grammar-shape knowledge、增量 action 与 replay 的重复 semantic work、错误恢复
node 对生产语义的耦合，以及 range/pointer identity 去重风险。

更完整的调用点审计与风险说明见
`attachments/current-compiler-lifecycle-and-parser-node-adapter-audit-2026-08-27.md`。

## 2026-08-29 CTA-S54 supersession

本 review 在第 78–82 行描述的 native node pointer + section/offset identity
桥已经退役。Canonical Sema 现在只保存精确复制的 build-local
`section + nodeKind + offset + length`，`as_sema.h/.cpp` 不再声明或存储
`asCScriptNode`，也没有 `firstChild/lastChild/->next` 遍历。冲突的 Decl、Expr
或目标 Type 绑定会保留第一个结果、给出确定性 diagnostic 并 fail closed。

精确身份迁移暴露并修复了两个旧指针模型隐藏的时序问题：cast/construct 的
目标类型曾在表达式 range 完成前绑定，函数/构造函数/lambda/record/import/
funcdef 等 declaration wrapper 也曾只绑定早期 range。现在早期 DeclContext
identity 和完成后的 Runtime-shell identity 都显式绑定到同一个 Canonical
Decl；表达式目标类型在最终或恢复 range 确定后绑定。最终 SemaAuthority
**405/405**，ProductionCodeGen + Module Snapshot + TypedASTJIT **186/186 PASS**。

这只 supersede 本 review 的 pointer/range identity 风险结论，不把整份历史
review 改写成“前端已全部完成”。完整 action-only 语言族覆盖、Sema 环境、
Frozen/Publishable 后端事实以及默认切换仍由 Tasks 4.2、5.x、9.x、10.x 和
13.2 管理。证据：
`attachments/canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`。

## 2026-08-29 CTA-S55 declaration-action closure supersession

The broad statement above that declaration-family adapters still consume
Parser nodes is now historical. After CTA-S09 through CTA-S54, the complete
maintained declaration inventory is action-driven and `as_sema*` has no native
child traversal or generic `ActOn*FromNode` / `ActOnParsed*` production API.
The retained native tree still exists independently for grammar, recovery,
LEGACY and reference testing.

Fresh completion evidence is SemaAuthority **405/405** and Frontend Parser
Declarations **18/18 PASS**. A first stale-prefix command omitted the current
`Frontend` segment, selected no tests and is explicitly excluded. Task 4.2 is
therefore closed, while type-production parity (4.3), declaration semantics
and registration parity (4.4-4.6), the full 13.2 Sema environment and default
cutover remain open. Evidence:
`attachments/canonical-declaration-sema-action-closure-gate-2026-08-29.md`.
