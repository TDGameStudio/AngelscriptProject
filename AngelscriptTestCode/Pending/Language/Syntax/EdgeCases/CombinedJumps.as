/**
 * @version v1
 * @summary Break, continue and return combined inside for-loops: break after a cutoff, continue to skip even iterations, a nested loop with its own continue and break, and an early return once an accumulator passes a limit.
 * @topic Language
 */
/**
 * @version root
 * @summary Break, continue and return combined inside for-loops: break after a cutoff, continue to skip even iterations, a nested loop with its own continue and break, and an early return once an accumulator passes a limit.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Breaks past a cutoff while skipping even iterations.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 64, the sum of odd indices up to 15
	 */
	int BreakAndContinue()
	{
		int Sum = 0;
		for (int i = 0; i < 20; i++)
		{
			if (i > 15)
				break;
			if (i % 2 == 0)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Combines an early return, a break and a continue in one loop.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an upper limit for the accumulator
	 * @Return 817 when the limit is 800
	 * @Param Limit the accumulator threshold that triggers the early return
	 */
	int AllThreeJumps(int Limit)
	{
		int Sum = 0;
		for (int i = 0; i < 100; i++)
		{
			if (Sum > Limit)
				return Sum;
			if (i > 50)
				break;
			if (i % 3 == 0)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Nests a loop whose body continues and breaks on its own index.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 12
	 */
	int NestedVariousJumps()
	{
		int Count = 0;
		for (int i = 0; i < 5; i++)
		{
			if (i == 0)
				continue;
			for (int j = 0; j < 5; j++)
			{
				if (j == 2)
					continue;
				if (j == 4)
					break;
				Count++;
			}
			if (Count > 10)
				return Count;
		}
		return Count;
	}

	/**
	 * Observe that all three jump combinations produce their expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BreakAndContinue, AllThreeJumps(800) and NestedVariousJumps
	 * @Return true when all three match
	 */
	UFUNCTION()
	bool CombinedJumpsProduceExpectedValues()
	{
		if (BreakAndContinue() != 64)
		{
			return false;
		}

		if (AllThreeJumps(800) != 817)
		{
			return false;
		}

		return NestedVariousJumps() == 12;
	}

	/**
	 * Observe the zero-limit early return.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AllThreeJumps(0)
	 * @Return 1
	 * @Boundary zero limit
	 */
	UFUNCTION()
	int AllThreeJumpsZeroLimitBoundary()
	{
		return AllThreeJumps(0);
	}
}
/** @end */
