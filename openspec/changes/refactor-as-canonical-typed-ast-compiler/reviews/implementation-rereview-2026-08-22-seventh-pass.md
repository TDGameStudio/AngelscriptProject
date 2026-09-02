# Canonical Typed AST Compiler 第七轮实现复审 — 2026-08-22

## 复审结论

当前实现仍为 **Request changes**。不能归档，不能把 CANONICAL 切成默认，也不能把 `Ready()==true`、ProductionCodeGen `33/33`、CanonicalAST `250/250` 或 OpenSpec checklist `56/105` 解读为完整 compiler ready。

但第七轮并不是重复第六轮结论。从第六轮快照到本轮，以下具体问题已经真实推进或关闭：

- script `class` 与 `struct` 不再统一注册成 value object：class 现在使用 `asOBJ_REF | asOBJ_IMPLICIT_HANDLE`，struct 使用 `asOBJ_VALUE | asOBJ_NOINHERIT`；
- global `40 + 1` 与 `0x29` 已不再直接由 CodeGen `atoi()` 源码文本，Sema 增加了整数常量求值，CodeGen 会按 1/2/4/8-byte storage 写入；
- generated accessor 与 repeat-list factory 已覆盖 8-byte `int64`/`double`，不再一律使用 `RDR4/WRTV4`；
- sibling lambda 捕获同一个外部变量时的 module-global 去重 bug 已修复，CodeGen 开始消费 Sema 写入的 per-lambda capture 列表；
- 默认 LEGACY lambda 的 parameter-list 消费协议已修复，并有 0/1 参数 build+execute `2/2` 保存结果；
- Parser 在函数名后创建 declaration、参数完成时逐个 intern 的增量路径，刚在 13:02 修复了 overload/in-flight identity；随后 enumerator incremental action 也落地。最新保存的 Build 成功，SemaAuthority `203/203`、CanonicalAST `251/251` 均为全绿。

因此第六轮 F1–F5 中的**窄而确定的回归**多数已经关闭。不过，实现仍存在一组比“再补几个 opcode”更根本的模块级正确性问题：

1. class/type registration 仍有固定 alignment、静默丢 property、direct-TU-only、裸名 host collision 和提前污染 live registry 的路径；
2. global int64/uint64 常量仍在 Sema 中被 `%d` 截断成 32 bit，generated member default initializer 仍只取表达式中第一个数字并用 `atoi()`；
3. accessor/list helper 把所有大于等于 8 byte 的值都当成恰好 8 byte，handle 只做 raw pointer copy，不执行 AddRef/Release，value object list element 也没有 construction/assignment/destruction；
4. CodeGen 仍在 emission 完成前直接安装 type/import/function/object behaviour/method table，`Abandon()` 无法完整撤销；
5. Sema 仍能把 unresolved call/member/index/unary/binary 等冻结成合法的 `int` placeholder，Verifier 又允许 CALL 没有 callee；
6. Verifier、Cache V2 body DTO、snapshot 原子 lease/public ABI、CompileFunction canonical parity 和 SourceManager content authority 等既有阻断没有实质变化。

当前最准确的定位是：

> **一个真实接入 opt-in module Build、已有较多 vertical slices 的 canonical Bytecode compiler prototype；Parser/Sema 迁移速度很快，但通用类型/lifetime ABI、module transaction 和跨代持久化边界仍未形成可证明正确的 production contract。**

总体方向仍正确，不需要推倒 canonical typed AST。当前应停止把“1/4/8-byte fixture 变绿”直接推广成通用 feature，先把 exact semantic plan、类型/lifetime support gate、原子安装和 verifier firewall 收紧。

## 复审快照与操作边界

- worktree：`D:\as-cta`；
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`；
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`；
- point-in-time：**2026-08-22 13:09:38（Asia/Shanghai）**；
- parent 有 `20` 个 changed/untracked paths，plugin 有 `108` 个 changed/untracked paths；实现仍是 dirty worktree 内容，不等同于两个 HEAD 的已提交源码；
- 最近关键源码时间：`as_sema_decl.cpp` 13:07:45、`as_sema.cpp` 13:07:35、`as_parser.cpp` 12:41:54、`as_bytecode_codegen.cpp` 12:22:47；
- 快照时没有仍在运行的相关 UnrealEditor/build/test 进程；
- reviewer 没有主动运行 build/test，没有修改 plugin 实现，也没有修改 `tasks.md` checkbox；测试数字来自实现者保存在 `D:\as-cta\Saved\Tests` / `Saved\Build` 的报告。

