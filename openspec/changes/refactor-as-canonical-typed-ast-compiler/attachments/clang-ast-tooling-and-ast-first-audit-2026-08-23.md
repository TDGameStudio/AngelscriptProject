# Clang AST tooling 对照与 AST-first 测试推进审计

日期：2026-08-23  
Change：`refactor-as-canonical-typed-ast-compiler`  
本地 Clang：`D:\LLVM\llvm-project-22.1.8.src`（22.1.8）

## 结论

Canonical Typed AST 的本阶段可观察性已经闭合：统一遍历/parent index、结构化
dump、路径化 verifier、typed matcher、完整 semantic diff，以及 lease-safe
Runtime/commandlet/Standalone `list/dump/verify/query/diff` 均已落地。已有 verifier
和稳定 dump 已经产生真实收益：最新 TypedASTJIT 问题就是由 publication
verifier 的 `continue-ancestor` 拒绝定位到 `for` 多增量节点拆分错误，而不是
等到 JIT 或 VM 崩溃后猜测。

AST-first 测试也已经真实推进：规则、路由矩阵、gate-card 模板和多个纵向
切片已经落地；但尚未覆盖每一个开放任务，默认切换前的完整矩阵仍未执行。
因此当前应区分：

```text
AST 自测基础设施：       已较成熟
AST-first 工作流落地：   已在多个真实缺陷上执行
全部剩余任务 gate 化：   进行中（0.2 未关闭）
默认切换前总闸门：       未完成（0.3 未关闭）
Clang-inspired 调试工具： 本阶段 2.9–2.13 已完成；typed CFG/DOT 属于后续 P2
```

## 当前已经拥有的 AST 工具和测试

### 实现能力

- `asCASTContext`：arena 所有权、模块 TranslationUnit、opaque ID、类型
  intern、SourceManager、Seal 和 post-seal mutation 拒绝。
- `asCASTVerify` / `asCASTVerifyPublication`：检查 dangling/foreign/wrong-kind
  ID、父子/owner、cycle、range/type/value category、CALL/CONSTRUCT callee、
  cleanup destructor、loop/switch transfer、duplicate case/default、fallthrough
  等发布不变量。
- `asCASTDump`：地址无关、确定性的 flat Decl/Stmt/Expr 文本，包含 stable key、
  type/quals/traits、依赖、调用目标、参数、receiver、控制阶段和 safe-point。
- `asCASTDumpOnVerifyFail`：在拒绝时附上完整 flat AST。
- `asCASTShadowDiff`：按 Source/Type/Decl/Stmt/Expr 的稳定顺序比较完整持久事实，
  返回第一处 `TU structural path.field left/right` 差异；无地址、snapshot owner
  或 Engine-local ID。
- `FCanonicalASTMatch` 测试查询层：精确 stable Decl、QualType、named edge、
  callee/receiver、conversion、control target、cleanup 和 source range，显式处理
  unique/zero/one-or-more cardinality。
- `asIASTSnapshot` V1：不可变 lease、generation、Decl/Stmt/Expr/Type/source view
  和逐 child traversal。
- Cache V2 `ASTBodySidecar`：独立的 pointer-free DTO，而不是 dump/JSON 输入。

### 测试规模

对 `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK` 下文件名包含
`CanonicalAST` 的测试源码进行静态统计：

```text
21 个文件名包含 CanonicalAST 的测试文件
466 个 TEST_METHOD 定义

其中：
  SemaAuthority                 256
  ProductionCodeGen             69
  Frontend CodeGen              25
  Verifier                      22
  CodeGen transaction           17
  Type                           12
  VM semantic matrix            12
  SourceManager                  8
  Cutover                        7
  Context                        6
  Dump / structured dump        10
  Traversal                      5
  Verifier path diagnostics      4
  Matcher + semantic diff        2
  Isolated differential          6
  其余 Sema/shadow/baseline      15
```

