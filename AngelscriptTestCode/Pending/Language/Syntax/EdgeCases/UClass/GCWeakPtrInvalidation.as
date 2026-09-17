/**
 * @version v1
 * @summary Weak pointer invalidation across collection: the weak reference is valid while a strong local exists and becomes invalid once that local is cleared and GC runs.
 * @topic Language
 */
/**
 * @version root
 * @summary Weak pointer invalidation across collection: the weak reference is valid while a strong local exists and becomes invalid once that local is cleared and GC runs.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCWeakPtrInvalidationActor : AActor
{
	UPROPERTY()
	bool WeakPtrValidBeforeGC = false;

	UPROPERTY()
	bool WeakPtrInvalidAfterGC = false;

	/**
	 * Checks the weak reference before and after collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create an object with no strong references
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference
		TWeakObjectPtr<UObject> WeakRef = TempObject;

		// Verify weak ref is initially valid
		if (WeakRef.IsValid())
		{
			WeakPtrValidBeforeGC = true;
		}

		// Clear strong reference
		TempObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Weak reference should now be invalid
		if (!WeakRef.IsValid())
		{
			WeakPtrInvalidAfterGC = true;
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
	bool GCWeakPtrFlagsDefaultToFalse()
	{
		if (WeakPtrValidBeforeGC)
		{
			return false;
		}

		return !WeakPtrInvalidAfterGC;
	}
}
/** @end */
