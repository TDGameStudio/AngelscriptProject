# CTA-S53 15.4：局部对象成功敏感激活门

日期：2026-08-28

## 结论

Task 15.4 已完成。局部值对象不再因为 Sema 看见 `DeclStmt` 就被视为
live；名字声明和生命周期激活现在是两个不同事实：

1. `DeclStmt` 只引入局部名字和存储身份；
2. 对应初始化 `Assign` 完整成功后，局部对象才进入 committed-live 集合；
3. 失败的当前对象不进入异常清理集合；
4. 已提交对象在正常、return、跨作用域 transfer 和异常路径上保持严格逆序
   清理语义。

Sema 同时为值对象写入 revision 1 snapshot-owned lifetime record，记录精确的
局部声明、析构动作、初始化成功提交点、语义 block、阶段和 exit mask。记录
不包含 Runtime 指针、Engine 数字 TypeId、backend label/slot/stack 或 dump
字符串身份。

## TDD RED

新增 AST-first fixture：

```angelscript
int Entry()
{
    FSuccessSensitiveValue First(1, false);
    FSuccessSensitiveValue Second(2, true);
    return 0;
}
```

`FSuccessSensitiveValue` 的构造函数在设置 `Id` 后调用可抛异常的 native
`LifetimeInitializer(bool)`。测试要求：

- `First` 和 `Second` 各有且只有一条 `LOCAL / DESTROY_VALUE` 记录；
- activation point 必须是各自的初始化 `Assign ExprId`，不能是 `DeclStmt`；
- semantic region 必须是 `Entry` 的精确 body block；
- phase 必须是 `LEXICAL_SCOPE`，exit mask 必须包含全部当前支持退出；
- `Second` 提交前的 abort snapshot 只能包含 `First`；
- 两者都提交后的正常清理必须是 `Second -> First`。

首次运行得到预期 **0/1 RED**。快照本身已经给出足够事实：

- `First`：`DeclStmt 5`，commit `Assign Expr 18`；
- `Second`：`DeclStmt 8`，commit `Assign Expr 25`；
- lifetime protocol record count 为 0。

因此失败原因是缺少协议作者，而不是 fixture 无法编译、无法找到初始化表达式
或测试未命中。

证据：

- 编译：`Saved/Build/cta-s54-local-activation-red/20260828_174558_321_ad32f3b1/RunMetadata.json`；
- RED：`Saved/Tests/cta-s54-local-activation-red-2/20260828_174944_580_9eb1a224/Report/index.json`。

## 实现

实现集中在 `as_sema_stmt.cpp`，没有加入 backend 私有协议或新的中间 IR。

### 1. 精确析构动作

`FindLexicalValueDestructor` 从已完成的 Canonical 类型/声明图中选择精确
destructor DeclId。`GetLexicalCleanupRoute` 复用该结果，不再重复按类型名循环
选择。该选择仍然属于 Sema，而不是交给 Bytecode/AOT 重新猜测。

### 2. 精确成功提交点

`FindLexicalActivationPoint` 从某个局部 `DeclStmt` 后开始，在下一个声明前查找
以该局部 `DeclRef` 为左值的精确初始化 `Assign`。如果一个需要清理的局部没有
这种提交表达式，CANONICAL 路径以 `local-lifetime-activation-invalid` 失败关闭，
不会退回到“声明即存活”。

### 3. 成功后才进入 transfer live set

旧实现进入 block direct-child 循环时，一遇到 `DeclStmt` 就把 declaration 放入
`activeDeclarations`。新实现先使用当前 live set 遍历该 child 及其 transfer，
只有整个初始化 `ExprStmt` 处理完成后，才按 activation ExprId 加入局部对象。

这使显式 return/break/continue/fallthrough 的 compatibility cleanup plan 与
success-before-active 规则一致。初始化表达式自身抛异常时，当前对象尚未进入
active set。

### 4. Sema 写入不可变协议事实

每个局部值对象写入：

```text
subjectKind       = LOCAL
subject           = exact local DeclId
actionKind        = DESTROY_VALUE
actionTarget      = exact destructor DeclId
activationPoint   = exact initializer Assign ExprId
semanticRegion    = exact enclosing Block StmtId
phase             = LEXICAL_SCOPE
supportedExitMask = ALL
constructionStep  = 0
order             = deterministic protocol storage index
completeCommit    = false
```

写入仍只允许发生在 `Building` 阶段；后续
`SemaFinalized -> LifetimePlanned` 会认证 revision、节点存在性、动作类型和顺序，
Frozen/Publishable 后不可修改。

## ProductionCodeGen 行为门

生产 fixture 使用同一对象模型，另外在脚本析构函数中调用
`RecordLifetimeDestructor(Id)`。同一个已发布函数执行两次：

| 路径 | initializer 尝试 | 执行结果 | 析构记录 |
|---|---:|---|---|
| `FailSecond=false` | 2 | `FINISHED`, return 42 | `[2, 1]` |
| `FailSecond=true` | 2 | `EXCEPTION` | `[1]` |

两条路径都确认 module publisher 是
`asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`，LEGACY compiler invocation count 为
0。

证据：

