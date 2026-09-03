/**
 * Single-hop full-reload source. Provider.Value stays 1; AddedValue defaults
 * to 2; Consumer.Provider is still null on a live consumer.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.SingleHopPropertyReload
 * @Harness UClass
 * @Tag Definitions.UClass.SingleHopPropertyReload
 * @Provenance Theme: Definitions.UClass. Reload version pair 02 (layout change). Positive full-reload source.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SingleHopPropertyDependencyRetargetsAfterProviderFullReload ReloadSource.
 * @Provenance Oracle: Provider.Value stays 1; AddedValue defaults to 2; Consumer.Provider still null on a live consumer.
 * @Provenance Retained: Provider/Consumer types, Value, Provider property. Replaced: AddedValue = 2.
 * @Provenance Extra: AddedValue 0 is the empty boundary; mutating one provider does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorPropagationProvider : UObject
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
	 * @Inputs a freshly constructed provider
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
	 * @Inputs a freshly constructed provider
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
	 * Observe that writing this provider leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other provider expected to stay at 2
	 * @Inputs this.AddedValue set to 9
	 * @Return true when Second.AddedValue is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationProvider Second)
	{
		if (Second is null)
		{
			throw("SingleHopPropertyReload setup: required Second is null");
		}
		AddedValue = 9;
		return Second.AddedValue == 2;
	}
}

UCLASS()
class UClassGeneratorPropagationConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationProvider Provider;
}
