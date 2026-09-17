/**
 * @version v1
 * @summary The Destroyed BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after the actor is destroyed.
 * @topic World
 */
/**
 * @version root
 * @summary The Destroyed BlueprintOverride counting how many times the engine dispatched it. C++ verifies the count is 1 after the actor is destroyed.
 * @topic Baseline
 */
UCLASS()
class ATestActorReceiveDestroyed : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: Destroyed counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ReceiveDestroyed
	 * @Inputs none
	 * @Return EventCallCount == 1 after the actor is destroyed
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not been destroyed.
	 *
	 * @Kind Observe
	 * @Covers Actor.ReceiveDestroyed
	 * @Inputs an actor that has not been destroyed
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
