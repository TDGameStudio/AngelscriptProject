/**
 * A return can exit a function before its body ends. Used as a guard clause it
 * filters out inputs up front; used inside a loop it ends both the loop and
 * the function at once; in a void function it exits with no value. Several
 * guards in sequence act as a clamp, and a return nested inside an if exits
 * from the innermost point reached.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnEarly
 * @Harness Function
 * @Tag Language.ControlFlow.ReturnEarly
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageJumpTests.cpp::ReturnEarly
 * @Provenance sha256=2e296b5a1a14b6ea866ecdebc7b327255f428605183f74b5fa3222b03134a50c; lines 378-433.
 * @Provenance Oracle: EarlyReturn(-5) -1; EarlyReturnInLoop 5; GuardClause(-5) 0;
 * @Provenance EarlyReturnNested(1, 1) 1.
 * @Provenance Extra: clamp/pass-through bounds; EarlyReturnVoid is callable.
 */

namespace ControlFlowTest
{
	/**
	 * Clamp an input with two guard returns, passing anything between through.
	 *
	 * @Covers ControlFlow.Return
	 * @Param Value Clamped to the range 0 through 100
	 * @Inputs Guard returns below zero and above one hundred
	 * @Return -1 below zero, 100 above one hundred, otherwise the value
	 */
	int ClampedEarlyReturn(int Value)
	{
		if (Value < 0)
			return -1;
		if (Value > 100)
			return 100;
		return Value;
	}

	/**
	 * Return from inside a loop, ending both the loop and the function.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A loop over 0 through 9 returning at 5
	 * @Return 5 when the loop reached it, otherwise -1
	 */
	int EarlyReturnInsideLoop()
	{
		for (int i = 0; i < 10; i++)
		{
			if (i == 5)
				return i;
		}
		return -1;
	}

	/**
	 * Exit a void function early with a bare return, for inputs outside the
	 * accepted range.
	 *
	 * @Covers ControlFlow.Return
	 * @Param Value Skips the rest of the body when out of range
	 * @Inputs Guard returns below zero and above ten
	 * @Return nothing
	 */
	void EarlyReturnFromVoid(int Value)
	{
		if (Value < 0)
			return;
		if (Value > 10)
			return;
	}

	/**
	 * Use a guard clause to reject out-of-range input before the real work.
	 *
	 * @Covers ControlFlow.Return
	 * @Param Value Doubled when within range
	 * @Inputs Guard returns below zero and above one hundred, else doubling
	 * @Return 0 below zero, 100 above one hundred, otherwise twice the value
	 */
	int GuardClauseDoublesInRange(int Value)
	{
		if (Value < 0)
			return 0;
		if (Value > 100)
			return 100;

		int Result = Value * 2;
		return Result;
	}

	/**
	 * Return from inside a nested if, so each branch can exit on its own.
	 *
	 * @Covers ControlFlow.Return
	 * @Param A Outer test operand
	 * @Param B Inner test operand
	 * @Inputs An if over A containing an if over B
	 * @Return 1 when both are positive, 2 when only A is, otherwise 3
	 */
	int NestedEarlyReturn(int A, int B)
	{
		if (A > 0)
		{
			if (B > 0)
				return 1;
			return 2;
		}
		return 3;
	}

	/**
	 * Observe that every early-return form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Each form evaluated with a representative input
	 * @Return true when all four produce their expected values
	 */
	UFUNCTION()
	bool EarlyReturnFormsProduceExpectedValues()
	{
		if (ClampedEarlyReturn(-5) != -1)
		{
			return false;
		}
		if (EarlyReturnInsideLoop() != 5)
		{
			return false;
		}
		if (GuardClauseDoublesInRange(-5) != 0)
		{
			return false;
		}
		return NestedEarlyReturn(1, 1) == 1;
	}

	/**
	 * Observe the zero default, including that the void early return is
	 * callable at each of its boundaries.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Zero passed to the clamping, guard, and nested forms
	 * @Return true when the results are 0, 0, and 3 respectively
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool EarlyReturnFormsHandleZeroInput()
	{
		EarlyReturnFromVoid(-1);
		EarlyReturnFromVoid(0);
		EarlyReturnFromVoid(20);
		if (ClampedEarlyReturn(0) != 0)
		{
			return false;
		}
		if (GuardClauseDoublesInRange(0) != 0)
		{
			return false;
		}
		return NestedEarlyReturn(0, 1) == 3;
	}

	/**
	 * Observe the clamp boundaries at both ends of each range.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Values inside and beyond each clamp, plus the nested inner branch
	 * @Return true when the clamps and the inner branch behave as expected
	 * @Boundary clamp thresholds
	 */
	UFUNCTION()
	bool EarlyReturnFormsRespectClampThresholds()
	{
		if (ClampedEarlyReturn(50) != 50)
		{
			return false;
		}
		if (ClampedEarlyReturn(150) != 100)
		{
			return false;
		}
		if (GuardClauseDoublesInRange(10) != 20)
		{
			return false;
		}
		if (GuardClauseDoublesInRange(150) != 100)
		{
			return false;
		}
		return NestedEarlyReturn(1, -1) == 2;
	}
}
