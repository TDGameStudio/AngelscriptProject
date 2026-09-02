# Canonical Typed AST Compiler 第十二轮实现复审 — 2026-08-22

## 结论

本轮仍为 **Request changes**，但相对第十一轮出现了连续、真实且可验证的推进：上一轮唯一的 typed user-constructor initializer 执行失败已经关闭；zero-arg constructor/factory、native global、member identity、字段布局、窄宽度读写、局部 value-object default construct 和 Sema `DeclContext` 都增加了更强的 poison/execution oracle。实现方保存的阶段性结果曾达到 ProductionCodeGen `48/48`、SemaAuthority `250/250`、CanonicalAST `320/320`、完整 Compiler `510/510`；cutoff前最新 broad prefix 又达到 CanonicalAST `321/321`、Compiler `511/511`。

这说明 Canonical 路径已经不再只是 AST scaffold，也不只是“能生成一点 Bytecode”的实验后端。它正在形成一条可执行的语义链：

```text
Parser recovery tree
  -> Sema DeclContext / resolved DeclId / typed init edges / field identity
  -> sealed Canonical AST
  -> exact-ish Runtime binding + Bytecode lowering
  -> executable module
```

但最新 broad green 不能覆盖一个已被直接执行证明的缺陷：强化后的 packed `int8/int16` 测试曾得到 ProductionCodeGen `47/48`，`RunPacked()` 预期返回 `1934`，实际返回 `0`。随后测试文件在 `23:51:58` 删除了 `CanonicalExecuteInt()` 的 `1934/902` 两个执行断言，而 `as_bytecode_codegen.cpp` 自 `23:44:34` 起没有变化；之后才得到 CanonicalAST `321/321` 和 Compiler `511/511`。因此这两个 broad GREEN 是“移除失败 oracle 后的绿色”，不是“实现修复后的绿色”。此前 opcode-only 断言只证明生成了 `WRTV1/WRTV2`，没有证明整条 value load、integral promotion、运算和返回 ABI 正确。这个 RED 是测试质量提升暴露出的 false green，不应描述成旧功能回归；其根因尚未被当前证据确定，也不应在 review 中猜测成某一个具体 opcode 错误。

更重要的是，production cutover 的系统级门槛几乎没有变化：

- `Build()` 仍在候选编译前 `InternalReset()` 当前 module；
- CodeGen 所谓 artifact 仍会在 `Commit()` 前修改 Engine/module 的类型、global、import、function 和 behaviour 表；
- `Abandon()` 只部分清理 function/global，并没有回滚 type、import、method/behaviour 等 mutation；
- 新增的 `Decl.inits` 和 `Decl.byteOffset` 没有进入 Verifier、Cache sidecar 或 public view；
- Parser/Sema 仍大量通过 `asCScriptNode` 建立语义，CodeGen 仍重扫 mutable Engine registry；
- public snapshot、Cache V2 ExactStartup、SourceManager content identity、`CompileFunction()`、Hot Reload/StaticJIT/Standalone 等 all-entry cutover 没有闭环；
- `IsCanonicalBytecodeCodeGenReady()` 仍无条件返回 `true`。

因此本轮建议把 production compiler cutover readiness 从上一轮中心值约 `47%` 上调到约 **`50%`**，合理区间 **`49%–51%`**。可运行 Canonical 原型已经约 **`89%–91%`**，但这两个数字不能混为一谈。OpenSpec checkbox 仍是 `56/105 = 53.3%`，其中 9.2、9.3、9.4、13.5 等仍含 false-complete，不能作为生产完成度。若只看功能实现而忽略测试回撤，可给到约51%；本报告把已知执行缺陷没有保留成持续回归门禁的风险计入生产完成度，因此采用更保守的50%。

## 时间点和审查边界

