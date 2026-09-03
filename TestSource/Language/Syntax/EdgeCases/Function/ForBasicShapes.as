/**
 * Basic for-loop shapes: count up, count down, stepped, single-statement body,
 * and comma-separated multiple variables in one header. The observers confirm
 * each total plus the never-entered boundary.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForBasicShapes
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ForBasicShapes
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageLoopTests.cpp::ForBasic ExpectGlobalReturn
 * @Provenance sha256=956808bcf89b204130ccf5071b50d64eef4e5cbd6c1c7797c8daebda41cba9b7; lines 73-126.
 * @Provenance Oracle: ForCountUp()==45; ForCountDown()==55; ForStepTwo()==20; ForEmptyBody()==5; ForMultipleVars()==50.
 * @Provenance Extra: ForCountUp-style I<0 yields 0; ForMultipleVars is already the comma-clause vector.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Sums an ascending count to ten.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 45
	 */
	int ForCountUp()
	{
		int Sum = 0;
		for (int i = 0; i < 10; i++)
		{
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Sums a descending count from ten.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 55
	 */
	int ForCountDown()
	{
		int Sum = 0;
		for (int i = 10; i >= 0; i--)
		{
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Sums every second value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 20
	 */
	int ForStepTwo()
	{
		int Sum = 0;
		for (int i = 0; i < 10; i += 2)
		{
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Counts a body written without braces.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 5
	 */
	int ForEmptyBody()
	{
		int Count = 0;
		for (int i = 0; i < 5; i++)
			Count++;
		return Count;
	}

	/**
	 * Sums two comma-declared loop variables moving in opposite directions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 50
	 */
	int ForMultipleVars()
	{
		int Sum = 0;
		for (int i = 0, j = 10; i < 5; i++, j--)
		{
			Sum += i + j;
		}
		return Sum;
	}

	/**
	 * Observe that all five shapes produce their totals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all five helpers
	 * @Return true when all five totals match
	 */
	UFUNCTION()
	bool ForBasicNominal()
	{
		if (ForCountUp() != 45)
		{
			return false;
		}

		if (ForCountDown() != 55)
		{
			return false;
		}

		if (ForStepTwo() != 20)
		{
			return false;
		}

		if (ForEmptyBody() != 5)
		{
			return false;
		}

		return ForMultipleVars() == 50;
	}

	/**
	 * Observe that a loop whose condition is false at entry sums nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a loop bounded by i < 0
	 * @Return 0
	 * @Boundary never-entered loop
	 */
	UFUNCTION()
	int ForBasicEmptyBound()
	{
		int Sum = 0;
		for (int i = 0; i < 0; i++)
		{
			Sum += i;
		}
		return Sum;
	}
}
