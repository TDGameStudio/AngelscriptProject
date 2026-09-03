/**
 * Unbind removes only HandlerA so HandlerB still receives the second Broadcast. C++
 * executes RunUnbindTest, so that name is part of the contract and is kept verbatim.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UnbindRemovesSpecificSubscriber
 * @Harness UClass
 * @Tag Feature.Delegates.UnbindRemovesSpecificSubscriber
 * @Provenance Theme: Feature.Delegates. WorldStory Unbind removes only HandlerA.
 * @Provenance C++: AngelscriptDelegateTests.cpp::UnbindRemovesSpecificSubscriber
 * @Provenance sha256 from theme-refs TS-FEAT-0206; lines 564-604.
 * @Provenance Oracle: RunUnbindTest returns 1 (A stays 1, B becomes 2). Extra: defaults 0;
 * @Provenance second local independent. FixtureIsolated.
 */

/**
 * Multicast pulse event used by the unbind test.
 *
 * @Kind Event
 * @Covers Delegates.UnbindRemovesSpecificSubscriber
 * @Inputs none
 * @Return void
 */
event void FOnPulse();

UCLASS()
class ATestDelegateUnbind : AActor
{
	UPROPERTY()
	FOnPulse OnPulse;

	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	/**
	 * Increment CountA when the multicast fires.
	 *
	 * @Kind Action
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
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
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
	 * @Inputs none
	 * @Return CountB increased by one
	 */
	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	/**
	 * Bind A and B, broadcast, Unbind A, broadcast again. A stays 1 and B becomes 2.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
	 * @Inputs none
	 * @Return 1 on success, 10/20/30 on step failure
	 */
	UFUNCTION()
	int RunUnbindTest()
	{
		OnPulse.AddUFunction(this, n"HandlerA");
		OnPulse.AddUFunction(this, n"HandlerB");

		OnPulse.Broadcast();
		if (CountA != 1)
		{
			return 10;
		}
		if (CountB != 1)
		{
			return 10;
		}

		OnPulse.Unbind(this, n"HandlerA");
		OnPulse.Broadcast();
		if (CountA != 1)
		{
			return 20;
		}
		if (CountB != 2)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that RunUnbindTest returns success.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int Nominal()
	{
		return RunUnbindTest();
	}

	/**
	 * Observe that an untouched actor has both counts at 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
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
	 * Observe that running the unbind test on this instance leaves Second at zero.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UnbindRemovesSpecificSubscriber
	 * @Inputs a second actor
	 * @Return true when this A/B are 1/2 and Second is 0/0
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateUnbind Second)
	{
		if (Second is null)
		{
			throw("UnbindRemovesSpecificSubscriber setup: required Second is null");
		}
		int FirstResult = RunUnbindTest();

		if (FirstResult != 1)
		{
			return false;
		}
		if (CountA != 1)
		{
			return false;
		}
		if (CountB != 2)
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
