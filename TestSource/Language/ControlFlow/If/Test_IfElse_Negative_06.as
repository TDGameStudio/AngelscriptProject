// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=5c587f588326bc22200c9f64f98976219cdffc01295b9fb5083b50b0dbc6e358; lines 117-119.
// Oracle: compile fails — float used as if condition.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if (1.0f)
	{
	}
}
