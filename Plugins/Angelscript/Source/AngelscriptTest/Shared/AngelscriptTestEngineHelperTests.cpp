#include "Shared/AngelscriptTestEngineHelper.h"

#include "Shared/AngelscriptNativeScriptTestObject.h"
#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "Engine/GameInstance.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UObjectIterator.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperCompileModuleTest,
	"Angelscript.TestModule.Shared.EngineHelper.CompileModuleFromMemory",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestEngineHelperCompileModuleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperCompileModule"));
	};

	const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
		&Engine,
		TEXT("HelperCompileModule"),
		TEXT("HelperCompileModule.as"),
		TEXT("int Entry() { return 42; }"));

	TestTrue(TEXT("CompileModuleFromMemory should compile a trivial module"), bCompiled);
	return bCompiled;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperExecuteIntFunctionTest,
	"Angelscript.TestModule.Shared.EngineHelper.ExecuteIntFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestEngineHelperExecuteIntFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperExecuteInt"));
	};

	const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
		&Engine,
		TEXT("HelperExecuteInt"),
		TEXT("HelperExecuteInt.as"),
		TEXT("int DoubleValue(int Value) { return Value * 2; } int Entry() { return DoubleValue(21); }"));
	if (!TestTrue(TEXT("ExecuteIntFunction test module compiles"), bCompiled))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = AngelscriptTestSupport::ExecuteIntFunction(&Engine, TEXT("HelperExecuteInt"), TEXT("int Entry()"), Result);
	if (!TestTrue(TEXT("ExecuteIntFunction should execute the compiled entry point"), bExecuted))
	{
		return false;
	}

	TestEqual(TEXT("ExecuteIntFunction returns the expected result"), Result, 42);
	return Result == 42;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperGeneratedSymbolLookupTest,
	"Angelscript.TestModule.Shared.EngineHelper.GeneratedSymbolLookup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperFailedAnnotatedIsolationTest,
	"Angelscript.TestModule.Shared.EngineHelper.FailedAnnotatedModuleDoesNotPolluteLaterCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperSharedEngineNeverAttachesToProductionTest,
	"Angelscript.TestModule.Shared.EngineHelper.SharedTestEngineNeverSilentlyAttachesToProductionEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperGetSharedTestEngineAliasesSharedCloneTest,
	"Angelscript.TestModule.Shared.EngineHelper.GetSharedTestEngineAliasesSharedCloneEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperGetResetSharedTestEngineResetsSharedStateTest,
	"Angelscript.TestModule.Shared.EngineHelper.GetResetSharedTestEngineResetsSharedState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperProductionHelperRejectsMissingProductionTest,
	"Angelscript.TestModule.Shared.EngineHelper.ProductionHelperRejectsMissingProductionEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperProductionDebuggerHelperPrefersDebuggableEngineOverScopedTestEngineTest,
	"Angelscript.TestModule.Shared.EngineHelper.ProductionDebuggerHelperPrefersDebuggableEngineOverScopedTestEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperResetSharedEngineDiscardsRawModulesTest,
	"Angelscript.TestModule.Shared.EngineHelper.ResetSharedEngineDiscardsRawModules",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperResetSharedEngineReleasesGeneratedComponentClassesTest,
	"Angelscript.TestModule.Shared.EngineHelper.ResetSharedEngineReleasesGeneratedComponentClasses",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperCompileRestoresScopedGlobalEngineTest,
	"Angelscript.TestModule.Shared.EngineHelper.CompileRestoresOuterCurrentEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperNestedGlobalScopeRestoreTest,
	"Angelscript.TestModule.Shared.EngineHelper.NestedCurrentEngineScopeRestoresPreviousEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperWorldContextScopeRestoreTest,
	"Angelscript.TestModule.Shared.EngineHelper.WorldContextScopeRestoresPreviousContext",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperEngineScopeWorldContextRestoreTest,
	"Angelscript.TestModule.Shared.EngineHelper.EngineScopeRestoresWorldContextAndCurrentEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperCompileSummaryPlainModuleTest,
	"Angelscript.TestModule.Shared.EngineHelper.CompileSummaryPlainModule",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperCompileSummaryDiagnosticCaptureTest,
	"Angelscript.TestModule.Shared.EngineHelper.CompileSummaryDiagnosticCapture",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperContextIsolationAcrossEnginesTest,
	"Angelscript.TestModule.Shared.EngineHelper.ExecutingOneTestEngineDoesNotLeakContextIntoNextTest",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestEngineHelperProductionSubsystemDoesNotHijackIsolatedEngineTest,
	"Angelscript.TestModule.Shared.EngineHelper.SubsystemAttachedProductionEngineDoesNotHijackIsolatedTestEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)


