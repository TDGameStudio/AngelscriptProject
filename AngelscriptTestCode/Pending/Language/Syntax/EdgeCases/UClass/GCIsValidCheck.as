/**
 * @version v1
 * @summary IsValid behaviour across a collection cycle: it reports true for a live object before GC, and reports false once the object has been collected and retrieved through a weak reference.
 * @topic Language
 */
/**
 * @version root
 * @summary IsValid behaviour across a collection cycle: it reports true for a live object before GC, and reports false once the object has been collected and retrieved through a weak reference.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCIsValidCheckActor : AActor
{
	UPROPERTY()
	bool IsValidReturnedTrueBeforeGC = false;

	UPROPERTY()
	bool IsValidDetectedInvalidObject = false;

	/**
	 * Checks IsValid before and after a forced collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags record both outcomes
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create object
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// IsValid should return true for live object
		if (IsValid(TempObject))
		{
			IsValidReturnedTrueBeforeGC = true;
		}

		// Get weak reference, then clear strong ref
		TWeakObjectPtr<UObject> WeakRef = TempObject;
		TempObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Try to get object from weak ref
		UObject RetrievedObject = WeakRef.Get();

		// IsValid should return false (or RetrievedObject is nullptr)
		if (RetrievedObject == nullptr || !IsValid(RetrievedObject))
		{
			IsValidDetectedInvalidObject = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run neither check.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCIsValidCheckFlagsDefaultToFalse()
	{
		if (IsValidReturnedTrueBeforeGC)
		{
			return false;
		}

		return !IsValidDetectedInvalidObject;
	}
}
/** @end */
