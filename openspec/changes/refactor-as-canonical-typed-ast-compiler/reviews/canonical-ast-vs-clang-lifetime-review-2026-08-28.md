# Canonical AST 对比 Clang 22.1.8：实现架构与生命周期静态审查（2026-08-28）

## 1. 审查结论

`refactor-as-canonical-typed-ast-compiler` 的总体方向成立，不建议推倒重来。
当前已经建立的 `Parser -> Sema -> asCASTContext -> Seal/Verify -> Bytecode/AOT`
边界，以及 stable type identity 与 generation-local numeric TypeId projection 的拆分，
都是适合 AngelScript、Hot Reload、Cache 和多 backend 的正确基础。

本轮对照本地 Clang 22.1.8 官方源码后，发现当前实现最需要修正的不是 AST 是否
“像 Clang”，而是 lifetime 语义在 producer、verifier、Bytecode 和 AOT 之间还没有
形成一个单一、具名、版本化的合同：

1. Canonical publication verifier 尚未证明 cleanup 的完整性、逆序性、live-only 和
   exactly-once；
2. Bytecode 依赖当前普通 statement children 中的 cleanup，AOT 又私有地重建另一套
   lifetime proof；
3. 当前 AOT 在 `DeclStmt` 处把对象加入 active set，但本地变量的真正初始化是后续
   `Assign ExprStmt`，因此 partial construction 时会提前激活当前失败对象；
4. cleanup kind 使用 `"scope-exit"` / `"scope-release"` 字符串，foreach cleanup
   phase 还依赖固定的第四 child；
5. constructor base/member/array 尚无 committed-prefix/activation 模型，不能表达
   “第 N 步失败，只逆序销毁已经成功的 0..N-1”；
6. `asCASTContext` ownership、foreign ID 与 sealed/publication/cache admission 还有三个
   独立的高优先级健壮性缺口。

Clang 的真实做法不是把每个 initializer-abort edge 的完整 cleanup list 持久化在
AST，也不是让 AST 完全不包含 lifetime 语义，而是三层分工：

```text
Sema / AST
    exact constructor/destructor、initializer、temporary、materialization、
    lifetime extension、storage duration 等稳定语义事实

Analysis CFG（按需、可重建）
    scope/lifetime/implicit-dtor/EH 的分析投影

CodeGen cleanup stack（瞬时、backend-local）
    当前函数中已成功构造对象的 active cleanup、landing pad、label、IR address
```

因此 CTA-S53 的推荐方向是一个 Clang 启发、但适配本项目多 backend/快照要求的混合
架构：

> Sema 在 sealed Canonical snapshot 中保存 exact action、activation、region、phase
> 和 construction commit 等语义事实；一个共享、确定性、可重建的 derived lifetime
> view 证明每条控制流边的 reverse live-only cleanup；Bytecode/AOT 只拥有各自的
> cleanup stack、label、patch、slot、EH table 和 native frame lowering 状态。

这不是恢复 HIR，也不是把完整 CFG 持久化。HIR 仍然物理删除；原生 `asCScriptNode`
Parser AST / Builder / `asCCompiler` 仍按要求保留在显式 LEGACY 路径；产品默认仍为
LEGACY。

## 2. 审查范围与证据基线

本轮为只读静态审查，没有修改 Runtime、Editor、Standalone 或测试实现，也没有执行
默认切换、提交、归档或 worktree 清理。

本地证据：

- Clang/LLVM 官方源码：`D:\as-cta\Reference\llvm-project`；
- 版本：`cmake/Modules/LLVMVersion.cmake:3-10`，LLVM/Clang `22.1.8`；
- 来源与许可：`Reference/README.md:363-377`；
- 当前实现：`D:\as-cta\Plugins\Angelscript`；
- 当前 OpenSpec：
  `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler`。

本轮还使用了一个本地 Clang probe：两个顺序构造的自动对象中，第二个 constructor
抛出时，生成的 LLVM IR unwind path 只调用第一个对象的 destructor；第二个对象只在
constructor 正常返回后才成为 normal/EH cleanup 的 owning value。这个 probe 只用于
验证源码结论，没有产生仓库文件。

`openspec validate refactor-as-canonical-typed-ast-compiler` 当前通过，
`git diff --check -- openspec/changes/refactor-as-canonical-typed-ast-compiler` 无输出。
这只能证明结构和文本基本有效，不代表所有状态描述都已与 2026-08-28 的源码事实同步。

## 3. Clang 22.1.8 的真实 lifetime 分层

### 3.1 AST 保存可重建的稳定语义事实

Clang AST 保存“是什么”和“语义上选择了谁”，但不保存 backend 的 landing pad 或
每条边的展开 cleanup block。

#### 局部变量

`VarDecl` 保存 initializer 与初始化风格：

- `clang/include/clang/AST/Decl.h:926-940`；
- `clang/include/clang/AST/Decl.h:960-972`；
- `clang/include/clang/AST/Decl.h:1356-1376`；
- `clang/include/clang/AST/Decl.h:1456-1472`。

`needsDestruction()` 是从声明/类型查询出的语义属性，不是已展开的 edge cleanup list：

- `clang/include/clang/AST/Decl.h:1696-1702`。

#### 构造表达式与 constructor initializer

`CXXConstructExpr` 保存最终 constructor、ordered arguments、construction kind、
zero/list initialization 等事实：

- `clang/include/clang/AST/ExprCXX.h:1540-1703`。

