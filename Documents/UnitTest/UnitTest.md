# Angelscript 单元测试规则

本文记录 AngelscriptProject 中新增或重构 C++ 自动化测试时必须遵守的单元测试规则。更完整的测试层级、运行方式和内联 AS 代码格式分别见：

- `Documents/Guides/Test.md`
- `Documents/Guides/TestConventions.md`
- `Documents/Rules/ASInlineFormattingRule.md`
- `Plugins/Angelscript/Source/AngelscriptTest/Template/`

## CQTest 结构规则

### 1. 测试实现放在 `TEST_CLASS_WITH_FLAGS` 内

使用 CQTest 时，相关测试实现优先直接放在 `TEST_CLASS_WITH_FLAGS` 内：

- `TEST_METHOD` 直接表达测试流程。
- 只被该测试类使用的常量、窄 helper、观察结构体放在同一个测试类的 `private:` 下。
- 不要为了单个 CQTest class 创建匿名 namespace。
- 不要把主要测试流程移到类外 static 函数，再让 `TEST_METHOD` 只做一层转发。
- 不要用文件级 `#define TestTrue(...)` / `TestEqual(...)` 这类断言别名包裹 CQTest 断言。

推荐：

```cpp
TEST_CLASS_WITH_FLAGS(FExampleHotReloadTest,
	"Angelscript.TestModule.HotReload.Example",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
private:
	struct FReloadObservation
	{
		int32 PostReloadCount = 0;
	};

public:
	TEST_METHOD(BroadcastsPostReload)
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FReloadObservation Observation;
		// compile, reload, assert
	}
};
```

避免：

```cpp
namespace ExampleTest_Private
{
	static bool RunBroadcastsPostReload(FAutomationTestBase& Test);
}

TEST_METHOD(BroadcastsPostReload)
{
	ASSERT_THAT(IsTrue(ExampleTest_Private::RunBroadcastsPostReload(*TestRunner)));
}
```

### 2. CQTest class 使用类级 engine lifecycle

每个 CQTest class 应在 `BEFORE_ALL()` 创建测试引擎，在 `AFTER_ALL()` 重置测试引擎。单个 `TEST_METHOD` 内只获取已创建的引擎：

```cpp
BEFORE_ALL()
{
	ASTEST_CREATE_ENGINE();
}

AFTER_ALL()
{
	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
	ASTEST_RESET_ENGINE(Engine);
}

TEST_METHOD(MyCase)
{
	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
	FAngelscriptEngineScope Scope(Engine);
}
```

规则：

- 不要在每个 `TEST_METHOD` 中调用 `ASTEST_CREATE_ENGINE()`。
- 不要在每个 `TEST_METHOD` 的 `ON_SCOPE_EXIT` 中调用 `ASTEST_RESET_ENGINE(Engine)`。
- 每个 `TEST_METHOD` 自己清理它编译的 AS module、注册的 delegate handle、创建的 transient object。
- 如果测试确实需要独立 full engine，使用 `ASTEST_CREATE_ENGINE_FULL()`，并显式 drain 测试期间创建的 module。

### 3. CQTest hook 必须保持 public 可见

如果测试类中有 `private:` helper，必须在 CQTest hook 和 test method 前恢复 `public:`：

```cpp
private:
	static bool IsHandledReloadResult(ECompileResult Result);

public:
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

TEST_METHOD(MyCase)
{
}
```

### 4. Bindings 大矩阵按场景拆成多个 `TEST_METHOD`

Bindings/CQTest 文件里如果一个类型有多个独立覆盖面，应参考 `AngelscriptHotReloadDelegateTests.cpp` 的组织方式：一个 test class 下拆多个场景化 `TEST_METHOD`，而不是把所有 section 聚合到一个 `OptionalCompat` / `Compat` 方法里再调用一串 `RunXxxSection()`。

推荐拆分维度：

- baseline/compat 行为。
- type matrix。
- API entry-point coverage。
- null / boundary / exception 场景。
- return-type 或 log diagnostic 这类专门路径。

推荐：

```cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptOptionalBindingsTest,
	"Angelscript.TestModule.Bindings.Container.Optional",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
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

	TEST_METHOD(OptionalTypeMatrix)
	{
		FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		const FString ScriptSource = ASTEST_AS(R"AS(
			int OptBool_True_IsSet()
			{
				TOptional<bool> O(true);
				return O.IsSet() ? 1 : 0;
			}
			)AS");

		FScopedAngelscriptModule ModuleScope(*TestRunner, Engine, TEXT("ASOptional_TypeMatrix"), ScriptSource);
		ASSERT_THAT(IsTrue(ModuleScope.IsValid(), TEXT("Optional type matrix module should compile")));
		// assertions
	}
};
```

