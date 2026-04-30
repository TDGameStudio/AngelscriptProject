// AngelscriptBodyInstanceBindingsTests.cpp
// CQTest coverage for FBodyInstance, FLatentActionInfo bindings.
// Automation IDs: Angelscript.TestModule.Bindings.BodyInstance.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GBodyInstProfile{
	TEXT("BodyInst"), TEXT(""), TEXT("ASBodyInst"), TEXT("BodyInst"), TEXT("BodyInstBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptBodyInstanceBindingsTest,
	"Angelscript.TestModule.Bindings.BodyInstance",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FBodyInstanceDefaults)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GBodyInstProfile, TEXT("BodyInst"), TEXT(R"(
int BodyInstance_SimulatePhysicsDefault()
{
	FBodyInstance B;
	return B.bSimulatePhysics ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FBodyInstance not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GBodyInstProfile,
			TEXT("int BodyInstance_SimulatePhysicsDefault()"),
			TEXT("Default FBodyInstance does not simulate physics"), 0);
	}

	TEST_METHOD(FLatentActionInfoDefault)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GBodyInstProfile, TEXT("Latent"), TEXT(R"(
int LatentInfo_DefaultLinkage()
{
	FLatentActionInfo Info;
	return Info.Linkage;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FLatentActionInfo not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GBodyInstProfile,
			TEXT("int LatentInfo_DefaultLinkage()"),
			TEXT("Default FLatentActionInfo linkage"), 0);
	}
};

#endif
