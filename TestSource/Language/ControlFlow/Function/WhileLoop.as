/**
 * while loop forms: a counted loop, a condition combining two clauses, an
 * unbounded loop exited with break, a nested loop, and a loop that skips
 * iterations with continue. A while condition must be a boolean expression,
 * so a false condition never enters the body and a negative bound never runs
 * it either. This file covers the while form; the do-while form, which runs
 * its body before testing, lives in DoWhileLoop.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.WhileLoop
 * @Harness Function
 * @Tag Language.ControlFlow.WhileLoop
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::WhileBasic
 * @Provenance Oracle: BasicWhile == 10; WhileComplexCondition == 21; WhileInfinite == 10;
 * @Provenance NestedWhile == 9; WhileWithContinue == 25.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a counted while loop: it accumulates 0 through 4.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (i < 5) accumulating i, incrementing each pass
	 * @Return 10 when the loop runs five times
	 */
	UFUNCTION()
	int CountedWhileAccumulates()
	{
		int Sum = 0;
		int i = 0;
		while (i < 5)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}

	/**
	 * Observe a while loop whose condition joins two clauses with &&; the
	 * loop stops as soon as either clause fails.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (i < 10 && Sum < 20) accumulating i
	 * @Return 21 when the sum clause ends the loop before the counter does
	 */
	UFUNCTION()
	int WhileWithCompoundConditionStopsEarly()
	{
		int Sum = 0;
		int i = 0;
		while (i < 10 && Sum < 20)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}

	/**
	 * Observe an unbounded while loop exited with break.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (true) with a break once the counter reaches 5
	 * @Return 10 when the break ends the loop
	 */
	UFUNCTION()
	int UnboundedWhileExitsWithBreak()
	{
		int Sum = 0;
		int i = 0;
		while (true)
		{
			Sum += i;
			i++;
			if (i >= 5)
			{
				break;
			}
		}
		return Sum;
	}

	/**
	 * Observe a nested while loop: the inner loop runs once per outer pass.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (i < 3) containing while (j < 2), accumulating i + j
	 * @Return 9 when both levels run
	 */
	UFUNCTION()
	int NestedWhileRunsBothLevels()
	{
		int Sum = 0;
		int i = 0;
		while (i < 3)
		{
			int j = 0;
			while (j < 2)
			{
				Sum += i + j;
				j++;
			}
			i++;
		}
		return Sum;
	}

	/**
	 * Observe continue: even iterations are skipped, so only odd values add.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (i < 10) with continue on even i
	 * @Return 25 when only the odd values accumulate
	 */
	UFUNCTION()
	int WhileContinueSkipsEvenIterations()
	{
		int Sum = 0;
		int i = 0;
		while (i < 10)
		{
			i++;
			if (i % 2 == 0)
			{
				continue;
			}
			Sum += i;
		}
		return Sum;
	}

	/**
	 * Observe the false-condition default: a while loop whose condition is
	 * false never runs its body.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (false) with an incrementing body
	 * @Return 0 when the body never runs
	 * @Boundary false condition
	 */
	UFUNCTION()
	int WhileFalseConditionNeverRuns()
	{
		int Sum = 0;
		int i = 0;
		while (false)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}

	/**
	 * Observe the negative-bound default: a loop whose bound is already
	 * satisfied never runs.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.While
	 * @Inputs while (i < 0) starting from i = 0
	 * @Return 0 when the body never runs
	 * @Boundary bound already satisfied
	 */
	UFUNCTION()
	int WhileNegativeBoundNeverRuns()
	{
		int Sum = 0;
		int i = 0;
		while (i < 0)
		{
			Sum += i;
			i++;
		}
		return Sum;
	}
}
