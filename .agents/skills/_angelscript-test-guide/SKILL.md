---
name: angelscript-test-guide
description: Use when implementing or extending Angelscript automation tests in AngelscriptProject. Guides choosing the correct test layer, using the right helpers and templates, applying standard Positive/Negative/Boundary/RoundTrip/Exception patterns, and reaching meaningful coverage.
---

# Angelscript Test Guide

This skill is a pattern handbook for **writing** Angelscript automation test cases in `Plugins/Angelscript/`. It is NOT an OpenSpec lifecycle skill, NOT a test runner guide, and NOT a substitute for the legal sources below.

Legal sources (this skill must defer if they conflict):

- [Documents/Guides/TestConventions.md](../../../Documents/Guides/TestConventions.md) — layer matrix, naming rules, new-test flow.
- [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) — runner entry points, CQTest framework usage, template index.
- [Plugins/Angelscript/AGENTS.md](../../../Plugins/Angelscript/AGENTS.md) — plugin-internal test layering rules.
- [Documents/Guides/TestCatalog.md](../../../Documents/Guides/TestCatalog.md) — catalogued baseline inventory.

This skill is a cheat-sheet on top of those documents. Whenever a sentence here disagrees with them, update this skill first, then continue.

## 1. When to use / When NOT to use

USE this skill when:

- Writing a new `TEST_CLASS_WITH_FLAGS` / `IMPLEMENT_SIMPLE_AUTOMATION_TEST`.
- Adding cases under an existing themed directory (`Actor/`, `Bindings/`, `Syntax/`, `HotReload/`, ...).
- Deciding which test layer / helper / template to start from.
- Filling in coverage gaps in a table-driven way (Positive / Negative / Boundary / RoundTrip / Exception).

Do NOT use this skill for:

- Running tests → [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) + the Cursor `full-test-suite` skill.
- Designing OpenSpec changes → `openspec-work`.
- Editing test runners, build scripts, or AgentConfig → [Documents/Guides/Build.md](../../../Documents/Guides/Build.md).

## 2. Four-step writing flow

1. **Pick the layer.** Answer in order:
   1. Does this need `FAngelscriptEngine`? If not → Native Core (`AngelScriptSDK/`).
   2. Does this need real `UObject` / `World` / `Actor` lifecycle? If yes → UE Functional layer (themed directory).
   3. Is it Editor-only behavior? If yes → Editor Tests (`AngelscriptEditor/Tests/`).
   4. Otherwise → Runtime Integration (`Source/AngelscriptTest/Core` / `Bindings` / `Compiler` / `Preprocessor` / etc.).
2. **Pick the directory and theme.** Place the file where the *final observable behavior* happens, not where the helper lives. Reuse existing themed directories before inventing a new one.
3. **Pick the pattern.** See §4 "Nine standard patterns". One pattern = one core helper triplet.
4. **Pick the template.** Copy-paste a `Template_*.cpp` and rename. See §7. Do not invent a fresh skeleton from scratch.

Full step description: [TestConventions.md §"新增测试的标准流程"](../../../Documents/Guides/TestConventions.md).

## 3. Layer quick reference

Numbers and Automation prefixes are authoritative in `TestConventions.md`; this table is the short version optimized for "which directory + helper do I open".

