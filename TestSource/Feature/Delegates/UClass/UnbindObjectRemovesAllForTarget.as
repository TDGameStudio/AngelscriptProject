/**
 * UnbindObject removes every handler on this actor so a later Broadcast does not fire.
 * C++ executes RunUnbindObjTest, so that name is part of the contract and is kept verbatim.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UnbindObjectRemovesAllForTarget
 * @Harness UClass
 * @Tag Feature.Delegates.UnbindObjectRemovesAllForTarget
 * @Provenance Theme: Feature.Delegates. WorldStory UnbindObject removes every handler on this.
 * @Provenance C++: AngelscriptDelegateTests.cpp::UnbindObjectRemovesAllForTarget
 * @Provenance sha256 from theme-refs TS-FEAT-0208; lines 688-729.
 * @Provenance Oracle: RunUnbindObjTest returns 1. Extra: counts default 0; second local independent.
 * @Provenance FixtureIsolated.
 */

/**
 * Multicast signal event used by the UnbindObject test.
 *
 * @Kind Event
 * @Covers Delegates.UnbindObjectRemovesAllForTarget
 * @Inputs none
 * @Return void
 */
event void FOnSignal();

UCLASS()
class ATestDelegateUnbindObj : AActor
{
	UPROPERTY()
	FOnSignal OnSignal;

	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	/**
	 * Increment CountA when the multicast fires.
	 *
	 * @Kind Action
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs none
	 * @Return CountA increased by one
	 */
	UFUNCTION()
	void HandlerA()
	{
		CountA += 1;
	}

	/**
	 * Increment CountB when the multicast fires.
	 *
	 * @Kind Action
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs none
	 * @Return CountB increased by one
	 */
	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	/**
	 * Bind A and B, broadcast, UnbindObject, broadcast again. Counts must stay 1.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs none
	 * @Return 1 on success, 10/20/30 on step failure
	 */
	UFUNCTION()
	int RunUnbindObjTest()
	{
		OnSignal.AddUFunction(this, n"HandlerA");
		OnSignal.AddUFunction(this, n"HandlerB");

		OnSignal.Broadcast();
		if (CountA != 1)
		{
			return 10;
		}
		if (CountB != 1)
		{
			return 10;
		}

		OnSignal.UnbindObject(this);
		if (OnSignal.IsBound())
		{
			return 20;
		}

		OnSignal.Broadcast();
		if (CountA != 1)
		{
			return 30;
		}
		if (CountB != 1)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that RunUnbindObjTest returns success.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int Nominal()
	{
		return RunUnbindObjTest();
	}

	/**
	 * Observe that an untouched actor has both counts at 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs none
	 * @Return CountA + CountB
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return CountA + CountB;
	}

	/**
	 * Observe that running the UnbindObject test on this instance leaves Second at zero.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindObjectRemovesAllForTarget
	 * @Inputs a second actor
	 * @Return true when this A/B are 1/1 and Second is 0/0
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateUnbindObj Second)
	{
		if (Second is null)
		{
			throw("UnbindObjectRemovesAllForTarget setup: required Second is null");
		}
		int FirstResult = RunUnbindObjTest();

		if (FirstResult != 1)
		{
			return false;
		}
		if (CountA != 1)
		{
			return false;
		}
		if (CountB != 1)
		{
			return false;
		}
		if (Second.CountA != 0)
		{
			return false;
		}
		return Second.CountB == 0;
	}
}
