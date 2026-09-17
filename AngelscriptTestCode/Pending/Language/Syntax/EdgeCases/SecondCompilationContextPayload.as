/**
 * @version v1
 * @summary The second of two compile-context payloads. Each compile run gets its own context, so this module's entry point is independent of the first one's.
 * @topic Language
 */
/**
 * @version root
 * @summary The second of two compile-context payloads. Each compile run gets its own context, so this module's entry point is independent of the first one's.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * The entry point of the second compile-context payload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 29
	 */
	int SecondEntry()
	{
		return 29;
	}

	/**
	 * Observe that the second context reports 29.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs SecondEntry()
	 * @Return true when the value is 29
	 */
	UFUNCTION()
	bool SecondContextReturnsTwentyNine()
	{
		return SecondEntry() == 29;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to SecondEntry()
	 * @Return true when both report 29
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool SecondContextRepeatsConsistently()
	{
		if (SecondEntry() != 29)
		{
			return false;
		}

		return SecondEntry() == 29;
	}
}
/** @end */
