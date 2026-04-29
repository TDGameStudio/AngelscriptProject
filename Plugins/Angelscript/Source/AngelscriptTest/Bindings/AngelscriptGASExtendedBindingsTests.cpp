// AngelscriptGASExtendedBindingsTests.cpp
// CQTest coverage for AngelscriptGASLibrary, FGameplayAbilitySpec,
// FGameplayAttribute bindings.
// Automation IDs: Angelscript.TestModule.Bindings.GASExtended.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GGASExtProfile{
	TEXT("GASExt"), TEXT(""), TEXT("ASGASExt"), TEXT("GASExt"), TEXT("GASExtBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptGASExtendedBindingsTest,
	"Angelscript.TestModule.Bindings.GASExtended",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FGameplayAttributeDefault)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GGASExtProfile, TEXT("Attribute"), TEXT(R"(
int Attribute_DefaultInvalid()
{
	FGameplayAttribute Attr;
	return Attr.IsValid() ? 0 : 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FGameplayAttribute not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GGASExtProfile,
			TEXT("int Attribute_DefaultInvalid()"), TEXT("Default FGameplayAttribute is invalid"), 1);
	}

	TEST_METHOD(FGameplayAbilitySpecDefault)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GGASExtProfile, TEXT("AbilitySpec"), TEXT(R"(
int AbilitySpec_DefaultLevel()
{
	FGameplayAbilitySpec Spec;
	return Spec.Level;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FGameplayAbilitySpec not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GGASExtProfile,
			TEXT("int AbilitySpec_DefaultLevel()"), TEXT("Default ability spec level"), 0);
	}
};

#endif
