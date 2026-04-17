#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeBoolTest,
	"Angelscript.TestModule.Native.ASSDK.Type.Bool",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeBitsTest,
	"Angelscript.TestModule.Native.ASSDK.Type.Bits",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeInt8Test,
	"Angelscript.TestModule.Native.ASSDK.Type.Int8",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeFloatTest,
	"Angelscript.TestModule.Native.ASSDK.Type.Float",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeTypedefBytecodeTest,
	"Angelscript.TestModule.Native.ASSDK.Type.TypedefBytecode",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeEnumTest,
	"Angelscript.TestModule.Native.ASSDK.Type.Enum",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKTypeAutoTest,
	"Angelscript.TestModule.Native.ASSDK.Type.Auto",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

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

using namespace AngelscriptTest_Native_AngelscriptASSDKTypeTests_Private;

bool FAngelscriptASSDKTypeBoolTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK bool type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKTypeBool",
		"bool Entry() { bool a = true; bool b = false; return a && !b && (a ^^ b); }");
	if (!TestNotNull(TEXT("ASSDK bool type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteTypeBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK bool type test should preserve basic boolean logic"), bResult);
}

bool FAngelscriptASSDKTypeBitsTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK bits type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKTypeBits",
		"bool Entry()                  \n"
		"{                             \n"
		"  uint oct = 0o777;           \n"
		"  uint bin = 0b10101010;      \n"
		"  uint dec = 0d255;           \n"
		"  uint8 newmask = 0xFF;       \n"
		"  uint8 mask2 = 1 << 2;       \n"
		"  uint8 mask3 = 1 << 3;       \n"
		"  uint8 mask5 = 1 << 5;       \n"
		"  newmask = newmask & (~mask2) & (~mask3) & (~mask5); \n"
		"  return oct == 0x1FF && bin == 0xAA && dec == 0xFF && newmask == 0xD3; \n"
		"}                             \n");
	if (!TestNotNull(TEXT("ASSDK bits type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteTypeBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK bits type test should preserve numeric literals and bitwise masks"), bResult);
}

