/**
 * NewObject with a named outer plus the reclaim of the unreferenced result: the
 * object is created with GetTransientPackage as outer, verified, then collected
 * once its only reference is cleared.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCNewObjectOuterAndCollection
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCNewObjectOuterAndCollection
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCNewObjectOuterAndCollection
 * @Provenance sha256=df575cd4ed04773eecfc433941eee46547a673c97a1608e81b2a7815efe4aa32; lines 723-749.
 * @Provenance Oracle: NewObjectCreatedWithOuter=true; UnreferencedNewObjectCollected=true.
 * @Provenance Extra: flags default false. FixtureIsolated. Outer is GetTransientPackage.
 */

UCLASS()
class ACoverageGCNewObjectOuterActor : AActor
{
	UPROPERTY()
	bool NewObjectCreatedWithOuter = false;

	UPROPERTY()
	bool UnreferencedNewObjectCollected = false;

	/**
	 * Creates the object, verifies its outer, then collects it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject CreatedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCNewObjectOuter");
		TWeakObjectPtr<UObject> WeakCreatedObject = CreatedObject;

		NewObjectCreatedWithOuter = CreatedObject != nullptr &&
			CreatedObject.GetOuter() == GetTransientPackage() &&
			CreatedObject.IsA(UTexture2D::StaticClass());

		CreatedObject = nullptr;
		CoverageGC::ForceGarbageCollectionNow();

		UnreferencedNewObjectCollected = !WeakCreatedObject.IsValid() && WeakCreatedObject.Get() == nullptr;
	}

	/**
	 * Observe that a locally constructed actor has run neither step.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCNewObjectOuterFlagsDefaultToFalse()
	{
		if (NewObjectCreatedWithOuter)
		{
			return false;
		}

		return !UnreferencedNewObjectCollected;
	}
}