这个数字只说明测试资产规模，不等于 461 个独立语义都已成为默认切换闸门；
一些测试仍可能依赖 dump substring、局部 hand-built graph 或 legacy-compatible
执行结果。OpenSpec 0.2 要求每个剩余语义任务留下 source-path sealed-AST card，
正是为了阻止用数量代替语义权威。

## Clang 能力对照

| Clang 原语/工具 | 本地源码证据 | AngelScript 当前状态 | 建议 |
| --- | --- | --- | --- |
| `RecursiveASTVisitor` | `clang/include/clang/AST/RecursiveASTVisitor.h` | 无统一 visitor；verifier、dump、TypedASTJIT 各自递归 | P0：实现 generic const traversal，统一 edge role 与顺序 |
| `ParentMapContext` | `clang/include/clang/AST/ParentMapContext.h` | verifier 临时构造局部 parent 表；无共享查询 API | P0：sealed snapshot 上按需构造 parent/edge index，不给每个 Expr 加永久 parent 字段 |
| text/JSON AST dumper | `ASTDumper.*`、`TextNodeDumper.*`、`JSONNodeDumper.*` | 只有 flat text | P0：保留 flat 兼容输出，新增 tree text + JSON |
| `clang-check` dump/list/print/filter | `clang/tools/clang-check/ClangCheck.cpp` | 无 AST 专用 list/query/filter 命令 | P0/P1：按 module/stable key/node/kind/source 过滤；开发/命令行入口持有 snapshot lease |
| AST Matchers / `MatchFinder` | `clang/include/clang/ASTMatchers/*` | AS 专用 typed matcher/assertion 已覆盖 identity/type/edge/call/control/cleanup/source；代表性 Sema dump 断言已迁移 | 保持小型显式 API，不复制完整动态 DSL |
| parent/ignored-node traversal policy | `ParentMapContext` traversal kind | 无统一 edge/implicit-node 策略 | P0：edge roles 明确区分 lexical child、receiver、callee、target、cleanup、dependency |
| `ASTStructuralEquivalence` / `ASTImporter` | `ASTImporter.*` | 完整只读 semantic diff 已覆盖 Source/Type/Decl/Stmt/Expr 并定位第一条结构路径 | 不做跨 context import；Cache 继续显式 DTO/remap |
| `ASTReader` / `ASTWriter` | `clang/include/clang/Serialization/*` | Cache V2 sidecar 已有独立 DTO | 不复制 PCH/Modules；借鉴 ID/offset/validation 思路即可 |
| on-demand `CFG::buildCFG` + dump/view | `clang/include/clang/Analysis/CFG.h` | 结构化控制节点和 verifier 已有，尚无 CFG | P1/P2：语句、cleanup、异常边稳定后生成 typed CFG text/DOT；不阻塞 AST 基础切换 |
| `ASTUnit` / `ASTConsumer` / FrontendAction | `clang/include/clang/Frontend/ASTUnit.h`、`ASTConsumers.h` | module snapshot/lease 已承担部分角色 | 不照搬类层级；补只读 consumer/tool action 即可 |

## Verifier 路径缺口（已由 2.11 关闭）

审计时的失败输出类似：

```text
VERIFY category=WRONG_KIND detail=continue-ancestor range=1:2785-1:2794
AST
DECL ...
STMT ...
EXPR ...
```

它能告诉我们“哪里不合法”，但仍需要人工在完整 flat 表中追 ID。2.11 的
实现目标是：

```text
VERIFY WRONG_KIND continue-ancestor
source: /Angelscript/Game/Test.as:87:9
node:   ContinueStmt #31
edge:   target -> ForStmt #12

path:
  FunctionDecl Test() #2
  └─ body: CompoundStmt #20
     └─ child[3]: CompoundStmt #29
        └─ child[0]: ContinueStmt #31   <-- offending

related target:
  ForStmt #12
  └─ increment: SequenceExpr #44

reason:
  target exists and has the correct kind, but is not an ancestor of #31
```

