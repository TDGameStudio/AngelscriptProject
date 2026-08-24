// Theme: Containers.TObjectPtr. WorldStory: UPROPERTY reachability vs weak invalidation.
// CSV NegativeDiagnostic is wrong; C++ compiles and VerifyByPath all four flags true.
// Extra: StrongObject/StrongObjects empty until BeginPlay; destroyed actor is the null boundary.
// FixtureIsolated.

UCLASS()
class ACoverageHandlesGCReachabilityActor : AActor
{
	UPROPERTY()
	UObject StrongObject;

	UPROPERTY()
	TArray<UObject> StrongObjects;

	UPROPERTY()
	TWeakObjectPtr<UObject> WeakStrongObject;

	UPROPERTY()
	TWeakObjectPtr<UObject> WeakContainerObject;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakDestroyedActor;

	UPROPERTY()
	bool StrongPropertySurvivedGC = false;

	UPROPERTY()
	bool StrongContainerSurvivedGC = false;

	UPROPERTY()
	bool WeakDestroyedActorInvalidated = false;

	UPROPERTY()
	bool WeakPointersObserveStrongReachability = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StrongObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandlesGCStrongTexture");
		UObject ContainerObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandlesGCContainerTexture");
		StrongObjects.Add(ContainerObject);

		WeakStrongObject = StrongObject;
		WeakContainerObject = ContainerObject;

		AActor DestroyedActor = SpawnActor(AActor::StaticClass());
		WeakDestroyedActor = DestroyedActor;
		DestroyedActor.DestroyActor();

		CoverageGC::ForceGarbageCollectionNow();

		StrongPropertySurvivedGC = StrongObject != nullptr &&
			WeakStrongObject.IsValid() &&
			WeakStrongObject.Get() == StrongObject;
		StrongContainerSurvivedGC = StrongObjects.Num() == 1 &&
			StrongObjects[0] != nullptr &&
			WeakContainerObject.IsValid() &&
			WeakContainerObject.Get() == StrongObjects[0];
		WeakDestroyedActorInvalidated = WeakDestroyedActor == nullptr &&
			WeakDestroyedActor.Get() == nullptr &&
			!WeakDestroyedActor.IsValid();
		WeakPointersObserveStrongReachability = StrongPropertySurvivedGC &&
			StrongContainerSurvivedGC &&
			WeakStrongObject.Get() != WeakContainerObject.Get();
	}
}
