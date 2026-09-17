/**
 * @version v1
 * @summary The conditional operator picks one of two arms from a boolean condition. Both arms must be the same type, the unselected arm is not evaluated as a statement, and the expression can be nested so each arm is itself a.
 * @topic Language
 */
/**
 * @version root
 * @summary The conditional operator picks one of two arms from a boolean condition. Both arms must be the same type, the unselected arm is not evaluated as a statement, and the expression can be nested so each arm is itself a.
 * @topic Baseline
 */
namespace ControlFlowTest
{
	/**
	 * Observe the basic form in an initializer: a true condition takes the
	 * first arm.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Param Condition Selects which arm to take
	 * @Inputs Condition ? 10 : 20
	 * @Return 10 when the condition is true, 20 when false
	 */
	UFUNCTION()
	int BinaryTernarySelectsArm(bool Condition)
	{
		int X = Condition ? 10 : 20;
		return X;
	}

	/**
	 * Observe the nested form: each arm is itself a conditional, so a value is
	 * classified into one of three outcomes.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Param Value Classified against zero
	 * @Inputs Value > 0 ? 1 : (Value < 0 ? -1 : 0)
	 * @Return 1 above zero, -1 below zero, and 0 at zero
	 */
	UFUNCTION()
	int NestedTernaryClassifiesSign(int Value)
	{
		int X = Value > 0 ? 1 : (Value < 0 ? -1 : 0);
		return X;
	}

	/**
	 * Observe the form used directly in a return.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Param Flag Selects which arm to return
	 * @Inputs return Flag ? 1 : 0
	 * @Return 1 when the flag is true, 0 when false
	 */
	UFUNCTION()
	int ReturnTernaryYieldsArm(bool Flag)
	{
		return Flag ? 1 : 0;
	}

	/**
	 * Observe the form used in an arithmetic expression: the two arms are
	 * themselves arithmetic.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Param A First operand
	 * @Param B Second operand
	 * @Inputs (A > B) ? (A + B) : (A - B)
	 * @Return the sum when A is greater, otherwise the difference
	 */
	UFUNCTION()
	int ArithmeticTernaryAddsOrSubtracts(int A, int B)
	{
		return (A > B) ? (A + B) : (A - B);
	}

	/**
	 * Observe the false default across all four forms.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Inputs Every form evaluated with a false, zero, or lesser condition
	 * @Return true when all four take their second arm
	 * @Boundary false condition
	 */
	UFUNCTION()
	bool TernaryFalseTakesSecondArm()
	{
		if (BinaryTernarySelectsArm(false) != 20)
		{
			return false;
		}
		if (NestedTernaryClassifiesSign(0) != 0)
		{
			return false;
		}
		if (ReturnTernaryYieldsArm(false) != 0)
		{
			return false;
		}
		return ArithmeticTernaryAddsOrSubtracts(10, 20) == -10;
	}

	/**
	 * Observe the negative boundary: a negative value is classified as below
	 * zero, and equal operands subtract to zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Ternary
	 * @Inputs NestedTernaryClassifiesSign(-3) and ArithmeticTernaryAddsOrSubtracts(7, 7)
	 * @Return true when the sign is -1 and the equal operands give 0
	 * @Boundary negative value and equal operands
	 */
	UFUNCTION()
	bool TernaryNegativeAndEqualBoundaries()
	{
		if (NestedTernaryClassifiesSign(-3) != -1)
		{
			return false;
		}
		return ArithmeticTernaryAddsOrSubtracts(7, 7) == 0;
	}
}
/** @end */
