#pragma once

#include "CoreMinimal.h"
#include "AngelscriptEngine.h"
#include "Misc/AutomationTest.h"

#include "AngelscriptBindingsCoverage.h"
#include "AngelscriptBindingsModuleBuilder.h"
#include "AngelscriptBindingsAssertions.h"

/**
 * AngelscriptBindingsExampleSection — copy-paste starting point for any
 * SubPlan executor working through `Plan_BindingsTestSuiteRefactor`.
 *
 * This file is *intentionally* tiny — it exists to demonstrate the canonical
 * shape of a Coverage Section: declare the profile, wrap the AS source in a
 * `FCoverageModuleScope`, then run each case through one of the
 * `ExpectGlobal*` helpers. There is no shared state between cases — each is
 * a self-contained AS function with a deterministic int return.
 *
 * The companion file `AngelscriptBindingsExampleSectionTests.cpp` registers
 * an Automation ID that runs this section, proving the base layer end-to-end.
 *
 * Pattern executors should mirror, NOT include, this file in their own
 * SubPlan implementation. This header lives only to be read as documentation.
 */

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTestBindings
{
	/**
	 * Run the example section under the supplied profile. Returns aggregate
	 * pass/fail. The profile drives the module name and case-label prefix.
	 */
	inline bool RunBindingsExampleSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		// Each case is a no-arg `int F()` that asserts a single behavior and
		// returns 0 / 1 (or a small int). Keep the script side dumb — all
		// branching/fallback logic stays here in C++ where the assertion
		// names live.
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Example"), TEXT(R"(
int EchoZero()           { return 0; }
int EchoOne()            { return 1; }
int EchoSum()            { int A = 17; int B = 25; return A + B; }
int EchoMaxOf(int A, int B) { return A > B ? A : B; }

// Container case — exercises a real bound type to prove the basics work
// against the actual Bindings layer (and to give the example a more
// realistic shape than pure arithmetic).
int CountFruits()
{
    TArray<FString> Fruits;
    Fruits.Add("apple");
    Fruits.Add("banana");
    Fruits.Add("cherry");
    return Fruits.Num();
}
)"));
		if (!ModuleScope.IsValid())
		{
			return false;
		}
		asIScriptModule& Module = ModuleScope.GetModule();

		bool bPassed = true;
		bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int EchoZero()"), TEXT("EchoZero returns 0"), 0);
		bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int EchoOne()"), TEXT("EchoOne returns 1"), 1);
		bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int EchoSum()"), TEXT("EchoSum returns 17 + 25"), 42);
		bPassed &= ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int CountFruits()"), TEXT("CountFruits builds and counts a TArray<FString>"), 3);

		// Batched form — useful when a section has many homogeneous cases.
		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int EchoZero()"), TEXT("Batched EchoZero baseline"), 0 },
			{ TEXT("int EchoOne()"),  TEXT("Batched EchoOne baseline"),  1 },
		};
		bPassed &= ExpectGlobalInts(Test, Engine, Module, Profile, Cases);

		return bPassed;
	}
}

#endif // WITH_DEV_AUTOMATION_TESTS
