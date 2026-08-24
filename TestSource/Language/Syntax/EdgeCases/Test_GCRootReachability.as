// Theme: Language.Syntax.EdgeCases. WorldStory AddToRoot then RemoveFromRoot collect.
// C++: AngelscriptCoverageGCTests.cpp::GCRootReachability
// sha256=58bd65c09c3ed26cd8195262a6176fd50e43a95146560f811bea11d7c3fafea4; lines 792-825.
// Oracle: RootedObjectSurvivedGC=true; RemovedRootAllowedCollection=true.
// Extra: flags default false. FixtureIsolated. Root is a GC owner independent of locals.

UCLASS()
class ACoverageGCRootReachabilityActor : AActor
{
	UPROPERTY()
	bool RootedObjectSurvivedGC = false;

	UPROPERTY()
	bool RemovedRootAllowedCollection = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject RootedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCRootedObject");
		RootedObject.AddToRoot();

		TWeakObjectPtr<UObject> WeakRootedObject = RootedObject;
		RootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RootedObjectSurvivedGC = WeakRootedObject.IsValid();

		UObject UnrootedObject = WeakRootedObject.Get();
		if (UnrootedObject != nullptr)
		{
			UnrootedObject.RemoveFromRoot();
		}
		UnrootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RemovedRootAllowedCollection = !WeakRootedObject.IsValid() && WeakRootedObject.Get() == nullptr;
	}
}

bool Observe_GCRootReachability_DefaultFalse(ACoverageGCRootReachabilityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCRootReachability setup: required Actor is null");
	}
	return !Actor.RootedObjectSurvivedGC && !Actor.RemovedRootAllowedCollection;
}
