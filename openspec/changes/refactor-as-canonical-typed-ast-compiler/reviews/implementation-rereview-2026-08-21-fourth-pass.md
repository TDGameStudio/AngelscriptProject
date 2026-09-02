# Canonical Typed AST Compiler 第四轮实现复审 — 2026-08-21

## 复审结论

当前实现仍为 **Request changes**。不能归档，不能把 canonical pipeline 切为 production default，也不应把当前 `56/105` checkbox 解释为已完成 53.3% 的 production compiler。

本轮相较第三轮有真实进展：

- R07 的 arena / construction API / sealed const traversal 已基本形成可用边界；
- Runtime type bridge 的 scoped foundation 已补强；
- Verifier 新增 stmt/expr ID、statement cycle/multi-owner、publication seal 等检查；
- Parser 已继续接入 declaration、call、return 等增量 Sema action；
- R09 Task 1 已能在部分失败路径回滚已分配 global；
- R11 funcdef/lambda teardown 崩溃仍保持关闭，没有重新出现新的 teardown 证据。

但第四轮发现了一个比“尚未 cutover”更直接的 production 回归：

> `ParseLambda()` 无条件改变了 legacy `snFunction` recovery-tree 的 child layout，而当前 production `asCCompiler` 仍按旧 layout 读取 lambda 参数。

这会使默认 LEGACY pipeline 的 lambda 参数计数和类型匹配出错。它不是 canonical pipeline 尚未完成的抽象风险，而是新 Parser shape 与现有 production consumer 之间的确定性协议断裂。

本轮还确认：

1. `2.8` 与 `13.5` 的 Verifier closure 勾选过早；实现没有满足 change spec 中的 skipped-nearer、完整 ownership/cycle、required resolved target、cleanup/transfer plan 等约束；
2. tokenizer 重新启用了 `interface` / `typedef` 关键字，改变了当前 fork 的 accepted syntax / identifier set，与 OpenSpec 明确的 non-goal 冲突；
3. `namespace A::B { ... }` 的增量 Sema action 只在读到第一个 identifier 后 push `A`，canonical graph 会漏掉 `B` 这一层；
4. production CodeGen、Cache DTO、public ABI、snapshot concurrency/atomicity 仍是原有 Blocking；
5. R09 虽新增 global rollback，但 success path 仍有额外 `AddRefInternal()`，且仍没有 detached artifact / atomic installer。

当前最准确的定位仍是：

> **Canonical Typed AST migration platform / shadow semantic compiler + isolated Bytecode CodeGen prototype**

而不是 production compiler authority。

## 复审快照与边界

- worktree：`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`；
- 短路径：`D:\as-cta`；
- parent branch：`refactor-as-canonical-typed-ast-compiler`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin submodule：`D:\as-cta\Plugins\Angelscript`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time：**2026-08-21 19:35（Asia/Shanghai）**；
- parent/plugin 都有大量未提交和 untracked 变更；本报告审查的是这个时间点的共享工作快照，不代表已提交分支；
- 另一个 agent 仍在持续实现，19:32 仍修改了 `as_parser.cpp` / `as_sema*.cpp`，19:34 仍产生新测试报告；
- 按用户要求，本轮没有主动运行 build/test，也没有占用编译锁；下面的数字来自实现者已保存的 JSON report，并经过只读解析，不是本 reviewer 对 19:35 快照重新构建后的独立验收。

OpenSpec checklist 在快照时为：

- total：`105`；
- checked：`56`；
- open：`49`；
- 新勾选项：`2.4`、`2.6`、`2.8`、`13.4`、`13.5`。

本报告认为 `2.8` 与 `13.5` 不满足其自身文字和 capability spec，应该重新打开。若只按本轮审计纠正这两项，诚实状态应为：

- checked：`54`；
- open：`51`；
- `54/105 = 51.4%`。

这仍只是未加权 checklist；production authority/cutover 的完成度远低于 scaffold/test 数量表现出来的比例。

## 实现者保存的测试证据

