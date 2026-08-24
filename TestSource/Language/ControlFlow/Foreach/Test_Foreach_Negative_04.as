// Theme: Language.ControlFlow.Foreach. Isolated compile-fail from Foreach_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Foreach_Negative
// sha256=c736c38ff8c67680a529870f0befd196ee1dab3be8cd460938e6f002a98338b5; lines 506-508.
// Oracle: compile fails — foreach over a literal int.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	for (int Val : 42)
	{
	}
}
