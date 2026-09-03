/**
 * break and continue work inside a range-for the same way they do in a while
 * loop: break ends the walk, and continue skips the rest of the current pass
 * and moves to the next element. A break on the first element ends the walk
 * before anything accumulates.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachBreakContinue
 * @Harness Function
 * @Tag Language.ControlFlow.ForeachBreakContinue
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::Foreach_Positive
 * @Provenance Oracle: BasicForeach == 6; ForeachBreak == 3; ForeachContinue == 4.
 */

namespace ControlFlowTest
{
	/**
	 * Observe the plain walk: every element is visited.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for (int Val : Arr) over 1, 2, 3
	 * @Return 6 when all three are visited
	 */
	UFUNCTION()
	int ForeachVisitsEveryElement()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe break: the walk ends as soon as the condition holds, so later
	 * elements are never visited.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for over 1, 2, 3, 4 with a break once Val > 2
	 * @Return 3 when only 1 and 2 accumulated
	 */
	UFUNCTION()
	int ForeachBreakEndsWalk()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		Arr.Add(4);
		int Sum = 0;
		for (int Val : Arr)
		{
			if (Val > 2)
			{
				break;
			}
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe continue: the matching element is skipped while the walk carries
	 * on with the rest.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for over 1, 2, 3 with continue on 2
	 * @Return 4 when 1 and 3 accumulated but 2 did not
	 */
	UFUNCTION()
	int ForeachContinueSkipsElement()
	{
		TArray<int> Arr;
		Arr.Add(1);
		Arr.Add(2);
		Arr.Add(3);
		int Sum = 0;
		for (int Val : Arr)
		{
			if (Val == 2)
			{
				continue;
			}
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Observe the empty default: an empty container produces no passes.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for over an empty TArray
	 * @Return true when the sum stays zero
	 * @Boundary empty container
	 */
	UFUNCTION()
	bool ForeachOverEmptyAccumulatesNothing()
	{
		TArray<int> Empty;
		int Sum = 0;
		for (int Val : Empty)
		{
			Sum += Val;
		}
		return Sum == 0;
	}

	/**
	 * Observe the immediate-break boundary: breaking on the first element
	 * leaves nothing accumulated.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs for over 3, 1 with a break once Val > 2
	 * @Return true when the sum is zero because the first pass broke out
	 * @Boundary break on the first element
	 */
	UFUNCTION()
	bool ForeachBreakOnFirstElementAccumulatesNothing()
	{
		TArray<int> Arr;
		Arr.Add(3);
		Arr.Add(1);
		int Sum = 0;
		for (int Val : Arr)
		{
			if (Val > 2)
			{
				break;
			}
			Sum += Val;
		}
		return Sum == 0;
	}
}
