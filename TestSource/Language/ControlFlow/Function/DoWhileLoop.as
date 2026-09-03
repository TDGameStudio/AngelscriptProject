/**
 * do-while runs its body before testing the condition, so the body always
 * executes at least once even when the condition is false. That is the one
 * observable difference from while, and it is what the false-condition and
 * single-pass cases pin down. break and continue work the same way here as
 * they do in a while loop.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.DoWhileLoop
 * @Harness Function
 * @Tag Language.ControlFlow.DoWhileLoop
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::DoWhileBasic
 * @Provenance Oracle: BasicDoWhile == 10; DoWhileOnce == 1; DoWhileWithBreak == 3;
 * @Provenance DoWhileWithContinue == 25; NestedDoWhile == 4.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a counted do-while loop: it accumulates 0 through 4.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { Sum += i; i++; } while (i < 5)
	 * @Return 10 when the loop runs five times
	 */
	UFUNCTION()
	int CountedDoWhileAccumulates()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			Sum += i;
			i++;
		} while (i < 5);
		return Sum;
	}

	/**
	 * Observe the single-pass case: a false condition still lets the body run
	 * once, which is the defining difference from while.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { Count++; } while (false)
	 * @Return 1 when the body ran exactly once
	 * @Boundary false condition still runs the body once
	 */
	UFUNCTION()
	int DoWhileFalseConditionRunsBodyOnce()
	{
		int Count = 0;
		do
		{
			Count++;
		} while (false);
		return Count;
	}

	/**
	 * Observe break inside a do-while loop.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { ... } while (true) with a break once i reaches 3
	 * @Return 3 when the break ends the loop
	 */
	UFUNCTION()
	int DoWhileExitsWithBreak()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			Sum += i;
			i++;
			if (i >= 3)
			{
				break;
			}
		} while (true);
		return Sum;
	}

	/**
	 * Observe continue inside a do-while loop: even values are skipped.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { i++; continue on even; Sum += i; } while (i < 10)
	 * @Return 25 when only the odd values accumulate
	 */
	UFUNCTION()
	int DoWhileContinueSkipsEvenIterations()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			i++;
			if (i % 2 == 0)
			{
				continue;
			}
			Sum += i;
		} while (i < 10);
		return Sum;
	}

	/**
	 * Observe a nested do-while loop.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { do { Sum += i + j; j++; } while (j < 2); i++; } while (i < 2)
	 * @Return 4 when both levels run
	 */
	UFUNCTION()
	int NestedDoWhileRunsBothLevels()
	{
		int Sum = 0;
		int i = 0;
		do
		{
			int j = 0;
			do
			{
				Sum += i + j;
				j++;
			} while (j < 2);
			i++;
		} while (i < 2);
		return Sum;
	}

	/**
	 * Observe that a do-while body still assigns when the condition is false,
	 * so the assignment is observable after the loop.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { X = 42; } while (false)
	 * @Return 42 when the assignment survived the single pass
	 * @Boundary false condition still applies the body
	 */
	UFUNCTION()
	int DoWhileFalseStillAssigns()
	{
		int X = 0;
		do
		{
			X = 42;
		} while (false);
		return X;
	}

	/**
	 * Observe the zero-boundary case: a body that runs once and then stops
	 * because the condition already fails.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.DoWhile
	 * @Inputs do { Sum += i; i++; } while (i < 1) starting from i = 1
	 * @Return 1 when exactly one pass ran
	 * @Boundary condition fails after the first pass
	 */
	UFUNCTION()
	int DoWhileZeroAfterFirstPass()
	{
		int Sum = 0;
		int i = 1;
		do
		{
			Sum += i;
			i++;
		} while (i < 1);
		return Sum;
	}
}
