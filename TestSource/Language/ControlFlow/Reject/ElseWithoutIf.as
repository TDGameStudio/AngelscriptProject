/**
 * An else with no matching if is rejected: else can only follow an if body.
 * This file is the illegal program itself; do not add the if, since the
 * missing one is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ElseWithoutIf
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ElseWithoutIf
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs else { } at function scope with no preceding if
 * @Return does not compile; diagnostic "else without a matching if"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=9b0ae4dffb595ba199aa907c05a8b3e45ff3ef9b1c3696f910120d6cf2af430e; lines 103-105.
 * @Provenance Oracle: compile fails — else without if.
 */

void Test()
{
	else
	{
	}
}
