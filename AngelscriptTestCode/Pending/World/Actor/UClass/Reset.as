/**
 * @version v1
 * @summary The OnReset override writing a new value and counting the dispatch. C++ verifies both by path. Nothing changes until the reset is requested.
 * @topic World
 */
/**
 * @version root
 * @summary The OnReset override writing a new value and counting the dispatch. C++ verifies both by path. Nothing changes until the reset is requested.
 * @topic Baseline
 */
UCLASS()
class ATestActorReset : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int ResetValue = 3;

	/**
	 * WorldStory: the reset override rewrites the value and counts the dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.Reset
	 * @Inputs none
	 * @Return EventCallCount 1 and ResetValue 7
	 */
	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Actor.Reset
	 * @Inputs an actor that has not been reset
	 * @Return true when the count is 0 and the value is still 3
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return ResetValue == 3;
	}
}
/** @end */
