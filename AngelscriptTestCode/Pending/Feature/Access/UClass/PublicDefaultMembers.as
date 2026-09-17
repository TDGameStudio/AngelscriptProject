/**
 * @version v1
 * @summary Public members are the default on a script actor. PublicVar starts at 0 and PublicFunc is callable without changing that default. Two instances stay independent after one of them is written.
 * @topic Feature
 */
/**
 * @version root
 * @summary Public members are the default on a script actor. PublicVar starts at 0 and PublicFunc is callable without changing that default. Two instances stay independent after one of them is written.
 * @topic Baseline
 */
class AActorPubDefault : AActor
{
	int PublicVar = 0;

	/**
	 * An empty public method whose only job is to complete.
	 *
	 * @Covers Access.PublicDefaultMembers
	 * @Inputs none
	 * @Return nothing
	 */
	void PublicFunc()
	{
	}

	/**
	 * Observe that an untouched instance holds the public default of 0.
	 *
	 * @Kind Observe
	 * @Covers Access.PublicDefaultMembers
	 * @Inputs none
	 * @Return 0, the default of PublicVar
	 * @Boundary empty default
	 */
	UFUNCTION()
	int PublicDefaultZero()
	{
		return PublicVar;
	}

	/**
	 * Observe that calling the public method leaves the default unchanged.
	 *
	 * @Kind Observe
	 * @Covers Access.PublicDefaultMembers
	 * @Inputs PublicFunc()
	 * @Return 0 after the call
	 */
	UFUNCTION()
	int PublicFuncLeavesDefault()
	{
		PublicFunc();
		return PublicVar;
	}

	/**
	 * Observe that writing one instance leaves another instance at the default.
	 *
	 * @Kind Observe
	 * @Covers Access.PublicDefaultMembers
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other reads 9
	 * @Param Second the other actor, written to 9
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorPubDefault Second)
	{
		if (Second is null)
		{
			throw("PublicDefaultMembers setup: required Second is null");
		}
		Second.PublicVar = 9;
		if (PublicVar != 0)
		{
			return false;
		}
		return Second.PublicVar == 9;
	}
}
/** @end */
