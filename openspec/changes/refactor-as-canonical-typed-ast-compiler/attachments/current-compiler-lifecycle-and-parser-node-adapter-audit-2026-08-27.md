# 当前编译生命周期与 Parser-node 语义适配器审计

日期：2026-08-27  
Worktree：`D:\as-cta`  
对应变更：`refactor-as-canonical-typed-ast-compiler`

## 结论

当前 CANONICAL 路线已经实现了“封存 Canonical AST 直接驱动
`asCBytecodeCodeGen` 与 TypedASTJIT/AOT”，不再通过 AST dump、HIR 或
Bytecode 反推源语义；但是它还没有实现完整的 Clang 风格
Parser-action-only 前端。`asCParser` 在 CANONICAL 编译时仍始终产生原生
`asCScriptNode`，而 `asCSema` 的函数体、表达式、语句和若干初始化器入口
仍通过命名的 `*FromNode`、`ActOnParsed*`、`InternParsed*` 适配器解释该树。

保留原生 `asCScriptNode` 本身是本变更的明确目标：它继续服务显式
LEGACY、语法/恢复、差分、参考和回滚。未完成项是 CANONICAL Sema 仍把
它当作语义输入，而不是仅把它作为独立的原生语法产物。

因此必须区分两个结论：

1. **Canonical 后端输入已独立。** `asCBytecodeCodeGen` 和
   TypedASTJIT/AOT 只读 sealed `asCASTContext`；dump 是诊断视图，不是输入。
2. **Canonical 前端构造尚未独立。** Parser/Sema 之间仍存在
   `asCScriptNode -> Canonical Expr/Stmt` 的语义回放边界，阻挡 Task 4.2、
   5.2–5.9、10.6、10.7 和最终默认切换。

## 当前完整生命周期

### 0. Engine 级编译权威选择

`FAngelscriptEngine` 创建底层 `asCScriptEngine` 时，通过
`SetCompilerPipeline()` 选择整个 Engine 的源编译路线：

- 默认仍为 `asCOMPILER_PIPELINE_LEGACY`；
- 聚焦迁移、TypedAST generation profile 或显式命令行可选择
  `asCOMPILER_PIPELINE_CANONICAL`；
- 不存在 `dual`；同一次 build 只能有一个 Bytecode 发布者；
- CANONICAL 失败时不得静默调用 LEGACY `asCCompiler` 或合并其语义事实。

当前默认保持 LEGACY 是有意的过渡门禁，不是最终状态。

### 1. 预处理与 Builder source session

UE host 收集、预处理 `.as` 源码并将每个 section 交给模块
`asCBuilder`。Builder 保存本次构建的 `asCScriptCode`，并通过
`asCSourceManager` 为 Canonical AST 建立 snapshot-local 的源文件、范围和
provenance 身份。

### 2. Stage 1：Parser 与声明/type shell

`BuildParallelParseScripts()` 执行以下工作：

1. `AttachCanonicalSemaIfNeeded()` 在 CANONICAL 或保留 AST snapshot 时创建
   `asCASTContext` 和 `asCSema`，并建立 translation unit；
2. 每个 section 创建一个 `asCParser`，将同一个 `asCSema` 连接到 Parser；
3. Parser 正常 tokenize/parse，并**始终**构造原生 `asCScriptNode` 树；
4. Parser 同时调用 Sema action，逐步构造 Canonical Decl/Type/Expr/Stmt；
5. section parse 完成后进行 deferred name 与捕获 lambda 使用检查。

声明头迁移已经取得实质进展。namespace、enum、typedef、import、普通函数
family、record、全局/字段/局部变量、class default、funcdef、access
specifier、parameter、declaration QualType、cast/construct target 和 lambda
header 已经有 pointer-free 或 ID-based typed actions。Parser 中仍可看到
大量 direct action 调用，这部分方向正确。

### 3. 当前混合边界：Parser-node replay

问题发生在 Parser 已经构造完整/局部 `asCScriptNode` 后，再把节点交给
Sema 解释：

- `ActOnFunctionBodyFromNode()` 把 `snStatementBlock` 重建为函数 body；
- `ActOnParsedExpr()` / `ActOnExprFromNode()` 根据 `nodeType`、`tokenType`、
  `firstChild/lastChild/next` 重建 typed expression；
- `ActOnParsedStmt()` / `ActOnStmtFromNode()` 重建 block、return、if、loop、
  foreach、switch/case 和 transfer；
- `InternParsedCompoundStmt()` 递归遍历 child list，并用 range/owner 去重；
- parameter default、enumerator/variable initializer、property/default 等命名
  adapter 仍接收 Parser node；
