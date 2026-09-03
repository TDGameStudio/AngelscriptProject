/**
 * A function may have several return points, and the one reached depends on
 * which branch the input selects. Returns can sit in an else-if chain, in each
 * case of a switch, in a ternary, at each level of a nested if, or inside a
 * nested loop where the return exits both loops at once. A trailing return
 * catches whatever reached the end without returning earlier.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.MultipleReturns
 * @Harness Function
 * @Tag Language.ControlFlow.MultipleReturns
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageJumpTests.cpp::MultipleReturns
 * @Provenance sha256=b2fa4c8e2ead242bf14dd071cf5e217b0a71e42b2c52dcdc9e4a253a1645215d; lines 456-539.
 * @Provenance Oracle: MultipleReturnPoints(-1) -1; ReturnFromSwitch(1) 10;
 * @Provenance ReturnExpression(10, 20) 30; ReturnTernary(1) 1;
 * @Provenance ComplexMultipleReturns(1, 1, 1) 1; ReturnInNestedLoops 35.
 * @Provenance Extra: remaining return bands; switch default 0; nested-loop miss returns -1.
 */

namespace ControlFlowTest
{
	/**
	 * Observe an else-if chain that returns a different band per condition.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Param Value Selects the band to return
	 * @Inputs Guards for negative, zero, below ten, below one hundred, and a trailing else
	 * @Return -1 below zero, 0 at zero, 1 below ten, 2 below one hundred, otherwise 3
	 */
	UFUNCTION()
	int ElseIfChainSelectsReturnBand(int Value)
	{
		if (Value < 0)
			return -1;
		else if (Value == 0)
			return 0;
		else if (Value < 10)
			return 1;
		else if (Value < 100)
			return 2;
		else
			return 3;
	}

	/**
	 * Observe a switch where each case returns its own value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Param Value Selects the case to return from
	 * @Inputs case 1 gives 10, case 2 gives 20, case 3 gives 30, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchCasesReturnTheirOwnValues(int Value)
	{
		switch (Value)
		{
			case 1:
				return 10;
			case 2:
				return 20;
			case 3:
				return 30;
			default:
				return 0;
		}
	}

	/**
	 * Observe a return carrying an expression over the parameters.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Param A First operand
	 * @Param B Second operand
	 * @Inputs return A + B
	 * @Return the sum of the two operands
	 */
	UFUNCTION()
	int ExpressionReturnSumsOperands(int A, int B)
	{
		return A + B;
	}

	/**
	 * Observe a return carrying a ternary expression.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Param Value Tested against zero
	 * @Inputs return Value > 0 ? 1 : -1
	 * @Return 1 above zero, otherwise -1
	 */
	UFUNCTION()
	int TernaryReturnClassifiesSign(int Value)
	{
		return Value > 0 ? 1 : -1;
	}

	/**
	 * Observe a three-level nested if where each arm returns its own value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Param X Outer test operand
	 * @Param Y Middle test operand
	 * @Param Z Inner test operand
	 * @Inputs Nested tests over all three operands
	 * @Return 1 when all are positive, 2 when only Z is not, 3 when Y is not,
	 *         4 when only Y is positive, and 5 when none are
	 */
	UFUNCTION()
	int NestedIfArmsReturnTheirOwnValues(int X, int Y, int Z)
	{
		if (X > 0)
		{
			if (Y > 0)
			{
				if (Z > 0)
					return 1;
				else
					return 2;
			}
			else
			{
				return 3;
			}
		}
		else
		{
			if (Y > 0)
				return 4;
			else
				return 5;
		}
	}

	/**
	 * Observe a return from inside nested loops: it exits both loops at once.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Two nested ten-pass loops returning when the counters reach 3 and 5
	 * @Return 35 when the pair was found, otherwise -1
	 * @Boundary nested loop exit
	 */
	UFUNCTION()
	int NestedLoopReturnExitsBothLoops()
	{
		for (int i = 0; i < 10; i++)
		{
			for (int j = 0; j < 10; j++)
			{
				if (i == 3 && j == 5)
					return i * 10 + j;
			}
		}
		return -1;
	}

	/**
	 * Observe that every return form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Each form evaluated with a representative input
	 * @Return true when all six produce their expected values
	 */
	UFUNCTION()
	bool MultipleReturnFormsProduceExpectedValues()
	{
		if (ElseIfChainSelectsReturnBand(-1) != -1)
		{
			return false;
		}
		if (SwitchCasesReturnTheirOwnValues(1) != 10)
		{
			return false;
		}
		if (ExpressionReturnSumsOperands(10, 20) != 30)
		{
			return false;
		}
		if (TernaryReturnClassifiesSign(1) != 1)
		{
			return false;
		}
		if (NestedIfArmsReturnTheirOwnValues(1, 1, 1) != 1)
		{
			return false;
		}
		return NestedLoopReturnExitsBothLoops() == 35;
	}

	/**
	 * Observe the zero default across the forms: each takes the arm a zero
	 * input selects.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Zero passed to each form
	 * @Return true when the results are 0, 0, 0, -1, and 5 respectively
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool MultipleReturnFormsHandleZeroInput()
	{
		if (ElseIfChainSelectsReturnBand(0) != 0)
		{
			return false;
		}
		if (SwitchCasesReturnTheirOwnValues(0) != 0)
		{
			return false;
		}
		if (ExpressionReturnSumsOperands(0, 0) != 0)
		{
			return false;
		}
		if (TernaryReturnClassifiesSign(0) != -1)
		{
			return false;
		}
		return NestedIfArmsReturnTheirOwnValues(0, 0, 0) == 5;
	}
}
