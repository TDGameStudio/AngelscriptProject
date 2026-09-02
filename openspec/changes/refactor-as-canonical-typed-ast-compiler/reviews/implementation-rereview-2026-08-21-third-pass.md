# Canonical Typed AST Compiler 第三轮实现复审 — 2026-08-21

## 复审结论

当前实现仍为 **Request changes**，不可归档，也不可把 canonical pipeline 切为 production default。

不过，第二轮报告中的 R11 Critical 已经关闭：funcdef/lambda 组合用例现在可以完成编译、执行、module/Engine teardown；本轮最新 `Frontend.CanonicalAST` 为 `56/56 PASS`，其中包含 24 个 CodeGen 用例以及最小化/组合生命周期用例。第三轮不再把 R11 描述为现存崩溃。

当前最准确的产品/架构定位仍然是：

> **Canonical Typed AST migration platform / shadow semantic compiler + isolated Bytecode CodeGen prototype**

它还不是 production compiler authority。真实 production 路径仍为：

```text
source
  -> legacy Parser constructs asCScriptNode
  -> canonical Sema incrementally/post-walks asCScriptNode and publishes a shadow graph
  -> asCModule::Build()
  -> asCBuilder::BuildCompileCode()
  -> legacy asCCompiler publishes production Bytecode

isolated tests only
  -> sealed canonical AST
  -> asCBytecodeCodeGen::Generate()
  -> subset Bytecode
```

目标路径仍未闭环：

```text
source
  -> Parser actions + authoritative Sema
  -> complete verified sealed canonical typed AST
  -> detached backend artifact
  -> atomic module/engine publication
  -> Bytecode / TypedASTJIT / Cache / future LLVM consumers
```

本轮最高价值的新发现位于 R04：Cache V2 `ASTBodySidecar` 当前的 per-function `contentHash` **没有覆盖函数体**，`profile` 也被显式忽略。这样即使把当前两个失败断言修绿，纯函数体修改仍可能错误复用旧 sidecar。当前 sidecar decode 也只重建 declaration skeleton，不重建 stmt/expr/body/reference graph，因此不能满足 `ExactStartup` 无 Parser/Sema 恢复完整 verified AST 的规范。

## 复审快照

- worktree：`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`；
- 短路径：`D:\as-cta`；
- branch：`refactor-as-canonical-typed-ast-compiler`；
- plugin submodule：`D:\as-cta\Plugins\Angelscript`；
- Engine：worktree `AgentConfig.ini` 指向 UE 5.8；
- point-in-time：2026-08-21 16:14（Asia/Shanghai）；
- parent/plugin 均有大量未提交与 untracked 变更，本报告审查的是该时刻的工作快照，不代表已提交分支；
- 项目文档产品基线仍写 UE 5.7，因此本轮 UE 5.8 结果是本机验证证据，不替代 UE 5.7/发布矩阵。

本轮测试完成后再次检查相关源码：最后一批相关实现修改为 `as_ast_public_view.cpp` 16:02，Cache 测试文件仍为 06:59，之后到 16:14 未再发生相关源码修改。OpenSpec 附件仍在更新，但没有改变下述 production call path 与源码判断。

用户随后明确说明另一个 agent 仍在继续实现。本报告因此严格限定为 **16:14 中间快照 review**，不是该 agent 完工后的最终验收；收到该说明后不再运行任何 build/test，也不再占用编译锁。后续源码变化应由下一轮 point-in-time review 重新核对，不能把本文测试数字自动外推到更新后的工作树。

OpenSpec checklist：

- total：`105`；
- checked：`51`；
- unchecked：`54`；
- `51/105 = 48.6%`；
- 13.1–13.12 全部保持未勾选，这是诚实状态。

未加权 checkbox 不能视为 production 完成度。分层评估为：