该能力现已实现为 offending/related node、named edge、logical source、TU path
和硬上限 local subtree，并已显著降低 Sema、Cache remap、Hot Reload generation
和 TypedASTJIT 的定位成本；2.13 随后已经把它接入统一只读命令入口。

## 推荐的分阶段实现

### P0：默认切换前应完成

1. Generic const traversal + named edge roles。
2. On-demand parent/edge index。
3. Tree text + JSON + filter dump；flat dump 保持兼容。
4. Verifier node/edge/path/snippet 诊断。
5. 小型 typed matcher/assertion 和完整 semantic diff。
6. 用这些工具继续执行每个开放任务的 AST-red/AST-green card。

```text
source
  -> Parser/Sema
  -> unsealed AST
  -> generic traversal + verifier
  -> Seal
  -> snapshot lease
      |-> tree/json/filter dump
      |-> matcher/query
      |-> structural diff
      |-> Cache/CodeGen/JIT consumers
```

### P1：基础工具稳定后

- Runtime/commandlet/Standalone 的 `list/dump/verify/query/diff` 入口。
- Cache sidecar 与 restored snapshot 的结构差异查看器。
- Hot Reload generation A/B AST diff。
- CodeGen provenance 联动：从函数 artifact 反查其 sealed AST digest/decl key。

### P2：控制流和生命周期稳定后

- On-demand typed CFG。
- text/DOT 输出，标注 cleanup、exception、safe-point、break/continue/switch
  edge。
- 基于 CFG 的 unreachable、definite assignment、liveness 和后续优化分析。

### 明确不照搬

- 不链接 Clang/LLVM。
- 不复制 Clang 完整 AST Matcher 生成体系或 `clang-query` 语言。
- 不复制 C++ PCH/Modules/lazy ASTReader。
- 不用 JSON/dump 替代 Cache V2 DTO。
- 不先做可变 AST rewrite/refactoring API。
- 不让 CFG 成为另一份 source-semantic authority。

## AST-first 测试推进状态

已完成：

- 0.1：AST-first 规则进入设计和 task graph。
- 0.2a：至少一个跨 Sema/CodeGen/Cache 的真实纵向切片完整走过红绿链；
  后续又用于 mixed-width comparison/return ABI。
- 0.2b：所有剩余任务已经有 owning suite 路由和 gate-card 模板。
- 多个永久 source-path AST 回归：float resolved width、comparison conversion、
  return ABI、Cache declaration identity/remap、StaticJIT stable identity、`for`
  多 increment + `continue` ancestor。
- 最新 `for` 修复后完整 TypedASTJIT 64/64 PASS，证明 verifier 找到的问题已在
  AST 层修复，而不是在 JIT 层绕过。

仍未完成：

- 0.2：尚未为 4.x/5.x/6.x/7.x/9.x/10.x/13.x 每个开放语义事实完成 card。
- 0.3：默认切换前尚未统一重跑 Frontend、SemaAuthority、Snapshot、Hot Reload、
  Cache AST、Canonical CodeGen 和 StaticJIT 的完整 AST gate matrix。
- 部分测试仍通过 flat dump substring 读取事实，缺少 typed matcher 的精确失败
  路径。
- hand-built verifier 测试很强，但每个用户可见语法还必须有真实 source ->
  Parser -> Sema -> Seal 测试，避免手工构图掩盖 parser-action 缺失。

当前评价：**测试体系的地基和规则已经成形，真实使用也已证明有效；全面 gate
覆盖仍在中段。工具建设已完成内部核心原语、结构化检查、路径诊断、精确测试
查询和统一只读开发者/commandlet/Standalone 入口。typed CFG/DOT 仍按设计
留在后续 P2。**

## 本次加入任务

OpenSpec 新增 2.9–2.13 五个任务：generic traversal/parent index、结构化 dump、
verifier path diagnostics、test matcher/full semantic diff、read-only tool commands。
这使机械任务总数从 110 增加到 115，完成数仍为 64；不是实现倒退，而是把
此前隐含但必要的 Clang-style AST 可观察性工作显式纳入完成定义。

