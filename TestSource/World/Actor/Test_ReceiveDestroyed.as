// Theme: World.Actor. WorldStory: Destroyed BlueprintOverride increments EventCallCount.
// C++: AngelscriptActorLifecycleTests.cpp::ReceiveDestroyed
// Oracle: VerifyByPath EventCallCount 1 after destroy.
// Extra: EventCallCount stays 0 until Destroyed. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorReceiveDestroyed : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		EventCallCount += 1;
	}
}