| 层次 | 第三轮判断 |
| --- | --- |
| scaffold、arena、dump、public view、测试与隔离原型 | 已形成可继续演进的平台，约 65–75% |
| shadow Sema / verifier 语义覆盖 | 有明显进展，但仍不完整、也不是 production authority |
| isolated canonical Bytecode CodeGen | R11 生命周期崩溃已修；仍是 subset，且 publication 不是 transaction |
| Cache/Public ABI/Snapshot/Source truth | 多个 Blocking contract 未完成 |
| production compiler authority/cutover | 未完成；生产 Bytecode 仍由 `asCCompiler` 发布 |
| 完整 OpenSpec 总体 | 粗略约 45–55%；不可归档、不可宣布 cutover |

## Findings（按严重性排序）

### F1 — Blocking：production `Build()` 仍没有消费 canonical AST CodeGen

证据：

- `as_module.cpp:406` 仍调用 `builder->BuildCompileCode()`；
- `as_builder.cpp:863+` 的 `BuildCompileCode()` 仍在多条 production 路径实例化 `asCCompiler`，例如 885、1135、1563；
- `asCBytecodeCodeGen::Generate()` 没有 production caller，仅由隔离 fixture 直接调用；
- `as_scriptengine.cpp:787` 默认 `canonicalCompilerPipeline = false`，这是当前实现成熟度下正确且诚实的配置；
- publisher provenance 与 Ready=false 已避免第一轮的虚假 cutover，但它们证明的是“没有冒充完成”，不是“完成了 cutover”。

影响：

- canonical AST 目前不是生产 Bytecode 的唯一语义输入；
- legacy compiler 会重新做真正的语义判断；
- 即使 canonical dump、CodeGen subset 和 legacy execution 都绿，也不能证明 exact graph → exact production Bytecode；
- 13.1、13.6、10.4 与最终 cutover gate 均不可勾选。

要求：production 路径必须从同一份 sealed/verified snapshot 生成 detached artifact，测试需 fail closed 地证明 canonical-selected `Build()` 中没有 `asCCompiler` publisher，并证明发布后的 Bytecode provenance 为 canonical CodeGen。

### F2 — Blocking：Cache V2 function record 不包含 body；当前 `ASTBodySidecar` 不能恢复完整 AST

这是第三轮新增的关键结构发现。

#### 2.1 content hash 没有覆盖函数体

`as_ast_sidecar.cpp:271-304` 的 `asCASTCollectFunctionRecords()` 只向 hash material 写入：

- `functionKey`；
- declaration type stable key；
- declaration qualifiers；
- traits；
- origin；
- default argument 文本；
- dependency stable keys。

它没有写入：

- `decl->body`；
- statement/child ordering；
- expression kind、literal/value；
- resolved declaration/callee/reference；
- conversion/call plan；
- cleanup/liveness；
- source-content identity。

同时 `as_ast_sidecar.cpp:274` 明确执行 `(void)profile`。因此：

```text
int G() { return 1; }
        ↓ pure body edit
int G() { return 2; }

signature/dependencies unchanged
  -> current contentHash unchanged
  -> planner classifies record as reused
  -> stale function body may survive incremental Cache activation
```

#### 2.2 当前“ChangedFunction”测试并没有修改函数体

`AngelscriptCacheASTBodySidecarTests.cpp:138-203` 名为 `IncrementalRebuildsChangedFunctionReusesUnchangedAndStaysAtomic`，但 fixture 没有创建 body；它在 line 158 把 `G` 的返回类型从 `int` 改成 `const int`。这只能证明 declaration qualifier 会改变 hash，不能证明 body-only edit 会 rebuild。

必须增加真正的 body-only fixture，例如保持 signature、origin、dependencies 全部不变，只把 literal `1` 改为 `2`，并断言 `G()` 进入 rebuilt set。

#### 2.3 encode/decode 不是完整 DTO reconstruction

- encode 在 `as_ast_sidecar.cpp:69-107` 写入 textual `asCASTDump` 和 declaration table；
- decode 在 142-218 读取 dump 字符串，但没有消费它来重建图；
- decode 只重新创建 translation unit/declarations/type key，并在 224 调用 `Seal()`；
- 没有重建 stmt、expr、body link、source table、resolved references 或 cleanup facts。

这不是规范要求的 pointer-free `FunctionBody` payload，也无法证明 `ExactStartup` 在不运行 Parser/Sema 的情况下恢复一份与 source compile 等价的 verified module AST。

