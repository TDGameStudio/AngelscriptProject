# Canonical Typed AST Compiler 第二轮实现复审 — 2026-08-21

## 复审结论

当前实现仍为 **Request changes**。

它已经从第一轮复审时“用 CANONICAL 名称包装旧 `asCCompiler`，并把未完成任务标成完成”的危险状态，修正为一个更诚实、也更有用的 **shadow/capture 编译器迁移平台**。这一点是实质进展：

- 默认 pipeline 已恢复为 `LEGACY`；
- `IsCanonicalBytecodeCodeGenReady()` 返回 `false`；
- module 记录实际 Bytecode publisher，Cutover 测试确认当前 production Bytecode 来自 `asCCompiler`；
- OpenSpec 已从第一轮的 `90/93` 虚高状态重开为 `51/105`，并新增 13.1–13.12 复审门禁；
- declaration stable key 已加入参数类型，StaticJIT 绑定不再直接取第一个同名函数；
- `asCASTContext` 已改用 block arena，sealed 后 mutable node getter 会拒绝访问；
- Sema、verifier、CodeGen 和相应测试继续扩展。

但是，完整 OpenSpec 的目标仍未完成：

```text
当前真实生产路径

source
  -> legacy Parser builds asCScriptNode
  -> canonical Sema walks asCScriptNode as a shadow graph
  -> legacy Builder + asCCompiler publishes production Bytecode
  -> canonical CodeGen is an isolated subset prototype
```

目标路径仍然是：

```text
source
  -> Parser actions + authoritative Sema
  -> complete, verified, sealed canonical typed AST
  -> canonical Bytecode / TypedASTJIT / future LLVM consumers
```

本轮还发现一个新的最高优先级阻塞：最新构建中的 Canonical CodeGen funcdef/lambda 测试能够执行出正确值，但随后销毁测试 Engine 时稳定发生访问违规。这证明当前 subset CodeGen 的函数类型/函数句柄/lambda 所有权还不安全，不能接入 production `Build()`。

## 复审快照和验证环境

复审目标：

- worktree：`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`；
- 短路径：`D:\as-cta`；
- branch：`refactor-as-canonical-typed-ast-compiler`；
- plugin submodule：`Plugins/Angelscript`；
- Engine：worktree `AgentConfig.ini` 指向 UE 5.8；
- 复审快照时间：2026-08-21 13:55（Asia/Shanghai）。

注意：本轮复审期间该 worktree 仍有另一个实现进程修改源码并运行测试。复审先吸收其 13:51 Runtime DLL、13:52 CanonicalAST 结果和 13:54 Compiler 结果，再以 13:55 为最终 point-in-time 证据。更早一次使用旧 DLL 的 `asCASTDump` 崩溃不计入最终结论；下面列出的 funcdef/lambda 崩溃已在 13:51 最新 DLL 上再次复现。

OpenSpec 当前 checklist：

- total：`105`；
- checked：`51`；
- unchecked：`54`；
- 13.1–13.12：全部未完成。

`51/105 = 48.6%` 只是未加权任务计数，不能解释为 production cutover 已完成 48.6%。更准确的分层判断是：

| 层次 | 当前状态 |
| --- | --- |
| 迁移 scaffold、dump、测试和隔离原型 | 已有较大规模，约 60–70% |
| Sema 语义覆盖原型 | 有明显进展，最新 CanonicalAST 32/32；但仍是 `asCScriptNode` 后置转换 |
| production compiler authority/cutover | 未完成；`Build()` 仍由 `asCCompiler` 发布 Bytecode |
| Cache/Public ABI/Snapshot 并发等交付闭环 | 多项仍是 placeholder 或不安全原型 |
| 完整 OpenSpec 的总体完成度 | 粗略约 40–50%，不可归档，不可宣布切换完成 |

## 新鲜验证结果

### Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools\RunBuild.ps1 `
  -Label canonical-ast-rereview-build-20260821 `
  -TimeoutMs 1800000 -NoXGE
```

