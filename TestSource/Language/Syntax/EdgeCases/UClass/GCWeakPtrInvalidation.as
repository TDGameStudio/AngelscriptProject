/**
 * Weak pointer invalidation across collection: the weak reference is valid while
 * a strong local exists and becomes invalid once that local is cleared and GC
 * runs.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCWeakPtrInvalidation
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCWeakPtrInvalidation
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCWeakPtrInvalidation
 * @Provenance sha256=fb32ab6297418db6cc458d8656b0d4cac3d141be857f0d2a7266bc63beba9af3; lines 221-259.
 * @Provenance Oracle: WeakPtrValidBeforeGC=true; WeakPtrInvalidAfterGC=true.
 * @Provenance Extra: both flags default false. FixtureIsolated.
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
