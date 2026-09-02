# Canonical Typed AST 阶段合入快照 — 2026-08-28

## 结论

本次适合作为一个**阶段性 WIP 检查点**进入主线，但不适合归档 OpenSpec，
也不应宣称 Canonical 编译器已经可以切成产品默认。

- OpenSpec 机械进度：**94/136，69.1%**；
- 架构加权进度：**约 81%**；
- action-only Sema：**约 99%**；
- Canonical Bytecode/Runtime：**约 75%**；
- 直接 Canonical-AST AOT：**约 63%**；
- 安全默认切换准备度：**约 53%**。

这几个数字衡量的不是同一件事：机械进度按任务勾选统计，架构加权进度
反映主干能力成熟度，而默认切换准备度受语义闭包、生命周期、AOT、缓存
和发布边界中的最弱项约束。

## 本阶段已经形成的主干

1. Canonical AST 已拥有 SourceManager、类型/声明/语句/表达式模型、结构化
   verifier、遍历/父边索引、诊断 dump/query/diff 和公开只读 snapshot lease。
2. CANONICAL Parser/Sema/Bytecode 已覆盖多类真实源码与 VM 执行；LEGACY 仍是
   默认和显式回退路径。
3. HIR 生产模型及 dump 入口已经物理删除；TypedASTJIT 正直接消费 sealed
   Canonical AST，而不是把 AST dump 或旧 HIR 当中间格式。
4. 动态 TypeId 已被限制在 Engine-local 解析/重定位边界；持久化、Provider
   和 detached artifact 使用稳定类型键/ABI 键，不能携带运行时数字 TypeId。
5. Context 已完成 owner admission 加固，并建立
   `Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable` 的统一
   生命周期。
6. CTA-S53 15.3 已加入 revision 1 的 snapshot-owned、pointer-free lifetime
   protocol 基础：Context 存储、typed equality/hash、revision/节点/动作验证
   和 freeze 后不可变约束均已通过测试。
7. CTA-S53 15.4 已把局部值对象的 activation 从 `DeclStmt` 移到精确初始化
   `Assign` 成功提交点；Sema 写入 exact local/destructor/block/exit lifetime
   record。正常析构 `[2,1]`、第二对象初始化失败析构 `[1]` 均已通过真实
   Canonical CodeGen 执行门。
8. CTA-S53 15.5 已加入唯一的 transient lifetime/control derived view：从
   immutable snapshot 认证 exact record，机械派生 nested scope edges、commit
   前后 live set、initializer-abort cleanup 和 reverse live-only order。该 view
   使用独立 `LTV1` typed digest，不进入 Context/Sidecar/Provider/detached
   artifact，也不是新 HIR/CFG。

## 当前最重要的未闭合项

### 1. lifetime protocol 还没有端到端接管生产语义

15.4 已完成普通局部值对象的 success-before-active 协议作者和生产行为门，
15.5 已完成 shared derived view 和 publish-admission authentication。但
Bytecode 当前仍可通过 compatibility cleanup statements 与既有 VM 对象变量
metadata 实现行为；TypedASTJIT 也尚未被要求只消费 authenticated view。
下一步是 15.6–15.10：

- 迁移 `scope-exit`、`scope-release` 和 foreach 位置编码并校验双向一致；
- Bytecode 与 TypedASTJIT 只消费已认证协议；
- 完成构造函数与数组/聚合的 partial-construction 语义。

### 2. Canonical Sema 仍保留少量 build-local native-node identity map

语义 replay/子树遍历适配器已经清除，但 Parser 组合、Builder 壳绑定和显式
LEGACY body reparse 仍用 native node 指针或 section/token 坐标定位已经创建的
Canonical ID。这不是旧 HIR，也不是后端语义来源，但在换成 pointer-free
parse-action identity 前，13.2 不能关闭。

### 3. TypedASTJIT 对对象生命周期仍应精确回退

当前 AOT 已能从 sealed AST 证明 empty/non-empty cleanup、reverse live-only
顺序和 foreach phase，但还没有原生 object-frame ABI、完整 exit kind、异常/
suspend、mutable global/import 和所有 Provider dependency。对象生命周期函数
应继续做 per-function BytecodeJIT/VM fallback，不能发布半套 native cleanup。

### 4. 产品默认仍必须保持 LEGACY

