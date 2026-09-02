# Canonical Typed AST Compiler 第九轮实现复审 — 2026-08-22

## 结论

本轮结论仍为 **Request changes**。当前仍不能归档，不能把 CANONICAL 设为默认，不能删除 LEGACY/HIR，也不能把 `IsCanonicalBytecodeCodeGenReady()==true` 或 OpenSpec `56/105` 解释为完整 production compiler ready。

不过，相对第八轮已经出现一组明确、可验证的实质进展：

- `.` postfix member call 不再提前发布 receiver-less CALL；
- `Make().Get()` 已通过 canonical CodeGen 执行并得到 `Trace(1), Trace(2)`，receiver single-evaluation 的这条具体 RED 已关闭；
- scoped / unresolved call replay 改成完整 source range identity；
- construction type 已区分 script `class` 的 reference/implicit-handle 与 `struct` 的 value semantics；
- script member same-name/same-arity fallback 已删除，native template method 会先实例化参数类型再参与 ranking；
- Param / Enumerator replay 已改成 same owner + same source range，distinct-range duplicate 会保留并报告；
- CANONICAL `asCModule::Build()` 已真实经过 `SealCanonicalAST()` 和 `asCBytecodeCodeGen::Generate()`，不再只是把 legacy Bytecode 标成 canonical provenance；
- 最新保存构建 `wave-b-54-1070` 与最新 Sema/CanonicalAST/Verifier/Compiler 前缀都没有 failure。

因此，第八轮 F1–F5 不能原样继续写成未修复。新的准确定位是：

> **canonical Parser/Sema/AST/Bytecode 的 opt-in vertical pipeline 已经真实可执行，并开始覆盖对象、容器和成员调用；但 backend 仍会重做部分 overload/ABI 决策，CodeGen artifact 并不 detached/atomic，Verifier、Cache、public snapshot 和 SourceManager 也尚未形成 production firewall。**

方向没有问题，不应推倒 canonical typed AST；现在应从“继续增加能跑的语法切片”转向“关闭 semantic authority、backend exactness、module transaction、snapshot/cache durability 四条系统边界”。

## 时间点与审查边界

- worktree：`D:\as-cta`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time cutoff：**2026-08-22 16:54:26（Asia/Shanghai）**；
- parent / plugin dirty paths：`20` / `108`；实现位于 dirty worktree，不等于两个 HEAD；
- reviewer 没有主动启动 build/test，没有修改 plugin 实现或 `tasks.md` checkbox；
- 本报告只读核验源码、OpenSpec 和实现者保存的 Build/Test JSON；
- cutoff 时没有运行中的 UnrealEditor / UnrealEditor-Cmd 进程。

为避免实现方继续写入后造成时间点歧义，本轮关键文件快照 SHA-256 前缀为：

| 文件 | SHA-256 前缀 |
| --- | --- |
| `as_parser.cpp` | `A6F022862E3C` |
| `as_sema.cpp` | `75F5156DAD75` |
| `as_sema_expr.cpp` | `C27234D4D164` |
| `as_bytecode_codegen.cpp` | `D4FD3AFC6AF5` |
| `as_ast_verifier.cpp` | `173CA1EF3A30` |
| `as_module.cpp` | `FF912191C238` |
| `as_ast_public_view.cpp` | `1A0C04E85712` |
| `as_source_manager.cpp` | `EB60196F8967` |
| `as_ast_sidecar.cpp` | `D2266F259F6E` |

## 保存验证证据

以下均为实现者运行、reviewer 只读核验的保存结果。

### Exact-current build / broad prefixes

| Label | 结果 | 说明 |
| --- | ---: | --- |
| `wave-b-54-1070` | Build exit `0` | 16:44:44 完成，晚于本轮最新 Sema/Parser 源码；UBT `Result: Succeeded` |
| `wave-b-54-1070-sema` | `236 success / 0 warning / 0 failed` | exact-current SemaAuthority |
| `wave-b-54-1070-canonical` | `285 success / 0 warning / 0 failed` | exact-current Compiler.CanonicalAST |
| `wave-b-54-1070-ver` | `16 success / 0 warning / 0 failed` | exact-current Verifier 前缀 |
| `wave-b-54-1070-compiler` | `474 success / 1 succeeded-with-warning / 0 failed` | 合计 `475`；不是纯 `475/475 PASS`，warning 仍来自 TypedSemanticIR SourceProvenance integration |

