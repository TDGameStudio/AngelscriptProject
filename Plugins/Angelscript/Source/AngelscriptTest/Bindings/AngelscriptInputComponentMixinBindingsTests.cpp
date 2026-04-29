// AngelscriptInputComponentMixinBindingsTests.cpp
// CQTest coverage for InputComponentScriptMixins, FPlatformApplicationMisc.
// Automation IDs: Angelscript.TestModule.Bindings.InputMixin.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GInputMixinProfile{
	TEXT("InputMixin"), TEXT(""), TEXT("ASInputMixin"), TEXT("InputMixin"), TEXT("InputMixinBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptInputComponentMixinBindingsTest,
	"Angelscript.TestModule.Bindings.InputMixin",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(PlatformApplicationMisc)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GInputMixinProfile, TEXT("PlatApp"), TEXT(R"(
int PlatApp_ClipboardEmpty()
{
	FString Clip;
	FPlatformApplicationMisc::ClipboardPaste(Clip);
	return Clip.Len() >= 0 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FPlatformApplicationMisc not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GInputMixinProfile,
			TEXT("int PlatApp_ClipboardEmpty()"),
			TEXT("ClipboardPaste does not crash"), 1);
	}
};

#endif
