/**
 * An if condition that is just an int variable is rejected: the condition
 * must be a boolean expression, not a bare integer. This file is the illegal
 * program itself; do not add a comparison, since the bare integer is the
 * point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfVariableIntegerCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfVariableIntegerCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if (X) { } where X is a local int
 * @Return does not compile; diagnostic "if condition must be a boolean expression"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=4f576dc12e8f08182409630b60e7493c07c02e7a636b3b534979009436e44d6b; lines 110-112.
 * @Provenance Oracle: compile fails — integer used as if condition.
 */

void Test()
{
	int X = 0;
	if (X)
	{
	}
}