### 第八轮 F1–F5 修复证据

| 修复 | 保存结果 |
| --- | --- |
| member receiver single-evaluation | Semantics `5/5`；SemaAuthority `214/214`；CanonicalAST `263/263` |
| scoped/unresolved call full-range identity | SemaAuthority `219/219`；CanonicalAST `268/268`；Frontend `85/85` |
| class/struct construction type | SemaAuthority `222/222`；CanonicalAST `271/271` |
| native template method substituted ranking | SemaAuthority `228/228`；CanonicalAST `277/277` |
| Param/Enumerator range identity | SemaAuthority `236/236`；CanonicalAST `285/285` |

这些结果证明对应切片已经从 RED 到 GREEN。它们不证明 full-language Sema、full-language CodeGen、Cache restore、public ABI 或 atomic module activation 完成。

## 已关闭或显著收窄的第八轮 finding

### 第八轮 F1：member orphan CALL 与 `Make().Get()` 多次求值 — 已关闭当前具体路径

- `as_parser.cpp:1842-1867` 的 `ParseFunctionCall(bool notifySema)` 支持延迟 Sema notification；
- `as_parser.cpp:2360-2369` 在 `.` postfix child 上调用 `ParseFunctionCall(false)`；
- `as_sema_expr.cpp:1679-1693` 只有在 receiver 已知后才建立 member call，并从 Sequence 去掉重复 receiver part；
- `as_bytecode_codegen.cpp:1944-1980` 复用 CALL child 中已经求值的 receiver offset；
- `CanonicalMemberPostfixCallEvaluatesReceiverOnce` 已由 `4/5` RED 变成 `5/5` GREEN。

这条具体 bug 不应继续列为 blocker。但 `OpaqueValue`/index/property/mutation 的完整 5.4 matrix 仍未完成，不能由一个 member-call case 推导 5.4 已关闭。

### 第八轮 F2：scoped/unresolved call replay identity — call 路径已修

`FindExistingCallByFullRange()` 现在比较 begin/end file+offset，覆盖 offset 0 和 unresolved CALL，并能返回同 range 的 Materialize wrapper。`Game::F()` 不再把 identifier offset 与 whole-call begin 混为一谈。

但一般 `FindExistingExpr()` 仍按 `kind + begin file/offset` 扫描整个 arena，并拒绝 begin offset 0；见本轮 F5。Call 修复没有建立全局 action identity protocol。

### 第八轮 F3：`T()` 一律 VALUE_OBJECT — 已修

`QualTypeFromClassDecl()` 读取 `asAST_TRAIT_VALUE`：script class 得到 `REFERENCE_OBJECT + HANDLE + AUTO_HANDLE`，script struct 得到 `VALUE_OBJECT`。这消除了 declaration/runtime descriptor 与 construction expression 的直接类型冲突。

### 第八轮 F4：script same-arity-first 与 unresolved→int — 主要路径已修

- script member miss 不再按同名同 arity 选择第一个 method；
- unresolved construction-API Call/DeclRef 使用 `asAST_TYPE_ERROR` 并记录 stable diagnostic；
- native template method 参数先经过 `DetermineTypeForTemplate()`，`array<int>::insertLast(const T&in)` 可作为 `const int&in` ranking；
- Sema test 已锁住 ambiguous、type mismatch、mixin 和 template same-arity 情况。

但 Parser-range unresolved DeclRef 仍存在 silent-int recovery，Verifier 也允许无 target CALL/DeclRef publication；因此 fail-closed production contract 仍未完成。

### 第八轮 F5：Param/Enumerator bare-name replay — 已修

