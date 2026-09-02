# Canonical Typed AST Compiler 第十轮实现复审 — 2026-08-22

## 结论

本轮结论仍为 **Request changes**。方向没有偏，CANONICAL Bytecode CodeGen 的可执行语义子集继续扩大；但截至本轮时间点，不能把 CANONICAL 设为默认，不能删除 LEGACY Compiler/HIR，不能归档 OpenSpec，也不能把 `IsCanonicalBytecodeCodeGenReady()==true`、单测单跑绿色或 `56/105` checklist 解释为 production compiler ready。

相对第九轮，本轮出现了两类重要进展：

- `OpaqueValue` 已改为 CodeGen-local memo，index compound assignment 能够保持 base single-evaluation 并 write-through；
- logical short-circuit、conditional arm、property compound assignment 和 value temporary 增加了 LEGACY/CANONICAL 隔离执行 trace，return-slot/dtor 覆盖路径也得到局部修正。

但最新保存证据同时暴露了一个新的真实语义错误：同一个 `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` 单独运行可以偶然通过，放入完整 Semantics 前缀后却返回 `13733`。源码交叉检查表明，当时用户自定义构造函数存在时，class/struct member 的 `int Value = 41` initializer 没有被注入到该构造函数；单跑绿色依赖未初始化 VM local 恰好包含期望值。这使第九轮 F3/F4 从“静态风险”升级为“已有运行时错误证据”。

在主 cutoff 之后，implementer 于 `18:11:22` 又向 CodeGen 添加了 `EmitConstructorMemberDefaults()`，在每个 constructor body 前直接按 `defaultArg` 写 integer/bool member。本报告已将它作为 post-cutoff addendum 纳入审查：新 patch 随后完成 `68/68` action build、isolated trace `4/4` 和 broad Semantics `12/12`，因此当前 `Value=41` 的具体运行症状已局部关闭。但实现仍通过 `atoi()` 在 backend 重新解释字符串、只支持整数类 property，并与 generated constructor body 的既有默认赋值存在重复风险；因此不等价于 spec 所需的 Sema-owned typed initializer plan。

## 时间点和审查边界

- primary point-in-time cutoff：`2026-08-22 18:07:52 +08:00`；
- post-cutoff source/verification addendum：源码锁定 `18:11:22`，验证完成 `18:14:22 +08:00`；仅 `as_bytecode_codegen.cpp` 再次变化；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- parent/plugin dirty path count：`20 / 108`；
- cutoff 时没有 `UnrealEditor` / `UnrealEditor-Cmd` 进程；
- reviewer 没有主动启动 build/test，没有修改 plugin 实现或 `tasks.md` checkbox；
- 本报告读取实现者已保存的 Build/Test reports，并静态复核当前源码；
- 上轮 cutoff 后实际变化集中于 `as_sema_expr.cpp`、`as_bytecode_codegen.cpp` 和两组 CanonicalAST tests；`as_module.cpp`、Verifier、public view、SourceManager、sidecar 等关键 blocker 文件未变化。

关键源码 SHA256 前 12 位：

| 文件 | SHA256 prefix | 相对第九轮 |
| --- | --- | --- |
| `as_parser.cpp` | `A6F022862E3C` | 未变 |
| `as_sema.cpp` | `75F5156DAD75` | 未变 |
| `as_sema_expr.cpp` | `49E546C6930D` | 已变 |
| `as_bytecode_codegen.cpp` | `25644DE66757` | 已变；包含 18:11 constructor-default tactical patch |
| `as_ast_verifier.cpp` | `173CA1EF3A30` | 未变 |
| `as_module.cpp` | `FF912191C238` | 未变 |
| `as_ast_public_view.cpp` | `1A0C04E85712` | 未变 |
| `as_source_manager.cpp` | `EB60196F8967` | 未变 |
| `as_ast_sidecar.cpp` | `D2266F259F6E` | 未变 |

## 当前保存验证证据

### Exact-current Build

`wave-b-54-remain/20260822_180423_124_1eb1ecc8`（18:11 patch之前）：

- `ProcessExitCode=0`；
- `Result: Succeeded`；
- UBT 判定 target up to date，执行 `0` compile actions；
- source 当时的最新修改时间为 `17:59:15`，因此该 up-to-date 判定晚于 pre-patch 源码修改；
- 这只能证明 pre-patch 二进制与源码时间戳一致，不能证明运行语义正确；
- pre-patch这份build不能证明18:11 patch；post-patch evidence见下一节。

### Post-patch验证

`wave-b-54-remain-ctorinit/20260822_181139_600_5f250458`：

