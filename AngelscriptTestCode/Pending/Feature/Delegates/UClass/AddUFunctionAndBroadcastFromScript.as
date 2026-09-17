/**
 * @version v1
 * @summary AddUFunction plus Broadcast accumulation. RunMulticastTest returns 1 after totals of 50 then 75. A second local stays at TotalReceived 0.
 * @topic Feature
 */
/**
 * @version root
 * @summary AddUFunction plus Broadcast accumulation. RunMulticastTest returns 1 after totals of 50 then 75. A second local stays at TotalReceived 0.
 * @topic Baseline
 */
/**
 * A multicast event that reports a score.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Score
 * @Return nothing when broadcast
 */
event void FOnScoreChanged(int32 Score);

UCLASS()
class ATestDelegateMulticastScript : AActor
{
	UPROPERTY()
	FOnScoreChanged OnScoreChanged;

	UPROPERTY()
	int TotalReceived = 0;

	/**
	 * Adds Score to TotalReceived.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param Score the payload
	 * @Inputs Score
	 * @Return nothing; TotalReceived gains Score
	 */
	UFUNCTION()
	void HandleScore(int32 Score)
	{
		TotalReceived += Score;
	}

	/**
	 * Binds HandleScore and broadcasts 50 then 25.
	 *
	 * @Covers Delegates.Broadcast
	 * @Inputs none
	 * @Return 1 on success, or 10/20/30 on a failed step
	 */
	UFUNCTION()
	int RunMulticastTest()
	{
		OnScoreChanged.AddUFunction(this, n"HandleScore");

		if (!OnScoreChanged.IsBound())
		{
			return 10;
		}

		OnScoreChanged.Broadcast(50);
		if (TotalReceived != 50)
		{
			return 20;
		}

		OnScoreChanged.Broadcast(25);
		if (TotalReceived != 75)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe the multicast accumulation path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs RunMulticastTest()
	 * @Return 1
	 */
	UFUNCTION()
	int MulticastPathReturnsOne()
	{
		return RunMulticastTest();
	}

	/**
	 * Observe the default TotalReceived.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs this
	 * @Return 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return TotalReceived;
	}

	/**
	 * Observe that running the path on this leaves Second at 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs RunMulticastTest on this
	 * @Return true when this totals 75 and Second stays 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateMulticastScript Second)
	{
		if (Second is null)
		{
			throw("AddUFunctionAndBroadcastFromScript setup: required Second is null");
		}
		int FirstResult = RunMulticastTest();
		if (FirstResult != 1)
		{
			return false;
		}
		if (TotalReceived != 75)
		{
			return false;
		}
		return Second.TotalReceived == 0;
	}
}
/** @end */