bool FAngelscriptTestEngineHelperGeneratedSymbolLookupTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperAnnotatedModule"));
	};

	const bool bCompiled = AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(
		&Engine,
		TEXT("HelperAnnotatedModule"),
		TEXT("HelperAnnotatedModule.as"),
		TEXT(R"(
UCLASS()
class UAnnotatedHelperObject : UObject
{
    UFUNCTION()
    int GetValue()
    {
        return 42;
    }
}
)") );
	if (!TestTrue(TEXT("CompileAnnotatedModuleFromMemory should compile an annotated class module"), bCompiled))
	{
		return false;
	}

	UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(&Engine, TEXT("UAnnotatedHelperObject"));
	if (!TestNotNull(TEXT("FindGeneratedClass should locate the generated class"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = AngelscriptTestSupport::FindGeneratedFunction(GeneratedClass, TEXT("GetValue"));
	TestNotNull(TEXT("FindGeneratedFunction should locate the generated UFunction"), GeneratedFunction);
	return GeneratedFunction != nullptr;
}

bool FAngelscriptTestEngineHelperFailedAnnotatedIsolationTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperBrokenAnnotated"));
		Engine.DiscardModule(TEXT("HelperRecoveredAnnotated"));
	};

	FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
	bool bWantsFullReload = false;
	bool bNeedsFullReload = false;
	const bool bBrokenCompiled = AngelscriptTestSupport::AnalyzeReloadFromMemory(
		&Engine,
		TEXT("HelperBrokenAnnotated"),
		TEXT("HelperBrokenAnnotated.as"),
		TEXT(R"(
UCLASS()
class UBrokenHelperObject : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
	)") ,
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);
	if (!TestFalse(TEXT("Invalid annotated helper module should fail to compile"), bBrokenCompiled))
	{
		return false;
	}
	TestEqual(TEXT("Broken annotated helper module should report an error reload requirement"), ReloadRequirement, FAngelscriptClassGenerator::Error);
	TestFalse(TEXT("Broken annotated helper module should not suggest a full reload"), bWantsFullReload);
	TestFalse(TEXT("Broken annotated helper module should not require a full reload"), bNeedsFullReload);

	const bool bRecoveredCompiled = AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(
		&Engine,
		TEXT("HelperRecoveredAnnotated"),
		TEXT("HelperRecoveredAnnotated.as"),
		TEXT(R"(
UCLASS()
class URecoveredHelperObject : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 7;
	}
}
)") );
	if (!TestTrue(TEXT("A later valid annotated helper module should compile after a failed one"), bRecoveredCompiled))
	{
		return false;
	}

	UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(&Engine, TEXT("URecoveredHelperObject"));
	if (!TestNotNull(TEXT("Recovered generated class should be discoverable"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = AngelscriptTestSupport::FindGeneratedFunction(GeneratedClass, TEXT("GetValue"));
	TestNotNull(TEXT("Recovered generated function should be discoverable"), GeneratedFunction);
	return GeneratedFunction != nullptr;
}

bool FAngelscriptTestEngineHelperSharedEngineNeverAttachesToProductionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* PreviousCurrentEngine = FAngelscriptTestEngineScopeAccess::GetCurrentEngine();
	FAngelscriptEngine* PreviousGlobalEngine = FAngelscriptTestEngineScopeAccess::GetGlobalEngine();
	FAngelscriptEngine& SharedEngine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	return TestTrue(
		TEXT("Explicit shared clone helper should resolve to the shared clone engine instance"),
		&AngelscriptTestSupport::GetOrCreateSharedCloneEngine() == &SharedEngine)
		&& TestTrue(
		TEXT("Clean shared clone helper should keep using the shared clone engine instance"),
		&AngelscriptTestSupport::AcquireCleanSharedCloneEngine() == &SharedEngine)
		&& TestTrue(
		TEXT("Shared clone helper should not silently replace the current engine"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == PreviousCurrentEngine)
		&& TestTrue(
		TEXT("Shared clone helper should not silently install itself as the legacy global engine"),
		FAngelscriptTestEngineScopeAccess::GetGlobalEngine() == PreviousGlobalEngine);
}

bool FAngelscriptTestEngineHelperGetSharedTestEngineAliasesSharedCloneTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();

	ON_SCOPE_EXIT
	{
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	FAngelscriptEngine& FirstSharedEngine = AngelscriptTestSupport::GetSharedTestEngine();
	FAngelscriptEngine& SecondSharedEngine = AngelscriptTestSupport::GetSharedTestEngine();
	FAngelscriptEngine& ExplicitSharedClone = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();

	return TestTrue(
		TEXT("GetSharedTestEngine should reuse the same shared engine instance across calls"),
		&FirstSharedEngine == &SecondSharedEngine)
		&& TestTrue(
		TEXT("GetSharedTestEngine should alias GetOrCreateSharedCloneEngine"),
		&FirstSharedEngine == &ExplicitSharedClone)
		&& TestTrue(
		TEXT("GetSharedTestEngine should install the recreated shared engine as the current scoped engine"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == &FirstSharedEngine)
		&& TestTrue(
		TEXT("GetSharedTestEngine should resolve as the legacy global engine alias after recreating the shared scope"),
		FAngelscriptTestEngineScopeAccess::GetGlobalEngine() == &FirstSharedEngine);
}

bool FAngelscriptTestEngineHelperGetResetSharedTestEngineResetsSharedStateTest::RunTest(const FString& Parameters)
{
	static const FName ModuleName(TEXT("HelperGetResetSharedAlias"));
	static const FString Filename(TEXT("HelperGetResetSharedAlias.as"));

	AngelscriptTestSupport::DestroySharedTestEngine();
	ON_SCOPE_EXIT
	{
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	FAngelscriptEngine& SharedEngine = AngelscriptTestSupport::GetSharedTestEngine();
	const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
		&SharedEngine,
		ModuleName,
		Filename,
		TEXT("int Entry() { return 17; }"));
	if (!TestTrue(TEXT("GetResetSharedTestEngine regression fixture should compile before reset"), bCompiled))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("GetResetSharedTestEngine regression fixture should register a tracked module before reset"),
		SharedEngine.GetModuleByModuleName(ModuleName.ToString()).IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& ResetEngine = AngelscriptTestSupport::GetResetSharedTestEngine();
	return TestTrue(
		TEXT("GetResetSharedTestEngine should reuse the shared engine instance"),
		&ResetEngine == &SharedEngine)
		&& TestFalse(
		TEXT("GetResetSharedTestEngine should clear tracked modules from the shared engine"),
		ResetEngine.GetModuleByModuleName(ModuleName.ToString()).IsValid())
		&& TestNull(
		TEXT("GetResetSharedTestEngine should discard the backing script module"),
		ResetEngine.GetScriptEngine()->GetModule(TCHAR_TO_UTF8(*ModuleName.ToString()), asGM_ONLY_IF_EXISTS));
}

bool FAngelscriptTestEngineHelperResetSharedEngineReleasesGeneratedComponentClassesTest::RunTest(const FString& Parameters)
{
	static const FName ModuleName(TEXT("HelperResetGeneratedComponent"));
	static const FString Filename(TEXT("HelperResetGeneratedComponent.as"));
	static const FName GeneratedClassName(TEXT("UHelperResetGeneratedComponent"));

	FAngelscriptEngine& Engine = AngelscriptTestSupport::AcquireFreshSharedCloneEngine();
	const bool bCompiled = AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(
		&Engine,
		ModuleName,
		Filename,
		TEXT(R"AS(
UCLASS()
class UHelperResetGeneratedComponent : UAngelscriptComponent
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}
)AS"));
	if (!TestTrue(TEXT("Generated component helper module should compile"), bCompiled))
	{
		return false;
	}

	UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(&Engine, GeneratedClassName);
	if (!TestNotNull(TEXT("Generated component helper class should exist before reset"), GeneratedClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& HostActor = Spawner.SpawnActor<AActor>();
	UActorComponent* Component = NewObject<UActorComponent>(&HostActor, GeneratedClass);
	if (!TestNotNull(TEXT("Generated component helper should instantiate"), Component))
	{
		return false;
	}

	HostActor.AddInstanceComponent(Component);
	Component->OnComponentCreated();
	Component->RegisterComponent();
	Component->PrimaryComponentTick.bCanEverTick = true;
	Component->SetComponentTickEnabled(true);
	Component->Activate(true);

	{
		FAngelscriptEngineScope EngineScope(Engine, &HostActor);
		HostActor.DispatchBeginPlay();
	}

	{
		FAngelscriptEngineScope EngineScope(Engine, Component);
		Component->TickComponent(0.016f, ELevelTick::LEVELTICK_All, &Component->PrimaryComponentTick);
	}

	AngelscriptTestSupport::ResetSharedCloneEngine(Engine);

	int32 MatchingClasses = 0;
	int32 RootedMatchingClasses = 0;
	int32 StandaloneMatchingClasses = 0;
	for (TObjectIterator<UASClass> It; It; ++It)
	{
		if (It->GetFName() != GeneratedClassName)
		{
			continue;
		}

		++MatchingClasses;
		if (It->IsRooted())
		{
			++RootedMatchingClasses;
		}
		if (It->HasAnyFlags(RF_Standalone))
		{
			++StandaloneMatchingClasses;
		}
	}

	TestEqual(TEXT("Generated component class should not remain alive after shared reset"), MatchingClasses, 0);
	TestEqual(TEXT("Generated component class should not remain rooted after shared reset"), RootedMatchingClasses, 0);
	TestEqual(TEXT("Generated component class should not remain standalone after shared reset"), StandaloneMatchingClasses, 0);
	return MatchingClasses == 0 && RootedMatchingClasses == 0 && StandaloneMatchingClasses == 0;
}

bool FAngelscriptTestEngineHelperProductionHelperRejectsMissingProductionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* ProductionEngine = AngelscriptTestSupport::TryGetRunningProductionEngine();
	if (UAngelscriptGameInstanceSubsystem* Subsystem = UAngelscriptGameInstanceSubsystem::GetCurrent())
	{
		return TestTrue(
			TEXT("Production-engine probe should resolve the subsystem-attached engine when one is available"),
			ProductionEngine == Subsystem->GetEngine());
	}

	if (FAngelscriptEngine::IsInitialized())
	{
		return TestTrue(
			TEXT("Production-engine probe should resolve the global runtime engine when the runtime is initialized without a subsystem owner"),
			ProductionEngine == &FAngelscriptEngine::Get());
	}

	return TestNull(
		TEXT("Production-engine probe should return null when no production engine is attached"),
		ProductionEngine);
}

bool FAngelscriptTestEngineHelperProductionDebuggerHelperPrefersDebuggableEngineOverScopedTestEngineTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* DebuggableEngine = AngelscriptTestSupport::TryGetRunningProductionDebuggerEngine();
	if (!TestNotNull(TEXT("Scoped production-debugger helper test requires an active debuggable production engine"), DebuggableEngine))
	{
		return false;
	}

	AngelscriptTestSupport::DestroySharedTestEngine();
	FAngelscriptEngine& SharedEngine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	if (!TestTrue(
		TEXT("Shared helper should create a distinct test engine when a debuggable production engine exists"),
		&SharedEngine != DebuggableEngine))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("Shared helper should become the current scoped engine while its persistent scope is active"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == &SharedEngine))
	{
		return false;
	}

	return TestTrue(
		TEXT("Production-debugger helper should still prefer the debuggable production engine over a scoped shared test engine"),
		AngelscriptTestSupport::TryGetRunningProductionDebuggerEngine() == DebuggableEngine);
}

bool FAngelscriptTestEngineHelperResetSharedEngineDiscardsRawModulesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	};

	{
		FAngelscriptEngineScope GlobalScope(Engine);
		asIScriptModule* Module = Engine.GetScriptEngine()->GetModule("HelperRawSharedReset", asGM_ALWAYS_CREATE);
		if (!TestNotNull(TEXT("Raw shared-engine reset test should create a script module"), Module))
		{
			return false;
		}

		asIScriptFunction* Function = nullptr;
		const int32 CompileResult = Module->CompileFunction("HelperRawSharedReset", "int Entry() { return 9; }", 0, 0, &Function);
		if (Function != nullptr)
		{
			Function->Release();
		}

		if (!TestEqual(TEXT("Raw shared-engine reset test should compile successfully"), CompileResult, asSUCCESS))
		{
			return false;
		}
	}

	if (!TestFalse(
		TEXT("Raw shared-engine reset test should not populate tracked module descriptors for direct script-engine modules"),
		Engine.GetModuleByModuleName(TEXT("HelperRawSharedReset")).IsValid()))
	{
		return false;
	}

	if (!TestNotNull(
		TEXT("Raw shared-engine reset test should leave the raw module registered before helper cleanup"),
		Engine.GetScriptEngine()->GetModule("HelperRawSharedReset", asGM_ONLY_IF_EXISTS)))
	{
		return false;
	}

	AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	return TestNull(
		TEXT("ResetSharedCloneEngine should also discard raw direct-compile script modules"),
		Engine.GetScriptEngine()->GetModule("HelperRawSharedReset", asGM_ONLY_IF_EXISTS));
}

bool FAngelscriptTestEngineHelperCompileRestoresScopedGlobalEngineTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* PreviousCurrentEngine = FAngelscriptTestEngineScopeAccess::GetCurrentEngine();
	FAngelscriptEngine& SharedEngine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	TUniquePtr<FAngelscriptEngine> IsolatedEngine = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	if (!TestNotNull(TEXT("Compile restore test should create an isolated engine"), IsolatedEngine.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope SharedScope(SharedEngine);
		const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
			IsolatedEngine.Get(),
			TEXT("HelperScopedGlobalRestore"),
			TEXT("HelperScopedGlobalRestore.as"),
			TEXT("int Entry() { return 1; }"));

		if (!TestTrue(TEXT("Scoped current-engine restore test module should compile"), bCompiled))
		{
			return false;
		}

		if (!TestTrue(
			TEXT("Compiling through helper should restore the previous scoped current engine"),
			FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == &SharedEngine))
		{
			return false;
		}
	}

	return TestTrue(
		TEXT("Leaving the outer scope should restore the previous current engine when no enclosing scoped test engine exists"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == PreviousCurrentEngine);
}

bool FAngelscriptTestEngineHelperNestedGlobalScopeRestoreTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* PreviousCurrentEngine = FAngelscriptTestEngineScopeAccess::GetCurrentEngine();
	TUniquePtr<FAngelscriptEngine> EngineA = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	TUniquePtr<FAngelscriptEngine> EngineB = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	if (!TestNotNull(TEXT("Nested scope restore test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Nested scope restore test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		if (!TestTrue(TEXT("Outer scope should install engine A as the current engine"), FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == EngineA.Get()))
		{
			return false;
		}

		{
			FAngelscriptEngineScope ScopeB(*EngineB);
			if (!TestTrue(TEXT("Inner scope should temporarily install engine B as the current engine"), FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == EngineB.Get()))
			{
				return false;
			}
		}

		if (!TestTrue(TEXT("Leaving inner scope should restore engine A as the current engine"), FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == EngineA.Get()))
		{
			return false;
		}
	}

	return TestTrue(
		TEXT("Leaving the outer scope should restore the previous current engine when no enclosing scoped test engine exists"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == PreviousCurrentEngine);
}

bool FAngelscriptTestEngineHelperWorldContextScopeRestoreTest::RunTest(const FString& Parameters)
{
	UObject* PreviousWorldContext = FAngelscriptEngine::GetAmbientWorldContext();
	UObject* DummyContext = NewObject<UAngelscriptNativeScriptTestObject>();
	if (!TestNotNull(TEXT("World context scope restore test should create a dummy context object"), DummyContext))
	{
		return false;
	}

	{
		AngelscriptTestSupport::FScopedTestWorldContextScope WorldContextScope(DummyContext);
		if (!TestTrue(TEXT("World context scope should install the dummy context"), FAngelscriptEngine::GetAmbientWorldContext() == DummyContext))
		{
			return false;
		}
	}

	return TestTrue(TEXT("World context scope should restore the previous context"), FAngelscriptEngine::GetAmbientWorldContext() == PreviousWorldContext);
}

bool FAngelscriptTestEngineHelperEngineScopeWorldContextRestoreTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* PreviousCurrentEngine = FAngelscriptTestEngineScopeAccess::GetCurrentEngine();
	TUniquePtr<FAngelscriptEngine> Engine = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	UObject* PreviousWorldContext = FAngelscriptEngine::GetAmbientWorldContext();
	UObject* DummyContext = NewObject<UAngelscriptNativeScriptTestObject>();
	if (!TestNotNull(TEXT("Engine-scope world context test should create an isolated engine"), Engine.Get())
		|| !TestNotNull(TEXT("Engine-scope world context test should create a dummy context object"), DummyContext))
	{
		return false;
	}

	{
		FAngelscriptEngineScope EngineScope(*Engine, DummyContext);
		if (!TestTrue(TEXT("Engine scope should install the isolated engine as current"), FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == Engine.Get()))
		{
			return false;
		}

		if (!TestTrue(TEXT("Engine scope should install the dummy world context"), FAngelscriptEngine::TryGetCurrentWorldContextObject() == DummyContext))
		{
			return false;
		}
	}

	if (!TestTrue(
		TEXT("Engine scope should restore the previous current engine"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine() == PreviousCurrentEngine))
	{
		return false;
	}

	return TestTrue(TEXT("Engine scope should restore the previous world context"), FAngelscriptEngine::GetAmbientWorldContext() == PreviousWorldContext);
}

bool FAngelscriptTestEngineHelperCompileSummaryPlainModuleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperCompileSummaryPlain"));
	};

	AngelscriptTestSupport::FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = AngelscriptTestSupport::CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		TEXT("HelperCompileSummaryPlain"),
		TEXT("HelperCompileSummaryPlain.as"),
		TEXT("int Entry() { return 42; }"),
		false,
		Summary);

	if (!TestTrue(TEXT("CompileModuleWithSummary should compile a plain module"), bCompiled))
	{
		return false;
	}

	TestFalse(TEXT("Plain module summary should report no preprocessor usage"), Summary.bUsedPreprocessor);
	TestEqual(TEXT("Plain module summary should report one module descriptor"), Summary.ModuleDescCount, 1);
	TestTrue(TEXT("Plain module summary should produce at least one compiled module"), Summary.CompiledModuleCount >= 1);
	TestEqual(TEXT("Plain module summary should report no diagnostics"), Summary.Diagnostics.Num(), 0);
	return Summary.ModuleDescCount == 1 && Summary.Diagnostics.Num() == 0;
}

