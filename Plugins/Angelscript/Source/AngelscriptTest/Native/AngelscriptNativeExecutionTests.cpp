#include "AngelscriptNativeTestSupport.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeExecuteVoidFunctionTest,
	"Angelscript.TestModule.Native.Execute.VoidFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeExecuteReturnValueTest,
	"Angelscript.TestModule.Native.Execute.ReturnValue",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeExecuteOneArgTest,
	"Angelscript.TestModule.Native.Execute.OneArg",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeExecuteTwoArgsTest,
	"Angelscript.TestModule.Native.Execute.TwoArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNativeExecuteThreeArgsTest,
	"Angelscript.TestModule.Native.Execute.ThreeArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptNativeExecutionTests_Private
{
	bool CreateEngineAndBuildModule(
		FAutomationTestBase& Test,
		const char* ModuleName,
		const char* Source,
		FNativeMessageCollector& OutMessages,
		asIScriptEngine*& OutScriptEngine,
		asIScriptModule*& OutModule)
	{
		OutScriptEngine = CreateNativeEngine(&OutMessages);
		if (!Test.TestNotNull(TEXT("Native execution tests should create a standalone AngelScript engine"), OutScriptEngine))
		{
			return false;
		}

		OutModule = BuildNativeModule(OutScriptEngine, ModuleName, Source);
		if (!Test.TestNotNull(TEXT("Native execution tests should compile the requested module from memory"), OutModule))
		{
			Test.AddInfo(CollectMessages(OutMessages));
			return false;
		}

		return true;
	}
}

using namespace AngelscriptTest_Native_AngelscriptNativeExecutionTests_Private;

bool FAngelscriptNativeExecuteVoidFunctionTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = nullptr;
	asIScriptModule* Module = nullptr;
	if (!CreateEngineAndBuildModule(*this, "NativeExecuteVoid", "void Test() {}", Messages, ScriptEngine, Module))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "void Test()");
	if (!TestNotNull(TEXT("Native void execution test should resolve the entry function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("Native void execution test should create a context"), Context))
	{
		return false;
	}

	const int ExecuteResult = PrepareAndExecute(Context, Function);
	Context->Release();
	return TestEqual(TEXT("Native void execution test should finish successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
}

bool FAngelscriptNativeExecuteReturnValueTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = nullptr;
	asIScriptModule* Module = nullptr;
	if (!CreateEngineAndBuildModule(*this, "NativeExecuteReturn", "int Test() { return 42; }", Messages, ScriptEngine, Module))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "int Test()");
	if (!TestNotNull(TEXT("Native return-value execution test should resolve the entry function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("Native return-value execution test should create a context"), Context))
	{
		return false;
	}

	const int ExecuteResult = PrepareAndExecute(Context, Function);
	TestEqual(TEXT("Native return-value execution test should finish successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestEqual(TEXT("Native return-value execution test should return 42"), static_cast<int32>(Context->GetReturnDWord()), 42);
	Context->Release();
	return ExecuteResult == asEXECUTION_FINISHED;
}

bool FAngelscriptNativeExecuteOneArgTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = nullptr;
	asIScriptModule* Module = nullptr;
	if (!CreateEngineAndBuildModule(*this, "NativeExecuteOneArg", "int Test(int Value) { return Value * 2; }", Messages, ScriptEngine, Module))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "int Test(int)");
	if (!TestNotNull(TEXT("Native one-arg execution test should resolve the entry function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("Native one-arg execution test should create a context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	if (!TestEqual(TEXT("Native one-arg execution test should prepare the function"), PrepareResult, static_cast<int32>(asSUCCESS)))
	{
		Context->Release();
		return false;
	}

	Context->SetArgDWord(0, 21);
	const int ExecuteResult = Context->Execute();
	TestEqual(TEXT("Native one-arg execution test should finish successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestEqual(TEXT("Native one-arg execution test should preserve the provided input"), static_cast<int32>(Context->GetReturnDWord()), 42);
	Context->Release();
	return ExecuteResult == asEXECUTION_FINISHED;
}

bool FAngelscriptNativeExecuteTwoArgsTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = nullptr;
	asIScriptModule* Module = nullptr;
	if (!CreateEngineAndBuildModule(*this, "NativeExecuteTwoArgs", "int Test(int A, int B) { return A + B; }", Messages, ScriptEngine, Module))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "int Test(int, int)");
	if (!TestNotNull(TEXT("Native two-arg execution test should resolve the entry function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("Native two-arg execution test should create a context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	if (!TestEqual(TEXT("Native two-arg execution test should prepare the function"), PrepareResult, static_cast<int32>(asSUCCESS)))
	{
		Context->Release();
		return false;
	}

	Context->SetArgDWord(0, 20);
	Context->SetArgDWord(1, 22);
	const int ExecuteResult = Context->Execute();
	TestEqual(TEXT("Native two-arg execution test should finish successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestEqual(TEXT("Native two-arg execution test should sum both arguments"), static_cast<int32>(Context->GetReturnDWord()), 42);
	Context->Release();
	return ExecuteResult == asEXECUTION_FINISHED;
}

bool FAngelscriptNativeExecuteThreeArgsTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = nullptr;
	asIScriptModule* Module = nullptr;
	if (!CreateEngineAndBuildModule(*this, "NativeExecuteThreeArgs", "int Test(int A, int B, int C) { return A + B + C; }", Messages, ScriptEngine, Module))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptFunction* Function = GetNativeFunctionByDecl(Module, "int Test(int, int, int)");
	if (!TestNotNull(TEXT("Native three-arg execution test should resolve the entry function"), Function))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("Native three-arg execution test should create a context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(Function);
	if (!TestEqual(TEXT("Native three-arg execution test should prepare the function"), PrepareResult, static_cast<int32>(asSUCCESS)))
	{
		Context->Release();
		return false;
	}

	Context->SetArgDWord(0, 10);
	Context->SetArgDWord(1, 20);
	Context->SetArgDWord(2, 12);
	const int ExecuteResult = Context->Execute();
	TestEqual(TEXT("Native three-arg execution test should finish successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestEqual(TEXT("Native three-arg execution test should sum all arguments"), static_cast<int32>(Context->GetReturnDWord()), 42);
	Context->Release();
	return ExecuteResult == asEXECUTION_FINISHED;
}

#endif
