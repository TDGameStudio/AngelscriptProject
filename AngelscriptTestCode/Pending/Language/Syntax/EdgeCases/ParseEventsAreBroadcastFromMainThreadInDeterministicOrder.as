/**
 * @version v1
 * @summary A parse-event payload module: the deterministic main-thread broadcast order does not disturb the module's own results, so Entry returns its constant.
 * @topic Language
 */
/**
 * @version root
 * @summary A parse-event payload module: the deterministic main-thread broadcast order does not disturb the module's own results, so Entry returns its constant.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 19
	 */
	int Entry()
	{
		return 19;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 19
	 */
	UFUNCTION()
	bool ParseEventsNominal()
	{
		return Entry() == 19;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 19
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ParseEventsRepeatCall()
	{
		int First = Entry();

		if (First != 19)
		{
			return false;
		}

		return Entry() == 19;
	}
}
/** @end */
