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
	FAngelscriptConsoleCommandLifecycleBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandLifecycleOriginalReplacementUnload",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandLifecycleBindingsTests_Private
{
	static constexpr ANSICHAR OriginalLifecycleModuleNameAnsi[] = "ASConsoleCommandOriginalLifecycle";
	static constexpr ANSICHAR ReplacementLifecycleModuleNameAnsi[] = "ASConsoleCommandReplacementLifecycle";
	static constexpr TCHAR OriginalLifecycleModuleName[] = TEXT("ASConsoleCommandOriginalLifecycle");
	static constexpr TCHAR ReplacementLifecycleModuleName[] = TEXT("ASConsoleCommandReplacementLifecycle");

	struct FConsoleCommandLifecycleScenario
	{
		FString CommandName;
		FString OutputName;
		int32 ExpectedOriginalMarker = 0;
		int32 ExpectedReplacementMarker = 0;
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
			*FString::Printf(TEXT("%s should remove the console command from IConsoleManager"), ContextLabel),
			FindConsoleCommand(Name));
	}

	bool ExecuteConsoleCommand(FAutomationTestBase& Test, const FString& Name, const TArray<FString>& Args, const TCHAR* ContextLabel)
	{
		IConsoleCommand* Command = FindConsoleCommand(Name);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should find a registered command before execution"), ContextLabel),
				Command))
		{
			return false;
		}

		FOutputDeviceNull OutputDevice;
		return Test.TestTrue(
			*FString::Printf(TEXT("%s should execute the registered console command delegate"), ContextLabel),
			Command->Execute(Args, nullptr, OutputDevice));
	}

	bool VerifyConsoleVariableInt(FAutomationTestBase& Test, const FString& Name, int32 ExpectedValue, const TCHAR* ContextLabel)
	{
		IConsoleVariable* Variable = IConsoleManager::Get().FindConsoleVariable(*Name);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should keep the output cvar registered"), ContextLabel),
				Variable))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should write the expected marker into the shared output sink"), ContextLabel),
			Variable->GetInt(),
			ExpectedValue);
	}

	bool CompileConsoleCommandModule(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const ANSICHAR* ModuleName,
		const FString& CommandName,
		const FString& OutputName,
		const TCHAR* HandlerName,
		const int32 OutputMarker,
		const TCHAR* ContextLabel)
	{
		asIScriptModule* Module = BuildModule(
			Test,
			Engine,
			ModuleName,
			FString::Printf(TEXT(R"(
const FConsoleCommand Command("%s", n"%s");

void %s(const TArray<FString>& Args)
{
	FConsoleVariable Output("%s", 0, "Console command lifecycle output sink");
	Output.SetInt(%d);
}

int Entry()
{
	return 1;
}
)"),
				*CommandName,
				HandlerName,
				HandlerName,
				*OutputName,
				OutputMarker));
		if (Module == nullptr)
		{
			return false;
		}

		asIScriptFunction* EntryFunction = GetFunctionByDecl(Test, *Module, TEXT("int Entry()"));
		if (EntryFunction == nullptr)
		{
			return false;
		}

		int32 EntryResult = INDEX_NONE;
		if (!ExecuteIntFunction(Test, Engine, *EntryFunction, EntryResult))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("%s should execute the module setup entrypoint"), ContextLabel),
			EntryResult,
			1);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptConsoleCommandLifecycleBindingsTests_Private;

