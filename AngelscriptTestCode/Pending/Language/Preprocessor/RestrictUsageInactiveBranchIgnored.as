/**
 * @version v1
 * @summary A #restrict usage directive sitting in a dead branch is ignored: under an EDITOR context the #if !EDITOR block is stripped, so no usage restriction is recorded and the module compiles with no diagnostics.
 * @topic Language
 */
/**
 * @version root
 * @summary A #restrict usage directive sitting in a dead branch is ignored: under an EDITOR context the #if !EDITOR block is stripped, so no usage restriction is recorded and the module compiles with no diagnostics.
 * @topic Baseline
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
/** @end */
