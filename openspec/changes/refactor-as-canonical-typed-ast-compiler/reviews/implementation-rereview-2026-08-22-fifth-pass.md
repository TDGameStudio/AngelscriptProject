# Canonical Typed AST Compiler 第五轮实现复审 — 2026-08-22

## 复审结论

当前实现仍为 **Request changes**。

不能归档，不能把 `CANONICAL` 切成 production default，也不能把 `IsCanonicalBytecodeCodeGenReady() == true` 解读为“canonical compiler 已覆盖 AngelScript module build 的完整语言面”。

第五轮相对第四轮有一个重要且真实的状态变化：

> `asCModule::Build()` 在显式选择 `CANONICAL` 时，已经不再进入 `BuildGenerateTypes()` / `BuildGenerateFunctions()` / `BuildLayout*()` / `BuildCompileCode()`，而是把同一次 parse/seal 产生的 `asCASTContext` 交给 `asCBytecodeCodeGen::Generate()`。

因此，第四轮报告中“即使选择 CANONICAL，module Build 最终仍由 `asCCompiler` 发布 Bytecode”这一条，**对当前 CANONICAL module Build 已不再成立**。保存的 `ProductionCodeGen 3/3`、`Cutover 5/5` 和 `Differential 2/2` 也证明了最小标量函数已经走通并能执行。

但新路由暴露了更直接的 production correctness 问题：

1. CodeGen 只收集带 body 的 function-like declaration；一个没有这类函数的 module 会直接成功返回，导致 global-only、type-only、interface/enum/funcdef/import-only 等 module 可能“Build 成功但没有安装声明”；
2. `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR` 被纳入 function list，但创建 runtime function 时没有设置 `objectType`，所有函数都被提交到 module global function tables；支持的 primitive member body 因而可能被错误安装成全局函数，而不是 fail-closed；
3. namespace、global initializer、type/funcdef/import/module-layout 等 production 语义没有完整安装路径；
4. `CompileFunction()` 仍明确走 legacy builder/compiler，而当前 Cutover test 主动接受这一混合发布者状态，这与任务 10.1/10.3/10.4/13.1 的文字不一致；
5. CodeGen 的所谓 artifact 仍在 Generate 阶段直接修改 Engine/module registry，不是 detached artifact + atomic install；
6. 第四轮的 lambda legacy layout 回归、Verifier firewall、Cache V2 DTO、snapshot publication、public ABI、SourceManager/Sema authority 等阻断均未关闭。

当前最准确的定位是：

> **已接入 opt-in production call path 的 canonical scalar Bytecode prototype，外加仍在迁移中的 canonical AST/Sema platform。**

它比第四轮的“isolated CodeGen prototype”前进了一步，但仍不是完整的 canonical production compiler。

## 复审快照与边界

- worktree：`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`；
- 短路径：`D:\as-cta`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time：**2026-08-22 00:39:42（Asia/Shanghai）**；
- parent/plugin 都有大量未提交和 untracked 变更；本报告审查的是共享 worktree 的这一时间点，不代表两个 HEAD 已提交的源码；
- 实现方在本轮检查期间继续修改了 `as_module.cpp`、`as_scriptengine.h` 和 Cutover tests，并产生了 00:37 的新报告；本报告已吸收这些最新落盘结果；
- 按用户要求，本 reviewer 没有主动 build/test，也没有修改 plugin 实现或 `tasks.md` checkbox；下述测试数字来自实现者保存在 `D:\as-cta\Saved\Tests` 的 JSON report，不是 reviewer 对 00:39 快照重新编译后的独立验收。

OpenSpec checklist 在快照时仍为：

- total：`105`；
- checked：`56`；
- open：`49`。

其中 `2.8` 与 `13.5` 仍然不满足自身文字，应至少重新打开；只纠正这两项时是 `54/105`。本轮进一步确认 `3.5`、`3.6`、`12.6` 的 closure 也与现有 snapshot 协议和任务证据不相容，`6.7`、`7.6`、`8.4` 也应按其宽泛文字重新审计。checkbox 是机械进度，不是 production readiness 百分比。

