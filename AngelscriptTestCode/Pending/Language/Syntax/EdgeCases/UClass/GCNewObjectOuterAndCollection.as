/**
 * @version v1
 * @summary NewObject with a named outer plus the reclaim of the unreferenced result: the object is created with GetTransientPackage as outer, verified, then collected once its only reference is cleared.
 * @topic Language
 */
/**
 * @version root
 * @summary NewObject with a named outer plus the reclaim of the unreferenced result: the object is created with GetTransientPackage as outer, verified, then collected once its only reference is cleared.
 * @topic Baseline
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
/** @end */
