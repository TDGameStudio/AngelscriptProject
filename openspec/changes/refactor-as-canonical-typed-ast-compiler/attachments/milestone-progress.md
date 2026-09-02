# Milestone progress (as-cta)

Worktree: `D:\as-cta`  
Engine: UE 5.8 via worktree `AgentConfig.ini`  
LLVM research: `Reference/llvm-project` → `D:\LLVM\llvm-project-22.1.8.src` (22.1.8)

## Plan coverage

Every OpenSpec task in sections 1–12 is listed with files, interfaces, and verification commands in `attachments/execution-plan.md`. LLVM/Clang encodings are locked in `attachments/llvm-ast-architecture.md`.

## Done with evidence

| Gate | Evidence |
| --- | --- |
| Sections 1–3 | baselines, SourceManager/AST foundation, public V1 + Hot Reload leases |
| Section 4 decl/type Sema | `attachments/decl-sema-results.md` |
| Section 5 body Sema | `attachments/body-sema-results.md` |
| Section 6 Cache V2 | `attachments/cache-v2-results.md` |
| Section 7 TypedASTJIT | `attachments/typed-ast-jit-results.md` |
| Section 8 Primary Generate | `attachments/primary-generate-results.md` |
| Section 9 Bytecode CodeGen | `attachments/bytecode-codegen-results.md` |
| Section 10 cutover | **Reopened.** Flag-only default is not production CodeGen. See `attachments/cutover-results.md` and `reviews/implementation-review-2026-08-21.md`. |
| Section 11 Standalone/docs | Debug **21/21**, Release **21/21**. Docs overclaim HIR removal; 11.3/11.4 reopened. |
| Record honesty | `attachments/record-reconciliation.md`. Tasks 10 and 13 restored to spec meaning. |

HIR capture stays off. LLVM/Clang are not linked. All-suite compatibility: 3632/3632 + Standalone 21/21 (`attachments/final-results.md`). That does not close section 10.

## Remaining

Execution order: `attachments/next-work.md`. Package prompts: `attachments/async-work.md`.

- **Wave A honesty — landed** (Cutover 5/5). 13.1 rereview gate still needs Wave D. 11.3 leftover: ZH knowledge + Standalone bundle still claim default CANONICAL.
- **Next: Wave B** — Sema authority + stable identity (13.2, 13.3, 4.x/5.x). SemaAuthority tests currently 0/2.
- Wave C — arena + verifier
- Wave D — production `Generate()` on `Build()`
- Wave E — public ABI + snapshot leases
- Wave F — Cache DTO + SourceManager
- Wave G — default CANONICAL, 10.x, All as CodeGen evidence
- Archive only if the user requests it **and** section 10 rereview gates exist

## Current status update — 2026-08-23 22:22

### 通俗结论

这项改造已经越过了“只设计、不落地”的阶段：Canonical Typed AST 已经拥有模块所有权、类型/声明/语句节点、验证与 Seal、不可变快照、公开 Lease，以及供 Hot Reload、Cache V2、Canonical Bytecode CodeGen 和 TypedASTJIT 使用的真实入口。最新修复还证明了严格 AST verifier 的实际价值——它在 JIT 之前准确拦住了 `for` 多个增量表达式导致真实循环体被 Sema 脱链的问题。

但当前仍处于“双轨迁移的中段”，不能把它描述为“新版 AST 已替换旧编译器”。正常语言编译的广覆盖仍主要依赖 `asCScriptNode`、`asCBuilder` 和 `asCCompiler`；Canonical Sema、Bytecode CodeGen、Cache V2 AST DTO 和 TypedASTJIT 的 AST 分析闭包还只是若干已验证的纵向切片。真正的默认切换、旧语义路径删除、HIR 读路径删除尚未完成。

```text
.as source
    |
    v
Lexer / Parser
    |
    +---------------- LEGACY -----------------------------+
    |     asCScriptNode -> asCBuilder/asCCompiler          |
    |                                      |               |
    |                                      +--> Bytecode   |  仍是广覆盖主路径
    |
    +---------------- CANONICAL --------------------------+
          Sema -> Typed AST -> Verify -> Seal
                               |
                               v
                    Immutable Snapshot / Lease
                       |        |        |
                       |        |        +--> TypedASTJIT
                       |        +----------> Cache V2 sidecar
                       +-------------------> Canonical Bytecode CodeGen
                                            Hot Reload / Public AST

目标：CANONICAL 成为唯一语义事实；LEGACY 只在迁移期作为回退和对照，最终删除。
```

### 两个进度口径

| 口径 | 当前值 | 解释 |
| --- | ---: | --- |
| OpenSpec 机械完成度 | **69 / 115 = 60.0%** | 已打勾的任务数量；Clang tooling 审计新增的五个 AST 可观察性任务 2.9–2.13 已全部完成。它仍不能等同于可切换程度。 |
| 真实默认切换完成度 | **约 46%** | 以“新版 AST 能否安全接管默认生产编译、随后删除旧语义路径”为准的工程估算；这是当前应采用的总进度。 |

```text
机械任务完成度  [############--------] 60.0%
真实切换完成度  [#########-----------] ~46%

已经完成得较扎实：  AST 地基 / Verify+Seal / Snapshot+Lease / 若干端到端切片
正在啃的核心：      Sema 全覆盖 / Cache DTO / JIT 分析迁移 / 完整 Bytecode CodeGen
最后才能做：        默认切换 / 删除旧 semantic AST / 删除 HIR 读路径 / 全量回归
```

机械数高于真实数是正常的：前 58.2% 里包含许多“修路”和“证明某个局部能走通”的任务，而最后的默认切换要求所有主要语言特性、生命周期和后端闭包同时成立，权重明显更大。

### 当前已经真正完成的能力

- Canonical Typed AST 不再只是另一棵临时树：它有模块所有权、稳定 ID/SourceManager、类型与声明信息、语句/表达式结构、只读 verifier、Seal 和发布约束。
- 公开 AST 使用不可变 snapshot/lease，而不是让外部长期借用可变编译上下文；Hot Reload 和部分后端消费者已有真实接线。
- Canonical Bytecode CodeGen 已能完成一组受控的生产切片，并使用候选 artifact/Commit 边界避免失败时污染模块状态；但覆盖面还不足以接管整个语言。
- Cache V2 已有 `ASTBodySidecar`、简单函数体/声明保真和 ExactWarm 恢复证据；但还不是完整、指针无关、可重映射的全 AST FunctionBody DTO。
- TypedASTJIT 已能在强制 AST 保留下通过完整前缀 **64/64**。这证明 AST 发布/兼容链路可用，不等于其 eligibility、调用、cleanup 和依赖分析已全部摆脱 HIR。
- HIR capture 的生产默认关闭方向已经成立；但 HIR 数据类型、诊断/测试 oracle 和若干分析读取仍存在，所以不能宣称 HIR 已删除。

### 最新一轮修复说明

最新的 TypedASTJIT 全组最初因为 AST 无法 Seal 而失败。诊断定位到 `continue-ancestor`：Parser 允许 `for (...; ...; A, B)`，并把 `A`、`B` 作为两个增量子节点；旧 Sema 却只按一个增量节点取孩子，把 `B` 错当作循环体，真实 block 因而脱离 `ForStmt`。

```text
Parser 实际子节点：
init -> cond -> inc A -> inc B -> real body { continue; }

旧 Sema 的误读：
init -> cond -> inc A -> body=inc B       real body 被丢在 ForStmt 外
                                              |
                                              +--> continue 指向 For，
                                                   但 For 不再是祖先
                                                   => verifier 拒绝发布

修复后的结构：
init -> cond -> Sequence(inc A, inc B) -> real body -> continue(target=For)
```

修复后新增 AST-first 源码回归，验证多个增量表达式会形成有序 `SequenceExpr`，循环体和 `continue` target 均保持正确；随后 Runtime build、原始 BytecodeIsolation 症状和完整 TypedASTJIT 前缀都通过，完整结果为 **64/64 PASS**。

### 仍然挡在默认切换前的主干工作

1. **补齐 Canonical Sema。** 让声明、类型、表达式、控制流、调用、重载、生命周期和 cleanup 计划真正由新 AST 独立表达，不再借旧 compiler 的隐式结论。
2. **补齐 Canonical Bytecode CodeGen。** 对象、容器、delegate、lambda、异常/清理、debug metadata、栈布局等仍需生产级覆盖和事务化失败保证。
3. **完成 Cache V2 AST 协议。** 需要完整的 pointer-free DTO、类型/导入/依赖编码、稳定身份重映射、增量失效和失败发布保持。
4. **把 TypedASTJIT 分析从 HIR 迁到 AST。** 当前 64/64 主要证明兼容性；必须继续迁移 eligibility、调用闭包、cleanup、lease/lifetime 和依赖分析，然后删除生产 HIR 读取。
5. **完成最终切换与删除。** 只有上述闭包通过 AST-first、差分、后端和全量回归后，才能把 CANONICAL 设为默认，随后删除旧 semantic AST/旧 compiler 语义权威；`asCScriptNode` 最终至多保留为短生命周期 Parser/错误恢复节点。

### 当前判断

实现方向没有明显架构性偏差：以 Canonical Typed AST 作为唯一语义事实、Seal 后不可变、消费者持有 Lease、Cache 使用稳定 DTO、后端只消费已验证 AST，这条路线是正确的。当前最大风险不是方向，而是“局部纵向切片已经能跑”容易被误读为“默认编译器已经替换”。现阶段最准确的描述是：**地基和桥墩已成形，多条试验车道已通车，主干迁流尚未完成；真实总进度约 46%。**

### 决策确认：LEGACY 可对照，HIR 必须退休

LEGACY 与 HIR 不采用相同的保留策略。完整 LEGACY 编译器在迁移期可以通过开发/测试配置显式选择，并在隔离 Engine 中与 CANONICAL 做编译结果、诊断、VM 行为、cleanup、Cache 和 JIT 差分；它还是最终切换前的发布回滚来源。但它不应成为最终 Shipping 中永久双编译器，也不能在 Canonical 不支持某个节点时静默接管生产编译。

