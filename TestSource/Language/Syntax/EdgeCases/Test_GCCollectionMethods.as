// Theme: Language.Syntax.EdgeCases. WorldStory CollectGarbageNow vs ForceGarbageCollectionNow.
// C++: AngelscriptCoverageGCTests.cpp::GCCollectionMethods
// sha256=7a5431b623878ed826edb8aea30b00fef7097389d3ccc486bc617d344fbaec3d; lines 556-598.
// Oracle: CollectGarbageWorked=true; ForceGarbageCollectionWorked=true.
// Extra: both flags default false. FixtureIsolated.

UCLASS()
class ACoverageGCCollectionMethodsActor : AActor
{
	UPROPERTY()
	bool CollectGarbageWorked = false;

	UPROPERTY()
	bool ForceGarbageCollectionWorked = false;

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
}

bool Observe_GCCollectionMethods_DefaultFalse(ACoverageGCCollectionMethodsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCCollectionMethods setup: required Actor is null");
	}
	return !Actor.CollectGarbageWorked && !Actor.ForceGarbageCollectionWorked;
}
