// Theme: World.Actor. WorldStory: EndPlay then Destroyed order on actor destroy.
// C++: AngelscriptActorLifecycleTests.cpp::DestroyLifecycleOrder
// Oracle: VerifyByPath EndPlayCallCount 1, DestroyedCallCount 1, EndPlayOrder 1, DestroyedOrder 2.
// Extra: all counts/orders stay 0 until destroy. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorDestroyLifecycleOrder : AActor
{
	UPROPERTY()
	int EndPlayCallCount = 0;

	UPROPERTY()
	int DestroyedCallCount = 0;

	UPROPERTY()
	int NextOrder = 0;

	UPROPERTY()
	int EndPlayOrder = 0;

	UPROPERTY()
	int DestroyedOrder = 0;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCallCount += 1;
		NextOrder += 1;
		EndPlayOrder = NextOrder;
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCallCount += 1;
		NextOrder += 1;
		DestroyedOrder = NextOrder;
	}
}