当前 function-owned TypedSemantic HIR 则只是重复的 source-semantic sidecar，不是需要长期保留的可切换后端。等 TypedASTJIT、Cache、dump/diagnostics 和测试 oracle 都迁到 sealed Canonical AST 后，应成组删除 HIR capture 标志、builder、节点/存储类型、accessor、Cache/dump 术语以及所有生产读取；不增加 `AST -> HIR` 兼容层，也不从 Bytecode/Cache 重建 HIR。保留下来的是 HIR 曾验证过的调用、求值顺序、cleanup、控制流和依赖语义及其测试，这些事实转由 Canonical AST 表达。

```text
迁移期间：
    LEGACY compiler  <---- isolated differential ---->  CANONICAL compiler
       可切换 oracle / 回滚来源                         最终生产路径

    HIR -------------- consumers migrate ------------> Canonical Typed AST
     |
     +-- 全部消费者迁完后删除，不作为第三条可切换生产路径

最终运行时后端回退：
    Canonical function -> TypedASTJIT -> BytecodeJIT -> VM
                                         ^              ^
                                         合法回退；不是 LEGACY/HIR 回退
```

### Clang AST tooling 对照与 AST-first 推进审计

本地 Clang 22.1.8 的 `RecursiveASTVisitor`、`ParentMapContext`、text/JSON AST dumper、`clang-check -ast-dump-filter`、AST Matchers、ASTImporter/structural equivalence、ASTReader/Writer 和 on-demand CFG 已完成针对性对照。当前 AngelScript 已有地址无关的稳定 flat dump、有限 declaration shadow diff、发布 verifier、SourceManager、公开 snapshot child traversal 和大量 AST 自身测试；尚缺通用 visitor/edge model、parent index、tree/JSON/filter dump、定位到坏节点路径的诊断、小型 matcher/query、完整 semantic diff 和可直接使用的诊断命令。

AST-first 测试不是停留在计划：当前 Native SDK 下名称落在 CanonicalAST 的测试源码共有 19 个文件、461 个 `TEST_METHOD` 定义，其中 SemaAuthority 单文件 256 个；浮点宽度/比较/返回 ABI、Cache declaration remap、StaticJIT identity 和最新 `for` 多增量/`continue` 修复都留下了 source -> Sema -> Seal 的永久断言。但总任务 0.2 仍未完成，因为不是每一个未完成语义/Cache/JIT/CodeGen 项目都有完整 gate card；默认切换前的 0.3 全矩阵也尚未执行。详细能力矩阵和推进顺序见 `attachments/clang-ast-tooling-and-ast-first-audit-2026-08-23.md`。

第一项 Clang 工具能力地基已经落地：`as_ast_traversal` 统一表达 Decl/Type/Stmt/Expr 和命名 structural/reference edges，提供确定性 pre/post 遍历、完整 context inventory、consumer edge filter、深度/节点预算/循环保护，以及 sealed-context 的按需 parent/incoming-edge index。Verifier 的 stmt/expr cycle、兼容 flat dump 的节点 inventory 和 TypedASTJIT canonical eligibility 已迁到同一遍历；后者显式不下钻 receiver，以保持迁移前 eligibility 行为。新增坏图测试覆盖 cycle、dangling、数组 zero-ID、depth/budget，Dump 也证明 dangling edge 后仍会继续枚举后续节点。详细设计和证据见 `attachments/ast-traversal-parent-edge-index-2026-08-23.md`。这完成了 2.9，但 tree/JSON/filter dump、路径化 verifier、matcher/diff 和命令入口仍分别属于 2.10–2.13。

第二项工具能力现已落地：`asCASTStructuredDump` 在不改变旧 flat dump 的前提下提供确定性 tree text 和 JSON，支持 module/stable-key/node class+ID/kind/logical-source 精确筛选，并保留 ancestor + matched structural subtree closure。输出包含 exact canonical type/qualifier、traits、命名边、resolved target、逻辑源码位置与 opt-in bounded snippet，且显式声明 diagnostic-only/non-Cache。新增 3 个专项测试；完整 Frontend CanonicalAST + Cache ASTBodySidecar **129/129**，Standalone **21/21**。见 `attachments/structured-ast-dump-2026-08-23.md`。2.11–2.13 的 verifier path、typed matcher/full diff 和 developer command surfaces 仍开放。

第三项工具能力也已落地：所有 verifier failure site 在保持 category/detail/range 兼容的同时，提供 offending node/kind、named edge、related target、logical line/column、确定性 TU path 和 8-node/16-edge/3-depth 的局部坏图。失败 publication 不会改变 Seal、节点计数或 dump；dangling/repeated/cycle/oversized 图均有 fail-safe 行为。专项 **4/4**，Frontend CanonicalAST + Module Snapshot + Cache ExactWarmStartup **145/145**，Standalone **21/21**。见 `attachments/verifier-path-diagnostics-2026-08-23.md`。该节点尚余 2.12 matcher/full diff 与 2.13 developer commands。

第四项工具能力也已落地：测试支持层现在用强类型查询精确断言 stable Decl、QualType/qualifiers、named edge、callee/receiver、conversion、control target、cleanup 和 logical source range；`asCASTShadowDiff` 按 Source/Type/Decl/Stmt/Expr 返回第一条确定性的结构路径字段差异。代表性的 SemaAuthority dump-substring 断言已迁移；cleanup 查询按真实语义接受多个退出路径并报告 `MatchCount`。专项 **2/2**，SemaAuthority **256/256**，Frontend CanonicalAST **123/123**，Standalone **21/21**。见 `attachments/typed-ast-matchers-and-shadow-diff-2026-08-23.md`。当前 Clang-inspired AST 工具层只剩 2.13 的 lease-safe developer/commandlet `list/dump/verify/query/diff` 入口。

第五项工具能力现已落地并关闭 2.13：标准 C++ 服务、Runtime `as.AST` 控制台和 Editor commandlet 共用只读 `list/dump/verify/query/diff` 合同；每次操作只通过 V1 snapshot lease 进入 sealed graph，并在返回前释放。source build 与 Cache V2 restore provenance 来自 snapshot 发布路径；精确 query 与结构闭包 dump 明确分开，五种操作的 text/JSON 均带 diagnostic-only/non-Cache/read-only/mutation-refused 声明。专项 **3/3**，Snapshot **9/9**，Cache ExactWarm **15/15**，Standalone **21/21**，真实 commandlet list exit 0。见 `attachments/read-only-ast-diagnostics-2026-08-23.md`。至此 2.9–2.13 的 Clang-inspired AST observability 工具层全部完成；后续 P2 typed CFG/text/DOT 仍等待控制流/异常/cleanup 语义稳定，不属于本阶段。

### Fresh verification evidence

- Generic traversal/parent-index Runtime build: `Saved/Build/cta-ast-traversal-final-build/20260823_204601_678_646e312d/RunMetadata.json` — exit 0.
- Frontend CanonicalAST after traversal/verifier/dump migration: `Saved/Tests/cta-ast-traversal-final-frontend/20260823_204623_655_2d132a7c/RunMetadata.json` — 114/114 PASS.
- Complete TypedASTJIT after eligibility visitor migration: `Saved/Tests/cta-ast-traversal-final-typedast/20260823_204709_053_8c637cde/RunMetadata.json` — 64/64 PASS.
- Standalone CMake/CTest including independent `as_ast_traversal.cpp`: `Saved/StandaloneTests/cta-ast-traversal-final-standalone_01_Standalone/20260823_204912_638_e538219d/RunMetadata.json` — 21/21 PASS.
- Structured AST dump Runtime build: `Saved/Build/cta-ast-structured-dump-final-build/20260823_210842_719_7a4cb5fa/RunMetadata.json` — exit 0.
- StructuredDump focused tests: `Saved/Tests/cta-ast-structured-dump-green/20260823_210239_635_78ff3f0f/RunMetadata.json` — 3/3 PASS.
- Frontend CanonicalAST + Cache ASTBodySidecar structured-tool gates: `Saved/Tests/cta-ast-structured-dump-final-regressions/20260823_210855_491_580e3ace/RunMetadata.json` — 129/129 PASS.
- Standalone after structured AST tooling: `Saved/StandaloneTests/cta-ast-structured-dump-final-verified_01_Standalone/20260823_210942_931_36d79110/RunMetadata.json` — 21/21 PASS.
- Verifier path diagnostics Runtime build: `Saved/Build/cta-ast-verifier-diagnostics-green-build/20260823_212044_958_fc608908/RunMetadata.json` — exit 0.
- VerifierDiagnostics focused tests: `Saved/Tests/cta-ast-verifier-diagnostics-green/20260823_212109_012_246d9e15/RunMetadata.json` — 4/4 PASS.
- CanonicalAST + Module Snapshot + Cache ExactWarmStartup verifier gates: `Saved/Tests/cta-ast-verifier-diagnostics-final-gates-rerun/20260823_212444_968_8f2383c8/RunMetadata.json` — 145/145 PASS.
- Standalone after verifier enrichment: `Saved/StandaloneTests/cta-ast-verifier-diagnostics-standalone_01_Standalone/20260823_212701_178_2f31e2db/RunMetadata.json` — 21/21 PASS.
- Matcher/full-diff final Runtime build: `Saved/Build/cta-ast-matcher-diff-shadow-tests-build/20260823_214705_308_b39dda4a/RunMetadata.json` — exit 0.
- Isolated typed matcher + first semantic diff path: `Saved/Tests/cta-ast-matcher-diff-final-isolated/20260823_214812_349_86b9bd35/RunMetadata.json` — 2/2 PASS.
- SemaAuthority after typed assertion migration: `Saved/Tests/cta-ast-matcher-diff-sema-authority-rerun/20260823_214501_117_a41b4d01/RunMetadata.json` — 256/256 PASS.
- Frontend CanonicalAST after full ShadowDiff contract migration: `Saved/Tests/cta-ast-matcher-diff-frontend-canonical-rerun/20260823_214724_346_983297e2/RunMetadata.json` — 123/123 PASS.
- Standalone after host-neutral semantic diff: `Saved/StandaloneTests/cta-ast-matcher-diff-standalone_01_Standalone/20260823_214852_277_17a177ea/RunMetadata.json` — 21/21 PASS.
- Final read-only AST diagnostics Runtime build: `Saved/Build/cta-ast-diagnostics-json-commandlet-build/20260823_221836_841_803b72b9/RunMetadata.json` — exit 0.
- Lease-balanced Runtime list/dump/verify/query/diff + valid JSON: `Saved/Tests/cta-ast-diagnostics-json-focused/20260823_221900_126_99ac9048/RunMetadata.json` — 3/3 PASS.
- Snapshot and Cache-restored provenance gates: `Saved/Tests/cta-ast-diagnostics-snapshot/20260823_221229_244_6bd879f7/RunMetadata.json` — 9/9 PASS; `Saved/Tests/cta-ast-diagnostics-cache-exact-rerun/20260823_221310_198_b1bf7c45/RunMetadata.json` — 15/15 PASS.
- Host-neutral diagnostics Standalone suite: `Saved/StandaloneTests/cta-ast-diagnostics-standalone_01_Standalone/20260823_221535_824_3385b6a5/RunMetadata.json` — 21/21 PASS.
- Real Editor AST diagnostics commandlet list: `Saved/Commandlet/cta-ast-diagnostics-commandlet-list-rerun/20260823_222059_389_7c68226f/RunMetadata.json` — exit 0.