避免：

```cpp
namespace
{
	static bool RunOptionalTypeMatrixSection(FAutomationTestBase& Test, FAngelscriptEngine& Engine);
	static bool RunOptionalReturnTypeSection(FAutomationTestBase& Test, FAngelscriptEngine& Engine);
}

TEST_METHOD(OptionalCompat)
{
	RunOptionalTypeMatrixSection(*TestRunner, Engine);
	RunOptionalReturnTypeSection(*TestRunner, Engine);
}
```

规则：

- `TEST_METHOD` 名称必须说明场景，避免所有覆盖挂在一个 `Compat` 方法下。
- `FScopedAngelscriptModule` 应在对应 `TEST_METHOD` 内创建，module name 与场景名对应。
- `ExpectGlobalInts` / `Execute...` 的返回值必须被 `ASSERT_THAT(IsTrue(...))` 或同等级断言消费，不要只调用后忽略返回值。
- 允许保留文件级 native bind 注册对象，例如 `AS_FORCE_LINK const FAngelscriptBinds::FBind ...`，因为这类对象必须在 AS bind 初始化期注册；但测试流程、fixture 和断言仍应留在 `TEST_CLASS_WITH_FLAGS` 内。

## 内联 AS fixture 规则

### 1. 使用 `ASTEST_AS(...)`

C++ 测试中的内联 AngelScript 代码必须使用 `ASTEST_AS(R"AS(... )AS")` 包裹。ASSDK/raw SDK 需要 `const char*` 或 `std::string` 时使用 `ASTEST_AS_ANSI(...)`。

不要把视觉缩进的 raw string 直接传给编译 helper：

```cpp
const FString Source = TEXT(R"AS(
	UCLASS()
	class AMyActor : AActor
	{
	}
	)AS");
```

应写成：

```cpp
const FString Source = ASTEST_AS(R"AS(
	UCLASS()
	class AMyActor : AActor
	{
	}
	)AS");
```

### 2. AS fixture 应直接内嵌在对应 `TEST_METHOD` 中

测试专用 AS 源码优先作为局部变量放在使用它的 `TEST_METHOD` 内，而不是做成 `static FString GetXxxScriptV1()` / `GetXxxScriptV2()`：

```cpp
TEST_METHOD(BroadcastDelegateSignatureSwap)
{
	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
	FAngelscriptEngineScope Scope(Engine);

	const FString DelegateSignatureV1Source = ASTEST_AS(R"AS(
		delegate void FHotReloadSignal(int Value);

		UCLASS()
		class UHotReloadDelegateSignatureCarrier : UObject
		{
			UPROPERTY()
			FHotReloadSignal Signal;
		}
		)AS");

	// compile V1, register observers

	const FString DelegateSignatureV2Source = ASTEST_AS(R"AS(
		delegate void FHotReloadSignal(int Value, const FString& Label);

		UCLASS()
		class UHotReloadDelegateSignatureCarrier : UObject
		{
			UPROPERTY()
			FHotReloadSignal Signal;
		}
		)AS");

	// reload V2, assert
}
```

原因：

- 测试阅读路径保持在一个 `TEST_METHOD` 内。
- V1/V2 fixture 与 compile/reload/assert 的顺序一致。
- 避免 helper 名称像生产 API 一样膨胀。

例外：

- 多个 `TEST_METHOD` 共享同一大段 fixture，且共享语义稳定。
- 需要按参数生成 fixture，且生成逻辑本身比重复源码更清楚。
- helper 名称表达的是测试领域概念，而不只是 `Get...ScriptV2()`。

### 3. 多源码测试使用场景化变量名

一个测试里有多个 AS 片段时，变量名必须说明版本或场景：

- `ReloadV1Source`
- `ReloadV2Source`
- `DelegateSignatureV1Source`
- `DelegateSignatureV2Source`
- `TypeReloadV1Source`
- `TypeReloadV2Source`

避免：

- `Script1`
- `Script2`
- `Text`
- `Source`

`ScriptSource` 只适合一个测试里只有一段明显脚本源码的场景。

### 4. 保持 AS 代码格式本身可读

内联 AS 代码也要遵守 Allman brace 和空行规则：

