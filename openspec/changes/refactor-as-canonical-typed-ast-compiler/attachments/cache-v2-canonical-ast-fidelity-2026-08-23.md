# Cache V2 Canonical AST fidelity proof（2026-08-23）

## 背景与缺口

Cache V2 已有 `ASTBodySidecar`（schema V2）与 Exact Startup 恢复链，但原有
warm-start 测试只断言恢复模块能取得一个 `asIASTSnapshot`。这无法区分：

```text
完整 AST DTO 恢复   vs.   只恢复 TranslationUnit 壳图
```

因此，本次在真实的 Cache V2 cold-capture → 存储 → Exact Startup restore 流程中，
补充了**只使用公开 AST V1 视图**的深度遍历验证；没有通过 internal context 或
Parser/Sema 辅助来让测试“看起来通过”。

## 锁定的行为

样例源为 `int Answer() { return 42; }`。在消费者引擎启用
`asAST_RETAIN_SNAPSHOT` 后，Exact Startup 必须在零 frontend work 情况下恢复模块，
并让 AST V1 依次观察到：

```text
TranslationUnit
  └─ FunctionDecl "Answer"
       └─ CompoundStmt
            └─ ReturnStmt
                 └─ IntegerLiteral "42"
```

测试逐层验证：翻译单元 child edge、函数声明 kind/name/body edge、函数体中的首条
语句、`ReturnStmt`、其 expression edge，以及整数文字 node/payload。若 DTO 被
替换为仅有 root 的占位对象，或 body/reference/literal 字段在 Cache 恢复时被丢弃，
测试会失败。

日志中的 producer 也确认该样例生成了一个含 `8` 个 pointer-free Cache V2 records
的 cold generation；Exact Startup 的现有断言继续确认不运行 frontend/compiler，且
不发布新的 Store generation。

## 范围与非结论

- 这是 13.9（Cache DTO）的**fidelity evidence 增量**，不是任务关闭。它只覆盖
  单函数整数返回的端到端形状。
- `as_ast_sidecar` 的 DTO 已携带 source/type/decl/stmt/expr/reference/dependency
  字段；后续仍需为更广的函数、类型、依赖及 SourceManager provenance 建立同等级
  的恢复证明。
- 此项不改变默认编译器选择；生产默认仍为 LEGACY，Cache 恢复的 VM 路径也不等同
  于 Canonical CodeGen 已覆盖完整语言。

## 修改与验证

- 修改：
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheExactWarmStartupTests.cpp`
  - 扩展 `RetainedCanonicalAstPolicyRestoresPublishedSnapshotWithoutFrontendWork`。
- 构建：
  `Saved/Build/cta-cache-sidecar-fidelity-build-rerun/20260823_114747_046_9081be73/RunMetadata.json`
- 深度恢复专项：`1/1 PASS`：
  `Saved/Tests/cta-cache-sidecar-fidelity/20260823_114805_998_b0f748ee/RunMetadata.json`
- ExactWarmStartup 回归：`6/6 PASS`：
  `Saved/Tests/cta-cache-sidecar-fidelity-exact-warm/20260823_114853_967_ffcdadb3/RunMetadata.json`