| Label / 范围 | 保存结果 | 本轮如何解释 |
| --- | ---: | --- |
| `wave-c-28-green` / Verifier | `13/13 PASS` | 证明已实现的 13 个检查为绿；不覆盖完整 spec firewall |
| `wave-c-28-frontend` | `63/63 PASS` | CanonicalAST frontend 正向覆盖扩大 |
| `wave-c-28-compiler` | `37/37 PASS` | Canonical compiler fixtures 为绿；仍非 production cutover |
| `r09-txn-green2` | `3/3 PASS` | 证明 Task 1 的有限回滚用例；不证明 detached/atomic transaction |
| `r09-txn-codegen-green` | `27/27 PASS` | R11 teardown 仍关闭；不证明 module reset 后无额外引用 |
| `wave-b-parser-expr-green2` | `57/57 PASS` | SemaAuthority parser/call actions 为绿 |
| `wave-b-parser-expr-canonical` | `72/72 PASS` | 对应 CanonicalAST 聚合为绿 |
| `wave-b-parser-stmt-green` | `61/61 PASS` | 最新 return statement action 为绿 |
| `wave-b-parser-stmt-canonical` | `76/76 PASS` | 最新 CanonicalAST 聚合为绿 |

这些报告的价值是真实的，但它们没有执行以下关键断言：

- 默认 LEGACY module build + lambda conversion + VM execution；
- `break`/`continue` 指向非最近但仍是 ancestor 的 loop/switch；
- expression cycle / expression multi-owner；
- CALL/CONSTRUCT 缺失 required resolved callee；
- CLEANUP 缺失 destructor target；
- `namespace A::B` canonical owner/stable key；
- 旧代码把 `interface` / `typedef` 当普通 identifier 的兼容性；
- CodeGen success 后 module reset / Engine teardown 的最终 function refcount；
- Cache pure-body edit、profile-only mismatch 和完整 DTO reconstruction。

因此不能从这些绿报告反推出下述 findings 已关闭。

## Findings（按严重性排序）

### F1 — Critical / Blocking：新 lambda Parser child layout 已破坏默认 LEGACY compiler consumer

这是第四轮最重要的新发现。

#### 新 Parser layout

`as_parser.cpp:1707-1792` 的 `ParseLambda()` 现在无条件构造：

```text
snFunction
  snIdentifier("function")
  snParameterList
    [snDataType, snDataType/type-mod, snIdentifier]...
  snStatementBlock
```

关键点是“无条件”：即使 `sema == nullptr`、Engine 使用默认 LEGACY pipeline，`functionIdent` 和 `snParameterList` 仍会进入 recovery tree。`ParseFunctionStatementBlock()` 虽然在无 Sema 时仍保持 superficial body，但 parameter layout 已经变化。

#### 现有 production consumer 仍读取旧 layout

`as_compiler.cpp:11521-11555` 的 `ImplicitConvLambdaToFunc()` 仍假定 lambda 参数直接平铺在 `snFunction` 下：

```cpp
asCScriptNode *argNode = ctx->exprNode->firstChild;
while( argNode->nodeType != snStatementBlock )
{
    if( argNode->nodeType == snDataType ) { ... }
    if( argNode->nodeType == snIdentifier )
        count++;
    argNode = argNode->next;
}
```

在新 layout 下：

- 第一个 `snIdentifier("function")` 会被错误计为一个 lambda parameter；
- `snParameterList` 本身既不是 `snDataType` 也不是 `snIdentifier`，其 children 不会被遍历；
- 零参数 lambda 会被算成 1 个参数；
- 有参数 lambda 的真实 parameter type/name 不会进入 legacy signature matching；
- `RegisterLambda()` 后续也收到与旧 compiler contract 不一致的 tree。

默认 production pipeline 当前仍是 LEGACY，`asCModule::Build()` 仍调用 `asCBuilder::BuildCompileCode()`，所以这是当前生产路径回归，不需要等 canonical cutover 才会暴露。

#### 为什么现有绿测试没发现

