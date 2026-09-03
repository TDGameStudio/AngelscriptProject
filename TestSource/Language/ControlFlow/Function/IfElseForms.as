/**
 * The if-else forms observed with fixed conditions: a bare if, an if-else, an
 * else-if chain, a nested if, an unbraced if-else, and a compound condition.
 * These take no parameters, so each pins one branch decision rather than
 * sweeping a range; the parameterised forms live in IfBasic and IfConditions.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfElseForms
 * @Harness Function
 * @Tag Language.ControlFlow.IfElseForms
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Positive
 * @Provenance sha256=c3bbf48b9914843b35513ca7dd38db4456299b32fdbfc2a5847315f3bb9ea2b2; lines 49-56.
 * @Provenance Oracle: BasicIf 1; IfElse 2; IfElseIf 2; Nested 1; NoBrace 1; Complex 3.
 * @Provenance Extra: NoBrace else is unreachable here; Complex requires both positives.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a bare if with a true condition: the body runs.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (true) returning 1, with 0 after
	 * @Return 1 when the body runs
	 */
	UFUNCTION()
	int BareIfWithTrueCondition()
	{
		if (true)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe an if-else with a false condition: the else arm runs.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (false) returning 1, else returning 2
	 * @Return 2 when the else arm runs
	 */
	UFUNCTION()
	int IfElseWithFalseCondition()
	{
		if (false)
		{
			return 1;
		}
		else
		{
			return 2;
		}
	}

	/**
	 * Observe an else-if chain: the second test holds for a value of 5.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs Tests against 10 and 3, with an else after
	 * @Return 2 when the second test holds
	 */
	UFUNCTION()
	int ElseIfChainSelectsSecondTest()
	{
		int X = 5;
		if (X > 10)
		{
			return 1;
		}
		else if (X > 3)
		{
			return 2;
		}
		else
		{
			return 3;
		}
	}

	/**
	 * Observe a nested if with both conditions true: the inner body runs.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs An if (true) containing another if (true)
	 * @Return 1 when the inner body runs
	 */
	UFUNCTION()
	int NestedIfWithTrueConditions()
	{
		if (true)
		{
			if (true)
			{
				return 1;
			}
		}
		return 0;
	}

	/**
	 * Observe an unbraced if-else: only the single following statement belongs
	 * to each arm.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (true) assigning 1, else assigning 2
	 * @Return 1 when the if arm ran, since the else is unreachable here
	 */
	UFUNCTION()
	int UnbracedIfElseAssignsSingleStatement()
	{
		int X = 0;
		if (true)
			X = 1;
		else
			X = 2;
		return X;
	}

	/**
	 * Observe a compound condition with both operands positive: the body runs
	 * and uses both values.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (A > 0 && B > 0) returning their sum
	 * @Return 3 when both operands hold
	 */
	UFUNCTION()
	int CompoundConditionWithBothPositive()
	{
		int A = 1;
		int B = 2;
		if (A > 0 && B > 0)
		{
			return A + B;
		}
		return 0;
	}

	/**
	 * Observe the false-else path of the unbraced form: a false condition takes
	 * the else statement.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (false) assigning 1, else assigning 2
	 * @Return true when the else assignment ran
	 * @Boundary false condition
	 */
	UFUNCTION()
	bool UnbracedElseRunsWhenConditionFalse()
	{
		int X = 0;
		if (false)
			X = 1;
		else
			X = 2;
		return X == 2;
	}

	/**
	 * Observe the zero boundary of the compound condition: one operand at zero
	 * stops the body from running.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs if (A > 0 && B > 0) with A at zero
	 * @Return true when the result stays zero
	 * @Boundary zero operand
	 */
	UFUNCTION()
	bool CompoundConditionFailsOnZeroOperand()
	{
		int A = 0;
		int B = 2;
		int Result = 0;
		if (A > 0 && B > 0)
		{
			Result = A + B;
		}
		return Result == 0;
	}
}
