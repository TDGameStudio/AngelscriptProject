/**
 * A float if condition is rejected: the condition must be a boolean
 * expression, and a float is not coerced to one. This file is the illegal
 * program itself; do not add a comparison, since the bare float is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfFloatCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfFloatCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if (1.0f) { }
 * @Return does not compile; diagnostic "if condition must be a boolean expression"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=5c587f588326bc22200c9f64f98976219cdffc01295b9fb5083b50b0dbc6e358; lines 117-119.
 * @Provenance Oracle: compile fails — float used as if condition.
 */

/** */
void Test()
{
	if (1.0f)
	{
	}
}