OpenSpec 机械 checklist 仍为：

- checked：`56`；
- open：`49`；
- total：`105`。

`2.8`、`3.5`、`3.6`、`6.7`、`7.6`、`8.4`、`12.6`、`13.5` 至少需要按任务原文重新审计。只重开第六轮已明确不成立的 `2.8/3.5/3.6/12.6/13.5` 是 `51/105`；再按宽任务文字重开 `6.7/7.6/8.4` 是 `48/105`。这只是记录诚实度，不是 production readiness。

## 当前保存验证证据

以下均为实现者运行、reviewer 只读核验：

| 证据 | 结果 | 与本轮源码的关系 |
| --- | ---: | --- |
| `wave-b-enum-green` Build | exit `0` | 包含 13:07 enumerator action 与此前参数 identity 修复 |
| `wave-b-enum-sema` | `203/203 PASS` | 当前 SemaAuthority 前缀全绿 |
| `wave-b-enum-canonical` | `251/251 PASS` | 当前 CanonicalAST 前缀全绿 |
| `wave-b-param-sema2` / `wave-b-param-canonical` | `202/202` / `250/250 PASS` | 直接证明 13:02 参数 intern/constructor overload 回归关闭；随后被 203/251 supersede |
| `wave-b-sema-phases-compiler` | `437/437 PASS` | 早于 13:02 参数 identity 修复；不是 exact-current broad Compiler 证据 |
| `wave-d-f4-prod3` ProductionCodeGen | `33/33 PASS` | 证明 F1–F4 的窄 production slices；早于后续 Parser/Sema 改动 |
| `wave-d-f5-exec` | `2/2 PASS` | 证明默认 LEGACY 0/1 参数 lambda 当前协议可执行 |

本轮中途出现过 `wave-b-param-sema` 的 `200/202`，失败是 constructor overload 与 incomplete later-function identity。13:02 的 `FindExistingFunctionLike()` 改为只按同一个 name-token source offset 复用 in-flight declaration，随后 `202/202` 与 `250/250` 已关闭这两条红测；13:07 的 enumerator action 之后又有 `203/203` 与 `251/251`。因此报告不把那两条短暂红测列成当前 finding。

## 相对第六轮的真实进展

### 已关闭的具体问题

1. **class/struct flag 混淆：关闭。** `as_bytecode_codegen.cpp:2383-2393` 已按 `asAST_TRAIT_VALUE` 区分 struct value 与 class ref/implicit-handle。
2. **global decimal-expression/hex fixture：关闭窄切片。** `as_sema.cpp:472-549` 可求值 literal、unary `+/-`、binary `+/-/*//`、conversion/sequence/assign；`as_bytecode_codegen.cpp:2732-2770` 按整数 storage width 写入。
3. **accessor/list 固定 4 byte：关闭 8-byte 窄切片。** `ValueDwords()` + `RDR8/WRTV8` 支持当前 int64/double fixtures。
4. **sibling lambda capture 全局去重：关闭。** capture uniqueness 已按本 lambda slice 处理，CodeGen 读取 `decl->captures`；保存的 sibling execution fixture为 `33/33` 中一项。
5. **LEGACY lambda 0/1 参数 layout：关闭。** compiler/builder 进入 `snParameterList` 并重算 offsets，保存执行结果 `2/2`。
6. **增量 parameter intern 当前 identity 回归：关闭。** after-name declaration、incremental param、完整 WalkOne 三阶段现在通过 source-range identity 复用同一 declaration；SemaAuthority `202/202`。

### 只关闭了 fixture、没有关闭通用 contract

- global initializer 只证明 32-bit `int` 的少量纯整数表达式；未证明 int64/uint64、overflow、enum/named constant、member initializer 或 runtime initialization；
- accessor/list 只证明 4/8-byte primitive 和 nullptr handle；未证明 non-null handle ownership、value object copy/cleanup 或大于 8 byte 的 storage；
- lambda 只证明当前 capture ID 列表和立即执行；capture mode、closure field layout、copy/move/destroy、escape lifetime 仍未成为完整 Sema plan；
- class flag fixture只证明两个 flags；没有证明 namespace、base/interface、layout、host-name collision、failure rollback。

