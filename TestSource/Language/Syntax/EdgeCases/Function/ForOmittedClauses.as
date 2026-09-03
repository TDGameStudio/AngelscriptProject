/**
 * For-loops with individual clauses omitted: no initializer, no condition, no
 * increment, all three empty, and a decrementing step. The observers confirm each
 * total plus the already-satisfied condition boundary.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForOmittedClauses
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ForOmittedClauses
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageLoopTests.cpp::ForVariations ExpectGlobalReturn
 * @Provenance sha256=b572a173092022e719035f45e35e16bc9bddabc2d167e96092d4847988e554a8; lines 150-215.
 * @Provenance Oracle: ForNoInit()==10; ForNoCondition()==10; ForNoIncrement()==10; ForAllEmpty()==3; ForDecrementStep()==77.
 * @Provenance Extra: ForAllEmpty already covers empty clauses; zero-trip uses ForNoInit's i starting at 5.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Sums a loop whose initializer is hoisted outside the header.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int ForNoInit()
	{
		int i = 0;
		int Sum = 0;
		for (; i < 5; i++)
		{
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Sums a loop whose condition is replaced by an internal break.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int ForNoCondition()
	{
		int Sum = 0;
		int i = 0;
		for (;;)
		{
			Sum += i;
			i++;
			if (i >= 5)
				break;
		}
		return Sum;
	}

	/**
	 * Sums a loop whose increment is performed in the body.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int ForNoIncrement()
	{
		int Sum = 0;
		for (int i = 0; i < 5;)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}

	/**
	 * Sums a loop with every clause omitted.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 3
	 */
	int ForAllEmpty()
	{
		int Sum = 0;
		int i = 0;
		for (;;)
		{
			Sum += i;
			i++;
			if (i >= 3)
				break;
		}
		return Sum;
	}

	/**
	 * Sums a loop stepping down by three.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 77
	 */
	int ForDecrementStep()
	{
		int Sum = 0;
		for (int i = 20; i > 0; i -= 3)
		{
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe that all five variations produce their totals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all five helpers
	 * @Return true when all five totals match
	 */
	UFUNCTION()
	bool ForOmittedClausesNominal()
	{
		if (ForNoInit() != 10)
		{
			return false;
		}

		if (ForNoCondition() != 10)
		{
			return false;
		}

		if (ForNoIncrement() != 10)
		{
			return false;
		}

		if (ForAllEmpty() != 3)
		{
			return false;
		}

		return ForDecrementStep() == 77;
	}

	/**
	 * Observe that a loop whose condition is already false sums nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a loop starting at i = 5 bounded by i < 5
	 * @Return 0
	 * @Boundary already-satisfied condition
	 */
	UFUNCTION()
	int ForOmittedClausesAlreadySatisfied()
	{
		int i = 5;
		int Sum = 0;
		for (; i < 5; i++)
		{
			Sum += i;
		}
		return Sum;
	}
}
