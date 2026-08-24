// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=af7a619ddd335a215b60685eb9cc8b18f480006ea79007b8d032ec9ca4ee7b19; lines 82-84.
// Oracle: compile fails — non-bool condition (integer 5).
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if (5)
	{
	}
}