`ActOnStartParamDecl()` / `ActOnStartEnumeratorDecl()` 只复用 same owner + same range。distinct-range same-name 节点会保留并产生 `duplicate-param:` / `duplicate-enumerator:`，anonymous empty-range param 也不会被错误合并。

## 当前 Findings（按严重性排序）

### F1 — Critical：CodeGen artifact 名义上 detached，实际仍在 emit 期间修改 live Engine/module；失败也不能保留 last-good module

这是当前最重要的切换 blocker。

`asCModule::Build()` 在任何新 parse/Sema/CodeGen 成功之前就调用 `InternalReset()`（`as_module.cpp:386-396`），旧 module 的 functions/types/globals/imports 已先被销毁。因此即使新 candidate 失败，也不可能满足 spec 的“failed replacement preserves current module and snapshot”。

`asSBytecodeCodeGenArtifact` 只保存四个 pointer arrays，但实际 Generate 过程仍会提前修改 live state：

- `RegisterCanonicalScriptTypes()` 直接写 `engine->allRegisteredTypesByName`、`module->classTypes`、`module->allLocalTypes`（`as_bytecode_codegen.cpp:2407-2518`）；
- `FillFunctionSignature()` 在 emission 成功前直接改 `objType->beh.construct/destruct/constructors`、`methods` 和 `methodTable`（`2523-2603`）；
- imports 通过 `module->AddImportedFunction()` 立即安装（`2844-2925`）；
- functions 在 body emit 前通过 `engine->AddScriptFunction()` 注册（`2927-3005`）。

而 `Artifact::Abandon()` 只回收 functions/globals，随后简单 `funcdefs.SetLength(0)` / `types.SetLength(0)`（`2609-2642`）。它没有撤销 type registries、module type arrays、imports、object behaviours、constructors、methods 或 methodTable。`Commit()` 也只是把 function pointers append 到 module arrays，不是一次 no-fail atomic exchange。

影响：任一 property/type/import/function/body failure 都可能留下 registry、method table、behaviour 或 ID 空洞；在 module rebuild 语义下，old-good module 已经先被 `InternalReset()` 擦除。

建议：

1. candidate module/context/type/function/import/global tables 必须在 detached storage 上完整构造；
2. emission、relocation、verification 全部成功后一次 activation；
3. 若必须复用 live Engine ID allocator，建立覆盖每个 mutation 的 transaction journal，并证明 rollback 后 before/after byte-equivalent；
4. module replacement 在 candidate 完成前不得 `InternalReset()` current generation；
5. 9.1 / 13.6 / 10.4 保持 open，并新增 type/import/behaviour/method-table failure injection。

### F2 — Critical：Bytecode CodeGen 会丢掉 Sema 的 exact native/member target，再按“名字 + 参数数量”重新选 Runtime method

Sema 现在可以正确选择 `array<int>::insertLast(const int&in)`，但 CodeGen 未必执行这个 exact target。

`EmitCall()` 首先用 AST DeclId 查 `FindFunc()`。native method 通常没有 canonical body bind，查找失败后，CodeGen 从 receiver Runtime type 重新遍历 `FindMethodUntil(name)`，只接受以下任一 arity 条件并返回第一个 method（`as_bytecode_codegen.cpp:1893-1934`）：

```text
method.params == userArgs
method.params == expr.children
method.params + 1 == expr.children
```

它没有比较 canonical parameter types、in/out/ref/handle qualifiers、const method、stable declaration key、route/ABI 或 Sema 已选的 exact signature。若 Runtime type 有多个同名同 arity overload，Sema 可以选对，CodeGen 仍可能调用第一个错误 overload。

constructor fallback 同样在 `EmitConstruct()` 中按 argument count 调 `FindConstructorId()`（`1440-1447`），而不是强制绑定 `expr->resolvedDecl` 的 exact Runtime function。

这直接违反 `as-canonical-compiler-pipeline` 的“backend MUST NOT perform overload lookup”和 `as-canonical-typed-ast` 的“backend traversal does not perform another overload search”。它也意味着 checked 的 9.4 仍是 false-complete。

