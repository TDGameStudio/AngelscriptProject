---
name: angelscript-test-guide
description: Use when implementing, extending, or refactoring AngelscriptProject C++ automation tests, especially CQTest, HotReload, Bindings, inline AngelScript fixtures, TEST_CLASS_WITH_FLAGS, TEST_METHOD, ASTEST_AS, FScopedAngelscriptModule, matcher assertions, test helpers, or validation commands.
---

# Angelscript Test Guide

Use this skill as the quick execution guide for writing or refactoring C++ automation tests in `AngelscriptProject`.

`Documents/UnitTest/UnitTest.md` is the current authority for unit-test structure. Read it before editing tests when the task touches CQTest, HotReload, Bindings, inline AngelScript fixtures, helper extraction, assertions, or validation. If this skill conflicts with `UnitTest.md`, follow `UnitTest.md` and update this skill.

Related sources:

- `Documents/UnitTest/UnitTest.md`: required structure and style for new or refactored C++ automation tests.
- `Documents/Guides/Test.md`: runner entry points, CQTest framework details, templates, and report layout.
- `Documents/Guides/TestConventions.md`: test layers, directory placement, naming, and Automation prefixes.
- `Documents/Rules/ASInlineFormattingRule.md`: inline AngelScript formatting.
- `Plugins/Angelscript/Source/AngelscriptTest/Template/`: current templates.

## Immediate Rules

- Prefer `TEST_CLASS_WITH_FLAGS` + scenario-specific `TEST_METHOD` for new CQTest work.
- Keep the main test flow inside `TEST_METHOD`; do not move it into file-level `RunXxxSection()` wrappers.
- Put constants, narrow helpers, and observation structs used by one CQTest class under that class, usually `private:`.
- Do not create an anonymous namespace just for one CQTest class.
- Do not use file-level CQTest assertion aliases such as `#define TestTrue(...)` or `#define TestEqual(...)`.
- Restore `public:` before `BEFORE_ALL`, `AFTER_ALL`, and `TEST_METHOD` when a class has `private:` helpers.
- Use class-level engine lifecycle: `BEFORE_ALL()` creates the engine, `AFTER_ALL()` resets it, each `TEST_METHOD` gets `ASTEST_GET_ENGINE()`.
- Each `TEST_METHOD` cleans up its own compiled modules, delegate handles, transient objects, commands, and other state.
- Use `ASTEST_CREATE_ENGINE_FULL()` only when isolation requires it; drain modules explicitly for full-engine tests.

## CQTest Shape

Preferred skeleton:

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

Avoid:

- `TEST_METHOD(MyCase) { ASSERT_THAT(IsTrue(RunMyCase(*TestRunner, Engine))); }`
- A single `OptionalCompat` / `Compat` method that dispatches unrelated sections.
- `ASTEST_CREATE_ENGINE()` inside every `TEST_METHOD`.
- `ON_SCOPE_EXIT { ASTEST_RESET_ENGINE(Engine); }` inside every `TEST_METHOD`.
- Ignoring `ExpectGlobalInts`, `Execute...`, or helper return values.

## Bindings Organization

For Bindings/CQTest matrices, split one test class into scenario-oriented `TEST_METHOD`s:

- baseline or compatibility behavior
- type matrix
- API entry-point coverage
- null, boundary, and exception paths
- return-type or diagnostic paths

Create the `FScopedAngelscriptModule` inside the relevant `TEST_METHOD`. Make the module name match the scenario, for example `ASOptional_TypeMatrix`.

File-level native bind registration objects such as `AS_FORCE_LINK const FAngelscriptBinds::FBind ...` may remain at file scope because they must register during bind initialization. Test flow, fixtures, and assertions still belong in the CQTest class.

## Inline AngelScript Fixtures

- Wrap inline AngelScript source with `ASTEST_AS(R"AS(... )AS")`.
- Use `ASTEST_AS_ANSI(...)` only for ASSDK/raw SDK paths that require `const char*` or `std::string`.
- Keep test-specific AS source as local variables inside the `TEST_METHOD`.
- Use scenario names when one test has multiple source strings: `ReloadV1Source`, `ReloadV2Source`, `DelegateSignatureV1Source`, `DelegateSignatureV2Source`.
- Use `ScriptSource` only when there is one obvious AS fixture in the method.
- Keep AS Allman braces, blank lines, and indentation readable.
- Do not place AS raw-string content or the closing delimiter at column 0.
- Avoid `static FString GetXxxScriptV1()` / `GetXxxScriptV2()` unless multiple methods share a stable large fixture or parameterized generation is genuinely clearer.

## Assertions And Helpers

Prefer matcher assertions in new or refactored CQTest main flow:

- `ASSERT_THAT(AreEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(AreNotEqual(Expected, Actual, TEXT("...")))`
- `ASSERT_THAT(IsTrue(Value, TEXT("...")))`
- `ASSERT_THAT(IsFalse(Value, TEXT("...")))`
- `ASSERT_THAT(IsNotNull(Value, TEXT("...")))`
- `ASSERT_THAT(IsNull(Value, TEXT("...")))`

Avoid old CQTest main-flow assertions unless working in untouched legacy code:

- `TestRunner->TestEqual`
- `TestRunner->TestTrue`
- `TestRunner->TestFalse`
- `TestRunner->TestNotNull`
- `TestRunner->TestNull`
- `TestRunner->TestNotEqual`

Rules:

- Pass `*TestRunner`, not `TestRunner`, to helpers expecting `FAutomationTestBase&`.
- Helper functions should hide noise, not the test intent.
- Acceptable helpers: lookup, conversion, observation structs, repeated cleanup, small class-private utilities.
- Avoid helpers that combine compile + reload + assert so the `TEST_METHOD` becomes unreadable.
- If a helper must return `bool`, use a local `FNoDiscardAsserter` inside it.

## Hot Reload Rules

HotReload tests must prove externally observable reload behavior, not just compilation:

- reload delegate broadcast
- old/new reflected types visible and distinct
- generated class, struct, enum, or delegate remains queryable
- Blueprint child, instance, CDO, or property points at the correct new type
- property, function, or delegate signature retargets correctly
- runtime behavior changes after reload where the scenario is runtime-facing

Each `TEST_METHOD` must manage modules and delegate handles locally. Register cleanup before the first early-return point:

```cpp
ON_SCOPE_EXIT
{
	Engine.GetOnDelegateReload().Remove(DelegateReloadHandle);
	Engine.DiscardModule(*ModuleName.ToString());
};
```

Use focused regression tests for AS `USTRUCT` delegate or `UFUNCTION` parameter bugs. These must execute the parameter path, not only compile metadata:

- create the AS `USTRUCT`
- use it in a delegate or `UFUNCTION`
- bind or invoke a real receiver
- execute the path
- assert field values actually crossed the boundary

For delegate hot reload, distinguish delegate declaration from `UPROPERTY` members using the delegate type. Test property retarget only when the scenario includes a delegate property.

## Layer And Placement

Use `Documents/Guides/TestConventions.md` for the authoritative layer matrix. Quick routing:

- `AngelscriptRuntime/Tests/`: runtime C++ unit paths without script integration.
- `AngelscriptEditor/Tests/`: editor-only behavior.
- `AngelscriptTest/AngelScriptSDK/`: raw AngelScript SDK tests; do not include `FAngelscriptEngine`.
- `AngelscriptTest/Bindings/`: AS-visible binding surface and API matrices.
- `AngelscriptTest/Syntax`, `Compiler`, `Preprocessor`, `Core`, `ClassGenerator`, `FileSystem`: runtime integration without world lifecycle.
- `AngelscriptTest/Actor`, `Component`, `Delegate`, `GC`, `HotReload`, `Interface`, `Subsystem`: world, UObject, actor, reload, or functional behavior.
- `AngelscriptTest/Coverage/`: coverage-matrix closure tracked in OpenSpec `test-coverage-matrix-consolidation` (`coverage-matrix.md`).
- `AngelscriptTest/Learning/*`: teaching or trace-oriented tests.

Automation prefixes should match the existing theme and nearby files. Do not invent a new prefix shape without checking `TestConventions.md`.

## Common Pitfalls

- AS `float` frequently maps to double-backed reflection in UE 5.x; inspect nearby tests before choosing `FFloatProperty` vs `FDoubleProperty`.
- This fork uses `asEP_FLOAT_IS_FLOAT64=1`; raw context float refs may require `double`.
- AS module-level mutable globals are rejected; pass state through functions, objects, or properties.
- `W.Tick` and `W.TickViaManager` do not guarantee strict tick counts; use direct dispatch helpers for exact count assertions.
- `Actor->Destroy()` leaves readable UObject memory until GC, but weak pointers become invalid.
- `AddExpectedError` must be registered before the failing operation.
- `FScopedAngelscriptModule` owns module cleanup; do not manually discard a scope-owned module.
- For manually compiled modules, use unique names and discard them on all paths.

## Verification

After changing CQTest or HotReload tests, run the narrowest useful Automation prefix through `Tools\RunTests.ps1`, then record pass/fail counts and report path.

Examples:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ReloadDelegates" -Label hotreload-reload-delegates -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Delegates" -Label hotreload-delegates -TimeoutMs 600000
```

Run `Tools\RunBuild.ps1` when the change can affect compilation structure, includes, unity/non-unity behavior, module dependencies, or runtime headers:

```powershell
Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000
```

Never mark coverage docs, tasks, or change records complete before fresh verification passes.
