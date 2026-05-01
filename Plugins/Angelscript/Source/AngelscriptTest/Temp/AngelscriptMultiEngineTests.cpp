#include "AngelscriptEngine.h"
#include "AngelscriptBinds.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"
#include "Testing/AngelscriptBindExecutionObservation.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptengine.h"
#include "source/as_module.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

struct FAngelscriptMultiEngineTestAccess
{
	static void DestroyGlobalEngine()
	{
		FAngelscriptEngine::DestroyGlobal();
	}

	static FAngelscriptEngine* GetGlobalEngine()
	{
		return FAngelscriptEngine::TryGetGlobalEngine();
	}

	static FString MakeModuleName(const FAngelscriptEngine& Engine, const FString& ModuleName)
	{
		return Engine.MakeModuleName(ModuleName);
	}

	static asIScriptModule* CreateNamedModule(FAngelscriptEngine& Engine, const FString& ModuleName)
	{
		return Engine.Engine->GetModule(TCHAR_TO_ANSI(*Engine.MakeModuleName(ModuleName)), asGM_ALWAYS_CREATE);
	}

	static asIScriptModule* FindNamedModule(FAngelscriptEngine& Engine, const FString& ModuleName)
	{
		return Engine.Engine->GetModule(TCHAR_TO_ANSI(*Engine.MakeModuleName(ModuleName)), asGM_ONLY_IF_EXISTS);
	}

	static void TrackNamedModule(FAngelscriptEngine& Engine, const FString& ModuleName, asIScriptModule* ScriptModule)
	{
		TSharedRef<FAngelscriptModuleDesc> ModuleDesc = MakeShared<FAngelscriptModuleDesc>();
		ModuleDesc->ModuleName = ModuleName;
		ModuleDesc->ScriptModule = static_cast<asCModule*>(ScriptModule);
		Engine.ActiveModules.Add(Engine.MakeModuleName(ModuleName), ModuleDesc);
		Engine.ModulesByScriptModule.Add(ScriptModule, ModuleDesc);
	}

	static int32 GetActiveParticipants(const FAngelscriptEngine& Engine)
	{
		return Engine.GetActiveParticipantsForTesting();
	}

	static int32 GetActiveCloneCount(const FAngelscriptEngine& Engine)
	{
		return Engine.GetActiveCloneCountForTesting();
	}

	static int32 GetLocalPooledContextCount(asIScriptEngine* ScriptEngine)
	{
		return FAngelscriptEngine::GetLocalPooledContextCountForTesting(ScriptEngine);
	}
};

struct FMultiEngineContextStackGuard
{
	TArray<FAngelscriptEngine*> SavedStack;
	FMultiEngineContextStackGuard()
	{
		SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
	}
	~FMultiEngineContextStackGuard()
	{
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
	}
};

static void ResetToIsolatedEngineState()
{
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptMultiEngineTestAccess::DestroyGlobalEngine();
	}
}