## Findings（按严重性排序）

### F1 — Critical：canonical script type registration 仍可产生错误 layout、静默丢字段和同名 host type 污染

`RegisterCanonicalScriptTypes()` 位于 `as_bytecode_codegen.cpp:2349-2462`。class-vs-struct flags 已修复，但通用注册协议仍不成立：

- 只遍历 TranslationUnit 的直接 child class（`2365-2370`），nested namespace class 不会进入这条注册路径；
- Engine 中只要存在同裸名 type，就直接 `continue`（`2372-2376`），没有 module/namespace/stable owner identity；
- `st->alignment` 仍固定为 `4`（`2397`）；property offset按各 property alignment前移，但 final size仍按固定 4 收尾（`2440-2455`）；
- property type解析失败或 `AddPropertyToClass()` 失败时静默 `continue`（`2430-2439`），Build 可以成功但 runtime type少字段；
- type在任何 function emission 前就写入 `engine->allRegisteredTypesByName`、`module->classTypes`、`module->allLocalTypes`（`2457-2460`）；
- `FindCanonicalObjectType()` 仍有裸名 Engine fallback（`as_bytecode_codegen.cpp:130-148`）；`FillFunctionSignature()` 随后修改 constructor/destructor/method behaviour tables（约 `2520-2542`）。

这意味着当前可以发生：脚本 type 与 host/其他 module type同名时复用错误 type，然后把 canonical constructor/method id写进其 behaviour table；或含高 alignment property 的 struct获得错误 `sizeof/alignment`；或字段解析失败却仍发布成功。

建议：

- 在 Sema/module artifact 中保存完整 type descriptor：kind、namespace/owner stable key、base/interfaces、flags、property sequence、exact layout requirements；
- 禁止任意 bare-name fallback；同名冲突必须按完整 identity 区分或 fail-closed；
- property/type/layout 任一步失败都在 live mutation 前整模块失败；
- final alignment取所有 base/property requirements的最大值，并复用/抽取 legacy已验证的 layout规则；
- 补 nested namespace、same-name host type、double/int64/value-object property、inheritance/interface、property-resolution failure 和 teardown/no-mutation tests。

### F2 — Critical：global int64/uint64 与 generated member default initializer 仍会静默产生错误值

global 路径已经从 CodeGen `atoi(source text)` 进步为 Sema constant evaluator，但值在跨层传递时仍被截断：

- `EvalIntegerConst()` 使用有符号 `asINT64`，只覆盖有限运算且没有 overflow检查（`as_sema.cpp:472-549`）；
- `ActOnGlobalVarInit()` 最终用 `text.Format("%d", (int)value)` 写入 `defaultArg`（`563-571`），任何超出 32-bit 的 int64/uint64 常量在进入 CodeGen 前已经丢失；
- CodeGen 虽用 `strtoll()` 并按 1/2/4/8 byte写入（`as_bytecode_codegen.cpp:2732-2770`），却无法恢复被 Sema截断的值，也无法表示 `uint64 > INT64_MAX`；
- signed `+/-/*` overflow、`INT64_MIN / -1` 也没有受控诊断。

generated member default 是另一条尚未 canonicalize 的路径：

- `IntegerInitText()` 找到表达式中的第一个 constant node，只截取十进制数字（`as_sema_decl.cpp:410-451`）；`int X = 40 + 1` 会留下 `40`，hex也会被错误切片；
- `FillGeneratedConstructorDefaults()` 再用 `atoi(member->defaultArg)` 创建 integer literal和 assignment（`630-656`）；
- 因此 generated default ctor 可以 Build 成功但产生错误 member value。

建议不要继续扩充字符串协议。canonical Decl 应持有 initializer Expr/typed APInt-like constant/initialization plan；CodeGen按 destination signedness/width执行已验证的 conversion，generated constructor也复用同一 initializer graph。至少增加 int64最大/最小、uint64高位、overflow/除法边界、member `40+1`、hex、named/enum constant 的 execute tests。

### F3 — Critical：accessor/list 把小于 4 byte和大于 8 byte的值都压成错误宽度，raw handle copy也会破坏对象语义

`as_bytecode_codegen.cpp:373-411` 的 `ValueDwords()` 可返回任意 dword 数，但 `EmitReadValue()` / `EmitWriteValue()` 只有两个分支：