| Layer | Code path | Automation prefix | Recommended helper | Template entry |
|---|---|---|---|---|
| Runtime CppTests | `AngelscriptRuntime/Tests/` | `Angelscript.TestModule.CppTests.*` | `StartAngelscriptHeaders.h` + runtime private headers | (no template — minimal skeleton) |
| Editor | `AngelscriptEditor/Tests/` | `Angelscript.Editor.*` | editor-only helpers | (no template — copy nearest peer) |
| Native Core | `AngelscriptTest/AngelScriptSDK/` | `Angelscript.TestModule.AngelScriptSDK.*` | [AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h) (NO `FAngelscriptEngine`) | (no template — see ASSDK peers) |
| Runtime Integration | `AngelscriptTest/Core`, `Bindings`, `Compiler`, `Preprocessor`, `ClassGenerator`, `FileSystem`, `Syntax`, ... | `Angelscript.TestModule.<Theme>.*` | [Shared/AngelscriptTestEngineHelper.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.h) + [Shared/AngelscriptTestMacros.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestMacros.h) | [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) / [Template_GlobalFunctions.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GlobalFunctions.cpp) |
| UE Functional (Actor/Component/HotReload/Subsystem/...) | `AngelscriptTest/Actor`, `Component`, `Delegate`, `GC`, `HotReload`, `Interface`, `Subsystem`, ... | `Angelscript.TestModule.<Theme>.*` | [Shared/AngelscriptTestWorld.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestWorld.h) + [Shared/AngelscriptFunctionalTestUtils.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptFunctionalTestUtils.h) + [Shared/AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h) | [Template_WorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp) / [Template_GameLifetime.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GameLifetime.cpp) / [Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp) / [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp) / [Template_ReflectionAccess.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp) |
| Bindings Coverage (CQTest) | `AngelscriptTest/Bindings/` | `Angelscript.TestModule.Bindings.<Type>.*` | `CQTest.h` + [Shared/AngelscriptBindingsCoverage.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsCoverage.h) + [Shared/AngelscriptBindingsModuleBuilder.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsModuleBuilder.h) + [Shared/AngelscriptBindingsAssertions.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsAssertions.h) | [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) |
| Learning | `AngelscriptTest/Learning/Native`, `Learning/Runtime` | `Angelscript.TestModule.Learning.<Layer>.*` | [Shared/AngelscriptLearningTrace.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h) | (no template — copy nearest peer) |

Themed-directory naming: `Angelscript.TestModule.<Theme>.*` is theme-first; do NOT prepend a redundant functional-layer segment. Examples: `Angelscript.TestModule.Actor.*`, `Angelscript.TestModule.HotReload.*`, `Angelscript.TestModule.Syntax.TypeDeclaration.*`.

## 4. Nine standard patterns

Each pattern uses the same micro-template:

```text
What     — one-line goal
When     — keyword triggers / decision criteria
Skeleton — code reference into the authoritative example
Helpers  — concrete symbols to grep / include
Pitfalls — see §6 by number
```

### Pattern A — Compile correctness (Positive / Negative / Warning)

- **What**: validate that an AS source fragment compiles, fails to compile with a specific diagnostic, or compiles with a warning.
- **When**: syntax / preprocessor / class-generator boundaries; new language rule; new diagnostic; new keyword. Themed directory: `Syntax/`, `Preprocessor/`, `Compiler/`.
- **Skeleton**: see the `Class_Positive` / `Class_Negative` pair below.

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

- **Helpers**: `SyntaxTestHelpers::AssertCompiles` / `AssertFailsWithError` / `AssertFailsToCompile` / `AssertCompilesWithWarning` in [AngelscriptSyntaxTestHelpers.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h).
- **Pitfalls**: §6.4 (module-name isolation), §6.10 (`AddExpectedError` for log-level errors). Disabled cases must carry an inline `DISABLED(#tag) — reason` comment + `#if 0` guard, as in `Class_Negative` above.

### Pattern B — Global function round-trip (C++ ↔ AS module-level global)

- **What**: compile an AS module containing a free function, call it from C++, assert return / out-ref values.
- **When**: not a `UFUNCTION`, not a member of an AS UCLASS; namespaced BP-library wrappers; module-level helpers.
- **Skeleton**:

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

- **Helpers**: `FASGlobalFunctionInvoker` in [AngelscriptGlobalFunctionInvoker.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptGlobalFunctionInvoker.h); module build via `AngelscriptTestSupport::BuildModule`.
- **Pitfalls**: §6.2 (`float` vs `double` at raw context), §6.5 (no mutable module-level globals in this fork).

### Pattern C — AS UFUNCTION reflective invoke

- **What**: spawn an AS UCLASS actor, call its `UFUNCTION` from C++, inspect arguments / return / out-ref / mutated UPROPERTYs.
- **When**: validating a single AS member function in isolation (not full lifecycle).
- **Skeleton**:

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