## 实现者保存的最新测试证据

| Label / 范围 | 保存结果 | 本轮解释 |
| --- | ---: | --- |
| `r09-prod-ready` / ProductionCodeGen | `3/3 PASS` | 证明 canonical module Build 的最小 `int F()` 路由、legacy publisher 和一个 value-object fail-closed case；不覆盖完整声明面 |
| `r09-cutover-green` / Cutover | `5/5 PASS` | 证明当前测试定义下 primary/HotReload-like/generation-like/commandlet-like/Standalone-like 均能运行；其中多个只是同一 native helper 的别名，不是实际 host 路径 |
| `r09-differential-publisher` / Differential | `2/2 PASS` | 证明最小 legacy/canonical 双 Engine 都能执行，且 publisher 标记不同；只覆盖一个标量返回函数 |
| `b-parser-fromnode-sema` / SemaAuthority | `128/128 PASS` | 证明现有 Parser→Sema action fixture 全绿；不证明 Sema 已摆脱 `asCScriptNode` post-walk |
| `b-parser-fromnode-canonical` / CanonicalAST | `143/143 PASS` | 证明 canonical frontend 聚合在当时 DLL 上全绿 |
| `b-parser-fromnode-compiler` / Compiler | `331/331 PASS` | 证明 00:20 时的 Compiler prefix 全绿；它早于 00:27 的 production Build 路由修改，不能验收当前新路由 |
| OpenSpec 附件中的 identity / transaction | `8/8 PASS`、`7/7 PASS` | 支持 non-lambda exact matching 和额外 internal ref 修复；不证明完整 lambda identity 或 detached atomic artifact |

`r09-cutover-publisher` 曾为 `4/5`，失败项是 retained snapshot 场景仍观察到 compiler publisher；随后实现/测试调整后的 `r09-cutover-green 5/5` 已取代这份中间红报告。它说明当前 test contract 已自洽，不自动说明 OpenSpec capability contract 已满足。

特别需要指出：

- `AngelscriptNativeCanonicalASTCutoverTests.cpp` 的测试名仍叫 `DefaultPipelineIsLegacyReadyIsFalseAndRejectsDual`，但当前断言已经改成 Ready 为 true，名称和行为相互矛盾；
- `CommandletLike` 和 `StandaloneLike` 都是在测试进程中创建同类 Engine/module 并调用同一 helper，没有启动真实 commandlet 或 Standalone frontend；
- `CompileFunction` case 明确期望 module Build 的 publisher 是 CANONICAL，而单函数追加仍由 COMPILER 发布。这是测试对混合 authority 的认可，不是任务 10.1/10.3/10.4 的 closure。

## 相对第四轮，哪些问题确实关闭或推进

### 已关闭/被新事实取代

1. **CANONICAL module Build 没有生产路由**：已关闭。`as_module.cpp:395-428` 现在直接调用 `asCBytecodeCodeGen::Generate(*pending, this)`。
2. **CodeGen success path 额外 `AddRefInternal()`**：已关闭。当前 `Commit()` 只做 `AddReferences()` 和 module table install；保存的 transaction evidence 为 `7/7`。
3. **最小 scalar function 只能 isolated Generate，不能经 module Build 执行**：已关闭。`ProductionCodeGen 3/3` 与 `Differential 2/2` 支持这一点。
4. **non-lambda runtime↔AST 只按裸名字匹配**：有实质推进。现在包含 owner/name/parameter identity 并要求 unique match；但 owner/type namespace 和 lambda identity 仍不完整。
5. R11 funcdef/lambda teardown crash 继续保持关闭，没有新崩溃证据。

### 仍未关闭

- complete declaration/type/layout/global/import installation；
- Sema sole authority；
- legacy lambda compatibility；
- detached/atomic CodeGen transaction；
- complete Verifier firewall；
- Cache V2 exact reconstruction；
- atomic snapshot/lease publication；
- append-only/size-negotiated public ABI；
- complete stable identity；
- SourceManager content truth；
- actual Commandlet/Standalone/Hot Reload/generation integration gate；
- final differential/all-suite verification。