- `ParserActOnLambda*` 只验证 Parser+Sema dump 和去重；
- `MultipleLambdasKeepDistinctStableKeys` 直接给 Parser 设置 Sema，并只 seal/dump canonical graph；
- Canonical CodeGen lambda fixtures 测 isolated canonical backend；
- 现有 2.38 lambda conformance 不是这次默认 production lambda regression 的完整 active gate；
- 没有新增“默认 Engine + module Build + typed lambda assignment + execute”的 compatibility test。

#### 要求

在继续 Parser action 扩张前必须先建立 recovery-tree consumer contract：

1. 最小修复可以在 legacy recovery tree 中继续保留旧 flat parameter layout，canonical Sema action 使用独立 parser-action payload/cursor；或同步迁移所有 `snFunction` lambda consumers，但在 production 仍依赖 legacy compiler 时必须一次完成；
2. 增加 active tests：
   - `Callback@ L = function() { ... };`
   - `Callback@ L = function(int X) { ... };`
   - inferred parameter lambda；
   - typed parameter + ref/in/out 修饰；
   - Build、执行结果、module reset、Engine teardown；
3. 在这些测试前，不应把 Parser ActOn lambda 的成功 dump 当作兼容性完成。

### F2 — Blocking：Verifier firewall closure 过早，`2.8` / `13.5` 应重新打开

`tasks.md:301` 对 `13.5` 的文字要求包括：

- parent/child ownership；
- cycles；
- control targets；
- resolved signatures；
- cleanup plans；
- sealed publication。

Capability spec 更明确：

- `as-canonical-typed-ast/spec.md:43` 要求拒绝 `skipped-nearer` transfer target；
- `spec.md:98` 要求覆盖 ownership、sequencing、cleanup、transfer target、stable references；
- `spec.md:105-107` 要求 unresolved required stable target 在 publication 前失败。

当前 `as_ast_verifier.cpp` 只完成了其中一部分。

#### 2.1 不拒绝 skipped-nearer break/continue target

`as_ast_verifier.cpp:265-288` 只检查：

- target 是 loop/switch 的正确 kind；
- target 的 subtree 包含当前 break/continue。

如果结构为：

```text
outer while
  inner while
    break -> outer while
```

outer 仍然是 ancestor，`StmtContains(outer, break)` 为 true，当前 verifier 会通过；但 spec 明确要求拒绝 skipped-nearer target。

#### 2.2 statement ownership 检查不完整

`stmtParent` 只拒绝“同一 child 被两个不同 parent 引用”。它不拒绝：

- 同一 parent 重复两次添加同一 child；
- 非 body root 的孤立 statement；
- body root 与其他 parent 同时拥有的边界组合；
- owner decl 与 statement subtree 的完整一致性。

#### 2.3 expression graph 没有 cycle / multi-owner 验证

`as_ast_verifier.cpp:379-445` 逐个检查 child existence 和少量 arity，但没有 expression DFS color，也没有 expression parent/owner table。因此：

- `A -> B -> A` expression cycle 可通过；
- 同一 materialize/cleanup/value expression 被多个 owner 重用是否允许没有 per-kind policy；
- tree-only operand 与合法 DAG/shared semantic reference 没有被区分。

#### 2.4 required resolved callee/signature 可缺失

当前只在 `resolvedDecl.IsValid()` 时验证它存在；CALL/CONSTRUCT 没有 resolved callee 仍可 seal。`tasks.md` 甚至写了 “Hard no: CALL/CONSTRUCT missing callee” 和 “CALL-without-callee not required”，这直接缩小了 capability spec，而没有先修改 design/spec。

如果后端不得重复 overload/constructor selection，那么 executable CALL/CONSTRUCT 没有 resolved target 就不是完整 semantic graph。

#### 2.5 cleanup / fallthrough 只验证了弱条件

- CLEANUP 只有在 `resolvedDecl` 已设置时才检查它是 destructor；完全没设置 destructor target 仍通过；
- 没有验证 cleanup 的 live value、reverse order、edge ownership 或 scope exit plan；
- FALLTHROUGH 只要求存在任意 switch ancestor，没有验证 target 是同一最近 switch 的 next case，也没有验证 case ordering/末 case 非法 fallthrough。

