/**
 * The middle link of the import chain: it imports the base and derives its own
 * value from it, so it must be preprocessed after the base and before the
 * consumer.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.TopologicalChainMiddle
 * @Harness Function
 * @Tag Language.Preprocessor.TopologicalChainMiddle
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 2
 * @Provenance sha256=8b76b432802ebf433f770c431a9fb88cf34dbb10d6aaa4eafcfaa391f51e1628; lines 431-437.
 * @Provenance Oracle: SharedValue() == BaseValue() + 3 == 5.
 * @Provenance Extra: provider BaseValue stays 2. DefaultSafe.
 */

import Tests.Preprocessor.ImportTopology.Base;

namespace PreprocessorTest
{
	/**
	 * Derives this module's value from the imported base.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported BaseValue
	 * @Return 5
	 */
	int SharedValue()
	{
		return BaseValue() + 3;
	}

	/**
	 * Observe that the derived value accounts for the base.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 5
	 */
	UFUNCTION()
	bool ChainMiddleDerivesFromBase()
	{
		return SharedValue() == 5;
	}

	/**
	 * Observe the base boundary as seen through this link.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs BaseValue() and SharedValue()
	 * @Return true when the base is 2 and the derivation holds
	 * @Boundary base value
	 */
	UFUNCTION()
	bool ChainMiddleBaseBoundary()
	{
		if (BaseValue() != 2)
		{
			return false;
		}

		return SharedValue() == BaseValue() + 3;
	}
}
