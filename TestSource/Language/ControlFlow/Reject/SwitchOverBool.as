/**
 * Switching over a bool is rejected: the switch expression must be an
 * integral number, and bool is not accepted here. This file is the illegal
 * program itself; do not rewrite it as an if.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchOverBool
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchOverBool
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs switch (Value) where Value is a bool, with true and false cases
 * @Return does not compile; diagnostic "switch expressions must be integral numbers"
 * @Provenance C++: AngelscriptCoverageConditionalTests.cpp::SwitchUnsupportedTypes
 * @Provenance sha256=f5aafffc859c2f34529e5fafb0e241baf376999400c16f8489c70620e2f14b18; lines 732-744.
 * @Provenance Oracle: compile fails — switch expressions must be integral numbers (bool is rejected).
 */

/** */
int SwitchBool(bool Value)
{
	switch (Value)
	{
		case true:
			return 1;
		case false:
			return 0;
	}
	return -1;
}
