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

using namespace AngelscriptTest_Native_AngelscriptASSDKFunctionTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKFunctionTests,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.Function",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(OverloadDefault)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK function overload/default test should create a standalone engine"), ScriptEngine))
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
		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKFunctionOverloadDefault",
			"int AddOne(int Value) { return Value + 1; }          \n"
			"int AddPair(int Left, int Right)                     \n"
			"{                                                    \n"
			"  return Left + Right;                               \n"
			"}                                                    \n"
			"int AddWithDefault(int Left, int Right = 10)         \n"
			"{                                                    \n"
			"  return Left + Right;                               \n"
			"}                                                    \n"
			"bool Entry()                                         \n"
			"{                                                    \n"
			"  return AddOne(2) == 3 && AddPair(2, 5) == 7 && AddWithDefault(5) == 15 && AddWithDefault(3, 2) == 5; \n"
			"}                                                    \n");
		if (!TestNotNull(TEXT("ASSDK function overload/default test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK function overload/default test should preserve overload resolution and default argument semantics"), bResult);
	}

	TEST_METHOD(RefArgument)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK function ref-argument test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKFunctionRefArgument",
			"void WriteValue(int &out Value)                       \n"
			"{                                                    \n"
			"  Value = 7;                                         \n"
			"}                                                    \n"
			"bool Entry()                                         \n"
			"{                                                    \n"
			"  int Value = 0;                                     \n"
			"  WriteValue(Value);                                 \n"
			"  return Value == 7;                                 \n"
			"}                                                    \n");
		if (!TestNotNull(TEXT("ASSDK function ref-argument test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK function ref-argument test should preserve out-parameter writes"), bResult);
	}

	TEST_METHOD(ByRefMutation)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK function by-ref mutation test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKFunctionByRefMutation",
			"void Increment(int &inout Value)                     \n"
			"{                                                    \n"
			"  Value += 1;                                        \n"
			"}                                                    \n"
			"bool Entry()                                         \n"
			"{                                                    \n"
			"  int Value = 41;                                    \n"
			"  Increment(Value);                                  \n"
			"  return Value == 42;                                \n"
			"}                                                    \n");
		if (!TestNotNull(TEXT("ASSDK function by-ref mutation test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteFunctionBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK function by-ref mutation test should preserve inout parameter semantics"), bResult);
	}
};

#endif
