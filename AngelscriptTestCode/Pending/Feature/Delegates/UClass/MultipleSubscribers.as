/**
 * @version v1
 * @summary Two multicast subscribers both fire on each Broadcast. C++ executes RunMultiSubTest, so that name is part of the contract and is kept verbatim.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two multicast subscribers both fire on each Broadcast. C++ executes RunMultiSubTest, so that name is part of the contract and is kept verbatim.
 * @topic Baseline
 */
/**
 * Multicast tick event used by the multi-subscriber test.
 *
 * @Kind Event
 * @Covers Delegates.MultipleSubscribers
 * @Inputs none
 * @Return void
 */
event void FOnTick();

UCLASS()
class ATestDelegateMultiSub : AActor
{
	UPROPERTY()
	FOnTick OnTick;

	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	/**
	 * Increment CountA when the multicast fires.
	 *
	 * @Kind Action
	 * @Covers Delegates.MultipleSubscribers
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
	 * @Covers Delegates.MultipleSubscribers
	 * @Inputs none
	 * @Return CountB increased by one
	 */
	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	/**
	 * Bind two handlers and broadcast twice. Counts must be 1 then 2.
	 *
	 * @Kind Observe
	 * @Covers Delegates.MultipleSubscribers
	 * @Inputs none
	 * @Return 1 on success, 10/20/30/40 on step failure
	 */
	UFUNCTION()
	int RunMultiSubTest()
	{
		OnTick.AddUFunction(this, n"HandlerA");
		OnTick.AddUFunction(this, n"HandlerB");

		OnTick.Broadcast();

		if (CountA != 1)
		{
			return 10;
		}
		if (CountB != 1)
		{
			return 20;
		}

		OnTick.Broadcast();
		if (CountA != 2)
		{
			return 30;
		}
		if (CountB != 2)
		{
			return 40;
		}

		return 1;
	}

	/**
	 * Observe that RunMultiSubTest returns success.
	 *
	 * @Kind Observe
	 * @Covers Delegates.MultipleSubscribers
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int Nominal()
	{
		return RunMultiSubTest();
	}

	/**
	 * Observe that an untouched actor has both counts at 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.MultipleSubscribers
	 * @Inputs none
	 * @Return CountA + CountB
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return CountA + CountB;
	}
}
/** @end */
