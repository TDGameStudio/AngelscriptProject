#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
// Validates script classes subclassing UScriptWorldSubsystem and
// UScriptGameInstanceSubsystem. The preprocessor auto-generates a Get()
// static method whose Cast<SubClass>(Subsystem::GetXxxSubsystem(...))
// expression requires correct TObjectPtr ↔ UObject* type routing in the
// binding layer.
//
// These tests assert compile SUCCESS after the CPF_TObjectPtr fix in
// Bind_BlueprintType.cpp restored correct type-finder routing.
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

// ============================================================================
// World Subsystem compilation tests — validate script subclassing compiles
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioWorldSubsystemLifecycleTest,
	"Angelscript.TestModule.WorldSubsystem.Lifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioWorldSubsystemTickTest,
	"Angelscript.TestModule.WorldSubsystem.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioWorldSubsystemActorAccessTest,
	"Angelscript.TestModule.WorldSubsystem.ActorAccess",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioGameInstanceSubsystemLifecycleTest,
	"Angelscript.TestModule.GameInstanceSubsystem.Lifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioWorldSubsystemLifecycleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestWorldSubsystemLifecycle"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		ModuleName,
		TEXT("TestWorldSubsystemLifecycle.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldLifecycleTracker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}
}
)AS"),
		CompileResult);

	// CPF_TObjectPtr fix landed: subsystem subclass should now compile successfully.
	TestTrue(TEXT("Script world subsystem lifecycle subclass should compile after TObjectPtr fix"), bCompiled);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioWorldSubsystemTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestWorldSubsystemTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		ModuleName,
		TEXT("TestWorldSubsystemTick.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldTicker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
	}
}
)AS"),
		CompileResult);

	// CPF_TObjectPtr fix landed: subsystem subclass should now compile successfully.
	TestTrue(TEXT("Script world subsystem tick subclass should compile after TObjectPtr fix"), bCompiled);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioWorldSubsystemActorAccessTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestWorldSubsystemActorAccess"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		ModuleName,
		TEXT("TestWorldSubsystemActorAccess.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldActorWatcher : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		GetWorld().GetPersistentLevel().GetActors().Num();
	}
}

UCLASS()
class AScenarioWorldSubsystemActorAccessActor : AActor
{
}
)AS"),
		CompileResult);

	// CPF_TObjectPtr fix landed: subsystem subclass should now compile successfully.
	TestTrue(TEXT("Script world subsystem actor access subclass should compile after TObjectPtr fix"), bCompiled);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioGameInstanceSubsystemLifecycleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestGameInstanceSubsystemLifecycle"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		ModuleName,
		TEXT("TestGameInstanceSubsystemLifecycle.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioGameInstanceLifecycleTracker : UScriptGameInstanceSubsystem
{
	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Deinitialize()
	{
	}
}
)AS"),
		CompileResult);

	// CPF_TObjectPtr fix landed: subsystem subclass should now compile successfully.
	TestTrue(TEXT("Script game-instance subsystem lifecycle subclass should compile after TObjectPtr fix"), bCompiled);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
