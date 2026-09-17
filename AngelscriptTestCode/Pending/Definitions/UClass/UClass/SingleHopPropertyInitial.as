/**
 * @version v1
 * @summary Single-hop full-reload initial source. Provider.Value defaults to 1; Consumer.Provider is null on a live consumer.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Single-hop full-reload initial source. Provider.Value defaults to 1; Consumer.Provider is null on a live consumer.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationProvider : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the Provider.Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed provider
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
	 * Observe that writing this provider leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other provider expected to stay at 1
	 * @Inputs this.Value set to 9
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationProvider Second)
	{
		if (Second is null)
		{
			throw("SingleHopPropertyInitial setup: required Second is null");
		}
		Value = 9;
		return Second.Value == 1;
	}
}

UCLASS()
class UClassGeneratorPropagationConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationProvider Provider;

	/**
	 * Observe that a live consumer's Provider is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed consumer
	 * @Return true when Provider is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool ProviderDefaultIsNull()
	{
		return Provider == nullptr;
	}
}
/** @end */
