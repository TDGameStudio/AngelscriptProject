/**
 * The ActorEndOverlap BlueprintOverride recording how many times it fired and the
 * actor that last stopped overlapping. C++ drives the end-overlap and verifies both
 * by path. ATestEndOverlapTrigger is the empty sibling that C++ also compiles.
 *
 * @Theme World.Actor
 * @Subject Actor.EndOverlap
 * @Harness UClass
 * @Tag World.Actor.ActorEndOverlap
 * @Provenance Theme: World.Actor. WorldStory: ActorEndOverlap BlueprintOverride.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::ActorEndOverlap
 * @Provenance Oracle: EventCallCount 1 and LastActorRef is the trigger after C++ end-overlap.
 * @Provenance Extra: EventCallCount 0 and LastActorRef null until end-overlap. Empty trigger sibling.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestEndOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the end overlap override records the other actor and counts the
	 * call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.EndOverlap
	 * @Inputs the actor that stopped overlapping
	 * @Return EventCallCount incremented and LastActorRef set to the trigger
	 * @Param OtherActor the actor that stopped overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed receiver has not fired.
	 *
	 * @Kind Observe
	 * @Covers Actor.EndOverlap
	 * @Inputs a receiver that has not ended an overlap
	 * @Return true when the count is 0 and the last actor is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastActorRef == nullptr;
	}
}

/**
 * The empty trigger actor that C++ compiles alongside the receiver.
 *
 * @Covers Actor.EndOverlap
 * @Inputs none
 * @Return a declared but empty actor used as the overlap trigger
 */
UCLASS()
class ATestEndOverlapTrigger : AActor
{
}
