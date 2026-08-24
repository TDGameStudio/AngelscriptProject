// Theme: World.Actor. WorldStory: EndPlay BlueprintOverride increments EventCallCount.
// C++: AngelscriptActorLifecycleTests.cpp::ReceiveEndPlay
// Oracle: VerifyByPath EventCallCount 1 after destroy/end play.
// Extra: EventCallCount stays 0 until EndPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorReceiveEndPlay : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EventCallCount += 1;
	}
}