结果：`Succeeded`，UBT 判定 target up to date。此时 Runtime/Test DLL 的时间为 13:46，晚于本轮最终纳入的 13:44–13:45 Runtime/Test 源码批次。

### CanonicalAST / SemaAuthority

实现进程运行：

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" `
  -Label goal-wave-b-gaps-green2 `
  -TimeoutMs 600000
```

中间结果：`15/17 PASS`，`2 FAIL`，`0 skipped`。

失败：

1. `BreakTargetsNearestSwitchNotOuterLoop`
   - `Module->Build()` 返回成功；
   - `GetCanonicalASTContext()` 返回 null；
   - 说明该控制流图未能形成可发布的 sealed snapshot，测试报告 `retain policy must keep a canonical AST`。
2. `PropertyReadWriteRewritesToAccessors`
   - dump 中 getter 已成为 `callee=T::GetValue()`；
   - setter `T::SetValue(int)` 没有出现在图中；
   - 当前 property rewrite 只完成读路径，没有完成赋值路径。

实现进程随后修改 `as_sema_expr.cpp`、`as_sema_stmt.cpp` 和对应 fixture，并运行：

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" `
  -Label goal-canonical-ast-wave-b `
  -TimeoutMs 600000
```

最新结果：`32/32 PASS`，`0 failed`，`0 skipped`。这包含上述 SemaAuthority fixtures，说明 nested switch break publication 与 property setter rewrite 的直接测试已修绿。

随后完整 Compiler prefix `goal-wave-b-compiler` 为 `220/220 PASS`；TypedASTJIT canonical migration prefix `goal-jit-identity-reject` 为 `8/8 PASS`。

通过项覆盖基础 exact overload、构造函数重载、namespace overload、operator overload、int/float conversion node、named/default arguments、mixin、multiple lambda stable keys、temporary materialize/cleanup、control target 等。这些是有效的 shadow-Sema 进展，但仍不是 production authority 证据：这些 fixture 验证 dump/attach 和 legacy-compatible execution，production Bytecode 仍由 `asCCompiler` 产生。

### Canonical CodeGen funcdef/lambda crash

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.FCanonicalASTCodeGenTests.CodeGenEmitsFuncdefCallAndLambda" `
  -Label canonical-ast-rereview-funcdef-final-20260821 `
  -TimeoutMs 600000
```

结果：进程退出 `1`；测试主体能计算出 `Invoke(Double,3)+L(4) == 11`，但在 test scope 退出、`Engine.Destroy()` 执行期间崩溃：

```text
EXCEPTION_ACCESS_VIOLATION reading address 0xffffffffffffffff
asCObjectType::ReleaseAllFunctions() ... as_objecttype.cpp:723
asCScriptEngine::~asCScriptEngine() ... as_scriptengine.cpp:987
asCScriptEngine::ShutDownAndRelease()
FCanonicalASTCodeGenTests::CodeGenEmitsFuncdefCallAndLambda() ... :753
```

该问题已在 13:51 最新 Runtime DLL 上稳定复现。此前三次复现也分别落在 `funcDefs[n]->ReleaseInternal()`、`functionBehaviours.ReleaseAllFunctions()` 和相邻 Engine teardown 路径，因此应按 funcdef/function-handle/lambda 引用或所有权破坏调查，而不是当作普通 assertion failure。

## 第一轮 R01–R10 处理矩阵

