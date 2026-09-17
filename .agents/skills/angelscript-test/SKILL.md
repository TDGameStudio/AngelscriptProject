---
name: angelscript-test-guide
description: Use when implementing, extending, or refactoring AngelscriptProject C++ automation tests, especially CQTest, HotReload, Bindings, inline AngelScript fixtures, TEST_CLASS_WITH_FLAGS, TEST_METHOD, ASTEST_AS, FScopedAngelscriptModule, matcher assertions, test helpers, or validation commands.
---

# Angelscript Test Guide

Use this skill as the quick execution guide for writing or refactoring C++ automation tests in `AngelscriptProject`.

The reconstruction baseline hard-disables the old runtime and legacy test corpus. New tests live under `Plugins/Angelscript/Source/AngelscriptTest/{NativeEngine,Bindings,Framework,FrameworkTests,Baseline}/`. NativeEngine identities are `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`; Bindings, Framework, and Baseline keep their existing prefixes. `NewVersion` is not a source root or identity segment.

Read [references/legacy-source-isolation.md](references/legacy-source-isolation.md) before changing a `Legacy/.ubtignore` boundary, moving old test source, or diagnosing why ignored sources still enter C++ or UHT. The durable behavior is owned by `openspec/specs/angelscript/testing/baseline/spec.md`.

Read [references/test-code-database.md](references/test-code-database.md) when authoring shared versioned `.as` containers, adding generic source annotations, registering C++ source factories from another module, or consuming `FAngelscriptTestCode` queries. It covers both providers, complete-version rules, ownership and failure boundaries; the production Language example is `Language/Syntax/StructFields` with parentless `fields-two`, child `add-field`, and `StructFieldsCompileFail`. The durable behavior is owned by `openspec/specs/angelscript/testing/code-database/spec.md`.

When you need CQTest macro expansion, registration, lifecycle, matcher internals, latent commands, or engine test components, load [cqtest.md](cqtest.md). That file is the UE 5.8 engine reference. This skill owns project identity, replacement fixtures, and Harness verification. If they conflict, this file wins.

## Replacement NativeEngine CQTest Rules

- Use CQTest only as an explicitly included UE assertion and registration library under `WITH_ANGELSCRIPT_TESTS`; do not enable `WITH_ANGELSCRIPT_UNITTESTS` or inherit the legacy force include.
- Put shared replacement-only fixtures in `NativeEngine/NativeEngineTestSupport.h`. Keep them limited to locally owned inputs and observations; do not construct an ambient `asCScriptEngine`, `FAngelscriptEngine`, or legacy engine pool.
- CQTest composes `<TestDir>.<ClassName>.<MethodName>`. Use `Angelscript.UnitTest.NativeEngine.<Layer>` as `TestDir`. The C++ class token names the scenario family and must not repeat the layer; each `TEST_METHOD` is the case token.
- Include `CQTest.h` explicitly in each test translation unit. Keep scenario flow and matcher assertions in the method, and clean up method-owned state deterministically.
- After an incremental Harness editor build, run one exact `Angelscript.UnitTest.NativeEngine.<Area>` prefix with `Fast = $true`. Treat the Automation report's complete paths, counts, warnings/errors, and process exit as the public-identity oracle.

## CQTest numeric assertions (replacement and legacy)

- `AreEqual` and `AreNotEqual` reject floating-point operands with a compile-time assertion. Use `ASSERT_THAT(IsNear(Expected, Actual, Epsilon))` for approximate numeric results; choose the tolerance from the tested contract rather than merely making a failure disappear.
- When exact numeric equality is the intended contract, use `ASSERT_THAT(IsTrue(Expected == Actual))` and explain why exactness is justified. For example, literal-decoding fixtures `0.5`, `1.0`, `0.25` and `100.0` are exactly representable; they should not lose their exact-value proof just to satisfy CQTest's matcher API.
- Exact numeric equality is not bitwise identity (for example, signed zero). If the contract concerns representation, compare the explicit representation instead. Do not cast floating values to integers or suppress compiler diagnostics to bypass the matcher restriction.
- Local authority: the selected engine's `Engine/Source/Developer/CQTest/Public/Assert/NoDiscardAsserter.inl` (`AreEqual`, `AreNotEqual`, `IsNear`), checked against UE 5.8. Confirm the implementation again if the engine or assertion library changes.

The remaining CQTest guidance describes the quarantined legacy corpus. Treat its force include, `ASTEST_*`, engine lifecycle, and test organization as recovery/reference material, not as defaults for reconstruction tests.

## Legacy CQTest Rules

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

Do not recreate `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/`. New replacement tests go only under `NativeEngine/<Layer>/`, `Bindings/`, `Framework/`, `FrameworkTests/`, or `Baseline/`.

Legacy layer routing:

- `AngelscriptRuntime/Tests/`: runtime C++ unit paths without script integration.
- `AngelscriptEditor/Legacy/Tests/`: editor-only legacy behavior.
- `AngelscriptTest/Legacy/AngelScriptSDK/`: raw AngelScript SDK tests; do not include `FAngelscriptEngine`.
- `AngelscriptTest/Legacy/Bindings/`: AS-visible binding surface and API matrices.
- Other old themes remain beneath `AngelscriptTest/Legacy/` and are excluded from active source discovery.

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

Run the narrowest useful Automation prefix through Harness and record the managed run ID, pass/fail counts, and report path.

Examples:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command workspace.activate -Context $context | Out-Null
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.Baseline'
    Fast = $true
    TimeoutMs = 600000
}
```

Run a Harness build when the change can affect compilation structure, includes, unity/non-unity behavior, module dependencies, or runtime headers:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'
    Platform = 'Win64'
    Configuration = 'Development'
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    TimeoutMs = 3600000
}
```

Never mark coverage docs, tasks, or change records complete before fresh verification passes.
