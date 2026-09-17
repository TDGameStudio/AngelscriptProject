/**
 * @version v1
 * @summary The provider half of a manual import: a module that exports a single value and nothing else. The companion consumer module imports this one.
 * @topic Language
 */
/**
 * @version root
 * @summary The provider half of a manual import: a module that exports a single value and nothing else. The companion consumer module imports this one.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by this provider module.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 11
	 */
	int SharedValue()
	{
		return 11;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool ProviderReportsSharedValue()
	{
		return SharedValue() == 11;
	}
}
/** @end */
