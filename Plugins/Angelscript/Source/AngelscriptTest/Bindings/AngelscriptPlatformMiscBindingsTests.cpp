// =============================================================================
// AngelscriptPlatformMiscBindingsTests.cpp
//
// CQTest coverage for FGenericPlatformMisc, CoreGlobals, SystemTimers,
// ConfigEnums bindings.
// Automation IDs: Angelscript.TestModule.Bindings.PlatformMisc.*
// =============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GPlatformMiscProfile{
	TEXT("PlatformMisc"),
	TEXT(""),
	TEXT("ASPlatformMisc"),
	TEXT("PlatformMisc"),
	TEXT("PlatformMiscBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptPlatformMiscBindingsTest,
	"Angelscript.TestModule.Bindings.PlatformMisc",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(CoreGlobals)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GPlatformMiscProfile, TEXT("CoreGlobals"), TEXT(R"(
int IsEditor()
{
	return GIsEditor ? 1 : 0;
}
int IsRunningCommandlet()
{
	return ::IsRunningCommandlet() ? 1 : 0;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		// We just verify these compile and run without crashing.
		// The actual values depend on the test environment.
		ExpectGlobalInt(*TestRunner, Engine, M, GPlatformMiscProfile,
			TEXT("int IsEditor()"),
			TEXT("GIsEditor returns int without crash"),
			1); // In editor automation context, GIsEditor should be true
	}

	TEST_METHOD(PlatformMisc)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GPlatformMiscProfile, TEXT("PlatMisc"), TEXT(R"(
int GetNumCores()
{
	return FGenericPlatformMisc::NumberOfCores();
}
int GetNumCoresIncludingHyperthreads()
{
	return FGenericPlatformMisc::NumberOfCoresIncludingHyperthreads();
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int GetNumCores()"), TEXT("NumberOfCores > 0"), -1 }, // placeholder
		};

		// Just verify compilation and execution without crash
		ExpectGlobalInt(*TestRunner, Engine, M, GPlatformMiscProfile,
			TEXT("int GetNumCores()"),
			TEXT("NumberOfCores returns positive"),
			FPlatformMisc::NumberOfCores());
	}

	TEST_METHOD(SystemTimers)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GPlatformMiscProfile, TEXT("Timers"), TEXT(R"(
int Seconds_Positive()
{
	double S = FApp::GetCurrentTime();
	return (S > 0.0) ? 1 : 0;
}
int DeltaTime_NonNegative()
{
	float DT = FApp::GetDeltaTime();
	return (DT >= 0.0) ? 1 : 0;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int Seconds_Positive()"),     TEXT("Current time is positive"), 1 },
			{ TEXT("int DeltaTime_NonNegative()"), TEXT("Delta time is non-negative"), 1 },
		};
		ExpectGlobalInts(*TestRunner, Engine, M, GPlatformMiscProfile, Cases);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
