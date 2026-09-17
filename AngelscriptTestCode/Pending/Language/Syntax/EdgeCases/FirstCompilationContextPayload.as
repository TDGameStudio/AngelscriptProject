/**
 * @version v1
 * @summary The first of two compile-context payloads. Each compile run gets its own context, so this module's entry point is independent of the second one's.
 * @topic Language
 */
/**
 * @version root
 * @summary The first of two compile-context payloads. Each compile run gets its own context, so this module's entry point is independent of the second one's.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * The entry point of the first compile-context payload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 23
	 */
	int FirstEntry()
	{
		return 23;
	}

	/**
	 * Observe that the first context reports 23.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs FirstEntry()
	 * @Return true when the value is 23
	 */
	UFUNCTION()
	bool FirstContextReturnsTwentyThree()
	{
		return FirstEntry() == 23;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to FirstEntry()
	 * @Return true when both report 23
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool FirstContextRepeatsConsistently()
	{
		if (FirstEntry() != 23)
		{
			return false;
		}

		return FirstEntry() == 23;
	}
}
/** @end */
