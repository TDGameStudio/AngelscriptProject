/**
 * A case label outside a switch is rejected: case only appears inside a
 * switch body. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.CaseOutsideSwitch
 * @Harness CompileReject
 * @Tag Language.ControlFlow.CaseOutsideSwitch
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs A case label at function scope with no enclosing switch
 * @Return does not compile; diagnostic "case outside of a switch"
 */

void Test()
{
	case 1:
		int X = 0;
}
