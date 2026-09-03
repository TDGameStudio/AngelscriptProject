/**
 * The OnReset override writing a new value and counting the dispatch. C++ verifies
 * both by path. Nothing changes until the reset is requested.
 *
 * @Theme World.Actor
 * @Subject Actor.Reset
 * @Harness UClass
 * @Tag World.Actor.Reset
 * @Provenance Theme: World.Actor. WorldStory: OnReset writes ResetValue 7 and increments EventCallCount.
 * @Provenance C++: AngelscriptActorLifecycleTests.cpp::Reset
 * @Provenance Oracle: VerifyByPath EventCallCount 1, ResetValue 7.
 * @Provenance Extra: EventCallCount 0 and ResetValue 3 until OnReset. Do not spawn from script. FixtureIsolated.
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