static FName MakeUniqueStartupBindName(const TCHAR* Prefix)
{
	return FName(*FString::Printf(TEXT("%s.%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits)));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineCreateFullModeTest,
	"Angelscript.TestModule.CppTests.MultiEngine.Create.Full",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineCreateCloneModeTest,
	"Angelscript.TestModule.CppTests.MultiEngine.Create.Clone",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineCreateForTestingDefaultsToCloneTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CreateForTesting.DefaultsToClone",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineCreateForTestingUsesScopedSourceEngineTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CreateForTesting.UsesScopedSourceEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineCreateForTestingFallbacksToFullTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CreateForTesting.FallbacksToFull",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCloneModuleIsolationTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CloneModuleIsolation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCloneDestroyDoesNotAffectPrimaryTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CloneDestroyDoesNotAffectPrimary",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCloneKeepsSharedStateAliveTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CloneKeepsSharedStateAlive",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDestroyingSourceWhileCloneAliveIsRejectedTest,
	"Angelscript.TestModule.CppTests.MultiEngine.DestroyingSourceWhileCloneAliveIsRejected",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDeferredSharedStateReleasePurgesLocalContextPoolTest,
	"Angelscript.TestModule.CppTests.MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSecondFullCreateIsRejectedBeforeBindRegistrationTest,
	"Angelscript.TestModule.CppTests.MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSingleFullDestroyResetsGlobalStateTest,
	"Angelscript.TestModule.CppTests.MultiEngine.SingleFullDestroyResetsGlobalState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCloneHonorsInjectedDependenciesTest,
	"Angelscript.TestModule.CppTests.MultiEngine.CloneHonorsInjectedDependencies",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupBindObservationFullCreateTest,
	"Angelscript.TestModule.CppTests.MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupBindObservationCloneCreateTest,
	"Angelscript.TestModule.CppTests.MultiEngine.StartupBindObservation.CloneCreateDoesNotReplayBinds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupBindObservationCreateForTestingCloneTest,
	"Angelscript.TestModule.CppTests.MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupBindObservationCreateForTestingFullFallbackTest,
	"Angelscript.TestModule.CppTests.MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSharedStateParticipantCountsTest,
	"Angelscript.TestModule.CppTests.MultiEngine.SharedState.ParticipantCountsTrackFullAndClones",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineCreateFullModeTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::Create(Config, Dependencies);

	if (!TestNotNull(TEXT("MultiEngine.Create.Full should create an engine instance"), Engine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.Create.Full should mark the engine as Full"), Engine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
	TestTrue(TEXT("MultiEngine.Create.Full should own the underlying script engine"), Engine->OwnsEngine());
	TestNull(TEXT("MultiEngine.Create.Full should not record a source engine"), Engine->GetSourceEngine());
	return TestNotNull(TEXT("MultiEngine.Create.Full should immediately create an asIScriptEngine"), Engine->GetScriptEngine());
}

bool FAngelscriptEngineCreateCloneModeTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.Create.Clone should create a source engine"), SourceEngine.Get()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
	if (!TestNotNull(TEXT("MultiEngine.Create.Clone should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.Create.Clone should mark the clone as Clone"), CloneEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
	TestFalse(TEXT("MultiEngine.Create.Clone should not own the shared script engine"), CloneEngine->OwnsEngine());
	TestTrue(TEXT("MultiEngine.Create.Clone should record the source engine"), CloneEngine->GetSourceEngine() == SourceEngine.Get());
	TestTrue(TEXT("MultiEngine.Create.Clone should share the source asIScriptEngine"), CloneEngine->GetScriptEngine() == SourceEngine->GetScriptEngine());
	return true;
}

bool FAngelscriptEngineCreateForTestingDefaultsToCloneTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should create a source engine"), SourceEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*SourceEngine);

	TUniquePtr<FAngelscriptEngine> TestEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should create a test engine"), TestEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should choose Clone mode when a source engine exists"), TestEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
	TestFalse(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should not own the shared script engine"), TestEngine->OwnsEngine());
	TestTrue(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should point back to the global source engine"), TestEngine->GetSourceEngine() == SourceEngine.Get());
	return TestTrue(TEXT("MultiEngine.CreateForTesting.DefaultsToClone should share the global asIScriptEngine"), TestEngine->GetScriptEngine() == SourceEngine->GetScriptEngine());
}

bool FAngelscriptEngineCreateForTestingUsesScopedSourceEngineTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should create a source engine"), SourceEngine.Get()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> TestEngine;
	{
		FAngelscriptEngineScope SourceScope(*SourceEngine);
		TestEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	}

	if (!TestNotNull(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should create a testing engine"), TestEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should choose Clone mode when a scoped source engine exists"), TestEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
	TestFalse(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should not own the shared script engine"), TestEngine->OwnsEngine());
	TestTrue(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should point back to the scoped source engine"), TestEngine->GetSourceEngine() == SourceEngine.Get());
	return TestTrue(TEXT("MultiEngine.CreateForTesting.UsesScopedSourceEngine should share the scoped source script engine"), TestEngine->GetScriptEngine() == SourceEngine->GetScriptEngine());
}

bool FAngelscriptEngineCreateForTestingFallbacksToFullTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();
	FMultiEngineContextStackGuard StackGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();

	TUniquePtr<FAngelscriptEngine> TestEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.CreateForTesting.FallbacksToFull should create a test engine"), TestEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.CreateForTesting.FallbacksToFull should choose Full mode when no source engine exists"), TestEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
	TestTrue(TEXT("MultiEngine.CreateForTesting.FallbacksToFull should own its script engine"), TestEngine->OwnsEngine());
	TestNull(TEXT("MultiEngine.CreateForTesting.FallbacksToFull should not record a source engine"), TestEngine->GetSourceEngine());
	return TestNotNull(TEXT("MultiEngine.CreateForTesting.FallbacksToFull should create an asIScriptEngine immediately"), TestEngine->GetScriptEngine());
}

bool FAngelscriptCloneModuleIsolationTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FString ModuleName = TEXT("Tests.SharedModule");
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> PrimaryEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> CloneA = FAngelscriptEngine::CreateCloneFrom(*PrimaryEngine, Config);
	TUniquePtr<FAngelscriptEngine> CloneB = FAngelscriptEngine::CreateCloneFrom(*PrimaryEngine, Config);

	if (!TestNotNull(TEXT("MultiEngine.CloneModuleIsolation should create primary engine"), PrimaryEngine.Get())
		|| !TestNotNull(TEXT("MultiEngine.CloneModuleIsolation should create first clone"), CloneA.Get())
		|| !TestNotNull(TEXT("MultiEngine.CloneModuleIsolation should create second clone"), CloneB.Get()))
	{
		return false;
	}

	asIScriptModule* CloneAModule = FAngelscriptMultiEngineTestAccess::CreateNamedModule(*CloneA, ModuleName);
	asIScriptModule* CloneBModule = FAngelscriptMultiEngineTestAccess::CreateNamedModule(*CloneB, ModuleName);
	FAngelscriptMultiEngineTestAccess::TrackNamedModule(*CloneA, ModuleName, CloneAModule);
	FAngelscriptMultiEngineTestAccess::TrackNamedModule(*CloneB, ModuleName, CloneBModule);

	TestNotNull(TEXT("MultiEngine.CloneModuleIsolation should create the first clone module"), CloneAModule);
	TestNotNull(TEXT("MultiEngine.CloneModuleIsolation should create the second clone module"), CloneBModule);
	TestTrue(TEXT("MultiEngine.CloneModuleIsolation should give Clone A an internal module name"), FAngelscriptMultiEngineTestAccess::MakeModuleName(*CloneA, ModuleName).Contains(TEXT("::")));
	TestTrue(TEXT("MultiEngine.CloneModuleIsolation should give Clone B an internal module name"), FAngelscriptMultiEngineTestAccess::MakeModuleName(*CloneB, ModuleName).Contains(TEXT("::")));
	TestNotEqual(TEXT("MultiEngine.CloneModuleIsolation should isolate internal module names per clone"), FAngelscriptMultiEngineTestAccess::MakeModuleName(*CloneA, ModuleName), FAngelscriptMultiEngineTestAccess::MakeModuleName(*CloneB, ModuleName));
	TestTrue(TEXT("MultiEngine.CloneModuleIsolation should keep external lookup working for Clone A"), CloneA->GetModuleByModuleName(ModuleName).IsValid());
	TestTrue(TEXT("MultiEngine.CloneModuleIsolation should keep external lookup working for Clone B"), CloneB->GetModuleByModuleName(ModuleName).IsValid());
	return TestTrue(TEXT("MultiEngine.CloneModuleIsolation should create distinct underlying script modules"), CloneAModule != CloneBModule);
}

bool FAngelscriptCloneDestroyDoesNotAffectPrimaryTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FString ModuleName = TEXT("Tests.SharedModule");
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> PrimaryEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*PrimaryEngine, Config);

	if (!TestNotNull(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should create primary engine"), PrimaryEngine.Get())
		|| !TestNotNull(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should create clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	asIScriptModule* PrimaryModule = FAngelscriptMultiEngineTestAccess::CreateNamedModule(*PrimaryEngine, ModuleName);
	asIScriptModule* CloneModule = FAngelscriptMultiEngineTestAccess::CreateNamedModule(*CloneEngine, ModuleName);
	FAngelscriptMultiEngineTestAccess::TrackNamedModule(*PrimaryEngine, ModuleName, PrimaryModule);
	FAngelscriptMultiEngineTestAccess::TrackNamedModule(*CloneEngine, ModuleName, CloneModule);

	if (!TestNotNull(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should create the primary module"), PrimaryModule)
		|| !TestNotNull(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should create the clone module"), CloneModule))
	{
		return false;
	}

	CloneEngine.Reset();

	TestTrue(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should keep the primary module descriptor registered"), PrimaryEngine->GetModuleByModuleName(ModuleName).IsValid());
	return TestNotNull(TEXT("MultiEngine.CloneDestroyDoesNotAffectPrimary should keep the primary underlying script module alive"), FAngelscriptMultiEngineTestAccess::FindNamedModule(*PrimaryEngine, ModuleName));
}

bool FAngelscriptCloneKeepsSharedStateAliveTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);

	if (!TestNotNull(TEXT("MultiEngine.CloneKeepsSharedStateAlive should create a source engine"), SourceEngine.Get())
		|| !TestNotNull(TEXT("MultiEngine.CloneKeepsSharedStateAlive should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	int32 RegisteredTypeCountBeforeDestroy = 0;
	{
		FAngelscriptEngineScope SourceScope(*SourceEngine);
		RegisteredTypeCountBeforeDestroy = FAngelscriptType::GetTypes().Num();
	}
	if (!TestTrue(TEXT("MultiEngine.CloneKeepsSharedStateAlive should start with registered types"), RegisteredTypeCountBeforeDestroy > 0))
	{
		return false;
	}

	AddExpectedError(TEXT("Rejecting Full engine shutdown while Clone instances still reference shared state"), EAutomationExpectedErrorFlags::Contains, 1);
	SourceEngine.Reset();

	{
		FAngelscriptEngineScope CloneScope(*CloneEngine);
		TestTrue(TEXT("MultiEngine.CloneKeepsSharedStateAlive should keep shared type registrations alive while the clone remains"), FAngelscriptType::GetTypes().Num() > 0);
	}
	return TestNotNull(TEXT("MultiEngine.CloneKeepsSharedStateAlive should keep the shared script engine reachable from the clone"), CloneEngine->GetScriptEngine());
}

bool FAngelscriptDestroyingSourceWhileCloneAliveIsRejectedTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);

	if (!TestNotNull(TEXT("MultiEngine.DestroyingSourceWhileCloneAliveIsRejected should create a source engine"), SourceEngine.Get())
		|| !TestNotNull(TEXT("MultiEngine.DestroyingSourceWhileCloneAliveIsRejected should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	AddExpectedError(TEXT("Rejecting Full engine shutdown while Clone instances still reference shared state"), EAutomationExpectedErrorFlags::Contains, 1);
	SourceEngine.Reset();

	TestNull(TEXT("MultiEngine.DestroyingSourceWhileCloneAliveIsRejected should clear the clone's source-engine link once the source owner is gone"), CloneEngine->GetSourceEngine());
	return TestNotNull(TEXT("MultiEngine.DestroyingSourceWhileCloneAliveIsRejected should leave the clone with a usable shared script engine reference"), CloneEngine->GetScriptEngine());
}

bool FAngelscriptDeferredSharedStateReleasePurgesLocalContextPoolTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);

	if (!TestNotNull(TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should create a source engine"), SourceEngine.Get())
		|| !TestNotNull(TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	asIScriptEngine* SharedScriptEngine = SourceEngine->GetScriptEngine();
	if (!TestNotNull(TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should resolve the shared script engine"), SharedScriptEngine))
	{
		return false;
	}

	{
		FAngelscriptEngineScope SourceScope(*SourceEngine);
		{
			FAngelscriptPooledContextBase SeedContext;
		}
	}

	if (!TestTrue(
		TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should place the seeded context into the local pool"),
		FAngelscriptMultiEngineTestAccess::GetLocalPooledContextCount(SharedScriptEngine) > 0))
	{
		return false;
	}

	AddExpectedError(TEXT("Rejecting Full engine shutdown while Clone instances still reference shared state"), EAutomationExpectedErrorFlags::Contains, 1);
	SourceEngine.Reset();

	if (!TestTrue(
		TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should keep the pooled shared context alive while the clone still references shared state"),
		FAngelscriptMultiEngineTestAccess::GetLocalPooledContextCount(SharedScriptEngine) > 0))
	{
		return false;
	}

	CloneEngine.Reset();
	return TestEqual(
		TEXT("MultiEngine.DeferredSharedStateReleasePurgesLocalContextPool should purge pooled contexts when the deferred shared state is finally released"),
		FAngelscriptMultiEngineTestAccess::GetLocalPooledContextCount(SharedScriptEngine),
		0);
}

bool FAngelscriptSecondFullCreateIsRejectedBeforeBindRegistrationTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> FirstOwner = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration should create the first full owner"), FirstOwner.Get()))
	{
		return false;
	}

	int32 FirstOwnerTypeCount = 0;
	{
		FAngelscriptEngineScope FirstOwnerScope(*FirstOwner);
		FirstOwnerTypeCount = FAngelscriptType::GetTypes().Num();
	}

	if (!TestTrue(TEXT("MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration should start with registered type metadata"), FirstOwnerTypeCount > 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> SecondOwner = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration should now allow a second full owner"), SecondOwner.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope FirstOwnerScope(*FirstOwner);
		TestEqual(TEXT("MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration should keep the original full owner's type metadata intact"), FAngelscriptType::GetTypes().Num(), FirstOwnerTypeCount);
	}

	{
		FAngelscriptEngineScope SecondOwnerScope(*SecondOwner);
		TestTrue(TEXT("MultiEngine.SecondFullCreateIsRejectedBeforeBindRegistration should initialize type metadata for the second full owner"), FAngelscriptType::GetTypes().Num() > 0);
	}

	return true;
}

bool FAngelscriptSingleFullDestroyResetsGlobalStateTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();
	FMultiEngineContextStackGuard StackGuard;

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);

	if (!TestNotNull(TEXT("MultiEngine.SingleFullDestroyResetsGlobalState should create a full owner"), Engine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope EngineScope(*Engine);
		if (!TestTrue(TEXT("MultiEngine.SingleFullDestroyResetsGlobalState should populate type metadata before teardown"), FAngelscriptType::GetTypes().Num() > 0))
		{
			return false;
		}
	}

	Engine.Reset();

	return TestEqual(TEXT("MultiEngine.SingleFullDestroyResetsGlobalState should clear type metadata after the only owner exits"), FAngelscriptType::GetTypes().Num(), 0);
}

bool FAngelscriptCloneHonorsInjectedDependenciesTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;

	const FAngelscriptEngineDependencies SourceDependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, SourceDependencies, EAngelscriptEngineCreationMode::Full);
	if (!TestNotNull(TEXT("MultiEngine.CloneHonorsInjectedDependencies should create a source testing full engine"), SourceEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*SourceEngine);

	bool bMakeDirectoryCalled = false;
	FString CreatedPath;

	FAngelscriptEngineDependencies InjectedDependencies;
	InjectedDependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/InjectedCloneProject"));
	};
	InjectedDependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};
	InjectedDependencies.DirectoryExists = [](const FString& Path)
	{
		return false;
	};
	InjectedDependencies.MakeDirectory = [&bMakeDirectoryCalled, &CreatedPath](const FString& Path, bool bTree)
	{
		bMakeDirectoryCalled = true;
		CreatedPath = Path;
		return true;
	};
	InjectedDependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>();
	};

	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, InjectedDependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("MultiEngine.CloneHonorsInjectedDependencies should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	TArray<FString> Roots = CloneEngine->DiscoverScriptRoots(false);
	TestTrue(TEXT("MultiEngine.CloneHonorsInjectedDependencies should honor the injected editor filesystem hooks"), bMakeDirectoryCalled);
	if (Roots.Num() > 0)
	{
		TestEqual(TEXT("MultiEngine.CloneHonorsInjectedDependencies should use the injected project root"), Roots[0], FString(TEXT("C:/InjectedCloneProject/Script")));
	}
	return TestEqual(TEXT("MultiEngine.CloneHonorsInjectedDependencies should create the expected injected clone project root path"), CreatedPath, FString(TEXT("C:/InjectedCloneProject/Script")));
}

bool FAngelscriptStartupBindObservationFullCreateTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FName FirstBindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.Full.First"));
	const FName SecondBindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.Full.Second"));
	FAngelscriptBinds::FBind FirstBind(FirstBindName, -25, []() {});
	FAngelscriptBinds::FBind SecondBind(SecondBindName, 25, []() {});

	FAngelscriptBindExecutionObservation::Reset();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds should create a full engine"), Engine.Get()))
	{
		return false;
	}

	const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
	if (!TestEqual(TEXT("MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds should observe a single startup bind pass"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 1))
	{
		return false;
	}

	const int32 FirstIndex = Snapshot.ExecutedBindNames.IndexOfByKey(FirstBindName);
	const int32 SecondIndex = Snapshot.ExecutedBindNames.IndexOfByKey(SecondBindName);
	if (!TestTrue(TEXT("MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds should observe the first named bind"), FirstIndex != INDEX_NONE)
		|| !TestTrue(TEXT("MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds should observe the second named bind"), SecondIndex != INDEX_NONE))
	{
		return false;
	}

	return TestTrue(TEXT("MultiEngine.StartupBindObservation.FullCreateRecordsOrderedBinds should preserve bind order in the observed startup pass"), FirstIndex < SecondIndex);
}

bool FAngelscriptStartupBindObservationCloneCreateTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FName BindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.Clone.Named"));
	FAngelscriptBinds::FBind NamedBind(BindName, []() {});

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.CloneCreateDoesNotReplayBinds should create a source engine"), SourceEngine.Get()))
	{
		return false;
	}

	FAngelscriptBindExecutionObservation::Reset();
	TUniquePtr<FAngelscriptEngine> CloneEngine = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.CloneCreateDoesNotReplayBinds should create a clone engine"), CloneEngine.Get()))
	{
		return false;
	}

	if (!TestEqual(TEXT("MultiEngine.StartupBindObservation.CloneCreateDoesNotReplayBinds should not observe a fresh startup bind pass for clone creation"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 0))
	{
		return false;
	}

	const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
	return TestEqual(TEXT("MultiEngine.StartupBindObservation.CloneCreateDoesNotReplayBinds should not append any executed bind names during clone creation"), Snapshot.ExecutedBindNames.Num(), 0);
}

bool FAngelscriptStartupBindObservationCreateForTestingCloneTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FName BindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.CreateForTesting.Clone.Named"));
	FAngelscriptBinds::FBind NamedBind(BindName, []() {});

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Full);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds should create a source full engine"), SourceEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope GlobalScope(*SourceEngine);
	FAngelscriptBindExecutionObservation::Reset();

	TUniquePtr<FAngelscriptEngine> TestEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds should create a clone testing engine"), TestEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds should choose clone mode when a global source engine exists"), TestEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Clone);
	if (!TestEqual(TEXT("MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds should not observe a fresh bind pass"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 0))
	{
		return false;
	}

	const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
	return TestEqual(TEXT("MultiEngine.StartupBindObservation.CreateForTestingCloneDoesNotReplayBinds should keep the observed bind list empty"), Snapshot.ExecutedBindNames.Num(), 0);
}

bool FAngelscriptStartupBindObservationCreateForTestingFullFallbackTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();
	FMultiEngineContextStackGuard StackGuard;

	const FName FirstBindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.CreateForTesting.FullFallback.First"));
	const FName SecondBindName = MakeUniqueStartupBindName(TEXT("Automation.StartupBind.CreateForTesting.FullFallback.Second"));
	FAngelscriptBinds::FBind FirstBind(FirstBindName, -50, []() {});
	FAngelscriptBinds::FBind SecondBind(SecondBindName, 50, []() {});

	FAngelscriptBindExecutionObservation::Reset();

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> TestEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should create a fallback full engine"), TestEngine.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should fall back to full mode when no global engine exists"), TestEngine->GetCreationMode(), EAngelscriptEngineCreationMode::Full);
	if (!TestEqual(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should observe one startup bind pass"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 1))
	{
		return false;
	}

	const FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
	const int32 FirstIndex = Snapshot.ExecutedBindNames.IndexOfByKey(FirstBindName);
	const int32 SecondIndex = Snapshot.ExecutedBindNames.IndexOfByKey(SecondBindName);
	if (!TestTrue(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should observe the first bind"), FirstIndex != INDEX_NONE)
		|| !TestTrue(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should observe the second bind"), SecondIndex != INDEX_NONE))
	{
		return false;
	}

	return TestTrue(TEXT("MultiEngine.StartupBindObservation.CreateForTestingFullFallbackReplaysBinds should preserve order for the fallback full startup pass"), FirstIndex < SecondIndex);
}

bool FAngelscriptSharedStateParticipantCountsTest::RunTest(const FString& Parameters)
{
	ResetToIsolatedEngineState();

	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> SourceEngine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should create the full owner"), SourceEngine.Get()))
	{
		return false;
	}

	if (!TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should start with one active participant"), FAngelscriptMultiEngineTestAccess::GetActiveParticipants(*SourceEngine), 1)
		|| !TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should start with zero active clones"), FAngelscriptMultiEngineTestAccess::GetActiveCloneCount(*SourceEngine), 0))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> CloneA = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
	TUniquePtr<FAngelscriptEngine> CloneB = FAngelscriptEngine::CreateCloneFrom(*SourceEngine, Config);
	if (!TestNotNull(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should create clone A"), CloneA.Get())
		|| !TestNotNull(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should create clone B"), CloneB.Get()))
	{
		return false;
	}

	TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should count the full owner and two clones"), FAngelscriptMultiEngineTestAccess::GetActiveParticipants(*SourceEngine), 3);
	TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should count two active clones"), FAngelscriptMultiEngineTestAccess::GetActiveCloneCount(*SourceEngine), 2);

	CloneB.Reset();
	TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should decrement participants when one clone is destroyed"), FAngelscriptMultiEngineTestAccess::GetActiveParticipants(*SourceEngine), 2);
	return TestEqual(TEXT("MultiEngine.SharedState.ParticipantCountsTrackFullAndClones should decrement clone count when one clone is destroyed"), FAngelscriptMultiEngineTestAccess::GetActiveCloneCount(*SourceEngine), 1);
}

#endif
