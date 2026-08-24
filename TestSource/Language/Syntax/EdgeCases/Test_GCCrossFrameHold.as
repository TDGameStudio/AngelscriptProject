// Theme: Language.Syntax.EdgeCases. WorldStory UPROPERTY hold survives multi-frame GC.
// C++: AngelscriptCoverageGCTests.cpp::GCCrossFrameHold
// sha256=fa58ec9c50058d8cfe25c7eb79fe6f175a7c3ab68a2a0710fe990ed40e4a428e; lines 395-436.
// Oracle: ObjectValidAfterMultipleFrames=true after Tick FrameCount==3.
// Extra: HeldObject null, FrameCount=0, flag false. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create object and hold it
		HeldObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		WeakRef = HeldObject;
	}

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
}

bool Observe_GCCrossFrameHold_DefaultEmpty(ACoverageGCCrossFrameHoldActor Actor)
{
	if (Actor is null)
	{
		throw("Test_GCCrossFrameHold setup: required Actor is null");
	}
	return Actor.HeldObject == nullptr && Actor.FrameCount == 0 && !Actor.ObjectValidAfterMultipleFrames;
}
