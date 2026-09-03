/**
 * Two default labels in one switch are rejected: there can be only one
 * fallback. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchDuplicateDefault
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchDuplicateDefault
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs Two default labels in the same switch
 * @Return does not compile; diagnostic "duplicate default label"
 */

/** */
void Test()
{
	int X = 1;
	switch (X)
	{
		default:
			break;
		default:
			break;
	}
}
