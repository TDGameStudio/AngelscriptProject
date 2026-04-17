#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKConversionNumericTest,
	"Angelscript.TestModule.Native.ASSDK.Conversion.Numeric",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKConversionExplicitCastTest,
	"Angelscript.TestModule.Native.ASSDK.Conversion.ExplicitCast",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKConversionImplicitValueTypeTest,
	"Angelscript.TestModule.Native.ASSDK.Conversion.ImplicitValueType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKConversionTests_Private
{
	bool ExecuteConversionBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Conversion test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Conversion test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Conversion test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	void TestValueConstruct0(asIScriptGeneric* Generic)
	{
		int* Value = static_cast<int*>(Generic->GetObject());
		*Value = 0;
	}

	void TestValueConstruct1(asIScriptGeneric* Generic)
	{
		int* Value = static_cast<int*>(Generic->GetObject());
		*Value = *static_cast<int*>(Generic->GetAddressOfArg(0));
	}

	void TestValueCastInt(asIScriptGeneric* Generic)
	{
		int* Value = static_cast<int*>(Generic->GetObject());
		*static_cast<int*>(Generic->GetAddressOfReturnLocation()) = *Value;
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKConversionTests_Private;

bool FAngelscriptASSDKConversionNumericTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK numeric conversion test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKConversionNumeric",
		"bool Entry()                           \n"
		"{                                      \n"
		"  int8 small = 2;                      \n"
		"  uint16 medium = 4;                   \n"
		"  int total = small + medium;          \n"
		"  double precise = total + 0.5;        \n"
		"  float narrow = float(precise);       \n"
		"  return total == 6 && narrow > 6.49f && narrow < 6.51f; \n"
		"}                                      \n");
	if (!TestNotNull(TEXT("ASSDK numeric conversion test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteConversionBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK numeric conversion test should preserve widening and narrowing conversions"), bResult);
}

bool FAngelscriptASSDKConversionExplicitCastTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK explicit-cast conversion test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKConversionExplicit",
		"bool Entry()                             \n"
		"{                                        \n"
		"  double d = 3.75;                       \n"
		"  int i = int(d);                        \n"
		"  uint64 wide = uint64(i);               \n"
		"  float f = float(wide) + 0.25f;         \n"
		"  return i == 3 && wide == 3 && f > 3.24f && f < 3.26f; \n"
		"}                                        \n");
	if (!TestNotNull(TEXT("ASSDK explicit-cast conversion test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	bool bResult = false;
	if (!ExecuteConversionBoolEntry(*this, ScriptEngine, Module, "bool Entry()", bResult))
	{
		return false;
	}

	return TestTrue(TEXT("ASSDK explicit-cast conversion test should preserve explicit cast semantics"), bResult);
}

bool FAngelscriptASSDKConversionImplicitValueTypeTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK implicit value-type conversion test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKConversionImplicitValueType",
		"class Test                         \n"
		"{                                  \n"
		"  int opImplConv() const           \n"
		"  {                                \n"
		"    return 7;                      \n"
		"  }                                \n"
		"}                                  \n"
		"bool Entry()                       \n"
		"{                                  \n"
		"  Test value;                      \n"
		"  int i = value;                   \n"
		"  return i == 7;                   \n"
		"}                                  \n");
	if (!TestNotNull(TEXT("ASSDK implicit value-type conversion test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return TestNotNull(TEXT("ASSDK implicit value-type conversion test should expose the compiled entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
}

#endif