- `dwords >= 2`：只发一次 `RDR8/WRTV8`；
- 其他情况：一律发 `RDR4/WRTV4`。

因此错误同时出现在两端：

- `bool/int8/int16` property或 list element会被 4-byte读写，越界覆盖相邻字段/元素；
- 12/16-byte value property或 list element会只复制前 8 byte。

legacy compiler已有按内存 byte width选择 `RDR1/RDR2/RDR4/RDR8`（`as_compiler.cpp:20303-20310`）和 `WRTV1/WRTV2/WRTV4/WRTV8`（`10476-10484`）的规则，canonical helper没有复用。

更严重的是，handle/ref property setter/getter也走 raw `RDR8/WRTV8`：setter没有释放旧 handle、没有 AddRef新 handle；getter也没有执行返回值 ownership语义。当前 handle fixture只把 `nullptr` 写入初始空字段，无法证明 non-null handle替换和 teardown。

list factory 在 `1329-1360` 取得 element type/size后同样直接 `EmitWriteValue()`。对 value object，它没有 default construction、copy/assignment behaviour和失败/退出cleanup。legacy compiler明确在 `as_compiler.cpp:7831-7852` 先调用 value-object constructor，再在 `7862-7875` 经 `DoAssignment()` 和 temporary/deferred cleanup完成赋值；canonical helper没有对应计划。

建议：

- 实现严格按 1/2/4/8-byte width选择 opcode，并给 bool/int8/int16 accessor/list加 execute+邻接内存 canary；在完整通用 lowering 前，>8-byte shape整模块 fail-closed；
- handle/ref使用显式 ownership assignment/return ABI；
- value object通过 Sema冻结的 construct/copy/move/assign/destroy plan生成；
- 增加 12/16-byte struct accessor/list、non-null handle addref/release计数、handle覆盖旧值、value-object ctor/copy/dtor计数和 failure cleanup tests。

### F4 — Critical：CodeGen 仍不是 detached artifact + atomic install，失败可留下 type/import/behaviour/method table mutation

`asSBytecodeCodeGenArtifact` 仍只包住一部分已安装对象：

- type 在 `2457-2460` 直接写入 Engine/module registries；
- object constructor/destructor/method tables在 signature填充时直接修改（约 `2520-2542`）；
- global 通过 `module->AllocateGlobalProperty()` 直接分配（`2728-2731`），实际由独立 local `globals`数组回收，`artifact.globals`不是完整 pending state；
- import 通过 `module->AddImportedFunction()` 直接安装（`2833+`）；
- function在 bytecode emission前取得 live id并调用 `engine->AddScriptFunction()`（`2880-2893`）。

`Abandon()`（`2551-2584`）会删除 artifact functions和部分 globals，但对 `types/funcdefs` 只是清空数组，没有从 registries移除 type，也没有撤销 imports或 object behaviour/method table。`Commit()`（`2586-2608`）又逐项 push module arrays，没有 no-fail atomic exchange。

这仍然违反 9.1/13.6 的 no-partial-state contract。外层 `InternalReset()` 不能等价替代 detached generation；尤其 host type被同名 fallback污染时，module reset未必能恢复外部 type。

需要一个完整 module artifact（types/layouts/globals/imports/funcdefs/functions/bytecode/relocations/init/cleanup/dependencies），先离线验证，再在一个可证明 no-fail 的 activation阶段发布；或者建立覆盖每一个 live table/free-list/ref/behaviour的 transaction journal。必须做每个 failure injection point 的 before/after完整状态比较。

### F5 — Blocking：Sema 仍能把 unresolved semantics 冻结成合法 `int` graph，Verifier不会阻止其发布

当前 Parser action和 incremental intern数量显著增加，但 graph中的“typed”仍不等于“exactly resolved”：

- `ActOnCallExpr()` 在 `ResolveCallee()` 无结果时仍以 `int` 创建 CALL，`resolvedDecl`可以无效（`as_sema_expr.cpp:493-556`）；
- assignment fallback固定 `int`（`665-682`）；
- unresolved member固定 `int`（`685-693`）；
- index先建 `int`，只有找到 `opIndex`才改类型（`696-723`）；
- unary fallback固定 `int`（`726-773`）；
- init-list自身建成 `int`-typed `list-pattern`（`776-796`）；
- binary fallback固定 `int`（`884-944`）；
- CodeGen `TypeOf()` 只在 type bridge返回 invalid时失败；placeholder `int`是 valid，所以不会触发这层防线（`as_bytecode_codegen.cpp:443-451`）。

