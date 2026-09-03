/**
 * A Tick override counting dispatches and storing the last frame delta. C++ ticks
 * the world manually and verifies the count and the delta.
 *
 * @Theme World.Actor
 * @Subject Actor.Tick
 * @Harness UClass
 * @Tag World.Actor.Tick
 * @Provenance Theme: World.Actor. WorldStory: Tick increments EventCallCount and stores DeltaTime.
 * @Provenance C++: AngelscriptActorLifecycleTests.cpp::Tick
 * @Provenance Oracle: EventCallCount >= 5 and LastDeltaTime > 0 after manual world ticks.
 * @Provenance Extra: EventCallCount 0 and LastDeltaTime 0 until Tick. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorTick : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	/**
	 * WorldStory: Tick counts each dispatch and keeps the delta it was given.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.Tick
	 * @Inputs the frame delta
	 * @Return EventCallCount at least 5 and LastDeltaTime greater than 0 after manual ticks
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}

	/**
	 * Observe that a locally constructed actor has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Actor.Tick
	 * @Inputs an actor that has not been ticked
	 * @Return true when the count is 0 and the delta is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastDeltaTime == 0.0f;
	}
}