- AS 内容和 closing delimiter 都不能从 column 0 开始。
- `UCLASS()` / `USTRUCT()` / `delegate` 代码跟随 C++ 嵌入缩进。
- `{` 独占一行。
- 多个 `UCLASS` / `USTRUCT` / 函数之间保留一个空行。
- `UPROPERTY()` + 声明之后如果还有下一个成员，保留一个空行。

## Hot Reload 测试规则

### 1. 测试应覆盖 reload 过程的外部可观察行为

HotReload 测试不要只验证“编译成功”。至少明确断言以下一种外部行为：

- reload delegate 是否广播。
- old/new class、struct、delegate、enum 是否可见且不同。
- reload 后 generated class / struct / enum / delegate 是否仍可查询。
- Blueprint 子类、实例、CDO 或 property 是否仍指向正确的新类型。
- reload 后 property、function、delegate signature 是否完成 retarget。

### 2. 每个测试方法自己管理 module 和 delegate handle

在 `TEST_METHOD` 内编译的 module 必须在同一个方法内清理：

```cpp
ON_SCOPE_EXIT
{
	Engine.GetOnDelegateReload().Remove(DelegateReloadHandle);
	Engine.DiscardModule(*ModuleName.ToString());
};
```

## AS `USTRUCT` 参数回归规则

### 1. Delegate/UFUNCTION struct 参数必须有真实执行测试

AS 定义的 `USTRUCT` 作为 delegate 或 `UFUNCTION` 参数时，不只验证编译成功或 reload 元数据。必须至少有一个真实执行测试覆盖参数传递路径，例如：

- 创建 AS `USTRUCT`。
- 定义 delegate 或 `UFUNCTION` 使用该 struct 参数。
- 绑定真实 receiver。
- 执行 delegate 或反射调用函数。
- 断言 struct 字段值真实传入并返回预期结果。

原因是这个路径会同时经过：

- `FScriptCall::PushArgument`
- UE event argument buffer
- `FFrame::StepCompiledInRef`
- `FUStructType::SetArgument`
- `UScriptStruct::InitializeStruct`
- `UASStruct` 的 CppStructOps fake-vtable 回调

只做编译测试无法覆盖 Unreal 拥有目标内存时的 struct 生命周期。

### 2. 记录过的崩溃根因

`fix-script-struct-delegate-argument-crash` 记录了一个 AS `USTRUCT` delegate 参数崩溃：

- AS 源码里的 by-value struct 参数会在 UE 反射签名中表现为 `const FStructName&`。
- 当 delegate 执行进入 `FUStructType::SetArgument` 时，会调用 `UScriptStruct::InitializeStruct` 构造 event 参数 buffer。
- UE 5.8 的 `ICppStructOps` fake-vtable 回调签名是 `Construct(void*)`、`Destruct(void*)`、`Copy(void*, const void*, int32)` 等，不会把 `ICppStructOps*` 作为第一个参数传入。
- 旧的 `FASStructOps` 回调把第一个参数声明成 `FASStructOps*`，导致 Unreal 传入的目标地址被误当成 ops 指针，后续访问崩溃。
- 相关修复使用 AS struct value header 记录 `ScriptType` / `CppStructOps`，并通过 `UASStruct::InitializeStruct` 注入第一次构造所需的 ops 上下文。

新增此类测试时，要优先写 focused regression，再让更大的 hot reload 测试复用同类参数形态。focused 用例便于先确认 runtime 生命周期，hot reload 用例再确认重载后类型迁移。

规则：

- 注册 delegate handle 后必须 remove。
- 编译 module 后必须 discard。
- 多个 module 用多个明确的 module name，或在 full engine 测试中统一 drain。
- 清理写在成功路径之前，避免中途 `return` 泄漏状态。

### 3. Delegate hot reload 要区分“声明”和“属性”

AngelScript 中 `delegate` 声明本身不是 `UPROPERTY`。可以标记为 `UPROPERTY` 的是使用该 delegate 类型的类成员：

```angelscript
delegate void FHotReloadSignal(int Value);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
```

这个成员会生成 `FDelegateProperty`，其 `SignatureFunction` 指向对应的 `UDelegateFunction`。因此 delegate signature hot reload 测试可以验证两层行为：

- `GetOnDelegateReload()` 广播 old/new `UDelegateFunction`。
- 使用该 delegate 的 `FDelegateProperty::SignatureFunction` reload 后 retarget 到新的 signature function。

如果测试目标只是 delegate reload 广播，可以不放 `UPROPERTY` 成员；如果测试目标包含属性 retarget，则必须保留。