- **Helpers**: `FFunctionInvoker`, `VerifyByPath`, `GetStructByPath` in [AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h). Full type matrix: `Template_ReflectionAccess.cpp` Tests 3 / 5 / 6.
- **Pitfalls**: §6.1 (AS `float` is `FDoubleProperty`), §6.7 (`FInstancedStruct` boundary), AS rejects `TOptional<T>` as a UFUNCTION parameter — cover it at UPROPERTY layer instead.

### Pattern D — UPROPERTY path read / write

- **What**: read AS-declared UPROPERTYs (including nested sub-fields, array indices, map keys, set membership, `TOptional` inner) and write them back from C++ through the same path API.
- **When**: validating state after AS-side code runs; coverage matrices for property kinds; map/set/optional containers.
- **Helpers**: `VerifyByPath<TProp, T>`, `SetByPath`, `GetStructByPath<T>`, `GetEnumByPath`, `GetObjectByPath`, `GetArrayNumByPath`, `GetMapValueByPath<K, TProp, V>`, `GetMapNumByPath`, `SetContainsByPath<K>`, `GetSetNumByPath`, `GetOptionalIsSetByPath`, `GetOptionalValueByPath`, `GetOptionalStructByPath`, `GetClassByPath`, `GetTextByPath`, `GetSoftObjectPathByPath`, `GetSoftClassPathByPath`, `GetWeakObjectByPath` in [AngelscriptReflectiveAccess.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptReflectiveAccess.h).
- **Skeleton**: see `Template_ReflectionAccess.cpp` Tests 2 (`PathAccessAllTypes`), 4 (`PathAccessExtendedTypes`), 6 (`PathAccessReferenceTypes`), 8 (`PathParserLimits`).
- **Path parser contract**: `FPropertyBindingPath::FromString` only understands `Name` and `Name[int]` segments. `Map["Key"]` parses to index 0 and silently returns the first entry; double-index `Foo[0][0]` collapses to `Foo[0]`. Use `GetMapValueByPath` / `SetContainsByPath` for maps/sets — never raw bracket syntax with a string key.
- **Pitfalls**: §6.1, the silent-resolution hazard above.

### Pattern E — Actor / Component lifecycle (UE functional)

- **What**: spawn an AS Actor / `UAngelscriptComponent` in a transient world, drive `BeginPlay` / `Tick` / `EndPlay` / `Destroyed`, assert counters and ordering.
- **When**: anything bound to `World`/`Actor`/`Component` semantics; full construction-through-destruction chains; multi-actor scenes.
- **Skeleton** (minimal full lifecycle, mirroring `Template_GameLifetime.cpp`):

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

- **Three tick drivers — pick by assertion strictness**:
  - `W.Tick(Dt, N)` — `World.Tick` + manual `TActorIterator` dispatch. Weak `>= N` assertions; multi-actor / mixed component scenes.
  - `W.TickViaManager(Dt, N)` — `World.Tick` only; UE scheduler decides dispatch. Weak `>= 1` assertions; demonstrates production scheduling path.
  - `W.DispatchActorTick(Actor, Dt, N)` / `W.DispatchComponentTick(Comp, Dt, N)` — direct loop, bypasses scheduler. Strict `== N` assertions; **preferred for tick-count math**.
- **Full lifecycle**: `SpawnActorOfClass` (triggers `UserConstructionScript`) → `BeginPlay` → `Tick` × N → `DestroyAndDrain` (synchronously dispatches `EndPlay(Destroyed) + Destroyed`). See `Template_GameLifetime.cpp` for the canonical ordering check (`ConstructOrder < BeginPlayOrder < FirstTickOrder < EndPlayOrder < DestroyedOrder`).
- **Pitfalls**: §6.3 (weak vs strict tick), §6.6 (Destroy → `PendingKill` but UObject memory still readable; do not use `TWeakObjectPtr::IsValid()` as a liveness check after Destroy), §6.4 (module isolation).

### Pattern F — CQTest bindings coverage (`Bindings/`)

- **What**: type-by-type AS binding coverage with per-method case tables; one `TEST_CLASS` per AS type, many `TEST_METHOD`s per AS API group.
- **When**: covering manual `Bind_*.cpp` API surface; mixin libraries; cross-boundary `FString`/`FName`/`FVector`/...
- **Skeleton**:

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

