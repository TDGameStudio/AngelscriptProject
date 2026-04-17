#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;
using namespace AngelscriptSDKTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKGlobalVarEnumerationTest,
	"Angelscript.TestModule.Native.ASSDK.GlobalVar.Enumerate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKGlobalVarResetTest,
	"Angelscript.TestModule.Native.ASSDK.GlobalVar.ResetState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKGlobalVarRemoveTest,
	"Angelscript.TestModule.Native.ASSDK.GlobalVar.RemoveBeforeDiscard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKStackDataLimitTest,
	"Angelscript.TestModule.Native.ASSDK.Stack.DataLimit",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKStackCallLimitTest,
	"Angelscript.TestModule.Native.ASSDK.Stack.CallLimit",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKStackExceptionLocationTest,
	"Angelscript.TestModule.Native.ASSDK.Stack.ExceptionLocation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Native_AngelscriptASSDKGlobalVarTests_Private
{
	static const char* RecursiveScript =
		"void recursive(int n) \n"
		"{                     \n"
		"  if (n > 0)          \n"
		"  {                   \n"
		"    recursive(n - 1); \n"
		"  }                   \n"
		"}                     \n";

	int FindGlobalVarIndexByName(asIScriptModule* Module, const char* Name)
	{
		if (Module == nullptr || Name == nullptr)
		{
			return -1;
		}

		const asUINT GlobalVarCount = Module->GetGlobalVarCount();
		for (asUINT Index = 0; Index < GlobalVarCount; ++Index)
		{
			const char* GlobalVarName = nullptr;
			if (Module->GetGlobalVar(Index, &GlobalVarName) >= 0 && GlobalVarName != nullptr && std::strcmp(GlobalVarName, Name) == 0)
			{
				return static_cast<int>(Index);
			}
		}

		return -1;
	}

	int FindGlobalVarIndexByDeclaration(asIScriptModule* Module, const char* Declaration)
	{
		if (Module == nullptr || Declaration == nullptr)
		{
			return -1;
		}

		const asUINT GlobalVarCount = Module->GetGlobalVarCount();
		for (asUINT Index = 0; Index < GlobalVarCount; ++Index)
		{
			const char* GlobalDeclaration = Module->GetGlobalVarDeclaration(Index);
			if (GlobalDeclaration != nullptr && std::strcmp(GlobalDeclaration, Declaration) == 0)
			{
				return static_cast<int>(Index);
			}
		}

		return -1;
	}
}

using namespace AngelscriptTest_Native_AngelscriptASSDKGlobalVarTests_Private;

bool FAngelscriptASSDKGlobalVarEnumerationTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK global-var enumeration test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKGlobalVarEnumerate",
		"const int a = 1; const double b = 2.0; const double c = 35.2; const uint d = 0xC0DE;");
	if (!TestNotNull(TEXT("ASSDK global-var enumeration test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var enumeration test should expose four globals"), static_cast<int32>(Module->GetGlobalVarCount()), 4))
	{
		return false;
	}

	const char* Declaration = Module->GetGlobalVarDeclaration(0);
	if (!TestNotNull(TEXT("ASSDK global-var enumeration test should report the first declaration"), Declaration))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var enumeration test should preserve the first declaration"), FString(UTF8_TO_TCHAR(Declaration)), FString(TEXT("const int a"))))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var enumeration test should find globals by name"), FindGlobalVarIndexByName(Module, "b"), 1))
	{
		return false;
	}

	const int ConstGlobalIndex = FindGlobalVarIndexByName(Module, "c");
	if (!TestEqual(TEXT("ASSDK global-var enumeration test should find the const global by name"), ConstGlobalIndex, 2))
	{
		return false;
	}

	const char* ConstGlobalName = nullptr;
	int ConstGlobalTypeId = 0;
	bool bIsConstGlobal = false;
	if (!TestTrue(TEXT("ASSDK global-var enumeration test should read metadata for the const global"), Module->GetGlobalVar(ConstGlobalIndex, &ConstGlobalName, nullptr, &ConstGlobalTypeId, &bIsConstGlobal) >= 0))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var enumeration test should preserve the const global name"), FString(UTF8_TO_TCHAR(ConstGlobalName != nullptr ? ConstGlobalName : "")), FString(TEXT("c"))))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK global-var enumeration test should mark the third global as const"), bIsConstGlobal))
	{
		return false;
	}

	const char* GlobalName = nullptr;
	Module->GetGlobalVar(3, &GlobalName);
	if (!TestEqual(TEXT("ASSDK global-var enumeration test should expose the global name for index 3"), FString(UTF8_TO_TCHAR(GlobalName != nullptr ? GlobalName : "")), FString(TEXT("d"))))
	{
		return false;
	}

	asUINT* DValue = static_cast<asUINT*>(Module->GetAddressOfGlobalVar(3));
	if (!TestNotNull(TEXT("ASSDK global-var enumeration test should expose the uint storage"), DValue))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK global-var enumeration test should preserve the uint initializer"), static_cast<uint32>(*DValue), static_cast<uint32>(0xC0DE));
}

