// Theme: World.Actor. WorldStory: Tick increments EventCallCount and stores DeltaTime.
// C++: AngelscriptActorLifecycleTests.cpp::Tick
// Oracle: EventCallCount >= 5 and LastDeltaTime > 0 after manual world ticks.
// Extra: EventCallCount 0 and LastDeltaTime 0 until Tick. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorTick : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastDeltaTime = 0.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		EventCallCount += 1;
		LastDeltaTime = DeltaTime;
	}
}
