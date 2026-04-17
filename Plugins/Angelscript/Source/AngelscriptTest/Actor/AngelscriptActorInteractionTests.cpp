#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Kismet/GameplayStatics.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Actor_AngelscriptActorInteractionTests_Private
{
	constexpr float InteractionScenarioDeltaTime = 0.016f;
}

using namespace AngelscriptTest_Actor_AngelscriptActorInteractionTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorPointDamageTest,
	"Angelscript.TestModule.Actor.PointDamage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorRadialDamageTest,
	"Angelscript.TestModule.Actor.RadialDamage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorMultiSpawnTest,
	"Angelscript.TestModule.Actor.MultiSpawn",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioActorCrossCallTest,
	"Angelscript.TestModule.Actor.CrossCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioActorPointDamageTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorPointDamage"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorPointDamage.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorPointDamage : AActor
{
	UFUNCTION(BlueprintOverride)
	void PointDamage(float Damage, TObjectPtr<UDamageType> DamageType, FVector HitLocation,
		FVector HitNormal, TObjectPtr<UPrimitiveComponent> HitComponent, FName BoneName,
		FVector ShotFromDirection, TObjectPtr<AController> InstigatedBy,
		TObjectPtr<AActor> DamageCauser, FHitResult HitInfo)
	{
		SetActorTickInterval(Damage);
	}
}
)AS"),
		TEXT("AScenarioActorPointDamage"));
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

	BeginPlayActor(*Actor);
	UGameplayStatics::ApplyPointDamage(Actor, 42.0f, FVector::ForwardVector, FHitResult(), nullptr, nullptr, nullptr);

	TestTrue(TEXT("Scenario point damage should route the applied damage into the script override"), FMath::IsNearlyEqual(Actor->GetActorTickInterval(), 42.0f));
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorRadialDamageTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorRadialDamage"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorRadialDamage.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioActorRadialDamageSphere : USphereComponent
{
}

UCLASS()
class AScenarioActorRadialDamage : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UScenarioActorRadialDamageSphere DamageSphere;

	default DamageSphere.SetSphereRadius(64.0f);

	UFUNCTION(BlueprintOverride)
	void RadialDamage(float DamageReceived, TObjectPtr<UDamageType> DamageType, FVector Origin,
		FHitResult HitInfo, TObjectPtr<AController> InstigatedBy,
		TObjectPtr<AActor> DamageCauser)
	{
		SetActorScale3D(FVector(DamageReceived, DamageReceived, DamageReceived));
	}
}
)AS"),
		TEXT("AScenarioActorRadialDamage"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = Cast<AActor>(SpawnScriptActor(*this, Spawner, ScriptClass));
	if (!TestNotNull(TEXT("Scenario radial-damage actor should spawn as an AActor"), Actor))
	{
		return false;
	}

	BeginPlayActor(*Actor);
	TArray<AActor*> IgnoredActors;
	const bool bAppliedDamage = UGameplayStatics::ApplyRadialDamage(&Spawner.GetWorld(), 24.0f, Actor->GetActorLocation(), 128.0f, nullptr, IgnoredActors, nullptr, nullptr, true);
	if (!TestTrue(TEXT("Scenario radial-damage setup should apply damage through the engine overlap path"), bAppliedDamage))
	{
		return false;
	}

	TestTrue(TEXT("Scenario radial damage should route the applied damage into the script override"), Actor->GetActorScale3D().Equals(FVector(24.0f, 24.0f, 24.0f), KINDA_SMALL_NUMBER));
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorMultiSpawnTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorMultiSpawn"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorMultiSpawn.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorMultiSpawn : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}
}
)AS"),
		TEXT("AScenarioActorMultiSpawn"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	TArray<AActor*> SpawnedActors;
	for (int32 Index = 0; Index < 3; ++Index)
	{
		AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
		if (Actor == nullptr)
		{
			return false;
		}
		BeginPlayActor(*Actor);
		SpawnedActors.Add(Actor);
	}

	int32 TotalBeginPlayCount = 0;
	for (AActor* SpawnedActor : SpawnedActors)
	{
		int32 BeginPlayCount = 0;
		if (!ReadPropertyValue<FIntProperty>(*this, SpawnedActor, TEXT("BeginPlayCount"), BeginPlayCount))
		{
			return false;
		}
		TotalBeginPlayCount += BeginPlayCount;
	}

	TestTrue(TEXT("Scenario multi-spawn should execute BeginPlay on every spawned instance at least once"), TotalBeginPlayCount >= 3);
	TestTrue(TEXT("Scenario multi-spawn should create distinct actor instances"), SpawnedActors[0] != SpawnedActors[1] && SpawnedActors[1] != SpawnedActors[2] && SpawnedActors[0] != SpawnedActors[2]);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioActorCrossCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioActorCrossCall"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ActorAClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioActorCrossCall.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioActorCrossCallB : AActor
{
	UPROPERTY()
	int CallCount = 0;

	UFUNCTION()
	void ReceiveCallFromA()
	{
		CallCount += 1;
	}
}

UCLASS()
class AScenarioActorCrossCallA : AActor
{
	UPROPERTY()
	AScenarioActorCrossCallB TargetActor;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TargetActor != null)
		{
			TargetActor.ReceiveCallFromA();
		}
	}
}
)AS"),
		TEXT("AScenarioActorCrossCallA"));
	if (ActorAClass == nullptr)
	{
		return false;
	}

	UClass* ActorBClass = FindGeneratedClass(&Engine, TEXT("AScenarioActorCrossCallB"));
	if (!TestNotNull(TEXT("Scenario cross-call target actor class should be generated"), ActorBClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* ActorA = Cast<AActor>(SpawnScriptActor(*this, Spawner, ActorAClass));
	AActor* ActorB = SpawnScriptActor(*this, Spawner, ActorBClass);
	if (!TestNotNull(TEXT("Scenario cross-call actor A should spawn"), ActorA) || !TestNotNull(TEXT("Scenario cross-call actor B should spawn"), ActorB))
	{
		return false;
	}

	FObjectPropertyBase* TargetActorProperty = FindFProperty<FObjectPropertyBase>(ActorA->GetClass(), TEXT("TargetActor"));
	if (!TestNotNull(TEXT("Scenario cross-call source actor should expose the target reference property"), TargetActorProperty))
	{
		return false;
	}
	TargetActorProperty->SetObjectPropertyValue_InContainer(ActorA, ActorB);

	ActorA->PrimaryActorTick.bCanEverTick = true;
	ActorA->SetActorTickEnabled(true);
	ActorA->RegisterAllActorTickFunctions(true, false);
	BeginPlayActor(*ActorA);
	BeginPlayActor(*ActorB);
	TickWorld(Spawner.GetWorld(), InteractionScenarioDeltaTime, 1);

	int32 CallCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ActorB, TEXT("CallCount"), CallCount))
	{
		return false;
	}

	TestTrue(TEXT("Scenario actor cross-call should let one spawned script actor invoke another's UFUNCTION"), CallCount >= 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
