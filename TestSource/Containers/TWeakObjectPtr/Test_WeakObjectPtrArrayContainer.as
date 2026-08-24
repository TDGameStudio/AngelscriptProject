// Theme: Containers.TWeakObjectPtr. WorldStory: TArray<TWeakObjectPtr> store/null/invalidate.
// CSV NegativeDiagnostic is wrong; C++ compiles, WeakActors Num==3, and VerifyByPath
// ArrayStoredWeakRefs / ArrayNullElementWorked / ArrayInvalidatedDestroyedElement all true.
// Nested TArray<TWeakObjectPtr<AActor>> is accepted here (not a syntax nested-pointer fail).
// Extra: local construct leaves WeakActors empty and flags false; Add on one copy stays independent.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageWeakRefArrayContainerActor : AActor
{
	UPROPERTY()
	TArray<TWeakObjectPtr<AActor>> WeakActors;

	UPROPERTY()
	bool ArrayStoredWeakRefs = false;

	UPROPERTY()
	bool ArrayNullElementWorked = false;

	UPROPERTY()
	bool ArrayInvalidatedDestroyedElement = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor FirstActor = SpawnActor(AActor::StaticClass());
		AActor SecondActor = SpawnActor(AActor::StaticClass());

		TWeakObjectPtr<AActor> WeakFirst = FirstActor;
		TWeakObjectPtr<AActor> WeakSecond = SecondActor;
		TWeakObjectPtr<AActor> EmptyWeak;

		WeakActors.Add(WeakFirst);
		WeakActors.Add(WeakSecond);
		WeakActors.Add(EmptyWeak);

		ArrayStoredWeakRefs = WeakActors.Num() == 3 && WeakActors[0].Get() == FirstActor && WeakActors[1].Get() == SecondActor;
		ArrayNullElementWorked = WeakActors[2] == nullptr;

		SecondActor.DestroyActor();
		ArrayInvalidatedDestroyedElement = !WeakActors[1].IsValid() && WeakActors[1].Get() == nullptr;
	}
}

bool Observe_WeakArrayContainer_DefaultEmpty(ACoverageWeakRefArrayContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrArrayContainer setup: required Actor is null");
	}
	return Actor.WeakActors.Num() == 0
		&& Actor.ArrayStoredWeakRefs == false
		&& Actor.ArrayNullElementWorked == false
		&& Actor.ArrayInvalidatedDestroyedElement == false;
}

bool Observe_WeakArrayContainer_EmptyWeakBoundary()
{
	TWeakObjectPtr<AActor> EmptyWeak;
	return EmptyWeak == nullptr && EmptyWeak.Get() == nullptr && EmptyWeak.IsValid() == false;
}

bool Observe_WeakArrayContainer_CopyIndependence(ACoverageWeakRefArrayContainerActor First, ACoverageWeakRefArrayContainerActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrArrayContainer setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrArrayContainer setup: required Second is null");
	}
	TWeakObjectPtr<AActor> EmptyWeak;
	First.WeakActors.Add(EmptyWeak);
	return First.WeakActors.Num() == 1
		&& First.WeakActors[0] == nullptr
		&& Second.WeakActors.Num() == 0
		&& Second.ArrayStoredWeakRefs == false;
}
