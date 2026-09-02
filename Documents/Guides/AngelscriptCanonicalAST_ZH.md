# Canonical Typed AST 嵌入与迁移说明

英文版：[AngelscriptCanonicalAST.md](AngelscriptCanonicalAST.md)

本文说明 Canonical Parser / Sema / sealed AST 编译链对嵌入方的当前契约。源码
血缘和 fork 策略见 `AngelscriptForkStrategy.md`。LLVM/Clang 只作为架构参考；
生产插件和 Standalone 不链接、不包含、也不复制 `llvm::` 或 Clang AST 类型。

## 编译管线

新 Engine 当前仍默认 `asCOMPILER_PIPELINE_LEGACY`。嵌入方可以在编译前显式
选择 `asCOMPILER_PIPELINE_CANONICAL`。CANONICAL 模块构建的真实路径是：

```text
SourceManager → Parser typed actions → Sema scope/type/call/lifetime
              → interned QualType AST → verifier seal
              → detached Bytecode artifact 或 direct TypedASTJIT/AOT visitor
```

CANONICAL `Build()` 从同一个 sealed AST 调用
`asCBytecodeCodeGen::Generate()`；CANONICAL `CompileFunction()` 使用只覆盖该函数
closure 的临时 sealed AST 和 `GenerateFunction()`。不支持的形式 fail-closed，
不能静默退回 `asCCompiler`，也不能合并 LEGACY 语义。生产环境没有 `dual` 模式。

- Public AST V1 只公开 snapshot-owned opaque ID 和容量协商 POD view；具体节点、
  mutable ASTContext、Engine pointer、Runtime TypeId 和 generation-local binding
  都是私有实现。
- 原生 AngelScript Parser tree、Builder 和 Compiler 继续保留给语法/恢复、显式
  LEGACY、差分测试和回滚，但不是 CANONICAL backend transport。
- HIR 已经物理删除。AST dump/diagnostic 只是观察器；dump、HIR replay 或文本
  序列化都不能作为 AST 到 Bytecode/AOT 的传输层。
- `SaveByteCode()` 和 VM `FunctionBody` 保存可执行 Bytecode，不保存 AST。
  Cache V2 的可选 `ASTBodySidecar` 是独立的 pointer-free snapshot DTO 边界。

需要证明某一代 Bytecode 的发布者时，应通过 maintained-fork diagnostics/tests
读取 `asCModule::GetLastBytecodePublisher()`；仅看 pipeline flag 不构成发布证明。

TypedASTJIT 直接租用 retained sealed AST snapshot，不构造 dump/HIR sibling
compiler pipeline。

## Public AST V1 契约

| 项目 | 契约 |
| --- | --- |
| Header / 产品版本 | 使用插件当前 `angelscript.h` 编译。产品版本是 `Unreal AngelScript 1.0.0`（`10000`）；vanilla `23300` 不是本产品 ABI。 |
| ABI 位置 | 三个 module AST 方法位于 `asIScriptModule` vtable 尾部，保留此前 product 1.0.0 方法位置；具体 AST 节点类不是 public ABI。 |
| Policy 时机 | 首次 `Build()` 前调用 `SetASTRetentionPolicy()`。默认 `asAST_DISCARD_AFTER_CODEGEN`；Build 开始后 policy 冻结，原地修改返回 `asNOT_SUPPORTED`。 |
| Retain | `asAST_RETAIN_SNAPSHOT` 只在完整 source build 成功且 AST sealed/verified 后发布快照；discard policy 在 CodeGen 后释放构建图。 |
| Acquire / null | `AcquireASTSnapshot(asAST_API_VERSION_1)` 返回一个 retained lease 或 null。discard、没有成功 retained/restored generation、不支持的版本、或 generation 因不再完整描述模块而被退役时，null 都是正常结果。 |
| Lease | 非空返回值已为调用方 AddRef；必须 `Release()`。view string 和 opaque ID 只在持有该 exact lease 时有效；lease 可以晚于 module discard 存活。 |
| 当前 generation | 只有最近一次完整成功发布的快照 `IsCurrentGeneration()` 为 true。成功替换后旧 lease 可继续遍历但不再 current；失败替换保持上一代 current。 |
| View 协商 | view 先清零，`structSize` 填调用方真实可写容量，`apiVersion` 填 0（V1 convenience）或 `asAST_API_VERSION_1`。不支持的非零版本或小于必需前缀的容量会在不覆盖调用方 bytes 的前提下失败；V1 扩展只能 append。 |
| Opaque ID | ID 属于特定 snapshot，不是全局稳定 ID；把其他 snapshot 的 ID 传入会 fail-closed。持久数据应保存完整 stable key/source identity，而不是数字 ID、pointer 或 `asASTTypeRef`。 |
| `CompileFunction` | CANONICAL 使用只覆盖一个 function closure 的临时 sealed AST。detached 成功不改变模块快照；`asCOMP_ADD_TO_MODULE` 成功改变模块声明集合，因此退役旧快照且不发布不完整替代；失败保留旧 executable/snapshot。之后只有完整 `Build()` 可以重新发布。 |
| Cache / `SaveByteCode` | `SaveByteCode()` 是 VM Bytecode 边界，不是 AST archive。Cache V2 AST sidecar 可选、pointer-free，并在 content/profile 校验通过且 retention policy 要求时才发布。成功 load bytecode 不代表存在 AST。 |

