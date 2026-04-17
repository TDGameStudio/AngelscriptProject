#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKObjectValueTypeTest,
	"Angelscript.TestModule.Native.ASSDK.Object.ValueType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKObjectConstructorTest,
	"Angelscript.TestModule.Native.ASSDK.Object.ConstructorChain",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKObjectNativeFloatWrapperTest,
	"Angelscript.TestModule.Native.ASSDK.Object.NativeFloatWrapper",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKObjectTests_Private
{
	bool ExecuteObjectBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Object test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Object test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("Object test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	class CObject
	{
	public:
		CObject()
			: Value(0)
		{
		}

		void Set(int32 InValue)
		{
			Value = InValue;
		}

		int32 Get() const
		{
			return Value;
		}

		int32& GetRef()
		{
			return Value;
		}

		int32 Value;
	};

	void ConstructObject(CObject* Address)
	{
		new (Address) CObject();
	}

	void DestructObject(CObject* Address)
	{
		Address->~CObject();
	}

	CObject GReturnedObject;

	CObject ReturnObjectValue()
	{
		CObject Result;
		Result.Value = 12;
		return Result;
	}

	CObject* ReturnObjectRef()
	{
		return &GReturnedObject;
	}

	void ConstructDefaultMyObj(class CMyObj& Address);
	void ConstructCopyMyObj(class CMyObj& Address, const class CMyObj& Other);
	void DestructMyObj(class CMyObj& Address);
	class CMyObj
	{
public:
		CMyObj() = default;
		CMyObj(const CMyObj&) = default;
	};

	void ConstructDefaultMyObj(CMyObj& Address)
	{
		new (&Address) CMyObj();
	}

	void ConstructCopyMyObj(CMyObj& Address, const CMyObj& Other)
	{
		new (&Address) CMyObj(Other);
	}

	void DestructMyObj(CMyObj& Address)
	{
		Address.~CMyObj();
	}

	struct CFloatWrapper
	{
		float Value;

		CFloatWrapper()
			: Value(0.0f)
		{
		}
	};

	void ConstructFloatWrapper(CFloatWrapper* Address)
	{
		new (Address) CFloatWrapper();
	}

	CFloatWrapper& AssignFloatToWrapper(float InValue, CFloatWrapper& Target)
	{
		Target.Value = InValue;
		return Target;
	}

	float AddWrapperToWrapper(CFloatWrapper* Self, CFloatWrapper* Other)
	{
		return Self->Value + Other->Value;
	}

	float MultiplyWrapperByFloat(CFloatWrapper* Self, float Other)
	{
		return Self->Value * Other;
	}

	CFloatWrapper& AccessWrapperSlot(int32 Index)
	{
		static CFloatWrapper Slots[8];
		return Slots[Index];
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKObjectTests_Private;

bool FAngelscriptASSDKObjectValueTypeTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK object value-type test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	const int RegisterObjectResult = ScriptEngine->RegisterObjectType("Object", sizeof(CObject), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<CObject>() | asOBJ_APP_CLASS_ALLINTS);
	const ASAutoCaller::FunctionCaller ObjectConstructCaller = ASAutoCaller::MakeFunctionCaller(ConstructObject);
	const int RegisterConstructResult = ScriptEngine->RegisterObjectBehaviour("Object", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(ConstructObject), asCALL_CDECL_OBJLAST, *(asFunctionCaller*)&ObjectConstructCaller);
	const int RegisterDestructResult = ScriptEngine->RegisterObjectBehaviour("Object", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(DestructObject), asCALL_CDECL_OBJLAST);
	const int RegisterPropertyResult = ScriptEngine->RegisterObjectProperty("Object", "int Value", asOFFSET(CObject, Value));

	if (!TestTrue(TEXT("ASSDK object value-type test should register all object APIs"),
		RegisterObjectResult >= 0 &&
		RegisterConstructResult >= 0 &&
		RegisterDestructResult >= 0 &&
		RegisterPropertyResult >= 0))
	{
		return false;
	}

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKObjectValueType",
		"bool Entry()                 \n"
		"{                            \n"
		"  Object value;              \n"
		"  value.Value = 10;          \n"
		"  Object copy = value;       \n"
		"  return copy.Value == 10;   \n"
		"}                            \n");
	if (!TestNotNull(TEXT("ASSDK object value-type test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return TestNotNull(TEXT("ASSDK object value-type test should expose the compiled entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
}

bool FAngelscriptASSDKObjectConstructorTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK object constructor-chain test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKObjectConstructorChain",
		"class InternalClass            \n"
		"{                              \n"
		"  InternalClass()              \n"
		"  {                            \n"
		"    m_x = 3;                   \n"
		"    m_y = 773456;              \n"
		"  }                            \n"
		"  int8 m_x;                    \n"
		"  int  m_y;                    \n"
		"}                              \n"
		"class MyClass                  \n"
		"{                              \n"
		"  MyClass()                    \n"
		"  {                            \n"
		"    m_c = InternalClass();     \n"
		"  }                            \n"
		"  bool Test() const            \n"
		"  {                            \n"
		"    return m_c.m_x == 3 && m_c.m_y == 773456; \n"
		"  }                            \n"
		"  InternalClass m_c;           \n"
		"}                              \n"
		"bool Entry()                   \n"
		"{                              \n"
		"  MyClass test;                \n"
		"  return test.Test();          \n"
		"}                              \n");
	if (!TestNotNull(TEXT("ASSDK object constructor-chain test should compile the script constructor chain module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return TestNotNull(TEXT("ASSDK object constructor-chain test should expose the compiled entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
}

bool FAngelscriptASSDKObjectNativeFloatWrapperTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK object native-float wrapper test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKObjectFloatValue",
		"class FloatValue               \n"
		"{                              \n"
		"  float Value;                 \n"
		"}                              \n"
		"bool Entry()                  \n"
		"{                             \n"
		"  FloatValue value;           \n"
		"  value.Value = 10.0f;        \n"
		"  return value.Value > 9.9f && value.Value < 10.1f; \n"
		"}                             \n");
	if (!TestNotNull(TEXT("ASSDK object native-float wrapper test should compile the float value module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return TestNotNull(TEXT("ASSDK object native-float wrapper test should expose the float entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
}

#endif
