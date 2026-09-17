/**
 * @version v1
 * @summary Multicast Clear drops every subscriber so a later Broadcast does not increment Count. C++ executes RunClearTest, so that name is part of the contract and is kept verbatim.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multicast Clear drops every subscriber so a later Broadcast does not increment Count. C++ executes RunClearTest, so that name is part of the contract and is kept verbatim.
 * @topic Baseline
 */
/**
 * Multicast ping event used by the clear test.
 *
 * @Kind Event
 * @Covers Delegates.ClearRemovesAllSubscribers
 * @Inputs none
 * @Return void
 */
event void FOnPing();

UCLASS()
class ATestDelegateMCClear : AActor
{
	UPROPERTY()
	FOnPing OnPing;

	UPROPERTY()
	int Count = 0;

	/**
	 * Increment Count when the multicast fires.
	 *
	 * @Kind Action
	 * @Covers Delegates.ClearRemovesAllSubscribers
	 * @Inputs none
	 * @Return Count increased by one
	 */
	UFUNCTION()
	void Handler()
	{
		Count += 1;
	}

	/**
	 * Bind, broadcast, Clear, then broadcast again. Count must stay 1 after Clear.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ClearRemovesAllSubscribers
	 * @Inputs none
	 * @Return 1 on success, 10/20/30 on step failure
	 */
	UFUNCTION()
	int RunClearTest()
	{
		OnPing.AddUFunction(this, n"Handler");
		OnPing.Broadcast();
		if (Count != 1)
		{
			return 10;
		}

		OnPing.Clear();
		if (OnPing.IsBound())
		{
			return 20;
		}

		OnPing.Broadcast();
		if (Count != 1)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that RunClearTest returns success.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ClearRemovesAllSubscribers
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int Nominal()
	{
		return RunClearTest();
	}

	/**
	 * Observe that an untouched actor has Count 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ClearRemovesAllSubscribers
	 * @Inputs none
	 * @Return Count
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return Count;
	}

	/**
	 * Observe that running the clear test on this instance leaves Second untouched.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ClearRemovesAllSubscribers
	 * @Inputs a second actor
	 * @Return true when this Count is 1 and Second Count is 0 and Second is unbound
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateMCClear Second)
	{
		if (Second is null)
		{
			throw("ClearRemovesAllSubscribers setup: required Second is null");
		}
		int FirstResult = RunClearTest();

		if (FirstResult != 1)
		{
			return false;
		}
		if (Count != 1)
		{
			return false;
		}
		if (Second.Count != 0)
		{
			return false;
		}
		return !Second.OnPing.IsBound();
	}
}
/** @end */
