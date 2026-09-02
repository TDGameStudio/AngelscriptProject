# CTA-S47：CANONICAL Sema 原生语法节点依赖审计与死适配器退役

日期：2026-08-28  
Change：`refactor-as-canonical-typed-ast-compiler`  
关联任务：`13.2`（部分推进，仍未关闭）、`0.2`、`0.3`

## 1. 本轮结论

本轮把 CANONICAL Sema 中仍出现的 `asCScriptNode` 相关代码分成了两类，
并只删除了已经能够证明没有调用方的第一类：

1. **已退役的语义遍历残留**：`as_sema_decl.cpp`、
   `as_sema_expr.cpp` 和 `as_sema_stmt.cpp` 中没有调用方的 native-node
   include、文本提取、scope 遍历和 source-range 适配器。它们会让代码审阅者
   误以为 CANONICAL Sema 仍可从完成的 AngelScript 原生 AST 重新解码语义；
   现已物理删除，并由源码架构测试锁定。
2. **仍保留的构建期语法身份桥**：`as_sema.cpp/.h` 中的
   `FindParsedDeclaration`、`BindParsedDeclarationIdentity`、
   `Bind/FindParsedExpressionType` 和 `Bind/FindParsedExpressionIdentity`。
   它们只读取 node pointer、`nodeType`、section、token offset/length，映射到
   已经由 typed Parser action 创建的 `DeclId`、`ExprId` 或 `QualType`；不遍历
   child，不根据 `nodeType` 重新执行表达式/声明语义。它们仍被 Parser、Builder
   和 LEGACY function-body reparse 使用，因此本轮没有删除。

这保持了用户确认的边界：原生 AngelScript AST 继续保留给 Parser、LEGACY、
恢复、参考与差分测试；HIR 继续保持删除；CANONICAL Sema 不能把原生 AST 当作
第二语义输入。

## 2. 发现的问题与处置

### CTA-S47-I1 — 无调用方的 native-node walker 仍留在 Sema 源码中

**状态：已解决。** 只读调用方扫描确认以下函数只有定义、没有调用：

- `as_sema_decl.cpp::RangeOf(...)`；
- `as_sema_expr.cpp::NodeText(...)`；
- `as_sema_expr.cpp::ScopeText(...)`；
- `as_sema_expr.cpp::ExprRange(...)`；
- `as_sema_expr.cpp::ResolveScopeOwner(...)`。

其中 `ResolveScopeOwner` 会遍历 `scopeNode->firstChild/next`、读取 token kind 和
identifier spelling；虽然当前已经是死代码，但其存在本身仍保留了一条可被重新
接回的 native-tree semantic replay 路径。现已删除上述函数以及三个完成 action
单元中不再需要的 `as_scriptnode.h` include。

### CTA-S47-I2 — “保留原生 AST”容易被误解为“Sema 可以继续读取原生 AST”

**状态：边界已明确并加门禁。** 原生 AST 的保留范围是：

- Parser 的语法树产物；
- LEGACY 编译器和回滚；
- 错误恢复、语法参考和差分测试。

它不是 CANONICAL Sema 的第二个语义 IR。新增源码架构测试要求完成 typed action
迁移的 declaration/expression/statement 单元不能再 include `as_scriptnode.h`，
也不能恢复本轮删除的 walker。该测试不会禁止 Parser/LEGACY 继续创建和使用原生
AST。

### CTA-S47-I3 — Parser/Builder 仍通过 node identity 找 Canonical ID

**状态：开放迁移债务，不属于当前 semantic replay。** 现有桥接读取：

- pointer-exact identity；
- source section；
- `tokenPos` / `tokenLength`；
- expression binding 额外读取 `nodeType` 作为坐标歧义的一部分。

它返回已经存在的 Canonical `DeclId`、`ExprId` 或 `QualType`，不读取 child、不做
name/type/operator/call/control-flow 决策。当前调用方包括 Parser action composition、
Builder 将稳定 declaration identity 绑定到 prepared Runtime shell，以及 LEGACY
body reparse 后的 lambda/target-type 恢复。

因此它与已删除的 walker 不同，不能仅按字符串 `asCScriptNode` 一刀切。任务
`13.2` 仍保持未完成，最终目标是以 Parser 自己拥有的稳定 parse-action identity
替代 node pointer/coordinate map，但迁移必须先处理 body reparse 和 Builder shell
绑定，且保持歧义 fail-closed。

### CTA-S47-I4 — LEGACY function-body reparse 会改变 node pointer

**状态：开放 cutover blocker。** `FindParsedDeclaration` 和较宽的 expression
lookup 在 pointer miss 后使用 section + exact token coordinates，并且只接受唯一
匹配。这是当前 lambda 等 body reparse 能关联回已建 Canonical identity 的原因。

直接删除坐标 fallback 会让同一源文本的第二次 Parser 节点地址无法找到第一次
action 创建的 identity；直接放宽为“同 offset 第一项”则会引入静默错绑。后续
方案必须满足：

