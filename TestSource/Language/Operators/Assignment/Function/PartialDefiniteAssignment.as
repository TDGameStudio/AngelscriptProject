/**
 * A definite-assignment matrix that covers only one branch: the value is
 * assigned when the flag is true and left untouched otherwise. The source
 * compiles, and the compiler emits a "may not be initialized" warning for the
 * value — the warning is the point of the case, not a value oracle. Only the
 * true branch has a defined result; the false branch reads an uninitialised
 * local, so no assertion is made on it.
 *
 * @Theme Language.Operators
 * @Subject Operators.PartialDefiniteAssignment
 * @Harness Function
 * @Tag Language.Operators.PartialDefiniteAssignment
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptControlFlowTests.cpp::NotInitialized_BranchDefiniteAssignmentMatrix
 * @Provenance sha256=c0e891844fdb67e46cafc1c01bc22fc40ab3345075021683b1b1b0f9c083d365; lines 288-298.
 * @Provenance C++ still compiles (bCompileSucceeded=true) and expects a
 * @Provenance "may not be initialized" warning for Value.
 * @Provenance Oracle: RunPartial(true) assigns 7. False branch is the warning path, not a value oracle.
 * @Provenance Extra: true branch is the assigned vector; default Value is uninitialized.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Assign the local only on the true branch, leaving the false branch to
	 * read it uninitialised.
	 *
	 * @Covers Operators.Assignment
	 * @Param bFlag Selects whether the local is assigned
	 * @Inputs An uninitialised int, assigned 7 when the flag is true
	 * @Return 7 on the true branch; the false branch is the warning path
	 */
	int RunPartial(bool bFlag)
	{
		int Value;
		if (bFlag)
		{
			Value = 7;
		}
		return Value;
	}

	/**
	 * Observe the true branch, where the local is assigned before being read.
	 *
	 * @Kind Observe
	 * @Covers Operators.Assignment
	 * @Inputs RunPartial(true)
	 * @Return true when the result is 7
	 */
	UFUNCTION()
	bool AssignedBranchReadsItsValue()
	{
		return RunPartial(true) == 7;
	}
}
