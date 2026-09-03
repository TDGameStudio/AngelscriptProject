/**
 * The consumer at the end of the import chain: it imports the middle link,
 * which in turn imports the base, so it must be preprocessed last.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.TopologicalChainConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.TopologicalChainConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 3
 * @Provenance sha256=4b89ce88a98976abc0c65ee6428cd3f153e278f292d02717b58760cae730330c; lines 439-445.
 * @Provenance Oracle: Entry() == SharedValue() + 5 == 10.
 * @Provenance Extra: SharedValue is 5. DefaultSafe.
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
