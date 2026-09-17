/**
 * @version v1
 * @summary The provider half of the async-load comparison: a module exporting a value and a multiplier. The same module must preprocess identically when loaded synchronously and when loaded asynchronously.
 * @topic Language
 */
/**
 * @version root
 * @summary The provider half of the async-load comparison: a module exporting a value and a multiplier. The same module must preprocess identically when loaded synchronously and when loaded asynchronously.
 * @topic Baseline
 */
const int ProviderMultiplier = 3;

namespace PreprocessorTest
{
	/**
	 * The value exported by this async provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 7
	 */
	int ProvideValue()
	{
		return 7;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ProvideValue()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool AsyncProviderReportsValue()
	{
		return ProvideValue() == 7;
	}

	/**
	 * Observe the multiplier's default value.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs the module-level const ProviderMultiplier
	 * @Return true when the multiplier is 3
	 * @Boundary default const
	 */
	UFUNCTION()
	bool AsyncProviderMultiplierDefault()
	{
		return ProviderMultiplier == 3;
	}

	/**
	 * Observe that value and multiplier combine to 21.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ProvideValue() and ProviderMultiplier
	 * @Return true when their product is 21
	 * @Boundary product
	 */
	UFUNCTION()
	bool AsyncProviderProductBoundary()
	{
		return ProvideValue() * ProviderMultiplier == 21;
	}
}
/** @end */
