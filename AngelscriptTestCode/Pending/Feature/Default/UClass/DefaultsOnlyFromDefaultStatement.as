/**
 * @version v1
 * @summary A method marked `defaults` may be called from a default statement. The CDO Value becomes 7 after `default Value = BuildDefaultValue()`. Instances stay independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary A method marked `defaults` may be called from a default statement. The CDO Value becomes 7 after `default Value = BuildDefaultValue()`. Instances stay independent.
 * @topic Baseline
 */
UCLASS()
class UDefaultsOnlyOkTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * A defaults-only helper that writes Value to 7 and returns it.
	 *
	 * @Covers Default.DefaultsOnlyFromDefaultStatement
	 * @Inputs none
	 * @Return 7 after writing Value
	 */
	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	default Value = BuildDefaultValue();

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsOnlyFromDefaultStatement
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UDefaultsOnlyOkTarget Target;
		return Target == nullptr;
	}

	/**
	 * Observe that the default statement applied the helper result.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsOnlyFromDefaultStatement
	 * @Inputs a freshly constructed object
	 * @Return 7
	 */
	UFUNCTION()
	int ValueAfterDefault()
	{
		return Value;
	}

	/**
	 * Observe that writing this object leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsOnlyFromDefaultStatement
	 * @Inputs this object written to, compared against a second object
	 * @Return true when the other still holds 7
	 * @Param Second the other object
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(UDefaultsOnlyOkTarget Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultsOnlyFromDefaultStatement setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 7;
	}
}
/** @end */
