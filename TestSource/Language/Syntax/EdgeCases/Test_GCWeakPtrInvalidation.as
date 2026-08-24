// Theme: Language.Syntax.EdgeCases. C++ compiles and VerifyByPath despite CSV NegativeDiagnostic.
// C++: AngelscriptCoverageGCTests.cpp::GCWeakPtrInvalidation
// sha256=fb32ab6297418db6cc458d8656b0d4cac3d141be857f0d2a7266bc63beba9af3; lines 221-259.
// Oracle: WeakPtrValidBeforeGC=true; WeakPtrInvalidAfterGC=true.
// Extra: both flags default false. FixtureIsolated.

UCLASS()
class ACoverageGCWeakPtrInvalidationActor : AActor
{
	UPROPERTY()
	bool WeakPtrValidBeforeGC = false;

	UPROPERTY()
	bool WeakPtrInvalidAfterGC = false;

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
}

bool Observe_GCWeakPtr_DefaultFalse(ACoverageGCWeakPtrInvalidationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCWeakPtrInvalidation setup: required Actor is null");
	}
	return !Actor.WeakPtrValidBeforeGC && !Actor.WeakPtrInvalidAfterGC;
}
