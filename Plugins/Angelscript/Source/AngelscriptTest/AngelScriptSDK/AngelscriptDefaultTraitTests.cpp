#include "AngelscriptTestAdapter.h"

#include "CQTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

TEST_CLASS_WITH_FLAGS(FAngelscriptASSDKDefaultTraitTests,
	"Angelscript.TestModule.AngelScriptSDK.ASSDK.Compiler",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(DefaultTraitModifiers)
	{
		FNativeMessageCollector Messages;
		asIScriptEngine* ScriptEngine = CreateNativeEngine(&Messages);
		if (!TestRunner->TestNotNull(TEXT("ASSDK default-trait modifier test should create a standalone engine"), ScriptEngine))
		{
			return;
		}

		ON_SCOPE_EXIT
		{
			DestroyNativeEngine(ScriptEngine);
		};

		asIScriptModule* Module = BuildNativeModule(ScriptEngine, "ASSDKDefaultTraitModifiers", R"(
int DefaultsOnlyValue() defaults
{
	return 7;
}

int UnsafeConstructionValue() unsafe_during_construction
{
	return 5;
}

int Entry()
{
	return 1;
}
)");
		if (!TestRunner->TestNotNull(TEXT("ASSDK default-trait modifier test should compile the module"), Module))
		{
			TestRunner->AddInfo(CollectMessages(Messages));
			return;
		}
	}
};

#endif