#### 2.6 stable references / signature compatibility / ABI 没有进入 verifier

这可以分阶段实现，但不能一边把它们留给“later Sema/Wave F”，一边把要求完整 stable references / resolved signatures 的 firewall task 标成 closed。

#### 要求

- 重新打开 `2.8` 与 `13.5`；
- 先把 spec requirement 拆成可审计 matrix，再逐项增加 malformed-graph tests；
- 不要用“已有 13 个 verifier tests”替代“任务文字中的每类 invariant 已覆盖”；
- `Seal()` 与 public/cache/backend publication 必须共用同一完整 verifier policy。

### F3 — Blocking：production `Build()` 仍由 legacy `asCCompiler` 发布 Bytecode

这不是新发现，但当前仍是最终 cutover 的中心阻断：

- `as_module.cpp:394-407` 的 production build 仍进入 `builder->BuildCompileCode()`；
- `as_builder.cpp:863+` 仍实例化/调用 legacy `asCCompiler`；
- `as_compiler.cpp:3282` 记录 publisher 为 `asBYTECODE_PUBLISHER_COMPILER`；
- `asCBytecodeCodeGen::Generate()` 仍没有 production `Build()` caller；
- `as_scriptengine.cpp:787` 默认 `canonicalCompilerPipeline = false`；
- `IsCanonicalBytecodeCodeGenReady()` 返回 false，这是诚实状态；
- 选择 `CANONICAL` 当前只让 Parser attach Sema/shadow graph，不改变 production Bytecode publisher。

所以当前数据流是：

```text
source
  -> asCParser recovery tree
  -> incremental/post-walk canonical Sema shadow graph
  -> asCBuilder::BuildCompileCode()
  -> legacy asCCompiler redoes production semantics
  -> VM Bytecode
```

而不是目标数据流：

```text
source
  -> Parser actions
  -> authoritative Sema
  -> complete verified sealed AST
  -> detached canonical Bytecode artifact
  -> atomic install
  -> VM / StaticJIT / Cache / future LLVM consumers
```

R01 honesty修正已经有效阻止“虚假 cutover”，但 13.1/13.6/10.4 仍必须保持 open。

### F4 — High：`namespace A::B` 的 canonical owner hierarchy 会丢失 `B`

Parser 明确支持 qualified namespace declaration：`as_parser.cpp:2655-2673` 读取 `namespace A::B::C`。

但新的增量 action 在只读完第一个 identifier 后就执行：

```text
ParseNamespace
  read A
  NotifySema(node)
  PushLastActed()   // push A
  then parse ::B::C
  then parse inner script under current Sema context A
```

`as_sema_decl.cpp:936-947` 的 `WalkOne(snNamespace)` 也只取 `FirstChildOfType(node, snIdentifier)`，创建/查找第一个 namespace，然后把 node 的所有 children 在这个 namespace 下 walk。第二、第三个 qualified identifier 不会被转换为 nested namespace decl。

因此：

```text
namespace A::B
{
    int F() { return 1; }
}
```

canonical graph 很可能得到 `A::F()`，而不是 `A::B::F()`，甚至没有 `B` declaration。

现有 `ParserActOnNestedNamespaceDeclBeforeInnerBodyFails` 测的是：

```text
namespace Game { namespace Inner { ... } }
```

它不能覆盖单个 qualified namespace declaration。

要求增加 `namespace A::B` / `A::B::C` 的 incomplete-body action、complete parse、stable key、lookup 和 legacy differential tests。Parser action 应在完整 qualified namespace path 可用后逐段 ActOn/push，不能把第一个 identifier 当成整个 declaration context。

### F5 — High / Scope violation：重新启用 `interface` / `typedef` 改变了当前语言行为

`as_tokendef.h:285` 与 `:300` 把原本注释的 token definitions 重新启用：

```diff
- //asTokenDef("interface", ttInterface)
+ asTokenDef("interface", ttInterface)

- //asTokenDef("typedef", ttTypedef)
+ asTokenDef("typedef", ttTypedef)
```

这同时产生两类 observable change：