- `68/68` build actions完成；
- `ProcessExitCode=0`；
- `Result: Succeeded`；
- isolated trace `wave-b-54-remain-iso2`：`4/4`；
- broad `wave-b-54-remain-sem/20260822_181348_894_13d4f1c6`：`12/12`，0 failed，0 skipped。

这证明当前integer member-default tactical patch关闭了本轮具体`13733`回归；它不证明typed initializer、exact lifetime或完整language surface已经完成。

### 最新运行证据

| Label / prefix | 结果 | 判断 |
| --- | --- | --- |
| `wave-b-54-remain-prop-g`（18:05） | `1/1` | property isolated 单跑 GREEN |
| `wave-b-54-remain-temp-g`（18:06） | `1/1` | value temporary isolated 单跑 GREEN |
| `wave-b-54-remain-iso`（18:01） | `4/4` | 四个 isolated trace 一次 GREEN |
| `wave-b-54-remain-sem`（18:02，pre-patch） | `11/12`, `1 failed` | 定位 member-init 缺口的 broad RED；post-patch 已变为 `12/12` |

失败项：

```text
IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace
CANONICAL FValue().Value+1 got=13733
```

同一测试在pre-patch相同源码/二进制下单跑多次为GREEN、完整前缀为RED，说明单跑绿色不是稳定正确性证据。结合initializer源码路径，可解释为未初始化local的运行顺序/内存布局偶然性，而不是已完成的deterministic lifetime semantics。18:11 patch之后的build + isolated + broad Semantics已经GREEN；仍缺非整数initializer、重复/随机顺序、full CanonicalAST/Compiler等更广证据。

较早的 `wave-b-54-opaque-sema` 为 `236/236`，但它发生在 `as_bytecode_codegen.cpp` 17:59 的后续变化之前，不能作为 exact-current broad CodeGen 证据。当前没有一份在最新 CodeGen 之后完整绿色的 SemaAuthority/CanonicalAST/Compiler broad report。

## 相对第九轮的真实进展

### P1 — OpaqueValue 已成为 CodeGen-local single-evaluation memo

`as_bytecode_codegen.cpp` 现在为每个 function emission 清空 `opaqueSlots`，`EmitExpr(OPAQUE_VALUE)` 按 `ExprId` 缓存第一次 child emission 的 slot。`ObjectTypeFromExpr` 也能解开 OpaqueValue，index mutation 保存地址并执行 write-through。

因此以下具体语义已得到更可信的 execute evidence：

- `Make()[0] += 1` 的 Make receiver 不重复执行；
- local `v[0] += 1` 的写入能够通过 `opIndex` reference 写回；
- `CanonicalIndexCompoundAssignEvaluatesMakeOnce` / `WritesThroughLocal` 已进入 Semantics 集合；
- property compound assignment 的 `RunMake` / `RunLocal` isolated 路径能够执行。

这关闭的是 5.4 的一部分 executable slice，不是完整 5.4/13.2：Sema 仍通过 arena replay 构造 OpaqueValue/Sequence，完整 mutation、temporary、compiler-generated value 和 lifetime contract 尚未闭环。

### P2 — return value 在 destructor 前保存的方向正确

CodeGen 为非 void function 分配 `returnSlot`，`STMT_RETURN` 先把结果复制到该 slot，再在 epilogue 执行 `DestroyLiveObjects()`，最后 `LoadReturn(returnSlot)`。Generated getter 也改为复制到统一 return slot，避免 getter 已经写返回寄存器后又被 epilogue 的未初始化 slot 覆盖。

这修复了 property `RunLocal` 的一个具体错误，也避免 destructor call 覆盖 primitive return register。方向是正确的，但只支持当前 4/8-byte `CopyVar/LoadReturn`，不能视为通用 value-return/lifetime 完成。

### P3 — logical/conditional/property/value trace coverage 变得更接近 differential oracle

新增测试使用不同 Engine，明确断言：

- LEGACY publisher 为 `COMPILER`；
- CANONICAL publisher 为 `CANONICAL_CODEGEN`；
- logical `&&/||` short-circuit side-effect trace；
- conditional 只执行被选择 arm；
- property/index receiver single-evaluation；
- value temporary ctor/dtor trace。

这种测试形式比“CANONICAL flag + script executes”更可信。不过 value temporary 当前 broad RED，恰好证明这些 tests 现在开始真正发现 canonical backend 自身的缺口。

### P4 — 第九轮 F2 已有高质量修复设计，但尚未实现

