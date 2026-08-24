// Theme: Language.ControlFlow.Foreach. Isolated compile-fail from Foreach_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Negative
// sha256=a137b5115fd14de60fe9665a7e8ec46ca8db1484e1f0888e5371beed7b0b97fb; lines 513-515.
// Oracle: compile fails — foreach over a string literal.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	for (int Val : "hello")
	{
	}
}
