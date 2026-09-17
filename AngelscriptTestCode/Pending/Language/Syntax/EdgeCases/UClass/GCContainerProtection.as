/**
 * @version v1
 * @summary UPROPERTY containers keep UObjects alive across collection: one object held in a TArray and one in a TMap both survive a forced GC after their locals are cleared.
 * @topic Language
 */
/**
 * @version root
 * @summary UPROPERTY containers keep UObjects alive across collection: one object held in a TArray and one in a TMap both survive a forced GC after their locals are cleared.
 * @topic Baseline
 */
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

	/**
	 * Stores two objects in the containers and forces collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags record survival
	 */
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

	/**
	 * Observe that a locally constructed actor starts with empty containers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both containers are empty and both flags are false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCContainerProtectionDefaultEmpty()
	{
		if (ObjectArray.Num() != 0)
		{
			return false;
		}

		if (ObjectMap.Num() != 0)
		{
			return false;
		}

		if (ArrayObjectSurvivedGC)
		{
			return false;
		}

		return !MapObjectSurvivedGC;
	}
}
/** @end */
