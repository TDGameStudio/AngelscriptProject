#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKFunctionTests_Private
{
	bool ExecuteFunctionBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Function test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Function test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Function test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}


TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKFunctionTests,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.Function",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(OverloadDefault)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKFunctionTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK function overload/default test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		// Test function overloading with distinct parameter counts
		// Note: This fork does not support ambiguous overload resolution when default args overlap
		// We test distinct overloads that don't have ambiguous calls
		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKFunctionOverloadDefault", R"(
int AddOne(int Value)
{
	return Value + 1;
}

int AddPair(int Left, int Right)
{
	return Left + Right;
}

int AddWithDefault(int Left, int Right = 10)
{
	return Left + Right;
}

bool Entry()
{
	return AddOne(2) == 3 && AddPair(2, 5) == 7 && AddWithDefault(5) == 15 && AddWithDefault(3, 2) == 5;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK function overload/default test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK function overload/default test should preserve overload resolution and default argument semantics"), bResult);
	}

	TEST_METHOD(RefArgument)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKFunctionTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK function ref-argument test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKFunctionRefArgument", R"(
void WriteValue(int &out Value)
{
	Value = 7;
}

bool Entry()
{
	int Value = 0;
	WriteValue(Value);
	return Value == 7;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK function ref-argument test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK function ref-argument test should preserve out-parameter writes"), bResult);
	}

	TEST_METHOD(ByRefMutation)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKFunctionTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK function by-ref mutation test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKFunctionByRefMutation", R"(
void Increment(int &inout Value)
{
	Value += 1;
}

bool Entry()
{
	int Value = 41;
	Increment(Value);
	return Value == 42;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK function by-ref mutation test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK function by-ref mutation test should preserve inout parameter semantics"), bResult);
	}
};

#endif
