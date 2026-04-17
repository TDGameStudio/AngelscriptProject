#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "HAL/IConsoleManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleVariableExistingIdentityBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleVariableExistingIdentityCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptConsoleVariableIdentityTests_Private
{
	FString MakeConsoleVariableIdentityName(const TCHAR* Prefix)
	{
		return FString::Printf(TEXT("Angelscript.Test.%s.%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	void UnregisterConsoleObjectIfPresent(const FString& Name)
	{
		if (IConsoleObject* ConsoleObject = IConsoleManager::Get().FindConsoleObject(*Name))
		{
			IConsoleManager::Get().UnregisterConsoleObject(ConsoleObject, false);
		}
	}

	bool VerifyConsoleVariableInt(FAutomationTestBase& Test, const FString& Name, int32 ExpectedValue)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(TEXT("Console variable identity test should find the registered int cvar"), Variable))
		{
			return false;
		}

		return Test.TestEqual(
			TEXT("Console variable identity test should preserve the updated int value in IConsoleManager"),
			Variable->GetInt(),
			ExpectedValue);
	}

	bool VerifyConsoleVariableIdentity(
		FAutomationTestBase& Test,
		const FString& Name,
		IConsoleVariable* ExpectedVariable,
		const FString& ExpectedHelp,
		const EConsoleVariableFlags ExpectedFlags)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(TEXT("Console variable identity test should find the registered cvar"), Variable))
		{
			return false;
		}

		const bool bPointerPreserved = Test.TestTrue(
			TEXT("Console variable identity test should keep the original native IConsoleVariable instance"),
			Variable == ExpectedVariable);
		const bool bHelpPreserved = Test.TestEqual(
			TEXT("Console variable identity test should preserve the original native help text"),
			FString(Variable->GetHelp()),
			ExpectedHelp);

		const uint32 SetByMaskBits = static_cast<uint32>(ECVF_SetByMask);
		const uint32 ExpectedPersistentFlags = static_cast<uint32>(ExpectedFlags) & ~SetByMaskBits;
		const uint32 CurrentPersistentFlags = static_cast<uint32>(Variable->GetFlags()) & ~SetByMaskBits;
		const bool bFlagsPreserved = Test.TestEqual(
			TEXT("Console variable identity test should preserve the original native flags outside the SetBy mask"),
			CurrentPersistentFlags,
			ExpectedPersistentFlags);

		return bPointerPreserved && bHelpPreserved && bFlagsPreserved;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptConsoleVariableIdentityTests_Private;

bool FAngelscriptConsoleVariableExistingIdentityBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString ExistingName = MakeConsoleVariableIdentityName(TEXT("ExistingIdentity"));
	IConsoleVariable* ExistingVariable = IConsoleManager::Get().RegisterConsoleVariable(
		*ExistingName,
		7,
		TEXT("Existing native cvar identity/help/flags should survive bindings test"),
		ECVF_Cheat);
	if (!TestNotNull(TEXT("Console variable identity test should pre-register a native cvar"), ExistingVariable))
	{
		return false;
	}

	const FString ExistingHelp = ExistingVariable->GetHelp();
	const EConsoleVariableFlags ExistingFlags = ExistingVariable->GetFlags();

	ON_SCOPE_EXIT
	{
		UnregisterConsoleObjectIfPresent(ExistingName);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleVariableExistingIdentityCompat",
		FString::Printf(TEXT(R"(
int Entry()
{
	FConsoleVariable ExistingVar("%s", 99, "Should not replace native cvar");
	if (ExistingVar.GetInt() != 7)
		return 10;
	ExistingVar.SetInt(21);
	if (ExistingVar.GetInt() != 21)
		return 20;
	return 1;
}
)"), *ExistingName));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	const bool bScriptPassed = TestEqual(TEXT("Console variable identity script should reuse the already-registered cvar"), Result, 1);
	const bool bNativeValuePassed = VerifyConsoleVariableInt(*this, ExistingName, 21);
	const bool bIdentityPassed = VerifyConsoleVariableIdentity(*this, ExistingName, ExistingVariable, ExistingHelp, ExistingFlags);
	const bool bCheatFlagPreserved = TestTrue(
		TEXT("Console variable identity test should preserve the native cheat flag on the reused object"),
		ExistingVariable->TestFlags(ECVF_Cheat));
	bPassed = bScriptPassed && bNativeValuePassed && bIdentityPassed && bCheatFlagPreserved;

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
