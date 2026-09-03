/**
 * break ends the innermost loop it sits in, in every loop form: for, while,
 * do-while, a loop with several break points, and a nested loop where the
 * break exits only the inner one. An empty loop range reaches no break at all,
 * and a break in the inner loop leaves the outer loop running.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.BreakInLoop
 * @Harness Function
 * @Tag Language.ControlFlow.BreakInLoop
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageJumpTests.cpp::BreakInLoop
 * @Provenance sha256=a2311a00b19398d642b2fe6b47e5d3d3d5fe99e8d27171f16c45f9d10cfbd52d; lines 77-151.
 * @Provenance Oracle: BreakInFor 10; BreakInWhile 21; BreakInDoWhile 6; MultipleBreaks 55; BreakInNested 6.
 * @Provenance Extra: empty-range for adds nothing; nested break does not exit the outer loop.
 */

namespace ControlFlowTest
{
	/**
	 * Observe break in a for loop: it ends the walk once the counter reaches 5.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A hundred-pass for loop that breaks at 5, accumulating the counter
	 * @Return 10 when only 0 through 4 accumulated
	 */
	UFUNCTION()
	int BreakInForAccumulates()
	{
		int Sum = 0;
		for (int i = 0; i < 100; i++)
		{
			if (i >= 5)
				break;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe break in a while loop: it ends the walk once the counter reaches 7.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A hundred-pass while loop that breaks at 7, accumulating the counter
	 * @Return 21 when only 0 through 6 accumulated
	 */
	UFUNCTION()
	int BreakInWhileAccumulates()
	{
		int Sum = 0;
		int i = 0;
		while (i < 100)
		{
			if (i >= 7)
				break;
			Sum += i;
			i++;
		}
		return Sum;
	}

	/**
	 * Observe break in a do-while loop: it ends the walk once the counter
	 * reaches 4, and the body still ran before the first test.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A hundred-pass do-while loop that breaks at 4, accumulating the counter
	 * @Return 6 when only 0 through 3 accumulated
	 */
	UFUNCTION()
	int BreakInDoWhileAccumulates()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			if (i >= 4)
				break;
			Sum += i;
			i++;
		} while (i < 100);
		return Sum;
	}

	/**
	 * Observe a loop with several break points: the first one to hold ends it,
	 * so the upper guard decides here.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A for loop with a break below zero and a break above ten
	 * @Return 55 when 0 through 10 accumulated and the upper guard fired
	 */
	UFUNCTION()
	int MultipleBreaksUseFirstHeldGuard()
	{
		int Sum = 0;
		for (int i = 0; i < 100; i++)
		{
			if (i < 0)
				break;
			if (i > 10)
				break;
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe break in a nested loop: it exits only the inner loop, so the
	 * outer one keeps going.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs An outer loop of three passes containing an inner loop that breaks at 2
	 * @Return 6 when the inner loop ran twice per outer pass
	 * @Boundary nested loop
	 */
	UFUNCTION()
	int BreakInNestedExitsOnlyInnerLoop()
	{
		int Count = 0;
		for (int i = 0; i < 3; i++)
		{
			for (int j = 0; j < 5; j++)
			{
				if (j >= 2)
					break;
				Count++;
			}
		}
		return Count;
	}

	/**
	 * Observe the empty default: a loop whose range is empty reaches no break
	 * and accumulates nothing.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs A for loop whose bound is already satisfied
	 * @Return true when the sum is zero
	 * @Boundary empty loop range
	 */
	UFUNCTION()
	bool BreakInEmptyRangeAccumulatesNothing()
	{
		int Sum = 0;
		for (int i = 0; i < 0; i++)
		{
			if (i >= 5)
				break;
			Sum += i;
		}
		return Sum == 0;
	}

	/**
	 * Observe that every loop form honours its break and produces the expected
	 * accumulated value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Jump
	 * @Inputs All five break forms
	 * @Return true when they produce 10, 21, 6, 55, and 6 respectively
	 */
	UFUNCTION()
	bool BreakFormsProduceExpectedValues()
	{
		if (BreakInForAccumulates() != 10)
		{
			return false;
		}
		if (BreakInWhileAccumulates() != 21)
		{
			return false;
		}
		if (BreakInDoWhileAccumulates() != 6)
		{
			return false;
		}
		if (MultipleBreaksUseFirstHeldGuard() != 55)
		{
			return false;
		}
		return BreakInNestedExitsOnlyInnerLoop() == 6;
	}
}
