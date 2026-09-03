/**
 * An if condition without parentheses is rejected: the condition must be
 * wrapped. This file is the illegal program itself; do not add the
 * parentheses, since the missing ones are the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfUnparenthesizedCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfUnparenthesizedCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if true { } with no parentheses around the condition
 * @Return does not compile; diagnostic "expected '(' after if"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=3bca7e479926bb2257fd28cea3354336181d6a29bb064a4d9f7d71f9522e7506; lines 89-91.
 * @Provenance Oracle: compile fails — missing parentheses around if condition.
 */

void Test()
{
	if true
	{
	}
}
