#include "AngelscriptConsoleBindingsSections.h"

#include "CQTest.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

TEST_CLASS_WITH_FLAGS(FAngelscriptConsoleCommandErrorBindingsTest,
	"Angelscript.TestModule.Bindings.ConsoleCommandMissingHandler",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(MissingHandlerCompat)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		RunConsoleCommandMissingHandlerSection(*TestRunner, Engine, GetConsoleBindingsProfile());
	}
};

#endif