- Runtime build: `Saved/Build/cta-for-multi-increment-ast-green-build/20260823_194303_329_0a6e8044/RunMetadata.json` — exit 0.
- AST-first multi-increment regression: `Saved/Tests/cta-for-multi-increment-ast-green/20260823_194338_791_a6555453/RunMetadata.json` — 1/1 PASS.
- TypedASTJIT BytecodeIsolation symptom: `Saved/Tests/cta-typedast-bytecode-isolation-after-for-fix/20260823_194418_599_67907cd9/RunMetadata.json` — 1/1 PASS.
- Full TypedASTJIT prefix: `Saved/Tests/cta-typedast-full-after-for-fix/20260823_194507_183_29900daf/RunMetadata.json` — 64/64 PASS, zero failures/skips/timeouts.
- Other current focused gates retained by the task ledger: Cache V2 ExactWarm declaration integrity 15/15, StaticJIT canonical identity 8/8, Canonical AST migration eligibility 9/9, Backend Contract retention profile 9/9.

## Current status update — 2026-08-24 10:00

### Governing estimate

The weighted engineering estimate is now **about 89% complete** toward a safe
Canonical Typed AST production cutover. The OpenSpec checklist is **70/115 =
60.9%**. These values measure different things: the checklist intentionally
keeps broad, overlapping closure/audit tasks open until HIR retirement and the
final regression matrix, while the weighted estimate credits the already-landed
AST, Sema, CodeGen, snapshot, Cache, tooling, and consumer infrastructure.

```text
Weighted implementation  [##################--] ~89%
Mechanical checklist     [############--------]  60.9% (70/115)

Canonical architecture / focused gates     mostly landed
Full-language semantic and ABI long tail    active hardening
HIR removal + final focused/All evidence    still open
```

This supersedes the earlier 2026-08-23 `~46%` default-cutover estimate. Since
that snapshot, Canonical source `Build()` and production CodeGen have advanced
through many vertical slices, the Canonical Compiler and Frontend gates have
grown substantially, and the current work is exposing failures from the broad
Native SDK rather than still constructing the architecture.

### Fresh evidence at this checkpoint

- Latest Runtime/Editor build after the POD ownership change:
  `Saved/Build/cta-pod-owned-transfer-build/20260824_094930_233_256fe594`
  — exit 0.
- Compiler CanonicalAST:
  `Saved/Tests/cta-compiler-canonical-360-green/20260824_093143_181_52980909`
  — **360/360 PASS**.
- Frontend CanonicalAST:
  `Saved/Tests/cta-frontend-canonical-123-green/20260824_093437_553_f2093294`
  — **123/123 PASS**.
- Production Canonical CodeGen:
  `Saved/Tests/cta-production-codegen-pod-abi-green/20260824_094948_281_80e0e1c0`
  — **71/71 PASS**.
- The formerly crashing generic small-POD object return/argument ABI case is
  now isolated green: hidden-return placement and system/generic by-value
  object ownership are covered by the new focused regression, and the original
  `ObjectReturnsByAuxiliaryRegistration` fixture is **1/1 PASS**.

### Current hard blocker

The complete default-Canonical Native SDK run
`Saved/Tests/cta-native-sdk-default-canonical-after-pod-abi/20260824_095145_814_422d1f93`
does **not** pass: the process exits with code 3 after reaching Language
Expressions. The exact reproducible stopper is
`Language.Expressions.Chain.FExpressionChainTests.ShapesByDepthStateAndContext`.
Its first valid implicit-handle chain leaves a native reference object alive;
the next matrix cell trips `check(LiveObjects == 0)` in
`AngelscriptNativeExpressionChainTests.cpp:77`. The isolated reproduction is
`Saved/Tests/cta-expression-chain-isolated-red/20260824_095400_043_bf4a6b0a`.

This is a Canonical cleanup/lifetime lowering gap, not evidence that the AST
architecture must be redesigned. It is also precisely why the final cutover
and HIR-removal tasks remain open. The broad run additionally reports a set of
non-crashing mismatches in legacy bytecode-shape/diagnostic tests and genuine
Canonical language coverage. They must be classified and closed without
silently routing production compilation back through LEGACY.

### Remaining critical path

1. Add a small non-fatal AST-first/CodeGen regression for implicit-handle
   expression-chain cleanup, fix the AddRef/Release ownership plan, and rerun
   the exact Language test plus ProductionCodeGen.
2. Continue the full default-Canonical Native SDK run to reveal and close the
   next hard semantic/ABI/lifecycle gaps; distinguish obsolete LEGACY bytecode
   shape assertions from product-visible semantic failures.
3. Remove production HIR capture/builder/accessor reads after TypedASTJIT,
   Cache, dump/diagnostics, and test oracles exclusively consume the sealed
   Canonical AST. Keep LEGACY only as an explicit isolated differential path.
4. Freshly rerun Cache V2, Hot Reload, StaticJIT, Standalone Debug/Release, and
   the final All suite; then reconcile the remaining 45 task entries against
   concrete evidence. No current evidence permits checking the final cutover or
   archiving the change.

## Historical snapshot — 2026-08-23 (superseded by the updates above)

### Two complementary measures

| Measure | Current estimate | What it means |
| --- | ---: | --- |
| OpenSpec task-list completion | **59 / 105 = 56.2%** | Mechanical count of checked task entries. It includes foundations, experiments, documentation, and evidence gates, so it must not be read as replacement readiness. |
| Real default-cutover completion | **about 44%** | Progress toward making Canonical Typed AST the normal, production-safe replacement for the legacy `asCScriptNode` + `asCCompiler` compile path. This is deliberately the governing number. |

### What moved the needle most recently

- Canonical `++` / `--` now preserves pre/post semantics for supported primitive local `int`/`uint` operands; Sema records their resolved form and production bytecode CodeGen emits it. Focused Sema-authority and production-CodeGen tests pass.
- Cache V2 Sidecar capture is now a held-snapshot consumer rather than a raw-context borrower. A red/green executable source contract, Standalone **21/21**, Runtime build, and ASTBodySidecar+ExactWarm **16/16** prove the lease change did not alter the pointer-free V2 artifact or zero-frontend warm restore behavior.
- The canonical emitter no longer lets a module containing only an uninitialized global appear to compile successfully while publishing nothing. A valid declaration-only global is now published with AngelScript's language-default storage (for example, `int G` becomes zero-initialized).
- Cache V2 exact warm startup now proves that the restored public AST snapshot contains a usable body tree rather than only a non-null/synthetic root: `TranslationUnit -> FunctionDecl Answer -> CompoundStmt -> ReturnStmt -> IntegerLiteral 42`. The exact-warm group passes **6/6**.
- Mutable integer globals now use property-owned Canonical init functions across
  all supported 1/2/4/8-byte integer widths. The `uint64` maximum-value
  lifecycle regression proves parse, initialization, `RDR8` load, external
  mutation, and `ResetGlobalVars()` restoration; ProductionCodeGen is
  **64/64** after the current automatic-import, candidate-rebuild, and
  regressions. This remains a bounded lifecycle slice, not general global-init
  or default-cutover completion.
- Candidate script functions, property-owned global initializer functions,
  imports, global properties, and script object types now remain outside their
  engine/module publication tables until the artifact `Commit()` boundary.
  Global candidates retain only stable `LDG` storage while emitting; script
  types resolve through an artifact-local runtime-type view. Commit validates
  type names and LIFO slot plans, installs types and then `varAddressMap`
  before function `AddReferences()`, and publishes the rest. A direct
  `Generate()` failure regression proves that a rejected mutable-global +
  `try/catch` candidate restores module/engine function and property tables
  without relying on `Build()`'s later reset; the 12-case transaction matrix
  and ProductionCodeGen **64/64** pass after type deferral. The remaining
  transaction breach is old-module reset/replacement above CodeGen plus
  unsupported funcdef/full-language forms, so this still does not close 9.1
  or 13.6.
- Canonical rebuilds now stage a fully separate, engine-unregistered candidate
  owner and promote it into the existing public module object only after
  successful CodeGen commit. A failed rebuild therefore keeps the old
  executable generation; successful function and same-name script-type
  replacement preserve the public module pointer while replacing the
  generation. Focused evidence is **3/3 PASS**.
