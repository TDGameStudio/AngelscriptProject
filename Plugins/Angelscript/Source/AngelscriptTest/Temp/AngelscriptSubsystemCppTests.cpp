#include "AngelscriptEngine.h"
#include "AngelscriptEngineSubsystem.h"
#include "AngelscriptGameInstanceSubsystem.h"
#include "AngelscriptRuntimeModule.h"
#include "Engine/GameInstance.h"
#include "Misc/AutomationTest.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "Tests/AutomationCommon.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameInstanceSubsystemTest,
	"Angelscript.TestModule.CppTests.Subsystem.GameInstanceSubsystem",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSubsystemCreatesPrimaryEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.CreatesPrimaryEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSubsystemTicksPrimaryEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.TicksPrimaryEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSubsystemDeinitializeDestroysPrimaryEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.DeinitializeDestroysPrimaryEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineSubsystemDoesNotTickWhenGameInstanceSubsystemOwnsEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.EngineSubsystem.DoesNotTickWhenGameInstanceSubsystemOwnsEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleInitializeCreatesGlobalEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.RuntimeModule.InitializeCreatesGlobalEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptRuntimeModuleStartupDoesNotBootstrapPrimaryEngineTest,
	"Angelscript.TestModule.CppTests.Subsystem.RuntimeModule.StartupDoesNotBootstrapPrimaryEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineSubsystemTicksGlobalEngineWithoutGameInstanceOwnerTest,
	"Angelscript.TestModule.CppTests.Subsystem.EngineSubsystem.TicksGlobalEngineWithoutGameInstanceOwner",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

struct FAngelscriptTickBehaviorTestAccess
{
	static FAngelscriptEngine* TryGetGlobalEngine()
	{
		return FAngelscriptEngine::TryGetGlobalEngine();
	}

	static void ResetToIsolatedState()
	{
		if (!UAngelscriptGameInstanceSubsystem::HasAnyTickOwner() && FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptEngine::DestroyGlobal();
		}
	}

	static double GetNextHotReloadCheck(const FAngelscriptEngine& Engine)
	{
		return Engine.NextHotReloadCheck;
	}

	static void PrepareTickProbe(FAngelscriptEngine& Engine)
	{
		Engine.bScriptDevelopmentMode = true;
		Engine.bUseHotReloadCheckerThread = true;
		Engine.bWaitingForHotReloadResults = false;
		Engine.NextHotReloadCheck = 0.0;
	}

	static void SetSubsystemPrimaryEngine(UAngelscriptGameInstanceSubsystem& Subsystem, FAngelscriptEngine* Engine)
	{
		Subsystem.PrimaryEngine = Engine;
		Subsystem.bOwnsPrimaryEngine = true;
		Subsystem.bInitialized = true;
		Subsystem.ActiveTickOwners = 1;
		FAngelscriptEngineContextStack::Push(Engine);
	}
};

struct FAngelscriptRuntimeModuleTickTestAccess
{
	static void ResetInitializeState()
	{
		FAngelscriptRuntimeModule::ResetInitializeStateForTesting();
	}

	static void SetInitializeOverride(TFunction<FAngelscriptEngine*()> InOverride)
	{
		FAngelscriptRuntimeModule::SetInitializeOverrideForTesting(MoveTemp(InOverride));
	}
};

static UAngelscriptGameInstanceSubsystem* CreateSubsystemWorld(FAutomationTestBase& Test, FTestWorldWrapper& TestWorld)
{
	FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();

	if (!TestWorld.CreateTestWorld(EWorldType::Game))
	{
		TestWorld.ForwardErrorMessages(&Test);
		return nullptr;
	}

	UWorld* World = TestWorld.GetTestWorld();
	if (!Test.TestNotNull(TEXT("A test world should be created"), World))
	{
		TestWorld.DestroyTestWorld(true);
		return nullptr;
	}

	UGameInstance* GameInstance = World->GetGameInstance();
	if (!Test.TestNotNull(TEXT("A game instance should be created for the test world"), GameInstance))
	{
		TestWorld.DestroyTestWorld(true);
		return nullptr;
	}

	return GameInstance->GetSubsystem<UAngelscriptGameInstanceSubsystem>();
}