## Findings（按严重性排序）

### F1 — Critical：CANONICAL Build 会对未支持声明“成功但漏装”，并可能把成员函数装成全局函数

这是第五轮最重要的新 finding。

`as_module.cpp:395-428` 的新 CANONICAL branch 在 parse/seal 后绕过了 legacy 的：

- `BuildGenerateTypes()`；
- `BuildGenerateFunctions()`；
- `BuildLayoutClasses()`；
- `BuildAllocateGlobalVariables()`；
- `BuildLayoutFunctions()`；
- `BuildCompileCode()`。

这本身是正确 cutover 方向，但要求 `asCBytecodeCodeGen::Generate()` 接管这些阶段的完整职责或对所有未实现形态整模块 fail-closed。当前两者都没有做到。

#### 无 function body 时直接成功

`as_bytecode_codegen.cpp:1558-1567` 只收集：

- FUNCTION；
- METHOD；
- CONSTRUCTOR；
- DESTRUCTOR；
- 并且 `decl->body.IsValid()`。

若列表为空，函数在检查 module/Engine、分配 globals、安装 types 之前就返回 `asAST_VERIFY_OK`。因此至少存在以下 fail-open 风险：

```text
global-only / declaration-only / enum-only / interface-only /
funcdef-only / import-only / type-only module
        ↓
functionDecls == 0
        ↓
Generate() returns success
        ↓
Build() publishes snapshot and reports success
        ↓
runtime module may contain none of those declarations
```

即使 module 有函数，globals 也只从 TranslationUnit 的直接 child 中处理（`1583-1607`）；nested namespace/class declarations、imports、funcdefs、types 和 layout 没有完整 commit 路径。显式 global initializer 也没有对应 initializer function/bytecode emission，因而不能保证 source initializer 的 observable semantics。

#### member/ctor/dtor 没有 owner 安装语义

`CanonicalDeclIsFunctionLike()` 明确把 METHOD/CONSTRUCTOR/DESTRUCTOR 纳入生成；`FillFunctionSignature()` 只填 name、return、parameters。随后：

- `func->nameSpace = module->defaultNamespace`（`1624`）；
- 没有设置 `func->objectType`；
- `Commit()` 无条件把全部 functions 加到 `module->globalFunctions` 和 `globalFunctionList`（`1526-1529`）。

因此，签名/函数体刚好落在当前 primitive emitter 子集内的 member 可能成功生成，却以错误的 runtime owner 和 lookup surface 发布。这比“对 script value object 返回 not supported”更严重，因为它是 silent semantic corruption，而不是 fail-closed。

#### 建议门禁

在 `Ready()` 保持 true 之前，至少需要：

1. 在任何 Engine/module mutation 前做整模块 declaration preflight；
2. 对每种 declaration 明确为“完整支持”或“整个 Build fail-closed”，禁止忽略；
3. global-only/type-only module 必须安装正确或失败；
4. method/ctor/dtor 必须安装到正确 `objectType`/behaviour table，未实现时必须失败；
5. namespace/import/funcdef/global initializer/generated lifecycle/default/accessor/list factory 都要有 production tests；
6. 测试必须断言 module registry、function owner、global initial value、lookup 和 execution，而不只断言 Build 返回值/publisher。

### F2 — Critical / Contract mismatch：module Build 已 canonical，但 `CompileFunction` 仍 legacy；Cutover tests 正在固化混合 authority

`as_module.cpp:1930-1981` 的 public `CompileFunction()` 仍建立 `asCBuilder` 并调用 `funcBuilder.CompileFunction(...)`，没有 CANONICAL 分支。当前 Cutover test 还明确写出：

> `CANONICAL module Build must record CodeGen; CompileFunction stays Compiler`

这与当前 OpenSpec 的以下未完成任务冲突：

- `10.1`：每个 source build purpose，包括 single-function compile，都选择 canonical Parser/Sema/Bytecode；
- `10.3`：module `Build()` 与 public `CompileFunction` 都接入 Parser+Sema canonical actions；
- `10.4`：canonical-selected Engine 的 production Bytecode 由同一 sealed AST 的 `asCBytecodeCodeGen` 发布；
- `13.1`：canonical-selected Engine 若调用 `asCCompiler`，cutover test 必须失败。

