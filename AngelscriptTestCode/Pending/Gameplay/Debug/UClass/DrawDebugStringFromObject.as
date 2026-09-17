/**
 * @version v1
 * @summary DrawDebugStringFromObject called from an actor's BeginPlay, recording that the draw happened. C++ verifies the flag by path, so the UPROPERTY name is part of the contract and is kept verbatim.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary DrawDebugStringFromObject called from an actor's BeginPlay, recording that the draw happened. C++ verifies the flag by path, so the UPROPERTY name is part of the contract and is kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ADebugStringCoverageActor : AActor
{
	UPROPERTY()
	bool bDrewDebugString = false;

	/**
	 * WorldStory: BeginPlay draws a debug string above the actor and records it.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.DrawDebugStringFromObject
	 * @Inputs none
	 * @Return bDrewDebugString == true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DrawDebugStringFromObject(this, GetActorLocation() + FVector(0.0, 0.0, 25.0), "CoverageDebugString", 0.01f, FLinearColor::Green);
		bDrewDebugString = true;
	}

	/**
	 * Observe that a locally constructed actor has not drawn anything.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringFromObject
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return !bDrewDebugString;
	}
}
/** @end */
