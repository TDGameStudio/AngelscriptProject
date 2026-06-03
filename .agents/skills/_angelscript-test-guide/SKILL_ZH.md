---
name: angelscript-test-guide
description: 在 AngelscriptProject 中实现或扩展 Angelscript 自动化测试时使用。指导如何选择测试层级、选用正确的 helper 与模板、套用 Positive/Negative/Boundary/RoundTrip/Exception 五象限范式，并达到有意义的覆盖率。
---

> 本文件是 [SKILL.md](./SKILL.md) 的中文同步版，仅供阅读参考。Agent 实际触发时读取的是 `SKILL.md`。两份文件冲突时以 `SKILL.md` 为准。

# Angelscript Test Guide

本 skill 是为 `Plugins/Angelscript/` 下**编写**自动化测试用例服务的「范式手册」。

法定来源（与本 skill 冲突时必须以它们为准）：

- [Documents/Guides/TestConventions.md](../../../Documents/Guides/TestConventions.md) —— 层级矩阵、命名规则、新增测试流程。
- [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) —— runner 入口、CQTest 框架用法、模板索引。
- [Plugins/Angelscript/AGENTS.md](../../../Plugins/Angelscript/AGENTS.md) —— 插件内部的测试分层规则。
- [Documents/Guides/TestCatalog.md](../../../Documents/Guides/TestCatalog.md) —— 已编目的基线清单。

本 skill 是建立在上述文档之上的 cheat-sheet。任何一处与法定来源矛盾，先更新本 skill，再继续。

## 1. 何时使用 / 何时不使用

**使用本 skill 当：**

- 新写一个 `TEST_CLASS_WITH_FLAGS` / `IMPLEMENT_SIMPLE_AUTOMATION_TEST`。
- 在已有主题目录下追加 case（`Actor/`、`Bindings/`、`Syntax/`、`HotReload/` 等）。
- 决定从哪个测试层级 / helper / 模板起步。
- 按表格法补齐覆盖率缺口（Positive / Negative / Boundary / RoundTrip / Exception）。

**不要用本 skill 做：**

- 跑测试 → [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) + Cursor 的 `full-test-suite` skill。
- 设计 OpenSpec 变更 → `openspec-work`。
- 修改测试 runner、构建脚本或 AgentConfig → [Documents/Guides/Build.md](../../../Documents/Guides/Build.md)。

## 2. 四步编写流程

1. **定层级。** 按顺序回答：
   1. 需要 `FAngelscriptEngine` 吗？不需要 → Native Core（`AngelScriptSDK/`）。
   2. 需要真实的 `UObject` / `World` / `Actor` 生命周期吗？需要 → UE 功能层（主题目录）。
   3. 是否仅 Editor 行为？是 → Editor Tests（`AngelscriptEditor/Tests/`）。
   4. 否则 → Runtime 集成（`Source/AngelscriptTest/Core` / `Bindings` / `Compiler` / `Preprocessor` / ...）。
2. **定目录与主题。** 把文件落在**最终可观测行为发生的地方**，而不是 helper 所在的地方。先复用已有主题目录，不要随便造新目录。
3. **定范式。** 见 §4「九大标准范式」。一种范式 = 一组核心 helper 三件套。
4. **选模板。** 复制粘贴一个 `Template_*.cpp` 后改名。见 §7。**不要**从零拼骨架。

完整步骤描述参见：[TestConventions.md §"新增测试的标准流程"](../../../Documents/Guides/TestConventions.md)。

## 3. 测试层级速查

具体数字与 Automation 前缀以 `TestConventions.md` 为准；本表是"我该打开哪个目录 + 哪个 helper"的精简版。

