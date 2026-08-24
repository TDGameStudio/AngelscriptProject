// Theme: Language.ControlFlow.If. Isolated compile-fail from IfElse_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
// sha256=f1fe3d33fdda2cf10ae65849cdff7158d4588355f05baaa87e15a59101f19861; lines 124-126.
// Oracle: compile fails — string used as if condition.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	if ("hello")
	{
	}
}
