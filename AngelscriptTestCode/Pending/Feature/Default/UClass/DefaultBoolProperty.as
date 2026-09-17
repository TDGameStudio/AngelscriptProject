/**
 * @version v1
 * @summary A default statement overrides a bool UPROPERTY initializer. The CDO value is false after `default bEnabled = false`, even though the inline initializer is true. Instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement overrides a bool UPROPERTY initializer. The CDO value is false after `default bEnabled = false`, even though the inline initializer is true. Instances stay independent.
 * @topic Baseline
 */
class AAttrBoolActor : AActor
{
	UPROPERTY()
	bool bEnabled = true;

	default bEnabled = false;

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.BoolProperty
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		AAttrBoolActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the default statement wins over the inline initializer.
	 *
	 * @Kind Observe
	 * @Covers Default.BoolProperty
	 * @Inputs a freshly constructed actor
	 * @Return true when bEnabled is false
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return !bEnabled;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.BoolProperty
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this is enabled and the other stays false
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(AAttrBoolActor Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultBoolProperty setup: required Second is null");
		}
		bEnabled = true;
		return !Second.bEnabled;
	}
}
/** @end */
