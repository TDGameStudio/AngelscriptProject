#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorUPropertyTest,
	"Angelscript.TestModule.Actor.UProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorUFunctionTest,
	"Angelscript.TestModule.Actor.UFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorDefaultValuesTest,
	"Angelscript.TestModule.Actor.DefaultValues",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioActorUPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestActorUProperty"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorUProperty.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorUProperty : AActor
{
	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FString DisplayName = "TestActor";
}
)AS"),
		TEXT("AScenarioActorUProperty"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	int32 Health = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("Health"), Health))
	{
		return false;
	}

	FString DisplayName;
	if (!ReadPropertyValue<FStrProperty>(*this, Actor, TEXT("DisplayName"), DisplayName))
	{
		return false;
	}

	TestEqual(TEXT("Scenario actor reflected int UPROPERTY should keep its default value"), Health, 100);
	TestEqual(TEXT("Scenario actor reflected FString UPROPERTY should keep its default value"), DisplayName, FString(TEXT("TestActor")));
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorUFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestActorUFunction"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorUFunction.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorUFunction : AActor
{
	UPROPERTY()
	int Health = 100;

	UFUNCTION()
	int GetHealth()
	{
		return Health;
	}
}
)AS"),
		TEXT("AScenarioActorUFunction"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	UFunction* GetHealthFunction = FindGeneratedFunction(ScriptClass, TEXT("GetHealth"));
	if (!TestNotNull(TEXT("Scenario actor reflected UFUNCTION should exist"), GetHealthFunction))
	{
		return false;
	}

	int32 Result = 0;
	if (!TestTrue(TEXT("Scenario actor reflected UFUNCTION should execute on the game thread"), ExecuteGeneratedIntEventOnGameThread(&Engine, Actor, GetHealthFunction, Result)))
	{
		return false;
	}

	TestEqual(TEXT("Scenario actor reflected UFUNCTION should return the scripted property value"), Result, 100);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorDefaultValuesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestActorDefaultValues"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorDefaultValues.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorDefaultValues : AActor
{
	default PrimaryActorTick.TickInterval = 0.5f;
}
)AS"),
		TEXT("AScenarioActorDefaultValues"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}
	BeginPlayActor(Engine, *Actor);

	TestTrue(TEXT("Scenario actor default values should apply the configured tick interval"), FMath::IsNearlyEqual(Actor->PrimaryActorTick.TickInterval, 0.5f));
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
