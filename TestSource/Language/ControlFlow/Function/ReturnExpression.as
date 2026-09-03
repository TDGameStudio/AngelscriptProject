/**
 * A return may carry an expression rather than a plain value: the expression
 * is evaluated first and its result returned. The caller sees the computed
 * result, not any intermediate step in the computation.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnExpression
 * @Harness Function
 * @Tag Language.ControlFlow.ReturnExpression
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=8cd8d78bed43284cddcea34dece420a5f94797e377da1696c7fbb7e43666fd65; lines 545-547.
 * @Provenance Oracle: Test() returns X * 2 + 1 == 11.
 * @Provenance Extra: expression is not the unmultiplied 5.
 */

namespace ControlFlowTest
{
	/**
	 * A function returning a computed expression.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs X = 5, returning X * 2 + 1
	 * @Return 11 when the expression is evaluated before returning
	 */
	int ComputedReturn()
	{
		int X = 5;
		return X * 2 + 1;
	}

	/**
	 * Observe that the caller receives the computed result.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the returning function
	 * @Return true when the result is 11
	 */
	UFUNCTION()
	bool ExpressionReturnDeliversComputedValue()
	{
		return ComputedReturn() == 11;
	}

	/**
	 * Observe that the result is neither the bare operand nor the intermediate
	 * product: the whole expression was applied.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the result against the operand and the intermediate
	 * @Return true when the result differs from both
	 * @Boundary intermediate values
	 */
	UFUNCTION()
	bool ExpressionReturnIsNotIntermediate()
	{
		if (ComputedReturn() == 5)
		{
			return false;
		}
		return ComputedReturn() != 10;
	}
}
