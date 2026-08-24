// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=5131f6b1fffe4a04dda8b5940c45553f7fad7df014a43dccd8682a74c6798e3d; lines 96-98.
// Oracle: compile fails — empty if condition.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if ()
	{
	}
}
