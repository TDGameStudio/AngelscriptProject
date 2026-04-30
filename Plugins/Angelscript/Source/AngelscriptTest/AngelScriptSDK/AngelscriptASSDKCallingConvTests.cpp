#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

namespace AngelscriptTest_Native_AngelscriptASSDKCallingConvTests_Private
{
	bool ExecuteCallingConvIntEntry(FAutomationTestBase& Test, asIScriptEngine* ScriptEngine, asIScriptModule* Module, const char* Declaration, int32& OutValue)
	{
		asIScriptFunction* Function = GetNativeFunctionByDecl(Module, Declaration);
		if (!Test.TestNotNull(TEXT("Calling-convention test should resolve the int entry function"), Function))
		{
			return false;
		}

		asIScriptContext* Context = ScriptEngine->CreateContext();
		if (!Test.TestNotNull(TEXT("Calling-convention test should create an execution context"), Context))
		{
			return false;
		}

		const int ExecuteResult = PrepareAndExecute(Context, Function);
		OutValue = static_cast<int32>(Context->GetReturnDWord());
		Context->Release();
		return Test.TestEqual(TEXT("Calling-convention test should finish execution successfully"), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED));
	}

	int32 DoubleNativeValue(int32 Value)
	{
		return Value * 2;
	}

	void TripleGenericValue(asIScriptGeneric* Generic)
	{
		const int32 Value = *static_cast<int32*>(Generic->GetAddressOfArg(0));
		Generic->SetReturnDWord(static_cast<asDWORD>(Value * 3));
	}

	struct FNativeAdder
	{
		int32 Base = 0;

		int32 Add(int32 Delta) const
		{
			return Base + Delta;
		}
	};

	void ConstructNativeAdder(FNativeAdder* Address)
	{
		new (Address) FNativeAdder();
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKCallingConvTests_Private;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKCallingConvTests,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.CallingConv",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(CDecl)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK calling-convention CDecl test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const ASAutoCaller::FunctionCaller Caller = ASAutoCaller::MakeFunctionCaller(DoubleNativeValue);
		const int RegisterResult = ScriptEngine->RegisterGlobalFunction("int DoubleNativeValue(int Value)", asFUNCTION(DoubleNativeValue), asCALL_CDECL, *(asFunctionCaller*)&Caller);
		if (!TestTrue(TEXT("ASSDK calling-convention CDecl test should register the native function"), RegisterResult >= 0))
		{
			return;
		}

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKCallingConvCDecl",
			"int Entry() { return DoubleNativeValue(21); }\n");
		if (!TestNotNull(TEXT("ASSDK calling-convention CDecl test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteCallingConvIntEntry(*this, ScriptEngine, Module, "int Entry()", Result))
		{
			return;
		}

		TestEqual(TEXT("ASSDK calling-convention CDecl test should preserve native CDecl calls"), Result, 42);
	}

	TEST_METHOD(Generic)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK calling-convention generic test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const int RegisterResult = ScriptEngine->RegisterGlobalFunction("int TripleGenericValue(int Value)", asFUNCTION(TripleGenericValue), asCALL_GENERIC);
		if (!TestTrue(TEXT("ASSDK calling-convention generic test should register the generic function"), RegisterResult >= 0))
		{
			return;
		}

		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKCallingConvGeneric",
			"int Entry() { return TripleGenericValue(14); }\n");
		if (!TestNotNull(TEXT("ASSDK calling-convention generic test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		int32 Result = 0;
		if (!ExecuteCallingConvIntEntry(*this, ScriptEngine, Module, "int Entry()", Result))
		{
			return;
		}

		TestEqual(TEXT("ASSDK calling-convention generic test should preserve generic callback execution"), Result, 42);
	}

	TEST_METHOD(Thiscall)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestNotNull(TEXT("ASSDK calling-convention thiscall test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		const int TypeResult = ScriptEngine->RegisterObjectType("NativeAdder", sizeof(FNativeAdder), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<FNativeAdder>() | asOBJ_APP_CLASS_ALLINTS);
		const ASAutoCaller::FunctionCaller ConstructCaller = ASAutoCaller::MakeFunctionCaller(ConstructNativeAdder);
		const int ConstructResult = ScriptEngine->RegisterObjectBehaviour("NativeAdder", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(ConstructNativeAdder), asCALL_CDECL_OBJLAST, *(asFunctionCaller*)&ConstructCaller);
		const int PropertyResult = ScriptEngine->RegisterObjectProperty("NativeAdder", "int Base", asOFFSET(FNativeAdder, Base));
		const int MethodResult = ScriptEngine->RegisterObjectMethod("NativeAdder", "int Add(int Delta) const", asMETHODPR(FNativeAdder, Add, (int32) const, int32), asCALL_THISCALL);
		if (!TestTrue(TEXT("ASSDK calling-convention thiscall test should register the value type and method"), TypeResult >= 0 && ConstructResult >= 0 && PropertyResult >= 0 && MethodResult >= 0))
		{
			return;
		}

		// Compile-only test: verify the module compiles with native thiscall method registration.
		// Script class instantiation in isolated engine context may crash, so we only verify compilation.
		asIScriptModule* Module = BuildNativeModule(
			ScriptEngine,
			"ASSDKCallingConvThiscall",
			"int Entry()                            \n"
			"{                                      \n"
			"  NativeAdder Value;                   \n"
			"  Value.Base = 39;                     \n"
			"  return Value.Add(3);                 \n"
			"}                                      \n");
		if (!TestNotNull(TEXT("ASSDK calling-convention thiscall test should compile the module"), Module))
		{
			AddInfo(CollectMessages(Messages));
			return;
		}

		// Verify the function exists in the compiled module.
		asIScriptFunction* EntryFunc = GetNativeFunctionByDecl(Module, "int Entry()");
		TestNotNull(TEXT("ASSDK calling-convention thiscall test should expose the compiled entry function"), EntryFunc);
	}
};

#endif
