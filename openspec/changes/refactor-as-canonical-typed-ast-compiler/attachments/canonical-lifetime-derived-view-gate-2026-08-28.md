# CTA-S53 15.5：确定性 lifetime derived view 门

日期：2026-08-28

## 结论

Task 15.5 已完成。Canonical frontend 现在能从已经完成 Sema 且即将进入、或
已经进入 `LifetimePlanned/Frozen` 的 immutable Context 重建唯一的 transient
lifetime/control view。该 view：

- 认证 revision 1 lifetime record 中的精确 subject、cleanup action、成功提交
  点、semantic region、phase、exit mask、construction step 和存储顺序；
- 从 AST 的结构父边机械派生 lifetime scope edge；
- 从成功提交点机械派生 `liveBefore`、`liveAfter`、initializer abort cleanup 和
  reverse live-only cleanup；
- 使用独立的 typed structural digest，不读取或哈希 `asCASTDump()` 文本；
- 不进入 Context、Sidecar、Cache、Provider 或 detached artifact，不持久化，
  也不携带 AST/Runtime 指针、Engine numeric TypeId、backend label/slot/stack。

Verifier 在 `LifetimePlanned` admission 和 Frozen re-verification 上都认证同一
view。伪造或不一致的 lifetime protocol 无法到达 Publishable consumer。

这完成的是共享语义/证明视图，不是 backend 接管。Bytecode 和 TypedASTJIT
尚未被要求只消费该 view；`scope-exit`、`scope-release` 和 foreach positional
phase 的 compatibility parity 仍属于 15.6，默认仍必须保持 LEGACY。

## TDD RED

先在 Frontend Verifier 增加三个 API/行为用例：

1. 同一 snapshot 重建两次，typed scope/record/commit 数据和 dedicated digest
   必须一致，且 digest 不能等于原始 protocol hash；
2. wrong subject/action/activation/order/phase 必须失败关闭；
3. missing/duplicate action、foreign owner、early complete-object destruction 和
   failed-current-object cleanup 必须失败或得到严格 live-only 结果。

第一次构建得到预期编译 RED：`asCASTLifetimeView` 和
`asCASTBuildLifetimeView` 尚不存在，而不是测试未命中或 fixture 构建失败。

证据：

- `Saved/Build/cta-s55-derived-view-red/20260828_181026_800_754c0136/RunMetadata.json`。

## 实现架构

### 1. View 是 transient owner，不是新的 HIR/CFG

`as_ast_lifetime.h/.cpp` 新增：

- `asSASTLifetimeScopeEdge`：region、nearest lifetime parent、depth 和确定性结构
  ordinal；
- `asSASTLifetimeViewRecord`：原始 authenticated record、record index、scope
  edge index、activation ordinal 和同 region 的 reverse cleanup ordinal；
- `asSASTLifetimeCommitPoint`：activation/region、`liveBefore`、`liveAfter`、
  `abortCleanup` 和 `reverseLiveCleanup`；
- `asCASTLifetimeView`：只在调用方栈/临时所有权中存在的 rebuildable container；
- `asCASTBuildLifetimeView`：唯一共享构建入口。

View 没有 Context setter、DTO、encode/decode、publication 或 provider API。
Backend label、patch、slot、EH/cleanup stack、native frame ABI 均不进入 view。

### 2. 语义选择仍属于 Sema

View 只沿已经写入 record 的 snapshot-local ID 读取 immutable AST 节点并认证
关系：local 必须是 exact VarDecl，action target 必须是 exact DestructorDecl，
activation 必须是以该 local DeclRef 为左值的 exact `Assign`，semantic region
必须是包含其 DeclStmt/ExprStmt 的 exact Block。

这里的 stable-key/type-kind 检查是对 Sema 已选结果的 fail-closed
authentication，不是名称 lookup、overload resolution、type inference 或
destructor selection。View 不枚举候选函数，也不会用字符串重新选择动作。

### 3. Scope edge 与 live set 是机械派生

构建器先从 statement child edges 重建父表，再对 lifetime regions 做稳定排序，
为每个 region 找 nearest recorded ancestor。每条 lexical local record 的提交
ordinal 来自 block 中 exact initializer ExprStmt 的直接 child 位置。

