/**
 * A long chained addition of fifteen terms in a single expression. The observers
 * confirm the total and the zero and single-term boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.LongChainedAddition
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.LongChainedAddition
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 3 AssertCompiles.
 * @Provenance sha256=4dbb6fcb0946a0d771acaaaa06ebdc07720788f0ad75c30a4b5bd69e094555a6; lines 241-243.
 * @Provenance Oracle: 1+...+15 evaluates to 120.
 * @Provenance Extra: empty sum is 0; single-term boundary is 1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * A fifteen-term chained addition.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
	}

	/**
	 * Observe the total of the chained addition.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the sum of one through fifteen
	 * @Return 120
	 */
	UFUNCTION()
	int LongExpressionSumsOneToFifteen()
	{
		int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
		return X;
	}

	/**
	 * Observe the zero boundary of the addition.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a zero initializer
	 * @Return 0
	 * @Boundary empty sum
	 */
	UFUNCTION()
	int LongExpressionEmptyDefaultZero()
	{
		int X = 0;
		return X;
	}

	/**
	 * Observe the single-term boundary of the addition.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a single-term initializer
	 * @Return 1
	 * @Boundary single term
	 */
	UFUNCTION()
	int LongExpressionSingleTermBoundary()
	{
		int X = 1;
		return X;
	}
}