- 增量 build：`Saved/Build/cta-s54-local-activation-green/20260828_175216_235_3527a38f/RunMetadata.json`；
- AST-first GREEN：`Saved/Tests/cta-s54-local-activation-green/20260828_175229_911_6f948b1c/Report/index.json`；
- production fixture build：`Saved/Build/cta-s54-production-lifetime-gate/20260828_175425_209_a98a785a/RunMetadata.json`；
- production focused **1/1 PASS**：`Saved/Tests/cta-s54-production-lifetime-gate/20260828_175453_987_5d32d896/Report/index.json`；
- complete ProductionCodeGen **119/119 PASS**：`Saved/Tests/cta-s54-production-codegen/20260828_175539_301_f5182c0d/Report/index.json`；
- complete SemaAuthority **400/400 PASS**：`Saved/Tests/cta-s54-sema-authority/20260828_175620_001_b77567c4/Report/index.json`；
- complete Frontend CanonicalAST Verifier **35/35 PASS**：`Saved/Tests/cta-s54-lifetime-verifier/20260828_180059_629_aec7d17f/Report/index.json`；
- `openspec validate refactor-as-canonical-typed-ast-compiler --strict` PASS；
- parent/plugin `git diff --check` PASS（仅 Git 的 LF/CRLF 工作区提示）。

## 本轮暴露并记录的问题

### 1. Worktree 正式入口必须使用 `D:\as-cta`

从底层路径
`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`
启动 `RunBuild.ps1` 时，脚本会校验失败，因为 `AgentConfig.ini` 的
`ProjectFile` 是 `D:\as-cta\AngelscriptProject.uproject`。这不是源码失败，也
不应通过改写机器配置规避；本 worktree 的构建/测试正式入口应使用
`D:\as-cta`。

### 2. CQTest 精确名称包含测试类段

第一次使用
`...SemaAuthority.LocalValueLifetime...` 得到零测试命中。实际完整路径是：

```text
...SemaAuthority.FCanonicalASTSemaAuthorityTests.LocalValueLifetime...
```

零命中结果没有作为 RED 证据；只有随后精确命中的 0/1 失败报告被记录。

### 3. VM 已有 success-before-active 能力，但还没有消费新协议

生产异常测试在 Sema 修复后无需修改 VM object-init/unwind 私有状态即可通过。
这说明现有 VM 的 `asOBJ_INIT`/对象变量展开已经遵守“成功后激活”，本轮缺口是
Sema 显式协议和 transfer compatibility plan 的激活时机。

这不等于 Task 15.7 完成。Bytecode 当前仍可通过 compatibility cleanup
statements、对象变量 metadata 和现有 exception unwind 实现行为；它尚未被
要求只从 authenticated shared lifetime view 取得语义清理动作。

### 4. Compatibility 编码仍然存在

`scope-exit`、`scope-release` 和 foreach positional child 尚未删除，也尚未完成
与协议/shared view 的双向等价校验。它们由 15.6 迁移。15.4 只修正普通局部
清理 plan 的 activation 时机并为值对象写入协议记录。

### 5. 引用/funcdef 还没有协议记录

本轮 success-sensitive direct-child activation descriptor 同时用于现有 owning
reference/funcdef transfer plan，但 revision 1 的新 record 当前只为值对象写入
`DESTROY_VALUE`。`RELEASE_REFERENCE` 的精确 action/accessor 和 compatibility
parity 属于 15.6，不能把本轮结果扩大解释为引用生命周期闭环。

### 6. `order` 不是跨嵌套控制流的平面执行序列

当前 `order` 是确定性的 protocol storage index，并在同一 block 内保留源提交
顺序。嵌套 block 的动态 activation 必须由 15.5 shared view 根据
`semanticRegion + activationPoint + control traversal` 推导，不能把全局 record
数组顺序直接当成唯一运行时构造序列。15.5 的 wrong-order/duplicate/failed-
current-object 负例必须明确覆盖这一点。

### 7. Standalone 不属于本轮范围

15.4 没有改 Standalone source/CMake，也没有运行 Standalone gate。15.3 已有的
20/20 结果仅作为历史证据保留；后续 Standalone 适配已按用户决定延期到独立
OpenSpec，不再阻塞 CTA-S53 Runtime 主链。

## 非声明

本轮没有关闭：

- 15.5 transient shared lifetime/control view；
- 15.6 compatibility encoding parity；
- 15.7 Bytecode protocol-only consumption；
- 15.8 TypedASTJIT protocol-only consumption；
- 15.9 constructor partial construction；
- 15.10 array/aggregate progress；
- 5.7/5.8、7.5、9.1/9.5/9.6、13.2/13.6 等 umbrella tasks；
- product default CANONICAL cutover。

LEGACY 仍是产品默认；原生 AngelScript AST/Parser/Builder/Compiler 继续保留；HIR
保持物理删除。

## 进度影响

关闭 15.4 后，OpenSpec 机械进度为 **93/136（68.4%）**，剩余 43 项。考虑
success-before-active 已进入真实 Sema 协议且正常/异常生产行为有门禁，整体
架构加权实现估计上调为 **约 80%**。直接 Canonical-AST AOT 仍约 63%；
Bytecode/Runtime 约 75%；action-only Sema 仍约 99%；安全默认切换准备度约
51%。这些估计不包含延期的 Standalone 适配完成度。
