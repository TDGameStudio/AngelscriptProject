# Canonical Typed AST Compiler 第八轮实现复审 — 2026-08-22

## 复审结论

当前实现仍为 **Request changes**。不能归档，不能把 CANONICAL 切为默认，也不能把 Parser action 数量、`Ready()==true`、CanonicalAST 前缀全绿或 OpenSpec checklist `56/105` 解释为完整 compiler ready。

相对第七轮，本轮有三项真实进展：

- enumerator 已有独立 `ActOnStartEnumeratorDecl()` / `ActOnParsedEnumerator()` 路径；
- `snVariableAccess` 已由 `InternParsedDeclRef()` 提取 scope/name 后调用 `ActOnDeclRefExpr()`；
- `snFunctionCall` 已由 `InternParsedCall()` 提取 scope/name/args 后调用 `ActOnCallExpr()`；在本轮快照最后，`snExprTerm` 的独立 `InternParsedExprTerm()` 也正在落地。

实现者保存的验证报告证明 DeclRef/Call peel 落地时没有造成已覆盖前缀失败：

- DeclRef：SemaAuthority `205/205`，CanonicalAST `253/253`，Compiler `442 success + 1 succeeded-with-warning + 0 failed`；
- Call：SemaAuthority `206/206`，CanonicalAST `254/254`，Compiler `443 success + 1 succeeded-with-warning + 0 failed`。

附件中“Compiler `443/443` / `444/444 PASS`”的简写不够准确：JSON report 分别有一条 `succeededWithWarnings`，不是所有测试都处于纯 `Success` 状态；warning 来自既有 TypedSemanticIR SourceProvenance integration。更重要的是，`as_sema_expr.cpp`、`as_sema_decl.cpp` 和 SemaAuthority 测试在最新 Call Compiler 报告之后又修改，正在进行的 `InternParsedExprTerm()` 没有 exact-current 保存验证。因此这些数字是最近一次已保存基线，不是 13:32 快照源码的完整验收。

本轮新增代码也暴露出一个比“还剩多少 FromNode 分支”更关键的事实：**当前 incremental action 仍按 syntax-node replay + arena 扫描去重组织，并没有形成 Clang 式的唯一 Sema action identity。** 在成员调用、作用域调用、unresolved call、参数和 enumerator 上，它会产生错误节点、重复节点或吞掉真实重复声明。最严重的是 side-effectful member receiver 在当前 canonical graph/CodeGen 组合中可被多次求值。

当前最准确的定位仍是：

> **一个已真实接入 opt-in module Build、拥有大量 vertical slices 的 canonical compiler prototype；Parser/Sema action peel 正在快速推进，但 action identity、exact resolution、single-evaluation、类型/lifetime ABI、module transaction 和持久化边界仍不是 production contract。**

总体架构方向仍正确，不需要推倒 canonical typed AST；但当前应优先修正 action protocol 和 semantic plan，而不是继续把每个 `asCScriptNode` case 机械搬进另一个 `InternParsed*()` helper。

## 复审快照与操作边界

- worktree：`D:\as-cta`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time cutoff：**2026-08-22 13:32:53（Asia/Shanghai）**；
- parent / plugin dirty paths：`20` / `108`；实现是 dirty worktree 内容，不等同于两个 HEAD；
- 快照时没有本轮相关 UnrealEditor build/test 进程；
- reviewer 没有主动运行 build/test，没有修改 plugin 实现，也没有修改 `tasks.md` checkbox；
- 本报告只做静态源码核验，并只读解析实现者保存的 JSON reports；
- 实现方仍在工作，本报告只对上述 cutoff 的文件内容负责。

最近关键文件时间：

