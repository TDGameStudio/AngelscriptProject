/**
 * @version v1
 * @summary A plain member setter plus a const getter. SetStoredValue(123) then GetStoredValue returns 123. The default StoredValue is 5, SetStoredValue(0) writes 0, and a second instance stays at 5.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A plain member setter plus a const getter. SetStoredValue(123) then GetStoredValue returns 123. The default StoredValue is 5, SetStoredValue(0) writes 0, and a second instance stays at 5.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionBasicActor : AActor
{
	UPROPERTY()
	int StoredValue = 5;

	/**
	 * Write StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value New StoredValue
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void SetStoredValue(int Value)
	{
		StoredValue = Value;
	}

	/**
	 * Read StoredValue through a const UFUNCTION.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION()
	int GetStoredValue() const
	{
		return StoredValue;
	}

	/**
	 * Observe SetStoredValue(123) then GetStoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs SetStoredValue(123)
	 * @Return 123
	 */
	UFUNCTION()
	int SetThenGetStoredValue()
	{
		SetStoredValue(123);
		return GetStoredValue();
	}

	/**
	 * Observe the default StoredValue of 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return 5
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultStoredValueIsFive()
	{
		return GetStoredValue();
	}

	/**
	 * Observe SetStoredValue at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs SetStoredValue(0)
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ZeroStoredValueBoundary()
	{
		SetStoredValue(0);
		return GetStoredValue();
	}

	/**
	 * Observe that writing this instance leaves another at 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at the default
	 * @Inputs SetStoredValue(123) on this compared against Other
	 * @Return true when this is 123 and Other stays 5
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool StoredValueIsIndependentAcrossInstances(ACoverageUFunctionBasicActor Other)
	{
		SetStoredValue(123);
		if (GetStoredValue() != 123)
		{
			return false;
		}
		return Other.GetStoredValue() == 5;
	}
}
/** @end */