static UAngelscriptGameInstanceSubsystem* CreateInjectedSubsystem(FAutomationTestBase& Test, FAngelscriptEngine* Engine, TStrongObjectPtr<UGameInstance>& OutGameInstance)
{
	if (!Test.TestNotNull(TEXT("Injected subsystem helper should receive an engine"), Engine))
	{
		return nullptr;
	}

	OutGameInstance.Reset(NewObject<UGameInstance>());
	if (!Test.TestNotNull(TEXT("Injected subsystem helper should create a game instance outer"), OutGameInstance.Get()))
	{
		return nullptr;
	}

	UAngelscriptGameInstanceSubsystem* Subsystem = NewObject<UAngelscriptGameInstanceSubsystem>(OutGameInstance.Get());
	if (!Test.TestNotNull(TEXT("Injected subsystem helper should create the subsystem object"), Subsystem))
	{
		return nullptr;
	}

	FAngelscriptTickBehaviorTestAccess::SetSubsystemPrimaryEngine(*Subsystem, Engine);
	return Subsystem;
}

bool FAngelscriptGameInstanceSubsystemTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("Game instance subsystem test should create a test engine wrapper"), OwnedEngine.Get()))
	{
		return false;
	}

	TStrongObjectPtr<UGameInstance> GameInstance;
	UAngelscriptGameInstanceSubsystem* TypedSubsystem = CreateInjectedSubsystem(*this, OwnedEngine.Get(), GameInstance);
	if (!TestNotNull(TEXT("Game instance subsystem test should create an injected subsystem instance"), TypedSubsystem))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*TypedSubsystem->GetEngine());
	ON_SCOPE_EXIT
	{
		TypedSubsystem->Deinitialize();
	};

	UClass* SubsystemClass = StaticLoadClass(
		UGameInstanceSubsystem::StaticClass(),
		nullptr,
		TEXT("/Script/AngelscriptRuntime.AngelscriptGameInstanceSubsystem"));
	if (!TestNotNull(TEXT("Angelscript game instance subsystem class should exist"), SubsystemClass))
	{
		return false;
	}

	UGameInstanceSubsystem* Subsystem = TypedSubsystem;
	const bool bSubsystemExists = TestNotNull(TEXT("Game instance should expose the Angelscript subsystem"), Subsystem);
	if (bSubsystemExists)
	{
		if (TestNotNull(TEXT("Subsystem should cast to UAngelscriptGameInstanceSubsystem"), TypedSubsystem))
		{
			FAngelscriptEngine* SubsystemEngine = TypedSubsystem->GetEngine();
			if (TestNotNull(TEXT("Subsystem should expose a live angelscript engine"), SubsystemEngine))
			{
				TestTrue(TEXT("Legacy FAngelscriptEngine::Get() should resolve to the subsystem engine"), &FAngelscriptEngine::Get() == SubsystemEngine);
			}
		}
	}
	return bSubsystemExists;
}

bool FAngelscriptSubsystemCreatesPrimaryEngineTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	TStrongObjectPtr<UGameInstance> GameInstance;
	UAngelscriptGameInstanceSubsystem* Subsystem = CreateInjectedSubsystem(*this, OwnedEngine.Get(), GameInstance);
	if (!TestNotNull(TEXT("Subsystem create test should expose the Angelscript subsystem"), Subsystem))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*Subsystem->GetEngine());
	ON_SCOPE_EXIT
	{
		Subsystem->Deinitialize();
	};

	FAngelscriptEngine* PrimaryEngine = Subsystem->GetEngine();
	const bool bHasPrimaryEngine = TestNotNull(TEXT("Subsystem create test should create a primary engine"), PrimaryEngine);
	if (bHasPrimaryEngine)
	{
		TestTrue(TEXT("Subsystem create test should register the primary engine as the current global engine"), FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine() == PrimaryEngine);
		TestTrue(TEXT("Subsystem create test should mark a tick owner as active"), UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	}
	return bHasPrimaryEngine;
}

