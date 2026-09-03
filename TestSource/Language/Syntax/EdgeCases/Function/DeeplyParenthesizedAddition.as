/**
 * An addition wrapped in four redundant layers of parentheses. The extra
 * parentheses must not change the result.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DeeplyParenthesizedAddition
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.DeeplyParenthesizedAddition
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 5 AssertCompiles.
 * @Provenance sha256=d41be6b6eae093ae930c8d940894aa8bf279164aa0e7fc54c7ffc439fcc9e5f5; lines 253-255.
 * @Provenance Oracle: ((((1 + 2)))) is 3.
 * @Provenance Extra: ((((0)))) empty default 0; extra parens around 1 stay 1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * An addition wrapped in four layers of parentheses.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int X = ((((1 + 2))));
	}

	/**
	 * Observe that the redundant parentheses do not change the sum.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ((((1 + 2))))
	 * @Return 3
	 */
	UFUNCTION()
	int DeepParensOnePlusTwo()
	{
		int X = ((((1 + 2))));
		return X;
	}

	/**
	 * Observe the zero boundary through the parentheses.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ((((0))))
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int DeepParensEmptyZero()
	{
		int X = ((((0))));
		return X;
	}

	/**
	 * Observe the single-term boundary through the parentheses.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ((((1))))
	 * @Return 1
	 * @Boundary single term
	 */
	UFUNCTION()
	int DeepParensSingleOneBoundary()
	{
		int X = ((((1))));
		return X;
	}
}
