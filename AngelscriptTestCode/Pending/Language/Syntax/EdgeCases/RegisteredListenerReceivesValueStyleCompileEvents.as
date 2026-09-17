/**
 * @version v1
 * @summary A compile-event payload module whose registered listener receives value-style events: the listener path does not disturb the module's results, so Entry returns its constant.
 * @topic Language
 */
/**
 * @version root
 * @summary A compile-event payload module whose registered listener receives value-style events: the listener path does not disturb the module's results, so Entry returns its constant.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 11
	 */
	int Entry()
	{
		return 11;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool RegisteredListenerCompileNominal()
	{
		return Entry() == 11;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 11
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool RegisteredListenerCompileRepeatCall()
	{
		int First = Entry();

		if (First != 11)
		{
			return false;
		}

		return Entry() == 11;
	}
}
/** @end */
