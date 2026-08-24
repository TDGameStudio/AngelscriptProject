// Theme: Language.Syntax.EdgeCases. WorldStory UPROPERTY TArray/TMap keep UObject alive.
// C++: AngelscriptCoverageGCTests.cpp::GCContainerProtection
// sha256=7da1c2766714bb582a18eecde8402a288bb4a28be682fbeb69284dbaa66853be; lines 302-352.
// Oracle: ArrayObjectSurvivedGC=true; MapObjectSurvivedGC=true.
// Extra: flags default false and containers empty. FixtureIsolated.

UCLASS()
class ACoverageGCContainerProtectionActor : AActor
{
	UPROPERTY()
	TArray<UObject> ObjectArray;

	UPROPERTY()
	TMap<int32, UObject> ObjectMap;

	UPROPERTY()
	bool ArrayObjectSurvivedGC = false;

	UPROPERTY()
	bool MapObjectSurvivedGC = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create objects and store in containers
		UObject ArrayObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		ObjectArray.Add(ArrayObject);

		UObject MapObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		ObjectMap.Add(1, MapObject);

		// Create weak references to verify survival
		TWeakObjectPtr<UObject> WeakArrayRef = ArrayObject;
		TWeakObjectPtr<UObject> WeakMapRef = MapObject;

		// Clear local references
		ArrayObject = nullptr;
		MapObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Container members should protect objects from GC
		if (WeakArrayRef.IsValid() && IsValid(ObjectArray[0]))
		{
			ArrayObjectSurvivedGC = true;
		}

		UObject RetrievedMapObject = ObjectMap[1];
		if (WeakMapRef.IsValid() && IsValid(RetrievedMapObject))
		{
			MapObjectSurvivedGC = true;
		}
	}
}

bool Observe_GCContainerProtection_DefaultEmpty(ACoverageGCContainerProtectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCContainerProtection setup: required Actor is null");
	}
	return Actor.ObjectArray.Num() == 0 && Actor.ObjectMap.Num() == 0 && !Actor.ArrayObjectSurvivedGC && !Actor.MapObjectSurvivedGC;
}