`attachments/wave-b-ninth-f2-exact-binding.md` 已准确梳理 native global/method/constructor/factory/opIndex 的 exact Runtime binding 方案，并提出 same-arity poison execution tests。研究方向正确，但 attachment 明确标注 research-only；当前源码中的 name+arity/first-match fallback 仍全部存在。

## Findings

### F1 — Critical：pre-patch 用户构造函数跳过 member initializer；post-cutoff backend string patch 仍不是 typed init plan

测试 source：

```angelscript
struct FValue
{
    int Value = 41;

    FValue()
    {
        Trace(1);
    }
}
```

Sema 的 `FillGeneratedConstructorDefaults()` 通过 `atoi(member->defaultArg)` 为 member initializer 生成 assignment，但 `EnsureGeneratedLifecycle()` 只在没有用户构造函数、或 constructor 本身具有 `TRAIT_GENERATED` 时调用它。存在用户 `FValue()` 时：

```text
hasCtor = true
generatedCtor = invalid
FillGeneratedConstructorDefaults() 不执行
```

CodeGen 注册 property layout，但不会把 `defaultArg` 自动写入每个用户 constructor；用户 constructor body 里也只有 `Trace(1)`。因此 `FValue().Value` 读取未初始化 local。

保存证据与该路径一致：

- isolated 单跑偶然得到 `42`；
- 完整 Semantics 前缀得到 `13733`；
- ctor/dtor trace 本身可以正确，但成员值不稳定。

18:11 新 patch 在 emitter 进入任意 `DECL_CONSTRUCTOR` 时调用 `EmitConstructorMemberDefaults()`，枚举 parent class 的 members，用 `atoi(defaultArg)` 建 immediate，然后直接写 property。它比“只填 generated ctor”覆盖面更大，可能修复当前 `int Value=41` 的具体症状，但仍有这些问题：

- Sema/AST没有保存 typed initializer plan，backend仍在重新解释源码文本；
- 只接受 integer/unsigned/bool，object、enum conversion、constant expression、list/value construction都被跳过；
- `atoi("40+1")`仍得到40，64-bit/overflow语义仍错；
- generated constructor已有 `FillGeneratedConstructorDefaults()`生成的assignment body，新 emitter会在body前再写一次；
- property lookup/unsupported type miss被静默continue，不能fail-closed；
- 写入仍经过4/8-byte粗粒度路径，窄字段安全问题未解决。

post-patch Build、isolated `4/4`、broad Semantics `12/12` 证明 `int Value=41` 的当前 fixture 已修复。修复不能停在清零local、修改测试把`Value=41`手写进ctor、或继续扩展backend `atoi`。正确语义是每个delegating/non-delegating constructor都有Sema-owned initializer plan：member default initializer应按declaration order在user body前执行，显式member initializer覆盖default，并带exact typed Expr/conversion/construction/lifetime/cleanup。通用问题继续阻塞5.7/5.8/9.5。

### F2 — Critical：CodeGen 仍重新按名字/参数数量选择 callable；第九轮 F2 未关闭

当前源码仍包含四条 backend re-Sema 路径：

1. `FindRegisteredGlobalFunction()` 只比较 `name + parameter count`，返回第一个 system global；
2. `EmitCall()` 在 `FindFunc(resolvedDecl)` miss 后，遍历 `FindMethodUntil(name)`，只用三种 arity 条件接受第一个 method；
3. `EmitConstructInto()` 用 `FindConstructorId(argCount)` / `FindFactoryId(userArgCount)`；
4. `EmitIndex()` 直接取第一个 `opIndex`，甚至不比较参数数量。

这些路径忽略 exact parameter QualType、in/out/ref、const method、return type、owner、template substitution、route/ABI 和 Sema stable target。当前没有 same-arity poison execute GREEN；attachment 不是实现证据。

OpenSpec 9.4 仍被 checked，与当前源码冲突，应重新打开。

### F3 — Critical：return-slot/OpaqueValue 局部修复没有解决通用 width/layout/lifetime

当前 `EmitReadValue`、`EmitWriteValue`、`CopyVar`、`LoadReturn` 都只有两种分支：

```text
dwords >= 2 → 8-byte instruction
otherwise   → 4-byte instruction
```

结果是：

- 1/2-byte property/member 使用 4-byte read/write，可能覆盖相邻字段；
- 大于 8-byte value 只复制前 8 bytes；
- `dwords >= 2` 把 3、4、更多 dword 全部降成 8-byte；
- member/index/global store 仍有固定 `WRTV4` 路径；
- handle/value/funcdef copy/move/refcount/destruction 没有统一 plan；
- fixed/approximate alignment 和 silent property loss 风险未变。