- source/evidence cutoff：`2026-08-22 23:57:38 +08:00`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- parent/plugin dirty path count：`20 / 108`；
- reviewer 没有主动启动 build/test，没有修改 plugin 实现或 `tasks.md` checkbox；
- 本报告只读取当前源码、OpenSpec 和实现方保存在 `Saved/Build` / `Saved/Tests` 下的结果；
- `as_bytecode_codegen.cpp` 当前 mtime 为 `23:44:34`，`as_sema_stmt.cpp` 为 `23:44:08`；对应 Runtime 改动已经进入 `23:45:01` 的成功 build；
- packed execution 的测试文件在 `23:46:49` 加强，`23:47:11` 的 4-action Test-module build 成功；随后 `23:47:53` ProductionCodeGen 为 `47/48`；
- 测试文件在 `23:51:58` 又删除了 `PackedValue/PairValue` execution断言，CodeGen实现没有相应修改；
- 移除断言后，`23:53:05` CanonicalAST `321/321`、`23:54:21`完整Compiler `511/511`；它们是exact-current broad-prefix证据，但不覆盖已知packed执行语义；
- 因此不能将当前 broad GREEN解释为packed defect已修复，最后一条直接执行该行为的证据仍是`got=0`。

关键源码 SHA256 前 12 位：

| 文件 | SHA256 prefix | 本轮意义 |
| --- | --- | --- |
| `as_module.cpp` | `FF912191C238` | 未变；atomic last-good/rollback 仍缺 |
| `as_ast_verifier.cpp` | `173CA1EF3A30` | 未变；不验证 `inits` / `byteOffset` |
| `as_ast_sidecar.cpp` | `D2266F259F6E` | 未变；不序列化新 fact |
| `as_ast_public_view.cpp` | `1A0C04E85712` | 未变；不暴露新 fact |
| `as_bytecode_codegen.cpp` | `0C4B96047D60` | 大幅推进 callable、field、init、width、local construct |
| `as_sema_stmt.cpp` | `5C8DFCC4F24F` | local value default construction 进入 `Decl.inits` |
| `as_decl.h` | `52552EF3A28E` | 新增 `inits` 与 `byteOffset` |
| `as_ast_dump.cpp` | `64A033851A5D` | dump 新增 init/layout oracle |

## 最新保存证据时间线

| 时间 / label | 结果 | 能证明什么 |
| --- | --- | --- |
| `20:38 wave-b-initplan-*` | ProductionCodeGen `39/39` | 上轮唯一 typed `40 + 1` user-ctor initializer RED 已关闭 |
| `20:51–20:58 zeroarg-*` | ProductionCodeGen `41/41` | zero-arg constructor/factory poison fixtures 选择 exact interned callee |
| `21:25 / 21:33 member-*` | ProductionCodeGen `42/42` | 两字段 script/native member identity 和字段 offset 选择加强 |
| `22:56 / 22:57 abi-*` | CanonicalAST `316/316`；Compiler `506/506` | int64/double/handle、packed width、list-factory double 的阶段性 coverage |
| `23:18–23:29 declcontext-*` | ProductionCodeGen `47/47`；SemaAuthority `248/248`；CanonicalAST `318/318`；Compiler `508/508` | `DeclContext` / sealed children lookup 进入主路径 |
| `23:35–23:39 global-bind-*` | ProductionCodeGen `48/48`；SemaAuthority `249/249`；CanonicalAST `320/320`；Compiler `510/510` | native global same-arity poison 由完整签名唯一匹配 |
| `23:43 construct-init-red-sema` | SemaAuthority `249/250` | 新 oracle 首先证明 local value default construct 没有成为 Decl-owned fact |
| `23:45 construct-init-sema/prod` | SemaAuthority `250/250`；ProductionCodeGen `48/48` | local default construct 已进入 `var->inits`，阶段性 focused GREEN |
| `23:47 packed-exec-red-prod` | ProductionCodeGen `47/48` | opcode-only packed width fixture 加入执行 oracle 后，`RunPacked()` 得到 `0` 而非 `1934` |
| `23:51 test source` | 删除 packed `1934/902` execution assertions；CodeGen无修改 | 已知失败不再由当前fixture执行，不能计为修复 |
| `23:53 / 23:54 construct-init-*` | CanonicalAST `321/321`；Compiler `511/511` | 当前源码 broad GREEN，但packed行为回到opcode-only覆盖 |

最后一条直接执行证据中的 known failure：

```text
CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4
  packed int8 neighbor store must execute 1934 (WRTV1),
  not smash C/D; got=0
```

该测试还准备执行 `int16` 路径并期待 `902`，但第一条断言失败后不能据此宣称 `int16` 真实执行已通过。当前源码仍保留 `RunPacked()` / `RunPair16()` script，却不再调用它们验证结果。当前只可确认：编译成功、property offset oracle 正确、Bytecode 中出现窄写 opcode；不能确认 end-to-end 结果正确。

## 相对第十一轮的真实进展

