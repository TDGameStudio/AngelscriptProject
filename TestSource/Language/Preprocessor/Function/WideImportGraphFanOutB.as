/**
 * The second fan-out module of the wide import graph: it imports the same root
 * as its sibling but derives a different value, so both siblings sit after the
 * root in topological order while remaining independent of each other.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.WideImportGraphFanOutB
 * @Harness Function
 * @Tag Language.Preprocessor.WideImportGraphFanOutB
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 3
 * @Provenance sha256=3e62d32d4a7b28bf1345e6d886cb466e8e99c91873b0cb17f9de6e0a1d9a8e30; lines 747-753.
 * @Provenance Oracle: ValueB() == RootValue() + 20 == 21.
 * @Provenance Extra: RootValue stays 1. DefaultSafe.
 */

import Tests.Preprocessor.WideGraph.Root;

namespace PreprocessorTest
{
	/**
	 * Derives this module's value from the imported root.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported RootValue
	 * @Return 21
	 */
	int ValueB()
	{
		return RootValue() + 20;
	}

	/**
	 * Observe that the derived value accounts for the root.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueB()
	 * @Return true when the value is 21
	 */
	UFUNCTION()
	bool FanOutBDerivesFromRoot()
	{
		return ValueB() == 21;
	}

	/**
	 * Observe the root boundary as seen through this fan-out.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue() and ValueB()
	 * @Return true when the root is 1 and the derivation holds
	 * @Boundary root value
	 */
	UFUNCTION()
	bool FanOutBRootBoundary()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return ValueB() == RootValue() + 20;
	}
}
