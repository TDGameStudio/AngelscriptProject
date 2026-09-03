/**
 * The consumer half of the async-load comparison: an actor that imports the
 * async provider and initialises a property from the imported multiplier. The
 * same module must preprocess identically whether loaded synchronously or
 * asynchronously.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.AsyncLoadConsumerActor
 * @Harness UClass
 * @Tag Language.Preprocessor.AsyncLoadConsumerActor
 * @Provenance C++: AngelscriptPreprocessorAsyncTests.cpp::AsyncMatchesSynchronousPreprocess
 * @Provenance Consumer.as; lines 329-340; both sync and async preprocess succeed.
 * @Provenance sha256=c0549203ce33558f6c7cf1aceac04b8d1fc8814aee85c1c21092db5d56d923e8.
 * @Provenance Oracle: UseProvider() == 21; StoredValue default is ProviderMultiplier (3).
 * @Provenance Extra: default StoredValue is 3; UseProvider does not mutate StoredValue.
 * @Provenance FixtureIsolated. Keep UPROPERTY name StoredValue.
 */

import Tests.Preprocessor.AsyncLoad.Provider;

class AAsyncLoadMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int StoredValue = ProviderMultiplier;

	/**
	 * Observe that the imported multiplier supplied the property default.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs a freshly constructed actor
	 * @Return true when StoredValue is 3
	 * @Boundary imported default
	 */
	UFUNCTION()
	bool StoredValueDefaultsToImportedMultiplier()
	{
		return StoredValue == 3;
	}

	/**
	 * Observe that consuming the provider leaves the property untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseProvider() then StoredValue
	 * @Return true when the product is 21 and StoredValue stays 3
	 * @Boundary no mutation
	 */
	UFUNCTION()
	bool ConsumingProviderLeavesStoredValue()
	{
		int Product = UseProvider();

		if (Product != 21)
		{
			return false;
		}

		return StoredValue == 3;
	}
}

/**
 * Multiplies the imported value by the imported multiplier.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported ProvideValue and ProviderMultiplier
 * @Return 21
 */
int UseProvider()
{
	return ProvideValue() * ProviderMultiplier;
}
