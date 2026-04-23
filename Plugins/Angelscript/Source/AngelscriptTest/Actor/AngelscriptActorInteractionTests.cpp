#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptReflectiveAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Kismet/GameplayStatics.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;

namespace AngelscriptTest_Actor_AngelscriptActorInteractionTests_Private
{
	constexpr float InteractionScenarioDeltaTime = 0.016f;

	void EnableActorTick(AActor& Actor)
	{
		Actor.PrimaryActorTick.bCanEverTick = true;
		Actor.SetActorTickEnabled(true);
		Actor.RegisterAllActorTickFunctions(true, false);
	}
}

using namespace AngelscriptTest_Actor_AngelscriptActorInteractionTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorPointDamageTest,
	"Angelscript.TestModule.Actor.PointDamage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorRadialDamageTest,
	"Angelscript.TestModule.Actor.RadialDamage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorMultiSpawnTest,
	"Angelscript.TestModule.Actor.MultiSpawn",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorCrossCallTest,
	"Angelscript.TestModule.Actor.CrossCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorPointDamageTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorPointDamage"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorPointDamage.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorPointDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	UPROPERTY()
	FName LastNameValue;

	UFUNCTION(BlueprintOverride)
	void PointDamage(float Damage, const UDamageType DamageType, FVector HitLocation,
		FVector HitNormal, UPrimitiveComponent HitComponent, FName BoneName,
		FVector ShotFromDirection, AController InstigatedBy,
		AActor DamageCauser, FHitResult HitInfo)
	{
		LastFloatValue = Damage;
		LastVectorValue = HitLocation;
		LastNameValue = BoneName;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorPointDamage"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("PointDamage actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(*Actor);
	const FVector ExpectedHitLocation(100.f, 200.f, 300.f);
	const FName ExpectedBoneName(TEXT("spine_01"));
	FHitResult HitResult;
	HitResult.Location = ExpectedHitLocation;
	HitResult.ImpactPoint = ExpectedHitLocation;
	HitResult.BoneName = ExpectedBoneName;
	UGameplayStatics::ApplyPointDamage(Actor, 42.0f, FVector::ForwardVector, HitResult, nullptr, nullptr, nullptr);

	VerifyByPath<FDoubleProperty, double>(*this, Actor, TEXT("LastFloatValue"), 42.0,
		TEXT("PointDamage should route the applied damage value into LastFloatValue"));
	{
		FVector ActualHitLocation = FVector::ZeroVector;
		if (!GetStructByPath<FVector>(*this, Actor, TEXT("LastVectorValue"), ActualHitLocation))
		{
			break;
		}
		TestTrue(TEXT("PointDamage should route the hit location into LastVectorValue"),
			ActualHitLocation.Equals(ExpectedHitLocation));
	}
	VerifyByPath<FNameProperty, FName>(*this, Actor, TEXT("LastNameValue"), ExpectedBoneName,
		TEXT("PointDamage should route the bone name into LastNameValue"));
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("PointDamage should fire exactly once"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorRadialDamageTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorRadialDamage"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorRadialDamage.as"),
		TEXT(R"AS(
UCLASS()
class UTestActorRadialDamageSphere : USphereComponent
{
}

UCLASS()
class ATestActorRadialDamage : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorRadialDamageSphere DamageSphere;

	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	FVector LastVectorValue = FVector::ZeroVector;

	default DamageSphere.SetSphereRadius(64.0f);

	UFUNCTION(BlueprintOverride)
	void RadialDamage(float DamageReceived, const UDamageType DamageType, FVector Origin,
		FHitResult HitInfo, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = DamageReceived;
		LastVectorValue = Origin;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorRadialDamage"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("RadialDamage actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(*Actor);
	TArray<AActor*> IgnoredActors;
	const bool bAppliedDamage = UGameplayStatics::ApplyRadialDamage(
		&Spawner.GetWorld(), 24.0f, Actor->GetActorLocation(), 128.0f,
		nullptr, IgnoredActors, nullptr, nullptr, true);
	if (!TestTrue(TEXT("RadialDamage setup should apply damage through the engine overlap path"), bAppliedDamage))
	{
		break;
	}

	VerifyByPath<FDoubleProperty, double>(*this, Actor, TEXT("LastFloatValue"), 24.0,
		TEXT("RadialDamage should route the applied damage value into LastFloatValue"));
	{
		FVector ActualOrigin = FVector::ZeroVector;
		if (!GetStructByPath<FVector>(*this, Actor, TEXT("LastVectorValue"), ActualOrigin))
		{
			break;
		}
		TestTrue(TEXT("RadialDamage should route the explosion origin into LastVectorValue"),
			ActualOrigin.Equals(Actor->GetActorLocation()));
	}
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("RadialDamage should fire exactly once"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorMultiSpawnTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorMultiSpawn"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorMultiSpawn.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorMultiSpawn : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorMultiSpawn"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	TArray<AActor*> SpawnedActors;
	for (int32 Index = 0; Index < 3; ++Index)
	{
		AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
		if (!TestNotNull(TEXT("MultiSpawn actor should spawn successfully"), Actor))
		{
			break;
		}
		BeginPlayActor(*Actor);
		SpawnedActors.Add(Actor);
	}

	int32 TotalBeginPlayCount = 0;
	for (AActor* SpawnedActor : SpawnedActors)
	{
		int32 EventCallCount = 0;
		if (!GetByPath<FIntProperty, int32>(*this, SpawnedActor, TEXT("EventCallCount"), EventCallCount))
		{
			break;
		}
		TotalBeginPlayCount += EventCallCount;
	}

	TestTrue(TEXT("MultiSpawn should execute BeginPlay on every spawned instance at least once"), TotalBeginPlayCount >= 3);
	TestTrue(TEXT("MultiSpawn should create distinct actor instances"),
		SpawnedActors[0] != SpawnedActors[1] &&
		SpawnedActors[1] != SpawnedActors[2] &&
		SpawnedActors[0] != SpawnedActors[2]);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

bool FAngelscriptTestActorCrossCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorCrossCall"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ActorAClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorCrossCall.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorCrossCallB : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION()
	void ReceiveCallFromA()
	{
		EventCallCount += 1;
	}
}

UCLASS()
class ATestActorCrossCallA : AActor
{
	UPROPERTY()
	ATestActorCrossCallB TargetActor;

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
		TEXT("ATestActorCrossCallA"));
	if (!TestNotNull(TEXT("ActorAClass should be valid"), ActorAClass))
	{
		break;
	}

	UClass* ActorBClass = FindGeneratedClass(&Engine, TEXT("ATestActorCrossCallB"));
	if (!TestNotNull(TEXT("CrossCall target actor class should be generated"), ActorBClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* ActorA = SpawnScriptActor(*this, Spawner, ActorAClass);
	AActor* ActorB = SpawnScriptActor(*this, Spawner, ActorBClass);
	if (!TestNotNull(TEXT("CrossCall actor A should spawn"), ActorA) ||
		!TestNotNull(TEXT("CrossCall actor B should spawn"), ActorB))
	{
		break;
	}

	if (!SetObjectByPath(*this, ActorA, TEXT("TargetActor"), ActorB))
	{
		break;
	}

	EnableActorTick(*ActorA);
	BeginPlayActor(*ActorA);
	BeginPlayActor(*ActorB);
	TickWorld(Spawner.GetWorld(), InteractionScenarioDeltaTime, 1);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, ActorB, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestTrue(TEXT("CrossCall should let one spawned script actor invoke another's UFUNCTION at least once"), EventCallCount >= 1);
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

// ---------------------------------------------------------------------------
// AnyDamage: Verifies that the generic AnyDamage BlueprintOverride fires for
// any damage type applied through the engine damage system.
// ---------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorAnyDamageTest,
	"Angelscript.TestModule.Actor.AnyDamage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorAnyDamageTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorAnyDamage"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorAnyDamage.as"),
		TEXT(R"AS(
UCLASS()
class ATestActorAnyDamage : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	UFUNCTION(BlueprintOverride)
	void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy, AActor DamageCauser)
	{
		LastFloatValue = Damage;
		LastActorRef = DamageCauser;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestActorAnyDamage"));
	if (!TestNotNull(TEXT("ScriptClass should be valid"), ScriptClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("AnyDamage actor should spawn successfully"), Actor))
	{
		break;
	}

	BeginPlayActor(*Actor);
	UGameplayStatics::ApplyDamage(Actor, 55.0f, nullptr, Actor, nullptr);

	VerifyByPath<FDoubleProperty, double>(*this, Actor, TEXT("LastFloatValue"), 55.0,
		TEXT("AnyDamage should route the applied damage value into LastFloatValue"));
	{
		UObject* DamageCauser = nullptr;
		if (!GetObjectByPath(*this, Actor, TEXT("LastActorRef"), DamageCauser))
		{
			break;
		}
		TestEqual(TEXT("AnyDamage should pass the damage causer into LastActorRef"),
			DamageCauser, static_cast<UObject*>(Actor));
	}
	VerifyByPath<FIntProperty, int32>(*this, Actor, TEXT("EventCallCount"), 1,
		TEXT("AnyDamage should fire exactly once"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

// ---------------------------------------------------------------------------
// ActorBeginOverlap: Verifies that AActor::NotifyActorBeginOverlap routes into
// the script ActorBeginOverlap BlueprintOverride.
// ---------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorBeginOverlapTest,
	"Angelscript.TestModule.Actor.ActorBeginOverlap",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorBeginOverlapTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorBeginOverlap"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ReceiverClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorBeginOverlap.as"),
		TEXT(R"AS(
UCLASS()
class ATestOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}
}

UCLASS()
class ATestOverlapTrigger : AActor
{
}
)AS"),
		TEXT("ATestOverlapReceiver"));
	if (!TestNotNull(TEXT("ReceiverClass should be valid"), ReceiverClass))
	{
		break;
	}

	UClass* TriggerClass = FindGeneratedClass(&Engine, TEXT("ATestOverlapTrigger"));
	if (!TestNotNull(TEXT("Overlap trigger actor class should be generated"), TriggerClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor* Receiver = SpawnScriptActor(*this, Spawner, ReceiverClass, FActorSpawnParameters(), FVector::ZeroVector);
	if (!TestNotNull(TEXT("Overlap receiver should spawn"), Receiver))
	{
		break;
	}

	AActor* Trigger = SpawnScriptActor(*this, Spawner, TriggerClass);
	if (!TestNotNull(TEXT("Overlap trigger should spawn"), Trigger))
	{
		break;
	}

	BeginPlayActor(*Receiver);
	BeginPlayActor(*Trigger);
	VerifyByPath<FIntProperty, int32>(*this, Receiver, TEXT("EventCallCount"), 0,
		TEXT("ActorBeginOverlap should not fire before NotifyActorBeginOverlap"));

	Receiver->NotifyActorBeginOverlap(Trigger);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Receiver, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestEqual(TEXT("ActorBeginOverlap should fire once when AActor notifies begin overlap"), EventCallCount, 1);
	{
		UObject* OtherActor = nullptr;
		if (!GetObjectByPath(*this, Receiver, TEXT("LastActorRef"), OtherActor))
		{
			break;
		}
		TestEqual(TEXT("ActorBeginOverlap should pass the overlapping actor as OtherActor"),
			OtherActor, static_cast<UObject*>(Trigger));
	}
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

// ---------------------------------------------------------------------------
// DelegateBroadcast: Verifies that one script actor can bind to another
// script actor's multicast delegate and receive broadcast notifications.
// ---------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorDelegateBroadcastTest,
	"Angelscript.TestModule.Actor.DelegateBroadcast",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorDelegateBroadcastTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorDelegateBroadcast"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* BroadcasterClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorDelegateBroadcast.as"),
		TEXT(R"AS(
event void FOnTestEvent(float Value);

UCLASS()
class ATestDelegateBroadcaster : AActor
{
	UPROPERTY()
	FOnTestEvent OnTestEvent;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		OnTestEvent.Broadcast(99.0f);
	}
}

UCLASS()
class ATestDelegateListener : AActor
{
	UPROPERTY()
	ATestDelegateBroadcaster Broadcaster;

	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Broadcaster != null)
		{
			Broadcaster.OnTestEvent.AddUFunction(this, n"HandleTestEvent");
		}
	}

	UFUNCTION()
	void HandleTestEvent(float Value)
	{
		LastFloatValue = Value;
		EventCallCount += 1;
	}
}
)AS"),
		TEXT("ATestDelegateBroadcaster"));
	if (!TestNotNull(TEXT("BroadcasterClass should be valid"), BroadcasterClass))
	{
		break;
	}

	UClass* ListenerClass = FindGeneratedClass(&Engine, TEXT("ATestDelegateListener"));
	if (!TestNotNull(TEXT("Delegate listener actor class should be generated"), ListenerClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Broadcaster = SpawnScriptActor(*this, Spawner, BroadcasterClass);
	AActor* Listener = SpawnScriptActor(*this, Spawner, ListenerClass);
	if (!TestNotNull(TEXT("Broadcaster should spawn"), Broadcaster) ||
		!TestNotNull(TEXT("Listener should spawn"), Listener))
	{
		break;
	}

	if (!SetObjectByPath(*this, Listener, TEXT("Broadcaster"), Broadcaster))
	{
		break;
	}

	EnableActorTick(*Broadcaster);

	BeginPlayActor(*Broadcaster);
	BeginPlayActor(*Listener);
	TickWorld(Spawner.GetWorld(), InteractionScenarioDeltaTime, 1);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Listener, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestTrue(TEXT("DelegateBroadcast should let the listener receive at least one broadcast"), EventCallCount >= 1);
	VerifyByPath<FDoubleProperty, double>(*this, Listener, TEXT("LastFloatValue"), 99.0,
		TEXT("DelegateBroadcast should pass the correct value through the delegate"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

// ---------------------------------------------------------------------------
// InterfaceCall: Verifies that one script actor can call a UFUNCTION on
// another script actor through a UInterface, validating polymorphic dispatch.
// ---------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestActorInterfaceCallTest,
	"Angelscript.TestModule.Actor.InterfaceCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestActorInterfaceCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	do
	{
	static const FName ModuleName(TEXT("TestActorInterfaceCall"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* CallerClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("TestActorInterfaceCall.as"),
		TEXT(R"AS(
UINTERFACE()
interface UTestInteractable
{
	void Interact(int Value);
}

UCLASS()
class ATestInterfaceTarget : AActor, UTestInteractable
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int LastIntValue = 0;

	UFUNCTION()
	void Interact(int Value)
	{
		LastIntValue = Value;
		EventCallCount += 1;
	}
}

UCLASS()
class ATestInterfaceCaller : AActor
{
	UPROPERTY()
	AActor TargetActor;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TargetActor != nullptr)
		{
			UTestInteractable Interactable = Cast<UTestInteractable>(TargetActor);
			if (Interactable != nullptr)
			{
				Interactable.Interact(77);
			}
		}
	}
}
)AS"),
		TEXT("ATestInterfaceCaller"));
	if (!TestNotNull(TEXT("CallerClass should be valid"), CallerClass))
	{
		break;
	}

	UClass* TargetClass = FindGeneratedClass(&Engine, TEXT("ATestInterfaceTarget"));
	if (!TestNotNull(TEXT("Interface target actor class should be generated"), TargetClass))
	{
		break;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Caller = SpawnScriptActor(*this, Spawner, CallerClass);
	AActor* Target = SpawnScriptActor(*this, Spawner, TargetClass);
	if (!TestNotNull(TEXT("Interface caller should spawn"), Caller) ||
		!TestNotNull(TEXT("Interface target should spawn"), Target))
	{
		break;
	}

	if (!SetObjectByPath(*this, Caller, TEXT("TargetActor"), Target))
	{
		break;
	}

	EnableActorTick(*Caller);

	BeginPlayActor(*Caller);
	BeginPlayActor(*Target);
	TickWorld(Spawner.GetWorld(), InteractionScenarioDeltaTime, 1);

	int32 EventCallCount = 0;
	if (!GetByPath<FIntProperty, int32>(*this, Target, TEXT("EventCallCount"), EventCallCount))
	{
		break;
	}
	TestTrue(TEXT("InterfaceCall should let the caller invoke the target's interface method at least once"), EventCallCount >= 1);
	VerifyByPath<FIntProperty, int32>(*this, Target, TEXT("LastIntValue"), 77,
		TEXT("InterfaceCall should pass the correct value through the interface method"));
	}
	while (false);
	ASTEST_END_SHARE_CLEAN

	return !HasAnyErrors();
}

#endif