bool FAngelscriptASSDKTypeInt8Test::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK int8 type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(RetInt8);
	const int RegisterFunctionResult = ScriptEngine->RegisterGlobalFunction("int8 RetInt8(int8 value)", asFUNCTION(RetInt8), asCALL_CDECL, *(asFunctionCaller*)&Caller);
	if (!TestTrue(TEXT("ASSDK int8 type test should register the native int8 callback"), RegisterFunctionResult >= 0))
	{
		return false;
	}

	const int RegisterPropertyResult = ScriptEngine->RegisterGlobalProperty("int8 gvar", &GInt8Value);
	if (!TestTrue(TEXT("ASSDK int8 type test should register the int8 global property"), RegisterPropertyResult >= 0))
	{
		return false;
	}

	asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKTypeInt8", "int Entry() { gvar = RetInt8(1); return gvar; }");
	if (!TestNotNull(TEXT("ASSDK int8 type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	int32 Result = 0;
	if (!ExecuteTypeIntEntry(*this, ScriptEngine, Module, "int Entry()", Result))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK int8 type test should preserve the int8 return through the global property"), Result, 1);
}

bool FAngelscriptASSDKTypeFloatTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK float type test should create a standalone engine"), ScriptEngine))
	{
		return false;
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
	if (!TestNotNull(TEXT("ASSDK float type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	double Result = 0.0;
	if (!ExecuteTypeDoubleEntry(*this, ScriptEngine, Module, "double Entry()", Result))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK float type test should preserve scientific literals and floating equality"), FMath::IsNearlyEqual(Result, 3.14, 0.0001));
}

bool FAngelscriptASSDKTypeTypedefBytecodeTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SaveEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK typedef bytecode test should create the save engine"), SaveEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(SaveEngine);
	};

	if (!TestTrue(TEXT("ASSDK typedef bytecode test should register TestType1 on the save engine"), SaveEngine->RegisterTypedef("TestType1", "int8") >= 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK typedef bytecode test should register TestType4 on the save engine"), SaveEngine->RegisterTypedef("TestType4", "int64") >= 0))
	{
		return false;
	}

	asIScriptModule* SaveModule = BuildNativeModule(
		SaveEngine,
		"ASSDKTypeTypedefSave",
		"TestType4 Func(TestType1 a)      \n"
		"{                                \n"
		"  return a;                      \n"
		"}                                \n"
		"int Entry()                      \n"
		"{                                \n"
		"  TestType1 v = 1;               \n"
		"  return int(Func(v));           \n"
		"}                                \n");
	if (!TestNotNull(TEXT("ASSDK typedef bytecode test should compile the save module"), SaveModule))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	FASSDKBytecodeStream Bytecode;
	if (!TestEqual(TEXT("ASSDK typedef bytecode test should save bytecode successfully"), SaveModule->SaveByteCode(&Bytecode), static_cast<int32>(asSUCCESS)))
	{
		return false;
	}

	Bytecode.Restart();

	FNativeMessageCollector LoadMessages;
	asIScriptEngine* LoadEngine = CreateNativeEngine(&LoadMessages);
	if (!TestNotNull(TEXT("ASSDK typedef bytecode test should create the load engine"), LoadEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(LoadEngine);
	};

	if (!TestTrue(TEXT("ASSDK typedef bytecode test should register TestType1 on the load engine"), LoadEngine->RegisterTypedef("TestType1", "int8") >= 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK typedef bytecode test should register TestType4 on the load engine"), LoadEngine->RegisterTypedef("TestType4", "int64") >= 0))
	{
		return false;
	}

	asIScriptModule* LoadModule = LoadEngine->GetModule("ASSDKTypeTypedefLoad", asGM_ALWAYS_CREATE);
	if (!TestNotNull(TEXT("ASSDK typedef bytecode test should create the load module"), LoadModule))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK typedef bytecode test should load bytecode successfully"), LoadModule->LoadByteCode(&Bytecode), static_cast<int32>(asSUCCESS)))
	{
		return false;
	}

	if (!TestNotNull(TEXT("ASSDK typedef bytecode test should preserve the loaded entry function"), GetNativeFunctionByDecl(LoadModule, "int Entry()")))
	{
		return false;
	}

	return true;
}

bool FAngelscriptASSDKTypeEnumTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK enum type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	if (!TestTrue(TEXT("ASSDK enum type test should register the first enum namespace"), ScriptEngine->RegisterEnum("myenum") >= 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK enum type test should register the first enum value"), ScriptEngine->RegisterEnumValue("myenum", "value", 1) >= 0))
	{
		return false;
	}

	ScriptEngine->SetDefaultNamespace("foo");
	if (!TestTrue(TEXT("ASSDK enum type test should register a namespaced enum with the same name"), ScriptEngine->RegisterEnum("myenum") >= 0))
	{
		ScriptEngine->SetDefaultNamespace("");
		return false;
	}

	if (!TestTrue(TEXT("ASSDK enum type test should register the namespaced enum value"), ScriptEngine->RegisterEnumValue("myenum", "value", 1) >= 0))
	{
		ScriptEngine->SetDefaultNamespace("");
		return false;
	}
	ScriptEngine->SetDefaultNamespace("");

	if (!TestTrue(TEXT("ASSDK enum type test should register TEST_ENUM"), ScriptEngine->RegisterEnum("TEST_ENUM") >= 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK enum type test should register ENUM1"), ScriptEngine->RegisterEnumValue("TEST_ENUM", "ENUM1", 1) >= 0))
	{
		return false;
	}

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKTypeEnum",
		"enum LocalEnum { LocalValue = 1 } \n"
		"bool Entry()                     \n"
		"{                                \n"
		"  LocalEnum Value = LocalEnum::LocalValue;  \n"
		"  return Value == LocalEnum::LocalValue;    \n"
		"}                                \n");
	if (!TestNotNull(TEXT("ASSDK enum type test should compile the enum entry module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteTypeBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK enum type test should preserve local enum equality"), bResult))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK enum type test should keep the registered enum declaration accessible"), FString(UTF8_TO_TCHAR(ScriptEngine->GetTypeDeclaration(ScriptEngine->GetTypeIdByDecl("TEST_ENUM")))), FString(TEXT("TEST_ENUM")));
}

bool FAngelscriptASSDKTypeAutoTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK auto type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKTypeAuto",
		"namespace A        \n"
		"{                  \n"
		"  class X          \n"
		"  {                \n"
		"    X() {}         \n"
		"  }                \n"
		"}                  \n"
		"bool Entry()       \n"
		"{                  \n"
		"  auto value = A::X(); \n"
		"  return true;     \n"
		"}                  \n");
	if (!TestNotNull(TEXT("ASSDK auto type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return true;
}

#endif
