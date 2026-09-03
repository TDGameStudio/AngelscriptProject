/**
 * A Tick override reached through the world tick manager rather than a manual tick.
 * C++ dispatches a world tick and verifies the count and the delta.
 *
 * @Theme World.Actor
 * @Subject Actor.TickRegisteredDispatch
 * @Harness UClass
 * @Tag World.Actor.TickRegisteredDispatch
 * @Provenance Theme: World.Actor. WorldStory: world tick manager dispatches registered script Tick.
 * @Provenance C++: AngelscriptActorLifecycleTests.cpp::TickRegisteredDispatch
 * @Provenance Oracle: EventCallCount >= 1 and LastDeltaTime > 0 after world tick dispatch.
 * @Provenance Extra: EventCallCount 0 and LastDeltaTime 0 until Tick. Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorTickRegisteredDispatch : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	/**
	 * WorldStory: a world tick dispatch reaches this override, which counts it and
	 * keeps the delta.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TickRegisteredDispatch
	 * @Inputs the frame delta
	 * @Return EventCallCount at least 1 and LastDeltaTime greater than 0 after a dispatch
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
	 * @Covers Actor.TickRegisteredDispatch
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