如果产品设计确实决定长期允许 `CompileFunction` 走 LEGACY，那么应先修订 proposal/design/spec/tasks，定义 capability name 和 provenance；不能通过缩窄本地测试含义来暗中推翻 change contract。

此外，Cutover matrix 中的 `HotReload`、`generation`、`commandlet`、`Standalone` 多数只是同一测试进程里的 helper 变体。它们可以作为 unit/integration foundation，但不能替代真实 host entry point、ownership、cache/provider 和 lifecycle 测试。

### F3 — Critical：CodeGen artifact 仍不是 detached artifact，Generate 期间已修改 live Engine/module

`asSBytecodeCodeGenArtifact` 虽然有 `functions/globals/funcdefs/types` 四个数组，但当前实现并未形成“离线构建、完整验证、一次原子提交”的 transaction：

- globals 通过 `module->AllocateGlobalProperty()` 直接进入 live module/Engine（`1599-1606`）；
- function ID 通过 `GetNextScriptFunctionId()` 提前保留（`1623`）；
- function 在 emission 完成前就通过 `engine->AddScriptFunction()` 进入 Engine registry（`1635`）；
- `artifact.globals/funcdefs/types` 没有承载实际 pending install state；
- `Abandon()` 是对已经发生的 live mutation 做回滚，不是销毁 detached storage；
- `Commit()` 逐个 push module arrays，没有完整 prepare/validate 阶段，也没有中途失败的反向原子恢复协议。

Build failure 外层的 `InternalReset()` 能清理一部分 module state，但不能证明 `Generate()` 自身满足 9.1/13.6 的“failure leaves no partial function/module/Engine state”。而且未来 Cache restore、CompileFunction、test helper 或其他 caller 不能被迫依赖 module 全量 reset 才获得 transaction safety。

本轮应保留的真实进展是：额外 internal ref 已删除，现有有限 transaction tests 为绿。它关闭的是一个 refcount bug，不是 detached/atomic architecture。

### F4 — Critical：默认 LEGACY pipeline 的 lambda node-layout regression 仍未修复

默认 pipeline 仍是 LEGACY（`as_scriptengine.cpp:787`），因此这不是未来 canonical-only 的边角问题。

`as_parser.cpp:1722-1807` 的 `ParseLambda()` 当前产生：

```text
snFunction
├── snIdentifier("function")
├── snParameterList
│   └── parameter type/mod/name ...
└── snStatementBlock
```

但 `as_compiler.cpp:11521-11570` 的 `ImplicitConvLambdaToFunc()` 仍从 `ctx->exprNode->firstChild` 开始，只扫描 `snFunction` 的直接 children，直到 `snStatementBlock`：

- 它会把 `snIdentifier("function")` 计成一个参数；
- 不进入 `snParameterList`，因此不读取真实 parameter type/name；
- 零参数 lambda 被算成一个参数；
- 单参数可能数量偶合但跳过类型检查；
- 多参数通常数量错误；
- `RegisterLambda()` 仍接收同一新 shape，后续注册也可能把标签当参数。

现有 `Compiler 331/331` 没有构成该风险的反证：需要默认 LEGACY Engine 的 lambda-to-funcdef compile + execute fixture，覆盖 0/1/N 参数、显式类型/ref modifiers、global/function/member owners 和 teardown。

### F5 — Blocking：Verifier 仍不是 capability spec 要求的 publication firewall

`as_ast_verifier.cpp` 增加了有价值的 ID、kind、range、statement cycle 和有限 ownership 检查，但 `2.8` / `13.5` 仍勾选过早：