- Automatic imports now have a deliberately narrow safe bridge for explicit
  qualified script-function calls and unique, explicit-namespace script-global
  reads. The global route projects only a provider-owned declaration, emits no
  duplicate consumer slot, and records an exact `asCGlobalProperty` reference
  for each bytecode global-address instruction. The focused regression proves
  provider `Discard()` + forced GC, continued consumer execution, then consumer
  discard and final map reclamation; ProductionCodeGen is **64/64** and the
  Cache ASTBodySidecar+ExactWarm group is **16/16**. This does not claim broad
  import/global support: ambiguous names remain fail-closed, and richer writes,
  initializer forms, reload-generation and Cache DTO semantics are still open.
- The current full native SDK execution is **1208/1218** rather than green.
  Its ten failures are tracked Canonical-coverage/compatibility gaps: eight
  compile-to-retained-snapshot forms (mixin, qualified parameter/method,
  fallthrough, enum, and namespace-global shapes), enum-alias target metadata,
  and the still-undecided original-fork `typedef` boundary. The new
  provider-global lifetime path is exercised by the focused test and none of
  those ten failures reaches it. This limits the cutover estimate to **about
  44%** until the broad native suite is restored.
- Cache V2's AST sidecar / Exact Startup / root-class / class-inheritance
  retention bundle remains green after the module-promotion work (**18/18**).
  Separately, the new source-build failed-replacement test proves a held
  snapshot lease stays current and a new acquire reports the same generation.
  The public snapshot group also runs its existing 64-generation concurrent
  Acquire-vs-publish stress case and is currently **9/9 PASS**. These are
  bounded lease guarantees, not a reason to close the full snapshot protocol
  gate.

### Why this is not yet a default switch

The normal production route still depends on the legacy builder/compiler protocol for broad language coverage and bytecode assembly. The remaining critical work is to make Canonical Sema authoritative for ordinary declarations and bodies, complete detached/transactional production CodeGen over the real language surface, preserve module/import/global lifecycle and diagnostics, expand Cache V2 fidelity evidence beyond the simple function case, and only then make Canonical the default under cutover gates. Therefore the new tests increase confidence in individual vertical slices but do not justify marking sections 10 or 13 complete.

## Current status update — 2026-08-24 12:46

### Governing estimate

The weighted engineering estimate is now **about 92% complete** toward a safe
Canonical Typed AST production cutover. The strict OpenSpec checklist remains
**70/115 = 60.9%** because the broad HIR-retirement, full-language, final
matrix, and removal/audit tasks intentionally stay open until their entire
sentences are proven.

```text
Weighted implementation  [##################--] ~92%
Mechanical checklist     [############--------]  60.9% (70/115)

Canonical AST/Sema/CodeGen core       substantially implemented
Focused AST-first + production gates  green for the closed slices
Non-HIR Compiler long tail            7 current failures
HIR oracle migration/removal          52 obsolete-HIR Compiler failures
Final subsystem/All verification      still pending after cleanup
```

### What closed since the previous checkpoint

- Funcdef call Sema now records the signature result rather than the funcdef
  handle type; SemaAuthority reached **263/263** and ProductionCodeGen
  **73/73**.
- Temporary property/index receivers, object-handle return transfer,
  `class`/`struct` type kind, native VALUE identity, and qualified script type
  lookup closed their focused AST-first and execution gates. Complete
  SemaAuthority reached **264/264**, ProductionCodeGen **73/73**, and
  CanonicalAST **365/365** at that checkpoint.
- Cross-section forward calls now survive later-section declaration binding;
  provisional ERROR Cleanup ownership is removed before Seal. The new
  CANONICAL AST + execution test and explicitly LEGACY Builder protocol test
  are **2/2 PASS**:
  `Saved/Tests/cta-cross-section-final-gates/20260824_124159_096_79d8d67f`.
- The current Runtime/Editor build is green:
  `Saved/Build/cta-cross-section-explicit-routing-build/20260824_124141_210_5ba1271f`.

### Current broad Compiler truth

`Saved/Tests/cta-compiler-post-cross-section/20260824_124251_451_d7324c8d`
is **497/556 PASS**. The former cross-section failure is gone and the new test
raises the discovered total by one. The remaining 59 failures are:

- **52 historical TypedSemanticIR/HIR tests.** Canonical is now the default
  source pipeline and deliberately does not publish HIR. Useful semantic
  assertions must move to Canonical AST / differential gates; obsolete HIR
  assertions and production APIs then leave under Task 10.5.
- **7 non-HIR tests.** One Builder layout case, four bytecode
  generation/optimization-internal cases, and two diagnostic behavior cases.
  These require either explicit LEGACY routing for private bytecode protocol
  coverage or a genuine Canonical semantic/diagnostic fix after isolation.

### Remaining critical path

1. Classify and close the seven non-HIR Compiler failures without weakening
   Canonical production provenance.
2. Migrate the useful 52 HIR oracles to sealed Canonical AST/differential
   tests, delete obsolete HIR-only coverage, then remove production HIR
   capture/builder/accessors.
3. Audit and remove residual production semantic dependence on
   `asCScriptNode`; keep LEGACY only as explicit comparison/compatibility flow.
4. Freshly run Compiler/Native SDK, Cache V2, Hot Reload, StaticJIT,
   TypedASTJIT, Standalone Debug/Release, and All; reconcile all 45 open tasks
   against concrete evidence.

This checkpoint does not check a broad task merely because one more slice is
green, and it does not authorize archive/commit.

## Current status update — 2026-08-24 16:31

### Corrected governing estimate

The current weighted delivery estimate is **about 67% complete**. The strict
OpenSpec checklist is still **70/115 = 60.9%**. This estimate supersedes the
earlier 89%/92% estimates: those snapshots credited the amount of implemented
infrastructure and focused vertical slices too heavily, while underweighting
the remaining cross-Engine Cache transaction, full-language parity, HIR
retirement, production cutover, and final subsystem matrix.

```text
Weighted delivery readiness [#############-------] ~67%
Mechanical checklist        [############--------] 60.9% (70/115)

AST/Sema/tooling foundation             substantially landed
Canonical production CodeGen            broad, but still hardening
Cache V2 cross-Engine restore            active blocker
HIR retirement + final cutover           not yet started as a safe deletion
Final focused/Standalone/All evidence    pending
```

### Progress since the 12:46 checkpoint

- Cache V2 exact-warm V3 mutation and AST sidecar gates are green:
  FunctionBody **5/5**, ASTBodySidecar **12/12**, ExactWarm **15/15**.
- Canonical Cache restore is now called from the detached CodeGen artifact
  path rather than being reconstructed after publication. Focused restore is
  **3/3**, compiler dependency capture is **2/2**, and the script-reference
  layout AST gate is **1/1**.
- Generated lifecycle Sema/CodeGen now records default member construction,
  stable constructor/destructor identities, factory/constructor/destructor/
  `InitDefaults` dependencies, and local value-object destructor dependencies.
  The focused AST + generated-dependency bundle is **2/2 PASS**.
- Invocation-family parity advanced past producer artifact encoding. The
  previous failure was an omitted local destructor dependency; after repairing
  that dependency, the test now reaches a real second-Engine restore.

Fresh evidence:

- `Saved/Tests/cta-cache-exact-warm-v3-mutation-green/20260824_151950_854_01260e11`
- `Saved/Tests/cta-canonical-cache-restore-hook-green/20260824_153415_182_1bd6805e`
- `Saved/Tests/cta-canonical-cache-compiler-dependency-green/20260824_154635_898_d6d5f199`
- `Saved/Tests/cta-canonical-default-member-and-dtor-gates-v2/20260824_162204_547_7984909c`
- `Saved/Build/cta-canonical-local-destructor-dependency-build/20260824_162457_951_adb463e2`

### Current exact blocker

`Saved/Tests/cta-cache-invocation-family-parity-v4/20260824_162511_559_d8fc8641`
is **0/1**. The producer artifact is valid, but the consumer cannot resolve
`FParityLeaf`, `FGeneratedParityOwner`, and other candidate types/functions
while restoring the artifact. These symbols are intentionally detached from
the module and Engine publication tables until `Commit()`, as required by the
transaction/rollback contract. Publishing them early would make the test pass
for the wrong architectural reason and reopen partial-state leaks on failure.

The next implementation slice is therefore a transaction-local candidate
symbol view used only by the artifact reader during restore. It must resolve
candidate types, functions, globals, constructors, destructors, and factories
without making them visible through normal module/Engine tables, and it must be
cleared on every success/failure exit before or as atomic commit completes.

```text
producer Engine
  sealed AST -> detached CodeGen artifact -> Cache records       GREEN
                                              |
                                              v
consumer Engine                         artifact reader
                                              |
                 public module tables --X    |  candidate not committed yet
                                              v
                          transaction-local candidate view      NEXT
                                              |
                                              v
                                      validate -> atomic Commit
```

### Remaining critical path

1. Implement and prove the transaction-local Cache restore resolver; make the
   invocation-family artifact/parity bundle green across two Engines.
2. Close Cache V2 full DTO/remap and incremental invalidation/atomic activation
   requirements (Tasks 6.3, 6.6, 13.9), then rerun the complete Cache prefix.
3. Finish canonical value/temporary/container/delegate/lambda/global/import/
   exception/debug-metadata coverage and broad differential execution (9.5–9.7).
4. Move every remaining TypedASTJIT/test/dump consumer off HIR, remove the
   production HIR capture/builder/accessors, and audit production semantic
   `asCScriptNode` reads. LEGACY remains only an explicit differential path.
5. Run the cutover matrix across source Build, Hot Reload, CompileFunction,
   generation, commandlet, Standalone, Cache, StaticJIT, Native SDK, and All;
   only then switch the default and reconcile the final OpenSpec tasks.

The current direction remains sound. The active failure is a transaction
boundary problem revealed by deeper integration coverage, not a reason to
discard the Canonical Typed AST architecture.

## Current status update — 2026-08-24 18:05

### Governing estimate after Cache V2 deferral

The current weighted delivery estimate is **about 70% complete**. The strict
OpenSpec checklist is **77/119 = 64.7%**. This checkpoint supersedes the 16:31
67% estimate because Cache V2 cross-Engine restore and function-granular reuse
are now explicitly outside this compiler change's completion boundary. The
estimate does not jump higher because `CompileFunction`, HIR retirement,
Parser/Sema authority, and the final subsystem matrix remain substantial work.

