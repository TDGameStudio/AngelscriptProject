/**
 * @version v1
 * @summary Multi-hop chain reload source. Leaf.Value stays 1; AddedValue defaults to 2; Middle.Leaf and Root.Middle still null on live owners.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Multi-hop chain reload source. Leaf.Value stays 1; AddedValue defaults to 2; Middle.Leaf and Root.Middle still null on live owners.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationLeaf : UObject
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
	 * @Inputs a freshly constructed leaf
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
	 * @Inputs a freshly constructed leaf
	 * @Return AddedValue
	 */
	UFUNCTION()
	int AddedValueDefault()
	{
		return AddedValue;
	}

	/**
	 * Observe writing AddedValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs AddedValue set to 0
	 * @Return AddedValue
	 * @Boundary zero
	 */
	UFUNCTION()
	int AddedValueEmptyBoundary()
	{
		AddedValue = 0;
		return AddedValue;
	}

	/**
	 * Observe that writing this leaf leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other leaf expected to stay at 2
	 * @Inputs this.AddedValue set to 9
	 * @Return true when Second.AddedValue is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationLeaf Second)
	{
		if (Second is null)
		{
			throw("MultiHopPropertyReload setup: required Second is null");
		}
		AddedValue = 9;
		return Second.AddedValue == 2;
	}
}

UCLASS()
class UClassGeneratorPropagationMiddle : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationLeaf Leaf;
}

UCLASS()
class UClassGeneratorPropagationRoot : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationMiddle Middle;
}
/** @end */