- statement 同一 child 在同一 parent 的 `children` 中重复出现不会被拒绝；
- 没有证明所有 stmt/expr 都从 declaration body 可达，也没有拒绝 orphan subgraph；
- break/continue 只有在 `target.IsValid()` 时才校验，required target 缺失会通过；
- target 只要求是某个合法 ancestor，不拒绝 skipped-nearer target；
- fallthrough 只要求任意 switch ancestor，不校验所属 case、next-case、最后 case 或错误 case target；
- expression 没有 cycle/multi-owner/complete reachability 检查；
- CALL/CONSTRUCT 的 required `resolvedDecl` 缺失会通过；
- CLEANUP 仅在 `resolvedDecl` 已设置时检查 destructor kind，缺失 destructor target 会通过；
- resolved signature、stable refs、dependencies、sequencing、cleanup/exception plan 没有完整验证；
- `asCASTVerifyPublication()` 只是检查 sealed 后再次调用同一个不完整 verifier。

保存的 Verifier tests 只能证明已写规则，不证明 spec 中列出的完整 firewall。`2.8` 与 `13.5` 必须重新打开，直到 adversarial matrix 覆盖 missing/foreign/duplicate/cycle/skipped-nearer/wrong-kind/orphan/required-reference cases。

### F6 — Blocking：Cache V2 sidecar 仍丢弃输入 payload，decode 不能重建 function body

UE wrapper `AngelscriptCacheASTBodySidecar.cpp:39-72` 只检查 `CanonicalAstBytes.Num() != 0`，随后完全不读取这些 bytes，而是新建一个只有 TranslationUnit 的空 `asCASTContext` 再 encode。调用者提供的 canonical AST payload 因而没有被持久化。

fork sidecar 本身也仍不满足 ExactStartup：

- encode 写 textual dump + 浅 declaration table（kind/parent/quals/traits/name/typeKey）；
- decode 读出 dump 后不使用它；
- decode 只重建 declaration skeleton，没有 source bytes/ranges、stmt、expr、body、resolved refs、cleanup/dependencies；
- named type 一律按 `VALUE_OBJECT` 尝试恢复，失败退成 `int`；
- `asCASTCollectFunctionRecords()` 明确忽略 profile，只 hash function key/type/quals/traits/origin/defaultArg/dependencies，不含 body/expr/literal/source content；pure body edit 可能得到相同 content hash 并错误复用旧记录。

因此当前 sidecar round-trip test 即使绿，也不能证明：

- `CanonicalAstBytes` fidelity；
- complete module reconstruction；
- capture-on ExactStartup 无 Parser/Sema restore；
- changed-body invalidation；
- source/profile/environment identity；
- module-atomic publication。

任务 13.9 继续是 Blocking；`6.7` 的 checked 状态也应按任务原文重新审计。

### F7 — Blocking：snapshot Acquire/publish 不是并发安全、失败保持 last-good 的原子协议

`as_module.cpp:2034-2045` 的 `AcquireASTSnapshot()` 是：

1. 读 raw `astSnapshot`；
2. 检查非空；
3. 再调用 `AddRef()`。

并发 publish/release 可发生在 1 与 3 之间，形成 use-after-free window。

`PublishCanonicalASTSnapshot()` 则先：

1. 把 previous 标成非 current；
2. 清空 `astSnapshot`；
3. release previous；
4. 再取 candidate、seal、分配新 snapshot。

candidate seal/alloc 失败时，last-good 已经丢失；context 缺失时还会制造一个空 TranslationUnit snapshot，而不是拒绝 publication。`IsCurrentGeneration` 也没有展示与 acquire/exchange 同一原子协议。

新 CANONICAL Build 还在 `PublishCanonicalASTSnapshot()` 之后才调用 `ResetGlobalVars()`（`as_module.cpp:424-427`）。如果 global initialization 失败，Build 返回失败，但新 snapshot 已经成为 current，违反“完整 build/activation 成功后再发布”的 transaction 语义。

`CompileFunction()` 追加 runtime function却不更新 retained complete module snapshot；StaticJIT generation 也必须持有真正 snapshot lease，而不是裸 context pointer。

因此 3.5/3.6/13.8 不能关闭；需要 candidate-first verify、atomic retained exchange、atomic current bit、failed publication preserves A、Acquire-vs-publish race test、generation lease 和明确的 CompileFunction completeness policy。

### F8 — Blocking：Public AST V1 仍有 mid-vtable ABI 和 size negotiation 问题

