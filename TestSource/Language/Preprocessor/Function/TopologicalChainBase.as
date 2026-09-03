/**
 * The base of a three-link import chain A→B→C. This module imports nothing, so
 * topological order must place it first.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.TopologicalChainBase
 * @Harness Function
 * @Tag Language.Preprocessor.TopologicalChainBase
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 1
 * @Provenance sha256=c768311d06e371947fc0d824bc63cbcd51222c2e54e79a6e18f4105546b50389; lines 424-429.
 * @Provenance Oracle: BaseValue() == 2; module order Base → Shared → Consumer.
 * @Provenance Extra: repeat stays 2. DefaultSafe.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by the chain base.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 2
	 */
	int BaseValue()
	{
		return 2;
	}

	/**
	 * Observe that the base reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs BaseValue()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool ChainBaseReportsValue()
	{
		return BaseValue() == 2;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to BaseValue()
	 * @Return true when both report 2
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ChainBaseRepeatsConsistently()
	{
		if (BaseValue() != 2)
		{
			return false;
		}

		return BaseValue() == 2;
	}
}
