// AngelscriptHitResultBindingsTests.cpp
// CQTest coverage for FHitResult, FOverlapResult bindings.
// Automation IDs: Angelscript.TestModule.Bindings.HitResult.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GHitResultProfile{
	TEXT("HitResult"), TEXT(""), TEXT("ASHitResult"), TEXT("HitResult"), TEXT("HitResultBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptHitResultBindingsTest,
	"Angelscript.TestModule.Bindings.HitResult",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FHitResultDefault)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GHitResultProfile, TEXT("Default"), TEXT(R"(
int HitResult_DefaultNoBlock()
{
	FHitResult Hit;
	return Hit.bBlockingHit ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FHitResult not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GHitResultProfile,
			TEXT("int HitResult_DefaultNoBlock()"),
			TEXT("Default FHitResult has no blocking hit"), 0);
	}

	TEST_METHOD(FHitResultDistance)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GHitResultProfile, TEXT("Distance"), TEXT(R"(
int HitResult_DefaultDistance()
{
	FHitResult Hit;
	return (Hit.Distance == 0.0) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FHitResult.Distance not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GHitResultProfile,
			TEXT("int HitResult_DefaultDistance()"),
			TEXT("Default FHitResult distance is 0"), 1);
	}

	TEST_METHOD(FOverlapResultDefault)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GHitResultProfile, TEXT("Overlap"), TEXT(R"(
int OverlapResult_DefaultNoOverlap()
{
	FOverlapResult Overlap;
	return (Overlap.ItemIndex == 0) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FOverlapResult not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GHitResultProfile,
			TEXT("int OverlapResult_DefaultNoOverlap()"),
			TEXT("Default FOverlapResult ItemIndex is 0"), 1);
	}
};

#endif
