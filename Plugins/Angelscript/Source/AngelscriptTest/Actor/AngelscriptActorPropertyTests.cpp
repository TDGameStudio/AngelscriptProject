#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptReflectiveAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorUPropertyTest,
	"Angelscript.TestModule.Actor.UProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorUFunctionTest,
	"Angelscript.TestModule.Actor.UFunction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorDefaultValuesTest,
	"Angelscript.TestModule.Actor.DefaultValues",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorUPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
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
class ATestActorUProperty : AActor
{
	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FString DisplayName = "TestActor";
}
)AS"),
		TEXT("ATestActorUProperty"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("UProperty actor should spawn successfully"), Actor))
	{
		break;
	}
	BeginPlayActor(Engine, *Actor);

	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("Health"), 100,
		TEXT("Script-defined int UPROPERTY should keep its default value after spawn"));
	VerifyByPath<FStrProperty, FString>(*this, Actor, TEXT("DisplayName"), FString(TEXT("TestActor")),
		TEXT("Script-defined FString UPROPERTY should keep its default value after spawn"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorUFunctionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
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
class ATestActorUFunction : AActor
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
		TEXT("ATestActorUFunction"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("UFunction actor should spawn successfully"), Actor))
	{
		break;
	}
	BeginPlayActor(Engine, *Actor);

	FFunctionInvoker Invoker(*this, Actor, FName(TEXT("GetHealth")));
	if (!Invoker.IsValid())
	{
		break;
	}
	const int32 Result = Invoker.CallAndReturn<int32>(/*Fallback=*/INDEX_NONE);
	TestEqual(TEXT("Script-defined UFUNCTION should return the scripted property value"), Result, 100);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorDefaultValuesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
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
class ATestActorDefaultValues : AActor
{
	default PrimaryActorTick.TickInterval = 0.5f;
}
)AS"),
		TEXT("ATestActorDefaultValues"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("DefaultValues actor should spawn successfully"), Actor))
	{
		break;
	}
	BeginPlayActor(Engine, *Actor);

	TestTrue(TEXT("Script default values should apply the configured tick interval"), FMath::IsNearlyEqual(Actor->PrimaryActorTick.TickInterval, 0.5f));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

#endif
