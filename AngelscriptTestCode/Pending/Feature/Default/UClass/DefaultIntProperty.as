/**
 * @version v1
 * @summary A default statement overrides an int UPROPERTY initializer. The CDO value is 100 after `default Health = 100`, even though the inline initializer is 0. Instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement overrides an int UPROPERTY initializer. The CDO value is 100 after `default Health = 100`, even though the inline initializer is 0. Instances stay independent.
 * @topic Baseline
 */
class AAttrIntActor : AActor
{
	UPROPERTY()
	int Health = 0;

	default Health = 100;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.IntProperty
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrIntActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the default statement wins over the inline initializer.
	 *
	 * @Kind Observe
	 * @Covers Default.IntProperty
	 * @Inputs a freshly constructed actor
	 * @Return 100
	 */
	UFUNCTION()
	int DefaultHundred()
	{
		return Health;
	}

	/**
	 * Observe the zero boundary of Health.
	 *
	 * @Kind Observe
	 * @Covers Default.IntProperty
	 * @Inputs Health set to 0
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		Health = 0;
		return Health;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.IntProperty
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds 100
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrIntActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultIntProperty setup: required Second is null");
		}
		Health = 0;
		return Second.Health == 100;
	}
}
/** @end */
