/**
 * A function returning an int sum. The observers confirm the nominal sum and the
 * zero and cancellation boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntReturnFunction
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntReturnFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 2 AssertCompiles.
 * @Provenance sha256=9878fbad429668a5d175dee08ce684b7f6a1ee5cb6177560c1da4898a4535208; lines 638-640.
 * @Provenance Oracle: Add(2, 3) == 5. Extra: Add(0, 0) == 0; Add(-4, 4) == 0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Adds two ints.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two addends
	 * @Return their sum
	 * @Param A the first addend
	 * @Param B the second addend
	 */
	int Add(int A, int B)
	{
		return A + B;
	}

	/**
	 * Observe the nominal sum.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Add(2, 3)
	 * @Return 5
	 */
	UFUNCTION()
	int IntReturnNominal()
	{
		return Add(2, 3);
	}

	/**
	 * Observe the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Add(0, 0)
	 * @Return 0
	 * @Boundary zero addends
	 */
	UFUNCTION()
	int IntReturnZeros()
	{
		return Add(0, 0);
	}

	/**
	 * Observe the cancellation boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Add(-4, 4)
	 * @Return 0
	 * @Boundary negative cancellation
	 */
	UFUNCTION()
	int IntReturnNegationBoundary()
	{
		return Add(-4, 4);
	}
}
