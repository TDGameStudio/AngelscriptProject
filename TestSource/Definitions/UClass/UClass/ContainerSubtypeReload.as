/**
 * TArray inner-type dependency reload source. Item.Value stays 1; AddedValue
 * defaults to 2; live Container.Items is still empty.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ContainerSubtypeReload
 * @Harness UClass
 * @Tag Definitions.UClass.ContainerSubtypeReload
 * @Provenance Theme: Definitions.UClass. Reload version pair 02 (item layout change). Positive TArray inner-type dependency.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::ContainerSubtypeDependencyRetargetsArrayInnerType ReloadSource.
 * @Provenance Oracle: Item.Value stays 1; AddedValue defaults to 2; live Container.Items is still empty.
 * @Provenance Retained: Item/Container types, Value, Items. Replaced: Item.AddedValue = 2.
 * @Provenance Extra: empty Items is the default vector; mutating AddedValue on one item does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorPropagationItem : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;

	/**
	 * Observe that Value stays 1 after reload.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed item
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe the AddedValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed item
	 * @Return AddedValue
	 */
	UFUNCTION()
	int AddedValueDefault()
	{
		return AddedValue;
	}

	/**
	 * Observe that writing AddedValue leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other item expected to stay at 2
	 * @Inputs this.AddedValue set to 0
	 * @Return true when Second.AddedValue is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationItem Second)
	{
		if (Second is null)
		{
			throw("ContainerSubtypeReload setup: required Second is null");
		}
		AddedValue = 0;
		return Second.AddedValue == 2;
	}
}

UCLASS()
class UClassGeneratorPropagationContainer : UObject
{
	UPROPERTY()
	TArray<UClassGeneratorPropagationItem> Items;

	/**
	 * Observe that live Items is still empty.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed container
	 * @Return Items.Num()
	 * @Boundary empty default
	 */
	UFUNCTION()
	int ItemsEmptyDefault()
	{
		return Items.Num();
	}
}