bool FAngelscriptConsoleCommandLifecycleBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FConsoleCommandLifecycleScenario Scenario;
	Scenario.CommandName = MakeConsoleObjectName(TEXT("LifecycleCommand"));
	Scenario.OutputName = MakeConsoleObjectName(TEXT("LifecycleOutput"));
	Scenario.ExpectedOriginalMarker = 11;
	Scenario.ExpectedReplacementMarker = 22;

	bool bOriginalDiscarded = false;
	bool bReplacementDiscarded = false;

	ON_SCOPE_EXIT
	{
		if (!bReplacementDiscarded)
		{
			Engine.DiscardModule(ReplacementLifecycleModuleName);
		}

		if (!bOriginalDiscarded)
		{
			Engine.DiscardModule(OriginalLifecycleModuleName);
		}

		UnregisterConsoleObjectIfPresent(Scenario.CommandName);
		UnregisterConsoleObjectIfPresent(Scenario.OutputName);
	};

	IConsoleVariable* OutputVariable = IConsoleManager::Get().RegisterConsoleVariable(
		*Scenario.OutputName,
		-1,
		TEXT("Console command lifecycle output sink"));
	if (!TestNotNull(TEXT("Console command lifecycle test should pre-register the shared output sink"), OutputVariable))
	{
		return false;
	}

	const bool bOriginalCompiled = CompileConsoleCommandModule(
		*this,
		Engine,
		OriginalLifecycleModuleNameAnsi,
		Scenario.CommandName,
		Scenario.OutputName,
		TEXT("OnOriginalCommand"),
		11,
		TEXT("Original console command lifecycle setup"));
	const bool bOriginalRegistered = VerifyConsoleCommandExists(*this, Scenario.CommandName, TEXT("Original console command lifecycle setup"));

	const TArray<FString> NoArgs;
	const bool bOriginalExecuted = ExecuteConsoleCommand(*this, Scenario.CommandName, NoArgs, TEXT("Original console command lifecycle execution"));
	const bool bOriginalObserved = VerifyConsoleVariableInt(
		*this,
		Scenario.OutputName,
		Scenario.ExpectedOriginalMarker,
		TEXT("Original console command lifecycle execution"));

	const bool bReplacementCompiled = CompileConsoleCommandModule(
		*this,
		Engine,
		ReplacementLifecycleModuleNameAnsi,
		Scenario.CommandName,
		Scenario.OutputName,
		TEXT("OnReplacementCommand"),
		22,
		TEXT("Replacement console command lifecycle setup"));
	const bool bReplacementRegistered = VerifyConsoleCommandExists(*this, Scenario.CommandName, TEXT("Replacement console command lifecycle setup"));
	const bool bReplacementExecuted = ExecuteConsoleCommand(*this, Scenario.CommandName, NoArgs, TEXT("Replacement console command lifecycle execution"));
	const bool bReplacementObserved = VerifyConsoleVariableInt(
		*this,
		Scenario.OutputName,
		Scenario.ExpectedReplacementMarker,
		TEXT("Replacement console command lifecycle execution"));

	Engine.DiscardModule(OriginalLifecycleModuleName);
	bOriginalDiscarded = true;

	const bool bOriginalUnloadKeptReplacementCommand = VerifyConsoleCommandExists(
		*this,
		Scenario.CommandName,
		TEXT("Original console command lifecycle unload"));
	const bool bReplacementStillExecutedAfterOriginalUnload = ExecuteConsoleCommand(
		*this,
		Scenario.CommandName,
		NoArgs,
		TEXT("Replacement console command execution after original unload"));
	const bool bReplacementStillObservedAfterOriginalUnload = VerifyConsoleVariableInt(
		*this,
		Scenario.OutputName,
		Scenario.ExpectedReplacementMarker,
		TEXT("Replacement console command execution after original unload"));

	Engine.DiscardModule(ReplacementLifecycleModuleName);
	bReplacementDiscarded = true;

	const bool bReplacementUnloadRemovedCommand = VerifyConsoleCommandMissing(
		*this,
		Scenario.CommandName,
		TEXT("Replacement console command lifecycle unload"));

	bPassed =
		bOriginalCompiled &&
		bOriginalRegistered &&
		bOriginalExecuted &&
		bOriginalObserved &&
		bReplacementCompiled &&
		bReplacementRegistered &&
		bReplacementExecuted &&
		bReplacementObserved &&
		bOriginalUnloadKeptReplacementCommand &&
		bReplacementStillExecutedAfterOriginalUnload &&
		bReplacementStillObservedAfterOriginalUnload &&
		bReplacementUnloadRemovedCommand;

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
