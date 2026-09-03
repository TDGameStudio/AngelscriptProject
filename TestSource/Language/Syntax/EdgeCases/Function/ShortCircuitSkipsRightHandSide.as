/**
 * Short-circuit evaluation: && skips its right operand when the left is false,
 * || skips it when the left is true, and the right side still evaluates when the
 * left does not decide the outcome. The operators are the subject, so they stay
 * in the if-conditions rather than being restructured.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ShortCircuitSkipsRightHandSide
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ShortCircuitSkipsRightHandSide
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageSpecialControlFlowTests.cpp::ShortCircuitSkipsRightHandSide
 * @Provenance sha256=539379a5c13ea106bef1a8311f927b577ce160ca71020a34327e043d38e21cbc; lines 61-103.
 * @Provenance Oracle: AndSkipsRightSide()==0; OrSkipsRightSide()==0; RightSideEvaluatesWhenNeeded()==1.
 * @Provenance Extra: RecordTrue on its own increments; RecordFalse increments independently.
 * @Provenance DefaultSafe. &inout Calls is the evaluation counter.
 */

namespace SyntaxTest
{
	/**
	 * Increments the counter and reports true.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the shared evaluation counter
	 * @Return true after incrementing
	 * @Param Calls the counter to increment
	 */
	bool RecordTrue(int&inout Calls)
	{
		Calls += 1;
		return true;
	}

	/**
	 * Increments the counter and reports false.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the shared evaluation counter
	 * @Return false after incrementing
	 * @Param Calls the counter to increment
	 */
	bool RecordFalse(int&inout Calls)
	{
		Calls += 1;
		return false;
	}

	/**
	 * Proves that && skipped its right operand.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return the number of recorded calls, 0 when skipped
	 */
	int AndSkipsRightSide()
	{
		int Calls = 0;
		if (false && RecordTrue(Calls))
		{
			return -1;
		}
		return Calls;
	}

	/**
	 * Proves that || skipped its right operand.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return the number of recorded calls, 0 when skipped
	 */
	int OrSkipsRightSide()
	{
		int Calls = 0;
		if (true || RecordFalse(Calls))
		{
			return Calls;
		}
		return -1;
	}

	/**
	 * Proves the right side evaluates when the left does not decide.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return the number of recorded calls, 1 when evaluated
	 */
	int RightSideEvaluatesWhenNeeded()
	{
		int Calls = 0;
		if (true && RecordTrue(Calls))
		{
			return Calls;
		}
		return -1;
	}

	/**
	 * Observe all three short-circuit outcomes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three short-circuit helpers
	 * @Return true when both skips report 0 and the needed case reports 1
	 */
	UFUNCTION()
	bool ShortCircuitNominal()
	{
		if (AndSkipsRightSide() != 0)
		{
			return false;
		}

		if (OrSkipsRightSide() != 0)
		{
			return false;
		}

		return RightSideEvaluatesWhenNeeded() == 1;
	}

	/**
	 * Observe the true-recorder incrementing on its own.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs one direct call to RecordTrue
	 * @Return 1
	 */
	UFUNCTION()
	int ShortCircuitRecordTrueDirect()
	{
		int Calls = 0;
		RecordTrue(Calls);
		return Calls;
	}

	/**
	 * Observe the false-recorder incrementing on its own.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs one direct call to RecordFalse
	 * @Return 1
	 */
	UFUNCTION()
	int ShortCircuitRecordFalseDirect()
	{
		int Calls = 0;
		RecordFalse(Calls);
		return Calls;
	}
}
