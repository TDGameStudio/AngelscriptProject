// AngelscriptASSDKCallFuncTests.cpp
// Tests for as_callfunc.cpp - native function call dispatch edge cases.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.CallFunc.*

#include "AngelscriptNativeTestSupport.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKCallFuncMultipleArgsTest,
	"Angelscript.TestModule.AngelScriptSDK.CallFunc.MultipleArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKCallFuncFloatPrecisionTest,
	"Angelscript.TestModule.AngelScriptSDK.CallFunc.FloatPrecision",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKCallFuncVoidSideEffectTest,
	"Angelscript.TestModule.AngelScriptSDK.CallFunc.VoidSideEffect",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKCallFuncNestedCallTest,
	"Angelscript.TestModule.AngelScriptSDK.CallFunc.NestedCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKCallFuncManyArgsTest,
	"Angelscript.TestModule.AngelScriptSDK.CallFunc.ManyArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_AngelScriptSDK_CallFunc_Private
{
	int32 AddFour(int32 A, int32 B, int32 C, int32 D) { return A + B + C + D; }
	double MultiplyDouble(double A, double B) { return A * B; }
	static int32 GSideEffectAccumulator = 0;
	void AccumulateValue(int32 Value) { GSideEffectAccumulator += Value; }
	int32 IncrementAndReturn(int32 Value) { return Value + 1; }
	int32 SumSix(int32 A, int32 B, int32 C, int32 D, int32 E, int32 F) { return A+B+C+D+E+F; }

	bool RegisterHelpers(FAutomationTestBase& Test, asIScriptEngine* SE)
	{
		ASAutoCaller::FunctionCaller Caller;
		int R;
		Caller = ASAutoCaller::MakeFunctionCaller(AddFour);
		R = SE->RegisterGlobalFunction("int AddFour(int,int,int,int)", asFUNCTION(AddFour), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (R < 0) { Test.AddError(TEXT("Failed register AddFour")); return false; }
		Caller = ASAutoCaller::MakeFunctionCaller(MultiplyDouble);
		R = SE->RegisterGlobalFunction("double MultiplyDouble(double,double)", asFUNCTION(MultiplyDouble), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (R < 0) { Test.AddError(TEXT("Failed register MultiplyDouble")); return false; }
		Caller = ASAutoCaller::MakeFunctionCaller(AccumulateValue);
		R = SE->RegisterGlobalFunction("void AccumulateValue(int)", asFUNCTION(AccumulateValue), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (R < 0) { Test.AddError(TEXT("Failed register AccumulateValue")); return false; }
		Caller = ASAutoCaller::MakeFunctionCaller(IncrementAndReturn);
		R = SE->RegisterGlobalFunction("int IncrementAndReturn(int)", asFUNCTION(IncrementAndReturn), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (R < 0) { Test.AddError(TEXT("Failed register IncrementAndReturn")); return false; }
		Caller = ASAutoCaller::MakeFunctionCaller(SumSix);
		R = SE->RegisterGlobalFunction("int SumSix(int,int,int,int,int,int)", asFUNCTION(SumSix), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (R < 0) { Test.AddError(TEXT("Failed register SumSix")); return false; }
		return true;
	}

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
}

using namespace AngelscriptTest_AngelScriptSDK_CallFunc_Private;

bool FAngelscriptASSDKCallFuncMultipleArgsTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
	if (!RegisterHelpers(*this, SE)) return false;
	asIScriptModule* M = BuildNativeModule(SE, "CallFuncMultiArgs", "int Entry() { return AddFour(10, 20, 30, 40); }\n");
	if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return false; }
	int32 Result = 0;
	if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return false;
	return TestEqual(TEXT("AddFour(10,20,30,40)=100"), Result, 100);
}

bool FAngelscriptASSDKCallFuncFloatPrecisionTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
	if (!RegisterHelpers(*this, SE)) return false;
	asIScriptModule* M = BuildNativeModule(SE, "CallFuncFloat", "double Entry() { return MultiplyDouble(3.14159, 2.0); }\n");
	if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return false; }
	asIScriptFunction* Func = GetNativeFunctionByDecl(M, "double Entry()");
	if (!TestNotNull(TEXT("Should resolve"), Func)) return false;
	asIScriptContext* Ctx = SE->CreateContext();
	if (!TestNotNull(TEXT("Context"), Ctx)) return false;
	int Ret = PrepareAndExecute(Ctx, Func);
	double Result = Ctx->GetReturnDouble();
	Ctx->Release();
	TestEqual(TEXT("Finished"), Ret, (int32)asEXECUTION_FINISHED);
	TestTrue(TEXT("MultiplyDouble precision"), FMath::IsNearlyEqual(Result, 3.14159*2.0, 1e-10));
	return true;
}

bool FAngelscriptASSDKCallFuncVoidSideEffectTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
	GSideEffectAccumulator = 0;
	if (!RegisterHelpers(*this, SE)) return false;
	asIScriptModule* M = BuildNativeModule(SE, "CallFuncVoid", "void Entry() { AccumulateValue(10); AccumulateValue(20); AccumulateValue(12); }\n");
	if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return false; }
	asIScriptFunction* Func = GetNativeFunctionByDecl(M, "void Entry()");
	if (!TestNotNull(TEXT("Should resolve"), Func)) return false;
	asIScriptContext* Ctx = SE->CreateContext();
	if (!TestNotNull(TEXT("Context"), Ctx)) return false;
	int Ret = PrepareAndExecute(Ctx, Func);
	Ctx->Release();
	TestEqual(TEXT("Finished"), Ret, (int32)asEXECUTION_FINISHED);
	TestEqual(TEXT("Accumulator=42"), GSideEffectAccumulator, 42);
	return true;
}

bool FAngelscriptASSDKCallFuncNestedCallTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
	if (!RegisterHelpers(*this, SE)) return false;
	asIScriptModule* M = BuildNativeModule(SE, "CallFuncNested", "int Entry() { return IncrementAndReturn(IncrementAndReturn(IncrementAndReturn(0))); }\n");
	if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return false; }
	int32 Result = 0;
	if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return false;
	return TestEqual(TEXT("Nested 3x increment = 3"), Result, 3);
}

bool FAngelscriptASSDKCallFuncManyArgsTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };
	if (!RegisterHelpers(*this, SE)) return false;
	asIScriptModule* M = BuildNativeModule(SE, "CallFuncManyArgs", "int Entry() { return SumSix(1, 2, 3, 4, 5, 6); }\n");
	if (!TestNotNull(TEXT("Should compile"), M)) { AddInfo(CollectMessages(Messages)); return false; }
	int32 Result = 0;
	if (!ExecuteIntEntry(*this, SE, M, "int Entry()", Result)) return false;
	return TestEqual(TEXT("SumSix(1..6)=21"), Result, 21);
}

#endif // WITH_DEV_AUTOMATION_TESTS
