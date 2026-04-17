#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "ClassGenerator/AngelscriptClassGenerator.h"
#include "Misc/AutomationTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_ClassGenerator_ClassGeneratorTests_Private
{
	FAngelscriptEngine* GetEngineForClassGeneratorTests(FAutomationTestBase* Test)
	{
		if (FAngelscriptEngine* ProductionEngine = AngelscriptTestSupport::TryGetRunningProductionEngine())
		{
			return ProductionEngine;
		}

		return &AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	}
}

using namespace AngelscriptTest_ClassGenerator_ClassGeneratorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptClassGeneratorEmptyModuleSetupTest,
	"Angelscript.TestModule.ClassGenerator.EmptyModuleSetup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptClassGeneratorEmptyModuleSetupTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* Engine = GetEngineForClassGeneratorTests(this);
	if (!TestNotNull(TEXT("ClassGenerator test should have an initialized engine"), Engine))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	TSharedRef<FAngelscriptModuleDesc> Module = MakeShared<FAngelscriptModuleDesc>();
	Module->ModuleName = TEXT("Tests.ClassGenerator.EmptyModule");
	Module->ScriptModule = static_cast<asCModule*>(Engine->GetScriptEngine()->GetModule("Tests.ClassGenerator.EmptyModule", asGM_ALWAYS_CREATE));
	if (!TestNotNull(TEXT("ClassGenerator scaffold should create a backing script module"), Module->ScriptModule))
	{
		return false;
	}

	FAngelscriptClassGenerator Generator;
	Generator.AddModule(Module);

	const FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = Generator.Setup();
	TestEqual(TEXT("An empty module should default to soft reload requirements"), ReloadRequirement, FAngelscriptClassGenerator::EReloadRequirement::SoftReload);
	TestFalse(TEXT("An empty module should not request a suggested full reload"), Generator.WantsFullReload(Module));
	TestFalse(TEXT("An empty module should not require a full reload"), Generator.NeedsFullReload(Module));
	return ReloadRequirement == FAngelscriptClassGenerator::EReloadRequirement::SoftReload;
}

#endif
