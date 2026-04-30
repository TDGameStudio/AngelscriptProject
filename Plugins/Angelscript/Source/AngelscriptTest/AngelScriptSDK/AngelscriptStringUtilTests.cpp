// AngelscriptASSDKStringUtilTests.cpp
// Tests for as_string_util.cpp - number/string conversion via script.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.StringUtil.*

#include "AngelscriptNativeTestSupport.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"

// TODO: RegisterStringFactory API differs between AS 2.33 fork and AS 2.38.
//       These tests use the 2.38-style 3-arg RegisterStringFactory which our
//       fork doesn't support. Disabled until the API gap is resolved.
#if 0 // WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private
{
	bool ExecuteIntEntry(FAutomationTestBase& Test, asIScriptEngine* SE, asIScriptModule* M, const char* Decl, int32& Out)
	{
		asIScriptFunction* Func = GetNativeFunctionByDecl(M, Decl);
		if (!Test.TestNotNull(TEXT("Should resolve function"), Func)) return false;
		asIScriptContext* Ctx = SE->CreateContext();
		if (!Test.TestNotNull(TEXT("Should create context"), Ctx)) return false;
		const int Ret = PrepareAndExecute(Ctx, Func);
		Out = static_cast<int32>(Ctx->GetReturnDWord());
		Ctx->Release();
		return Test.TestEqual(TEXT("Execution should finish"), Ret, (int32)asEXECUTION_FINISHED);
	}

	bool ExecuteDoubleEntry(FAutomationTestBase& Test, asIScriptEngine* SE, asIScriptModule* M, const char* Decl, double& Out)
	{
		asIScriptFunction* Func = GetNativeFunctionByDecl(M, Decl);
		if (!Test.TestNotNull(TEXT("Should resolve function"), Func)) return false;
		asIScriptContext* Ctx = SE->CreateContext();
		if (!Test.TestNotNull(TEXT("Should create context"), Ctx)) return false;
		const int Ret = PrepareAndExecute(Ctx, Func);
		Out = Ctx->GetReturnDouble();
		Ctx->Release();
		return Test.TestEqual(TEXT("Execution should finish"), Ret, (int32)asEXECUTION_FINISHED);
	}

	void RegisterStringFactory(asIScriptEngine* SE)
	{
		SE->RegisterObjectType("string", sizeof(std::string), asOBJ_VALUE | asGetTypeTraits<std::string>());
		SE->RegisterStringFactory("string", asFUNCTION(+[](asUINT Length, const char* Data) -> std::string {
			return std::string(Data, Length);
		}), asCALL_CDECL);
		SE->RegisterObjectBehaviour("string", asBEHAVE_CONSTRUCT, "void f()",
			asFUNCTION(+[](std::string* P) { new(P) std::string(); }), asCALL_CDECL_OBJFIRST);
		SE->RegisterObjectBehaviour("string", asBEHAVE_DESTRUCT, "void f()",
			asFUNCTION(+[](std::string* P) { using T = std::string; P->~T(); }), asCALL_CDECL_OBJFIRST);
		SE->RegisterObjectMethod("string", "int parseInt(uint Base = 10) const",
			asFUNCTION(+[](const std::string& S, asUINT Base) -> int {
				return (int)std::strtol(S.c_str(), nullptr, (int)Base);
			}), asCALL_CDECL_OBJFIRST);
		SE->RegisterObjectMethod("string", "double parseFloat() const",
			asFUNCTION(+[](const std::string& S) -> double {
				return std::strtod(S.c_str(), nullptr);
			}), asCALL_CDECL_OBJFIRST);
	}
}


TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKStringUtilTests, "Angelscript.TestModule.AngelScriptSDK.StringUtil", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(ParseInt)
	{
		using namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
		RegisterStringFactory(SE);
		asIScriptModule* M = BuildNativeModule(SE, "StrUtilPI", "int Entry() { string s = \"42\"; return s.parseInt(); }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }
		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return;
		TestEqual(TEXT("parseInt 42"), Result, 42);
	}

	TEST_METHOD(ParseNegativeInt)
	{
		using namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
		RegisterStringFactory(SE);
		asIScriptModule* M = BuildNativeModule(SE, "StrUtilNI", "int Entry() { string s = \"-100\"; return s.parseInt(); }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }
		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return;
		TestEqual(TEXT("parseInt -100"), Result, -100);
	}

	TEST_METHOD(ParseFloat)
	{
		using namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
		RegisterStringFactory(SE);
		asIScriptModule* M = BuildNativeModule(SE, "StrUtilPF", "double Entry() { string s = \"3.14\"; return s.parseFloat(); }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }
		double Result = 0.0;
		if (!ExecuteDoubleEntry(*this, SE, M, "double Entry()", Result)) return;
		TestTrue(TEXT("parseFloat 3.14"), FMath::IsNearlyEqual(Result, 3.14, 0.001));
	}

	TEST_METHOD(ParseZero)
	{
		using namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
		RegisterStringFactory(SE);
		asIScriptModule* M = BuildNativeModule(SE, "StrUtilZ", "int Entry() { string s = \"0\"; return s.parseInt(); }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }
		int32 Result = -1;
		if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return;
		TestEqual(TEXT("parseInt 0"), Result, 0);
	}

	TEST_METHOD(LargeValue)
	{
		using namespace AngelscriptTest_AngelScriptSDK_StringUtil_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SE = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("Should create engine"), SE)) return;
		ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
		RegisterStringFactory(SE);
		asIScriptModule* M = BuildNativeModule(SE, "StrUtilLV", "int Entry() { string s = \"2147483647\"; return s.parseInt(); }\n");
		if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return; }
		int32 Result = 0;
		if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return;
		TestEqual(TEXT("parseInt INT32_MAX"), Result, 2147483647);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