`Core/angelscript.h:1058-1060` 把 AST methods 插在 `CompileFunction()` 与 `SetAccessMask()` 之间，改变了其后全部 virtual slot。对于 embedding ABI，这不是 append-only extension。

虽然 public view structs 有 `structSize` / `apiVersion` 字段，`as_ast_public_view.cpp:64-142` 的 getters 并不读取 caller capacity/version，而是直接覆盖完整当前 struct 并把字段改成当前大小/版本。这会破坏旧 caller 的 smaller buffer/canary。

同时 Decl/Stmt/Expr/Type ID 仍只是同类 context 内的数值 index；没有 snapshot identity/cookie，另一个 snapshot 的同 index ID 可能被误接受。公开 view 也没有暴露完整 resolved call/owner/control/cleanup/source/dependency facts。

任务 13.7 继续 Blocking。正确方向是 append-only extension interface 或单独 query interface，并按 caller `structSize` 写最小公共前缀、拒绝不兼容 version、拒绝 foreign-snapshot IDs。

### F9 — High：tokenizer 和 qualified namespace 仍有 scope/correctness 偏差

#### 重新启用关键字改变语言行为

`as_tokendef.h:285` / `300` 重新把 `interface` / `typedef` 注册为关键字。若当前 fork 之前允许它们作为 identifier，这会改变 accepted syntax 和 identifier set，与本 change 的 language-behavior non-goal 冲突。

实现方需要二选一：

- 回退该 tokenizer 改动，在 Parser/Sema 通过现有 token contract 处理；或
- 明确修订 OpenSpec scope、语言版本/兼容策略并补旧脚本 migration tests。

#### `namespace A::B` canonical owner 丢失 `B`

`as_parser.cpp:2776-2794` 在读完第一个 identifier `A` 后就调用 `NotifySema(node)` 并 push last acted；后续才解析 `::B`。`as_sema_decl.cpp:943-953` 的 `snNamespace` fallback 也只取 `FirstChildOfType(snIdentifier)`。

因此 `namespace A::B { int F(); }` 的 canonical graph 可能变成 `A::F`，而不是 `A::B::F`。两层独立 `namespace A { namespace B { ... } }` 测试不能覆盖这个语法形态。需要 direct qualified namespace ownership/stable-key test。

### F10 — High：Sema 仍在翻译 `asCScriptNode`，SourceManager 也没有成为内容真相

当前有更多 `ActOnParsed*FromNode` action，这是迁移进展；但 `as_sema_decl.cpp` 仍通过 `WalkOne()`、`FirstChildOfType()` 和 `firstChild/next` post-walk parser tree。它不是拥有 scope/symbol/overload/conversion/lifetime/control environment 的 sole semantic authority。

一个直接例子是 `ActOnLambdaFromNode()`：它最终把 lambda 作为 `DeclRef` expression，并硬编码成 `int` type（`as_sema_decl.cpp:912-927`）。这不能承载 closure/funcdef/callable exact type 和 capture semantics。

`as_source_manager.cpp:192-204` 的 `RemapLogical()` 只按 logical key + origin 命中 existing file，完全不比较新 bytes、byteCount 或 lineOffset。相同 logical path 的内容变化可能错误复用旧 source record，破坏 diagnostics/cache/source identity。

任务 13.2 和 13.10 继续 open；当前 128/128 是 action coverage，不是 semantic authority closure。

### F11 — High：runtime↔AST identity 有进展，但 lambda/owner/type namespace 仍可能错配

`BuildRuntimeAstIdentityKey()` 现在包含 object/nameSpace/name/parameters，这是第四轮之后的真实进步；但：

- object owner 只用 `objectType->GetName()`，没有 owner namespace/完整 stable owner identity；
- non-primitive parameter type只用 `GetTypeInfo()->GetName()`，没有完整 namespace/template/qualifier identity；
- lambda binding 只比较 parameter substring，把所有同参数 lambda 按 AST source offset 排序、runtime `$...$N` 排序，然后跨 module 按 rank 配对；没有 enclosing function/object/namespace owner identity。

