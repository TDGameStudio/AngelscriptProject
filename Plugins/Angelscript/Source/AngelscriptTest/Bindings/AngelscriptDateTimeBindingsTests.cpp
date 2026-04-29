// AngelscriptDateTimeBindingsTests.cpp
// CQTest coverage for FDateTime, FTimespan bindings.
// Automation IDs: Angelscript.TestModule.Bindings.DateTime.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GDateTimeProfile{
	TEXT("DateTime"), TEXT(""), TEXT("ASDateTime"), TEXT("DateTime"), TEXT("DateTimeBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptDateTimeBindingsTest,
	"Angelscript.TestModule.Bindings.DateTime",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FDateTimeNow)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GDateTimeProfile, TEXT("Now"), TEXT(R"(
int DateTime_NowIsValid()
{
	FDateTime Now = FDateTime::Now();
	return Now.GetYear() >= 2024 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FDateTime not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GDateTimeProfile,
			TEXT("int DateTime_NowIsValid()"),
			TEXT("FDateTime::Now returns year >= 2024"), 1);
	}

	TEST_METHOD(FTimespanFromSeconds)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GDateTimeProfile, TEXT("Timespan"), TEXT(R"(
int Timespan_FromSeconds()
{
	FTimespan Span = FTimespan::FromSeconds(3600.0);
	return Span.GetHours() == 1 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FTimespan not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GDateTimeProfile,
			TEXT("int Timespan_FromSeconds()"),
			TEXT("FTimespan 3600s == 1 hour"), 1);
	}

	TEST_METHOD(FTimespanZero)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GDateTimeProfile, TEXT("Zero"), TEXT(R"(
int Timespan_ZeroIsZero()
{
	FTimespan Span = FTimespan::Zero();
	return Span.GetTotalSeconds() == 0.0 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FTimespan::Zero not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GDateTimeProfile,
			TEXT("int Timespan_ZeroIsZero()"),
			TEXT("FTimespan::Zero has zero seconds"), 1);
	}
};

#endif
