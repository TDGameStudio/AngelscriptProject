/**
 * The two GC entry points, CollectGarbageNow and ForceGarbageCollectionNow, both
 * reclaim an object whose only reference was a cleared local. The flags record
 * each outcome separately.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GCCollectionMethods
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.GCCollectionMethods
 * @Provenance C++: AngelscriptCoverageGCTests.cpp::GCCollectionMethods
 * @Provenance sha256=7a5431b623878ed826edb8aea30b00fef7097389d3ccc486bc617d344fbaec3d; lines 556-598.
 * @Provenance Oracle: CollectGarbageWorked=true; ForceGarbageCollectionWorked=true.
 * @Provenance Extra: both flags default false. FixtureIsolated.
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
