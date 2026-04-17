#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKModuleCreateTest,
	"Angelscript.TestModule.Native.ASSDK.Module.Create",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKModuleDiscardTest,
	"Angelscript.TestModule.Native.ASSDK.Module.Discard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKModuleMultiTest,
	"Angelscript.TestModule.Native.ASSDK.Module.Multi",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKModuleTests_Private
{
	bool ExecuteModuleBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Module test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Module test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Module test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKModuleTests_Private;

bool FAngelscriptASSDKModuleCreateTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK module create test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = ScriptEngine->GetModule("ASSDKModuleCreate", asGM_ALWAYS_CREATE);
	if (!TestNotNull(TEXT("ASSDK module create test should create a module"), Module))
	{
		return false;
	}

	const int AddResult = Module->AddScriptSection("test", "const int Value = 42; bool Entry() { return Value == 42; }");
	if (!TestTrue(TEXT("ASSDK module create test should add script section"), AddResult >= 0))
	{
		return false;
	}

	const int BuildResult = Module->Build();
	if (!TestEqual(TEXT("ASSDK module create test should build successfully"), BuildResult, 0))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "bool Entry()");
	return TestNotNull(TEXT("ASSDK module create test should find entry function"), Function);
}

bool FAngelscriptASSDKModuleDiscardTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK module discard test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKModuleDiscard",
		"const int Value = 100;                         \n");
	if (!TestNotNull(TEXT("ASSDK module discard test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	// Discard the module
	ScriptEngine->DiscardModule("ASSDKModuleDiscard");

	// Verify module is gone
	asIScriptModule* DiscardedModule = ScriptEngine->GetModule("ASSDKModuleDiscard", asGM_ONLY_IF_EXISTS);
	return TestNull(TEXT("ASSDK module discard test should discard the module"), DiscardedModule);
}

bool FAngelscriptASSDKModuleMultiTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK module multi test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	// Create first module
	asIScriptModule* Module1 = BuildNativeModule(
		ScriptEngine,
		"ASSDKModuleMulti1",
		"int GetValue() { return 1; }                   \n");
	if (!TestNotNull(TEXT("ASSDK module multi test should compile first module"), Module1))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	// Create second module
	asIScriptModule* Module2 = BuildNativeModule(
		ScriptEngine,
		"ASSDKModuleMulti2",
		"int GetValue() { return 2; }                   \n");
	if (!TestNotNull(TEXT("ASSDK module multi test should compile second module"), Module2))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	// Verify both modules exist and have distinct functions
	asIScriptFunction* Func1 = GetNativeFunctionByDecl(Module1, "int GetValue()");
	asIScriptFunction* Func2 = GetNativeFunctionByDecl(Module2, "int GetValue()");

	if (!TestNotNull(TEXT("ASSDK module multi test should find first module function"), Func1))
	{
		return false;
	}

	if (!TestNotNull(TEXT("ASSDK module multi test should find second module function"), Func2))
	{
		return false;
	}

	return TestNotEqual(TEXT("ASSDK module multi test should have distinct functions"), Func1, Func2);
}

#endif
