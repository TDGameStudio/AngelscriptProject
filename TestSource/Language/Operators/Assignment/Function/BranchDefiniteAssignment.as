/**
 * A definite-assignment matrix that covers both branches: whichever way the
 * flag goes, the local is assigned before it is read, so the compiler emits no
 * "may not be initialized" warning. Both outcomes are observable, and the
 * shared matrix can be called directly with either flag value.
 *
 * @Theme Language.Operators
 * @Subject Operators.BranchDefiniteAssignment
 * @Harness Function
 * @Tag Language.Operators.BranchDefiniteAssignment
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptControlFlowTests.cpp::NotInitialized_BranchDefiniteAssignmentMatrix
 * @Provenance sha256=184fb7a869e7a0e65d8ced13c736700d32e26ea666d93242d502d711c8089438; lines 323-347.
 * @Provenance Oracle: RunSafeTrue 7; RunSafeFalse 9. No uninitialized warning for Value.
 * @Provenance Extra: both bool wrappers; Compute is the shared assignment matrix.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Assign the local on both branches, so it is always defined when read.
	 *
	 * @Covers Operators.Assignment
	 * @Param bFlag Selects which branch assigns the local
	 * @Inputs An uninitialised int, assigned 7 when true and 9 when false
	 * @Return 7 on the true branch, 9 on the false branch
	 */
	int Compute(bool bFlag)
	{
		int Value;
		if (bFlag)
		{
			Value = 7;
		}
		else
		{
			Value = 9;
		}
		return Value;
	}

	/**
	 * Run the matrix with the true flag.
	 *
	 * @Covers Operators.Assignment
	 * @Inputs Compute(true)
	 * @Return 7
	 */
	int RunSafeTrue()
	{
		return Compute(true);
	}

	/**
	 * Run the matrix with the false flag.
	 *
	 * @Covers Operators.Assignment
	 * @Inputs Compute(false)
	 * @Return 9
	 */
	int RunSafeFalse()
	{
		return Compute(false);
	}

	/**
	 * Observe that both wrappers produce their expected values.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs Both bool wrappers over the shared matrix
	 * @Return true when the results are 7 and 9 respectively
	 */
	UFUNCTION()
	bool BothBranchesReadTheirAssignedValue()
	{
		if (RunSafeTrue() != 7)
		{
			return false;
		}
		return RunSafeFalse() == 9;
	}

	/**
	 * Observe that calling the shared matrix directly gives the same results as
	 * going through the wrappers.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs Compute called directly with both flag values
	 * @Return true when the results are 7 and 9 respectively
	 */
	UFUNCTION()
	bool DirectCallsMatchWrappers()
	{
		if (Compute(true) != 7)
		{
			return false;
		}
		return Compute(false) == 9;
	}
}