这会让“seal成功”只证明 graph structurally存在，而不是 callee/type/conversion/lifetime已正确解析。未来 LLVM backend会直接放大同一问题：LLVM lowering需要 exact width/signedness/value category/callee/ABI/cleanup，不允许从 placeholder恢复语义。

应为 unresolved/error type和required target建立显式状态；任何 backend-required fact缺失都不能 seal/publication。逐步移除 `FromNode` replay和按 range/kind复用表达式，让 Sema scope/symbol/overload/conversion/lifetime/control environment成为唯一权威。

### F6 — Blocking：Verifier firewall 没有变化，`2.8/13.5` 仍然 false-complete

`as_ast_verifier.cpp` 自 2026-08-21 20:23 后未修改。当前仍有：

- break/continue 只有 `target.IsValid()` 时才检查；required target缺失会通过（`265-289`）；
- 只验证 target是某个 compatible ancestor，不验证 nearest legal target；
- fallthrough只验证 owner和某个 switch ancestor，不完整验证 case、next-case、last-case和 nearest-switch关系（`324-365`）；
- expression没有 complete ownership/reachability/cycle graph验证；
- CALL/CONSTRUCT没有 required `resolvedDecl`；
- CLEANUP只在 `resolvedDecl` 已存在时检查 destructor kind（`416-425`），缺失 destructor仍通过；
- 没有完整 signature compatibility、stable reference、dependency、sequencing和 live-only reverse cleanup plan验证。

`tasks.md:47` 写 CALL/CONSTRUCT missing callee是“Hard no”，`tasks.md:303` 又写“CALL-without-callee not required”，与 capability spec要求拒绝 unresolved required stable target冲突。`2.8`、`13.5` 和声称已完成 reconciliation 的 `12.6` 不能继续保持当前表述。

### F7 — Blocking：Cache V2 AST sidecar仍不是完整 body DTO，body/profile edit仍可能错误复用

相关核心文件在第六轮后未改变：

- `as_ast_sidecar.cpp` encode/decode仍主要是 dump文本和 declaration skeleton，没有完整 source/type/body/stmt/expr/resolved ref/dependency/cleanup graph；
- decode把 named type按 value object方式重建，并有 int fallback；
- function record content仍不完整覆盖 body/source/profile语义；
- UE wrapper `AngelscriptCacheASTBodySidecar.cpp` 仍没有把传入 `CanonicalAstBytes` 作为完整 canonical graph重建输入，而是处理空/浅 context envelope。

因此 ExactStartup不能在不跑 Parser/Sema时恢复一份 complete verified AST，body-only/profile-only变化也没有可靠的 content identity。`6.7`/`13.9` 不能由 envelope round-trip或旧 FunctionBody cache tests代表关闭。

### F8 — Blocking：snapshot publication/public ABI/CompileFunction 仍保留既有并发、兼容性和 authority 问题

这组文件在本轮没有实质修改：

- `AcquireASTSnapshot()` 先读取 raw `astSnapshot` 再 `AddRef()`（`as_module.cpp:2050-2061`），与 publication没有共同 atomic-retain协议；
- `PublishCanonicalASTSnapshot()` 在 candidate seal/allocation成功前先把 previous标为非当前并 release（`2107-2115`）；后续失败会丢 last-good；
- 没有 pending context时仍会制造空 TranslationUnit snapshot（`2139-2147`）；
- `currentGeneration` 仍是普通 `bool`（`as_ast_public_view.h:27-35`）；
- public `CompileFunction()` 仍调用 legacy `funcBuilder.CompileFunction()`（`as_module.cpp:1946-1995`），可添加 executable function却不建立对应 canonical completeness/publication；
- AST methods仍插入 `asIScriptModule` mid-vtable（`angelscript.h:1057-1063`）；
- `GetDecl/GetStmt/GetExpr/GetType` 覆盖整份 output struct，不读取 caller提供的 `structSize/apiVersion`（`as_ast_public_view.cpp:64-142`）；小版本 caller可能被越界写，foreign snapshot同 index ID也缺少 domain校验。

