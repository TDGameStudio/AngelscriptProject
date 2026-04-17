#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Shared/AngelscriptNativeScriptTestObject.h"

#include "BaseClasses/ScriptGameInstanceSubsystem.h"
#include "BaseClasses/ScriptWorldSubsystem.h"
#include "Components/ActorTestSpawner.h"
#include "Engine/GameInstance.h"
#include "Engine/World.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "Subsystems/WorldSubsystem.h"
#include "TestGameInstance.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Subsystem_AngelscriptSubsystemScenarioTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	constexpr float SubsystemScenarioDeltaTime = 0.016f;

	void InitializeSubsystemScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}

	UAngelscriptNativeScriptTestObject* GetScenarioNativeRecorder(FAutomationTestBase& Test)
	{
		UAngelscriptNativeScriptTestObject* NativeRecorder = GetMutableDefault<UAngelscriptNativeScriptTestObject>();
		Test.TestNotNull(TEXT("Scenario native recorder should exist"), NativeRecorder);
		if (NativeRecorder != nullptr)
		{
			NativeRecorder->bNativeFlag = false;
			NativeRecorder->NameCounts.Reset();
		}
		return NativeRecorder;
	}
}

using namespace AngelscriptTest_Subsystem_AngelscriptSubsystemScenarioTests_Private;

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
	static const FName ModuleName(TEXT("ScenarioWorldSubsystemLifecycle"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		TEXT("ScenarioWorldSubsystemLifecycle.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldLifecycleTracker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void BP_Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BP_Deinitialize()
	{
	}
}
)AS"),
		CompileResult);
	UE_SET_LOG_VERBOSITY(Angelscript, Log);

	if (!TestFalse(TEXT("Scenario world subsystem script generation remains unsupported on this branch"), bCompiled))
	{
		return false;
	}

	TestEqual(TEXT("Scenario world subsystem lifecycle should currently fail compilation on this branch"), CompileResult, ECompileResult::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioWorldSubsystemTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioWorldSubsystemTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		TEXT("ScenarioWorldSubsystemTick.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldTicker : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void BP_Tick(float DeltaTime)
	{
	}
}
)AS"),
		CompileResult);
	UE_SET_LOG_VERBOSITY(Angelscript, Log);

	if (!TestFalse(TEXT("Scenario world subsystem ticking remains unsupported on this branch"), bCompiled))
	{
		return false;
	}

	TestEqual(TEXT("Scenario world subsystem tick should currently fail compilation on this branch"), CompileResult, ECompileResult::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioWorldSubsystemActorAccessTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioWorldSubsystemActorAccess"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		TEXT("ScenarioWorldSubsystemActorAccess.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioWorldActorWatcher : UScriptWorldSubsystem
{
	UFUNCTION(BlueprintOverride)
	void BP_Tick(float DeltaTime)
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
	UE_SET_LOG_VERBOSITY(Angelscript, Log);

	if (!TestFalse(TEXT("Scenario world subsystem actor access remains unsupported on this branch"), bCompiled))
	{
		return false;
	}

	TestEqual(TEXT("Scenario world subsystem actor access should currently fail compilation on this branch"), CompileResult, ECompileResult::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioGameInstanceSubsystemLifecycleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioGameInstanceSubsystemLifecycle"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::FullyHandled;
	UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		TEXT("ScenarioGameInstanceSubsystemLifecycle.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioGameInstanceLifecycleTracker : UScriptGameInstanceSubsystem
{
	UFUNCTION(BlueprintOverride)
	void BP_Initialize()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BP_Deinitialize()
	{
	}
}
)AS"),
		CompileResult);
	UE_SET_LOG_VERBOSITY(Angelscript, Log);

	if (!TestFalse(TEXT("Scenario game-instance subsystem script generation remains unsupported on this branch"), bCompiled))
	{
		return false;
	}

	TestEqual(TEXT("Scenario game-instance subsystem lifecycle should currently fail compilation on this branch"), CompileResult, ECompileResult::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
