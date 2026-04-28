#include "AngelscriptTestAdapter.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASSDKDefaultTraitModifierCompileTest,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.Compiler.DefaultTraitModifiers",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASSDKDefaultTraitModifierCompileTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("ASSDK default-trait modifier test should create a standalone engine"), ScriptEngine))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		DestroyNativeEngine(ScriptEngine);
	};

	asIScriptModule* Module = BuildNativeModule(
		ScriptEngine,
		"ASSDKDefaultTraitModifiers",
		"int DefaultsOnlyValue() defaults { return 7; }                         \n"
		"int UnsafeConstructionValue() unsafe_during_construction { return 5; }  \n"
		"int Entry() { return 1; }                                               \n");
	if (!TestNotNull(TEXT("ASSDK default-trait modifier test should compile the module"), Module))
	{
		AddInfo(CollectMessages(Messages));
		return false;
	}

	return true;
}

#endif
