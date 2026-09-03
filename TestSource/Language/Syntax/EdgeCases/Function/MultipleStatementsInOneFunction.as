/**
 * Several statements in one function: two initializers feeding a third. The
 * observers confirm the sum, the zero boundary, and that overwriting the sum
 * leaves the addends untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.MultipleStatementsInOneFunction
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.MultipleStatementsInOneFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 4 AssertCompiles.
 * @Provenance sha256=e31f69f5265fc485a7d704fc65d845bdad93bbac7e44c6dce04c07cc927d1468; lines 247-249.
 * @Provenance Oracle: A=1, B=2, C=A+B is 3; A and B stay 1 and 2 after the add.
 * @Provenance Extra: 0+0 empty sum; copy of C does not rewrite A.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Three statements where the third consumes the first two.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int A = 1;
		int B = 2;
		int C = A + B;
	}

	/**
	 * Observe the sum of the two addends.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs A=1 and B=2 summed into C
	 * @Return 3
	 */
	UFUNCTION()
	int MultipleStatementsSumNominal()
	{
		int A = 1;
		int B = 2;
		int C = A + B;
		return C;
	}

	/**
	 * Observe the zero boundary of the sum.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs A=0 and B=0 summed into C
	 * @Return 0
	 * @Boundary zero addends
	 */
	UFUNCTION()
	int MultipleStatementsEmptyDefaultZero()
	{
		int A = 0;
		int B = 0;
		int C = A + B;
		return C;
	}

	/**
	 * Observe that overwriting the sum leaves the addends untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs C overwritten to 99, then A and B re-added
	 * @Return 3
	 * @Boundary addend independence
	 */
	UFUNCTION()
	int MultipleStatementsAddendsUnchanged()
	{
		int A = 1;
		int B = 2;
		int C = A + B;
		C = 99;
		return A + B;
	}
}
