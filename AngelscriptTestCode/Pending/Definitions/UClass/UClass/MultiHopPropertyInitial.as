/**
 * @version v1
 * @summary Multi-hop chain initial source. Leaf.Value defaults to 1; Middle.Leaf and Root.Middle are null on live owners.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Multi-hop chain initial source. Leaf.Value defaults to 1; Middle.Leaf and Root.Middle are null on live owners.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationLeaf : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the Leaf.Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed leaf
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
	 * Observe that writing this leaf leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other leaf expected to stay at 1
	 * @Inputs this.Value set to 9
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationLeaf Second)
	{
		if (Second is null)
		{
			throw("MultiHopPropertyInitial setup: required Second is null");
		}
		Value = 9;
		return Second.Value == 1;
	}
}

UCLASS()
class UClassGeneratorPropagationMiddle : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationLeaf Leaf;

	/**
	 * Observe that live Middle.Leaf is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed middle
	 * @Return true when Leaf is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool LeafDefaultIsNull()
	{
		return Leaf == nullptr;
	}
}

UCLASS()
class UClassGeneratorPropagationRoot : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationMiddle Middle;
}
/** @end */