新 return-slot 只能保护当前 scalar return，不是通用 ABI/lifetime 层。OpenSpec 9.2 仍被 checked，也应重新打开或拆成“scalar subset”与“exact language matrix”。

### F4 — Critical：initializer/default semantic contract 仍是 string，最新 failure 已证明其不足

当前仍有：

- integer literal/default 使用 `strtoul()`；
- member default 使用 `atoi()`；
- global initializer 通过 `defaultArg` string + `strtoll()`；
- generated constructor 默认值只处理能被 host parser 当作整数开头的文本；
- user constructor 未接入 member initializer plan。

因此以下语义均不可靠：

- 64-bit signed/unsigned literal 和 overflow diagnostics；
- `40 + 1`、enum、const expression、conversion；
- non-integer/object member initializer；
- member initialization order；
- user constructor 与 generated constructor 的一致性；
- exceptional cleanup。

需要由 Sema 保存 typed `InitPlan` / `ConstValue` / conversion / construction / cleanup；CodeGen 只执行 plan，不再解析文本。

### F5 — Blocking：通用 expression replay identity 未修；OpaqueValue 仍建立在 arena 猜测上

`FindExistingExpr()` 仍然：

```text
拒绝 begin offset == 0
只比较 kind + begin FileID + begin offset
忽略 end、owner、semantic role、operands、callee、generation
```

CALL full-range 专用修复仍在，但 Sequence、Conversion、Assign、OpaqueValue、Index、Unary、Construct、Conditional、Logical、Binary、DeclRef、Cleanup 等仍大量调用通用启发式复用。

OpaqueValue CodeGen memo 是正确的 backend-local lowering state，但 Sema 创建哪个 OpaqueValue 仍可能复用错误节点。13.2、4.2–5.9 继续 open 是正确的。

### F6 — Blocking：Verifier 仍不是 executable publication firewall；13.5 仍 false-complete

`as_ast_verifier.cpp` 哈希与第九轮相同。它仍只在 `resolvedDecl.IsValid()` 时检查 DeclId 是否存在；不要求 CALL/CONSTRUCT/DECL_REF/CLEANUP 必须具有 target，也不验证：

- call target kind/signature；
- receiver 和 argument role/order；
- type compatibility；
- Expr owner/reachability/multi-owner；
- Expr cycle；
- exact init/cleanup plan。

当前 `tasks.md` 仍把 13.5 标为 checked，与 spec 的 “Seal must fail before any consumer sees an incomplete graph” 不符，应重新打开。

### F7 — Critical：CodeGen artifact/module activation 仍非 detached/atomic

`as_module.cpp` 未变化：`Build()` 在 candidate parse/Sema/CodeGen 前调用 `InternalReset()`，last-good module 已先被删除。

`as_bytecode_codegen.cpp` 当前仍在 emission/commit 前修改 live state：

- `RegisterCanonicalScriptTypes()` 写 Engine type registry、module class/local type tables；
- imports 直接 `AddImportedFunction()`；
- globals直接 `AllocateGlobalProperty()`；
- script functions 在 body emission 前 `engine->AddScriptFunction()`；
- function signature 填充会修改 behaviours/method tables。

`Artifact::Abandon()` 只回收部分 function/global；它最后直接清空 `funcdefs/types` tracking，不能撤销这些 registry/table/behaviour/import mutation。F1 的 atomic replacement blocker没有关闭。

### F8 — Critical/Blocking：Cache、public ABI 和 snapshot protocol 均未变化

以下文件自第九轮未变化：`as_ast_sidecar.cpp`、`as_ast_public_view.cpp`、`as_module.cpp`。

因此仍然成立：

- UE Cache wrapper 丢弃调用者真正的 `CanonicalAstBytes`；
- sidecar codec 只保存 dump + declaration skeleton，不保存完整 Source/Type/Stmt/Expr/body/reference/dependency/init/cleanup/call plan；
- decode 把 named type 粗略恢复成 VALUE_OBJECT；
- public AST methods mid-vtable insertion 仍可能破坏 embedding ABI；
- Get* 不尊重 caller `structSize/apiVersion`；
- snapshot Acquire raw-pointer→AddRef 存在并发窗口；
- current generation 不是原子协议；
- failed publication 不能保留 last-good。

13.7/13.8/13.9 继续是 cutover blocker。

### F9 — Blocking：SourceManager content identity 未变化