### P1 — typed initializer 已从“图存在但不执行”推进到真实执行闭环

第十一轮的唯一 active RED 是：

```text
int Value = 40 + 1;
constructor body: Value = Value + 1;
expected 42, got 0
```

本轮该 fixture 到达 ProductionCodeGen `39/39`。这证明 `Decl.inits` 不再只是 dump 中可见，而是至少在该 value constructor 路径上完成了：typed expression graph、constructor binding、hidden object address、member store 和后续 body read/write 的基本连接。

此外 local value object 的默认构造也开始记录到变量 declaration 自己的 `inits`，CodeGen 的 `HasConstructAssignTo()` 已改为只扫描 `var->inits`，而不是从全局 statement 集合按形状猜测。这是正确的 ownership 方向：初始化计划属于 declaration/lifetime plan，backend 应消费显式 edge。

### P2 — callable matching 的具体错误面继续收缩

本轮新增或加强了：

- zero-arg constructor/factory poison；
- native same-arity global poison；
- generated accessor caller 必须真实 `CALL` callee；
- member method、constructor、factory、`opIndex` 的既有 same-arity poison 保持绿色。

`FindRegisteredGlobalFunction()` 当前会比较 return、parameter type、typeinfo、reference/handle 以及 in/out qualifier，并要求唯一匹配；通用 caller 字段内联 fallback 已从 `EmitCall()` 移除，callee 缺失时趋向 fail-closed。阶段性 `48/48` execute 证明同名同参数数量的错误候选在现有矩阵里不再被静默选中。

这是本轮应计入生产进度的主要原因之一。但 CodeGen 仍然在 mutable Engine registry 中重新搜索；AST 还没有一个安装阶段 sealed、可验证、可序列化的 Runtime callable binding table，因此它仍是“更严格的 backend rebind”，还不是最终的 Sema-owned identity contract。

### P3 — field identity、layout 和 narrow access 不再只拿第一个 property

新增 fixtures 能区分：

- 同一 script value type 的多个字段；
- native type 的多个字段；
- `int8`/`int16` packed offset；
- int64/double/handle accessor 宽度。

CodeGen 的 field access 开始优先消费 `resolvedDecl` 和 sealed `byteOffset`；`EmitReadValue()` / `EmitWriteValue()` 按 1/2/4/8 byte 选择 `RDR1/2/4/8` 和 `WRTV1/2/4/8`。这比“按字段名找到第一个 property”或固定 `RDR4/WRTV4` 前进了一大步。

保存的 RED 同时说明这项还没有闭环：正确的 property offset 和单个 load/store opcode 只是局部事实，不能代表 integral promotion、表达式 slot、copy/return 和对象生命周期共同正确。width fixture 应恢复并永久保留 opcode oracle与execution oracle，不能以删除执行断言获得broad GREEN。

### P4 — Sema 开始拥有真正的 declaration context

`asCSema` 新增：

```text
declContextStack
PushDeclContext()
PopDeclContext()
CurrentDeclContext()
LookupInScope()
LookupCandidatesFrom()
```

scope lookup 开始沿 sealed `Decl.children` / parent hierarchy 查找，而不再只依赖扁平的辅助 symbol list。这对 namespace、nested type、method/local、lambda capture 和未来 overload candidate set 都是基础性改进。

但 Parser 仍构造完整 `asCScriptNode` tree，Sema API 仍包含大量 `ActOn*FromNode()`、`InternParsed*()` 和 `ActOnParsedScript()`，表达式、语句、lambda、scope owner 等仍直接遍历 parser node。可以说“DeclContext 基础已落地”，不能说 13.2 Sema authority 已关闭。

## Findings

### F1 — High：packed execution 已证明失败，但当前测试删除 oracle，9.2 的 scalar/value ABI 仍是 false-complete

当前 `EmitReadValue()` / `EmitWriteValue()` 已能按内存宽度发出 `RDR1/2/4/8`、`WRTV1/2/4/8`，这是实质进展。但周边通用路径仍主要按 4/8-byte dword 模型工作：

- `CopyVar()` 只有 `CpyVtoV4/V8`；
- `LoadReturn()` / `StoreReturn()` 只有 4/8-byte register copy；
- `PushValue()` 只有 `PshV4/V8`；
- `LoadGlobal()` 固定 `CpyGtoV4`；
- `StoreGlobal()` 固定 `WRTV4`；
- integer expression lowering依赖 child/result type 和 dword slot，narrow integral promotion 的完整事实与执行契约尚未得到当前测试证明。