| 文件 | LastWriteTime | 与最近保存验证的关系 |
| --- | --- | --- |
| `as_parser.cpp` | 13:07:35 | 包含 enumerator/DeclRef/Call Parser action 触发点 |
| `as_sema.cpp` | 13:07:35 | 包含 Param/Enumerator action 和 DeclRef 默认行为 |
| `as_sema_expr.cpp` | 13:30:14 | 晚于 `wave-b-call-compiler`；含未重新验证的 `InternParsedExprTerm()` WIP |
| `as_sema_decl.cpp` | 13:30:14 | 晚于 `wave-b-call-compiler`；dispatcher 已转到 `InternParsedExprTerm()` |
| SemaAuthority test file | 13:28:31 | 晚于 `wave-b-call-compiler` |
| `as_bytecode_codegen.cpp` | 12:22:47 | 第七轮 Critical CodeGen blockers 本轮未修改 |
| `as_ast_verifier.cpp` | 2026-08-21 20:23:37 | Verifier blockers 本轮未修改 |

OpenSpec apply 机械状态仍为 checked `56`、open `49`、total `105`。该比例只说明 checkbox 状态。第七轮指出的 false-complete 没有因本轮 Parser/Sema peel 自动关闭；本轮还进一步证明 checked 的 9.4 不能按原任务文字视为完整 ordinary/member call lowering。

## 当前保存验证证据

以下均为实现者运行、reviewer 只读核验：

| Label | JSON 结果 | 说明 |
| --- | ---: | --- |
| `wave-b-enum-sema` | `203 success / 0 failed` | Enumerator action slice |
| `wave-b-enum-canonical` | `251 success / 0 failed` | Enumerator 后 CanonicalAST |
| `wave-b-declref-sema` | `205 success / 0 failed` | DeclRef peel |
| `wave-b-declref-canonical` | `253 success / 0 failed` | DeclRef 后 CanonicalAST |
| `wave-b-declref-compiler` | `442 success / 1 warning / 0 failed` | 合计 443，不能写成纯 `443/443 PASS` |
| `wave-b-call-sema` | `206 success / 0 failed` | Call peel |
| `wave-b-call-canonical` | `254 success / 0 failed` | Call 后 CanonicalAST |
| `wave-b-call-compiler` | `443 success / 1 warning / 0 failed` | 合计 444；warning 为既有 SourceProvenance integration |

这些报告均早于 13:28–13:30 的 ExprTerm WIP。当前源码缺少至少一轮新的 Build、SemaAuthority、CanonicalAST 和 broad Compiler exact-current 结果。本报告不把“没有看到运行中的进程”解释成新代码已验证。

## 相对第七轮的真实进展

1. **Parser recovery timing 更早。** 不完整 enum、variable access、call 在完整 function body WalkOne 前即可记录部分 canonical fact，这对诊断/recovery 和未来 Clang-shaped action 是正确方向。
2. **DeclRef scope extraction 已独立。** `InternParsedDeclRef()` 明确拆出 scope owner 与 identifier，nested scope fixture 已有保存结果。
3. **Call argument plan继续复用现有 Sema。** `InternParsedCall()` 会先解析 named/default arguments并调用 `ActOnCallExpr()`；不完整 `F(3` 能选择 `F(int)`，不再只是按第一个同名函数。
4. **记录保持诚实。** `tasks.md` 仍明确 4.2、5.9、13.2、13.3 未关闭，LEGACY 仍由 `asCCompiler` 执行；没有把 Call peel 宣称为完成 cutover。

但这些进展不能解释成以下能力已经完成：

- `ActOnParsedExpr()`、`InternParsedDeclRef()`、`InternParsedCall()`、`InternParsedExprTerm()` 仍以 `asCScriptNode*` 为输入并递归调用 `ActOnExprFromNode()` 提取 child meaning；这是更早的 syntax-tree semantic replay，不是 Parser token/action 直接向 Sema 传 semantic operands；
- expression identity 仍靠遍历整个 arena并匹配 `kind + source begin`，call 又使用另一套 `identifier offset + resolved callee` 规则；
- correct node“存在”不代表 arena 中没有错误/孤儿/重复 node，现有 dumps/tests大多只查 substring；
- member receiver、callee、argument order和single-evaluation尚未成为一个不可歧义的 canonical call plan；
- unresolved type/callee仍被合法 `int` placeholder掩盖，Verifier没有阻止 publication。

