#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "HAL/IConsoleManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/OutputDeviceNull.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleVariableBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleVariableCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleVariableExistingBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleVariableExistingCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleCommandBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleCommandReplacementBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandReplacementCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleCommandSignatureBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandSignatureCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptConsoleBindingsTests_Private
{
	FString MakeConsoleVariableName(const TCHAR* Prefix)
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
		if (!Test.TestNotNull(TEXT("Console variable test should register the int cvar"), Variable))
		{
			return false;
		}

		return Test.TestEqual(TEXT("Console variable test should preserve the int value in IConsoleManager"), Variable->GetInt(), ExpectedValue);
	}

	bool VerifyConsoleVariableFloat(FAutomationTestBase& Test, const FString& Name, float ExpectedValue)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(TEXT("Console variable test should register the float cvar"), Variable))
		{
			return false;
		}

		return Test.TestTrue(
			TEXT("Console variable test should preserve the float value in IConsoleManager"),
			FMath::IsNearlyEqual(Variable->GetFloat(), ExpectedValue, 0.0001f));
	}

	bool VerifyConsoleVariableBool(FAutomationTestBase& Test, const FString& Name, bool bExpectedValue)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(TEXT("Console variable test should register the bool cvar"), Variable))
		{
			return false;
		}

		return Test.TestEqual(TEXT("Console variable test should preserve the bool value in IConsoleManager"), Variable->GetBool(), bExpectedValue);
	}

	bool VerifyConsoleVariableString(FAutomationTestBase& Test, const FString& Name, const FString& ExpectedValue)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(TEXT("Console variable test should register the string cvar"), Variable))
		{
			return false;
		}

		return Test.TestEqual(TEXT("Console variable test should preserve the string value in IConsoleManager"), Variable->GetString(), ExpectedValue);
	}

	IConsoleCommand* FindConsoleCommand(const FString& Name)
	{
		return static_cast<IConsoleCommand*>(IConsoleManager::Get().FindConsoleObject(*Name));
	}

	bool VerifyConsoleCommandExists(FAutomationTestBase& Test, const FString& Name)
	{
		return Test.TestNotNull(TEXT("Console command test should register the command in IConsoleManager"), FindConsoleCommand(Name));
	}

	bool VerifyConsoleCommandMissing(FAutomationTestBase& Test, const FString& Name)
	{
		return Test.TestNull(TEXT("Console command test should remove the command from IConsoleManager"), FindConsoleCommand(Name));
	}

	bool ExecuteConsoleCommand(FAutomationTestBase& Test, const FString& Name, const TArray<FString>& Args)
	{
		IConsoleCommand* Command = FindConsoleCommand(Name);
		if (!Test.TestNotNull(TEXT("Console command test should find a registered command before execution"), Command))
		{
			return false;
		}

		FOutputDeviceNull OutputDevice;
		return Test.TestTrue(TEXT("Console command test should execute the registered delegate"), Command->Execute(Args, nullptr, OutputDevice));
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptConsoleBindingsTests_Private;

bool FAngelscriptConsoleVariableBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString IntName = MakeConsoleVariableName(TEXT("Int"));
	const FString FloatName = MakeConsoleVariableName(TEXT("Float"));
	const FString BoolName = MakeConsoleVariableName(TEXT("Bool"));
	const FString StringName = MakeConsoleVariableName(TEXT("String"));

	ON_SCOPE_EXIT
	{
		UnregisterConsoleObjectIfPresent(IntName);
		UnregisterConsoleObjectIfPresent(FloatName);
		UnregisterConsoleObjectIfPresent(BoolName);
		UnregisterConsoleObjectIfPresent(StringName);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleVariableCompat",
		FString::Printf(TEXT(R"(
int Entry()
{
	FConsoleVariable IntVar("%s", 5, "Test int cvar");
	if (IntVar.GetInt() != 5)
		return 10;
	IntVar.SetInt(42);
	if (IntVar.GetInt() != 42)
		return 20;

	FConsoleVariable FloatVar("%s", 1.5f, "Test float cvar");
	float32 CurrentFloat = FloatVar.GetFloat();
	if (CurrentFloat < 1.49f || CurrentFloat > 1.51f)
		return 30;
	FloatVar.SetFloat(3.25f);
	CurrentFloat = FloatVar.GetFloat();
	if (CurrentFloat < 3.24f || CurrentFloat > 3.26f)
		return 40;

	FConsoleVariable BoolVar("%s", true, "Test bool cvar");
	if (!BoolVar.GetBool())
		return 50;
	BoolVar.SetBool(false);
	if (BoolVar.GetBool())
		return 60;

	FConsoleVariable StringVar("%s", "DefaultValue", "Test string cvar");
	if (!(StringVar.GetString() == "DefaultValue"))
		return 70;
	StringVar.SetString("UpdatedValue");
	if (!(StringVar.GetString() == "UpdatedValue"))
		return 80;

	return 1;
}
)"), *IntName, *FloatName, *BoolName, *StringName));
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

	const bool bScriptPassed = TestEqual(TEXT("Console variable compat script should exercise all supported cvar types"), Result, 1);
	const bool bIntPassed = VerifyConsoleVariableInt(*this, IntName, 42);
	const bool bFloatPassed = VerifyConsoleVariableFloat(*this, FloatName, 3.25f);
	const bool bBoolPassed = VerifyConsoleVariableBool(*this, BoolName, false);
	const bool bStringPassed = VerifyConsoleVariableString(*this, StringName, TEXT("UpdatedValue"));
	bPassed = bScriptPassed && bIntPassed && bFloatPassed && bBoolPassed && bStringPassed;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptConsoleVariableExistingBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	const FString ExistingName = MakeConsoleVariableName(TEXT("Existing"));
	IConsoleVariable* ExistingVariable = IConsoleManager::Get().RegisterConsoleVariable(*ExistingName, 7, TEXT("Existing native cvar for bindings test"));
	if (!TestNotNull(TEXT("Console variable existing-value test should pre-register a native cvar"), ExistingVariable))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		UnregisterConsoleObjectIfPresent(ExistingName);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleVariableExistingCompat",
		FString::Printf(TEXT(R"(
int Entry()
{
	FConsoleVariable ExistingVar("%s", 99, "Should reuse existing native cvar");
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

	const bool bScriptPassed = TestEqual(TEXT("Console variable existing-value script should reuse the already-registered cvar"), Result, 1);
	const bool bNativeValuePassed = VerifyConsoleVariableInt(*this, ExistingName, 21);
	bPassed = bScriptPassed && bNativeValuePassed;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptConsoleCommandBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	const FString CommandName = MakeConsoleVariableName(TEXT("Command"));
	const FString OutputName = MakeConsoleVariableName(TEXT("CommandOutput"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASConsoleCommandCompat"));
		UnregisterConsoleObjectIfPresent(CommandName);
		UnregisterConsoleObjectIfPresent(OutputName);
	};

	IConsoleManager::Get().RegisterConsoleVariable(*OutputName, -1, TEXT("Console command output sink"));

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleCommandCompat",
		FString::Printf(TEXT(R"(
const FConsoleCommand Command("%s", n"OnCommand");

void OnCommand(const TArray<FString>& Args)
{
	FConsoleVariable Output("%s", 0, "Command output");
	Output.SetInt(Args.Num());
}

int Entry()
{
	return 1;
}
)"), *CommandName, *OutputName));
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

	const bool bEntryPassed = TestEqual(TEXT("Console command compat script should execute setup entrypoint"), Result, 1);
	const bool bRegistered = VerifyConsoleCommandExists(*this, CommandName);

	TArray<FString> Args;
	Args.Add(TEXT("One"));
	Args.Add(TEXT("Two"));
	Args.Add(TEXT("Three"));
	const bool bExecuted = ExecuteConsoleCommand(*this, CommandName, Args);
	const bool bOutputUpdated = VerifyConsoleVariableInt(*this, OutputName, 3);

	Engine.DiscardModule(TEXT("ASConsoleCommandCompat"));
	const bool bUnregistered = VerifyConsoleCommandMissing(*this, CommandName);
	bPassed = bEntryPassed && bRegistered && bExecuted && bOutputUpdated && bUnregistered;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptConsoleCommandReplacementBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	const FString CommandName = MakeConsoleVariableName(TEXT("ReplacementCommand"));
	const FString OutputName = MakeConsoleVariableName(TEXT("ReplacementOutput"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASConsoleCommandOriginalCompat"));
		Engine.DiscardModule(TEXT("ASConsoleCommandReplacementCompat"));
		UnregisterConsoleObjectIfPresent(CommandName);
		UnregisterConsoleObjectIfPresent(OutputName);
	};

	IConsoleManager::Get().RegisterConsoleVariable(*OutputName, -1, TEXT("Console command replacement output sink"));

	asIScriptModule* OriginalModule = BuildModule(
		*this,
		Engine,
		"ASConsoleCommandOriginalCompat",
		FString::Printf(TEXT(R"(
const FConsoleCommand Command("%s", n"OnOriginalCommand");

void OnOriginalCommand(const TArray<FString>& Args)
{
	FConsoleVariable Output("%s", 0, "Command output");
	Output.SetInt(11);
}

int Entry()
{
	return 1;
}
)"), *CommandName, *OutputName));
	if (OriginalModule == nullptr)
	{
		return false;
	}

	asIScriptFunction* OriginalEntry = GetFunctionByDecl(*this, *OriginalModule, TEXT("int Entry()"));
	if (OriginalEntry == nullptr)
	{
		return false;
	}

	int32 OriginalResult = 0;
	if (!ExecuteIntFunction(*this, Engine, *OriginalEntry, OriginalResult))
	{
		return false;
	}

	asIScriptModule* ReplacementModule = BuildModule(
		*this,
		Engine,
		"ASConsoleCommandReplacementCompat",
		FString::Printf(TEXT(R"(
const FConsoleCommand Command("%s", n"OnReplacementCommand");

void OnReplacementCommand(const TArray<FString>& Args)
{
	FConsoleVariable Output("%s", 0, "Command output");
	Output.SetInt(22);
}

int Entry()
{
	return 1;
}
)"), *CommandName, *OutputName));
	if (ReplacementModule == nullptr)
	{
		return false;
	}

	asIScriptFunction* ReplacementEntry = GetFunctionByDecl(*this, *ReplacementModule, TEXT("int Entry()"));
	if (ReplacementEntry == nullptr)
	{
		return false;
	}

	int32 ReplacementResult = 0;
	if (!ExecuteIntFunction(*this, Engine, *ReplacementEntry, ReplacementResult))
	{
		return false;
	}

	const bool bEntryPassed = TestEqual(TEXT("Console command replacement script should execute setup entrypoint"), ReplacementResult, 1);
	const bool bRegistered = VerifyConsoleCommandExists(*this, CommandName);
	const bool bExecuted = ExecuteConsoleCommand(*this, CommandName, {});
	const bool bReplacementObserved = VerifyConsoleVariableInt(*this, OutputName, 22);

	Engine.DiscardModule(TEXT("ASConsoleCommandReplacementCompat"));
	const bool bUnregistered = VerifyConsoleCommandMissing(*this, CommandName);
	bPassed = bEntryPassed && bRegistered && bExecuted && bReplacementObserved && bUnregistered;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptConsoleCommandSignatureBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	AddExpectedError(TEXT("Global function for console command must have signature"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASConsoleCommandSignatureCompat"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("int Entry() | Line 8 | Col 2"), EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	const FString CommandName = MakeConsoleVariableName(TEXT("BadSignatureCommand"));

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASConsoleCommandSignatureCompat"));
		UnregisterConsoleObjectIfPresent(CommandName);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASConsoleCommandSignatureCompat",
		FString::Printf(TEXT(R"(
void WrongSignature()
{
}

int Entry()
{
	const FConsoleCommand Command("%s", n"WrongSignature");
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
	if (!TestNotNull(TEXT("Console command signature mismatch test should create an execution context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	Context->Release();

	const bool bPrepared = TestEqual(TEXT("Console command signature mismatch should still prepare the entry function"), PrepareResult, asSUCCESS);
	const bool bExecutionFailed = TestTrue(TEXT("Console command signature mismatch should fail command construction during execution"), ExecuteResult != asEXECUTION_FINISHED);
	const bool bNotRegistered = VerifyConsoleCommandMissing(*this, CommandName);
	bPassed = bPrepared && bExecutionFailed && bNotRegistered;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
