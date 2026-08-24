// Theme: Language.ControlFlow.Jump. Isolated compile-fail from BreakContinue_Negative.
// C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
// sha256=20b1873e55a903e345d7b8bb263dc2fc832b6609412653cd7fb4415842ff86bb; lines 382-384.
// Oracle: compile fails — Invalid 'break' outside a loop.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	break;
}
