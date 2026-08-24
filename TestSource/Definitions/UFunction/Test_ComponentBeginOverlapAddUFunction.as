// Theme: Definitions.UFunction. WorldStory: AddUFunction binds component begin-overlap.
// C++: AngelscriptActorInteractionTests.cpp::ComponentBeginOverlapAddUFunction
// Spawn owner/other, BeginPlay, Broadcast OnComponentBeginOverlap.
// Oracle: VerifyByPath BeginOverlapCount == 1; LastOtherActor is the other actor.
// Extra: default count 0 / LastOtherActor null; direct handler with null other.
// FixtureIsolated. Keep UPROPERTY names the C++ path uses. n"" FName.

UCLASS()
class UTestComponentBeginOverlapReceiver : USphereComponent
{
	UPROPERTY()
	int BeginOverlapCount = 0;

	UPROPERTY()
	AActor LastOtherActor = nullptr;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap");
	}

	UFUNCTION()
	void HandleComponentBeginOverlap(
		UPrimitiveComponent OverlappedComponent,
		AActor OtherActor,
		UPrimitiveComponent OtherComponent,
		int OtherBodyIndex,
		bool bFromSweep,
		const FHitResult&in Hit)
	{
		LastOtherActor = OtherActor;
		BeginOverlapCount += 1;
	}
}

UCLASS()
class ATestComponentBeginOverlapOwner : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestComponentBeginOverlapReceiver Trigger;
}

UCLASS()
class ATestComponentBeginOverlapOther : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Trigger;
}

int Observe_BeginOverlapCount_DefaultZero(UTestComponentBeginOverlapReceiver Receiver)
{
	return Receiver.BeginOverlapCount;
}

bool Observe_LastOtherActor_DefaultNull(UTestComponentBeginOverlapReceiver Receiver)
{
	return Receiver.LastOtherActor == nullptr;
}

bool Observe_HandleComponentBeginOverlap_Direct(
	UTestComponentBeginOverlapReceiver Receiver,
	AActor OtherActor)
{
	FHitResult Hit;
	Receiver.HandleComponentBeginOverlap(nullptr, OtherActor, nullptr, 0, false, Hit);
	return Receiver.BeginOverlapCount == 1 && Receiver.LastOtherActor is OtherActor;
}

bool Observe_HandleComponentBeginOverlap_NullOtherBoundary(UTestComponentBeginOverlapReceiver Receiver)
{
	FHitResult Hit;
	Receiver.HandleComponentBeginOverlap(nullptr, nullptr, nullptr, 0, false, Hit);
	return Receiver.BeginOverlapCount == 1 && Receiver.LastOtherActor == nullptr;
}
