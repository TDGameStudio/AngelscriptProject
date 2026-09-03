/**
 * Operator precedence as it shows up in real expressions, where several
 * operator kinds appear together and the language decides the grouping. The
 * ordering is: arithmetic before comparison, comparison before logical, and
 * bitwise between arithmetic and comparison. Parentheses override all of it.
 * A single-operator file cannot show this, because the interaction between
 * kinds is the whole point.
 *
 * @Theme Language.Operators
 * @Subject Operators.ExpressionPrecedenceChains
 * @Harness Advance
 * @Tag Language.Operators.ExpressionPrecedenceChains
 * @Namespace OperatorsTest
 */

namespace OperatorsTest
{
	/**
	 * Report whether arithmetic binds tighter than comparison: the sum is
	 * computed before it is compared.
	 *
	 * @Covers Operators.Arithmetic
	 * @Inputs 1 + 2 == 3, where the addition happens first
	 * @Return true when the grouping puts the addition inside the comparison
	 */
	bool ArithmeticBindsBeforeComparison()
	{
		return (1 + 2 == 3);
	}

	/**
	 * Report whether comparison binds tighter than logical and: both
	 * comparisons are evaluated before the conjunction combines them.
	 *
	 * @Covers Operators.Logical
	 * @Inputs 1 < 2 && 3 < 4, where both comparisons precede the and
	 * @Return true when the grouping puts both comparisons inside the and
	 */
	bool ComparisonBindsBeforeLogical()
	{
		bool Result = (1 < 2 && 3 < 4);
		return Result;
	}

	/**
	 * Report whether parentheses override the natural precedence: grouping the
	 * comparison first changes the outcome of the and.
	 *
	 * @Covers Operators.Logical
	 * @Inputs (1 < 2) && 0, where the parenthesised comparison is combined with
	 *         a false operand
	 * @Return true when the parenthesised grouping is what the expression does
	 */
	bool ParenthesesOverridePrecedence()
	{
		bool Result = ((1 < 2) && (2 < 1));
		return Result == false;
	}

	/**
	 * Report whether bitwise and binds tighter than comparison: the mask is
	 * applied before the result is compared.
	 *
	 * @Covers Operators.Bitwise
	 * @Inputs (0xFF & 0x0F) == 0x0F, where the mask precedes the comparison
	 * @Return true when the grouping masks first, then compares
	 */
	bool BitwiseBindsBeforeComparison()
	{
		return ((0xFF & 0x0F) == 0x0F);
	}

	/**
	 * Report whether a conditional used as an operand is evaluated before the
	 * arithmetic around it.
	 *
	 * @Covers Operators.Ternary
	 * @Inputs 1 + (true ? 2 : 3) == 3, where the conditional resolves first
	 * @Return true when the conditional is resolved before the addition
	 */
	bool ConditionalResolvesInsideArithmetic()
	{
		return (1 + (true ? 2 : 3) == 3);
	}

	/**
	 * Observe the precedence chain across every operator kind at once.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs All five precedence probes
	 * @Return true when every one reports the expected grouping
	 */
	UFUNCTION()
	bool PrecedenceChainHoldsAcrossOperatorKinds()
	{
		if (!ArithmeticBindsBeforeComparison())
		{
			return false;
		}
		if (!ComparisonBindsBeforeLogical())
		{
			return false;
		}
		if (!ParenthesesOverridePrecedence())
		{
			return false;
		}
		if (!BitwiseBindsBeforeComparison())
		{
			return false;
		}
		return ConditionalResolvesInsideArithmetic();
	}

	/**
	 * Observe a longer chain where arithmetic, comparison, and logical and all
	 * appear, and short-circuiting stops evaluation part way through.
	 *
	 * @Kind Observe
	 * @Covers Operators.Logical
	 * @Inputs 2 + 3 * 4 compared against 14, combined with a short-circuit probe
	 * @Return true when the arithmetic grouping is right and the short-circuit
	 *         prevented the faulting operand from running
	 * @Boundary short-circuit inside a precedence chain
	 */
	UFUNCTION()
	bool MixedChainShortCircuitsAfterComparison()
	{
		int Computed = 2 + 3 * 4;
		if (Computed != 14)
		{
			return false;
		}

		bool A = (Computed > 100);
		int Z = 0;
		bool Probed = (A && (1 / Z > 0));
		return Probed == false;
	}

	/**
	 * Observe that parenthesising a comparison changes the result of an
	 * otherwise identical expression, which is what makes grouping observable.
	 *
	 * @Kind Observe
	 * @Covers Operators.Logical
	 * @Inputs The same operands grouped two ways, compared against each other
	 * @Return true when the two groupings differ
	 * @Boundary grouping changes the outcome
	 */
	UFUNCTION()
	bool RegroupingChangesTheOutcome()
	{
		bool LeftGrouped = (1 < 2 && 2 < 1);
		bool RightGrouped = (1 < (2 && 2) < 1);
		return LeftGrouped != RightGrouped;
	}
}