`GetCompilerPipeline()` / `SetCompilerPipeline()` 是 maintained-fork Engine API，
不是第二套 AST ABI。unknown/dual 值会被拒绝并保持原选择不变。完整 OpenSpec
cutover gate 通过前，产品默认保持 LEGACY；切换以后仍保留显式 LEGACY rollback。

## 嵌入方迁移清单

1. 使用当前插件 `angelscript.h` 重新编译嵌入程序；不要把 V1 接口与 vanilla
   2.33 header 或单独流出的 incomplete/pre-release AST header 混用。
2. compiler pipeline 和 AST retention 是两个独立选择。按需显式选择 CANONICAL，
   并在 `Build()` 前设置 retention。
3. 先处理 `Build()` 失败，再 Acquire。null snapshot 是受支持状态，不是读取私有
   ASTContext 或 replay dump 的许可。
4. 每次 `Get*View` 都填真实 `structSize` 和 V1 version，只读取容量覆盖的字段；
   使用返回的 string、child ID、source ID 时一直持有 lease。
5. 工具持久数据只保存 stable declaration/type/source identity。不要跨 lease、
   Engine、Hot Reload、Cache 或 process 保存 snapshot-local ID、Runtime TypeId、
   node address 或 view string pointer。
6. Hot Reload/rebuild 后需要当前数据时重新 Acquire。旧 lease 是安全的历史代；
   用 `IsCurrentGeneration()` 判断，不比较 pointer。
7. `CompileFunction(asCOMP_ADD_TO_MODULE)` 成功后，直到下一次完整 retained
   `Build()`，Acquire 应返回 null；detached compilation 不会退役模块快照。
8. AST tooling 与 `SaveByteCode()`、Cache executable records、StaticJIT Provider
   ABI 和 Runtime binding table 分离，只交换各自文档定义的 stable pointer-free
   identity。
9. 每个 Acquire 到的 lease 恰好 Release 一次，不要缓存 module implementation
   raw pointer 来代替 lease。

AST V1 在 product 1.0.0 内开发。如果外部 binary 使用过 vtable 位置不同的旧
incomplete V1 header，应使用当前 header 重新编译；本文不对未发布或单独分发的
broken layout 声称 binary compatibility。

## 保留的原生编译器边界

`asCScriptNode`、原生 Parser tree、`asCBuilder` 和 `asCCompiler` 暂时保留用于
语法覆盖、恢复、显式 LEGACY、比较和回滚；物理删除属于之后的独立 OpenSpec。
HIR 不保留。CANONICAL Sema/backend 直接消费 typed action 和 sealed AST。

## Dump 与 diagnostics

State dump 和开发者 AST diagnostics 是只读观察器，不是 Cache、Provider、
Bytecode 或 AOT 输入，也不拥有 AST、Sema、CodeGen、Runtime 或 Editor 对象。
