// Theme: World.Actor. WorldStory: ActorEndOverlap BlueprintOverride.
// C++: AngelscriptActorInteractionTests.cpp::ActorEndOverlap
// Oracle: EventCallCount 1 and LastActorRef is the trigger after C++ end-overlap.
// Extra: EventCallCount 0 and LastActorRef null until end-overlap. Empty trigger sibling.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestEndOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}
}

UCLASS()
class ATestEndOverlapTrigger : AActor
{
}