1. 原来把 `interface` / `typedef` 当普通 identifier 的脚本会被重新分类为 keyword，可能从 accepted 变为 rejected；
2. 原来 tokenizer 不可达的 interface/typedef declaration syntax 重新变为 accepted。

但：

- `design.md:39` 明确把 “Changing accepted AngelScript syntax or intentional language behavior” 列为 Non-Goal；
- `proposal.md:17` 要求保留 current AngelScript language behavior；
- 当前 change 没有记录这是一个语言恢复/扩展决策，也没有兼容性、迁移或 release-note gate。

如果产品确实决定恢复这两个语法，这是可以做的，但必须先显式修订 OpenSpec scope，并增加：

- 旧 identifier compatibility negative/positive matrix；
- interface/typedef runtime/compiler semantics，而不仅是 Parser ActOn dump；
- public language version / migration note；
- Standalone 与 UE 同语义验证。

如果本 change 只做 compiler architecture refactor，则应还原 token set，并用不改变 accepted syntax 的 fixture 推进 Parser action。

### F6 — Blocking：Cache V2 仍不是 function-body complete canonical AST DTO

第三轮 R04 finding 仍完整存在，本轮相关实现没有关闭它。

`as_ast_sidecar.cpp:271-304` 的 `asCASTCollectFunctionRecords()`：

- 显式 `(void)profile`；
- hash 只包含 function key、decl type、quals、traits、origin、default arg、dependencies；
- 不包含 `decl->body`、stmt/expr/literal、resolved references、conversion/call plan、cleanup、source content identity。

因此 pure body edit 仍可能错误复用旧 sidecar。

`as_ast_sidecar.cpp:62-224` 的 encode/decode 仍然：

- encode textual dump + declaration table；
- decode 读取 dump 但不使用；
- 只重建 TU/declarations/type keys；
- 不重建 SourceManager、body、stmt、expr、resolved target、dependencies graph、cleanup plan；
- 最后对 declaration skeleton 调用 `Seal()`。

这不满足 `as-incremental-script-cache/spec.md:3-24` 的 pointer-free body DTO 和 ExactStartup complete verified module AST reconstruction。

第三轮最新 Cache report 仍为 `5/7 PASS`；本轮没有新的 Cache sidecar 保存报告，也没有修改 Cache fixture。即使把 `F/H` 断言修成 `F()/H()`，body-less hash 与 skeleton decode 仍然是 Blocking。

### F7 — Blocking：snapshot Acquire/publication 仍有并发 UAF 和 last-good 丢失窗口

当前 `as_module.cpp:1999-2010`：

```text
read raw astSnapshot
check version
astSnapshot->AddRef()
return
```

publish/release 可在 raw pointer read 与 AddRef 之间释放对象。

`PublishCanonicalASTSnapshot()` 在 `as_module.cpp:2056-2064` 先：

- 把 previous 标记为非 current；
- 清空 module pointer；
- release previous；

然后才在 2066-2110 seal/allocate candidate。candidate seal 或 allocation 失败时，last-good generation 已丢失。

同时：

- `currentGeneration` 仍是普通 bool；
- `astSnapshot` / `pendingCanonicalAST` / `astGeneration` 没有统一同步协议；
- public reader concurrency test 仍没有 race Acquire 本身；
- failed candidate keeping previous generation 的 adversarial test 未落地。

R06/13.8 继续保持 Blocking。

### F8 — Blocking：public AST V1 仍破坏旧 vtable，view 不尊重 caller capacity/version

`angelscript.h:1058-1061` 把三项 AST API 插入 `asIScriptModule::CompileFunction` 与旧 `SetAccessMask` 之间：

- `SetASTRetentionPolicy`；
- `GetASTRetentionPolicy`；
- `AcquireASTSnapshot`。

这是 mid-vtable insertion，不是 append-only ABI，也不是 extension interface。

`as_ast_public_view.cpp:64-143` 的 `GetDecl/GetStmt/GetExpr/GetType`：

