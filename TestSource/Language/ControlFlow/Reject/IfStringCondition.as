/**
 * A string if condition is rejected: the condition must be a boolean
 * expression, and a string is not coerced to one. This file is the illegal
 * program itself; do not add a comparison, since the bare string is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfStringCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfStringCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if ("hello") { }
 * @Return does not compile; diagnostic "if condition must be a boolean expression"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=f1fe3d33fdda2cf10ae65849cdff7158d4588355f05baaa87e15a59101f19861; lines 124-126.
 * @Provenance Oracle: compile fails — string used as if condition.
 */

void Test()
{
	if ("hello")
	{
	}
}
