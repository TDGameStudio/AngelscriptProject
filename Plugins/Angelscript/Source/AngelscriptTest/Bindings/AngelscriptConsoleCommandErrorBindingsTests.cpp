#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "HAL/IConsoleManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleCommandMissingHandlerBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandMissingHandlerCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandErrorBindingsTests_Private
{
	FString MakeConsoleCommandName(const TCHAR* Prefix)
	{
		return FString::Printf(TEXT("Angelscript.Test.%s.%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	IConsoleCommand* FindConsoleCommand(const FString& Name)
	{
		return static_cast<IConsoleCommand*>(IConsoleManager::Get().FindConsoleObject(*Name));
	}

	void UnregisterConsoleObjectIfPresent(const FString& Name)
	{
		if (IConsoleObject* ConsoleObject = IConsoleManager::Get().FindConsoleObject(*Name))
		{
			IConsoleManager::Get().UnregisterConsoleObject(ConsoleObject, false);
		}
	}

	bool VerifyConsoleCommandMissing(FAutomationTestBase& Test, const FString& Name)
	{
		return Test.TestNull(TEXT("Console command missing-handler test should leave no registered command behind"), FindConsoleCommand(Name));
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandErrorBindingsTests_Private;

bool FAngelscriptConsoleCommandMissingHandlerBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	AddExpectedError(TEXT("Could not find global function 'MissingHandler' to bind as console command."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASConsoleCommandMissingHandlerCompat"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("int Entry() | Line 4 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	const FString CommandName = MakeConsoleCommandName(TEXT("MissingHandlerCommand"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASConsoleCommandMissingHandlerCompat"));
		UnregisterConsoleObjectIfPresent(CommandName);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleCommandMissingHandlerCompat",
		FString::Printf(TEXT(R"(
int Entry()
{
	const FConsoleCommand Command("%s", n"MissingHandler");
	return 1;
}
)"), *CommandName));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptContext* Context = Engine.CreateContext();
	if (!TestNotNull(TEXT("Console command missing-handler test should create an execution context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	const FString ExceptionString = Context->GetExceptionString() != nullptr ? ANSI_TO_TCHAR(Context->GetExceptionString()) : FString();
	Context->Release();

	const bool bPrepared = TestEqual(TEXT("Console command missing-handler test should still prepare the entry function"), PrepareResult, static_cast<int32>(asSUCCESS));
	const bool bExecutionFailedWithException = TestEqual(TEXT("Console command missing-handler test should raise a script exception during command construction"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION));
	const bool bExceptionStringMatched = TestTrue(
		TEXT("Console command missing-handler test should surface the missing-function error text in the exception string"),
		ExceptionString.Contains(TEXT("Could not find global function 'MissingHandler' to bind as console command.")));
	const bool bNotRegistered = VerifyConsoleCommandMissing(*this, CommandName);
	const bool bStillMissing = TestNull(TEXT("Console command missing-handler test should not leave a native command lookup result after the failure path"), FindConsoleCommand(CommandName));
	bPassed = bPrepared && bExecutionFailedWithException && bExceptionStringMatched && bNotRegistered && bStillMissing;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
