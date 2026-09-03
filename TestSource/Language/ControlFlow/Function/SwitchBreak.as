/**
 * break ends a case body, which is what stops execution from running on into
 * the next case. A break can also sit inside a nested condition, so a case
 * may break early without reaching its own end.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchBreak
 * @Harness Function
 * @Tag Language.ControlFlow.SwitchBreak
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::BreakInSwitch
 * @Provenance Oracle: BreakInSwitch(1) == 10; BreakPreventsFallthrough(2) == 5;
 * @Provenance MultipleBreaksInSwitch(1) == 10.
 */

namespace ControlFlowTest
{
	/**
	 * Observe that a break after each case keeps the cases independent.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs Each case assigns its own result and breaks
	 * @Return the value assigned by the matching case
	 */
	UFUNCTION()
	int BreakKeepsCasesIndependent(int Value)
	{
		int Result = 0;
		switch (Value)
		{
			case 1:
				Result = 10;
				break;
			case 2:
				Result = 20;
				break;
			case 3:
				Result = 30;
				break;
			default:
				Result = 99;
				break;
		}
		return Result;
	}

	/**
	 * Observe that omitting a break lets execution run into the next case:
	 * case 2 adds 2 and then falls through into case 3 to add 3 more.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 2 has no break, so it continues into case 3
	 * @Return 5 for value 2, showing both case bodies ran
	 * @Boundary missing break
	 */
	UFUNCTION()
	int MissingBreakFallsThrough(int Value)
	{
		int Result = 0;
		switch (Value)
		{
			case 1:
				Result += 1;
				break;
			case 2:
				Result += 2;
			case 3:
				Result += 3;
				break;
			default:
				Result = 0;
		}
		return Result;
	}

	/**
	 * Observe a break nested inside a condition: the case exits before
	 * reaching its own assignment.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 1 assigns 10 and breaks early when the value is above 5
	 * @Return 10 for value 1, showing the later assignment was skipped
	 */
	UFUNCTION()
	int NestedBreakExitsCaseEarly(int Value)
	{
		int Result = 0;
		switch (Value)
		{
			case 1:
				Result = 10;
				if (Result > 5)
				{
					break;
				}
				Result = 20;
				break;
			case 2:
				Result = 30;
				break;
			default:
				break;
		}
		return Result;
	}
}