- **Profile fields** (`FBindingsCoverageProfile`): `Theme / Variant / ModulePrefix / CasePrefix / LogCategory`. Each `FCoverageModuleScope` builds a uniquely named AS module (`ModulePrefix_CasePrefix_Section`) and `DiscardModule`s on RAII exit.
- **Assertion helpers** (in [AngelscriptBindingsAssertions.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptBindingsAssertions.h)): `ExpectGlobalInt`, `ExpectGlobalInts` (table-driven via `FExpectedGlobalInt` array), `ExpectGlobalReturnCustom<T>` (validator lambda), `ExecuteFunctionExpectingScriptException` (for AS-side exception paths).
- **Production reference**: [AngelscriptFStringBindingsTests.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringBindingsTests.cpp) — 17 `TEST_METHOD`s, 300+ tabulated cases.
- **Pitfalls**: §6.9 (`*TestRunner` not `TestRunner`), §6.10 (`AddExpectedErrorPlain` before module compile for `NegativePath`), §6.4 (each `FCoverageModuleScope` already isolates the module).

### Pattern G — Hot reload V1 → V2

- **What**: compile V1 of an AS module, create live objects / observe state, compile V2, assert soft / full reload semantics and state preservation.
- **When**: anything in [HotReload/](../../../Plugins/Angelscript/Source/AngelscriptTest/HotReload/) — class layout, property migration, function add/remove, delegate signatures, version chaining, event hooks, literal asset reload.
- **Recommended approach**: prefer `ASTEST_CREATE_ENGINE_FULL()` so V1 / V2 type tables stay isolated from the shared clone engine; use `Engine.GetActiveModules()` + `Engine.DiscardModule(...)` in an `ON_SCOPE_EXIT` to drain everything compiled during the test.
- **Existing peers** (read before authoring): `AngelscriptHotReloadTests.cpp`, `AngelscriptHotReloadPropertyTests.cpp`, `AngelscriptHotReloadVersionChainTests.cpp`, `AngelscriptHotReloadLifecycleTests.cpp` in the same directory.
- **Pitfalls**: §6.4 (multiple modules per test → multiple discards), §6.7 (AS-defined USTRUCT lifecycle is fragile across reload; avoid `FInstancedStruct` round-trips).

### Pattern H — Blueprint subclass of an AS class

- **What**: create a transient `UBlueprint` whose `ParentClass` is an AS-generated `UClass`, compile it, assert the generated class is a child of the script class.
- **When**: Blueprint inheritance / compilation regressions; child-class parameter chain validation; `BeginPlay` / `Tick` of BP children whose parent is AS.
- **Helpers** (in [Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp)): `TemplateBlueprintTest::FScopedTransientBlueprint::CreateAndCompile(Test, ParentClass, Suffix)` + `GetGeneratedClass()`; cleanup is RAII.
- **Skeleton**:

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

- **BP child + world tick**: see [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp) for the BP-actor lifecycle pattern (spawn BP child of AS class → drive through `FAngelscriptTestWorld`).
- **Pitfalls**: §6.4 (Blueprint package is `MarkAsGarbage` + `CollectGarbage` on RAII exit, but the AS module still needs its own discard), §6.6 (BP CDO outlives `Actor->Destroy()`).

### Pattern I — Debugger protocol scenarios

- **What**: stand up a production-like engine with a debug server, drive a mock client through handshake / breakpoints / stepping / variable inspection, assert protocol-level state transitions.
- **When**: anything in [Debugger/](../../../Plugins/Angelscript/Source/AngelscriptTest/Debugger/) — DAP handshake, breakpoint placement, step into / over / out, pause, evaluate, variable scope navigation.
- **Helpers**: [Shared/AngelscriptDebuggerTestSession.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.h) (session lifecycle), [Shared/AngelscriptDebuggerTestClient.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.h) (mock DAP client), [Shared/AngelscriptDebuggerScriptFixture.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.h) (script payloads), [Shared/AngelscriptDebuggerTestMonitor.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestMonitor.h) (assertion monitor).
- **Existing peers**: `AngelscriptDebuggerBreakpointTests.cpp`, `AngelscriptDebuggerSteppingTests.cpp`, `AngelscriptDebuggerSessionInfraTests.cpp`, `AngelscriptDebuggerSmokeTests.cpp`.
- **Pitfalls**: debugger tests must set `MaxPauseTimeoutSeconds` so a stuck monitor cannot hang the entire suite; long debugger waves run under `RunTestSuite -Suite Debugger`.

