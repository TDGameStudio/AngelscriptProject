/**
 * Super-class dependency reload source. ReadValue returns Value + AddedValue
 * (1 + 2 == 3). The child inherits AddedValue from the reloaded base.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.SuperClassDependencyReload
 * @Harness UClass
 * @Tag Definitions.UClass.SuperClassDependencyReload
 * @Provenance Theme: Definitions.UClass. Reload version pair 02 (base layout change). Positive super-class dependency.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SuperClassDependencyRetargetsChildToReloadedBase ReloadSource.
 * @Provenance Oracle: ReadValue returns Value + AddedValue (1 + 2 == 3). Child inherits AddedValue from the reloaded base.
 * @Provenance Retained: Base/Child types, Value, ReadValue name. Replaced: AddedValue = 2; ReadValue body uses AddedValue.
 * @Provenance Extra: both zeros is the empty boundary; mutating one child does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
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
