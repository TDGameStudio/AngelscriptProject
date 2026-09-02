# Canonical Typed AST Compiler 第六轮实现复审 — 2026-08-22

## 复审结论

当前实现仍为 **Request changes**。

这轮不是“没有进展”。从第五轮到本轮，CANONICAL production CodeGen 已经从少量标量函数扩展到 value object、temporary、引用参数、suspend、host funcdef、`array<int>`、import、generated accessor/destructor/default constructor、list factory、capturing IIFE、overload-selected call 等一批真实切片；Parser→Sema 的独立 action 覆盖也继续扩大。实现者保存的当前证据包括：

- ProductionCodeGen `25/25 PASS`；
- Cutover `5/5 PASS`；
- SemaAuthority `170/170 PASS`；
- CanonicalAST `210/210 PASS`；
- Compiler `398/398` 完成，其中 `397` success、`1` succeeded-with-warning、`0` failed。

但本轮发现的问题比“某个语言特性尚未支持”更严重：若干新增路径正在把只对 `int` fixture 成立的实现推广成通用 runtime 类型/layout/ABI 语义，从而产生 **Build 成功但运行语义错误、对象布局错误、甚至写错内存** 的风险。最突出的例子是：

1. 所有 canonical script class 都被注册成 `asOBJ_VALUE | asOBJ_NOINHERIT`，而 legacy Builder 对普通 script class 使用 `asOBJ_REF | asOBJ_IMPLICIT_HANDLE`；
2. class 的最终 alignment 固定为 4，property 解析/安装失败还会被静默跳过；
3. generated accessor 与 list factory 固定用 4-byte `RDR4/WRTV4`；
4. integer global initializer 通过 `atoi(defaultArg)` 重新解释源码字符串，并始终向 `int*` 写 32 bit；
5. capturing lambda 的 capture 集合由 backend 重新遍历 AST 推断，而且多个 lambda 捕获同一外部变量时，第二个 lambda 会因全局去重而得到零 capture；
6. type/import/object behaviour/method table 已在 emission 完成前写入 live Engine/module，但 rollback 没有撤销这些 mutation。

因此当前最准确的定位是：

> **一个 breadth 快速扩大的 opt-in canonical Bytecode prototype；它已经有真实 production route，但当前新增语言面仍以窄 fixture 驱动，尚未形成可证明正确的通用类型 ABI、Sema authority 和原子安装协议。**

不能归档，不能切 production default，也不能把 `Ready()==true` 或 `25/25` 解读为完整 AngelScript compiler ready。

## 复审快照与边界