### Pattern J — Native / ASSDK (no `FAngelscriptEngine`)

- **What**: validate raw AngelScript SDK behavior (engine create / module add / compile / execute / shutdown) without the project's runtime layer.
- **When**: only when proving SDK contract / ASSDK adapter behavior. Most binding work belongs in Patterns C/D/F instead.
- **Helpers**: [AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h), `ASTEST_CREATE_ENGINE_NATIVE()` (raw `asIScriptEngine*`).
- **Hard rule**: do NOT include `FAngelscriptEngine` / project runtime types in `AngelScriptSDK/` files. ASSDK adapter files must carry the `ASSDK` marker in their name (e.g. `AngelscriptASSDKExecuteTests.cpp`).
- **Pitfalls**: §6.8 (no `FAngelscriptEngine`).

### Pattern K — Learning trace

- **What**: structured, observable, teaching-flavored tests that emit a trace via [AngelscriptLearningTrace.h](../../../Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h) so the test doubles as documentation.
- **When**: when the goal is to *explain* a subsystem, not just verify it (handoff, onboarding asset, regression for an example doc).
- **Layered prefixes**: `Angelscript.TestModule.Learning.Native.*` (no `FAngelscriptEngine`) vs `Angelscript.TestModule.Learning.Runtime.*` (full runtime). Pick by the same Native/Runtime split as the rest of the matrix.

## 5. Coverage methodology

Three orthogonal coverage axes — a feature is "covered" only when all three pass.

### 5.1 Line coverage (AS source lines)

- Source of truth: [AngelscriptRuntime/CodeCoverage/](../../../Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/) — per-line tracking, HTML + JSON report generator.
- Rule: every AS source file you ship under `Script/` or under a test fixture must be touched by at least one Automation case. If a branch in the AS source is dead-on-test, add a Boundary case to drive it.

### 5.2 Bindings coverage (C++ ↔ AS API surface)

- Source of truth: `FBindingsCoverageProfile` + `FCoverageModuleScope` + the `ExpectGlobal*` family. Each case keys into a per-type CSV slot.
- Rule of thumb per AS-visible API: at least one Positive (happy path), one Boundary (edge values — empty string, INT_MIN/MAX, NaN, empty container), one NegativePath (typed mismatch / out-of-range), one RoundTrip (C++ → AS → C++) when the API is reversible, one Exception (AS-side throw) when the API can throw.
- Cross-reference: the UHT pipeline emits `AS_FunctionTable_Summary.json` + `AS_FunctionTable_Entries.csv` (see [Documents/Guides/Test.md](../../../Documents/Guides/Test.md)) — when investigating "is this UFUNCTION reached as `Direct` or `Stub`?", read those, do not grep generated `AS_FunctionTable_*.cpp` shards.

### 5.3 Behavioral coverage (five-quadrant table)

Per testable feature, design cases across five quadrants, then refuse to ship until each quadrant has ≥ 1 case (or an explicit `DISABLED(#tag) — reason` comment):

| Quadrant | Question | Typical helper |
|---|---|---|
| Positive | Does the happy path produce the expected output? | `AssertCompiles`, `ExpectGlobalInt`, `VerifyByPath`, `TestEqual` |
| Negative | Does invalid input get rejected? | `AssertFailsWithError`, `AddExpectedErrorPlain` + log assertions |
| Boundary | Empty / max / min / zero / single-element values? | tabulated `ExpectGlobalInts` + edge inputs |
| RoundTrip | Does C++ → AS → C++ preserve value semantics? | `FFunctionInvoker::AddParam` + `VerifyByPath` mirror property |
| Exception | Does the AS-side throw produce the documented diagnostic? | `ExecuteFunctionExpectingScriptException` + pre-registered `AddExpectedErrorPlain` |

