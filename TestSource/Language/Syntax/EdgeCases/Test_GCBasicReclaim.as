// Theme: Language.Syntax.EdgeCases. C++ compiles and VerifyByPath despite CSV NegativeDiagnostic.
// C++: AngelscriptCoverageGCTests.cpp::GCBasicReclaim CompileScriptModule + spawn.
// sha256=7eabb0358a720f329af36b5350f90bebafaf9fe4aaa5c10ad826f90a956935e1; lines 78-110.
// Oracle: WeakRefInvalidatedAfterGC=true after ForceGarbageCollectionNow with no strong refs.
// Extra: local construct flag is false. FixtureIsolated. Locals do not keep UObject alive.

UCLASS()
class ACoverageGCBasicReclaimActor : AActor
{
	UPROPERTY()
	bool WeakRefInvalidatedAfterGC = false;

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
}

bool Observe_GCBasicReclaim_DefaultFalse(ACoverageGCBasicReclaimActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCBasicReclaim setup: required Actor is null");
	}
	return !Actor.WeakRefInvalidatedAfterGC;
}
