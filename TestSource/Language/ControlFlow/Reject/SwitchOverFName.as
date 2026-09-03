/**
 * Switching over an FName is rejected: the switch expression must be an
 * integral number. This file is the illegal program itself; do not rewrite it
 * as a chain of comparisons.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.SwitchOverFName
 * @Harness CompileReject
 * @Tag Language.ControlFlow.SwitchOverFName
 * @Kind CompileReject
 * @Covers ControlFlow.Switch
 * @Inputs switch (Name) where Name is an FName, with an n"Alpha" case
 * @Return does not compile; diagnostic "switch expressions must be integral numbers"
 * @Provenance C++: AngelscriptCoverageConditionalTests.cpp::SwitchUnsupportedTypes
 * @Provenance sha256=558f222b278210ca8e5cea1c1d4891fb615b57e47f8aead55af76283914ecf4c; lines 753-764.
 * @Provenance Oracle: compile fails — switch expressions must be integral numbers (FName is rejected).
 */

int SwitchFName(FName Name)
{
	switch (Name)
	{
		case n"Alpha":
			return 1;
		default:
			return 0;
	}
}