## Findings（按严重性排序）

### F1 — Critical：成员调用会先创建无 receiver 的错误 Call，side-effectful receiver 在 canonical CodeGen 中可被重复求值

这是本轮最重要的新 finding。

Parser 的成员调用路径是：

1. `ParseExprPostOp()` 在看到 `.` 后调用 `ParseFunctionCall()`（`as_parser.cpp:2340-2367`）；
2. `ParseFunctionCall()` 在只知道 `Get(args)`、还不知道外层 receiver 的阶段，无条件调用 `sema->ActOnParsedExpr(node, script)`（`1842-1863`）；
3. `ActOnParsedExpr(snFunctionCall)` 调用 `InternParsedCall(..., implicitReceiver = invalid)`（`as_sema_decl.cpp:1737-1741`）；
4. 如果没有同名 free global，`ActOnCallExpr()` 仍创建一个 `int`-typed、无 resolved callee 的 CALL（`as_sema_expr.cpp:493-556`）；
5. 外层 `snExprTerm` 完成后，才以 `value` 作为 `implicitReceiver` 再次调用 `InternParsedCall()`（`as_sema_expr.cpp:1399-1504`），产生正确的 `T::Get(...)` CALL。

因此 `v.Get(3)` 至少会在 arena 中留下一个 receiver-less 错误 CALL 和一个正确 member CALL。`as_ast_verifier.cpp:379-428` 只在 `resolvedDecl` 有效时检查 dangling id，不要求 CALL 必须有 callee，也不检查 expression reachability/ownership；错误 CALL 可以随 snapshot/dump/cache consumer一起发布。

当前 CodeGen已经在 sequence lowering中加入特殊分支，跳过“Parser FromNode can intern a receiver-less CALL beside the member CALL”（`as_bytecode_codegen.cpp:914-935`）。这不是 semantic contract，而是 backend识别frontend污染后绕过它；未来 LLVM backend不应复制这种猜测。

single-evaluation 更严重：

- `InternParsedExprTerm()` 把 primary receiver和之后的 member CALL都加入 `SEQUENCE`；
- `ActOnCallExpr()` 又把 receiver加入 CALL children，并同时通过 `literalBits`记录同一个 receiver；
- `EmitExpr(SEQUENCE)` 先执行 receiver part，再执行 CALL（`914-935`）；
- `EmitCall()` 先遍历所有 CALL children执行一次 receiver（`1905-1914`），随后当 `literalBits`存在时又执行receiver一次（`1918-1923`）。

对 `Make().Get()` 一类 side-effectful receiver，当前组合路径可把 `Make()`求值多次，而不是一次。现有 `ParserActOnMemberOverloadCallBeforeArgListCloseFails` 只断言 dump 中存在 `callee=T::Get(int)` 且不存在 `T::Get(float)`；它没有断言无 receiver-less CALL、没有检查 graph reachability，也没有执行 side-effectful receiver。现有 single-evaluation VM fixture覆盖 `MakeBox().Stored += 3` property mutation，不覆盖 `MakeBox().Method()`。

建议：

- `ParseFunctionCall()` 不应在自己是 `snExprPostOp('.')` child 时发布自由调用 semantic action；由带 receiver 的 postfix action一次性创建 call plan；
- receiver应是 call plan中的独立字段/角色，只求值一次；不要同时作为普通 argument child、`literalBits` side-channel和 sequence前置 child重复表达；
- 删除 CodeGen 对 receiver-less orphan CALL 的猜测性 skip；Frontend必须产出干净 graph；
- 增加 `Make().Method()` execution trace、arena总 CALL计数、reachable ownership、无 callee拒绝和 member/free同名冲突 tests；
- 9.4 必须重审：当前不能声称 ordinary/member call lowering已按原任务文字完成。

### F2 — Critical：Call replay去重协议对 scoped和unresolved call必然失效，可产生重复 canonical nodes