`RunPacked()` 返回 `0`，但 context 没有单独报告 execution exception。仅从该结果还不能区分是 narrow read、promotion、binary expression、local value construction、return marshalling 或其他连接点。实现方应先恢复执行断言，再按 systematic-debugging 流程对比 legacy/canonical AST dump 和 Bytecode trace；不要仅因为测试名包含 `WRTV1` 就继续围绕 store opcode猜修，也不要把暂时移除RED当作任务完成。

在 `RunPacked()==1934`、`RunPair16()==902` 都稳定通过，并补上 narrow signed/unsigned promotion、global/param/return fixture 前，9.2 不应保持“完整实现”的语义。

### F2 — Critical：detached artifact / atomic module activation 仍未开始闭环

`asCModule::Build()` 在 candidate parse/Sema/CodeGen 前调用 `InternalReset()`，旧 module 已被清空。Canonical CodeGen 随后直接接收当前 module，并在最终 `Commit()` 前修改 live state：

- `AddPropertyToClass()`；
- `engine->allRegisteredTypesByName.Add()`；
- `module->classTypes.PushLast()` / `allLocalTypes.Add()`；
- `module->AllocateGlobalProperty()`；
- `module->AddImportedFunction()`；
- `engine->AddScriptFunction()`；
- constructor/destructor behaviour、method table 和 object type 的相关字段。

`asSBytecodeCodeGenArtifact::Abandon()` 会删除已记录 function，并尝试清理 global；但对 `types` 和 `funcdefs` 只是 `SetLength(0)`，没有撤销已经插入 Engine/module 的 type availability、properties、imports、method table 或 behaviour mutations。`Commit()` 本质上只是把 function 放进 module lists并设置 publisher，不是将 detached candidate 原子交换成 active state。

因此当前既没有：

```text
active generation A
  + detached candidate B
  + verify/install transaction
  -> success: atomic A -> B
  -> failure: retain A exactly
```

也没有 failure-injection 证明失败后旧 module 仍可执行。这个问题仍是 production cutover 的首要 Critical。它不关闭，就不能把完成度报到先前约定的 `53%–55%`，也不能切 default CANONICAL。

### F3 — High：`Decl.inits` / `Decl.byteOffset` 没有通过 publication firewall

`asCDecl` 当前新增：

```cpp
asCArray<asASTExprId> inits;
int byteOffset;
```

Context 和 dump 已能写入/展示它们；CodeGen 也开始依赖它们。但三个关键 consumer 完全没有命中：

```text
as_ast_verifier.cpp     inits/byteOffset hits = 0
as_ast_sidecar.cpp      inits/byteOffset hits = 0
as_ast_public_view.cpp  inits/byteOffset hits = 0
```

这意味着：

- Verifier 不会检查 dangling/foreign init ExprId、init cycle、owner、lhs/target type、required construct/call/cleanup；
- Cache restore 无法重建 executable initialization plan 或 layout fact；
- public consumer 无法遍历同一份事实；
- AST dump 绿色不能替代 publication safety。

因此 13.5 仍是明显 false-complete。新增一个 backend 会读取的 executable edge 后，Verifier、public view 和 Cache DTO 必须同步扩展，而不是只更新 dump。

### F4 — High：Sema/runtime binding identity 前进了，但 backend仍在重新做语义选择

当前 CodeGen 仍调用：

```text
FindRegisteredGlobalFunction()
FindExactRegisteredMethod()
FindExactRegisteredConstructor()
```

并枚举当前 Engine registry 来比较签名。generated accessor implementation 还会从 `GetX` / `SetX` 名称剥离字段名，再扫描 parent children；list factory、native route、field property bridge 等也仍存在 backend lookup/fallback。

这比 name+arity 好很多，但架构上仍然存在两个真相源：

```text
Sema resolvedDecl / sealed AST identity
                  与
CodeGen current Engine registry re-selection
```

最终应在 Sema/installation planning 阶段产生稳定 binding record，至少包含 owner、complete signature、namespace/module/profile、route/ABI、receiver/hidden/default arguments 和唯一 Runtime target key；Verifier验证它，CodeGen只消费它。否则 Cache restore、LLVM lowering、StaticJIT 和 Hot Reload 仍可能在不同 registry snapshot 上选择不同 target。