bool FAngelscriptTestEngineHelperCompileSummaryDiagnosticCaptureTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("HelperCompileSummaryBroken"));
	};

	AngelscriptTestSupport::FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = AngelscriptTestSupport::CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		TEXT("HelperCompileSummaryBroken"),
		TEXT("HelperCompileSummaryBroken.as"),
		TEXT(R"(
UCLASS()
class UBrokenCompileSummaryObject : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
)"),
		true,
		Summary,
		true);

	TestFalse(TEXT("CompileModuleWithSummary should fail for broken annotated input"), bCompiled);
	TestTrue(TEXT("Broken annotated summary should report preprocessor usage"), Summary.bUsedPreprocessor);
	TestTrue(TEXT("Broken annotated summary should capture diagnostics"), Summary.Diagnostics.Num() > 0);
	TestEqual(TEXT("Broken annotated summary should report an error compile result"), Summary.CompileResult, ECompileResult::Error);
	return !bCompiled && Summary.Diagnostics.Num() > 0 && Summary.CompileResult == ECompileResult::Error;
}

bool FAngelscriptTestEngineHelperContextIsolationAcrossEnginesTest::RunTest(const FString& Parameters)
{
	TUniquePtr<FAngelscriptEngine> EngineA = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	TUniquePtr<FAngelscriptEngine> EngineB = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	if (!TestNotNull(TEXT("Context isolation test should create engine A"), EngineA.Get())
		|| !TestNotNull(TEXT("Context isolation test should create engine B"), EngineB.Get()))
	{
		return false;
	}

	const bool bCompiledA = AngelscriptTestSupport::CompileModuleFromMemory(
		EngineA.Get(),
		TEXT("HelperIsolationA"),
		TEXT("HelperIsolationA.as"),
		TEXT("int EntryA() { return 11; }"));
	const bool bCompiledB = AngelscriptTestSupport::CompileModuleFromMemory(
		EngineB.Get(),
		TEXT("HelperIsolationB"),
		TEXT("HelperIsolationB.as"),
		TEXT("int EntryB() { return 22; }"));
	if (!TestTrue(TEXT("Context isolation test should compile module A"), bCompiledA)
		|| !TestTrue(TEXT("Context isolation test should compile module B"), bCompiledB))
	{
		return false;
	}

	int32 ResultA = 0;
	int32 ResultB = 0;
	if (!TestTrue(TEXT("Engine A should execute its own module"), AngelscriptTestSupport::ExecuteIntFunction(EngineA.Get(), TEXT("HelperIsolationA"), TEXT("int EntryA()"), ResultA))
		|| !TestTrue(TEXT("Engine B should execute its own module"), AngelscriptTestSupport::ExecuteIntFunction(EngineB.Get(), TEXT("HelperIsolationB"), TEXT("int EntryB()"), ResultB)))
	{
		return false;
	}

	TestEqual(TEXT("Engine A should return its own result"), ResultA, 11);
	return TestEqual(TEXT("Engine B should return its own result without context leakage"), ResultB, 22);
}

bool FAngelscriptTestEngineHelperProductionSubsystemDoesNotHijackIsolatedEngineTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& SharedEngine = AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	TUniquePtr<FAngelscriptEngine> IsolatedEngine = AngelscriptTestSupport::CreateIsolatedCloneEngine();
	if (!TestNotNull(TEXT("Subsystem hijack test should create an isolated engine"), IsolatedEngine.Get()))
	{
		return false;
	}

	const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
		IsolatedEngine.Get(),
		TEXT("HelperIsolationHijack"),
		TEXT("HelperIsolationHijack.as"),
		TEXT("int Entry() { return 5; }"));
	if (!TestTrue(TEXT("Subsystem hijack test module should compile"), bCompiled))
	{
		return false;
	}

	TestTrue(TEXT("Isolated engine should keep its own module record"), IsolatedEngine->GetModuleByModuleName(TEXT("HelperIsolationHijack")).IsValid());
	return TestTrue(TEXT("Shared test engine should not receive isolated engine modules"), !SharedEngine.GetModuleByModuleName(TEXT("HelperIsolationHijack")).IsValid());
}

#endif
