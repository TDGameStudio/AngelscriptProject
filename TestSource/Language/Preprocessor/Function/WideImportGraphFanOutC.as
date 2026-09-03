/**
 * The third fan-out module of the wide import graph: it imports the same root
 * as its siblings and derives a third distinct value, so all three siblings sit
 * after the root while remaining mutually independent.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.WideImportGraphFanOutC
 * @Harness Function
 * @Tag Language.Preprocessor.WideImportGraphFanOutC
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 4
 * @Provenance sha256=62973240d8d1521a435d4752b1be89097735da0f80bba042fb31872c016143f1; lines 755-761.
 * @Provenance Oracle: ValueC() == RootValue() + 30 == 31.
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
	 * @Return 31
	 */
	int ValueC()
	{
		return RootValue() + 30;
	}

	/**
	 * Observe that the derived value accounts for the root.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueC()
	 * @Return true when the value is 31
	 */
	UFUNCTION()
	bool FanOutCDerivesFromRoot()
	{
		return ValueC() == 31;
	}

	/**
	 * Observe the root boundary as seen through this fan-out.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue() and ValueC()
	 * @Return true when the root is 1 and the derivation holds
	 * @Boundary root value
	 */
	UFUNCTION()
	bool FanOutCRootBoundary()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return ValueC() == RootValue() + 30;
	}
}
