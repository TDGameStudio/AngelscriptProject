# Angelscript 插件测试目录

> 自动化测试基线：**275/275 PASS**（0 失败，0 禁用）
>
> 测试模块路径：`Plugins/Angelscript/Source/AngelscriptTest/`
>
> 启动 bind / watcher / 性能分层矩阵：`Documents/Guides/AngelscriptValidationMatrix.md`
>
> 测试分层、命名规则与典型场景：`Documents/Guides/TestConventions.md`
>
> 说明：这里的 `275/275 PASS` 表示**已编目基线**，不是当前源码实时扫描到的全部测试数量。实时扫描规模与新增覆盖请以 `Documents/Guides/TechnicalDebtInventory.md` 的 live inventory / verification snapshot 为准。
>
> 历史 closeout：`P6.3` 曾在独立 worktree 上收口到 4 个已知失败；该结果已被 `TechnicalDebtInventory.md` 第 17 节的最新回归快照覆盖。当前 live full-suite 口径与失败 owner 以 `Documents/Guides/TechnicalDebtInventory.md`、`Documents/Plans/Plan_KnownTestFailureFixes.md`、`Documents/Plans/Plan_TechnicalDebtRefresh.md` 为准。
>
> 当前测试债分流：zero/weak coverage 优先进入 `Documents/Plans/Plan_TestCoverageExpansion.md`；StaticJIT 专项优先进入 `Documents/Plans/Plan_StaticJITUnitTests.md`；测试层级/目录/命名规范化优先进入 `Documents/Plans/Plan_TestSystemNormalization.md` 与 `Documents/Plans/Plan_TestModuleStandardization.md`；negative tests 继续作为能力边界证据保留在对应主题中，不与已知失败混写。

---

## 目录

