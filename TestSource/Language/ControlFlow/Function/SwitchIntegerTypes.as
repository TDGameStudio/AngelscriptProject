/**
 * A switch works over the integer types, so the same selection applies to
 * int8, int16, int64, uint8, and uint. Each type compares against case labels
 * of its own width, and a value matching nothing falls to default.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchIntegerTypes
 * @Harness Function
 * @Tag Language.ControlFlow.SwitchIntegerTypes
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::SwitchTypes
 * @Provenance Oracle: SwitchInt8(1) == 10; SwitchInt16(100) == 1; SwitchInt64(1000) == 1;
 * @Provenance SwitchUInt8(5) == 50; SwitchUInt(42) == 1.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a switch over int8.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 1 gives 10, case 2 gives 20, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchOverInt8(int8 Value)
	{
		switch (Value)
		{
			case 1:
				return 10;
			case 2:
				return 20;
			default:
				return 0;
		}
	}

	/**
	 * Observe a switch over int16.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 100 gives 1, case 200 gives 2, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchOverInt16(int16 Value)
	{
		switch (Value)
		{
			case 100:
				return 1;
			case 200:
				return 2;
			default:
				return 0;
		}
	}

	/**
	 * Observe a switch over int64.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 1000 gives 1, case 2000 gives 2, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchOverInt64(int64 Value)
	{
		switch (Value)
		{
			case 1000:
				return 1;
			case 2000:
				return 2;
			default:
				return 0;
		}
	}

	/**
	 * Observe a switch over uint8.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 5 gives 50, case 10 gives 100, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchOverUint8(uint8 Value)
	{
		switch (Value)
		{
			case 5:
				return 50;
			case 10:
				return 100;
			default:
				return 0;
		}
	}

	/**
	 * Observe a switch over uint.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Param Value Selects the case to run
	 * @Inputs case 42 gives 1, case 100 gives 2, default gives 0
	 * @Return the value produced by the matching case
	 */
	UFUNCTION()
	int SwitchOverUint(uint Value)
	{
		switch (Value)
		{
			case 42:
				return 1;
			case 100:
				return 2;
			default:
				return 0;
		}
	}

	/**
	 * Observe the zero default across every integer width: a zero value
	 * matches no case and falls to default.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Switch
	 * @Inputs Zero in each of the five integer types
	 * @Return true when all five fall to default and return 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool IntegerSwitchZeroFallsToDefault()
	{
		if (SwitchOverInt8(int8(0)) != 0)
		{
			return false;
		}
		if (SwitchOverInt16(int16(0)) != 0)
		{
			return false;
		}
		if (SwitchOverInt64(int64(0)) != 0)
		{
			return false;
		}
		if (SwitchOverUint8(uint8(0)) != 0)
		{
			return false;
		}
		return SwitchOverUint(uint(0)) == 0;
	}
}
