/**
 * @version v1
 * @summary The provider half of a conditional import: a module exporting a single value, imported only when the importing module defines USESHARED.
 * @topic Language
 */
/**
 * @version root
 * @summary The provider half of a conditional import: a module exporting a single value, imported only when the importing module defines USESHARED.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by this conditionally imported provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 42
	 */
	int SharedValue()
	{
		return 42;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool ConditionalProviderReportsSharedValue()
	{
		return SharedValue() == 42;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ConditionalProviderRepeatsConsistently()
	{
		if (SharedValue() != 42)
		{
			return false;
		}

		return SharedValue() == 42;
	}
}
/** @end */
