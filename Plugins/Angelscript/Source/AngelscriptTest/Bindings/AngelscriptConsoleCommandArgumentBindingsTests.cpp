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
	FAngelscriptConsoleCommandEmptyArgsMarkerBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandArgumentMarshalling.EmptyArgsMarker",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConsoleCommandContentAndOrderBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandArgumentMarshalling.ContentAndOrder",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandArgumentBindingsTests_Private
{
	struct FConsoleCommandArgumentScenario
	{
		const TCHAR* ModuleName = TEXT("");
		const TCHAR* ContextLabel = TEXT("");
		TArray<FString> Args;
		FString ExpectedOutput;
	};

	FString MakeConsoleObjectName(const TCHAR* Prefix)
	{
		return FString::Printf(TEXT("Angelscript.Test.Console.%s.%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	void UnregisterConsoleObjectIfPresent(const FString& Name)
	{
		if (IConsoleObject* ConsoleObject = IConsoleManager::Get().FindConsoleObject(*Name))
		{
			IConsoleManager::Get().UnregisterConsoleObject(ConsoleObject, false);
		}
	}

	IConsoleCommand* FindConsoleCommand(const FString& Name)
	{
		return static_cast<IConsoleCommand*>(IConsoleManager::Get().FindConsoleObject(*Name));
	}

	bool VerifyConsoleCommandExists(FAutomationTestBase& Test, const FString& Name, const TCHAR* ContextLabel)
	{
		return Test.TestNotNull(
			*FString::Printf(TEXT("%s should register the console command in IConsoleManager"), ContextLabel),
			FindConsoleCommand(Name));
	}

	bool VerifyConsoleCommandMissing(FAutomationTestBase& Test, const FString& Name, const TCHAR* ContextLabel)
	{
		return Test.TestNull(
			*FString::Printf(TEXT("%s should unregister the console command after module discard"), ContextLabel),
			FindConsoleCommand(Name));
	}

	bool ExecuteConsoleCommand(FAutomationTestBase& Test, const FString& Name, const TArray<FString>& Args, const TCHAR* ContextLabel)
	{
		IConsoleCommand* Command = FindConsoleCommand(Name);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should find the registered console command before execution"), ContextLabel),
				Command))
		{
			return false;
		}

		FOutputDeviceNull OutputDevice;
		return Test.TestTrue(
			*FString::Printf(TEXT("%s should execute the registered console command delegate"), ContextLabel),
			Command->Execute(Args, nullptr, OutputDevice));
	}

	bool VerifyConsoleVariableString(FAutomationTestBase& Test, const FString& Name, const FString& ExpectedValue, const TCHAR* ContextLabel)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should register the string output cvar"), ContextLabel),
				Variable))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the bridged argument payload in the output cvar"), ContextLabel),
			FString(Variable->GetString()),
			ExpectedValue);
	}

	bool CompileConsoleCommandModule(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FString& ModuleName,
		const FString& CommandName,
		const FString& OutputName,
		const TCHAR* ContextLabel)
	{
		asIScriptModule* Module = BuildModule(
			Test,
			Engine,
			StringCast<ANSICHAR>(*ModuleName).Get(),
			FString::Printf(TEXT(R"(
const FConsoleCommand Command("%s", n"OnCommand");

void OnCommand(const TArray<FString>& Args)
{
	FConsoleVariable Output("%s", "__unset__", "Console command output sink");
	if (Args.Num() == 0)
	{
		Output.SetString("<empty>");
		return;
	}

	FString Joined = "";
	for (int Index = 0, Count = Args.Num(); Index < Count; ++Index)
	{
		if (Index != 0)
			Joined += "|";
		Joined += Args[Index];
	}

	Output.SetString(Joined);
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

		asIScriptFunction* Function = GetFunctionByDecl(Test, *Module, TEXT("int Entry()"));
		if (Function == nullptr)
		{
			return false;
		}

		int32 Result = INDEX_NONE;
		if (!ExecuteIntFunction(Test, Engine, *Function, Result))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should execute the setup entrypoint successfully"), ContextLabel),
			Result,
			1);
	}

	bool RunConsoleCommandArgumentScenario(
		FAutomationTestBase& Test,
		const FConsoleCommandArgumentScenario& Scenario)
	{
		bool bPassed = true;
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
		ASTEST_BEGIN_SHARE_CLEAN

		const FString ModuleName = Scenario.ModuleName;
		const FString CommandName = MakeConsoleObjectName(TEXT("Command"));
		const FString OutputName = MakeConsoleObjectName(TEXT("Output"));
		bool bModuleDiscarded = false;

		ON_SCOPE_EXIT
		{
			if (!bModuleDiscarded)
			{
				Engine.DiscardModule(*ModuleName);
			}

			UnregisterConsoleObjectIfPresent(CommandName);
			UnregisterConsoleObjectIfPresent(OutputName);
		};

		IConsoleVariable* OutputVariable = IConsoleManager::Get().RegisterConsoleVariable(*OutputName, TEXT("__native_unset__"), TEXT("Console command output sink"));
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should pre-register the output cvar"), Scenario.ContextLabel),
				OutputVariable))
		{
			return false;
		}

		if (!CompileConsoleCommandModule(Test, Engine, ModuleName, CommandName, OutputName, Scenario.ContextLabel))
		{
			return false;
		}

		const bool bRegistered = VerifyConsoleCommandExists(Test, CommandName, Scenario.ContextLabel);
		const bool bExecuted = ExecuteConsoleCommand(Test, CommandName, Scenario.Args, Scenario.ContextLabel);
		const bool bOutputMatched = VerifyConsoleVariableString(Test, OutputName, Scenario.ExpectedOutput, Scenario.ContextLabel);

		Engine.DiscardModule(*ModuleName);
		bModuleDiscarded = true;
		const bool bUnregistered = VerifyConsoleCommandMissing(Test, CommandName, Scenario.ContextLabel);
		bPassed = bRegistered && bExecuted && bOutputMatched && bUnregistered;

		ASTEST_END_SHARE_CLEAN
		return bPassed;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandArgumentBindingsTests_Private;

bool FAngelscriptConsoleCommandEmptyArgsMarkerBindingsTest::RunTest(const FString& Parameters)
{
	FConsoleCommandArgumentScenario Scenario;
	Scenario.ModuleName = TEXT("ASConsoleCommandArgumentEmptyCompat");
	Scenario.ContextLabel = TEXT("Console command empty-args marshalling");
	Scenario.ExpectedOutput = TEXT("<empty>");
	return RunConsoleCommandArgumentScenario(*this, Scenario);
}

bool FAngelscriptConsoleCommandContentAndOrderBindingsTest::RunTest(const FString& Parameters)
{
	FConsoleCommandArgumentScenario Scenario;
	Scenario.ModuleName = TEXT("ASConsoleCommandArgumentContentCompat");
	Scenario.ContextLabel = TEXT("Console command content-and-order marshalling");
	Scenario.Args =
	{
		TEXT("One"),
		TEXT("Two Words"),
		TEXT("Three=Value"),
	};
	Scenario.ExpectedOutput = TEXT("One|Two Words|Three=Value");
	return RunConsoleCommandArgumentScenario(*this, Scenario);
}

#endif