应先生成/验证 candidate，随后用 atomic exchange + retain协议发布并在成功后释放 previous；public AST应迁到 queryable extension/append-only ABI，尊重 caller capacity/version并给 ID snapshot/domain identity。CompileFunction要么 canonicalize并更新 snapshot，要么显式修改 OpenSpec、隔离为不进入 canonical completeness contract 的能力，不能继续让测试把混合 authority当最终行为。

### F9 — Important：SourceManager仍按 logical key/origin复用旧 file，稳定 owner/type identity 仍不完整

`as_source_manager.cpp:192-204` 的 `RemapLogical()` 发现相同 logical key/origin就直接返回旧 file id，不比较 bytes、byte count、line offset或content identity。变更后的源码可能继续携带旧 source mapping。

同时，runtime type lookup仍存在 bare-name fallback，qualified/nested owner与 lambda/closure identity也尚未形成完整跨 Cache/Hot Reload/backend稳定协议。这会影响 diagnostics、record hash、runtime-to-AST mapping和 future LLVM object cache key。应统一采用 content-aware SourceManager和包含 module/namespace/type/function/signature/source identity 的稳定 key。

### F10 — Important：参数 action 当前按“同 owner + 同名字”去重，会吞掉真正的 duplicate-param declaration和诊断

13:02 的 in-flight function identity修复是正确进展，但 `ActOnStartParamDecl()`（`as_sema.cpp:395-411`）为了防止 incremental action与完整 syntax walk重复建 Param，会在 owner下找到同名参数后直接返回已有 id。它没有比较 source range或 parser action identity。

这会把两种情况混为一谈：

- 同一个参数被 incremental action和 WalkOne replay两次：应该复用；
- 源码真实写了两个同名参数：应该保留第二个 invalid declaration并触发 `ActOnParamDecl()` 的 `duplicate-param:<name>` 诊断。

当前 name-only fast return让第二种情况也直接复用第一个 Param，绕过 `ActOnParamDecl()` 在 `369-392` 的 duplicate诊断路径。建议只对 same owner + same source range/token identity的 replay去重，并增加 successful replay、真正重名参数、匿名参数和同名不同 overload的测试。

## 对“整体完成度”的判断

若沿用此前“架构资产是否已经建立”的尺度，当前仍在约 **50%**：arena/context、dump、大量 tests、opt-in Build route和若干 Sema/CodeGen vertical slices已经形成。

若衡量用户真正关心的“是否可以替换现有 compiler并安全成为默认”，当前约 **35%–40%**。下降感不是代码倒退，而是第六/七轮把此前被窄 fixture掩盖的通用 ABI、transaction、Cache/snapshot/public ABI问题计入了剩余工作。剩余项比继续增加 statement/expression action更难，也更决定 production安全性。

建议后续统一报告两个数字，避免混淆：

- mechanical checklist：`56/105 = 53.3%`，但有 false-complete；
- production cutover readiness：约 `35%–40%`。

## 建议修复顺序

1. **立即收紧 support gate**：对 >8-byte value、non-null handle ownership、value-object list、无法解析 property/type/layout 先整模块 fail-closed，避免 silent corruption。
2. **统一 initializer semantics**：global/member/generated ctor 都消费 typed constant/initializer Expr，不再经 `defaultArg` 字符串和 `atoi`。
3. **完成 type/module artifact transaction**：类型、imports、globals、functions、behaviours在完整验证后一次性 activation；补 failure injection no-mutation matrix。
4. **让 Sema exact且 fail-closed**：移除 unresolved→int；callee/conversion/capture/lifetime/control/init plan成为 sealed graph required facts。
5. **完成 Verifier firewall**：required targets、expr ownership/cycles、nearest control、signature/stable refs、cleanup sequencing。
6. **再闭环 snapshot/public ABI/Cache DTO/SourceManager/CompileFunction**。
7. **最后扩大完整语言面并切默认**：stored closures、containers/templates、exception/debug/coverage/timeout、真实 Hot Reload/generation/commandlet/Standalone和 final All。

## Ready to merge?

**No.**

方向正确，局部实现进展明显，参数 intern与第六轮多条具体回归已经关闭；但目前仍有会导致“Build成功却值/layout/lifetime错误”或“失败后残留 live mutation”的 Critical 路径。默认必须继续 LEGACY，当前 OpenSpec change不能归档。