建议建立 canonical stable target → exact Runtime callable binding table；bind 失败必须 fail-closed，禁止 backend 再按 name/arity 猜测。新增同名同 arity native/member/constructor execute tests，而不只检查 Sema dump。

### F3 — Critical：对象 layout、窄/宽值读写、handle/value lifetime 仍存在潜在截断、越界和引用计数错误

当前 CodeGen language surface 已增长，但 ABI/lifetime helper 仍不是通用实现：

- script type registration 只扫描 translation-unit direct children，nested namespace type 会漏掉；
- type collision按裸 `child->name` 查询，namespace/module owner 不在 key 中（`2430-2434`）；
- `st->alignment` 固定为 4，property type resolve 或 AddProperty 失败时静默 `continue`（`2436-2515`）；
- `EmitReadValue()` / `EmitWriteValue()` 只按 dword 数选择 `RDR4/RDR8` 与 `WRTV4/WRTV8`（`426-448`），1/2-byte property 会读写 4 bytes，>8-byte value 只处理 8 bytes；
- `StoreGlobal()` 无论 data type 都使用 `WRTV4`（`993-999`），64-bit global assignment 会截断；
- 多个 member store 分支固定 `WRTV4`（`1206-1231`, `1573-1594`）；
- list buffer 对 value object/handle 只做 raw value write，未证明 construct/copy/AddRef/destroy/failure cleanup；
- handle/reference setter、assignment、return 与 cleanup 还没有完整 AddRef/Release/liveness matrix。

这些不是“暂时少支持一个语法”的问题，而是 Build 成功后可能产生错误内存访问或 lifetime。支持面必须先严格 fail-closed：只有 exact width/alignment/behaviour/lifetime 已证明的 shape 才能 canonical Build 成功。

9.2、9.4 的 checked 状态需要按原任务全文重新审查；9.5 保持 open 是正确的。

### F4 — Critical：integer/default/global/member initializer 仍通过 C 字符串和宿主窄解析器传递，64-bit 与表达式语义会丢失

canonical AST 还没有真正的 typed initializer plan：

- integer literal 和 default argument 使用 `strtoul()`（`as_sema_expr.cpp:1406-1415`, `1775-1779`; `as_sema_decl.cpp:1896-1899`）。Windows 的 `unsigned long` 是 32-bit，超过 32-bit 的 literal/default 会截断或饱和；
- generated member default 使用 `atoi(member->defaultArg)`（`as_sema_decl.cpp:665-677`），`40 + 1` 会变成 40，64-bit/enum/named constant/conversion 也无法表达；
- global initializer仍保存到 declaration `defaultArg` string，再由 CodeGen `strtoll()` 解析并直接写内存（`as_bytecode_codegen.cpp:2772-2837`）；unsigned 64-bit 大值、非十进制、constant expression、enum、conversion 和 overflow diagnostics 不完整；
- `AppendDefaultArguments()` 从 string新造 integer literal，而不是引用 Sema 已验证的默认 expression/constant plan。

未来 LLVM lowering若读取这些事实会稳定地产生错误 native code。应把 default/member/global initializer 全部表示成 canonical typed Expr/ConstValue/InitPlan，字符串只保留为诊断/source spelling，不再作为 backend contract。

### F5 — Blocking：一般 expression replay identity 仍是 arena 猜测，Sema 仍大量从 `asCScriptNode` 重放语义

Call 的 full-range identity 已修，但通用 `FindExistingExpr()` 仍只比较 kind、file 和 begin offset，忽略 end、owner、semantic role、operands、callee和generation，并显式拒绝 offset 0（`as_sema_expr.cpp:35-52`）。同 source begin 的 recovery wrapper、conversion、operator rewrite 或不同 owner expression 仍可能被错误合并；另一些 replay 则会漏复用。

