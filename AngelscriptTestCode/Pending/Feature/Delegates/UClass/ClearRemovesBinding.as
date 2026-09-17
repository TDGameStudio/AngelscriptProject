/**
 * @version v1
 * @summary BindUFunction, Execute, then Clear. RunClearTest returns 1 when the handler ran once and the delegate is unbound afterwards. A second local stays at CallCount 0.
 * @topic Feature
 */
/**
 * @version root
 * @summary BindUFunction, Execute, then Clear. RunClearTest returns 1 when the handler ran once and the delegate is unbound afterwards. A second local stays at CallCount 0.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Clear
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FSimpleNotify();

UCLASS()
class ATestDelegateClear : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	UPROPERTY()
	int CallCount = 0;

	/**
	 * Increments CallCount.
	 *
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; CallCount gains 1
	 */
	UFUNCTION()
	void HandleNotify()
	{
		CallCount += 1;
	}

	/**
	 * Binds, executes once, then clears.
	 *
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return 1 on success, or 10/20/30 on a failed step
	 */
	UFUNCTION()
	int RunClearTest()
	{
		OnNotify.BindUFunction(this, n"HandleNotify");
		if (!OnNotify.IsBound())
		{
			return 10;
		}

		OnNotify.Execute();
		if (CallCount != 1)
		{
			return 20;
		}

		OnNotify.Clear();
		if (OnNotify.IsBound())
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe the clear path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs RunClearTest()
	 * @Return 1
	 */
	UFUNCTION()
	int ClearPathReturnsOne()
	{
		return RunClearTest();
	}

	/**
	 * Observe the default CallCount.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs this
	 * @Return 0
	 * @Boundary default CallCount
	 */
	UFUNCTION()
	int DefaultCallCount()
	{
		return CallCount;
	}

	/**
	 * Observe that running the clear path on this leaves Second untouched.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs RunClearTest on this
	 * @Return true when this counted 1 and Second stays at 0 unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateClear Second)
	{
		if (Second is null)
		{
			throw("ClearRemovesBinding setup: required Second is null");
		}
		int FirstResult = RunClearTest();
		if (FirstResult != 1)
		{
			return false;
		}
		if (CallCount != 1)
		{
			return false;
		}
		if (Second.CallCount != 0)
		{
			return false;
		}
		return !Second.OnNotify.IsBound();
	}
}
/** @end */