| 层级 | 代码路径 | Automation 前缀 | 推荐 helper | 起点模板 |
|---|---|---|---|---|
| Runtime CppTests | `AngelscriptRuntime/Tests/` | `Angelscript.TestModule.CppTests.*` | `StartAngelscriptHeaders.h` + runtime 私有头 | （无模板 —— 最小骨架） |
| Editor | `AngelscriptEditor/Tests/` | `Angelscript.Editor.*` | editor-only helper | （无模板 —— 复制邻近同类） |
| Native Core | `AngelscriptTest/AngelScriptSDK/` | `Angelscript.TestModule.AngelScriptSDK.*` | [AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h)（**禁止引入** `FAngelscriptEngine`） | （无模板 —— 参考 ASSDK 邻居） |
| Runtime 集成 | `AngelscriptTest/Core`、`Bindings`、`Compiler`、`Preprocessor`、`ClassGenerator`、`FileSystem`、`Syntax`、... | `Angelscript.TestModule.<Theme>.*` | [Shared/AngelscriptTestEngineHelper.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h) + [Shared/AngelscriptTestMacros.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestMacros.h) | [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) / [Template_GlobalFunctions.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GlobalFunctions.cpp) |
| UE 功能层（Actor/Component/HotReload/Subsystem/...） | `AngelscriptTest/Actor`、`Component`、`Delegate`、`GC`、`HotReload`、`Interface`、`Subsystem`、... | `Angelscript.TestModule.<Theme>.*` | [Shared/AngelscriptTestWorld.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestWorld.h) + [Shared/AngelscriptFunctionalTestUtils.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptFunctionalTestUtils.h) + [Shared/AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h) | [Template_WorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp) / [Template_GameLifetime.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GameLifetime.cpp) / [Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp) / [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp) / [Template_ReflectionAccess.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp) |
| Bindings 覆盖（CQTest） | `AngelscriptTest/Bindings/` | `Angelscript.TestModule.Bindings.<Type>.*` | `CQTest.h` + [Shared/AngelscriptBindingsCoverage.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsCoverage.h) + [Shared/AngelscriptBindingsModuleBuilder.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsModuleBuilder.h) + [Shared/AngelscriptBindingsAssertions.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsAssertions.h) | [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) |
| Learning | `AngelscriptTest/Learning/Native`、`Learning/Runtime` | `Angelscript.TestModule.Learning.<Layer>.*` | [Shared/AngelscriptLearningTrace.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h) | （无模板 —— 复制邻近同类） |

主题目录命名：`Angelscript.TestModule.<Theme>.*` 是**主题优先**；不要再前缀重复的"功能层"段。例：`Angelscript.TestModule.Actor.*`、`Angelscript.TestModule.HotReload.*`、`Angelscript.TestModule.Syntax.TypeDeclaration.*`。

## 4. 九大标准范式

每个范式使用统一的微模板：

```text
What     —— 一句话目标
When     —— 关键字触发 / 决策准则
Skeleton —— 指向权威示例的代码引用
Helpers  —— 可 grep / include 的具体符号
Pitfalls —— 按编号回指 §6
```

### 范式 A —— 编译正确性（Positive / Negative / Warning）

- **What**：验证一段 AS 源代码编译通过、按预期诊断失败，或带特定 warning 通过。
- **When**：语法 / 预处理器 / class-generator 边界；新增语言规则；新增诊断；新增关键字。主题目录：`Syntax/`、`Preprocessor/`、`Compiler/`。
- **Skeleton**：参见下面 `Class_Positive` / `Class_Negative` 这对示例。

```54:171:Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTypeDeclarationTests.cpp
	TEST_METHOD(Class_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ClassP_Basic"),
			TEXT(R"(
class AClassBasicActor : AActor { }
)"),
			TEXT("Basic class"));
		// ... more positive cases ...
	}

	TEST_METHOD(Class_Negative)
	{
		// ... negative cases via AssertFailsToCompile / AssertFailsWithError ...
	}
```

- **Helpers**：[AngelscriptSyntaxTestHelpers.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h) 中的 `SyntaxTestHelpers::AssertCompiles` / `AssertFailsWithError` / `AssertFailsToCompile` / `AssertCompilesWithWarning`。
- **Pitfalls**：§6.4（模块名隔离）、§6.10（`AddExpectedError` 用于 log 级 Error）。Disabled case 必须带上 inline `DISABLED(#tag) —— reason` 注释 + `#if 0` 守卫，参考上面的 `Class_Negative`。

### 范式 B —— 全局函数 round-trip（C++ ↔ AS 模块级全局）

- **What**：编译一个含自由函数的 AS 模块，从 C++ 调用，断言返回值 / out-ref。
- **When**：不是 `UFUNCTION`，不是 AS UCLASS 成员；命名空间化的 BP-library wrapper；模块级 helper。
- **Skeleton**：

