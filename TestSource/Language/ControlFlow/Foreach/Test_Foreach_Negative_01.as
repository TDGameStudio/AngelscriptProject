// Theme: Language.ControlFlow.Foreach. Isolated compile-fail from Foreach_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Negative
// sha256=fbb1cdb524f6a82a5e1d13c4c225afa45bdeb6007e0996670eb1d362f1cf0230; lines 485-487.
// Oracle: compile fails — foreach over a non-iterable int.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	int X = 5;
	for (int Val : X)
	{
	}
}
