/**
 * A switch over an enum matches each enumerator by name. Enumerators carry
 * their underlying integer values, so a switch on an enum behaves like a
 * switch on those values while keeping the names readable.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchEnum
 * @Harness Function
 * @Tag Language.ControlFlow.SwitchEnum
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::SwitchEnum
 */

enum ECoverageSwitchState
{
	Idle = 0,
	Running = 1,
	Done = 2
}

namespace ControlFlowTest
{
	/**
	 * Observe that each enumerator selects its own case.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param State Selects the case to run
	 * @Inputs Idle gives 0, Running gives 1, Done gives 2
	 * @Return the value produced by the matching enumerator
	 */
	UFUNCTION()
	int EnumSwitchSelectsMatchingEnumerator(ECoverageSwitchState State)
	{
		switch (State)
		{
			case ECoverageSwitchState::Idle:
				return 0;
			case ECoverageSwitchState::Running:
				return 1;
			case ECoverageSwitchState::Done:
				return 2;
			default:
				return -1;
		}
	}

	/**
	 * Observe that an enum switch can be written against an integer value
	 * holding one of the enumerator values.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Integer holding an enumerator value
	 * @Inputs The integer form of Idle, Running, and Done
	 * @Return the matching enumerator's value, or -1 when nothing matches
	 */
	UFUNCTION()
	int EnumSwitchAcceptsIntegerValue(int Value)
	{
		switch (ECoverageSwitchState(Value))
		{
			case ECoverageSwitchState::Idle:
				return 0;
			case ECoverageSwitchState::Running:
				return 1;
			case ECoverageSwitchState::Done:
				return 2;
			default:
				return -1;
		}
	}

	/**
	 * Observe the zero boundary: the first enumerator is the default-valued
	 * one and is reachable.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Inputs The Idle enumerator, whose value is 0
	 * @Return 0 when the zero-valued enumerator matches
	 * @Boundary zero enumerator
	 */
	UFUNCTION()
	int EnumSwitchMatchesZeroEnumerator()
	{
		return EnumSwitchSelectsMatchingEnumerator(ECoverageSwitchState::Idle);
	}
}