## 实施进展 — 2026-08-23 21:05

2.9 和 2.10 已落地，Clang-style 工具能力从“审计结论”进入可执行基础设施：

- `asIASTConstVisitor` + 命名 structural/reference edge；
- sealed-context parent/incoming-edge index；
- 保留兼容 flat dump，同时新增确定性 tree text 和合法 JSON；
- module、stable declaration key、node class/ID、kind、logical source 精确筛选；
- 筛选的 ancestor + structural subtree closure；
- exact type/qualifier、traits、resolved target、line/column 和 opt-in bounded snippet；
- 明确 `diagnosticOnly=true` / `cacheInput=false`，不进入 Cache V2 schema/key。

新增结构化 dump 测试 3/3；完整 Frontend CanonicalAST 已增至 117 项，并与 12
项 Cache ASTBodySidecar 联合达到 129/129 PASS；Standalone 21/21 PASS。详细输出
合同、Clang 对应关系和证据见 `attachments/structured-ast-dump-2026-08-23.md`。
当前还缺 2.11 verifier path/local subtree、2.12 typed matcher/full diff 和 2.13
lease-safe developer command surfaces，因此不能把“工具层”描述为全部完成。

2.11 也已随后完成：verifier 在不改变 stable category/detail 的前提下，现会给出
offending D/T/S/E node + kind、named edge、related target、logical source
line/column、确定性 TU structural path，以及 8-node/16-edge/3-depth 的硬上限局部树。
坏图中的 dangling edge 只报告不跟随，超限显式 `truncated=true`；失败 publication
已证明不改变 Seal、节点计数或 flat dump。专项 4/4，CanonicalAST + Snapshot +
ExactWarmStartup 145/145，Standalone 21/21。见
`attachments/verifier-path-diagnostics-2026-08-23.md`。该节点当时剩余的 Clang-style 工具层为
2.12 typed matcher/full diff 与 2.13 lease-safe command surfaces。

2.12 现已完成。`FCanonicalASTMatch` 提供 stable Decl、exact QualType、named edge、
callee/receiver、conversion、control target、cleanup 和 logical source range 的
强类型查询，并区分 unique、zero 和 one-or-more cardinality。`asCASTShadowDiff`
按 Source/Type/Decl/Stmt/Expr 比较完整持久事实，只输出第一条确定性的
`structural-path.field left/right` 差异。代表性的 overload/conversion/continue/
cleanup SemaAuthority 测试已停止解析 flat dump；旧 Shadow 测试也迁到精确字段
路径。专项 2/2，SemaAuthority 256/256，Frontend CanonicalAST 123/123，Standalone
21/21。一次 255/256 的中间运行还纠正了“cleanup 必须唯一”的错误假设：同一
临时值可以为多个退出路径拥有多个合法 Cleanup 节点，查询现在返回第一个节点
并报告完整 `MatchCount`，没有删除真实语义事实。见
`attachments/typed-ast-matchers-and-shadow-diff-2026-08-23.md`。

2.13 现已完成，因此 2.9–2.13 的 Clang-inspired AST tooling 本阶段整体闭合。
维护分支现在提供 host-neutral `asCASTRunDiagnostics`，Runtime `as.AST` 控制台命令、
Editor commandlet 和 Standalone 共用 `list/dump/verify/query/diff` 合同。每次读取都
获取并释放不可变 snapshot lease，输出明确 module/generation/provenance、read-only、
mutation refused 与 cacheInput=false；source-build 和 Cache V2 restore provenance
均有测试。Runtime 专项 3/3、Snapshot 9/9、ExactWarm 15/15、Standalone 21/21，
真实 commandlet `list` 也已通过。JSON/text 仍只是诊断输出，不参与 Cache schema、
key 或 restore；DOT/typed CFG 和 Clang matcher DSL 留在后续 P2。完整合同与证据见
`attachments/read-only-ast-diagnostics-2026-08-23.md`。
