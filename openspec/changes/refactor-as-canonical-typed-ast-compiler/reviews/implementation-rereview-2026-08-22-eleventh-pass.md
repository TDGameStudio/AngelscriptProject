# Canonical Typed AST Compiler 第十一轮实现复审 — 2026-08-22

## 结论

本轮仍为 **Request changes**，但相对第十轮有一段明确、可验证的实质进展：native method、member method、constructor、factory、`opIndex` 的 same-arity poison 执行矩阵曾在保存二进制上达到 `38/38`，SemaAuthority 同期为 `239/239`。这说明 Canonical AST 的 `resolvedDecl` 已经开始真正控制一部分 Runtime callable 选择，过去“只按名字和参数数量取第一个”的具体错误面被明显缩小。

随后实现方开始把 member default initializer 从 `atoi(defaultArg)` workaround 迁移成 AST-owned typed init graph：`asCDecl::inits`、`AddDeclInit()`、constructor 前置 init emission 和 dump oracle 都已落地，SemaAuthority 扩到 `240/240`。这个方向正确，也是本轮最重要的架构进步。

但当前不能把 exact callable 或 typed initializer 标成完成：

- primary cutoff时 ProductionCodeGen 是 `36/39`；post-cutoff当前源码复跑已恢复到`38/39`，还剩一个active failure；
- `40 + 1` member init 虽然出现在 constructor Bytecode 中，执行仍得到 `0` 而不是 `42`；
- generated accessor的新CALL断言曾证明此前字段内联是false green；post-cutoff修正后这两个fixture已经转绿，但源码仍保留callee缺失时的字段内联fallback；
- native global 仍按 `name + arity` 绑定，generated accessor、zero-arg ctor/factory 等仍存在 backend fallback；
- `decl->inits` 尚未进入 Verifier、Cache sidecar 或 public view contract；
- module atomic install、public snapshot、Cache、SourceManager、all-entry cutover 均未变化。

因此，当前阶段从第十轮的 B 中期推进到 **B 中后段**，接近“有意义的 semantic core”，但尚未进入 production cutover 阶段。结合post-cutoff accessor转绿，建议 production cutover readiness 从上一轮中心值约 `44%` 小幅上调到约 `47%`，合理区间 `46%–49%`；不能按 focused `38/39` 或 Sema `240/240` 上调到 50% 以上。

## 时间点和审查边界

- point-in-time source cutoff：`2026-08-22 20:22:03 +08:00`；post-cutoff build/test addendum检查到`20:26:54`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- parent/plugin dirty path count：`20 / 108`；
- cutoff 时没有 `UnrealEditor` / `UnrealBuildTool` 进程；
- reviewer 没有主动启动 build/test，没有修改 plugin 实现或 `tasks.md` checkbox；
- 本报告只读取当前源码、OpenSpec 和实现方保存在 `Saved/Build` / `Saved/Tests` 下的结果；
- primary cutoff时最新成功 build 完成于 `20:08:49`，而 `as_bytecode_codegen.cpp` 在 `20:10:23` 修改；随后实现方的post-cutoff `wave-b-initplan-exec-g2` 于`20:26:07`完成7-action build、`ProcessExitCode=0`，并于`20:26:54`完成ProductionCodeGen `38/39`复跑。因此当前源码已有exact-current focused compile/test证据，唯一剩余失败为typed user-ctor initializer。

关键源码 SHA256 前 12 位：

