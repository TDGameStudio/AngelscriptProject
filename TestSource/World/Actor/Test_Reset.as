// Theme: World.Actor. WorldStory: OnReset writes ResetValue 7 and increments EventCallCount.
// C++: AngelscriptActorLifecycleTests.cpp::Reset
// Oracle: VerifyByPath EventCallCount 1, ResetValue 7.
// Extra: EventCallCount 0 and ResetValue 3 until OnReset. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorReset : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int ResetValue = 3;

	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetValue = 7;
		EventCallCount += 1;
	}
}