| ID | 第一轮问题 | 第二轮状态 | 决定 |
| --- | --- | --- | --- |
| R01 | CANONICAL 名称虚假宣称 production CodeGen | 默认 LEGACY、Ready false、publisher provenance 已修；production cutover 仍未发生 | **部分解决；cutover Blocking 保留** |
| R02 | Sema 只是 syntax conversion，不是语义权威 | overload/conversion/namespace/operator/mixin/lambda 等 shadow facts 增加；CanonicalAST 32/32，但仍遍历 `asCScriptNode` | **部分解决；Blocking 保留** |
| R03 | stable key/name-first StaticJIT 误绑 | 参数类型进入 key；StaticJIT 要求唯一 name+arity+param match | **危险误绑显著缓解；完整 identity 仍未完成** |
| R04 | Cache ASTBodySidecar placeholder | 未见完整 body/source/type/reference reconstruction | **未解决，Blocking** |
| R05 | public AST V1 vtable/size negotiation 不安全 | module 方法仍插入旧 vtable 中间；实现仍不按 caller size/version bounded write | **未解决，Blocking** |
| R06 | snapshot Acquire/publication 并发不安全 | raw pointer→AddRef race、plain bool、replace-before-verify 仍存在 | **未解决，Blocking** |
| R07 | 无 arena，sealed graph 可修改 | block arena 已实现；sealed mutable node getter 已收紧 | **有实质改善；残余 immutability 问题保留** |
| R08 | verifier 不是 semantic firewall | ID/range/control/duplicate case 等检查增加；完整 ownership/type/cycle/signature/cleanup 仍缺失 | **部分解决，High** |
| R09 | CodeGen failure 不能原子回滚 | 仍在成功前修改 funcdef/global/engine function 状态；另新增 teardown crash | **未解决，且风险升级** |
| R10 | SourceManager 不是统一坐标真相 | 新 AST 使用增加；legacy Parser/Compiler diagnostics、Cache/public persistence、changed-content remap 仍未闭环 | **未解决，High** |

## R11 — Critical/Blocking：Canonical CodeGen 会破坏 funcdef/lambda teardown 状态

### 证据

- `AngelscriptNativeCanonicalASTCodeGenTests.cpp:730-753` 注册 `Callback` funcdef，生成 `Double`、`Invoke` 和 lambda，执行结果正确后销毁 Engine。
- `as_bytecode_codegen.cpp:522-537` 直接用 `asBC_FuncPtr`、`asBC_REFCPY` 和 `engine->functionBehaviours` 构造函数句柄。
- `as_bytecode_codegen.cpp:1006-1044` 对变量间接调用发出 `asBC_CallPtr`。
- `as_bytecode_codegen.cpp:1440-1488` 在 module 安装前先向 Engine 注册所有 pending function，并在成功后调用 `AddReferences()`；该流程缺少一份可审核的 funcdef/lambda/function-handle ownership transaction。
- 最新测试在 `asCScriptEngine::~asCScriptEngine()` 中稳定崩溃；不同复现分别落在 funcdef 和 function-behaviour 清理附近。

### 影响

这不是“某个不支持语法应 fallback”的问题，而是成功路径执行后损坏 Engine teardown 状态。若 production `Build()` 现在切到该 backend，可能把正常脚本编译升级为进程级 use-after-free/double-release/invalid reference 风险。

### 修正要求

1. 将 fixture 最小化为 funcdef-only、function-reference-only、lambda-only、indirect-call-only 四个生命周期测试，找出第一个破坏引用平衡的操作。
2. 对比 legacy `asCCompiler` 为 funcdef local、lambda function、`asBC_FuncPtr`、`asBC_REFCPY`、cleanup 和 `AddReferences()` 建立的完整 metadata/refcount 约束。
3. CodeGen 必须在 detached/transactional state 中完成并验证函数类型、function handle 和 lambda ownership；失败不得污染 Engine/module。
4. 增加执行后 `DiscardModule()`、Engine shutdown、Save/Load Bytecode、重复 build、失败回滚测试。

### Rereview gate

上述最小化测试和组合 fixture 必须在正常执行、module discard 与 Engine teardown 三个阶段均通过；禁止仅跳过 destructor 或泄漏 Engine 来让测试变绿。

## R01 — 部分解决：命名和 provenance 已诚实，production cutover 仍未完成

### 已解决

