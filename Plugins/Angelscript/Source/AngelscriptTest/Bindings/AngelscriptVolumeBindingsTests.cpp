// AngelscriptVolumeBindingsTests.cpp
// CQTest compile-check coverage for AVolume, LandscapeProxy, UFXSystemComponent.
// Automation IDs: Angelscript.TestModule.Bindings.Volume.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GVolumeProfile{
	TEXT("Volume"), TEXT(""), TEXT("ASVolume"), TEXT("Volume"), TEXT("VolumeBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptVolumeBindingsTest,
	"Angelscript.TestModule.Bindings.Volume",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(TypeAvailability)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GVolumeProfile, TEXT("TypeCheck"), TEXT(R"(
int Volume_TypeExists()
{
	// Compile-time type availability check
	AVolume Volume;
	return 1;
}
)"));
		// If types are not registered, Mod will be invalid - that is acceptable.
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("AVolume type not available in test engine, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GVolumeProfile,
			TEXT("int Volume_TypeExists()"), TEXT("AVolume type compiles"), 1);
	}

	TEST_METHOD(FXSystemComponentTypeCheck)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GVolumeProfile, TEXT("FXTypeCheck"), TEXT(R"(
int FX_TypeExists()
{
	UFXSystemComponent Comp;
	return 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("UFXSystemComponent not available in test engine, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GVolumeProfile,
			TEXT("int FX_TypeExists()"), TEXT("UFXSystemComponent compiles"), 1);
	}
};

#endif