```text
Weighted delivery readiness [##############------] ~70%
Mechanical checklist        [#############-------] 64.7% (77/119)

default product path
  .as source
      |
      v
  Preprocessor -> Parser/current syntax tree -> Canonical Sema/AST
                                               |
                                               v
                                 sealed + verified module snapshot
                                               |
                                               v
                                  asCBytecodeCodeGen -> VM Bytecode

  Cache V2 = OFF by default
      X ExactStartup / cross-Engine restore
      X source/Hot Reload capture publication
      X shutdown persistence

explicit comparison/prototype paths
  LEGACY compiler       retained for comparison and compatibility
  Cache V2 opt-in       retained for focused prototype tests only
```

### What changed in this checkpoint

- `UAngelscriptCacheSettings::bEnableCacheV2` and the host project default are
  false. Each Engine freezes the setting/explicit override at construction.
- Disabled Cache V2 is a complete lifecycle bypass: no ExactStartup restore,
  initial-compile capture, Hot Reload capture, or shutdown persistence. Source
  compilation and module/function publication remain authoritative.
- Cache lifecycle fixtures that actually test the prototype now opt in per
  Engine. The known incomplete cross-Engine invocation-family test remains in
  source but is Disabled under `#cache-v2-redesign`.
- The OpenSpec now treats the dormant Cache sidecar/restore work as retained
  prototype evidence, not a canonical compiler cutover gate. A later Cache V2
  redesign must redefine its own artifact, authority, transaction, remap, and
  incremental-reuse contracts.
- Canonical generated handle construction/access exposed and closed a real VM
  ABI issue during validation: null-handle types now cross the runtime bridge
  as null handles (not primitive void), pointer-sized locals use `AS_PTR_SIZE`,
  and VALUE-method `this` dereferences the receiver frame slot before accessing
  the actual object. Temporary raw-bytecode diagnostics were removed.

Fresh evidence:

- Cache default-off lifecycle: **7/7 PASS** —
  `Saved/Tests/cta-cache-default-off-final/20260824_180600_350_09993273`.
- Final 164-action Editor/plugin rebuild after record/header cleanup: **PASS** —
  `Saved/Build/cta-cache-default-off-final-build/20260824_180259_671_c0f8af9e`.
- Generated handle accessor execution: **1/1 PASS** —
  `Saved/Tests/cta-handle-accessor-clean/20260824_175924_680_b64e759b`.
- Complete Canonical ProductionCodeGen gate: **73/73 PASS** —
  `Saved/Tests/cta-production-codegen-after-cache-default-off/20260824_180006_261_0e8d1bdd`.
- OpenSpec validation and parent/plugin `git diff --check`: **PASS** after this
  checkpoint (line-ending conversion warnings only).
- The complete Cache prefix attempt is **inconclusive**, not a pass/fail result,
  because the long SemanticDiff run outlived the 15-minute outer execution and
  produced no final summary:
  `Saved/Tests/cta-cache-default-off-full/20260824_170448_409_c9835ec2`.

### Weighted interpretation

The ~70% figure is an engineering-readiness estimate, not just checked boxes:

| Area | Current reading |
|---|---|
| Canonical AST context, types, verifier, snapshots, public/tooling foundation | largely implemented |
| Module `Build()` canonical Sema/CodeGen and focused VM execution | broad and green for the 73-case production gate |
| Sema ownership of the complete language | incomplete; substantial semantic walks still consume `asCScriptNode` |
| `CompileFunction` and every production entry point | incomplete; public single-function compile still routes through legacy `BuildCompileCode` |
| TypedASTJIT/dump/test migration and HIR deletion | incomplete; production/editor readers and historical HIR tests remain |
| Full-language/subsystem/Standalone/All evidence | not freshly closed after final cleanup |
| Cache V2 cross-Engine/incremental prototype | deferred and default-off; no longer counted against this change |

### Remaining critical path

1. Make Parser-to-Sema actions and the canonical graph authoritative for the
   remaining declaration/expression/statement/lifetime forms, then eliminate
   production semantic dependence on `asCScriptNode`.
2. Route public `CompileFunction` and the remaining build purposes through the
   same sealed-AST CodeGen/publication contract, while preserving retained
   module snapshot completeness.
3. Move TypedASTJIT, HIR dump, and useful historical semantic oracles to
   canonical Decl/Type/Stmt/Expr views; remove production HIR capture,
   builders, accessors, and obsolete HIR-only tests.
4. Close debug/coverage/safe-point/exception/cleanup metadata and remaining
   language-form differential coverage without weakening AST-first gates.
5. Run fresh Frontend/Compiler/Runtime/Module/TypeSystem/Language/Embedding/
   Conformance, Hot Reload, StaticJIT/TypedASTJIT, Standalone Debug/Release,
   and All gates with Cache V2 at its product-default disabled setting.

The implementation direction is still sound: the new AST is already a real
sealed production input for source-module Bytecode generation, not merely a
dump-only sidecar. It is not yet the sole semantic/compiler representation,
which is why the honest completion estimate remains near 70% rather than the
earlier 90% range.

## 2026-08-24 20:00 status checkpoint: StaticJIT canonical boundary and current percentage

This checkpoint records the answer to the follow-up progress question after
the StaticJIT generation-boundary, public `CompileFunction`, PreClass layout,
and canonical power-lowering slices. Cache V2 redesign remains explicitly out
of scope and the product default remains disabled.

```text
Functional implementation      [###############-----] ~75%
Archive/closure readiness       [#############-------] ~65%
Mechanical OpenSpec checklist   [#############-------] 64.7% (77/119)

source build / public CompileFunction
              |
              v
 Parser -> Sema -> sealed + verified Canonical AST
                         |                 |
                         |                 +--> StaticJIT generation
                         |                      (canonical snapshot;
                         |                       no production HIR capture)
                         v
                 Canonical Bytecode CodeGen
                         |
                         v
                        VM

 LEGACY ------------------------------> isolated comparison/opt-out
 HIR production fallback --------------> still being removed
 Cache V2 -----------------------------> OFF; redesign deferred
```

### Newly closed or strengthened since the ~70% checkpoint

- Public `CompileFunction` now uses the canonical Parser/Sema/seal/CodeGen
  path for supported functions, including current-module functions/globals,
  exact binding, failure atomicity, and nested lambda coverage.
- Canonical Sema now retains exact `PreClassData` property layout consumed by
  CodeGen instead of asking the old compiler to rediscover it.
- StaticJIT generation explicitly requests and leases the verified canonical
  snapshot. It no longer enables typed-HIR capture, and its clean generation
  snapshot is prepared independently of whether Cache V2 is enabled.
- Canonical Bytecode CodeGen now lowers `**` and `**=` across double, float,
  signed, and unsigned integer forms instead of falling back to legacy
  emission for those expressions.

Fresh focused evidence is green:

- Canonical AST migration adapter: **14/14 PASS** —
  `Saved/Tests/cta-staticjit-canonical-adapter-green/20260824_193911_634_5986040a`.
- Project generation Engine regression: **32/32 PASS** —
  `Saved/Tests/cta-staticjit-project-generation-engine-regression/20260824_193949_369_7d5187fe`.
- StaticJIT backend contract: **9/9 PASS** —
  `Saved/Tests/cta-staticjit-canonical-capture-backend-contract/20260824_192527_873_28b06d3d`.
- Cache-independent StaticJIT generation profile: **1/1 PASS** —
  `Saved/Tests/cta-staticjit-generation-cache-independent-green/20260824_193223_982_5151b670`.
- Project source graph: **2/2 PASS** —
  `Saved/Tests/cta-staticjit-canonical-source-graph-green/20260824_193311_313_a3f15b53`.
- HIR dump compatibility gate: **5/5 PASS** —
  `Saved/Tests/cta-staticjit-canonical-hir-dump-compat/20260824_193354_256_b8f4c04e`.
- Runtime/Editor build after canonical power lowering: **PASS** —
  `Saved/Build/cta-canonical-pow-codegen-build/20260824_193848_456_16dd52db`.
- OpenSpec validation and parent/plugin `git diff --check`: **PASS** at this
  checkpoint; only existing LF/CRLF conversion warnings were printed.

### Why the honest number is ~75%, not 90%+

The remaining work is concentrated in the final authority/cutover boundary,
not in AST container scaffolding. Runtime and Editor source still contain 82
textual HIR-related references (`VerifiedTypedHIR`, `TypedHIR`, capture flags,
or `GetTypedSemanticFunction()`); many are legacy tests, comparison helpers,
and compatibility diagnostics rather than live production reads, but the
production TypedASTJIT input/fallback surface has not yet been physically
removed. Open declaration/expression/control/lifetime Sema tasks also mean the
sealed AST is not yet the sole semantic authority for the complete language.

The next critical slice is therefore to make HIR-only TypedASTJIT input fail
closed as `MissingCanonicalAST`, remove HIR visibility from the official
generation/backend graph, retain any still-useful LEGACY oracle only behind an
explicit comparison/test boundary, and then run the focused StaticJIT and
canonical migration gates. After that, the remaining large milestones are
complete language-form Sema/CodeGen coverage, default canonical cutover,
physical HIR builder/accessor deletion, and the broad/final verification
matrix.

## 2026-08-24 20:16 status checkpoint: TypedASTJIT production is canonical-only

```text
Functional implementation      [###############-----] ~77%
Archive/closure readiness       [#############-------] ~66%
Mechanical OpenSpec checklist   [#############-------] 64.7% (77/119)

sealed canonical AST + exact DeclId
                |
                +--> production eligibility / closure / backend
                +--> generation snapshot / deterministic dump

valid legacy HIR only ------------------------------X fail closed
explicit unit-test legacy oracle -------------------> comparison only
```

The previous checkpoint's next critical slice is now materially closed:

- A valid HIR-only production eligibility fixture first failed because the old
  evaluator accepted it, then turned green after the production input became
  canonical-only.
