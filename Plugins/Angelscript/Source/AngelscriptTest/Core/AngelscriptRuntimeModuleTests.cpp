#include "AngelscriptEngine.h"
#include "AngelscriptGameInstanceSubsystem.h"
#include "AngelscriptRuntimeModule.h"
#include "Angelscript/AngelscriptTestSupport.h"

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
	static bool TickFallbackPrimaryEngine(FAngelscriptRuntimeModule& Module, float DeltaTime)
	{
		return Module.TickFallbackPrimaryEngine(DeltaTime);
	}

	static void SetInitializeOverride(TFunction<FAngelscriptEngine*()> InOverride)
	{
		FAngelscriptRuntimeModule::SetInitializeOverrideForTesting(MoveTemp(InOverride));
	}

	static void SetStartupEnvironmentOverride(const TOptional<bool>& bIsEditorOverride, const TOptional<bool>& bIsRunningCommandletOverride)
	{
		FAngelscriptRuntimeModule::SetStartupEnvironmentOverrideForTesting(bIsEditorOverride, bIsRunningCommandletOverride);
	}

	static void ClearStartupEnvironmentOverride()
	{
		FAngelscriptRuntimeModule::ClearStartupEnvironmentOverrideForTesting();
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

	static bool HasFallbackTicker(const FAngelscriptRuntimeModule& Module)
	{
		return Module.FallbackTickHandle.IsValid();
	}

	static void SetFallbackTicker(FAngelscriptRuntimeModule& Module, FTSTicker::FDelegateHandle InHandle)
	{
		Module.FallbackTickHandle = InHandle;
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
	FAngelscriptRuntimeModuleShutdownReleasesOwnedPrimaryEngineAndTickerHandleTest,
	"Angelscript.TestModule.Engine.RuntimeModule.ShutdownReleasesOwnedPrimaryEngineAndTickerHandle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleStartupModuleHonorsEditorAndCommandletGatesTest,
	"Angelscript.TestModule.Engine.RuntimeModule.StartupModuleHonorsEditorAndCommandletGates",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleFallbackTickRespectsSubsystemOwnershipTest,
	"Angelscript.TestModule.Engine.RuntimeModule.FallbackTickRespectsSubsystemOwnership",
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

bool FAngelscriptRuntimeModuleShutdownReleasesOwnedPrimaryEngineAndTickerHandleTest::RunTest(const FString& Parameters)
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
	if (!TestTrue(
			TEXT("RuntimeModule shutdown test should create an owned primary engine when no current engine exists"),
			FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine()))
	{
		return false;
	}

	FAngelscriptEngine* OwnedEngine = FAngelscriptRuntimeModuleTickTestAccess::GetOwnedPrimaryEngine();
	if (!TestNotNull(
			TEXT("RuntimeModule shutdown test should expose the owned primary engine instance"),
			OwnedEngine))
	{
		return false;
	}
	if (!TestTrue(
			TEXT("RuntimeModule shutdown test should push the owned primary engine onto the context stack"),
			FAngelscriptEngine::TryGetCurrentEngine() == OwnedEngine))
	{
		return false;
	}

	FAngelscriptRuntimeModuleTickTestAccess::SetFallbackTicker(
		RuntimeModule,
		FTSTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateLambda([](float)
		{
			return true;
		})));

	if (!TestTrue(
			TEXT("RuntimeModule shutdown test should inject a fallback ticker handle before shutdown"),
			FAngelscriptRuntimeModuleTickTestAccess::HasFallbackTicker(RuntimeModule)))
	{
		return false;
	}

	RuntimeModule.ShutdownModule();

	bool bPassed = true;
	bPassed &= TestFalse(
		TEXT("RuntimeModule shutdown test should clear the fallback ticker handle on first shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasFallbackTicker(RuntimeModule));
	bPassed &= TestFalse(
		TEXT("RuntimeModule shutdown test should release the owned primary engine on first shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());
	bPassed &= TestNull(
		TEXT("RuntimeModule shutdown test should clear the current engine after releasing the owned primary engine"),
		FAngelscriptEngine::TryGetCurrentEngine());

	TArray<FAngelscriptEngine*> StackAfterFirstShutdown = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("RuntimeModule shutdown test should leave the context stack empty after first shutdown"),
		StackAfterFirstShutdown.Num(),
		0);

	RuntimeModule.ShutdownModule();

	bPassed &= TestFalse(
		TEXT("RuntimeModule shutdown test should keep the fallback ticker handle cleared on repeated shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasFallbackTicker(RuntimeModule));
	bPassed &= TestFalse(
		TEXT("RuntimeModule shutdown test should keep the owned primary engine released on repeated shutdown"),
		FAngelscriptRuntimeModuleTickTestAccess::HasOwnedPrimaryEngine());
	bPassed &= TestNull(
		TEXT("RuntimeModule shutdown test should keep the current engine cleared on repeated shutdown"),
		FAngelscriptEngine::TryGetCurrentEngine());

	TArray<FAngelscriptEngine*> StackAfterSecondShutdown = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("RuntimeModule shutdown test should keep the context stack empty on repeated shutdown"),
		StackAfterSecondShutdown.Num(),
		0);
	return bPassed;
}

bool FAngelscriptRuntimeModuleStartupModuleHonorsEditorAndCommandletGatesTest::RunTest(const FString& Parameters)
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
		FAngelscriptRuntimeModuleTickTestAccess::ClearStartupEnvironmentOverride();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> OverrideEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("RuntimeModule startup gate test should create an isolated override engine"), OverrideEngine.Get()))
	{
		return false;
	}

	struct FStartupScenario
	{
		const TCHAR* Label;
		bool bIsEditor = false;
		bool bIsRunningCommandlet = false;
		int32 ExpectedInitializeCalls = 0;
		bool bExpectFallbackTicker = false;
	};

	const TArray<FStartupScenario> Scenarios = {
		{ TEXT("EditorStartup"), true, false, 1, true },
		{ TEXT("CommandletStartup"), false, true, 1, false },
		{ TEXT("PlainRuntimeStartup"), false, false, 0, false },
	};

	bool bPassed = true;
	for (const FStartupScenario& Scenario : Scenarios)
	{
		int32 InitializeCalls = 0;
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		FAngelscriptRuntimeModuleTickTestAccess::ClearStartupEnvironmentOverride();

		if (!TestNull(FString::Printf(TEXT("%s should start without a current engine"), Scenario.Label), FAngelscriptEngine::TryGetCurrentEngine()))
		{
			return false;
		}

		FAngelscriptRuntimeModuleTickTestAccess::SetStartupEnvironmentOverride(Scenario.bIsEditor, Scenario.bIsRunningCommandlet);
		FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([&OverrideEngine, &InitializeCalls]()
		{
			++InitializeCalls;
			return OverrideEngine.Get();
		});

		FAngelscriptRuntimeModule RuntimeModule;
		RuntimeModule.StartupModule();

		bPassed &= TestEqual(
			FString::Printf(TEXT("%s should trigger the expected number of initialize calls"), Scenario.Label),
			InitializeCalls,
			Scenario.ExpectedInitializeCalls);
		bPassed &= TestEqual(
			FString::Printf(TEXT("%s should match the expected fallback ticker registration state"), Scenario.Label),
			FAngelscriptRuntimeModuleTickTestAccess::HasFallbackTicker(RuntimeModule),
			Scenario.bExpectFallbackTicker);

		if (Scenario.ExpectedInitializeCalls > 0)
		{
			bPassed &= TestTrue(
				FString::Printf(TEXT("%s should push the override engine when initialization runs"), Scenario.Label),
				FAngelscriptEngine::TryGetCurrentEngine() == OverrideEngine.Get());
		}
		else
		{
			bPassed &= TestNull(
				FString::Printf(TEXT("%s should keep the context stack empty when initialization is gated off"), Scenario.Label),
				FAngelscriptEngine::TryGetCurrentEngine());
		}

		RuntimeModule.ShutdownModule();

		bPassed &= TestFalse(
			FString::Printf(TEXT("%s should clear the fallback ticker handle during shutdown"), Scenario.Label),
			FAngelscriptRuntimeModuleTickTestAccess::HasFallbackTicker(RuntimeModule));

		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
		bPassed &= TestNull(
			FString::Printf(TEXT("%s should leave no current engine after reset"), Scenario.Label),
			FAngelscriptEngine::TryGetCurrentEngine());

		const TArray<FAngelscriptEngine*> StackAfterScenario = FAngelscriptEngineContextStack::SnapshotAndClear();
		bPassed &= TestEqual(
			FString::Printf(TEXT("%s should leave the context stack empty after teardown"), Scenario.Label),
			StackAfterScenario.Num(),
			0);
	}

	return bPassed;
}

bool FAngelscriptRuntimeModuleFallbackTickRespectsSubsystemOwnershipTest::RunTest(const FString& Parameters)
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
	if (!TestNotNull(TEXT("RuntimeModule fallback tick test should create an isolated full engine"), TestEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope EngineScope(*TestEngine);
	if (!TestTrue(TEXT("RuntimeModule fallback tick test should make the isolated engine current"), FAngelscriptEngine::TryGetCurrentEngine() == TestEngine.Get()))
	{
		return false;
	}

	FAngelscriptRuntimeModule RuntimeModule;
	bool bPassed = true;

	FAngelscriptTickBehaviorTestAccess::SetActiveTickOwners(0);
	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*TestEngine, -1.0);

	bPassed &= TestFalse(
		TEXT("RuntimeModule fallback tick test should start without subsystem tick owners"),
		UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	bPassed &= TestTrue(
		TEXT("RuntimeModule fallback tick test should keep the ticker alive when no subsystem owner exists"),
		FAngelscriptRuntimeModuleTickTestAccess::TickFallbackPrimaryEngine(RuntimeModule, 0.016f));
	bPassed &= TestTrue(
		TEXT("RuntimeModule fallback tick test should advance NextHotReloadCheck when fallback tick owns progression"),
		FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*TestEngine) > 0.0);

	FAngelscriptTickBehaviorTestAccess::SetActiveTickOwners(1);
	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*TestEngine, -1.0);

	bPassed &= TestTrue(
		TEXT("RuntimeModule fallback tick test should report an active subsystem tick owner after the owner setup"),
		UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	bPassed &= TestTrue(
		TEXT("RuntimeModule fallback tick test should keep the ticker alive when a subsystem owner exists"),
		FAngelscriptRuntimeModuleTickTestAccess::TickFallbackPrimaryEngine(RuntimeModule, 0.016f));
	bPassed &= TestEqual(
		TEXT("RuntimeModule fallback tick test should leave NextHotReloadCheck unchanged while a subsystem owner exists"),
		FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*TestEngine),
		-1.0);

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