- 不先读取 caller 给出的 `structSize/apiVersion`；
- 直接写完整当前 struct；
- 最后把 caller 字段覆盖为当前 size/version；
- smaller old caller buffer 会发生越界写风险；
- same-index foreign snapshot ID 仍可能被当成本 snapshot 的合法 ID。

R05/13.7 的 smaller-view canary、incompatible-version rejection、foreign-ID domain 和 ABI append-only gate 都未完成。

### F9 — Blocking：R09 Task 1 有进展，但 success path 仍多持有一个 function internal ref

有效进展：

- `DiscardAllocatedGlobals()` 已加入；
- 保存的 Transaction `3/3 PASS` 覆盖 unsealed、signature failure、部分 prior-function rollback；
- R11 failure teardown 的 bytecode-before-AddReferences extra-release 已修复。

但 `as_bytecode_codegen.cpp:1614-1622` 的 successful commit 仍执行：

```cpp
func->AddReferences();
module->scriptFunctions.PushLast(func);
func->AddRefInternal();
module->globalFunctions.Add(func);
module->globalFunctionList.PushLast(func);
```

对比正常新 function 注册路径 `as_module.cpp:1443-1452`：

```cpp
// The internal ref count was already set by the constructor
scriptFunctions.PushLast(func);
engine->AddScriptFunction(func);
```

canonical CodeGen 创建的是全新的 `asCScriptFunction`，constructor 已给 internal ref。额外 `AddRefInternal()` 会使 module reset 时：

- `DestroyInternal()` + 单次 `ReleaseInternal()` 后对象仍可能剩余一个 ref；
- destructor 不运行，Engine `scriptFunctions` slot 不一定被移除；
- 形成 leak/stale registry 或延迟到不正确生命周期释放的风险。

现有 Transaction tests 主要验证 Generate failure 前后 count，不验证成功 Generate 后 module reset / Engine teardown 的最终 refcount/registry 清空。

更根本地，`Generate()` 仍在 emit 全部成功前直接：

- `AllocateGlobalProperty()`；
- `GetNextScriptFunctionId()`；
- `engine->AddScriptFunction()`。

`as_bytecode_codegen_artifact.h` 仍不存在，没有 detached artifact + atomic installer。因此 9.1/9.5/13.6/10.4 必须继续 open。

### F10 — High：Sema action 覆盖扩大，但仍不是 sole semantic authority

本轮 Parser/SemaAuthority `61/61` 和 CanonicalAST `76/76` 说明实现速度和 fixture 覆盖都在提升，尤其是：

- declaration actions；
- overload/conversion/call plan；
- lambda declaration；
- return statement action；
- incomplete parse 保留已 ActOn declaration。

但结构上仍然：

- Parser 构造 `asCScriptNode` recovery tree；
- `as_sema_decl/expr/stmt` 的主要 lowering 仍是 `WalkOne` / `ActOn*FromNode` 遍历 Parser nodes；
- 部分 action 先产生孤立 expr/stmt，再依赖后续 full function walk 去重/重建；
- production `asCCompiler` 仍重新做真正语义判断；
- incomplete action 的 scope/identity protocol 仍有 `namespace A::B` 等缺口；
- complete stable key 仍缺 param qualifier/ABI/profile/module-source identity；
- Runtime FunctionKey↔AST exact owner mapping仍未闭环。

所以 13.2/13.3 继续 open 是正确的。当前应称为 shadow Sema graph，不应从 action test 数量推导“sole authority 已完成”。

## 已经可以保留的 closure

### R07 / 2.4 / 13.4：可暂时保持 closed

当前 ASTContext 已有：

- 64 KiB slab/block arena；
- private `DestroyAll`；
- public construction API；
- public `GetDecl/GetStmt/GetExpr/GetSourceManager` 只返回 const；
- private `Mutable*`；
- sealed 后 construction mutation fail closed；
- snapshot 只暴露 const Context。

节点字段仍是 internal public POD，这不是理想最终封装，但在没有 mutable Context pointer 泄漏的前提下，可以把 field-friend 化留作后续内部卫生，不需要因此重新打开 13.4。

### 2.6 Runtime type bridge：可按 scoped foundation 保持 closed

