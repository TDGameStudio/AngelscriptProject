// Theme: World.Actor. WorldStory: BeginPlay increments EventCallCount.
// C++: AngelscriptActorLifecycleTests.cpp::BeginPlay
// Oracle: VerifyByPath EventCallCount 1 after world BeginPlay.
// Extra: EventCallCount stays 0 until BeginPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorBeginPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
