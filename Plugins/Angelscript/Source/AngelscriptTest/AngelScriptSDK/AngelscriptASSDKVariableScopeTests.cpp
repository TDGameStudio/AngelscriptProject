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

using namespace AngelscriptTest_AngelScriptSDK_VariableScope_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKVariableScopeTests, "Angelscript.TestModule.AngelScriptSDK.VariableScope", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Isolation)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		// Variable declared in inner scope should not be visible in outer scope
		Messages.Reset();
		asIScriptModule* M = BuildNativeModule(SE, "ScopeIso",
			"int Entry() { { int x = 5; } return x; }\n");
		TestNull(TEXT("Access to out-of-scope variable should fail compilation"), M);
	}

	TEST_METHOD(Shadowing)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		asIScriptModule* M = BuildNativeModule(SE, "ScopeShadow",
			"int Entry() {\n"
			"  int x = 10;\n"
			"  { int x = 20; }\n"
			"  return x;\n"
			"}\n");
		if (!TestNotNull(TEXT("Shadowing should compile"), M))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, Result)) return;
		TestEqual(TEXT("Outer x should remain 10 after inner shadow"), Result, 10);
	}

	TEST_METHOD(NestedBlocks)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		asIScriptModule* M = BuildNativeModule(SE, "ScopeNested",
			"int Entry() {\n"
			"  int sum = 0;\n"
			"  { int a = 1; sum += a; }\n"
			"  { int b = 2; sum += b; }\n"
			"  { int c = 3; { int d = 4; sum += d; } sum += c; }\n"
			"  return sum;\n"
			"}\n");
		if (!TestNotNull(TEXT("Nested blocks should compile"), M))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, Result)) return;
		TestEqual(TEXT("sum = 1+2+4+3 = 10"), Result, 10);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
