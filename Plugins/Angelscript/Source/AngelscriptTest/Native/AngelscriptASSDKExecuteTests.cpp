#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#include <cstring>

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKExecuteBasicCallbackTest,
	"Angelscript.TestModule.Native.ASSDK.Execute.BasicCallback",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKExecuteOneArgTest,
	"Angelscript.TestModule.Native.ASSDK.Execute.OneArg",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKExecuteTwoArgsTest,
	"Angelscript.TestModule.Native.ASSDK.Execute.TwoArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKExecuteFourArgsTest,
	"Angelscript.TestModule.Native.ASSDK.Execute.FourArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKExecuteFloatArgsTest,
	"Angelscript.TestModule.Native.ASSDK.Execute.FloatArgs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKExecuteTests_Private
{
	bool GCalled = false;
	int32 GIntResult = 0;
	bool GCleanupCalled = false;
	bool GCleanupUserDataMatched = false;
	int32 GFourArgInt = 0;
	int32 GFourArgShort = 0;
	int32 GFourArgByte = 0;
	int32 GFourArgTail = 0;
	float GFloatArgA = 0.0f;
	float GFloatArgB = 0.0f;
	double GFloatArgC = 0.0;
	float GFloatArgD = 0.0f;
	double GDoubleArgA = 0.0;
	double GDoubleArgB = 0.0;
	double GDoubleArgC = 0.0;
	double GDoubleArgD = 0.0;

	void ResetExecuteState()
	{
		GCalled = false;
		GIntResult = 0;
		GCleanupCalled = false;
		GCleanupUserDataMatched = false;
		GFourArgInt = 0;
		GFourArgShort = 0;
		GFourArgByte = 0;
		GFourArgTail = 0;
		GFloatArgA = 0.0f;
		GFloatArgB = 0.0f;
		GFloatArgC = 0.0;
		GFloatArgD = 0.0f;
		GDoubleArgA = 0.0;
		GDoubleArgB = 0.0;
		GDoubleArgC = 0.0;
		GDoubleArgD = 0.0;
	}

	bool UsesMaxPortability()
	{
		return std::strstr(asGetLibraryOptions(), "AS_MAX_PORTABILITY") != nullptr;
	}

	void CFunctionBasic()
	{
		GCalled = true;
	}

	void CFunctionBasicGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionBasic();
		}
	}

	void CleanupContext(asIScriptContext* Context)
	{
		GCleanupCalled = true;
		GCleanupUserDataMatched = Context != nullptr && Context->GetUserData() == reinterpret_cast<void*>(static_cast<SIZE_T>(0xDEADF00D));
	}

	void CFunctionOneArg(int Value)
	{
		GCalled = true;
		GIntResult = Value;
	}

	void CFunctionOneArgGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionOneArg(static_cast<int>(Generic->GetArgDWord(0)));
		}
	}

	void CFunctionTwoArgs(int A, int B)
	{
		GCalled = true;
		GIntResult = A + B;
	}

	void CFunctionTwoArgsGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionTwoArgs(static_cast<int>(Generic->GetArgDWord(0)), static_cast<int>(Generic->GetArgDWord(1)));
		}
	}

	void CFunctionFourArgs(int A, short B, char C, int D)
	{
		GCalled = true;
		GFourArgInt = A;
		GFourArgShort = B;
		GFourArgByte = C;
		GFourArgTail = D;
	}

	void CFunctionFourArgsGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionFourArgs(
				static_cast<int>(Generic->GetArgDWord(0)),
				*static_cast<short*>(Generic->GetAddressOfArg(1)),
				*static_cast<char*>(Generic->GetAddressOfArg(2)),
				static_cast<int>(Generic->GetArgDWord(3)));
		}
	}

	void CFunctionFloatArgs(float A, float B, double C, float D)
	{
		GCalled = true;
		GFloatArgA = A;
		GFloatArgB = B;
		GFloatArgC = C;
		GFloatArgD = D;
	}

	void CFunctionDoubleArgs(double A, double B, double C, double D)
	{
		GCalled = true;
		GDoubleArgA = A;
		GDoubleArgB = B;
		GDoubleArgC = C;
		GDoubleArgD = D;
	}

	void CFunctionFloatArgsGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionFloatArgs(
				Generic->GetArgFloat(0),
				Generic->GetArgFloat(1),
				Generic->GetArgDouble(2),
				Generic->GetArgFloat(3));
		}
	}

	void CFunctionDoubleArgsGeneric(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			CFunctionDoubleArgs(
				Generic->GetArgDouble(0),
				Generic->GetArgDouble(1),
				Generic->GetArgDouble(2),
				Generic->GetArgDouble(3));
		}
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKExecuteTests_Private;

