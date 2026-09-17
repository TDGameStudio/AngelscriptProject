/**
 * @version v1
 * @summary The consumer at the end of the import chain: it imports the middle link, which in turn imports the base, so it must be preprocessed last.
 * @topic Language
 */
/**
 * @version root
 * @summary The consumer at the end of the import chain: it imports the middle link, which in turn imports the base, so it must be preprocessed last.
 * @topic Baseline
 */
import Tests.Preprocessor.ImportTopology.Shared;

namespace PreprocessorTest
{
	/**
	 * Derives this module's value from the imported middle link.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported SharedValue
	 * @Return 10
	 */
	int Entry()
	{
		return SharedValue() + 5;
	}

	/**
	 * Observe that the derived value accounts for the middle link.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry()
	 * @Return true when the value is 10
	 */
	UFUNCTION()
	bool ChainConsumerDerivesFromMiddle()
	{
		return Entry() == 10;
	}

	/**
	 * Observe the middle boundary as seen through this consumer.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue() and Entry()
	 * @Return true when the middle is 5 and the derivation holds
	 * @Boundary middle value
	 */
	UFUNCTION()
	bool ChainConsumerMiddleBoundary()
	{
		if (SharedValue() != 5)
		{
			return false;
		}

		return Entry() == SharedValue() + 5;
	}
}
/** @end */
