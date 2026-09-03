/**
 * The root of a fan-out import graph: a module importing nothing and exporting
 * one value. Two sibling modules import it, and a consumer imports those, so
 * the topological order must place this module first.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.WideImportGraphRoot
 * @Harness Function
 * @Tag Language.Preprocessor.WideImportGraphRoot
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 1
 * @Provenance sha256=65a35cdc6a921da31e8ac20ad91dcc1cf5d26510abe9a4e80ad6390bb99ec064; lines 732-737.
 * @Provenance Oracle: RootValue() == 1; Root is first in topological order.
 * @Provenance Extra: repeat stays 1. DefaultSafe.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by the graph root.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 1
	 */
	int RootValue()
	{
		return 1;
	}

	/**
	 * Observe that the root reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool GraphRootReportsValue()
	{
		return RootValue() == 1;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to RootValue()
	 * @Return true when both report 1
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool GraphRootRepeatsConsistently()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return RootValue() == 1;
	}
}
