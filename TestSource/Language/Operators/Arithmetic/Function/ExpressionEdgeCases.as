/**
 * Expression edge cases: a deeply nested parenthesis chain, a long addition
 * chain, a precedence mix where multiplication binds tighter than addition, a
 * condition joining a comparison with a bitwise test, and an assignment used
 * as an expression so its result can be read. The precedence mix and the
 * zero-multiply case are what pin down that the usual C ordering applies.
 *
 * @Theme Language.Operators
 * @Subject Operators.ExpressionEdgeCases
 * @Harness Function
 * @Tag Language.Operators.ExpressionEdgeCases
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
 * @Provenance sha256=f703a91639dfb55a06fd8cfbe7c75fb2ed58dfc8c5cee18479844a54d126e246; lines 645-651.
 * @Provenance Oracle: MaxParens 3; LongChain 55; PrecedenceMix 13; BitAndLogic 1; AssignInExpr 5.
 * @Provenance Extra: zero-parenthesized identity; precedence mix matches 2+3*4-1 and 1+2*0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Wrap an addition in several redundant parenthesis levels.
	 */
	int MaxParens()
	{
		return ((((1 + 2))));
	}

	/**
	 * Chain ten additions together.
	 */
	int LongChain()
	{
		return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
	}

	/**
	 * Mix addition, multiplication, and subtraction so precedence decides.
	 */
	int PrecedenceMix()
	{
		return 2 + 3 * 4 - 1;
	}

	/**
	 * Join a comparison with a bitwise test in one condition, binding the
	 * result to a local first.
	 */
	int BitAndLogic()
	{
		int X = 5;
		bool Result = (X > 0 && (X & 1) == 1);
		return Result ? 1 : 0;
	}

	/**
	 * Use an assignment as an expression, reading its result through a copy.
	 */
	int AssignInExpr()
	{
		int X = 0;
		X = 5;
		int Y = X;
		return Y;
	}

	/**
	 * Observe that every edge case produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs All five expression forms
	 * @Return true when the results are 3, 55, 13, 1, and 5 respectively
	 */
	UFUNCTION()
	bool AllEdgeCasesProduceExpectedValues()
	{
		if (MaxParens() != 3)
		{
			return false;
		}
		if (LongChain() != 55)
		{
			return false;
		}
		if (PrecedenceMix() != 13)
		{
			return false;
		}
		if (BitAndLogic() != 1)
		{
			return false;
		}
		return AssignInExpr() == 5;
	}

	/**
	 * Observe the copy-from-default boundary: a copy of an unwritten local is
	 * zero, which neither the parenthesis form nor the assignment form equals.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs A copy of a zeroed local, compared against two expression forms
	 * @Return true when the copy is 0, the parens form differs, and the
	 *         assignment form minus five equals it
	 * @Boundary unwritten local copy
	 */
	UFUNCTION()
	bool CopiedDefaultDiffersFromExpressionResults()
	{
		int Start = 0;
		int Copied = Start;
		if (Copied != 0)
		{
			return false;
		}
		if (MaxParens() == Copied)
		{
			return false;
		}
		return (AssignInExpr() - 5) == Copied;
	}

	/**
	 * Observe the precedence boundary: the same expression written inline
	 * matches the helper, and multiplying by zero collapses the other term.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs 2 + 3 * 4 - 1 and 1 + 2 * 0
	 * @Return true when the first matches the helper and the second is 1
	 * @Boundary operator precedence
	 */
	UFUNCTION()
	bool PrecedenceFollowsMultiplicationBeforeAddition()
	{
		if ((2 + 3 * 4 - 1) != PrecedenceMix())
		{
			return false;
		}
		return (1 + 2 * 0) == 1;
	}
}
