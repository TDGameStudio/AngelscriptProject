---
name: angelscript-test-guide
description: 在 AngelscriptProject 中实现、扩展或重构 C++ 自动化测试时使用，尤其是 CQTest、HotReload、Bindings、内联 AngelScript fixture、TEST_CLASS_WITH_FLAGS、TEST_METHOD、ASTEST_AS、FScopedAngelscriptModule、matcher 断言、测试 helper 或验证命令。
---

> 本文件是 [SKILL.md](./SKILL.md) 的中文同步版，仅供阅读参考。Agent 实际触发时读取的是 `SKILL.md`。两份文件冲突时以 `SKILL.md` 为准。

# Angelscript Test Guide

在 `AngelscriptProject` 中编写或重构 C++ 自动化测试时，使用本 skill 作为快速执行指南。

`Documents/UnitTest/UnitTest.md` 是当前单元测试结构的权威来源。任务涉及 CQTest、HotReload、Bindings、内联 AngelScript fixture、helper 抽取、断言或验证时，编辑测试前先读它。如果本 skill 与 `UnitTest.md` 冲突，以 `UnitTest.md` 为准，并更新本 skill。

相关来源：

- `Documents/UnitTest/UnitTest.md`：新增或重构 C++ 自动化测试必须遵守的结构与风格。
- `Documents/Guides/Test.md`：测试 runner 入口、CQTest 框架细节、模板和报告目录。
- `Documents/Guides/TestConventions.md`：测试层级、目录落点、命名和 Automation 前缀。
- `Documents/Rules/ASInlineFormattingRule.md`：内联 AngelScript 格式。
- `Plugins/Angelscript/Source/AngelscriptTest/Template/`：当前测试模板。

## 立即规则

- 新 CQTest 优先使用 `TEST_CLASS_WITH_FLAGS` + 场景化 `TEST_METHOD`。
- 主测试流程留在 `TEST_METHOD` 里；不要挪到文件级 `RunXxxSection()` 包装函数。
- 只被一个 CQTest class 使用的常量、窄 helper、观察结构体放在该 class 内，通常放在 `private:` 下。
- 不要为了单个 CQTest class 创建匿名 namespace。
- 不要使用文件级 CQTest 断言别名，例如 `#define TestTrue(...)` 或 `#define TestEqual(...)`。
- class 里有 `private:` helper 时，在 `BEFORE_ALL`、`AFTER_ALL`、`TEST_METHOD` 前恢复 `public:`。
- 使用 class 级 engine 生命周期：`BEFORE_ALL()` 创建引擎，`AFTER_ALL()` 重置引擎，每个 `TEST_METHOD` 只用 `ASTEST_GET_ENGINE()` 获取。
- 每个 `TEST_METHOD` 自己清理编译的 module、delegate handle、transient object、console command 和其他状态。
- 只有确实需要隔离时才用 `ASTEST_CREATE_ENGINE_FULL()`；full-engine 测试要显式 drain modules。

## CQTest 结构

推荐骨架：

```cpp
TEST_CLASS_WITH_FLAGS(FExampleTest,
	"Angelscript.TestModule.Example.Feature",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
private:
	struct FObservation
	{
		int32 Count = 0;
	};

public:
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		ASTEST_RESET_ENGINE(Engine);
	}

	TEST_METHOD(ScenarioName)
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		const FString ScriptSource = ASTEST_AS(R"AS(
			int GetValue()
			{
				return 42;
			}
			)AS");

		FScopedAngelscriptModule ModuleScope(*TestRunner, Engine, TEXT("ASExample_ScenarioName"), ScriptSource);
		ASSERT_THAT(IsTrue(ModuleScope.IsValid(), TEXT("ScenarioName module should compile")));
	}
};
```

避免：

- `TEST_METHOD(MyCase) { ASSERT_THAT(IsTrue(RunMyCase(*TestRunner, Engine))); }`
- 一个 `OptionalCompat` / `Compat` 方法串行转发多个无关 section。
- 在每个 `TEST_METHOD` 里调用 `ASTEST_CREATE_ENGINE()`。
- 在每个 `TEST_METHOD` 的 `ON_SCOPE_EXIT` 里调用 `ASTEST_RESET_ENGINE(Engine)`。
- 忽略 `ExpectGlobalInts`、`Execute...` 或 helper 返回值。

## Bindings 组织

Bindings/CQTest 矩阵按场景拆到同一个 test class 下的多个 `TEST_METHOD`：

- baseline 或 compatibility 行为
- type matrix
- API entry-point coverage
- null、boundary、exception 路径
- return-type 或 diagnostic 路径

`FScopedAngelscriptModule` 在对应 `TEST_METHOD` 内创建。module name 要与场景对应，例如 `ASOptional_TypeMatrix`。

文件级 native bind 注册对象，例如 `AS_FORCE_LINK const FAngelscriptBinds::FBind ...`，可以保留在文件作用域，因为它们必须在 bind 初始化期注册。测试流程、fixture 和断言仍放在 CQTest class 内。

## 内联 AngelScript Fixture

- 内联 AngelScript 源码用 `ASTEST_AS(R"AS(... )AS")` 包裹。
- 只有 ASSDK/raw SDK 需要 `const char*` 或 `std::string` 时才用 `ASTEST_AS_ANSI(...)`。
- 测试专用 AS 源码优先作为局部变量放在使用它的 `TEST_METHOD` 内。
- 一个测试有多个源码片段时使用场景名：`ReloadV1Source`、`ReloadV2Source`、`DelegateSignatureV1Source`、`DelegateSignatureV2Source`。
- `ScriptSource` 只适合一个方法里只有一段明显 AS fixture 的情况。
- AS 代码保持 Allman brace、空行和缩进可读。
- AS raw string 内容和 closing delimiter 都不要从 column 0 开始。
- 避免 `static FString GetXxxScriptV1()` / `GetXxxScriptV2()`，除非多个方法共享稳定的大 fixture，或参数化生成确实更清楚。

