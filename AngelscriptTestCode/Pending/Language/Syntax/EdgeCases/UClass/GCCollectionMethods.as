/**
 * @version v1
 * @summary The two GC entry points, CollectGarbageNow and ForceGarbageCollectionNow, both reclaim an object whose only reference was a cleared local. The flags record each outcome separately.
 * @topic Language
 */
/**
 * @version root
 * @summary The two GC entry points, CollectGarbageNow and ForceGarbageCollectionNow, both reclaim an object whose only reference was a cleared local. The flags record each outcome separately.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCCollectionMethodsActor : AActor
{
	UPROPERTY()
	bool CollectGarbageWorked = false;

	UPROPERTY()
	bool ForceGarbageCollectionWorked = false;

	/**
	 * Runs both collection entry points over dropped locals.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test CollectGarbage()
		{
			UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
			TWeakObjectPtr<UObject> WeakRef = TempObject;
			TempObject = nullptr;

			CoverageGC::CollectGarbageNow();

			if (!WeakRef.IsValid())
			{
				CollectGarbageWorked = true;
			}
		}

		// Test ForceGarbageCollection()
		{
			UObject TempObject2 = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
			TWeakObjectPtr<UObject> WeakRef2 = TempObject2;
			TempObject2 = nullptr;

			CoverageGC::ForceGarbageCollectionNow();

			if (!WeakRef2.IsValid())
			{
				ForceGarbageCollectionWorked = true;
			}
		}
	}

	/**
	 * Observe that a locally constructed actor has run neither collection.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCCollectionMethodsFlagsDefaultToFalse()
	{
		if (CollectGarbageWorked)
		{
			return false;
		}

		return !ForceGarbageCollectionWorked;
	}
}
/** @end */