本轮静态扫描在 `as_sema*.cpp` 中仍有 `223` 行命中 `asCScriptNode` / `ActOnParsed*` / FromNode 相关路径；`ActOnExprFromNode()` / `ActOnStmtFromNode()` 仍被大量用于 call args、index、postfix、cast、binary、condition、loop、return、initializer和default dispatcher。`InternParsedCall()` 本身也递归 `ActOnExprFromNode()` 解释 argument child。

这说明 13.2 仍是“syntax-node semantic replay + 部分 dedicated actions”，而不是 Parser action identity → Sema environment → exact immutable node。现有 `236/236` 很有价值，但不能把 test method 数量当成 sole authority。

建议为 Parser action建立明确 identity/token-range+owner+role key，Sema维护 pending/completed action map；完成 action应以 semantic operands 为参数，不再让 backend或第二遍 WalkOne从 `asCScriptNode` 重新提取 meaning。

### F6 — Blocking：Verifier 仍允许 executable CALL/DeclRef 缺少 required target，且没有 expression ownership/cycle/reachability firewall；13.5 不应保持 checked

`as_ast_verifier.cpp:472-539` 只在 `resolvedDecl.IsValid()` 时检查 DeclId 是否存在。它不要求 CALL、CONSTRUCT、DECL_REF、CLEANUP 等需要 target 的 node 必须有 target；也不验证 call target kind、signature、receiver、argument role/order、type compatibility或route metadata。

Stmt 已增加 parent/multi-owner/cycle检查，但 Expr 没有对应 parent table、single-owner/reachability/cycle检查。arena 中孤儿或多 owner expression仍可 Seal。`ExpectedExprChildCount()`只检查固定 operand count，不能证明语义完整。

当前 unresolved CALL 使用 `asAST_TYPE_ERROR`，但 node kind 仍是 `asAST_EXPR_CALL`，Verifier会接受它；`asCASTVerifyPublication()`只先检查 `IsSealed()`，随后调用同一宽松 verifier。因此 recovery/error graph仍可能被 publish 给 CodeGen，而不是只留在失败candidate中。

OpenSpec 13.5 的原任务明确包含“resolved signatures、cleanup plans、Seal before consumer”。当前实现未达到该文字，应重新打开 13.5，并区分：

- construction-time verifier：允许 incomplete/error nodes；
- publication verifier：所有 executable reachable nodes必须具备 required targets/types/roles，任何 error/recovery node都阻止 executable publication。

### F7 — Critical：Cache `ASTBodySidecar` wrapper 丢弃调用者的 `CanonicalAstBytes`，fork codec 也只重建 declaration skeleton

`AngelscriptEncodeASTBodySidecar()` 只用 `CanonicalAstBytes.Num()!=0` 判断“非空”，随后新建一个只含 translation unit 的空 `asCASTContext` 并编码它；**传入的 `Sidecar.CanonicalAstBytes` 内容从未写入输出**（`AngelscriptCacheASTBodySidecar.cpp:39-72`）。因此 `{1}`、`{2}` 或真实body bytes会产生同一类空图 envelope。

Decode又把整个 encoded envelope原样追加到 `OutSidecar.CanonicalAstBytes`，而不是恢复原始 caller payload或完整 function-body DTO。

fork `asCASTEncodeSidecar()` 只写 text dump和 declarations 的 kind/parent/quals/traits/name/typeKey（`as_ast_sidecar.cpp:62-113`）；没有 SourceManager、canonical type table、Stmt、Expr、body ownership、references、dependencies、cleanup/call plan。Decode把所有 named type都按 `VALUE_OBJECT`重建（`170-224`），不能保持 class ref、enum、funcdef、template或exact qualifiers。

测试 `Sidecar.CanonicalAstBytes = {1}` 本身已经说明当前只是 envelope fixture，不是 13.9 DTO fidelity。6.3、6.4、6.6、13.9 保持 open是正确的；在这些完成前，Cache不能作为 retained AST authority或ExactStartup source。

### F8 — Blocking：public AST V1 仍是 mid-vtable breaking change，view size/version和snapshot concurrency协议都不安全