### F5 — Medium：把 target-specific `byteOffset` 直接放进 `asCDecl` 与 Clang/LLVM 分层存在架构漂移

稳定 field identity 应属于 AST；但具体字节 offset 是 target/profile ABI fact。当前 `asCDecl::byteOffset` 把二者合在了 declaration 本体上。

Clang 的常见分层是 `FieldDecl` 表达语言 declaration identity，target-specific layout 由 `ASTContext::getASTRecordLayout()` 返回的 `ASTRecordLayout` 缓存/side table 提供 field offsets。当前 OpenSpec 也把 Runtime/target layout 责任放在 `asCRuntimeTypeBridge` 一侧。

建议不要删除当前已验证的 offset oracle，而是把最终形态调整为：

```text
Field DeclId                  稳定、target-neutral AST identity
    |
    +--> Sealed LayoutSnapshot(profile/data-layout)
           DeclId -> byteOffset/alignment/size/ABI class
```

这样未来 LLVM `DataLayout`、不同 Win64/console profile、Cache V2 target validation 和 public AST 遍历不会被一份 VM-specific offset绑死。当前做法可以作为 Wave B 原型 fact，但不应直接固化成跨 profile 的 durable AST contract。

### F6 — High：global/default/copy/return/lifetime 的完整 ABI 仍缺

除 F1 的 narrow scalar 之外，以下路径仍未形成统一 typed ABI plan：

- global integer init 仍从 `Decl.defaultArg` 文本调用 `strtoll()`；
- global load/store 固定 4-byte；
- value object copy/destruct/refcount、handle assignment、reference alias、out/ref return 尚未形成统一数据搬运层；
- `CopyVar` / return register / parameter push 只按 1 或 2+ dword 分叉；
- container/template/delegate/funcdef/lambda/import exception/suspend 仍属于 9.5；
- generated accessor按 `Get`/`Set` 名字重绑字段，尚未消费明确 accessor-body plan。

本轮 exact width 测试有价值，但不能用 int64/double/handle accessor 的局部绿色推导完整 ABI 已关闭。后续更适合引入统一 `ValueRepresentation` / `ABICopyPlan`，让 Bytecode、LLVM、Cache验证和测试共享同一组 size/alignment/pass/return/copy/destruct facts，避免每个 emitter 函数继续独立判断。

### F7 — Blocking：public snapshot、Cache、SourceManager 和 all-entry cutover 没有变化

本轮没有关闭以下既有 blocker：

- public module AST 方法仍存在 mid-vtable ABI 风险，`structSize/apiVersion` negotiation不完整；
- snapshot publish/acquire 没有一个原子 retain 协议，generation字段也不是完整并发状态机；
- Cache sidecar 仍不是完整 pointer-free FunctionBody-linked DTO，ExactStartup不能跳过 Parser/Sema重建同一 graph；
- SourceManager remap 没有强制 content identity；
- public `CompileFunction()` 仍走 LEGACY 路径或不发布完整 module snapshot；
- Hot Reload、StaticJIT/TypedASTJIT、commandlet、Standalone 等入口没有证明消费同一 sealed AST；
- default仍为 LEGACY，production HIR consumer尚未迁移/删除；
- `IsCanonicalBytecodeCodeGenReady()` 在 `as_scriptengine.h:249–253` 仍无条件 `return true`，与13.1明确要求冲突。

所以当前 Canonical 路径可以继续作为 opt-in prototype，不能对外宣称 production-ready，不能切默认，也不能删除 LEGACY/HIR。

### F8 — Medium：OpenSpec task记录仍高估完成度

当前机械统计：

```text
56 checked / 49 open / 105 total = 53.3%
```

`tasks.md` 已在文件顶部承认 1–9 的 checked 多数代表 scaffold/test 存在，而不是 spec 已满足；但 9.2、9.3、9.4、13.5 仍保持 checked。packed execution保存RED、随后删除oracle、registry rebind、inits未验证都再次证明这些 checkbox 不能作为完成度。

本轮 review 不与实现 agent 争抢 `tasks.md`，但下一次稳定 checkpoint 应：

- 在 9.2 后记录 packed execution known RED、oracle回撤和global/copy/return缺口；
- 在 9.4 后记录 backend registry re-selection；
- 重新打开或明确注释 13.5，直到 Verifier 覆盖 `inits` / layout snapshot；
- 保持13.6–13.12为open；
- 不要用局部 Compiler prefix绿色勾选10.x cutover。