bool FAngelscriptASSDKExecuteBasicCallbackTest::RunTest(const FString& Parameters)
{
	ResetExecuteState();
	FAngelscriptSDKTestAdapter Adapter(*this);
	asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter);
	if (!TestNotNull(TEXT("ASSDK execute basic-callback test should create a script engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		AngelscriptNativeTestSupport::DestroyNativeEngine(ScriptEngine);
	};

	const int RegisterResult = UsesMaxPortability()
		? ScriptEngine->RegisterGlobalFunction("void cfunction()", asFUNCTION(CFunctionBasicGeneric), asCALL_GENERIC)
		: [&]()
		{
			const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(CFunctionBasic);
			return ScriptEngine->RegisterGlobalFunction("void cfunction()", asFUNCTION(CFunctionBasic), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		}();
	if (!TestEqual(TEXT("ASSDK execute basic-callback test should register the callback"), RegisterResult >= 0, true))
	{
		return false;
	}

	const int ExecuteResult = ASSDKExecuteString(ScriptEngine, "cfunction();");
	if (!TestEqual(TEXT("ASSDK execute basic-callback test should execute a statement snippet"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED)))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK execute basic-callback test should call the registered function"), GCalled))
	{
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK execute basic-callback test should create a context"), Context))
	{
		return false;
	}

	Context->SetUserData(reinterpret_cast<void*>(static_cast<SIZE_T>(0xDEADF00D)));
	ScriptEngine->SetContextUserDataCleanupCallback(CleanupContext);
	const int PrepareResult = Context->Prepare(ScriptEngine->GetGlobalFunctionByDecl("void cfunction()"));
	Context->Release();

	TestEqual(TEXT("ASSDK execute basic-callback test should prepare the callback function"), PrepareResult, static_cast<int32>(asSUCCESS));
	TestTrue(TEXT("ASSDK execute basic-callback test should trigger context cleanup on release"), GCleanupCalled);
	TestTrue(TEXT("ASSDK execute basic-callback test should preserve context user data for cleanup"), GCleanupUserDataMatched);
	return PrepareResult == asSUCCESS && GCleanupCalled && GCleanupUserDataMatched;
}

bool FAngelscriptASSDKExecuteOneArgTest::RunTest(const FString& Parameters)
{
	ResetExecuteState();
	FAngelscriptSDKTestAdapter Adapter(*this);
	asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter);
	if (!TestNotNull(TEXT("ASSDK execute one-arg test should create a script engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		AngelscriptNativeTestSupport::DestroyNativeEngine(ScriptEngine);
	};

	const int FunctionId = UsesMaxPortability()
		? ScriptEngine->RegisterGlobalFunction("void cfunction(int value)", asFUNCTION(CFunctionOneArgGeneric), asCALL_GENERIC)
		: [&]()
		{
			const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(CFunctionOneArg);
			return ScriptEngine->RegisterGlobalFunction("void cfunction(int value)", asFUNCTION(CFunctionOneArg), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		}();
	if (!TestTrue(TEXT("ASSDK execute one-arg test should register the callback"), FunctionId >= 0))
	{
		return false;
	}

	const int ExecuteResult = ASSDKExecuteString(ScriptEngine, "cfunction(5);");
	if (!TestEqual(TEXT("ASSDK execute one-arg test should execute the statement snippet"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED)))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK execute one-arg test should call the registered function"), GCalled))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK execute one-arg test should pass the correct value through the snippet"), GIntResult, 5))
	{
		return false;
	}

	ResetExecuteState();
	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK execute one-arg test should create a direct-call context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(ScriptEngine->GetFunctionById(FunctionId));
	if (!TestEqual(TEXT("ASSDK execute one-arg test should prepare the direct-call context"), PrepareResult, static_cast<int32>(asSUCCESS)))
	{
		Context->Release();
		return false;
	}

	Context->SetArgDWord(0, 5);
	const int DirectExecuteResult = Context->Execute();
	Context->Release();

	TestEqual(TEXT("ASSDK execute one-arg test should finish the direct callback execution"), DirectExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestTrue(TEXT("ASSDK execute one-arg test should call the direct callback"), GCalled);
	TestEqual(TEXT("ASSDK execute one-arg test should preserve the direct callback argument"), GIntResult, 5);
	return DirectExecuteResult == asEXECUTION_FINISHED && GCalled && GIntResult == 5;
}

bool FAngelscriptASSDKExecuteTwoArgsTest::RunTest(const FString& Parameters)
{
	ResetExecuteState();
	FAngelscriptSDKTestAdapter Adapter(*this);
	asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter);
	if (!TestNotNull(TEXT("ASSDK execute two-args test should create a script engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		AngelscriptNativeTestSupport::DestroyNativeEngine(ScriptEngine);
	};

	const int RegisterResult = UsesMaxPortability()
		? ScriptEngine->RegisterGlobalFunction("void cfunction(int left, int right)", asFUNCTION(CFunctionTwoArgsGeneric), asCALL_GENERIC)
		: [&]()
		{
			const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(CFunctionTwoArgs);
			return ScriptEngine->RegisterGlobalFunction("void cfunction(int left, int right)", asFUNCTION(CFunctionTwoArgs), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		}();
	if (!TestTrue(TEXT("ASSDK execute two-args test should register the callback"), RegisterResult >= 0))
	{
		return false;
	}

	const int ExecuteResult = ASSDKExecuteString(ScriptEngine, "cfunction(5, 9);");
	TestEqual(TEXT("ASSDK execute two-args test should execute the statement snippet"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestTrue(TEXT("ASSDK execute two-args test should call the registered function"), GCalled);
	TestEqual(TEXT("ASSDK execute two-args test should sum both arguments"), GIntResult, 14);
	return ExecuteResult == asEXECUTION_FINISHED && GCalled && GIntResult == 14;
}

bool FAngelscriptASSDKExecuteFourArgsTest::RunTest(const FString& Parameters)
{
	ResetExecuteState();
	FAngelscriptSDKTestAdapter Adapter(*this);
	asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter);
	if (!TestNotNull(TEXT("ASSDK execute four-args test should create a script engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		AngelscriptNativeTestSupport::DestroyNativeEngine(ScriptEngine);
	};

	const int RegisterResult = UsesMaxPortability()
		? ScriptEngine->RegisterGlobalFunction("void cfunction(int first, int16 second, int8 third, int fourth)", asFUNCTION(CFunctionFourArgsGeneric), asCALL_GENERIC)
		: [&]()
		{
			const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(CFunctionFourArgs);
			return ScriptEngine->RegisterGlobalFunction("void cfunction(int first, int16 second, int8 third, int fourth)", asFUNCTION(CFunctionFourArgs), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		}();
	if (!TestTrue(TEXT("ASSDK execute four-args test should register the callback"), RegisterResult >= 0))
	{
		return false;
	}

	const int ExecuteResult = ASSDKExecuteString(ScriptEngine, "cfunction(5, 9, 1, 3);");
	TestEqual(TEXT("ASSDK execute four-args test should execute the statement snippet"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestTrue(TEXT("ASSDK execute four-args test should call the registered function"), GCalled);
	TestEqual(TEXT("ASSDK execute four-args test should preserve the first argument"), GFourArgInt, 5);
	TestEqual(TEXT("ASSDK execute four-args test should preserve the int16 argument"), GFourArgShort, 9);
	TestEqual(TEXT("ASSDK execute four-args test should preserve the int8 argument"), GFourArgByte, 1);
	TestEqual(TEXT("ASSDK execute four-args test should preserve the trailing argument"), GFourArgTail, 3);
	return ExecuteResult == asEXECUTION_FINISHED && GCalled;
}

bool FAngelscriptASSDKExecuteFloatArgsTest::RunTest(const FString& Parameters)
{
	ResetExecuteState();
	FAngelscriptSDKTestAdapter Adapter(*this);
	asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter);
	if (!TestNotNull(TEXT("ASSDK execute float-args test should create a script engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		AngelscriptNativeTestSupport::DestroyNativeEngine(ScriptEngine);
	};

	const bool bFloatUsesFloat64 = ScriptEngine->GetEngineProperty(asEP_FLOAT_IS_FLOAT64) != 0;
	const char* Declaration = bFloatUsesFloat64
		? "void cfunction(double first, double second, double third, double fourth)"
		: "void cfunction(float first, float second, double third, float fourth)";
	const char* ScriptCall = bFloatUsesFloat64
		? "cfunction(9.2, 13.3, 18.8, 3.1415);"
		: "cfunction(9.2f, 13.3f, 18.8, 3.1415f);";

	int RegisterResult = asERROR;
	if (!UsesMaxPortability())
	{
		const ASAutoCaller::FunctionCaller Caller = bFloatUsesFloat64
			? ASAutoCaller::MakeFunctionCaller(CFunctionDoubleArgs)
			: ASAutoCaller::MakeFunctionCaller(CFunctionFloatArgs);
		RegisterResult = ScriptEngine->RegisterGlobalFunction(
			Declaration,
			bFloatUsesFloat64 ? asFUNCTION(CFunctionDoubleArgs) : asFUNCTION(CFunctionFloatArgs),
			asCALL_CDECL,
			*(asFunctionCaller*)&Caller);
	}

	if (RegisterResult < 0)
	{
		RegisterResult = ScriptEngine->RegisterGlobalFunction(
			Declaration,
			bFloatUsesFloat64 ? asFUNCTION(CFunctionDoubleArgsGeneric) : asFUNCTION(CFunctionFloatArgsGeneric),
			asCALL_GENERIC);
	}
	if (!TestTrue(TEXT("ASSDK execute float-args test should register the callback"), RegisterResult >= 0))
	{
		return false;
	}

	const int ExecuteResult = ASSDKExecuteString(ScriptEngine, ScriptCall);
	TestEqual(TEXT("ASSDK execute float-args test should execute the statement snippet"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	TestTrue(TEXT("ASSDK execute float-args test should call the registered function"), GCalled);
	if (bFloatUsesFloat64)
	{
		TestTrue(TEXT("ASSDK execute float-args test should preserve the first promoted double"), FMath::IsNearlyEqual(GDoubleArgA, 9.2, 0.0001));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the second promoted double"), FMath::IsNearlyEqual(GDoubleArgB, 13.3, 0.0001));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the third double"), FMath::IsNearlyEqual(GDoubleArgC, 18.8, 0.0001));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the fourth promoted double"), FMath::IsNearlyEqual(GDoubleArgD, 3.1415, 0.0001));
	}
	else
	{
		TestTrue(TEXT("ASSDK execute float-args test should preserve the first float"), FMath::IsNearlyEqual(GFloatArgA, 9.2f, 0.0001f));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the second float"), FMath::IsNearlyEqual(GFloatArgB, 13.3f, 0.0001f));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the double argument"), FMath::IsNearlyEqual(GFloatArgC, 18.8, 0.0001));
		TestTrue(TEXT("ASSDK execute float-args test should preserve the trailing float"), FMath::IsNearlyEqual(GFloatArgD, 3.1415f, 0.0001f));
	}
	return ExecuteResult == asEXECUTION_FINISHED && GCalled;
}

#endif
