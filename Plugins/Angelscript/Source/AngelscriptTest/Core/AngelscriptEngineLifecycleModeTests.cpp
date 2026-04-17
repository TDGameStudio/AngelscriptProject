#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptEngineLifecycleModeTests_Private
{
	struct FEngineLifecycleContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FEngineLifecycleContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FEngineLifecycleContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};
}

using namespace AngelscriptTest_Core_AngelscriptEngineLifecycleModeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCreateForTestingLifecycleModeTest,
	"Angelscript.TestModule.Engine.Lifecycle.CreateForTestingUsesScopedSourceOrFallsBackToFull",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCreateForTestingLifecycleModeTest::RunTest(const FString& Parameters)
{
	FEngineLifecycleContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();
	ON_SCOPE_EXIT
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> SourceEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("CreateForTesting lifecycle test should create an isolated full source engine"), SourceEngine.Get()))
	{
		return false;
	}

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();

	{
		FAngelscriptEngineScope SourceScope(*SourceEngine);
		if (!TestTrue(TEXT("Scoped source engine should become the current engine"), FAngelscriptEngine::TryGetCurrentEngine() == SourceEngine.Get()))
		{
			return false;
		}

		TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
		if (!TestNotNull(TEXT("Scoped source engine should allow CreateForTesting(Clone) to return an engine"), CloneEngine.Get()))
		{
			return false;
		}

		TestEqual(TEXT("Scoped CreateForTesting(Clone) should preserve clone creation mode"), CloneEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
		TestFalse(TEXT("Scoped CreateForTesting(Clone) should not own the script engine"), CloneEngine->OwnsEngine());
		TestTrue(TEXT("Scoped CreateForTesting(Clone) should remember the scoped source engine"), CloneEngine->GetSourceEngine() == SourceEngine.Get());
		TestTrue(TEXT("Scoped CreateForTesting(Clone) should reuse the scoped source script engine"), CloneEngine->GetScriptEngine() == SourceEngine->GetScriptEngine());
	}

	if (!TestNull(TEXT("Leaving the source scope should clear the current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> FallbackEngine = FAngelscriptEngine::CreateForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("No-current-engine CreateForTesting(Clone) should fall back to a full engine"), FallbackEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("No-current-engine CreateForTesting(Clone) should report full creation mode"), FallbackEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
	TestTrue(TEXT("No-current-engine CreateForTesting(Clone) should own its script engine"), FallbackEngine->OwnsEngine());
	TestNull(TEXT("No-current-engine CreateForTesting(Clone) should not retain a source engine"), FallbackEngine->GetSourceEngine());
	TestNotNull(TEXT("No-current-engine CreateForTesting(Clone) should still initialize a script engine"), FallbackEngine->GetScriptEngine());
	TestTrue(TEXT("No-current-engine CreateForTesting(Clone) should create a distinct script engine instead of reusing an unscoped source"), FallbackEngine->GetScriptEngine() != SourceEngine->GetScriptEngine());
	return true;
}

#endif