### 4. Delegate hot reload runtime 覆盖矩阵

新增或重构 delegate hot reload 测试时，不要只验证 delegate 类型或 property 编译成功。至少按测试目标覆盖下面的运行路径：

- `UPROPERTY` delegate 成员：创建 AS 父类、创建 transient Blueprint 子类、生成 Blueprint 实例，reload 后验证 `FDelegateProperty::SignatureFunction`、property flags 和实例行为。
- 运行前后对比：先执行 V1 行为，再 reload，再执行 V2/V3 行为，断言返回值或 reflected state 变化。
- Blueprint 运行态：参考 `Template_BlueprintWorldTick.cpp` / `FAngelscriptTestWorld`，让 Blueprint child 经历 `BeginPlay` / `Tick`，在 actor 已经运行后 reload，再继续 tick 或调用函数。
- 全局函数运行态：参考 `Template_GlobalFunctions.cpp`，使用 `FAngelscriptTestExecutor::ExecuteAndGet` 调用 AS global function，覆盖 reload 前后全局函数绑定 delegate 的行为。
- property flag 切换：`NotEditable` / `EditAnywhere` / `BlueprintReadWrite` 等 specifier 会进入 property definition equivalence，比普通函数体变更更结构化；测试应走 full reload，并断言 `CPF_Edit` / `CPF_BlueprintVisible` 等实际 flag。
- 参数或签名变化：delegate 参数变化应使用 full reload，断言新的 `UDelegateFunction` 参数存在，并在 reload 后实际执行新签名路径。

注意：当前 AS property 的默认 Blueprint specifier 是 `BlueprintReadWrite`。`UPROPERTY(NotEditable)` 只关闭 `CPF_Edit` 对应的编辑能力，不会关闭 `CPF_BlueprintVisible`；如果测试要验证 Blueprint 不可见，需要显式使用对应的 Blueprint specifier 或调整默认配置，而不是只依赖 `NotEditable`。

推荐把不同 reload 语义拆开：

- V1：baseline，创建对象/Blueprint/运行态实例。
- V2：只改函数体或 delegate handler body，使用 `ECompileType::SoftReloadOnly`，验证 live actor 继续运行新行为。
- V3：改 `UPROPERTY` flags 或 reflected surface，使用 `ECompileType::FullReload`，验证 Blueprint 可重新编译并能创建新实例。
- V4：改 delegate signature 或参数形状，使用 `ECompileType::FullReload`，验证 property signature retarget 和新签名运行行为。

当前 `Plugins/Angelscript/Source/AngelscriptTest/HotReload/Delegate/AngelscriptHotReloadDelegateRuntimeTests.cpp` 覆盖内容：

| `TEST_METHOD` | 主要场景 | Reload 序列 | 运行验证 | 关键断言 |
|---|---|---|---|---|
| `BlueprintDelegatePropertyReloadsAfterInstanceRuntime` | AS 父类的 `UPROPERTY` delegate 成员，创建 transient Blueprint 子类和实例后 reload | V1 baseline → V2 body-only soft reload → V3 property flag full reload → V4 delegate signature full reload | 通过 `FFunctionInvoker` 调用 Blueprint actor 的 `RunDelegate`，分别验证旧实例和 reload 后新 Blueprint 实例 | `FDelegateProperty::SignatureFunction` retarget、`CPF_Edit` / `CPF_BlueprintVisible` 切换、Blueprint generated class 不是 `UASClass`、`BeginPlay` 不因 soft reload 重放 |
| `GlobalDelegateCallerRunsAcrossReloads` | AS global function 内局部创建 delegate、绑定 UObject receiver 后执行 | V1 baseline → V2 receiver body-only soft reload → V3 delegate/global function 参数变化 full reload | 通过 `FAngelscriptTestExecutor::ExecuteAndGet` 调用 `RunGlobal` | global function reload 前后返回值变化、新 `Bonus` 参数出现在 `UDelegateFunction` 上、签名变化后用新 receiver 执行 |
| `BlueprintDelegateWorldTickContinuesAfterSoftReload` | 参考 `Template_BlueprintWorldTick.cpp` 的真实运行态 Blueprint child，`BeginPlay` 绑定 delegate，`Tick` 中执行 delegate | V1 baseline running actor → V2 delegate handler body-only soft reload | 通过 `FAngelscriptTestWorld` 创建 world、spawn Blueprint actor、dispatch tick，reload 后继续 tick | running Blueprint actor 保持原 Blueprint class、tick count 延续、后续 tick 执行 V2 handler、`BeginPlay` 不重放 |