`CXXCtorInitializer` / `CXXConstructorDecl` 保存 base/member/delegating initializer：

- `clang/include/clang/AST/DeclCXX.h:2369-2464`；
- `clang/include/clang/AST/DeclCXX.h:2608-2612`；
- `clang/include/clang/AST/DeclCXX.h:2695-2759`。

非 dependent constructor 的 initializer AST 由 Sema 按真正构造顺序排列：virtual
bases、non-virtual bases、fields，而不是简单保留源码书写顺序：

- `clang/lib/Sema/SemaDeclCXX.cpp:5437-5601`。

#### temporary、materialization 与 lifetime extension

- `CXXTemporary` 保存 exact destructor：
  `clang/include/clang/AST/ExprCXX.h:1458-1474`；
- `CXXBindTemporaryExpr` 保存 temporary 与 subexpression：
  `clang/include/clang/AST/ExprCXX.h:1477-1517`；
- `MaterializeTemporaryExpr` 保存 materialized subexpression、extending declaration
  与 storage duration：`clang/include/clang/AST/ExprCXX.h:4910-4989`；
- `LifetimeExtendedTemporaryDecl` 保存 temporary、extending declaration 和 mangling
  number：`clang/include/clang/AST/DeclCXX.h:3300-3343`。

#### `ExprWithCleanups` 不是完整 cleanup plan

`ExprWithCleanups` 标记 full-expression 引入 cleanup，但源码注释明确说明无需额外记住
temporary 集合；temporary/destructor identity 仍在嵌套 AST 中：

- `clang/include/clang/AST/ExprCXX.h:3648-3698`；
- Sema wrapper：`clang/lib/Sema/SemaExprCXX.cpp:6680-6699`。

因此现有 OpenSpec 不能再把 `ExprWithCleanups` 直接类比成“每条 edge 上的显式 cleanup
plan”。这可以是本项目自己的设计选择，但不是 Clang AST 的事实。

### 3.2 Analysis CFG 是可选、派生、非持久的分析投影

`CFG::BuildOptions` 默认关闭 EH edges、implicit dtors、temporary dtors、initializers 和
lifetime elements：

- `clang/include/clang/Analysis/CFG.h:1224-1250`。

CFG 从 `Decl* + Stmt* + ASTContext*` 按需重新构建：

- `clang/include/clang/Analysis/CFG.h:1269-1271`；
- `clang/lib/Analysis/CFG.cpp:1653-1658`。

typed implicit destructor elements 包括：

- `CFGAutomaticObjDtor`；
- `CFGBaseDtor`；
- `CFGMemberDtor`；
- `CFGTemporaryDtor`。

这些元素引用当前 AST 的 `VarDecl*`、`FieldDecl*`、`CXXBindTemporaryExpr*` 等对象，
不是可跨 snapshot 的 durable cleanup record：

- `clang/include/clang/Analysis/CFG.h:365-528`。

自动变量离开作用域时的 implicit dtor 是从 local scope 反向派生的：

- `clang/lib/Analysis/CFG.cpp:1906-1994`；
- `clang/lib/Analysis/CFG.cpp:2199-2201`；
- `clang/lib/Analysis/CFG.cpp:2930-2939`；
- `clang/lib/Analysis/CFG.cpp:3332-3357`。

temporary dtor 也从 `ExprWithCleanups`、`MaterializeTemporaryExpr`、
`CXXBindTemporaryExpr` 和条件表达式结构派生：

- `clang/lib/Analysis/CFG.cpp:4923-4935`；
- `clang/lib/Analysis/CFG.cpp:5114-5129`；
- `clang/lib/Analysis/CFG.cpp:5188-5307`。

但 Clang Analysis CFG 不是 constructor-abort cleanup 的完整权威。它没有构造 CodeGen
级别的 base/member constructed-prefix unwind chain，并且源码中仍有 virtual-base 与
lifetime-extension 精度 TODO/FIXME：

- `clang/lib/Analysis/CFG.cpp:1686-1721`；
- `clang/lib/Analysis/CFG.cpp:2100-2148`；
- `clang/lib/Analysis/CFG.cpp:2203-2228`；
- `clang/lib/Analysis/CFG.cpp:2828-2895`；
- `clang/lib/Analysis/CFG.cpp:4954-4962`。

### 3.3 partial construction 的正确性来自 CodeGen push 时点

Clang CodeGen 的核心规则是：

```text
emit initializer N
if initializer N returns successfully:
    push destroy(N) as active cleanup
emit initializer N+1
```

因此 N+1 抛出时，cleanup stack 中只有已经成功的 0..N，且按 LIFO 逆序执行；当前
失败的 N+1 不在栈里。

#### 自动变量

`EmitAutoVarDecl()` 的顺序是 allocate、init、再注册 cleanup：

- `clang/lib/CodeGen/CGDecl.cpp:1345-1352`；
- `clang/lib/CodeGen/CGDecl.cpp:2134-2216`。

这意味着当前 local constructor 自己抛出时，当前 local 的 destructor 尚未入栈。

#### base 与 member

base initializer 正常返回后才 push base destructor：

- `clang/lib/CodeGen/CGClass.cpp:548-585`。

field initializer 正常返回后才 push field destroy：

- `clang/lib/CodeGen/CGClass.cpp:647-713`。

constructor prologue/body 使用 cleanup scope 统一清理 fully constructed bases/members：