```105:130:Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GlobalFunctions.cpp
	// Void global — no args, no return. Demonstrates the Call()-only path.
	{
		FASGlobalFunctionInvoker Invoker(*this, Engine, *Module, TEXT("void Trigger()"));
		if (!Invoker.IsValid() || !Invoker.Call())
		{
			return false;
		}
	}

	// Int-returning global — two args.
	{
		FASGlobalFunctionInvoker Invoker(*this, Engine, *Module, TEXT("int Sum(int, int)"));
		Invoker.AddArg(static_cast<int32>(17)).AddArg(static_cast<int32>(25));
		const int32 Result = Invoker.CallAndReturn<int32>(/*Fallback=*/INDEX_NONE);
		TestEqual(TEXT("Sum(17, 25) should return 42"), Result, 42);
	}
```

- **Helpers**：[AngelscriptGlobalFunctionInvoker.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptGlobalFunctionInvoker.h) 中的 `FASGlobalFunctionInvoker`；模块编译走 `AngelscriptTestSupport::BuildModule`。
- **Pitfalls**：§6.2（raw context 下 `float` 与 `double`）、§6.5（本 fork 禁止可变模块级 global）。

### 范式 C —— AS UFUNCTION 反射调用

- **What**：spawn 一个 AS UCLASS actor，从 C++ 调它的 `UFUNCTION`，检查入参 / 返回 / out-ref / 被改写的 UPROPERTY。
- **When**：单独验证某个 AS 成员函数（非完整生命周期）。
- **Skeleton**：

```197:218:Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp
	// Approach B - FindFunction + invoke via the typed invoker.
	// Note: AS `float` parameters are reflected as FDoubleProperty.
	{
		FFunctionInvoker Invoker(*this, Actor, FName(TEXT("ApplyDamage")));
		if (!Invoker.IsValid())
		{
			return false;
		}
		Invoker.AddParam<double>(25.0);
		Invoker.AddParam<int32>(1);
		const int32 RemainingHealth = Invoker.CallAndReturn<int32>(/*Fallback=*/INDEX_NONE);
		TestEqual(TEXT("UFUNCTION return value should equal post-call Health"), RemainingHealth, 100 - 50);
	}

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("Health"), 50,
		TEXT("Health should reflect damage applied by the AS UFUNCTION"));
```

- **Helpers**：[AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h) 中的 `FFunctionInvoker`、`VerifyByPath`、`GetStructByPath`。完整类型矩阵：`Template_ReflectionAccess.cpp` 的 Test 3 / 5 / 6。
- **Pitfalls**：§6.1（AS `float` 是 `FDoubleProperty`）、§6.7（`FInstancedStruct` 边界），且 AS 拒绝 `TOptional<T>` 作为 UFUNCTION 参数 —— 转到 UPROPERTY 层覆盖。

### 范式 D —— UPROPERTY 路径读写

- **What**：读 AS 声明的 UPROPERTY（含嵌套子字段、数组索引、map 键、set 成员、`TOptional` 内层），并通过同一组 path API 从 C++ 写回去。
- **When**：AS 端代码跑完后的状态验证；按属性种类做覆盖矩阵；map / set / optional 容器。
- **Helpers**：[AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h) 中的 `VerifyByPath<TProp, T>`、`SetByPath`、`GetStructByPath<T>`、`GetEnumByPath`、`GetObjectByPath`、`GetArrayNumByPath`、`GetMapValueByPath<K, TProp, V>`、`GetMapNumByPath`、`SetContainsByPath<K>`、`GetSetNumByPath`、`GetOptionalIsSetByPath`、`GetOptionalValueByPath`、`GetOptionalStructByPath`、`GetClassByPath`、`GetTextByPath`、`GetSoftObjectPathByPath`、`GetSoftClassPathByPath`、`GetWeakObjectByPath`。
- **Skeleton**：参见 `Template_ReflectionAccess.cpp` 的 Test 2（`PathAccessAllTypes`）、Test 4（`PathAccessExtendedTypes`）、Test 6（`PathAccessReferenceTypes`）、Test 8（`PathParserLimits`）。
- **路径解析器契约**：`FPropertyBindingPath::FromString` 只认识 `Name` 和 `Name[int]` 两类段。`Map["Key"]` 会被解析成 index 0 并静默返回第一项；`Foo[0][0]` 这种双重索引会塌缩成 `Foo[0]`。Map/Set 请用 `GetMapValueByPath` / `SetContainsByPath`，**绝不要**用带字符串键的裸方括号语法。
- **Pitfalls**：§6.1，以及上文的"静默解析"陷阱。

### 范式 E —— Actor / Component 生命周期（UE 功能层）

