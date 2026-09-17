/**
 * @version v1
 * @summary The EndPlay BlueprintOverride recording the reason it was given. C++ verifies the count and that the reason came through as Destroyed.
 * @topic World
 */
/**
 * @version root
 * @summary The EndPlay BlueprintOverride recording the reason it was given. C++ verifies the count and that the reason came through as Destroyed.
 * @topic Baseline
 */
UCLASS()
class ATestActorReceiveEndPlayReason : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	/**
	 * WorldStory: EndPlay records the reason and counts the dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveEndPlayReason
	 * @Inputs the end play reason supplied by the engine
	 * @Return EventCallCount 1 and LastReason set to Destroyed
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		LastReason = Reason;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveEndPlayReason
	 * @Inputs an actor that has not ended play
	 * @Return true when the count is 0 and the reason is still Quit
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastReason == EEndPlayReason::Quit;
	}
}
/** @end */