`as_source_manager.cpp` 哈希与第九轮相同。`RemapLogical()` 仍按 logical key + origin 命中旧 FileID，不比较 bytes、byteCount、content hash、lineOffset 或 generation。changed content 可继续复用 stale source table。13.10 仍 open。

### F10 — Blocking：all-entry cutover 未变化，Ready 仍无条件 true

`as_module.cpp` 未变化：

- default pipeline 仍 LEGACY；
- public `CompileFunction()` 仍走 `asCBuilder::CompileFunction()` / `asCCompiler`；
- CANONICAL `Build()` 只是当前子集 opt-in；
- HIR/TypedASTJIT/cache/snapshot consumer 尚未统一。

`as_scriptengine.h` 当前仍写：

```cpp
bool IsCanonicalBytecodeCodeGenReady() const
{
    return true;
}
```

它最多表达 binary 中存在一个 CANONICAL Build route，不能表达 current module eligibility、supported semantic matrix、last-build provenance 或 production-default readiness。13.1 仍未完成。

## OpenSpec 记录一致性

当前 checklist 仍是：

```text
56 checked / 49 open / 105 total = 53.3%
```

机械数字没有变化。但至少以下 checked 项与当前源码/证据冲突：

- 9.2：exact-width/local/global/member reads/writes 与通用 marshalling 未完成；
- 9.4：exact callable binding 尚未实现，backend 仍 name+arity/first-match；
- 13.5：Verifier 不要求 executable required targets，也没有 Expr ownership/cycle/reachability firewall；
- 12.1/12.5：可保留为历史 verification 执行记录，但不能被解释为“当前实现最终验证完成”。

本轮只记录该冲突，没有主动修改 checkbox，避免与实现 agent 的工作流发生冲突。

## 进度估计

建议继续区分三个数字：

- checklist 机械完成度：`53.3%`；
- architecture/scaffold assets：约 `59%–62%`；
- production cutover readiness：约 `42%–45%`，中心估计约 `43%`。

相对第九轮，expression/CodeGen executable slice确实扩大，pre-patch broad RED也推动出post-patch `12/12`修复，因此architecture assets和production readiness都可小幅上调；但F1–F10中没有一个系统级cutover blocker完全关闭。阶段仍是B中期：

```text
A Canonical AST/Source/Type scaffold          基本具备
B Sema + Canonical CodeGen executable slice   进行中  ← 当前
C Full language + exact init/lifetime/ABI     未完成
D Detached artifact + atomic activation       未完成
E Public snapshot + Cache + Source truth      未完成
F All-entry production cutover                未完成
G HIR/LEGACY retirement                       未开始
```

## 推荐下一步

当前不要继续扩展新的语言 breadth，也不要开始 LLVM backend。建议顺序调整为：

1. 先把 `IsolatedValueTemporary...` 变成稳定 RED→GREEN：为 user/generated constructors 统一建立 typed member-init plan，禁止依赖 local 初始内存；随后连续执行单测、Semantics broad、随机/重复顺序；
2. 实现 attachment 已设计好的 `ExactCallableBinding`，增加 native global/method/ctor/factory/opIndex same-arity poison execute tests，删除 CodeGen name+arity/first-match；
3. 建立 exact layout/value operation/lifetime plan，覆盖 1/2/4/8/>8-byte、value return、handle/refcount、copy/move/destruct；
4. 将 Generate 改为真正 detached module artifact，并在完整验证后 atomic activation，失败保留 last-good；
5. 把 Verifier 升级为 strict executable publication firewall；
6. 再处理通用 Sema action identity，逐步删除 `FindExistingExpr(kind+begin)` 和 `FromNode` arena replay；
7. 最后完成 public ABI/snapshot、Cache DTO、SourceManager content truth、all-entry cutover；
8. 只有上述 gates 完成并通过 broad/full canonical provenance tests 后，才讨论 default CANONICAL、HIR/LEGACY retirement 和 LLVM lowering。

## 最终判断

实现方向仍然正确，并且本轮的 OpaqueValue/return-slot/trace 工作是有效的：它让 canonical backend 开始承受真正的 evaluation-order 和 lifetime oracle，而不是只看 dump/flag。

但也正因为测试更真实，不能把post-patch `4/4`或`12/12`外推为完整compiler ready。pre-patch `11/12` + `got=13733`证明了缺口，post-patch验证只证明当前integer fixture局部修复；`EmitConstructorMemberDefaults()`仍是backend string workaround。下一阶段应从“继续增加能跑的例子”切换为“把initializer变成Sema-owned typed plan，并消除backend re-Sema、partial mutation和非原子发布”。