- `clang/lib/CodeGen/CGClass.cpp:829-883`；
- `clang/lib/CodeGen/CGClass.cpp:1264-1358`。

non-delegating constructor 不会在函数入口把 complete-object destructor 入栈。只有
delegating target constructor 成功以后，complete object 才达到 commit point：

- `clang/lib/CodeGen/CGClass.cpp:2631-2678`。

#### array

array 使用 `[begin, current)` 或动态 end cursor 表示成功前缀，cleanup 只逆序析构已经
成功的 elements：

- `clang/lib/CodeGen/CGClass.cpp:2202-2263`；
- `clang/lib/CodeGen/CGDecl.cpp:2424-2602`；
- `clang/lib/CodeGen/CGExprCXX.cpp:1115-1144`；
- `clang/lib/CodeGen/CGExprCXX.cpp:1263-1312`。

#### temporary 与条件激活

temporary subexpression 完成后才 push cleanup：

- `clang/lib/CodeGen/CGExprAgg.cpp:1432-1445`；
- `clang/lib/CodeGen/CGExpr.cpp:6575-6581`；
- `clang/lib/CodeGen/CGCleanup.cpp:1321-1326`。

条件执行的 cleanup 使用 backend-local active flag：

- `clang/lib/CodeGen/CGCleanup.cpp:275-298`。

这些 active flags、landing pads、IR values 和 cleanup closures 都是函数 lowering 状态，
不是 AST 语义对象。

### 3.4 Clang 不序列化 initializer-abort cleanup plan

Clang AST writer/reader 序列化：

- `CXXConstructExpr`：
  `clang/lib/Serialization/ASTWriterStmt.cpp:1763-1782`，
  `clang/lib/Serialization/ASTReaderStmt.cpp:1769-1787`；
- `CXXBindTemporaryExpr`：
  `ASTWriterStmt.cpp:1946-1950`，`ASTReaderStmt.cpp:1931-1935`；
- `ExprWithCleanups`：
  `ASTWriterStmt.cpp:2025-2040`，`ASTReaderStmt.cpp:2011-2025`；
- `MaterializeTemporaryExpr`：
  `ASTWriterStmt.cpp:2295-2302`，`ASTReaderStmt.cpp:2284-2290`；
- constructor initializer 数组：
  `clang/lib/Serialization/ASTWriterDecl.cpp:3107-3112`，
  `clang/lib/Serialization/ASTReaderDecl.cpp:508-520`。

没有序列化 constructed prefix、failure edge、cleanup active flag、landing pad、array end
cursor 或每条边的 destructor closure。`EHScopeStack::Cleanup` 会携带当前函数的
`Address`、`llvm::Value*` 或虚调用 closure，本质上只能是 backend-local 状态：

- `clang/lib/CodeGen/EHScopeStack.h:139-203`；
- `clang/lib/CodeGen/EHScopeStack.h:289-331`。

## 4. 当前 Canonical AST 与 Clang 的架构对比

| 维度 | Clang 22.1.8 | 当前 Canonical AST | 审查判断 |
| --- | --- | --- | --- |
| graph owner | `ASTContext` + bump allocator | `asCASTContext` + arena/tables | 方向正确；AS Context 必须显式 noncopyable |
| node identity | 内部 raw pointer/class hierarchy | table ID + public owner-tagged opaque ID | 更适合 Hot Reload/snapshot，但 owner 校验要一致 |
| type identity | uniqued `Type*` + `QualType` | `asCType` + `asCQualType` + stable key | 正确；不要把 numeric TypeId 放回 AST |
| AST shape | typed subclasses、named accessors | flat generic record + kind/literal/children | 紧凑但过度 stringly/positional，关键 protocol 应类型化 |
| Parser/Sema | Parser 驱动 Sema actions | Parser/adapter 驱动 Canonical Sema | 总体正确；仍需清除 backend 内语义重推 |
| immutable boundary | CodeGen 约定读取 completed AST | `Seal()` + verifier + snapshot lease | AS 是更强的本地扩展，但当前状态机太弱 |
| local init | initializer 在 `VarDecl` 上 | `decl->inits` + 后续 synthetic Assign stmt | 信息存在，但 activation relation 未被 verifier 证明 |
| lifetime facts | typed temporary/materialization/destructor facts | generic cleanup expr + string literals | 需要具名、版本化 lifetime protocol |
| CFG | 按需分析投影 | 尚无共享层；AOT 内私有递归 proof | 需要最小 shared derived lifetime/control view |
| cleanup lowering | CodeGen EH/normal cleanup stack | VM opcode state + AOT 私有 proof/lowering | backend-local state合理，但 semantic selection 必须共享 |
| partial construction | success 后 push、committed prefix | local `asOBJ_INIT` 部分正确；subobject plan 缺失 | CTA-S53 的主 blocker |
| serialization | semantic AST facts，重建 derived state | sidecar 序列化 node tables | 不应序列化 backend cleanup；应重建 derived view |
| dynamic type ID | Clang 不适用 AS Engine TypeId | stable identity -> runtime binding -> late TypeId | 当前方向正确，应保持 |

## 5. 当前实现的明确正项

### 5.1 ownership 与 phase boundary 已成型

`asCASTContext` 已经统一拥有 arena、Decl/Stmt/Expr/Type 表、interner、source manager 与
Seal 边界：

- `as_ast_context.h:12-146`；
- `as_ast_context.cpp:9-116`；
- `as_ast_context.cpp:363-377`。

