# Public AST V1：语义遍历、源坐标与版本协商闭环（2026-08-23）

## 结论

Public AST V1 不再只是“能拿到 TranslationUnit 的几个字段”。当前实现把已经封存于
`asCASTContext` 的只读语义图，以**快照归属、无内部地址、可遍历、可定位**的形式公开：

```text
asIASTSnapshot lease
  |
  +-- GetTranslationUnitDecl()
        |
        +-- GetDeclChild() ---> DeclView (sourceRange, QualType, body, traits)
                                  |
                                  +-- GetStmt(body) ---> StmtView (owner/target/expr)
                                                         |
                                                         +-- GetExpr(expr) ---> ExprView
                                                                (value category,
                                                                 resolved declaration,
                                                                 receiver, children)

sourceRange.begin.file (snapshot-owned opaque ID)
  |
  +-- GetSourceFile()       -> logical key/origin/line offset/byte length
  +-- GetSourceLineColumn() -> 1-based published coordinates
```

这满足 `design.md` 第 6 节中 V1 对 source range、精确 QualType/value category、
resolved semantic edges、children 和 stable keys 的可观察性要求，同时没有泄漏
`asCDecl*`、`asCStmt*`、`asCExpr*`、`asCTypeInfo*`、`asCScriptFunction*`、Engine
FunctionId 或可写 AST 存储。

这不是 Canonical AST 已成为默认编译器，也不是 Cache V2/LLVM 后端已完成。它只完成了
“一个已保留且已封存的 AST generation 可以被外部只读分析”的 V1 API 面。

## 实现边界

### 公开数据与操作

`Core/angelscript.h` 现在定义：

- `asASTSourceFileId`：同 Decl/Stmt/Expr/Type ID 一样携带 `snapshotOwner`。不能把
  snapshot A 的源文件 ID 交给 snapshot B。
- `asSASTSourceLocation` / `asSASTSourceRange`：紧凑的 file + byte offset 坐标；
  range 必须是同一个公开 source-file ID 的有序区间。
- `asSASTSourceFileView`：`logicalKey`、origin、`lineOffset`、`byteLength`，但**不**
  返回内部 buffer 指针或节点地址。
- 公共 Decl/Stmt/Expr/Type kind 名称以及 qualifier、trait、value-category、safe-point
  和 accessor 枚举值。枚举只是稳定的 view 值，不暴露私有类层次。
- Decl view：`sourceRange`、`typeQuals`、`body`、traits、accessor relation、child count。
- Stmt view：`sourceRange`、owner、transfer target、expression、decl、safe-point、child count。
- Expr view：`sourceRange`、value category、resolved declaration、receiver、literal bits、
  safe-point、child count。
- 追加在 `asIASTSnapshot` 尾部的单边查询：`GetDeclChild`、`GetStmtChild`、
  `GetExprChild`、`GetSourceFile` 和 `GetSourceLineColumn`。

查询一次只返回一个 opaque child ID，而不是把内部 `asCArray` 或可变数组交给调用方。
这使并发只读、后续 V2 扩展和 snapshot lease 生命周期保持可控。

### 版本与错误优先级

所有 `Get*View` 调用的规则现在固定为：

1. `structSize` 必须至少是当前 V1 view 的完整尺寸，否则返回 `asINVALID_ARG` 并且不写输出；
2. opaque ID 必须属于当前 snapshot，否则返回 `asINVALID_ARG` 并且不写输出；
3. `apiVersion == 0` 是 aggregate-zero-init 的 V1 便捷写法，显式
   `asAST_API_VERSION_1` 也合法；其他非零版本返回 `asNOT_SUPPORTED` 并且不写输出；
4. 成功才回写完整 V1 view，并把 `apiVersion` 写成 V1。

第 2 步必须先于版本协商：外来 ID 不能因为调用者的缓冲区里碰巧留下非 V1 哨兵值而得到
不同错误，也不能被错误解引用。此前整组回归正好暴露了这个优先级回归；修正后恢复了
foreign-ID fail-closed 行为。

### ABI 说明

当前 `asIScriptModule` 中的三项 AST 方法位于现有接口的**尾部**，不会移动此前模块虚表槽。
本轮新增的 `asIASTSnapshot` 查询也追加在该新接口的既有 V1 方法之后。

当前工作树的 V1 是尚在改造中的 API，原先的 incomplete view layout 没有应被视为可对外发布的
契约；本轮以完整 `structSize` 校验锁住了新布局。任何外部发布前仍应执行产品/二进制分发审计：
如果曾存在包含旧 incomplete layout 的已发布二进制，必须用新的 API version/extension interface
做迁移，不能声称二进制兼容。

## TDD 与验证证据

红测先于实现：

| 阶段 | 证据 | 结果 |
| --- | --- | --- |
| 缺少语义/源遍历 API | `Saved/Build/cta-public-ast-v1-traversal-red-build/20260823_073625_561_13242952` | 预期编译失败：view 没有 `childCount`/`body`/`sourceRange`，snapshot 没有 child/source 查询，kind/value-category 枚举未公开。 |
| 不兼容 view 版本 | `Saved/Tests/cta-public-ast-v1-version-red/20260823_074348_747_22ebf1f6` | 预期 0/1：非零 V2 请求被静默当 V1 写入。 |
| 语义遍历实现 | `Saved/Build/cta-public-ast-v1-traversal-green-build/20260823_073931_786_168906f2` | Editor target build 成功。 |
| 语义遍历组 | `Saved/Tests/cta-public-ast-v1-traversal-green/20260823_074218_199_943bb2c6` | Snapshot group 8/8 passed。 |
| 版本协商 | `Saved/Build/cta-public-ast-v1-version-green-build/20260823_074452_039_265943fc` + `Saved/Tests/cta-public-ast-v1-version-green/20260823_074735_843_dcceeef9` | build 成功；专门版本协商测试 1/1 passed。 |
| 验证次序回归修正 | `Saved/Build/cta-public-ast-v1-validation-order-green-build/20260823_074940_620_35acce6b` + `Saved/Tests/cta-public-ast-v1-contract-final/20260823_074952_238_0c371800` | build 成功；完整 Snapshot group **8/8 passed**。 |

新增端到端测试 `RetainedV1SnapshotTraversesSourceAndResolvedSemanticEdges` 使用：

```angelscript
int F(int Value) { return Value; }
```

它实际遍历 `TU -> F -> body block -> return -> DeclRef -> Value parameter`，并验证：

- authored source origin、稳定逻辑源名与 `lineOffset=7 -> line 8`；
- body/owner/expression 的 snapshot-local semantic edges；
- `DeclRef` 的 lvalue category 与 resolved parameter declaration；
- 外部 source coordinates 和 children 不依赖内部节点指针。

## 仍未关闭的关联工作

- **3.4 / 9.x / 13.2**：生产编译的完整 canonical authority 仍未完成；Public AST 只展示已保留图，
  不会让 partial AST 成为语义或 Bytecode authority。
- **3.7 / 13.8**：需要继续审计并强化 Acquire/publication 的真实并发协议、失败发布保留最后成功
  generation、以及 StaticJIT generation 对 snapshot lease 的持有；本轮 API 只读面不能替代该工作。
- **13.9**：Cache V2 的 pointer-free AST DTO、验证后 restore 和 ExactStartup 原子 activation 尚未完成。
- **11.4**：面向 embedding client 的发布迁移说明，应在 ABI 分发审计完成后写入正式 Guide；本附件仅是
  本次实现证据和不变量记录。
