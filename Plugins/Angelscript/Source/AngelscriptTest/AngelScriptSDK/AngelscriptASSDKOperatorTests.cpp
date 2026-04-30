#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

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


TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKOperatorTests, "Angelscript.TestModule.AngelScriptSDK.ASSDK.Operator", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Call)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator opCall test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorCall", R"(
class C
{
	int opCall(int a, int b)
	{
		return a + b;
	}
}

int Entry()
{
	C c;
	return c(2, 3);
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator opCall test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		TestRunner->TestNotNull(TEXT("ASSDK operator opCall test should expose the entry function after successful resolution"), GetNativeFunctionByDecl(Module, "int Entry()"));
	}

	TEST_METHOD(Pow)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator pow test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorPow", R"(
bool Entry()
{
	return 3 ** 2 == 9
		&& 9.0 ** 0.5 == 3.0
		&& 2.5 ** 2 == 6.25;
}

void Overflow()
{
	double x = 1.0e100;
	x = x ** 6.0;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator pow test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bPowResult = false;
		if (!ExecuteOperatorBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bPowResult))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK operator pow test should preserve exponent behavior"), bPowResult))
		{
			return;
		}

		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "void Overflow()");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator pow test should resolve the overflow function"), Function))
		{
			return;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator pow test should create a context"), Context))
		{
			return;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		const FString ExceptionString = UTF8_TO_TCHAR(Context->GetExceptionString() != nullptr ? Context->GetExceptionString() : "");
		Context->Release();

		if (!TestRunner->TestEqual(TEXT("ASSDK operator pow test should raise an execution exception on overflow"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("ASSDK operator pow test should report overflow in exponent operation"), ExceptionString, FString(TEXT("Overflow in exponent operation")));
	}

	TEST_METHOD(Negate)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator negate test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorNegate", R"(
bool Entry()
{
	int value = 1000;
	value = -value;
	value = value - value;
	return value == 0;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator negate test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteOperatorBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK operator negate test should preserve unary minus and subtraction semantics"), bResult);
	}

	TEST_METHOD(MultiAssign)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator multi-assign test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorMultiAssign", R"(
bool Entry()
{
	int a = 0, b = 0, c = 0, d = 0;
	int clr = 0x12345678;
	a = b = c = d = clr;
	return a == clr && b == clr && c == clr && d == clr;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator multi-assign test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteOperatorBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK operator multi-assign test should assign every local target equally"), bResult);
	}

	TEST_METHOD(Condition)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator condition test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorCondition", R"(
bool Entry()
{
	int value = true ? 1 : 0;
	return value == 1;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator condition test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteOperatorBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK operator condition test should preserve ternary assignment side effects"), bResult);
	}

	TEST_METHOD(ForLoop)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKOperatorTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator for-loop test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKOperatorForLoop", R"(
bool Entry()
{
	int result = 0;
	for (int a = 1, b = 1; a < 5 && b < 5; a++, b = a + 1)
	{
		result += a * b;
	}
	return result == (1 + 6 + 12);
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK operator for-loop test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteOperatorBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK operator for-loop test should preserve multiple increment expressions"), bResult);
	}
};

#endif
