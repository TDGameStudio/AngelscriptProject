// Theme: World.Actor. WorldStory: ActorBeginOverlap BlueprintOverride.
// C++: AngelscriptActorInteractionTests.cpp::ActorBeginOverlap
// Oracle: after C++ overlap, EventCallCount 1 and LastActorRef is the trigger.
// Extra: EventCallCount 0 and LastActorRef null until overlap. ATestOverlapTrigger
// is the empty sibling. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}
}

UCLASS()
class ATestOverlapTrigger : AActor
{
}
