# AS_CanonicalTypedAST — 密封 typed AST 与公开 V1

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: canonical Parser/Sema、密封 interned typed AST、Bytecode CodeGen、公开 snapshot V1、Cache AST sidecar
> **关键源码**:
> `ThirdParty/angelscript/source/as_source_manager.*`
> · `as_ast_context.*` / `as_decl.*` / `as_stmt.*` / `as_expr.*` / `as_ast_type.*`
> · `as_sema*.*` / `as_bytecode_codegen.*` / `as_ast_public_view.*`
> · `AngelscriptRuntime/Cache/AngelscriptCacheASTBodySidecar.*`
> **关联文档**:
> `Documents/Guides/AngelscriptCanonicalAST.md` — 嵌入方迁移与公开契约
> · `AS_Compiler.md` — 内部 `asCCompiler` 仍覆盖完整语言面
> · `AS_Parser.md` — `asCScriptNode` 作为语法树
> · `RT_CacheV2.md` — `ASTBodySidecar`
> · `RT_StaticJIT.md` — TypedASTJIT 可消费密封 AST（若存在）；HIR oracle 仍在

## 一句话

新引擎默认 `asCOMPILER_PIPELINE_LEGACY`。`asCOMPILER_PIPELINE_CANONICAL` 是可选的捕获/旁路挂接：可以在编译旁构建密封 AST，但在 `asCModule::Build()` 从 `asCBytecodeCodeGen::Generate()` 发布字节码之前，`IsCanonicalBytecodeCodeGenReady()` 保持 false。生产字节码仍由 `asCCompiler` 发出。LLVM/Clang 是非目标，不进产品和 Standalone 链接。

## 流水线

目标前端是 Clang 形态，但不链接 LLVM：

```text
SourceManager
  → Parser Sema 动作
  → interned QualType AST
  → verifier 密封
```

- 新引擎默认 `asCOMPILER_PIPELINE_LEGACY`。
- `asCOMPILER_PIPELINE_CANONICAL` 是可选的捕获/旁路挂接，直到 `Build()` 从 `asCBytecodeCodeGen::Generate()` 发布。
- `IsCanonicalBytecodeCodeGenReady()` 当前为 false。
- 没有生产 `dual` 选择，也没有 `asCOMPILER_PIPELINE_DUAL`。
- 隔离的 `asCBytecodeCodeGen` 可以从密封 AST 发出语言子集。生产 `Build()` 仍记录 `asBYTECODE_PUBLISHER_COMPILER`（`asCCompiler`）。
- 公开 AST V1 只有不透明 ID 和 POD view，不是具体节点 ABI。
- 默认 discard：`Build()` 后不发布 snapshot。retain 必须在 `Build()` 前设置。
- retain 策略下，`CompileFunction(asCOMP_ADD_TO_MODULE)` 还没有将新增声明合并进
  Canonical AST；成功追加后必须 retire 旧 snapshot。旧 lease 仍可只读遍历，但新的
  `AcquireASTSnapshot` 返回空，直到下一次完整 `Build()` 发布包含全部声明的新 generation。
- HIR oracle 仍在；默认不捕获 sidecar HIR。Cache 用 `ASTBodySidecar`（kind 8），不进 `SaveByteCode`。

用 `asCModule::GetLastBytecodePublisher()` 观察是谁发布了字节码。流水线开关本身不是那份证明。

## 本轮未删除的内部件

`asCCompiler`、解析器 `asCScriptNode`、以及 TypedASTJIT/测试用的 HIR 类型仍在 fork 里。原因是 Bytecode CodeGen 还不是生产 `Build()` 的发布者，TypedASTJIT goldens 仍会查阅 HIR oracle。生产默认不捕获 HIR，不注册 dual 选择，也不把解析器节点存在 `ScriptFunctionData` 上。
