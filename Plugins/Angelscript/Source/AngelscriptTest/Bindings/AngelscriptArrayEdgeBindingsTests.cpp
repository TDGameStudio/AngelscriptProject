#include "../Shared/AngelscriptGlobalFunctionInvoker.h"
#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptReflectiveAccess;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptArraySyntaxCompatBindingsTest,
	"Angelscript.TestModule.Bindings.ArraySyntaxCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptArraySyntaxCompatTests_Private
{
	static constexpr ANSICHAR ArraySyntaxCompatModuleName[] = "ASArraySyntaxCompat";

	bool ExpectGlobalInt(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		const TCHAR* ContextLabel,
		int32 ExpectedValue)
	{
		FASGlobalFunctionInvoker Invoker(Test, Engine, Module, FunctionDecl);
		const int32 ActualValue = Invoker.CallAndReturn<int32>(INDEX_NONE);
		Test.AddInfo(FString::Printf(TEXT("%s returned %d"), ContextLabel, ActualValue));
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should return the expected script-visible value"), ContextLabel),
			ActualValue,
			ExpectedValue);
	}

	bool ExpectGlobalIntAtLeast(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		const TCHAR* ContextLabel,
		int32 MinimumValue)
	{
		FASGlobalFunctionInvoker Invoker(Test, Engine, Module, FunctionDecl);
		const int32 ActualValue = Invoker.CallAndReturn<int32>(INDEX_NONE);
		Test.AddInfo(FString::Printf(TEXT("%s returned %d"), ContextLabel, ActualValue));
		return Test.TestTrue(
			*FString::Printf(TEXT("%s should be at least %d"), ContextLabel, MinimumValue),
			ActualValue >= MinimumValue);
	}

	bool ExecuteFunctionExpectingScriptException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
		const FString& ExpectedExceptionText,
		const TCHAR* ContextLabel)
	{
		asIScriptFunction* Function = ResolveFunctionByDecl(Test, Module, FunctionDecl);
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
		const bool bHasExpectedMessage = Test.TestTrue(
			*FString::Printf(TEXT("%s should report the expected exception text"), ContextLabel),
			ExceptionString.Contains(ExpectedExceptionText));
		const bool bHasLine = Test.TestTrue(
			*FString::Printf(TEXT("%s should report a positive exception line"), ContextLabel),
			ExceptionLine > 0);
		Test.AddInfo(FString::Printf(
			TEXT("%s raised script exception at line %d: %s"),
			ContextLabel,
			ExceptionLine,
			*ExceptionString));

		return bPrepared && bThrew && bHasMessage && bHasExpectedMessage && bHasLine;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptArraySyntaxCompatTests_Private;

bool FAngelscriptArraySyntaxCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASArraySyntaxCompat"));
		ResetSharedCloneEngine(Engine);
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		ArraySyntaxCompatModuleName,
		TEXT(R"(
bool HasRemainingValues(const int[] Values)
{
	return Values.Num() == 2
		&& ((Values[0] == 2 && Values[1] == 3) || (Values[0] == 3 && Values[1] == 2));
}

int ReserveCount()
{
	int[] Reserved;
	Reserved.Add(4);
	Reserved.Add(5);
	Reserved.Reserve(16);
	return Reserved.Num();
}

int ReserveFirstValue()
{
	int[] Reserved;
	Reserved.Add(4);
	Reserved.Add(5);
	Reserved.Reserve(16);
	return Reserved[0];
}

int ReserveSecondValue()
{
	int[] Reserved;
	Reserved.Add(4);
	Reserved.Add(5);
	Reserved.Reserve(16);
	return Reserved[1];
}

int ReserveMaxAfterReserve()
{
	int[] Reserved;
	Reserved.Add(4);
	Reserved.Add(5);
	Reserved.Reserve(16);
	return Reserved.Max();
}

int SetNumCount()
{
	int[] ZeroExtended;
	ZeroExtended.Add(9);
	ZeroExtended.SetNum(4);
	return ZeroExtended.Num();
}

int SetNumExistingValue()
{
	int[] ZeroExtended;
	ZeroExtended.Add(9);
	ZeroExtended.SetNum(4);
	return ZeroExtended[0];
}

int SetNumNewSlotSum()
{
	int[] ZeroExtended;
	ZeroExtended.Add(9);
	ZeroExtended.SetNum(4);
	return ZeroExtended[1] + ZeroExtended[2] + ZeroExtended[3];
}

int RemoveSwapRemovedCount()
{
	int[] Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	Values.Add(3);
	return Values.RemoveSwap(1);
}

int RemoveSwapCountAfterRemove()
{
	int[] Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	Values.Add(3);
	Values.RemoveSwap(1);
	return Values.Num();
}

int RemoveSwapNoRemovedValueLeft()
{
	int[] Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	Values.Add(3);
	Values.RemoveSwap(1);
	for (int Index = 0; Index < Values.Num(); ++Index)
	{
		if (Values[Index] == 1)
			return 0;
	}
	return 1;
}

int RemoveSwapHasExpectedSurvivors()
{
	int[] Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	Values.Add(3);
	Values.RemoveSwap(1);
	return HasRemainingValues(Values) ? 1 : 0;
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

	bool bHappyPathPassed = true;
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int ReserveCount()"), TEXT("int[] compatibility Reserve should preserve Num"), 2);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int ReserveFirstValue()"), TEXT("int[] compatibility Reserve should preserve first value"), 4);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int ReserveSecondValue()"), TEXT("int[] compatibility Reserve should preserve second value"), 5);
	bHappyPathPassed &= ExpectGlobalIntAtLeast(*this, Engine, *Module, TEXT("int ReserveMaxAfterReserve()"), TEXT("int[] compatibility Reserve should grow Max"), 16);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int SetNumCount()"), TEXT("int[] compatibility SetNum should extend Num"), 4);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int SetNumExistingValue()"), TEXT("int[] compatibility SetNum should preserve existing values"), 9);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int SetNumNewSlotSum()"), TEXT("int[] compatibility SetNum should zero-initialize new slots"), 0);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int RemoveSwapRemovedCount()"), TEXT("int[] compatibility RemoveSwap should remove all matching values"), 2);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int RemoveSwapCountAfterRemove()"), TEXT("int[] compatibility RemoveSwap should shrink Num"), 2);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int RemoveSwapNoRemovedValueLeft()"), TEXT("int[] compatibility RemoveSwap should leave no removed value"), 1);
	bHappyPathPassed &= ExpectGlobalInt(*this, Engine, *Module, TEXT("int RemoveSwapHasExpectedSurvivors()"), TEXT("int[] compatibility RemoveSwap should preserve survivor set"), 1);
	AddExpectedError(TEXT("Cannot Add an element from the same array by reference. Copy it to a temporary first."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Cannot Insert an element from the same array by reference. Copy it to a temporary first."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASArraySyntaxCompat"), EAutomationExpectedErrorFlags::Contains, 2);
	AddExpectedError(TEXT("| Col 2"), EAutomationExpectedErrorFlags::Contains, 2);
	const bool bSelfAliasAddPassed = ExecuteFunctionExpectingScriptException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerSelfAliasAdd()"),
		TEXT("Cannot Add an element from the same array by reference. Copy it to a temporary first."),
		TEXT("int[] compatibility Add self-alias"));
	const bool bSelfAliasInsertPassed = ExecuteFunctionExpectingScriptException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerSelfAliasInsert()"),
		TEXT("Cannot Insert an element from the same array by reference. Copy it to a temporary first."),
		TEXT("int[] compatibility Insert self-alias"));

	bPassed = bHappyPathPassed && bSelfAliasAddPassed && bSelfAliasInsertPassed;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