`FromDataType()` 已按 Engine type flags 区分 enum/funcdef/template/value/ref，并通过稳定格式串与 QualType quals 表达，不把 pointer/typeId 当 durable public identity。后续 namespace ambiguity、full qualifiers、Cache decode kind fidelity 仍属于 4.3/6.3/R03/R04，不必把所有未来 type work 塞回 2.6。

### R11：继续保持 closed，但增加 success teardown gate

第四轮没有发现 R11 原 teardown AV 复发。它应继续作为 CodeGen 回归门禁，而不是当前 blocker 名称。新增的 extra `AddRefInternal()` finding 属于 R09 success publication ownership，应通过 module reset/Engine teardown test 单独关闭。

## OpenSpec 状态审计

| 项目 | 当前状态 | 第四轮建议 |
| --- | --- | --- |
| 2.4 / 13.4 arena+seal | checked | 保持 checked |
| 2.6 runtime type bridge foundation | checked | 保持 checked，但不要外推为 complete identity |
| 2.8 verifier implementation | checked | **reopen**：expr graph/required targets/nearest transfer 等未满足 malformed graph spec |
| 13.5 verifier firewall | checked | **reopen**：任务文字和 capability spec 明确未完成 |
| 13.1 production provenance | open | 保持 open |
| 13.2 sole Sema authority | open | 保持 open |
| 13.3 complete identity | open | 保持 open |
| 13.6 production transactional CodeGen | open | 保持 open |
| 13.7 public ABI | open | 保持 open |
| 13.8 snapshot protocol | open | 保持 open |
| 13.9 Cache DTO | open | 保持 open |
| 13.10 SourceManager truth | open | 保持 open |
| 13.11 adversarial matrix | open | 保持 open |
| 13.12 final validation | open | 保持 open |

另外，`tasks.md` 中一些早期段落仍保留过时的“CANONICAL/Ready true”叙述，而 section 13 已正确写成 LEGACY/Ready false。实现继续前应统一文档时态，避免同一文件向 agent 提供冲突 guidance。

## 推荐修正顺序

### 立即止血

1. 修复 F1 lambda recovery-tree/legacy consumer 协议，并增加默认 production build+execute 测试；
2. 决定 `interface` / `typedef` 是本 change 的语言决策还是误入范围；没有明确 spec revision 前先不要依赖它们关闭 Parser task；
3. 增加 `namespace A::B::C` action/dump/lookup/differential 红测试；
4. 重新打开 `2.8` / `13.5`，把 verifier requirement 做成逐项 matrix。

### 然后完成可信 publication 基础

5. 修正 CodeGen success ref ownership；
6. 把 `Generate()` 拆成 detached artifact + validated atomic installer；
7. 完成 public AST extension/append-only ABI 与 bounded view negotiation；
8. 完成 snapshot retain/exchange/current-generation 同步协议；
9. 完成 body/profile/source/reference/cleanup complete Cache DTO 与 ExactStartup reconstruction。

### 最后才 cutover

10. 完成 Sema/identity/SourceManager 全语义闭环；
11. 让 production `Build()` 只消费同一 sealed verified snapshot；
12. 以 publisher fail-closed、legacy/canonical differential、Cache/HotReload/StaticJIT、Standalone、All suite 作为最终门禁；
13. 只有此后才能删除 duplicate HIR / legacy semantic production path 并归档 change。

## 第四轮判定

```text
Direction:               正确，继续保留现有 scaffold
Implementation progress: 有明显进展
Production regression:   有，lambda recovery-tree consumer protocol
Spec conformance:        未达到；Verifier closure 与 token syntax change 存在偏差
Production authority:    未切换
Cache/public/concurrency: 仍有 Blocking contract
Archive:                 No
Production default:      No
Review result:           Request changes
```

本轮只新增 review 文档和会话记录；没有修改插件实现，没有替实现者勾选/取消 tasks，也没有运行 build/test。后续 agent 修改超过 19:35 后，应重新做 point-in-time review，不能把本文结论或保存测试数字自动外推到新快照。
