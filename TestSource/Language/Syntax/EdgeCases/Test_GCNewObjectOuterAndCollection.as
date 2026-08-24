// Theme: Language.Syntax.EdgeCases. WorldStory NewObject outer plus unreferenced collect.
// C++: AngelscriptCoverageGCTests.cpp::GCNewObjectOuterAndCollection
// sha256=df575cd4ed04773eecfc433941eee46547a673c97a1608e81b2a7815efe4aa32; lines 723-749.
// Oracle: NewObjectCreatedWithOuter=true; UnreferencedNewObjectCollected=true.
// Extra: flags default false. FixtureIsolated. Outer is GetTransientPackage.

UCLASS()
class ACoverageGCNewObjectOuterActor : AActor
{
	UPROPERTY()
	bool NewObjectCreatedWithOuter = false;

	UPROPERTY()
	bool UnreferencedNewObjectCollected = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject CreatedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCNewObjectOuter");
		TWeakObjectPtr<UObject> WeakCreatedObject = CreatedObject;

		NewObjectCreatedWithOuter = CreatedObject != nullptr &&
			CreatedObject.GetOuter() == GetTransientPackage() &&
			CreatedObject.IsA(UTexture2D::StaticClass());

		CreatedObject = nullptr;
		CoverageGC::ForceGarbageCollectionNow();

		UnreferencedNewObjectCollected = !WeakCreatedObject.IsValid() && WeakCreatedObject.Get() == nullptr;
	}
}

bool Observe_GCNewObjectOuter_DefaultFalse(ACoverageGCNewObjectOuterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCNewObjectOuterAndCollection setup: required Actor is null");
	}
	return !Actor.NewObjectCreatedWithOuter && !Actor.UnreferencedNewObjectCollected;
}