#### 2.4 当前 Cache prefix 为红

最新：`Angelscript.TestModule.Cache.ASTBodySidecar` 为 `5/7 PASS`，失败：

1. `IncrementalRebuildsChangedFunctionReusesUnchangedAndStaysAtomic`；
2. `DependencyChangeInvalidatesOnlyDependentClosure`。

这两个失败的直接 fixture 原因是 stable key 已从 `F/H` 演进为 `F()/H()`，而测试 line 176/183/237/244 仍只接受 `F`、`IncMod::F`、`H`、`DepMod::H`。planner line 335/339 原样返回 `functionKey`，所以断言无法识别 `F()`/`H()`。

但不能把问题理解为“只需要把断言加括号”：修正 fixture 后，上述 body-less content hash 与 incomplete decode 仍然使 R04 保持 Blocking。

### F3 — Blocking：snapshot Acquire/publication 仍有并发 UAF 窗口，并会在失败发布时丢失 last-good generation

证据：

- `as_module.cpp:1999-2010` 先读取 raw `astSnapshot`，随后才 `AddRef()`；publish/release 可在两者之间释放对象；
- `as_module.cpp:2056-2064` 在验证 candidate 前先把 previous 标为非 current、清空 module pointer 并 `Release()`；
- candidate seal/allocate 在 2066-2110 之后才发生；一旦 seal 或 allocation 失败，旧 generation 已经丢失；
- context 为空时 2088-2096 会制造空 translation unit 并发布，而不是明确区分“没有 snapshot”与“有效空模块”；
- `as_ast_public_view.h:27/35` 的 `currentGeneration` 是普通 `bool`，并发读写有 data race。

现有 HotReload 测试 `5/5` 是有效的 positive evidence，但它预先 acquire Generation A，再让保留 lease 的 reader 遍历；它没有把 `AcquireASTSnapshot()` 本身与 atomic publish/release 竞态起来，也没有验证 failed candidate 保留 previous current generation。

要求：先构造、seal、verify 新 snapshot；再以同一同步协议原子交换；Acquire 的 retain 必须与 exchange/release 处于相同协议中；current-generation 状态要么原子化，要么由 generation token/owner protocol 表达；失败发布必须保留 last-good snapshot。

### F4 — Blocking：public AST V1 的 vtable 与 size/version negotiation 仍不安全

证据：

- `angelscript.h:1058-1060` 把 `SetASTRetentionPolicy`、`GetASTRetentionPolicy`、`AcquireASTSnapshot` 插在 `asIScriptModule::CompileFunction` 与原有 `SetAccessMask` 之间；这不是 append-only ABI；
- `as_ast_public_view.cpp:64-143` 的 `GetDecl/GetStmt/GetExpr/GetType` 直接写完整当前 struct；
- implementation 在写入后把 `outView->structSize` 和 `apiVersion` 覆盖成当前值，没有先读取/验证 caller capacity/version，也没有 bounded write；
- `DeclId/StmtId/ExprId` 只是 context 内部 index，没有携带 snapshot domain/generation；另一个 snapshot 的同 index ID 可能被误认为本 snapshot 的合法节点。

最新 public snapshot prefix `4/4 PASS` 只能证明同版本、同 snapshot、足够大 struct 的 happy path。仍缺：

- smaller-view canary；
- incompatible version rejection；
- foreign-snapshot same-index ID；
- append-only/extension-interface ABI 验证。

### F5 — Blocking：Canonical CodeGen failure 仍不是 detached/atomic transaction

R11 teardown 引用平衡已修，但 R09 的 transaction contract 没有因此完成。

`as_bytecode_codegen.cpp:1461-1583` 当前顺序：

1. 1518：在所有 function body emission 成功前调用 `module->AllocateGlobalProperty()`；
2. 1534-1552：创建 function、分配 Engine id，并立即 `engine->AddScriptFunction()`；
3. 1559-1569：之后才逐个 emit function body；
4. emit 失败时 `DiscardPending()` 只 remove/release pending functions；没有回滚已分配 global property、funcdef/engine registry 等所有可观察状态；
5. 1572-1580：成功后才 `AddReferences()` 并安装到 module function lists。