bool FAngelscriptASSDKGlobalVarResetTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK global-var reset test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKGlobalVarReset",
		"const double First = 2.0; const double Second = 5.0;");
	if (!TestNotNull(TEXT("ASSDK global-var reset test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var reset test should reset globals successfully"), Module->ResetGlobalVars(), static_cast<int32>(asSUCCESS)))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK global-var reset test should keep both const globals after reset"), static_cast<int32>(Module->GetGlobalVarCount()), 2);
}

bool FAngelscriptASSDKGlobalVarRemoveTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK global-var remove test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKGlobalVarRemove",
		"const int First = 1; const int Second = 2;");
	if (!TestNotNull(TEXT("ASSDK global-var remove test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	if (!TestEqual(TEXT("ASSDK global-var remove test should start with two globals"), static_cast<int32>(Module->GetGlobalVarCount()), 2))
	{
		return false;
	}

	if (!TestTrue(TEXT("ASSDK global-var remove test should remove the first global successfully"), Module->RemoveGlobalVar(0) >= 0))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK global-var remove test should leave one global after removal"), static_cast<int32>(Module->GetGlobalVarCount()), 1);
}

bool FAngelscriptASSDKStackDataLimitTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK stack data-limit test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKStackDataLimit", RecursiveScript);
	if (!TestNotNull(TEXT("ASSDK stack data-limit test should compile the recursive module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK stack data-limit test should create a context"), Context))
	{
		return false;
	}

	ScriptEngine->SetEngineProperty(asEP_INIT_STACK_SIZE, 256);
	ScriptEngine->SetEngineProperty(asEP_MAX_STACK_SIZE, 256);
	Context->Prepare(GetNativeFunctionByDecl(Module, "void recursive(int)"));
	Context->SetArgDWord(0, 100);
	const int ExecuteResult = Context->Execute();
	Context->Release();
	return TestEqual(TEXT("ASSDK stack data-limit test should raise an execution exception when the data stack overflows"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION));
}

bool FAngelscriptASSDKStackCallLimitTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK stack call-limit test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKStackCallLimit", RecursiveScript);
	if (!TestNotNull(TEXT("ASSDK stack call-limit test should compile the recursive module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK stack call-limit test should create a context"), Context))
	{
		return false;
	}

	ScriptEngine->SetEngineProperty(asEP_INIT_CALL_STACK_SIZE, 1);
	ScriptEngine->SetEngineProperty(asEP_MAX_CALL_STACK_SIZE, 1);
	ScriptEngine->SetEngineProperty(asEP_MAX_NESTED_CALLS, 1);
	Context->Prepare(GetNativeFunctionByDecl(Module, "void recursive(int)"));
	Context->SetArgDWord(0, 1000);
	const int ExecuteResult = Context->Execute();
	Context->Release();
	return TestEqual(TEXT("ASSDK stack call-limit test should raise an execution exception when the call stack overflows"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION));
}

bool FAngelscriptASSDKStackExceptionLocationTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK stack exception-location test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	ScriptEngine->SetEngineProperty(asEP_MAX_STACK_SIZE, 256);
	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKStackExceptionLocation",
		RecursiveScript);
	if (!TestNotNull(TEXT("ASSDK stack exception-location test should compile the overflow module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	asIScriptContext* Context = ScriptEngine->CreateContext();
	if (!TestNotNull(TEXT("ASSDK stack exception-location test should create a context"), Context))
	{
		return false;
	}

	const int PrepareResult = Context->Prepare(GetNativeFunctionByDecl(Module, "void recursive(int)"));
	if (!TestEqual(TEXT("ASSDK stack exception-location test should prepare the entry point"), PrepareResult, static_cast<int32>(asSUCCESS)))
	{
		Context->Release();
		return false;
	}

	Context->SetArgDWord(0, 100);
	const int ExecuteResult = Context->Execute();
	const FString ExceptionString = UTF8_TO_TCHAR(Context->GetExceptionString() != nullptr ? Context->GetExceptionString() : "");
	const FString ExceptionFunctionName = Context->GetExceptionFunction() != nullptr
		? UTF8_TO_TCHAR(Context->GetExceptionFunction()->GetName())
		: FString();
	Context->Release();

	if (!TestEqual(TEXT("ASSDK stack exception-location test should raise an execution exception"), ExecuteResult, static_cast<int32>(asEXECUTION_EXCEPTION)))
	{
		return false;
	}

	if (!TestEqual(TEXT("ASSDK stack exception-location test should surface the stack overflow reason"), ExceptionString, FString(TEXT("Stack overflow"))))
	{
		return false;
	}

	return TestEqual(TEXT("ASSDK stack exception-location test should report the recursive function as the overflow site"), ExceptionFunctionName, FString(TEXT("recursive")));
}

#endif