- `as_scriptengine.cpp:787` 默认 `canonicalCompilerPipeline = false`。
- `as_scriptengine.h` 明确 LEGACY 是 production default，CANONICAL 只是 capture/shadow selection。
- `IsCanonicalBytecodeCodeGenReady()` 返回 false。
- `as_compiler.cpp` 和 `as_bytecode_codegen.cpp` 分别记录 `COMPILER` / `CANONICAL_CODEGEN` publisher。
- Cutover 测试明确断言 canonical selection 当前仍由 `asCCompiler` 发布 production Bytecode。

### 仍未解决

- `as_module.cpp:393-406` 的 production `Build()` 仍调用 `builder->BuildCompileCode()`。
- `as_builder.cpp:863+` 仍为 production functions/factories/constructors 创建 `asCCompiler`。
- `asCBytecodeCodeGen::Generate()` 仍只有隔离测试调用，没有 production caller。

因此 13.1 的“诚实命名”子目标已达到，但 13.1 rereview gate 和 13.6/10.4 production CodeGen gate 均未达到。

## R02 — 部分解决：shadow Sema 变强，但仍不是 source-semantic authority

### 有效进展

- stable signature dump、basic overload ranking 和 explicit conversion node 已实现；
- namespace/operator/property-get/mixin/named/default args/control target 等 fixture 已加入；
- 最新 CanonicalAST 通过 32/32、Compiler 通过 220/220，证明这些不是只有空文件或占位测试。

### 仍然阻塞的结构事实

- `as_parser.cpp:2334` 仍先构造完整 `asCScriptNode`，再调用 `sema->ActOnParsedScript(scriptNode, script)`。
- `as_sema_decl.cpp`、`as_sema_expr.cpp`、`as_sema_stmt.cpp` 仍 include 并遍历 `as_scriptnode.h`。
- `asCSema` 持有 Engine，但主要解析仍基于 ASTContext 内自己猜出的有限符号/类型；没有复用完整 AngelScript semantic environment。
- `FindBestCallee()` 只实现少量 exact/numeric ranking；qualifier、reference/handle、access、inheritance、template/container、delegate、import/global、完整 receiver/ABI/lifetime 规则仍不完整。
- node model 仍缺少完整 call plan、conversion sequence、cleanup/liveness、dependency/ABI facts。
- production Bytecode 仍由 legacy compiler 再做一次真正语义分析；shadow dump 不是 backend-consumed authority。
- property-set rewrite 和 nested switch break snapshot publication 的直接 fixture 已在本轮后半段修绿；这关闭了两个具体用例，但没有改变 Sema 仍是 post-parse shadow conversion、production backend 仍会重跑 legacy semantics 的结构事实。

因此这里的准确描述是“shadow semantic graph coverage 正在增长”，不能描述为“已经用 Clang 风格 Sema 替换了 AS compiler semantics”。

## R03 — 部分解决：wrong-body 直接误绑已收紧，但 identity 还不是完整合同

### 已改善

- `asCSema::FinishDecl()` 把 owner 与 parameter type stable keys 加入 function key；lambda 再附加 source offset。
- StaticJIT 现在按 name、parameter count、parameter stable name 统计匹配，并只接受 `MatchCount == 1`。
- 对常见 global overload，第一轮“找到第一个同名函数就绑定”的错误路径已消除；ambiguous 情况会保持未绑定/fallback，而不是选错 body。

### 仍缺失

- key 没有完整编码 qualifiers、method qualifiers、return/ABI identity、module/profile；
- type stable key 与 StaticJIT runtime type-name 比较会丢失 reference/handle/const/in-out 细节；
- lambda identity 使用 offset，但没有完整 source-section/stable file identity；不同 section 的相同 offset 可冲突；
- StaticJIT 扫描整个 context，不以 exact owner key 定位 namespace/class；相同 name+params 的不同 owner 目前会 ambiguous fallback，而不是 exact match；
- Sidecar/Cache 仍把不完整 key 当持久身份使用。

该问题从“可能静默生成错误 native body”的 Blocking 风险下降为“多数歧义 fail closed，但 identity/caching/cutover 不完整”的 High/Blocking-for-cutover。

## R04 — Blocking：Cache V2 仍不能重建完整 canonical AST

