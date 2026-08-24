// Theme: Language.ControlFlow.Jump. Isolated compile-fail from BreakContinue_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
// sha256=6e3b7bfbe0962261b58eda1410b6added4231f54b3f87b1d884102dc98afd2c3; lines 390-392.
// Oracle: compile fails — Invalid 'continue' outside a loop.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	continue;
}
