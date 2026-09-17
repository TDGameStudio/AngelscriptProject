/**
 * @version v1
 * @summary A UPROPERTY UObject member keeps the referent alive across GC. C++ verifies ObjectSurvivedGC by path, so that name is kept. The observers cover a null StrongRefObject and an empty weak ref.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY UObject member keeps the referent alive across GC. C++ verifies ObjectSurvivedGC by path, so that name is kept. The observers cover a null StrongRefObject and an empty weak ref.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCUPropertyProtectionActor : AActor
{
	UPROPERTY()
	UObject StrongRefObject;

	UPROPERTY()
	bool ObjectSurvivedGC = false;

	/**
	 * WorldStory: hold a UObject through a UPROPERTY across a forced GC.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.GCUPropertyProtection
	 * @Inputs a NewObject Texture2D stored in StrongRefObject
	 * @Return ObjectSurvivedGC true when the weak ref and strong ref stay valid
	 */
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

	/**
	 * Observe that a null StrongRefObject is not a surviving referent.
	 *
	 * @Kind Observe
	 * @Covers UProperty.GCUPropertyProtection
	 * @Inputs an unset UObject
	 * @Return true when the object is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool NullStrongRefDoesNotSurvive()
	{
		UObject StrongRefObject;
		return StrongRefObject == nullptr;
	}

	/**
	 * Observe that an empty weak ref is invalid.
	 *
	 * @Kind Observe
	 * @Covers UProperty.GCUPropertyProtection
	 * @Inputs a default-constructed TWeakObjectPtr<UObject>
	 * @Return true when IsValid is false
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyWeakRefIsInvalid()
	{
		TWeakObjectPtr<UObject> WeakRef;
		return !WeakRef.IsValid();
	}
}
/** @end */
