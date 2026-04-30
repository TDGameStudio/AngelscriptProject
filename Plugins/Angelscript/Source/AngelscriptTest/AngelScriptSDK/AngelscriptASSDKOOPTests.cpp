#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKOOPTests_Private
{
	bool ExecuteOOPBoolEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, bool& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("OOP test should resolve the bool entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("OOP test should create a bool execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		if (ExecuteResult == asEXECUTION_EXCEPTION)
		{
			const int ExceptionLine = Context->GetExceptionLineNumber();
			const FString ExceptionFunction = Context->GetExceptionFunction() != nullptr
				? UTF8_TO_TCHAR(Context->GetExceptionFunction()->GetName())
				: FString();
			Test.AddInfo(FString::Printf(
				TEXT("OOP execution exception: %s (line=%d function=%s)"),
				UTF8_TO_TCHAR(Context->GetExceptionString() != nullptr ? Context->GetExceptionString() : "<null>"),
				ExceptionLine,
				*ExceptionFunction));
		}
		OutValue = Context->GetReturnByte() != 0;
		Context->Release();
		return Test.TestEqual(TEXT("OOP test should finish bool execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKOOPTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKOOPTests, "Angelscript.TestModule.AngelScriptSDK.ASSDK.OOP", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(InterfaceBridge)
	{
		FAngelscriptSDKTestAdapter Adapter(*this);
		FASSDKBufferedOutStream Buffered;
		asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter, &Buffered);
		if (!TestNotNull(TEXT("ASSDK OOP interface test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const int InterfaceResult = ScriptEngine->RegisterInterface("appintf");
		const int MethodResult = InterfaceResult >= 0
			? ScriptEngine->RegisterInterfaceMethod("appintf", "void test()")
			: InterfaceResult;
		if (!TestTrue(TEXT("ASSDK OOP interface test should register the application interface"), InterfaceResult >= 0 && MethodResult >= 0))
		{
			return;
		}

		const FString InterfaceDeclaration = UTF8_TO_TCHAR(ScriptEngine->GetTypeDeclaration(InterfaceResult));
		if (!TestEqual(TEXT("ASSDK OOP interface test should preserve the registered interface declaration"), InterfaceDeclaration, FString(TEXT("appintf"))))
		{
			return;
		}

		asITypeInfo* InterfaceType = ScriptEngine->GetTypeInfoByName("appintf");
		if (!TestNotNull(TEXT("ASSDK OOP interface test should expose the registered interface type"), InterfaceType))
		{
			return;
		}

		TestEqual(TEXT("ASSDK OOP interface test should expose the registered interface method count"), static_cast<int32>(InterfaceType->GetMethodCount()), 1);
	}

	TEST_METHOD(MixinNamespace)
	{
		FAngelscriptSDKTestAdapter Adapter(*this);
		FASSDKBufferedOutStream Buffered;
		asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter, &Buffered);
		if (!TestNotNull(TEXT("ASSDK OOP mixin test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKOOPMixinNamespace",
			"struct Counter                              \n"
			"{                                           \n"
			"  int Value = 0;                            \n"
			"}                                           \n"
			"mixin void AddToCounter(Counter& Self, int Delta) \n"
			"{                                           \n"
			"  Self.Value += Delta;                      \n"
			"}                                           \n"
			"bool Entry()                                \n"
			"{                                           \n"
			"  Counter Value;                            \n"
			"  Value.AddToCounter(3);                    \n"
			"  return Value.Value == 3;                  \n"
			"}                                           \n");
		if (!TestNotNull(TEXT("ASSDK OOP mixin test should compile the module"), Module))
		{
			AddInfo(UTF8_TO_TCHAR(Buffered.Buffer.c_str()));
			return;
		}

		TestNotNull(TEXT("ASSDK OOP mixin test should expose the compiled entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
	}

	TEST_METHOD(InheritedInterfaceMethod)
	{
		FAngelscriptSDKTestAdapter Adapter(*this);
		FASSDKBufferedOutStream Buffered;
		asIScriptEngine* ScriptEngine = CreateASSDKTestEngine(Adapter, &Buffered);
		if (!TestNotNull(TEXT("ASSDK OOP inherited-interface-method test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKOOPInheritedInterfaceMethod",
			"class B                                    \n"
			"{                                          \n"
			"  bool touched = false;                    \n"
			"  void Touch() { touched = true; }         \n"
			"}                                          \n"
			"class D : B                                \n"
			"{                                          \n"
			"}                                          \n"
			"bool Entry()                               \n"
			"{                                          \n"
			"  D value = D();                           \n"
			"  value.Touch();                           \n"
			"  return value.touched;                    \n"
			"}                                          \n");
		if (!TestNotNull(TEXT("ASSDK OOP inherited-interface-method test should compile the module"), Module))
		{
			AddInfo(UTF8_TO_TCHAR(Buffered.Buffer.c_str()));
			return;
		}

		TestNotNull(TEXT("ASSDK OOP inheritance test should expose the compiled entry function"), GetNativeFunctionByDecl(Module, "bool Entry()"));
	}
};

#endif
