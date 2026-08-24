// Theme: World.Actor. WorldStory: a second BeginPlay dispatch does not increment again.
// C++: AngelscriptActorLifecycleTests.cpp::BeginPlayIdempotent
// Oracle: VerifyByPath EventCallCount 1 after two BeginPlay attempts.
// Extra: EventCallCount stays 0 until first BeginPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorBeginPlayIdempotent : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