- Official generation/backend function structures no longer expose a HIR
  pointer. The generation snapshot never enables HIR capture and reports the
  old compatibility diagnostic as false.
- The Editor generation dump keeps its external compatibility name but now
  captures and emits only deterministic sealed canonical AST. It has no HIR
  include, accessor call, verifier, normalization, or JSON payload.
- Legacy HIR capability analysis remains behind both
  `WITH_ANGELSCRIPT_UNITTESTS` and an explicit selection flag; absence of
  canonical AST no longer activates it implicitly.

Fresh evidence:

- Final incremental build after source-format cleanup: **PASS** —
  `Saved/Build/cta-typedastjit-canonical-only-boundary-final/20260824_201841_677_d464db6d`.
  The earlier full boundary build also passed at
  `Saved/Build/cta-typedastjit-canonical-only-boundary-green/20260824_201135_718_018eeb30`.
- HIR-only fail-closed AST gate: **1/1 PASS** —
  `Saved/Tests/cta-typedastjit-hir-only-canonical-boundary-green/20260824_201223_246_c086bd99`.
- CanonicalASTMigration: **15/15 PASS** —
  `Saved/Tests/cta-canonical-ast-migration-hir-boundary-green/20260824_201406_981_1393251d`.
- TypedASTJIT eligibility and call closure: **30/30 PASS** —
  `Saved/Tests/cta-typedastjit-eligibility-canonical-only-green/20260824_201455_992_15ecd17d`.
- Canonical payload dump compatibility: **5/5 PASS** —
  `Saved/Tests/cta-hirdump-canonical-ast-payload-green/20260824_201301_355_88739bd8`.

The percentage rises only modestly because Task 10.5 still requires physical
removal of the compiler HIR builder/storage/accessors and migration or deletion
of historical HIR/cache tests. Complete-language Sema authority, remaining
production entry-point cutover, and the broad final verification matrix also
remain open. Cache V2 redesign remains excluded and default-off.

## 2026-08-24 20:27 checkpoint: canonical provenance transaction is trustworthy

Task 13.1 is closed. The existing legacy-compiler invocation diagnostic was
correct at the point of construction but lost its value when a successful
canonical candidate module was promoted. A focused candidate-transaction gate
failed `0/1`, then passed `1/1` after promotion began publishing the count with
the bytecode publisher and sealed-AST digest.

Fresh gates:

- candidate provenance RED:
  `Saved/Tests/cta-canonical-provenance-promotion-red/20260824_202357_991_fb950ceb`
  — `0/1 PASS` for the expected lost-count assertion;
- candidate provenance GREEN:
  `Saved/Tests/cta-canonical-provenance-promotion-green/20260824_202456_421_4f9e1ac8`
  — `1/1 PASS`;
- Cutover: `12/12 PASS` —
  `Saved/Tests/cta-canonical-cutover-provenance-green/20260824_202535_661_f1a8665b`;
- ProductionCodeGen: `73/73 PASS` —
  `Saved/Tests/cta-production-codegen-provenance-green/20260824_202622_028_7c52130e`;
- build: PASS —
  `Saved/Build/cta-canonical-provenance-promotion-green-build/20260824_202442_493_e2298e79`.

Mechanical OpenSpec progress is now `78/119` (`65.5%`). The functional
estimate remains approximately `78%`: this closes a serious audit blind spot,
but complete-language Sema authority and physical HIR/parser-node removal are
still the dominant remaining work.
## 2026-08-24 — historical UE staged primary compiler RED audit

- A new real-primary-engine gate starts `FAngelscriptEngine`, compiles the
  temporary project source, finds its active source module, and requires
  `CANONICAL_CODEGEN` with zero `asCCompiler` invocations.
- RED is confirmed: the full PrimaryCanonicalASTGenerate group is **9/10 PASS**
  with the new method as the only failure. The UE four-stage compiler still
  calls `asCBuilder::BuildCompileCode()` in Stage 3 and publishes the retained
  AST only after legacy Bytecode has been emitted.
- At this historical RED point Task 13.1 was reopened. The native
  `asCModule::Build()` and public
  `CompileFunction()` provenance work remains valid, but it is not evidence for
  the separate UE batch compiler. Tasks 10.1, 10.4, and 13.6 remain blocked on
  a staged canonical CodeGen contract.
- Evidence and the implementation boundary are recorded in
  `attachments/ue-staged-primary-canonical-publisher-gate-2026-08-24.md`.

This RED is superseded by the prepared-module Stage 3 repair and closure audit.
The current real-primary group is **12/12 PASS** at
`Saved/Tests/cta-primary-staged-canonical-current-audit/20260825_010544_185_5bfff802`;
Task 13.1 is checked and the authoritative closure is recorded in
`attachments/canonical-provenance-closure-audit-2026-08-24.md`.

## 2026-08-25 checkpoint: architecture is mostly formed; closure work remains

The user-facing answer needs three separate percentages because they measure
different things:

```text
AST/compiler architecture shape [#################---] ~85-90%
Functional delivery readiness   [################----] ~78%
Mechanical OpenSpec checklist   [#############-------] 65.5% (78/119)
```

The first number says that the major components and their ownership boundaries
now exist. It does not mean the compiler change can be archived. The strict
checklist remains unchanged by the object-iterator slice because Tasks 5.7,
5.8, 9.5, 13.2, and 13.6 are full-language umbrella items and are not honestly
complete from one newly green language family.

### What is already structurally in place

```text
.as source
    |
    v
Lexer / incremental Parser actions
    |
    v
Canonical Decl / Type / Stmt / Expr arena
    |
    v
Sema: symbols, types, calls, layouts, control and selected lifetimes
    |
    v
Seal + verifier + immutable snapshot/public debug view
    |
    v
detached Canonical CodeGen candidate -> atomic publication -> VM Bytecode
    |
    +--> canonical-only TypedASTJIT generation boundary

LEGACY -----------------> explicit comparison/opt-out path
HIR --------------------> production boundary removed; physical remnants pending
Cache V2 ---------------> default OFF; redesign deferred outside completion gate
```

The arena/type system, source model, typed nodes, Sema action framework,
verifier, deterministic dump/public view, snapshot retention, detached
CodeGen transaction, module `Build()`, public `CompileFunction`, and
canonical-only TypedASTJIT boundary are real implementations rather than empty
interfaces. Canonical CodeGen already executes a broad focused subset with
publisher provenance and zero legacy compiler invocations.

### Newly closed semantic slice