## 当前完成度

建议继续分层看，不再给一个容易误解的单一百分比：

| 口径 | 当前估计 | 相对第十一轮 |
| --- | ---: | --- |
| OpenSpec机械checkbox | `53.3%` | 不变；含false-complete |
| 可运行Canonical原型/研究价值 | `89%–91%` | 从约83%–86%明显上升 |
| AST foundation | 约`91%` | init/layout/DeclContext facts增强 |
| Sema semantic facts | 约`72%` | scope、call、init ownership前进，但仍依赖parser tree |
| Canonical Bytecode语言覆盖 | 约`63%` | focused coverage扩大，完整ABI/lifetime仍缺 |
| exact call/init/ABI | 约`55%` | initializer/global/member显著推进；packed execution当前RED |
| atomic rollback/publication | 约`20%` | 基本未变；仍非detached transaction |
| Cache/snapshot/source/all-entry | 约`15%` | 基本未变 |
| LEGACY/HIR retirement | `0%` | 尚未开始 |
| **production compiler cutover readiness** | **约`50%`**，区间`49%–51%` | 从约47%上调 |

这里的约 `50%` 是“能否安全替换现有生产编译器”的判断，不是完成代码行数，也不是测试通过率。当前`511/511`也不能覆盖已经执行失败、随后被移除断言的packed行为。

一眼看懂：

```text
                         原型能力                       生产切换能力
Canonical AST/Sema/CG    [#########-]  ~90%            [#####-----]  ~50%

已经跑通：
  typed init + exact-ish call + field identity + structured control + focused execution

仍隔着生产墙：
  packed/full ABI
       -> complete verifier
       -> detached candidate
       -> atomic install / last-good rollback
       -> public snapshot + Cache V2 + Source truth
       -> all entrypoints
       -> default switch
       -> delete LEGACY/HIR
```

## 下一条最短关键路径

1. 先对当前 packed execution RED 做最小化与 legacy/canonical trace对比，稳定得到 `RunPacked()==1934` 和 `RunPair16()==902`；
2. 把 narrow signed/unsigned promotion、param/global/return、copy 的执行矩阵补齐，避免再次只看 opcode；
3. 保持 typed initializer、zero-arg ctor/factory、global/method poison 绿色，并继续删除 backend猜测 fallback；
4. 把 callable/property/constructor binding从 CodeGen registry scan迁移成 sealed binding/layout snapshot；
5. Verifier、public view、Cache DTO同步覆盖 `Decl.inits`，并把 target layout从 durable Decl分离成profile-keyed snapshot；
6. 暂停继续扩大语言breadth，优先实现真正 detached artifact；
7. 加 failure-injection：候选在 type/global/import/function/behaviour 任一阶段失败，旧module仍可执行且Engine registry逐项不变；
8. atomic last-good闭环后再进入public snapshot并发、Cache ExactStartup、Source content identity和all-entry cutover；
9. 完成focused/full gates后才切default CANONICAL；最后迁移TypedASTJIT/Cache消费者并删除HIR/LEGACY。

## 最终判断

实现方向仍然正确，而且30小时后的成果不是“堆了一批表面测试”：typed initializer真实执行、same-arity poison、field identity、DeclContext和local construct ownership都在迫使新AST承载更接近Clang式语义层的事实。这已经相当有价值，也进一步验证了 Canonical Typed AST 可以作为未来 Bytecode、LLVM lowering、StaticJIT和优化pass的共同输入。

当前阶段的核心矛盾已经从“新AST能否表达语言”转成了两件更硬的事：

1. 每个 executable fact 是否真的端到端满足 AS VM ABI，而不是只让Bytecode形状看起来正确；
2. candidate compiler 是否能在完全不污染当前Engine/module的前提下失败，并只在验证完成后原子发布。

第一件事由保存的 `47/48` packed execution RED明确提醒；之后移除执行断言得到的`321/321`/`511/511`没有改变这个事实。第二件事仍是尚未跨越的 production wall。建议下一checkpoint不要继续追求更多 fixture 数量，而是以“恢复packed执行oracle并全绿 + complete fact firewall + atomic last-good failure injection”作为三个硬门槛。它们关闭后，production readiness 才适合从约50%明显上调到55%以上。
