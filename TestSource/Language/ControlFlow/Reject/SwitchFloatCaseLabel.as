/**
 * A floating-point case label is rejected: case labels must be integral
 * constants. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchFloatCaseLabel
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchFloatCaseLabel
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs case 1.5f on an int switch expression
 * @Return does not compile; diagnostic "case label must be an integral constant"
 */

/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		case 1.5f:
			break;
	}
}
