#include "AngelscriptNativeTestSupport.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

TEST_CLASS_WITH_FLAGS(FAngelscriptNativeCompileTests,
	"Angelscript.TestModule.AngelScriptSDK.Compile",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(SimpleFunction)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Native compile simple-function test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "NativeCompileSimpleFunction", "int Test() { return 42; }");
		if (!TestRunner->TestNotNull(TEXT("Native compile simple-function test should compile a trivial function"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		TestRunner->TestNotNull(TEXT("Native compile simple-function test should expose the compiled function"), GetNativeFunctionByDecl(Module, "int Test()"));
	}

	TEST_METHOD(MultipleFunctions)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Native compile multiple-functions test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "NativeCompileMultipleFunctions", "void A() {} void B() {} int C() { return 42; }");
		if (!TestRunner->TestNotNull(TEXT("Native compile multiple-functions test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		TestRunner->TestEqual(TEXT("Native compile multiple-functions test should expose every compiled function"), static_cast<int32>(Module->GetFunctionCount()), 3);
	}

	TEST_METHOD(GlobalVariables)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Native compile global-variables test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "NativeCompileGlobalVariables", "const int First = 40; const int Second = 2; int Read() { return First + Second; }");
		if (!TestRunner->TestNotNull(TEXT("Native compile global-variables test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		TestRunner->TestEqual(TEXT("Native compile global-variables test should preserve both global declarations"), static_cast<int32>(Module->GetGlobalVarCount()), 2);
	}

	TEST_METHOD(SyntaxError)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Native compile syntax-error test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = nullptr;
		const int BuildResult = CompileNativeModule(ScriptEngine, "NativeCompileSyntaxError", "int Broken( { return 1; }", Module);
		if (!TestRunner->TestTrue(TEXT("Native compile syntax-error test should fail with a negative build result"), BuildResult < 0))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		TestRunner->TestNotNull(TEXT("Native compile syntax-error test should still expose a module handle for diagnostics"), Module);
	}

	TEST_METHOD(ErrorMessage)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Native compile error-message test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = nullptr;
		const int BuildResult = CompileNativeModule(ScriptEngine, "NativeCompileErrorMessage", "int Broken( { return 1; }", Module);
		if (!TestRunner->TestTrue(TEXT("Native compile error-message test should fail with a negative build result"), BuildResult < 0))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		if (!TestRunner->TestTrue(TEXT("Native compile error-message test should capture at least one diagnostic entry"), Messages.Entries.Num() > 0))
		{
			return;
		}

		const FNativeMessageEntry& FirstMessage = Messages.Entries[0];
		TestRunner->TestTrue(TEXT("Native compile error-message test should capture a non-empty message text"), !FirstMessage.Message.IsEmpty());
		TestRunner->TestTrue(TEXT("Native compile error-message test should capture a valid source row"), FirstMessage.Row > 0);
		TestRunner->TestTrue(TEXT("Native compile error-message test should format the diagnostics for debugging"), !CollectMessages(Messages).IsEmpty());
	}
};

#endif