`InternParsedCall()` 计算 node range后，却用 identifier token offset作为查重 key（`as_sema_expr.cpp:1331-1364`）：

```text
existing.range.begin.offset == identifier.tokenPos
```

对 `Game::F()`，`asCScriptNode::AddChildLast()` 会把 parent range更新为所有 children的最早位置；`ParseOptionalScope()` 先把 `Game::` 加入 FunctionCall node。因此 CALL 的 `range.begin` 是 `Game`，而 `callOffset` 是 `F`。Parser action和后续 WalkOne/ExprTerm replay永远无法匹配，最终会生成多个 resolved CALL。当前成功去重测试只覆盖 unscoped `F(1,2)`。

对 unresolved `F()`，查重又显式要求 `existing->resolvedDecl.IsValid()`。第一次创建的 unresolved CALL因此永远不会被复用；任何 replay都会再创建一个 invalid CALL。

一般 expression去重也不安全：`FindExistingExpr()` 只匹配 kind、file和 begin offset，忽略 end、owner、semantic role/callee/operands，并直接拒绝 offset 0（`as_sema_expr.cpp:35-52`）。这既可能漏复用，也可能把同一 source begin上的不同 wrapper/恢复节点错误合并。

建议不要继续增加 arena线性扫描特例。Parser action应持有明确的 action/syntax identity，由 Sema维护 `pending/completed` semantic node映射；replay必须比较完整 source identity、owner和semantic role。至少增加successful scoped call唯一性、unresolved拒绝、offset 0、同begin不同role和跨generation reparse tests。

### F3 — Critical：`T()` 解析成 class/constructor call时一律得到 VALUE_OBJECT type，与已修正的 class ref语义冲突

`ConstructFromCallee()` 在 callee是class或constructor时无条件执行：

```cpp
context.InternNamedType(asAST_TYPE_VALUE_OBJECT, classDecl->name.AddressOf(), 0)
```

见 `as_sema_expr.cpp:471-488`。它没有读取 `asAST_TRAIT_VALUE`，也没有区分 AngelScript `struct` value type与`class` ref/implicit-handle type。

第七轮已经修正 runtime type registration：struct注册为value，class注册为ref+implicit handle。但Sema中的 `T()` call rewrite仍把两者都标成value object。结果是同一个script class在Decl/runtime descriptor一侧是reference object，在construction expression一侧却是value object；temporary/materialization、return ABI、assignment、cleanup和未来LLVM type lowering会读到互相冲突的事实。

应通过canonical class descriptor/decl trait构造exact QualType；class factory/handle creation和struct value construction必须是不同plan。补class `T()`、struct `T()`、handle assignment/return、temporary/cleanup和public view type-kind tests。

### F4 — Blocking：member overload失败后仍退回“第一个同名同参数数量”，unresolved DeclRef/Call仍默认为合法 int

`ResolveCallee()` 对member call先调用 `FindBestCallee()`；若结果无效，又遍历class children并返回第一个 `name相同 + parameter count相同` 的method（`as_sema_expr.cpp:421-455`）。这会撤销 `FindBestCallee()` 的fail-closed行为：ambiguous overload已经记录diagnostic后仍可能绑定第一个同arity method；参数类型不兼容但数量相同时也可能错误绑定；声明顺序会影响结果。

同时，`ActOnCallExpr()` unresolved时创建 `int` CALL；`ActOnDeclRefExpr()` 找不到目标时仍创建 `int` lvalue DeclRef（`as_sema.cpp:677-708`）；member/index/unary/binary等第七轮列出的default-int路径未改；Verifier允许这些node Seal。

这说明13.2的核心不是“剩余 `snExprTerm` case数量”，而是exact semantic resolution和error-state publication。应删除same-arity fallback，建立显式error/unresolved type，required callee/target/type缺失时拒绝Seal/Publish。增加member ambiguity、same-arity mismatch、unresolved DeclRef/Call和diagnostic parity tests。

