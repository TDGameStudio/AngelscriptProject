/**
 * @version v1
 * @summary GC root reachability: an object added to the root set survives collection, and removing it from the root set allows collection again.
 * @topic Language
 */
/**
 * @version root
 * @summary GC root reachability: an object added to the root set survives collection, and removing it from the root set allows collection again.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCRootReachabilityActor : AActor
{
	UPROPERTY()
	bool RootedObjectSurvivedGC = false;

	UPROPERTY()
	bool RemovedRootAllowedCollection = false;

	/**
	 * Roots an object, collects, unroots it, and collects again.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject RootedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCRootedObject");
		RootedObject.AddToRoot();

		TWeakObjectPtr<UObject> WeakRootedObject = RootedObject;
		RootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RootedObjectSurvivedGC = WeakRootedObject.IsValid();

		UObject UnrootedObject = WeakRootedObject.Get();
		if (UnrootedObject != nullptr)
		{
			UnrootedObject.RemoveFromRoot();
		}
		UnrootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RemovedRootAllowedCollection = !WeakRootedObject.IsValid() && WeakRootedObject.Get() == nullptr;
	}

	/**
	 * Observe that a locally constructed actor has run neither phase.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCRootReachabilityFlagsDefaultToFalse()
	{
		if (RootedObjectSurvivedGC)
		{
			return false;
		}

		return !RemovedRootAllowedCollection;
	}
}
/** @end */