- worktree：`D:\as-cta`，对应 `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time：**2026-08-22 08:01:55（Asia/Shanghai）**；
- parent 有 `20` 个 changed/untracked paths，plugin 有 `106` 个 changed/untracked paths；全部实现仍是 dirty worktree 内容，不等同于两个 HEAD 的已提交源码；
- `as_sema_decl.cpp` 在 07:56 又有更新；随后实现者完成了 07:57–07:59 的 SemaAuthority/CanonicalAST/Compiler 三组报告。本报告吸收了这批最新落盘源码与结果；
- 快照时没有仍在运行的相关 UnrealEditor/build/test 进程；
- reviewer 没有主动 build/test，没有修改 plugin 实现，也没有修改 `tasks.md` checkbox；测试数字来自实现者保存在 `D:\as-cta\Saved\Tests` 的 JSON report。

OpenSpec checklist 仍为：

- total：`105`；
- checked：`56`；
- open：`49`。

至少 `2.8`、`3.5`、`3.6`、`12.6`、`13.5` 与当前源码/规格不相容；只纠正这五项时是 `51/105`。若严格按任务原文重开 `6.7`、`7.6`、`8.4`，则为 `48/105`。这只是 checklist honesty，不是 production readiness 百分比。

## 相对第五轮的真实进展

### 已关闭或被新实现取代

1. **无 function body 就提前成功、完全不处理 type/global 的路径已移除。** `Generate()` 现在先做 declaration preflight、注册 class、处理 direct-TU globals，再建立 functions。
2. **member 无条件作为 global 发布的问题已局部修正。** `FillFunctionSignature()` 现在尝试绑定 `objectType`；`Commit()` 只把 `objectType == 0` 的函数加入 global function tables。
3. **CodeGen 正错误码映射已修复。** `as_module.cpp:416-425` 现在把任何 `Generate()!=0` 当失败，并把 verifier 的正数错误码映射为 `asERROR`；不再存在“positive verifier code 被 Build 当成功”的路径。
4. **production language slices 明显扩大。** 当前 production fixture 已达到 `25` 项，并覆盖 import、generated bodies、list factory、capture 和 selected-overload call，而不是第五轮时的最小 scalar route。
5. **Parser→Sema 独立 action coverage 继续扩大。** 当前新增 named declaration、compound/case/expression stmt、literal、conditional、control、decl-ref、type、member/index/unary 等 action tests；最新保存结果为 `170/170`、`210/210`、`398/398`。
6. tasks 对 `9.1`、`9.5`、`9.6`、`9.7`、`13.1`–`13.3`、`13.6`–`13.12` 仍保持 open，这是正确的，没有直接拿 `25/25` 宣布 full-language closure。

### 仍未关闭

- default LEGACY lambda compatibility；
- Sema sole authority 与 complete exact typing；
- detached artifact / atomic install / no-mutation-on-failure；
- complete verifier firewall；
- Cache V2 complete DTO / ExactStartup reconstruction；
- snapshot atomic retain/exchange / last-good preservation；
- append-only、size-negotiated public ABI；
- CompileFunction canonical parity；
- SourceManager content truth；
- complete owner/type/lambda stable identity；
- 真实 Hot Reload、generation、commandlet、Standalone entry 和 final All gate。

## Findings（按严重性排序）

### F1 — Critical：canonical script class 注册与 layout 语义错误，并可能复用/污染同名 host type

`RegisterCanonicalScriptTypes()` 位于 `as_bytecode_codegen.cpp:2325-2408`。当前实现对每个 TranslationUnit 直接 child class：

- 若 Engine 已存在同裸名 type，就直接 `continue`（`2348-2352`）；
- 否则总是创建 `asOBJ_VALUE | asOBJ_SCRIPT_OBJECT | asOBJ_NOINHERIT`（`2354-2364`）；
- `alignment` 固定为 `4`（`2364`）；
- property type 解析失败或 `AddPropertyToClass()` 失败时只是 `continue`（`2376-2385`）；
- property offset 按各自 alignment 前移，但没有把 `st->alignment` 更新到最大 property alignment；最终 size 仍只按 4 对齐（`2386-2402`）；
- emission 尚未开始就把 type 写入 Engine/module registries（`2403-2406`）。

这与现行 legacy Builder 的语义直接冲突。`as_builder.cpp:2846-2883` 对普通 script class 使用 `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`，只有 `struct` 才切成 `asOBJ_VALUE | asOBJ_NOINHERIT`；它还处理 shared/final/abstract/UE shadow/base layout 等状态。Canonical CodeGen 当前把 class/struct 语义压成同一种 value object，不能视为兼容实现。

具体风险包括：

1. 普通 script class 的 handle/reference/GC/object lifetime 语义被改成 value object；
2. 含 `double`/64-bit/高 alignment property 的对象，最终 size/alignment 可错误，例如 `double + int` 可能得到 12-byte/align-4，而正确布局需要按最大 alignment 收尾；
3. 无法解析的 property 被静默丢弃，Build 仍可能成功；
4. nested namespace class 没有被这段 direct-TU scan 注册；
5. `FindCanonicalObjectType()` 在 module 找不到后会调用 `engine->GetTypeInfoByName(name)`（`199-217`）。若脚本 class 与 host/另一 module type 同裸名，前面的 `continue` 加这里的 fallback 会把方法/constructor/destructor 绑定到已有 type；
6. `FillFunctionSignature()` 随即修改该 object type 的 `beh.construct`、`beh.destruct`、`constructors`、`methods` 和 `methodTable`（`2463-2488`）。同名碰撞因此不只是 lookup 错，而可能污染 host type behaviour table。

这是一条 silent ABI/layout corruption 路径。必须在扩大更多 object/container opcode 前修复。

建议：

- 把 class/struct/interface/enum 的 source semantics、namespace、base/interface、flags、GC/ref/value policy 做成 Sema/module artifact 中的显式类型描述；
- 使用完整 stable owner identity 查找，禁止按裸名 fallback 复用任意 Engine type；
- property/type/layout 任一步失败都整模块 fail-closed，禁止 `continue` 丢字段；
- layout 计算必须复用或抽取 legacy 已验证规则，并让 final size 按最大 alignment、base/shadow requirement 对齐；
- 加 `class` vs `struct`、nested namespace、same-name host type、double/int64/property object、inheritance/interface、property-resolution failure 的 production registry/layout/execute/teardown tests。

### F2 — Critical：global initializer 不是从 canonical initializer expression 求值，而是 `atoi` + 32-bit 裸写

`as_bytecode_codegen.cpp:2647-2658` 当前对 integer global：

```cpp
int* memory = static_cast<int*>(prop->GetAddressOfValue());
*memory = atoi(child->defaultArg.AddressOf());
prop->isPureConstant = true;
```

这不是 Sema/constant evaluator，也不是 Bytecode initializer lowering。它会产生直接的静默错误：

- `const int G = 40 + 1` 会被 `atoi` 解析成 `40`；
- `const int G = 0x29` 会被解析成 `0`；
- enum constant、cast、named constant、unary/binary expression、call 均不会按 AngelScript 语义求值；
- `int64`/`uint64` 也满足 integer-type 条件，却仍只经 `int*` 写低 32 bit；
- 不论 overflow、signedness、endianness、alignment、storage type 和 initializer side effect，都直接标记 `isPureConstant=true`。

现有 production test `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp:264-297` 只覆盖 `const int G = 41`，恰好让 `atoi` 看起来正确；global-only test 也仍是单个 decimal int literal。

这正是 canonical typed AST 设计应避免的 backend 重解释 syntax residue。Sema 应保存 exact initializer expression/constant value/conversion/initialization plan；CodeGen 只能消费该事实。未实现的 initializer 必须整模块 fail-closed，不能读取 `defaultArg` 文本猜语义。

### F3 — Critical：generated accessor 与 list factory 把 `int` fixture 的 4-byte ABI 硬编码成通用实现

`EmitGeneratedAccessor()`（`as_bytecode_codegen.cpp:551-609`）对任意 property：

- getter 固定 `AllocDwords(1)`；
- 固定 `RDR4`；
- 固定 `LoadReturn(..., 1)`；
- setter 固定 `WRTV4`。

它没有检查 property type、size、handle/reference/object ownership、copy/assign behaviour 或 return ABI。当前 test `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp:993-1068` 只有 `int Value`，因此没有暴露 double/int64/handle/value-object property 的错误。

`EmitListFactoryInto()`（`as_bytecode_codegen.cpp:1297-1354`）同样固定：

- `bufferSize = 4 + 4 * count`；
- 第一个 element offset 为 4；
- 每个 element `WRTV4`；
- 每次 `offset += 4`。

它没有从 list pattern/type metadata 读取 element size/alignment、repeat/named pattern、handle/object construction/destruction。当前 test `:1153-1238` 恰好只注册 `{repeat int}`。

因此这些不是“已支持 generated accessor/list factory”，而是“已支持 int accessor 和 repeat-int list factory”。若保留泛化函数名和宽 preflight，它们会对 64-bit、handle、object 参数生成可执行但错误的 Bytecode。

在通用 lowering 完成前，至少应在全模块 mutation 前把 support gate 精确限制为当前证明过的 shape；更好的方案是让 Sema/type bridge 提供 exact ABI/storage/copy/cleanup plan，emitter 按 plan 生成并由 differential tests 覆盖 1/2/4/8-byte、handle、ref、value object 和失败回滚。

### F4 — Critical：多个 lambda 捕获同一外部变量时，第二个 lambda 会丢失 capture；capture 语义还由 backend 重新发明

当前 capture collector 位于 `as_bytecode_codegen.cpp:59-155`，CodeGen 自己递归遍历 expression/statement graph，寻找 enclosing local/param 的 `DECL_REF`。这已经违反 change 的核心边界：capture set、capture mode、closure storage、lifetime/cleanup 应由 Sema 显式记录，backend 不应再次做 semantic discovery。

此外还存在一个确定的实现 bug：

1. 整个 module 的所有 lambda 共用一个 `captureDecls` 数组（`2667-2668`）；
2. `AddUniqueCapture()` 从 index 0 扫描整个数组做去重（`86-99`）；
3. 每个 lambda 先记录 `captureBegin = captureDecls.GetLength()`，再调用 collector，最后用新增长度计算本 lambda 的 `captureCount`（`2781-2786`）。

若两个 lambda 都捕获外部 `X`：第一个把 `X` 加入数组；第二个 collector 看到全局已有 `X` 就不再添加，因此第二个 lambda 的 `captureCount == 0`。其 body 后续找不到 hidden capture slot，或绑定到错误参数。

当前 capturing production test `:1458-1506` 只有一个 lambda，无法发现该问题。hidden captures 还被统一追加为 `asTM_NONE` value parameters（`2787-2815`），没有按 by-value/by-ref/handle/this、mutation、nested escape、closure lifetime 和 cleanup 处理。

建议先把 capture plan 放回 Sema/canonical AST：每个 lambda 独立记录 ordered captures、source decl、capture mode、closure field type/layout、init/copy/move/destroy 和 escape semantics。CodeGen 只消费该 plan。短期 bugfix 至少必须把 uniqueness 限制在 `[captureBegin, end)`，并增加两个 sibling lambda 捕获同一变量、不同变量、nested lambda、mutating capture、handle/value object capture 和 stored escaping closure tests。

### F5 — Critical：默认 LEGACY pipeline 的 lambda node-layout regression 仍然存在

默认 pipeline 仍是 LEGACY，因此这不是只影响未来 canonical backend 的问题。

`as_parser.cpp:1722-1807` 当前生成：

```text
snFunction
├── snIdentifier("function")
├── snParameterList
│   └── parameter type/mod/name ...
└── snStatementBlock
```

但 `as_compiler.cpp:11521-11570` 的 `ImplicitConvLambdaToFunc()` 仍从 `exprNode->firstChild` 开始只扫描 `snFunction` 的直接 children，直到 `snStatementBlock`。它会：

- 把 `snIdentifier("function")` 计成参数；
- 不进入 `snParameterList`；
- 看不到真实 parameter type/inout/name；
- 将同一不兼容 shape 传给 `RegisterLambda()`。

零参数 lambda 会被错算为一个参数；单参数可能数量偶合但跳过类型检查；多参数通常数量错误。当前 `Compiler 398/398` 不构成反证，因为没有覆盖默认 LEGACY 的 lambda→funcdef compile+execute compatibility matrix。tasks 自己也写明 F4 legacy lambda 尚未完成。

应优先用一个集中 adapter 同时支持 migration 期间的 old/new layout，或在 LEGACY 时保留旧 producer shape；补 0/1/N 参数、typed/ref/in/out/inout、global/function/member owner、compatible/incompatible funcdef 和 teardown tests。

### F6 — Blocking：CodeGen transaction 覆盖面随功能扩大而变得更不完整

`asSBytecodeCodeGenArtifact` 名义上有 functions/globals/funcdefs/types，但当前仍不是 detached artifact：

- types 在 `RegisterCanonicalScriptTypes()` 中直接写入 Engine/module（`2403-2406`）；
- globals 由 `module->AllocateGlobalProperty()` 直接分配，且实际记录在独立 local `globals` 数组，`artifact.globals` 根本没有承载它们；
- imports 通过 `module->AddImportedFunction()` 直接写入 module（`2717-2725`）；
- functions 先取 live Engine ID，并在 emission 前 `engine->AddScriptFunction()`（`2764-2777`）；
- constructor/destructor/method tables 在 emission 前已经由 `FillFunctionSignature()` 修改；
- `Abandon()` 只删除 functions/globals，随后只是把 `funcdefs/types` 数组清零（`2497-2530`），没有从 Engine/module 注销 type，没有撤销 import，没有从 object behaviour/method table 删除 function id；
- `Commit()` 只是把 functions push 到 module lists，随后清空 arrays（`2532-2554`）。

因此后续某个 function emission 失败时，前面注册的 type/import/method behaviour 仍可能残留；若脚本 class 同名复用了 host type，外层 `InternalReset()` 也无法可靠恢复被污染的 host type。`Generate()` 的 isolated no-mutation-on-failure contract 明确不成立。

外层 `asCModule::Build()` failure 时调用 `InternalReset()` 是一层兜底，不等价于 9.1/13.6 所要求的 detached artifact + atomic install，也不能服务 Cache restore、CompileFunction 或未来其他 caller。

需要 module-level artifact 描述 types/globals/imports/funcdefs/functions/layout/init/relocations/dependencies，完整验证后再一次性安装；或提供覆盖所有 live tables、IDs、free lists、refs、behaviours、publisher 的完整 transaction journal，并对每一个 failure injection point 比较 before/after Engine/module state。

### F7 — Blocking：Sema action 数量增加了，但 graph 仍包含大量猜测类型和 unresolved-success

最新 `170/170` 是有价值的 action-shape 进展，但源码仍显示 Sema 没有形成完整 semantic authority：

- unresolved call 默认返回 `int` 并创建 CALL（`as_sema_expr.cpp:474-537`）；callee 无效时不一定 fail；
- assignment 的 fallback type 固定 `int`（`554-571`）；
- unresolved member 固定为 `int` member ref（`574-582`）；
- index 初始类型固定 `int`（`585-612`）；
- unary fallback 固定 `int`（`615-650`）；
- init-list 自身被构造成 `int`-typed `list-pattern`（`653-673`）；
- binary fallback 固定返回 `int`（`761-821`），没有完整 primitive promotion/common-type/operator rules；
- conditional 只取 then type，并在 type id 不同时把 else 强转到 then type（`714-744`），不是完整 common-type resolution；
- 空 type text 回退为 `int`（`as_sema_decl.cpp:328-330`）；
- lambda 无 explicit type 时 return type 固定 `int`，复用已有 lambda 时 DeclRef type 也固定 `int`（`1007-1045`）；
- 当前三个 Sema 源文件仍合计包含大量 `FromNode` 路径，`ActOnParsed*`/`WalkOne()` 仍把 `asCScriptNode` 当主要 semantic extraction input。

这会形成一种危险假象：graph 是 sealed/typed 的，但不少 type 只是 placeholder `int`；CodeGen 随后基于这些“已解析类型”生成真实 runtime layout/ABI。对未来 LLVM backend 同样不可接受，因为 LLVM lowering 需要 exact signedness/width/reference/value category/callee/cleanup，而不是默认 int。

建议把错误/未解析状态显式化，required semantic fact 缺失就不能 seal/publication；逐步用真正 scope/symbol/overload/conversion/lifetime/control environment 替代 `FindExistingExpr(kind, range)` 与 FromNode replay。测试应验证 exact semantic decisions，而不只验证 action 能创建某个 kind。

### F8 — Blocking：Verifier 仍允许缺失 required target、错误 transfer target 和 expression graph 缺陷；2.8/13.5 不能 closed

`as_ast_verifier.cpp` 自 2026-08-21 20:23 后未修改。当前：

- break/continue 只有在 `target.IsValid()` 时才检查（`265-289`），required target 缺失会通过；
- 只检查 target 是某个合法 ancestor，不检查 nearest legal target；
- fallthrough 只要求 owner 和某个 switch ancestor（`324-365`），没有完整 case/next-case/last-case/nearest-switch 语义；
- expression 没有 ownership/multi-owner/reachability/cycle traversal；
- CALL/CONSTRUCT 没有 required `resolvedDecl` 规则；
- CLEANUP 仅在 `resolvedDecl` 已存在时检查 destructor kind（`416-425`），缺失 destructor target会通过；
- 没有完整 signature compatibility、stable reference、dependency、sequencing、live-only reverse cleanup plan 验证。

这与 change spec `as-canonical-typed-ast/spec.md:97-106` 明确要求 verifier 拒绝 unresolved required stable target 冲突。`tasks.md:45-47` 一处写“Hard no: CALL/CONSTRUCT missing callee”，`tasks.md:301-303` 又把 13.5 勾选并写“CALL-without-callee not required”；这是 record 内部自相矛盾，也是 `12.6` 不能 closed 的直接证据。

### F9 — Blocking：Cache V2 AST sidecar 仍不是 AST body DTO，body/profile edit 仍可能错误 reuse

相关源码自第五轮后未变化：

- UE wrapper `AngelscriptCacheASTBodySidecar.cpp:39-72` 只检查 `CanonicalAstBytes` 非空，随后完全不读取这些 bytes，而是创建一个空 TranslationUnit 再 encode；
- `as_ast_sidecar.cpp:170-224` decode 只重建 declaration skeleton，没有 source/range/type graph/stmt/expr/body/resolved refs/cleanup；
- named type 全部按 `VALUE_OBJECT` 重建，失败退成 `int`；
- `asCASTCollectFunctionRecords()` 明确忽略 profile（`271-274`），content material 只有 key/type/quals/traits/origin/defaultArg/dependencies，不含 body/source/expr/literal/cleanup（`283-301`）。

pure body edit 或 profile edit 因此可能得到相同 record hash并错误复用；ExactStartup 也不可能无 Parser/Sema 恢复 complete verified module AST。任务 `6.7` 与 `13.9` 不能靠现有 round-trip envelope tests关闭。

### F10 — Blocking：snapshot/public ABI/CompileFunction 的既有 production contract 问题没有变化

#### Snapshot publication

`as_module.cpp:2050-2061` 的 Acquire 仍是 raw pointer check 后再 `AddRef()`，与 publish 没有共同 lock/atomic-retain protocol；publication 可在两步之间释放最后一个 reference。

`PublishCanonicalASTSnapshot()`（`2107-2161`）仍先把 previous 标成 non-current、清空并 release，再 seal/allocate candidate。candidate 失败时 last-good 已丢失；没有 context 时还会制造空 TranslationUnit snapshot。

CANONICAL Build 仍在 `PublishCanonicalASTSnapshot()` 后才 `ResetGlobalVars()`（`as_module.cpp:437-444`），并且已先 `BuildCompleted()`。global init 失败时，Build 返回失败但新 snapshot 已 current，且 build transaction 已结束。

#### Public ABI

`Core/angelscript.h:1057-1061` 仍把三个 AST virtual methods插在 `CompileFunction()` 与 `SetAccessMask()` 之间，移动后续 vtable slots；`as_ast_public_view.cpp:64-142` 仍不读取 caller `structSize/apiVersion`，而是写完整当前 struct并覆盖 header；ID 仍没有 snapshot/domain cookie。

#### CompileFunction

`as_module.cpp:1946-1997` 的 public `CompileFunction()` 仍直接使用 `asCBuilder::CompileFunction()`，没有 CANONICAL branch；追加 function 也不更新/失效 retained complete module snapshot。当前 module Build 与 CompileFunction 仍是混合 authority。

任务 `3.5`、`3.6`、`13.7`、`13.8`、`13.11` 和相关 section 10 继续是 release blocker。

### F11 — High：namespace、SourceManager 和 stable identity 的旧缺口仍在

- `RegisterCanonicalScriptTypes()` 和 global scan只处理 TranslationUnit 直接 children；namespace 中的 class/global 没有同等 install path；function 虽按全 decl scan收集，runtime `nameSpace` 仍固定为 `module->defaultNamespace`，因此 nested namespace ownership 不完整；
- `as_source_manager.cpp:192-204` 的 `RemapLogical()` 只按 logical key + origin 返回已有 file，不比较新 bytes、byteCount、lineOffset/content hash；相同 logical source 更新可能复用 stale source identity；
- StaticJIT runtime↔AST identity 对 non-lambda 已有明显进步，但 lambda 仍需完整 enclosing owner + exact stable identity；本轮新增 CodeGen capture 的 module-global去重也再次说明 lambda identity/closure semantics 尚未成为 canonical fact。

这些问题不是当前第一修复顺序，但会阻断 Cache、Hot Reload、StaticJIT 和未来 LLVM backend 的可靠复用。

### F12 — Minor：library code 仍直接 `printf` canonical failure

`as_module.cpp:404` 与 `421` 在通过 Engine message callback 报错之外，还直接写 process stdout。嵌入式 runtime/UE commandlet/测试宿主不应由 compiler library擅自向 stdout 打印；应统一走 message callback/diagnostic sink，并在测试中断言 stable source-located diagnostic。

## 对最新测试绿灯的解释

| 保存证据 | 当前值 | 能证明什么 | 不能证明什么 |
| --- | ---: | --- | --- |
| `wave-b-overload-id` / ProductionCodeGen | `25/25` | 当前 25 个命名切片经 CANONICAL module Build 可完成预期行为 | full-language、通用 ABI/layout、failure atomicity、legacy lambda |
| `d95-capture-cutover` / Cutover | `5/5` | 当前 helper 定义下 publisher/route 仍自洽 | 真实 Hot Reload/commandlet/Standalone/generation entry |
| `wave-b-decl-sema` | `170/170` | 独立 Sema actions 和对应 dumps持续增加 | 不使用 FromNode、exact type system、complete capture/lifetime/control semantics |
| `wave-b-decl-canonical` | `210/210` | CanonicalAST prefix在最新 Sema 源码后全绿 | verifier spec 已完整、public/cache snapshot 安全 |
| `wave-b-decl-compiler` | `398/398`，含 1 warning | 最新 Compiler prefix没有失败，legacy兼容面总体稳定 | 缺失的 default-LEGACY lambda→funcdef fixture不会被不存在的测试证明 |

当前 production tests 是很好的 vertical-slice资产，但有明显 fixture concentration：global/accessor/list factory/capture 主要围绕 decimal `int` 和单 lambda。因此绿灯和本轮静态 finding 可以同时成立，并不矛盾。

## OpenSpec task 复核

### 可以继续保留 closed

- arena/seal 基础边界与 const traversal 对应的 `13.4`；
- R11 funcdef/lambda teardown crash 修复；
- module Build opt-in CANONICAL route 的最小存在性；
- positive CodeGen error 映射修复；
- non-lambda stable signature matching 的局部进展；
- 已落地的独立 Sema action tests和 narrow CodeGen vertical slices，作为子进展记录。

### 至少必须重新打开

- `2.8`：Verifier不满足任务/spec列出的完整 firewall；
- `3.5`：当前协议不能保证 acquire race和 failed candidate保留 generation A；
- `3.6`：publication/lease/current-generation不是原子集成；
- `12.6`：spec/task仍矛盾，且存在 false-complete items；
- `13.5`：required callee/target/cleanup、expr ownership/cycle等明确缺失。

### 强烈建议按原文重新打开或缩窄

- `6.7`：current sidecar tests不证明 body fidelity、body/profile hash、ExactStartup；
- `7.6`：generation仍需要真正 snapshot lease/freshness protocol；
- `8.4`：真实 project source graph/queue freeze/owned-output-only orchestration不能由同进程 helper替代。

### 必须保持 open

- `9.1`、`9.5`、`9.6`、`9.7`；
- section 10 尚未闭环的 cutover/removal tasks；
- `13.1`、`13.2`、`13.3`、`13.6`–`13.12`。

## 建议修复顺序

```text
1. 立即冻结“按 int fixture 泛化”的新增 surface
   ├─ class/ref-vs-value/layout/namespace/host collision
   ├─ global initializer exact semantic plan
   ├─ accessor/list factory exact ABI gate
   └─ multi-lambda capture correctness
        ↓
