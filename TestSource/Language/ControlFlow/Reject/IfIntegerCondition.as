/**
 * An integer if condition is rejected: the condition must be a boolean
 * expression, and this fork does not treat a non-zero integer as true. This
 * file is the illegal program itself; do not rewrite it with a comparison.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfIntegerCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfIntegerCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if (5) { }
 * @Return does not compile; diagnostic "if condition must be a boolean expression"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=af7a619ddd335a215b60685eb9cc8b18f480006ea79007b8d032ec9ca4ee7b19; lines 82-84.
 * @Provenance Oracle: compile fails — non-bool condition (integer 5).
 */

void Test()
{
	if (5)
	{
	}
}
