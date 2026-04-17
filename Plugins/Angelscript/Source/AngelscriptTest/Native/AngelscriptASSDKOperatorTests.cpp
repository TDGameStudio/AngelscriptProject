#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorCallTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.Call",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorPowTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.Pow",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorNegateTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.Negate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorMultiAssignTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.MultiAssign",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorConditionTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.Condition",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKOperatorForLoopTest,
	"Angelscript.TestModule.Native.ASSDK.Operator.ForLoop",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private
{
	asDWORD GAssignA = 0;
	asDWORD GAssignB = 0;
	asDWORD GAssignC = 0;
	asDWORD GAssignD = 0;
	asDWORD GAssignSource = 0;
	int32 GNegateValue = 0;
	bool GNegateCalled = false;

	asDWORD& AssignValue(asDWORD& Source, asDWORD& Destination)
	{
		Destination = Source;
		return Destination;
	}

	void AssignValueGeneric(asIScriptGeneric* Generic)
	{
		asDWORD* Destination = static_cast<asDWORD*>(Generic->GetObject());
		asDWORD* Source = static_cast<asDWORD*>(Generic->GetArgAddress(0));
		*Destination = *Source;
		Generic->SetReturnAddress(Destination);
	}

	int NegateValueNative(int* Value)
	{
		GNegateCalled = true;
		return -*Value;
	}

	void NegateValueGeneric(asIScriptGeneric* Generic)
	{
		int* Value = static_cast<int*>(Generic->GetObject());
		GNegateCalled = true;
		int Result = -*Value;
		Generic->SetReturnObject(&Result);
	}

	int SubtractValueNative(int* Left, int* Right)
	{
		GNegateCalled = true;
		return *Left - *Right;
	}

	void SubtractValueGeneric(asIScriptGeneric* Generic)
	{
		int* Left = static_cast<int*>(Generic->GetObject());
		int* Right = static_cast<int*>(Generic->GetArgAddress(0));
		GNegateCalled = true;
		int Result = *Left - *Right;
		Generic->SetReturnObject(&Result);
	}

	bool ExecuteOperatorBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Operator test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Operator test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Operator test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	bool ExecuteOperatorIntEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, int32& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Operator test should resolve the int entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Operator test should create an int execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = static_cast<int32>(Context->GetReturnDWord());
		Context->Release();
		return Test.TestEqual(TEXT("Operator test should finish int execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;

bool FAngelscriptASSDKOperatorCallTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator opCall test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorCall",
		"class C                     \n"
		"{                           \n"
		"  int opCall(int a, int b)  \n"
		"  {                         \n"
		"    return a + b;           \n"
		"  }                         \n"
		"}                           \n"
		"int Entry()                 \n"
		"{                           \n"
		"  C c;                      \n"
		"  return c(2, 3);           \n"
		"}                           \n");
	if (!TestNotNull(TEXT("ASSDK operator opCall test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return TestNotNull(TEXT("ASSDK operator opCall test should expose the entry function after successful resolution"), GetNativeFunctionByDecl(Module, "int Entry()"));
}

bool FAngelscriptASSDKOperatorPowTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator pow test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorPow",
		"bool Entry()                  \n"
		"{                             \n"
		"  return 3 ** 2 == 9          \n"
		"    && 9.0 ** 0.5 == 3.0      \n"
		"    && 2.5 ** 2 == 6.25;      \n"
		"}                             \n"
		"void Overflow()               \n"
		"{                             \n"
		"  double x = 1.0e100;         \n"
		"  x = x ** 6.0;               \n"
		"}                             \n");
	if (!TestNotNull(TEXT("ASSDK operator pow test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bPowResult = false;
	if (!ExecuteOperatorBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bPowResult))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK operator pow test should preserve exponent behavior"), bPowResult))
	{
		return false;
	}

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "void Overflow()");
	if (!TestNotNull(TEXT("ASSDK operator pow test should resolve the overflow function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK operator pow test should create a context"), Context))
	{
		return false;
	}

	const int ExecuteResult = PrepareAndExecute(Context, Function);
	const FString ExceptionString = UTF8_TO_TCHAR(Context->GetExceptionString() != nullptr ? Context->GetExceptionString() : "");
	Context->Release();

	if (!TestEqual(TEXT("ASSDK operator pow test should raise an execution exception on overflow"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION)))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK operator pow test should report overflow in exponent operation"), ExceptionString, FString(TEXT("Overflow in exponent operation")));
}

bool FAngelscriptASSDKOperatorNegateTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator negate test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorNegate",
		"bool Entry()                   \n"
		"{                              \n"
		"  int value = 1000;            \n"
		"  value = -value;              \n"
		"  value = value - value;       \n"
		"  return value == 0;           \n"
		"}                              \n");
	if (!TestNotNull(TEXT("ASSDK operator negate test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteOperatorBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK operator negate test should preserve unary minus and subtraction semantics"), bResult);
}

bool FAngelscriptASSDKOperatorMultiAssignTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator multi-assign test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorMultiAssign",
		"bool Entry()                   \n"
		"{                              \n"
		"  int a = 0, b = 0, c = 0, d = 0; \n"
		"  int clr = 0x12345678;        \n"
		"  a = b = c = d = clr;         \n"
		"  return a == clr && b == clr && c == clr && d == clr; \n"
		"}                              \n");
	if (!TestNotNull(TEXT("ASSDK operator multi-assign test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteOperatorBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK operator multi-assign test should assign every local target equally"), bResult);
}

bool FAngelscriptASSDKOperatorConditionTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator condition test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorCondition",
		"bool Entry()             \n"
		"{                        \n"
		"  int value = true ? 1 : 0; \n"
		"  return value == 1;    \n"
		"}                        \n");
	if (!TestNotNull(TEXT("ASSDK operator condition test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteOperatorBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK operator condition test should preserve ternary assignment side effects"), bResult);
}

bool FAngelscriptASSDKOperatorForLoopTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK operator for-loop test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKOperatorForLoop",
		"bool Entry()                                \n"
		"{                                           \n"
		"  int result = 0;                           \n"
		"  for (int a = 1, b = 1; a < 5 && b < 5; a++, b = a + 1) \n"
		"  {                                         \n"
		"    result += a * b;                        \n"
		"  }                                         \n"
		"  return result == (1 + 6 + 12);           \n"
		"}                                           \n");
	if (!TestNotNull(TEXT("ASSDK operator for-loop test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteOperatorBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK operator for-loop test should preserve multiple increment expressions"), bResult);
}

#endif
