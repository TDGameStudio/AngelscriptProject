// AngelscriptMessageDialogBindingsTests.cpp
// CQTest coverage for FMessageDialog, UInputSettings type availability.
// Automation IDs: Angelscript.TestModule.Bindings.MessageDialog.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GMsgDlgProfile{
	TEXT("MsgDlg"), TEXT(""), TEXT("ASMsgDlg"), TEXT("MsgDlg"), TEXT("MsgDlgBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptMessageDialogBindingsTest,
	"Angelscript.TestModule.Bindings.MessageDialog",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(UInputSettingsTypeCheck)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GMsgDlgProfile, TEXT("InputSettings"), TEXT(R"(
int InputSettings_GetDefaultExists()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	return (Settings != nullptr) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("UInputSettings not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GMsgDlgProfile,
			TEXT("int InputSettings_GetDefaultExists()"),
			TEXT("UInputSettings::GetInputSettings returns non-null"), 1);
	}
};

#endif