两个不同函数/类中同签名 lambda 的数量和顺序发生变化时仍可能错绑。`13.3` 必须保持 open，并增加同名 owner namespace、同名 value types、qualifier/ref/inout、overloads、多个 enclosing owners 内同签名 lambda 的 ambiguity rejection tests。

## OpenSpec task 复核

### 可以保留 closed 的部分

- `13.4` arena/seal 的基础边界当前可继续保留；
- R11 teardown fix 可继续作为已关闭 regression；
- extra `AddRefInternal()` 修复及其有限 transaction tests 可保留为 R09 的子进展；
- non-lambda exact matching 和 Parser/Sema action coverage可记录为子进展；
- CANONICAL module Build 的最小 scalar route 已成立，但它属于 13.6/10.4 的局部实现，不能关闭整项。

### 至少应重新打开

- `2.8`：Verifier 没有覆盖 task/spec 全部 invariants；
- `13.5`：publication firewall 不完整；
- `3.5`：现有实现不能保证 failed replacement preservation / acquire race；
- `3.6`：snapshot publication/lease integration 不是原子协议；
- `12.6`：仍存在 false-complete tasks，且设计/测试已被实际实现缩窄但未完成 reconcile。

### 应按任务原文重新审计

- `6.7`：测试没有证明 complete Cache DTO、body hash、source authority 和 exact restore；
- `7.6`：generation 需要真正 immutable snapshot lease/freshness gate；
- `8.4`：真实 generation orchestration/queue freeze/owned-output-only gate 不能由同进程 helper 代替。

### 必须保持 open

- `9.1`、`9.5`；
- `10.1`、`10.3`、`10.4` 以及其余 section 10 cutover/removal tasks；
- `13.1`、`13.2`、`13.3`、`13.6`–`13.12`。

## 建议修复顺序

```text
1. 立即给新 CANONICAL Build 加整模块 preflight/fail-closed
   ├─ global-only/type-only/import/funcdef/namespace
   ├─ member/ctor/dtor owner
   └─ global initializer/generated bodies
        ↓
2. 修复默认 LEGACY lambda node-layout regression
        ↓
3. 明确 CompileFunction/Ready/cutover contract
   ├─ 按 spec 接 canonical
   └─ 或先显式修订 OpenSpec，禁止测试暗改契约
        ↓
4. Detached CodeGen artifact + atomic module/Engine install
        ↓
5. Verifier adversarial firewall
        ↓
6. Snapshot candidate-first atomic lease protocol + public ABI
        ↓
7. Cache V2 complete pointer-free DTO + body/profile/source hash
        ↓
8. Sema sole authority + SourceManager content truth + stable identity
        ↓
9. 真实 HotReload / generation / commandlet / Standalone entry tests
        ↓
10. fresh focused prefixes → Standalone Debug/Release → All
```

第一步应优先于继续扩大 emitter opcode 子集。只要 route 还能“成功但漏装/错装声明”，增加更多 expression/statement emission 只会扩大 silent corruption surface。

## 最终判定

第五轮最重要的判断不是“没有进展”，而是：

> **实现已经跨过了 production call-path 的第一道门，但还没有跨过 production compiler 的完整性门。**

最小 scalar module 经 CANONICAL Build → sealed AST → `asCBytecodeCodeGen` → executable Bytecode 的链路已经成立；旧的“Build 仍总由 `asCCompiler` 发布”结论应更新。

与此同时，当前路由对声明覆盖、owner/layout/global initialization、失败原子性和 host purpose 的定义都不完整。尤其是 `functionDecls == 0` 直接成功以及 member 被统一提交为 global 的路径，使 `Ready=true` 过早且不安全。

因此本轮仍给出：

> **Request changes — do not archive, do not switch the default, do not treat 56/105 or the narrow green reports as production cutover.**

下一轮复审应首先要求实现方提供 fail-closed declaration matrix、正确 owner/registry assertions、global initializer execution、legacy lambda regression、Generate failure no-mutation，以及真实 snapshot/cache/host entry evidence；否则不应继续讨论默认切换。
