// Theme: Containers.TWeakObjectPtr. WorldStory: TArray<TWeakObjectPtr> plus reassignment.
// CSV NegativeDiagnostic is wrong; C++ compiles, WeakActors Num==3, and VerifyByPath
// ArrayStoredWeakReferences / ArrayNullElementComparedToNull / DestroyedElementInvalidated /
// ReassignedToNewObject all true. Nested TArray<TWeakObjectPtr<AActor>> is accepted here.
// Extra: local construct leaves WeakActors empty and flags false; Add on one copy stays independent.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageHandlesWeakArrayReassignActor : AActor
{
	UPROPERTY()
	TArray<TWeakObjectPtr<AActor>> WeakActors;

	UPROPERTY()
	TWeakObjectPtr<AActor> ReassignedWeakActor;

	UPROPERTY()
	bool ArrayStoredWeakReferences = false;

	UPROPERTY()
	bool ArrayNullElementComparedToNull = false;

	UPROPERTY()
	bool DestroyedElementInvalidated = false;

	UPROPERTY()
	bool ReassignedToNewObject = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor FirstActor = SpawnActor(AActor::StaticClass());
		AActor SecondActor = SpawnActor(AActor::StaticClass());
		AActor ReplacementActor = SpawnActor(AActor::StaticClass());

		TWeakObjectPtr<AActor> WeakFirst = FirstActor;
		TWeakObjectPtr<AActor> WeakSecond = SecondActor;
		TWeakObjectPtr<AActor> EmptyWeak;

		WeakActors.Add(WeakFirst);
		WeakActors.Add(WeakSecond);
		WeakActors.Add(EmptyWeak);

		ArrayStoredWeakReferences = WeakActors.Num() == 3 &&
			WeakActors[0].Get() == FirstActor &&
			WeakActors[1].Get() == SecondActor;
		ArrayNullElementComparedToNull = WeakActors[2] == nullptr;

		SecondActor.DestroyActor();
		DestroyedElementInvalidated = WeakActors[1] == nullptr &&
			WeakActors[1].Get() == nullptr &&
			!WeakActors[1].IsValid();

		ReassignedWeakActor = FirstActor;
		ReassignedWeakActor = ReplacementActor;
		ReassignedToNewObject = ReassignedWeakActor.IsValid() &&
			ReassignedWeakActor.Get() == ReplacementActor &&
			ReassignedWeakActor.Get() != FirstActor;
	}
}

bool Observe_WeakArrayReassign_DefaultEmpty(ACoverageHandlesWeakArrayReassignActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrArrayContainerAndReassignment setup: required Actor is null");
	}
	return Actor.WeakActors.Num() == 0
		&& Actor.ReassignedWeakActor == nullptr
		&& Actor.ReassignedWeakActor.Get() == nullptr
		&& Actor.ArrayStoredWeakReferences == false
		&& Actor.ArrayNullElementComparedToNull == false
		&& Actor.DestroyedElementInvalidated == false
		&& Actor.ReassignedToNewObject == false;
}

bool Observe_WeakArrayReassign_EmptyWeakBoundary()
{
	TWeakObjectPtr<AActor> EmptyWeak;
	return EmptyWeak == nullptr && EmptyWeak.Get() == nullptr && EmptyWeak.IsValid() == false;
}

bool Observe_WeakArrayReassign_CopyIndependence(ACoverageHandlesWeakArrayReassignActor First, ACoverageHandlesWeakArrayReassignActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrArrayContainerAndReassignment setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrArrayContainerAndReassignment setup: required Second is null");
	}
	TWeakObjectPtr<AActor> EmptyWeak;
	First.WeakActors.Add(EmptyWeak);
	return First.WeakActors.Num() == 1
		&& First.WeakActors[0] == nullptr
		&& Second.WeakActors.Num() == 0
		&& Second.ReassignedWeakActor == nullptr;
}