Canonical 能力存在不等于默认切换已经安全。Tasks 1–9 的全部权威性、生产
Bytecode 语义面、发布回滚、缓存/Hot Reload/commandlet 等矩阵尚未全部闭合，
因此 `canonicalCompilerPipeline` 不能默认翻转。Standalone 适配已延期到独立
OpenSpec，不再作为本 change 的切换门。

## 本次新验证证据

- Runtime/Editor build：**PASS**；
- Frontend CanonicalAST：**163/163 PASS**；
- Context：**12/12 PASS**；
- Verifier：**39/39 PASS**；
- 15.4 AST-first focused：**0/1 RED -> 1/1 PASS**；
- 15.4 production focused：**1/1 PASS**；
- SemaAuthority：**400/400 PASS**；
- ProductionCodeGen：**119/119 PASS**；
- 15.5 API-first：missing-contract build RED -> Runtime/Editor build PASS；
- 15.5 nested scope/live-set proof：PASS；
- Standalone Debug：**20/20 PASS（15.3 历史证据，后续适配延期）**。

精确报告路径、RED/GREEN、DLL link 问题、Standalone 残留 `IsSealed()` 问题
和 staged empty-protocol 风险见：
`attachments/canonical-lifetime-protocol-foundation-2026-08-28.md`。
15.4 的提交点、异常析构、工作树路径和 CQTest 名称问题见：
`attachments/canonical-local-success-sensitive-activation-gate-2026-08-28.md`。
15.5 的 derived-view TDD、MSVC export/friend linkage、旧 Context fixture
漂移、source scans 和 staged capability boundary 见：
`attachments/canonical-lifetime-derived-view-gate-2026-08-28.md`。

## 合入与后续约束

- 本次只作为阶段检查点，OpenSpec 保持 active，不归档；
- 15.5 已完成；不提前勾选 15.6–15.11，也不关闭 5/7/9/13 的 umbrella rows；
- 不删除原生 AngelScript AST/Parser/Builder/Compiler；HIR 删除保持不变；
- 不修改 Sidecar V6，除非 15.11 的 AST-first RED 证明 decoded snapshot 无法
  重建必需语义事实；
- 后续从 15.6 named protocol accessor/compatibility parity 开始继续 TDD，不先
  扩展 backend 启发式；
- 不再为本 change 增加 Standalone source/CMake/test 适配，已有结果仅保留为
  历史证据，未来使用独立 OpenSpec 重构。

## 集成环境问题

阶段分支本身已具备上述验证证据，但主 checkout 的 `main` 在准备合入时包含
大量不属于本 OpenSpec 的已修改、删除和未跟踪文件。为避免把其他重构混入
CTA 提交，集成必须先提交插件子模块，再提交父仓 OpenSpec/gitlink；不能在
脏 main 工作区中直接执行破坏性清理、checkout 或强制合并。

## 2026-08-29 CTA-S54 supersession

本检查点第 2 项记录的 build-local native-node identity map 已关闭。Parser 与
prepared Builder shell 现在只复制精确的
`section + nodeKind + offset + length`，Canonical Sema 不再保存
`asCScriptNode*`，也不再保留 offset-only/ambiguous fallback。冲突绑定会产生
稳定 diagnostic 并 fail closed。

迁移过程中发现并修复了 cast/construct expression range 与 declaration
wrapper range 在早期绑定后继续增长的问题；最终 SemaAuthority **405/405**，
ProductionCodeGen + Module Snapshot + TypedASTJIT **186/186 PASS**。因此“必须先
替换 parse-action identity”这一特定阻塞已经解除，但 13.2 的完整 Sema
environment、生产 backend 事实和最终门禁仍未完成，默认仍保持 LEGACY。
证据：
`attachments/canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`。

## 2026-08-29 CTA-S55 declaration-action closure

The declaration-side Parser/Sema action migration is now complete for the
maintained language, so Task 4.2 is checked. Native syntax nodes remain for
LEGACY/recovery/reference, but Canonical Sema has no native child traversal or
generic declaration replay API. Fresh evidence is SemaAuthority **405/405**
and Frontend Parser Declarations **18/18 PASS**. The formal checklist advances
to **101/136 (74.3%)**.

This does not change the integration decision: LEGACY remains default,
Standalone remains deferred, and Tasks 4.3-4.6, 5.x, 9.x, 10.x and 13.2/13.6
still block the final switch. Full mapping, no-selection prefix issue and
non-claims:
`attachments/canonical-declaration-sema-action-closure-gate-2026-08-29.md`.