这与 Clang 的 `ASTContext` 思路一致，同时通过 table IDs 和 snapshot lease 适配了 Hot
Reload 与 Cache 场景。

### 5.2 type identity 与 numeric TypeId 已正确拆层

Canonical type 只保存 kind、primitive token、stable key 与 qualifiers：

- `as_ast_type.h:11-50`。

stable type 到 Runtime 类型的解析集中在 binding table：

- `as_runtime_type_binding.cpp:733-789`。

detached artifact 在 candidate transaction 中晚投影 numeric TypeId，并有 sequence
验证与 rollback：

- `as_bytecode_codegen.cpp:9125-9224`；
- `as_bytecode_codegen.cpp:9375-9465`；
- `as_bytecode_codegen.cpp:9718-9787`。

这个边界是动态 TypeId 问题的长期正确解；CTA-S53 不应把 numeric TypeId、Engine
pointer、`asCTypeInfo*` 或 snapshot-local TypeRef 放进 durable protocol/sidecar identity。

### 5.3 local value object 的 VM activation 时点已有正确基础

普通构造成功后才发射 `asOBJ_INIT`：

- `as_bytecode_codegen.cpp:5523-5657`。

赋值初始化只有在 RHS 与 `decl->inits` 的 exact initializer 对应且 copy 成功后才发射
`asOBJ_INIT`：

- `as_bytecode_codegen.cpp:5245-5260`；
- `as_bytecode_codegen.cpp:7541+`。

因此 VM 局部对象已经具备 Clang-style “success before active” 的重要行为基础。问题是
这个事实没有成为共享、可验证的 Canonical lifetime contract，AOT 也没有复用它。

### 5.4 HIR 与 native AST 边界当前清晰

- HIR 已经物理删除，不应通过 `LifetimeHIR`、persisted CFG 或 backend transport 改名
  恢复；
- 原生 `asCScriptNode` Parser AST / Builder / `asCCompiler` 应继续保留，仅由显式
  LEGACY 路径使用；
- product default 仍为 LEGACY；
- Dump/JSON/DOT 只应观察 AST/protocol，不能作为 compiler/cache input。

## 6. Severity-ranked findings

### F1 — High：publication verifier 没有证明 lifetime/cleanup 完整性

Sema 当前把 cleanup 复制为 Block 尾部或 transfer statement children：

- `as_sema_stmt.cpp:1750-1803`；
- `as_sema_stmt.cpp:1843-1949`；
- `as_sema_stmt.cpp:2028-2055`。

verifier 只验证单个 `"scope-exit"` / `"scope-release"` expression 的局部形状：

- `as_ast_verifier.cpp:1609-1699`。

publication verifier 主要补充 Call/Construct/DeclRef 的 resolved target 与 dispatch：

- `as_ast_verifier.cpp:739-787`；
- `as_ast_verifier.cpp:1739-1756`。

Bytecode 只调用该 publication verifier，然后按原始 Block/transfer children 顺序发射：

- `as_bytecode_codegen.cpp:10182-10190`；
- `as_bytecode_codegen.cpp:11566-11574`；
- `as_bytecode_codegen.cpp:7131-7138`；
- `as_bytecode_codegen.cpp:7169-7186`；
- `as_bytecode_codegen.cpp:7208-7213`；
- `as_bytecode_codegen.cpp:7253-7276`；
- `as_bytecode_codegen.cpp:7392-7423`。

相反，TypedASTJIT 在 backend 文件里重新证明 Block cleanup 数量、逆序、transfer 覆盖、
standalone cleanup 禁止与 loop phase：

- `AngelscriptTypedASTJITCanonical.cpp:910-945`；
- `AngelscriptTypedASTJITCanonical.cpp:995-1291`；
- `AngelscriptTypedASTJITCanonical.cpp:2948-2975`。

影响：同一棵 sealed AST 可以被 Bytecode 接受、被 AOT 拒绝。伪造或遗漏 cleanup 时，
Bytecode 可能产生 leak、double cleanup、wrong order 或 scope coverage 错误。这是 CTA-S53
最优先的 correctness blocker。

### F2 — High：AOT 在 DeclStmt 处提前激活对象

Canonical local variable 的执行形态是：

```text
DeclStmt(var)
ExprStmt(Assign(DeclRef(var), exact init expr))
```

证据：

- `as_sema_stmt.cpp:237-286`；
- `as_decl.h:34` 保存 exact `decl->inits`。

AOT lifetime proof 却在遇到 `DeclStmt` 时立即 `Active.Add(Expected)`：

- `AngelscriptTypedASTJITCanonical.cpp:1123-1175`。

因此第二个对象的 initializer 抛出时，derived active set 已错误包含第二个对象本身。
Clang 的正确规则是 constructor 正常返回后才 push destructor；当前 VM 的 `asOBJ_INIT`
也已经遵守这一点。AOT 应消费一个共享 activation fact，而不是把 DeclStmt 当 commit。

### F3 — High：constructor/base/member/array 无 partial-construction plan

constructor `decl->inits` 当前按序发射，失败直接返回，没有 step-level activation：

- `as_bytecode_codegen.cpp:1912-1922`。

non-POD field 在 member storage 上直接调用 constructor：

- `as_bytecode_codegen.cpp:4995-5082`。

generated destructor 会无条件按反向 field 顺序并再处理 base：

- `as_bytecode_codegen.cpp:3170-3293`。