`DiscardPending()` 在 1408-1413 清空未 AddReferences 的 bytecode，修复了 R11 的 extra-release 路径；这是正确的局部 ownership 修复。但它仍不是通用 publication transaction。

现有 failure fixture 主要观察 function count/早期 mutation。必须增加一个“在至少一个 global 和一个 pending function 已创建后，后续 body emit 失败”的用例，并对比失败前后：

- module globals；
- Engine script-function table / next id 可见约束；
- funcdefs/types；
- module function lists；
- publisher；
- snapshot/current generation。

理想结构是 CodeGen 只产出 detached `CanonicalBytecodeArtifact`；验证通过后由独立 installer 一次性提交 module/engine mutation。

### F6 — Blocking：Sema 覆盖增强，但仍不是 source semantic authority

有效进展：

- incremental `NotifySema()` 已接入一部分 parser declaration actions；
- overload、numeric conversion、constructor、namespace/operator/mixin、named/default args、property get/set、lambda、control targets、temporary/cleanup 等 fixture 增加；
- 本轮 `Compiler.CanonicalAST` 为 `37/37 PASS`，完整 Compiler prefix 为 `225/225 PASS`；
- graph 对后续 verifier/CodeGen/JIT 研究已经很有价值。

结构阻塞仍在：

- `as_parser.cpp:2346` 仍保留 `ActOnParsedScript(scriptNode, script)` 全图 fallback；
- `as_sema_decl/expr/stmt` 仍直接遍历 `asCScriptNode`；
- parser 仍先构造 legacy syntax tree，再通知/转换 canonical graph；
- production `asCCompiler` 仍重新执行真正的语义分析；
- 当前 scope/symbol/candidate/ranking/type/conversion/receiver/lifetime environment 仍只是 AngelScript 全语义的有限子集；
- `as_sema.h:10` 的注释称其为 “the only semantic authority for the canonical pipeline”，对当前 production 事实过强，容易让实现者误判完成度。

所以当前应称为 **shadow semantic graph**。只有 legacy compiler 不再重新决定 overload/conversion/lifetime、所有 backend 都消费同一份 verified facts 时，才能称为 authority。

### F7 — High：stable identity 比第一轮安全，但还不是完整函数身份

进展：`asCSema::FinishDecl()` 现在形成 `parent::name(param type keys)`，lambda 还加入 source offset；这已能区分许多重载和 lambda，StaticJIT 也已 fail closed 地避免简单 name-first 取错。

残余：

- `as_sema.cpp:14-79` 的 key 没编码 return type、method const、完整 ref/handle/in-out qualifiers、ABI/profile、module/source identity；
- parameter key 只拼 `type->stableKey`，没有直接拼 child qual bits；
- lambda offset 只有在 source identity/内容 identity 完整稳定时才可靠；
- `as_bytecode_codegen.cpp:531-587` funcdef resolution 遍历 Engine funcdef tables，并返回首个 `IsEqualExceptRefAndConst` 匹配项；完整 owner/ABI identity 仍未证明。

因此 R03 的“危险 name-only 误绑”已经显著缓解，但 exact identity gate 仍未达到。

### F8 — High：arena/seal/verifier 有实质进展，尚未形成完整 semantic firewall

已完成的有价值进展：

- ASTContext 使用 block arena；
- `DestroyAll` 已收紧；
- sealed 后 mutable node getter 返回 null；
- snapshot public traversal 使用 const Context；
- verifier 已覆盖 decl/stmt/expr ID、decl parent/child、decl cycle、body owner、ranges、break/continue ancestor kind、duplicate case/default、expression type/value category/operand count 等；
- `Frontend.CanonicalAST 56/56` 与 `Compiler.CanonicalAST 37/37` 为最新正向证据。

残余：

