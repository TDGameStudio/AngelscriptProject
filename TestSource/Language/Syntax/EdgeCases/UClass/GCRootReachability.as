/**
 * GC root reachability: an object added to the root set survives collection, and
 * removing it from the root set allows collection again.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCRootReachability
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCRootReachability
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCRootReachability
 * @Provenance sha256=58bd65c09c3ed26cd8195262a6176fd50e43a95146560f811bea11d7c3fafea4; lines 792-825.
 * @Provenance Oracle: RootedObjectSurvivedGC=true; RemovedRootAllowedCollection=true.
 * @Provenance Extra: flags default false. FixtureIsolated. Root is a GC owner independent of locals.
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
