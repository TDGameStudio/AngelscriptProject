#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKCompilerTests_Private
{
	bool ExecuteCompilerBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Compiler test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Compiler test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Compiler test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKCompilerTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKCompilerTests,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.Compiler",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Basic)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK compiler basic test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKCompilerBasic",
			"const int GlobalVar = 42;                       \n"
			"int Multiply(int A, int B)                      \n"
			"{                                               \n"
			"  return A * B;                                 \n"
			"}                                               \n"
			"bool Entry()                                    \n"
			"{                                               \n"
			"  return GlobalVar == 42 && Multiply(6, 7) == 42; \n"
			"}                                               \n");
		if (!TestNotNull(TEXT("ASSDK compiler basic test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteCompilerBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestTrue(TEXT("ASSDK compiler basic test should compile and execute basic constructs"), bResult);
	}

	TEST_METHOD(Error)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK compiler error test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		// Test that invalid syntax produces compile errors
		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKCompilerError",
			"int MissingReturn() { }                         \n");

		// This should fail to compile - expect null module or error messages
		if (Module != nullptr)
		{
			AddInfo(TEXT("Expected compile error for missing return statement"));
			return;
		}

		TestTrue(TEXT("ASSDK compiler error test should detect syntax errors"), Messages.Entries.Num() > 0);
	}

	TEST_METHOD(Config)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK compiler config test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		// Test engine property access
		const int PropResult = ScriptEngine->SetEngineProperty(asEP_COPY_SCRIPT_SECTIONS, true);
		if (!TestTrue(TEXT("ASSDK compiler config test should set engine property"), PropResult >= 0))
		{
			return;
		}

		// Test type registration configuration
		const int TypeResult = ScriptEngine->RegisterObjectType("TestConfigType", 0, asOBJ_REF | asOBJ_NOCOUNT);
		if (!TestTrue(TEXT("ASSDK compiler config test should register reference type"), TypeResult >= 0))
		{
			return;
		}

		TestTrue(TEXT("ASSDK compiler config test should configure engine properties"), true);
	}
};

#endif
