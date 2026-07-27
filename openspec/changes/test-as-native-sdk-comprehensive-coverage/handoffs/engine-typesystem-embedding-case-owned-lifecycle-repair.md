# Engine、TypeSystem 与 Embedding 案例独占生命周期修复

## 范围

本次按 `fixture-and-large-file-quality-review.csv` 中
`ChangeRequiredClassOwnedMutableOrUnjustified` 的分类，处理以下 9 个文件：

- `Embedding/AngelscriptNativeJitCompilerTests.cpp`：2 个测试方法。
- `Engine/AngelscriptNativeEngineMessageCallbackTests.cpp`：3 个测试方法。
- `Engine/AngelscriptNativeEnginePropertyIsolationTests.cpp`：1 个测试方法。
- `Engine/AngelscriptNativeEnginePropertyProfileTests.cpp`：1 个测试方法。
- `TypeSystem/AngelscriptNativeConfigGroupTests.cpp`：3 个测试方法。
- `TypeSystem/AngelscriptNativeDataTypeQualifierCartesianTests.cpp`：1 个测试方法。
- `TypeSystem/AngelscriptNativeDefaultTraitTests.cpp`：1 个测试方法。
- `TypeSystem/AngelscriptNativeTypeInfoShadowSystemTypeTests.cpp`：1 个测试方法。
- `TypeSystem/AngelscriptNativeVariableScopeTests.cpp`：9 个测试方法。

合计 9 个文件、22 个测试方法。

## 实施结果

- 删除了上述文件中的类级可变 `FNativeTestEngine`、裸引擎指针以及
  `BEFORE_ALL`、`BEFORE_EACH`、`AFTER_ALL` 生命周期钩子。
- 每个测试方法现在独占其原生 SDK 引擎。每次 `Create(*TestRunner)` 后立即
  注册多行 `ON_SCOPE_EXIT`，由当前案例负责 `Destroy()`。
- 属性隔离测试保留三个彼此独立的引擎，但三个引擎都改为方法局部对象，
  并按创建顺序分别注册清理，因此退出时按相反顺序销毁。
- 属性配置测试保留“fork 配置引擎”和“bare SDK 引擎”两类行为对照。
  两个 `FNativeTestEngine` 和两个裸 SDK 引擎均改为方法局部所有权；
  每次创建后立即注册相应的 `Destroy()` 或 `DestroyNativeEngine()`。
- 三处直接创建的 `asIScriptContext` 均在创建后立即注册空值安全的
  `Release()`，并通过局部作用域保证 Context 先于 Module 和 Engine 清理。
- JIT 测试中的编译器实例保持案例局部。清除 JIT 编译器的清理动作在
  编译器实例创建后注册，因此退出时会先解除引擎引用，再析构编译器实例，
  最后销毁引擎。
- 消息回调替换测试保留原始回调三元组，并在替代接收器创建后注册恢复动作；
  退出时会先恢复原始回调，再析构替代接收器，最后销毁引擎。
- 未修改产品标识、案例标识、断言、生成的 AngelScript 源码、模块名或测试语义，
  也未拆分大文件。

## 静态核对

文件级统计结果：

- `TEST_METHOD`：22。
- `FNativeTestEngine::Create/Destroy`：25/25。
- bare SDK engine 创建/销毁：2/2。
- `CreateContext/Release`：3/3。
- 类级可变 `inline static`：0；仅保留不可变的 `inline static constexpr`
  用例描述数据。
- `BEFORE_*` / `AFTER_*`：0。
- 所有目标 Engine、bare Engine 和 Context 创建语句的下一条有效语句均为
  `ON_SCOPE_EXIT`。
- 目标文件的 `git diff --check` 通过。

## 验证边界

按本轮任务约束，没有执行构建或自动化测试，也没有运行会重写目录、审计表或
目录清单的全局脚本。后续应在同一阶段其余代码完成后，再统一执行构建和
`Angelscript.TestModule.AngelScriptSDK` 前缀测试，并把实际结果记录到对应验证记录。
