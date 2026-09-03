/**
 * The provider half of the async-load comparison: a module exporting a value and
 * a multiplier. The same module must preprocess identically when loaded
 * synchronously and when loaded asynchronously.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.AsyncProviderModule
 * @Harness Function
 * @Tag Language.Preprocessor.AsyncProviderModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorAsyncTests.cpp::AsyncMatchesSynchronousPreprocess
 * @Provenance Provider.as; lines 318-324;
 * @Provenance sha256=676298873b957c62de25b0838f6e865697e5dfa21a1aba12352f25d17080e123.
 * @Provenance Oracle: ProvideValue() == 7; ProviderMultiplier == 3.
 * @Provenance Extra: 7 * 3 == 21 is the consumer product; multiplier default is 3.
 * @Provenance DefaultSafe. C++ padding after this body is load-size only, not source.
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
