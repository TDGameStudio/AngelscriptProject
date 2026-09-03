/**
 * UnbindObject removes every listener on the target. After BeginPlay,
 * WasBoundBeforeUnbind is true, WasBoundAfterUnbind is false, and CountA/B/C
 * are each 1 because the second broadcast is a no-op.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastUnbindObjectRemovesTargetListeners
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastUnbindObjectRemovesTargetListeners
 * @Provenance Theme: Feature.Delegates. WorldStory: UnbindObject removes every listener on the target.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastUnbindObjectRemovesTargetListeners
 * @Provenance Spawn + BeginPlay oracle: WasBoundBeforeUnbind==true, WasBoundAfterUnbind==false,
 * @Provenance CountA/CountB/CountC each ==1 (second broadcast is a no-op).
 * @Provenance Extra: default counts 0; default WasBoundBeforeUnbind false / WasBoundAfterUnbind true.
 * @Provenance Keep Count* and WasBound*. FixtureIsolated.
 */

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Multicast
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageUnbindObjectSignal();

UCLASS()
class ACoverageMulticastUnbindObjectActor : AActor
{
	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	UPROPERTY()
	int CountC = 0;

	UPROPERTY()
	bool WasBoundBeforeUnbind = false;

	UPROPERTY()
	bool WasBoundAfterUnbind = true;

	UPROPERTY()
	FCoverageUnbindObjectSignal OnSignal;

	/**
	 * Adds three handlers, broadcasts, UnbindObject, then broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; each count ends at 1 and the event is unbound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnSignal.AddUFunction(this, n"HandlerA");
		OnSignal.AddUFunction(this, n"HandlerB");
		OnSignal.AddUFunction(this, n"HandlerC");
		WasBoundBeforeUnbind = OnSignal.IsBound();

		OnSignal.Broadcast();
		OnSignal.UnbindObject(this);
		WasBoundAfterUnbind = OnSignal.IsBound();
		OnSignal.Broadcast();
	}

	/**
	 * Increments CountA.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; CountA gains 1
	 */
	UFUNCTION()
	void HandlerA()
	{
		CountA += 1;
	}

	/**
	 * Increments CountB.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; CountB gains 1
	 */
	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	/**
	 * Increments CountC.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; CountC gains 1
	 */
	UFUNCTION()
	void HandlerC()
	{
		CountC += 1;
	}

	/**
	 * Observe the default handler counts.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return CountA + CountB + CountC
	 * @Boundary default counts
	 */
	UFUNCTION()
	int CountsDefaultZero()
	{
		return CountA + CountB + CountC;
	}

	/**
	 * Observe the declared bound-flag defaults.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return true when WasBoundBeforeUnbind is false and WasBoundAfterUnbind is true
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool BoundFlagsDefaults()
	{
		if (WasBoundBeforeUnbind)
		{
			return false;
		}
		return WasBoundAfterUnbind;
	}
}
