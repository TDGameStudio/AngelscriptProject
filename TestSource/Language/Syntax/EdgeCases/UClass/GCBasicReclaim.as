/**
 * A basic GC reclaim: a UObject held only by a local variable, whose reference is
 * cleared before collection, must be collected and its weak reference invalidated.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCBasicReclaim
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCBasicReclaim
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCBasicReclaim CompileScriptModule + spawn.
 * @Provenance sha256=7eabb0358a720f329af36b5350f90bebafaf9fe4aaa5c10ad826f90a956935e1; lines 78-110.
 * @Provenance Oracle: WeakRefInvalidatedAfterGC=true after ForceGarbageCollectionNow with no strong refs.
 * @Provenance Extra: local construct flag is false. FixtureIsolated. Locals do not keep UObject alive.
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
