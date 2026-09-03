/**
 * A switch body without braces is rejected: the cases must be grouped in a
 * block. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchWithoutBraces
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchWithoutBraces
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs switch (X) case 0: break; with no braces around the body
 * @Return does not compile; diagnostic "expected '{' after the switch expression"
 */

void Test()
{
	int X = 1;
	switch (X) case 0: break;
}
