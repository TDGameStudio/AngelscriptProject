/**
 * @version v1
 * @summary A class may read and write its own private field through public accessors. GetX starts at 0; SetX stores the given value, including a negative boundary. Two instances stay independent after one of them is written.
 * @topic Feature
 */
/**
 * @version root
 * @summary A class may read and write its own private field through public accessors. GetX starts at 0; SetX stores the given value, including a negative boundary. Two instances stay independent after one of them is written.
 * @topic Baseline
 */
class AActorSelfPriv : AActor
{
	private int X = 0;

	/**
	 * Write the private field from inside the declaring class.
	 *
	 * @Covers Access.SelfPrivateReadWrite
	 * @Inputs the value to store
	 * @Return nothing; X receives Val
	 * @Param Val the value to store
	 */
	void SetX(int Val)
	{
		X = Val;
	}

	/**
	 * Read the private field from inside the declaring class.
	 *
	 * @Covers Access.SelfPrivateReadWrite
	 * @Inputs none
	 * @Return the current X
	 */
	int GetX()
	{
		return X;
	}

	/**
	 * Observe that an untouched instance holds the private default of 0.
	 *
	 * @Kind Observe
	 * @Covers Access.SelfPrivateReadWrite
	 * @Inputs none
	 * @Return 0, the default of X
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return GetX();
	}

	/**
	 * Observe that SetX stores a negative value.
	 *
	 * @Kind Observe
	 * @Covers Access.SelfPrivateReadWrite
	 * @Inputs SetX(-1)
	 * @Return -1
	 * @Boundary negative
	 */
	UFUNCTION()
	int NegativeBoundary()
	{
		SetX(-1);
		return GetX();
	}

	/**
	 * Observe that writing one instance leaves another instance at the default.
	 *
	 * @Kind Observe
	 * @Covers Access.SelfPrivateReadWrite
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other reads 8
	 * @Param Second the other actor, written to 8
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorSelfPriv Second)
	{
		if (Second is null)
		{
			throw("SelfPrivateReadWrite setup: required Second is null");
		}
		Second.SetX(8);
		if (GetX() != 0)
		{
			return false;
		}
		return Second.GetX() == 8;
	}
}
/** @end */
