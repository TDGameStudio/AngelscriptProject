/**
 * The Destroyed BlueprintOverride counting how many times the engine dispatched it.
 * C++ verifies the count is 1 after the actor is destroyed.
 *
 * @Theme World.Actor
 * @Subject Actor.ReceiveDestroyed
 * @Harness UClass
 * @Tag World.Actor.ReceiveDestroyed
 * @Provenance Theme: World.Actor. WorldStory: Destroyed BlueprintOverride increments EventCallCount.
 * @Provenance C++: AngelscriptActorLifecycleTests.cpp::ReceiveDestroyed
 * @Provenance Oracle: VerifyByPath EventCallCount 1 after destroy.
 * @Provenance Extra: EventCallCount stays 0 until Destroyed. Do not spawn from script. FixtureIsolated.
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