bool FAngelscriptSubsystemTicksPrimaryEngineTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	TStrongObjectPtr<UGameInstance> GameInstance;
	UAngelscriptGameInstanceSubsystem* Subsystem = CreateInjectedSubsystem(*this, OwnedEngine.Get(), GameInstance);
	if (!TestNotNull(TEXT("Subsystem tick test should expose the Angelscript subsystem"), Subsystem))
	{
		return false;
	}
	FAngelscriptEngineScope GlobalScope(*Subsystem->GetEngine());

	ON_SCOPE_EXIT
	{
		Subsystem->Deinitialize();
	};

	FAngelscriptEngine* PrimaryEngine = Subsystem->GetEngine();
	if (!TestNotNull(TEXT("Subsystem tick test should create a primary engine"), PrimaryEngine))
	{
		return false;
	}

	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*PrimaryEngine);
	if (!TestTrue(TEXT("Subsystem tick test should mark the subsystem as allowed to tick"), Subsystem->IsAllowedToTick()))
	{
		return false;
	}
	if (!TestTrue(TEXT("Subsystem tick test should expose a tickable primary engine"), PrimaryEngine->ShouldTick()))
	{
		return false;
	}
	Subsystem->Tick(0.0f);
	return true;
}

bool FAngelscriptSubsystemDeinitializeDestroysPrimaryEngineTest::RunTest(const FString& Parameters)
{
	TArray<FAngelscriptEngine*> SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
	ON_SCOPE_EXIT { FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack)); };

	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Full);
	if (!TestNotNull(TEXT("Subsystem deinitialize test should create a test-owned primary engine"), OwnedEngine.Get()))
	{
		return false;
	}

	UGameInstance* GameInstance = NewObject<UGameInstance>();
	UAngelscriptGameInstanceSubsystem* Subsystem = NewObject<UAngelscriptGameInstanceSubsystem>(GameInstance);
	if (!TestNotNull(TEXT("Subsystem deinitialize test should allocate a subsystem object"), Subsystem))
	{
		return false;
	}

	FAngelscriptTickBehaviorTestAccess::SetSubsystemPrimaryEngine(*Subsystem, OwnedEngine.Get());
	Subsystem->Deinitialize();

	TestFalse(TEXT("Subsystem deinitialize test should clear active tick owners"), UAngelscriptGameInstanceSubsystem::HasAnyTickOwner());
	return TestNull(TEXT("Subsystem deinitialize test should release the engine it owned"), Subsystem->GetEngine());
}

bool FAngelscriptEngineSubsystemDoesNotTickWhenGameInstanceSubsystemOwnsEngineTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	TStrongObjectPtr<UGameInstance> GameInstance;
	UAngelscriptGameInstanceSubsystem* Subsystem = CreateInjectedSubsystem(*this, OwnedEngine.Get(), GameInstance);
	if (!TestNotNull(TEXT("EngineSubsystem tick-owner test should expose the Angelscript game instance subsystem"), Subsystem))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*Subsystem->GetEngine());
	ON_SCOPE_EXIT
	{
		Subsystem->Deinitialize();
	};

	FAngelscriptEngine* PrimaryEngine = Subsystem->GetEngine();
	if (!TestNotNull(TEXT("EngineSubsystem tick-owner test should create a primary engine"), PrimaryEngine))
	{
		return false;
	}

	UAngelscriptEngineSubsystem* EngineSubsystem = NewObject<UAngelscriptEngineSubsystem>(GetTransientPackage());
	if (!TestNotNull(TEXT("EngineSubsystem tick-owner test should create a native engine subsystem object"), EngineSubsystem))
	{
		return false;
	}
	EngineSubsystem->EnsurePrimaryEngineInitialized();

	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*PrimaryEngine);
	EngineSubsystem->Tick(0.0f);
	const bool bDidNotTick = TestEqual(TEXT("EngineSubsystem tick should not touch the primary engine while the game instance subsystem owns ticking"), FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*PrimaryEngine), 0.0);
	EngineSubsystem->Deinitialize();
	return bDidNotTick;
}