### 5.4 "Is this enough?" — three objective criteria

A feature is "covered enough" only when all three hold:

1. CodeCoverage report shows the AS source lines for the feature ≥ project threshold (see [TestCatalog.md](../../../Documents/Guides/TestCatalog.md)).
2. Bindings coverage CSV shows the feature's API surface has Positive + Boundary + RoundTrip cases (or a documented reason why a quadrant is N/A).
3. The five-quadrant table is filled or marked `DISABLED(#tag)` with the reason recorded inline. The disable tag must reference a known issue family (e.g. `#ue57-headless`, `#as-engine-behavior`) so a future un-disable sweep can find it.

## 6. Common pitfalls (numbered — cross-referenced from §4)

1. **AS `float` UPROPERTY is `FDoubleProperty`**. In UE 5.x, math types were migrated to double. C++ reads must use `ReadPropertyValue<FDoubleProperty>` + `double`, or `VerifyByPath<FDoubleProperty, double>`. Using `FFloatProperty` silently returns null. This applies to UFUNCTION `float` parameters and AS `float` UPROPERTYs both.
2. **`asEP_FLOAT_IS_FLOAT64=1` in this AS fork**. At the script source level `float` is an 8-byte slot. `SetArgFloat` / `GetReturnFloat` still work for the 4-byte half (consistent low half), but binding a C++ `float*` to AS `float&out` writes half the slot and corrupts subsequent args. Use `double&out` and `double*` in out-ref cases. Same rule for `float&` UFUNCTION parameters.
3. **`W.Tick` and `W.TickViaManager` do not guarantee `ReceiveTick` per frame**. In a test world the scheduler may dispatch zero or one tick to a newly registered actor. Any assertion that requires `TickCount == NumTicks` must use `W.DispatchActorTick` / `W.DispatchComponentTick`. Conversely, multi-actor scenes need `W.Tick`'s manual iteration; assert `>= N`.
4. **Module-name isolation**. Every test that compiles AS source must use a unique `FName ModuleName` and pair it with `ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };`. For CQTest, `FCoverageModuleScope` already enforces this — do NOT call `DiscardModule` manually on a scope-owned module. For `ASTEST_CREATE_ENGINE_FULL()` tests that compile many modules, drain via `Engine.GetActiveModules()` loop.
5. **AS module-level mutable globals are rejected** by this fork ("Global variable 'X' must be const. Mutable global variables are not supported."). Pass state via function parameters and return values instead. `const` module-level globals are fine.
6. **`Actor->Destroy()` synchronously fires `EndPlay(Destroyed) + Destroyed`**. The actor is then `PendingKill`. UObject memory remains valid until the next GC, so `FProperty::GetPropertyValue_InContainer` / `ReadPropertyValue` / `VerifyByPath` still work on the same pointer. But `TWeakObjectPtr::IsValid()` returns false — do NOT use it as a liveness check across `Destroy`. Use raw `AActor*` + read counters in the same statement.
7. **`FInstancedStruct` is fragile across the AS↔C++ boundary**. AS-declared USTRUCTs wrapped into `FInstancedStruct` crash inside `FASStructOps::Construct` during `BeginPlay`. C++ math structs like `FVector` are rejected because they have no `UScriptStruct` peer in the AS type table. Reference: comment block in [Template_ReflectionAccess.cpp Test 6](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp). Cover `FInstancedStruct` via AS-only helpers, not from C++ side raw `FProperty` writes.
8. **ASSDK layer forbids `FAngelscriptEngine`**. Files under `AngelScriptSDK/` and `Learning/Native/` must include only [AngelscriptNativeTestSupport.h](../../../Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeTestSupport.h) / `AngelscriptTestAdapter.h` and raw `asIScriptEngine*` APIs. Bringing in `FAngelscriptEngine` blurs the SDK/runtime boundary and breaks the layer contract.
9. **CQTest `TestRunner` is a static pointer** of type `TTestRunner<FNoDiscardAsserter>*`. Helpers that accept `FAutomationTestBase&` must be called with `*TestRunner` (dereferenced), not `TestRunner`. Common compile error: `cannot convert 'TTestRunner<...>*' to 'FAutomationTestBase&'`.
10. **`AddExpectedError` must be registered BEFORE the failing operation**, not after. The Automation framework records errors as they emit; late registration leaves Error-level log entries unmatched, which then fail the test. For AS exception cases register three patterns: (a) module name (e.g. `"ASTemplateCQ_CQTest_Negative"`), (b) function signature (e.g. `"void StringIndexOOB()"`), (c) exception message fragment (e.g. `"out of bounds"`). Use `count = 0` to match any number of occurrences.

