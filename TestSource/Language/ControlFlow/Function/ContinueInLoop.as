/**
 * continue skips the rest of the current pass and moves to the next iteration,
 * in every loop form: for, while, do-while, a loop with several continue
 * points, a nested loop where it skips only the inner pass, and a loop whose
 * skip test joins two clauses. An empty loop range reaches no continue at all,
 * and a continue in the inner loop leaves the outer loop running.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ContinueInLoop
 * @Harness Function
 * @Tag Language.ControlFlow.ContinueInLoop
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageJumpTests.cpp::ContinueInLoop
 * @Provenance sha256=aca66875b20d794c6101eeafe5d1f2ac4645275ed14619a99f8a914f98dadb80; lines 266-353.
 * @Provenance Oracle: ContinueInFor 25; ContinueInWhile 25; ContinueInDoWhile 37;
 * @Provenance MultipleContinues 110; ContinueInNested 6; ContinueComplexCondition 64.
 * @Provenance Extra: empty-range for adds nothing; continue skips even values.
 */

namespace ControlFlowTest
{
	/**
	 * Observe continue in a for loop: even counters are skipped.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A ten-pass for loop skipping even counters, accumulating the rest
	 * @Return 25 when only the odd counters accumulated
	 */
	UFUNCTION()
	int ContinueInForSkipsEvenCounters()
	{
		int Sum = 0;
		for (int i = 0; i < 10; i++)
		{
			if (i % 2 == 0)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe continue in a while loop: even counters are skipped, and the
	 * counter still advances because it increments before the test.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A ten-pass while loop incrementing first, then skipping even values
	 * @Return 25 when only the odd counters accumulated
	 */
	UFUNCTION()
	int ContinueInWhileSkipsEvenCounters()
	{
		int Sum = 0;
		int i = 0;
		while (i < 10)
		{
			i++;
			if (i % 2 == 0)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe continue in a do-while loop: multiples of three are skipped, and
	 * the body still runs before the first test.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A do-while loop over 1 through 10 skipping multiples of three
	 * @Return 37 when only the non-multiples accumulated
	 */
	UFUNCTION()
	int ContinueInDoWhileSkipsMultiplesOfThree()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			i++;
			if (i % 3 == 0)
				continue;
			Sum += i;
		} while (i < 10);
		return Sum;
	}

	/**
	 * Observe a loop with several continue points: both guards skip their own
	 * ranges, so only the middle band accumulates.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A twenty-pass loop skipping below five and above fifteen
	 * @Return 110 when only 5 through 15 accumulated
	 */
	UFUNCTION()
	int MultipleContinuesSkipBothRanges()
	{
		int Sum = 0;
		for (int i = 0; i < 20; i++)
		{
			if (i < 5)
				continue;
			if (i > 15)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe continue in a nested loop: it skips only the inner pass, so the
	 * outer loop keeps going.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs An outer loop of three passes containing an inner loop skipping even counters
	 * @Return 6 when the inner loop counted twice per outer pass
	 * @Boundary nested loop
	 */
	UFUNCTION()
	int ContinueInNestedSkipsOnlyInnerPass()
	{
		int Count = 0;
		for (int i = 0; i < 3; i++)
		{
			for (int j = 0; j < 5; j++)
			{
				if (j % 2 == 0)
					continue;
				Count++;
			}
		}
		return Count;
	}

	/**
	 * Observe a continue whose test joins two clauses: either clause alone is
	 * enough to skip the pass.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A twenty-pass loop skipping even counters and anything above fifteen
	 * @Return 64 when only odd counters up to fifteen accumulated
	 */
	UFUNCTION()
	int ContinueWithCompoundConditionSkipsEitherClause()
	{
		int Sum = 0;
		for (int i = 0; i < 20; i++)
		{
			if (i % 2 == 0 || i > 15)
				continue;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe the empty default: a loop whose range is empty reaches no
	 * continue and accumulates nothing.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A for loop whose bound is already satisfied
	 * @Return true when the sum is zero
	 * @Boundary empty loop range
	 */
	UFUNCTION()
	bool ContinueInEmptyRangeAccumulatesNothing()
	{
		int Sum = 0;
		for (int i = 0; i < 0; i++)
		{
			if (i % 2 == 0)
				continue;
			Sum += i;
		}
		return Sum == 0;
	}

	/**
	 * Observe that every loop form honours its continue and produces the
	 * expected accumulated value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs All six continue forms
	 * @Return true when they produce 25, 25, 37, 110, 6, and 64 respectively
	 */
	UFUNCTION()
	bool ContinueFormsProduceExpectedValues()
	{
		if (ContinueInForSkipsEvenCounters() != 25)
		{
			return false;
		}
		if (ContinueInWhileSkipsEvenCounters() != 25)
		{
			return false;
		}
		if (ContinueInDoWhileSkipsMultiplesOfThree() != 37)
		{
			return false;
		}
		if (MultipleContinuesSkipBothRanges() != 110)
		{
			return false;
		}
		if (ContinueInNestedSkipsOnlyInnerPass() != 6)
		{
			return false;
		}
		return ContinueWithCompoundConditionSkipsEitherClause() == 64;
	}
}
