/**
 * The basic if forms: a bare if, an if with an else, an else-if chain, an
 * else-if chain with a trailing else, and a single-statement if with no
 * braces. A bare if leaves its result untouched when the condition is false,
 * an else-if chain tests each condition in order, and a trailing else catches
 * whatever fell past every test.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfBasic
 * @Harness Function
 * @Tag Language.ControlFlow.IfBasic
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageConditionalTests.cpp::IfBasic
 * @Provenance sha256=c21d26b5495e59f8a697601a26b9c38bb9c47300d04f717579f4441aa5b08214; lines 79-151.
 * @Provenance Oracle: SimpleIf(true) 10; IfElse(true) 1; IfElseIf(5) 1; IfElseIfElse(15) 2;
 * @Provenance SingleLineIf(true) 5.
 * @Provenance Extra: false/zero/else branches; SingleLineIf(false) stays 0.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a bare if: the assignment happens only when the condition holds.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Condition Selects whether the body runs
	 * @Inputs A result initialised to 0 and set to 10 inside the if
	 * @Return 10 when the condition is true, 0 when false
	 */
	UFUNCTION()
	int BareIfAssignsWhenTrue(bool Condition)
	{
		int Result = 0;
		if (Condition)
		{
			Result = 10;
		}
		return Result;
	}

	/**
	 * Observe an if with an else: exactly one of the two arms runs.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Condition Selects which arm runs
	 * @Inputs if returns 1, else returns 2
	 * @Return 1 when the condition is true, 2 when false
	 */
	UFUNCTION()
	int IfElseSelectsOneArm(bool Condition)
	{
		if (Condition)
		{
			return 1;
		}
		else
		{
			return 2;
		}
	}

	/**
	 * Observe an else-if chain with no trailing else: a value matching none of
	 * the conditions falls through to the statement after the chain.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Value Classified by the chain
	 * @Inputs Tests for negative, positive, then zero
	 * @Return -1 below zero, 1 above zero, 0 at zero, and 999 if none match
	 */
	UFUNCTION()
	int ElseIfChainClassifiesValue(int Value)
	{
		if (Value < 0)
		{
			return -1;
		}
		else if (Value > 0)
		{
			return 1;
		}
		else if (Value == 0)
		{
			return 0;
		}
		return 999;
	}

	/**
	 * Observe an else-if chain with a trailing else: the else catches whatever
	 * fell past every condition.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Value Classified into bands by the chain
	 * @Inputs Tests against 10, 20, then 30, with an else after
	 * @Return 1 below ten, 2 below twenty, 3 below thirty, otherwise 4
	 */
	UFUNCTION()
	int ElseIfChainWithTrailingElse(int Value)
	{
		if (Value < 10)
		{
			return 1;
		}
		else if (Value < 20)
		{
			return 2;
		}
		else if (Value < 30)
		{
			return 3;
		}
		else
		{
			return 4;
		}
	}

	/**
	 * Observe a single-statement if with no braces: only the one following
	 * statement belongs to the body.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Condition Selects whether the single statement runs
	 * @Inputs A result initialised to 0 and set to 5 by the unbraced if
	 * @Return 5 when the condition is true, 0 when false
	 */
	UFUNCTION()
	int SingleStatementIfAssignsWhenTrue(bool Condition)
	{
		int Result = 0;
		if (Condition)
			Result = 5;
		return Result;
	}

	/**
	 * Observe the false default across the forms: each stays at its initial
	 * value or takes the else arm.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs Every form evaluated with a false or zero condition
	 * @Return true when the results are 0, 2, 0, and 0 respectively
	 * @Boundary false condition
	 */
	UFUNCTION()
	bool IfFalseTakesElseOrStaysUnchanged()
	{
		if (BareIfAssignsWhenTrue(false) != 0)
		{
			return false;
		}
		if (IfElseSelectsOneArm(false) != 2)
		{
			return false;
		}
		if (ElseIfChainClassifiesValue(0) != 0)
		{
			return false;
		}
		return SingleStatementIfAssignsWhenTrue(false) == 0;
	}

	/**
	 * Observe the band boundaries: each threshold selects the band it opens.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs The negative branch and the three band thresholds
	 * @Return true when the results are -1, 1, 3, and 4 respectively
	 * @Boundary band thresholds
	 */
	UFUNCTION()
	bool IfChainRespectsThresholds()
	{
		if (ElseIfChainClassifiesValue(-3) != -1)
		{
			return false;
		}
		if (ElseIfChainWithTrailingElse(5) != 1)
		{
			return false;
		}
		if (ElseIfChainWithTrailingElse(25) != 3)
		{
			return false;
		}
		return ElseIfChainWithTrailingElse(30) == 4;
	}
}
