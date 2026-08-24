// Theme: Language.Syntax.EdgeCases. C++ compiles and VerifyByPath despite CSV NegativeDiagnostic.
// C++: AngelscriptCoverageGCTests.cpp::GCIsValidCheck
// sha256=2a9432b7bead2888945bfd06dd7d09debab57f4c1051b8d35323ddd303b36409; lines 641-680.
// Oracle: IsValidReturnedTrueBeforeGC=true; IsValidDetectedInvalidObject=true.
// Extra: both flags default false. FixtureIsolated.

UCLASS()
class ACoverageGCIsValidCheckActor : AActor
{
	UPROPERTY()
	bool IsValidReturnedTrueBeforeGC = false;

	UPROPERTY()
	bool IsValidDetectedInvalidObject = false;

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
}

bool Observe_GCIsValidCheck_DefaultFalse(ACoverageGCIsValidCheckActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCIsValidCheck setup: required Actor is null");
	}
	return !Actor.IsValidReturnedTrueBeforeGC && !Actor.IsValidDetectedInvalidObject;
}