## 7. Template quick-pick

Copy-paste a template, rename it under the destination directory, then strip / extend per the chosen pattern. Templates are teaching fixtures; they themselves run under the `Angelscript.Template.*` prefix and must not be the landing place for new functional cases.

| Template | Best for | Prefix |
|---|---|---|
| [Template_CQTest.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp) | CQTest skeleton: compile / multi-assertion / return-struct / pass-args / negative path / ASSERT_THAT short-circuit | `Angelscript.Template.CQTest.*` |
| [Template_GlobalFunctions.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GlobalFunctions.cpp) | C++ ↔ AS global function via `FASGlobalFunctionInvoker` (no `UFUNCTION`) | `Angelscript.Template.GlobalFunctions.*` |
| [Template_ReflectionAccess.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_ReflectionAccess.cpp) | UPROPERTY path read/write + UFUNCTION invoke across the full type matrix | `Angelscript.Template.Reflection.*` |
| [Template_WorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_WorldTick.cpp) | World.Tick / Actor.Tick / Component.Tick three driving paths | `Angelscript.Template.WorldTick.*` |
| [Template_GameLifetime.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_GameLifetime.cpp) | Full lifecycle: Construction → BeginPlay → Tick → EndPlay → Destroyed with ordering check | `Angelscript.Template.GameLifetime.*` |
| [Template_Blueprint.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_Blueprint.cpp) | AS-parent → transient Blueprint child compile + class hierarchy | `Angelscript.Template.Blueprint.*` |
| [Template_BlueprintWorldTick.cpp](../../../Plugins/Angelscript/Source/AngelscriptTest/Template/Template_BlueprintWorldTick.cpp) | Blueprint actor child driven through `FAngelscriptTestWorld` callbacks | `Angelscript.Template.Blueprint.*` |

## 8. File / prefix / entry self-check

Before sending the diff for review, answer YES to every question — if any answer is NO, fix it now, not in a follow-up.

- [ ] Does the file name start with `Angelscript`? ASSDK adapter files also carry the `ASSDK` marker.
- [ ] Multi-case files end in `Tests.cpp`; single-case files end in `Test.cpp`?
- [ ] Automation prefix matches the layer (`Angelscript.TestModule.CppTests.*` / `Angelscript.Editor.*` / `Angelscript.TestModule.<Theme>.*` / `Angelscript.TestModule.Learning.<Layer>.*` / `Angelscript.TestModule.AngelScriptSDK.*`)?
- [ ] Themed-directory prefixes do NOT prepend a redundant `Functional.` / `CppTests.` segment (the layer is the directory, not the prefix)?
- [ ] Every compiled AS module uses a unique `FName` and is discarded on scope exit (or owned by `FCoverageModuleScope`)?
- [ ] Disabled cases carry `DISABLED(#tag) — reason` plus a `#if 0` guard, not a silent removal?
- [ ] The new file is added to the relevant section of [TestCatalog.md](../../../Documents/Guides/TestCatalog.md) when it lands in a catalogued area?

## 9. Relationship with OpenSpec

- This skill is **auxiliary**: it does not own a slash command and is not part of the OpenSpec lifecycle.
- `openspec-work` references this skill when executing TDD tasks: when a task says "write a test for X", read this skill IMMEDIATELY, then pick the pattern, then write the test.
- `tasks.md` verification commands still come from [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) — never duplicate `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` invocation rules into this skill.
- If a new test layer or helper class lands, update [Documents/Guides/TestConventions.md](../../../Documents/Guides/TestConventions.md) and [Documents/Guides/Test.md](../../../Documents/Guides/Test.md) first, then refresh §3, §4, §7 of this skill to match.
