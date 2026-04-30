#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private
{
	int32 GEnumValue = 0;
	asBYTE GInt8Value = 0;

	asBYTE RetInt8(asBYTE InValue)
	{
		return InValue;
	}

	void CaptureEnum(asIScriptGeneric* Generic)
	{
		if (Generic != nullptr)
		{
			GEnumValue = static_cast<int32>(Generic->GetArgDWord(0));
		}
	}

	bool ExecuteTypeBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Type test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Type test should create a context for bool execution"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Type test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	bool ExecuteTypeIntEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, int32& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Type test should resolve the int entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Type test should create a context for int execution"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = static_cast<int32>(Context->GetReturnDWord());
		Context->Release();
		return Test.TestEqual(TEXT("Type test should finish int execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	bool ExecuteTypeDoubleEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, double& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Type test should resolve the numeric entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Type test should create a context for numeric execution"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnDouble();
		Context->Release();
		return Test.TestEqual(TEXT("Type test should finish numeric execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}


TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKTypeTests, "Angelscript.TestModule.AngelScriptSDK.ASSDK.Type", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Bool)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK bool type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKTypeBool",
			"bool Entry() { bool a = true; bool b = false; return a && !b && (a ^^ b); }");
		if (!TestRunner->TestNotNull(TEXT("ASSDK bool type test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteTypeBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK bool type test should preserve basic boolean logic"), bResult);
	}

	TEST_METHOD(Bits)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK bits type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeBits", R"(
bool Entry()
{
	uint oct = 0o777;
	uint bin = 0b10101010;
	uint dec = 0d255;
	uint8 newmask = 0xFF;
	uint8 mask2 = 1 << 2;
	uint8 mask3 = 1 << 3;
	uint8 mask5 = 1 << 5;
	newmask = newmask & (~mask2) & (~mask3) & (~mask5);
	return oct == 0x1FF && bin == 0xAA && dec == 0xFF && newmask == 0xD3;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK bits type test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteTypeBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK bits type test should preserve numeric literals and bitwise masks"), bResult);
	}

	TEST_METHOD(Int8)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK int8 type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(RetInt8);
		const int RegisterFunctionResult = ScriptEngine->RegisterGlobalFunction("int8 RetInt8(int8 value)", asFUNCTION(RetInt8), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (!TestRunner->TestTrue(TEXT("ASSDK int8 type test should register the native int8 callback"), RegisterFunctionResult >= 0))
		{
			return;
		}

		const int RegisterPropertyResult = ScriptEngine->RegisterGlobalProperty("int8 gvar", &GInt8Value);
		if (!TestRunner->TestTrue(TEXT("ASSDK int8 type test should register the int8 global property"), RegisterPropertyResult >= 0))
		{
			return;
		}

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeInt8", "int Entry() { gvar = RetInt8(1); return gvar; }");
		if (!TestRunner->TestNotNull(TEXT("ASSDK int8 type test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteTypeIntEntry(*TestRunner, ScriptEngine, Module, "int Entry()", Result))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("ASSDK int8 type test should preserve the int8 return through the global property"), Result, 1);
	}

	TEST_METHOD(Float)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK float type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const bool bFloatUsesFloat64 = ScriptEngine->GetEngineProperty(asEP_FLOAT_IS_FLOAT64) != 0;
		const char* Source = bFloatUsesFloat64
			? "double Entry() { double a = 1e5; double b = 1.0e5; return (a == b) ? 3.14 : 0.0; }"
			: "double Entry() { float a = 1e5; float b = 1.0e5; return (a == b) ? 3.14f : 0.0f; }";

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeFloat", Source);
		if (!TestRunner->TestNotNull(TEXT("ASSDK float type test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		double Result = 0.0;
		if (!ExecuteTypeDoubleEntry(*TestRunner, ScriptEngine, Module, "double Entry()", Result))
		{
			return;
		}

		TestRunner->TestTrue(TEXT("ASSDK float type test should preserve scientific literals and floating equality"), FMath::IsNearlyEqual(Result, 3.14, 0.0001));
	}

	TEST_METHOD(TypedefBytecode)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* SaveEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK typedef bytecode test should create the save engine"), SaveEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(SaveEngine);
		};

		if (!TestRunner->TestTrue(TEXT("ASSDK typedef bytecode test should register TestType1 on the save engine"), SaveEngine->RegisterTypedef("TestType1", "int8") >= 0))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK typedef bytecode test should register TestType4 on the save engine"), SaveEngine->RegisterTypedef("TestType4", "int64") >= 0))
		{
			return;
		}

		asIScriptModule* SaveModule = BuildNativeModule(SaveEngine, "ASSDKTypeTypedefSave", R"(
TestType4 Func(TestType1 a)
{
	return a;
}

int Entry()
{
	TestType1 v = 1;
	return int(Func(v));
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK typedef bytecode test should compile the save module"), SaveModule))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		FASSDKBytecodeStream Bytecode;
		if (!TestRunner->TestEqual(TEXT("ASSDK typedef bytecode test should save bytecode successfully"), SaveModule->SaveByteCode(&Bytecode), static_cast<int32>(asSUCCESS)))
		{
			return;
		}

		Bytecode.Restart();

		FNativeMessageCollector LoadMessages;
		asIScriptEngine* LoadEngine = CreateNativeEngine(&LoadMessages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK typedef bytecode test should create the load engine"), LoadEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(LoadEngine);
		};

		if (!TestRunner->TestTrue(TEXT("ASSDK typedef bytecode test should register TestType1 on the load engine"), LoadEngine->RegisterTypedef("TestType1", "int8") >= 0))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK typedef bytecode test should register TestType4 on the load engine"), LoadEngine->RegisterTypedef("TestType4", "int64") >= 0))
		{
			return;
		}

		asIScriptModule* LoadModule = LoadEngine->GetModule("ASSDKTypeTypedefLoad", asGM_ALWAYS_CREATE);
		if (!TestRunner->TestNotNull(TEXT("ASSDK typedef bytecode test should create the load module"), LoadModule))
		{
			return;
		}

		if (!TestRunner->TestEqual(TEXT("ASSDK typedef bytecode test should load bytecode successfully"), LoadModule->LoadByteCode(&Bytecode), static_cast<int32>(asSUCCESS)))
		{
			return;
		}

		TestRunner->TestNotNull(TEXT("ASSDK typedef bytecode test should preserve the loaded entry function"), GetNativeFunctionByDecl(LoadModule, "int Entry()"));
	}

	TEST_METHOD(Enum)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK enum type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register the first enum namespace"), ScriptEngine->RegisterEnum("myenum") >= 0))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register the first enum value"), ScriptEngine->RegisterEnumValue("myenum", "value", 1) >= 0))
		{
			return;
		}

		ScriptEngine->SetDefaultNamespace("foo");
		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register a namespaced enum with the same name"), ScriptEngine->RegisterEnum("myenum") >= 0))
		{
			ScriptEngine->SetDefaultNamespace("");
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register the namespaced enum value"), ScriptEngine->RegisterEnumValue("myenum", "value", 1) >= 0))
		{
			ScriptEngine->SetDefaultNamespace("");
			return;
		}
		ScriptEngine->SetDefaultNamespace("");

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register TEST_ENUM"), ScriptEngine->RegisterEnum("TEST_ENUM") >= 0))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should register ENUM1"), ScriptEngine->RegisterEnumValue("TEST_ENUM", "ENUM1", 1) >= 0))
		{
			return;
		}

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeEnum", R"(
enum LocalEnum
{
	LocalValue = 1
}

bool Entry()
{
	LocalEnum Value = LocalEnum::LocalValue;
	return Value == LocalEnum::LocalValue;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK enum type test should compile the enum entry module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}

		bool bResult = false;
		if (!ExecuteTypeBoolEntry(*TestRunner, ScriptEngine, Module, "bool Entry()", bResult))
		{
			return;
		}

		if (!TestRunner->TestTrue(TEXT("ASSDK enum type test should preserve local enum equality"), bResult))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("ASSDK enum type test should keep the registered enum declaration accessible"), FString(UTF8_TO_TCHAR(ScriptEngine->GetTypeDeclaration(ScriptEngine->GetTypeIdByDecl("TEST_ENUM")))), FString(TEXT("TEST_ENUM")));
	}

	TEST_METHOD(Auto)
	{
		using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK auto type test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeAuto", R"(
namespace A
{
	class X
	{
		X()
		{
		}
	}
}

bool Entry()
{
	auto value = A::X();
	return true;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK auto type test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}
	}
};

#endif
