#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugBindingsTest,
	"Angelscript.TestModule.Bindings.DebuggingThrowAndCallstackCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptDebugBindingsTests_Private
{
	static constexpr ANSICHAR DebugBindingsModuleName[] = "ASDebuggingCompat";

	struct FDebugBindingsExceptionResult
	{
		int32 PrepareResult = MIN_int32;
		int32 ExecuteResult = MIN_int32;
		FString ExceptionString;
		FString ExceptionFunctionName;
		FString ExceptionFunctionDeclaration;
	};

	bool ExecuteFunctionAndCaptureException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptFunction& Function,
		FDebugBindingsExceptionResult& OutResult)
	{
		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(TEXT("Debug bindings test should create an execution context"), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		OutResult.PrepareResult = Context->Prepare(&Function);
		OutResult.ExecuteResult = OutResult.PrepareResult == asSUCCESS ? Context->Execute() : OutResult.PrepareResult;
		OutResult.ExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");

		if (asIScriptFunction* ExceptionFunction = Context->GetExceptionFunction())
		{
			OutResult.ExceptionFunctionName = UTF8_TO_TCHAR(ExceptionFunction->GetName());
			OutResult.ExceptionFunctionDeclaration = UTF8_TO_TCHAR(ExceptionFunction->GetDeclaration());
		}

		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptDebugBindingsTests_Private;

bool FAngelscriptDebugBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("DebuggingThrowCompat"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASDebuggingCompat"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("void ThrowLeaf()"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("void ThrowMiddle()"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("int EntryThrow()"), EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASDebuggingCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		DebugBindingsModuleName,
		TEXT(R"AS(
bool StackContains(const TArray<FString>& Stack, const FString& Needle)
{
	for (int Index = 0; Index < Stack.Num(); ++Index)
	{
		if (Stack[Index].Contains(Needle))
		{
			return true;
		}
	}

	return false;
}

int ProbeCallstack()
{
	TArray<FString> Stack = GetAngelscriptCallstack();
	FString Formatted = FormatAngelscriptCallstack();
	if (Stack.Num() < 3)
	{
		return 10;
	}
	if (!StackContains(Stack, "ProbeCallstack"))
	{
		return 11;
	}
	if (!StackContains(Stack, "EntryCallstack"))
	{
		return 12;
	}
	if (!Formatted.Contains("ProbeCallstack"))
	{
		return 13;
	}
	if (!Formatted.Contains("EntryCallstack"))
	{
		return 14;
	}

	return 1;
}

int EntryCallstack()
{
	return ProbeCallstack();
}

void ThrowLeaf()
{
	throw("DebuggingThrowCompat");
}

void ThrowMiddle()
{
	ThrowLeaf();
}

int EntryThrow()
{
	ThrowMiddle();
	return 0;
}
)AS"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* CallstackFunction = GetFunctionByDecl(*this, *Module, TEXT("int EntryCallstack()"));
	asIScriptFunction* ThrowFunction = GetFunctionByDecl(*this, *Module, TEXT("int EntryThrow()"));
	if (CallstackFunction == nullptr || ThrowFunction == nullptr)
	{
		return false;
	}

	int32 CallstackResult = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *CallstackFunction, CallstackResult))
	{
		return false;
	}

	FDebugBindingsExceptionResult ExceptionResult;
	if (!ExecuteFunctionAndCaptureException(*this, Engine, *ThrowFunction, ExceptionResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Debug bindings callstack path should report success"),
		CallstackResult,
		1);
	bPassed &= TestEqual(
		TEXT("Debug bindings throw path should prepare the entry function"),
		ExceptionResult.PrepareResult,
		static_cast<int32>(asSUCCESS));
	bPassed &= TestEqual(
		TEXT("Debug bindings throw path should raise a script exception"),
		ExceptionResult.ExecuteResult,
		static_cast<int32>(asEXECUTION_EXCEPTION));
	bPassed &= TestTrue(
		TEXT("Debug bindings throw path should surface the thrown message"),
		ExceptionResult.ExceptionString.Contains(TEXT("DebuggingThrowCompat")));
	bPassed &= TestFalse(
		TEXT("Debug bindings throw path should capture a non-empty exception function name"),
		ExceptionResult.ExceptionFunctionName.IsEmpty());
	bPassed &= TestTrue(
		TEXT("Debug bindings throw path should report ThrowLeaf as the exception site"),
		ExceptionResult.ExceptionFunctionDeclaration.Contains(TEXT("ThrowLeaf")));

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
