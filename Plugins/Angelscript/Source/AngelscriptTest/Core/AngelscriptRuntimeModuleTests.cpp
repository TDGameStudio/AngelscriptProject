#include "AngelscriptEngine.h"
#include "AngelscriptEngineSubsystem.h"
#include "AngelscriptGameInstanceSubsystem.h"
#include "AngelscriptRuntimeModule.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptRuntimeModuleTests_Private
{
	struct FRuntimeModuleContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FRuntimeModuleContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FRuntimeModuleContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};
}

using namespace AngelscriptTest_Core_AngelscriptRuntimeModuleTests_Private;

struct FAngelscriptRuntimeModuleTickTestAccess
{
	static void SetInitializeOverride(TFunction<FAngelscriptEngine*()> InOverride)
	{
		FAngelscriptRuntimeModule::SetInitializeOverrideForTesting(MoveTemp(InOverride));
	}

	static void ResetInitializeState()
	{
		FAngelscriptRuntimeModule::ResetInitializeStateForTesting();
	}

	static bool HasOwnedPrimaryEngine()
	{
		return FAngelscriptRuntimeModule::OwnedPrimaryEngine.IsValid();
	}

	static bool WasInitializeAngelscriptCalled()
	{
		return FAngelscriptRuntimeModule::bInitializeAngelscriptCalled;
	}

	static FAngelscriptEngine* GetOwnedPrimaryEngine()
	{
		return FAngelscriptRuntimeModule::OwnedPrimaryEngine.Get();
	}
};

struct FAngelscriptTickBehaviorTestAccess
{
	static int32 GetActiveTickOwners()
	{
		return UAngelscriptGameInstanceSubsystem::ActiveTickOwners;
	}

	static void SetActiveTickOwners(const int32 InValue)
	{
		UAngelscriptGameInstanceSubsystem::ActiveTickOwners = InValue;
	}

	static double GetNextHotReloadCheck(const FAngelscriptEngine& Engine)
	{
		return Engine.NextHotReloadCheck;
	}

