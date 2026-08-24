// Theme: Definitions.UProperty. WorldStory: UPROPERTY UObject member keeps the referent alive across GC.
// C++: VerifyByPath ObjectSurvivedGC true after CoverageGC::ForceGarbageCollectionNow.
// Extra: null StrongRefObject is not a surviving referent. FixtureIsolated.

UCLASS()
class ACoverageGCUPropertyProtectionActor : AActor
{
	UPROPERTY()
	UObject StrongRefObject;

	UPROPERTY()
	bool ObjectSurvivedGC = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StrongRefObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		TWeakObjectPtr<UObject> WeakRef = StrongRefObject;

		CoverageGC::ForceGarbageCollectionNow();

		if (WeakRef.IsValid() && IsValid(StrongRefObject))
		{
			ObjectSurvivedGC = true;
		}
	}
}

bool Observe_NullStrongRefDoesNotSurvive()
{
	UObject StrongRefObject;
	return StrongRefObject == nullptr;
}

bool Observe_EmptyWeakRefIsInvalid()
{
	TWeakObjectPtr<UObject> WeakRef;
	return !WeakRef.IsValid();
}
