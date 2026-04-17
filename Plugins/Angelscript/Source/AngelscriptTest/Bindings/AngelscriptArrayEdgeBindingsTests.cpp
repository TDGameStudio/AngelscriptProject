#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptArrayMutationEdgeCasesBindingsTest,
	"Angelscript.TestModule.Bindings.ArrayMutationEdgeCases",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptArrayEdgeBindingsTests_Private
{
	static constexpr ANSICHAR ArrayMutationEdgeCasesModuleName[] = "ASArrayMutationEdgeCases";

	bool ExecuteFunctionExpectingScriptException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
		const TCHAR* ContextLabel)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* ScriptContext = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), ScriptContext))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			ScriptContext->Release();
		};

		const int PrepareResult = ScriptContext->Prepare(Function);
		const int ExecuteResult = PrepareResult == asSUCCESS ? ScriptContext->Execute() : PrepareResult;
		const FString ExceptionString = UTF8_TO_TCHAR(
			ScriptContext->GetExceptionString() != nullptr ? ScriptContext->GetExceptionString() : "");
		const int32 ExceptionLine = ScriptContext->GetExceptionLineNumber();

		const bool bPrepared = Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully before the runtime error path"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS));
		const bool bThrew = Test.TestEqual(
			*FString::Printf(TEXT("%s should raise a script execution exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION));
		const bool bHasMessage = Test.TestFalse(
			*FString::Printf(TEXT("%s should provide a non-empty exception string"), ContextLabel),
			ExceptionString.IsEmpty());
		const bool bHasLine = Test.TestTrue(
			*FString::Printf(TEXT("%s should report a positive exception line"), ContextLabel),
			ExceptionLine > 0);

		return bPrepared && bThrew && bHasMessage && bHasLine;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptArrayEdgeBindingsTests_Private;

bool FAngelscriptArrayMutationEdgeCasesBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASArrayMutationEdgeCases"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		ArrayMutationEdgeCasesModuleName,
		TEXT(R"(
bool HasRemainingValues(const int[] Values)
{
	return Values.Num() == 2
		&& ((Values[0] == 2 && Values[1] == 3) || (Values[0] == 3 && Values[1] == 2));
}

int Entry()
{
	int[] Reserved;
	Reserved.Add(4);
	Reserved.Add(5);
	Reserved.Reserve(16);
	if (Reserved.Num() != 2)
		return 10;
	if (Reserved[0] != 4 || Reserved[1] != 5)
		return 20;
	if (Reserved.Max() < 16)
		return 30;

	int[] ZeroExtended;
	ZeroExtended.Add(9);
	ZeroExtended.SetNum(4);
	if (ZeroExtended.Num() != 4)
		return 40;
	if (ZeroExtended[0] != 9)
		return 50;
	if (ZeroExtended[1] != 0 || ZeroExtended[2] != 0 || ZeroExtended[3] != 0)
		return 60;

	int[] Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	Values.Add(3);
	if (Values.RemoveSwap(1) != 2)
		return 70;
	if (!HasRemainingValues(Values))
		return 80;

	return 1;
}

void TriggerSelfAliasAdd()
{
	int[] Values;
	Values.Add(7);
	Values.Add(9);
	Values.Add(Values[0]);
}

void TriggerSelfAliasInsert()
{
	int[] Values;
	Values.Add(7);
	Values.Add(9);
	Values.Insert(Values[0], 0);
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	const bool bHappyPathPassed = TestEqual(
		TEXT("TArray reserve, SetNum, and RemoveSwap edge cases should preserve the expected script-visible results"),
		Result,
		1);
	AddExpectedError(TEXT("Cannot Add an element from the same array by reference. Copy it to a temporary first."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Cannot Insert an element from the same array by reference. Copy it to a temporary first."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASArrayMutationEdgeCases"), EAutomationExpectedErrorFlags::Contains, 2);
	AddExpectedError(TEXT("| Col 2"), EAutomationExpectedErrorFlags::Contains, 2);
	const bool bSelfAliasAddPassed = ExecuteFunctionExpectingScriptException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerSelfAliasAdd()"),
		TEXT("TArray.Add self-alias"));
	const bool bSelfAliasInsertPassed = ExecuteFunctionExpectingScriptException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerSelfAliasInsert()"),
		TEXT("TArray.Insert self-alias"));

	bPassed = bHappyPathPassed && bSelfAliasAddPassed && bSelfAliasInsertPassed;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