`asIScriptModule` 在 `CompileFunction()` 与 `SetAccessMask()` 之间插入三个AST virtual methods（`Core/angelscript.h:1045-1063`），会移动后续所有虚函数slot；这不是兼容扩展。

`asCASTSnapshot::GetDecl/GetStmt/GetExpr/GetType()` 不读取 caller 提供的 `structSize/apiVersion`，而是直接按当前完整 struct写入并覆盖 header（`as_ast_public_view.cpp:64-143`）。旧/小 view buffer会被越界写，incompatible version也不会被拒绝。

snapshot lifetime同样不是 atomic publication protocol：

- `AcquireASTSnapshot()` 先读 raw `astSnapshot` 再 `AddRef()`；与 publish/release并发时存在 use-after-free window（`as_module.cpp:2050-2062`）；
- `currentGeneration` 是普通 bool，读写非原子；
- `PublishCanonicalASTSnapshot()` 先把 previous标 stale、清空并 Release，再从 pending context构造 candidate（`2107-2161`）；allocation/seal失败会丢失last-good snapshot；
- opaque ID只有1-based numeric index，没有snapshot domain token；foreign snapshot中相同index可被接受。

3.2/3.4/3.7、13.7/13.8/13.11保持 open是正确的。建议把AST能力放到append-only extension/query interface，并用锁或atomic pointer + retain protocol完成Acquire/exchange；candidate必须先构造/verify，再一次发布，old snapshot在exchange后才标stale/release。

### F9 — Blocking：SourceManager remap只按 logical key + origin复用，完全不校验content identity

`asCSourceManager::RemapLogical()` 调用 `FindFile(logicalKey, origin)`，一旦命中直接返回旧 FileID；传入的 `bytes`、`byteCount` 和 `lineOffset` 都不比较（`as_source_manager.cpp:176-204`）。相同逻辑路径但内容或line mapping已变化时会静默复用错误source table。

同时，当前Lexer/Parser/legacy diagnostics并没有统一以SourceManager作为唯一坐标事实；public/cache view也没有完整持久化source identity/content digest。2.2与13.10保持 open是正确的。

应为section记录stable logical key、origin、content hash/length、line-offset policy与generation；remap mismatch必须创建新snapshot-local FileID或fail restore，而不是复用旧表项。

### F10 — Blocking：production entry/consumer cutover仍未统一，`Ready()`还在无条件返回 true

虽然 CANONICAL module `Build()` 已真实调用 canonical CodeGen，这是本轮最大的架构进展，但完整cutover还没有发生：

- public `asCModule::CompileFunction()` 仍走 `asCBuilder::CompileFunction()` / `asCCompiler`（`as_module.cpp:1946-2010`）；
- default仍是 LEGACY（`as_scriptengine.cpp:787`）；
- `IsCanonicalBytecodeCodeGenReady()` 直接 `return true`（`as_scriptengine.h:249-253`），没有反映language surface、module shape、retention、snapshot、cache或entrypoint readiness，且与13.1“must not be unconditionally true”直接冲突；
- TypedASTJIT仍有7.2/7.4/7.5/7.8未完成，HIR相关production/source references仍大量存在；
- 10.1–10.7、10.9仍全部open；
- final active SDK/Script corpus differential、metadata、Standalone/All canonical-default gates未运行。

建议将 `Ready` 拆成：binary capability、module preflight eligibility和last-build publisher/provenance；不要用一个无条件bool表达三种状态。CANONICAL opt-in只允许通过exact preflight的module，默认继续LEGACY。

## OpenSpec checklist 审计

机械状态仍为 `56/105 = 53.3%`，本轮没有修改 checkbox。以下状态是诚实的：

- 13.1、13.2、13.3、13.6–13.12 open；
- 4.2–4.6、5.2–5.9、6.3/6.4/6.6、7.2/7.4/7.5/7.8 open；
- 9.1、9.5–9.7、10.1–10.7/10.9 open。

需要重新审查的 checked 项：