- **What**：在临时 world 中 spawn 一个 AS Actor / `UAngelscriptComponent`，驱动 `BeginPlay` / `Tick` / `EndPlay` / `Destroyed`，断言计数与次序。
- **When**：任何与 `World`/`Actor`/`Component` 语义绑定的测试；从构造到销毁的完整链条；多 actor 场景。
- **Skeleton**（最小完整生命周期，对齐 `Template_GameLifetime.cpp`）：

```176:194:Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp
		FAngelscriptTestWorld W(*TestRunner, Engine);
		ASSERT_THAT(IsTrue(W.IsValid()));

		AActor* Actor = W.SpawnActorOfClass(ScriptClass);
		ASSERT_THAT(IsNotNull(Actor));

		EnableActorTick(*Actor);
		W.BeginPlay(*Actor);
		W.TickViaManager(TemplateWorldTickTest::DefaultDeltaTime, 3);

		int32 BeginPlayCount = 0;
		int32 TickCount = 0;
		ASSERT_THAT(IsTrue(ReadPropertyValue<FIntProperty>(*TestRunner, Actor, TEXT("BeginPlayCount"), BeginPlayCount)));
		ASSERT_THAT(IsTrue(ReadPropertyValue<FIntProperty>(*TestRunner, Actor, TEXT("TickCount"), TickCount)));

		TestRunner->TestTrue(TEXT("[BasicTickFlow] BeginPlay should be dispatched at least once"), BeginPlayCount >= 1);
		TestRunner->TestTrue(TEXT("[BasicTickFlow] Tick should be dispatched at least once"), TickCount >= 1);
```

- **三种 tick 驱动 —— 按断言严格度选**：
  - `W.Tick(Dt, N)` —— `World.Tick` + 手动 `TActorIterator` 派发。弱断言 `>= N`；多 actor / 混合 component 场景。
  - `W.TickViaManager(Dt, N)` —— 只调 `World.Tick`；由 UE 调度器决定派发。弱断言 `>= 1`；演示生产级调度路径。
  - `W.DispatchActorTick(Actor, Dt, N)` / `W.DispatchComponentTick(Comp, Dt, N)` —— 直接循环，绕过调度器。严格 `== N`；**做 tick 计数代数运算的首选**。
- **完整生命周期**：`SpawnActorOfClass`（触发 `UserConstructionScript`）→ `BeginPlay` → `Tick` × N → `DestroyAndDrain`（同步派发 `EndPlay(Destroyed) + Destroyed`）。`Template_GameLifetime.cpp` 内有标准次序校验（`ConstructOrder < BeginPlayOrder < FirstTickOrder < EndPlayOrder < DestroyedOrder`）。
- **Pitfalls**：§6.3（弱 / 严格 tick）、§6.6（Destroy → `PendingKill` 但 UObject 内存仍可读；Destroy 之后**不要**用 `TWeakObjectPtr::IsValid()` 做存活判断）、§6.4（模块隔离）。

### 范式 F —— CQTest bindings 覆盖（`Bindings/`）

- **What**：按 AS 类型做绑定覆盖、按 method 表化 case；每个 AS 类型一个 `TEST_CLASS`，每个 API 组多个 `TEST_METHOD`。
- **When**：覆盖手写 `Bind_*.cpp` 的 API 面；mixin 库；跨边界的 `FString` / `FName` / `FVector` / ...
- **Skeleton**：

```90:135:Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptTemplateCQTest,
	"Angelscript.Template.CQTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}
	AFTER_ALL() { FAngelscriptEngine& Engine = ASTEST_GET_ENGINE(); ASTEST_RESET_ENGINE(Engine); }

	TEST_METHOD(BasicCompileAndRun)
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GTemplateProfile, TEXT("Basic"), TEXT(R"(
int GetFortyTwo()
{
	return 42;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		ExpectGlobalInt(*TestRunner, Engine, M, GTemplateProfile,
			TEXT("int GetFortyTwo()"),
			TEXT("Literal 42 round-trips through AS"),
			42);
	}
};
```

