// Theme: Language.ControlFlow.Jump. Isolated compile-fail from BreakContinue_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
// sha256=65ef893941cb3f7e3816e6d14e05fdc7a0f7ebeb3528d4b50a1cc10f814c3c1c; lines 406-408.
// Oracle: compile fails — Invalid 'continue' inside if but not a loop.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if (true)
	{
		continue;
	}
}
