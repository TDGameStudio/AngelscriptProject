// Theme: World.Actor. WorldStory: EndPlay records EEndPlayReason::Destroyed.
// C++: AngelscriptActorLifecycleTests.cpp::ReceiveEndPlayReason
// Oracle: VerifyByPath EventCallCount 1; LastReason is Destroyed.
// Extra: EventCallCount 0 and LastReason Quit until EndPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorReceiveEndPlayReason : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		LastReason = Reason;
		EventCallCount += 1;
	}
}
