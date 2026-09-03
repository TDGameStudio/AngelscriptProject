/**
 * A case label built from a variable is rejected: case labels must be
 * compile-time constants. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchVariableCaseLabel
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchVariableCaseLabel
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs case Y where Y is a local int
 * @Return does not compile; diagnostic "case label must be a constant"
 */

/** */
void Test()
{
	int X = 1;
	int Y = 2;
	switch (X)
	{
		case Y:
			break;
	}
}