| 文件 | SHA256 prefix | 相对第十轮 |
| --- | --- | --- |
| `as_sema.h` | `4604FE24C0A0` | 已变；candidate/lookup支持扩展 |
| `as_sema.cpp` | `95E3C1822876` | 已变 |
| `as_sema_decl.cpp` | `9AD5E872B25E` | 已变；member init attachment |
| `as_sema_expr.cpp` | `84AE1D825CC3` | 已变；call/constructor resolution继续扩展 |
| `as_ast_context.cpp` | `1E022FF316D8` | 已变；`AddDeclInit()` |
| `as_decl.h` | `88D65237C1B9` | 已变；`inits` edge |
| `as_ast_dump.cpp` | `713FAC2B3372` | 已变；dump `init=` |
| `as_bytecode_codegen.cpp` | `A86E0B690CB1` | 已变；exact method/ctor binding、init emission、accessor/width工作中 |
| `as_ast_verifier.cpp` | `173CA1EF3A30` | 未变；不知道 `decl->inits` |
| `as_module.cpp` | `FF912191C238` | 未变；atomic install/last-good仍缺 |
| `as_ast_public_view.cpp` | `1A0C04E85712` | 未变 |
| `as_source_manager.cpp` | `EB60196F8967` | 未变 |
| `as_ast_sidecar.cpp` | `D2266F259F6E` | 未变；不编码 `decl->inits` |

## 最新保存证据时间线

| 时间 / label | 结果 | 能证明什么 |
| --- | --- | --- |
| `18:54 wave-b-ninth-f2-prod-g` | ProductionCodeGen `35/35` | method/member exact-signature slice转绿 |
| `18:54 wave-b-ninth-f2-sema` | SemaAuthority `239/239` | 同期Sema graph无focused回归 |
| `19:29 / 19:33 / 19:38 wave-b-ninth-f2-ctor-g14/g16/g17` | ProductionCodeGen `38/38` | constructor/factory/opIndex same-arity poison矩阵最终转绿并重复通过 |
| `19:39 wave-b-ninth-f2-sema-g17` | SemaAuthority `239/239` | exact binding改动后的focused Sema证据 |
| `19:48 wave-b-initplan-sema-g` | SemaAuthority `240/240` | user ctor dump出现typed `init=` graph |
| `19:49 wave-b-initplan-prod-g` | ProductionCodeGen `38/39` | typed init execute仍RED |
| `19:51 wave-b-initplan-sem` | Semantics `12/12` | 已有isolated evaluation/lifetime子集未回归 |
| `20:01 / 20:02 initplan-exec-g/dump` | ProductionCodeGen `38/39` | typed init执行失败稳定复现，非一次性抖动 |
| `20:09 wave-b-initplan-get-inline` | ProductionCodeGen `36/39` | 更强accessor oracle揭露两个false green；typed init继续失败 |
| `20:26 wave-b-initplan-exec-g2` | 7-action build成功；ProductionCodeGen `38/39` | post-cutoff当前源码可编译；两个accessor RED关闭，typed init仍RED |

primary cutoff时的三个失败：

```text
CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes
  F() must CALL GetValue; inline ADDSi/RDR4 on F() is a false green

CanonicalGeneratedInt64AccessorUsesRdr8NotRdr4
  int64 F() must CALL GetValue

CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody
  typed 40+1 then user Value=Value+1 expected 42, got=0
```

post-cutoff `wave-b-initplan-exec-g2` 已将前两个generated-accessor失败转绿，当前唯一失败是：

```text
CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody
```

primary cutoff时最后一次 build `wave-b-initplan-get-inline` 的 `ProcessExitCode=0`，但当前 CodeGen 文件晚于该 build 约 1 分 35 秒。文档核验期间出现的post-cutoff `wave-b-initplan-exec-g2` 已重新编译 Runtime/Test 共7个actions并成功，随后ProductionCodeGen为`38/39`。这证明20:10当前源码已经关闭两个accessor active RED；它也明确证明typed initializer仍未修复。

## 相对第十轮的真实进展

### P1 — same-arity method/constructor/factory/opIndex 的具体错误面明显收缩

新测试覆盖：

- native same-arity method；
- native same-arity member method；
- same-arity constructor；
- same-arity factory；
- same-arity `opIndex`。

当前 CodeGen 在 emit 前为 external method/constructor 构造 bind：

