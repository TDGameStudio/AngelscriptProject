/**
 * The EndPlay and Destroyed overrides recording the order in which the engine ran
 * them when the actor was destroyed. C++ verifies both counts and the relative
 * order. Nothing is recorded until the actor is destroyed.
 *
 * @Theme World.Actor
 * @Subject Actor.DestroyLifecycleOrder
 * @Harness UClass
 * @Tag World.Actor.DestroyLifecycleOrder
 * @Provenance Theme: World.Actor. WorldStory: EndPlay then Destroyed order on actor destroy.
 * @Provenance C++: AngelscriptActorLifecycleTests.cpp::DestroyLifecycleOrder
 * @Provenance Oracle: VerifyByPath EndPlayCallCount 1, DestroyedCallCount 1, EndPlayOrder 1, DestroyedOrder 2.
 * @Provenance Extra: all counts/orders stay 0 until destroy. Do not spawn from script. FixtureIsolated.
 */

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

	/**
	 * WorldStory: EndPlay counts the call and claims the next order token.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCallCount incremented and EndPlayOrder set to the claimed token
	 * @Param Reason why the actor is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCallCount += 1;
		NextOrder += 1;
		EndPlayOrder = NextOrder;
	}

	/**
	 * WorldStory: Destroyed counts the call and claims the next order token.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs none
	 * @Return DestroyedCallCount incremented and DestroyedOrder set to the claimed token
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCallCount += 1;
		NextOrder += 1;
		DestroyedOrder = NextOrder;
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.DestroyLifecycleOrder
	 * @Inputs an actor that has not been destroyed
	 * @Return true when both counts and all three order fields are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EndPlayCallCount != 0)
		{
			return false;
		}
		if (DestroyedCallCount != 0)
		{
			return false;
		}
		if (NextOrder != 0)
		{
			return false;
		}
		if (EndPlayOrder != 0)
		{
			return false;
		}
		return DestroyedOrder == 0;
	}
}
