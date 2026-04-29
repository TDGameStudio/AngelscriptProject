// AngelscriptGuidBindingsTests.cpp
// CQTest coverage for FGuid, FRandomStream bindings.
// Automation IDs: Angelscript.TestModule.Bindings.Guid.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GGuidProfile{
	TEXT("Guid"), TEXT(""), TEXT("ASGuid"), TEXT("Guid"), TEXT("GuidBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptGuidBindingsTest,
	"Angelscript.TestModule.Bindings.Guid",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FGuidNewGuidIsValid)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GGuidProfile, TEXT("NewGuid"), TEXT(R"(
int Guid_NewGuidIsValid()
{
	FGuid G = FGuid::NewGuid();
	return G.IsValid() ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FGuid not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GGuidProfile,
			TEXT("int Guid_NewGuidIsValid()"),
			TEXT("FGuid::NewGuid is valid"), 1);
	}

	TEST_METHOD(FGuidDefaultInvalid)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GGuidProfile, TEXT("Default"), TEXT(R"(
int Guid_DefaultInvalid()
{
	FGuid G;
	return G.IsValid() ? 0 : 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FGuid not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GGuidProfile,
			TEXT("int Guid_DefaultInvalid()"),
			TEXT("Default FGuid is invalid"), 1);
	}

	TEST_METHOD(FRandomStreamSeed)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GGuidProfile, TEXT("Random"), TEXT(R"(
int RandomStream_Deterministic()
{
	FRandomStream Stream1 = FRandomStream(42);
	FRandomStream Stream2 = FRandomStream(42);
	float V1 = Stream1.FRand();
	float V2 = Stream2.FRand();
	return (V1 == V2) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FRandomStream not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GGuidProfile,
			TEXT("int RandomStream_Deterministic()"),
			TEXT("Same seed produces same value"), 1);
	}
};

#endif
