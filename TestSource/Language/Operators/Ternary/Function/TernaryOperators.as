/**
 * The conditional operator: a basic selection, a nested one whose inner
 * condition decides between two values, one whose branches are expressions,
 * and one whose condition is false so the false branch runs. A nested
 * conditional is evaluated inside out, so the inner false branch wins over
 * both the inner true branch and the outer false branch.
 *
 * @Theme Language.Operators
 * @Subject Operators.TernaryOperators
 * @Harness Function
 * @Tag Language.Operators.TernaryOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Positive ExpectGlobalInts lines 565-570;
 * @Provenance sha256=a466a71fd0190fb2bebc8cf6b48eabdc288a342224c8a6d2df357bfb6abed375.
 * @Provenance Oracle: Basic()==1; Nested()==2; WithExpr()==10; FalseCondition()==200.
 * @Provenance Extra: FalseCondition is the false-branch boundary; Nested's inner false
 * @Provenance selects 2 rather than 1 or the outer 3.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Select between two literal branches with a true condition.
	 */
	int Basic()
	{
		return true ? 1 : 0;
	}

	/**
	 * Nest one conditional inside another, so the inner condition decides.
	 */
	int Nested()
	{
		return true ? (false ? 1 : 2) : 3;
	}

	/**
	 * Select between two expressions over a local.
	 */
	int WithExpr()
	{
		int A = 5;
		return (A > 3) ? A * 2 : A - 1;
	}

	/**
	 * Select the false branch with a false condition.
	 */
	int FalseCondition()
	{
		return false ? 100 : 200;
	}

	/**
	 * Observe that every form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Ternary
	 * @Inputs All four conditional forms
	 * @Return true when the results are 1, 2, 10, and 200 respectively
	 */
	UFUNCTION()
	bool AllTernaryFormsProduceExpectedValues()
	{
		if (Basic() != 1)
		{
			return false;
		}
		if (Nested() != 2)
		{
			return false;
		}
		if (WithExpr() != 10)
		{
			return false;
		}
		return FalseCondition() == 200;
	}

	/**
	 * Observe the false-branch boundary: a false condition takes the false
	 * branch, and the nested form's inner false branch wins.
	 *
	 * @Kind Observe
	 * @Covers Operators.Ternary
	 * @Inputs The false-condition helper and the nested helper
	 * @Return true when the results are 200 and 2 respectively
	 * @Boundary false branch
	 */
	UFUNCTION()
	bool FalseBranchBoundarySelectsSecondArm()
	{
		if (FalseCondition() != 200)
		{
			return false;
		}
		return Nested() == 2;
	}

	/**
	 * Observe the expression path: the true branch computes over the local
	 * rather than returning a literal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Ternary
	 * @Inputs The expression helper
	 * @Return true when the result is 10
	 */
	UFUNCTION()
	bool ExpressionBranchComputesOverLocal()
	{
		return WithExpr() == 10;
	}
}
