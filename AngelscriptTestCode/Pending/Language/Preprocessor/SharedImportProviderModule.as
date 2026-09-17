/**
 * @version v1
 * @summary A shared provider module exporting one value, used by the consumer that guards its import behind USE_SHARED. C++ orders this module before that consumer.
 * @topic Language
 */
/**
 * @version root
 * @summary A shared provider module exporting one value, used by the consumer that guards its import behind USE_SHARED. C++ orders this module before that consumer.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by this shared provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 40
	 */
	int SharedValue()
	{
		return 40;
	}

	/**
	 * Observe that the shared provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 40
	 */
	UFUNCTION()
	bool SharedProviderReportsValue()
	{
		return SharedValue() == 40;
	}
}
/** @end */