### F5 — Important：Param和Enumerator都按bare name复用，真实重复声明会被当成replay吞掉

- `ActOnStartParamDecl()` 在同owner下找到同名Param就直接返回（`as_sema.cpp:395-411`）；
- `ActOnStartEnumeratorDecl()` 在同enum下找到同名VAR就直接返回（`414-431`）。

两者都不比较source range/action identity。incremental action + complete WalkOne replay确实应该复用，但源码真实写出两个同名参数或enumerator应该报告duplicate，现在也会复用第一个。当前direct-action tests还用同名、同空range调用两次并断言ID相同，无法区分非法第二声明。

应改为same owner + same source/action identity才复用；distinct range同名必须走duplicate diagnostic。补duplicate param、duplicate enumerator、anonymous param、同名不同overload和recovery-after-error tests。

### F6 — Critical：第七轮 type/layout/accessor/list/handle/value-object lifetime blockers完全未变

`as_bytecode_codegen.cpp` 本轮未修改，因此第七轮F1/F3保持：

- script type registration只扫描direct-TU class、按裸名碰撞、alignment固定4、property失败静默跳过，并在完整emission前修改live registry/behaviour/method table；
- accessor/list helper仍只有4/8-byte路径：1/2-byte会越界读写，>8-byte会截断；
- non-null handle setter/getter仍是raw pointer copy，没有AddRef/Release；
- value-object list element没有完整construct/copy/assign/destroy/failure cleanup。

这些是可能产生内存破坏和对象lifetime错误的production blockers。当前支持面必须先fail-closed：只有被exact ABI/lifetime matrix证明的type shape才允许canonical Build成功。

### F7 — Critical：global/member initializer仍通过截断字符串协议传递

本轮没有修改相关路径：global integer evaluator最终仍经 `Format("%d", (int)value)` 写入 `defaultArg`，int64/uint64高位丢失；generated member default仍从syntax中取第一个数字并用`atoi()`，`40+1`可被生成为40；overflow、enum/named constant和完整conversion plan未闭环。

initializer必须是canonical typed Expr/constant/init plan，不应继续经string side-channel在Sema与CodeGen之间传递。

### F8 — Critical：CodeGen仍不是detached artifact + atomic install

本轮没有修改 `as_bytecode_codegen.cpp`。type、import、global、function ID、object behaviour和method table仍会在完整模块emission/verification之前写入live state；`Abandon()`不能完整撤销，`Commit()`也不是一次no-fail atomic exchange。

必须建立完整pending module artifact或覆盖所有live mutation的transaction journal，并用每个failure injection point的before/after状态比较证明no mutation。

### F9 — Blocking：Verifier仍允许当前新增的错误/孤儿graph发布

`as_ast_verifier.cpp` 本轮未修改。它仍没有expression reachability/single-owner/cycle完整验证、CALL/CONSTRUCT required callee、DeclRef required target、nearest legal control target、required cleanup destructor和call signature/receiver/argument role一致性。

本轮receiver-less orphan CALL恰好证明这些不是理论缺口。任务记录中“CALL-without-callee not required”必须撤销；2.8/13.5继续是false-complete。

### F10 — Blocking：Cache DTO、snapshot/public ABI、CompileFunction和SourceManager本轮无变化

以下第七轮blockers没有修改：Cache V2 sidecar仍不是完整pointer-free body DTO；snapshot Acquire/publish没有共同atomic-retain协议且candidate失败可能丢last-good；AST API仍有mid-vtable与caller size/version问题；public `CompileFunction()`仍使用legacy Compiler；SourceManager remap不校验content identity；stable owner/type/function/lambda identity仍不足以支撑Hot Reload、Cache和LLVM object cache。

## 对HIR/typed AST架构方向的影响

本轮findings并不说明应该删除canonical typed AST或回到legacy AST直接发LLVM。恰恰相反，它说明新AST必须真正承担“唯一、exact、可验证的语义事实”责任，而不能只是把旧 `asCScriptNode` walk分散到多个helper：