- `FindExactRegisteredMethod()` 比较 return type、parameter type、reference/handle、in/out qualifier，并处理 template instance；
- `FindExactRegisteredConstructor()` 比较 user-visible parameter type/qualifier并在 constructor/factory表中要求唯一匹配；
- `EmitCall()` 已删除第十轮看到的通用 `FindMethodUntil(name)+arity` fallback；
- `EmitIndex()` 现在要求通过 `FindFunc(expr->resolvedDecl)` 取得 `opIndex`，找不到即 fail-closed。

这不是单纯加测试：`38/38` execute evidence 证明错误的同参数数量候选不会再被当前这些fixture选中。它值得计入生产进展。

### P2 — member initializer 开始成为 AST-owned typed graph

新结构和流程包括：

```text
member Decl.inits
  -> AttachConstructorMemberInits()
  -> DeclRef(member) + typed RHS + Assign
  -> constructor Decl.inits
  -> CodeGen在constructor body前EmitExpr(init)
```

`asCDecl` 新增 `inits`，Context 提供 seal 前 `AddDeclInit()`，Dump 输出稳定 `init=<ExprId>`。`AttachConstructorMemberInits()` 会把每个 member 的 typed initializer assignment 附加到用户或generated constructor；CodeGen 在 constructor body 前顺序执行这些表达式。

SemaAuthority `240/240` 证明 `int Value = 40 + 1` 不再只以 `defaultArg="40 + 1"` 存在，而是已经有可遍历的 typed binary/assign graph。这是从 backend string workaround 向 Sema-owned plan 的正确迁移方向。

### P3 — accessor测试开始拒绝“行为碰巧正确、调用契约错误”的false green

此前 `Object.Value` 可以由 caller CodeGen 直接生成字段地址和 `RDR4/RDR8`，即使 generated `GetValue()` 从未被调用，最终值仍可能正确。新断言不仅检查返回值，还检查：

- caller Bytecode 必须 CALL exact `GetValue`；
- setter调用必须到 `SetValue`；
- int64 getter必须通过真实callee返回，而不是caller自己内联字段读取。

这两项新增RED不是退步，而是测试质量上升：它揭露了 generated-call binding缺口，避免把字段内联误判为exact callable完成。post-cutoff复跑中两项已经转绿，说明当前fixture已真正走generated accessor CALL；但fallback源码仍在，缺callee时仍不会fail-closed。

## Findings

### F1 — High：exact callable 已完成重要子集，但仍不是 Sema-owned Runtime callable identity

当前 `FindExactRegisteredMethod()` / `FindExactRegisteredConstructor()` 仍由 CodeGen 在 mutable Engine registry 中重新枚举并比较签名；AST call node只持 `resolvedDecl`，没有独立、稳定、可验证的 Runtime callable binding record。

仍然存在的fallback：

- `FindRegisteredGlobalFunction()` 仍只比较 `funcType + name + parameter count`，同名同arity global仍可能选错；
- `FindConstructorId()` / `FindFactoryId()` 仍有按argument count选择的fallback，尤其zero-arg construction；
- list factory仍直接读取`objType->beh.listFactory`；
- generated accessor binding失败时，`EmitCall()`不fail-closed，而是直接内联字段读取；
- identical-signature、namespace/module/profile/owner冲突仍依赖Engine当前registry形状。

因此可以说“same-arity method/ctor/factory/opIndex fixture已关闭”，不能说9.4或完整exact callable contract已完成。最终应由Sema/installation阶段产生唯一binding record，CodeGen只消费该record，不再做overload或registry搜索。

### F2 — High：typed initializer 图已经生成，但production执行仍错误

`CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody` 连续多次得到 `0`。失败dump表明被检查的constructor确实包含：

```text
SetV4 -> ADDSi -> WRTV4
... body read -> ADDi -> WRTV4
```