- `BeginParsedControl()` 先创建控制流占位，以便 parse body 时让
  break/continue 绑定正确目标，完成后再由 node adapter 填充结构。

2026-08-27 的源码调用点快照：Parser 中共有约 **111** 个
`sema->ActOn*` 调用点，其中 **19** 个为 `ActOnParsedExpr`，**48** 个为
`ActOnParsedStmt`，另有函数体/初始化器等显式 `*FromNode` 入口。该计数只
用于说明剩余边界规模，不是完成率或稳定 ABI。

表达式适配器的典型行为包括：

- `snConstant` 重新读取 token 和源文本生成 literal；
- `snVariableAccess` / `snFunctionCall` 再做 decl/callee lookup；
- `snExpression` 按 Parser 的扁平 `term/op/term` 布局，重新执行一套与
  `asCCompiler::ConvertToPostFix` 对齐的优先级整理；
- `snAssignment`、condition、construct、cast、init-list 等递归读取 children；
- 用 node/section/range identity 查找 Parser 前面已经发布的部分 typed
  identity，混合“直接 action”与“事后回放”结果。

语句适配器的典型行为包括：

- 通过 `snIf/snWhile/snFor/snDoWhile/snForEach/snSwitch/snCase` 判断结构；
- 依靠 child 顺序推断 condition、body、increment、case value；
- 通过 source range 查找此前增量 action 已创建的节点，避免重复创建；
- 对 loop/switch 采用 create/push/fill/finish 的混合协议。

这不是 dump/readback，也不是 HIR，但仍是 CANONICAL 对原生 AST 内部形状
的生产语义依赖。

### 4. Stage 1/2：原生 Builder 仍建立 Runtime shells

`BuildGenerateTypes()`、`BuildGenerateFunctions()`、`ParseScripts()` 仍由
`asCBuilder` 遍历原生 Parser tree，注册/准备 `asCObjectType`、
`asCScriptFunction`、global、import、factory 和 class layout 所需的 Runtime
shell。Canonical declaration 通过 stable declaration key 与 exact
Runtime type/function bridge 绑定这些 transient Runtime objects。

这层 Runtime shell 仍然必要，因为 VM、GC、绑定和 Unreal 集成使用
Engine-local 类型/函数对象；问题不在于 Runtime object 存在，而在于最终
CANONICAL declaration/type 语义不应由 Builder node-walk 决定或补写。
Builder 可继续作为显式 LEGACY 实现，但 CANONICAL 路线需要把它收窄为
“消费 Sema 已确定事实并准备 Runtime 容器”的投影/安装层。

### 5. Layout 与 Canonical seal

类型、类、函数和 Runtime 参数布局完成后：

- LEGACY 会在 layout 阶段调用旧的 global initializer 编译；
- CANONICAL 使用 `BuildLayoutFunctionsWithoutGlobalInitializers()`，不允许
  旧 compiler 提前发布 global initializer Bytecode；
- `SealCanonicalAST()` 执行 deferred name、lexical scope、script field
  layout、lambda capture validation；
- 有任何 Canonical diagnostic 时 fail closed；
- `asCASTContext::Seal()` 运行图验证并冻结所有节点；
- generated/runtime identities 在 sealed graph 与 prepared Runtime shell 之间
  做 exact structural binding。

seal 之后 Backend 只获得只读 AST，不再执行 Sema，也不允许修补节点。

### 6. Stage 3：两个明确分开的 Bytecode 发布路线

CANONICAL 路线：

```text
SealCanonicalAST
  -> TakeCanonicalAST
  -> asCBytecodeCodeGen::GeneratePreparedModule(AST, Builder)
  -> candidate commit/promotion
```

该路线不调用 `asCCompiler::CompileFunction()`。CodeGen 从 sealed Decl/Expr/
Stmt、resolved targets、types、cleanup/control facts 直接产生 VM Bytecode 和
函数元数据。

LEGACY 路线：

```text
asCBuilder::BuildCompileCode
  -> factories/functions/globals
  -> asCCompiler::CompileFunction / CompileFactory / ...
  -> VM Bytecode
```

如果 LEGACY build 仅因诊断保留策略附带创建了 Canonical snapshot，该
snapshot 也不能伪装成其 Bytecode 的编译权威；TypedAST production generation
profile 因此明确选择 CANONICAL。

### 7. Publication、VM 与 StaticJIT/AOT

Stage 3 成功后，模块收养 pending Canonical context，Builder/Parser/native
tree 随 build 生命周期销毁；retention policy 决定是否发布 sealed snapshot
lease。Stage 4 初始化 globals，随后 VM 可执行 Bytecode。

