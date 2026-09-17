/**
 * @version v1
 * @summary Super-class dependency reload source. ReadValue returns Value + AddedValue (1 + 2 == 3). The child inherits AddedValue from the reloaded base.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Super-class dependency reload source. ReadValue returns Value + AddedValue (1 + 2 == 3). The child inherits AddedValue from the reloaded base.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationBase : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationChild : UClassGeneratorPropagationBase
{
	/**
	 * Observe ReadValue: the reloaded body returns Value + AddedValue.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Value and AddedValue
	 * @Return Value + AddedValue
	 */
	UFUNCTION()
	int ReadValue()
	{
		return Value + AddedValue;
	}

	/**
	 * Observe the ReadValue default after reload.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed child
	 * @Return ReadValue()
	 */
	UFUNCTION()
	int ReadValueDefault()
	{
		return ReadValue();
	}

	/**
	 * Observe ReadValue after writing both values to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Value and AddedValue set to 0
	 * @Return ReadValue()
	 * @Boundary both zeros
	 */
	UFUNCTION()
	int EmptyValuesBoundary()
	{
		Value = 0;
		AddedValue = 0;
		return ReadValue();
	}

	/**
	 * Observe the inherited AddedValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed child
	 * @Return AddedValue
	 */
	UFUNCTION()
	int AddedValueDefault()
	{
		return AddedValue;
	}

	/**
	 * Observe that writing this child leaves another ReadValue at 3.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other child expected to stay at 3
	 * @Inputs this.Value and AddedValue set to 9
	 * @Return true when Second.ReadValue() is 3
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationChild Second)
	{
		if (Second is null)
		{
			throw("SuperClassDependencyReload setup: required Second is null");
		}
		Value = 9;
		AddedValue = 9;
		return Second.ReadValue() == 3;
	}
}
/** @end */
