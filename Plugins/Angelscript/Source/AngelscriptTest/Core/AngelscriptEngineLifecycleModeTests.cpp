#include "AngelscriptEngine.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "CQTest.h"

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


TEST_CLASS_WITH_FLAGS(FAngelscriptEngineLifecycleModeTests,
	"Angelscript.TestModule.Engine.Lifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(CreateForTestingUsesScopedSourceOrFallsBackToFull)
	{
		using namespace AngelscriptTest_Core_AngelscriptEngineLifecycleModeTests_Private;
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
		if (!TestRunner->TestNotNull(TEXT("CreateForTesting lifecycle test should create an isolated full source engine"), SourceEngine.Get()))
		{
			return;
		}

		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();

		{
			FAngelscriptEngineScope SourceScope(*SourceEngine);
			if (!TestRunner->TestTrue(TEXT("Scoped source engine should become the current engine"), FAngelscriptEngine::TryGetCurrentEngine() == SourceEngine.Get()))
			{
				return;
			}

			TUniquePtr<FAngelscriptEngine> CloneEngine = AngelscriptTestSupport::CreateScriptScanFreeEngineForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
			if (!TestRunner->TestNotNull(TEXT("Scoped source engine should allow CreateForTesting(Clone) to return an engine"), CloneEngine.Get()))
			{
				return;
			}

			TestRunner->TestEqual(TEXT("Scoped CreateForTesting(Clone) should preserve clone creation mode"), CloneEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
			TestRunner->TestFalse(TEXT("Scoped CreateForTesting(Clone) should not own the script engine"), CloneEngine->OwnsEngine());
			TestRunner->TestTrue(TEXT("Scoped CreateForTesting(Clone) should remember the scoped source engine"), CloneEngine->GetSourceEngine() == SourceEngine.Get());
			TestRunner->TestTrue(TEXT("Scoped CreateForTesting(Clone) should reuse the scoped source script engine"), CloneEngine->GetScriptEngine() == SourceEngine->GetScriptEngine());
		}

		if (!TestRunner->TestNull(TEXT("Leaving the source scope should clear the current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
		{
			return;
		}

		TUniquePtr<FAngelscriptEngine> FallbackEngine = AngelscriptTestSupport::CreateScriptScanFreeEngineForTesting(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
		if (!TestRunner->TestNotNull(TEXT("No-current-engine CreateForTesting(Clone) should fall back to a full engine"), FallbackEngine.Get()))
		{
			return;
		}

		TestRunner->TestEqual(TEXT("No-current-engine CreateForTesting(Clone) should report full creation mode"), FallbackEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
		TestRunner->TestTrue(TEXT("No-current-engine CreateForTesting(Clone) should own its script engine"), FallbackEngine->OwnsEngine());
		TestRunner->TestNull(TEXT("No-current-engine CreateForTesting(Clone) should not retain a source engine"), FallbackEngine->GetSourceEngine());
		TestRunner->TestNotNull(TEXT("No-current-engine CreateForTesting(Clone) should still initialize a script engine"), FallbackEngine->GetScriptEngine());
		TestRunner->TestTrue(TEXT("No-current-engine CreateForTesting(Clone) should create a distinct script engine instead of reusing an unscoped source"), FallbackEngine->GetScriptEngine() != SourceEngine->GetScriptEngine());
	}
};

#endif