- **Profile 字段**（`FBindingsCoverageProfile`）：`Theme / Variant / ModulePrefix / CasePrefix / LogCategory`。每个 `FCoverageModuleScope` 会构造一个唯一命名（`ModulePrefix_CasePrefix_Section`）的 AS 模块，并在 RAII 退出时 `DiscardModule`。
- **断言 helper**（[AngelscriptBindingsAssertions.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsAssertions.h)）：`ExpectGlobalInt`、`ExpectGlobalInts`（表驱动，传入 `FExpectedGlobalInt` 数组）、`ExpectGlobalReturnCustom<T>`（用 lambda 校验）、`ExecuteFunctionExpectingScriptException`（用于 AS 端异常路径）。
- **产线参考**：[AngelscriptFStringBindingsTests.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringBindingsTests.cpp) —— 17 个 `TEST_METHOD`，300+ 张表化 case。
- **Pitfalls**：§6.9（要 `*TestRunner` 不是 `TestRunner`）、§6.10（NegativePath 必须在模块编译前 `AddExpectedErrorPlain`）、§6.4（`FCoverageModuleScope` 已经隔离了模块）。

### 范式 G —— 热重载 V1 → V2

- **What**：编译 V1，创建活动对象 / 观察状态，编译 V2，断言 soft / full reload 语义与状态保持。
- **When**：[HotReload/](../../../Plugins/Angelscript/Source/AngelscriptTest/HotReload/) 下所有 case —— class layout、属性迁移、函数增删、delegate 签名、版本链、事件 hook、字面资产 reload。
- **推荐做法**：优先用 `ASTEST_CREATE_ENGINE_FULL()`，让 V1 / V2 的类型表与共享 clone engine 隔离；用 `ON_SCOPE_EXIT` 里跑 `Engine.GetActiveModules()` + `Engine.DiscardModule(...)` 一次性清空测试期内编译的所有模块。
- **现有同类**（动手前先读）：同目录下 `AngelscriptHotReloadTests.cpp`、`AngelscriptHotReloadPropertyTests.cpp`、`AngelscriptHotReloadVersionChainTests.cpp`、`AngelscriptHotReloadLifecycleTests.cpp`。
- **Pitfalls**：§6.4（一个测试多个模块 → 多次 discard）、§6.7（AS 声明的 USTRUCT 在 reload 中生命周期脆弱，避免 `FInstancedStruct` 跨边界）。

### 范式 H —— AS 类的 Blueprint 子类

- **What**：用 AS 生成的 `UClass` 作 `ParentClass` 创建临时 `UBlueprint`，编译，断言其 generated class 是脚本类的子类。
- **When**：Blueprint 继承 / 编译回归；子类参数链验证；以 AS 为父的 BP 子类的 `BeginPlay` / `Tick`。
- **Helpers**（[Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp) 内）：`TemplateBlueprintTest::FScopedTransientBlueprint::CreateAndCompile(Test, ParentClass, Suffix)` + `GetGeneratedClass()`；cleanup 走 RAII。
- **Skeleton**：

```151:164:Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp
	TemplateBlueprintTest::FScopedTransientBlueprint Blueprint;
	if (!Blueprint.CreateAndCompile(*this, ScriptClass, TEXT("ScriptParentChild")))
	{
		return false;
	}

	UClass* GeneratedBlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint template should expose a generated class"), GeneratedBlueprintClass))
	{
		return false;
	}

	TestTrue(TEXT("Blueprint template should create a child blueprint from the script class"), GeneratedBlueprintClass->IsChildOf(ScriptClass));
	return true;
```

- **BP 子类 + world tick**：参见 [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp)（spawn 以 AS 为父的 BP 子类 → 通过 `FAngelscriptTestWorld` 驱动）。
- **Pitfalls**：§6.4（Blueprint package 在 RAII 退出时 `MarkAsGarbage` + `CollectGarbage`，但 AS 模块仍需自己 discard）、§6.6（BP CDO 在 `Actor->Destroy()` 之后仍存活）。

### 范式 I —— Debugger 协议场景

- **What**：拉起一个 production-like engine 与 debug server，让 mock client 走完握手 / 断点 / 步进 / 变量审查，断言协议层状态迁移。
- **When**：[Debugger/](../../../Plugins/Angelscript/Source/AngelscriptTest/Debugger/) 下所有 case —— DAP 握手、断点放置、step into / over / out、pause、evaluate、变量域导航。
- **Helpers**：[Shared/AngelscriptDebuggerTestSession.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.h)（会话生命周期）、[Shared/AngelscriptDebuggerTestClient.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.h)（mock DAP 客户端）、[Shared/AngelscriptDebuggerScriptFixture.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.h)（脚本载荷）、[Shared/AngelscriptDebuggerTestMonitor.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestMonitor.h)（断言 monitor）。
- **现有同类**：`AngelscriptDebuggerBreakpointTests.cpp`、`AngelscriptDebuggerSteppingTests.cpp`、`AngelscriptDebuggerSessionInfraTests.cpp`、`AngelscriptDebuggerSmokeTests.cpp`。
- **Pitfalls**：Debugger 测试必须设 `MaxPauseTimeoutSeconds`，防止卡死的 monitor 拖垮整个 suite；长链路 debugger 波次走 `RunTestSuite -Suite Debugger`。

