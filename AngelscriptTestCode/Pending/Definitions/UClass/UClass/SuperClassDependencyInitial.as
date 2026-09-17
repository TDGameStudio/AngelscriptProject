/**
 * @version v1
 * @summary Super-class dependency initial source. ReadValue returns Value (default 1).
 * @topic Definitions
 */
/**
 * @version root
 * @summary Super-class dependency initial source. ReadValue returns Value (default 1).
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationBase : UObject
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UClassGeneratorPropagationChild : UClassGeneratorPropagationBase
{
	/**
	 * Observe ReadValue: the initial body returns Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Value
	 * @Return Value
	 */
	UFUNCTION()
	int ReadValue()
	{
		return Value;
	}

	/**
	 * Observe the ReadValue default.
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
	 * Observe ReadValue after writing Value to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Value set to 0
	 * @Return ReadValue()
	 * @Boundary zero
	 */
	UFUNCTION()
	int EmptyValueBoundary()
	{
		Value = 0;
		return ReadValue();
	}

	/**
	 * Observe that a nullptr child handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs UClassGeneratorPropagationChild Child = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UClassGeneratorPropagationChild Child = nullptr;
		return Child == nullptr;
	}

	/**
	 * Observe that writing this child leaves another ReadValue at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other child expected to stay at 1
	 * @Inputs this.Value set to 9
	 * @Return true when Second.ReadValue() is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationChild Second)
	{
		if (Second is null)
		{
			throw("SuperClassDependencyInitial setup: required Second is null");
		}
		Value = 9;
		return Second.ReadValue() == 1;
	}
}
/** @end */
