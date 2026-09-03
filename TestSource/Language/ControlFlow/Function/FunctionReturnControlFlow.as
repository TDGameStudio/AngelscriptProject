/**
 * The ways a function can produce its return: an expression, a call to another
 * function, a conditional expression, and an early return that exits before
 * reaching the end of the body. An early return short-circuits the rest of the
 * body, so the trailing statement only runs for inputs that did not trigger it.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FunctionReturnControlFlow
 * @Harness Function
 * @Tag Language.ControlFlow.FunctionReturnControlFlow
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReturnControlFlow
 * @Provenance sha256=16302e73e1d23570f632329604a6e47eabac96a42ab96667a1e279aa5376ac6d; lines 884-916.
 * @Provenance Oracle: ReturnExpression 42; ReturnFunctionCall 42; ConditionalReturn(-42) 42;
 * @Provenance EarlyReturn(-5) -1; EarlyReturn(41) 42.
 * @Provenance Extra: Add(0,0) 0; ConditionalReturn(0) 0; EarlyReturn(0) 1.
 */

namespace ControlFlowTest
{
	/**
	 * Add two ints, used as the callee for the call-return case.
	 *
	 * @Covers ControlFlow.Return
	 * @Param A First operand
	 * @Param B Second operand
	 * @Inputs Two ints
	 * @Return their sum
	 */
	int AddPair(int A, int B)
	{
		return A + B;
	}

	/**
	 * Return the result of an expression over two locals.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs Locals holding 20 and 22
	 * @Return 42
	 */
	int ExpressionReturn()
	{
		int A = 20;
		int B = 22;
		return A + B;
	}

	/**
	 * Return the result of calling another function.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs AddPair(20, 22)
	 * @Return 42
	 */
	int CallReturn()
	{
		return AddPair(20, 22);
	}

	/**
	 * Return through a conditional expression, taking the absolute value here.
	 *
	 * @Covers ControlFlow.Return
	 * @Param Value Made non-negative by the conditional
	 * @Inputs Value > 0 ? Value : -Value
	 * @Return the magnitude of the value
	 */
	int ConditionalAbsoluteReturn(int Value)
	{
		return Value > 0 ? Value : -Value;
	}

	/**
	 * Return early for negative inputs, otherwise fall through to the trailing
	 * statement.
	 *
	 * @Covers ControlFlow.Return
	 * @Param Value Decides whether the early return triggers
	 * @Inputs A negative value returns -1; anything else returns the value plus one
	 * @Return -1 for negative input, otherwise the incremented value
	 */
	int EarlyReturnOnNegative(int Value)
	{
		if (Value < 0)
		{
			return -1;
		}

		return Value + 1;
	}

	/**
	 * Observe that every return form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Each return form evaluated with a representative input
	 * @Return true when all five produce their expected values
	 */
	UFUNCTION()
	bool ReturnFormsProduceExpectedValues()
	{
		if (ExpressionReturn() != 42)
		{
			return false;
		}
		if (CallReturn() != 42)
		{
			return false;
		}
		if (ConditionalAbsoluteReturn(-42) != 42)
		{
			return false;
		}
		if (EarlyReturnOnNegative(-5) != -1)
		{
			return false;
		}
		return EarlyReturnOnNegative(41) == 42;
	}

	/**
	 * Observe the zero default: zero inputs keep each form at its base value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Zero passed to the add, conditional, and early-return forms
	 * @Return true when the results are 0, 0, and 1 respectively
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool ReturnFormsHandleZeroInput()
	{
		if (AddPair(0, 0) != 0)
		{
			return false;
		}
		if (ConditionalAbsoluteReturn(0) != 0)
		{
			return false;
		}
		return EarlyReturnOnNegative(0) == 1;
	}

	/**
	 * Observe the positive boundary: a positive value passes through the
	 * conditional unchanged, and opposite operands cancel.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs A positive value and a cancelling operand pair
	 * @Return true when the results are 42 and 0 respectively
	 */
	UFUNCTION()
	bool ReturnFormsHandlePositiveAndCancellingInputs()
	{
		if (ConditionalAbsoluteReturn(42) != 42)
		{
			return false;
		}
		return AddPair(-1, 1) == 0;
	}
}
