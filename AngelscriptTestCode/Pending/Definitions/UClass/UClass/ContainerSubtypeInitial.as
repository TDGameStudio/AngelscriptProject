/**
 * @version v1
 * @summary TArray inner-type dependency initial source. Item.Value defaults to 1; live Container.Items is empty.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray inner-type dependency initial source. Item.Value defaults to 1; live Container.Items is empty.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationItem : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the Item.Value default.
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
	 * Observe writing Value to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Value set to 0
	 * @Return Value
	 * @Boundary zero
	 */
	UFUNCTION()
	int EmptyValueBoundary()
	{
		Value = 0;
		return Value;
	}

	/**
	 * Observe that writing this item leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other item expected to stay at 1
	 * @Inputs this.Value set to 9
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationItem Second)
	{
		if (Second is null)
		{
			throw("ContainerSubtypeInitial setup: required Second is null");
		}
		Value = 9;
		return Second.Value == 1;
	}
}

UCLASS()
class UClassGeneratorPropagationContainer : UObject
{
	UPROPERTY()
	TArray<UClassGeneratorPropagationItem> Items;

	/**
	 * Observe that live Items is empty.
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
/** @end */
