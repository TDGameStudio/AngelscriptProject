/**
 * @version v1
 * @summary A BeginPlay override counting how many times the engine dispatched it. C++ verifies the count is 1 after the world has begun play.
 * @topic World
 */
/**
 * @version root
 * @summary A BeginPlay override counting how many times the engine dispatched it. C++ verifies the count is 1 after the world has begun play.
 * @topic Baseline
 */
UCLASS()
class ATestActorBeginPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginPlay
	 * @Inputs none
	 * @Return EventCallCount == 1 after the world has begun play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Actor.BeginPlay
	 * @Inputs an actor that has not begun play
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
