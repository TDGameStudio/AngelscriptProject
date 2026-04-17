#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private
{
	constexpr float LifecycleScenarioDeltaTime = 0.016f;
}

using namespace AngelscriptTest_Actor_AngelscriptActorLifecycleTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorBeginPlayTest,
	"Angelscript.TestModule.Actor.BeginPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorTickTest,
	"Angelscript.TestModule.Actor.Tick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorReceiveEndPlayTest,
	"Angelscript.TestModule.Actor.ReceiveEndPlay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorReceiveDestroyedTest,
	"Angelscript.TestModule.Actor.ReceiveDestroyed",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorResetTest,
	"Angelscript.TestModule.Actor.Reset",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioActorBeginPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorBeginPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorBeginPlay.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorBeginPlay : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}
}
)AS"),
		TEXT("AScenarioActorBeginPlay"));
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

	int32 BeginPlayCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayCalled"), BeginPlayCalled))
	{
		return false;
	}

	TestEqual(TEXT("BeginPlay should run when the script actor is spawned into the test world"), BeginPlayCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorTickTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorTick"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorTick.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorTick : AActor
{
	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}
}
)AS"),
		TEXT("AScenarioActorTick"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = Cast<AActor>(SpawnScriptActor(*this, Spawner, ScriptClass));
	if (!TestNotNull(TEXT("Scenario tick actor should spawn as an AActor"), Actor))
	{
		return false;
	}

	Actor->PrimaryActorTick.bCanEverTick = true;
	Actor->SetActorTickEnabled(true);
	Actor->RegisterAllActorTickFunctions(true, false);
	BeginPlayActor(Engine, *Actor);
	TickWorld(Engine, Spawner.GetWorld(), LifecycleScenarioDeltaTime, 5);

	int32 TickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("TickCount"), TickCount))
	{
		return false;
	}

	TestTrue(TEXT("Tick should execute at least once per manual world tick"), TickCount >= 5);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorReceiveEndPlayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorReceiveEndPlay"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorReceiveEndPlay.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorReceiveEndPlay : AActor
{
	UPROPERTY()
	int EndPlayCalled = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCalled = 1;
	}
}
)AS"),
		TEXT("AScenarioActorReceiveEndPlay"));
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
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	int32 EndPlayCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("EndPlayCalled"), EndPlayCalled))
	{
		return false;
	}

	TestEqual(TEXT("ReceiveEndPlay should run when the script actor is destroyed"), EndPlayCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorReceiveDestroyedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorReceiveDestroyed"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorReceiveDestroyed.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorReceiveDestroyed : AActor
{
	UPROPERTY()
	int DestroyedCalled = 0;

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCalled = 1;
	}
}
)AS"),
		TEXT("AScenarioActorReceiveDestroyed"));
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
	Actor->Destroy();
	TickWorld(Engine, Spawner.GetWorld(), 0.0f, 1);

	int32 DestroyedCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("DestroyedCalled"), DestroyedCalled))
	{
		return false;
	}

	TestEqual(TEXT("ReceiveDestroyed should run when the script actor is destroyed"), DestroyedCalled, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorResetTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorReset"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorReset.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorReset : AActor
{
	UPROPERTY()
	int ResetValue = 3;

	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
	}
}
)AS"),
		TEXT("AScenarioActorReset"));
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
	FIntProperty* ResetValueProperty = FindFProperty<FIntProperty>(Actor->GetClass(), TEXT("ResetValue"));
	if (!TestNotNull(TEXT("Reset scenario property should exist"), ResetValueProperty))
	{
		return false;
	}
	ResetValueProperty->SetPropertyValue_InContainer(Actor, 99);
	Actor->Reset();

	int32 ResetValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("ResetValue"), ResetValue))
	{
		return false;
	}

	TestEqual(TEXT("Reset should route through the script override and restore the expected value"), ResetValue, 7);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