- construction 仍可通过 public mutable node getter/raw POD write 完成；没有类型上分离 builder phase 与 sealed read-only graph；
- 同名 const/non-const getter + sealed 时 mutable getter 返回 null 很容易误用。本轮实现过程中 `as_ast_public_view.cpp` 就曾在 sealed snapshot 上选中 non-const overload，造成 HotReload `3/5`；16:02 改为显式 `static_cast<const asCASTContext*>` 后，本轮 fresh rerun 为 `5/5`。它已不是当前失败，但暴露了 API 形状风险；
- verifier 尚未完整检查 stmt graph cycle/multiple ownership、nearest control target、expr graph cycle/multiple ownership、每种 node 的 mandatory fields、完整 call signature/receiver、cleanup/liveness/dependency/ABI consistency；
- 当前 verifier tests 数量和 adversarial graph 仍不足以证明所有 consumer 前都建立了 semantic firewall。

建议将 mutable construction 收敛为明确 builder/friend surface，snapshot 暴露不可取得 mutable overload 的只读类型，而不是依赖运行期 null。

### F9 — High：SourceManager 仍不是整个编译体系的统一 source truth

`as_source_manager.cpp:192-204` 的 `RemapLogical()` 只按 `logicalKey + origin` 查重；如果同 logical key 的 bytes 内容变化，它直接返回旧 FileID，旧 line table/content metadata 可被复用。当前没有 content digest/generation 参与 remap。

同时 legacy lexer/parser/compiler diagnostics、public AST view、Cache DTO 与 backend debug positions 尚未统一由同一 source model 驱动。R10 保持 High，最终 Cache/diagnostic/debug parity 前不可关闭。

### F10 — Documentation consistency：R11 已修，但 tasks 13.6 的 blocking intercept 仍是旧事实

`tasks.md:295` 仍写 “isolated test executes 11 then AVs during Engine.Destroy()”。这在第二轮是准确证据，但第三轮已过期。`attachments/r11-results.md` 和 fresh tests 已证明具体崩溃关闭。

不应因此勾选 13.6，因为 R09 transaction 与 production routing 仍未完成；但下一次实现更新应把 13.6 的说明改成：

- R11 lifecycle intercept：resolved on current snapshot；
- R09 detached artifact/atomic installation：still blocking；
- production `Build()` routing：not started/not complete。

这样可以避免后续实现者继续围绕已关闭崩溃工作，或反过来因为 crash 修复就误勾完整 13.6。

## R01–R11 第三轮状态矩阵

| ID | 主题 | 第三轮状态 | 决定 |
| --- | --- | --- | --- |
| R01 | honest pipeline naming / production provenance | LEGACY default、Ready=false、publisher provenance 已完成；production cutover 未发生 | **部分解决；Blocking 保留** |
| R02 | authoritative Sema | 语义 fixture 增加，37/37；仍是 `asCScriptNode` shadow conversion，production compiler 重跑语义 | **部分解决；Blocking 保留** |
| R03 | exact stable identity | parameter-aware key 与 fail-closed matching 有效；qualifier/ABI/owner/profile 仍不完整 | **显著改善；High/Blocking gate 保留** |
| R04 | Cache ASTBodySidecar | 新发现 body 不进 hash、profile ignored、decode 只建 decl skeleton；fresh 5/7 | **未解决；Blocking** |
| R05 | public AST ABI/views | happy path 4/4；mid-vtable insertion、unbounded write、foreign ID domain 未解 | **未解决；Blocking** |
| R06 | snapshot publication/concurrency | positive HotReload 5/5；raw acquire race、replace-before-verify、plain bool 未解 | **未解决；Blocking** |
| R07 | arena / immutable seal | block arena、const snapshot、post-seal mutable getter rejection 已落地 | **有实质进展；残余 High** |
| R08 | verifier firewall | 检查覆盖明显增强；graph ownership/cycles/call/cleanup 等仍不完整 | **部分解决；High** |
| R09 | transactional CodeGen / production backend | R11 cleanup 修复；global/Engine mutation 仍先于全量 emit，production 未接入 | **未解决；Blocking** |
| R10 | unified SourceManager | canonical graph 使用增加；content-aware remap/diagnostic/cache/public 闭环未完成 | **未解决；High** |
| R11 | funcdef/lambda teardown crash | 最小化与组合生命周期、执行、teardown fresh green | **当前快照已解决；降级为回归门禁** |

