/**
 * Default-argument metadata round-trips so omitting Value and Extra uses 21 and 7.
 * Entry sums 14 with those defaults to 42. The observers cover the nominal sum,
 * explicit zeros and a repeated call.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.FunctionDefaultMetadataRoundTrip
 * @Harness Function
 * @Tag Definitions.Meta.FunctionDefaultMetadataRoundTrip
 * @Namespace MetaTest
 * @Provenance Theme: Definitions.Meta. Positive default-argument metadata round-trip.
 * @Provenance C++: AngelscriptCompilerFunctionDefaultTests.cpp::FunctionDefaultMetadataRoundTrip
 * @Provenance Oracle: Entry() uses omitted defaults Value=21 Extra=7 so 14+21+7 == 42.
 * @Provenance Extra: explicit zeros are a boundary; repeating Entry is stable.
 * @Provenance DefaultSafe.
 */

namespace MetaTest
{
	/**
	 * Sum a required argument with two defaulted extras.
	 *
	 * @Kind Observe
	 * @Covers Meta.FunctionDefaultMetadataRoundTrip
	 * @Inputs a required addend plus optional Value and Extra
	 * @Return Required + Value + Extra
	 * @Param Required the required addend
	 * @Param Value the first defaulted addend
	 * @Param Extra the second defaulted addend
	 */
	UFUNCTION()
	int SumWithDefaults(int Required, int Value = 21, int Extra = 7)
	{
		return Required + Value + Extra;
	}

	/**
	 * Call SumWithDefaults with only the required argument so defaults apply.
	 *
	 * @Kind Observe
	 * @Covers Meta.FunctionDefaultMetadataRoundTrip
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return SumWithDefaults(14);
	}

	/**
	 * Observe that omitted defaults and explicit matching defaults both yield 42.
	 *
	 * @Kind Observe
	 * @Covers Meta.FunctionDefaultMetadataRoundTrip
	 * @Inputs none
	 * @Return true when both sums are 42
	 */
	UFUNCTION()
	bool FunctionDefaultNominal()
	{
		if (Entry() != 42)
		{
			return false;
		}
		return SumWithDefaults(14, 21, 7) == 42;
	}

	/**
	 * Observe that explicit zeros override the defaults.
	 *
	 * @Kind Observe
	 * @Covers Meta.FunctionDefaultMetadataRoundTrip
	 * @Inputs none
	 * @Return true when the sum is 14
	 * @Boundary explicit zeros
	 */
	UFUNCTION()
	bool ExplicitZerosBoundary()
	{
		return SumWithDefaults(14, 0, 0) == 14;
	}

	/**
	 * Observe that repeating Entry is stable.
	 *
	 * @Kind Observe
	 * @Covers Meta.FunctionDefaultMetadataRoundTrip
	 * @Inputs none
	 * @Return true when both calls agree
	 * @Boundary repeated call
	 */
	UFUNCTION()
	bool RepeatCall()
	{
		return Entry() == Entry();
	}
}