对象状态主要只有单个 `live` bit：

- `as_bytecode_codegen.cpp:1625-1630`；
- `as_bytecode_codegen.cpp:3322-3340`。

这不能表达第 N 个 base/member/element 失败时的 committed prefix，也不能安全地用完整对象
destructor 代替。需要明确区分：

- subobject step commit；
- complete-object commit；
- delegating construction commit；
- dynamic array/aggregate progress cursor；
- normal/exception/abort applicability。

### F4 — High：AOT consumer 在重复 Sema lifetime classification

AOT 当前按 type stable key/name 扫描 destructor，并按 type kind、handle/reference/init
状态重新分类 cleanup family：

- `AngelscriptTypedASTJITCanonical.cpp:843-907`。

它随后重建 active lexical stack、loop phase 与 transfer coverage：

- `AngelscriptTypedASTJITCanonical.cpp:995-1291`。

这超出了“读取 sealed semantic facts 并做 backend lowering”。CTA-S53 应让 exact action
selection、activation 与 phase ownership 在 Seal 前成为 verifier-authenticated fact；AOT
只做结构 sanity/eligibility 与 physical lowering，不得重新搜 destructor 或猜 cleanup
family。

### F5 — High：`asCASTContext` raw arena owner 隐式可复制

`asCASTContext` 声明 destructor，但没有删除 copy constructor/copy assignment：

- `as_ast_context.h:12-16`。

它直接拥有 node pointer tables 与 raw arena blocks：

- `as_ast_context.h:131-146`。

destructor/`DestroyAll()` 手动析构节点并释放 arena blocks：

- `as_ast_context.cpp:15-17`；
- `as_ast_context.cpp:86-116`。

编译器生成的浅拷贝会导致 double destructor/free 与 UAF。该类型应显式 noncopyable；若
确有 move 需求，必须提供清空 source owner 的显式 move，否则连 move 一并删除。

### F6 — High：Decl/Stmt/Expr lookup 忽略 foreign `snapshotOwner`

公共 ID 合同说明 `value` 是 snapshot-local index，`snapshotOwner` 必须匹配发行 snapshot：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:979-989`。

但 `GetDecl/GetStmt/GetExpr` 只检查 numeric value：

- `as_ast_context.cpp:308-333`。

`OwnsDecl/OwnsStmt/OwnsExpr` 因此也可能把 foreign same-index ID 认成本 Context 的节点：

- `as_ast_context.cpp:348-361`。

`GetType()` 已经正确拒绝 `snapshotOwner != 0`：

- `as_ast_context.cpp:335-345`。

四类 ID 的 owner 规则不一致。若公共 handle 泄入内部 API，foreign ID 可能静默重绑定到
另一棵图的同 index 节点，verifier 也可能无法发现。

### F7 — High：`sealed`、publishable、cache-restorable 不是同一状态

`Seal()` 只运行结构 verifier 并设置一个 `bool sealed`：

- `as_ast_context.cpp:363-377`。

publication verifier 是另一个更强入口：

- `as_ast_verifier.cpp:1739-1756`。

sidecar encode/decode 只要求或调用弱 `Seal()`：

- `as_ast_sidecar.cpp:362-379`；
- `as_ast_sidecar.cpp:1037-1041`。

TypedASTJIT 也只先检查 `IsSealed()`，Bytecode 到生成阶段才要求 publication verifier：

- `AngelscriptTypedASTJITCanonical.cpp:2880-2918`；
- `as_bytecode_codegen.cpp:10182-10190`。

因此“sealed AST”目前没有唯一、清楚的 admission 含义。推荐至少形成：

```text
Building
  -> SemaFinalized
  -> LifetimePlanned
  -> Verified
  -> Frozen/Publishable
