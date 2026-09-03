/**
 * A #restrict usage directive sitting in a dead branch is ignored: under an
 * EDITOR context the #if !EDITOR block is stripped, so no usage restriction is
 * recorded and the module compiles with no diagnostics.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.RestrictUsageInactiveBranchIgnored
 * @Harness Function
 * @Tag Language.Preprocessor.RestrictUsageInactiveBranchIgnored
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorNamespaceTests.cpp::RestrictUsageInactiveBranchIgnored block 1
 * @Provenance sha256=02dd97721230db2f8f2f550eedcd6ff664d0734d799b066aa4c4a5f29b573f6f; lines 156-164.
 * @Provenance Oracle: Entry() == 7; EDITOR context records zero usage restrictions.
 * @Provenance Extra: repeat stays 7. DefaultSafe.
 * @Provenance Also covers block 2, the same fixture compiled and executed through
 * @Provenance the preprocessor pipeline; sha256=02dd97721230db2f8f2f550eedcd6ff664d0734d799b066aa4c4a5f29b573f6f; lines 204-212.
 */

#if !EDITOR
#restrict usage disallow Runtime.*
#endif

namespace PreprocessorTest
{
	/**
	 * A constant entry point in a module whose restriction is dead.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return 7
	 */
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe that the dead restriction does not block execution.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs Entry()
	 * @Return true when the value is 7
	 * @Boundary inactive branch
	 */
	UFUNCTION()
	bool InactiveRestrictUsageIsIgnored()
	{
		return Entry() == 7;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs two calls to Entry()
	 * @Return true when both report 7
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool InactiveRestrictUsageRepeatsConsistently()
	{
		if (Entry() != 7)
		{
			return false;
		}

		return Entry() == 7;
	}
}
