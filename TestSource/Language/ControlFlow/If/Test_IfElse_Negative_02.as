// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=3bca7e479926bb2257fd28cea3354336181d6a29bb064a4d9f7d71f9522e7506; lines 89-91.
// Oracle: compile fails — missing parentheses around if condition.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if true
	{
	}
}