```

sidecar encode、Cache restore、Bytecode、StaticJIT 与 TypedASTJIT 都只能接收同一
`Frozen/Publishable` 合同。

### F8 — Medium：cleanup/control protocol 是 stringly-typed、position-based

基础 `asCStmt` / `asCExpr` 使用通用字段：

- `as_stmt.h:11-28`；
- `as_expr.h:12-35`。

Sema 用 `"cleanup"`、`"scope-exit"`、`"scope-release"` literal 编码 action：

- `as_sema_lifetime.cpp:18-49`；
- `as_sema_stmt.cpp:1805-1841`。

verifier、Bytecode、AOT 分别重解码：

- `as_ast_verifier.cpp:1609-1699`；
- `as_bytecode_codegen.cpp:7169-7410`；
- `AngelscriptTypedASTJITCanonical.cpp:910-945`。

foreach cleanup phase 还依赖 `children[3]`：

- `as_sema_stmt.cpp:713-716`、`889-907`；
- `as_ast_verifier.cpp:1207-1277`；
- `AngelscriptTypedASTJITCanonical.cpp:1017-1106`。

Clang 的 `CXXForRangeStmt` 使用具名字段/accessor 保存各 phase：

- `clang/include/clang/AST/StmtCXX.h:128-200`。

它没有“第四 child 是 cleanup”的协议。当前 AS 形态只是迁移实现，不应继续当长期
Canonical contract。

### F9 — Medium：sidecar 序列化包含 unreachable recovery artifacts

`ReplaceExprUses()` 明确允许 old node 留在 arena 中成为 unreachable recovery artifact：

- `as_ast_context.h:89-93`。

sidecar 不是从 semantic roots 遍历 reachability，而是依次写出整个 Decl/Stmt/Expr 表：

- `as_ast_sidecar.cpp:439-515`。

不同 recovery/rewrite 历史可能产生不同 sidecar bytes 和 node budget，即使 reachable
semantic graph 相同。后续应从 roots 做 reachability traversal、重新分配 dense DTO IDs，
不要让 arena insertion history 成为 canonical persistence identity。

### F10 — Medium：compiler provenance digest 依赖 diagnostic dump text

规范要求 dump/JSON/DOT 只用于观察，不成为 compiler/cache input，但当前 bytecode digest
通过 `asCASTDump(context, dump)` 的渲染文本计算：

- `as_bytecode_codegen.cpp:142-156`；
- `as_bytecode_codegen.cpp:11192`、`11544`、`12360`。

这不会反向解析 dump 为 AST，但 diagnostic formatting 变化会改变 compiler provenance。
CTA-S53 不应复用该方式生成 protocol hash。应提供独立 deterministic structural hash，
直接 hash typed fields、stable keys、protocol revision 与必要的 logical source identity。

### F11 — Medium：function semantic hash 混入 debug/source offset，且 digest/key gate 偏弱

当前 range identity 包含 logical file、origin、绝对 begin/end offset 与 source slice：

- `as_ast_sidecar.cpp:1088-1123`。

Decl/Stmt/Expr/function identity 递归包含这些 range facts：

- `as_ast_sidecar.cpp:1147-1315`。

digest 使用 FNV-1a 64，planner 以 `functionKey + contentHash` 判定 reuse，且 key 可退化到
name：

- `as_ast_sidecar.cpp:1044-1076`；
- `as_ast_sidecar.cpp:1317-1396`。

这会让空行/注释导致 semantic rebuild，并存在重复 fallback key/弱 hash 的设计债。当前
增量 sidecar planner 尚未发现生产调用，因此记为后续 persistence identity 风险，不应
阻塞 S53 的最小 lifetime closure。

### F12 — Medium：cleanup destructor resolution 仍有 name-based 风险

`ActOnCleanup()` 扫描所有 declarations，以 parent name 与 type stable key 相等来选择
destructor：

- `as_sema_lifetime.cpp:18-49`。

这不如 exact type declaration/behaviour identity 稳健。长期 lifetime protocol 应直接保存
Sema 已解析的 exact action target，不允许 verifier/AOT/CodeGen 再按 display name 或
stable key 扫描并猜测 destructor。

### F13 — Low：AOT type-shape 仍绕过 frozen Runtime binding snapshot

TypedAST canonical helper 使用 `asCRuntimeTypeBridge(nullptr)`，随后对 script enum 和
少量 managed types 加稳定名白名单：

- `AngelscriptTypedASTJITCanonical.cpp:265-413`；
- `as_runtime_type_binding.cpp:733-789`。

当前 whitelist 很窄且 fail closed，不是直接错误，但扩展 AOT ABI surface 时容易重复
Bytecode/Runtime type interpretation。更合适的输入是 frozen
`RuntimeTypeBindingSnapshot` / `TypeABIKey`。

## 7. CTA-S53 推荐架构

### 7.1 四层边界

```text
Canonical AST semantic facts
    exact decl/type/init/target/action/activation/region/phase
                |
                v
Canonical Lifetime Protocol（snapshot-owned、immutable、versioned）
    per-function lifetime/construction records；Seal verifier authentication
                |
                v
Derived Lifetime/Control View（shared、deterministic、transient）
    scope/edge/live-set/reverse cleanup proof；可选诊断视图
                |
                v
Backend-local lowering
    VM/AOT cleanup stack、labels、patches、slots、EH tables、native frame ABI
```

关键所有权：

- Sema 决定 exact action 与语义 region；
- verifier 证明 activation、edge coverage、order 与 exactly-once；
- derived view 只做机械控制流/liveness 推导，不做 lookup、overload、conversion、type 或
  destructor selection；
- backend 只把已验证 semantic action lower 成自己的执行结构。

### 7.2 最小 `CanonicalLifetimeProtocol`

建议的内部合同：

```text
ProtocolRevision
FunctionDeclId

LifetimeRecord[]
  LifetimeId
  SubjectDeclId / storage identity
  OwnerScopeOrPhaseId
  ActionKind
  ExactActionTargetDeclId
  ActivationPoint / commit-on-success edge
  NormalLifetimeEnd
  ExitMask: normal / exception / reviewed abort kind
  ConstructionKind
  ExceptionalRegionId (optional)
  SourceRange

ConstructionRecord[]
  OwnerObject
  OrderedStep[]: virtual-base / base / field / element / delegating target
  CompleteObjectCommit
  DynamicProgressIdentity for arrays/aggregates (optional)

RegionRecord[]
  RegionId
  OwnerStmtOrExpr
  ParentRegionId
  Supported failure/exception edges

PhaseRecord[]
  PhaseId
  OwnerLoopOrConstruct
  Named semantic role
  Activated lifetimes
  Exit policy