	static void PrepareTickProbe(FAngelscriptEngine& Engine, const double InNextHotReloadCheck)
	{
		Engine.bScriptDevelopmentMode = true;
		Engine.bUseHotReloadCheckerThread = true;
		Engine.bWaitingForHotReloadResults = false;
		Engine.NextHotReloadCheck = InNextHotReloadCheck;
	}
};

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleInitializeOverrideLifecycleTest,
	"Angelscript.TestModule.Engine.RuntimeModule.InitializeOverrideIsIdempotentAndRestorable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleInitializeRoutesToEngineSubsystemTest,
	"Angelscript.TestModule.Engine.RuntimeModule.InitializeRoutesToEngineSubsystem",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleStartupModuleDoesNotBootstrapPrimaryEngineTest,
	"Angelscript.TestModule.Engine.RuntimeModule.StartupModuleDoesNotBootstrapPrimaryEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineSubsystemTickRespectsGameInstanceOwnershipTest,
	"Angelscript.TestModule.Engine.EngineSubsystem.TickRespectsGameInstanceOwnership",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleInitializeAdoptsAmbientEngineWithoutOwningItTest,
	"Angelscript.TestModule.Engine.RuntimeModule.InitializeAdoptsAmbientEngineWithoutOwningIt",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptRuntimeModuleInitializeOverrideLifecycleTest::RunTest(const FString& Parameters)
{
	FRuntimeModuleContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	if (!TestNull(TEXT("RuntimeModule initialize-override test should start without a current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> OverrideEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("RuntimeModule initialize-override test should create an isolated override engine"), OverrideEngine.Get()))
	{
		return false;
	}

	FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([&OverrideEngine]()
	{
		return OverrideEngine.Get();
	});

	FAngelscriptRuntimeModule::InitializeAngelscript();
	if (!TestTrue(
			TEXT("RuntimeModule initialize-override test should make the override engine current after first initialize"),
			FAngelscriptEngine::TryGetCurrentEngine() == OverrideEngine.Get()))
	{
		return false;
	}

	FAngelscriptRuntimeModule::InitializeAngelscript();

	TArray<FAngelscriptEngine*> StackAfterSecondInitialize = FAngelscriptEngineContextStack::SnapshotAndClear();
	if (!TestEqual(
			TEXT("RuntimeModule initialize-override test should keep exactly one engine on the context stack after repeated initialize"),
			StackAfterSecondInitialize.Num(),
			1)
		|| !TestTrue(
			TEXT("RuntimeModule initialize-override test should keep the override engine as the only stack entry"),
			StackAfterSecondInitialize.Num() == 1 && StackAfterSecondInitialize[0] == OverrideEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(StackAfterSecondInitialize));
	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();

	if (!TestNull(
			TEXT("RuntimeModule initialize-override test should clear the current engine after reset"),
			FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	const TArray<FAngelscriptEngine*> StackAfterReset = FAngelscriptEngineContextStack::SnapshotAndClear();
	return TestEqual(
		TEXT("RuntimeModule initialize-override test should leave the context stack empty after reset"),
		StackAfterReset.Num(),
		0);
}

bool FAngelscriptRuntimeModuleInitializeRoutesToEngineSubsystemTest::RunTest(const FString& Parameters)
{
	FRuntimeModuleContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	FAngelscriptRuntimeModule RuntimeModule;
	UAngelscriptEngineSubsystem* EngineSubsystem = UAngelscriptEngineSubsystem::Get();
	if (!TestNotNull(TEXT("RuntimeModule subsystem-route test should have an engine subsystem in editor automation"), EngineSubsystem))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		RuntimeModule.ShutdownModule();
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	if (!TestNull(TEXT("RuntimeModule shutdown test should start without a current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	FAngelscriptRuntimeModule::InitializeAngelscript();
	if (!TestFalse(
			TEXT("RuntimeModule subsystem-route test should not create a module-owned primary engine when the engine subsystem exists"),
			FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine()))
	{
		return false;
	}

	FAngelscriptEngine* SubsystemEngine = EngineSubsystem->GetEngine();
	if (!TestNotNull(
			TEXT("RuntimeModule subsystem-route test should expose the subsystem primary engine instance"),
			SubsystemEngine))
	{
		return false;
	}
	if (!TestTrue(
			TEXT("RuntimeModule subsystem-route test should make the subsystem primary engine current"),
			FAngelscriptEngine::TryGetCurrentEngine() == SubsystemEngine))
	{
		return false;
	}

	RuntimeModule.ShutdownModule();

	bool bPassed = true;
	bPassed &= TestFalse(
		TEXT("RuntimeModule subsystem-route test should still not own the primary engine after shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());
	bPassed &= TestTrue(
		TEXT("RuntimeModule subsystem-route test should leave the subsystem primary engine current after module shutdown"),
		FAngelscriptEngine::TryGetCurrentEngine() == SubsystemEngine);

	TArray<FAngelscriptEngine*> StackAfterFirstShutdown = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("RuntimeModule subsystem-route test should leave exactly one subsystem engine on the context stack after first shutdown"),
		StackAfterFirstShutdown.Num(),
		1);
	bPassed &= TestTrue(
		TEXT("RuntimeModule subsystem-route test should keep the subsystem engine as the only stack entry"),
		StackAfterFirstShutdown.Num() == 1 && StackAfterFirstShutdown[0] == SubsystemEngine);

	RuntimeModule.ShutdownModule();

	bPassed &= TestFalse(
		TEXT("RuntimeModule subsystem-route test should keep module-owned engine absent on repeated shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());
	bPassed &= TestNull(
		TEXT("RuntimeModule subsystem-route test should keep the current engine cleared after the test manually clears the stack"),
		FAngelscriptEngine::TryGetCurrentEngine());

	TArray<FAngelscriptEngine*> StackAfterSecondShutdown = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("RuntimeModule subsystem-route test should keep the context stack empty after manual clear and repeated shutdown"),
		StackAfterSecondShutdown.Num(),
		0);
	return bPassed;
}

bool FAngelscriptRuntimeModuleStartupModuleDoesNotBootstrapPrimaryEngineTest::RunTest(const FString& Parameters)
{
	FRuntimeModuleContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	int32 InitializeCalls = 0;
	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([&InitializeCalls]()
	{
		++InitializeCalls;
		return nullptr;
	});

	if (!TestNull(TEXT("RuntimeModule startup test should start without a current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	FAngelscriptRuntimeModule RuntimeModule;
	RuntimeModule.StartupModule();

	bool bPassed = true;
	bPassed &= TestEqual(
		TEXT("RuntimeModule startup test should not call compatibility initialization"),
		InitializeCalls,
		0);
	bPassed &= TestFalse(
		TEXT("RuntimeModule startup test should leave InitializeAngelscript uncalled"),
		FAngelscriptRuntimeModuleTickTestAccess::WasInitializeAngelscriptCalled());
	bPassed &= TestNull(
		TEXT("RuntimeModule startup test should leave the context stack empty"),
		FAngelscriptEngine::TryGetCurrentEngine());

	RuntimeModule.ShutdownModule();

	const TArray<FAngelscriptEngine*> StackAfterStartup = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("RuntimeModule startup test should leave the context stack empty after shutdown"),
		StackAfterStartup.Num(),
		0);

	return bPassed;
}

bool FAngelscriptEngineSubsystemTickRespectsGameInstanceOwnershipTest::RunTest(const FString& Parameters)
{
	FRuntimeModuleContextStackGuard ContextGuard;
	const int32 SavedActiveTickOwners = FAngelscriptTickBehaviorTestAccess::GetActiveTickOwners();
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptTickBehaviorTestAccess::SetActiveTickOwners(SavedActiveTickOwners);
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> TestEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("EngineSubsystem tick test should create an isolated full engine"), TestEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope EngineScope(*TestEngine);
	if (!TestTrue(TEXT("EngineSubsystem tick test should make the isolated engine current"), FAngelscriptEngine::TryGetCurrentEngine() == TestEngine.Get()))
	{
		return false;
	}

	TStrongObjectPtr<UAngelscriptEngineSubsystem> EngineSubsystem(NewObject<UAngelscriptEngineSubsystem>(GetTransientPackage()));
	if (!TestNotNull(TEXT("EngineSubsystem tick test should create a native subsystem object"), EngineSubsystem.Get()))
	{
		return false;
	}

	EngineSubsystem->EnsurePrimaryEngineInitialized();
	bool bPassed = true;

	FAngelscriptTickBehaviorTestAccess::SetActiveTickOwners(0);
	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*TestEngine, -1.0);

	bPassed &= TestFalse(
		TEXT("EngineSubsystem tick test should start without game instance tick owners"),
		UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	EngineSubsystem->Tick(0.016f);
	bPassed &= TestTrue(
		TEXT("EngineSubsystem tick test should advance NextHotReloadCheck when no game instance owner exists"),
		FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*TestEngine) > 0.0);

	FAngelscriptTickBehaviorTestAccess::SetActiveTickOwners(1);
	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*TestEngine, -1.0);

	bPassed &= TestTrue(
		TEXT("EngineSubsystem tick test should report an active game instance tick owner after setup"),
		UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	EngineSubsystem->Tick(0.016f);
	bPassed &= TestEqual(
		TEXT("EngineSubsystem tick test should leave NextHotReloadCheck unchanged while a game instance owner exists"),
		FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*TestEngine),
		-1.0);

	EngineSubsystem->Deinitialize();
	return bPassed;
}

bool FAngelscriptRuntimeModuleInitializeAdoptsAmbientEngineWithoutOwningItTest::RunTest(const FString& Parameters)
{
	FRuntimeModuleContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	if (!TestNull(TEXT("RuntimeModule ambient-initialize test should start without a current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> AmbientEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("RuntimeModule ambient-initialize test should create an isolated ambient engine"), AmbientEngine.Get()))
	{
		return false;
	}

	bool bPassed = true;
	{
		FAngelscriptEngineScope AmbientScope(*AmbientEngine);
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should make the isolated engine current inside the scope"),
			FAngelscriptEngine::TryGetCurrentEngine() == AmbientEngine.Get());

		TArray<FAngelscriptEngine*> StackBeforeInitialize = FAngelscriptEngineContextStack::SnapshotAndClear();
		bPassed &= TestEqual(
			TEXT("RuntimeModule ambient-initialize test should start with exactly one ambient engine on the context stack"),
			StackBeforeInitialize.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should keep the ambient engine as the only pre-initialize stack entry"),
			StackBeforeInitialize.Num() == 1 && StackBeforeInitialize[0] == AmbientEngine.Get());
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(StackBeforeInitialize));

		FAngelscriptRuntimeModule::InitializeAngelscript();

		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should mark initialize as called after initialization"),
			FAngelscriptRuntimeModuleTickTestAccess::WasInitializeAngelscriptCalled());
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should keep the ambient engine current after initialization"),
			FAngelscriptEngine::TryGetCurrentEngine() == AmbientEngine.Get());
		bPassed &= TestFalse(
			TEXT("RuntimeModule ambient-initialize test should not create an owned primary engine when an ambient engine already exists"),
			FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());

		TArray<FAngelscriptEngine*> StackAfterInitialize = FAngelscriptEngineContextStack::SnapshotAndClear();
		bPassed &= TestEqual(
			TEXT("RuntimeModule ambient-initialize test should keep the context stack depth unchanged after initialization"),
			StackAfterInitialize.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should keep the ambient engine as the only stack entry after initialization"),
			StackAfterInitialize.Num() == 1 && StackAfterInitialize[0] == AmbientEngine.Get());
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(StackAfterInitialize));

		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();

		bPassed &= TestFalse(
			TEXT("RuntimeModule ambient-initialize test should clear the initialize-called flag on reset"),
			FAngelscriptRuntimeModuleTickTestAccess::WasInitializeAngelscriptCalled());
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should preserve the ambient current engine after reset"),
			FAngelscriptEngine::TryGetCurrentEngine() == AmbientEngine.Get());
		bPassed &= TestFalse(
			TEXT("RuntimeModule ambient-initialize test should still avoid owned-engine creation after reset"),
			FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());

		TArray<FAngelscriptEngine*> StackAfterReset = FAngelscriptEngineContextStack::SnapshotAndClear();
		bPassed &= TestEqual(
			TEXT("RuntimeModule ambient-initialize test should preserve the ambient stack depth after reset"),
			StackAfterReset.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("RuntimeModule ambient-initialize test should keep the ambient engine as the only stack entry after reset"),
			StackAfterReset.Num() == 1 && StackAfterReset[0] == AmbientEngine.Get());
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(StackAfterReset));
	}

	bPassed &= TestNull(
		TEXT("RuntimeModule ambient-initialize test should clear the current engine after the ambient scope exits"),
		FAngelscriptEngine::TryGetCurrentEngine());
	return bPassed;
}

#endif