bool FAngelscriptRuntimeModuleInitializeCreatesGlobalEngineTest::RunTest(const FString& Parameters)
{
	FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([]()
	{
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateUncompiled(Config, Dependencies).Release();
	});
	ON_SCOPE_EXIT
	{
		FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	};

	FAngelscriptRuntimeModule::InitializeAngelscript();
	FAngelscriptEngine* GlobalEngine = FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine();
	if (!TestNotNull(TEXT("Runtime module initialize test should create the global primary engine"), GlobalEngine))
	{
		return false;
	}

	TestEqual(TEXT("Runtime module initialize test should create a full engine"), GlobalEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
	return TestTrue(TEXT("Runtime module initialize test should leave a tickable primary engine"), GlobalEngine->ShouldTick());
}

bool FAngelscriptRuntimeModuleStartupDoesNotBootstrapPrimaryEngineTest::RunTest(const FString& Parameters)
{
	FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	int32 InitializeCalls = 0;
	FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([&InitializeCalls]()
	{
		++InitializeCalls;
		return nullptr;
	});
	FAngelscriptRuntimeModule RuntimeModule;
	ON_SCOPE_EXIT
	{
		RuntimeModule.ShutdownModule();
		FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	};

	FAngelscriptEngine* PreStartupEngine = FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine();
	RuntimeModule.StartupModule();
	TestEqual(TEXT("Runtime module startup test should not call compatibility initialization"), InitializeCalls, 0);
	TestTrue(TEXT("Runtime module startup test should not replace the engine subsystem primary engine"), FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine() == PreStartupEngine);

	RuntimeModule.ShutdownModule();
	return TestTrue(TEXT("Runtime module shutdown should not release the engine subsystem primary engine"), FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine() == PreStartupEngine);
}

bool FAngelscriptEngineSubsystemTicksGlobalEngineWithoutGameInstanceOwnerTest::RunTest(const FString& Parameters)
{
	FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
	FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	FAngelscriptRuntimeModuleTickTestAccess::SetInitializeOverride([]()
	{
		FAngelscriptEngineConfig Config;
		Config.bDevelopmentMode = true;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateUncompiled(Config, Dependencies).Release();
	});
	ON_SCOPE_EXIT
	{
		FAngelscriptTickBehaviorTestAccess::ResetToIsolatedState();
		FAngelscriptRuntimeModuleTickTestAccess::ResetInitializeState();
	};

	FAngelscriptRuntimeModule::InitializeAngelscript();
	FAngelscriptEngine* GlobalEngine = FAngelscriptTickBehaviorTestAccess::TryGetGlobalEngine();
	if (!TestNotNull(TEXT("EngineSubsystem tick without game instance owner should start from a global engine"), GlobalEngine))
	{
		return false;
	}

	FAngelscriptTickBehaviorTestAccess::PrepareTickProbe(*GlobalEngine);
	UAngelscriptEngineSubsystem* EngineSubsystem = NewObject<UAngelscriptEngineSubsystem>(GetTransientPackage());
	if (!TestNotNull(TEXT("EngineSubsystem tick without game instance owner should create a native subsystem object"), EngineSubsystem))
	{
		return false;
	}

	EngineSubsystem->EnsurePrimaryEngineInitialized();
	EngineSubsystem->Tick(0.0f);
	const bool bTicked = TestTrue(TEXT("EngineSubsystem tick without game instance owner should advance the next hot reload check"), FAngelscriptTickBehaviorTestAccess::GetNextHotReloadCheck(*GlobalEngine) > 0.0);
	EngineSubsystem->Deinitialize();
	return bTicked;
}

#endif
