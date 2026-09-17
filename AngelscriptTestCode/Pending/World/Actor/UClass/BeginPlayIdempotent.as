/**
 * @version v1
 * @summary A BeginPlay override that must not increment a second time when the engine dispatches BeginPlay again. C++ attempts two BeginPlay dispatches and verifies the count is still 1.
 * @topic World
 */
/**
 * @version root
 * @summary A BeginPlay override that must not increment a second time when the engine dispatches BeginPlay again. C++ attempts two BeginPlay dispatches and verifies the count is still 1.
 * @topic Baseline
 */
UCLASS()
class ATestActorBeginPlayIdempotent : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch, and a second dispatch is expected
	 * not to happen.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginPlayIdempotent
	 * @Inputs none
	 * @Return EventCallCount == 1 even after two dispatch attempts
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
	 * @Covers Actor.BeginPlayIdempotent
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
