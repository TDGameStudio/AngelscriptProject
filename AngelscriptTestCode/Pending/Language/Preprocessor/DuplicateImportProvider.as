/**
 * @version v1
 * @summary The provider for the duplicate-import case: a module exporting one value, imported twice by the consumer that follows.
 * @topic Language
 */
/**
 * @version root
 * @summary The provider for the duplicate-import case: a module exporting one value, imported twice by the consumer that follows.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by this provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 17
	 */
	int SharedValue()
	{
		return 17;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 17
	 */
	UFUNCTION()
	bool DuplicateImportProviderReportsValue()
	{
		return SharedValue() == 17;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 17
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool DuplicateImportProviderRepeatsConsistently()
	{
		if (SharedValue() != 17)
		{
			return false;
		}

		return SharedValue() == 17;
	}
}
/** @end */