- [1. Shared — 测试基础设施](#1-shared--测试基础设施)
- [Native — 原生 AngelScript / ASSDK](#native--原生-angelscript--assdk)
- [2. Core — 引擎核心](#2-core--引擎核心)
- [3. Angelscript — 脚本引擎行为](#3-angelscript--脚本引擎行为)
  - [3.1 Core — 创建/编译/执行](#31-core--创建编译执行)
  - [3.2 Execute — 执行与调用约定](#32-execute--执行与调用约定)
  - [3.3 Types — 类型系统](#33-types--类型系统)
  - [3.4 ControlFlow — 控制流](#34-controlflow--控制流)
  - [3.5 Functions — 函数特性](#35-functions--函数特性)
  - [3.6 Objects — 对象模型](#36-objects--对象模型)
  - [3.7 Operators — 运算符](#37-operators--运算符)
  - [3.8 Handles — 句柄与引用](#38-handles--句柄与引用)
  - [3.9 Inheritance — 继承](#39-inheritance--继承)
  - [3.10 Misc — 杂项](#310-misc--杂项)
  - [3.11 NativeScriptHotReload — 原生脚本热重载](#311-nativescripthotreload--原生脚本热重载)
  - [3.12 Upgrade — 版本升级兼容](#312-upgrade--版本升级兼容)
- [4. Bindings — UE API 绑定](#4-bindings--ue-api-绑定)
- [5. HotReload — 热重载](#5-hotreload--热重载)
- [6. AngelScriptSDK — 内部机制](#6-AngelScriptSDK--内部机制)
- [7. Compiler — 编译管线](#7-compiler--编译管线)
- [8. Preprocessor — 预处理器](#8-preprocessor--预处理器)
- [9. ClassGenerator — 类生成器](#9-classgenerator--类生成器)
- [10. FileSystem — 文件系统](#10-filesystem--文件系统)
- [11. Editor — 编辑器](#11-editor--编辑器)
- [11.5 Debugger — 调试器](#115-debugger--调试器)
- [12. Themed Integration Tests — 主题化集成回归](#12-themed-integration-tests--主题化集成回归)
  - [12.1 Actor 生命周期](#121-actor-生命周期)
  - [12.2 Actor 交互](#122-actor-交互)
  - [12.3 Actor 属性](#123-actor-属性)
  - [12.4 ScriptClass 创建](#124-scriptclass-创建)
  - [12.5 ScriptActor 重载执行](#125-scriptactor-重载执行)
  - [12.6 BlueprintSubclass 蓝图子类化](#126-blueprintsubclass-蓝图子类化)
  - [12.7 BlueprintChild 运行时](#127-blueprintchild-运行时)
  - [12.8 Component 组件](#128-component-组件)
  - [12.9 DefaultComponent 默认组件](#129-defaultcomponent-默认组件)
  - [12.10 Inheritance 继承场景](#1210-inheritance-继承场景)
  - [12.11 Interface 接口](#1211-interface-接口)
  - [12.12 Delegate 委托](#1212-delegate-委托)
  - [12.13 GC 垃圾回收](#1213-gc-垃圾回收)
  - [12.14 Subsystem 子系统](#1214-subsystem-子系统)
  - [12.15 HotReload 热重载场景](#1215-hotreload-热重载场景)
  - [12.16 Functional Round1 Gap-Fill — 真空区与深度补漏](#1216-functional-round1-gap-fill--真空区与深度补漏)
- [13. Learning — 教学型可观测测试](#13-learning--教学型可观测测试)
  - [13.1 Native 层学习测试](#131-native-层学习测试)
  - [13.2 Runtime 层学习测试](#132-runtime-层学习测试)
- [14. Examples — 示例脚本编译](#14-examples--示例脚本编译)
- [15. Template — 模板场景](#15-template--模板场景)
- [15.6 Performance — 运行期微基准](#156-performance--运行期微基准)
- [16. Dump — 状态导出](#16-dump--状态导出)

---

## 1. Shared — 测试基础设施

> 源文件：`Shared/AngelscriptTestEngineHelperTests.cpp`、`Shared/AngelscriptTestEnginePoolTests.cpp`、`Shared/AngelscriptNativeScriptTestObjectTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Shared.EngineHelper.CompileModuleFromMemory | 内存字符串模块能成功编译 |
| Shared.EngineHelper.ExecuteIntFunction | `ExecuteIntFunction` 能执行入口并返回正确整型结果（42） |
| Shared.EngineHelper.GeneratedSymbolLookup | 带注解模块编译后，`FindGeneratedClass` / `FindGeneratedFunction` 能定位生成的类与 UFUNCTION |
| Shared.EngineHelper.FailedAnnotatedModuleDoesNotPolluteLaterCompiles | 无效注解模块编译失败后，后续有效模块仍能编译并生成符号 |
| Shared.EngineHelper.SharedTestEngineNeverSilentlyAttachesToProductionEngine | `GetOrCreateSharedCloneEngine` / `AcquireCleanSharedCloneEngine` 始终指向同一个共享 clone 引擎，不会静默附着到生产引擎 |
| Shared.EngineHelper.ProductionHelperRejectsMissingProductionEngine | 无生产子系统/全局引擎时 `TryGetRunningProductionEngine` 为 null |
| Shared.EngineHelper.CompileUsesScopedGlobalEngine | 在 `FScopedGlobalEngineOverride` 下编译后，全局引擎指针恢复为共享 clone 引擎 |
| Shared.EngineHelper.ResetSharedEngineReleasesGeneratedComponentClasses | `ResetSharedCloneEngine` 后测试生成的组件 `UASClass` 需从 weak/path/对象迭代中消失 |
| Shared.EngineHelper.ResetSharedEngineReleasesGeneratedStructs | `ResetSharedCloneEngine` 后测试生成的 `UASStruct` 需从 weak/path/对象迭代中消失 |
| Shared.EngineHelper.ResetSharedEngineReleasesGeneratedEnumsAndDelegates | `ResetSharedCloneEngine` 后测试生成的 `UEnum`、单播 delegate 和 multicast event `UDelegateFunction` 需从 weak/path 中消失 |
| Shared.EngineHelper.NestedGlobalEngineScopeRestoresPreviousEngine | 嵌套 scope 先装 B 再退出后恢复 A |
| Shared.EngineHelper.WorldContextScopeRestoresPreviousContext | `FScopedTestWorldContextScope` 正确设置/恢复 `CurrentWorldContext` |
| Shared.EngineHelper.ExecutingOneTestEngineDoesNotLeakContextIntoNextTest | 两个 clone 引擎分别编译执行不同模块，结果互不串线 |
| Shared.EngineHelper.SubsystemAttachedProductionEngineDoesNotHijackIsolatedTestEngine | 隔离引擎编译的模块不出现在共享测试引擎中 |
| Shared.TestEnginePool.PrewarmCachesBindDatabase | module-clean source engine 预热后复用 bind database，不重复 replay bind |
| Shared.TestEnginePool.ModuleCleanDiscardsOnlyDelta | module-clean scope 只丢弃当前 scope 新增模块，不清 baseline |
| Shared.TestEnginePool.GeneratedClassCleanupIsBounded | module-clean 清理测试生成的 `UASClass`，不留下 rooted detached class |
| Shared.TestEnginePool.GeneratedStructCleanupIsBounded | module-clean 清理测试生成的 `UASStruct`，并触发 batched GC 释放 |
| Shared.TestEnginePool.GeneratedEnumDelegateCleanupIsBounded | module-clean 只按本次丢弃模块清理测试生成的 `UEnum`、单播 delegate 和 multicast event `UDelegateFunction` |
| Shared.TestEnginePool.GeneratedClassActionCacheIsCleared | module-clean 清掉 generated class 对应 Blueprint action cache，避免 cache 强引用阻止 GC |
| Shared.NativeScriptTestObject.Instantiate | 原生测试用 `UAngelscriptNativeScriptTestObject` 可实例化 |

---

## Native — 原生 AngelScript / ASSDK

> 源文件：`AngelScriptSDK/AngelscriptNativeSmokeTest.cpp`、`AngelScriptSDK/AngelscriptNativeCompileTests.cpp`、`AngelScriptSDK/AngelscriptNativeExecutionTests.cpp`、`AngelScriptSDK/AngelscriptNativeExecutionAdvancedTests.cpp`、`AngelScriptSDK/AngelscriptNativeRegistrationTests.cpp`、`AngelScriptSDK/AngelscriptASSDKSmokeTest.cpp`、`AngelScriptSDK/AngelscriptASSDKEngineTests.cpp`、`AngelScriptSDK/AngelscriptASSDKExecuteTests.cpp`、`AngelScriptSDK/AngelscriptASSDKGlobalVarTests.cpp` 以及其余 `AngelScriptSDK/AngelscriptASSDK*Tests.cpp`

| 测试前缀 | 代表源文件 | 验证内容 |
|--------|----------|----------|
| `Angelscript.TestModule.AngelScriptSDK.Smoke` | `AngelScriptSDK/AngelscriptNativeSmokeTest.cpp` | 最小原生 AngelScript 引擎创建、编译与执行烟雾 |
| `Angelscript.TestModule.AngelScriptSDK.Compile.*` | `AngelScriptSDK/AngelscriptNativeCompileTests.cpp` | 纯公共 API 路径下的编译、错误消息与模块构建 |
| `Angelscript.TestModule.AngelScriptSDK.Execute.*` | `AngelScriptSDK/AngelscriptNativeExecutionTests.cpp`、`AngelScriptSDK/AngelscriptNativeExecutionAdvancedTests.cpp` | 原生上下文 Prepare / Execute、参数传递、返回值、执行状态 |
| `Angelscript.TestModule.AngelScriptSDK.Register.*` | `AngelScriptSDK/AngelscriptNativeRegistrationTests.cpp` | 原生全局函数/属性/值类型注册 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.Smoke` | `AngelScriptSDK/AngelscriptASSDKSmokeTest.cpp` | ASSDK 适配层最小引擎创建、消息回调与脚本执行 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.Engine.*` | `AngelScriptSDK/AngelscriptASSDKEngineTests.cpp` | ASSDK 引擎生命周期、回调复用与基础引擎语义 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.Execute.*` | `AngelScriptSDK/AngelscriptASSDKExecuteTests.cpp` | ASSDK 回调注册、参数调用约定、cleanup 与 portability 分支 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.GlobalVar.*` / `Stack.*` | `AngelScriptSDK/AngelscriptASSDKGlobalVarTests.cpp` | 全局变量枚举/重置/删除、栈深限制与异常位置信息 |
| `Angelscript.TestModule.AngelScriptSDK.ASSDK.*` | 其余 `AngelScriptSDK/AngelscriptASSDK*Tests.cpp` | 类型、对象、OOP、模块、函数、调用约定、运行时与编译器邻近回归 |

> 放置规则：`Native/` 只验证 `AngelscriptInclude.h` / `angelscript.h` 暴露的公共 API，不把 `FAngelscriptEngine` 或运行时私有实现带进这一层。

---

## 2. Core — 引擎核心

> 源文件：`Core/AngelscriptEngineCoreTests.cpp`、`Core/AngelscriptBindConfigTests.cpp`、`Core/AngelscriptEngineParityTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Engine.CreateDestroy | 引擎创建与销毁生命周期正常 |
| Engine.CompileSnippet | 代码片段编译 |
| Engine.ExecuteSnippet | 代码片段执行 |
| Engine.BindConfig.GlobalDisabledBindNames | 全局设置中禁用绑定名后，对应绑定不执行 |
| Engine.BindConfig.EngineDisabledBindNames | 引擎级禁用绑定集合生效 |
| Engine.BindConfig.UnnamedBindBackwardCompatibility | 未命名绑定的向后兼容行为 |
| Parity.SkinnedMeshCompile | 生产引擎中 `USkinnedMeshComponent` 类型及关键方法存在 |
| Parity.DelegateWithPayloadCompile | `FAngelscriptDelegateWithPayload` 及 `IsBound`/`ExecuteIfBound` |
| Parity.CollisionProfileCompile | `CollisionProfile` 常量片段可编译并与 `FName` 比较 |
| Parity.CollisionQueryParamsCompile | 碰撞查询参数绑定编译 |
| Parity.WorldCollisionCompile | 世界碰撞相关 API 编译 |
| Parity.FIntPointCompile | `FIntPoint` 绑定编译 |
| Parity.FVector2fCompile | `FVector2f` 绑定编译 |
| Parity.SoftReferenceCppForm | 软引用 C++ 形式在脚本侧可用性 |
| Parity.SoftReferenceCompile | 软引用脚本编译 |
| Parity.UserWidgetPaintCompile | `UserWidget` 绘制相关编译 |
| Parity.LevelStreamingCompile | 关卡流送相关编译 |
| Parity.RuntimeCurveLinearColorCompile | `RuntimeCurveLinearColor` 编译 |
| Parity.HitResultCompile | `FHitResult` 编译 |
| Parity.DeprecationsMetadata | 弃用元数据暴露正确 |
| Engine.LastFullDestroyClearsTypeState | 最后一个 full owner 销毁后类型元数据清空 |
| Engine.FullDestroyAllowsCleanRecreate | full owner 销毁后可干净重建并再次编译执行 |
| Core.Performance.Startup.Full | fresh full 启动基线与 startup 指标产物写出 |
| Core.Performance.Startup.Clone | clone 启动基线与 0 bind replay 指标 |
| Core.Performance.Startup.CreateForTestingFallbackFull | 无 source engine 时 CreateForTesting fallback 全量启动基线 |
| Core.Performance.Startup.CreateForTestingClone | 有 source engine 时 CreateForTesting clone 启动基线 |
| Core.Performance.ShareCleanCycle | `ASTEST_CREATE_ENGINE_SHARE_CLEAN` 串行 acquire/compile/reset 周期耗时基线，并观测生成 `UASClass` reset 后 GC/脱离/引用来源 |
| Core.Performance.ArtifactGeneration | metrics.json 产物结构与落盘回归 |
| Core.Performance.InstrumentationScopeCatalog | runtime performance instrumentation scope 目录回归 |

---

## 3. Angelscript — 脚本引擎行为

### 3.1 Core — 创建/编译/执行

> 源文件：`Angelscript/AngelscriptCoreExecutionTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Core.CreateCompileExecute | 内存模块编译并执行 `Run()`：`DoubleValue(21)` 返回 42 |
| Core.GlobalState | 全局 `const` 与 `Step` 调用：`Run()` 返回 7（3+4） |
| Core.CreateEngine | 两次 `CreateForTesting` 得到非空独立 `asIScriptEngine`；版本号为 23300 |
| Core.CompilerBasic | 简单/多函数/全局变量模块编译成功；语法错误模块编译失败 |
| Core.Parser | 算术/逻辑/if、嵌套块可编译；括号不匹配脚本编译失败 |
| Core.Optimize | 常量折叠 `1+2+3` 执行得 6；含死代码的 `return` 路径仍返回 1 |

### 3.2 Execute — 执行与调用约定

> 源文件：`Angelscript/AngelscriptExecutionTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Execute.Basic | `void TestVoid()` 与 `int TestValue()` 的 Prepare/Execute 成功，返回值 42 |
| Execute.OneArg | `int Test(int)` 传入 21，返回 42 |
| Execute.TwoArgs | `int Test(int,int)` 20+22=42 |
| Execute.FourArgs | 四参数相加为 42 |
| Execute.MixedArgs | `int`+`float`/`double`+`int` 混合参数，返回值约 42.5 |
| Execute.Context | 两次 `CreateContext` 指针不同；Prepare/Execute 前后上下文状态为 Prepared/Finished |
| Execute.Nested | `Outer(20)` 调用 `Inner`，应得 41 |
| Execute.Discard | `DiscardModule` 前后模块描述存在性；重复 discard 应失败 |
| Execute.Script | `Calculate(1,10)` 含 for 循环累加，应得 55 |

### 3.3 Types — 类型系统

> 源文件：`Angelscript/AngelscriptTypeTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Types.PrimitiveAndEnum | `bool`、`float` 与枚举 `EState::Running` 混合运算，应得 9 |
| Types.Int64AndTypedef | `int64` 左移 40 位再加 7，与宽整数常量一致 |
| Types.Bool | `true && !false` 应得 1 |
| Types.Float | `3.14*2` 应约 6.28（按引擎 float/double 选择脚本） |
| Types.FloatDebuggerFormatting | `FAngelscriptTypeUsage` 对小浮点取调试字符串，应含科学计数法 |
| Types.Int8 | `int8` 相加再转 `int`，应得 150 |
| Types.Bits | 按位或/与/异或掩码判断，应得 1 |
| Types.Enum | `Color::Green` 的 `int` 值应为 1 |
| Types.Auto | `auto Value = 42` 应返回 42 |
| Types.Conversion | `float`/`double` 显式转 `int` 向零截断，3.7→3 |
| Types.ImplicitCast | `int` 隐式提升为 `float`/`double`，返回值应约 42.0 |

### 3.4 ControlFlow — 控制流

> 源文件：`Angelscript/AngelscriptControlFlowTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| ControlFlow.ForLoop | `Index` 从 0 到 <5 累加，应得 10 |
| ControlFlow.SwitchAndConditional | `switch` 与三元运算，`Run()` 应得 7 |
| ControlFlow.Condition | 嵌套三元 `Evaluate` 组合，应得 210 |
| ControlFlow.NeverVisited | `if` 早退后存在"可能永不执行"的块，仍能编译 |
| ControlFlow.NotInitialized | 未初始化 `int` 直接返回：应捕获含 "may not be initialized" 的 Warning |

### 3.5 Functions — 函数特性

> 源文件：`Angelscript/AngelscriptFunctionTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Functions.DefaultArguments | `Add(7)` 使用默认参数 `B=5`，应得 12 |
| Functions.NamedArguments | `Mix(C:3,A:1,B:2)` 应得 321 |
| Functions.OverloadResolution | `int`/`float` 版 `Convert` 重载，应得 5+6=11 |
| Functions.Pointer | `funcdef` + `@Callback` 函数指针语法应编译失败 |
| Functions.Constructor | 双构造函数脚本类能成功 `BuildModule` |
| Functions.Destructor | 含析构函数的类：`Run()` 执行后返回 1 |
| Functions.Template | 泛型类 `TemplateCarrier<T>` 应编译失败 |
| Functions.Factory | `FactoryCarrier @CreateCarrier` 返回句柄应编译失败 |

### 3.6 Objects — 对象模型

> 源文件：`Angelscript/AngelscriptObjectModelTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Objects.ValueTypeConstruction | `FIntPoint(3,4)` 的 `X+Y` 应得 7 |
| Objects.ValueTypeCopyAndArithmetic | `FIntPoint` 拷贝与算术操作结果应为 57 |
| Objects.Basic | 脚本类方法 `Set`/`Get` 能编译（仅编译/符号覆盖） |
| Objects.Composition | 嵌套脚本对象成员赋值能编译 |
| Objects.Singleton | 占位：单例式全局类变量为已知不支持的分支约束，测试恒通过 |
| Objects.ZeroSize | 空脚本类实例化后 `Run()` 返回 1 |

### 3.7 Operators — 运算符

> 源文件：`Angelscript/AngelscriptOperatorTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Operators.Overload | 脚本类 `opAdd` 与 `A+B` 能编译 |
| Operators.GetSet | `get_value`/`set_value` 属性访问脚本 `Build()` 为 `asSUCCESS` |
| Operators.Const | `const` 成员方法脚本能编译 |
| Operators.Power | `2.0f ** 3.0f` 转 `int` 应为 8 |

### 3.8 Handles — 句柄与引用

> 源文件：`Angelscript/AngelscriptHandleTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Handles.Basic | 脚本类句柄声明与赋值应编译失败（当前不支持） |
| Handles.Implicit | 以值类型隐式传脚本对象给函数能编译 |
| Handles.Auto | 返回 `HandleAutoObject@` 的工厂式句柄应编译失败 |
| Handles.RefArgument | `int &out` 参数：`Modify(Value)` 后 `Test()` 应返回 42 |

### 3.9 Inheritance — 继承

> 源文件：`Angelscript/AngelscriptInheritanceTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Inheritance.Basic | `Base`/`Derived` 继承与成员调用脚本能编译且模块可解析 |
| Inheritance.Interface | 含 `interface`/`implements` 的脚本应编译失败（当前分支不支持原生 AS 接口语法） |
| Inheritance.VirtualMethod | 派生类重写 `GetValue` 能编译 |
| Inheritance.CastOp | 脚本类句柄 `CastOpClass@` 构造应编译失败 |
| Inheritance.Mixin | `mixin class` 语法应编译失败（解析不支持） |

### 3.10 Misc — 杂项

> 源文件：`Angelscript/AngelscriptMiscTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Misc.Namespace | 命名空间内函数与常量，`MyNamespace::GetValue()` 应得 42 |
| Misc.Any | 原始模块下 `any` 存取 `int`，`Module->Build()` 为 `asSUCCESS` |
| Misc.GlobalVar | 模块级 `const int GlobalValue`，`Test()` 应得 42 |
| Misc.MultiAssign | 链式赋值 `A=B=C=42`，三数之和应 126 |
| Misc.Assign | `+=`、`-=`、`*=`、`/=` 序列运算结果应为 8 |
| Misc.DuplicateFunction | 两个同名 `Test()` 函数，`Build()` 仍为 `asSUCCESS`（记录当前行为） |

### 3.11 NativeScriptHotReload — 原生脚本热重载

> 源文件：`Angelscript/AngelscriptNativeScriptHotReloadTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| NativeScriptHotReload.Phase2A | 对 `Test_Enums.as`/`Test_Inheritance.as`/`Test_Handles.as` 全量编译再软重载，重载结果为 Fully/Partially Handled |
| NativeScriptHotReload.Phase2B | 对 `Test_GameplayTags`/`Test_SystemUtils`/`Test_ActorLifecycle`/`Test_MathNamespace` 同样流程 |
| NativeScriptHotReload.Phase2C | 对 `Test_ExampleActorFixture.as` 全量编译再软重载，验证新增语料路径也走 handled reload |

### 3.12 Upgrade — 版本升级兼容

> 源文件：`Angelscript/AngelscriptUpgradeCompatibilityTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Upgrade.HeaderCompatibility | AngelScript 升级头文件兼容层 |
| Upgrade.EngineProperties | 引擎属性相关兼容 |
| Upgrade.MessageCallback | 消息回调兼容 |
| Upgrade.RegisterObjectTypeFlags | `RegisterObjectType` 标志兼容 |
| Upgrade.CStringHash | `asCString` 的 `GetTypeHash` 在替换弃用 CRC API 后仍保持大小写无关 |

---

## 4. Bindings — UE API 绑定

> 源文件：`Bindings/` 目录下 67 个测试文件

### 值类型与引擎核心

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ValueTypes | `int32`/`double`/`FString`/`FName`/`FVector`/`FRotator`/`FTransform`/`FText` 运算与比较 | AngelscriptEngineBindingsTests.cpp |
| Bindings.FNameArrayCompat | `FName[]` 与 `TArray<FName>` 别名/显式、`Add`、索引、`Contains` | AngelscriptEngineBindingsTests.cpp |
| Bindings.TArraySyntaxCompat | 独立覆盖 `T[]`/`int[]` 默认数组语法：`int[]` 全接口、值类型/结构体/`TSubclassOf<AActor>[]`、返回值、运行时负向异常、嵌套容器与 UObject/Actor 简写编译边界 | AngelscriptTArraySyntaxCompatBindingsTests.cpp |
| Bindings.ForeachCompat | `int[]`/`TArray` 的 `for (x : arr)` 与 `const FVector&` 范围 for | AngelscriptEngineBindingsTests.cpp |

### 全局变量与控制台

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.GlobalVariableCompat | `CollisionProfile::BlockAllDynamic`、`FComponentQueryParams::DefaultComponentQueryParams`、`FGameplayTag::EmptyTag`、`FGameplayTagContainer::EmptyContainer`、`FGameplayTagQuery::EmptyQuery` 等命名空间全局变量可在脚本侧读值 | AngelscriptGlobalBindingsTests.cpp |
| Bindings.ConsoleVariableCompat | `FConsoleVariable` 的 `int`/`float`/`bool`/`FString` 构造、`Get*`/`Set*` 与底层 `IConsoleManager` 值同步 | AngelscriptConsoleBindingsTests.cpp |
| Bindings.ConsoleVariableExistingCompat | `FConsoleVariable` 以已有 C++ CVar 名构造时复用现有值，并继续把写回同步到底层 `IConsoleManager` | AngelscriptConsoleBindingsTests.cpp |
| Bindings.ConsoleCommandCompat | 脚本侧全局 `FConsoleCommand` 可注册到 `IConsoleManager`、执行后将参数数量写回底层 CVar，并在模块丢弃后卸载 | AngelscriptConsoleBindingsTests.cpp |
| Bindings.ConsoleCommandReplacementCompat | 相同命令名的第二次脚本注册会替换前一个命令实现，执行结果以最新注册版本为准 | AngelscriptConsoleBindingsTests.cpp |
| Bindings.ConsoleCommandSignatureCompat | `FConsoleCommand` 绑定到错误签名的全局函数时应构造失败，且不会在 `IConsoleManager` 中留下残留命令 | AngelscriptConsoleBindingsTests.cpp |

### 容器

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.OptionalCompat | `TOptional<int>`：`IsSet`/`Get`/`Set`/`GetValue`/`Reset`；`TOptional<FName>` | AngelscriptContainerBindingsTests.cpp |
| Bindings.SetCompat | `TSet<int>`：去重 `Add`/`Contains`/拷贝/`Remove`/`Reset`；`TSet<FName>` | AngelscriptContainerBindingsTests.cpp |
| Bindings.MapCompat | `TMap<FName,int>`：`Add` 覆盖/`Find`/`FindOrAdd`/复制/`Remove`/`Reset` | AngelscriptContainerBindingsTests.cpp |
| Bindings.TArray | 单个 AS engine 测试入口覆盖 `TArray` 兼容性、显式 API、类型矩阵、对象/Actor 类型、返回值、运行时负向异常和嵌套容器编译拒绝 | AngelscriptTArrayBindingsTests.cpp |
| Bindings.ArrayForeach | `TArray` 的 `foreach (值, 索引)` 累加元素和与索引和 | AngelscriptContainerBindingsTests.cpp |
| Bindings.SetForeach | `TSet` 的 `foreach` 累加为 7 | AngelscriptContainerBindingsTests.cpp |
| Bindings.MapForeach | `TMap` 的 `foreach (值, 键)` 和为 7、键计数为 2 | AngelscriptContainerBindingsTests.cpp |

### 容器比较与调试

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.SetCompareCompat | 两个 `TSet` 元素相同顺序不同仍 `==`，增元素后不等 | AngelscriptContainerCompareBindingsTests.cpp |
| Bindings.MapCompareCompat | 两个 `TMap` 键值相同插入顺序不同时 `==` 为真 | AngelscriptContainerCompareBindingsTests.cpp |
| Bindings.OptionalTypeCompareCompat | `TOptional<int>` 的 `CanCompare()`、未设置/相同/不同值的 `IsValueEqual` | AngelscriptContainerCompareBindingsTests.cpp |
| Bindings.MapDebuggerCompat | `TMap` 的 `GetDebuggerValue` 摘要、`Num` 成员、键调试值 | AngelscriptContainerCompareBindingsTests.cpp |

### 迭代器

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.SetIteratorCompat | `TSetIterator`：`CanProceed`/`Proceed` 遍历求和为 7 | AngelscriptIteratorBindingsTests.cpp |
| Bindings.MapIteratorCompat | `TMapIterator`：`Proceed`/`GetKey`/`GetValue` 遍历求和与键识别 | AngelscriptIteratorBindingsTests.cpp |

### 类与类型查找

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ClassLookupCompat | `FindClass("AActor")`/`GetAllClasses` 能在全类列表中找到 `AActor` | AngelscriptClassBindingsTests.cpp |
| Bindings.TSubclassOfCompat | `TSubclassOf<AActor>`：空/有效/`Get`/`==`/`GetDefaultObject` | AngelscriptClassBindingsTests.cpp |
| Bindings.TSoftClassPtrCompat | `TSoftClassPtr<AActor>`：空/构造/隐式/`Get`/`ToString`/`Reset` | AngelscriptClassBindingsTests.cpp |
| Bindings.StaticClassCompat | `AActor::StaticClass` 与 `TSubclassOf`；注解 Actor 内 `StaticClass` | AngelscriptClassBindingsTests.cpp |
| Bindings.NativeStaticClassNamespace | `SetDefaultNamespace("AActor")` 下存在全局 `UClass StaticClass()` | AngelscriptClassBindingsTests.cpp |
| Bindings.NativeStaticTypeGlobal | 全局 `__StaticType_AActor`：`IsValid`/`Get`/`==`/`IsChildOf`/`GetDefaultObject` | AngelscriptClassBindingsTests.cpp |

### 对象指针与引用

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ObjectPtrCompat | `TObjectPtr<UTexture2D>`：空/构造/赋值/比较/`Get`/与裸指针转换 | AngelscriptObjectBindingsTests.cpp |
| Bindings.SoftObjectPtrCompat | `TSoftObjectPtr<UTexture2D>`：空/有效/`==`/`Get`/`ToSoftObjectPath`/路径构造/`Reset` | AngelscriptObjectBindingsTests.cpp |

### 兼容性（Cast/DateTime/Timespan）

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ObjectCastCompat | `Cast<UPackage>`、`n"..."` 与 `FName`；注解模块 `Cast` 到生成类 | AngelscriptCompatBindingsTests.cpp |
| Bindings.ObjectEditorOnlyCompat | `UPackage::IsEditorOnly()` 对暂存包为 false | AngelscriptCompatBindingsTests.cpp |
| Bindings.TimespanCompat | `FTimespan`：Zero/FromSeconds/Hours/构造/`opCmp`/运算/`ToString` | AngelscriptCompatBindingsTests.cpp |
| Bindings.DateTimeCompat | `FDateTime`：Unix 纪元/构造/比较/与 `FTimespan` 加减/闰年/`ToIso8601`/Today/Now/UtcNow | AngelscriptCompatBindingsTests.cpp |

### 数学与平台

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.MathExtendedCompat | `Math::` 扩展：`RandHelper`/`IsPowerOfTwo`/`VRand`/`ClampAngle`/`Clamp`/插值系列/三次插值，以及 `FVector2f::ToDirectionAndLength`、`Math::LinePlaneIntersection(FPlane)`、`int64 Abs/Sign/Min/Max/Square` 等低风险 parity 闭环 | AngelscriptMathAndPlatformBindingsTests.cpp |
| Bindings.PlatformProcessCompat | `FPlatformProcess`：用户目录/设置/临时/可执行路径/计算机名/用户名/`CanLaunchURL` | AngelscriptMathAndPlatformBindingsTests.cpp |
| Bindings.Logging | `Log`/`LogDisplay`/`Warning`/`Error` 可执行；`AddExpectedError` 捕获 Error 输出 | AngelscriptMathAndPlatformBindingsTests.cpp |

### 杂项工具

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.HashCompat | `Hash::CityHash32/64`、带种子哈希的确定性与区分 | AngelscriptUtilityBindingsTests.cpp |
| Bindings.UtilityCompat | `FCommandLine::Get` 非空/`Parse` 与 C++ 一致/`FApp::GetProjectName` 一致 | AngelscriptUtilityBindingsTests.cpp |
| Bindings.ParseCompat | `FParse::Value` 解析 int/float/FString，`FParse::Bool` 解析 bool | AngelscriptUtilityBindingsTests.cpp |
| Bindings.RandomStreamCompat | `FRandomStream`：种子/`RandRange` 可重复/`GetFraction`/双精度范围/拷贝/`GenerateNewSeed`/`ToString` | AngelscriptUtilityBindingsTests.cpp |
| Bindings.StringRemoveAtCompat | `FString::RemoveAt` 删除子串后内容正确 | AngelscriptUtilityBindingsTests.cpp |

### GUID 与路径

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.GuidCompat | `FGuid`：构造/`ToString`/`Parse`/`ParseExact`/`Invalidate`/`NewGuid`/`GetTypeHash` | AngelscriptCoreMiscBindingsTests.cpp |
| Bindings.PathsCompat | `FPaths`：`ProjectDir`/`CombinePaths`/`IsRelative`/`GetExtension`/`DirectoryExists`/`FileExists` | AngelscriptCoreMiscBindingsTests.cpp |
| Bindings.NumberFormattingOptionsCompat | `FNumberFormattingOptions` 链式 Set、`IsIdentical`、`GetTypeHash`；默认预设 | AngelscriptCoreMiscBindingsTests.cpp |

### GameplayTag

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.GameplayTagCompat | `RequestGameplayTag`/空 Tag/`RequestGameplayTag(NAME_None,false)` | AngelscriptGameplayTagBindingsTests.cpp |
| Bindings.GameplayTagContainerCompat | `FGameplayTagContainer`：空/增删/`HasTag`/`HasAny`/`HasAll`/`AppendTags`/`Reset` | AngelscriptGameplayTagBindingsTests.cpp |
| Bindings.GameplayTagQueryCompat | `FGameplayTagQuery`：`MakeQuery_MatchAny/All/No/Exact`、与 Container 匹配逻辑 | AngelscriptGameplayTagBindingsTests.cpp |

### 委托与文件

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ScriptDelegateCompat | `delegate`/`event`：`BindUFunction`/`AddUFunction`/`Unbind`/`Clear`/`IsBound` | AngelscriptFileAndDelegateBindingsTests.cpp |
| Bindings.SoftPathCompat | `FSoftObjectPath`/`FSoftClassPath` 有效性/资源名/包名/`IsSubobject`/相等 | AngelscriptFileAndDelegateBindingsTests.cpp |
| Bindings.SourceMetadataCompat | 磁盘 `.as` 编译后：`UClass`/`UFunction` 源路径/模块名/脚本声明/行号 | AngelscriptFileAndDelegateBindingsTests.cpp |
| Bindings.FileHelperCompat | `FFileHelper::SaveStringToFile` / `LoadFileToString` 读写一致 | AngelscriptFileAndDelegateBindingsTests.cpp |

### 原生引擎方法

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.NativeActorMethods | `GetActorLocation`/`GetActorRotation`/`GetClass`/`GetName`/`IsA` 等原生 Actor 桥接调用 | AngelscriptNativeEngineBindingsTests.cpp |
| Bindings.NativeComponentMethods | `USceneComponent`：`Activate`/`Deactivate`/相对变换/`GetComponent`/标签，以及 `SetComponentVelocity` / `GetComponentVelocity` / `FScopedMovementUpdate` | AngelscriptNativeEngineBindingsTests.cpp |
| Bindings.ComponentDestroyCompat | 注解组件上 `DestroyComponent()` 可编译执行，组件进入 `IsBeingDestroyed()` | AngelscriptNativeEngineBindingsTests.cpp |

### BlueprintCallable 反射回退缓存

> 缓存实现见 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp`（`FReflectiveParamCache` + `FBlueprintCallableReflectiveSignature::GetOrBuildCache` + `InvokeReflectiveUFunctionFromGenericCallCached`）。原始 `InvokeReflectiveUFunctionFromGenericCall` 公共 API 现在转发到缓存路径，因此现存的 UMG/AIModule/GameplayTags 反射回退测试也间接覆盖缓存。
>
> 通过 CVar `as.ReflectiveFallback.UseCache`（默认 1）可在运行时切换两条调度策略：1=`FFrame`+`UFunction::Invoke` 缓存路径；0=传统 `UObject::ProcessEvent` + 每调用 `TFieldIterator` 路径。在线切换支持 A/B 性能对比、灰度发布以及缓存路径出问题时立即回退。
>
> 8 个功能用例选用 GameplayTags BPLib（UHT 摘要 35/35 stub，100% 反射回退）作为驱动函数，避免 AngelscriptTest 模块内函数被 UHT 直接绑定旁路缓存。

| 测试名 | 验证内容 | 源文件 |
|--------|----------|--------|
| Bindings.ReflectiveFallbackCache.PODScalar | POD 标量参数与返回值通过 `FMemory::Memcpy` 快路径反射回退 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.NonPOD | `FName`/`FGameplayTag` 等非 POD 类型走 `CopySingleValue` 反射回退 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.OutParam | `UPARAM(ref) FGameplayTagContainer&` 经 FOutParmRec 链表正确写回脚本侧 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.Return | 非 POD USTRUCT 返回值（`FGameplayTagContainer`）经缓存回写到 AS 返回槽 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.MixinObject | `bInjectMixinObject==true` 静态 BPLib 函数：首参从 `Generic->GetObject()` 注入而非 AS 参数列表 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.CacheReuse | 同一 UFunction 在循环中调用 32 次，验证首次构建的缓存在后续调用中被正确复用 | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.FuncNetEligibility | 结构性兜底：BPLib UFUNCTION 在缓存改造后仍保持反射回退资格（FUNC_Net 端到端验证待网络环境） | AngelscriptReflectiveFallbackCacheTests.cpp |
| Bindings.ReflectiveFallbackCache.CVarParityCachedVsProcessEvent | 在同一测试中切换 `as.ReflectiveFallback.UseCache` 0/1，跑同脚本两遍（POD 标量 + FName 返回 + non-const out 写回 + 8 次循环），断言缓存路径与 ProcessEvent 路径产出复合 checksum 完全一致；测试结束 `ON_SCOPE_EXIT` 还原 CVar | AngelscriptReflectiveFallbackCacheTests.cpp |

---

## 5. HotReload — 热重载

### 函数与模块

> 源文件：`HotReload/AngelscriptHotReloadFunctionTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| HotReload.ModuleRecordTracking | 模块记录/追踪热重载相关状态 |
| HotReload.DiscardModule | 丢弃模块后引擎状态符合预期 |
| HotReload.DiscardAndRecompile | 丢弃后能重新编译同一/新模块 |
| HotReload.ModuleWatcherQueuesFileChanges | 文件监视器将变更入队供重载 |
| HotReload.AddModifyLookupFlow | 新增并修改模块后，lookup/函数执行结果应更新到最新脚本体 |
| HotReload.FailureKeepsOldCodeAndDiagnostics | 热重载失败时保留旧代码可执行，并记录诊断信息 |
| HotReload.Performance.SoftReloadLatency | body-only soft reload 延迟基线 |
| HotReload.Performance.FullReloadLatency | 结构变化 full reload 延迟基线 |
| HotReload.Performance.RenameWindowLatency | rename-window 建模下 full reload 延迟基线 |
| HotReload.Performance.BurstChurnLatency | repeated soft/full/soft burst churn 延迟基线 |


### 属性保留

> 源文件：`HotReload/AngelscriptHotReloadPropertyTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| HotReload.SoftReload.Basic | 软重载基本路径可用 |
| HotReload.SoftReload.PreservesOtherModules | 软重载时其他模块状态保留 |
| HotReload.FullReload.Basic | 全量重载基本路径 |
| HotReload.FullReload.EnumBasic | 枚举变更触发的全量重载场景 |

### 重载分析

> 源文件：`HotReload/AngelscriptHotReloadAnalysisTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| HotReload.AnalyzeReload.NoChange | 源码未变时分析为 `SoftReload`，不要求全量 |
| HotReload.AnalyzeReload.PropertyCountChange | 属性数量变化时重载需求分析正确 |
| HotReload.AnalyzeReload.SuperClassChange | 父类变化被分析识别 |
| HotReload.AnalyzeReload.SoftReloadRequirement | 需软重载的情形被正确标记 |
| HotReload.AnalyzeReload.ClassAdded | 新增类对分析结果的影响 |
| HotReload.AnalyzeReload.ClassRemoved | 删除类对分析结果的影响 |
| HotReload.AnalyzeReload.FunctionSignatureChanged | 函数签名变化对重载分析的影响 |

---

## 6. AngelScriptSDK — 内部机制

### Builder 构建器

> 源文件：`AngelScriptSDK/AngelscriptBuilderTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Builder.SingleModulePipeline | 单模块构建管线端到端 |
| AngelScriptSDK.Builder.CompileErrors | 编译错误收集与报告 |
| AngelScriptSDK.Builder.RebuildModule | 模块重建行为 |
| AngelScriptSDK.Builder.ImportBinding | import/绑定导入路径 |

### Restore 序列化

> 源文件：`AngelScriptSDK/AngelscriptRestoreTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Restore.RoundTrip | 脚本节点/字节码等序列化往返一致 |
| AngelScriptSDK.Restore.StripDebugInfoRoundTrip | 去掉调试信息后仍可往返 |
| AngelScriptSDK.Restore.EmptyStreamFails | 空字节流加载失败并报告 `Unexpected end of file`，且不崩溃 |
| AngelScriptSDK.Restore.TruncatedStreamFails | 截断字节流加载失败并报告 `Unexpected end of file`，且不崩溃 |

### Compiler 编译器

> 源文件：`AngelScriptSDK/AngelscriptCompilerTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Compiler.BytecodeGeneration | 编译器生成字节码 |
| AngelScriptSDK.Compiler.VariableScopes | 变量作用域 |
| AngelScriptSDK.Compiler.FunctionCalls | 函数调用编译 |
| AngelScriptSDK.Compiler.TypeConversions | 类型转换编译 |

### DataType 数据类型

> 源文件：`AngelScriptSDK/AngelscriptDataTypeTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.DataType.Primitives | 内部原始类型表示 |
| AngelScriptSDK.DataType.Comparisons | 类型比较/相等语义 |
| AngelScriptSDK.DataType.ObjectHandles | 对象句柄类型 |
| AngelScriptSDK.DataType.SizeAndAlignment | 大小与对齐 |

### GC 垃圾回收内部

> 源文件：`AngelScriptSDK/AngelscriptGCInternalTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.GC.Statistics | GC 统计接口 |
| AngelScriptSDK.GC.EmptyCollect | 空集合回收行为 |
| AngelScriptSDK.GC.InvalidLookup | 无效对象查找处理 |
| AngelScriptSDK.GC.ReportUndestroyedEmpty | 未销毁报告为空场景 |
| AngelScriptSDK.GC.ManualCycleCollection | 手动环收集 |
| AngelScriptSDK.GC.CycleDetection | 环检测 |

### Parser 解析器

> 源文件：`AngelScriptSDK/AngelscriptParserTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Parser.Declarations | 解析器：声明解析 |
| AngelScriptSDK.Parser.ExpressionAst | 表达式 AST |
| AngelScriptSDK.Parser.ControlFlow | 控制流解析 |
| AngelScriptSDK.Parser.SyntaxErrors | 语法错误处理 |

### ScriptNode 脚本节点

> 源文件：`AngelScriptSDK/AngelscriptScriptNodeTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.ScriptNode.Types | 脚本节点类型 |
| AngelScriptSDK.ScriptNode.Traversal | 节点遍历 |
| AngelScriptSDK.ScriptNode.Copy | 节点拷贝 |

### Bytecode 字节码

> 源文件：`AngelScriptSDK/AngelscriptBytecodeTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Bytecode.InstructionSequence | 字节码指令序列 |
| AngelScriptSDK.Bytecode.Append | 字节码追加 |
| AngelScriptSDK.Bytecode.JumpResolution | 跳转解析/回填 |
| AngelScriptSDK.Bytecode.Output | 字节码输出 |

### Memory 内存管理

> 源文件：`AngelScriptSDK/AngelscriptMemoryTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Memory.Construction | 内存管理器构造 |
| AngelScriptSDK.Memory.FreeUnused | 释放未使用内存 |
| AngelScriptSDK.Memory.ScriptNodeReuse | ScriptNode 池复用 |
| AngelScriptSDK.Memory.ByteInstructionReuse | 字节指令复用 |
| AngelScriptSDK.Memory.PoolLeakTracking | 池泄漏追踪 |

### Tokenizer 词法分析

> 源文件：`AngelScriptSDK/AngelscriptTokenizerTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.Tokenizer.BasicTokens | 基本 token |
| AngelScriptSDK.Tokenizer.Keywords | 关键字 |
| AngelScriptSDK.Tokenizer.CommentsAndStrings | 注释与字符串 |
| AngelScriptSDK.Tokenizer.ErrorRecovery | 错误恢复 |

### StructCppOps

> 源文件：`AngelScriptSDK/AngelscriptStructCppOpsTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| AngelScriptSDK.StructCppOps.NotBlueprintTypeByDefault | 结构体 C++ 操作默认非 BlueprintType 行为 |

---

## 7. Compiler — 编译管线

> 源文件：`Compiler/AngelscriptCompilerPipelineTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Compiler.EndToEnd.DelegateEnumClassCompile | 委托与 `enum class` 等端到端编译 |
| Compiler.EndToEnd.FunctionDefaultsAndClassLikeCompile | 函数默认值与类式声明编译 |
| Compiler.EndToEnd.PropertyDefaultsCompile | 属性默认值编译 |
| Compiler.EndToEnd.GeneratedClassConsistency | 生成 `UClass` 一致性 |
| Compiler.EndToEnd.ModuleFunctionInspection | 模块内函数反射/检查 |
| Compiler.EndToEnd.EnumAvailability | 枚举在生成侧可用性 |
| Compiler.EndToEnd.DelegateSignatureConsistency | 委托签名一致性 |
| Compiler.EndToEnd.ClassLikeReflectionShape | 类式反射形状 |

---

## 8. Preprocessor — 预处理器

> 源文件：`Preprocessor/AngelscriptPreprocessorTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Preprocessor.BasicParse | 预处理器基础解析 |
| Preprocessor.MacroDetection | 宏检测与展开 |
| Preprocessor.ImportParsing | `#import` 等解析 |

---

## 9. ClassGenerator — 类生成器

> 源文件：`ClassGenerator/ClassGeneratorTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| ClassGenerator.EmptyModuleSetup | 空模块下类生成器初始化/搭建 |

---

## 10. FileSystem — 文件系统

> 源文件：`FileSystem/AngelscriptFileSystemTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| FileSystem.ModuleLookupByFilename | 按文件名查找模块 |
| FileSystem.CompileFromDisk | 从磁盘路径编译 |
| FileSystem.PartialFailurePreservesGoodModules | 部分模块失败时其余好模块仍保留 |
| FileSystem.Discovery | 脚本文件发现 |
| FileSystem.SkipRules | 跳过规则（不扫描某些路径） |

---

## 11. Editor — 编辑器

> 源文件：`AngelscriptEditor/Tests/AngelscriptDirectoryWatcherTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Editor.DirectoryWatcher.Queue.ScriptAddAndRemove | `.as` 文件 add/remove 进入对应队列 |
| Editor.DirectoryWatcher.Queue.IgnoresNonScriptFiles | 非 `.as` 文件被忽略 |
| Editor.DirectoryWatcher.Queue.FolderAddScansContainedScripts | 新增目录递归扫描脚本 |
| Editor.DirectoryWatcher.Queue.FolderRemoveUsesLoadedScriptEnumerator | 删除目录通过已加载脚本枚举生成删除队列 |
| Editor.DirectoryWatcher.Queue.RenameWindowTracksRemoveAndAdd | rename-window 建模下 remove+add 同时入队 |
| Editor.DirectoryWatcher.Queue.DuplicateStormDeduplicatesEntries | 事件风暴下同一路径重复变更保持去重入队 |


> 源文件：`AngelscriptEditor/Tests/AngelscriptBlueprintImpactScannerTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Editor.BlueprintImpact.NormalizePaths | changed-script 输入会统一分隔符、去掉前导相对标记、大小写归一化并去重 |
| Editor.BlueprintImpact.MatchChangedScriptsToModuleSections | changed-script 只命中包含对应 code section 的活跃模块 |
| Editor.BlueprintImpact.BuildImpactSymbols | scanner 会从 module desc 收集生成类、struct 与 enum 符号集合 |
| Editor.BlueprintImpact.AnalyzeParentClass | 已加载 Blueprint 的父类链命中 impact class 时，会返回 `ScriptParentClass` 原因 |
| Editor.BlueprintImpact.AnalyzeVariableType | `NewVariables` 中引用 impacted struct 的 Blueprint 会返回 `VariableType` 原因 |
| Editor.BlueprintImpact.AnalyzePinType | 节点 pin 使用 impacted struct 时会返回 `PinType` 原因 |
| Editor.BlueprintImpact.AnalyzeNodeDependency | 节点外部依赖命中 impacted class 时会返回 `NodeDependency` 原因 |
| Editor.BlueprintImpact.AnalyzeReferencedAsset | replacement-object 扫描命中 Blueprint 引用时会返回 `ReferencedAsset` 原因 |
| Editor.BlueprintImpact.AnalyzeDelegateSignature | 事件节点签名命中 impacted delegate 时会返回 `DelegateSignature` 原因 |
| Editor.BlueprintImpact.FindBlueprintAssetsDiskBacked | `FindBlueprintAssets(..., true)` 只返回磁盘上真实存在的 Blueprint 资产 |
| Editor.BlueprintImpact.CommandletInvalidFile | commandlet 对无效 `ChangedScriptFile=` 参数返回参数错误退出码 |


> 源文件：`Editor/AngelscriptSourceNavigationTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Editor.SourceNavigation.Functions | 编译注解类后，`UASFunction` 保留源路径与行号，`FSourceCodeNavigation::CanNavigateTo*` 为真 |

---

## 11.5 Debugger — 调试器

> 源文件：`AngelscriptRuntime/Tests/AngelscriptDebugProtocolTests.cpp`、`AngelscriptRuntime/Tests/AngelscriptDebugTransportTests.cpp`、`Debugger/AngelscriptDebuggerSmokeTests.cpp`、`Debugger/AngelscriptDebuggerBreakpointTests.cpp`、`Debugger/AngelscriptDebuggerSteppingTests.cpp`

| 测试前缀 | 代表源文件 | 验证内容 |
|--------|----------|----------|
| `Angelscript.CppTests.Debug.Protocol.*` | `AngelscriptDebugProtocolTests.cpp` | 调试消息体 round-trip、版本字段与结构兼容 |
| `Angelscript.CppTests.Debug.Transport.*` | `AngelscriptDebugTransportTests.cpp` | 调试 envelope 的 framing、半包、多包与错误长度处理 |
| `Angelscript.TestModule.Debugger.Smoke.*` | `Debugger/AngelscriptDebuggerSmokeTests.cpp` | 调试会话握手、server version 返回与基础连接链路 |
| `Angelscript.TestModule.Debugger.Breakpoint.*` | `Debugger/AngelscriptDebuggerBreakpointTests.cpp` | 断点下发、命中行号、分支忽略与继续执行行为 |
| `Angelscript.TestModule.Debugger.Stepping.*` | `Debugger/AngelscriptDebuggerSteppingTests.cpp` | `StepIn` / `StepOver` / `StepOut` 的停止行为与调用栈变化 |

---

## 12. Themed Integration Tests — 主题化集成回归

> 说明：
>
> - 这组测试原先集中放在旧的宽泛目录下，现已按主题拆分到 Actor/、Blueprint/、ClassGenerator/、Component/、Delegate/、GC/、HotReload/、Inheritance/、Interface/、Subsystem/ 等目录。
> - 自动化测试路径已去掉历史上的宽泛中间层，目录分类与测试发现路径现在保持一致。

### 12.1 Actor 生命周期

> 源文件：`Actor/AngelscriptActorLifecycleTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Actor.BeginPlay | 脚本重写 `BeginPlay`，`BeginPlayCalled` 为 1 |
| Actor.Tick | 启用 Actor Tick 后多次世界 tick，`TickCount` ≥ 5 |
| Actor.ReceiveEndPlay | 销毁后 `EndPlay` 调用，`EndPlayCalled` 为 1 |
| Actor.ReceiveDestroyed | 销毁流程中 `Destroyed` 调用，`DestroyedCalled` 为 1 |
| Actor.Reset | 修改 `ResetValue` 后 `Actor->Reset()` 触发脚本 `OnReset`，值为 7 |

### 12.2 Actor 交互

> 源文件：`Actor/AngelscriptActorInteractionTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Actor.PointDamage | `ApplyPointDamage` 后脚本的 `PointDamage` 用伤害值设置 `ActorTickInterval`（42） |
| Actor.RadialDamage | 球体重叠路径施加径向伤害，脚本 `RadialDamage` 将缩放设为伤害值（24） |
| Actor.MultiSpawn | 连续生成 3 个实例，BeginPlay 计数总和 ≥3 且三者指针互异 |
| Actor.CrossCall | A 的 Tick 调用 B 的 `UFUNCTION`，B 的 `CallCount` ≥ 1 |

### 12.3 Actor 属性

> 源文件：`Actor/AngelscriptActorPropertyTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Actor.UProperty | 反射 int/FString `UPROPERTY` 在实例上保持脚本默认值 |
| Actor.UFunction | `GetHealth` 经 `ExecuteGeneratedIntEventOnGameThread` 返回与 `Health` 一致（100） |
| Actor.DefaultValues | `default PrimaryActorTick.TickInterval = 0.5f` 生效 |

### 12.4 ScriptClass 创建

> 源文件：`ClassGenerator/AngelscriptScriptClassCreationTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| ScriptClass.CompilesToUClass | 脚本类生成 `UClass` 且派生自 `AActor`，`SpawnMarker` 默认为 7 |
| ScriptClass.CanSpawnInTestWorld | 在测试世界中生成脚本 Actor，`BeginPlay` 后 `BeginPlayObserved` 为 1 |
| ScriptClass.MultiSpawnKeepsStateIsolation | 同一类多实例：改其一 `LocalState` 不影响另一实例 |
| ScriptClass.BlueprintChildCompiles | 以脚本类为父的蓝图可编译、继承关系正确 |
| ScriptClass.CDOHasExpectedDefaults | CDO 与实例上 int/bool/FString 默认值与脚本一致 |
| ScriptClass.RecompileDoesNotCrashClassSwitch | 同模块重编译后新属性与更新默认值可见 |
| ScriptClass.NonUClassTypeCannotSpawn | 非 Actor 的 `UObject` 脚本类可 `NewObject`，但 `SpawnActor` 返回 null |
| ScriptClass.RenameReplacesOldClass | 类名重命名后新类可查找、旧类名不再暴露且旧类被替换隐藏 |

### 12.5 ScriptActor 重载执行

> 源文件：`Actor/AngelscriptScriptSpawnedActorOverrideTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| ScriptActor.BeginPlayRunsInWorld | 脚本 Actor 进入世界后 `BeginPlayObserved` 为 1 |
| ScriptActor.NativeUFunctionCanBeInvoked | `ProcessEvent` 调用带 int 参数的脚本 `UFUNCTION`，属性反映调用与参数 |
| ScriptActor.BeginPlayCallsAnotherScriptUFunction | `BeginPlay` 内调用另一脚本 `UFUNCTION`，`ScriptDispatchObserved` 为 1 |
| ScriptActor.TickRunsNTimes | 启用 Tick 后手动 tick N 次，`LogicalTickCount` 增量为 N |
| ScriptActor.CrossInstanceCallDoesNotLeakState | 实例 A 在 `BeginPlay` 通过引用调用 B，双方 `LocalState` 互不串扰 |
| ScriptActor.DestroyedActorInvocationFailsSafely | 目标 Actor 销毁后，源侧调用不执行目标体 |
| ScriptActor.MissingFunctionReportsExplicitFailure | 对不存在函数名调用返回失败 |

### 12.6 BlueprintSubclass 蓝图子类化

> 源文件：`Blueprint/AngelscriptBlueprintSubclassActorTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Actor.BlueprintSubclassBeginPlay | 以脚本 Actor 为父创建蓝图子类，生成实例后继承的 `BeginPlay` 执行一次 |

### 12.7 BlueprintChild 运行时

> 源文件：`Blueprint/AngelscriptBlueprintSubclassRuntimeTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| BlueprintChild.InheritsScriptBeginPlay | BP 子类继承并执行脚本层的 `BeginPlay` 重载 |
| BlueprintChild.InheritsScriptTick | BP 子类继承并执行脚本层的 `Tick` 重载 |
| BlueprintChild.ScriptUFunctionStillCallable | BP 子类可以通过 `ProcessEvent` 调用脚本定义的 `UFUNCTION` |
| BlueprintChild.RecreateDoesNotLeakPreviousState | BP 子类重新创建不会泄漏之前实例的状态 |
| BlueprintChild.NoOverrideUsesScriptParentDefault | BP 子类不覆盖属性时正确继承脚本父类的默认值 |
| BlueprintChild.OverrideChainHasDeterministicCounts | 脚本父→子重写链再被蓝图子类化后，各层计数确定性正确 |


> 源文件：`Blueprint/AngelscriptBlueprintImpactTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| BlueprintImpact.ScriptParentMatch | 变更脚本过滤命中对应 module 后，脚本父类派生的 Blueprint 会被 scanner 标记为受影响 |
| BlueprintImpact.ChangedScriptFilter | changed-script 过滤不会把无关脚本父类的 Blueprint 一并误报 |
| BlueprintImpact.DiskBackedAssetScan | 保存到 `/Game/Automation/...` 的磁盘 Blueprint 资产会进入 AssetRegistry 候选集，并能被 scanner 命中 |

### 12.8 Component 组件

> 源文件：`Component/AngelscriptComponentTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Component.BeginPlay | 脚本组件 `BeginPlay` 将 `bReady` 置 true |
| Component.Tick | 启用组件 Tick 后多次世界 tick，`TickCount` ≥ 5 |
| Component.ReceiveEndPlay | 宿主 Actor 销毁后组件 `EndPlay` 将 `bCleanedUp` 置 true |
| Component.ActorOwner | 组件 `BeginPlay` 中 `Cast` 宿主脚本 Actor 并读取 `OwnerValue` 为 42 |

### 12.9 DefaultComponent 默认组件

> 源文件：`Component/AngelscriptComponentTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| DefaultComponent.Basic | `DefaultComponent`+`RootComponent` 生成正确类型的根组件 |
| DefaultComponent.Multiple | 根 Scene + 子 Billboard 默认组件存在且父子附着关系正确 |

### 12.10 Inheritance 继承场景

> 源文件：`Inheritance/AngelscriptInheritanceFunctionalTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Inheritance.ScriptToScript | 脚本 Actor 间继承+重写 `UFUNCTION` 的 reload 分析（当前分支为 Error） |
| Inheritance.Super | 含 `Super::` 的脚本继承场景分析（当前分支为 Error） |
| Inheritance.IsA | `Cast`/IsA 类脚本变更可分析，且要求 Full reload |

### 12.11 Interface 接口

> 源文件：`Interface/AngelscriptInterfaceNativeTests.cpp`、`Interface/AngelscriptInterfaceNativeBridgeTests.cpp`、`Interface/AngelscriptInterfaceNativeBindingTests.cpp`、`Interface/AngelscriptInterfaceNativeLifecycleTests.cpp`、`Interface/AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp`、`Interface/AngelscriptInterfaceNativePointerOffsetTests.cpp`
>
> 当前不支持脚本 `UINTERFACE()` / `interface UIFoo {}` 声明；Interface 测试覆盖的是脚本实现或调用 C++ native UInterface 的路径。

| 测试名 | 验证内容 |
|--------|----------|
| Interface.NativeImplement | 脚本 Actor 实现 native parent interface，脚本侧 `Cast` 与 C++ `Execute_` bridge 均可调用脚本实现 |
| Interface.NativeInheritedImplement | 脚本 Actor 实现 native child interface，并可通过 parent/child 接口引用调用继承链方法 |
| Interface.NativeReferenceRoundTrip | native interface 引用在脚本与 C++ 之间往返时保持可调用状态 |
| Interface.NativeReferenceRoundTrip.CppBridgeMutatesActorState | C++ bridge 通过 native interface 调用脚本实现并修改 Actor 状态 |
| Interface.NativeInheritedImplement.ParentBridgeSetterAndRef | parent interface 的 setter 与 ref 参数通过 child implementer 正确分发 |
| Interface.NativeImplement.CppImplementerScriptCall | 脚本 Actor 持有 C++ native implementer，脚本侧 cast 后调用 C++ `_Implementation` |
| Interface.NativeBinding.SignatureRegistrationLifecycle | interface method signature 注册和释放生命周期不泄漏 |
| Interface.Native.SignatureRegistrationRelease | shared engine 中 signature 注册/释放按基线计数恢复 |
| Interface.NativeInheritedImplement.ChildSurfaceIncludesParentMethods | child native interface 暴露 parent interface 方法面 |
| Interface.NativePointerOffset.MultiInterfaceCast | 多 native interface C++ implementer 的非零 `PointerOffset` cast 与调用正确 |
| Interface.NativePointerOffset.ScriptClassStillZeroOffset | 脚本类实现 native interface 的零偏移路径仍保持正确 |

### 12.12 Delegate 委托

> 源文件：`Delegate/AngelscriptDelegateTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Delegate.Unicast | 脚本声明 delegate，绑定原生函数，触发后 `NameCounts["Unicast"]` 为 77 |
| Delegate.Multicast | `event` 多播在 `BeginPlay` 绑定脚本处理，C++ 广播后 `EventTriggerCount` 增加 |

### 12.13 GC 垃圾回收

> 源文件：`GC/AngelscriptGCTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| GC.ActorDestroy | 脚本 Actor 销毁并 GC 后弱引用无效 |
| GC.ComponentDestroy | 脚本组件 `DestroyComponent` 并 GC 后弱引用无效 |
| GC.WorldTeardown | `FActorTestSpawner` 作用域结束后世界/Actor/组件弱引用均被释放 |

### 12.14 Subsystem 子系统

> 源文件：`Subsystem/AngelscriptSubsystemTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| WorldSubsystem.Lifecycle | `UScriptWorldSubsystem` 生命周期（当前分支编译失败） |
| WorldSubsystem.Tick | World 子系统 `BP_Tick`（当前分支编译失败） |
| WorldSubsystem.ActorAccess | World 子系统在 Tick 中访问 Actor（当前分支编译失败） |
| GameInstanceSubsystem.Lifecycle | `UScriptGameInstanceSubsystem` 生命周期（当前分支编译失败） |

### 12.15 HotReload 热重载场景

> 源文件：`HotReload/AngelscriptHotReloadTests.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| HotReload.PropertyPreserved | Soft reload 后类指针不变、实例 `Counter` 保留 |
| HotReload.AddProperty | Full reload 后新属性 `NewValue` 默认 99，原属性仍存在 |
| HotReload.FunctionChange | Soft reload 前后 `GetValue` 分别从 1 变为 2 |
| HotReload.PIEStructuralChangeNeedsFullReload | 分析脚本增属性变更，要求走 Full reload 路径 |

### 12.16 Functional Round1 Gap-Fill — 真空区与深度补漏

> 源文件：`Functional/<Theme>/Angelscript<Theme><Topic>Tests.cpp`
>
> 来源：`Documents/Plans/Plan_ReferenceBasedTestExpansion.md` Round1 落地（仅补真空区与深度，共 15 个用例）。
>
> Prefix 沿用 Round1 蓝图字面：`Angelscript.TestModule.Functional.<Theme>.<Topic>.*`，与默认 `<Theme>.*` 主题层并存的例外说明见 `Documents/Guides/TestConventions.md`。

| 测试名 | 验证内容 |
|--------|----------|
| Functional.Types.ScriptDataAsset.CompilesAndRegistersProperties | `class : UDataAsset` 编译；`UPROPERTY` 进入反射；CDO 默认值匹配；`AActor` 持 `UDataAsset` 引用 |
| Functional.Widget.BindWidget.MetadataAndPropertyTypes | `UUserWidget` 子类 `UPROPERTY(BindWidget)` 多种 widget 类型注册 + metadata 反射 |
| Functional.Animation.AnimNotifyScript.SubclassRegistersUPropertyAndDerivesFromUAnimNotify | `class : UAnimNotify` 编译，`UPROPERTY` 进入反射，CDO 默认值（FName / float）正确 |
| Functional.Animation.AnimNotifyStateScript.SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState | `class : UAnimNotifyState` 编译，多 `UPROPERTY` 类型注册，bool CDO 默认值生效 |
| Functional.Rendering.DynamicMaterial.ScriptCompilesDynamicMaterialAPI | `UStaticMeshComponent` `DefaultComponent` + `UMaterialInstanceDynamic` 引用 + AS 端 `CreateDynamicMaterialInstance` / `SetScalarParameterValue` / `SetVectorParameterValue` 编译路径打通 |
| Functional.GAS.ScriptAttributeSet.SubclassRegistersAttributeFieldsAndOnRepFunction | `class : UAngelscriptAttributeSet` 编译；`FAngelscriptGameplayAttributeData` 字段进入反射；`OnRep_Attribute` UFunction 继承 |
| Functional.Component.SplineUsage.SplineDefaultComponentRegistersAndAPICompiles | `USplineComponent` `DefaultComponent` + AS `GetSplineLength` / `GetLocationAtDistanceAlongSpline` / `GetRotationAtDistanceAlongSpline` 编译路径打通 |
| Functional.Component.MultiLevelHierarchy.FourLevelAttachChainResolves | 4 层 `DefaultComponent` 链（Root → Middle → LeafMesh → DeepLight）的 `GetAttachParent` / `GetChildrenComponents` 全链验证 |
| Functional.Component.DefaultPropertyOverride.DefaultStatementsAffectComponentCDOs | `default Sphere.SphereRadius=128`、`default Mesh.bHiddenInGame=true`、`default Mesh.CastShadow=false` 在 CDO 上正确生效 |
| Functional.Property.MetaSpecifiersMatrix.MetaSpecifiersAreReflectedOnFProperty | `EditCondition` / `EditConditionHides` / `InlineEditConditionToggle` / `ClampMin/Max` / `UIMin/Max` / `MakeEditWidget` 经 `FProperty::GetMetaData` 全部可读 |
| Functional.Functions.MixinReferenceMatrix.MixinSignaturesCompileAndDispatchAtRuntime | mixin 单参 / 单参+默认值 / 多参+默认值 三种签名运行时正确 dispatch |
| Functional.Delegate.BroadcastWithParams.EventBroadcastFanOutsToAllListenersAndDelegateExecuteReturnsValue | `event` AddUFunction + Broadcast 多绑定 fan-out + Unbind 后只剩 1 listener；`delegate` IsBound + Execute 返回值 |
| Functional.Actor.SpawnPatterns.MultipleSpawnSyntaxesProduceValidActors | `SpawnActor(Class, Loc, Rot)` / 命名参数 / `bDeferredSpawn=true`+`FinishSpawningActor` / `TSubclassOf`+`Cast<>` 四种调用模式均成功 |
| Functional.Actor.TimerRuntimeBehavior.PauseUnpauseAndClearTransitionsAreObservable | `SetTimer` 后 `IsTimerPausedHandle == false` → `Pause` 后 == true → `UnPause` 后 == false → `Clear` 后 == false 状态机闭合 |
| Functional.Types.StringInterpolationAndFNameLiteral.FStringInterpolationAndFNameLiteralRuntimeValues | `f"Hello {Name}!"` / `f"{A} {B} in {C}s"` 运行时输出正确；`n"Tag" == FName("Tag")` 与 case-insensitive `n"tag" == FName("TAG")` |

---

## 13. Learning — 教学型可观测测试

> 源文件：`Learning/` 目录下所有测试
>
> 目标：解释机制如何工作，而非仅验证功能回归。输出包含阶段、步骤、观测值和教学总结。

### 13.1 Native 层学习测试

> 源文件：`Learning/AngelScriptSDK/AngelscriptLearningNative*.cpp`
>
> 解释原生 AngelScript 引擎的启动、绑定、字节码、handles、调试器上下文。

| 测试名 | 教学目标 |
|--------|----------|
| Learning.Native.Bootstrap | 解释 `asCreateScriptEngine`、引擎属性、模块创建、函数声明收集 |
| Learning.Native.Binding | 解释 `RegisterGlobalFunction`、`RegisterGlobalProperty`、`RegisterObjectType`、值类型绑定 |
| Learning.Native.Bytecode | 解释函数声明、参数计数、局部变量、字节码长度、`Prepare`/`Execute` 流程 |
| Learning.Native.HandleAndScriptObject | 解释 script object 编译、类型元数据可见性、handle 声明边界 |
| Learning.Native.DebuggerContext | 解释异常上下文中的 `GetExceptionString`、`GetCallstackSize`、栈变量读取 |

### 13.2 Runtime 层学习测试

> 源文件：`Learning/Runtime/AngelscriptLearning*.cpp`
>
> 解释编译管线、预处理、模块解析、热重载判定、类生成、UE 桥接等。

| 测试名 | 教学目标 |
|--------|----------|
| Learning.Runtime.Compiler | 解释 `BuildModule()` vs `CompileModuleFromMemory()` vs `CompileAnnotatedModuleFromMemory()` 的差异 |
| Learning.Runtime.Preprocessor | 解释 `FilenameToModuleName()`、chunk 拆分、macro 记录、import 移除 |
| Learning.Runtime.FileSystemAndModule | 解释磁盘编译、`GetModule`/`GetModuleByFilename`、模块发现跳过规则 |
| Learning.Runtime.RestoreAndBytecodePersistence | 解释 `SaveByteCode`/`LoadByteCode`、debug info strip 标志、restored function discoverability |
| Learning.Runtime.HotReloadDecision | 解释软重载/完整重载判定触发条件（no-change、body-only、property-count、super-class、class-add/remove、signature-change） |
| Learning.Runtime.ClassGeneration | 解释 `UCLASS()` 脚本如何生成 `UClass`、属性枚举、CDO 默认值、actor-derived 检测 |
| Learning.Runtime.ScriptClassToBlueprint | 解释脚本类如何作为 Blueprint 父类、继承验证、BeginPlay override、属性传播 |
| Learning.Runtime.InterfaceDispatch | 解释脚本类实现 C++ native UInterface、`ImplementsInterface` 验证、C++ `Execute_` bridge 和 dispatch 可见性 |
| Learning.Runtime.DelegateBridge | 解释 unicast delegate 绑定、`BindUFunction`、native->script dispatch |
| Learning.Runtime.ComponentHierarchy | 解释 `DefaultComponent` specifier、组件生命周期（BeginPlay/Tick） |
| Learning.Runtime.BlueprintSubclass | 解释 Blueprint 继承脚本类、属性继承、运行时 override 行为 |
| Learning.Runtime.ExecutionLifecycle | 解释 `CreateContext`/`Prepare`/`Execute`/`GetReturnValue` 原生执行生命周期 |
| Learning.Runtime.UEBridge | 解释脚本函数如何成为 UFunction、ProcessEvent 调用、属性读写桥接 |

---

## 14. Examples — 示例脚本编译

> 源文件：`Examples/AngelscriptScriptExample*Test.cpp`（各文件对应一个示例 `.as`）以及 `Examples/AngelscriptScriptExampleCoverageTests.cpp`（直接从 `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/` 读取真实资产）
>
> 所有测试通过 `RunScriptExampleCompileTest` 将内嵌示例脚本编译为注解模块，验证文档级示例脚本能完整通过编译。

| 测试名 | 验证内容（示例主题） |
|--------|----------------------|
| ScriptExamples.Actor | Actor 类/UProperty/BlueprintOverride |
| ScriptExamples.AccessSpecifiers | 访问修饰符 |
| ScriptExamples.Array | 数组操作 |
| ScriptExamples.BehaviorTreeNodes | 行为树节点 |
| ScriptExamples.CharacterInput | 角色输入 |
| ScriptExamples.ConstructionScript | 构造脚本 |
| ScriptExamples.Delegates | 委托 |
| ScriptExamples.Enum | 枚举 |
| ScriptExamples.FormatString | 格式化字符串 |
| ScriptExamples.Functions | 函数示例 |
| ScriptExamples.FunctionSpecifiers | 函数说明符 |
| ScriptExamples.Map | Map 容器 |
| ScriptExamples.Math | 数学 |
| ScriptExamples.MixinMethods | Mixin 方法 |
| ScriptExamples.MovingObject | 移动对象 |
| ScriptExamples.Overlaps | 重叠检测 |
| ScriptExamples.PropertySpecifiers | 属性说明符（依赖 `Example_Enum.as`） |
| ScriptExamples.Coverage.Actor | 从真实 `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Actor.as` 读取并验证 Actor 默认值、`BeginPlay`、`UFUNCTION` 与默认语句 |
| ScriptExamples.Coverage.Component | 从真实 `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Component.as` 读取并验证脚本组件 `BeginPlay`、`Tick` 与宿主 Actor 访问 |
| ScriptExamples.Coverage.UObject | 从真实 `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_UObject.as` 读取并验证脚本 `UObject` 默认值与 `UFUNCTION` |
| ScriptExamples.Coverage.PropertySpecifiers | 从真实 `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_PropertySpecifiers.as` 读取并验证 `DefaultComponent`、`RootComponent`、`Attach` 与常用属性说明符 |
| ScriptExamples.Struct | 结构体 |
| ScriptExamples.Timers | 定时器 |
| ScriptExamples.WidgetUMG | UMG 控件 |

---

## 15. Template — 模板场景

> 源文件：`Template/Template_Blueprint.cpp`、`Template_BlueprintWorldTick.cpp`、`Template_WorldTick.cpp`

| 测试名 | 验证内容 |
|--------|----------|
| Template.Blueprint.ScriptParentChild | 蓝图与脚本父类子类关系模板场景 |
| Template.Blueprint.ActorChildWorldTick | 蓝图 Actor 子类在世界 Tick 下行为模板 |
| Template.WorldTick.ScriptActorLifecycle | 世界 Tick 驱动的脚本 Actor 生命周期模板 |

---

## 15. Phase 6 完整回归矩阵（分层执行视图）

> 目标：把快速烟雾层、功能正确性层、真实语料层、长时压力层、产物验证层拆分为可执行模板。

### 15.1 快速烟雾层（PR 前）

| 测试前缀 | 说明 |
|--------|----------|
| `Angelscript.CppTests.MultiEngine` | 创建模式与 startup owner 基础烟雾 |
| `Angelscript.TestModule.Engine.BindConfig` | 启动 bind 配置与顺序烟雾 |
| `Angelscript.TestModule.Shared.EngineHelper` | 引擎隔离与 scope 恢复烟雾 |
| `Angelscript.TestModule.Parity` | 生产引擎 bind 可见性 smoke |

### 15.2 功能正确性层

| 测试前缀 | 说明 |
|--------|----------|
| `Angelscript.Editor.DirectoryWatcher` | callback 输入到队列输出 deterministic 语义 |
| `Angelscript.TestModule.HotReload` | queue 消费、热重载行为与失败兜底 |
| `Angelscript.TestModule.ScriptClass` | generated class 重编译/rename/可见性 |
| `Angelscript.TestModule.FileSystem` | 文件发现、映射、路径归一化与 skip 规则 |

### 15.3 真实脚本语料层

| 测试前缀 | 说明 |
|--------|----------|
| `Angelscript.TestModule.Angelscript.NativeScriptHotReload` | `Script/Tests/*.as` 语料全量编译 + soft reload handled 路径 |

### 15.4 长时压力层（阶段收口/夜间）

| 测试前缀 | 说明 |
|--------|----------|
| `Angelscript.TestModule.Core.Performance.Startup` | startup/bind baseline |
| `Angelscript.TestModule.Core.Performance.ShareCleanCycle` | share-clean 串行 acquire/compile/reset baseline，含生成类 reset 后引用诊断 |
| `Angelscript.TestModule.Performance` | 参考外部性能样例的脚本自调用、C++ 属性、C++ 函数微基准 |
| `Angelscript.TestModule.HotReload.Performance` | reload 延迟 baseline 与 burst churn |

### 15.5 产物验证层

| 测试前缀 | 说明 |
|--------|----------|
| `Angelscript.TestModule.Core.Performance.ArtifactGeneration` | metrics.json 与目录结构落盘验证 |
| `Angelscript.CppTests.CodeCoverage.HtmlReport.Generation` | 报告产物写出能力邻近回归 |
| `Angelscript.CppTests.StaticJIT.PrecompiledData.*` | 预编译数据产物与 round-trip 稳定性 |

### 15.6 Performance — 运行期微基准

> 源文件：`Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp`、`Performance/AngelscriptReflectiveFallbackBenchmarkTests.cpp`、`Performance/AngelscriptPerformanceTestTypes.cpp`
>
> 标准分组：`AngelscriptPerformance` 同时路由 `Angelscript.TestModule.Performance.`、`Angelscript.TestModule.Core.Performance.` 与 `Angelscript.TestModule.HotReload.Performance.`。

| 测试名 | 验证内容 |
|--------|----------|
| Performance.ScriptSelf | 参考外部样例中的脚本自调用场景，采样空函数与算术函数循环，并与 native baseline checksum 对齐 |
| Performance.NativeProperty | 采样脚本访问 C++ scalar/container UPROPERTY 的读写循环，并与 C++ native loop checksum 对齐 |
| Performance.NativeFunction | 采样脚本调用 C++ scalar/container UFUNCTION 的读写循环，并与 C++ native loop checksum 对齐 |
| Performance.ReflectiveFallback.Benchmark | 纯 C++ 四组对照基准（不经过 AS）：A0=直接 C++ 方法调用（绝对下限） / A1=`UObject::ProcessEvent` / A2=`FFrame`+`UFunction::Invoke`（无缓存）/ A3=预缓存 `FBenchParamCache`+`FFrame`+`Invoke`（含 POD `FMemory::Memcpy` 快路径）。覆盖 16 个 UFunction，按 FProperty 类型矩阵铺开：(1) 反射地板基线 `StaticNoOp` / `MemberNoOp` / `StaticAdd`；(2) POD 标量 getter `GetBool` / `GetInt32` / `GetDouble` / `GetEnum`；(3) 非 POD getter `GetName` / `GetString` / `GetStruct` / `GetObject` / `GetArray` / `GetMap`；(4) `const&` 入参 setter `SetString` / `SetStruct` / `SetArray` / `SetMap`。每个函数四路径都通过同一 `BenchOne` 驱动 + `ExtractChecksum` 跨路径校验（A1/A2/A3 始终比对，A0 在类型可比较时也比对）。输出 metrics.json，前缀 `reflective.<funcname>.{a0,a1,a2,a3}_*_seconds`，用于量化跳过 `ProcessEvent`（A2 vs A1）、额外缓存（A3 vs A2）以及反射 vs 原生（A3 vs A0）随类型复杂度的衰减。注：纯静态函数 / 标量 getter 的 A0 测量受编译器 inline / DCE 影响会偏低；`Get*` 容器 / 字符串类型的 A0 才是真实可比较的反射不可消除下限。参考 `Reference/sluaunreal/Plugins/slua_unreal/Source/slua_unreal/Private/LuaFunctionAccelerator.cpp`。 |

### 15.7 首轮执行快照（2026-04-03）

| 层级 | 前缀 | 报告目录 | 结果摘要 |
|--------|----------|----------|----------|
| 快速烟雾层 | `Angelscript.CppTests.MultiEngine` | `Saved/Automation/AngelscriptPerformance/P6_MultiEngine/Reports/index.json` | `failed=0` |
| 快速烟雾层 | `Angelscript.CppTests.Engine.DependencyInjection` | `Saved/Automation/AngelscriptPerformance/P6_DependencyInjection/Reports/index.json` | `failed=0` |
| 快速烟雾层 | `Angelscript.CppTests.Subsystem` | `Saved/Automation/AngelscriptPerformance/P6_Subsystem/Reports/index.json` | `failed=0` |
| 快速烟雾层 | `Angelscript.TestModule.Engine.BindConfig` | `Saved/Automation/AngelscriptPerformance/P6_BindConfig/Reports/index.json` | `failed=0` |
| 快速烟雾层 | `Angelscript.TestModule.Shared.EngineHelper` | `Saved/Automation/AngelscriptPerformance/P6_SharedEngineHelper/Reports/index.json` | `failed=0` |
| 快速烟雾层 | `Angelscript.TestModule.Parity` | `Saved/Automation/AngelscriptPerformance/P6_Parity/Reports/index.json` | `failed=0` |
| 功能正确性层 | `Angelscript.Editor.DirectoryWatcher` | `Saved/Automation/AngelscriptPerformance/P6_EditorDirectoryWatcher/Reports/index.json` | `failed=0` |
| 功能正确性层 | `Angelscript.TestModule.HotReload` | `Saved/Automation/AngelscriptPerformance/P6_HotReload/Reports/index.json` | `failed=1 (BurstChurnLatency)` |
| 功能正确性层 | `Angelscript.TestModule.ScriptClass` | `Saved/Automation/AngelscriptPerformance/P6_ScriptClass/Reports/index.json` | `failed=0` |
| 功能正确性层 | `Angelscript.TestModule.FileSystem` | `Saved/Automation/AngelscriptPerformance/P6_FileSystem/Reports/index.json` | `failed=0` |
| 功能正确性层 | `Angelscript.TestModule.FileSystem.MixedSuccessFailureRecoveryAndRemap` | `Saved/Automation/AngelscriptPerformance/P5_5_MixedSuccessFailureRecovery_Rerun6/Reports/index.json` | `failed=0` |
| 真实语料层 | `Angelscript.TestModule.Angelscript.NativeScriptHotReload` | `Saved/Automation/AngelscriptPerformance/P6_NativeScriptHotReload/Reports/index.json` | `failed=0` |
| 长时压力层 | `Angelscript.TestModule.Core.Performance.Startup` | `Saved/Automation/AngelscriptPerformance/P6_PerfStartup/Reports/index.json` | `failed=0` |
| 长时压力层 | `Angelscript.TestModule.HotReload.Performance` | `Saved/Automation/AngelscriptPerformance/P6_PerfHotReload/Reports/index.json` | `failed=1 (BurstChurnLatency)` |
| 产物验证层 | `Angelscript.TestModule.Core.Performance.ArtifactGeneration` | `Saved/Automation/AngelscriptPerformance/P6_PerfArtifactGeneration/Reports/index.json` | `failed=0` |

---

## 16. Dump — 状态导出

> 源文件：`Dump/AngelscriptDumpCommand.cpp`、`Dump/AngelscriptDumpTests.cpp`
>
> 控制台命令：`as.DumpEngineState [OutputDir]`

| 测试名 | 验证内容 |
|--------|----------|
| Dump.CSVWriter.Basic | `FCSVWriter` 能写出基础 header/row，并将结果保存到磁盘 |
| Dump.CSVWriter.SpecialCharacters | `FCSVWriter` 对逗号、双引号与换行字段做正确 CSV 转义 |
| Dump.DumpAll.EndToEnd | `FAngelscriptStateDump::DumpAll()` 会生成 Phase 1-7 约定的全部 CSV 文件 |
| Dump.DumpAll.Summary | `DumpSummary.csv` 会为每张表写出状态与行数；当前 `ToStringTypes` / `HotReloadState` / `CodeCoverage` 的 `NotAvailable` / `PartialExport` / `Skipped` 属于受 public API 与编译开关约束的预期结果 |