### 范式 J —— Native / ASSDK（不引入 `FAngelscriptEngine`）

- **What**：验证 AngelScript SDK 原生行为（engine create / module add / compile / execute / shutdown），不经过项目运行时层。
- **When**：仅当要证明 SDK 契约 / ASSDK 适配层行为时。大多数绑定工作请走范式 C/D/F。
- **Helpers**：[AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h)、`ASTEST_CREATE_ENGINE_NATIVE()`（裸 `asIScriptEngine*`）。
- **硬规则**：`AngelScriptSDK/` 下的文件**禁止** include `FAngelscriptEngine` / 项目运行时类型。ASSDK 适配文件名必须带 `ASSDK` 标记（例：`AngelscriptASSDKExecuteTests.cpp`）。
- **Pitfalls**：§6.8（不引入 `FAngelscriptEngine`）。

### 范式 K —— Learning trace

- **What**：结构化、可观测、教学风的测试，通过 [AngelscriptLearningTrace.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h) 输出 trace，让测试本身即是文档。
- **When**：目标是**讲清楚**一个子系统而不只是验证它（交接、新人 onboarding、示例文档的回归）。
- **分层前缀**：`Angelscript.TestModule.Learning.Native.*`（不引入 `FAngelscriptEngine`）vs `Angelscript.TestModule.Learning.Runtime.*`（完整 runtime）。按矩阵中相同的 Native / Runtime 划分选。

## 5. 覆盖率方法论

三条正交的覆盖率轴 —— 一项特性"被覆盖"当且仅当三条都过。

### 5.1 行覆盖（AS 源码行）

- 真理来源：[AngelscriptRuntime/CodeCoverage/](../../../Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/) —— 逐行追踪 + HTML + JSON 报告生成器。
- 规则：你交付的每个 `Script/` 下的 AS 源文件或测试 fixture，都必须至少被一个 Automation case 触达。若有 AS 源里出现"测试到不了"的分支，加一个 Boundary case 驱过去。

### 5.2 绑定覆盖（C++ ↔ AS API 表面）

- 真理来源：`FBindingsCoverageProfile` + `FCoverageModuleScope` + `ExpectGlobal*` 系列。每个 case 落到按类型分的 CSV 槽。
- 经验规则（按 AS 可见的每个 API）：至少一个 Positive（happy path）、一个 Boundary（边界值 —— 空串、INT_MIN/MAX、NaN、空容器）、一个 NegativePath（类型不符 / 越界）、API 可逆时一个 RoundTrip（C++ → AS → C++）、API 可能 throw 时一个 Exception（AS 端抛出）。
- 交叉参考：UHT 流水线会产出 `AS_FunctionTable_Summary.json` + `AS_FunctionTable_Entries.csv`（详见 [Documents/Guides/Test.md](../../../Documents/Guides/Test.md)）—— 想查"这个 UFUNCTION 是 `Direct` 还是 `Stub` 命中"，去读这两个文件，**不要** grep 生成的 `AS_FunctionTable_*.cpp` 分片。

### 5.3 行为覆盖（五象限表）

每项可测特性按五象限设计 case，每象限 ≥ 1 个 case 之前不准发布（或带显式的 `DISABLED(#tag) —— reason` 注释）：

| 象限 | 问题 | 典型 helper |
|---|---|---|
| Positive | Happy path 产出预期了吗？ | `AssertCompiles`、`ExpectGlobalInt`、`VerifyByPath`、`TestEqual` |
| Negative | 非法输入被拒了吗？ | `AssertFailsWithError`、`AddExpectedErrorPlain` + log 断言 |
| Boundary | 空 / max / min / 零 / 单元素值？ | 表化的 `ExpectGlobalInts` + 边界输入 |
| RoundTrip | C++ → AS → C++ 保持值语义吗？ | `FFunctionInvoker::AddParam` + `VerifyByPath` 镜像属性 |
| Exception | AS 端 throw 出来的诊断符合文档吗？ | `ExecuteFunctionExpectingScriptException` + 预注册 `AddExpectedErrorPlain` |