本轮未观察到能关闭第一轮问题的实现：

- `as_ast_sidecar.cpp` 仍以 textual dump + declaration table 为主；
- SourceManager、完整 types、Stmt/Expr/body/children、resolved references、cleanup/dependency facts 未形成完整 pointer-free DTO；
- decoder 不能重建与 source build 等价的 verified module graph；
- `AngelscriptCacheASTBodySidecar.cpp` 仍忽略调用方 `CanonicalAstBytes` 的实际 AST 内容，封装空 TranslationUnit context；
- 测试仍以 `{1}` 作为 payload，未证明 byte fidelity、cross-Engine remap、zero-frontend ExactStartup。

13.9、6.x 和 ExactStartup gate 均保持打开。

## R05 — Blocking：Public AST V1 仍有 ABI 和结构协商问题

- `asIScriptModule` 的三个 AST virtual 方法仍位于 `CompileFunction` 与 `SetAccessMask` 之间，移动了后续 vtable slots；
- product version 仍是 1.0.0，没有旧 client ABI 迁移证明；
- public view 虽有 `structSize/apiVersion`，实现仍未按 caller 提供的 size/version 限制写入；
- test 仍以 zero-init full struct 为主，没有 smaller-view canary；
- ID 没有 snapshot generation/domain，A snapshot 的 numeric ID 可错误访问 B snapshot 同索引；
- V1 traversal 仍缺 ranges、children/operands、value category、resolved targets、dependencies 等 backend/tooling 所需字段。

13.7 保持 Blocking。

## R06 — Blocking：Snapshot publication/acquire 仍不是安全并发协议

- `AcquireASTSnapshot()` 仍是读取 raw `astSnapshot` 后再 `AddRef()`；publish/release 可夹在两步之间；
- `currentGeneration` 仍为普通 bool；异步 reader/writer 构成数据竞争；
- publication 仍先 invalid/release previous，再 seal/allocate replacement；replacement 失败会丢 last-good snapshot；
- retain 路径仍可在没有 canonical context 时伪造空 TranslationUnit snapshot；
- `CompileFunction(asCOMP_ADD_TO_MODULE)` 仍可增加 executable function 而不重建完整 module snapshot；
- Hot Reload 测试只证明预先持有的 A lease 能读，不证明 Acquire-vs-publish race；
- StaticJIT generation snapshot 内仍保存 raw `SealedAST`。当前 contained-generation callback 通常让 Engine 在消费期间存活，但类型本身没有携带 AST lease，合同仍脆弱。

13.8 保持 Blocking。

## R07 — 有实质改善：arena 已实现，sealed immutability 仍未完全关闭

第二轮确认 `as_ast_context.cpp` 已实现 block arena/placement new，`DestroyAll()` 变为 owner-private；sealed 后 mutable `GetDecl/GetStmt/GetExpr` 返回 null。这关闭了第一轮“逐 node `asNEW/asDELETE`”的主要部分。

残余问题：

- `GetSourceManager()` 仍暴露 mutable reference；SourceManager 没有 seal 状态；
- internal snapshot/context surfaces 仍存在 mutable `GetContext()`；
- 构造期与消费期接口没有完全用类型系统分离。

建议把 R07 从第一轮 High 降为 Medium/High residual，但 13.4 仍不应勾选。

## R08 — High：Verifier 增强了，但仍不是完整 semantic firewall

当前 verifier 已增加 decl/stmt table index、部分 parent/child、range、break/continue target kind、duplicate case/default、expression type/resolved decl 检查。

仍缺：

- expression table 自身 ID 与索引一致性；
- expression operands/children 全量验证；
- cycle、multiple ownership、bidirectional owner/body；
- nearest valid control ancestor；
- expression-kind mandatory type/value-category；
- resolved call/signature/receiver compatibility；
- cleanup/materialization/live-value plan；
- 完整 qualifier legality（unknown bits、direction without ref、auto-handle without handle、void quals 等）；
- 对抗性测试矩阵。

