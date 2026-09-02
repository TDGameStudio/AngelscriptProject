# Canonical CodeGen 全局默认值发布修正（2026-08-23）

## 问题

`asCBytecodeCodeGen::Generate()` 在收集顶层 Canonical `VarDecl` 时曾有一个
与函数数量耦合的跳过条件：当模块没有函数、且全局变量没有显式初始化表达式
时，CodeGen 会直接跳过该声明。

这会使一个已 seal 的、只包含 `int G;` 的 Canonical AST 返回成功码，却没有：

- 在模块中安装 `G`；
- 分配/登记全局变量存储；
- 发布 Canonical CodeGen publisher；
- 产生任何可见编译产物。

这不是一种可接受的“空模块成功”，而是 declaration 被静默丢弃。初始专项测试
在旧实现上确认了该行为：`Generate()` 返回 `0`，因此违反了测试对“不能静默
no-op”的断言。

## 采用的语义

移除了该跳过条件。无初始化全局变量现在和有初始化的顶层 `VarDecl` 一样进入
`AllocateGlobalProperty()` 的既有 AngelScript 路径。该路径负责把属性挂到模块与
引擎表，并分配语言默认初始化的存储。

当前可执行证据覆盖 `int G;`：

```text
sealed Canonical AST:  TranslationUnit -> VarDecl int G
                                    |
                                    v
Canonical CodeGen -> AllocateGlobalProperty("G", int)
                                    |
                                    v
Module global table: G, addressable storage, initial value 0
```

新增的事务测试验证：成功返回、全局数量为一、按 `G` 名称可定位、地址有效、值为
零，并且 publisher 为 `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`。这把“返回成功”
提升为真实的模块可观察状态验证。

## 明确边界

- 本修正只处理**无初始化的顶层全局声明**被错误跳过的问题。
- 它不扩展任意运行时初始化表达式；当前 Canonical CodeGen 对显式全局初始值仍
  只接受已由 Sema 计算完成的整数常量路径。
- 它不改变默认生产 Build：常规源编译仍选择 LEGACY compiler；Canonical CodeGen
  仍是受控/测试路径，`IsCanonicalBytecodeCodeGenReady()` 在孤立 `Generate()` 后
  仍为 false。
- 缓存 DTO、Cache V2 生命周期、默认切换与完整的全局初始化函数生成仍属于后续
  OpenSpec 工作，不能由本项推断为完成。

## 实现位置

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`
  - 删除只在“无函数 + 无显式初始化”时跳过顶层 `VarDecl` 的分支。
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`
  - `CodeGenPublishesUninitializedGlobalWithDefaultValue` 锁定发布、查找和默认值。

## 验证记录

1. 旧行为的红色证据（返回成功却违反 no-op 防线）：
   `Saved/Tests/cta-uninitialized-global-red/20260823_113841_045_3f2edb48/RunMetadata.json`
2. 编译 Runtime/Test 模块：
   `Saved/Build/cta-uninitialized-global-publication-build/20260823_114057_093_4e804d8b/RunMetadata.json`
3. 新专项发布语义：`1/1 PASS`：
   `Saved/Tests/cta-uninitialized-global-publication/20260823_114113_093_b0903843/RunMetadata.json`
4. CodeGen 失败原子性/事务回归：`12/12 PASS`：
   `Saved/Tests/cta-uninitialized-global-transaction/20260823_114150_225_bcb507eb/RunMetadata.json`
5. 生产 Canonical CodeGen 回归：`58/58 PASS`：
   `Saved/Tests/cta-uninitialized-global-production-codegen-rerun/20260823_114312_749_3adee51a/RunMetadata.json`

`cta-uninitialized-global-production-codegen` 的一次失败仅因使用了不存在的
Automation 前缀 `...Frontend.CanonicalAST.CodeGen.Production`，测试数为零；它不是
实现或回归失败。有效生产组前缀为
`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`，其
有效重跑记录如上。