Entry也包含constructor `CALL`，但最终对象字段仍为0。这把问题从“没有init plan”推进到了“init plan/constructor call/this ABI/installed behaviour identity之间不一致”。当前至少需要同时核对：

- Entry的CALL operand是否就是dump出来的user constructor ID；
- value-object constructor的hidden `this` push/pop约定是否与callee `thisOffset`一致；
- `objType->beh.construct`和`beh.constructors[]`是否出现placeholder、generated/user重复或被错误覆盖；
- constructor return/pop和对象slot生命周期是否在CALL后清空/覆盖对象；
- init assignment的member address是否属于Entry里的实际对象slot。

在该execute RED转绿之前，不能删除旧 `EmitConstructorMemberDefaults()` 思路后就宣称typed initializer迁移完成；也不能用dump `init=`或SemaAuthority `240/240`代替运行语义。

### F3 — High：新 `decl->inits` 边没有进入publication firewall、Cache或public contract

`as_ast_verifier.cpp` 哈希未变，源码没有遍历 `decl->inits`。因此它不会拒绝：

- dangling/foreign init ExprId；
- init expression cycle或非法共享；
- initializer lhs不属于目标class；
- initializer type与member type不兼容；
- constructor init引用错误generation/owner；
- init中缺失required callee/cleanup target。

`as_ast_sidecar.cpp`和`as_ast_public_view.cpp`同样没有 `inits` 路由。当前init graph只能在内存内部由CodeGen和Dump看到，Cache restore/public consumer无法重建或遍历。由于 initializer 是 executable graph 的一部分，这进一步证明13.5、13.9和public AST完整性仍未关闭。

### F4 — High：generated accessor仍由caller绕过，宽度支持仍是局部的

`EmitCall()` 在找不到 generated getter callee 时仍可直接执行：

```text
receiver -> ADDSi(property offset) -> RDR4/RDR8
```

这正是primary cutoff两个测试拒绝的路径。post-cutoff当前fixture已能绑定并CALL generated getter/setter；生成accessor自身的 `EmitGeneratedAccessor()` 也会按 `ValueDwords()` 调用 `EmitReadValue/EmitWriteValue`。剩余问题是fallback仍存在：任何binding遗漏仍可能静默降级为caller字段内联，而不是publication/codegen失败。

此外通用数据路径仍有固定4-byte操作：

- member assignment直接 `WRTV4`；
- `EmitMemberStore()`直接 `WRTV4`；
- `LoadGlobal()`直接 `CpyGtoV4`；
- `StoreGlobal()`直接 `WRTV4`。

double/handle getter fixture通过不能外推到member setter、global、reference counting、copy/destruct。9.2仍是false-complete。

### F5 — Critical：detached artifact / atomic module activation 没有变化

`as_module.cpp`未变化，`Build()`仍在candidate前`InternalReset()`旧module。CodeGen仍会在完整emit成功之前：

- `AllocateGlobalProperty()`并写live global memory；
- `engine->AddScriptFunction(func)`预占live function slot；
- `FillFunctionSignature()`修改constructor/destructor behaviour和method table；
- import registration修改module状态；
- object/type/function表在失败时只做部分回收。

当前 `Artifact::Abandon()` 不是完整transaction rollback，失败也不能保留旧module和last-good snapshot。exact callable和typed init越复杂，这个风险越高，因为更多失败点发生在live registry已被修改之后。13.6仍是production cutover的首要系统级Critical。

### F6 — Blocking：Verifier/public snapshot/Cache/SourceManager/all-entry cutover未推进

本轮未变化的系统blocker：

- Verifier仍不要求CALL/CONSTRUCT/DeclRef required target，也没有Expr owner/cycle/reachability协议；
- public methods仍在mid-vtable，view size/version negotiation和snapshot Acquire并发协议仍不安全；
- Cache sidecar仍是declaration skeleton/facade，不是完整body DTO；
- SourceManager remap仍不校验content identity；
- public `CompileFunction()`仍走legacy compiler；
- default仍LEGACY，HIR/TypedASTJIT/cache/snapshot consumer未统一；
- `IsCanonicalBytecodeCodeGenReady()`仍无条件true。