```

内部表可以使用 owner-tagged snapshot-local IDs，但必须与 `asCASTContext` 同寿命、同 Seal
和同 snapshot lease。任何进入 Cache DTO、Provider、detached artifact 或跨 generation
identity 的视图都必须使用 stable key + explicit remap，不能持久化 raw pointer、numeric
TypeId、Engine ID 或裸 snapshot-local ID。

### 7.3 derived view 的边界

derived lifetime/control view 应从 sealed AST + protocol 确定性构建：

- scope/phase nesting；
- normal、return、break、continue、fallthrough 与已明确支持的 failure/exception edge；
- committed-live set；
- reverse live-only cleanup sequence；
- missing/duplicate/wrong-order/wrong-target；
- current failing action 不在 abort cleanup；
- whole-object destructor 只在 complete-object commit 后可达；
- array cursor 不超过最后成功 element；
- 每个 owning action最多 cleanup 一次。

它不得：

- 持久化为另一个 per-function HIR；
- 进入 Provider/Cache/artifact；
- 从 dump/bytecode 解析；
- 写回 sealed AST；
- 做 destructor lookup 或 cleanup-family selection；
- 引入 SSA、dominators、优化 pass 或泛化 LLVM CFG 框架。

### 7.4 backend-local 状态继续保留

Bytecode/AOT 可以继续各自拥有：

- cleanup/EH stack；
- labels 与 branch patches；
- local slots / active flags / constructed counters；
- physical exception table；
- shared cleanup block；
- VM opcode/native call routing；
- native frame layout 和 ABI。

这些对应 Clang 的 `EHScopeStack` / `RunCleanupsScope`，是 lowering state，不应进入
Canonical snapshot。

### 7.5 Sidecar V6 的建议

Clang 对照表明没有必要为了 S53 把“每条 initializer failure edge 的完整 reverse cleanup
list”持久化成 Sidecar V7。优先方案是：

1. V6 继续保存 exact Decl/Expr/Stmt/type/init semantic facts；
2. 如果 existing facts 能唯一确定 activation/commit，则 Seal 后确定性重建 protocol/view；
3. 如果不能唯一确定，只增加最小、具名的 activation/action/region semantic facts，并在
   decode 后重建 derived view；
4. 不序列化 backend cleanup stack、CFG block、landing pad、numeric TypeId 或展开 edge
   cleanup list。

是否完全不 bump schema 必须由首个 initializer-abort RED test 决定，不能先假定。如果
`decl->inits + exact Assign` 足以形成无歧义 activation relation，S53 可以不改 sidecar schema；
若需要新增不可派生的 semantic role，则应显式 bump schema，而不是用 literal/child index
偷渡。

## 8. 可选方案与取舍

### 方案 A：继续在每条 statement edge 复制完整 cleanup children

优点：Bytecode 消费直接；与当前 CTA-S44 形态接近。

缺点：

- 不是 Clang 的实际分层；
- statement graph 膨胀；
- normal/transfer/foreach/exception 每新增一种 edge 都要复制；
- Sema、verifier、Bytecode、AOT 容易继续漂移；
- partial arrays 与 conditional activation 很难用静态 child list表达。

结论：不推荐作为长期协议；已有 normal/transfer cleanup children 可在迁移期保留并由
shared plan 反向验证。

### 方案 B：最小 sealed lifetime facts + shared derived view（推荐）

优点：

- sealed AST 仍是 semantic authority；
- 避免 backend 重跑 Sema；
- 不把通用 CFG/HIR 变成持久运输层；
- Bytecode/AOT/Verifier 可共享同一 liveness 解释；
- 支持 partial construction、array cursor 与 conditional activation；
- 大概率可继续使用 Sidecar V6 或只做最小 schema 增量。

风险：必须严格限制 derived view 不做 lookup/selection；必须设计清楚 snapshot-local 与
durable identity 边界。

### 方案 C：纯 CodeGen cleanup stack

优点：最接近 Clang 单 LLVM backend 的实现机制。

缺点：本项目有 Bytecode、AOT、verification、Cache 与 Provider；各 backend 会重新推导
semantic cleanup，违反 sealed AST authoritative 和 backend 不重跑 Sema。

结论：不适合作为本项目语义架构；只应借鉴为 backend-local lowering 状态。

### 方案 D：持久化完整 CFG/cleanup IR

优点：消费者读取简单。

缺点：容易成为 HIR 的改名复活；引入第二 semantic authority；增加 schema、Cache、Hot
Reload 与 Provider identity 负担；Clang 也不持久化这些 CodeGen cleanup states。

结论：拒绝。

## 9. 建议执行顺序

以下顺序已经作为 2026-08-28 批准的 B2 方案写入 OpenSpec Tasks 15.1-15.11；
它仍是实施计划，不代表这些步骤已经实现：

1. 先修正 owner/state 基础不变量：`asCASTContext` noncopyable、foreign owner 校验、统一
   Frozen/Publishable admission；
2. 用 AST-first RED 固化两个顺序 local value objects，第二个 initializer 失败时只清第一个；
3. 定义最小 lifetime protocol revision、activation point 与 exact cleanup action；
4. 把 AOT 私有 `ProveCanonicalLifetimeStmt()` 中的通用 lifetime proof 上移为 shared derived
   view；
5. 让 publication verifier、Bytecode、AOT 消费同一 verified contract；
6. 迁移 `scope-exit` / `scope-release` magic strings 与 foreach `children[3]`；迁移期保留
   旧 normal/transfer cleanup statements 并做双向一致性验证；
7. 再闭合 constructor base/member、delegating constructor、array prefix；
8. exception、abort、timeout、suspend 按各自明确语义和 exit mask 分批支持，未知情形继续
   fail closed；
9. 最后独立处理 sidecar reachability、semantic hash 与 dump-derived digest，不把它们混成
   initializer-abort slice 的范围膨胀。

## 10. 推荐 CTA-S53 acceptance evidence

### AST-first RED/GREEN

- 两个 local value objects：第二个 constructor 失败，仅第一个进入 abort cleanup；
- 当前失败对象不得析构；
- 正常路径严格逆序析构第二个、再第一个；
- sealed snapshot 精确断言 subject、action target、activation、region、commit frontier；
- repeated derived view byte/digest equality。

### forged protocol negative tests

- wrong subject；
- wrong destructor/release target；
- activation before initializer completion；
- missing/duplicate cleanup；
- wrong cleanup order；
- wrong loop phase；
- current failing action included in abort cleanup；
- complete-object destructor reachable before complete commit；
- foreign snapshot-local ID；
- protocol revision mismatch。

### backend parity

- Bytecode 与 AOT 对同一 verified protocol 的 acceptance/fallback 一致；
- VM 保持 `asOBJ_INIT` success-before-active 行为；
- native object-frame ABI 尚未支持时，AOT 精确 per-function fallback；
- Provider 只收到 pointer-free copy/summary，不保留 AST/protocol pointer；
- RuntimeTypeBindingSnapshot/TypeABIKey 为两 backend 的相同 ABI 事实来源。

### boundary scans

- HIR production symbols 仍为零；
- native `asCScriptNode` 语义遍历与 `asCCompiler` 函数体发布仍存在且只由显式
  LEGACY/syntax/recovery/reference 路径使用；CANONICAL 只允许复用已在 Task 13.1
  接受的 `asCBuilder` Stage 1/2 Runtime registration/transaction shell，不得从其
  native tree 推导表达式/语句语义，也不得调用 legacy compiler；
- product default 仍为 LEGACY；
- durable record 不含 Engine pointer、numeric TypeId、裸 TypeRef/DeclId/StmtId/ExprId；
- dump/JSON/DOT 不作为 compiler/cache input；
- CTA-S53 不宣称关闭 native object ABI、完整 exception/suspend 或 umbrella tasks。

## 11. OpenSpec 一致性问题

### 11.1 设计表述已按 B2 修订

审查时，下列位置把“semantic lifetime fact”和“每条 edge 的展开 cleanup plan”混在一起：

- `design.md:269`；
- `design.md:316`；
- `specs/as-canonical-typed-ast/spec.md:28-44`；
- `specs/as-canonical-compiler-pipeline/spec.md:16-17`；
- `specs/as-typed-semantic-ir/spec.md:33-36`；
- `tasks.md:862-887`。

2026-08-28 的 OpenSpec 修订已经改为：sealed snapshot 保存 exact lifetime subject、
action、activation、region、phase、transfer target 与 construction commit；deterministic
shared verifier-authenticated view 机械派生 reverse live-only edge sequence。Backend 不得
选择新 action 或把 invalid/missing protocol 当 no-cleanup，但可以拥有自己的 labels、
cleanup stack 与 block sharing。

### 11.2 bounded shared view 已纳入当前 change

审查时的过时表述位于：

- `attachments/llvm-ast-architecture.md:21`；
- `design.md:303-305`；
- `design.md:557`。

CTA-S51/S52 的 AOT 私有 proof 已经实质上构造了一个 lifetime/control view。修订后的
OpenSpec 允许本 change 引入最小 shared derived view，并明确它不是通用 SSA/data-flow/
LLVM CFG，不进入 Cache、Provider、Public ABI 或 artifact。

### 11.3 HIR/default 状态记录已纠正

审查时，以下位置仍用现在时描述 HIR consumer，或残留默认 CANONICAL 的旧说法：

- `proposal.md:8-9`、`:62`；
- `design.md:43-50`、`:83-89`；
- `reviews/canonical-ast-architecture-clang-dascript-typeid-2026-08-27.md:387-390`、
  `:419-420`。

这些 normative/active review 位置现已纠正为：HIR 已物理删除；default 是 LEGACY；
native AST 保留；S53 不设计 HIR 兼容路径。历史 checkpoint 原文保持历史语境。

### 11.4 dump 非运输与当前 digest 的张力

`design.md:297-299` 和 `specs/as-canonical-typed-ast/spec.md:128-149` 要求 dump 不成为
compiler/cache input，但当前 bytecode provenance digest 依赖 `asCASTDump()` 渲染文本。
该问题应单列，S53 protocol digest 不得继续沿用。

## 12. 状态与非声明

本轮是静态 review 与设计确认 checkpoint，不是实现 checkpoint。B2 已于
2026-08-28 获批并完成 OpenSpec 规范化，但下列实现非声明保持不变：

- 没有实现 `CanonicalLifetimeProtocol`；
- 没有实现 derived CFG/lifetime view；
- 没有修复 partial construction；
- 没有修改 Sidecar schema；
- 没有修改 product default；
- 没有删除 native AST；
- 没有恢复 HIR；
- 没有宣称 5.7/5.8/7.5/9.5/9.6 等 umbrella tasks 完成；
- 没有宣称 native object AOT ABI、exception、abort、timeout 或 suspend 完整支持。

本 review 为 CTA-S53 提供可追溯证据。B2 分层已经同步到 `proposal.md`、
`design.md`、spec deltas、`tasks.md`、Clang 对照附件和问题台账；实现仍应从
Tasks 15.1-15.11 的 AST-first RED 开始。任何 Sidecar schema 变更仍需先满足
15.11 的不可派生证据门槛。