TypedASTJIT/AOT generation 对 snapshot 获取只读 lease，并以
`ASTContext + stable DeclId/function key` 直接发射 C++/native artifact。AST
text/JSON dump 只供 list/dump/query/verify/diff 等诊断，不参与生成、缓存
identity 或成功判定。HIR model 已在本轮物理删除。

## 为什么该边界危险

1. **双重 grammar knowledge。** Parser 与 `ActOnExprFromNode`/
   `ActOnStmtFromNode` 都知道 `asCScriptNode` child 排列；新增语法必须同时
   修改两处。
2. **隐式语义漂移。** native tree 的 child 顺序或 recovery shape 改变时，
   adapter 可能仍能编译但生成错误 Canonical 结构。
3. **重复 semantic work。** call lookup、表达式优先级、conversion、control
   fill 和去重在“增量 action + replay”之间交错，容易产生 first-match、
   duplicate-range 或多 owner 问题。
4. **错误恢复与有效语义耦合。** recovery node 适合诊断/继续解析，不适合
   成为 sealed production semantic graph 的事实来源。
5. **阻挡可信默认切换。** 即使 CodeGen 已经不调用 `asCCompiler`，只要
   Canonical Sema 仍读 native tree，就还不能声明新前端独立完成。

## 目标态

目标态与 Clang 的责任边界一致，但不复制 Clang 类：

```text
token/grammar
    |\
    | +--> native asCScriptNode             (LEGACY/reference/recovery)
    |
    +----> typed Parser action payload/IDs
                 -> asCSema lookup/rewrite/lifetime
                 -> asCASTContext
                 -> Seal
                 -> BytecodeCodeGen / TypedASTJIT / public views
```

Parser 在识别语法的当下把明确结构交给 Sema。例如 binary action 直接携带
`lhs ExprId + operator + rhs ExprId + range`；if action 携带 condition/then/
else IDs；function body action携带已构造的 block StmtId，而不是完整
`asCScriptNode*`。Sema 负责 lookup、overload、conversion、rewrite、cleanup
和 control target，并返回 typed IDs。原生 tree 可以同时照旧构造，但不再
作为这些 action 的输入。

## 建议迁移顺序

每一片严格遵守 OpenSpec AST-first RED -> GREEN -> downstream gate：

1. **叶子表达式**：literal、decl-ref、paren/cast；移除最小
   `ActOnParsedExpr` 调用点。
2. **表达式组合**：unary/binary/logical/conditional/assignment，以 ExprId
   直接组合，并删除 Sema 内部 postfix 重建。
3. **call/index/property/mutation**：由 typed action 携带 receiver、argument
   IDs、source order 与明确 syntax traits，Sema 只做一次 resolution/rewrite。
4. **简单语句**：expr/return/block，由 StmtId 直接组装。
5. **控制流协议**：if/loop/foreach/switch 采用显式 begin/phase/finish IDs，
   break/continue 在 Sema control stack 内绑定，不回读 child 顺序。
6. **initializer/default/property/lambda body/lifetime**：删除剩余命名
   `*FromNode` adapter。
7. **Builder authority 收窄**：CANONICAL Builder 只安装 Sema/AST 已确定的
   declarations/types/layout references；LEGACY node-walk 保留在独立路线。
8. **最终 forbidden scan**：CANONICAL Sema/CodeGen 路线不得有生产
   `asCScriptNode*` 语义入口；Parser/native AST/Builder/Compiler 与显式
   LEGACY 必须继续存在。

## 当前完成与未完成边界

已经完成：

- sealed Canonical AST 到 Bytecode CodeGen 的直接生产路线；
- sealed Canonical AST 到 TypedASTJIT/AOT 的直接路线；
- dump 非输入边界；
- HIR capture/model/storage/consumer 的物理退役；
- 多数 declaration header typed actions；
- Engine 级 LEGACY/CANONICAL 单选和 unknown/dual 拒绝。

仍未完成：

- body/expression/statement/lifetime 的 action-only Sema；
- type/template/contextual inference 对 Builder/LEGACY facts 的完全独立；
- CANONICAL Runtime shell 安装完全由 sealed semantic facts 驱动；
- 完整 language/cleanup/exception/debug/coverage/corpus 的 Canonical CodeGen
  闭环；
- CANONICAL 产品默认和最终 cutover gate。

该附件关闭的是“当前生命周期解释不清”的记录缺口，不关闭 Task 4.2、
5.x、10.6 或 10.7。
