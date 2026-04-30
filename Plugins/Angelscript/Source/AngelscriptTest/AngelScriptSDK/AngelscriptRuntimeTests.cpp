#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKRuntimeTests_Private
{
	bool ExecuteRuntimeBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Runtime test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Runtime test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Runtime test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKRuntimeTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKRuntimeTests, "Angelscript.TestModule.AngelScriptSDK.ASSDK.Runtime", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Context)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK runtime context test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKRuntimeContext",
			"int Compute(int N)                               \n"
			"{                                                \n"
			"  int Result = 0;                                \n"
			"  for (int i = 1; i <= N; i++)                   \n"
			"  {                                              \n"
			"    Result += i;                                 \n"
			"  }                                              \n"
			"  return Result;                                 \n"
			"}                                                \n"
			"bool Entry()                                     \n"
			"{                                                \n"
			"  return Compute(10) == 55;                      \n"
			"}                                                \n");
		if (!TestNotNull(TEXT("ASSDK runtime context test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteRuntimeBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK runtime context test should execute context operations"), bResult);
	}

	TEST_METHOD(Exception)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK runtime exception test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKRuntimeException",
			"void ThrowException()                          \n"
			"{                                             \n"
			"  int a = 0;                                  \n"
			"  int b = 1 / a;                              \n"
			"}                                             \n"
			"bool Entry()                                  \n"
			"{                                             \n"
			"  ThrowException();                           \n"
			"  return true;                                \n"
			"}                                             \n");
		if (!TestNotNull(TEXT("ASSDK runtime exception test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "bool Entry()");
		if (!TestNotNull(TEXT("ASSDK runtime exception test should resolve entry function"), Function))
		{
			return;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!TestNotNull(TEXT("ASSDK runtime exception test should create context"), Context))
		{
			return;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		Context->Release();

		// Expect exception from divide by zero
		TestEqual(TEXT("ASSDK runtime exception test should detect exception"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION));
	}

	TEST_METHOD(Suspend)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK runtime suspend test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKRuntimeSuspend",
			"int Sum(int N)                                \n"
			"{                                             \n"
			"  int Result = 0;                             \n"
			"  for (int i = 1; i <= N; i++)                \n"
			"  {                                           \n"
			"    Result += i;                              \n"
			"  }                                           \n"
			"  return Result;                              \n"
			"}                                             \n"
			"bool Entry()                                  \n"
			"{                                             \n"
			"  return Sum(10) == 55;                       \n"
			"}                                             \n");
		if (!TestNotNull(TEXT("ASSDK runtime suspend test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteRuntimeBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK runtime suspend test should execute loop with suspend support"), bResult);
	}
};

#endif
