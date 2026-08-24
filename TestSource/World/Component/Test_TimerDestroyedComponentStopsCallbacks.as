// Theme: World.Component. WorldStory: destroy a component that owns a timer.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDestroyedComponentStopsCallbacks
// sha256=08b396d21470e9b1eb914ca7789ece21623e37b0a9262b2f65b227c988d32ed3; lines 2563-2624.
// Oracle bComponentTimerActiveBeforeDestroy true; after DestroyTimerComponent
// bComponentDestroyed true, ObservedCallbackCount 0.
// Extra: local construct flags false, ObservedCallbackCount -1 (declared),
// DestroyableComponent null. FixtureIsolated.

UCLASS()
class UCoverageTimerDestroyableComponent : UActorComponent
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyedComponentHandle;

	UFUNCTION()
	void CallbackAfterDestroy()
	{
		CallbackCount++;
	}

	UFUNCTION()
	void ConfigureTimer()
	{
		DestroyedComponentHandle = System::SetTimer(this, n"CallbackAfterDestroy", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyedComponentHandle);
	}
}

UCLASS()
class ACoverageTimerDestroyedComponentOwner : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTimerDestroyableComponent DestroyableComponent;

	UPROPERTY()
	bool bComponentTimerActiveBeforeDestroy = false;

	UPROPERTY()
	bool bComponentDestroyed = false;

	UPROPERTY()
	int ObservedCallbackCount = -1;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyableComponent.ConfigureTimer();
		bComponentTimerActiveBeforeDestroy = DestroyableComponent.bTimerActiveBeforeDestroy;
	}

	UFUNCTION()
	void DestroyTimerComponent()
	{
		DestroyableComponent.DestroyComponent();
		bComponentDestroyed = DestroyableComponent.IsBeingDestroyed();
	}

	UFUNCTION()
	void SnapshotDestroyedComponent()
	{
		ObservedCallbackCount = DestroyableComponent.CallbackCount;
	}
}

bool Observe_TimerDestroyedComponent_DefaultEmpty(ACoverageTimerDestroyedComponentOwner Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerDestroyedComponentStopsCallbacks setup: required Actor is null");
	}
	return !Actor.bComponentTimerActiveBeforeDestroy
		&& !Actor.bComponentDestroyed
		&& Actor.ObservedCallbackCount == -1
		&& Actor.DestroyableComponent == nullptr;
}

bool Observe_TimerDestroyedComponent_CopyIndependence(ACoverageTimerDestroyedComponentOwner First, ACoverageTimerDestroyedComponentOwner Second)
{
	if (First is null)
	{
		throw("Test_TimerDestroyedComponentStopsCallbacks setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TimerDestroyedComponentStopsCallbacks setup: required Second is null");
	}
	First.bComponentDestroyed = true;
	First.ObservedCallbackCount = 0;
	return First.bComponentDestroyed
		&& First.ObservedCallbackCount == 0
		&& !Second.bComponentDestroyed
		&& Second.ObservedCallbackCount == -1;
}