2. 修复默认 LEGACY lambda producer/consumer compatibility
        ↓
3. 让 Sema graph 成为真正语义权威
   ├─ unresolved 不得默认 int 后 seal
   ├─ exact call/type/conversion/capture/lifetime/control
   └─ backend 不再扫描 AST 发明 capture/initializer 语义
        ↓
4. Detached module artifact + atomic Engine/module activation
   ├─ type/global/import/funcdef/function/layout/init
   └─ complete failure-injection no-mutation matrix
        ↓
5. Verifier adversarial firewall
        ↓
6. Snapshot candidate-first atomic lease + append-only public ABI
        ↓
7. Cache V2 complete pointer-free DTO + source/profile/body identity
        ↓
8. CompileFunction 与真实 HotReload/generation/commandlet/Standalone entry
        ↓
9. focused differential → Standalone Debug/Release → All
        ↓
10. 只有此后才讨论 default CANONICAL、删除 legacy consumer、archive
```

修复策略不要求推倒当前 canonical AST worktree。应保留现有 vertical slices 和 action tests，但先收紧 support gate、修正 semantic/type/transaction boundary，再继续扩语言宽度。

## 最终判定

第六轮最重要的判断是：

> **实现宽度显著增长，但安全性和语义完整性没有按相同速度增长。当前主要风险已从“漏实现”转为“窄 fixture 的实现被当作通用 compiler 语义”。**

CANONICAL module Build → sealed AST → CodeGen → executable Bytecode 的链路已经确立；这部分方向和资产应保留。`25/25`、`170/170`、`210/210`、`398/398` 都是真实进展。

然而 class flags/layout、global initializer、accessor/list ABI、capture plan和 transaction rollback 中存在可静默产出错误 runtime state 的路径；Verifier、Cache、snapshot、公有 ABI、CompileFunction、SourceManager 等旧 blocker 也没有消失。只增加更多 production fixture 数量不能关闭这些 contract。

因此本轮仍给出：

> **Request changes — do not archive, do not switch the default, do not treat `Ready=true`、`25/25` 或 `56/105` as production readiness.**

