// AngelscriptInstancedStructBindingsTests.cpp
// CQTest coverage for FInstancedStruct binding.
// Automation IDs: Angelscript.TestModule.Bindings.InstancedStruct.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GInstancedStructProfile{
	TEXT("InstancedStruct"), TEXT(""), TEXT("ASInstStruct"), TEXT("InstancedStruct"), TEXT("InstancedStructBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptInstancedStructBindingsTest,
	"Angelscript.TestModule.Bindings.InstancedStruct",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(DefaultConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GInstancedStructProfile, TEXT("Default"), TEXT(R"(
int InstancedStruct_DefaultInvalid()
{
	FInstancedStruct S;
	return S.IsValid() ? 0 : 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FInstancedStruct not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GInstancedStructProfile,
			TEXT("int InstancedStruct_DefaultInvalid()"),
			TEXT("Default FInstancedStruct is invalid"), 1);
	}

	TEST_METHOD(ResetClears)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GInstancedStructProfile, TEXT("Reset"), TEXT(R"(
int InstancedStruct_ResetMakesInvalid()
{
	FInstancedStruct S;
	S.Reset();
	return S.IsValid() ? 0 : 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FInstancedStruct not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GInstancedStructProfile,
			TEXT("int InstancedStruct_ResetMakesInvalid()"),
			TEXT("Reset FInstancedStruct is invalid"), 1);
	}
};

#endif
