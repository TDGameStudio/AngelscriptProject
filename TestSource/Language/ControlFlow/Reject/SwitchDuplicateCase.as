/**
 * Two case labels with the same value are rejected: the switch could not
 * decide which body to run. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchDuplicateCase
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchDuplicateCase
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs Two case 1 labels in the same switch
 * @Return does not compile; diagnostic "duplicate case label"
 */

void Test()
{
	int X = 1;
	switch (X)
	{
		case 1:
			break;
		case 1:
			break;
	}
}
