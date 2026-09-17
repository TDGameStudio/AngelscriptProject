/**
 * @version v1
 * @summary A UserConstructionScript override computing the product of two editable values. C++ verifies the count and product after the first construction, then mutates the values and verifies them again.
 * @topic World
 */
/**
 * @version root
 * @summary A UserConstructionScript override computing the product of two editable values. C++ verifies the count and product after the first construction, then mutates the values and verifies them again.
 * @topic Baseline
 */
UCLASS()
class ATestActorConstructionScript : AActor
{
	UPROPERTY()
	int ConstructionCallCount = 0;

	UPROPERTY()
	int ValueA = 3;

	UPROPERTY()
	int ValueB = 4;

	UPROPERTY()
	int Product = 0;

	/**
	 * WorldStory: the construction script counts each run and recomputes the product.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.ConstructionScript
	 * @Inputs none
	 * @Return ConstructionCallCount 1 with Product 12, then 2 with Product 30 once the values change
	 */
	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCallCount += 1;
		Product = ValueA * ValueB;
	}

	/**
	 * Observe that a locally constructed actor has not run its construction script.
	 *
	 * @Kind Observe
	 * @Covers Actor.ConstructionScript
	 * @Inputs an actor whose construction script has not run
	 * @Return true when the count is 0 and the product is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ConstructionCallCount != 0)
		{
			return false;
		}
		return Product == 0;
	}

	/**
	 * Observe that the product follows the two editable values.
	 *
	 * @Kind Observe
	 * @Covers Actor.ConstructionScript
	 * @Inputs the declared values 3 and 4
	 * @Return ValueA * ValueB
	 */
	UFUNCTION()
	int DeclaredProduct()
	{
		return ValueA * ValueB;
	}
}
/** @end */
