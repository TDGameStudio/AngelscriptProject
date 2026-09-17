/**
 * @version v1
 * @summary A memory-source module compiled under a full virtual path: the module's payload survives with its identity intact, so Entry still returns its constant.
 * @topic Language
 */
/**
 * @version root
 * @summary A memory-source module compiled under a full virtual path: the module's payload survives with its identity intact, so Entry still returns its constant.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Returns the memory-source module's constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 37
	 */
	int Entry()
	{
		return 37;
	}

	/**
	 * Observe the entry value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 37
	 */
	UFUNCTION()
	bool MemorySourceNominal()
	{
		return Entry() == 37;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 37
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool MemorySourceRepeatCall()
	{
		int First = Entry();

		if (First != 37)
		{
			return false;
		}

		return Entry() == 37;
	}
}
/** @end */
