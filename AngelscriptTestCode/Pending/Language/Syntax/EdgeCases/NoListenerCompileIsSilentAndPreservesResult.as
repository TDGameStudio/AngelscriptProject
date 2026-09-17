/**
 * @version v1
 * @summary A compile with no listener attached: the compile-event pipeline stays silent and the module's result is unaffected, so Entry still returns its constant.
 * @topic Language
 */
/**
 * @version root
 * @summary A compile with no listener attached: the compile-event pipeline stays silent and the module's result is unaffected, so Entry still returns its constant.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Returns the module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 7
	 */
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe the entry value without any listener.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool NoListenerCompileNominal()
	{
		return Entry() == 7;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 7
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool NoListenerCompileRepeatCall()
	{
		int First = Entry();

		if (First != 7)
		{
			return false;
		}

		return Entry() == 7;
	}
}
/** @end */