Value-object foreach iterators now own an exact fourth `scope-exit` cleanup
phase. Sema seals the exact generated iterator and destructor; the verifier
rejects forged cleanup graphs; CodeGen performs trait-gated storage copy,
emits cleanup for natural/transfer exits, and prevents double destruction.
Final evidence is SemaAuthority **276/276** and complete CanonicalAST
**392/392**, with an incremental Editor/plugin build PASS. Full evidence is in
`attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

### What the remaining tasks actually do

1. **Complete semantic authority (4.x, 5.x, 13.2).** Fill every remaining
   declaration, type, overload/call, conversion, single-evaluation, control,
   lifetime, container, delegate, closure, global/import, exception, and
   suspend form. Remove remaining semantic decisions that still walk
   `asCScriptNode`.
2. **Complete the production backend (9.x, 13.6).** Lower all those sealed
   forms, publish debug/coverage/safe-point/exception/cleanup/stack metadata,
   expand detached transaction coverage, and run broad differential behavior
   against LEGACY.
3. **Retire old semantic representations (7.x, 10.5, 10.6).** Finish every
   canonical TypedASTJIT consumer, migrate or delete historical HIR-only
   tests/tools, physically remove HIR builder/storage/accessors, and stop using
   `asCScriptNode` as a production semantic body. LEGACY may retain its own
   isolated syntax/compiler internals for comparison.
4. **Cut over every production entry point (10.x).** Native module `Build()`,
   public `CompileFunction`, the real UE staged primary compiler, and real Hot
   Reload now have canonical publisher evidence. Prove generation, commandlet,
   and Standalone through their actual host entry points before changing the
   default.
5. **Harden snapshots and external contracts (3.4, 11.4, 13.8, 13.10).** Prove
   atomic acquire/publish races, failed-publication last-good behavior,
   SourceManager truth, generation leases, retention timing, and embedding API
   compatibility.
6. **Close the gates (0.x, 12.x, 13.11, 13.12).** Retain an AST-first card for
   every semantic slice, add adversarial graph/transaction/concurrency tests,
   run every focused subsystem, Standalone Debug/Release, and finally the All
   suite.

Cache V2 restore, incremental reuse, and cross-Engine recovery are not in this
critical path. The feature is default-disabled and is expected to be redesigned
later; only the default-off boundary must remain healthy.

### Performance interpretation

The architecture work should not be advertised as an immediate speedup. On
equivalent Bytecode, VM runtime should be close to LEGACY, while current cold
compile latency and retained-snapshot memory are likely worse because the new
pipeline performs explicit Sema, verification, detached publication, and
optional retention. Its material advantage is that incremental analysis,
shared optimization passes, TypedASTJIT/AOT, and a possible LLVM lowering can
consume one verified semantic source. The measurement plan and exact
non-claims are recorded in
`attachments/canonical-ast-performance-assessment-2026-08-25.md`.

## 2026-08-25 checkpoint: the architecture is nearly formed; later tasks are closure work

The current status should be read on three different axes:

```text
AST/compiler architecture shape [##################--] ~88-90%
Functional delivery readiness   [################----] ~78-80%
Mechanical OpenSpec checklist   [#############-------] 65.5% (78/119)
```

The architecture percentage is high because the main ownership chain already
exists and executes real code:

```text
.as
 |
 v
Lexer / incremental Parser actions
 |
 v
Canonical Decl + Type + Stmt + Expr
 |
 v
Sema facts and explicit lifetime/control plans
 |
 v
Seal + verifier + immutable snapshot/debug view
 |
 v
detached Canonical CodeGen -> atomic publication -> VM
 |
 +--> canonical-only TypedASTJIT / generation consumers
```

The remaining tasks are not a second AST redesign. They are six closure
families:

1. complete the language surface in Sema and CodeGen, especially uncommon
   declaration, conversion, call, lifetime, container, closure, import,
   exception, suspend, and generated-body forms;
2. remove remaining production semantic walks over `asCScriptNode`;
3. physically remove HIR builder/storage/accessors after migrating or deleting
   the remaining historical HIR tests and tools;
4. prove the remaining generation, commandlet, and Standalone entry points and
   only then consider the reversible default switch;
5. close debug/coverage/source/safe-point/cleanup metadata, snapshot races,
   failed publication, and embedding/public API contracts;
6. run focused subsystem, Standalone Debug/Release, and final All validation.

The real UE staged primary gate is now **12/12 PASS**. Hot Reload also has a
real canonical publisher and rollback gate: focused **1/1 PASS**, complete
HotReload CanonicalAST **6/6 PASS**. See
`attachments/canonical-hotreload-publisher-gate-2026-08-25.md`.

Cache V2 restore/cross-Engine work is deliberately not part of this critical
path. It remains default-off and deferred for redesign; only the default-off
boundary must stay healthy.

## 2026-08-28 CTA-S40 checkpoint: leaf statement authority

Expression statements, returns, break, continue and fallthrough now publish
through one pointer-free `asSLeafStatementAction`. Return conversion and
value-object transfer cleanup no longer live in `ActOnStmtFromNode`; the five
leaf semantic cases are physically gone from both generic statement adapters.
Native statement nodes remain for syntax/recovery and LEGACY.

Evidence is focused **17/17**, SemaAuthority **380/380**, and ProductionCodeGen
+ Canonical Semantics + native ScriptNode **158/158**. No umbrella checkbox
closes, so the mechanical ratio remains **87/125 (69.6%)**. Weighted delivery
is now **about 71%**, safe default readiness **about 44%**, and action-only
Sema **about 88%**.

The next authority boundary is ordered Block/If construction. Current compound
assembly only re-identifies already-published leaf statements, but still does
so through native child kind/range; loop/switch control-stack setup also
remains node-based. These are recorded, open dependencies rather than hidden
fallback claims.

## 2026-08-28 CTA-S41 checkpoint: Block/If typed assembly

Block and If construction now use pointer-free typed actions. Blocks own the
exact ordered `StmtId` sequence and explicitly flatten local-declaration
carriers; If owns the exact condition `ExprId` and then/else `StmtId`s.
Completed Block/If semantics no longer pass through `ActOnParsedStmt` or
`ActOnStmtFromNode`.

The first full SemaAuthority run was **368/383** and correctly exposed a
transition bug: remaining loop/switch adapters publish an early stub whose end
range grows after parsing the body. Binding their already-published ID by the
unique kind/owner/file/start coordinate repaired the 15 regressions. Final
evidence is focused **8/8**, failed-case recheck **15/15**, SemaAuthority
**383/383**, and downstream **158/158**. Full details are in
`attachments/canonical-block-if-typed-action-gate-2026-08-28.md`.

No umbrella checkbox closes, so mechanical progress remains **87/125
(69.6%)**. Weighted delivery is now **about 72%**, safe default readiness
**about 45%**, and action-only Sema **about 91%**. The default remains LEGACY.
The next milestone is typed loop/foreach/switch/case actions and deletion of
the temporary start-coordinate control identity bridge.

## 2026-08-28 CTA-S42 partial checkpoint: loop/foreach control identity

While, do-while, for and foreach have crossed the two-phase typed-action
boundary. Sema now creates the exact loop target at header completion, before
the body, and the typed finish action updates that same statement's complete
range and exact semantic phases. For multi-increment order is frozen in a Sema
`SequenceExpr`; foreach variables/range/body are exact IDs and protocol
selection remains entirely in Sema.

The old `ActOnForStmtFromNode` is physically removed, and completed
`snFor`/`snForEach` semantics are absent from the generic node adapters. Native
AST construction and the LEGACY compiler remain intentionally available.

Evidence is while/do focused **12/12**, for/foreach new **3/3**, for/foreach
regression **10/10**, and final SemaAuthority **389/389**, all PASS. Exact paths
and RED/build evidence are in
`attachments/canonical-loop-foreach-typed-action-gate-2026-08-28.md`.

The mechanical ratio stays **87/125 (69.6%)** because the control/lifetime
umbrella is still open. Weighted delivery is **about 73%**, safe default
readiness **about 46%**, and action-only Sema **about 95%**. CTA-S42 next moves
to switch/case/default and then removes the temporary control identity bridge.

## 2026-08-28 CTA-S42 completion checkpoint: switch/case/default

Switch/case/default construction is now action-only. Parser publishes an exact
switch header identity before the body, exact ordered case/default identities
and children during parsing, and one exact switch finish action. Sema owns
case-parent validation, default/value shape, switch safe points, break targets
and fallthrough-to-next-case wiring. Completed native switch/case nodes are not
semantic input.

The bounded control transition bridge is gone: `BeginParsedControl` and
`FindStatementActionIdentity` have been physically removed. Native AST remains
for syntax/recovery, explicit LEGACY, reference and differential use.

Evidence is build PASS, focused **3/3**, regression **10/10**, SemaAuthority
**392/392**, and downstream **158/158**. Details and exact paths are in
`attachments/canonical-switch-case-typed-action-gate-2026-08-28.md`.

Mechanical progress remains **87/125 (69.6%)** because the open Sema umbrella
also contains lifetime/cleanup and uncommon surface closure. Weighted delivery
is now **about 74%**, safe default readiness **about 47%**, and action-only Sema
**about 98%**. The next critical slice is lifetime/cleanup; the default remains
LEGACY.

## 2026-08-28 CTA-S43 checkpoint: generic native Sema replay retirement

The six generic completed-node expression/statement replay adapters have been
physically deleted from CANONICAL Sema: `ActOnExprFromNode`,
`InternParsedExprTerm`, `ActOnStmtFromNode`, `InternParsedChildStmt`,
`InternParsedCompoundStmt` and `ActOnParsedStmt`. Parser still builds the
native AngelScript AST for syntax/recovery, LEGACY, reference and differential
use; this milestone does not authorize native AST deletion.

The new physical-boundary test produced the expected **0/1 RED** before the
deletion. After implementation and repair of one obsolete source-contract
assumption, complete SemaAuthority is **393/393 PASS** and downstream
ProductionCodeGen + Canonical Semantics + retained ScriptNode is **158/158
PASS**. Exact reports and the false-green method-slice test hazard are recorded
in
`attachments/canonical-native-sema-replay-adapter-retirement-gate-2026-08-28.md`.

Mechanical progress remains **87/125 (69.6%)** because lifetime/backend/AOT
and product-cutover umbrellas remain open. Weighted delivery advances to
**about 75%**, safe default readiness to **about 48%**, and whole-Sema
action-only authority stays conservatively **about 98%**. Residual
declaration/type/scope node-identity helpers and explicit lifetime/cleanup are
the next audit boundary; the default remains LEGACY.

## 2026-08-28 CTA-S44 checkpoint: lexical value cleanup plans

Canonical Sema now seals reverse-order `scope-exit` cleanup for initialized
direct lexical value-object locals with an exact destructor. Normal block exit
owns the live-only cleanup sequence; every return or targeted transfer that
leaves the block owns distinct cleanup statement identities. Nested exits
therefore destroy inner locals before outer locals without consulting the
native Parser tree after seal.

Canonical CodeGen executes the sealed plan and retires the normal-path object
state to prevent an epilogue double destroy. The verifier rejects wrong
destructor owners and malformed targets. Runtime evidence executes early and
normal routes with three constructions and exactly three destructions each.
The first complete backend run was **114/115** and exposed a missing prepared
Runtime shell for Sema-generated script destructors; generated object
accessors/destructors now publish atomically, with a direct bytecode-call
assertion.

Final gates are SemaAuthority **394/394**, ProductionCodeGen **115/115**, and
the combined downstream gate **159/159 PASS**. Full evidence is in
`attachments/canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`.
Tasks 5.7/5.8 remain open, so mechanical progress stays **87/125 (69.6%)**.
Weighted delivery is **about 76%**, safe default readiness **about 49%**, and
whole-Sema action-only authority **about 98%**. The default remains LEGACY.

## 2026-08-28 CTA-S45 checkpoint: lexical owning-reference release plans

Initialized direct lexical `ReferenceObject` and `FuncDef` locals now use the
same sealed, reverse-order cleanup stack as value objects. Sema emits a
destructor-free `scope-release` expression with one exact local `DeclRef` for
normal block exit and for every return/break/continue/fallthrough that leaves
the owning block. A true non-owning `REFERENCE` qualifier is deliberately
excluded.

The verifier requires `scope-release` to have no destructor binding, one exact
variable target, and an owning reference-object or funcdef type. Canonical
CodeGen consumes the plan as `asBC_FREE` plus `asOBJ_UNINIT`; only the normal
path retires the tracked compile-time slot, while copied transfer plans remain
live on their own control-flow routes. The shared release classification also
repairs common-epilogue handling for implicit handles, whose Canonical local
type is `REFERENCE_OBJECT` even though its qualifier bits are zero.

The clean missing-contract evidence is Sema **0/1**, verifier **27/29** and
production execution **0/1**. Final gates are SemaAuthority **388/388**,
ProductionCodeGen **111/111**, verifier **29/29**, and ProductionCodeGen +
Canonical Semantics + retained native ScriptNode **160/160 PASS**. Full
evidence and the implicit-handle qualifier discovery are recorded in
`canonical-lexical-owning-release-plan-gate-2026-08-28.md`.

No lifetime umbrella task closes because deferred/out, template/container,
global, exception, suspend/resume, capture ownership and direct AOT cleanup
remain. Mechanical progress stays **87/125 (69.6%)**. Weighted delivery is now
**about 77%**, Canonical Bytecode/Runtime closure **about 73%**, safe default
readiness **about 50%**, direct Canonical-AST AOT **about 55%**, and whole-Sema
action-only authority **about 98%**. The default remains LEGACY; the retained
native AngelScript AST remains available for syntax/recovery/reference and
rollback, while HIR remains physically deleted.

## 2026-08-28 CTA-S46 checkpoint: funcdef default-null lifetime

Valid implicit-handle funcdef locals without source initializers now carry a
direct Canonical `NullLiteral` initializer and executable assignment. This
turns the VM's previously implicit zero-storage behavior into a sealed AST
live-state fact and activates the existing owning `scope-release` route on
normal and transfer exits. The verifier rejects release plans whose target
declaration has no initializer; Canonical Bytecode continues to lower the
sealed null and release as pointer clear followed by `FREE` + `UNINIT`.

Final gates are build PASS, focused verifier/Sema/production **1/1** each,
verifier **30/30**, SemaAuthority **389/389**, ProductionCodeGen **112/112**,
and ProductionCodeGen + Canonical Semantics + retained native ScriptNode
**161/161 PASS**. Full RED/GREEN evidence and the explicit-`@`, host funcdef
flag, comparison-surface and AST-live-state issue decisions are recorded in
`canonical-funcdef-default-null-lifetime-gate-2026-08-28.md`.

The slice does not close deferred/out, aggregate/container, capture, global,
exception, suspend/resume, detached Bytecode or direct AOT ownership breadth.
Progress stays **87/125 (69.6%)**, weighted delivery **about 77%**,
Bytecode/Runtime **about 73%**, safe default readiness **about 50%**, direct
AST AOT **about 55%**, and action-only Sema authority **about 98%**. LEGACY
remains the default; the native AST remains retained and HIR remains deleted.

## 2026-08-28 CTA-S47 checkpoint: dead native-node Sema dependency retirement

The completed declaration/expression/statement Sema units no longer include
`as_scriptnode.h`. Five unused helpers that could read text, ranges or scope
children from a completed `asCScriptNode` are physically deleted. The live
path continues to consume typed action spelling/ranges/scope segments and the
existing pointer-free `ResolveScopeSegments` routine.

This does not delete the native AngelScript AST. Parser, LEGACY, recovery and
reference/differential tests retain it. The remaining maps in `as_sema.cpp`
are separately classified as build-local syntax identity bridges: they map an
exact pointer or unique section/token coordinate to an already-created
Canonical ID and remain required by Builder and LEGACY body reparse. They do
not decode semantic children, but their pointer/coordinate transport remains
open work under task 13.2.

After one excluded assertion-macro compile error, the valid focused gate
produced **0/1 RED** before implementation. Final evidence is build PASS,
focused **1/1 PASS** and full SemaAuthority **397/397 PASS**, recorded in
`canonical-sema-native-node-dependency-audit-2026-08-28.md`. Mechanical
progress remains **87/125 (69.6%)** and weighted implementation **about 77%**;
the default remains LEGACY, the native AST remains retained and HIR remains
deleted.

## 2026-08-28 Task 11.4 checkpoint: embedding migration contract

Chinese-first and English Canonical AST guides now provide the complete
embedding migration contract: current product header/version, trailing module
ABI slots, V1 `structSize`/`apiVersion`, append-only views, foreign IDs,
pre-Build retention freeze, normal null acquisition, lease/current-generation
rules, exact detached versus `ADD_TO_MODULE` CompileFunction behavior,
Cache/SaveByteCode/dump separation, stable pointer-free persistence and no
concrete node ABI.

The audit corrected two stale statements: explicit CANONICAL builds already
publish through sealed-AST CodeGen, and HIR is physically deleted. The native
AST, Builder and Compiler remain intentionally available for Parser/recovery,
LEGACY/reference and rollback. Fresh Module Snapshot is **10/10 PASS**;
strict OpenSpec and diff checks pass. Task 11.4 is closed, advancing mechanical
progress to **88/125 (70.4%)**. Weighted implementation stays **about 77%**,
safe default readiness **about 50%**, and the default remains LEGACY. Evidence:
`embedding-client-canonical-ast-migration-notes-2026-08-28.md`.

## 2026-08-28 CTA-S49 checkpoint: direct AOT verified-empty cleanup facts

TypedASTJIT now derives a bounded lifetime fact from the exact sealed Canonical
function body and copies it into pointer-free backend/provider diagnostics. A
complete shared structural traversal containing no cleanup action publishes
`VerifiedEmpty` and all-transfer coverage. Invalid graphs and every non-empty
cleanup family remain `Unverified`; the path reads neither bytecode nor dump,
native syntax nodes or HIR.

The permanent production-closure assertion produced a clean backend dependency
**1/2 RED** and is now **2/2 PASS**. Runtime/Editor build passes,
CanonicalASTMigration is **11/11 PASS**, and complete TypedASTJIT is **40/40
PASS**. Evidence and the excluded zero-selection attempt are recorded in
`canonical-aot-cleanup-facts-gate-2026-08-28.md`.

Task 7.5 remains open for non-empty destructor/release liveness, partial
construction, exception/suspend, globals/imports, call-site fallback and
remaining provider dependencies. Mechanical progress stays **88/125
(70.4%)** and weighted delivery stays **about 78%**. Direct Canonical-AST AOT
is now estimated at **about 57%**; Bytecode/Runtime remains about **74%**, safe
default readiness about **50%**, and action-only Sema authority about **98%**.
LEGACY remains the default; native AST retention and HIR deletion are
unchanged.

## 2026-08-28 CTA-S53 design checkpoint: B2 lifetime protocol approved

The OpenSpec has been reconciled around the approved B2 lifetime architecture.
The Frozen/Publishable Canonical snapshot owns exact lifetime subject, action,
activation/commit, region/phase and construction facts. One deterministic,
transient shared view verifies committed-live sets and reverse live-only
cleanup without performing semantic lookup or becoming persisted HIR/CFG.
Bytecode and TypedASTJIT retain only backend-local cleanup/EH stacks, labels,
slots, tables and frame ABI. Sidecar V6 remains the default; a schema change
requires an AST-first RED proving that a required semantic fact cannot be
reconstructed.

Proposal, design, Clang mapping, five normative spec deltas, task topology,
review and issue records are synchronized. Tasks 15.1-15.11 now provide the
implementation-ready TDD sequence and file/test map. Task 7.8 is reconciled as
closed because function-owned HIR is physically absent; Tasks 7.2/7.4/7.5
remain open for actual Canonical AOT capability rather than HIR migration.

This checkpoint changes records only and adds no compiler functionality, so
the weighted implementation estimates remain **about 79%** overall,
**about 63%** direct Canonical-AST AOT, **about 99%** action-only Sema,
**about 74%** Bytecode/Runtime and **about 50%** safe-default readiness.
Mechanical progress is now **89/136 (65.4%)**: one already-proven HIR-retirement
task was reconciled closed while eleven explicit CTA-S53 implementation tasks
were added to the denominator. The lower raw percentage reflects finer task
decomposition, not an implementation regression. Product default remains
LEGACY; native AngelScript AST/Builder/Compiler remain available for explicit
LEGACY, syntax/recovery and reference use; HIR remains deleted.

## 2026-08-28 CTA-S53 Task 15.1 checkpoint: Context ownership and ID admission

The Canonical arena owner is now explicitly noncopyable/nonmovable, preventing
duplicate ownership of arena blocks. Internal Context access is also uniform:
Decl, Stmt, Expr and Type const/mutable lookups accept only owner-zero internal
IDs. Public snapshot adapters remain the token authority and strip the owner
only after validating that the reference belongs to that snapshot.

Two AST-first tests produced the expected **6/8 RED** before implementation:
copy construction was admitted and a foreign public declaration ID with the
same numeric index resolved through Context. After the minimal fix,
Runtime/Editor build passed, focused Context is **8/8 PASS**, and complete
Frontend CanonicalAST is **154/154 PASS**. Evidence and exact report paths are
recorded in `canonical-lifetime-context-admission-gate-2026-08-28.md`.

Task 15.1 is closed and mechanical progress advances to **90/136 (66.2%)**.
Weighted implementation remains **about 79%** because this is a narrow
correctness/admission closure. CTA-S53-I7 is only partially resolved: the
ordered lifecycle and shared Frozen/Publishable admission predicate remain
open under Task 15.2. Product default remains LEGACY, native Parser
AST/Builder/Compiler remain retained, and HIR remains deleted.

## 2026-08-28 CTA-S53 Task 15.2 checkpoint: ordered lifecycle admission

`asCASTContext` now has one explicit lifecycle:
`Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable`.
Transitions are adjacent and one-shot; skipped, repeated and stale requests
leave the state unchanged. Ordinary graph mutation stops after Building and
remains rejected after freeze. The existing `Seal()` surface is retained only
as an internal compatibility completion that executes all three adjacent
transitions; it is no longer idempotent.

All Canonical consumers now share `IsPublishable()`: publication verification,
Module/Cache retention, Sidecar encode, Bytecode CodeGen, StaticJIT snapshots
and TypedASTJIT. Sidecar decode is the construction inverse: it accepts only a
fresh Building destination and returns success only after the same lifecycle
reaches Frozen/Publishable. Canonical `IsSealed()` was removed; a source scan
classifies the remaining same-name uses as the unrelated bind collection.

The API-first lifecycle test produced the expected build RED. Final evidence
is Runtime/Editor build PASS, Frontend CanonicalAST **156/156 PASS**, Cache
ASTBodySidecar **22/22 PASS**, and TypedASTJIT CanonicalASTMigration **16/16
PASS**. Exact paths and scope boundaries are in
`canonical-lifecycle-admission-gate-2026-08-28.md`.

Task 15.2 is closed and mechanical progress is **91/136 (66.9%)**. Weighted
implementation remains **about 79%**: this closes a critical admission
boundary, but Task 15.3 must still bind `LifetimePlanned` to real revisioned
snapshot-owned lifetime facts. Product default remains LEGACY, native Parser
AST/Builder/Compiler remain retained, Sidecar stays V6 and HIR remains deleted.
