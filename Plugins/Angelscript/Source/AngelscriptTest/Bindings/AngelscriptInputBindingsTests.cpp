// AngelscriptInputBindingsTests.cpp
// CQTest coverage for FInputActionKeyMapping, FInputBindingHandle, InputEvents.
// Automation IDs: Angelscript.TestModule.Bindings.Input.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GInputProfile{
	TEXT("Input"), TEXT(""), TEXT("ASInput"), TEXT("Input"), TEXT("InputBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptInputBindingsTest,
	"Angelscript.TestModule.Bindings.Input",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FInputActionValue)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GInputProfile, TEXT("ActionValue"), TEXT(R"(
int InputActionValue_DefaultZero()
{
	FInputActionValue V;
	return V.IsNonZero() ? 0 : 1;
}
)"));
		if (!Mod.IsValid()) return;
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GInputProfile,
			TEXT("int InputActionValue_DefaultZero()"), TEXT("Default FInputActionValue is zero"), 1);
	}

	TEST_METHOD(FKeyConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GInputProfile, TEXT("Key"), TEXT(R"(
int Key_IsValid()
{
	FKey K = EKeys::SpaceBar;
	return K.IsValid() ? 1 : 0;
}
)"));
		if (!Mod.IsValid()) return;
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GInputProfile,
			TEXT("int Key_IsValid()"), TEXT("SpaceBar key is valid"), 1);
	}
};

#endif
