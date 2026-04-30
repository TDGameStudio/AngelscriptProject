// AngelscriptASSDKVariableScopeTests.cpp
// Tests for as_variablescope.cpp - variable scope isolation and shadowing.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.VariableScope.*

#include "AngelscriptNativeTestSupport.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_AngelScriptSDK_VariableScope_Private
{
	bool ExecuteIntEntry(FAutomationTestBase& Test, asIScriptEngine* SE, asIScriptModule* M, int32& Out)
	{
		asIScriptFunction* Func = GetNativeFunctionByDecl(M, "int Entry()");
		if (!Test.TestNotNull(TEXT("Should resolve Entry"), Func)) return false;
		asIScriptContext* Ctx = SE->CreateContext();
		if (!Test.TestNotNull(TEXT("Should create context"), Ctx)) return false;
		const int Ret = PrepareAndExecute(Ctx, Func);
		Out = static_cast<int32>(Ctx->GetReturnDWord());
		Ctx->Release();
		return Test.TestEqual(TEXT("Should finish"), Ret, (int32)asEXECUTION_FINISHED);
	}
}


TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKVariableScopeTests, "Angelscript.TestModule.AngelScriptSDK.VariableScope", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Isolation)
	{
		using namespace AngelscriptTest_AngelScriptSDK_VariableScope_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		// Variable declared in inner scope should not be visible in outer scope
		Messages.Reset();
		asIScriptModule* M = BuildNativeModule(SE, "ScopeIso", R"(
int Entry()
{
	{ int x = 5; }
	return x;
}
)");
		TestNull(TEXT("Access to out-of-scope variable should fail compilation"), M);
	}

	TEST_METHOD(Shadowing)
	{
		using namespace AngelscriptTest_AngelScriptSDK_VariableScope_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		asIScriptModule* M = BuildNativeModule(SE, "ScopeShadow", R"(
int Entry()
{
	int x = 10;
	{ int x = 20; }
	return x;
}
)");
		if (!TestRunner->TestNotNull(TEXT("Shadowing should compile"), M))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteIntEntry(*TestRunner, SE, M, Result)) return;
		TestRunner->TestEqual(TEXT("Outer x should remain 10 after inner shadow"), Result, 10);
	}

	TEST_METHOD(NestedBlocks)
	{
		using namespace AngelscriptTest_AngelScriptSDK_VariableScope_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		asIScriptModule* M = BuildNativeModule(SE, "ScopeNested", R"(
int Entry()
{
	int sum = 0;
	{ int a = 1; sum += a; }
	{ int b = 2; sum += b; }
	{ int c = 3; { int d = 4; sum += d; } sum += c; }
	return sum;
}
)");
		if (!TestRunner->TestNotNull(TEXT("Nested blocks should compile"), M))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteIntEntry(*TestRunner, SE, M, Result)) return;
		TestRunner->TestEqual(TEXT("sum = 1+2+4+3 = 10"), Result, 10);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