### 5.4 "够不够" —— 三条客观判据

一项特性"覆盖足够"当且仅当三条全部成立：

1. CodeCoverage 报告显示该特性所涉 AS 源行 ≥ 项目阈值（参考 [TestCatalog.md](../../../Documents/Guides/TestCatalog.md)）。
2. Bindings coverage CSV 显示该特性 API 面有 Positive + Boundary + RoundTrip case（或者用文字记明某象限为何 N/A）。
3. 五象限表填满，或用 `DISABLED(#tag)` 加 inline 原因标记。disable tag 必须挂到一个已知问题家族（如 `#ue57-headless`、`#as-engine-behavior`），方便未来 un-disable 扫描。

## 6. 常见坑（编号 —— 被 §4 交叉引用）

1. **AS `float` UPROPERTY 反射为 `FDoubleProperty`**。UE 5.x 把数学类型迁到 double。C++ 端读取必须用 `ReadPropertyValue<FDoubleProperty>` + `double`，或 `VerifyByPath<FDoubleProperty, double>`。用 `FFloatProperty` 会静默返回 null。UFUNCTION `float` 参数与 AS `float` UPROPERTY 同理。
2. **本 AS fork 默认 `asEP_FLOAT_IS_FLOAT64=1`**。脚本源码层面的 `float` 实际是 8 字节槽。`SetArgFloat` / `GetReturnFloat` 因为只动低 4 字节仍合法，但把 C++ `float*` 绑到 AS `float&out` 会只写一半槽，污染后续参数。out-ref 一律 `double&out` 配 `double*`。UFUNCTION 的 `float&` 同理。
3. **`W.Tick` 与 `W.TickViaManager` 不保证每帧派发 `ReceiveTick`**。测试 world 中调度器对刚注册的 actor 可能派发 0 或 1 次。任何依赖 `TickCount == NumTicks` 的断言必须改用 `W.DispatchActorTick` / `W.DispatchComponentTick`。反之，多 actor 场景需要 `W.Tick` 的手动迭代；断言 `>= N`。
4. **模块名隔离**。每个会编译 AS 源的测试都必须用唯一 `FName ModuleName` 并配 `ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };`。CQTest 中 `FCoverageModuleScope` 已经替你做了 —— **不要**对被它接管的模块手动 `DiscardModule`。`ASTEST_CREATE_ENGINE_FULL()` 测试若编译多模块，用 `Engine.GetActiveModules()` 循环 drain。
5. **AS 模块级可变 global 被本 fork 拒绝**（"Global variable 'X' must be const. Mutable global variables are not supported."）。状态走参数与返回值。`const` 模块级 global 是允许的。
6. **`Actor->Destroy()` 同步派发 `EndPlay(Destroyed) + Destroyed`**。actor 随后是 `PendingKill`。UObject 内存在下次 GC 前仍有效，所以 `FProperty::GetPropertyValue_InContainer` / `ReadPropertyValue` / `VerifyByPath` 对同一指针仍然能读。但 `TWeakObjectPtr::IsValid()` 已经返回 false —— **不要**用它做 Destroy 跨界的存活检查。直接用 `AActor*` + 同语句内读计数器。
7. **`FInstancedStruct` 在 AS↔C++ 边界很脆弱**。把 AS 声明的 USTRUCT 装进 `FInstancedStruct` 会在 `BeginPlay` 期间于 `FASStructOps::Construct` 内崩。`FVector` 这类 C++ 数学结构因为在 AS 类型表里没有 `UScriptStruct` 对端，也会被拒。参考 [Template_ReflectionAccess.cpp Test 6](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp) 内的注释。`FInstancedStruct` 通过 AS-only helper 覆盖，不要从 C++ 侧裸 `FProperty` 写。
8. **ASSDK 层禁用 `FAngelscriptEngine`**。`AngelScriptSDK/` 与 `Learning/Native/` 下的文件只能 include [AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h) / `AngelscriptTestAdapter.h` 与裸 `asIScriptEngine*` API。引入 `FAngelscriptEngine` 会模糊 SDK / runtime 边界，破坏层级契约。
9. **CQTest 的 `TestRunner` 是静态指针**，类型 `TTestRunner<FNoDiscardAsserter>*`。接受 `FAutomationTestBase&` 的 helper 必须传 `*TestRunner`（解引用），不是 `TestRunner`。常见编译错误：`cannot convert 'TTestRunner<...>*' to 'FAutomationTestBase&'`。
10. **`AddExpectedError` 必须在引发错误的操作之前注册**，不能事后补。Automation framework 是实时收集错误的，迟到的注册会让 Error 级 log 失配 → 测试被判失败。AS 异常 case 至少要注册三类：(a) 模块名（如 `"ASTemplateCQ_CQTest_Negative"`）、(b) 函数签名（如 `"void StringIndexOOB()"`）、(c) 异常消息片段（如 `"out of bounds"`）。用 `count = 0` 匹配任意次数。