对某个 commit：

```text
liveBefore        = 已进入的 ancestor region 中、控制边界之前已经提交的记录
                  + 当前 region 中 activation 之前已经提交的记录
liveAfter         = liveBefore + current record
abortCleanup      = reverse(liveBefore)
reverseLiveCleanup= reverse(liveAfter)
```

因此 initializer 失败时当前对象永远不会出现在 abort cleanup；正常离开时只
清理已经成功提交的对象并保持严格逆序。

### 4. Digest 独立于诊断渲染

Derived view 使用独立 `LTV1` hash domain，按 protocol revision、scope edges、
typed records、commit points 和每个 index array 做 fieldwise hash。测试在两次
build 之间显式调用 `asCASTDump()`，随后第二次 build 仍得到完全相同 typed
records/digest；dump 只是无关的诊断副作用。

## Verifier 负例矩阵

| 伪造/错误 | 结果 |
|---|---|
| subject 指向 DestructorDecl | `INVALID_LIFETIME_PROTOCOL` |
| value local 把 action 改成 `RELEASE_REFERENCE` | reject |
| activation 提前指向 initializer value 而非成功 Assign | reject |
| 同一 region 的 record storage order 逆于 commit order | reject |
| lexical local 伪装成 `FULL_EXPRESSION` | reject |
| cleanup action target 缺失 | reject |
| 同一个 subject/commit/action 重复记录 | reject |
| 任意 protocol node 携带 foreign/public owner token | reject |
| lexical local 提前宣称 complete-object commit/destruction | reject |
| protocol revision 不匹配 | `SemaFinalized -> LifetimePlanned` 失败且状态不前进 |
| 第二对象初始化失败 | `abortCleanup == [First]`，不含失败的 Second |

## 嵌套作用域证明

补充的 nested fixture 在 outer block 成功提交 `Outer`，随后进入 inner block
初始化 `Inner`。派生结果为：

- outer edge：无 parent，depth 0；
- inner edge：parent 为 exact outer region，depth 1；
- Inner `liveBefore == [Outer]`；
- Inner `liveAfter == [Outer, Inner]`；
- normal reverse cleanup 为 `[Inner, Outer]`；
- Inner initializer abort cleanup 为 `[Outer]`。

这证明全局 protocol record index 没有被误当成唯一动态控制流；view 使用
`semanticRegion + structural boundary + activation ordinal` 组合派生 live set。

## 验证结果

- Runtime/Editor 首次 GREEN build：PASS：
  `Saved/Build/cta-s55-derived-view-compile-3/20260828_182051_430_a918ced5/RunMetadata.json`；
- 旧 Context fixture 修正后的 build：PASS：
  `Saved/Build/cta-s55-context-fixture-build/20260828_182714_092_c7b2f2f9/RunMetadata.json`；
- nested scope fixture build：PASS：
  `Saved/Build/cta-s55-nested-scope-test-build/20260828_182929_610_2ff92e14/RunMetadata.json`；
- Context：**12/12 PASS**：
  `Saved/Tests/cta-s55-derived-view-context-green/20260828_182742_082_8c79cf8d/Report/index.json`；
- Verifier（含四个 15.5 用例）：**39/39 PASS**：
  `Saved/Tests/cta-s55-derived-view-verifier-green/20260828_182950_126_ea146c43/Report/index.json`；
- complete Frontend CanonicalAST：**163/163 PASS**：
  `Saved/Tests/cta-s55-derived-view-frontend-full/20260828_183134_280_ea5002a7/Report/index.json`；
- complete SemaAuthority：**400/400 PASS**：
  `Saved/Tests/cta-s55-derived-view-sema-authority/20260828_183041_450_2843b3f9/Report/index.json`；
- complete ProductionCodeGen：**119/119 PASS**：
  `Saved/Tests/cta-s55-derived-view-production-codegen/20260828_183216_506_ea7aea27/Report/index.json`。

Source scan 还证明 lifetime implementation 中没有 `asCASTDump`、numeric
TypeId、`asCScriptNode`、HIR/CFG、Provider/Sidecar/Cache 或 UObject 依赖；当前
consumer 只有 lifetime builder、Verifier 和专用测试。Backend 尚未消费它，这
是 15.7/15.8 的真实未完成状态，而不是遗漏记录。