## 断言和 Helper

新增或重构 CQTest 主流程优先使用 matcher 断言：

- `ASSERT_THAT(AreEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(AreNotEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(IsTrue(Value, TEXT("...")))`
- `ASSERT_THAT(IsFalse(Value, TEXT("...")))`
- `ASSERT_THAT(IsNotNull(Value, TEXT("...")))`
- `ASSERT_THAT(IsNull(Value, TEXT("...")))`

除非维护未触碰的旧代码，否则避免在 CQTest 主流程继续使用：

- `TestRunner->TestEqual`
- `TestRunner->TestTrue`
- `TestRunner->TestFalse`
- `TestRunner->TestNotNull`
- `TestRunner->TestNull`
- `TestRunner->TestNotEqual`

规则：

- 传给需要 `FAutomationTestBase&` 的 helper 时使用 `*TestRunner`，不要传 `TestRunner`。
- helper 只隐藏噪音，不隐藏测试意图。
- 可以抽 helper：查找、转换、观察结构体、重复清理、小型 class-private 工具。
- 避免 helper 同时做 compile + reload + assert，让 `TEST_METHOD` 只剩一行。
- helper 必须返回 `bool` 时，在内部使用局部 `FNoDiscardAsserter`。

## Hot Reload 规则

HotReload 测试必须证明 reload 后的外部可观察行为，不只是编译成功：

- reload delegate 广播
- old/new reflected type 可见且不同
- generated class、struct、enum 或 delegate 仍可查询
- Blueprint child、instance、CDO 或 property 指向正确的新类型
- property、function 或 delegate signature 正确 retarget
- 场景涉及运行态时，reload 后运行行为发生预期变化

每个 `TEST_METHOD` 本地管理 module 和 delegate handle。清理要在第一个 early return 前注册：

```cpp
ON_SCOPE_EXIT
{
	Engine.GetOnDelegateReload().Remove(DelegateReloadHandle);
	Engine.DiscardModule(*ModuleName.ToString());
};
```

AS `USTRUCT` delegate 或 `UFUNCTION` 参数 bug 要优先写 focused regression。这类测试必须执行参数传递路径，而不是只编译元数据：

- 创建 AS `USTRUCT`
- 在 delegate 或 `UFUNCTION` 中使用它
- 绑定或调用真实 receiver
- 执行路径
- 断言字段值真实跨过边界

做 delegate hot reload 时，区分 delegate 声明和使用该 delegate 类型的 `UPROPERTY` 成员。只有场景包含 delegate property 时，才测试 property retarget。

## 层级和落点

权威层级矩阵看 `Documents/Guides/TestConventions.md`。快速路由：

- `AngelscriptRuntime/Tests/`：不需要脚本集成的 runtime C++ unit 路径。
- `AngelscriptEditor/Tests/`：editor-only 行为。
- `AngelscriptTest/AngelScriptSDK/`：raw AngelScript SDK 测试；不要包含 `FAngelscriptEngine`。
- `AngelscriptTest/Bindings/`：AS 可见绑定表面和 API 矩阵。
- `AngelscriptTest/Syntax`、`Compiler`、`Preprocessor`、`Core`、`ClassGenerator`、`FileSystem`：不需要 world 生命周期的 runtime integration。
- `AngelscriptTest/Actor`、`Component`、`Delegate`、`GC`、`HotReload`、`Interface`、`Subsystem`：world、UObject、actor、reload 或 functional 行为。
- `AngelscriptTest/Coverage/`：覆盖矩阵收口，记录于 OpenSpec `test-coverage`（`coverage-matrix.md`）。
- `AngelscriptTest/Learning/*`：教学或 trace 型测试。

Automation 前缀要匹配现有主题和邻近文件。没有先检查 `TestConventions.md` 时，不要创造新的前缀形状。

## 常见坑

- UE 5.x 中 AS `float` 经常映射到 double-backed reflection；选 `FFloatProperty` 还是 `FDoubleProperty` 前先看邻近测试。
- 当前 fork 使用 `asEP_FLOAT_IS_FLOAT64=1`；raw context float ref 可能需要 `double`。
- AS module-level mutable globals 会被拒绝；用函数、对象或 property 传递状态。
- `W.Tick` 和 `W.TickViaManager` 不保证严格 tick 次数；精确计数断言用直接 dispatch helper。
- `Actor->Destroy()` 后 UObject 内存到 GC 前仍可读，但 weak pointer 会无效。
- `AddExpectedError` 必须在失败操作前注册。
- `FScopedAngelscriptModule` 拥有 module 清理；不要手动 discard 它管理的 module。
- 手动编译的 module 必须使用唯一名称，并在所有路径上 discard。

## 验证

修改 CQTest 或 HotReload 测试后，用 `Tools\RunTests.ps1` 跑最窄可证明的 Automation prefix，并记录 pass/fail 数字和报告路径。

示例：

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ReloadDelegates" -Label hotreload-reload-delegates -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Delegates" -Label hotreload-delegates -TimeoutMs 600000
```

如果改动可能影响编译结构、include、unity/non-unity 行为、module dependencies 或 runtime headers，再运行：

```powershell
Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000
```

不要在 fresh verification 通过前，把覆盖文档、tasks 或 change record 标成完成。
