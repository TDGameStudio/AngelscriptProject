/**
 * The six relational operators each report their relation, a chained
 * comparison joins two of them, and the same operators apply to floats. Each
 * observation returns 1 when the relation holds and 0 when it does not, so the
 * false boundary and the inverse float comparison are both observable.
 *
 * @Theme Language.Operators
 * @Subject Operators.ComparisonOperators
 * @Harness Function
 * @Tag Language.Operators.ComparisonOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Positive
 * @Provenance sha256=b708bfe2855b0d7c4671dc503affcf9c59e0d24a7b1ca9f42bfe9718ab7ffd70; lines 367-376.
 * @Provenance Oracle: Equal 1; NotEqual 1; LessThan 1; GreaterThan 1; LessEqual 1;
 * @Provenance GreaterEqual 1; ChainedCmp 1; FloatCompare 1.
 * @Provenance Extra: 1==2 and 2<1 are the false boundary; 1.0f>1.5f is the inverse float compare.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	/**
	 * Report whether equality holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1 == 1
	 * @Return 1 when equal, 0 otherwise
	 */
	int EqualHolds()
	{
		return (1 == 1) ? 1 : 0;
	}

	/**
	 * Report whether inequality holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1 != 2
	 * @Return 1 when not equal, 0 otherwise
	 */
	int NotEqualHolds()
	{
		return (1 != 2) ? 1 : 0;
	}

	/**
	 * Report whether the lesser relation holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1 < 2
	 * @Return 1 when lesser, 0 otherwise
	 */
	int LessThanHolds()
	{
		return (1 < 2) ? 1 : 0;
	}

	/**
	 * Report whether the greater relation holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 2 > 1
	 * @Return 1 when greater, 0 otherwise
	 */
	int GreaterThanHolds()
	{
		return (2 > 1) ? 1 : 0;
	}

	/**
	 * Report whether the lesser-or-equal relation holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1 <= 1
	 * @Return 1 when lesser or equal, 0 otherwise
	 */
	int LessEqualHolds()
	{
		return (1 <= 1) ? 1 : 0;
	}

	/**
	 * Report whether the greater-or-equal relation holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 2 >= 1
	 * @Return 1 when greater or equal, 0 otherwise
	 */
	int GreaterEqualHolds()
	{
		return (2 >= 1) ? 1 : 0;
	}

	/**
	 * Report whether a chained comparison holds across three values.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1 < 2 and 2 < 3
	 * @Return 1 when both links hold, 0 otherwise
	 */
	int ChainedComparisonHolds()
	{
		int A = 1;
		int B = 2;
		int C = 3;
		return ((A < B) && (B < C)) ? 1 : 0;
	}

	/**
	 * Report whether a float comparison holds.
	 *
	 * @Covers Operators.Comparison
	 * @Inputs 1.5f > 1.0f
	 * @Return 1 when greater, 0 otherwise
	 */
	int FloatComparisonHolds()
	{
		return (1.5f > 1.0f) ? 1 : 0;
	}

	/**
	 * Observe that every relation reports its expected result.
	 *
	 * @Kind Observe
	 * @Covers Operators.Comparison
	 * @Inputs All eight comparison forms
	 * @Return true when every one reports 1
	 */
	UFUNCTION()
	bool AllRelationsHold()
	{
		if (EqualHolds() != 1)
		{
			return false;
		}
		if (NotEqualHolds() != 1)
		{
			return false;
		}
		if (LessThanHolds() != 1)
		{
			return false;
		}
		if (GreaterThanHolds() != 1)
		{
			return false;
		}
		if (LessEqualHolds() != 1)
		{
			return false;
		}
		if (GreaterEqualHolds() != 1)
		{
			return false;
		}
		if (ChainedComparisonHolds() != 1)
		{
			return false;
		}
		return FloatComparisonHolds() == 1;
	}

	/**
	 * Observe the false boundary: relations that do not hold report 0.
	 *
	 * @Kind Observe
	 * @Covers Operators.Comparison
	 * @Inputs 1 == 2 and 2 < 1
	 * @Return true when both report 0
	 * @Boundary false relations
	 */
	UFUNCTION()
	bool FalseRelationsReportZero()
	{
		if (((1 == 2) ? 1 : 0) != 0)
		{
			return false;
		}
		return ((2 < 1) ? 1 : 0) == 0;
	}

	/**
	 * Observe the inverse float boundary: the comparison matches the helper in
	 * one direction and reports 0 in the other.
	 *
	 * @Kind Observe
	 * @Covers Operators.Comparison
	 * @Inputs 1.5f > 1.0f and its inverse 1.0f > 1.5f
	 * @Return true when the forward comparison holds and the inverse does not
	 * @Boundary inverted float comparison
	 */
	UFUNCTION()
	bool InvertedFloatComparisonReportsZero()
	{
		if (((1.5f > 1.0f) ? 1 : 0) != FloatComparisonHolds())
		{
			return false;
		}
		return ((1.0f > 1.5f) ? 1 : 0) == 0;
	}
}
