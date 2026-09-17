/**
 * @version v1
 * @summary A basic GC reclaim: a UObject held only by a local variable, whose reference is cleared before collection, must be collected and its weak reference invalidated.
 * @topic Language
 */
/**
 * @version root
 * @summary A basic GC reclaim: a UObject held only by a local variable, whose reference is cleared before collection, must be collected and its weak reference invalidated.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCBasicReclaimActor : AActor
{
	UPROPERTY()
	bool WeakRefInvalidatedAfterGC = false;

	/**
	 * Creates an object, drops the only reference, and collects it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flag records whether the weak reference died
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create a local object that has no strong references
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference to track it
		TWeakObjectPtr<UObject> WeakRef = TempObject;

		// At this point, only the local variable holds it
		// Local variables do not protect from GC in AngelScript

		// Clear the local reference
		TempObject = nullptr;

		// Force garbage collection
		CoverageGC::ForceGarbageCollectionNow();

		// After GC, the weak reference should be invalid
		if (!WeakRef.IsValid())
		{
			WeakRefInvalidatedAfterGC = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has not run the probe.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the flag is still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCBasicReclaimFlagDefaultsToFalse()
	{
		return WeakRefInvalidatedAfterGC == false;
	}
}
/** @end */
