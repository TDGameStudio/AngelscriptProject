// Theme: World.Actor. WorldStory: one script actor Tick invokes another's UFUNCTION.
// C++: AngelscriptActorInteractionTests.cpp::CrossCall
// Oracle: TargetActor.ReceiveCallFromA increments EventCallCount (>= 1 after a tick).
// Extra: EventCallCount 0 and TargetActor null until C++ assigns the target and ticks.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorCrossCallB : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION()
	void ReceiveCallFromA()
	{
		EventCallCount += 1;
	}
}

UCLASS()
class ATestActorCrossCallA : AActor
{
	UPROPERTY()
	ATestActorCrossCallB TargetActor;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TargetActor != null)
		{
			TargetActor.ReceiveCallFromA();
		}
	}
}
