/**
 * @version v1
 * @summary Infinite loops terminated by break: a for(;;), a while(true), a do-while(true) and a bounded loop with two separate break conditions.
 * @topic Language
 */
/**
 * @version root
 * @summary Infinite loops terminated by break: a for(;;), a while(true), a do-while(true) and a bounded loop with two separate break conditions.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Counts a for(;;) loop broken by a counter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
	int InfiniteFor()
	{
		int Sum = 0;
		for (;;)
		{
			Sum++;
			if (Sum >= 10)
				break;
		}
		return Sum;
	}

	/**
	 * Counts a while(true) loop broken by a counter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 7
	 */
	int InfiniteWhile()
	{
		int Sum = 0;
		while (true)
		{
			Sum++;
			if (Sum >= 7)
				break;
		}
		return Sum;
	}

	/**
	 * Counts a do-while(true) loop broken by a counter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 5
	 */
	int InfiniteDoWhile()
	{
		int Sum = 0;
		do
		{
			Sum++;
			if (Sum >= 5)
				break;
		} while (true);
		return Sum;
	}

	/**
	 * Sums a bounded loop with two separate break conditions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 56
	 */
	int MultipleBreaks()
	{
		int Sum = 0;
		for (int i = 0; i < 100; i++)
		{
			if (i > 20)
				break;
			if (i % 2 == 0)
				Sum += i;
			if (Sum > 50)
				break;
		}
		return Sum;
	}

	/**
	 * Observe that all four loop forms terminate at their totals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four helpers
	 * @Return true when all four totals match
	 */
	UFUNCTION()
	bool InfiniteLoopsNominal()
	{
		if (InfiniteFor() != 10)
		{
			return false;
		}

		if (InfiniteWhile() != 7)
		{
			return false;
		}

		if (InfiniteDoWhile() != 5)
		{
			return false;
		}

		return MultipleBreaks() == 56;
	}

	/**
	 * Observe the do-while single-execution shape.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs InfiniteDoWhile()
	 * @Return 5
	 * @Boundary body runs before the check
	 */
	UFUNCTION()
	int InfiniteLoopsDoWhileOnceShape()
	{
		return InfiniteDoWhile();
	}
}
/** @end */