1. Parser action 生成独立于 node address 的 build-local identity；
2. reparse 可复现同一 identity，或 CANONICAL 路径不再依赖 LEGACY reparse；
3. 重复坐标/恢复节点继续 fail-closed；
4. build-local ID 不进入 snapshot、cache、Runtime ABI 或持久 TypeId。

### CTA-S47-I5 — 第一次 RED 构建是测试宏错误，不是产品 RED

**状态：已纠正并保留证据。** 新测试最初把 CQTest 的 message 参数放在
`ASSERT_THAT` 外层，导致 C4002，路径为：

`Saved/Build/cta-s47-red/20260828_103834_887_a6ff6961/RunMetadata.json`。

该结果只证明测试代码未编译，不能作为产品缺口证据。修正宏写法后重新构建通过，
随后聚焦测试得到干净的 **0/1 RED**，失败原因仅为产品源码中仍存在 native-node
include/walker。本附件明确区分两次结果，避免把无效 RED 写成实现证据。

### CTA-S47-I6 — 任务 13.2 与最终 AST-first gate 仍未完成

**状态：开放。** 本轮关闭的是 completed declaration/expression/statement Sema
单元中的死语义 walker，不等于整个构建链已经没有 native node identity。剩余
工作至少包括：

- 用 pointer-free parse-action identity 替代上述构建期映射；
- 处理 Builder prepared Runtime shell 的 declaration 关联；
- 处理 lambda/target-type 的 LEGACY body reparse；
- 对 Parser、Builder、Sema、Bytecode 和 TypedASTJIT/AOT 做最终静态/执行矩阵；
- 保证原生 AST 仍保留，但不能重新成为 CANONICAL 语义 transport。

## 3. 实现改动

### Runtime / Sema

- `as_sema_decl.cpp`
  - 删除未使用的 `as_scriptnode.h`；
  - 删除未使用的 `RangeOf(asCScriptNode*)`。
- `as_sema_expr.cpp`
  - 删除未使用的 `as_scriptnode.h`；
  - 删除 `NodeText`、`ScopeText`、`ExprRange`、`ResolveScopeOwner`；
  - 继续使用 action payload 中已经复制的 spelling、range、scope segments 和
    `absoluteScope`，以及 live `ResolveScopeSegments`。
- `as_sema_stmt.cpp`
  - 删除未使用的 `as_scriptnode.h`。

### Test

在 `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` 新增：

`CanonicalSemaExpressionAndStatementUnitsDoNotWalkNativeSyntaxNodes`

它验证：

- declaration/expression/statement Sema 完成单元不 include `as_scriptnode.h`；
- 本轮退役的五个 adapter 不得重新出现；
- 现有保留原生 AST 的 Parser/LEGACY 契约由同一测试类中既有门禁继续保护。

## 4. TDD 与验证证据

| 阶段 | 结果 | 证据 |
|---|---:|---|
| 初始测试编译 | FAIL，测试宏错误；不计产品 RED | `Saved/Build/cta-s47-red/20260828_103834_887_a6ff6961/RunMetadata.json` |
| 修正测试后的 RED 编译 | PASS | `Saved/Build/cta-s47-red-compile/20260828_103959_347_5bbeff27/RunMetadata.json` |
| 聚焦 clean RED | **0/1**，仅因 native-node include/walker 存在 | `Saved/Tests/cta-s47-red/20260828_104026_673_fbf31b4d/RunMetadata.json` |
| 实现后构建 | PASS | `Saved/Build/cta-s47-green/20260828_104155_621_74b1d028/RunMetadata.json` |
| 聚焦 GREEN | **1/1 PASS** | `Saved/Tests/cta-s47-focused-green/20260828_104217_681_acffd96e/RunMetadata.json` |
| 完整 SemaAuthority | **397/397 PASS** | `Saved/Tests/cta-s47-sema-green/20260828_104252_937_e15afc6d/RunMetadata.json` |
| OpenSpec strict validation | PASS，`Change ... is valid` | `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` |
| parent/plugin whitespace gate | PASS；只有既有 LF/CRLF 提示，无 error | parent 与 `Plugins/Angelscript` 的 `git diff --check` |

所有正式 GREEN 均为零失败、零跳过。源码删除经过 `git diff --check`；附件同步
后的 OpenSpec strict validation 和 parent/plugin diff check 均已通过。

## 5. 进度影响

- OpenSpec 勾选项不变：**87/125（69.6%）**；
- 加权整体实现维持：**约 77%**；
- whole-Sema action-only authority 仍保守记为：**约 98%**；
- Canonical Bytecode/Runtime：**约 73%**；
- direct Canonical-AST AOT：**约 55%**；
- safe default readiness：**约 50%**；
- 默认编译器仍为 **LEGACY**。

本轮提高的是架构边界的可信度，不足以关闭 `13.2` 或任何 backend/cutover
umbrella。原生 AST 继续保留；HIR 继续保持删除；dump 继续只用于观察，不作为
AST/AOT transport。
