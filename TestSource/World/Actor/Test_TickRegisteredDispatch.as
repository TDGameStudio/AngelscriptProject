// Theme: World.Actor. WorldStory: world tick manager dispatches registered script Tick.
// C++: AngelscriptActorLifecycleTests.cpp::TickRegisteredDispatch
// Oracle: EventCallCount >= 1 and LastDeltaTime > 0 after world tick dispatch.
// Extra: EventCallCount 0 and LastDeltaTime 0 until Tick. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorTickRegisteredDispatch : AActor
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
