// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=4f576dc12e8f08182409630b60e7493c07c02e7a636b3b534979009436e44d6b; lines 110-112.
// Oracle: compile fails — integer used as if condition.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	int X = 0;
	if (X)
	{
	}
}