所以本轮不能切default CANONICAL、不能删除LEGACY/HIR、不能archive。

### F7 — Medium：OpenSpec记录没有吸收18:24后的新进展和RED边界

`tasks.md`最后修改时间仍为`18:24:16`，机械进度仍是：

```text
56 checked / 49 open / 105 total = 53.3%
```

它没有记录：

- exact binding `35/35 -> 38/38`；
- typed init Sema `240/240`；
- latest ProductionCodeGen `36/39`；
- generated accessor false-green RED；
- `decl->inits`未进入Verifier/Cache/public view。

尤其9.4、9.2、13.5仍为checked，与当前源码和最新主动RED冲突。本轮review不与实现agent争抢`tasks.md`，但下一次实现checkpoint应更新任务注释或重新打开false-complete项。

## 当前完成度

建议继续使用分层指标：

| 口径 | 当前估计 | 第十轮后变化 |
| --- | ---: | --- |
| OpenSpec机械checkbox | `53.3%` | 不变，且含false-complete |
| 可运行Canonical原型/验证价值 | `83%–86%` | exact-call poison、generated accessor CALL和typed-init graph使原型能力明显增强 |
| architecture/scaffold assets | `64%–67%` | `Decl.inits`和更强call matrix是有效资产 |
| production compiler cutover readiness | `46%–49%`，中心约`47%` | 从约44%小幅上调；系统级blocker仍全部存在 |
| default切换并删除LEGACY/HIR | `33%–38%` | 基本仍由后续consumer/cutover/retirement工作决定 |

阶段图：

```text
A Canonical AST/Source/Type scaffold          基本具备
B Sema facts + executable CodeGen slice       中后段  <- 当前
C Exact init/lifetime/ABI/full language       已开始，但active RED
D Detached artifact + atomic activation       未完成
E Public snapshot + Cache + Source truth      未完成
F All-entry production cutover                未完成
G HIR/LEGACY retirement                       未开始
```

## 下一条最短关键路径

1. 暂停增加新的语言breadth，先把当前`38/39`变成真实`39/39`；
2. 保持generated accessor exact CALL绿色，并删除caller字段内联fallback使缺binding fail-closed；
3. 对user value constructor新增CALL operand/behaviour identity断言，定位`init Bytecode存在但Entry返回0`的ABI或install错误；
4. 把global exact binding从name+arity升级为完整owner/namespace/signature/qualifier唯一匹配，随后停止CodeGen registry re-selection；
5. Verifier必须遍历并验证`decl->inits`，public view和Cache DTO也必须携带该edge；
6. 用typed initializer graph替代global/member `defaultArg` string路径，不再由CodeGen `strtoll`；
7. 修正1/2/4/8/pointer/value-object读写、copy、refcount和destruct，再扩大container/lambda/import语言面；
8. 立即进入detached artifact + atomic install failure-injection，而不是继续扩展backend特例；
9. 最后才处理snapshot/cache/source/all-entry/default/HIR retirement。

## 最终判断

本轮实现方向继续正确，而且进展比“测试数量增加”更实：same-arity poison矩阵已经迫使call binding从name+arity向exact signature前进，member initializer也第一次成为canonical AST中的typed executable edge。这两项都说明新AST确实可以承载未来优化和LLVM lowering需要的语义事实。

当前问题不再是“Canonical AST能不能做”，而是“这套语义事实能否在Runtime binding、Bytecode ABI、publication、Cache和all-entry中保持同一个identity和生命周期”。最新`38/39`正好卡在typed user-constructor ABI边界上。应把这一个RED和atomic install作为下一checkpoint，避免继续用backend fallback扩大表面覆盖。