本轮中间状态曾使 `BreakTargetsNearestSwitchNotOuterLoop` 无法发布 retained context；后续 fixture 已修绿。Verifier 仍缺少上述全图 invariant，因此不能用一个控制流用例通过替代 semantic firewall closure。

## R09 — High/Blocking-for-cutover：CodeGen 安装仍非原子，且出现成功路径 teardown crash

`asCBytecodeCodeGen::Generate()` 在所有 body 成功前会：

- `module->AddFuncDef()`；
- `AllocateGlobalProperty()`；
- `engine->AddScriptFunction()`。

后续失败只通过 `DiscardPending()` 回收 pending functions，不回滚 funcdef、globals 和所有 Engine/module side effects。现有 `CodeGenFailureLeavesNoPartialModuleState` 只覆盖在 mutation 前失败的 unsealed context；unsupported-body 测试只断言 module function count，不验证 funcdef/global/engine tables。

新增 R11 又证明成功路径的 funcdef/lambda ownership 不安全。13.6 必须先实现 detached artifact + atomic install/rollback，再考虑 production cutover。

## R10 — High：SourceManager 仍不是全编译器唯一坐标真相

- `RemapLogical()` 仍主要按 logical key + origin 复用 FileID，没有把 changed bytes/line-offset identity 纳入复用条件；
- legacy Lexer/Parser/Builder/Compiler diagnostics 仍沿旧 section/row/column 路径；
- SourceManager 没有进入 public view 和 Cache sidecar 的完整持久合同；
- 测试只有相同 source 的 deterministic remap，缺 changed-content/stale-line-table case。

13.10 保持 High。

## 对“完成得怎么样”的通俗判断

这次实现不是失败，也不应推倒重来。它已经形成了一个可继续演进的 AST/Sema/CodeGen 实验平台，并修正了最危险的“把旧编译器冒充新编译器”问题。

但它仍不是“AST 编译体系改造完成”，更不是可直接接 LLVM 的 final semantic IR。当前最准确的阶段名称是：

```text
Canonical Typed AST migration platform / shadow semantic compiler
```

而不是：

```text
Canonical Typed AST production compiler
```

如果按下一步价值排序：

1. 先修 R11 funcdef/lambda teardown crash，禁止带内存所有权破坏继续扩 coverage。
2. 收完当前 Wave B 的 2 个 failing SemaAuthority fixtures，但不要把 17/17 等同于 R02 完成。
3. 让 Sema graph 表达完整事实并成为 CodeGen 唯一输入，而不是继续堆 dump-only special cases。
4. 完成 arena/verifier firewall。
5. 把 CodeGen 改成 detached transaction，先覆盖完整语言子集，再接 production `Build()`。
6. 独立关闭 Public ABI、snapshot concurrency、Cache DTO、SourceManager truth。
7. 最后才将 default 切到 CANONICAL，并用 publisher provenance + All suite 证明真正 cutover。

## 下一轮复审的最小门禁

在再次请求“production cutover 完成”复审前，至少需要：

- R11 最小生命周期矩阵全部通过，Engine teardown 无崩溃；
- SemaAuthority 当前 17/17，并新增 access/ref-handle/template/import/global/cleanup adversarial cases；
- production `Build()` 的 publisher 为 `CANONICAL_CODEGEN`，测试可在任何 `asCCompiler` invocation 时失败；
- CodeGen failed/success transaction 均不留下 funcdef/global/function/Engine mutation；
- verifier、public ABI、snapshot concurrency、Cache full reconstruction、SourceManager changed-content gates 关闭；
- focused SDK/Cache/HotReload/StaticJIT、Standalone Debug/Release 和 All 均在真实 canonical production path 上通过。

## 最终决定

- 保留当前实现和已完成 scaffold；
- 不回退到第一轮的虚假 CANONICAL 默认；
- 不归档 change；
- 不勾选 section 10 或 13；
- 按 R11 → Wave B remaining → R07/R08 → R09/production CodeGen → R05/R06 → R04/R10 → final cutover 的顺序继续。
