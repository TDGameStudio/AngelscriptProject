/**
 * A switch selects one case by matching the value against each case label,
 * falling back to default when nothing matches. Each case label is a
 * compile-time constant, and the body runs until a break or the end of the
 * switch.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchBasic
 * @Harness Function
 * @Tag Language.ControlFlow.SwitchBasic
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::SwitchBasic
 */

namespace ControlFlowTest
{
	/**
	 * Observe that each case label selects its own result.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 1 gives 10, case 2 gives 20, default gives 99
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchSelectsMatchingCase(int Value)
	{
		switch (Value)
		{
			case 1:
				return 10;
			case 2:
				return 20;
			case 3:
				return 30;
			default:
				return 99;
		}
	}

	/**
	 * Observe the default branch: a value matching no case lands there.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Inputs A value that matches none of the case labels
	 * @Return 99 when the default branch runs
	 * @Boundary no matching case
	 */
	UFUNCTION()
	int SwitchFallsBackToDefault()
	{
		return SwitchSelectsMatchingCase(0);
	}

	/**
	 * Observe that cases after the first are still reachable.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Inputs Values 2 and 3
	 * @Return true when case 2 gives 20 and case 3 gives 30
	 */
	UFUNCTION()
	bool SwitchReachesLaterCases()
	{
		if (SwitchSelectsMatchingCase(2) != 20)
		{
			return false;
		}
		return SwitchSelectsMatchingCase(3) == 30;
	}
}
