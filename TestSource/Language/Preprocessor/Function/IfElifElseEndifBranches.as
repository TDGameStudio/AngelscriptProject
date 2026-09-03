/**
 * The conditional directive chain: #if, #elif, #else and #endif. Which branch
 * survives depends on the flag vector the preprocessor is given, so the oracle
 * checks the branch selected by the first C++ flag vector, where
 * FIRST_BRANCH is false and SECOND_BRANCH is true.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.IfElifElseEndifBranches
 * @Harness Function
 * @Tag Language.Preprocessor.IfElifElseEndifBranches
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::IfElifElseEndifBranches
 * @Provenance lines 163-174;
 * @Provenance sha256=fd285765d180c673511bba0650cea2159393f1a5b369615dbc8d8aba793f8120.
 * @Provenance Oracle: FIRST_BRANCH=false, SECOND_BRANCH=true => Entry()==2.
 * @Provenance Second preprocess: both flags false => Entry()==3.
 * @Provenance Extra: FIRST_BRANCH true would return 1; that path is excluded in C++.
 * @Provenance DefaultSafe. Observe uses the first C++ flag vector (elif / 2).
 */

namespace PreprocessorTest
{
	/**
	 * Returns a different value from each branch of the conditional chain.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the flags FIRST_BRANCH and SECOND_BRANCH
	 * @Return 1 from the if, 2 from the elif, or 3 from the else
	 */
	int Entry()
	{
#if FIRST_BRANCH
		return 1;
#elif SECOND_BRANCH
		return 2;
#else
		return 3;
#endif
	}

	/**
	 * Observe the elif branch selected by the first flag vector.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs FIRST_BRANCH=false, SECOND_BRANCH=true
	 * @Return true when the surviving branch returns 2
	 */
	UFUNCTION()
	bool ElifBranchSelected()
	{
		return Entry() == 2;
	}
}
