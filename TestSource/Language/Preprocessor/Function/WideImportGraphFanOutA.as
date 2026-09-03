/**
 * The first fan-out module of the wide import graph: it imports the root and
 * derives its own value from the root's, so it must be preprocessed after the
 * root.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.WideImportGraphFanOutA
 * @Harness Function
 * @Tag Language.Preprocessor.WideImportGraphFanOutA
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 2
 * @Provenance sha256=7baa2ff7e4e523ba01c1d7af407a759585404427b2c68165e5ffb7053a79e3cc; lines 739-745.
 * @Provenance Oracle: ValueA() == RootValue() + 10 == 11.
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
	 * @Return 11
	 */
	int ValueA()
	{
		return RootValue() + 10;
	}

	/**
	 * Observe that the derived value accounts for the root.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueA()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool FanOutADerivesFromRoot()
	{
		return ValueA() == 11;
	}

	/**
	 * Observe the root boundary as seen through this fan-out.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue() and ValueA()
	 * @Return true when the root is 1 and the derivation holds
	 * @Boundary root value
	 */
	UFUNCTION()
	bool FanOutARootBoundary()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return ValueA() == RootValue() + 10;
	}
}
