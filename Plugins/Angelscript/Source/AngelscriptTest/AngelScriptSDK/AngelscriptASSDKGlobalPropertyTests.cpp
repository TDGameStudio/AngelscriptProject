// AngelscriptASSDKGlobalPropertyTests.cpp
// Tests for as_globalproperty.cpp - global variable registration and access.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.GlobalProperty.*

#include "AngelscriptNativeTestSupport.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_AngelScriptSDK_GlobalProperty_Private
{
	static int32 GTestValue = 0;
	static int32 GTestA = 0;
	static int32 GTestB = 0;

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

	void ExecuteVoidEntry(FAutomationTestBase& Test, asIScriptEngine* SE, asIScriptModule* M)
	{
		asIScriptFunction* Func = GetNativeFunctionByDecl(M, "void Entry()");
		if (!Test.TestNotNull(TEXT("Should resolve Entry"), Func)) return;
		asIScriptContext* Ctx = SE->CreateContext();
		if (!Test.TestNotNull(TEXT("Should create context"), Ctx)) return;
		PrepareAndExecute(Ctx, Func);
		Ctx->Release();
	}
}

using namespace AngelscriptTest_AngelScriptSDK_GlobalProperty_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKGlobalPropertyTests,
	"Angelscript.TestModule.AngelScriptSDK.GlobalProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(ScriptReads)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		GTestValue = 42;
		int R = SE->RegisterGlobalProperty("int GTestValue", &GTestValue);
		TestTrue(TEXT("RegisterGlobalProperty should succeed"), R >= 0);

		asIScriptModule* M = BuildNativeModule(SE, "GPRead", "int Entry() { return GTestValue; }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }

		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, Result)) return;
		TestEqual(TEXT("Script should read C++ global value 42"), Result, 42);
	}

	TEST_METHOD(ScriptWrites)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		GTestValue = 0;
		SE->RegisterGlobalProperty("int GTestValue", &GTestValue);

		asIScriptModule* M = BuildNativeModule(SE, "GPWrite", "void Entry() { GTestValue = 99; }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }

		ExecuteVoidEntry(*this, SE, M);
		TestEqual(TEXT("C++ should see script-written value 99"), GTestValue, 99);
	}

	TEST_METHOD(MultipleGlobals)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

		GTestA = 10;
		GTestB = 20;
		SE->RegisterGlobalProperty("int GTestA", &GTestA);
		SE->RegisterGlobalProperty("int GTestB", &GTestB);

		asIScriptModule* M = BuildNativeModule(SE, "GPMulti", "int Entry() { return GTestA + GTestB; }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }

		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, Result)) return;
		TestEqual(TEXT("Script reads both globals: 10+20=30"), Result, 30);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