## 7. 模板速查

复制粘贴一个模板到目标目录后改名，再按所选范式裁剪 / 扩展。模板本身是教学夹具，跑在 `Angelscript.Template.*` 前缀下，**不**作为新增功能 case 的落点。

| 模板 | 适用场景 | 前缀 |
|---|---|---|
| [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) | CQTest 骨架：compile / 多断言 / 返回 struct / 传参 / negative path / `ASSERT_THAT` 短路 | `Angelscript.Template.CQTest.*` |
| [Template_GlobalFunctions.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GlobalFunctions.cpp) | 通过 `FASGlobalFunctionInvoker` 调 AS 全局函数（非 `UFUNCTION`） | `Angelscript.Template.GlobalFunctions.*` |
| [Template_ReflectionAccess.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp) | UPROPERTY 路径读写 + 全类型矩阵下的 UFUNCTION 调用 | `Angelscript.Template.Reflection.*` |
| [Template_WorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp) | World.Tick / Actor.Tick / Component.Tick 三种驱动路径 | `Angelscript.Template.WorldTick.*` |
| [Template_GameLifetime.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GameLifetime.cpp) | 完整生命周期：Construction → BeginPlay → Tick → EndPlay → Destroyed 次序校验 | `Angelscript.Template.GameLifetime.*` |
| [Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp) | 以 AS 为父 → 临时 Blueprint 子类编译 + 继承链 | `Angelscript.Template.Blueprint.*` |
| [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp) | Blueprint 子 actor 通过 `FAngelscriptTestWorld` 驱动回调链 | `Angelscript.Template.Blueprint.*` |

## 8. 文件名 / 前缀 / 入口自检

把 diff 提交 review 前，下面每条都要回答 YES —— 任何一条 NO，**现在**修，不要留到后续。

- [ ] 文件名以 `Angelscript` 开头？ASSDK 适配文件名带 `ASSDK` 标记？
- [ ] 多 case 文件以 `Tests.cpp` 结尾；单 case 文件以 `Test.cpp` 结尾？
- [ ] Automation 前缀与层级匹配（`Angelscript.TestModule.CppTests.*` / `Angelscript.Editor.*` / `Angelscript.TestModule.<Theme>.*` / `Angelscript.TestModule.Learning.<Layer>.*` / `Angelscript.TestModule.AngelScriptSDK.*`）？
- [ ] 主题目录前缀**没有**冗余的 `Functional.` / `CppTests.` 段（层级是目录，不是前缀）？
- [ ] 编译出的每个 AS 模块都用唯一 `FName` 且在 scope 退出时被 discard（或交给 `FCoverageModuleScope`）？
- [ ] Disabled case 带 `DISABLED(#tag) —— reason` 和 `#if 0` 守卫，**不是**静默删除？
- [ ] 文件如果落在已编目区域，已经同步加入 [TestCatalog.md](../../../Documents/Guides/TestCatalog.md) 对应小节？

## 9. 与 OpenSpec 的关系

- 本 skill 是**辅助型**：不占 slash command，不属于 OpenSpec 生命周期。
- `openspec-work` 执行 TDD 任务时会引用本 skill：任务一旦说"为 X 写测试"，立即读本 skill → 选范式 → 写测试。
- `tasks.md` 的验证命令仍以 [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) 为准 —— **不要**把 `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` 调用规则复制进本 skill。
- 一旦有新的测试层级或 helper 类落地，先更新 [Documents/Guides/TestConventions.md](../../../Documents/Guides/TestConventions.md) 与 [Documents/Guides/Test.md](../../../Documents/Guides/Test.md)，再回头对齐本 skill 的 §3、§4、§7。
