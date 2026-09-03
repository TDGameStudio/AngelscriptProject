/**
 * Two script actors where one calls a UFUNCTION on the other from its Tick. C++
 * assigns the target and ticks, then verifies the callee's count. Nothing happens
 * until the target has been assigned.
 *
 * @Theme World.Actor
 * @Subject Actor.CrossCall
 * @Harness UClass
 * @Tag World.Actor.CrossCall
 * @Provenance Theme: World.Actor. WorldStory: one script actor Tick invokes another's UFUNCTION.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::CrossCall
 * @Provenance Oracle: TargetActor.ReceiveCallFromA increments EventCallCount (>= 1 after a tick).
 * @Provenance Extra: EventCallCount 0 and TargetActor null until C++ assigns the target and ticks.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorCrossCallB : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * Count each call received from the other actor.
	 *
	 * @Kind Action
	 * @Covers Actor.CrossCall
	 * @Inputs none
	 * @Return EventCallCount incremented once per call
	 */
	UFUNCTION()
	void ReceiveCallFromA()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed callee has received no calls.
	 *
	 * @Kind Observe
	 * @Covers Actor.CrossCall
	 * @Inputs a callee that has not been called
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}

UCLASS()
class ATestActorCrossCallA : AActor
{
	UPROPERTY()
	ATestActorCrossCallB TargetActor;

	/**
	 * WorldStory: each Tick calls into the target actor.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.CrossCall
	 * @Inputs the frame delta and the assigned target actor
	 * @Return one ReceiveCallFromA call per tick once the target is set
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TargetActor != null)
		{
			TargetActor.ReceiveCallFromA();
		}
	}

	/**
	 * Observe that a locally constructed caller has no target assigned.
	 *
	 * @Kind Observe
	 * @Covers Actor.CrossCall
	 * @Inputs a caller whose target has not been assigned
	 * @Return true when TargetActor is null
	 * @Boundary null target
	 */
	UFUNCTION()
	bool DefaultNullTarget()
	{
		return TargetActor == nullptr;
	}
}