1. **13.5**：publication verifier缺required callee/DeclRef target、expr ownership/cycle/reachability/signature/receiver/arg role，按任务全文不应closed；
2. **9.4**：CodeGen仍按name/arity重新选native/member/constructor target，不能称“from resolved canonical call nodes”；
3. **9.2**：global/member/narrow/wide/value write并非exact width/lifetime，原任务中的“exact conversions、reads/writes、return marshalling”尚未完整；
4. **12.1/12.5**：保存build/validation只证明当时snapshot；当前仍是dirty dual-repo实现，不应视为final archive readiness；
5. **11.3**：文档若仍写“production Bytecode still asCCompiler”已被CANONICAL Build route部分推翻，需要更新为“default LEGACY；explicit CANONICAL Build uses CodeGen subset；CompileFunction仍Compiler”。

## 当前完成度

建议继续分三种指标：

| 指标 | 当前判断 | 说明 |
| --- | ---: | --- |
| Mechanical checklist | `56/105 = 53.3%` | 含上面列出的 false-complete，不代表ready |
| 架构资产完成度 | 约 `56%–60%` | AST/Sema actions、Verifier骨架、public/cache骨架、TypedASTJIT适配、真实canonical Build/CodeGen slices都已存在 |
| Production compiler cutover readiness | 约 `40%–45%` | 比第八轮`35%–40%`上升，主要来自F1–F5与真实Build route；但atomic module、exact backend binding、ABI/lifetime、Verifier、Cache、snapshot/ABI、entrypoints仍是硬门槛 |

用流水线表示：

```text
Parser/Sema actions        ██████░░░░  约60%
Canonical semantic graph  ██████░░░░  约55–60%
Bytecode language/ABI      ████░░░░░░  约40–45%
Atomic module install      ██░░░░░░░░  约20%
Snapshot/Public ABI        ███░░░░░░░  约25–30%
Cache exact restore        ██░░░░░░░░  约15–20%
All-entry cutover          ██░░░░░░░░  约20–25%
```

这些百分比是review估算，不是测试覆盖率。当前阶段从“A后半段/B早中期”推进到了 **B中期**：canonical module Build已经是真实backend route，但尚不能作为默认production compiler。

## 推荐的下一条最短关键路径

1. **先修F2 exact Runtime binding。** Sema选中的stable declaration必须直接绑定exact native/member/constructor callable；删除CodeGen name/arity search。
2. **完成F1 detached candidate + atomic activation。** 覆盖type/import/behaviour/method/global/function所有failure injection，并保留last-good module/snapshot。
3. **把Verifier升级为publication firewall。** required target/signature/receiver/arg role、expr ownership/cycle/reachability、error-node prohibition。
4. **收紧CodeGen ABI/lifetime支持门。** 在通用width/layout/handle/value lifetime完成前，危险shape整模块fail-closed。
5. **把initializer/default改为typed AST plan。** 删除`strtoul/atoi/defaultArg string`作为backend语义协议。
6. **完成Sema action identity与FromNode退场。** 以semantic operands/action identity替代arena scan replay。
7. **闭环public snapshot + Cache DTO + SourceManager。** atomic lease、size/version、foreign domain、complete body DTO、content identity。
8. **最后统一CompileFunction/HotReload/generation/commandlet/Standalone和final canonical provenance gates。** 完成后再讨论默认CANONICAL与LEGACY退场。

## 最终判断

实现方向没有偏。第八轮最担心的member-call协议已经被快速、正确地修正，canonical Build也跨过了“只是shadow AST”的门槛，证明整条新compiler链路可行。

但当前最大风险已经从“前端能不能生成节点”转成“生成的exact语义会不会在backend/安装/持久化边界被重新猜测、部分发布或丢失”。在F1–F10关闭前：

- 默认继续LEGACY；
- CANONICAL只作为显式opt-in/dogfood；
- 不删除HIR或legacy compiler；
- 不归档OpenSpec；
- 不开始正式LLVM backend实现，只保留backend-neutral boundary检查。