## 本轮暴露并记录的问题

### 1. MSVC friend/export linkage 必须一致

第一次实现后的两个 build 失败不是算法错误，而是 exported free function 的
forward declaration、class friend declaration 和 DLL consumer 看到的 linkage
不一致。最终 friend declaration 与 `ANGELSCRIPTRUNTIME_API` 保持一致后，
Runtime producer 和 AngelscriptTest consumer 都能链接。

- 首次失败：
  `Saved/Build/cta-s55-derived-view-compile/20260828_181834_464_96c963e3/RunMetadata.json`；
- consumer 侧仍失败：
  `Saved/Build/cta-s55-derived-view-compile-2/20260828_181934_692_3fb27d10/RunMetadata.json`；
- 修正后 PASS：
  `Saved/Build/cta-s55-derived-view-compile-3/20260828_182051_430_a918ced5/RunMetadata.json`。

### 2. 旧 Context fixture 已与 15.4 语义漂移

首次 Context audit 为 **11/12 PASS**。失败 fixture 仍使用 Construct Expr 作为
activation，而且没有真实 `DeclStmt + Assign ExprStmt` block shape。15.4 已
明确 activation 是赋值成功边界，因此正确修复是更新 fixture，不是放宽
Verifier 重新允许 construct/declaration-before-success。

原报告：
`Saved/Tests/cta-s55-derived-view-context-audit/20260828_182446_870_a7336daa/Report/index.json`。

### 3. 当前 view 只接受 lexical local value record

这是有意的 staged closure。Owning reference/funcdef 的
`RELEASE_REFERENCE`、foreach phase named accessor 和 compatibility parity 属于
15.6；constructor base/member/delegating/complete-object steps 属于 15.9；
array/aggregate committed cursor 属于 15.10。当前实现对这些尚未定义的 record
shape 失败关闭，不通过 heuristic 猜测。

### 4. 空 protocol 仍是 compatibility state

当前 revision 的空 protocol 仍可通过，因为大量不需要 cleanup 的函数合法，
而“AST 中存在 cleanup encoding 却漏写 record”的双向 completeness 需要 15.6
用 named accessor 与 compatibility encoding 做精确对账。本轮的 missing-action
负例验证的是已存在 record 缺少 exact action；不能把它扩大解释为全 AST
cleanup completeness 已关闭。

### 5. `order` 仍是 protocol storage identity

Verifier 要求 `record.order == storage index`，并在同一 region 额外验证 storage
顺序严格跟随 activation ordinal。跨嵌套 region 的 live set/cleanup 由 scope
edge 和 structural boundary 派生，而不是把平面数组当运行时构造序列。

### 6. Standalone 明确延期

本轮没有改 Standalone source/CMake，也没有运行 Standalone gate。按用户决定，
Standalone 适配将在独立 OpenSpec 中处理，不阻塞 CTA-S53 Runtime 主链。

## 非声明

本轮没有关闭：

- 15.6 compatibility encoding named accessor/parity；
- 15.7 Bytecode protocol-only consumption；
- 15.8 TypedASTJIT protocol-only consumption；
- 15.9 constructor partial construction；
- 15.10 array/aggregate committed progress；
- 15.11 CTA-S53 final boundary gate；
- 5.7/5.8、7.5、9.1/9.5/9.6、13.2/13.6 umbrella tasks；
- product default CANONICAL cutover。

LEGACY 仍是产品默认；原生 AngelScript AST/Parser/Builder/Compiler 继续保留；HIR
保持物理删除。

## 进度影响

关闭 15.5 后，OpenSpec 机械进度为 **94/136（69.1%）**，剩余 42 项。考虑
shared lifetime/control proof boundary 已有统一实现并挂入 publish admission，
整体架构加权实现估计上调为 **约 81%**。直接 Canonical-AST AOT 仍约 63%；
Bytecode/Runtime 仍约 75%；action-only Sema 仍约 99%；安全默认切换准备度约
53%。默认切换仍受 15.6–15.11、backend protocol-only consumption、partial
construction 和最终产品矩阵约束；这些估计不包含延期的 Standalone 适配。
