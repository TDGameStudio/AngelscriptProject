// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=9b0ae4dffb595ba199aa907c05a8b3e45ff3ef9b1c3696f910120d6cf2af430e; lines 103-105.
// Oracle: compile fails — else without if.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	else
	{
	}
}
