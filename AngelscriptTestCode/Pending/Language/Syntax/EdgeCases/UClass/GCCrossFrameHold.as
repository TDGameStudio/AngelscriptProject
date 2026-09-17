/**
 * @version v1
 * @summary A UPROPERTY hold surviving multi-frame collection: the object is held in BeginPlay and verified alive after three ticks and a forced GC at the third.
 * @topic Language
 */
/**
 * @version root
 * @summary A UPROPERTY hold surviving multi-frame collection: the object is held in BeginPlay and verified alive after three ticks and a forced GC at the third.
 * @topic Baseline
 */
UCLASS()
class ACoverageGCCrossFrameHoldActor : AActor
{
	UPROPERTY()
	UObject HeldObject;

	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;

	UPROPERTY()
	int32 FrameCount = 0;

	UPROPERTY()
	bool ObjectValidAfterMultipleFrames = false;

	/**
	 * Creates the object and holds it in a UPROPERTY.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; HeldObject and WeakRef are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create object and hold it
		HeldObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		WeakRef = HeldObject;
	}

	/**
	 * Counts ticks and verifies the hold on the third frame.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the frame delta
	 * @Return nothing; the flag records survival after the third tick
	 * @Param DeltaSeconds the seconds since the last tick
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		FrameCount++;

		// After 3 frames, force GC and verify object still exists
		if (FrameCount == 3)
		{
			CoverageGC::ForceGarbageCollectionNow();

			if (WeakRef.IsValid() && IsValid(HeldObject))
			{
				ObjectValidAfterMultipleFrames = true;
			}
		}
	}

	/**
	 * Observe that a locally constructed actor holds nothing yet.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the hold is null, the count is 0 and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCCrossFrameHoldDefaultEmpty()
	{
		if (HeldObject != nullptr)
		{
			return false;
		}

		if (FrameCount != 0)
		{
			return false;
		}

		return !ObjectValidAfterMultipleFrames;
	}
}
/** @end */
