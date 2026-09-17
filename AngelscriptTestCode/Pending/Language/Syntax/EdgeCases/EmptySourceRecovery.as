/**
 * @version v1
 * @summary The recovery body compiled after an empty-source failure. The C++ test feeds an empty prelude first, expects that compile to fail, then compiles this body into a fresh module to prove no state leaked. This file is that.
 * @topic Language
 */
/**
 * @version root
 * @summary The recovery body compiled after an empty-source failure. The C++ test feeds an empty prelude first, expects that compile to fail, then compiles this body into a fresh module to prove no state leaked. This file is that.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * The constant entry point of the recovery module.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return 42;
	}

	/**
	 * Observe that the recovery module reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool EmptySourceRecoveryReturnsFortyTwo()
	{
		return Entry() == 42;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool EmptySourceRecoveryRepeatsConsistently()
	{
		if (Entry() != 42)
		{
			return false;
		}

		return Entry() == 42;
	}
}
/** @end */
