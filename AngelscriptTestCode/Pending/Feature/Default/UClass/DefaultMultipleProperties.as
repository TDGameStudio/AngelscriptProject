/**
 * @version v1
 * @summary Multiple default statements on one class. X becomes 10 and Y becomes 20, overriding both inline zeros. Instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multiple default statements on one class. X becomes 10 and Y becomes 20, overriding both inline zeros. Instances stay independent.
 * @topic Baseline
 */
class AAttrMultiActor : AActor
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	default X = 10;
	default Y = 20;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.MultipleProperties
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrMultiActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the default assigned to X.
	 *
	 * @Kind Observe
	 * @Covers Default.MultipleProperties
	 * @Inputs a freshly constructed actor
	 * @Return 10
	 */
	UFUNCTION()
	int DefaultX()
	{
		return X;
	}

	/**
	 * Observe the default assigned to Y.
	 *
	 * @Kind Observe
	 * @Covers Default.MultipleProperties
	 * @Inputs a freshly constructed actor
	 * @Return 20
	 */
	UFUNCTION()
	int DefaultY()
	{
		return Y;
	}

	/**
	 * Observe the zero boundary of both properties.
	 *
	 * @Kind Observe
	 * @Covers Default.MultipleProperties
	 * @Inputs X and Y set to 0
	 * @Return true when both are 0
	 * @Boundary zeros
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		X = 0;
		Y = 0;
		if (X != 0)
		{
			return false;
		}
		return Y == 0;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.MultipleProperties
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds 10 and 20
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrMultiActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultMultipleProperties setup: required Second is null");
		}
		X = 0;
		Y = 0;
		if (Second.X != 10)
		{
			return false;
		}
		return Second.Y == 20;
	}
}
/** @end */
