/**
 * @version v1
 * @summary The EndPlay BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after a destroy or end of play.
 * @topic World
 */
/**
 * @version root
 * @summary The EndPlay BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after a destroy or end of play.
 * @topic Baseline
 */
UCLASS()
class ATestActorReceiveEndPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: EndPlay counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveEndPlay
	 * @Inputs the end play reason supplied by the engine
	 * @Return EventCallCount == 1 after a destroy or end of play
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not ended play.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveEndPlay
	 * @Inputs an actor that has not ended play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
/** @end */
