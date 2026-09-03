/**
 * IsValid behaviour across a collection cycle: it reports true for a live object
 * before GC, and reports false once the object has been collected and retrieved
 * through a weak reference.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCIsValidCheck
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCIsValidCheck
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCIsValidCheck
 * @Provenance sha256=2a9432b7bead2888945bfd06dd7d09debab57f4c1051b8d35323ddd303b36409; lines 641-680.
 * @Provenance Oracle: IsValidReturnedTrueBeforeGC=true; IsValidDetectedInvalidObject=true.
 * @Provenance Extra: both flags default false. FixtureIsolated.
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