## R11 关闭证据与残余边界

第二轮 crash 的修正不是简单跳过 destructor。当前代码/附件显示处理了多个真实 ownership/emit 问题：

- function → funcdef conversion 不再当普通 numeric conversion；
- 不依赖不可靠的 `asCScriptFunction::funcdefType` 假设；
- 修正普通 call argument 的重复 reverse；
- function handle store 补齐对象初始化/ownership 所需 metadata；
- funcdef lookup 复用现有 compatible type；
- `DiscardPending()` 在 `ReleaseInternal()` 前清空尚未执行 `AddReferences()` 的 bytecode，避免 teardown extra-release。

最新 `Frontend.CanonicalAST 56/56` 覆盖：

- CodeGen 24 个用例；
- funcdef-only / lambda-only / combined lifecycle；
- execution；
- scope exit、module/Engine teardown；
- 当前 save/load round-trip fixture。

因此本轮不再保留 Critical finding。R11 应成为防回归测试集，并纳入未来 production routing、失败 rollback、重复 build、hot reload generation replacement 的验证，而不是继续作为当前 intercept。

## 新鲜验证结果

### Build

```powershell
Tools\RunBuild.ps1 `
  -Label canonical-ast-third-review-build-20260821 `
  -TimeoutMs 1800000 -NoXGE
```

结果：exit `0`，target up to date。

日志：`Saved/Build/canonical-ast-third-review-build-20260821/20260821_160401_926_f5fe931c/Build.log`

说明：最初从长 worktree path 调用时，安全检查因 `ProjectFile=D:\as-cta\AngelscriptProject.uproject` 不在传入长路径 root 下而拒绝执行；改为在官方 bootstrap 建立的 `D:\as-cta` 短路径运行后成功。前者不是源码 build failure。

### UE Automation

| Prefix | 结果 | 报告 |
| --- | ---: | --- |
| `AngelScriptSDK.Frontend.CanonicalAST` | **56/56 PASS** | `Saved/Tests/canonical-ast-third-review-frontend-20260821/.../Report/index.json` |
| `AngelScriptSDK.Compiler.CanonicalAST` | **37/37 PASS** | `Saved/Tests/canonical-ast-third-review-compiler-canonical-20260821/.../Report/index.json` |
| `AngelScriptSDK.Module.CanonicalAST.Snapshot` | **4/4 PASS** | `Saved/Tests/canonical-ast-third-review-module-snapshot-20260821/.../Report/index.json` |
| `HotReload.CanonicalAST` | **5/5 PASS** | `Saved/Tests/canonical-ast-third-review-hotreload-20260821/.../Report/index.json` |
| `AngelScriptSDK.Compiler` | **225/225 PASS** | `Saved/Tests/canonical-ast-third-review-compiler-full-20260821/.../Report/index.json` |
| `StaticJIT.TypedASTJIT.CanonicalASTMigration` | **8/8 PASS** | `Saved/Tests/canonical-ast-third-review-jit-migration-20260821/.../Report/index.json` |
| `Cache.ASTBodySidecar` | **5/7 PASS，2 FAIL** | `Saved/Tests/canonical-ast-third-review-cache-sidecar-20260821/.../Report/index.json` |

完整 Compiler 的 225 个测试中，有一个成功测试带预期 StaticJIT clean-capture warning：`AssetAndSubsystemOriginsReachTheNormalizedHIRDump` 使用 unsupported module shape；无 failure/skip。

### Standalone

```powershell
Tools\RunTestSuite.ps1 `
  -Suite Standalone `
  -LabelPrefix canonical-ast-third-review-standalone `
  -TimeoutMs 900000
