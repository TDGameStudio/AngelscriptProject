/**
 * A string case label is rejected: case labels must be integral constants.
 * This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchStringCaseLabel
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchStringCaseLabel
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs case "hello" on an int switch expression
 * @Return does not compile; diagnostic "case label must be an integral constant"
 */

void Test()
{
	int X = 1;
	switch (X)
	{
		case "hello":
			break;
	}
}