### 4. Blueprint 子类 hot reload 测试要包含普通 BlueprintGeneratedClass

之前的崩溃模式是 hot reload 遍历 `UBlueprintGeneratedClass` 时，普通 Blueprint generated class 不是 `UASClass`，直接使用 `Cast<UASClass>(CheckClass)` 后的空指针会崩溃。

相关测试应覆盖：

- 创建 AS class。
- 创建 transient Blueprint 子类。
- 修改 AS class 的 reflected surface，例如新增 `UPROPERTY(EditAnywhere)`。
- 执行 reload。
- 断言不会崩溃，Blueprint generated class 仍是 AS class 的子类。

测试意图不是验证 Blueprint 编译器所有行为，而是固定“普通 Blueprint 子类参与 AS hot reload 遍历时不能被当成 `UASClass`”这个边界。

## CQTest 断言和 helper 边界

### 1. 新 CQTest 优先使用 matcher 断言

新增或重构 CQTest 时，`TEST_METHOD` 主流程优先使用：

- `ASSERT_THAT(AreEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(AreNotEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(IsTrue(Value, TEXT("...")))`
- `ASSERT_THAT(IsFalse(Value, TEXT("...")))`
- `ASSERT_THAT(IsNotNull(Value, TEXT("...")))`
- `ASSERT_THAT(IsNull(Value, TEXT("...")))`

避免在新 CQTest 主流程中继续使用：

- `TestRunner->TestEqual`
- `TestRunner->TestTrue`
- `TestRunner->TestFalse`
- `TestRunner->TestNotNull`
- `TestRunner->TestNull`
- `TestRunner->TestNotEqual`

如果 helper 必须返回 `bool` 给 `ASSERT_THAT(IsTrue(...))`，可以在 helper 内创建局部 `FNoDiscardAsserter`，例如：

```cpp
static bool ExpectNotNull(FAutomationTestBase& Test, UObject* Value, const TCHAR* Message)
{
	FNoDiscardAsserter LocalAssert(Test);
	return LocalAssert.IsNotNull(Value, Message);
}
```

这类 helper 只用于消除重复噪音，不应隐藏测试主流程。

### 2. `TestRunner` 传参必须解引用

CQTest 中 `TestRunner` 是静态指针。传给需要 `FAutomationTestBase&` 的 helper 时必须使用 `*TestRunner`：

```cpp
CompileScriptModule(*TestRunner, Engine, ModuleName, Filename, Source);
```

不要传：

```cpp
CompileScriptModule(TestRunner, Engine, ModuleName, Filename, Source);
```

### 3. helper 只隐藏噪音，不隐藏测试意图

可以抽 helper 的情况：

- 纯查找或转换逻辑，例如按 enum suffix 查值。
- 观察结构体，例如 reload delegate 计数。
- 多处重复的安全清理。
- 单个测试类私有、不会跨主题复用的小函数。

不建议抽 helper 的情况：

- 把完整 `TEST_METHOD` 主流程移到类外。
- 把 V1/V2 AS fixture 移到 `Get...ScriptV1()` 这类 getter。
- helper 同时做 compile、reload、assert，导致 `TEST_METHOD` 只剩一行。

测试读者应能在 `TEST_METHOD` 里直接看到：准备 fixture、编译 V1、建立观察点、reload V2、断言结果。

## 验证规则

Angelscript C++ automation 测试默认不面向消费者注册。运行本页中的 `Tools\RunTests.ps1` 命令前，确认 `Config/DefaultAngelscriptCompileOptions.ini` 中：

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
bCompileAngelscriptUnitTests=true
```

修改该值后必须先通过 `Tools\RunBuild.ps1` 重新构建。`false` 构建仍会编译 `AngelscriptTest` 模块，但 `WITH_ANGELSCRIPT_UNITTESTS=0` 会禁用 AngelscriptTest 的 CQTest 注册和测试启动副作用；此时按 `Angelscript.TestModule.*` 前缀运行测试应报告未找到匹配测试。

修改 CQTest 或 HotReload 测试后，优先运行最窄的 Automation prefix：

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ReloadDelegates" -Label hotreload-reload-delegates -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Delegates" -Label hotreload-delegates -TimeoutMs 600000
```

如果改动影响编译结构、include、unity build 或 module dependencies，再运行：

```powershell
Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000
```

验证结果必须记录 pass/fail 数字。不要用“应该能过”替代实际运行结果。