```

结果：**21/21 CTest PASS**，包括 `AngelscriptStandalone.CanonicalAST`、TypedSemanticIR、Frontend、Runtime、Package、Corpus、Soak、Benchmarks。

报告：`Saved/StandaloneTests/canonical-ast-third-review-standalone_01_Standalone/20260821_161233_082_fa62918b/`

编译中仍有多条 MSVC C4819：若干新增 AST header 含当前 CP936 无法表示的字符。这不阻断本轮测试，但在 release/跨区域构建前应统一 UTF-8 source encoding，避免编译器在非 UTF-8 code page 下潜在字符损失。

### OpenSpec / diff hygiene

```powershell
openspec validate refactor-as-canonical-typed-ast-compiler --strict
git diff --check
git diff --cached --check
```

结果：

- Change valid；
- parent tracked diff check 通过；
- plugin tracked/staged diff check 通过。

注意：`git diff --check` 不覆盖全部 untracked 新文件的每一种格式问题；本轮没有把它夸大为整个 dirty worktree 的完整 lint。

## 对实现进展的通俗判断

当前不是“方向做错了”，也不建议推倒重来。现在已经有一套可以继续收敛的 canonical AST 基础设施：arena、类型/节点模型、Sema actions、dump、verifier、public snapshot、StaticJIT bridge、Cache skeleton 和可执行 subset CodeGen 都存在，并且 R11 的严重 lifecycle bug 已经被真实最小化和修掉。

但它目前更像：

```text
                  ┌────────────────────────────┐
legacy source --->│ production Parser/Compiler │---> production Bytecode/VM
       │          └────────────────────────────┘
       │
       └---------> canonical AST shadow graph
                    │       │        │
                    │       │        ├-- Cache skeleton (body missing)
                    │       ├----------- TypedASTJIT identity/migration checks
                    └------------------- isolated subset CodeGen
```

而不是：

```text
source -> authoritative canonical AST -> verified artifact transaction
                                      ├-> production Bytecode
                                      ├-> TypedASTJIT
                                      ├-> Cache V2 restore
                                      └-> future LLVM lowering
```

所以测试数量增长是好现象，但目前尚未关闭最难的“单一语义权威 + 原子交付 + 可持久化精确图”三件事。

## 建议的后续顺序

1. **立即修复 Cache 红项的 key fixture，但不要把 R04 判完成。** 同时新增 body-only content hash test、profile separation test、decode exact-graph equality test，让当前结构缺陷先变成稳定红测试。
2. **完成 R07/R08 的 construction/read-only 分离与 verifier adversarial matrix。** 这决定后续 backend/cache 是否能信任 sealed graph。
3. **完成 R09 detached CodeGen artifact + atomic installer。** 在任何 production routing 前，先让 globals/functions/funcdefs/types 的失败路径完全无污染。
4. **扩展 canonical CodeGen 语义子集并建立 exact parity。** 不只比较执行结果，还比较异常、cleanup、debug positions、save/load、reload 和 publisher。
5. **处理 R05/R06。** public API 使用 append-only extension/bounded view；snapshot 使用同一 retain/exchange protocol，并验证 failed publish keeps last good。
6. **重做 R04 payload。** 使用 pointer-free typed DTO 序列化 source/type/decl/stmt/expr/body/reference/dependency/cleanup，module 级重组并 verifier seal；不要把 textual dump 当 Cache DTO。
7. **完成 R10 content-aware SourceManager。** 把 diagnostic/cache/public/backend 坐标统一起来。
8. **最后才接 production `Build()` 并切 default。** Cutover 测试必须证明同一 sealed snapshot 是唯一 backend semantic input，且失败自动回退/保持旧 generation 的策略符合规范。

R11 不再需要排在第一位；它已关闭并应保留为回归门禁。

## Review 决定

- **不归档 change**；
- **不勾选 13.1–13.12**；
- **不勾选 section 10 的 production cutover/retirement**；
- **不删除现有 scaffold，不重新开第二套 AST**；
- **允许继续在当前 worktree 修正**；
- 下一轮复审优先检查：Cache body-only red/green、R09 transaction、R05/R06 adversarial tests，以及 production caller 是否真正从 `asCCompiler` 切到 canonical CodeGen。

最终判断：第三轮相较第二轮是实质进步，且最危险的 teardown crash 已经修复；但生产 authority、Cache fidelity、snapshot concurrency、public ABI 和 CodeGen transaction 仍是架构级 Blocking。当前适合继续实现，不适合宣布完成。