```text
当前过渡形态

asCScriptNode
   ├─ ParseFunctionCall 过早 ActOn（receiver 未知）
   ├─ ExprTerm 再 ActOn（receiver 已知）
   └─ WalkOne / FromNode 再 replay
          │
          ├─ arena 扫描猜测是否复用
          ├─ unresolved → int
          └─ backend 再跳过“看起来像孤儿”的节点

目标形态

Parser semantic operands / action identity
          │
          ▼
Sema pending action → complete exact call/init/lifetime/control plan
          │
          ▼
Verifier：唯一 ownership + required targets + exact types/signatures
          │
          ▼
sealed snapshot
   ├─ Bytecode CodeGen
   ├─ TypedASTJIT
   └─ future LLVM lowering
```

LLVM lowering比当前Bytecode helper更依赖exact receiver、evaluation order、type width、ABI和lifetime；如果不先修正这些语义，LLVM只会把silent wrong graph更快地变成native wrong code。

## 对整体完成度的判断

本轮新增Enumerator/DeclRef/Call/ExprTerm action是实质进展，但主要增加Frontend迁移资产，没有关闭决定production cutover的hard gates。

- mechanical checklist：`56/105 = 53.3%`，仍含false-complete；
- 架构资产完成度：约 **50%–52%**；
- 可安全替换现有compiler并成为默认的production readiness：仍约 **35%–40%**。

不建议因为SemaAuthority从203增长到206就上调production readiness。新finding反而要求重新审计9.4、2.8、13.5等已勾选宽任务。

## 建议修复顺序

1. **先修成员调用action protocol与single-evaluation。** 禁止member child在receiver未知时创建free CALL；receiver只保留一个semantic role；增加side-effect execution test。
2. **替换arena扫描式去重。** 建立source/action identity和pending→complete映射；覆盖scoped/unresolved/reparse/offset-zero。
3. **让Sema exact且fail-closed。** 删除member same-arity-first fallback和unresolved→int；class/struct construction产生正确type；required fact缺失不得Seal。
4. **完成Verifier ownership/required-target firewall。** 首先让orphan/duplicate/missing-callee graph无法发布。
5. **收紧CodeGen支持门。** 1/2-byte、>8-byte、non-null handle、value-object list、错误layout/type先fail-closed，再逐项实现exact ABI/lifetime。
6. **统一typed initializer plan并完成module transaction。** 删除`defaultArg`数值字符串协议；完整artifact验证后atomic activation。
7. **闭环snapshot/public ABI/Cache DTO/SourceManager/CompileFunction。**
8. **最后扩大完整语言面、真实host purposes并切默认。**

## 建议立即增加的最小回归矩阵

| 用例 | 必须锁住的事实 |
| --- | --- |
| `Make().Get(3)` | `Make()` side effect恰好一次；无receiver-less CALL；receiver不重复出现在arg/side-channel |
| free `Get()` 与 member `T::Get()` 同时存在 | member postfix不能先绑定free global；只有正确reachable callee |
| `Game::F()` successful parse + seal | 只有一个CALL；scope owner与range identity一致 |
| unresolved `Missing()` | diagnostic + Seal/Publish拒绝；不得生成多个int CALL |
| member ambiguous/no-viable same-arity overload | 不绑定第一个method；产生明确diagnostic |
| class `C()` vs struct `S()` | reference/value type kind、ABI、temporary/cleanup正确 |
| duplicate params/enumerators | distinct source range触发duplicate；same action replay才复用 |
| expression at offset 0 | action identity/去重正确 |
| failed canonical module build | Engine/module/type/import/behaviour/method/global/function状态逐项不变 |

## Ready to merge?

**No.**

方向正确，Frontend action迁移有真实推进，保存前缀也没有出现已覆盖回归；但本轮发现的member orphan/multiple-evaluation、scoped/unresolved call identity、class construction type和same-arity fallback都是semantic correctness问题。默认必须继续LEGACY，当前change不能归档，也不应开始正式LLVM backend实现。
